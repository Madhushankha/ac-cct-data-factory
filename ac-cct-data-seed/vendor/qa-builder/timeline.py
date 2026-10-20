"""Timeline scenarios for the QA generator (F12 step 3): append booking changes to a generated booking's PNR history.

Each step becomes one new PNR version, built the way the feed builds them: the latest processedPnr copied and changed,
its version advanced, lastModification stamped, and two change records the engines read:
  - previousRecord: the RFC 6902 JSON Patch that turns this version back into the previous one;
  - events.events: one {origin: COMPARISON, eventType: CREATED|UPDATED|DELETED, currentPath, previousPath} per change.

Steps (segments are numbered from 1 in departure order; "at" is an optional UTC time, default spread before now):
  {"kind": "schedule_change", "segment": 2, "minutes": 95}
  {"kind": "cancel", "segment": 1}
  {"kind": "rebook", "segment": 1, "carrier": "AC", "number": "305", "depart": "2026-11-03T10:00", "arrive": "..."}
      (a rebook replaces the segment, cancellation included; a cancel right before a rebook of the same segment is
      folded into it)
Two steps are other feeds, not PNR versions:
  {"kind": "delay", "segment": 1, "minutes": 90, "code": "93"}  -> FDM messages for that flight (live Kafka shape): the
      schedule, then the delay with estimated times and the IATA delay code; once the delayed times are past, the
      off-block/airborne and landing/on-block actuals (state ARR), so the flight completes. Times are UTC via the
      airport's time zone (timezone_airports.json, the engine's own table).
  {"kind": "check_in", "segment": 1, "channel": "WEB"}  -> for every passenger's CM record on that flight, the
      acceptance set to ACCEPTED, with the previousRecord patch and the COMPARISON event at .../acceptance the parser
      reads as CHECK_IN. The template must carry CM records for that flight (else the next template is tried).
  {"kind": "boarding", "segment": 1}  -> the same, with the leg's boarding set to BOARDED (gate reader scan, boarding
      pass printed) and the acceptance too when the passenger had not checked in; event at .../boarding (BOARDING).
  {"kind": "bags", "segment": 1, "through": 2, "count": 1, "outcome": "delivered"}  -> BROCK baggage events for
      `count` checked bags per passenger, tagged from `segment` through `through` (default the last segment): created
      and accepted at check-in, onloaded and unloaded on each leg, then by outcome: delivered (to the carousel), delayed
      (misses the last leg; a delayed-bag record is opened at arrival) or delayed_delivered (also delivered and closed
      the next day). Station-local timestamps with their UTC offset, as BROCK sends them. Events after now are dropped.
"""
import copy
import json
import random
import re
import string
from datetime import datetime, timedelta, timezone
from pathlib import Path
from zoneinfo import ZoneInfo

PNR_TOPIC_HINT = "PNRDATA"
FDM_TOPIC = "emh-prd.EAI-FDM-PRD"
CM_TOPIC = "emh-prd.ALTEA-CM-PRD"
BAG_TOPIC = "emh-prd.BROCK-BAGGAGE-PRD"
ST_ID = re.compile(r'"(?:[^"]*-)?ST-(\d+)"')
AIRPORT_TZ = json.loads((Path(__file__).with_name("timezone_airports.json")).read_text())


def _parse(s):
    return datetime.strptime(s.replace("Z", "")[:19], "%Y-%m-%dT%H:%M:%S") if "T" in s and len(s) >= 19 else datetime.strptime(s[:16], "%Y-%m-%dT%H:%M")


def _fmt(d):
    return d.strftime("%Y-%m-%dT%H:%M:%S")


def _air_products(pnr):
    """(index in products, product) for every AIR product, in departure order."""
    out = [(i, p) for i, p in enumerate(pnr.get("products") or []) if p.get("subType") == "AIR" and isinstance(p.get("airSegment"), dict)
           and isinstance(p["airSegment"].get("departure"), dict) and isinstance(p["airSegment"].get("arrival"), dict)]  # open segments have no times
    return sorted(out, key=lambda ip: ip[1]["airSegment"]["departure"].get("localDateTime", ""))


def _trigger_id(rng):
    return "".join(rng.choice(string.ascii_lowercase + string.digits) for _ in range(32)) + "-" + "".join(rng.choice(string.ascii_lowercase + string.digits) for _ in range(16))


