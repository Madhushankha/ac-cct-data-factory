"""Ask the new engine what it sees, and what it decides.

Two reads per booking, in this order, because the second is only meaningful after the first:

1. **the Trip** -- `GET /api/service/trips/{pnrId}?engine=raptor`: did the booking arrive, and did the
   disruption arrive with it? Passengers, segments, times, and per segment the delay, status and
   cause the engine actually holds.
2. **the verdict** -- `POST /api/dds-evaluations?engine=raptor`: does it agree with the spec?

Without the Trip, a verdict is ambiguous. Proven on INT on 2026-10-16: FD_PO_001 seeded cleanly,
35 of 35 checkpoints green, and Raptor answered NOT_ELIGIBLE / FD-APPR-NE-20 with `delayMinutes: 0`
and `promisedItinerary == actualItinerary`. The verdict alone looks like a rule disagreement. The
Trip shows what it really is: the booking reached the engine and the delay did not, because the FDM
is not ingested and `finalize` wrote `flight_leg` rows into the database instead -- rows an engine
that folds events never reads.

## Why this runs in a one-off task

The token must be signed with a key held in `cct-case-intake-int/app-secrets`
(`TRIPTRACER_SERVICE_KEY`), and INT's Secrets Manager admits that secret to the case-intake task
role alone. So the read runs where the key already is: a one-off task on the case-intake service,
with its command overridden, which is how the uat-scenarios kit's gate works. Nothing is granted to
this project, no key is copied, and the task only reads.

The call goes to tt-api directly. Case-services' own client is not used, and nor is its API: its
`_normalize_dds_output` would reshape the answer and its routes would record the request as case
intake's traffic. We want the engine's answer as the engine gives it.

The container command is replaced, so the task serves no traffic. At most `MAX_PNRS` bookings per
task, because the override has an 8 KiB ceiling.
"""
from __future__ import annotations

import argparse
import datetime as _dt
import json
import pathlib
import sys
import time

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from core import registry                                                   # noqa: E402

#: INT. The other environments differ only in these names.
ENVS = {
    "int": {"cluster": "cct-case-intake-int-cluster",
            "service": "cct-case-intake-int-service",
            "log_group": "/ecs/cct-case-intake-int"},
    "bat": {"cluster": "ac-cct-bat-ecs-cluster",
            "service": "ac-cct-bat-case-intake-ecs-fargate-service",
            "log_group": "/ecs/ac-cct-bat-case-intake"},
}
CONTAINER = "Container"
LOG_PREFIX = "api"
MARK = "TTGATE"
#: Bookings per gate task. The ECS command override holds 8 KiB and carries the inner script
#: (3,760 bytes) plus the ids (about 24 bytes each). Measured: 50 ids give a 5,200-byte override,
#: leaving room for roughly 124 more. 100 keeps real headroom for longer pnrIds; 25 was a guess.
MAX_PNRS = 100
TASK_WAIT_SECONDS = 300

