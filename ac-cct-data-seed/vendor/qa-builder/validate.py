"""/tools/validate: what a built timeline must satisfy before it may be published (contracts.md §2).

Rules, each `{"id", "ok", "detail", "warnings"}`; `ok` of the whole is every rule but `timing` (which warns):
  identity  ZZ locator, synth.test e-mails, +1-555 phones, no tester placeholder in any message
  leak      no identity value of the seed survives (locators, names, e-mails, phones, tickets, CPIDs, DCS ids, bag tags)
  ordering  every family's playbook predecessors come earlier; PNR versions, CM etags and ticket versions increase
  joins     tickets, correlations, CM, bags, profile links, vouchers, notifications and FDM legs name this booking's
            ids and flights
  schema    every message round-trips as JSON and carries the fields the Rust parsers read; when tt-engine-oracle is
            built, the owner folder replays through it (its EDS changes are the detail)
  timing    each family's offset from its anchor is within the playbook norms (warnings)
"""
import hashlib
import json
import os
import re
import shutil
import subprocess
import tempfile
from datetime import datetime, timedelta, timezone
from pathlib import Path

from builder import TESTER, TOPIC, feed_of, iso_utc, kind_of, parse_utc
from playbook import playbook

def repo_root(here: Path) -> Path | None:
    """The checkout above tools/qa-scenarios/service/, or None in the tt-qa image, where this file is
    /app/validate.py with no repository above it (the import crashed there on 2026-10-15: IndexError)."""
    parents = here.resolve().parents
    return parents[3] if len(parents) > 3 else None


# In the image the oracle, rules and refdb come from the TT_QA_* variables or are absent; validation then
# skips the oracle step (see the ORACLE.exists() check), as it always did without them.
REPO = repo_root(Path(__file__)) or Path("/nonexistent-repo")
ORACLE = Path(os.environ.get("TT_QA_ORACLE", REPO / "apps/trip-tracer-event-processor/rust/target/dev-qa/tt-engine-oracle"))
RULES = Path(os.environ.get("TT_QA_RULES", REPO / "apps/trip-tracer-event-processor/rules"))
REFDB = Path(os.environ.get("TT_QA_REFDB", REPO / "kb/source-code/ecs/ac-cct-rule-engine-platform/reference/refdb/refdb.json"))
FAMILY_ALIAS = {"pnr_version": "pnr_creation", "flight_ops": "flight_scheduled", "bag_scan": "bag_created"}


def validate(build, oracle=True):
    rules = [rule_identity(build), rule_leak(build), rule_ordering(build), rule_joins(build), rule_schema(build, oracle), rule_timing(build)]
    return {"ok": all(r["ok"] for r in rules if r["id"] != "timing"), "rules": rules}


def _rule(rid, problems, detail="", warnings=None):
    return {"id": rid, "ok": not problems, "detail": detail if not problems else "; ".join(problems[:8]) + (f" (+{len(problems) - 8})" if len(problems) > 8 else ""),
            "warnings": warnings or []}


