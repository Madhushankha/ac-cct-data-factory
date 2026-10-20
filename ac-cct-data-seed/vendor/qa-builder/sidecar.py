"""The builder sidecar's tool routes (F12 contracts.md §2): `http://127.0.0.1:3100/tools/*`, loopback callers only.

  POST /tools/playbook  {"family"?}                         -> event families and timing norms
  POST /tools/pool      {"tags"?, "shape"?}                 -> local anonymised templates matching (refs + summaries)
  POST /tools/tester    the tester block                    -> {"testerRef"}   (kept in memory for 2 h, never logged or stored)
  POST /tools/build     {"plan", "seeds", "testerRef"?}      -> {"buildRef", "events", "byPhase", "byFamily", "locators", ...}
  POST /tools/validate  {"buildRef"}                        -> {"ok", "rules": [...]}
  POST /tools/timeline  {"buildRef"}                        -> the built timeline for review (tester values are never in it)
  POST /tools/publish   {"buildRef"}                        -> {"delivered", "undelivered", "locators"}; refuses unless validate passed
  POST /tools/verify    {"locators", "cookie"?, "waitSeconds"?} -> per booking: found, Trip summary, EDS changes, DDS outcomes, score band

`configure()` wires the environment (pool, env, tt-api, the Kafka publisher and the run recorder); app.py does it at
start, the tests pass fakes. Runs and tester blocks live in memory only and expire after two hours.
"""
import asyncio
from datetime import datetime, timezone
import copy
import hashlib
import json
import logging
import re
import secrets
import threading
import time
import urllib.parse
import urllib.request
from pathlib import Path

from fastapi import APIRouter, HTTPException, Request

from builder import TESTER, TOPIC_FEED, Build, Exemplars, pool_index, kind_of, step_params
from playbook import PHASES, playbook
from validate import validate

TTL = 2 * 3600
_cfg = {"env": "", "pool": None, "api": "http://127.0.0.1:3000", "publish": None, "record_run": None, "oracle": True}
_runs, _testers, _pool_cache = {}, {}, {"index": None, "exemplars": None}


_index_lock = threading.Lock()
STEP_PARAMS = step_params()
# The plan builder.Plan reads; tt-api's build tool states the same shape in its schema (qa/tools.rs PLAN_SCHEMA).
PLAN_SHAPE = ('Expected {"passengers": [{"firstName", "lastName", "type"?, "email"?, "phone"?, ...}], "bounds": [{"segments": '
              '[{"carrier": "AC", "number": "834", "origin": "YUL", "destination": "MAD", "departure": "YYYY-MM-DDTHH:MM" (local), '
              '"arrival": "YYYY-MM-DDTHH:MM" (local), "operating"?: {"carrier", "number"}, "cabin"?, "bookingClass"?}]}], '
              '"booking"?: {"createdAt" | "createdDaysBefore"}, "phases": {"<phase>": [{"family": "<builder family>", '
              '"at": {"anchor": "booking|ticketing|departure[:k]|arrival[:k]|last_arrival", "offsetMinutes": n}, "params": {...}}]}, '
              '"surround"?: true}; phases are ' + ", ".join(PHASES) + "; families are the playbook's `families` keys; every step comes after the booking's creation (the seed supplies it).")