#: Runs INSIDE the task. `__IDS__` is replaced with the list of pnrIds.
INNER = '''
import json, urllib.request, urllib.error
from case_intake_service.config.loader import get_settings
from case_intake_service.infrastructure.providers.trip_tracer.service_token import signer_from_settings
s = get_settings(); sig = signer_from_settings(s)
base = s.trip_tracer_live_api_base_url.rstrip("/")
M = "TTGATE"
def call(url, body=None):
    req = urllib.request.Request(url, data=(json.dumps(body).encode() if body else None),
        method=("POST" if body else "GET"),
        headers={"Content-Type": "application/json", "Accept": "application/json",
                 "Authorization": "Bearer " + sig.token(), "User-Agent": "ac-cct-data-seed-gate"})
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return 200, json.load(r)
    except urllib.error.HTTPError as ex:
        return ex.code, (ex.read() or b"")[:300].decode("utf-8", "replace")
    except Exception as ex:
        return 0, "%s: %s" % (type(ex).__name__, str(ex)[:200])
import time
WATCH, EVERY, WANT = __WATCH__, __EVERY__, __WANT__
def flown(t):
    """Is the booking in the state we are waiting for?

    Two conditions, because "something changed" is not good enough. When a delay is expected, wait
    for THAT delay: the leg may already report an earlier, wrong value from a previous publish, and
    stopping on it reads as success. Proven the hard way on YXHFMQ, where a stale delayMin of 60
    satisfied a looser condition while the corrected 240 was still in flight.
    """
    for sg in (t.get("segments") or []):
        got = sg.get("delayMin") or 0
        if WANT:
            if int(got) == int(WANT):
                return True
            continue
        if (sg.get("status") or "").upper() in ("ARR", "ARRIVED", "DEP", "DEPARTED", "LANDED") or got:
            return True
    return False
for pid in __IDS__:
    out = {"pnrId": pid}
    deadline = time.time() + WATCH
    while True:
        code, trip = call("%s/api/service/trips/%s?engine=raptor" % (base, pid))
        t = (trip.get("trip") or trip) if (code == 200 and isinstance(trip, dict)) else {}
        segs = [{k: sg.get(k) for k in ("flight", "status", "delayMin", "cause", "causeCode")}
                for sg in (t.get("segments") or [])]
        print(M, json.dumps({"pnrId": pid, "poll": True, "tripStatus": code,
                             "at": time.strftime("%H:%M:%SZ", time.gmtime()),
                             "segments": segs, "flown": flown(t)},
                            separators=(",", ":")), flush=True)
        if flown(t) or time.time() >= deadline:
            break
        time.sleep(EVERY)
    code, trip = call("%s/api/service/trips/%s?engine=raptor" % (base, pid))
    out["tripStatus"] = code
    if code == 200 and isinstance(trip, dict):
        t = trip.get("trip") or trip
        out["trip"] = {
            "counts": {k: len(t.get(k) or []) for k in ("passengers", "segments", "tickets", "ancillaries")},
            "segments": [{k: sg.get(k) for k in ("flight", "from", "to", "status", "delayMin",
                                                 "cause", "causeCode", "regimes")}
                         for sg in (t.get("segments") or [])][:8]}
    else:
        out["tripError"] = trip if isinstance(trip, str) else "unexpected shape"
    code, ev = call("%s/api/dds-evaluations?engine=raptor" % base, {"pnrId": pid})
    out["ddsStatus"] = code
    if code == 200 and isinstance(ev, dict):
        out["engine"] = {k: ev.get(k) for k in ("engine", "engineRelease", "rulesSha256", "evaluatedAt")}
        out["document"] = ev.get("document")
    else:
        out["ddsError"] = ev if isinstance(ev, str) else "unexpected shape"
    print(M, json.dumps(out, separators=(",", ":")), flush=True)
print(M, "done", flush=True)
'''


def _boto(env: str):
    import boto3
    session = boto3.Session(profile_name="int-cce" if env == "int" else None,
                            region_name="ca-central-1")
    return session.client("ecs"), session.client("logs")


