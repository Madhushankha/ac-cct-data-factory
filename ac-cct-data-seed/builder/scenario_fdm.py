"""Flight-status (EAI-FDM) XML for scenario bookings built by the /qa builder, in the shape BAT's FDM topic carries.

The /qa builder's own FDM JSON puts the estimated times at the leg and the delay outside the live structure, so
TripTracer BAT shows "ETD —" and no delay code (pilot ZZZ77Z, 2026-10-15). This writes the same flight's status the
way the live feed does (the classic replay's XML, proven on BAT: AC8169 code 04 -> cause, ETD and ETA parsed).

Input: a JSON list of flights
  {"rider": pnrId, "carrier", "number", "origin", "destination", "depUtc", "arrUtc" (scheduled, ISO Z),
   "kind": "delay" | "cancel" | "ontime", "minutes": arrival delay, "code": IATA delay/cancel code,
   "depMinutes": departure delay (default = minutes)}
Usage: scenario_fdm.py <flights.json> <out> [int|crt|bat]
Output: <out>/messages.jsonl in the replay batch format (event_replay.py check/publish).
"""
import json
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path
from xml.sax.saxutils import escape

NS = "http://www.lsb.de/apc/customer/aca/flightDetail"
TOPICS = {"int": "emh-int.EAI-FDM-INT", "crt": "emh-dev.EAI-FDM-UAT", "bat": "emh-dev.EAI-FDM-INT"}


def z(d):
    return d.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def parse(s):
    return datetime.fromisoformat(s.replace("Z", "+00:00"))


def el(tag, text, modified=None):
    attr = f' modified="{modified}"' if modified else ""
    return f"<{tag}{attr}>{escape(str(text))}</{tag}>"


def message(f, state, at, actuals):
    dep, arr = parse(f["depUtc"]), parse(f["arrUtc"])
    number = str(int(f["number"])) if str(f["number"]).isdigit() else f["number"]
    call = f"ACA{int(number):03d}" if f["carrier"] == "AC" and number.isdigit() else f"{f['carrier']}{number}"
    acts = "".join(actuals)
    mark = "" if state == "SKD" else ' modified="UPD"'  # the live feed flags every state change after the schedule
    return (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        f'<ns0:flightDetail xmlns:ns0="{NS}">\n'
        f"    <identifier><flight><fnCarrier>{f['carrier']}</fnCarrier><fnNumber>{number}</fnNumber></flight>"
        f"<dayOfOrigin>{dep.strftime('%Y-%m-%d')}</dayOfOrigin></identifier>\n"
        f'    <leg modified="UPD"><state{mark}>{state}</state><callSign>{call}</callSign>'
        f"<schedule><serviceType>J</serviceType><departureAirport>{f['origin']}</departureAirport>"
        f"<arrivalAirport>{f['destination']}</arrivalAirport><departure>{z(dep)}</departure><arrival>{z(arr)}</arrival></schedule>"
        + (f"<actuals>{acts}</actuals>" if acts else "")
        + f"<lastUpdate><userId>TTUAT</userId><timestamp>{z(at)}</timestamp></lastUpdate></leg>\n"
        "</ns0:flightDetail>\n"
    )


def flight_messages(f):
    dep, arr = parse(f["depUtc"]), parse(f["arrUtc"])
    kind, code = f.get("kind", "delay"), str(f.get("code") or "")
    arr_delay = int(f.get("minutes") or 0)
    dep_delay = int(f.get("depMinutes", arr_delay) or 0)
    out = [("SKD", dep - timedelta(days=3), [])]
    if kind == "scheduleonly":  # the flight is known, its operating times never arrive
        return out
    if kind == "cancel":
        out.append(("CNL", dep - timedelta(minutes=int(f.get("noticeMinutes", 180))),
                    [f'<cancel modified="NEW">{el("legCancelCodePrimary", code or "WX")}</cancel>']))
        return out
    delay = [f'<delay modified="NEW">{el("delayCode", code)}</delay>'] if code and dep_delay > 0 else []
    delay_upd = [f'<delay modified="UPD">{el("delayCode", code)}</delay>'] if delay else []
    off, on = dep + timedelta(minutes=dep_delay), arr + timedelta(minutes=arr_delay)
    if f.get("codeOnly") and code and not delay:  # the delay sits in the shifted schedule; the code still reports its cause
        delay = [f'<delay modified="NEW">{el("delayCode", code)}</delay>']
        delay_upd = [f'<delay modified="UPD">{el("delayCode", code)}</delay>']
    if dep_delay > 0:
        # when the delay was first reported: SoC reads the informed time from this message's lastUpdate
        out.append(("ETD", dep - timedelta(minutes=int(f.get("reportedMinutes") or 120)),
                    [el("estimatedTimeDeparture", z(off), "UPD"), el("estimatedTimeArrival", z(on), "UPD"), *delay]))
    out.append(("DEP", off + timedelta(minutes=1),
                [el("offblockTime", z(off), "NEW"), el("airborneTime", z(off + timedelta(minutes=12)), "NEW"),
                 el("estimatedTimeArrival", z(on), "UPD"), *delay_upd]))
    if f.get("noArrival"):
        return out
    out.append(("ARR", on + timedelta(minutes=1),
                [el("offblockTime", z(off), "UPD"), el("airborneTime", z(off + timedelta(minutes=12)), "UPD"),
                 el("landingTime", z(on - timedelta(minutes=6)), "NEW"), el("onblockTime", z(on), "NEW"), *delay_upd]))
    return out


