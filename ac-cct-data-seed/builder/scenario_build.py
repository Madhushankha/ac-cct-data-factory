"""Build UAT scenario bookings locally with TripTracer's /qa builder, fix the message shapes the lower envs need, and
write one replay batch (event_replay.py check/publish) plus a manifest of what each booking must show.

  scenario_build.py <specs.json> <pool-dir> <out-dir> [int|crt|bat]      (pool-dir "-" = $QA_POOL_DIR or ./seed-pool)

specs.json: [{"id": "FD_TC_230", "seeds": ["ZZOKRU"], "plan": {...builder plan...},
              "flights": [{"segment": 1, "kind": "delay|cancel|ontime", "minutes": 420, "code": "96", "depMinutes": 420}],
              "expect": {...}}]

Fixes over the builder's own output (pilot ZZZ77Z/ZZ6DOD, 2026-10-15):
  - FDM: the builder's JSON leaves the delay unreadable (ETD "—", no code); dropped, and the flight status is sent as the
    live XML (scenario_fdm.py), with the scenario's delay and code.
  - TKT: carries the record envelope the lower envs' TKT feed has (events: recordDomain TICKET, recordId
    <LOCATOR>-<document>, CREATED), version "1", isFinalStatus and lastUpdateDatetime, like the classic replay's
    tickets, which TripTracer shows.
"""
import json
import sys
from datetime import timedelta, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import uat_config  # noqa: E402

uat_config.use_builder()  # builder with rebooking shapes (cascade branch claude/qa-builder-rebooking-shapes-20261015)
from builder import Build  # noqa: E402
import tz_extra  # noqa: E402,F401
import scenario_fdm  # noqa: E402

FEEDS = {"ALTEA-PNRDATA": "PNR", "ALTEA-TKT": "TKT", "ALTEA-PNRCORR": "PNRCORR", "ALTEA-CM": "CM", "ALTEA-AACC": "AACC",
         "BROCK-BAGGAGE": "BAGGAGE", "CUSTOMER-PROFILE-EVENTS": "CPID", "EAI-FDM": "FDM", "DBASS-ICOUPON": "ICOUPON",
         "STORMX-EVENTHUB": "STORMX", "MULE-DAMAGEDBAGGAGE": "DAMAGEDBAG"}


def env_topic(prod_topic, env):
    core = next((k for k in FEEDS if k in prod_topic), None)
    if core is None:
        raise ValueError(f"no lower-env topic for {prod_topic}")
    if core == "CUSTOMER-PROFILE-EVENTS":
        return {"int": "CUSTOMER-PROFILE-EVENTS-INT", "crt": "CUSTOMER-PROFILE-EVENTS-UAT", "bat": "CUSTOMER-PROFILE-EVENTS-BAT"}[env]
    return {"int": f"emh-int.{core}-INT", "crt": f"emh-dev.{core}-UAT", "bat": f"emh-dev.{core}-INT"}[env], FEEDS[core]


STR_KEYS = {"total", "totalTaxes", "amount", "flightnumber", "flightNumber", "primaryDocumentNumber", "documentNumber",
            "issuanceLocalDate", "number" + "_"}
INT_KEYS = {"sequenceNumber", "quantity", "numberOfBooklets"}


def strict(v, key=""):
    """Raptor's ticket reader (engine/src/booking/documents.rs) is strict: no null lists or fields, text where it reads
    text, integers where it reads integers (the facts fold and tt-replay-check are lenient, so they hid it)."""
    if isinstance(v, dict):
        return {k: strict(x, k) for k, x in v.items() if x is not None}
    if key == "coupons" and isinstance(v, list):
        # live TKT: coupons[].number is an integer (Raptor drops the whole document on text); frequentFlyer.number stays text
        return [{**strict(c, ""), **({"number": int(c["number"])} if isinstance(c, dict) and str(c.get("number", "")).isdigit() else {})} for c in v if c is not None]
    if isinstance(v, list):
        return [strict(x, key) for x in v if x is not None]
    if key in STR_KEYS and isinstance(v, (int, float)) and not isinstance(v, bool):
        return str(v)
    if key in INT_KEYS and isinstance(v, str) and v.isdigit():
        return int(v)
    if key == "stopOver" and isinstance(v, str):
        return v.lower() == "true"
    return v


