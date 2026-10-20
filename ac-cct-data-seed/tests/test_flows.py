"""The flow interface, against a document shaped like the engine's.

Three things are asserted: FD compares a real document correctly and catches a wrong one; a case
with no stated expectation reports n/a rather than a pass; and every assessment section has exactly
one flow reading it, with the uncovered ones named rather than forgotten.

Run:  python tests/test_flows.py
"""
from __future__ import annotations

import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from core import registry                                                   # noqa: E402
from core.flow import SECTIONS                                              # noqa: E402

FAILED: list[str] = []


def check(label: str, got, want) -> None:
    if got != want:
        FAILED.append(f"{label}: got {got!r}, wanted {want!r}")
        print(f"  FAIL {label}: got {got!r}, wanted {want!r}")
    else:
        print(f"  ok   {label}")


#: FD_TC_001 as a spec, trimmed to what the flow reads
SPEC = {
    "id": "FD_TC_001", "family": "FD", "flightDaysAgo": 10,
    "passengers": [{"type": "ADT", "firstName": "CATHERINE", "lastName": "BOUCHARD",
                    "residence": "CA", "aeroplanTier": "Basic"}],
    "segments": [{"seg": 1, "bound": 1, "carrier": "AC", "number": "301", "origin": "YUL",
                  "destination": "YYZ", "depLocal": "12:40", "arrLocal": "14:00", "status": "HK"}],
    "outcomes": [{"seg": 1, "kind": "delay", "arrDelayMin": 240, "delayCode": "64"}],
    "expect": {"regime": "APPR", "eligibility": "ELIGIBLE", "systemCode": "FD-APPR-EL-01",
               "amount": 400, "currency": "CAD", "delayMin": 240, "control": "CONTROLLABLE",
               "cause": "64", "delayBand": "DELAY_3_TO_LT_6_HOURS"},
}


def document(**over) -> dict:
    """An assessment document for that spec, with fields overridden to make one wrong."""
    row = {"passengerName": "CATHERINE BOUCHARD", "eligibilityStatus": "ELIGIBLE",
           "systemCode": "FD-APPR-EL-01", "delayMinutes": 240, "delayType": "CONTROLLABLE",
           "delayOrCancelCode": "64",
           "compensationDetails": {"amount": 400, "currency": "CAD",
                                   "delayBand": "DELAY_3_TO_LT_6_HOURS"}}
    comp = over.pop("compensationDetails", {})
    row["compensationDetails"] = {**row["compensationDetails"], **comp}
    row.update(over)
    return {"compensationEligibility": [{"regime": "APPR", "passengerEligibility": [row]}]}


def by_name(checks) -> dict:
    return {c.name: c for c in checks}


def main() -> int:
    fd = registry.get("fd")

    print("FD: a spec it can run")
    check("validate finds nothing missing", fd.validate(SPEC), [])

    print("FD: the matching document")
    rows = fd.rows(document())
    check("one row", len(rows), 1)
    checks = by_name(fd.checks(SPEC, rows))
    for name in ("fd_eligibility", "fd_systemCode", "fd_amount", "fd_currency",
                 "fd_delayMin", "fd_control", "fd_delayBand", "fd_cause", "fd_row_count"):
        check(f"{name} passes", (checks[name].applies, checks[name].ok), (True, True))

    print("FD: a document with the wrong amount")
    bad = by_name(fd.checks(SPEC, fd.rows(document(compensationDetails={"amount": 1000}))))
    check("fd_amount fails", bad["fd_amount"].ok, False)
    check("fd_amount says what it saw", bad["fd_amount"].actual, "1000.0")
    check("fd_systemCode still passes", bad["fd_systemCode"].ok, True)

    print("FD: an empty document")
    empty = by_name(fd.checks(SPEC, fd.rows({})))
    check("fd_section_present fails", empty["fd_section_present"].ok, False)

    print("FD: a case with no stated expectation (the 41 table cases)")
    inputs_only = {**SPEC, "expect": {}}
    check("validate objects", any("eligibility" in m for m in fd.validate(inputs_only)), True)
    na = fd.checks(inputs_only, fd.rows(document()))
    check("one n/a check", (len(na), na[0].applies, na[0].ok), (1, False, None))

    print("FD: a document holding a regime the spec did not expect")
    two = document()
    two["compensationEligibility"].append(
        {"regime": "EU", "passengerEligibility": [{"passengerName": "CATHERINE BOUCHARD",
                                                   "eligibilityStatus": "NOT_ELIGIBLE",
                                                   "systemCode": "FD-EU-NE-01"}]})
    both = by_name(fd.checks(SPEC, fd.rows(two)))
    check("the APPR comparison still passes", both["fd_systemCode"].ok, True)
    check("fd_row_count notices the extra regime", both["fd_row_count"].ok, True)

    print("Flows that are not ready")
    # baggage's first need was the bag-event lane until `builder/bag_build.py` became it; what it
    # still wants is the per-bag row shape, which is why it can seed today and not judge
    for fid, first_need in (("soc", "row shape"), ("baggage", "row shape"), ("anc", "EMD")):
        f = registry.get(fid)
        check(f"{fid} is not ready", f.ready, False)
        check(f"{fid} names what it needs", first_need in " ".join(f.needs), True)
        only = f.checks(SPEC, [])
        check(f"{fid} claims nothing", (len(only), only[0].applies, only[0].ok), (1, False, None))

    print("Sections")
    owners = registry.sections_covered()
    check("every section is listed", sorted(owners), sorted(SECTIONS))
    check("fd reads compensationEligibility", owners["compensationEligibility"], "fd")
    # the dict-based registry only ever tracked one section per flow, so the two secondary
    # sections look unowned here. `flows/registry.py` reads a flow's `also` and owns all six;
    # `tests/test_registry.py` is where that is checked.
    uncovered = [s for s, o in owners.items() if o is None]
    check("the dict registry leaves the two secondary sections untracked",
          sorted(uncovered),
          sorted(["interimExpensesEligibility", "seatFeeRefundEligibility"]))
    check("one flow can claim a verdict today", [f.id for f in registry.ready()], ["fd"])

    print(f"\n{'FAILED: ' + str(len(FAILED)) if FAILED else 'all checks passed'}")
    return 1 if FAILED else 0


if __name__ == "__main__":
    raise SystemExit(main())