def rule_identity(build):
    problems = []
    if not re.fullmatch(r"ZZ[A-Z0-9]{4}", build.locator):
        problems.append(f"locator {build.locator} is not a ZZ sentinel")
    for i, m in enumerate(build.messages):
        text = m["value"]
        for e in set(re.findall(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}", text)):
            if not e.endswith("@synth.test"):
                problems.append(f"message {i}: e-mail {e[:3]}… is not synth.test")
        for p in set(re.findall(r"\+\d[\d-]{9,15}", text)):
            if not p.startswith("+1-555") and not p.startswith("+1555"):
                problems.append(f"message {i}: phone {p[:4]}… is not +1-555")
        if TESTER.search(text):
            problems.append(f"message {i}: a tester placeholder is in the message")
    return _rule("identity", problems, f"{build.locator}: synthetic identities only")


def rule_leak(build):
    originals = build.seed.originals
    # A value the build legitimately carries is not a survivor: a fresh token, a stand-in or a plan name.
    fresh = set(build.rw.tokens.values()) | {n for pair in build.rw.stand_ins for n in pair} | \
        {str(p.get(k, "")).upper() for p in build.plan.passengers for k in ("firstName", "lastName")}
    live = set()
    for kind, values in originals.items():
        for v in values:
            if len(v) >= 4 and v not in fresh and v not in build.rw.tokens.get(v, "") and build.rw.tokens.get(v) != v:
                live.add(v)
    if not live:
        return _rule("leak", [], "no seed identity to check")
    rx = re.compile(r"(?<![A-Za-z0-9@.])(" + "|".join(re.escape(v) for v in sorted(live, key=len, reverse=True)) + r")(?![A-Za-z0-9@])")
    problems = []
    for i, m in enumerate(build.messages):
        hit = rx.search(m["value"])
        if hit:
            problems.append(f"message {i} ({m['family']}): seed value {hit.group(1)[:2]}…{hit.group(1)[-2:]} survives")
    return _rule("leak", problems, f"{len(live)} seed identity values checked across {len(build.messages)} messages")


def _families_seen(build):
    """family -> list of (ts, index), with the seed's families mapped onto the playbook's names."""
    seen = {}
    for i, m in enumerate(build.messages):
        fam = FAMILY_ALIAS.get(m["family"], m["family"])
        seen.setdefault(fam, []).append((parse_utc(m["ts"]), i))
    return seen


def rule_ordering(build):
    pb = playbook()
    seen = _families_seen(build)
    problems = []
    for i, m in enumerate(build.messages):
        fam = FAMILY_ALIAS.get(m["family"], m["family"])
        preds = pb["families"].get(fam, {}).get("predecessors", [])
        # The seed's own history is real PROD order (a BROCK scan without a CM bag group happens); the playbook
        # judges what the builders added.
        if not preds or m["origin"] == "seed":
            continue
        at = parse_utc(m["ts"])
        earlier = [p for p in preds if any(t < at for t, _ in seen.get(p, []))]
        if not earlier:
            problems.append(f"message {i} ({fam}) has none of {preds} before it")
    # Sequence numbers: a generated version, etag or document version must exceed every earlier one of its entity.
    # The seed's own history is real (PROD does deliver an older ticket version after a newer one), so only the
    # builders' messages are judged, against everything before them.
    versions = []
    for m in build.messages:
        o = m["obj"]
        if isinstance(o, dict) and "processedPnr" in o:
            versions.append((parse_utc(m["ts"]), int(str(o["processedPnr"].get("version", "0"))), m["origin"]))
    for (t1, v1, _), (t2, v2, origin) in zip(versions, versions[1:]):
        if origin == "seed":
            continue
        if v2 <= v1:
            problems.append(f"PNR version {v2} after {v1}")
        if t2 < t1:
            problems.append(f"PNR version {v2} timestamped before version {v1}")
    etags, tickets, fdm = {}, {}, {}
    for i, m in enumerate(build.messages):
        o = m["obj"]
        if not isinstance(o, dict):
            continue
        generated = m["origin"] != "seed"
        if "processedDcsPassenger" in o:
            d = o["processedDcsPassenger"]
            last = etags.get(d.get("id"))
            if generated and last is not None and str(d.get("etag", "")) <= last:
                problems.append(f"message {i}: CM etag {d.get('etag')} does not increase")
            etags[d.get("id")] = max(str(d.get("etag", "")), last or "")
        for key in ("processedTicket", "processedEmd"):
            if key in o:
                t = o[key]
                last = tickets.get(t.get("id"))
                if generated and last is not None and str(t.get("version", "")) < last:
                    problems.append(f"message {i}: ticket version {t.get('version')} goes back")
                tickets[t.get("id")] = max(str(t.get("version", "")), last or "")
        if m["prodTopic"] == TOPIC["FDM"] and "message" in o:
            key = json.dumps(o["message"]["flightDetail"].get("identifier"), sort_keys=True)
            states = fdm.setdefault(key, [])
            for leg in o["message"]["flightDetail"].get("legs", {}).get("leg", []):
                st = (leg.get("state") or {}).get("_text")
                if st == "ARR" and "DEP" not in states and "DIV" not in states:
                    problems.append(f"message {i}: FDM ARR before DEP for {key[:60]}")
                states.append(st)
    return _rule("ordering", problems, f"{len(build.messages)} messages, {len(versions)} PNR versions, predecessors satisfied")


def rule_joins(build):
    problems = []
    pnr = build.last_pnr()["processedPnr"]
    pnr_id = pnr["id"]
    travelers = {t["id"] for t in pnr.get("travelers", [])}
    products = set()
    flights = set()
    for m in build.messages:
        o = m["obj"]
        if isinstance(o, dict) and "processedPnr" in o:
            for p in o["processedPnr"].get("products", []):
                products.add(p.get("id"))
                a = p.get("airSegment")
                if a:
                    flights.add((a.get("carrierCode"), str(a.get("number", "")).lstrip("0"), a["departure"]["iataCode"], a["departure"]["localDateTime"][:10]))
                    op = a.get("operating") or {}
                    flights.add((op.get("carrierCode", a.get("carrierCode")), str(op.get("number", a.get("number", ""))).lstrip("0"), a["departure"]["iataCode"], a["departure"]["localDateTime"][:10]))
    flight_keys = {(c, n, o) for c, n, o, _ in flights}
    ticket_ids, dcs_ids, bag_ids = set(), set(), set()
    for i, m in enumerate(build.messages):
        o = m["obj"]
        if isinstance(o, list):
            o = o[0] if o else {}
        if not isinstance(o, dict):
            continue
        where = f"message {i} ({m['family']})"
        for key in ("processedTicket", "processedEmd"):
            if key in o:
                t = o[key]
                ticket_ids.add(t.get("id"))
                locs = {r.get("recordLocator") for r in t.get("pnrReferences", [])}
                # A real ticket may name an associated record (ZZ5TI8's tickets name another locator); the
                # engines link it by its correlation, so only a built ticket must name this booking.
                if build.locator not in locs and m["origin"] != "seed":
                    problems.append(f"{where}: ticket names {locs or 'no locator'}, not {build.locator}")
                if key == "processedTicket":
                    for c in t.get("coupons", []):
                        s = c.get("soldSegment") or c.get("currentSegment") or {}
                        fk = (s.get("carrierCode"), str(s.get("flightnumber", "")).lstrip("0"), (s.get("departure") or {}).get("iataCode"))
                        if fk not in flight_keys:
                            problems.append(f"{where}: coupon {c.get('number')} flies {fk}, not a PNR segment")
        corr = o.get("correlationPnrTicket") or (o.get("pnrCorrelations") or {}).get("correlationPnrTicket")
        if corr:
            if corr.get("pnrId") != pnr_id:
                problems.append(f"{where}: correlation pnrId {corr.get('pnrId')} is not {pnr_id}")
            for tid in corr.get("ticketIds", []):
                if tid not in ticket_ids:
                    problems.append(f"{where}: correlation names ticket {tid} not issued before it")
            # A row names ids this booking must hold; a real row may leave one null (ZZ5TI8's ticket rows).
            for rows in (corr.get("correlatedData") or {}).values():
                for r in rows:
                    if r.get("pnrTravelerId") and r["pnrTravelerId"] not in travelers:
                        problems.append(f"{where}: correlation traveler {r['pnrTravelerId']} unknown")
                    if r.get("pnrAirSegmentId") and r["pnrAirSegmentId"] not in products:
                        problems.append(f"{where}: correlation segment {r['pnrAirSegmentId']} unknown")
        cm = o.get("correlationDcsPassengerPnr") or (o.get("dcsPassengerCorrelations") or {}).get("correlationDcsPassengerPnr")
        if cm:
            dcs_ids.add(cm.get("dcsPassengerId"))
            if pnr_id not in (cm.get("pnrIds") or []):
                problems.append(f"{where}: CM correlation pnrIds {cm.get('pnrIds')} lack {pnr_id}")
            for rows in (cm.get("correlatedData") or {}).values():
                for r in rows:
                    if r.get("pnrTravelerId") and r["pnrTravelerId"] not in travelers:
                        problems.append(f"{where}: CM correlation traveler {r['pnrTravelerId']} unknown")
                    if r.get("pnrAirSegmentId") and r["pnrAirSegmentId"] not in products:
                        problems.append(f"{where}: CM correlation segment {r['pnrAirSegmentId']} unknown")
        if "processedDcsPassenger" in o:
            d = o["processedDcsPassenger"]
            if d.get("recordLocator") != build.locator:
                problems.append(f"{where}: DCS passenger locator {d.get('recordLocator')} is not {build.locator}")
            # The engines accept a passenger record before its correlation (a "borrowed" passenger; PROD delivers
            # them in that order, ZZ5TI8); a built record always follows the correlation the builder wrote.
            if d.get("id") not in dcs_ids and m["origin"] != "seed":
                problems.append(f"{where}: DCS passenger {d.get('id')} has no correlation before it")
            for s in d.get("segmentDeliveries", []):
                sg = s.get("segment") or {}
                fk = (sg.get("carrierCode"), str(sg.get("number", "")).lstrip("0"), (sg.get("departure") or {}).get("iataCode"))
                if fk not in flight_keys:
                    problems.append(f"{where}: DCS segment {fk} is not a PNR segment")
        if "processedBagsGroup" in o:
            g = o["processedBagsGroup"]
            if (g.get("responsiblePassenger") or {}).get("id") not in dcs_ids:
                problems.append(f"{where}: bag group passenger {(g.get('responsiblePassenger') or {}).get('id')} unknown")
            bag_ids.update(b.get("id") for b in o.get("processedBags", []))
        bc = (o.get("dcsBaggageCorrelations") or {}).get("correlationBagsGroupPnr")
        if bc:
            for rows in (bc.get("correlatedData") or {}).values():
                for r in rows:
                    if r.get("bagId") not in bag_ids:
                        problems.append(f"{where}: bag correlation bag {r.get('bagId')} unknown")
                    for l in r.get("bagLegCorrelations", []):
                        if l.get("pnrAirSegmentId") not in products:
                            problems.append(f"{where}: bag correlation segment {l.get('pnrAirSegmentId')} unknown")
        if "BagTag" in o and "Type" in o and o.get("PNR") != build.locator:
            problems.append(f"{where}: BROCK PNR {o.get('PNR')} is not {build.locator}")
        if o.get("messageType") == "passenger.profile.link":
            for r in o.get("payload", []):
                if r.get("passengerId") not in travelers:
                    problems.append(f"{where}: profile link passenger {r.get('passengerId')} unknown")
        if "PassengerNotification" in o:
            locs = [r.get("recordNumber") for r in o["PassengerNotification"].get("recordLocator", []) if not r.get("recordType")]
            if build.locator not in locs:
                problems.append(f"{where}: notification locator {locs} is not {build.locator}")
        if "RedemptionPassDetails" in o and o["RedemptionPassDetails"].get("PNR") != build.locator:
            problems.append(f"{where}: voucher PNR is not {build.locator}")
        if "event_type" in o and "data" in o and ((o["data"].get("passenger") or {}).get("pax_record_locator") != build.locator):
            problems.append(f"{where}: StormX locator is not {build.locator}")
        if m["prodTopic"] == TOPIC["FDM"] and "message" in o:
            ident = o["message"]["flightDetail"].get("identifier", {})
            number = str((ident.get("flight") or {}).get("fnNumber", {}).get("_text", "")).lstrip("0")
            carrier = (ident.get("flight") or {}).get("fnCarrier", {}).get("_text")
            for leg in o["message"]["flightDetail"].get("legs", {}).get("leg", []):
                origin = (leg.get("schedule") or {}).get("departureAirport", {}).get("_text")
                if (carrier, number, origin) not in flight_keys:
                    problems.append(f"{where}: FDM leg {carrier}{number} {origin} is not a PNR flight")
    return _rule("joins", problems, f"{len(ticket_ids)} tickets, {len(dcs_ids)} DCS passengers, {len(bag_ids)} bags, {len(flight_keys)} flights resolve")


def _schema_problems(m, i):
    """The fields each Rust parser requires (rust/src/feeds/*)."""
    o = m["obj"]
    where = f"message {i} ({m['family']})"
    need = lambda cond, what: [] if cond else [f"{where}: {what}"]  # noqa: E731
    out = []
    try:
        json.loads(m["value"])
    except ValueError:
        return [f"{where}: value is not JSON"]
    feed = feed_of(m["prodTopic"], o)
    if isinstance(o, list):
        return need(len(o) == 1 and "BagTag" in o[0], "BROCK array must hold one bag event with BagTag")
    if feed == "PNR":
        p = o.get("processedPnr") or {}
        out += need(p.get("id") and str(p.get("version", "")).isdigit(), "PNR needs id and numeric version")
        out += need(_time_ok((p.get("lastModification") or {}).get("dateTime")), "PNR lastModification.dateTime")
        out += need("travelers" in p and "products" in p, "PNR travelers and products")
        for pr in p.get("products", []):
            if pr.get("subType") == "AIR":
                a = pr.get("airSegment") or {}
                out += need(a.get("carrierCode") and a.get("number") and (a.get("departure") or {}).get("iataCode") and _time_ok((a.get("departure") or {}).get("localDateTime")),
                            f"air segment {pr.get('id')} needs carrierCode, number, departure iataCode/localDateTime")
        if int(str(p.get("version", "0"))) > 0 and "previousRecord" in o:
            out += need(isinstance(o["previousRecord"], list) and all(op.get("op") in ("add", "remove", "replace", "move", "copy", "test") and op.get("path", "").startswith("/") for op in o["previousRecord"]),
                        "PNR previousRecord must be a JSON patch")
    elif feed in ("TKT", "EMD"):
        t = o.get("processedTicket") or o.get("processedEmd")
        if t is None:
            out += need("ticketingCorrelations" in o, "ticket feed message is neither a document nor a correlation")
        else:
            out += need(re.fullmatch(r"\d{13}", str(t.get("primaryDocumentNumber", ""))), "ticket needs a 13-digit primaryDocumentNumber")
            out += need(t.get("id") and str(t.get("version", "")).isdigit(), "ticket needs id and numeric version")
            out += need((t.get("latestEvent") or {}).get("code"), "ticket needs latestEvent.code")
            for c in t.get("coupons", []):
                out += need(c.get("number") and c.get("documentNumber") and (c.get("soldSegment") or c.get("currentSegment")), f"coupon {c.get('id')} needs number, documentNumber, soldSegment")
    elif feed == "CM":
        if "processedDcsPassenger" in o:
            d = o["processedDcsPassenger"]
            out += need(d.get("id") and d.get("etag"), "DCS passenger needs id and etag")
            out += need(isinstance((o.get("events") or {}).get("events"), list), "DCS passenger needs events.events")
            for s in d.get("segmentDeliveries", []):
                out += need(s.get("id") and (s.get("segment") or {}).get("number") and all(l.get("id") for l in s.get("legDeliveries", [])), f"DCS segment {s.get('id')} needs id, segment.number and leg ids")
        else:
            c = o.get("correlationDcsPassengerPnr") or (o.get("dcsPassengerCorrelations") or {}).get("correlationDcsPassengerPnr") or {}
            out += need(c.get("dcsPassengerId") and c.get("pnrIds"), "CM correlation needs dcsPassengerId and pnrIds")
            for rows in (c.get("correlatedData") or {}).values():
                for r in rows:
                    out += need(r.get("dcsPassengerSegmentDeliveryId") and r.get("pnrAirSegmentId") and r.get("pnrTravelerId"), "CM correlation rows need delivery, segment and traveler ids")
    elif feed == "CM_BAG":
        if "processedBagsGroup" in o:
            out += need(o["processedBagsGroup"].get("id") and "processedBags" in o, "bag group needs id and processedBags")
        else:
            c = (o.get("dcsBaggageCorrelations") or {}).get("correlationBagsGroupPnr") or {}
            out += need(c.get("bagsGroupId") and c.get("pnrIds"), "bag correlation needs bagsGroupId and pnrIds")
    elif feed == "PNRCORR":
        c = o.get("correlationPnrTicket") or o.get("correlationPnrEmd") or (o.get("pnrCorrelations") or {}).get("correlationPnrTicket") or {}
        out += need(c.get("pnrId") and (c.get("ticketIds") or c.get("emdIds")), "correlation needs pnrId and non-empty document ids")
    elif feed == "FDM":
        fd = (o.get("message") or {}).get("flightDetail") or {}
        flight = (fd.get("identifier") or {}).get("flight") or fd.get("flightIdentifier") or {}
        out += need(_t(flight.get("fnCarrier")) and _t(flight.get("fnNumber")), "FDM needs fnCarrier and fnNumber")
        legs = (fd.get("legs") or {}).get("leg") or fd.get("leg") or []
        legs = legs if isinstance(legs, list) else [legs]
        out += need(legs, "FDM needs a leg")
        for leg in legs:
            s = leg.get("schedule") or {}
            out += need(_t(s.get("serviceType")) in ("J", "G", "O", "D", "U"), "FDM leg serviceType must be passenger (J/G/O/D/U)")
            out += need(_t(s.get("departureAirport")) and _time_ok(_t(s.get("departure"))), "FDM leg needs departureAirport and departure")
        out += need(_time_ok(o.get("created")), "FDM needs created")
    elif feed == "AACC":
        n = o.get("PassengerNotification") or {}
        out += need(any(r.get("recordNumber") for r in n.get("recordLocator", [])), "AACC needs recordLocator[].recordNumber")
        pd = (n.get("processingData") or {}).get("processingDateTime") or {}
        out += need(re.fullmatch(r"\d{8}", str(pd.get("date", ""))) and re.fullmatch(r"\d{6}", str(pd.get("time", ""))), "AACC needs processingDateTime date (DDMMYYYY) and time (HHMMSS)")
    elif feed == "ICOUPON":
        out += need(o.get("event_type") and o.get("voucher_id") and _time_ok(o.get("issuance_date") or o.get("cancellation_date")), "iCoupon needs event_type, voucher_id, issuance_date")
        out += need((o.get("RedemptionPassDetails") or o.get("passenger") or {}).get("PNR"), "iCoupon needs a PNR")
    elif feed == "STORMX":
        out += need(o.get("event_type") and o.get("message_timestamp") and ((o.get("data") or {}).get("passenger") or {}).get("pax_record_locator"), "StormX needs event_type, message_timestamp, data.passenger.pax_record_locator")
    elif feed == "CUSTOMER_PROFILE_CPID":
        out += need(o.get("messageType") and isinstance(o.get("payload"), list) and all(r.get("passengerId") for r in o["payload"]), "profile event needs messageType and payload[].passengerId")
    elif feed == "SMART_SUITE":
        out += need(o.get("Type") and o.get("BagTag") and o.get("PNR") and _time_ok(o.get("Timestamp")), "BROCK needs Type, BagTag, PNR, Timestamp")
    return out


def _t(v):
    return v.get("_text") if isinstance(v, dict) else v


def _time_ok(v):
    if not isinstance(v, str) or not v:
        return False
    try:
        parse_utc(v)
        return True
    except ValueError:
        return False


def rule_schema(build, oracle=True):
    problems = []
    for i, m in enumerate(build.messages):
        problems += _schema_problems(m, i)
    detail = f"{len(build.messages)} messages carry the parser-read fields"
    if oracle and ORACLE.exists() and RULES.exists() and REFDB.exists():
        try:
            eds = run_oracle(build)
            detail += f"; tt-engine-oracle replayed the owner: {len(eds)} EDS changes" + (f" ({', '.join(sorted({str(e[2]) for e in eds})[:6])})" if eds else "")
        except Exception as e:  # noqa: BLE001
            problems.append(f"tt-engine-oracle: {str(e)[:300]}")
    else:
        detail += "; tt-engine-oracle not available here"
    return _rule("schema", problems, detail)


def owner_records(build):
    """The owner folder's records for the engines (`owner-record-base-v1`), and the FDM messages by flight id."""
    records, flights = [], {}
    # As the PROD owner bundles record them (corpus owners, 2026-10-14).
    authority = {"PNR": "pnr", "TKT": "document", "EMD": "document", "CM": "customer-movement", "CM_BAG": "baggage", "PNRCORR": "correlation",
                 "AACC": "reaccommodation", "SMART_SUITE": "baggage", "STORMX": "voucher", "ICOUPON": "voucher", "CUSTOMER_PROFILE_CPID": "customer-profile"}

    def identity(feed, o, ts):
        """(aggregate id, numeric version, source timestamp, source ordinal) exactly as `feeds::identify` derives
        them from the payload (rust/src/feeds/mod.rs, historical.rs): the loader refuses a record whose routed
        ordering differs from the decoded identity."""
        ev = (o.get("events") or {}).get("originFeedTimeStamp") if isinstance(o, dict) else None
        millis = str(int(parse_utc(ts).timestamp()) * 1000)  # whole seconds: ordinal_timestamp renders ...:SSZ
        if feed == "PNR":
            p = o["processedPnr"]
            return p["id"], int(str(p.get("version", "0"))), (p.get("lastModification") or {}).get("dateTime") or ev or p.get("lastUpdated") or "", str(p.get("version", "0"))
        if feed in ("TKT", "EMD"):
            doc = o.get("processedTicket") or o.get("processedEmd")
            if doc:
                return doc["id"], int(str(doc.get("version", "0"))), ev or (doc.get("latestEvent") or {}).get("dateTimeGMT") or "", str(doc.get("version", "0"))
            corr = (o.get("ticketingCorrelations") or {})
            node = next((v for k, v in corr.items() if k.startswith("correlation") and isinstance(v, dict)), {})
            tid = node.get("ticketId") or node.get("emdId") or ""
            ver = int(str(((corr.get("dictionaries") or {}).get("tickets") or (corr.get("dictionaries") or {}).get("emds") or {}).get(tid, {}).get("version", millis)))
            return tid, ver, ev or "", str(ver)
        if feed == "CM":
            if "processedDcsPassenger" in o:
                d = o["processedDcsPassenger"]
                ordinal = str(d.get("etag") or millis)
                return d["id"], int(ordinal), ev or d.get("lastUpdated") or "", ordinal
            c = o.get("correlationDcsPassengerPnr") or (o.get("dcsPassengerCorrelations") or {}).get("correlationDcsPassengerPnr") or {}
            dicts = o.get("dictionaries") or (o.get("dcsPassengerCorrelations") or {}).get("dictionaries") or {}
            ordinal = str(((dicts.get("dcsPassengers") or {}).get(c.get("dcsPassengerId"), {}) or {}).get("version") or millis)
            return c.get("dcsPassengerId", ""), int(ordinal), ev or "", ordinal
        if feed == "CM_BAG":
            if "processedBagsGroup" in o:
                g = o["processedBagsGroup"]
                return g["id"], int(str(g.get("etag") or millis)), ev or "", str(g.get("etag") or millis)
            c = (o.get("dcsBaggageCorrelations") or {}).get("correlationBagsGroupPnr") or {}
            dicts = (o.get("dcsBaggageCorrelations") or {}).get("dictionaries") or {}
            ordinal = str(((dicts.get("bagsGroups") or {}).get(c.get("bagsGroupId"), {}) or {}).get("version") or millis)
            return c.get("bagsGroupId", ""), int(ordinal), ev or "", ordinal
        if feed == "SMART_SUITE":
            item = o[0] if isinstance(o, list) else o
            stamp = item.get("Timestamp") if isinstance(o, list) else iso_utc(parse_utc(ts))
            return item.get("BagTag", ""), int(millis), stamp, millis
        if feed == "AACC":
            n = o.get("PassengerNotification") or {}
            loc = next((r.get("recordNumber") for r in n.get("recordLocator", []) if not r.get("recordType")), build.locator)
            pd = (n.get("processingData") or {}).get("processingDateTime") or {}
            d, t = str(pd.get("date", "")), str(pd.get("time", ""))
            ver = int(d[4:8] + d[2:4] + d[0:2] + t) if len(d) == 8 and len(t) == 6 else int(millis)
            return loc, ver, iso_utc(parse_utc(ts)), millis
        if feed == "PNRCORR":
            node = o.get("correlationPnrTicket") or o.get("correlationPnrEmd") or (o.get("pnrCorrelations") or {}).get("correlationPnrTicket") or {}
            dicts = o.get("dictionaries") or (o.get("pnrCorrelations") or {}).get("dictionaries") or {}
            ver = int(str(((dicts.get("pnrs") or {}).get(node.get("pnrId"), {}) or {}).get("version") or millis))
            return node.get("pnrId", ""), ver, ev or "", str(ver)
        if feed == "CUSTOMER_PROFILE_CPID":
            first = (o.get("payload") or [{}])[0]
            return str(first.get("passengerId", ""))[:17], int(millis), o.get("timestamp") or "", millis
        if feed == "STORMX":
            data = o.get("data") or {}
            agg = (data.get("voucher") or {}).get("hotel_voucher", {}).get("id") or (data.get("passenger") or {}).get("context_id") or build.locator
            return agg, int(millis), str(o.get("message_timestamp") or ""), millis
        if feed == "ICOUPON":
            return o.get("voucher_id", ""), int(millis), iso_utc(parse_utc(ts)), millis
        return build.pnr_id, int(millis), ev or "", millis

    def ordinal_timestamp(ordinal):
        """`domain::event::ordinal_timestamp`: an epoch ordinal (s, ms, µs or ns by its length) as RFC 3339."""
        scale = {10: 1_000_000_000, 13: 1_000_000, 16: 1_000, 19: 1}.get(len(ordinal))
        if scale is None or not ordinal.isdigit():
            return ""
        nanos = int(ordinal) * scale
        base = datetime.fromtimestamp(nanos // 1_000_000_000, tz=timezone.utc).strftime("%Y-%m-%dT%H:%M:%S")
        frac = nanos % 1_000_000_000
        return base + (f".{frac:09d}".rstrip("0") if frac else "") + "Z"

    for i, m in enumerate(build.messages):
        feed = feed_of(m["prodTopic"], m["obj"])
        o = m["obj"]
        uri = f"kafka://qa/{m['prodTopic']}/0/{i}"
        sha = hashlib.sha256(m["value"].encode()).hexdigest()
        if feed == "FDM":
            fd = o["message"]["flightDetail"]
            flight = fd["identifier"]["flight"]
            leg = fd["legs"]["leg"][0]
            key = f"{_t(flight['fnCarrier'])}#{_t(flight['fnNumber'])}#{_t(fd['identifier']['dayOfOrigin'])}#{_t(leg['schedule']['departureAirport'])}"
            flights.setdefault(key, []).append({"sourceSequence": i, "occurredAtMicros": int(parse_utc(m["ts"]).timestamp() * 1_000_000),
                                                "record": {"feed": "FDM", "sourceUri": uri, "aggregateId": key, "sourceOrdinal": str(i), "payloadSha256": sha, "payload": o}})
            continue
        agg, version, stamp, ordinal = identity(feed, o, m["ts"])
        if not stamp:  # no timestamp field in the payload: the engines read the ordinal (a bare CM correlation)
            stamp = ordinal_timestamp(ordinal)
        lane = {"TKT": "TKT", "EMD": "TKT", "CM": "CM_CORR" if "processedDcsPassenger" not in o else "CM", "CM_BAG": "CM", "PNRCORR": "PNRCORR",
                "AACC": "AACC", "SMART_SUITE": "BAGGAGE", "STORMX": "STORMX", "ICOUPON": "ICOUPON", "CUSTOMER_PROFILE_CPID": "CUSTOMER_PROFILE_CPID",
                "CLD": "CLD"}.get(feed)
        records.append({"feed": feed, "lane": lane, "sourceOrdinal": ordinal, "observationNoop": False,
                        "coordinate": {"aggregate_id": agg, "source_sequence": i, "source_uri": uri, "source_key": uri, "source_record_index": None,
                                       "source_byte_offset": None, "source_byte_length": None, "source_object_sha256": sha, "payload_sha256": sha},
                        "routing": {"status": "resolved", "owners": [build.pnr_id], "hints": [{"kind": "pnr-id", "value": build.pnr_id}], "reason": None},
                        "ordering": {"authority": authority.get(feed, feed.lower()), "aggregateId": agg, "numericVersion": version, "subEventOrdinal": 0,
                                     "sourceTimestamp": stamp, "sourceKey": uri},
                        "payload": {"kind": "embedded-json", "value": o}})
    return records, flights


def _write_entity(directory, head_schema, doc_schema, entity, id_key, records, through, sequences):
    """One owner or shared flight as the engines' local loaders read it: `000.json.zst` (the base document) and
    `head.json` pinning it (sizes, sha256, record count), no deltas. Mirrors the PROD owner bundles' head shape."""
    directory.mkdir(parents=True)
    unit = {"uri": f"qa://build/{key_segment(entity)}", "bytes": 1, "sha256": hashlib.sha256(entity.encode()).hexdigest()}
    lo, hi = (min(sequences), max(sequences)) if sequences else (0, 0)
    doc = {"schema": doc_schema, "entity": entity, "sourceRoot": "qa", "sourceUnit": unit, "sourcePins": {}, "sourceCompleteThrough": through,
           "minSourceSequence": lo, "maxSourceSequence": hi, "records": records}
    if head_schema == "shared-flight-head":
        doc.pop("sourcePins")
    raw = json.dumps(doc, separators=(",", ":")).encode()
    packed = _zstd_bytes(raw)
    (directory / "000.json.zst").write_bytes(packed)
    base = {"uri": f"file://{directory}/000.json.zst", "documentSchema": doc_schema, "sourceRoot": "qa", "sourceUnit": unit, "minSourceSequence": lo,
            "maxSourceSequence": hi, "schemaVersion": 1, "format": "json", "codec": "zstd", "compressionLevel": 9, "compressedBytes": len(packed),
            "decodedBytes": len(raw), "sha256": hashlib.sha256(packed).hexdigest(), "records": len(records), "s3VersionId": "", "s3ChecksumSha256": ""}
    head = {"schema": head_schema, "schemaVersion": 1, "headSequence": 0, id_key: entity, "sourceSelectionReceiptSha256": unit["sha256"],
            "sourceCompleteThrough": through, "base": base, "deltaPrefix": f"file://{directory}/deltas", "deltas": []}
    if head_schema == "shared-flight-head":
        head.update(sourceBase="qa", sourceManifestSha256=unit["sha256"])
    (directory / "head.json").write_text(json.dumps(head))


def key_segment(value):
    return "".join(c if c.isascii() and (c.isalnum() or c in "-_.") else "".join(f"%{b:02X}" for b in c.encode()) for c in value)


def run_oracle(build, timeout=180):
    """Replay the build through tt-engine-oracle --eds; returns its EDS change rows (raises on failure)."""
    records, flights = owner_records(build)
    through = iso_utc(max(parse_utc(m["ts"]) for m in build.messages) + timedelta(days=1))
    with tempfile.TemporaryDirectory(prefix="tt-qa-oracle-") as tmp:
        root = Path(tmp)
        owner = root / "owner" / key_segment(build.pnr_id)
        _write_entity(owner, "owner-bundle-head", "owner-record-base-v1", build.pnr_id, "ownerId", records, through,
                      [r["coordinate"]["source_sequence"] for r in records])
        fdir = root / "flights"
        fdir.mkdir()
        for key, rows in flights.items():
            _write_entity(fdir / key_segment(key), "shared-flight-head", "shared-flight-record-base-v1", key, "flight", rows, through,
                          [r["sourceSequence"] for r in rows])
        at = iso_utc(max(parse_utc(m["ts"]) for m in build.messages) + timedelta(days=2))
        cmd = [str(ORACLE), "--config", str(RULES), "--refdb", str(REFDB), "--flights", str(fdir), "--evaluated-at", at, "--eds", str(owner)]
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        if r.returncode != 0:
            raise RuntimeError((r.stderr or r.stdout).strip()[-400:])
        line = next((l for l in r.stdout.splitlines() if l.startswith("{")), "")
        out = json.loads(line) if line else {}
        if out.get("error"):
            raise RuntimeError(str(out["error"])[:400])
        return out.get("eds") or out.get("changes") or []


def _zstd_bytes(data):
    if shutil.which("zstd"):
        return subprocess.run(["zstd", "-q", "-9", "-c"], input=data, capture_output=True, check=True).stdout
    import zstandard  # noqa: PLC0415  (the image has the zstd CLI; the laptop venv has the module)
    return zstandard.ZstdCompressor(level=9).compress(data)


def rule_timing(build):
    norms = playbook()["norms"]
    warnings = []
    for i, m in enumerate(build.messages):
        if m["origin"] == "seed":
            continue
        n = norms.get(m["family"])
        if not n:
            continue
        # A departure or arrival anchor is any segment's (an event of the second flight is timed against it).
        if n["anchor"] in ("departure", "arrival"):
            anchors = [build.plan.anchor(f"{n['anchor']}:{s.k}") for s in build.plan.segments]
        else:
            try:
                anchors = [build.plan.anchor(n["anchor"])]
            except (ValueError, IndexError):
                continue
        offsets = [(parse_utc(m["ts"]) - a).total_seconds() / 60 for a in anchors]
        if not any(n["minMinutes"] <= o <= n["maxMinutes"] for o in offsets):
            nearest = min(offsets, key=abs)
            warnings.append(f"message {i} ({m['family']}) is {int(nearest)} min from {n['anchor']}; norm {n['minMinutes']}..{n['maxMinutes']}")
    return {"id": "timing", "ok": True, "detail": f"{len(warnings)} outside the playbook norms" if warnings else "every step within the playbook norms", "warnings": warnings[:20]}
