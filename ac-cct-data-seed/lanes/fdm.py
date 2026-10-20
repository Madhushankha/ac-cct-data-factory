"""The rest of a flight's life: it departed, and it arrived.

The agentic-qa pipeline publishes two FDM states per leg -- `SKD`, the flight as sold, and `ETD`,
the flight expected to be late -- and then stops. Neither says the flight operated. TripTracer's
rebuilt engine folds the event history and keeps nothing else, so it held the leg at
`status: SCHEDULED`, `delayMin: 0`, `cause: UNKNOWN`, and answered `FD-APPR-NE-20` -- the right
answer to the booking it could see.

Measured on INT, 2026-10-16, for FD_PO_001 seeded twice:

    trip  AC9485 YYZ->YVR  status=SCHEDULED  delayMin=0  cause=UNKNOWN  regimes=[APPR]
    dds   NOT_ELIGIBLE  FD-APPR-NE-20  "Delay below 3 hours or no cancellation"

The booking half was perfect -- one passenger, one segment, one ticket, the regime derived by the
engine itself. Only the disruption was missing. It had gone unnoticen for 230 cases because three
layers hid it: `cascade` saw `flight_leg: 0` and said so, `finalize` wrote the `flight_leg` rows
straight into the database, and the pinned verdict made the DDS checkpoints pass.

This lane publishes what was missing, in the shape the live feed uses, taken from
`reference/scenario_fdm.py` -- the uat-scenarios kit's solution to the same problem on BAT, where
its own docstring records the symptom: "TripTracer BAT shows 'ETD -' and no delay code".

Two messages per leg, and one record:

* `DEP` -- `offblockTime` and `airborneTime` NEW, arrival re-estimated, the delay UPD
* `ARR` -- `landingTime` and `onblockTime` NEW, off-block and airborne UPD, the delay UPD
* the Snowflake `ARRIVAL_CODE` record carrying `arrivalDelayCodePrimary`

The last one is not optional. The `<delay>` inside an FDM leg is the DEPARTURE code; APPR wants the
arrival code and without this record reads the departure one as a fallback -- `FD-APPR-EL-07/08/09`
instead of `EL-01/02/03`. Its `message.flightDetail` block is what routes it: the live consumers
route an FDM-topic record to its flight only from there, and a record without it sits in
pending-invalid-flight.

Transport is the agentic-qa publisher and the environment's own topic -- `emh-int.EAI-FDM-INT` on
INT, the same topic the kit uses and the same one the pipeline already publishes `SKD` to. Only the
payload was ever wrong, so only the payload is built here.
"""
from __future__ import annotations

import datetime as _dt
import hashlib
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

# after the insert, not before: imported first, `core` resolves against whatever else is
# on sys.path (another checkout of this project, or cct-qa-framework) rather than ours
from core import paths  # noqa: E402

AQA = paths.agentic_qa()

#: minutes between off-block and airborne, and between landing and on-block, as the live feed runs
TAXI_OUT_MINUTES = 12
TAXI_IN_MINUTES = 6

_TEMPLATE = """<?xml version="1.0" encoding="UTF-8"?>
<!-- {comment} -->
<env:envelope xmlns:env="http://www.lsb.de/apc/ops/Envelope" xmlns:fld="http://www.lsb.de/apc/customer/aca/flightDetail">
  <sender>FDM-OPS</sender>
  <receiver>MessageBroker</receiver>
  <created>{created}</created>
  <messages>
    <fld:flightDetail>
      <identifier>
        <flight><fnCarrier>{carrier}</fnCarrier><fnNumber>{fn}</fnNumber></flight>
        <dayOfOrigin>{day}</dayOfOrigin>
      </identifier>
      <leg modified="UPD">
        <state modified="UPD">{state}</state>
        <callSign>ACA{fn}</callSign>
        <schedule>
          <departureAirport>{origin}</departureAirport>
          <departure>{dep}</departure>
          <arrivalAirport>{destination}</arrivalAirport>
          <arrival>{arr}</arrival>
          <serviceType>J</serviceType>
          <aircraftOwner>{carrier}</aircraftOwner>
          <aircraftSubtype>{aircraft}</aircraftSubtype>
        </schedule>
        <actuals>{actuals}</actuals>
        <lastUpdate><userId>CCTQA</userId><timestamp>{created}</timestamp></lastUpdate>
      </leg>
    </fld:flightDetail>
  </messages>
</env:envelope>
"""