def fix_ticket(obj, locator, ts):
    """The ticket document as the live TKT feed carries it and Raptor reads it: the builder's ids
    (<document>-<issue date>), version an epoch-millisecond string, latestEvent at the message time (after the PNR's
    creation, so routing finds the booking), the record meta and envelope, strict JSON types."""
    from datetime import datetime
    pt = obj.get("processedTicket") or obj.get("processedEmd")
    if not pt or not pt.get("id"):
        return obj
    import re as _re
    when = datetime.fromisoformat(_re.sub(r"\.\d+", "", ts.replace("Z", "+00:00")))
    pt["version"] = str(int(when.timestamp() * 1000))
    pt["latestEvent"] = {**(pt.get("latestEvent") or {}), "dateTimeGMT": when.strftime("%Y-%m-%dT%H:%M:%S")}
    obj["meta"] = {"triggerEventLog": {"id": (obj.get("meta") or {}).get("triggerEventLog", {}).get("id", "qa-builder")}, "version": "3.5.0"}
    obj.setdefault("events", {"recordDomain": "TICKET", "recordId": pt["id"],
                              "events": [{"origin": "COMPARISON", "eventType": "CREATED", "currentPath": ""}]})
    key = "processedTicket" if "processedTicket" in obj else "processedEmd"
    obj[key] = strict(pt)
    return obj


def ticket_pnr_correlations(corr_obj, ts):
    """The live TKT feed's TICKET_PNR records (ticketingCorrelations.correlationTicketPnr, one per ticket), derived from
    the builder's PNR->ticket correlation: without them TripTracer holds the tickets but never puts them on the Trip
    (INT live sample 2026-10-15; replay and /qa bookings showed 0 tickets)."""
    cpt = (corr_obj.get("pnrCorrelations") or corr_obj).get("correlationPnrTicket") or {}
    pnr_id = cpt.get("pnrId")
    out = []
    for tid in cpt.get("ticketIds") or []:
        rows = (cpt.get("correlatedData") or {}).get(tid) or []
        out.append({"meta": {"triggerEventLog": {"id": "qa-builder-ticket-pnr"}, "version": "3.5.0"},
                    "ticketingCorrelations": {
                        "correlationTicketPnr": {"ticketId": tid, "pnrIds": [pnr_id],
                                                 "correlatedData": {pnr_id: [{k: r[k] for k in r if k in ("ticketCouponId", "pnrTravelerId", "pnrAirSegmentId", "pnrTicketingReferenceId")} for r in rows]}},
                        "dictionaries": {"tickets": {tid: {"type": "air-travel-document", "id": tid, "version": tid.split("-")[0]}},
                                         "pnrs": {pnr_id: {"type": "pnr", "id": pnr_id, "version": "1"}}}},
                    "events": {"recordDomain": "TICKET_PNR", "recordId": tid, "originFeedTimeStamp": ts.replace("+00:00", "Z"),
                               "events": [{"origin": "COMPARISON", "eventType": "CREATED", "currentPath": ""}]}})
    return out


def fix_correlation(obj, locator, ts):
    """The builder's PNR->ticket correlation in the live PNRCORR shape: the pnrCorrelations wrapper and its PNR_TICKET
    record envelope; ids stay the builder's (<document>-<issue date>, air-travel-document) as the live feed has them."""
    if "pnrCorrelations" in obj:
        return obj
    cpt = obj.get("correlationPnrTicket") or {}
    return {"meta": {"triggerEventLog": {"id": "qa-builder-pnr-ticket"}, "version": "1.13.0"},
            "pnrCorrelations": obj,
            "events": {"recordDomain": "PNR_TICKET", "recordId": cpt.get("pnrId"),
                       "events": [{"origin": "COMPARISON", "eventType": "CREATED", "currentPath": ""}]}}


def one_itinerary_per_bound(obj, bounds):
    """The 2-segment template is a round trip (two JOURNEY_SERVER_BOUND itineraries). A connection is ONE bound: Raptor
    numbers bounds by itinerary position (booking/pnr.rs), so two itineraries make the unflown second leg a separate
    'remained at origin' bound. Merge the itineraries, in order, into one per plan bound (sizes = segments per bound);
    any extra itinerary (a replacement the builder added) joins the bound it follows."""
    pp = obj.get("processedPnr") if isinstance(obj, dict) else None
    its = (pp or {}).get("flightItineraries")
    bound_sizes = [len(b["segments"]) for b in bounds]
    if not its or len(its) <= len(bound_sizes):
        return obj
    groups, i = [], 0
    for n in bound_sizes:
        groups.append(its[i:i + n] or its[-1:]); i += n
    groups[-1] = groups[-1] + its[i:]
    merged = []
    for g, b in zip(groups, bounds):
        it = json.loads(json.dumps(g[0]))
        it["flights"] = [f for x in g for f in x.get("flights", [])]
        it["originIataCode"] = b["segments"][0]["origin"]
        it["destinationIataCode"] = b["segments"][-1]["destination"]
        merged.append(it)
    pp["flightItineraries"] = merged
    return obj