def _retarget(doc, old_id, new_id):
    """Rewrite every string value equal to old_id (outside the products themselves' own ids) to new_id; return the
    JSON pointers changed."""
    changed = []

    def walk(o, ptr):
        items = o.items() if isinstance(o, dict) else enumerate(o) if isinstance(o, list) else ()
        for k, v in items:
            p = f"{ptr}/{str(k).replace('~', '~0').replace('/', '~1')}"
            if v == old_id and isinstance(v, str) and not (ptr.startswith("/products/") and k == "id" and ptr.count("/") == 2):
                o[k] = new_id
                changed.append(p)
            elif isinstance(v, (dict, list)):
                walk(v, p)
    if old_id:
        walk(doc, "")
    return changed


def _version(m):
    try:
        return int(json.loads(m["value"])["processedPnr"].get("version") or 0)
    except (ValueError, TypeError, KeyError):
        return 0


def newest(pnrs):
    """The newest PNR version: the highest version number (the order the engines fold in), then the latest time. Feed
    timestamps are not in version order (a re-sent version can arrive later), so the latest message is not always the
    newest version, and a step built on it would reuse a version number that already exists."""
    return max(pnrs, key=lambda m: (_version(m), m["ts"] or ""))


def flights_left(messages):
    """Air segments the booking's newest PNR version still holds (not XX/UN/HX/UC/NO), in departure order."""
    pnrs = [m for m in messages if PNR_TOPIC_HINT in m["prodTopic"] and isinstance(json.loads(m["value"]).get("processedPnr"), dict)]
    if not pnrs:
        return []
    pnr = json.loads(newest(pnrs)["value"])["processedPnr"]
    return [p for _, p in _air_products(pnr) if p["airSegment"].get("status") not in ("XX", "UN", "HX", "UC", "NO")]


def merged_rebooks(steps):
    """A rebook already cancels the segment it replaces. A cancel of segment n followed by a rebook of segment n
    (the way a tester says "cancelled and rebooked") would remove the flight twice and leave the booking with no
    flights (found by the /qa end-to-end run on INT, 2026-10-14), so the cancel is folded into the rebook."""
    out = []
    for k, st in enumerate(steps):
        nxt = steps[k + 1] if k + 1 < len(steps) else None
        if st.get("kind") == "cancel" and nxt and nxt.get("kind") == "rebook" \
                and int(nxt.get("segment", 1)) == int(st.get("segment", 1)):
            continue
        out.append(st)
    return out


