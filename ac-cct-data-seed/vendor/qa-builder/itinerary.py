"""Free-form itineraries for the QA generator (F12): rewrite a template booking's event history to a requested itinerary.

A template is a real, anonymised booking from the pool (one JSON message per line, {"ts", "prodTopic", "value"}). The
requested itinerary has the same number of air segments as the template (the caller picks a template of that shape):

    {"segments": [{"carrier": "AC", "number": "301", "from": "YUL", "to": "YYZ", "depart": "2026-11-03T08:00"}, ...]}

What changes, in every message of every feed:
  - Time: the whole history shifts by one delta (requested first departure minus the template's), so bookings,
    ticketing, check-in and flight events keep their order and spacing. ISO dates and date-times are shifted wherever
    they appear, including inside ids such as "ZZ1234-2026-09-23".
  - Each air segment (processedPnr products of subType AIR, and any object with that airSegment shape) is set exactly:
    airports, marketing carrier and number, departure as requested, arrival = departure + the template's duration.
  - Elsewhere (check-in legs, tickets, flight ids): a value equal to a template airport becomes the requested one; a
    flight-number field equal to a template flight number becomes the requested one; composite ids like
    "AC#123#2026-09-12#YYZ" and "AC123" are rewritten.
Anything else (fares, statuses, bags, the anonymised identities) stays as the template had it.
"""
import json
import re
from datetime import datetime, timedelta

DT = re.compile(r"(?<!\d)(\d{4}-\d{2}-\d{2})(?:([T ])(\d{2}:\d{2}(?::\d{2}(?:\.\d+)?)?))?(?!\d)")
SEG_MARK = "__qa_segment"
FLIGHT_NUMBER_KEYS = {"number", "flightNumber", "FlightNumber", "flightnumber", "marketingFlightNumber",
                      "operatingFlightNumber", "OutboundFlightNumber", "causingFlightNumber"}


# Identifiers that link one booking's records across feeds: DCS passenger and leg ids (16 upper-case hex, with at
# least one letter), ticket and EMD numbers (13 digits, airline prefix first) and bag tags (10 digits). The pool keeps
# the template's values, so every copy of a template shared them; ingestion routes check-in records by DCS passenger
# id, and copies made the same day sent each other's check-ins to the wrong booking or held them for minutes (ZZHU5M,
# ZZI5Z2 and ZZ937O from ZZ9T5L, INT, 2026-10-14).
LINK_IDS = re.compile(r"(?<![A-Za-z0-9])(?:[0-9A-F]{16}|0\d{12}|0\d{9})(?![A-Za-z0-9])")


def fresh_ids(text, rng):
    """`text` with every cross-feed identifier replaced by a fresh random one, the same one wherever it recurs.
    Prefixes stay (the airline code of a ticket, the 0014 of a bag tag); all-digit hex and all-zero values stay."""
    new = {}

    def fresh(tok):
        if len(tok) == 16:
            return "".join(rng.choice("0123456789ABCDEF") for _ in range(16)) if re.search("[A-F]", tok) else tok
        if not tok.strip("0"):
            return tok
        keep = 3 if len(tok) == 13 else 4
        return tok[:keep] + "".join(rng.choice("0123456789") for _ in range(len(tok) - keep))
    return LINK_IDS.sub(lambda m: new.setdefault(m.group(0), fresh(m.group(0))), text)


def _parse(s):
    s = s.replace(" ", "T")[:19]
    for f in ("%Y-%m-%dT%H:%M:%S", "%Y-%m-%dT%H:%M", "%Y-%m-%d"):
        try:
            return datetime.strptime(s, f)
        except ValueError:
            pass
    raise ValueError(f"not a date-time: {s}")


def _walk(v, fn, key=""):
    if isinstance(v, dict):
        return {k: _walk(x, fn, k) for k, x in v.items()}
    if isinstance(v, list):
        return [_walk(x, fn, key) for x in v]
    if isinstance(v, str):
        if v[:1] in "{[":
            try:
                return json.dumps(_walk(json.loads(v), fn, key))
            except ValueError:
                pass
        return fn(v, key)
    return v


def _air_segments(v, out):
    """Every airSegment-shaped dict (departure/arrival with iataCode, carrierCode, number) found in v."""
    if isinstance(v, dict):
        if isinstance(v.get("departure"), dict) and isinstance(v.get("arrival"), dict) and "carrierCode" in v and "number" in v:
            out.append(v)
        for x in v.values():
            _air_segments(x, out)
    elif isinstance(v, list):
        for x in v:
            _air_segments(x, out)
    elif isinstance(v, str) and v[:1] in "{[":
        try:
            _air_segments(json.loads(v), out)
        except ValueError:
            pass
    return out


