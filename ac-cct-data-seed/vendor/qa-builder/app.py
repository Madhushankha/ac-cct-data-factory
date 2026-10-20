"""tt-qa: the /qa chat of a lower-env TripTracer node (F12 step 4, kb/source/proposals/F12-qa-scenario-generator).

A signed-in user describes a scenario; Claude (Bedrock, Opus 5.5 at max effort; Suresh, 2026-10-14) answers and calls two tools:
  generate_bookings(tags, count, summary)  pick templates from the anonymised pool of those scenario sets, give every
                                           identity a fresh fake (new ZZ locator, names, e-mails, phones), publish to
                                           this env's Kafka (MSK IAM), and return the locators
  check_booking(locator)                   ask this node's TripTracer search, with the user's own session, whether the
                                           booking has arrived
The pool is anonymised before it reaches the env (qa.py export-pool, on the laptop that holds the corpus) and lives in
the env's control bucket under qa/pool/. Every run is recorded under qa/runs/ (who, description, plan, locators).
Lower envs only: refuses to start unless TT_ENV is int, crt or bat.
"""
import asyncio
import datetime
import json
import zoneinfo
import os
import random
import re
import subprocess
import time
import uuid
import urllib.request
from pathlib import Path

import boto3
from botocore.config import Config
import jwt
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, JSONResponse, RedirectResponse

ENV = os.environ.get("TT_ENV", "")
if ENV not in ("int", "crt", "bat"):
    raise SystemExit(f"tt-qa runs only on a lower env (TT_ENV={ENV!r})")
REGION = "ca-central-1"
BUCKET = os.environ["TT_CONTROL_BUCKET"]
POOL = Path(os.environ.get("TT_QA_POOL", "/data/qa-pool"))
MODEL = os.environ.get("TT_QA_MODEL", "global.anthropic.claude-opus-5-5")
# Opus 5.5 thinks before it answers and its default effort is medium; the chat runs at max (Suresh, 2026-10-14).
EFFORT = os.environ.get("TT_QA_EFFORT", "max")
# TripTracer's session cookie: tt_session, an HS256 token tt-api mints with the env's JWT_SECRET (http/auth.rs).
# The edge forwards only TripTracer's own cookies (tt_session, tt-language, tt-theme), so the legacy
# .aircanada.com cct_auth_token never reaches the node behind CloudFront; it is read only as a fallback.
SESSION_COOKIES = ("tt_session", os.environ.get("AUTH_COOKIE_NAME", "cct_auth_token"))
API = os.environ.get("TT_QA_API", "http://127.0.0.1:3000")
BROKERS = os.environ["TT_QA_BROKERS_IAM"]  # the env's MSK IAM brokers (9098)
MAX_PER_RUN = 50

s3 = boto3.client("s3", region_name=REGION)
# A max-effort turn can think for minutes: the read timeout covers it (the default is 60 s).
bedrock = boto3.client("bedrock-runtime", region_name=REGION, config=Config(read_timeout=900, retries={"max_attempts": 2}))
_secret = None


def jwt_secret():
    global _secret
    if _secret is None:
        v = boto3.client("secretsmanager", region_name=REGION).get_secret_value(SecretId=os.environ["TT_SECRET_JWT"])["SecretString"]
        _secret = json.loads(v)["JWT_SECRET"] if v.lstrip().startswith("{") else v
    return _secret


def session_cookie(req: Request):
    """(name, value) of the first session cookie that verifies, else None."""
    for name in SESSION_COOKIES:
        tok = req.cookies.get(name)
        if not tok:
            continue
        try:
            jwt.decode(tok, jwt_secret(), algorithms=["HS256"], options={"require": ["exp"], "verify_aud": False, "verify_iss": False})
            return name, tok
        except jwt.PyJWTError:
            continue
    return None


def user_of(req: Request):
    sc = session_cookie(req)
    if not sc:
        return None
    c = jwt.decode(sc[1], jwt_secret(), algorithms=["HS256"], options={"verify_aud": False, "verify_iss": False})
    return c.get("email") or c.get("user") or c.get("preferred_username") or c.get("upn") or c.get("sub")