def apply(messages, steps, now=None, rng=None):
    """messages: the booking's messages ({ts, prodTopic, value}), already re-identified and moved to its itinerary.
    Returns them with one new PNR message per step appended, ordered by time."""
    now = now or datetime.utcnow().replace(microsecond=0)
    rng = rng or random.Random()
    steps = merged_rebooks(steps)
    pnrs = [m for m in messages if PNR_TOPIC_HINT in m["prodTopic"] and isinstance(json.loads(m["value"]).get("processedPnr"), dict)]
    if not pnrs:
        raise ValueError("the booking has no PNR version to change")
    base_msg = newest(pnrs)
    base = json.loads(base_msg["value"])
    last = _parse(base_msg["ts"]) if base_msg["ts"] else now - timedelta(days=1)
    times = []
    for k, st in enumerate(steps):
        times.append(_parse(st["at"]) if st.get("at") else last + (now - timedelta(minutes=2) - last) * (k + 1) / (len(steps) + 1))
    if any(t > now for t in times) or times != sorted(times):
        raise ValueError("timeline steps must be in order and before now")
    out = list(messages)
    prev = base["processedPnr"]
    # Segment tattoos: a new segment takes the next unused number, never one an earlier version used.
    st_used = max((int(n) for m in pnrs for n in ST_ID.findall(m["value"])), default=0)
    for st, at in zip(steps, times):
        cur = copy.deepcopy(prev)
        ops, events = [], []
        air = _air_products(cur)
        n = int(st.get("segment", 1))
        if not 1 <= n <= len(air):
            raise ValueError(f"segment {n}: the booking has {len(air)} air segments")
        idx, prod = air[n - 1]
        seg = prod["airSegment"]
        if st["kind"] == "delay":
            out += _delay(seg, st, at, now, rng)
            continue
        if st["kind"] in ("check_in", "boarding"):
            out += _check_in(messages, out, seg, st, at, rng)
            continue
        if st["kind"] == "bags":
            last_seg = int(st.get("through") or len(air))
            if not n <= last_seg <= len(air):
                raise ValueError(f"bags through segment {last_seg}: the booking has {len(air)} air segments")
            out += _bags(cur, [p["airSegment"] for _, p in air[n - 1:last_seg]], st, at, now, rng)
            continue
        if st["kind"] == "schedule_change":
            dm = timedelta(minutes=int(st["minutes"]))
            for end in ("departure", "arrival"):
                old = seg[end]["localDateTime"]
                seg[end]["localDateTime"] = _fmt(_parse(old) + dm)
                path = f"/products/{idx}/airSegment/{end}/localDateTime"
                ops.append({"op": "replace", "path": path, "value": old})
                events.append({"origin": "COMPARISON", "eventType": "UPDATED", "currentPath": path, "previousPath": path})
        elif st["kind"] in ("cancel", "rebook"):
            old_prod = cur["products"].pop(idx)
            if st["kind"] == "rebook":
                new_prod = copy.deepcopy(old_prod)
                # The feed gives a rebooked segment a new tattoo (…-ST-<next>); the facts writer numbers segments by
                # that trailing integer, so a non-numeric id ("ST-1-R2195") made the new flight invisible to search
                # and the booking read NO_FLIGHTS (found by the /qa end-to-end run on INT, 2026-10-14).
                st_used += 1
                stem = (old_prod.get("id") or "ST-0").rsplit("-", 1)[0]
                new_prod["id"] = f"{stem}-{st_used}"
                s2 = new_prod["airSegment"]
                s2["carrierCode"], s2["number"] = st["carrier"], str(st["number"])
                dep = _parse(st["depart"])
                dur = _parse(seg["arrival"]["localDateTime"]) - _parse(seg["departure"]["localDateTime"])
                s2["departure"]["localDateTime"] = _fmt(dep)
                s2["arrival"]["localDateTime"] = _fmt(_parse(st["arrive"]) if st.get("arrive") else dep + dur)
                if isinstance(s2.get("operating"), dict):
                    s2["operating"].update(carrierCode=st["carrier"], number=str(st["number"]))
                cur["products"].append(new_prod)
                new_idx = len(cur["products"]) - 1
                # Everything that named the old segment (flight itineraries and groups, deliveries, keywords, loyalty
                # requests ...) names the new one, as the feed's next version does; without it the booking keeps no
                # live flight and search reads NO_FLIGHTS (found by the /qa end-to-end run on INT, 2026-10-14). The
                # reverse patch restores each reference first, while the product indices are still this version's.
                for ptr in _retarget(cur, old_prod.get("id"), new_prod["id"]):
                    ops.insert(0, {"op": "replace", "path": ptr, "value": old_prod.get("id")})
                    events.append({"origin": "COMPARISON", "eventType": "UPDATED", "currentPath": ptr, "previousPath": ptr})
                ops.append({"op": "remove", "path": f"/products/{new_idx}"})  # undo the addition first
                events.append({"origin": "COMPARISON", "eventType": "CREATED", "currentPath": f"/products/{new_idx}"})
            ops.append({"op": "add", "path": f"/products/{idx}", "value": old_prod})
            events.append({"origin": "COMPARISON", "eventType": "DELETED", "previousPath": f"/products/{idx}"})
        else:
            raise ValueError(f"unknown step kind {st['kind']!r} (schedule_change, cancel, rebook, delay, check_in, boarding, bags)")
        old_version, cur["version"] = cur.get("version", "1"), str(int(cur.get("version", "1") or 1) + 1)
        ops.append({"op": "replace", "path": "/version", "value": old_version})
        events.append({"origin": "COMPARISON", "eventType": "UPDATED", "currentPath": "/version", "previousPath": "/version"})
        lm = cur.setdefault("lastModification", {})
        old_lm = lm.get("dateTime")
        lm["dateTime"] = _fmt(at) + "Z"
        ops.append({"op": "replace", "path": "/lastModification/dateTime", "value": old_lm} if old_lm else {"op": "remove", "path": "/lastModification/dateTime"})
        events.append({"origin": "COMPARISON", "eventType": "UPDATED", "currentPath": "/lastModification/dateTime", "previousPath": "/lastModification/dateTime"})
        msg = copy.deepcopy(base)
        msg["processedPnr"] = cur
        msg["previousRecord"] = ops
        msg.setdefault("meta", {}).setdefault("triggerEventLog", {})["id"] = _trigger_id(rng)
        ev = msg.setdefault("events", {})
        ev["events"] = events
        ev["originFeedTimeStamp"] = _fmt(at) + "Z"
        ev.setdefault("recordDomain", "PNR")
        ev.setdefault("recordId", cur.get("id"))
        out.append({"ts": _fmt(at) + "Z", "prodTopic": base_msg["prodTopic"], "value": json.dumps(msg, separators=(",", ":"))})
        prev = cur
    return sorted(out, key=lambda m: m["ts"] or "")


