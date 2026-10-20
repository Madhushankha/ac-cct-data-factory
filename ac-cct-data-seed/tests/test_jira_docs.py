"""The Jira snapshot: does it still line up with the specs we seed?

Jira is the source of truth for these tests, so the thing worth checking on every run is that the
two sides describe the same set of cases. Both directions are findings:

* a spec with no Jira test is a case being seeded that nothing authoritative defines;
* a Jira test with no spec is a defined case nobody can run.

The one known exception is pinned by name, so it stays visible without making every run red — and
so a NEW misalignment still fails.

Run:  python tests/test_jira_docs.py
"""
from __future__ import annotations

import json
import pathlib
import shutil
import sys
import tempfile

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from adapters.file_spec_source import FileSpecSource                         # noqa: E402
from adapters.jira_docs import FileTestDocs                                  # noqa: E402
from domain.testdoc import TestDoc                                           # noqa: E402
from ports import TestDocs                                                   # noqa: E402

#: `SOC_UAT_076` is defined by both CHAI-31990 ("ASL - Pending - 72 Hours") and CHAI-31991
#: ("Override - Pending"), and SOC_UAT_075 does not exist, so one of them is mis-numbered. Our spec
#: carries the issue key in its name to point at one test unambiguously. Not renumbered here: Jira
#: is the source, and that is the test owner's call. See jira/README.md.
KNOWN_MISALIGNED = {"soc/uat/automation": {"SOC_UAT_076__CHAI-31991"}}
KNOWN_DUPLICATE_IDS = {"soc/uat/automation": {"SOC_UAT_076"}}

FAILED: list[str] = []


def check(label: str, got: object, want: object) -> None:
    if got != want:
        FAILED.append(label)
        print(f"  FAIL {label}: got {got!r}, wanted {want!r}")
    else:
        print(f"  ok   {label}")


# --------------------------------------------------------------------- the doc

def test_the_value() -> None:
    print("a test doc, parsed")
    doc = TestDoc.parse({
        "key": "CHAI-31510", "test_id": "FD_TC_118", "status": "New",
        "title": "EU 261 | Sister City", "summary": "FD_TC_118_EU 261 | Sister City",
        "description": "Guadeloupe-origin flight. Prerequisites: a. b.",
        "goal": "Guadeloupe-origin flight.",
        "prerequisites": "a. b.", "prerequisite_items": ["Regime: EU", "Delay 3+ hrs", ""],
        "scenario_type": "scenario", "execution": "CHAI-31809",
        "synced_at": "2026-10-13T07:02:34Z"}, gherkin="Feature: x")
    check("the case id comes from test_id", doc.case_id, "FD_TC_118")
    check("blank prerequisite items are dropped", doc.prerequisite_items,
          ("Regime: EU", "Delay 3+ hrs"))
    check("it builds the issue url", doc.url.endswith("/browse/CHAI-31510"), True)
    check("a scenario card says so", doc.is_scenario, True)
    check("it can be searched by its own words", doc.mentions("sister city"), True)
    check("and says no to what it does not say", doc.mentions("baggage"), False)
    check("an empty search matches nothing", doc.mentions("  "), False)
    check("undamaged text counts zero", doc.damaged_characters, 0)
    damaged = TestDoc.parse({"test_id": "X", "key": "K", "summary": "ASL � Eligible"})
    check("damage is counted", damaged.damaged_characters, 1)


def test_reading_a_folder() -> None:
    print("reading a case folder")
    root = pathlib.Path(tempfile.mkdtemp(prefix="jiradocs-"))
    try:
        d = root / "fd/uat/automation/FD_TC_001__CHAI-31393"
        d.mkdir(parents=True)
        (d / "test.json").write_text(json.dumps(
            {"test_id": "FD_TC_001", "key": "CHAI-31393", "title": "t"}), encoding="utf-8")
        (d / "test.feature").write_text("Feature: seeded", encoding="utf-8")
        docs = FileTestDocs(root)
        check("satisfies the port", isinstance(docs, TestDocs), True)
        check("the set is found", docs.sets(), ("fd/uat/automation",))
        check("a case is found by id", docs.doc("FD_TC_001").key, "CHAI-31393")
        check("case does not matter", docs.doc("fd_tc_001").key, "CHAI-31393")
        check("the gherkin comes with it", docs.doc("FD_TC_001").gherkin, "Feature: seeded")
        check("an unknown case is None, not an error", docs.doc("FD_TC_999"), None)
        check("the set lists it", [d.case_id for d in docs.docs("fd/uat/automation")],
              ["FD_TC_001"])
        check("an unknown set is empty", docs.docs("soc/uat/po"), ())
    finally:
        shutil.rmtree(root, ignore_errors=True)