def _z(when: _dt.datetime) -> str:
    return when.astimezone(_dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _parse(value: str) -> _dt.datetime:
    v = (value or "").replace("Z", "+00:00")
    out = _dt.datetime.fromisoformat(v)
    return out if out.tzinfo else out.replace(tzinfo=_dt.timezone.utc)


def scheduled(seg: dict) -> tuple[_dt.datetime, _dt.datetime]:
    """The instants this leg's LOCAL clock readings name, through each airport's own timezone.

    Not `dep_utc` / `arr_utc`. A fixture's stored UTC is a claim about an instant rather than
    anything that was published: the PNR carries `localDateTime` only, and TripTracer derives the
    instant itself. They disagree, and the disagreement is not academic -- FD_PO_001 states
    `arr_local 14:00` at YVR with `arr_utc 18:00Z`, while 14:00 at YVR in June is 21:00Z, which is
    what Raptor derived. Anchoring a 240-minute delay on 18:00Z put on-block at 22:00Z, the engine
    measured that against its own 21:00Z, and the Trip reported 60 minutes instead of 240.

    `aqa.workflows.seed.airports` is the one conversion both sides agree on, including its
    deliberate Los_Angeles/Denver stand-ins for YVR and YYC: in tzdata 2026.3 those provinces have
    stopped observing daylight time while trip tracer has not, so the stand-ins keep the clock the
    reading service uses.
    """
    sys.path.insert(0, str(AQA))
    from aqa.workflows.seed import airports                                 # noqa: PLC0415
    dep = airports.to_utc(seg["origin"], seg["dep_local"])
    arr = airports.to_utc(seg["destination"], seg["arr_local"])
    if dep is None or arr is None:
        missing = seg["origin"] if dep is None else seg["destination"]
        raise ValueError(f"{missing} has no known timezone, so the instant its local clock names "
                         f"cannot be computed; add it to aqa.workflows.seed.airports.TZ")
    return dep.astimezone(_dt.timezone.utc), arr.astimezone(_dt.timezone.utc)


def leg_id(seg: dict) -> str:
    """The flight history id the raw FDM aggregate keys on: carrier#number#day#origin."""
    return f'{seg["carrier"]}#{seg["flight_number"]}#{seg["dep_local"][:10]}#{seg["origin"]}'


def messages(seg: dict, *, code: str = "", minutes: int = 0) -> list[tuple[str, str, str]]:
    """`(state, leg_id, xml)` for the DEP and ARR of one leg.

    `minutes` is the arrival delay; the departure is taken to slip by the same amount, which is what
    the kit does when a scenario states only one figure.
    """
    dep, arr = scheduled(seg)
    off = dep + _dt.timedelta(minutes=minutes)
    airborne = off + _dt.timedelta(minutes=TAXI_OUT_MINUTES)
    on = arr + _dt.timedelta(minutes=minutes)
    landing = on - _dt.timedelta(minutes=TAXI_IN_MINUTES)
    delay_el = (f'<delay modified="UPD"><delayCode>{code}</delayCode>'
                f'<delayTime>{minutes}</delayTime><subDelayCode>00</subDelayCode></delay>'
                if code and minutes else "")

    def build(state: str, actuals: str, created: _dt.datetime, comment: str) -> tuple[str, str, str]:
        return state, leg_id(seg), _TEMPLATE.format(
            comment=comment, created=_z(created), carrier=seg["carrier"], fn=seg["flight_number"],
            day=seg["dep_local"][:10], state=state, origin=seg["origin"],
            destination=seg["destination"], dep=_z(dep), arr=_z(arr),
            aircraft=seg.get("aircraft", "320"), actuals=actuals)

    return [
        build("DEP",
              f'<offblockTime modified="NEW">{_z(off)}</offblockTime>'
              f'<airborneTime modified="NEW">{_z(airborne)}</airborneTime>'
              f'<estimatedTimeArrival modified="UPD">{_z(on)}</estimatedTimeArrival>{delay_el}',
              off + _dt.timedelta(minutes=1), f"DEP {leg_id(seg)} off {_z(off)}"),
        build("ARR",
              f'<offblockTime modified="UPD">{_z(off)}</offblockTime>'
              f'<airborneTime modified="UPD">{_z(airborne)}</airborneTime>'
              f'<landingTime modified="NEW">{_z(landing)}</landingTime>'
              f'<onblockTime modified="NEW">{_z(on)}</onblockTime>{delay_el}',
              on + _dt.timedelta(minutes=1), f"ARR {leg_id(seg)} on {_z(on)} delay {minutes}min"),
    ]


def arrival_code(seg: dict, code: str, minutes: int) -> dict:
    """The Snowflake `ARRIVAL_CODE` record: where the ARRIVAL delay code lives."""
    day = seg["dep_local"][:10]
    entity = leg_id(seg)
    at = _z(scheduled(seg)[1] + _dt.timedelta(minutes=minutes + 2))
    return {
        "version": "1.0",
        "id": hashlib.sha256(f"VW_LEG_ARR_DELAY_CD|{entity}|{at}".encode()).hexdigest(),
        "entityId": entity, "sourceFeed": "SNOWFLAKE", "eventName": "ARRIVAL_CODE",
        "timestamp": at, "eventType": "UPDATE",
        "data": {"carrier": seg["carrier"], "flightNumber": str(seg["flight_number"]),
                 "departureAirport": seg["origin"], "departureDate": day, "legState": "ARR",
                 "lastUpdate": at, "arrivalDelayCodePrimary": str(code)},
        # not decoration: the live consumers route an FDM-topic record to its flight only from here
        "message": {"flightDetail": {
            "identifier": {"flight": {"fnCarrier": seg["carrier"],
                                      "fnNumber": str(seg["flight_number"])},
                           "dayOfOrigin": day},
            "leg": {"schedule": {"departureAirport": seg["origin"],
                                 "arrivalAirport": seg["destination"]}}}},
    }


def plan(manifest: dict) -> list[tuple[str, str, object]]:
    """Everything this lane would publish for one seeded booking, in order.

    `manifest` is a seeded case's own metadata -- the one the pipeline wrote, with the minted flight
    numbers and the shifted dates in it, not the spec. The spec says what the case means; only the
    manifest knows which flight actually got published.

    A cancelled leg never departed and a diverted one carries its own DIV message, so neither is
    given a life here: only the legs that flew as sold.
    """
    exp = manifest.get("expected") or {}
    minutes = int(exp.get("delay_minutes") or 0)
    code = str(exp.get("delay_code") or "")
    segs = [s for s in (manifest.get("segments") or [])
            if not s.get("cancellation_code") and not s.get("diverted_to")]
    if not segs:
        return []
    # the delay belongs to the leg whose arrival it is measured against: the last one
    msl = segs[-1]
    out: list[tuple[str, str, object]] = []
    for seg in segs:
        mins = minutes if seg is msl else 0
        c = code if seg is msl else ""
        for state, lid, xml in messages(seg, code=c, minutes=mins):
            out.append((state, lid, xml))
        if c and mins:
            out.append(("ARRIVAL_CODE", leg_id(seg), arrival_code(seg, c, mins)))
    return out


def publish(manifest: dict, env_name: str = "int", *, dry_run: bool = True,
            only: tuple[str, ...] = (), shape: str = "envelope", log=print) -> list[dict]:
    """Send the plan to the environment's FDM topic, using the agentic-qa publisher.

    Dry run by default. This writes to a topic other services read, so the caller says so
    explicitly rather than discovering it.
    """
    # "bare" is the kit's root element, which is the shape proven on BAT; "envelope" is what the
    # seeder has always sent and what TripTracer appears never to have ingested.
    if shape == "bare":
        from lanes.fdm_bare import plan as plan_fn                          # noqa: PLC0415
    else:
        plan_fn = plan
    steps = [x for x in plan_fn(manifest) if not only or x[0] in only]
    if not steps:
        log("[fdm] nothing to publish: no leg flew as sold")
        return []
    sys.path.insert(0, str(AQA))
    from aqa.workflows.seed.env import ENVS                                 # noqa: PLC0415
    env = ENVS[env_name]
    log(f"[fdm] {len(steps)} message(s) -> {env.topic_fdm}"
        + ("  (dry run, nothing sent)" if dry_run else ""))
    for state, lid, _ in steps:
        log(f"    {state:<13} {lid}")
    if dry_run:
        return [{"state": s, "leg": l, "sent": False} for s, l, _ in steps]

    from aqa.workflows.seed.publish import producer                         # noqa: PLC0415
    p = producer(env)
    out = []
    try:
        for state, lid, body in steps:
            key = lid.split("#")[1].encode()
            # the producer takes bytes: the XML is encoded, and the code record is JSON first.
            # Handing it a dict raises an AssertionError inside kafka-python, after the earlier
            # messages of the batch are already on the topic.
            value = (json.dumps(body).encode() if isinstance(body, dict) else body.encode())
            md = p.send(env.topic_fdm, value=value, key=key).get(timeout=60)
            at = _dt.datetime.now(_dt.timezone.utc).strftime("%H:%M:%SZ")
            log(f"    sent {at} {state:<13} {lid} -> offset {md.offset}")
            out.append({"state": state, "leg": lid, "sent": True,
                        "offset": md.offset, "at": at})
        p.flush(timeout=30)
    finally:
        p.close(timeout=10)
    return out


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser(prog="lanes.fdm", description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("manifest", help="a seeded case's metadata json (data/seed/<env>/fd-<suite>/<CASE>/<LOCATOR>/)")
    ap.add_argument("--env", default="int")
    ap.add_argument("--go", action="store_true", help="actually publish; without it, a dry run")
    ap.add_argument("--only", default="", help="comma-separated states, e.g. ARR,ARRIVAL_CODE")
    ap.add_argument("--shape", default="envelope", choices=("envelope", "bare"),
                    help="bare: the kit's root flightDetail document, proven on BAT")
    a = ap.parse_args()
    m = json.loads(pathlib.Path(a.manifest).read_text(encoding="utf-8"))
    publish(m, a.env, dry_run=not a.go, shape=a.shape,
            only=tuple(x.strip() for x in a.only.split(",") if x.strip()))