def sync_pool():
    POOL.mkdir(parents=True, exist_ok=True)
    pages = s3.get_paginator("list_objects_v2").paginate(Bucket=BUCKET, Prefix="qa/pool/")
    for page in pages:
        for o in page.get("Contents", []):
            dest = POOL / o["Key"][len("qa/pool/"):]
            if not dest.exists() or dest.stat().st_size != o["Size"]:
                dest.parent.mkdir(parents=True, exist_ok=True)
                s3.download_file(BUCKET, o["Key"], str(dest))
    return json.loads((POOL / "tags.json").read_text())


TAGS = sync_pool()

import itinerary  # noqa: E402  (free-form itineraries: rewrite a template booking to requested flights and dates)
import timeline  # noqa: E402  (timeline scenarios: append schedule changes, cancellations and rebookings)


def _pool_messages(loc):
    raw = subprocess.run(["zstd", "-dc", str(POOL / "bookings" / f"{loc}.jsonl.zst")], capture_output=True, check=True).stdout.decode()
    return [json.loads(l) for l in raw.splitlines() if l]


def _shapes():
    """Each pool booking's shape: air-segment count and passenger count (for matching a requested itinerary)."""
    out = {}
    for f in (POOL / "bookings").glob("*.jsonl.zst"):
        loc = f.name.split(".")[0]
        try:
            m = _pool_messages(loc)
            out[loc] = (len(itinerary.template_segments(m)), itinerary.passengers(m))
        except Exception:  # noqa: BLE001  (a template that cannot be read is simply never chosen)
            pass
    return out


SHAPES = _shapes()


# ---------- re-identification of a pool booking (already anonymised; this gives it fresh fakes per run) ----------
FIRST = ["ALEX", "JORDAN", "TAYLOR", "MORGAN", "CASEY", "RILEY", "JAMIE", "AVERY", "QUINN", "ROWAN", "SAGE", "DREW"]
LAST = ["TESTER", "SAMPLE", "EXAMPLE", "MOCKWELL", "FAKERSON", "DUMMY", "PLACEHOLD", "SYNTHIA", "NULLMAN", "VOIDSON"]


def reidentify(lines, rng):
    """Every ZZ locator, synthetic name, synth.test e-mail, +1-555 phone and cross-feed id (itinerary.fresh_ids) in a
    pool booking gets a new value."""
    text = "\n".join(lines)
    subs = {}
    for loc in sorted(set(re.findall(r"(?<![A-Z0-9])ZZ[A-Z0-9]{4}(?![A-Z0-9])", text))):
        subs[loc] = "ZZ" + "".join(rng.choice("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") for _ in range(4))
    for n in FIRST + LAST:
        subs[n] = rng.choice(FIRST if n in FIRST else LAST)
    for e in set(re.findall(r"synth-\d+@synth\.test", text)):
        subs[e] = f"synth-{rng.randrange(10**8)}@synth.test"
    for p in set(re.findall(r"\+1-555-\d{7}", text)):
        subs[p] = "+1-555-" + "".join(rng.choice("0123456789") for _ in range(7))
    text = itinerary.fresh_ids(text, rng)  # DCS passenger ids, ticket numbers, bag tags: unique per copy, as in real data
    if subs:
        text = re.sub("|".join(r"(?<![A-Za-z0-9])" + re.escape(k) + r"(?![A-Za-z0-9])" for k in sorted(subs, key=len, reverse=True)),
                      lambda m: subs[m.group(0)], text)
    return text.split("\n"), {k: v for k, v in subs.items() if k.startswith("ZZ")}


def env_topic(prod_topic):
    if prod_topic.startswith("CUSTOMER-PROFILE-EVENTS"):
        return "CUSTOMER-PROFILE-EVENTS-" + ENV.upper()
    base = re.sub(r"^emh-prd\.(.*)-PRD$", r"\1", prod_topic)
    return {"int": f"emh-int.{base}-INT", "crt": f"emh-dev.{base}-UAT", "bat": f"emh-dev.{base}-INT"}[ENV]


def producer():
    from aws_msk_iam_sasl_signer import MSKAuthTokenProvider
    from confluent_kafka import Producer

    def token(_cfg):
        t, exp_ms = MSKAuthTokenProvider.generate_auth_token(REGION)
        return t, exp_ms / 1000
    return Producer({"bootstrap.servers": BROKERS, "security.protocol": "SASL_SSL", "sasl.mechanisms": "OAUTHBEARER",
                     "oauth_cb": token, "acks": "all", "linger.ms": 5})