def build_one(spec, pool, env):
    b = Build(spec["plan"], spec["seeds"], pool)
    pnr_id, locator = b.pnr_id, b.locator
    rows = []
    # A ticket the template issued before its booking existed (the template's dates shift as a whole) is moved to the
    # booking's creation day: its id, coupon ids, issue date and every correlation naming it.
    created_day = pnr_id[-10:]
    redate = {}
    for m in b.messages:
        pt = (m["obj"] or {}).get("processedTicket") or (m["obj"] or {}).get("processedEmd")
        if pt and pt.get("id") and pt.get("issuanceLocalDate") and pt["issuanceLocalDate"] < created_day:
            doc = pt["id"].rsplit("-", 3)[0]
            redate[f'{doc}-{pt["issuanceLocalDate"]}'] = f"{doc}-{created_day}"
    def apply_redate(obj):
        if not redate:
            return obj
        t = json.dumps(obj)
        for old_id, new_id in redate.items():
            t = t.replace(old_id, new_id)
        o = json.loads(t)
        pt = o.get("processedTicket") or o.get("processedEmd")
        if pt and pt.get("issuanceLocalDate", "9") < created_day:
            pt["issuanceLocalDate"] = created_day
        return o
    # sister-city arrivals: the builder keeps the booked arrival airport; Raptor needs the booking to end at the sister
    sister, diverted = {}, {}
    for f in spec.get("flights") or []:
        if f.get("sisterDest"):
            if f.get("explicit"):  # a rebooking: only the versions after it hold the replacement
                sister[(f["carrier"], str(f["number"]).lstrip("0"))] = f["sisterDest"]
            else:  # a diversion: the promise keeps the booked airport; a version after the landing ends at the sister
                s = b.plan.segments[f.get("segment", 1) - 1]
                diverted[(s.carrier, str(s.number).lstrip("0"))] = (f["sisterDest"], s.arr_utc + timedelta(minutes=int(f.get("minutes") or 0) + 60))
    def apply_sister(obj, table=None):
        table = sister if table is None else table
        pp = obj.get("processedPnr") if isinstance(obj, dict) else None
        if not table or not pp:
            return obj
        for p in pp.get("products") or []:
            a = p.get("airSegment") or {}
            dest = table.get((a.get("carrierCode"), str(a.get("number", "")).lstrip("0")))
            if dest and isinstance(a.get("arrival"), dict):
                a["arrival"]["iataCode"] = dest
                for it in pp.get("flightItineraries") or []:
                    ids = [(x.get("flightSegment") or {}).get("id") for x in it.get("flights", [])]
                    if ids and ids[-1] == p.get("id"):
                        it["destinationIataCode"] = dest
        return obj
    for m in b.messages:
        topic = env_topic(m["prodTopic"], env)
        topic, feed = topic if isinstance(topic, tuple) else (topic, "CPID")
        if feed == "FDM":
            continue
        obj = apply_redate(m["obj"])
        obj = apply_sister(one_itinerary_per_bound(obj, spec["plan"]["bounds"]))
        if spec.get("operatingUnknown") and isinstance(obj, dict) and obj.get("processedPnr"):
            unk = {b.plan.segments[k - 1].number for k in spec["operatingUnknown"] if 1 <= k <= len(b.plan.segments)}
            for pr in obj["processedPnr"].get("products") or []:
                a = pr.get("airSegment") or {}
                if str(a.get("number", "")).lstrip("0") in {str(u).lstrip("0") for u in unk}:
                    a.pop("operating", None)  # the booking does not say who operates this leg
        if spec.get("dbcpSegs") and isinstance(obj, dict) and obj.get("processedPnr"):
            # proposed contract (C10): a DENIED BOARDING keyword on a partner-operated segment the AC DCS never sees
            pp = obj["processedPnr"]
            travelers = [t.get("id") for t in pp.get("travelers") or []]
            kws = pp.setdefault("keywords", [])
            for k in spec["dbcpSegs"]:
                if not 1 <= k <= len(b.plan.segments):
                    continue
                sg = b.plan.segments[k - 1]
                prod = next((p for p in pp.get("products") or [] if (p.get("airSegment") or {}).get("carrierCode") == sg.carrier
                             and str((p.get("airSegment") or {}).get("number", "")).lstrip("0") == str(sg.number).lstrip("0")), None)
                if prod and travelers and not any(kw.get("code") == "DBCP" for kw in kws if isinstance(kw, dict)):
                    kws.append({"id": f"{pnr_id}-OT-98", "subType": "SPECIAL_KEYWORD", "code": "DBCP", "status": "HK", "text": "DENIED BOARDING",
                                "products": {"collection": [{"id": prod["id"], "ref": "processedPnr.products", "type": "product"}]},
                                "travelers": {"collection": [{"id": travelers[0], "ref": "processedPnr.travelers", "type": "stakeholder"}]}})
        if spec.get("stripLoyalty") and isinstance(obj, dict) and obj.get("processedPnr"):
            # the seed's Aeroplan membership is not the scenario's: a passenger without Aeroplan has no loyalty link
            obj["processedPnr"].pop("loyaltyRequests", None)
            obj["processedPnr"].pop("loyaltyAccruals", None)
        if any(spec.get("tiers") or []) and isinstance(obj, dict) and obj.get("processedPnr"):
            pp = obj["processedPnr"]
            travelers = [t.get("id") for t in pp.get("travelers") or []]
            reqs = pp.setdefault("loyaltyRequests", [])
            for i, tier in enumerate(spec["tiers"]):
                if not tier or i >= len(travelers):
                    continue
                mine = [q for q in reqs if travelers[i] in json.dumps(q.get("travelers") or {})]
                if not mine and reqs:
                    q = json.loads(json.dumps(reqs[0]))
                    q["id"] = f"{pnr_id}-OT-{80 + i}"
                    q["travelers"] = {"collection": [{"id": travelers[i], "ref": "processedPnr.travelers", "type": "stakeholder"}]}
                    reqs.append(q); mine = [q]
                elif not mine:
                    q = {"id": f"{pnr_id}-OT-{80 + i}", "code": "FQTV", "status": "HK", "subType": "SPECIAL_SERVICE_REQUEST",
                         "serviceProvider": {"code": "AC"}, "membership": {"number": f"98765432{i:02d}", "membershipType": "INDIVIDUAL"},
                         "travelers": {"collection": [{"id": travelers[i], "ref": "processedPnr.travelers", "type": "stakeholder"}]}}
                    reqs.append(q); mine = [q]
                for q in mine:
                    q.setdefault("membership", {})["activeTier"] = {"code": tier, "companyCode": "AC", "priorityCode": "0"}
        if spec.get("officeId") and isinstance(obj, dict) and obj.get("processedPnr"):
            office = ((obj["processedPnr"].get("creation") or {}).get("pointOfSale") or {}).get("office")
            if isinstance(office, dict):
                office["id"] = spec["officeId"]
            if spec.get("oalEmployee"):
                kws = obj["processedPnr"].setdefault("keywords", [])
                if not any(str(k.get("text", "")).startswith("SN-00000") for k in kws if isinstance(k, dict)):
                    kws.append({"id": f"{pnr_id}-OT-99", "subType": "SPECIAL_KEYWORD", "code": "OTHS", "status": "HK",
                                "text": "SN-00000 LH STAFF"})
        if feed == "TKT":
            obj = fix_ticket(obj, locator, m["ts"])
        elif feed == "PNRCORR":
            obj = fix_correlation(obj, locator, m["ts"])  # ticket_pnr_correlations() is not sent: a no-op in TripTracer (feeds/historical.rs)
        rows.append({"booking": pnr_id, "riders": [pnr_id], "feed": feed, "topic": topic, "key": None, "at": m["ts"], "source": "qa-builder",
                     "value": json.dumps(obj, separators=(",", ":"), ensure_ascii=False)})
    # After travel the coupons of flown legs read FLOWN (the live ticket feed does this): for a leg another airline
    # operates it is Raptor's only proof the passenger flew it (passengers.rs flown_coupons; no AC DCS boarding).
    boarded = {st.get("params", {}).get("segment") for ph in (spec["plan"].get("phases") or {}).values() for st in ph
               if st.get("family") == "boarding"}
    flown = []
    for k in boarded:
        if k and 1 <= k <= len(b.plan.segments):
            s = b.plan.segments[k - 1]
            flown.append((s.carrier, str(s.number).lstrip("0"), s.dep_local[:10], s.arr_utc))
    if flown:
        when = (max(x[3] for x in flown) + timedelta(hours=3)).astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
        last_tkt = {}
        for r in rows:
            if r["feed"] == "TKT":
                o = json.loads(r["value"])
                pt = o.get("processedTicket")
                if pt and pt.get("id") and r["at"] >= last_tkt.get(pt["id"], ({}, ""))[1]:
                    last_tkt[pt["id"]] = (r, r["at"])
        keys = {(c, n, d) for c, n, d, _ in flown}
        for r, _ in last_tkt.values():
            o = json.loads(r["value"])
            changed = False
            for c in o["processedTicket"].get("coupons") or []:
                seg = c.get("currentSegment") or c.get("soldSegment") or {}
                key = (seg.get("carrierCode"), str(seg.get("flightnumber", "")).lstrip("0"), str((seg.get("departure") or {}).get("at", ""))[:10])
                if key in keys and c.get("status") != "FLOWN":
                    c["status"] = "FLOWN"; changed = True
            if changed:
                rows.append({**r, "at": when, "value": json.dumps(fix_ticket(o, locator, when), separators=(",", ":"), ensure_ascii=False)})
    if diverted:
        last = max((r for r in rows if r["feed"] == "PNR" and '"processedPnr"' in r["value"]), key=lambda r: r["at"], default=None)
        if last:
            o = json.loads(last["value"])
            when = max(v[1] for v in diverted.values()).astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
            old_ts = ((o["processedPnr"].get("lastModification") or {}).get("dateTime"))
            if old_ts:
                o = json.loads(json.dumps(o).replace(old_ts, when))
            v = o["processedPnr"].get("version")
            o["processedPnr"]["version"] = (str(int(v) + 1) if isinstance(v, str) else int(v) + 1) if str(v).isdigit() else v
            o = apply_sister(o, {k: d for k, (d, _) in diverted.items()})
            rows.append({**last, "at": when, "value": json.dumps(o, separators=(",", ":"), ensure_ascii=False)})
    flights = []
    segs = b.plan.segments
    for f in spec.get("flights") or [{"segment": k + 1, "kind": "ontime"} for k in range(len(segs))]:
        f = {k: v for k, v in f.items() if not k.startswith("_")}
        if f.get("explicit"):
            flights.append({"rider": pnr_id, **{k: v for k, v in f.items() if k != "explicit"}})
            continue
        s = segs[f.get("segment", 1) - 1]
        flights.append({"rider": pnr_id, "carrier": s.op_carrier, "number": s.op_number, "origin": s.origin,
                        "destination": s.destination, "depUtc": s.dep_utc.astimezone(timezone.utc).isoformat().replace("+00:00", "Z"),
                        "arrUtc": s.arr_utc.astimezone(timezone.utc).isoformat().replace("+00:00", "Z"), **{k: v for k, v in f.items() if k != "segment"}})
    return pnr_id, locator, rows, flights