def code_record(f, kind, code, at):
    """The code feed's record (migration/code_feeds.rs, as the live code jobs send it): ARRIVAL_CODE with
    arrivalDelayCodePrimary, or CANCEL_CODE with legCancelCodePrimary, keyed by the flight's day of origin. Without
    it APPR reads the departure code as a fallback (FD-APPR-EL-07/08) and a cancellation has no reason."""
    import hashlib
    dep = parse(f["depUtc"])
    number = str(int(f["number"])) if str(f["number"]).isdigit() else f["number"]
    day = dep.strftime("%Y-%m-%d")
    entity = f"{f['carrier']}#{number}#{day}#{f['origin']}"  # the flight history id (raw FDM aggregate: carrier#number#day#origin)
    event, field, view = (("ARRIVAL_CODE", "arrivalDelayCodePrimary", "VW_LEG_ARR_DELAY_CD") if kind == "arrival"
                          else ("CANCEL_CODE", "legCancelCodePrimary", "VW_LEG_CNL_CD"))
    data = {"carrier": f["carrier"], "flightNumber": number, "departureAirport": f["origin"], "departureDate": day,
            "legState": "ARR" if kind == "arrival" else "CNL", "lastUpdate": z(at), field: str(code)}
    # The live consumers route an FDM-topic record to its flight only from message.flightDetail
    # (feeds/fdm.rs source_flight_id); the code feed never travels by Kafka in PROD, so its envelope has none and
    # would sit in pending-invalid-flight. The identity block routes it; the compiler still reads eventName/data first.
    flight_detail = {"identifier": {"flight": {"fnCarrier": f["carrier"], "fnNumber": number}, "dayOfOrigin": day},
                     "leg": {"schedule": {"departureAirport": f["origin"], "arrivalAirport": f["destination"]}}}
    return {"version": "1.0", "id": hashlib.sha256(f"{view}|{entity}|{z(at)}".encode()).hexdigest(), "entityId": entity,
            "sourceFeed": "SNOWFLAKE", "eventName": event, "timestamp": z(at), "eventType": "UPDATE", "data": data,
            "message": {"flightDetail": flight_detail}}


def main(src, out_dir, env="int"):
    flights = json.load(open(src))
    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    rows, seq = [], 0
    now = datetime.now(timezone.utc)
    for f in flights:
        ident = f"{f['carrier']}#{int(f['number']) if str(f['number']).isdigit() else f['number']}#{parse(f['depUtc']).strftime('%Y-%m-%d')}#{f['origin']}"
        for state, at, actuals in flight_messages(f):
            if at > now:
                continue
            seq += 1
            rows.append({"booking": ident, "riders": [f["rider"]], "feed": "FDM", "topic": TOPICS[env], "key": None,
                         "at": z(at), "seq": seq, "generated": True, "value": message(f, state, at, actuals)})
        kind = f.get("kind", "delay")
        if f.get("noArrival") or kind == "scheduleonly":
            rec = None
        elif kind in ("delay", "divert") and f.get("arrivalCode", f.get("code")) and (int(f.get("minutes") or 0) > 0 or f.get("codeOnly")):
            at = parse(f["arrUtc"]) + timedelta(minutes=int(f.get("minutes") or 0) + 30)
            rec = code_record(f, "arrival", f.get("arrivalCode", f.get("code")), at)
        elif kind == "cancel" and f.get("cancelCode"):
            at = parse(f["depUtc"]) - timedelta(minutes=int(f.get("noticeMinutes", 180)) - 5)
            rec = code_record(f, "cancel", f["cancelCode"], at)
        else:
            rec = None
        if rec and at <= now:
            seq += 1
            rows.append({"booking": ident, "riders": [f["rider"]], "feed": "FDM", "topic": TOPICS[env], "key": None,
                         "at": z(at), "seq": seq, "generated": True, "value": json.dumps(rec)})
    with open(out / "messages.jsonl", "w") as fh:
        for r in rows:
            fh.write(json.dumps(r) + "\n")
    print(json.dumps({"flights": len(flights), "messages": len(rows)}))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else "int")