def _utc(local, airport):
    tz = AIRPORT_TZ.get(airport)
    if not tz:
        raise ValueError(f"no time zone for airport {airport}")
    return _parse(local).replace(tzinfo=ZoneInfo(tz)).astimezone(timezone.utc).replace(tzinfo=None)


def _z(d):
    return _fmt(d) + "Z"


def _delay(seg, st, at, now, rng):
    """FDM messages for one delayed flight, in the live Kafka shape (no landing envelope; lastUpdate stamps the time)."""
    mins = int(st["minutes"])
    if mins <= 0:
        raise ValueError("a delay needs minutes > 0")
    op = seg.get("operating") if isinstance(seg.get("operating"), dict) else seg
    carrier, number = op.get("carrierCode") or seg["carrierCode"], str(op.get("number") or seg["number"])
    dep_ap, arr_ap = seg["departure"]["iataCode"], seg["arrival"]["iataCode"]
    sd, sa = _utc(seg["departure"]["localDateTime"], dep_ap), _utc(seg["arrival"]["localDateTime"], arr_ap)
    ed, ea = sd + timedelta(minutes=mins), sa + timedelta(minutes=mins)
    user = f"AC{rng.randrange(100000, 999999)}"
    code = str(st.get("code") or "93")

    def msg(t, state, actuals):
        leg = {"state": state, "callSign": f"ACA{number}" if carrier == "AC" else f"{carrier}{number}",
               "schedule": {"departureAirport": dep_ap, "departure": _z(sd), "arrivalAirport": arr_ap, "arrival": _z(sa),
                            "serviceType": "J", "aircraftOwner": carrier, "employerCabin": carrier, "employerCockpit": carrier},
               "lastUpdate": {"userId": user, "timestamp": _z(t)}, "_attributes": {"modified": "UPD"}}
        if actuals:
            leg["actuals"] = actuals
        v = {"message": {"flightDetail": {
            "identifier": {"flight": {"fnCarrier": carrier, "fnNumber": number}, "dayOfOrigin": sd.strftime("%Y-%m-%d"),
                           "localDayOfOrigin": _parse(seg["departure"]["localDateTime"]).strftime("%Y-%m-%d")},
            "leg": leg}}}
        return {"ts": _z(t), "prodTopic": FDM_TOPIC, "value": json.dumps(v, separators=(",", ":"))}

    upd = lambda x: {"_attributes": {"modified": "UPD"}, "_text": _z(x)}
    est = {"estimatedTimeDeparture": upd(ed), "estimatedTimeArrival": upd(ea),
           "delay": [{"delayCode": code, "delayTime": str(mins), "subDelayCode": "", "_attributes": {"modified": "UPD"}}]}
    out = [msg(min(at - timedelta(minutes=1), sd - timedelta(hours=2)), "SKD", None), msg(at, "ETD", est)]
    if ed + timedelta(minutes=10) < now:  # the delayed flight has left: off-block and airborne
        out.append(msg(ed + timedelta(minutes=10), "OFB", dict(est, offblockTime=upd(ed), airborneTime=upd(ed + timedelta(minutes=10)))))
    if ea < now:  # and arrived: landing, on-block, state ARR (what DDS waits for)
        out.append(msg(ea, "ARR", dict(est, offblockTime=upd(ed), airborneTime=upd(ed + timedelta(minutes=10)),
                                       landingTime=upd(ea - timedelta(minutes=8)), onblockTime=upd(ea))))
    return [m for m in out if _parse(m["ts"]) <= now]