def main(src, pool, out_dir, env="int"):
    if pool in ("-", ""):
        pool = str(uat_config.pool_dir())
    specs = json.load(open(src, encoding="utf-8"))
    out = Path(out_dir)
    (out / "batch").mkdir(parents=True, exist_ok=True)
    all_rows, all_flights, manifest = [], [], []
    failed = []
    for spec in specs:
        try:
            pnr_id, locator, rows, flights = build_one(spec, pool, env)
        except Exception as e:  # one plan the builder refuses is reported, not fatal
            import os as _os, traceback as _tb
            failed.append({"id": spec["id"], "error": f"{type(e).__name__}: {str(e)[:300]}",
                           **({"traceback": _tb.format_exc()[-1800:]} if _os.environ.get("UAT_TRACE") else {})})
            continue
        all_rows += rows
        all_flights += flights
        manifest.append({"id": spec["id"], "pnrId": pnr_id, "locator": locator, "flights": flights, "expect": spec.get("expect", {}),
                         **{k: spec.get(k) for k in ("daysAgo", "seedNote", "unsupported", "assumed", "passengers")}})
    tmp = out / "fdm"
    tmp.mkdir(exist_ok=True)
    json.dump(all_flights, open(tmp / "flights.json", "w", encoding="utf-8"))
    scenario_fdm.main(str(tmp / "flights.json"), str(tmp), env)
    fdm_rows = [json.loads(l) for l in open(tmp / "messages.jsonl", encoding="utf-8")]
    rows = sorted(all_rows + fdm_rows, key=lambda r: r["at"])
    with open(out / "batch" / "messages.jsonl", "w", encoding="utf-8") as fh:
        for i, r in enumerate(rows, 1):
            r["seq"] = i
            fh.write(json.dumps(r) + "\n")
    json.dump(manifest, open(out / "manifest.json", "w", encoding="utf-8"), indent=1)
    json.dump(failed, open(out / "build-failed.json", "w", encoding="utf-8"), indent=1)
    print(json.dumps({"bookings": len(manifest), "failed": len(failed), "messages": len(rows), "fdm": len(fdm_rows)}))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4] if len(sys.argv) > 4 else "int")
