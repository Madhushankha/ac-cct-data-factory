"""The FDM lifecycle in the kit's shape: a bare `flightDetail` document, no envelope.

Why this exists as a second builder rather than a flag. `lanes/fdm.py` follows the shape the
agentic-qa seeder has always published -- an `<env:envelope>` carrying `<messages>` carrying
`<fld:flightDetail>`. Published to `emh-int.EAI-FDM-INT` on 2026-10-16, a DEP and an ARR for
`AC#9485#2026-06-19#YYZ` were accepted by the broker (offsets 16951971, 16951972) and seven minutes
later TripTracer still reported the leg as `status: SCHEDULED`, `delayMin: 0`, `cause: UNKNOWN`.

The evidence says no FDM of ours has ever been ingested, not that the DEP and ARR were late:

* every seed logs `not materialised by FDM ingestion ({'flight_leg': 0, 'updates': []})` -- zero
  rows, not a stale one, and `finalize` then writes the `flight_leg` rows directly to compensate;
* the segment Raptor does show carries the flight number, route and scheduled times, all of which
  the PNR already states, and `cause: UNKNOWN`, which only an FDM could fill.

So the booking's own segment is what we have been looking at all along, and the FDM lane has
contributed nothing since the seeder was written.

The one structural difference against the kit -- whose FDM is proven on BAT, "AC8169 code 04 ->
cause, ETD and ETA parsed" -- is the root element. The kit publishes the document bare:

    <ns0:flightDetail xmlns:ns0="http://www.lsb.de/apc/customer/aca/flightDetail">

This builder reproduces that exactly, including the element order inside `schedule`, the `ACA%03d`
call sign, the `TTUAT` user id, and the full sequence SKD -> ETD -> DEP -> ARR rather than the two
states the seeder sends. Everything is copied from `reference/scenario_fdm.py` deliberately: the
point of the test is that nothing differs except the shape.

If the Trip reports `ARR` after this, the envelope was the fault, every FDM we have published has
been silently dropped, and `finalize`'s direct `flight_leg` writes have been covering for it.
"""
from __future__ import annotations

import datetime as _dt
from xml.sax.saxutils import escape

NS = "http://www.lsb.de/apc/customer/aca/flightDetail"

#: as the kit spaces them: the schedule three days out, the delay reported two hours before
#: departure, then the two operating messages a minute after the event each reports
SKD_DAYS_BEFORE = 3
ETD_MINUTES_BEFORE = 120
TAXI_OUT_MINUTES = 12
TAXI_IN_MINUTES = 6


def _z(when: _dt.datetime) -> str:
    return when.astimezone(_dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _parse(value: str) -> _dt.datetime:
    out = _dt.datetime.fromisoformat((value or "").replace("Z", "+00:00"))
    return out if out.tzinfo else out.replace(tzinfo=_dt.timezone.utc)


def _el(tag: str, text, modified: str | None = None) -> str:
    attr = f' modified="{modified}"' if modified else ""
    return f"<{tag}{attr}>{escape(str(text))}</{tag}>"


def _document(seg: dict, state: str, at: _dt.datetime, actuals: list[str]) -> str:
    """One message, in the kit's shape. `state` SKD carries no `modified` on the state element."""
    dep, arr = _parse(seg["dep_utc"]), _parse(seg["arr_utc"])
    number = str(seg["flight_number"])
    call = f"ACA{int(number):03d}" if seg["carrier"] == "AC" and number.isdigit() else f'{seg["carrier"]}{number}'
    # the live feed flags every state change after the schedule
    mark = "" if state == "SKD" else ' modified="UPD"'
    acts = "".join(actuals)
    return (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        f'<ns0:flightDetail xmlns:ns0="{NS}">\n'
        f"    <identifier><flight><fnCarrier>{seg['carrier']}</fnCarrier>"
        f"<fnNumber>{number}</fnNumber></flight>"
        f"<dayOfOrigin>{dep.strftime('%Y-%m-%d')}</dayOfOrigin></identifier>\n"
        f'    <leg modified="UPD"><state{mark}>{state}</state><callSign>{call}</callSign>'
        f"<schedule><serviceType>J</serviceType>"
        f"<departureAirport>{seg['origin']}</departureAirport>"
        f"<arrivalAirport>{seg['destination']}</arrivalAirport>"
        f"<departure>{_z(dep)}</departure><arrival>{_z(arr)}</arrival></schedule>"
        + (f"<actuals>{acts}</actuals>" if acts else "")
        + f"<lastUpdate><userId>TTUAT</userId><timestamp>{_z(at)}</timestamp></lastUpdate></leg>\n"
        "</ns0:flightDetail>\n"
    )


def lifecycle(seg: dict, *, code: str = "", minutes: int = 0) -> list[tuple[str, str]]:
    """`(state, xml)` for the whole life of one leg: SKD, ETD, DEP, ARR.

    The seeder sends only the first two. An engine that folds events has no actual times from
    those, so it holds the leg at SCHEDULED and finds no delay to compensate -- which is the
    correct reading of a flight that, as far as the events say, has not yet flown.
    """
    dep, arr = _parse(seg["dep_utc"]), _parse(seg["arr_utc"])
    off = dep + _dt.timedelta(minutes=minutes)
    airborne = off + _dt.timedelta(minutes=TAXI_OUT_MINUTES)
    on = arr + _dt.timedelta(minutes=minutes)
    landing = on - _dt.timedelta(minutes=TAXI_IN_MINUTES)
    delay_new = [f'<delay modified="NEW">{_el("delayCode", code)}</delay>'] if code and minutes else []
    delay_upd = [f'<delay modified="UPD">{_el("delayCode", code)}</delay>'] if code and minutes else []

    out = [("SKD", _document(seg, "SKD", dep - _dt.timedelta(days=SKD_DAYS_BEFORE), []))]
    if minutes:
        # when the delay was first reported: SoC reads the informed time from this lastUpdate
        out.append(("ETD", _document(
            seg, "ETD", dep - _dt.timedelta(minutes=ETD_MINUTES_BEFORE),
            [_el("estimatedTimeDeparture", _z(off), "UPD"),
             _el("estimatedTimeArrival", _z(on), "UPD"), *delay_new])))
    out.append(("DEP", _document(
        seg, "DEP", off + _dt.timedelta(minutes=1),
        [_el("offblockTime", _z(off), "NEW"), _el("airborneTime", _z(airborne), "NEW"),
         _el("estimatedTimeArrival", _z(on), "UPD"), *delay_upd])))
    out.append(("ARR", _document(
        seg, "ARR", on + _dt.timedelta(minutes=1),
        [_el("offblockTime", _z(off), "UPD"), _el("airborneTime", _z(airborne), "UPD"),
         _el("landingTime", _z(landing), "NEW"), _el("onblockTime", _z(on), "NEW"), *delay_upd])))
    return out


def plan(manifest: dict) -> list[tuple[str, str, str]]:
    """`(state, leg_id, xml)` for every leg of a seeded booking that flew as sold."""
    from lanes.fdm import leg_id                                            # noqa: PLC0415
    exp = manifest.get("expected") or {}
    minutes, code = int(exp.get("delay_minutes") or 0), str(exp.get("delay_code") or "")
    segs = [s for s in (manifest.get("segments") or [])
            if not s.get("cancellation_code") and not s.get("diverted_to")]
    if not segs:
        return []
    msl = segs[-1]
    out = []
    for seg in segs:
        mins = minutes if seg is msl else 0
        c = code if seg is msl else ""
        for state, xml in lifecycle(seg, code=c, minutes=mins):
            out.append((state, leg_id(seg), xml))
    return out
