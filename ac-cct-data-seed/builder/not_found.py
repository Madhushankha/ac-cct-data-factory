"""Scenarios that need NO booking (spec "expectNotFound": true, e.g. FD_ED_TC_03): TripTracer must answer 404 for a
fresh, never-published locator.

  not_found.py pick  <all-builds-skipped.json> <run-day YYYY-MM-DD> <notfound.json>   fresh ZZ locator per such scenario
  not_found.py apply <report.json> <gate.out> <notfound.json>                         PASS when the gate saw a 404
"""
import json
import secrets
import string
import sys

ALPHABET = string.ascii_uppercase + string.digits


def pick(skipped, run_day, out):
    rows = [{"id": s["id"], "pnrId": "ZZ" + "".join(secrets.choice(ALPHABET) for _ in range(4)) + f"-{run_day}"}
            for s in json.load(open(skipped)) if s.get("expectNotFound")]
    json.dump(rows, open(out, "w"), indent=1)
    print(json.dumps({"notFoundChecks": len(rows)}))


def apply(report, gate_out, notfound):
    obs = {}
    for line in open(gate_out):
        line = line.strip()
        if line.startswith("{"):
            try:
                d = json.loads(line)
                obs[d["pnrId"]] = d
            except Exception:
                pass
    rows = json.load(open(report))
    for nf in json.load(open(notfound)):
        o = obs.get(nf["pnrId"])
        if o is None:
            new = {"id": nf["id"], "pnrId": nf["pnrId"], "result": "NOT_OBSERVED", "mismatches": ["fresh locator not gated"]}
        elif "404" in str(o.get("tripErr") or ""):
            new = {"id": nf["id"], "pnrId": nf["pnrId"], "result": "PASS", "mismatches": [],
                   "reason": "scenario requires no booking: TripTracer returns 404 for a fresh locator"}
        else:
            new = {"id": nf["id"], "pnrId": nf["pnrId"], "result": "FAIL",
                   "mismatches": [f"expected TripTracer 404 for a fresh locator, got {o.get('tripErr') or 'a booking'}"]}
        rows = [r for r in rows if r["id"] != nf["id"]] + [new]
    json.dump(rows, open(report, "w"), indent=1)


if __name__ == "__main__":
    cmd, *args = sys.argv[1:]
    {"pick": pick, "apply": apply}[cmd](*args)
