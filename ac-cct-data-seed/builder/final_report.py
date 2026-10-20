"""$UAT_WORK_DIR/combined-report.json -> FINAL_REPORT.json and FINAL_REPORT.md (same folder).

  final_report.py [combined-report.json]

A failing scenario listed in pending-rules.json is tagged with the TripTracer rule item it depends on (those rule
changes ship in cascade PR #400; BAT must run that image, see README). The PE-01 group (FD_TC_103/150/171,
SOC_UAT_024/048/076) is only PENDING within 72 h of arrival: gated too late it fails by design.
"""
import collections
import json
import os
import sys
from pathlib import Path

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import uat_config  # noqa: E402

src = Path(sys.argv[1]) if len(sys.argv) > 1 else uat_config.work_dir() / "combined-report.json"
rows = json.load(open(src))
rule_of = {i: k for k, v in json.load(open(f"{HERE}/pending-rules.json")).items() for i in v}
out = []
for x in sorted(rows, key=lambda r: r["id"]):
    row = {k: x.get(k) for k in ("id", "pnrId", "result", "mismatches", "reason", "daysAgo")}
    if x["result"] != "PASS" and x["id"] in rule_of:
        row["rule"] = rule_of[x["id"]]
    out.append(row)
json.dump(out, open(src.parent / "FINAL_REPORT.json", "w"), indent=1)
c = collections.Counter(x["result"] for x in out)
fam = collections.Counter((x["id"].split("_")[0], x["result"]) for x in out)
kinds = sorted(c)
lines = ["# UAT scenario PNRs: gate report", "",
         f"Total {len(out)}: " + ", ".join(f"{k} {v}" for k, v in sorted(c.items())), "",
         "| family | " + " | ".join(kinds) + " |", "|---|" + "---|" * len(kinds)]
for f in sorted({k[0] for k in fam}):
    lines.append(f"| {f} | " + " | ".join(str(fam[(f, k)]) for k in kinds) + " |")
for kind in [k for k in kinds if k != "PASS"]:
    lines += ["", f"## {kind}", "", "| id | PNR | detail |", "|---|---|---|"]
    for x in out:
        if x["result"] == kind:
            d = (f"[rule {x['rule']}] " if x.get("rule") else "") + (x.get("reason") or "; ".join(x["mismatches"] or [])[:300])
            lines.append(f"| {x['id']} | {x['pnrId'] or ''} | {d.replace('|', '/')} |")
lines += ["", "## All scenarios", "", "| scenario | PNR | result |", "|---|---|---|"]
lines += [f"| {x['id']} | {x['pnrId'] or ''} | {x['result']} |" for x in out]
(src.parent / "FINAL_REPORT.md").write_text("\n".join(lines) + "\n")
print(json.dumps(dict(c)), "->", src.parent / "FINAL_REPORT.md")