def template_segments(messages):
    """The template's distinct air segments in departure order: (carrier, number, from, to, depart, arrive)."""
    seen = {}
    for m in messages:
        for s in _air_segments(json.loads(m["value"]), []):
            try:
                key = (s["carrierCode"], s["number"], s["departure"]["iataCode"], s["arrival"]["iataCode"])
                dep, arr = _parse(s["departure"]["localDateTime"]), _parse(s["arrival"]["localDateTime"])
            except (KeyError, ValueError, TypeError):
                continue
            seen[key] = (dep, arr)
    segs = sorted(((k, v) for k, v in seen.items()), key=lambda kv: kv[1][0])
    return [{"carrier": k[0], "number": k[1], "from": k[2], "to": k[3], "depart": d, "arrive": a} for k, (d, a) in segs]


def passengers(messages):
    n = 0
    for m in messages:
        v = json.loads(m["value"])
        if isinstance(v, dict) and isinstance(v.get("processedPnr"), dict):
            n = max(n, len(v["processedPnr"].get("travelers") or []))
    return n


def _ts(m):
    try:
        return _parse(m["ts"]) if m.get("ts") else None
    except ValueError:
        return None


def rewrite(messages, itinerary, now=None):
    """The template's history moved to the itinerary. A booking cannot have events after now: for a flight still ahead,
    only the template's events before its departure are kept (booking, ticketing, changes) and they are moved so the
    latest lands 5 minutes ago; for a past flight the whole history moves with the flights and anything that would land
    after now is dropped."""
    now = now or datetime.utcnow().replace(microsecond=0)
    old = template_segments(messages)
    new = itinerary["segments"]
    if len(old) != len(new) or not old:
        raise ValueError(f"template has {len(old)} air segments, itinerary has {len(new)}")
    new_dep = [_parse(s["depart"]) for s in new]
    durations = [(_parse(n["arrive"]) - d) if n.get("arrive") else (o["arrive"] - o["depart"]) for n, o, d in zip(new, old, new_dep)]
    delta = new_dep[0] - old[0]["depart"]
    if new_dep[0] > now:
        pre = [m for m in messages if (_ts(m) or old[0]["depart"]) <= old[0]["depart"]] or messages[:1]
        last = max((_ts(m) for m in pre if _ts(m)), default=old[0]["depart"])
        delta = min(delta, (now - timedelta(minutes=5)) - last)
        messages = pre
    by_key = {(o["carrier"], o["number"], o["from"], o["to"]): i for i, o in enumerate(old)}
    airports, numbers, ids = {}, {}, []
    for o, n in zip(old, new):
        airports.setdefault(o["from"], n["from"]); airports.setdefault(o["to"], n["to"])
        numbers.setdefault(o["number"], str(n["number"]))
        ids.append((re.compile(rf"(?<![A-Z0-9]){re.escape(o['carrier'])}(#?)0*{re.escape(o['number'])}(?!\d)"),
                    lambda m, n=n: f"{n['carrier']}{m.group(1)}{n['number']}"))

    def shift(s, key):
        def one(m):
            d = _parse(m.group(1) + ("T" + m.group(3) if m.group(3) else ""))
            d += delta if m.group(3) else timedelta(days=round(delta.total_seconds() / 86400))
            out = d.strftime("%Y-%m-%d")
            if m.group(3):
                frac = m.group(3)[8:] if len(m.group(3)) > 8 else ""
                out += m.group(2) + d.strftime("%H:%M:%S" if len(m.group(3)) >= 8 else "%H:%M") + frac
            return out
        s = DT.sub(one, s)
        if s in airports:
            return airports[s]
        if "#" in s:  # composite flight ids: AC#856#2026-09-10#YYZ, the date becoming that segment's requested date
            toks = [airports.get(t, numbers.get(t, t)) for t in s.split("#")]
            seg = next((i for i, n in enumerate(new) if str(n["number"]) in toks), None)
            if seg is not None:
                toks = [new_dep[seg].strftime("%Y-%m-%d") if re.fullmatch(r"\d{4}-\d{2}-\d{2}", t) else t for t in toks]
            s = "#".join(toks)
        if key in FLIGHT_NUMBER_KEYS and s in numbers:
            return numbers[s]
        for rx, rep in ids:
            s = rx.sub(rep, s)
        return s

    def fix_segments(v):
        if isinstance(v, dict):
            if isinstance(v.get("departure"), dict) and isinstance(v.get("arrival"), dict) and "carrierCode" in v and "number" in v:
                i = by_key.get((v.get("carrierCode"), v.get("number"), v["departure"].get("iataCode"), v["arrival"].get("iataCode")))
                if i is not None:
                    n, o = new[i], old[i]
                    dep = new_dep[i]
                    arr = dep + durations[i]
                    v["carrierCode"], v["number"] = n["carrier"], str(n["number"])
                    v["departure"]["iataCode"], v["arrival"]["iataCode"] = n["from"], n["to"]
                    v["departure"]["localDateTime"] = dep.strftime("%Y-%m-%dT%H:%M:%S")
                    v["arrival"]["localDateTime"] = arr.strftime("%Y-%m-%dT%H:%M:%S")
                    op = v.get("operating")
                    if isinstance(op, dict) and op.get("carrierCode") == o["carrier"]:
                        op["carrierCode"], op["number"] = n["carrier"], str(n["number"])
                    v[SEG_MARK] = i  # the shift pass may remap a requested airport/number that equals a template one
            return {k: fix_segments(x) for k, x in v.items()}
        if isinstance(v, list):
            return [fix_segments(x) for x in v]
        if isinstance(v, str) and v[:1] in "{[":
            try:
                return json.dumps(fix_segments(json.loads(v)))
            except ValueError:
                pass
        return v

    out = []
    for m in messages:
        v = fix_segments(json.loads(m["value"]))          # exact segments first (they hold the template's values)
        v = _walk(v, shift)                                 # then time, airports, numbers, ids everywhere
        v = fix_segments_reassert(v, new, new_dep, durations)  # segment times as requested, not shifted twice
        ts = DT.sub(lambda mm: (_parse(mm.group(0)) + delta).strftime("%Y-%m-%dT%H:%M:%S") if mm.group(3) else mm.group(0), m["ts"]) if m["ts"] else m["ts"]
        if ts and _parse(ts) > now:
            continue  # would be in the future
        out.append({"ts": ts, "prodTopic": m["prodTopic"], "value": json.dumps(v, separators=(",", ":"))})
    return out


