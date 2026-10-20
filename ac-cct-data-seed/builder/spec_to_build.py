"""UAT scenario specs (specs/*.json, SPEC_SCHEMA.md) -> scenario_build.py specs, dated relative to the run.

  spec_to_build.py <run-date YYYY-MM-DD> <out.json> [--taken taken.json] [--specs specs-dir]

Every scenario gets its own flight day(s): the spec's flightDaysAgo is the starting point and is moved a day earlier
until none of its flights (carrier#number#day#origin) is used by another scenario of this run or listed in
taken.json (flights the environment already holds bookings on). Same scenario, new run -> new day, new ZZ locator.
Needs the /qa builder (CASCADE_DIR or QA_BUILDER_DIR, see uat_config.py).
"""
import json
import glob
import os
import sys
from datetime import date, datetime, timedelta

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import uat_config  # noqa: E402

uat_config.use_builder()  # builder with rebooking shapes (cascade branch claude/qa-builder-rebooking-shapes-20261015)
from builder import local_to_utc  # noqa: E402
import tz_extra  # noqa: E402,F401

# Raptor's sister-city table pairs YYZ only with YTZ: a rebooking the text sends to YHM reads as sister only via YTZ
TIER = {"50K": "E", "75K": "D", "SE": "SE", "SUPER ELITE": "SE", "SUPERELITE": "SE", "BASIC": "A"}
SISTER_FIX = {("YYZ", "YHM"): "YTZ"}
SEEDS = {(1, 1): "ZZOKRU", (1, 2): "ZZFERC", (1, 5): "ZZNS8I", (2, 1): "ZZ6GMP"}  # ZZ7CMK (AI) rewrote to a codeshare: not used


def seed_for(segs, pax):
    exact = SEEDS.get((segs, pax))
    if exact:
        return exact, None
    larger = sorted((p, r) for (s, p), r in SEEDS.items() if s == segs and p >= pax)
    if larger:
        return larger[0][1], f"template has {larger[0][0]} passengers for {pax}"
    best = max(((p, r) for (s, p), r in SEEDS.items() if s == segs), default=None)
    if best:
        return best[1], f"no template with {pax} passengers; {best[0]} built"
    return SEEDS[(1, 1)], f"no template with {segs} segments"


def office_for(spec):
    """Employee travel as Raptor reads it (eds-booking-type): AC staff = office suffix ES; another airline's staff
    (the NE-02 codes) = suffix EC plus a SN-00000 keyword (scenario_build adds it)."""
    if not any(p.get("employee") for p in spec.get("passengers") or []):
        return None
    return "YULAC01EC" if str((spec.get("expect") or {}).get("systemCode") or "").endswith("NE-02") else "YULAC01ES"


def hhmm(t, default):
    t = (t or default or "12:00").strip()[:5]
    return t if len(t) == 5 and t[2] == ":" else default


def seg_times(day0, s):
    d = day0 + timedelta(days=int(s.get("dayOffset") or 0))
    dep = f"{d.isoformat()}T{hhmm(s.get('depLocal'), '10:00')}"
    arr_day = d
    arr = f"{arr_day.isoformat()}T{hhmm(s.get('arrLocal'), None) or '12:00'}"
    try:
        for _ in range(3):  # long-haul across the date line can land two calendar days later
            if local_to_utc(arr, s["destination"]) > local_to_utc(dep, s["origin"]):
                break
            arr_day += timedelta(days=1)
            arr = f"{arr_day.isoformat()}T{hhmm(s.get('arrLocal'), '12:00')}"
    except Exception:
        pass
    return dep, arr


def utc(local, airport):
    return local_to_utc(local, airport).strftime("%Y-%m-%dT%H:%M:%SZ")


def flight_key(s, dep_local):
    return f"{s['carrier']}#{str(s['number']).lstrip('0')}#{local_to_utc(dep_local, s['origin']).strftime('%Y-%m-%d')}#{s['origin']}"