def read(pnr_ids: list[str], env: str = "int", *, watch: int = 0,
         want_delay: int = 0, every: int = 20, log=print) -> dict[str, dict]:
    """Run one task that reads the Trip and the verdict for each booking, and return what it said."""
    if not pnr_ids:
        return {}
    if len(pnr_ids) > MAX_PNRS:
        raise ValueError(f"{len(pnr_ids)} bookings exceeds {MAX_PNRS} per task "
                         f"(the ECS command override holds 8 KiB)")
    cfg = ENVS[env]
    ecs, logs = _boto(env)

    svc = ecs.describe_services(cluster=cfg["cluster"], services=[cfg["service"]])["services"][0]
    script = (INNER.replace("__IDS__", json.dumps(pnr_ids))
                   .replace("__WATCH__", str(int(watch)))
                   .replace("__WANT__", str(int(want_delay or 0)))
                   .replace("__EVERY__", str(int(every or 20))))
    task = ecs.run_task(
        cluster=cfg["cluster"], taskDefinition=svc["taskDefinition"], launchType="FARGATE",
        networkConfiguration=svc["networkConfiguration"], startedBy="data-seed-gate",
        overrides={"containerOverrides": [{"name": CONTAINER, "command": ["python", "-c", script]}]})
    if task.get("failures"):
        raise RuntimeError(f"run_task refused: {task['failures']}")
    arn = task["tasks"][0]["taskArn"]
    task_id = arn.rsplit("/", 1)[-1]
    log(f"[gate] task {task_id} reading {len(pnr_ids)} booking(s)")

    waiter = ecs.get_waiter("tasks_stopped")
    waiter.wait(cluster=cfg["cluster"], tasks=[arn],
                WaiterConfig={"Delay": 10,
                            "MaxAttempts": max(2, (TASK_WAIT_SECONDS + watch) // 10)})
    desc = ecs.describe_tasks(cluster=cfg["cluster"], tasks=[arn])["tasks"][0]
    exit_code = (desc.get("containers") or [{}])[0].get("exitCode")
    log(f"[gate] task stopped, exit {exit_code}: {desc.get('stoppedReason', '')}")

    stream = f"{LOG_PREFIX}/{CONTAINER}/{task_id}"
    out: dict[str, dict] = {}
    # the task's own startup lines come first; only the marked ones are ours
    for _ in range(6):
        try:
            events = logs.get_log_events(logGroupName=cfg["log_group"], logStreamName=stream,
                                         limit=200, startFromHead=True)["events"]
        except logs.exceptions.ResourceNotFoundException:
            time.sleep(5)
            continue
        for ev in events:
            for line in (ev.get("message") or "").splitlines():
                if not line.startswith(MARK + " {"):
                    continue
                row = json.loads(line[len(MARK) + 1:])
                if row.get("poll"):
                    log(f"    [poll {row.get('at', '')}] {row['pnrId']} "
                        f"flown={row['flown']} {row['segments']}")
                    continue
                out[row["pnrId"]] = row
        if out:
            break
        time.sleep(5)
    missing = [p for p in pnr_ids if p not in out]
    if missing:
        log(f"[gate] no answer for {len(missing)}: {', '.join(missing[:5])}")
    return out


def judge(spec: dict, row: dict) -> dict:
    """What the engine saw, and whether it agrees -- kept apart, because they fail differently."""
    flow = registry.get((spec.get("family") or "fd").lower())
    seen = {"tripStatus": row.get("tripStatus"), "counts": (row.get("trip") or {}).get("counts"),
            "segments": (row.get("trip") or {}).get("segments")}

    # Is the disruption there at all? A verdict read without this question is misleading: an
    # itinerary the engine holds with no delay produces a correct NOT_ELIGIBLE for the wrong reason.
    segs = seen.get("segments") or []
    delays = [s.get("delayMin") for s in segs if s.get("delayMin")]
    seen["disruption_present"] = bool(delays)
    seen["delays"] = delays

    doc = row.get("document")
    if row.get("ddsStatus") != 200:
        return {"seen": seen, "checked": False,
                "why": f"DDS read failed: HTTP {row.get('ddsStatus')} {row.get('ddsError', '')}"[:200],
                "checks": []}
    if doc is None:
        return {"seen": seen, "checked": False,
                "why": "the engine holds no assessment for this booking yet", "checks": []}
    checks = [c.__dict__ for c in flow.checks(spec, flow.rows(doc))]
    return {"seen": seen, "checked": True, "why": "", "engine": row.get("engine"),
            "checks": checks,
            "agree": sum(1 for c in checks if c["applies"] and c["ok"]),
            "disagree": sum(1 for c in checks if c["applies"] and not c["ok"])}


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="core.gate", description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("pnr_ids", nargs="*", help="e.g. YXHFMQ-2026-06-19")
    ap.add_argument("--run", default="", help="gate every booking in runs/<env>/<label>/")
    ap.add_argument("--manifest", default="", metavar="PATH",
                    help="a builder batch's manifest.json. Each booking is judged against ITS OWN "
                         "expectation, which is the only thing that works for a batch: --spec "
                         "applies one expectation to every id, so a batch of 25 different cases "
                         "reports nothing useful")
    ap.add_argument("--spec", default="", metavar="ID",
                    help="the spec whose expectation to compare against, e.g. FD_TC_001. Without "
                         "it a bare pnrId carries no expectation and the verdict reports n/a -- "
                         "which is honest but useless")
    ap.add_argument("--env", default="int", choices=sorted(ENVS))
    ap.add_argument("--every", type=int, default=20, metavar="SECONDS",
                    help="how often to re-read the Trip while watching")
    ap.add_argument("--expect-delay", type=int, default=0, metavar="MINUTES",
                    help="with --watch, wait for THIS delay rather than for any change: a stale "
                         "value from an earlier publish otherwise reads as success")
    ap.add_argument("--watch", type=int, default=0, metavar="SECONDS",
                    help="inside the task, re-read the Trip every 20s for up to this long, until a "
                         "leg reports it operated. One container start instead of one per read")
    a = ap.parse_args(argv)

    specs: dict[str, dict] = {}
    ids = list(a.pnr_ids)
    if a.run:
        folder = ROOT / "runs" / a.env / a.run
        for f in sorted(folder.glob("*.json")):
            if f.name.startswith("_"):
                continue
            rec = json.loads(f.read_text(encoding="utf-8"))
            if not rec.get("locator"):
                continue
            pid = rec.get("pnr_id") or f"{rec['locator']}-{(rec.get('flight_date') or '')}"
            ids.append(pid)
            specs[pid] = {"family": "fd", "expect": rec.get("expect") or {},
                          "id": rec.get("spec_id"), "passengers": [{}], "segments": [{}],
                          "outcomes": [{}]}
    if a.manifest:
        for row in json.loads(pathlib.Path(a.manifest).read_text(encoding="utf-8")):
            pid = row.get("pnrId")
            if not pid:
                continue
            if pid not in ids:
                ids.append(pid)
            # the manifest's `expect` is the scenario's own, in the spec's shape
            specs[pid] = {"id": row.get("id"), "family": "fd", "expect": row.get("expect") or {},
                          "passengers": [{}], "segments": [{}], "outcomes": [{}]}
        print(f"judging {len(specs)} booking(s), each against its own manifest expectation")
    if not ids:
        raise SystemExit("name some pnrIds, --manifest <path>, or --run <label>")
    if a.spec:
        hits = sorted((ROOT / "spec").rglob(f"{a.spec}.json"))
        if not hits:
            raise SystemExit(f"no spec {a.spec!r} under {ROOT / 'spec'}")
        spec = json.loads(hits[0].read_text(encoding="utf-8"))
        for pid in ids:
            specs[pid] = spec
        print(f"comparing against {hits[0].relative_to(ROOT)}: "
              f"{json.dumps({k: v for k, v in (spec.get('expect') or {}).items() if k != 'ttUi'})}")

    rows = read(ids, a.env, watch=a.watch, want_delay=a.expect_delay, every=a.every)
    out = {}
    for pid in ids:
        row = rows.get(pid)
        if not row:
            print(f"{pid}: no answer")
            continue
        result = judge(specs.get(pid, {"family": "fd", "expect": {}}), row)
        out[pid] = {**row, "judgement": result}
        seen = result["seen"]
        print(f"\n{pid}")
        print(f"  trip  HTTP {seen['tripStatus']}  counts={seen['counts']}")
        for s in (seen.get("segments") or [])[:4]:
            print(f"        {s}")
        print(f"  disruption in the Trip: {seen['disruption_present']} {seen['delays'] or ''}")
        if result["checked"]:
            print(f"  verdict {result['agree']} agree, {result['disagree']} disagree "
                  f"({(result.get('engine') or {}).get('engine')} "
                  f"release {(result.get('engine') or {}).get('engineRelease')})")
            for c in result["checks"]:
                if c["applies"] and not c["ok"]:
                    print(f"    DISAGREES {c['name']}: {c['detail']}")
        else:
            print(f"  verdict not checked: {result['why']}")

    stamp = _dt.datetime.now(_dt.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    dest = ROOT / "runs" / a.env / (a.run or "gate") / f"_gate-{stamp}.json"
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(json.dumps(out, indent=1) + "\n", encoding="utf-8")
    print(f"\nwritten: {dest.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