def fix_segments_reassert(v, new, new_dep, durations):
    """After the global shift, every segment object fix_segments marked gets the requested values again: the shift moved
    its times by the global delta, and may have remapped a requested airport or number that equals a template one
    (template YYZ-YHZ to YUL-YYZ turned the new YYZ back into YUL)."""
    if isinstance(v, dict):
        i = v.pop(SEG_MARK, None)
        if i is not None:
            n = new[i]
            v["carrierCode"], v["number"] = n["carrier"], str(n["number"])
            v["departure"]["iataCode"], v["arrival"]["iataCode"] = n["from"], n["to"]
            v["departure"]["localDateTime"] = new_dep[i].strftime("%Y-%m-%dT%H:%M:%S")
            v["arrival"]["localDateTime"] = (new_dep[i] + durations[i]).strftime("%Y-%m-%dT%H:%M:%S")
            if isinstance(v.get("operating"), dict) and v["operating"].get("carrierCode") == n["carrier"]:
                v["operating"]["number"] = str(n["number"])
        return {k: fix_segments_reassert(x, new, new_dep, durations) for k, x in v.items()}
    if isinstance(v, list):
        return [fix_segments_reassert(x, new, new_dep, durations) for x in v]
    if isinstance(v, str) and v[:1] in "{[":
        try:
            return json.dumps(fix_segments_reassert(json.loads(v), new, new_dep, durations))
        except ValueError:
            pass
    return v