def configure(env, pool, api, publish, record_run, oracle=True, warm=True, now=None):
    _cfg.update(env=env, pool=pool, api=api, publish=publish, record_run=record_run, oracle=oracle,
                now=now or (lambda: datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")))
    _pool_cache.update(index=None, exemplars=Exemplars(pool))
    if warm and pool:
        threading.Thread(target=pool_rows, daemon=True, name="pool-index").start()


def pool_rows():
    """The pool's index, built once (off the event loop) and kept beside the pool as index.json, keyed by its files.
    Indexing reads every payload (about 2 minutes for 392 bookings on a laptop, more on a 2-vCPU node); built inside
    the request on the event loop it held every route, the node's /qa/api/health check included, and tt-api's call
    timed out (TTQ-QA-SIDECAR-POOL-INDEX-BLOCKS)."""
    pool = _cfg["pool"]
    with _index_lock:
        if _pool_cache["index"] is not None and _pool_cache.get("for") == pool:
            return _pool_cache["index"]
        rows = []
        if pool:
            files = sorted((Path(pool) / "bookings").glob("*.jsonl*")) if (Path(pool) / "bookings").exists() else []
            tags = Path(pool) / "tags.json"
            # "v2": the row shape (historyGapDays); a new field invalidates the saved index.
            key = hashlib.sha256(json.dumps(["v2"] + [[f.name, f.stat().st_size, f.stat().st_mtime_ns] for f in files + ([tags] if tags.exists() else [])]).encode()).hexdigest()
            cached = Path(pool) / "index.json"
            try:
                saved = json.loads(cached.read_text())
                rows = saved["rows"] if saved.get("key") == key else None
            except (OSError, ValueError, KeyError):
                rows = None
            if rows is None:
                rows = pool_index(pool)
                try:
                    cached.write_text(json.dumps({"key": key, "rows": rows}))
                except OSError:
                    pass  # a read-only pool still serves the index from memory
        _pool_cache.update(index=rows, **{"for": pool})
        return rows


def loopback(request: Request):
    host = request.client.host if request.client else ""
    if host not in ("127.0.0.1", "::1"):
        raise HTTPException(403, "the tool routes answer loopback callers only")


router = APIRouter(prefix="/tools")


def _sweep():
    now = time.time()
    for store in (_runs, _testers):
        for k in [k for k, v in store.items() if now - v["created"] > TTL]:
            del store[k]


def _run(ref):
    _sweep()
    run = _runs.get(ref or "")
    if run is None:
        raise HTTPException(404, "unknown or expired buildRef")
    return run


async def _body(request):
    try:
        return await request.json()
    except ValueError:
        raise HTTPException(400, "JSON body required") from None


@router.post("/playbook")
async def tool_playbook(request: Request):
    loopback(request)
    body = await _body(request)
    out = playbook(body.get("family"))
    for family, entry in out["families"].items():
        entry["params"] = STEP_PARAMS.get(family, [])  # what the step reads (TTQ-QA-STEP-PARAMS-UNSTATED)
    return out


@router.post("/pool")
async def tool_pool(request: Request):
    loopback(request)
    body = await _body(request)
    rows = [r for r in await asyncio.to_thread(pool_rows) if "error" not in r]
    tags = set(body.get("tags") or [])
    if tags:
        rows = [r for r in rows if tags <= set(r["tags"])]
    shape = body.get("shape") or {}
    if shape.get("segments"):
        rows = [r for r in rows if r["segments"] == shape["segments"]]
    if shape.get("passengers"):
        rows = [r for r in rows if r["passengers"] == shape["passengers"]]
    if shape.get("feeds"):
        rows = [r for r in rows if set(shape["feeds"]) <= set(r["feeds"])]
    if shape.get("minVersions"):
        rows = [r for r in rows if r["pnrVersions"] >= shape["minVersions"]]
    # Seeds whose history starts at their creation first: a late-starting one cannot carry early steps.
    rows.sort(key=lambda r: ((r.get("historyGapDays") or 0) > 0, -r["events"], r["ref"]))
    return {"matching": len(rows), "templates": rows[: body.get("limit", 25)]}


@router.post("/tester")
async def tool_tester(request: Request):
    """The tester block, by reference. Never logged, never written: memory for the run, two hours at most."""
    loopback(request)
    body = await _body(request)
    allowed = {"phone", "email", "firstName", "lastName", "dateOfBirth", "loyaltyNumber", "document"}
    values = {k: str(v) for k, v in body.items() if k in allowed and v}
    if not values:
        raise HTTPException(400, f"a tester block needs at least one of {sorted(allowed)}")
    _sweep()
    ref = "tester-" + secrets.token_urlsafe(12)
    _testers[ref] = {"values": values, "created": time.time()}
    return {"testerRef": ref, "fields": sorted(values)}


@router.post("/build")
async def tool_build(request: Request):
    loopback(request)
    body = await _body(request)
    plan, seeds = body.get("plan"), body.get("seeds") or []
    if not plan or not seeds:
        raise HTTPException(400, "plan and seeds are required")
    tester_ref = body.get("testerRef")
    if tester_ref and tester_ref not in _testers:
        raise HTTPException(404, "unknown or expired testerRef")
    try:
        # Off the event loop: a seed's identity table takes seconds on a large booking.
        build = await asyncio.to_thread(Build, plan, seeds, _cfg["pool"], exemplars=_pool_cache["exemplars"])
    except (KeyError, TypeError, AttributeError) as e:
        # A plan in another shape is the agent's to fix, so it gets the shape, not a 500 (TTQ-QA-PLAN-SHAPE-UNSTATED).
        raise HTTPException(422, f"the plan is not in the builder's shape ({type(e).__name__}: {e}). {PLAN_SHAPE}") from None
    except (ValueError, FileNotFoundError) as e:
        raise HTTPException(422, f"cannot build: {e}") from None
    except Exception as e:  # noqa: BLE001  (a builder bug: logged whole, and the agent reads what failed, not a bare 500)
        logging.getLogger("tt-qa").exception("build failed")
        raise HTTPException(500, f"the builder failed: {type(e).__name__}: {e}") from None
    build.drop_after(_cfg["now"]())  # no events after now (TTQ-QA-FUTURE-EVENTS-PUBLISHED)
    _sweep()
    ref = "build-" + secrets.token_urlsafe(9)
    _runs[ref] = {"build": build, "validation": None, "testerRef": tester_ref, "created": time.time(), "plan": plan}
    placeholders = {s["placeholder"] for s in build.tester_slots}
    if placeholders and not tester_ref:
        build.notes.add(f"the plan names tester fields {sorted(placeholders)} but no testerRef was given: the stand-ins publish")
    return {"buildRef": ref, **build.summary()}


@router.post("/validate")
async def tool_validate(request: Request):
    loopback(request)
    run = _run((await _body(request)).get("buildRef"))
    run["validation"] = validate(run["build"], oracle=_cfg["oracle"])
    return run["validation"]


@router.post("/timeline")
async def tool_timeline(request: Request):
    loopback(request)
    run = _run((await _body(request)).get("buildRef"))
    return {**run["build"].timeline(), "summary": run["build"].summary(), "validated": bool(run["validation"] and run["validation"]["ok"])}


def _set_pointer(obj, pointer, value):
    parts = pointer.strip("/").split("/")
    for p in parts[:-1]:
        obj = obj[int(p)] if isinstance(obj, list) else obj[p]
    last = parts[-1]
    if isinstance(obj, list):
        obj[int(last)] = value
    else:
        obj[last] = value


def substitute_tester(build, values):
    """The messages to publish: the tester's values in exactly the recorded slots, nowhere else.
    Returns (messages, fields used); raises when a value would appear outside its slots."""
    messages = [copy.deepcopy(m["obj"]) for m in build.messages]
    used = set()
    for s in build.tester_slots:
        v = values.get(s["placeholder"])
        if v is None:
            continue
        _set_pointer(messages[s["message"]], s["pointer"], v)
        used.add(s["placeholder"])
    # Leak check: each tester value may occur only at its slots.
    slots_by_message = {}
    for s in build.tester_slots:
        slots_by_message.setdefault(s["message"], []).append(s)
    for i, m in enumerate(messages):
        probe = copy.deepcopy(m)
        for s in slots_by_message.get(i, []):
            _set_pointer(probe, s["pointer"], "")
        text = json.dumps(probe)
        for field, v in values.items():
            if len(v) >= 3 and re.search(r"(?<![A-Za-z0-9@.])" + re.escape(v) + r"(?![A-Za-z0-9@])", text, re.IGNORECASE):
                raise HTTPException(409, f"tester {field} would reach a field outside its allowed slots in message {i}; publish refused")
    return messages, sorted(used)


@router.post("/publish")
async def tool_publish(request: Request):
    loopback(request)
    body = await _body(request)
    run = _run(body.get("buildRef"))
    if not run["validation"]:
        raise HTTPException(409, "validate the build first")
    if not run["validation"]["ok"]:
        raise HTTPException(409, "the build did not pass validation; publish refused")
    build = run["build"]
    tester = _testers.get(run["testerRef"] or "")
    messages, fields = substitute_tester(build, tester["values"] if tester else {})
    out = [(TOPIC_FEED.get(m["prodTopic"], m["prodTopic"]), m["prodTopic"], build.locator, json.dumps(obj, separators=(",", ":")))
           for m, obj in zip(build.messages, messages)]
    delivered, undelivered, errors = _cfg["publish"](out)
    record = {"at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()), "env": _cfg["env"], "who": body.get("who"), "buildRef": body.get("buildRef"),
              "description": body.get("description"), "plan": _plan_record(run["plan"]), "locators": [build.locator], "messages": len(out),
              "byFamily": build.summary()["byFamily"], "delivered": delivered, "undelivered": undelivered, "errors": errors[:5],
              "testerUsed": bool(fields), "testerFields": fields, "validation": [r["id"] for r in run["validation"]["rules"] if r["ok"]]}
    _cfg["record_run"](record)
    return {"delivered": delivered, "undelivered": undelivered, "locators": [build.locator], "errors": errors[:5], "testerUsed": bool(fields)}


def _plan_record(plan):
    """The plan as recorded: the tester's values never reach it (the plan carries placeholders), but to be sure any
    passenger field that is not a placeholder or a synthetic name is dropped."""
    p = copy.deepcopy(plan)
    for pax in p.get("passengers") or []:
        for k in list(pax):
            if k in ("email", "phone", "dateOfBirth", "loyaltyNumber", "document") and not TESTER.search(str(pax[k])):
                pax[k] = "<redacted>"
    return p


def _get(url, headers):
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req, timeout=20) as r:
        return json.loads(r.read().decode())


def summarize_trip(trip):
    """The parts of a Trip the agent compares with its plan: summary, EDS changes, DDS outcomes, score band."""
    def pick(row, keys):
        return {k: row[k] for k in keys if k in row}
    changes = [pick(c, ("changeType", "change", "type", "bound", "boundNumber", "at", "detectedAt", "flight", "delayMinutes", "entity", "summary", "title"))
               for c in trip.get("changes") or [] if isinstance(c, dict)]
    assessment = (trip.get("compensation") or {}).get("assessment") or {}
    bounds = assessment.get("bounds") if isinstance(assessment, dict) else None
    dds = []
    for b in bounds or ([assessment] if isinstance(assessment, dict) and assessment else []):
        if isinstance(b, dict):
            dds.append(pick(b, ("bound", "boundNumber", "regime", "eligibility", "outcome", "status", "reason", "decision", "compensation", "amount", "currency", "provisional")))
    scores = trip.get("disruptionScores")
    rows = scores.get("rows") if isinstance(scores, dict) else scores if isinstance(scores, list) else []
    order = ["low", "moderate", "high", "very_high"]
    bands = [r.get("band") for r in rows or [] if isinstance(r, dict) and r.get("band") in order]
    return {"summary": trip.get("summary"), "passengers": len(trip.get("passengers") or []), "segments": len(trip.get("segments") or []),
            "tickets": len(trip.get("tickets") or []), "baggage": len(trip.get("baggage") or []), "edsChanges": changes, "dds": dds,
            "scoreBand": max(bands, key=order.index) if bands else None, "updatedAt": trip.get("updatedAt")}


VERIFY_WAIT_S, VERIFY_EVERY_S = 120, 10


async def _search(loc, headers):
    """The booking's search row (its pnrId) or None; raises on an HTTP or network failure."""
    found = await asyncio.to_thread(_get, f"{_cfg['api']}/api/search/bookings?type=pnr", headers)
    rows = found.get("results") or found.get("rows") or found.get("bookings") or found.get("items") or []
    return next((r for r in rows if isinstance(r, dict) and loc in json.dumps(r)), None) if isinstance(rows, list) else None


@router.post("/verify")
async def tool_verify(request: Request):
    """Each booking as this env's TripTracer shows it, read as the user (tt-api passes its tt_session as `cookie`).
    Published events take a moment to be ingested, so a booking not found yet is searched again every 10 s for up to
    `waitSeconds` (default 120) before it is reported missing; reporting it at once made the agent revise and publish a
    duplicate (TTQ-QA-VERIFY-BEFORE-INGEST). The Trip is read whole: its first view and its deferred sections, where
    `changes` (the EDS change record) lives (trip_sections::DEFERRED; TTQ-QA-VERIFY-CHANGES-DEFERRED)."""
    loopback(request)
    body = await _body(request)
    cookie = body.get("cookie") or request.headers.get("cookie") or ""
    wait = max(0, min(int(body.get("waitSeconds", VERIFY_WAIT_S)), 240))  # inside tt-api's 300 s call timeout
    out, began = [], time.monotonic()  # one wait for the whole call: tt-api gives the sidecar 300 s
    for loc in (body.get("locators") or [])[:50]:
        loc = str(loc).strip().upper()
        if not re.fullmatch(r"[A-Z0-9]{6}", loc):
            out.append({"locator": loc, "found": False, "error": "not a locator"})
            continue
        headers = {"Cookie": cookie, "x-tt-search-term": loc, "Accept": "application/json"}
        row, hit = {"locator": loc, "found": False}, None
        while True:
            try:
                hit = await _search(loc, headers)
                row.pop("error", None)
            except Exception as e:  # noqa: BLE001  (a 401 or a refusal does not get better by waiting)
                row["error"] = f"search: {str(e)[:160]}"
                if "HTTP Error 4" in row["error"]:
                    break
            if hit or time.monotonic() - began >= wait:
                break
            await asyncio.sleep(VERIFY_EVERY_S)
        if hit:
            row["found"] = True
            pnr_id = hit.get("pnrId") or hit.get("id") or ""
            # mode=live, as TTUI reads every Trip (lib/trip-sections.ts): a lower env holds no stored projections and
            # answers 503 PROJECTION_SOURCE_UNAVAILABLE without it (2026-10-15, release-59 INT run; TTQ-QA-VERIFY-MODE-LIVE).
            base = f"{_cfg['api']}/api/trip/{urllib.parse.quote(loc)}?mode=live" + (f"&pnrId={urllib.parse.quote(pnr_id)}" if pnr_id else "")
            try:
                trip = await asyncio.to_thread(_get, base, headers)
                as_of = trip.get("asOf")
                deferred = await asyncio.to_thread(_get, base + "&sections=deferred"
                                                   + (f"&asOf={urllib.parse.quote(str(as_of))}" if as_of else ""), headers)
                # The Trip API wraps the Trip: {asOf, keys, source, deferred, trip: {...}} (2026-10-15: read unwrapped,
                # every booking looked empty, "hasn't built a trip yet"; TTQ-QA-VERIFY-TRIP-WRAPPED).
                inner = lambda body: body.get("trip") if isinstance(body.get("trip"), dict) else body  # noqa: E731
                row["trip"] = summarize_trip({**inner(trip), **{k: v for k, v in inner(deferred).items() if v is not None}})
            except Exception as e:  # noqa: BLE001
                row["error"] = f"trip: {str(e)[:160]}"
        elif "error" not in row:
            row["error"] = f"not in this environment's TripTracer after {wait} s"
        out.append(row)
    return {"bookings": out}


def kinds_of(build):
    return sorted({kind_of(m["obj"]) for m in build.messages})