def route_of(key):
    """`AC#467#2026-08-26#YYZ` -> `AC#467#YYZ`: the flight without its day.

    Two bookings on the same flight number and origin but different days are distinct legs, and
    the planner used to treat them as such. The engine does not: an ARRIVAL_CODE published for
    AC467/YYZ on 7 Oct arrived on the 26 Aug booking, so twelve sibling cases on AC467 each
    received a neighbour's delay code (FD_TC_067 published 84 and was judged on 82, FD_TC_066
    published 83 and was judged on POLI -- a cancellation code from a third day). Keeping the
    route unique within a run is what makes each case answerable.
    """
    parts = str(key).split("#")
    return "#".join((parts[0], parts[1], parts[3])) if len(parts) >= 4 else str(key)


def build(spec, run_day, days_ago):
    day0 = run_day - timedelta(days=days_ago)
    segs = sorted(spec.get("segments") or [], key=lambda s: s.get("seg", 0))
    pax = spec.get("passengers") or [{"firstName": "ALEX", "lastName": "TESTER", "type": "ADT"}]
    bounds = {}
    times = {}
    prev_arr, prev_seg, prev_bound = None, None, None
    seg_shift = {}
    for s in segs:
        dep, arr = seg_times(day0, s)
        # a connection never leaves before the previous segment lands: move it a day later until it does
        # an on-time first leg with a connection under Raptor's minimum connection time (up to 240 min in its tables) makes
        # Raptor skip the later leg as the disruption: give such connections 250 minutes
        prev_o = next((o for o in spec.get("outcomes") or [] if o.get("seg") == prev_seg), {}) if prev_arr is not None else {}
        if prev_arr is not None and (prev_o.get("kind") or "ontime") == "ontime" and s.get("bound", 1) == prev_bound:
            try:
                gap = (local_to_utc(dep, s["origin"]) - prev_arr).total_seconds() / 60
                if 0 <= gap < 250:
                    shift = timedelta(minutes=250 - gap)
                    seg_shift[s["seg"]] = shift  # its replacements move with it (scenario delays are relative)
                    fmt = lambda x: (datetime.fromisoformat(x) + shift).strftime("%Y-%m-%dT%H:%M")
                    dep, arr = fmt(dep), fmt(arr)
            except Exception:
                pass
        bump = 0
        while prev_arr is not None and bump < 3:
            try:
                if local_to_utc(dep, s["origin"]) > prev_arr:
                    break
            except Exception:
                break
            bump += 1
            dep, arr = seg_times(day0, {**s, "dayOffset": int(s.get("dayOffset") or 0) + bump})
        try:
            prev_arr = local_to_utc(arr, s["destination"])
        except Exception:
            prev_arr = None
        prev_seg, prev_bound = s["seg"], s.get("bound", 1)
        times[s["seg"]] = (dep, arr)
        bounds.setdefault(s.get("bound", 1), []).append(
            {"carrier": s["carrier"], "number": str(s["number"]), "origin": s["origin"], "destination": s["destination"],
             "departure": dep, "arrival": arr, "cabin": s.get("cabin") or "Y", "bookingClass": (s.get("bookingClass") or "T")[:1],
             "status": s.get("status") or "HK", **({"operating": s["operating"]} if isinstance(s.get("operating"), dict) else {})})
    k_of = {s["seg"]: i + 1 for i, s in enumerate(segs)}
    outcomes = {o.get("seg"): o for o in spec.get("outcomes") or []}
    phases = {"ticketing": [{"family": "ticket_issued", "at": {"anchor": "ticketing", "offsetMinutes": 0}, "params": {}}],
              "changes": [], "day_of_flight": [], "post_flight": []}
    for c in spec.get("scheduleChanges") or []:
        k = k_of.get(c.get("seg"), 1)
        phases["changes"].append({"family": "schedule_change",
                                  "at": {"anchor": f"departure:{k}", "offsetMinutes": -int((c.get("noticeHours") or 72) * 60)},
                                  "params": {"segment": k, "departureDeltaMinutes": int(c.get("depDeltaMin") or 0),
                                             "arrivalDeltaMinutes": int(c.get("arrDeltaMin") or 0)}})
    extra_flights = []
    cur = {}  # replaced (original) segment -> the segment index that now stands for it, after earlier rebookings
    def notice_of(r):
        days = r.get("changeDaysBeforeDeparture", r.get("changeDaysBeforeFlight"))
        if days is not None:
            return int(float(days) * 1440)
        return int(((outcomes.get(r.get("replacesSeg")) or {}).get("noticeHours") or 3) * 60)
    # builder steps run in listed order: the earliest change first (a chain VOL at D-15, then INVOL at D-3)
    rbs = sorted(spec.get("rebooking") or [], key=lambda r: -notice_of(r))
    last_of = {r.get("replacesSeg"): i for i, r in enumerate(rbs)}
    for n, r in enumerate(rbs):
        orig = r.get("replacesSeg")
        k0 = k_of.get(orig, 1)
        k = cur.get(orig, k0)
        o = outcomes.get(orig) or {}
        notice = notice_of(r)
        rs = {"carrier": r["carrier"], "number": str(r["number"]), "origin": r["origin"],
              "destination": SISTER_FIX.get((segs[k0 - 1]["destination"], r["destination"]), r["destination"]),
              "dayOffset": r.get("dayOffset", 0), "depLocal": r.get("depLocal"), "arrLocal": r.get("arrLocal")}
        dep, arr = seg_times(day0, rs)
        try:
            if orig in times and local_to_utc(dep, rs["origin"]) < local_to_utc(times[orig][0], segs[k0 - 1]["origin"]) - timedelta(hours=12):
                rs = {**rs, "dayOffset": int(rs.get("dayOffset") or 0) + 1}
                dep, arr = seg_times(day0, rs)
        except Exception:
            pass
        if orig in seg_shift:
            mv = lambda x: (datetime.fromisoformat(x) + seg_shift[orig]).strftime("%Y-%m-%dT%H:%M")
            dep, arr = mv(dep), mv(arr)
        repl = {"carrier": rs["carrier"], "number": rs["number"], "origin": rs["origin"], "destination": rs["destination"],
                "departure": dep, "arrival": arr}
        if r.get("voluntary"):
            # the customer moves themselves: HK added, old removed, no UN/TK (Raptor's voluntary change)
            phases["changes"].append({"family": "customer_rebooking", "at": {"anchor": f"departure:{k0}", "offsetMinutes": -notice},
                                      "params": {"segment": k, "replacement": repl}})
        else:
            phases["changes"].append({"family": "flight_cancelled_rebooked",
                                      "at": {"anchor": f"departure:{k0}", "offsetMinutes": -notice},
                                      "params": {"segment": k, "reason": o.get("cancelCode") or o.get("delayCode") or "WX", "replacement": repl}})
            if r.get("accepted", True):
                phases["changes"].append({"family": "rebooking_accepted", "at": {"anchor": f"departure:{k0}", "offsetMinutes": -notice + 30}, "params": {}})
        k_new = len(segs) + n + 1
        cur[orig] = k_new
        final = last_of.get(orig) == n
        # the passenger flies the final replacement: without its check-in and boarding Raptor reads no travel (origin)
        if final and (r.get("voluntary") or r.get("accepted", True)) and r.get("paxEvent", "boarded") not in ("not_travelled", "no_show"):
            rdelay = int(r.get("depDelayMin", r.get("arrDelayMin") or 0) or 0)
            # anchors resolve against planned segments only: time from the replaced one, shifted to the replacement
            gap = int((local_to_utc(dep, rs["origin"]) - local_to_utc(times[orig][0] if orig in times else times[segs[0]["seg"]][0],
                                                                       segs[k0 - 1]["origin"])).total_seconds() // 60)
            ci = max(gap - 180, -notice + 40)
            phases["day_of_flight"].append({"family": "check_in", "at": {"anchor": f"departure:{k0}", "offsetMinutes": ci}, "params": {"segment": k_new}})
            # boarding is read only after the check-in: never before it, even for a replacement leaving soon after the change
            phases["day_of_flight"].append({"family": "boarding", "at": {"anchor": f"departure:{k0}", "offsetMinutes": max(gap + rdelay - 25, ci + 5)}, "params": {"segment": k_new}})
        nxt = next((x for x in rbs[n + 1:] if x.get("replacesSeg") == orig), None)
        cancelled_next = nxt is not None and not nxt.get("voluntary") and o.get("kind") == "cancel"
        extra_flights.append({"carrier": rs["carrier"], "number": rs["number"], "origin": rs["origin"], "destination": rs["destination"],
                              "depUtc": utc(dep, rs["origin"]), "arrUtc": utc(arr, rs["destination"]),
                              **({"cancelCode": o.get("cancelCode") or o.get("delayCode"), "noticeMinutes": notice_of(nxt)} if cancelled_next else {}),
                              "kind": "cancel" if cancelled_next else ("delay" if r.get("arrDelayMin") else "ontime"), "minutes": int(r.get("arrDelayMin") or 0),
                              "code": r.get("delayCode"), "_key": flight_key(rs, dep),
                              **({"sisterDest": rs["destination"]} if final and rs["destination"] != segs[k0 - 1]["destination"] else {})})
    ev = {(e.get("seg"), e.get("pax")): e.get("event") for e in spec.get("paxEvents") or []}
    vol = {(e.get("seg"), e.get("pax")) for e in spec.get("paxEvents") or [] if e.get("voluntary")}
    for s in segs:
        k = k_of[s["seg"]]
        o = outcomes.get(s["seg"]) or {}
        if o.get("kind") == "cancel" or any(r.get("replacesSeg") == s["seg"] or r.get("replacesAlsoSeg") == s["seg"] for r in spec.get("rebooking") or []):
            for p in range(1, len(pax) + 1):
                if ev.get((s["seg"], p)) == "denied_boarding":
                    phases["day_of_flight"].append({"family": "check_in", "at": {"anchor": f"departure:{k}", "offsetMinutes": -185}, "params": {"segment": k}})
                    phases["day_of_flight"].append({"family": "denied_boarding", "at": {"anchor": f"departure:{k}", "offsetMinutes": -20},
                                                    "params": {"segment": k, "passengers": [p - 1],
                                                               "reason": "DENIED_BOARDING_VOLUNTARY" if (s["seg"], p) in vol else "OVERSALES"}})
            continue
        events = {p: ev.get((s["seg"], p)) for p in range(1, len(pax) + 1)}
        flown = [p for p, e in events.items() if e not in ("denied_boarding", "no_show", "not_travelled")]
        if flown:
            phases["day_of_flight"].append({"family": "check_in", "at": {"anchor": f"departure:{k}", "offsetMinutes": -180}, "params": {"segment": k}})
        for p, e in events.items():
            if e == "denied_boarding":
                phases["day_of_flight"].append({"family": "check_in", "at": {"anchor": f"departure:{k}", "offsetMinutes": -185}, "params": {"segment": k}})
                phases["day_of_flight"].append({"family": "denied_boarding", "at": {"anchor": f"departure:{k}", "offsetMinutes": -20},
                                                "params": {"segment": k, "passengers": [p - 1],
                                                           "reason": "DENIED_BOARDING_VOLUNTARY" if (s["seg"], p) in vol else "OVERSALES"}})
            elif e == "no_show":
                phases["day_of_flight"].append({"family": "no_show", "at": {"anchor": f"departure:{k}", "offsetMinutes": 5},
                                                "params": {"segment": k, "passengers": [p - 1]}})
        if flown:
            dep_delay = int((o.get("depDelayMin") if o.get("depDelayMin") is not None else (o.get("arrDelayMin") or 0)) or 0)
            phases["day_of_flight"].append({"family": "boarding", "at": {"anchor": f"departure:{k}", "offsetMinutes": dep_delay - 25}, "params": {"segment": k}})
    for v in spec.get("vouchers") or []:
        k = k_of.get(v.get("seg"), 1)
        if v.get("kind") == "meal":
            phases["day_of_flight"].append({"family": "meal_voucher", "at": {"anchor": f"departure:{k}", "offsetMinutes": 60},
                                            "params": {"segment": k, "currency": v.get("currency") or "CAD", "value": v.get("value") or 15}})
        elif v.get("kind") == "hotel":
            phases["post_flight"].append({"family": "hotel_voucher", "at": {"anchor": f"departure:{k}", "offsetMinutes": 240},
                                          "params": {"segment": k, "nights": v.get("nights") or 1}})
    flights = []
    for s in segs:
        o = outcomes.get(s["seg"]) or {"kind": "ontime"}
        if o.get("kind") == "nodata":  # the operating carrier's status never arrives (OAL without OAG data)
            continue
        dep, arr = times[s["seg"]]
        kind = o.get("kind") or "ontime"
        code = o.get("delayCode") or o.get("arrDelayCode") or o.get("depDelayCode")
        # a schedule change already moved the segment: the flight status reports only the delay beyond it
        sc = [c for c in spec.get("scheduleChanges") or [] if c.get("seg") == s["seg"]]
        arr_shift = sum(int(c.get("arrDeltaMin") or 0) for c in sc)
        dep_shift = sum(int(c.get("depDeltaMin") or 0) for c in sc)
        arr_min = max(0, int(o.get("arrDelayMin") or 0) - arr_shift)
        dep_min = max(0, int((o.get("depDelayMin") if o.get("depDelayMin") is not None else (o.get("arrDelayMin") or 0)) or 0) - dep_shift)
        want = (spec.get("expect") or {}).get("delayMin")
        if sc and want is not None and kind in ("delay", "divert"):
            # Raptor measures against the promise (the schedule before the change): the flight status carries the
            # rest of the scenario's total delay (patched specs already hold the remainder, so never subtract twice)
            arr_min = max(0, int(want) - arr_shift)
            dep_min = max(0, int(want) - dep_shift)
        f = {"segment": k_of[s["seg"]], "kind": "delay" if kind == "divert" else kind,
             "minutes": arr_min, "depMinutes": dep_min, "code": code, "_key": flight_key(s, dep)}
        if kind == "noarrival":  # the flight departed but its actual arrival is never reported (ND-05)
            f["kind"] = "delay"; f["noArrival"] = True
        # A divert back to the origin does NOT come through here: `builder/fixes-zz-manual.json`
        # patches those four SOC cases with an explicit origin-to-origin rebooking segment
        # ("returned to origin"), so narrowing this condition changed nothing for them. Left as it
        # was rather than carrying an unproven change through a builder FD also uses.
        if kind == "divert" and o.get("divertTo") and o["divertTo"] != s["destination"]:
            f["sisterDest"] = o["divertTo"]  # the booking's arrival becomes the sister airport (scenario_build)
        if o.get("reportedHoursBefore") is not None:
            f["reportedMinutes"] = int(float(o["reportedHoursBefore"]) * 60)
        if o.get("delayCode"):
            f["arrivalCode"] = o["delayCode"]
        elif o.get("depDelayCode") or o.get("fallback"):
            f["arrivalCode"] = None  # the scenario is about the departure-code fallback: no arrival code
        if code and (o.get("codeOnly") or (sc and arr_min == 0) or (f.get("arrivalCode", "x") is None and dep_min == 0)):
            f["codeOnly"] = True  # the code must still reach Raptor (schedule-shifted delay, or the departure-code fallback)
        first_rb = next((r for r in sorted(spec.get("rebooking") or [], key=lambda r: -notice_of(r)) if r.get("replacesSeg") == s["seg"]), None)
        if kind == "cancel" and first_rb is not None and first_rb.get("voluntary"):
            kind = f["kind"] = "ontime"  # the customer left this flight before AC cancelled their new one
        if kind == "cancel":
            # the scenarios often give the cancellation's reason as its only code (delayCode); APPR needs it as the cancel code
            f.update({"cancelCode": o.get("cancelCode") or o.get("delayCode"), "noticeMinutes": int((o.get("noticeHours") or 3) * 60)})
        flights.append(f)
    # the builder runs steps in listed order (its PNR/DCS state follows build order): list each phase by time
    def step_time(st):
        base, _, kk = st["at"]["anchor"].partition(":")
        if base in ("departure", "arrival") and kk.isdigit() and int(kk) <= len(segs):
            s = segs[int(kk) - 1]
            dep_l, arr_l = times[s["seg"]]
            t0 = local_to_utc(dep_l, s["origin"]) if base == "departure" else local_to_utc(arr_l, s["destination"])
            return t0 + timedelta(minutes=st["at"].get("offsetMinutes", 0))
        return None
    for name in ("changes", "day_of_flight", "post_flight"):
        known = [st for st in phases[name] if step_time(st) is not None]
        if len(known) == len(phases[name]):
            phases[name].sort(key=step_time)
    plan = {"bounds": [{"segments": v} for _, v in sorted(bounds.items())],
            "passengers": [{"firstName": (p.get("firstName") or "ALEX").upper(), "lastName": (p.get("lastName") or "TESTER").upper(),
                            "type": p.get("type") or "ADT"} for p in pax],
            "booking": {"createdDaysBefore": 30}, "phases": {k: v for k, v in phases.items() if v}}
    return plan, flights, extra_flights


def main(run_day, out, taken_path=None, specs_dir="specs"):
    run_day = date.fromisoformat(run_day)
    taken = set(json.load(open(taken_path, encoding="utf-8"))) if taken_path else set()
    used = set(taken)
    #: routes this run has planned, without the day. Only our own: the snapshot is date-keyed and
    #: holds most AC flights, so seeding `routes` from it would renumber the whole set.
    routes = set()
    builds, skipped = [], []
    for f in sorted(glob.glob(f"{specs_dir}/*.json")):
        d = json.load(open(f, encoding="utf-8"))
        specs = d["bookings"] if isinstance(d.get("bookings"), list) else [d]
        for i, spec in enumerate(specs):
            sid = d.get("id") or f.split("/")[-1][:-5]
            sid = sid if len(specs) == 1 else f"{sid}#{i + 1}"
            if not spec.get("segments"):
                skipped.append({"id": sid, "reason": "no booking data: " + "; ".join(spec.get("unsupported") or [spec.get("summary") or ""])[:200],
                                # the scenario needs a locator TripTracer does not know (gated as a 404 on a fresh locator)
                                **({"expectNotFound": True} if spec.get("expectNotFound") else {})})
                continue
            base = int(spec.get("flightDaysAgo") or 10)
            if spec.get("pinDaysAgo"):
                # the scenario's timing matters (PE-01: within 72 h of arrival): keep the day, renumber colliding flights
                for bump in range(0, 200):
                    plan, flights, extra = build(spec, run_day, base)
                    keys = {fl["_key"] for fl in flights + extra}
                    rts = {route_of(k) for k in keys}
                    if not (keys & used) and not (rts & routes):
                        break
                    for sg in spec["segments"]:
                        sg["number"] = str(7000 + (int(str(sg["number"])[-3:]) + bump * 37) % 2999)
                days_ago = base
                used |= keys
                routes |= {route_of(k) for k in keys}
                segs, paxn = len(spec["segments"]), len(spec.get("passengers") or [1])
                seed, seed_note = seed_for(segs, paxn)
                builds.append({"id": sid, "seeds": [seed], "plan": plan, "flights": flights + [dict(x, explicit=True) for x in extra],
                               "expect": spec.get("expect") or {}, "daysAgo": days_ago, "seedNote": seed_note,
                               "unsupported": spec.get("unsupported") or [], "assumed": spec.get("assumed") or [],
                               "passengers": paxn, "officeId": (spec.get("booking") or {}).get("officeId") or office_for(spec),
                               "oalEmployee": office_for(spec) == "YULAC01EC", "stripLoyalty": bool(spec.get("stripLoyalty")), "dbcpSegs": spec.get("dbcpSegs") or [],
                               "operatingUnknown": [sg["seg"] for sg in spec["segments"] if sg.get("operatingUnknown")],
                               "tiers": [TIER.get(str(p.get("aeroplanTier") or "").upper()) for p in spec.get("passengers") or []]})
                continue
            for shift in range(0, 120):
                days_ago = base + shift
                if days_ago < 1:
                    continue
                plan, flights, extra = build(spec, run_day, days_ago)
                keys = {fl["_key"] for fl in flights + extra}
                if not keys & used and not {route_of(k) for k in keys} & routes:
                    break
            if keys & used or {route_of(k) for k in keys} & routes:
                # every day in the window is taken for this flight -- AC 871 out of CDG has 208
                # taken days across a year -- and the loop used to fall through and publish onto
                # one of them anyway. The engine then folds whichever leg it already holds, and the
                # case is judged against someone else's delay: FD_TC_136 and FD_TC_137 both landed
                # on AC#871#2026-06-11#CDG twice in a row, with 420 minutes answered against our
                # 240. Renumber instead, exactly as the pinned branch does.
                original = {id(sg): str(sg["number"]) for sg in spec["segments"]}
                for bump in range(1, 200):
                    for sg in spec["segments"]:
                        tail = int(original[id(sg)][-3:])
                        sg["number"] = str(7000 + (tail + bump * 37) % 2999)
                    plan, flights, extra = build(spec, run_day, days_ago)
                    keys = {fl["_key"] for fl in flights + extra}
                    if not keys & used and not {route_of(k) for k in keys} & routes:
                        break
            used |= keys
            routes |= {route_of(k) for k in keys}
            segs, paxn = len(spec["segments"]), len(spec.get("passengers") or [1])
            seed, seed_note = seed_for(segs, paxn)
            builds.append({"id": sid, "seeds": [seed], "plan": plan, "flights": flights + [dict(x, explicit=True) for x in extra],
                           "expect": spec.get("expect") or {}, "daysAgo": days_ago, "seedNote": seed_note,
                           "unsupported": spec.get("unsupported") or [], "assumed": spec.get("assumed") or [],
                           "passengers": paxn,
                           # employee travel: Raptor reads it from the creation office's suffix (eds-booking-type)
                           "officeId": (spec.get("booking") or {}).get("officeId") or office_for(spec),
                           "oalEmployee": office_for(spec) == "YULAC01EC",
                           # Aeroplan elite tier per passenger, as Raptor's aeroplan_elite_tiers_lookup codes it
                           "stripLoyalty": bool(spec.get("stripLoyalty")), "dbcpSegs": spec.get("dbcpSegs") or [],
                           "operatingUnknown": [sg["seg"] for sg in spec["segments"] if sg.get("operatingUnknown")],
                           "tiers": [TIER.get(str(p.get("aeroplanTier") or "").upper()) for p in spec.get("passengers") or []]})
    json.dump(builds, open(out, "w", encoding="utf-8"), indent=1)
    json.dump(skipped, open((out[:-5] if out.endswith(".json") else out) + "-skipped.json", "w", encoding="utf-8"), indent=1)
    print(json.dumps({"builds": len(builds), "skipped": len(skipped), "flights": len(used - taken)}))


if __name__ == "__main__":
    args = sys.argv[1:]
    taken = args[args.index("--taken") + 1] if "--taken" in args else None
    specs_dir = args[args.index("--specs") + 1] if "--specs" in args else "specs"
    main(args[0], args[1], taken, specs_dir)