def generate_bookings(tags, count, summary, who, description, itin=None, pax=None, steps=None):
    count = max(1, min(int(count), MAX_PER_RUN))
    pool, note = None, None
    for t in tags:
        s = set(TAGS.get(t, []))
        pool = s if pool is None else pool & s
    if itin:
        # A template of the itinerary's shape: same air-segment count (and passenger count when given); the scenario
        # sets narrow it when they can, and are dropped (with a note) when no template of that shape is in them.
        n = len(itin.get("segments") or [])
        shaped = {l for l, (segs, p) in SHAPES.items() if segs == n and (not pax or p == int(pax))}
        if pool is not None and pool & shaped:
            pool = pool & shaped
        else:
            if pool is not None:
                note = f"no template in {tags} has {n} segments" + (f" and {pax} passengers" if pax else "") + "; used another booking of that shape"
            pool = shaped
        if not pool:
            return {"error": f"no template booking has {n} air segments" + (f" and {pax} passengers" if pax else "")}
    pool = sorted(pool or [])
    if not pool:
        return {"error": f"no template booking is in every one of {tags}; try fewer or broader scenario sets"}
    rng = random.Random(time.time_ns())
    order = rng.sample(pool, len(pool))
    msgs, locators = [], []
    # Each booking takes the next template that can carry the itinerary and timeline (a template whose kept history
    # has no PNR version, or fewer segments than a step names, is skipped); templates repeat when count > pool.
    built, last_err, tries = 0, None, 0
    while built < count and tries < max(3 * count, len(order)):
        loc = order[tries % len(order)]; tries += 1
        msgs_t = _pool_messages(loc)
        try:
            if itin:
                msgs_t = itinerary.rewrite(msgs_t, itin)
            if steps:
                msgs_t = timeline.apply(msgs_t, steps, rng=rng)
            if itin:
                # The booking must end holding the requested flights (less any the timeline cancels). A template whose
                # own newest version had already dropped its flight (a standby passenger removed, a cancelled booking)
                # gave an itinerary booking that searched as NO_FLIGHTS (ZZCMG1 from template ZZFOEK, INT, 2026-10-14).
                want = len(itin.get("segments") or []) - sum(1 for st in timeline.merged_rebooks(steps or []) if st.get("kind") == "cancel")
                have = len(timeline.flights_left(msgs_t))
                if have != want:
                    raise ValueError(f"template ends with {have} flights held, the request needs {want}")
        except (ValueError, KeyError) as e:
            last_err = e
            continue
        built += 1
        lines, newlocs = reidentify([json.dumps(m) for m in msgs_t], rng)
        locators.append(newlocs.get(loc, loc))
        for l in lines:
            m = json.loads(l)
            key = re.search(r'"(ZZ[A-Z0-9]{4})"', m["value"])
            msgs.append((m["ts"], env_topic(m["prodTopic"]), m["value"], key.group(1) if key else None))
    if not built:
        return {"error": f"{'timeline' if steps else 'itinerary'}: no template could carry it ({last_err})"}
    msgs.sort(key=lambda x: x[0])
    p, errs, acked = producer(), [], []
    for _ts, topic, value, key in msgs:
        p.produce(topic, value.encode(), key=key, on_delivery=lambda e, _m: errs.append(str(e)) if e else acked.append(1))
        p.poll(0)
    left = p.flush(120)
    run = {"at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()), "env": ENV, "who": who, "description": description,
           "plan": {"tags": tags, "count": count, "summary": summary, "itinerary": itin, "passengers": pax, "timeline": steps},
           "locators": locators, "messages": len(msgs),
           "delivered": len(acked), "undelivered": left, "errors": errs[:5]}
    s3.put_object(Bucket=BUCKET, Key=f"qa/runs/{run['at']}-{rng.randrange(10**6)}.json", Body=json.dumps(run).encode())
    res = {k: run[k] for k in ("locators", "messages", "delivered", "undelivered", "errors")}
    if itin and note:
        res["note"] = note
    return res