def _check_in(template, built, seg, st, at, rng):
    """One CM message per passenger record on this flight: acceptance ACCEPTED (check_in), or boarding BOARDED plus the
    acceptance when missing (boarding); previousRecord patch and a COMPARISON event at each changed path."""
    latest = {}
    for m in template + built:  # the newest CM record per DCS passenger id
        if "ALTEA-CM" not in m["prodTopic"]:
            continue
        v = json.loads(m["value"])
        p = v.get("processedDcsPassenger")
        if isinstance(p, dict) and p.get("id") and (p["id"] not in latest or (m["ts"] or "") >= latest[p["id"]][0]):
            latest[p["id"]] = (m["ts"] or "", m["prodTopic"], v)
    out = []
    for _ts, topic, v in latest.values():
        v = copy.deepcopy(v)
        p = v["processedDcsPassenger"]
        hit = None
        for i, sd in enumerate(p.get("segmentDeliveries") or []):
            s = sd.get("segment") or {}
            if (s.get("carrierCode"), str(s.get("number"))) == (seg["carrierCode"], str(seg["number"])) and sd.get("legDeliveries"):
                hit = i
                break
        if hit is None:
            continue
        base = f"/segmentDeliveries/{hit}/legDeliveries/0"
        leg = p["segmentDeliveries"][hit]["legDeliveries"][0]
        new = {}
        if st["kind"] == "check_in" or not leg.get("acceptance"):
            new["acceptance"] = {"securityNumber": f"{seg['departure']['iataCode']}-{rng.randrange(1, 400)}",
                                 "channel": st.get("channel", "WEB"), "isAdvanceAccepted": False,
                                 "acceptanceType": "PRIMARY", "status": "ACCEPTED"}
        if st["kind"] == "boarding":
            new["boarding"] = {"trackingLog": {"referenceDeviceType": "DUMD_GATE_READER", "utcDateTime": _z(at), "logSource": "JFE",
                                               "deviceId": "SYN" + "".join(rng.choice(string.ascii_uppercase) for _ in range(6))},
                               "boardingPassPrint": {"channel": st.get("channel", "WEB"), "status": "PRINTED"},
                               "boardingStatus": "BOARDED", "boardingZone": str(rng.randrange(1, 7))}
        ops, evs = [], []
        for k, val in new.items():
            path, old = f"{base}/{k}", leg.get(k)
            leg[k] = val
            ops.append({"op": "replace", "path": path, "value": old} if old else {"op": "remove", "path": path})
            evs.append({"origin": "COMPARISON", "eventType": "UPDATED" if old else "CREATED", "currentPath": path,
                        "previousPath": path if old else ""})
        old_etag, p["etag"] = p.get("etag"), str(int(at.replace(tzinfo=timezone.utc).timestamp() * 1000))
        v["previousRecord"] = ops[::-1] + [{"op": "replace", "path": "/etag", "value": old_etag}]
        v["lastModification"] = {"dateTime": _z(at), "triggerEventName": "BOARDING" if st["kind"] == "boarding" else "CHECKIN"}
        v.setdefault("meta", {}).setdefault("triggerEventLog", {})["id"] = _trigger_id(rng)
        v["events"] = {"recordId": p["id"], "recordDomain": "DcsPassenger", "originFeedTimeStamp": _z(at), "events": evs + [
            {"origin": "COMPARISON", "eventType": "UPDATED", "currentPath": "/etag", "previousPath": "/etag"}]}
        out.append({"ts": _z(at), "prodTopic": topic, "value": json.dumps(v, separators=(",", ":"))})
    if not out:
        raise ValueError(f"the booking has no check-in record for {seg['carrierCode']}{seg['number']}")
    return out


def _local(d_utc, airport):
    """A UTC time as BROCK writes it: station-local with its offset, e.g. 2026-02-13T14:36:48.0000000+08:00."""
    t = d_utc.replace(tzinfo=timezone.utc).astimezone(ZoneInfo(AIRPORT_TZ[airport]))
    off = t.strftime("%z")
    return t.strftime("%Y-%m-%dT%H:%M:%S.0000000") + off[:3] + ":" + off[3:]


