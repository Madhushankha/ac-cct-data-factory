"""Compare gate observations with each scenario's expectations.

  gate_compare.py <manifest.json> <gate.out> <skipped.json> <build-failed.json> <report.json>

Reads TripTracer's lookup tables (LOOKUP_TABLES or $CASCADE_DIR/apps/trip-tracer-event-processor/rules/lookup-tables.json)
for a delay code's controllability.
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import uat_config  # noqa: E402

_lt = json.load(open(uat_config.lookup_tables()))
_tabs = _lt if isinstance(_lt, list) else _lt.get("tables", _lt)
def _table(tid):
    return {str(r.get("key")): (r.get("controllability") or r.get("value")) for t in (_tabs.values() if isinstance(_tabs, dict) else _tabs)
            if isinstance(t, dict) and t.get("id") == tid for r in t.get("data", [])}
APPR_DELAY = _table("APPR_delay_lookup")
EU_ASL_DELAY = _table("EU_ASL_delay_code_controllability_lookup")
import re
manifest, gate_out, skipped, failed, report = sys.argv[1:6]
obs = {}
for l in open(gate_out):
    l = l.strip()
    if l.startswith('{'):
        try: d = json.loads(l); obs[d["pnrId"]] = d
        except Exception: pass
STATUS = {}  # Raptor reports PENDING itself (PE-01)
rows = []
for m in json.load(open(manifest)):
    e = m.get("expect") or {}; o = obs.get(m["pnrId"])
    row = {"id": m["id"], "pnrId": m["pnrId"], "result": "PASS", "mismatches": []}
    if not o:
        row.update(result="NOT_OBSERVED"); rows.append(row); continue
    if o.get("tripErr") or o.get("ddsErr"):
        row["mismatches"].append(f"read error: {o.get('tripErr') or o.get('ddsErr')}")
    regime = (e.get("regime") or "").upper()
    soc = str(m["id"]).startswith("SOC")
    rows_seen = (o.get("soc") or []) if soc else (o.get("comp") or [])
    comp = [c for c in rows_seen if not regime or c["regime"] == regime or regime == "MIXED"]
    # Raptor returns a row per bound and passenger: compare the one the scenario is about (its expected code, else the
    # most delayed / the first)
    want_code = str(e.get("systemCode") or "")
    c0 = (next((c for c in comp if str(c.get("code")) == want_code), None)
          or (max(comp, key=lambda c: int(c.get("delayMin") or 0)) if comp else None))
    def check(name, want, got):
        if want in (None, "", []): return
        if str(want).upper() != str(got).upper(): row["mismatches"].append(f"{name}: expected {want}, got {got}")
    if regime and regime != "MIXED" and not comp:
        row["mismatches"].append(f"regime {regime}: no DDS row (regimes {sorted({c['regime'] for c in o.get('comp') or []})})")
    if c0:
        check("eligibility", STATUS.get(str(e.get("eligibility") or "").upper(), e.get("eligibility")), c0["status"])
        sc = e.get("systemCode")
        check("systemCode", sc if sc and re.match(r"^(FD|SoC|SOC|BAG|BF)-", str(sc)) else None, c0.get("code"))
        if not soc and e.get("amount") not in (None, 0):
            check("amount", e.get("amount"), c0.get("amount"))
            check("currency", e.get("currency"), c0.get("currency"))
        if not soc and str(e.get("delayBand") or "").startswith("DELAY_") and c0.get("band"):
            check("delayBand", {"DELAY_9_HOURS_PLUS": "DELAY_GTE_9_HOURS", "DELAY_GE_9_HOURS": "DELAY_GTE_9_HOURS"}.get(e.get("delayBand"), e.get("delayBand")), c0["band"])
        if e.get("delayMin") not in (None, ""):  # an early arrival (negative) counts as no delay
            try:
                if not soc and abs(int(e["delayMin"]) - max(0, int(c0.get("delayMin") or 0))) > 2: row["mismatches"].append(f"delayMin: expected {e['delayMin']}, got {c0['delayMin']}")
            except Exception: pass
        if not soc:
            # a NOT_ELIGIBLE row (delay under the threshold) carries no cause: the disrupted leg's own code and
            # controllability are what TripTracer shows for it
            msl = max((s for s in o.get("segs") or [] if s.get("causeCode")), key=lambda s: int(s.get("delayMin") or 0), default={})
            ctl = c0.get("delayType") or msl.get("cause")
            if str(ctl or "").upper() in ("", "UNKNOWN", "NONE") and msl.get("causeCode"):
                ctl = (APPR_DELAY if regime in ("APPR", None, "") else EU_ASL_DELAY).get(str(msl["causeCode"]), ctl)  # the code's controllability as TripTracer's table states it
            check("control", e.get("control"), ctl)
            check("cause", e.get("cause"), c0.get("cause") or msl.get("causeCode"))
    want_tickets = m.get("passengers") or 1
    if (o.get("counts") or {}).get("tickets", 0) < 1:
        row["mismatches"].append(f"tickets: expected >=1, got {(o.get('counts') or {}).get('tickets')}")
    if row["mismatches"]: row["result"] = "FAIL"
    row.update({"daysAgo": m.get("daysAgo"), "seedNote": m.get("seedNote"), "unsupported": m.get("unsupported")})
    rows.append(row)
for s in json.load(open(skipped)): rows.append({"id": s["id"], "result": "NOT_BOOKING_DATA", "mismatches": [s["reason"]]})
for f in json.load(open(failed)): rows.append({"id": f["id"], "result": "BUILD_FAILED", "mismatches": [f["error"]]})
json.dump(rows, open(report, "w"), indent=1)
from collections import Counter
print(json.dumps(Counter(r["result"] for r in rows)))
mm = Counter(re.sub(r"expected .*", "", x).strip() for r in rows if r["result"] == "FAIL" for x in r["mismatches"])
print("top mismatch kinds:", mm.most_common(12))