def check_booking(locator, cookie):
    """cookie is the user's own (name, value) session cookie, passed to tt-api as is."""
    # The search term rides the x-tt-search-term header, never the URL: tt-api ignores ?q= and answers 400 to a
    # typed search with no term (booking references stay out of URLs and access logs).
    req = urllib.request.Request(f"{API}/api/search/bookings?type=pnr",
                                 headers={"Cookie": f"{cookie[0]}={cookie[1]}", "x-tt-search-term": locator})
    try:
        with urllib.request.urlopen(req, timeout=15) as r:
            body = json.loads(r.read().decode())
    except Exception as e:  # noqa: BLE001
        return {"found": False, "error": str(e)[:200]}
    rows = body.get("results") or body.get("rows") or body.get("bookings") or []
    return {"found": bool(rows), "rows": rows[:3]}


TOOLS = [
    {"toolSpec": {"name": "generate_bookings", "description": "Generate bookings of the given scenario kinds in this environment: real anonymised Air Canada bookings, re-identified with fresh synthetic identities, published to Kafka. Returns the ZZ booking references.",
                  "inputSchema": {"json": {"type": "object", "required": ["tags", "count", "summary"], "properties": {
                      "tags": {"type": "array", "items": {"type": "string"}, "description": "Scenario sets; a booking must be in every one"},
                      "count": {"type": "integer", "minimum": 1, "maximum": MAX_PER_RUN},
                      "summary": {"type": "string"},
                      "itinerary": {"type": "object", "description": "Optional free-form itinerary. Each generated booking gets exactly these flights; the booking's whole event history moves in time to match.",
                                    "required": ["segments"], "properties": {"segments": {"type": "array", "minItems": 1, "items": {"type": "object",
                                        "required": ["carrier", "number", "from", "to", "depart"], "properties": {
                                            "carrier": {"type": "string", "description": "IATA airline code, e.g. AC"},
                                            "number": {"type": "string", "description": "Flight number, e.g. 301"},
                                            "from": {"type": "string", "description": "IATA airport code"},
                                            "to": {"type": "string", "description": "IATA airport code"},
                                            "depart": {"type": "string", "description": "Local departure date-time, YYYY-MM-DDTHH:MM"},
                                            "arrive": {"type": "string", "description": "Optional local arrival date-time, YYYY-MM-DDTHH:MM (else the template flight's duration)"}}}}}},
                      "passengers": {"type": "integer", "minimum": 1, "maximum": 9, "description": "Optional: passengers per booking"},
                      "timeline": {"type": "array", "description": "Optional booking changes after it was made, in order, each one new PNR version: schedule_change (segment, minutes: + later / - earlier), cancel (segment: the flight is cancelled and not replaced), rebook (segment, carrier, number, depart, optional arrive: replaces that segment with the new flight, the cancellation included, so do not add a cancel step before it); and two flight-day steps that are not PNR versions: delay (segment, minutes, optional IATA delay 'code', default 93) sends the flight's FDM status with the delay, and its departure and arrival once those times are past; check_in (segment, optional channel WEB|KIOSK|AIRPORT|MOBILE) accepts every passenger on that flight; boarding (segment, optional channel) boards them (checking them in too if needed); bags (segment = first bag segment, optional through = last, count per passenger, outcome delivered|delayed|delayed_delivered; delayed needs 2+ segments: the bag misses the last connection) sends the baggage events. Give check_in an 'at' within 24 h before departure, boarding about 30 min before, bags at check-in time. Segments count from 1 in departure order. Optional 'at' (UTC YYYY-MM-DDTHH:MM, before now); default spread between the booking's last event and now.",
                                   "items": {"type": "object", "required": ["kind", "segment"], "properties": {
                                       "kind": {"type": "string", "enum": ["schedule_change", "cancel", "rebook", "delay", "check_in", "boarding", "bags"]},
                                       "code": {"type": "string"}, "channel": {"type": "string"},
                                       "through": {"type": "integer", "minimum": 1}, "count": {"type": "integer", "minimum": 1, "maximum": 3},
                                       "outcome": {"type": "string", "enum": ["delivered", "delayed", "delayed_delivered"]},
                                       "segment": {"type": "integer", "minimum": 1},
                                       "minutes": {"type": "integer"},
                                       "carrier": {"type": "string"}, "number": {"type": "string"},
                                       "depart": {"type": "string"}, "arrive": {"type": "string"}, "at": {"type": "string"}}}}}}}}},
    {"toolSpec": {"name": "check_booking", "description": "Whether a ZZ booking reference has arrived in this environment's TripTracer yet (ingestion takes seconds to a minute).",
                  "inputSchema": {"json": {"type": "object", "required": ["locator"], "properties": {"locator": {"type": "string"}}}}}},
]


