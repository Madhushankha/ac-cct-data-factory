"""Reading the Trip and the verdict from the new engine, from inside a case-intake task.

Implements `ports.AssessmentReader`.

Why a task and not an HTTP call from here. The engine admits an internal service with a short-lived
JWT the service signs with its own key, and the key for the principal that is already registered
lives in `cct-case-intake-int/app-secrets` -- a secret INT's Secrets Manager admits to the
case-intake task role alone. So the read runs where the key already is: a one-off task on that
service with its command overridden, which is the uat-scenarios kit's own mechanism. Nothing is
granted to this project and no key is copied.

`docs/triptracer-principal.md` describes the alternative -- registering this project's own
principal, public key only -- which would make an ordinary HTTPS call possible. Reachability is not
the obstacle: the endpoint answered 401 in 0.27 s from this workstation.

Both reads go straight to tt-api rather than through case-services' API, so the answer arrives as
the engine gives it: case-services flattens the document before its consumers see it, and routing
through its endpoint would also record the request as that service's traffic.

The Trip is read first, always. Without it a correct NOT_ELIGIBLE for a flight that never flew looks
like a rule defect, which cost an hour before the ordering was enforced.
"""
from __future__ import annotations

import json
import time
from dataclasses import dataclass
from typing import Any

from domain.models import Assessment

#: environment -> the cluster, service and log group a one-off task uses
ENVIRONMENTS: dict[str, dict[str, str]] = {
    "int": {"cluster": "cct-case-intake-int-cluster",
            "service": "cct-case-intake-int-service",
            "log_group": "/ecs/cct-case-intake-int",
            "profile": "int-cce"},
    "bat": {"cluster": "ac-cct-bat-ecs-cluster",
            "service": "ac-cct-bat-case-intake-ecs-fargate-service",
            # BAT ships stdout through firelens, not awslogs, so both the group and the stream
            # naming differ from INT's `api/Container/<task-id>`
            "log_group": "/aws/ecs/firelens/cct-case-intake-bat-api",
            "log_prefix": "ecs",
            # and its container is `App`: overriding `Container` fails the RunTask call outright
            "container": "App",
            "profile": "bat-sso"}   # verified: bat-sso reaches ac-cct-bat-ecs-cluster (acct 209479273605),
}
#: INT's names; an environment may override either in ENVIRONMENTS above
CONTAINER = "Container"
LOG_PREFIX = "api"
MARK = "TTGATE"

#: Bookings per task. The ECS command override holds 8 KiB and carries the script (~3.8 KB) plus
#: the ids (~24 bytes each). Measured: 50 ids give a 5,200-byte override. 100 keeps real headroom.
MAX_PER_TASK = 100
TASK_TIMEOUT_SECONDS = 600

#: Runs INSIDE the task. `__IDS__` is replaced with the booking ids.
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
                 "Authorization": "Bearer " + sig.token(), "User-Agent": "ac-cct-data-seed"})
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return 200, json.load(r)
    except urllib.error.HTTPError as ex:
        return ex.code, (ex.read() or b"")[:300].decode("utf-8", "replace")
    except Exception as ex:
        return 0, "%s: %s" % (type(ex).__name__, str(ex)[:200])