def _bags(pnr, legs, st, at, now, rng):
    """BROCK events for checked bags over `legs` (PNR airSegments, in order) for every passenger."""
    outcome = st.get("outcome", "delivered")
    if outcome not in ("delivered", "delayed", "delayed_delivered"):
        raise ValueError("bags outcome must be delivered, delayed or delayed_delivered")
    if outcome != "delivered" and len(legs) < 2:
        raise ValueError("a delayed bag needs at least two segments (it misses the connection)")
    names = [f"{(t.get('names') or [{}])[0].get('lastName', 'TESTER')}/{(t.get('names') or [{}])[0].get('firstName', 'ALEX')}"
             for t in pnr.get("travelers") or [{}]]
    locator = (pnr.get("id") or "ZZ0000").split("-")[0]
    times = [(_utc(l["departure"]["localDateTime"], l["departure"]["iataCode"]), _utc(l["arrival"]["localDateTime"], l["arrival"]["iataCode"]))
             for l in legs]
    flight = lambda l: {"FlightArrivalStationCode": l["arrival"]["iataCode"], "FlightCarrierCode": l["carrierCode"],
                        "FlightDepartureDateLocal": l["departure"]["localDateTime"][:10],
                        "FlightDepartureStationCode": l["departure"]["iataCode"], "FlightNumber": str(l["number"]).zfill(4)}
    store = rng.randrange(6_000_000_000, 7_000_000_000)
    out = []
    for name in names:
        for _ in range(int(st.get("count", 1))):
            tag, bag_id = "0014" + "".join(rng.choice(string.digits) for _ in range(6)), rng.randrange(150_000_000, 199_999_999)
            evs = []

            def ev(t, typ, station, **kw):
                nonlocal store
                store += rng.randrange(1, 5000)
                evs.append((t, dict({"BagId": bag_id, "BagTag": tag, "EventStoreId": store, "PNR": locator, "SourceSystemId": 1,
                                     "StationCode": station, "Timestamp": _local(t, station), "Type": typ,
                                     "Version": "1.60.0+synthetic"}, **kw)))
            legs_json = [dict(flight(l), FlightLegTypeId=i) for i, l in enumerate(legs)]
            ev(at, "BagCreatedEvent", legs[0]["departure"]["iataCode"], PassengerName=name, BagTagStatus="Active",
               FrequentFlyerNumber="", FlightLegs=legs_json,
               BagFlightLegs=[dict(x, BagCategory="B", BagType="CheckedBag", Weight="", WeightUnitTypeId=1) for x in legs_json])
            ev(at + timedelta(seconds=2), "BagAcceptedDeclaration", legs[0]["departure"]["iataCode"], PassengerName=name)
            flown = legs if outcome == "delivered" else legs[:-1]  # a delayed bag misses the last connection
            for i, (l, (dep, arr)) in enumerate(zip(flown, times)):
                ev(dep - timedelta(minutes=40), "BagOnloadedEvent", l["departure"]["iataCode"], FlightLegTypeId=i,
                   ContainerBehaviorId="Loading", ContainerName=f"AKE{rng.randrange(10000, 99999)}AC", **flight(l))
                ev(arr + timedelta(minutes=15), "BagUnloadedEvent", l["arrival"]["iataCode"], BagCategory="B", BagTypeId=1,
                   BagHandlingTypeId=1, **flight(l))
            end, last_arr = legs[-1]["arrival"]["iataCode"], times[-1][1]
            if outcome == "delivered":
                ev(last_arr + timedelta(minutes=25), "BagDeliveredToCarouselDeclaration", end,
                   CarouselFriendlyName=f"Carousel {rng.randrange(1, 12)}", CarouselLocalizableIdentifier=f"IB{rng.randrange(1, 12)}A")
            else:
                ref = f"{end}AC{rng.randrange(10000, 99999)}"
                ev(last_arr + timedelta(minutes=45), "BagDelayedBagBdoCreatedEvent", end, IsSuccess=True, TracerReferenceId=ref)
                if outcome == "delayed_delivered":
                    d = last_arr + timedelta(hours=20)
                    ev(d, "BagDelayedBagDeliveredEvent", end, CarrierCode="AC", DeliveryInfo="Bag Delivered",
                       DeliveryTimestamp=_z(d)[:-1] + "+00:00", MasterBagId=bag_id, TracerReferenceId=ref)
                    ev(d + timedelta(minutes=5), "BagDelayedBagRecordClosedEvent", end, IsSuccess=True, TracerReferenceId=ref)
            out += [{"ts": _z(t), "prodTopic": BAG_TOPIC, "value": json.dumps(e, separators=(",", ":"))} for t, e in evs if t <= now]
    return out


def _apply_patch(doc, ops):
    """Minimal RFC 6902 apply (add, remove, replace) for the self-check: previousRecord must restore the prior version."""
    doc = copy.deepcopy(doc)
    for op in ops:
        parts = [p for p in op["path"].split("/")[1:]]
        parent = doc
        for p in parts[:-1]:
            parent = parent[int(p)] if isinstance(parent, list) else parent[p]
        k = parts[-1]
        if isinstance(parent, list):
            k = int(k)
            if op["op"] == "add":
                parent.insert(k, op["value"])
            elif op["op"] == "remove":
                parent.pop(k)
            else:
                parent[k] = op["value"]
        else:
            if op["op"] == "remove":
                parent.pop(k)
            else:
                parent[k] = op["value"]
    return doc