def system_prompt():
    vocab = "\n".join(f"- {t} ({len(v)})" for t, v in sorted(TAGS.items()))
    # Today, so "two days from now" or "next Tuesday" resolve without asking (Suresh's test, 2026-10-14: the chat
    # asked the tester for today's date). Eastern, the testers' clock.
    today = datetime.datetime.now(zoneinfo.ZoneInfo("America/Toronto"))
    return (f"Today is {today:%A %Y-%m-%d}, {today:%H:%M} Toronto time. "
            f"You are the QA scenario assistant of TripTracer's {ENV.upper()} environment. Testers describe travel "
            "scenarios; you generate matching test bookings by calling generate_bookings with scenario sets chosen only "
            "from this vocabulary (name and number of templates):\n" + vocab + "\n\nEach generated booking is a real Air "
            "Canada booking of that kind, anonymised (ZZ booking reference, synthetic names). When the tester names flights, "
            "routes or dates, pass them as 'itinerary' (every segment: carrier, flight number, from, to, local departure "
            "YYYY-MM-DDTHH:MM; invent sensible Air Canada flight numbers and times when only a route or day is given, and "
            "say so) and 'passengers' when a party size is given: the booking then gets exactly those flights and its "
            "whole history moves to those dates. Without an itinerary bookings replay their real flights and dates. For "
            "changes after booking (a schedule change, a cancellation, a rebooking, a flight delay, check-in, boarding, checked bags) pass 'timeline' "
            "steps in order; give an itinerary too when the tester names flights, so segment numbers are known. Flight "
            "A completed delayed flight (for disruption checks) needs a past itinerary. Named passengers are not supported. After generating, call check_booking for each "
            "reference (it may need a few tries) and tell the tester the references to open in TripTracer. Be brief.")


app = FastAPI()
PAGE = (Path(__file__).parent / "index.html").read_text()


# ---------- the builder sidecar of the deep QA agent (contracts.md §2): /tools/*, loopback callers only ----------
def publish_messages(rows):
    """rows: (feed, prodTopic, key, value) -> (delivered, undelivered, errors). Broker acknowledgements only count."""
    p, errs, acked = producer(), [], []
    for _feed, prod_topic, key, value in rows:
        p.produce(env_topic(prod_topic), value.encode(), key=key, on_delivery=lambda e, _m: errs.append(str(e)) if e else acked.append(1))
        p.poll(0)
    left = p.flush(120)
    return len(acked), left, errs


def record_run(run):
    """qa/runs/: who, plan, locators, counts; tester details are noted as used, never their values."""
    s3.put_object(Bucket=BUCKET, Key=f"qa/runs/{run['at']}-{random.randrange(10**6)}.json", Body=json.dumps(run).encode())


import sidecar  # noqa: E402

sidecar.configure(env=ENV, pool=POOL, api=API, publish=publish_messages, record_run=record_run,
                  oracle=os.environ.get("TT_QA_ORACLE_VALIDATE", "0") == "1")
app.include_router(sidecar.router)


@app.get("/qa")
@app.get("/qa/")
def page(req: Request):
    if not user_of(req):
        return RedirectResponse("/login?next=%2Fqa%2F")
    return HTMLResponse(PAGE.replace("{{ENV}}", ENV.upper()))


@app.post("/qa/api/chat")
async def chat(req: Request):
    who = user_of(req)
    if not who:
        return JSONResponse({"error": "sign in"}, status_code=401)
    msgs = (await req.json())["messages"][-20:]
    convo = [{"role": m["role"], "content": [{"text": m["text"]}]} for m in msgs if m.get("text")]
    description = next((m["text"] for m in reversed(msgs) if m["role"] == "user"), "")
    cookie = session_cookie(req)
    # The lower-env edge (API Gateway HTTP API) buffers a response and ends it at 30 s, so a long Opus turn cannot
    # stream through it (Error 504, 2026-10-14). The turn runs here as a job; the page polls its lines.
    for k in [k for k, j in JOBS.items() if j["done"] and time.time() - j["at"] > 600]:
        JOBS.pop(k)
    jid = uuid.uuid4().hex
    JOBS[jid] = {"who": who, "lines": [], "done": False, "at": time.time()}

    async def run():
        try:
            async for l in turns(convo, description, who, cookie):
                JOBS[jid]["lines"].append(json.loads(l))
        except Exception as e:  # noqa: BLE001  (the tester sees the failure instead of a page that waits forever)
            JOBS[jid]["lines"].append({"error": f"{type(e).__name__}: {e}"})
        JOBS[jid].update(done=True, at=time.time())
    JOBS[jid]["task"] = asyncio.ensure_future(run())  # held, so the loop does not drop it
    return {"job": jid}