if __name__ == "__main__":  # self-check on a synthetic two-segment booking
    seg = lambda c, n, f, t, d, a: {"carrierCode": c, "number": n, "departure": {"iataCode": f, "localDateTime": d},
                                    "arrival": {"iataCode": t, "localDateTime": a}, "operating": {"carrierCode": c, "number": n}}
    pnr = {"processedPnr": {"id": "ZZ1234-2026-09-01", "travelers": [{}, {}], "products": [
        {"subType": "AIR", "airSegment": seg("AC", "100", "YUL", "YYZ", "2026-09-10T08:00:00", "2026-09-10T09:20:00")},
        {"subType": "AIR", "airSegment": seg("AC", "856", "YYZ", "LHR", "2026-09-10T21:00:00", "2026-09-11T09:00:00")}]},
           "meta": {"triggerEventLog": {"id": "x"}}}
    cm = {"leg": {"boardPoint": "YYZ", "offPoint": "LHR", "flightId": "AC#856#2026-09-10#YYZ", "number": "856"}}
    msgs = [{"ts": "2026-09-01T10:00:00Z", "prodTopic": "emh-prd.ALTEA-PNRDATA-PRD", "value": json.dumps(pnr)},
            {"ts": "2026-09-10T19:00:00Z", "prodTopic": "emh-prd.ALTEA-CM-PRD", "value": json.dumps(cm)}]
    assert len(template_segments(msgs)) == 2 and passengers(msgs) == 2
    out = rewrite(msgs, now=datetime(2027, 1, 1), itinerary={"segments": [{"carrier": "AC", "number": "301", "from": "YVR", "to": "YYC", "depart": "2026-11-03T07:00"},
                                      {"carrier": "AC", "number": "850", "from": "YYC", "to": "CDG", "depart": "2026-11-03T18:30"}]})
    p, c = json.loads(out[0]["value"]), json.loads(out[1]["value"])
    s0, s1 = (x["airSegment"] for x in p["processedPnr"]["products"])
    assert (s0["number"], s0["departure"]["iataCode"], s0["arrival"]["iataCode"]) == ("301", "YVR", "YYC"), s0
    assert s0["departure"]["localDateTime"] == "2026-11-03T07:00:00" and s0["arrival"]["localDateTime"] == "2026-11-03T08:20:00", s0
    assert s1["departure"]["localDateTime"] == "2026-11-03T18:30:00" and s1["arrival"]["localDateTime"] == "2026-11-04T06:30:00", s1
    assert p["processedPnr"]["id"] == "ZZ1234-2026-10-25", p["processedPnr"]["id"]  # history shifted by the same delta
    assert c["leg"] == {"boardPoint": "YYC", "offPoint": "CDG", "flightId": "AC#850#2026-11-03#YYC", "number": "850"}, c
    assert out[0]["ts"].startswith("2026-10-25T"), out[0]["ts"]
    # A flight still ahead: only pre-departure events, moved so the latest lands 5 min before now; nothing after now.
    fut = rewrite(msgs, now=datetime(2026, 10, 14, 12, 0), itinerary={"segments": [
        {"carrier": "AC", "number": "301", "from": "YVR", "to": "YYC", "depart": "2026-11-03T07:00"},
        {"carrier": "AC", "number": "850", "from": "YYC", "to": "CDG", "depart": "2026-11-03T18:30", "arrive": "2026-11-04T08:45"}]})
    assert len(fut) == 1 and fut[0]["ts"] == "2026-10-14T11:55:00Z", [m["ts"] for m in fut]
    s1 = json.loads(fut[0]["value"])["processedPnr"]["products"][1]["airSegment"]
    assert s1["departure"]["localDateTime"] == "2026-11-03T18:30:00" and s1["arrival"]["localDateTime"] == "2026-11-04T08:45:00", s1
    # A requested airport equal to another template airport (template YYZ-YHZ, requested YUL-YYZ) must not be remapped
    one = {"processedPnr": {"id": "ZZ1234-2026-09-01", "travelers": [{}], "products": [
        {"subType": "AIR", "airSegment": seg("AC", "814", "YYZ", "YHZ", "2025-06-08T23:00:00", "2025-06-09T02:09:00")}]}}
    r = rewrite([{"ts": "2025-06-05T12:00:00Z", "prodTopic": "emh-prd.ALTEA-PNRDATA-PRD", "value": json.dumps(one)}],
                {"segments": [{"carrier": "AC", "number": "301", "from": "YUL", "to": "YYZ", "depart": "2026-10-10T08:00"}]},
                now=datetime(2026, 10, 14, 12, 0))
    s0 = json.loads(r[0]["value"])["processedPnr"]["products"][0]["airSegment"]
    assert (s0["departure"]["iataCode"], s0["arrival"]["iataCode"], s0["departure"]["localDateTime"]) == ("YUL", "YYZ", "2026-10-10T08:00:00"), s0
    assert SEG_MARK not in r[0]["value"]
    import random
    t = '{"id":"300E14B2000F38B5-CMH","p":"300E14B2000F38B5","doc":"0144089762161","tag":"0014123456","n":"1234567890123456","z":"0000000000","ts":1792028618739}'
    f = fresh_ids(t, random.Random(1))
    d = json.loads(f)
    assert d["p"] != "300E14B2000F38B5" and d["id"] == d["p"] + "-CMH", d  # one id, replaced the same everywhere
    assert d["doc"][:3] == "014" and d["doc"] != "0144089762161" and len(d["doc"]) == 13
    assert d["tag"][:4] == "0014" and d["tag"] != "0014123456"
    assert (d["n"], d["z"], d["ts"]) == ("1234567890123456", "0000000000", 1792028618739)  # not identifiers
    print("itinerary self-check ok")