for pid in __IDS__:
    out = {"pnrId": pid}
    code, trip = call("%s/api/service/trips/%s?engine=raptor" % (base, pid))
    out["tripStatus"] = code
    if code == 200 and isinstance(trip, dict):
        t = trip.get("trip") or trip
        out["trip"] = {
            "counts": {k: len(t.get(k) or []) for k in ("passengers", "segments", "tickets", "ancillaries", "baggage")},
            # every address the booking carries, found by scanning rather than by field name,
            # because the contact is nested differently per feed. It is here because a booking
            # published with the builder's `synth-*@synth.test` address is silently unusable --
            # the suite fetches OTP and notification mail from the Mailinator box, and nothing can
            # ever arrive at synth.test. Nothing else in a read would show it.
            "emails": sorted({w for w in json.dumps(t).replace('"', " ").replace(",", " ").split() if "@" in w})[:4],
            # the traveller's date of birth, for the same reason as the e-mail above: it is set
            # by a rewrite on the way out, the seed pool's own value (1980-01-01) is what a booking
            # carries otherwise, and nothing else in a read would show which one went out.
            # TripTracer normalises the PNR's `birthDate`/`dateOfBirth` into one `dob` per
            # passenger, so that is the field to read -- the wire spellings never appear in a Trip.
            "dobs": sorted({str(pax.get("dob")) for pax in (t.get("passengers") or [])
                            if isinstance(pax, dict) and pax.get("dob")})[:4],
            # the bags, because a baggage case's whole expectation is about them and the segment
            # projection cannot carry it: `expectBag` states AHL presence and count, delivery,
            # closure and the 21/51-day windows, and none of that is derivable from a delay.
            # Field names are TripTracer's own, taken from the baggage kit's `tt_facts`.
            "baggage": [{"tag": b.get("tag"), "bound": b.get("bound"), "status": b.get("status"),
                         "loc": b.get("loc"),
                         "ahl": (b.get("ahl") or {}).get("id"),
                         "ahlAt": (b.get("ahl") or {}).get("at"),
                         "events": [[e.get("event"), e.get("at")] for e in b.get("tracking") or []]}
                        for b in (t.get("baggage") or [])][:8],
            # the times as well as the delay: a delay the engine disagrees with cannot be
            # diagnosed without them. FD_ED_TC_13 published a 240-minute delay and the engine
            # answered 420, and nothing in the read said which of the two numbers moved.
            "segments": [{k: sg.get(k) for k in ("flight", "from", "to", "status", "delayMin",
                                                 "cause", "causeCode", "regimes",
                                                 "schedDep", "schedArr", "actualDep",
                                                 "actualArr", "scheduledDeparture",
                                                 "scheduledArrival", "actualDeparture",
                                                 "actualArrival")}
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


class TaskFailed(RuntimeError):
    """The task could not be run, or produced no marked output."""


@dataclass
class EcsAssessmentReader:
    """Reads Trip and verdict for a set of bookings in one task.

    Satisfies `ports.AssessmentReader` for single reads, and `read_many` does a batch -- which is
    what the cost shape wants: roughly 60 of a task's 70 seconds is container startup, so one
    booking and a hundred cost nearly the same.
    """
    env_name: str = "int"
    log: Any = print
    _cache: dict[str, dict] = None  # type: ignore[assignment]

    def __post_init__(self) -> None:
        if self.env_name not in ENVIRONMENTS:
            raise KeyError(f"no ECS settings for {self.env_name!r}; "
                           f"known: {', '.join(sorted(ENVIRONMENTS))}")
        self._cache = {}

    # ------------------------------------------------------------ the ports

    def trip(self, pnr_id: str) -> dict:
        return (self._row(pnr_id).get("trip") or {})

    def assessment(self, pnr_id: str) -> Assessment:
        row = self._row(pnr_id)
        return Assessment.parse(pnr_id, {**(row.get("engine") or {}),
                                         "document": row.get("document")})

    # ------------------------------------------------------------- batching

    def read_many(self, pnr_ids: list[str]) -> dict[str, dict]:
        """One task for up to `MAX_PER_TASK` bookings. Results are cached for `trip`/`assessment`."""
        if not pnr_ids:
            return {}
        if len(pnr_ids) > MAX_PER_TASK:
            raise ValueError(f"{len(pnr_ids)} bookings exceeds {MAX_PER_TASK} per task "
                             f"(the ECS command override holds 8 KiB)")
        rows = self._run_task(pnr_ids)
        self._cache.update(rows)
        missing = [p for p in pnr_ids if p not in rows]
        if missing:
            self.log(f"[read] no answer for {len(missing)}: {', '.join(missing[:5])}")
        return rows

    def _row(self, pnr_id: str) -> dict:
        if pnr_id not in self._cache:
            self.read_many([pnr_id])
        return self._cache.get(pnr_id) or {}

    # ------------------------------------------------------------ internals

    @staticmethod
    def _log_group(ecs, task_definition: str, cfg: dict) -> str:
        """Where this task's stdout goes, from the container's own logConfiguration.

        firelens names it `log_group_name`, awslogs `awslogs-group`. An explicit `log_group` in
        ENVIRONMENTS still wins, so a misconfigured task definition can be worked around.
        """
        try:
            td = ecs.describe_task_definition(taskDefinition=task_definition)["taskDefinition"]
            for c in td.get("containerDefinitions") or []:
                opts = ((c.get("logConfiguration") or {}).get("options") or {})
                group = opts.get("log_group_name") or opts.get("awslogs-group")
                if group:
                    return group
        except Exception:                                                   # noqa: BLE001
            pass
        return cfg["log_group"]

    @staticmethod
    def _lines(message: str) -> list[str]:
        """The log lines in one event, unwrapping firelens' `{"log": "..."}` envelope."""
        out = []
        for raw in message.splitlines():
            line = raw
            if raw.lstrip().startswith("{"):
                try:
                    line = json.loads(raw).get("log", raw)
                except Exception:                                           # noqa: BLE001
                    line = raw
            out.append(line)
        return out

    def _clients(self):
        import boto3                                                        # noqa: PLC0415
        cfg = ENVIRONMENTS[self.env_name]
        session = boto3.Session(profile_name=cfg["profile"], region_name="ca-central-1")
        return session.client("ecs"), session.client("logs"), cfg

    def _run_task(self, pnr_ids: list[str]) -> dict[str, dict]:
        ecs, logs, cfg = self._clients()
        service = ecs.describe_services(cluster=cfg["cluster"],
                                        services=[cfg["service"]])["services"][0]
        log_group = self._log_group(ecs, service["taskDefinition"], cfg)
        script = INNER.replace("__IDS__", json.dumps(pnr_ids))
        task = ecs.run_task(
            cluster=cfg["cluster"], taskDefinition=service["taskDefinition"],
            launchType="FARGATE", networkConfiguration=service["networkConfiguration"],
            startedBy="data-seed-read",
            overrides={"containerOverrides": [
                {"name": cfg.get("container", CONTAINER),
                 "command": ["python", "-c", script]}]})
        if task.get("failures"):
            raise TaskFailed(f"run_task refused: {task['failures']}")
        import datetime as _dt
        started_at = _dt.datetime.now(_dt.timezone.utc)
        arn = task["tasks"][0]["taskArn"]
        task_id = arn.rsplit("/", 1)[-1]
        self.log(f"[read] task {task_id}, {len(pnr_ids)} booking(s)")

        ecs.get_waiter("tasks_stopped").wait(
            cluster=cfg["cluster"], tasks=[arn],
            WaiterConfig={"Delay": 10, "MaxAttempts": max(2, TASK_TIMEOUT_SECONDS // 10)})
        described = ecs.describe_tasks(cluster=cfg["cluster"], tasks=[arn])["tasks"][0]
        exit_code = (described.get("containers") or [{}])[0].get("exitCode")
        self.log(f"[read] stopped, exit {exit_code}")

        # filter the GROUP on the marker rather than reading one stream: with firelens the stream
        # name is not ours to predict, and a wrong guess reads as "no output" instead of an error
        started = int((started_at.timestamp() - 300) * 1000)
        for _ in range(8):
            rows = {}
            try:
                token = None
                while True:
                    kw = {"logGroupName": log_group, "startTime": started,
                          "filterPattern": f'"{MARK} "'}
                    if token:
                        kw["nextToken"] = token
                    page = logs.filter_log_events(**kw)
                    for ev in page.get("events") or []:
                        for line in self._lines(ev.get("message") or ""):
                            if line.startswith(MARK + " {"):
                                row = json.loads(line[len(MARK) + 1:])
                                rows[row["pnrId"]] = row
                    token = page.get("nextToken")
                    if not token:
                        break
            except logs.exceptions.ResourceNotFoundException:
                pass
            if rows:
                return rows
            time.sleep(5)
        raise TaskFailed(f"task {task_id} produced no marked output in {log_group}")