@app.get("/qa/api/chat/{jid}")
def chat_poll(jid: str, req: Request, start: int = 0):
    j = JOBS.get(jid)
    if not j or j["who"] != user_of(req):
        return JSONResponse({"error": "no such chat turn"}, status_code=404)
    return {"lines": j["lines"][start:], "done": j["done"]}


JOBS = {}  # ponytail: in-memory, one uvicorn worker; a restart loses turns in flight (the page says so)


async def waiting(work):
    """Run `work` off the event loop; yield a progress line every 10 s until it ends, then its result.
    The edge (CloudFront, 30 s origin read timeout) drops a response that sends nothing for that long."""
    task = asyncio.ensure_future(asyncio.to_thread(work))
    while True:
        done, _ = await asyncio.wait({task}, timeout=10)
        if done:
            yield task.result()
            return
        yield None


async def turns(convo, description, who, cookie):
    """The chat as newline-delimited JSON: {"wait":true} while Claude or a tool works, {"step":…} per tool call,
    and a last line {"reply","steps"}."""
    line = lambda o: json.dumps(o) + "\n"
    steps = []
    for _ in range(8):
        call = lambda: bedrock.converse(modelId=MODEL, system=[{"text": system_prompt()}], messages=convo,
                                        toolConfig={"tools": TOOLS}, inferenceConfig={"maxTokens": 32000},
                                        additionalModelRequestFields={"output_config": {"effort": EFFORT}})
        async for r in waiting(call):
            if r is None:
                yield line({"wait": True})
        # The whole message goes back, reasoning blocks included and unchanged (Opus 5.5 checks them).
        out = r["output"]["message"]
        convo.append(out)
        uses = [c["toolUse"] for c in out["content"] if "toolUse" in c]
        if not uses:
            reply = " ".join(c.get("text", "") for c in out["content"] if "text" in c).strip()
            # Every booking the reply names links to its Trip (/booking/<pnr-id>, index.html bookingHref), so one the
            # model did not check is looked up here (Suresh, 2026-10-15: the search link found nothing).
            checked = {str(row.get("pnrId") or "").split("-")[0] for s in steps if s["tool"] == "check_booking"
                       for row in s["result"].get("rows") or []}
            for locator in sorted(set(re.findall(r"\bZZ[A-Z0-9]{4}\b", reply)) - checked):
                async for res in waiting(lambda locator=locator: check_booking(locator, cookie)):
                    if res is None:
                        yield line({"wait": True})
                steps.append({"tool": "check_booking", "input": {"locator": locator}, "result": res})
            yield line({"reply": reply, "steps": steps})
            return
        results = []
        for u in uses:
            def run(u=u):
                if u["name"] == "generate_bookings":
                    return generate_bookings(u["input"].get("tags", []), u["input"].get("count", 1), u["input"].get("summary", ""), who, description,
                                             u["input"].get("itinerary"), u["input"].get("passengers"), u["input"].get("timeline"))
                if u["name"] == "check_booking":
                    time.sleep(5)
                    return check_booking(u["input"].get("locator", ""), cookie)
                return {"error": "unknown tool"}
            async for res in waiting(run):
                if res is None:
                    yield line({"wait": True})
            step = {"tool": u["name"], "input": u["input"], "result": res}
            steps.append(step)
            yield line({"step": step})
            results.append({"toolResult": {"toolUseId": u["toolUseId"], "content": [{"json": res}]}})
        convo.append({"role": "user", "content": results})
    yield line({"reply": "Stopped after 8 tool steps; the steps above show where it got to.", "steps": steps})


@app.get("/qa/api/health")
def health():
    return {"ok": True, "env": ENV, "tags": len(TAGS), "templates": len({l for v in TAGS.values() for l in v})}