if __name__ == "__main__":
    seg = lambda n, d, a: {"carrierCode": "AC", "number": n, "departure": {"iataCode": "YUL", "localDateTime": d},
                           "arrival": {"iataCode": "YYZ", "localDateTime": a}}
    pnr = {"id": "ZZ1234-2026-10-01", "version": "4", "lastModification": {"dateTime": "2026-10-01T10:00:00Z"},
           "products": [{"id": "ST-1", "subType": "SERVICE"},
                        {"id": "ST-2", "subType": "AIR", "airSegment": seg("301", "2026-11-03T08:00:00", "2026-11-03T09:25:00")},
                        {"id": "ST-3", "subType": "AIR", "airSegment": seg("856", "2026-11-03T19:30:00", "2026-11-04T07:35:00")}]}
    msgs = [{"ts": "2026-10-01T10:00:00Z", "prodTopic": "emh-prd.ALTEA-PNRDATA-PRD",
             "value": json.dumps({"meta": {"triggerEventLog": {"id": "x"}, "version": "1.0.0"}, "processedPnr": pnr,
                                  "events": {"events": [], "recordDomain": "PNR", "recordId": pnr["id"]}})}]
    out = apply(msgs, [{"kind": "schedule_change", "segment": 2, "minutes": 95},
                       {"kind": "rebook", "segment": 1, "carrier": "AC", "number": "305", "depart": "2026-11-03T10:00"}],
                now=datetime(2026, 10, 14, 12, 0), rng=random.Random(1))
    assert len(out) == 3 and out[0]["ts"] < out[1]["ts"] < out[2]["ts"] <= "2026-10-14T12:00:00Z", [m["ts"] for m in out]
    v1, v2 = (json.loads(m["value"]) for m in out[1:])
    p1, p2 = v1["processedPnr"], v2["processedPnr"]
    assert p1["products"][2]["airSegment"]["departure"]["localDateTime"] == "2026-11-03T21:05:00"
    assert _apply_patch(p1, v1["previousRecord"]) == pnr  # the patch restores the version before the change
    assert _apply_patch(p2, v2["previousRecord"]) == p1
    air = [p["airSegment"] for p in p2["products"] if p.get("subType") == "AIR"]
    assert [a["number"] for a in air] == ["856", "305"] and air[1]["arrival"]["localDateTime"] == "2026-11-03T11:25:00", air
    assert (p1["version"], p2["version"]) == ("5", "6")
    assert {e["eventType"] for e in v2["events"]["events"]} == {"CREATED", "DELETED", "UPDATED"}
    assert p2["products"][-1]["id"] == "ST-4"  # a fresh numeric tattoo, past every one in use (ST-1..ST-3)
    assert len(flights_left(out)) == 2
    # the base is the highest version even when an older version's message is the latest (a re-send)
    resent = msgs + [dict(msgs[0], ts="2026-10-02T10:00:00Z", value=msgs[0]["value"].replace('"version": "4"', '"version": "3"'))]
    v = json.loads(apply(resent, [{"kind": "schedule_change", "segment": 1, "minutes": 5}], now=datetime(2026, 10, 14, 12, 0))[-1]["value"])
    assert v["processedPnr"]["version"] == "5", v["processedPnr"]["version"]
    # a booking whose newest version has no flight left (a standby removed, a cancelled booking) holds none
    gone = [dict(msgs[0], value=json.dumps({"processedPnr": dict(pnr, products=[pnr["products"][0]])}))]
    assert flights_left(gone) == []
    # delay + check-in on a past flight: FDM completes (ARR) with the delay; CM acceptance created with its patch
    cmdoc = {"meta": {"triggerEventLog": {"id": "y"}}, "processedDcsPassenger": {"id": "P1", "etag": "1", "segmentDeliveries": [
        {"segment": {"carrierCode": "AC", "number": "301"}, "legDeliveries": [{"id": "L1"}]}]}}
    past = [{"ts": "2026-09-01T10:00:00Z", "prodTopic": "emh-prd.ALTEA-PNRDATA-PRD", "value": msgs[0]["value"].replace("2026-11-03", "2026-10-03")},
            {"ts": "2026-09-02T10:00:00Z", "prodTopic": CM_TOPIC, "value": json.dumps(cmdoc)}]
    out = apply(past, [{"kind": "check_in", "segment": 1, "at": "2026-10-03T06:00"},
                       {"kind": "delay", "segment": 1, "minutes": 90, "at": "2026-10-03T10:30"}],
                now=datetime(2026, 10, 14, 12, 0), rng=random.Random(2))
    fdm = [json.loads(m["value"]) for m in out if m["prodTopic"] == FDM_TOPIC]
    assert [f["message"]["flightDetail"]["leg"]["state"] for f in fdm] == ["SKD", "ETD", "OFB", "ARR"], fdm
    leg = fdm[1]["message"]["flightDetail"]["leg"]
    assert leg["schedule"]["departure"] == "2026-10-03T12:00:00Z"  # 08:00 Montreal (EDT) is 12:00 UTC
    assert leg["actuals"]["estimatedTimeDeparture"]["_text"] == "2026-10-03T13:30:00Z"
    assert fdm[0]["message"]["flightDetail"]["identifier"] == {"flight": {"fnCarrier": "AC", "fnNumber": "301"},
                                                              "dayOfOrigin": "2026-10-03", "localDayOfOrigin": "2026-10-03"}
    ci = [json.loads(m["value"]) for m in out if m["prodTopic"] == CM_TOPIC][-1]
    assert ci["processedDcsPassenger"]["segmentDeliveries"][0]["legDeliveries"][0]["acceptance"]["status"] == "ACCEPTED"
    assert _apply_patch(ci["processedDcsPassenger"], ci["previousRecord"]) == cmdoc["processedDcsPassenger"]
    assert ci["events"]["events"][0] == {"origin": "COMPARISON", "eventType": "CREATED", "previousPath": "",
                                         "currentPath": "/segmentDeliveries/0/legDeliveries/0/acceptance"}
    assert all(m["ts"] <= "2026-10-14T12:00:00Z" for m in out) and [m["ts"] for m in out] == sorted(m["ts"] for m in out)
    bo = apply(past, [{"kind": "boarding", "segment": 1, "at": "2026-10-03T11:40"}], now=datetime(2026, 10, 14, 12, 0), rng=random.Random(3))
    b = [json.loads(m["value"]) for m in bo if m["prodTopic"] == CM_TOPIC][-1]
    leg0 = b["processedDcsPassenger"]["segmentDeliveries"][0]["legDeliveries"][0]
    assert leg0["boarding"]["boardingStatus"] == "BOARDED" and leg0["acceptance"]["status"] == "ACCEPTED"  # not checked in before
    assert _apply_patch(b["processedDcsPassenger"], b["previousRecord"]) == cmdoc["processedDcsPassenger"]
    assert {e["currentPath"] for e in b["events"]["events"]} >= {"/segmentDeliveries/0/legDeliveries/0/boarding",
                                                                "/segmentDeliveries/0/legDeliveries/0/acceptance"}
    pnr2 = dict(pnr, id="ZZ1234-2026-09-01", travelers=[{"names": [{"firstName": "ALEX", "lastName": "TESTER"}]}],
                products=[dict(p, airSegment=dict(p["airSegment"], departure=dict(p["airSegment"]["departure"], localDateTime=p["airSegment"]["departure"]["localDateTime"].replace("11-03", "10-03")),
                                                   arrival=dict(p["airSegment"]["arrival"], localDateTime=p["airSegment"]["arrival"]["localDateTime"].replace("11-03", "10-03").replace("11-04", "10-04"))))
                          if p.get("subType") == "AIR" else p for p in pnr["products"]])
    two = [{"ts": "2026-09-01T10:00:00Z", "prodTopic": "emh-prd.ALTEA-PNRDATA-PRD", "value": json.dumps({"processedPnr": pnr2, "events": {}})}]
    for outcome, last in (("delivered", "BagDeliveredToCarouselDeclaration"), ("delayed_delivered", "BagDelayedBagRecordClosedEvent")):
        bg = [json.loads(m["value"]) for m in apply(two, [{"kind": "bags", "segment": 1, "outcome": outcome, "at": "2026-10-03T10:30"}],
                                                    now=datetime(2026, 10, 14, 12, 0), rng=random.Random(4)) if m["prodTopic"] == BAG_TOPIC]
        assert bg[0]["Type"] == "BagCreatedEvent" and bg[0]["PassengerName"] == "TESTER/ALEX" and bg[0]["PNR"] == "ZZ1234", bg[0]
        assert bg[0]["Timestamp"] == "2026-10-03T06:30:00.0000000-04:00" and len(bg[0]["FlightLegs"]) == 2
        assert bg[-1]["Type"] == last, [x["Type"] for x in bg]
        onl = [x for x in bg if x["Type"] == "BagOnloadedEvent"]
        assert len(onl) == (2 if outcome == "delivered" else 1) and onl[0]["FlightNumber"] == "0301"
        assert len({x["BagTag"] for x in bg}) == 1
    try:
        apply(past[:1], [{"kind": "check_in", "segment": 1}], now=datetime(2026, 10, 14, 12, 0))
        raise AssertionError("check-in without a CM record must fail")
    except ValueError:
        pass
    print("timeline self-check ok")