def test_coverage_counts_cases_not_rows() -> None:
    print("coverage counts cases, not rows")
    root = pathlib.Path(tempfile.mkdtemp(prefix="jiracov-"))
    try:
        d = root / "fd/uat/automation/FD_TC_209__CHAI-31601"
        d.mkdir(parents=True)
        (d / "test.json").write_text(json.dumps(
            {"test_id": "FD_TC_209", "key": "CHAI-31601"}), encoding="utf-8")
        docs = FileTestDocs(root)
        # a spec holding two bookings parses as #1 and #2 but is one case
        cover = docs.coverage("fd/uat/automation", ("FD_TC_209#1", "FD_TC_209#2"))
        check("two booking rows are one case", cover.specs, ("FD_TC_209",))
        check("so the two sides align", cover.aligned, True)
        gap = docs.coverage("fd/uat/automation", ("FD_TC_209", "FD_TC_999"))
        check("a spec with no test is reported", gap.missing_docs, ("FD_TC_999",))
        check("and that is not aligned", gap.aligned, False)
        orphan = docs.coverage("fd/uat/automation", ())
        check("a test with no spec is reported", orphan.missing_specs, ("FD_TC_209",))
    finally:
        shutil.rmtree(root, ignore_errors=True)


# ---------------------------------------------------------------- the real set

def test_the_real_snapshot() -> None:
    print("the snapshot as it is")
    docs, src = FileTestDocs(), FileSpecSource()
    check("both sets are present", docs.sets(),
          ("fd/uat/automation", "soc/uat/automation"))

    for set_name in docs.sets():
        spec_ids = tuple(s.case_id for s in src.scenarios(set_name))
        cover = docs.coverage(set_name, spec_ids)
        unexplained_specs = set(cover.missing_docs) - KNOWN_MISALIGNED.get(set_name, set())
        unexplained_docs = set(cover.missing_specs) - KNOWN_MISALIGNED.get(set_name, set())
        check(f"{set_name}: every spec has a Jira test", sorted(unexplained_specs), [])
        check(f"{set_name}: every Jira test has a spec", sorted(unexplained_docs), [])
        check(f"{set_name}: no new duplicate ids",
              set(cover.duplicate_ids), KNOWN_DUPLICATE_IDS.get(set_name, set()))

    fd = docs.coverage("fd/uat/automation",
                       tuple(s.case_id for s in src.scenarios("fd/uat/automation")))
    check("the FD set is 266 cases", len(fd.specs), 266)
    check("and fully aligned", fd.aligned, True)


def test_the_known_defect_is_still_the_defect() -> None:
    """If Jira is fixed, this fails -- which is the point: then the pin should go."""
    print("the known SOC numbering defect")
    docs = FileTestDocs()
    soc = docs.docs("soc/uat/automation")
    by_id: dict[str, list[str]] = {}
    for d in soc:
        by_id.setdefault(d.case_id, []).append(d.key)
    check("SOC_UAT_076 is still defined twice", sorted(by_id.get("SOC_UAT_076", [])),
          ["CHAI-31990", "CHAI-31991"])
    check("SOC_UAT_075 still does not exist", "SOC_UAT_075" in by_id, False)
    check("the two are different tests",
          len({d.title for d in soc if d.case_id == "SOC_UAT_076"}), 2)


def test_search() -> None:
    print("searching the tests")
    docs = FileTestDocs()
    wallet = docs.search("AC Wallet", "fd/uat/automation")
    check("AC Wallet is mentioned by some FD tests", len(wallet) > 0, True)
    check("every hit really says it",
          all(d.mentions("ac wallet") for d in wallet), True)
    check("a nonsense search finds nothing", docs.search("zzzz-not-a-thing"), ())


def main() -> int:
    for fn in (test_the_value, test_reading_a_folder, test_coverage_counts_cases_not_rows,
               test_the_real_snapshot, test_the_known_defect_is_still_the_defect, test_search):
        fn()
        print()
    print(f"{len(FAILED)} failed: {', '.join(FAILED)}" if FAILED else "all checks passed")
    return 1 if FAILED else 0


if __name__ == "__main__":
    raise SystemExit(main())
