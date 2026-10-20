"""The flow registry and the spec tree: the two things that decide what can be seeded at all.

No network, no AWS. The spec-tree checks run against a temporary tree rather than the real one, so
they state a rule instead of describing today's contents -- except where a count is the point.

Run:  python tests/test_registry.py
"""
from __future__ import annotations

import json
import pathlib
import shutil
import sys
import tempfile

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from adapters.file_spec_source import DuplicateCaseId, FileSpecSource    # noqa: E402
from domain.sections import SECTIONS, owned_by, owner                    # noqa: E402
from flows import registry                                              # noqa: E402
from flows.not_ready import NotReady                                     # noqa: E402
from ports import FlowPolicy                                            # noqa: E402

FAILED: list[str] = []


def check(label: str, got: object, want: object) -> None:
    if got != want:
        FAILED.append(label)
        print(f"  FAIL {label}: got {got!r}, wanted {want!r}")
    else:
        print(f"  ok   {label}")


def raises(label: str, fn, kind=Exception, contains: str = "") -> None:
    try:
        fn()
    except kind as ex:                                                   # noqa: BLE001
        if contains and contains not in str(ex):
            FAILED.append(label)
            print(f"  FAIL {label}: raised but said {str(ex)[:90]!r}")
        else:
            print(f"  ok   {label}")
        return
    FAILED.append(label)
    print(f"  FAIL {label}: did not raise")


# ------------------------------------------------------------------- sections

def test_sections() -> None:
    print("the six sections")
    check("there are six", len(SECTIONS), 6)
    check("interim expenses belong to baggage, not SOC",
          owner("interimExpensesEligibility"), "baggage")
    check("baggage owns two sections", len(owned_by("baggage")), 2)
    check("ancillary owns two sections", len(owned_by("anc")), 2)
    check("fd owns one", owned_by("fd"), ("compensationEligibility",))
    raises("an unknown section raises and names the six", lambda: owner("nope"), KeyError,
           "is not an assessment section")


def test_registry() -> None:
    print("the registry")
    check("every policy satisfies the port",
          all(isinstance(p, FlowPolicy) for p in registry.POLICIES), True)
    owners = registry.sections()
    check("every section has exactly one owner", sorted(owners), sorted(SECTIONS))
    check("no section is unowned", [s for s, o in owners.items() if o is None], [])
    check("the owners match the domain record",
          owners, {s: f for s, f in SECTIONS.items()})
    check("one flow can claim a verdict today", [p.flow_id for p in registry.ready()], ["fd"])
    check("a set resolves to its flow", registry.for_set("fd/uat/automation").flow_id, "fd")
    check("so does a set of a flow that cannot claim",
          registry.for_set("baggage/uat/automation").flow_id, "baggage")
    raises("an unknown flow raises and lists the known ones",
           lambda: registry.get("nope"), KeyError, "known: anc, baggage, fd, soc")


def test_the_invariant_is_enforced() -> None:
    print("the invariant, against policies built to break it")

    class ReadsNothingReal(NotReady):
        flow_id, label, section = "x", "X", "notASection"

    class StealsCompensation(NotReady):
        flow_id, label, section = "y", "Y", "compensationEligibility"

    def with_policies(*extra):
        saved = registry.POLICIES
        try:
            registry.POLICIES = (*saved, *extra)
            registry._check()
        finally:
            registry.POLICIES = saved

    raises("a section that does not exist is refused",
           lambda: with_policies(ReadsNothingReal()), ValueError,
           "not one of the six")
    raises("two flows reading one section is refused",
           lambda: with_policies(StealsCompensation()), ValueError,
           "one section, one flow")


def test_not_ready_claims_nothing() -> None:
    print("a flow that is not ready")
    from domain.models import Assessment, Scenario
    soc = registry.get("soc")
    scenario = Scenario.parse({"id": "SOC_UAT_001", "family": "SOC",
                               "expect": {"eligibility": "ELIGIBLE"},
                               "passengers": [{"type": "ADT"}],
                               "segments": [{"seg": 1}]})
    # SOC accepts a scenario for SEEDING and still refuses to judge it. `blocks_seeding` is empty
    # because the builder consumes every block the 77 specs use; the three entries in `needs` stop
    # a verdict being claimed, which is what the `judge` assertions below check. This used to
    # assert that `validate` refused -- true only while the two were the same list.
    check("it accepts the scenario for seeding", list(soc.validate(scenario)), [])
    check("nothing it still needs blocks seeding", list(soc.blocks_seeding), [])
    check("and it still names what it cannot do", bool(soc.needs), True)
    document = {"socFlightEligibility": [{"regime": "APPR", "boundRph": 1,
                                          "passengerEligibility": [
                                              {"eligibilityStatus": "ELIGIBLE",
                                               "passengerName": "A B"}]}]}
    checks = soc.judge(scenario, soc.rows(Assessment.parse("P", {"document": document})))
    check("it reads its section", len(soc.rows(Assessment.parse("P", {"document": document}))), 1)
    check("it claims nothing", [c.applies for c in checks], [False, False])
    check("no check can be read as a pass", [c.ok for c in checks], [None, None])


# ------------------------------------------------------------------ spec tree

def _tree(layout: dict[str, dict]) -> pathlib.Path:
    """Build a temporary spec tree: `{"fd/uat/automation": {"FD_TC_1": {...}}}`."""
    root = pathlib.Path(tempfile.mkdtemp(prefix="spectree-"))
    for set_name, specs in layout.items():
        d = root / set_name
        d.mkdir(parents=True, exist_ok=True)
        for case_id, body in specs.items():
            (d / f"{case_id}.json").write_text(json.dumps(body), encoding="utf-8")
    return root


SPEC = {"family": "FD", "expect": {"eligibility": "ELIGIBLE"},
        "passengers": [{"type": "ADT"}], "segments": [{"seg": 1}]}


def test_tree_discovery() -> None:
    print("the spec tree")
    root = _tree({"fd/uat/automation": {"FD_TC_001": SPEC, "FD_TC_002": SPEC},
                  "soc/uat/po": {"SOC_UAT_001": SPEC},
                  "baggage/uat/automation": {}})
    try:
        src = FileSpecSource(root)
        check("sets are discovered, not registered",
              src.sets(), ("baggage/uat/automation", "fd/uat/automation", "soc/uat/po"))
        check("an empty set is listed", src.set_named("baggage/uat/automation").count, 0)
        s = src.set_named("fd/uat/automation")
        check("flow, phase and purpose come from the path", (s.flow, s.phase, s.purpose),
              ("fd", "uat", "automation"))
        check("scenarios parse", [x.case_id for x in src.scenarios("fd/uat/automation")],
              ["FD_TC_001", "FD_TC_002"])
        check("a case is found by id", src.scenario("SOC_UAT_001").case_id, "SOC_UAT_001")
        raises("an unknown set raises and lists what there is",
               lambda: src.set_named("fd/uat/nope"), KeyError, "the tree holds")
        raises("an unknown case id raises", lambda: src.scenario("NOPE"), KeyError)
    finally:
        shutil.rmtree(root, ignore_errors=True)


def test_one_id_one_spec() -> None:
    print("one id, one spec")
    root = _tree({"fd/uat/automation": {"FD_TC_001": SPEC},
                  "fd/sit/po": {"FD_TC_001": SPEC}})
    try:
        raises("the same id in two sets raises, naming both",
               lambda: FileSpecSource(root).index(), DuplicateCaseId, "fd/sit/po")
    finally:
        shutil.rmtree(root, ignore_errors=True)


def test_superseded_is_not_a_set() -> None:
    print("a superseded spec is kept but never built")
    root = _tree({"fd/uat/automation": {"FD_TC_001": SPEC},
                  "fd/uat/automation/_superseded": {"FD_TC_001": {"family": "FD"}}})
    try:
        src = FileSpecSource(root)
        check("_superseded is not a set", src.sets(), ("fd/uat/automation",))
        check("so the duplicate id does not raise", len(src.index()), 1)
        check("and the live spec is the one that is read",
              src.scenario("FD_TC_001").expectation.eligibility, "ELIGIBLE")
    finally:
        shutil.rmtree(root, ignore_errors=True)


def test_one_file_many_bookings() -> None:
    print("a spec holding several bookings")
    root = _tree({"fd/uat/automation": {"FD_TC_209": {
        "family": "FD", "summary": "two bookings",
        "bookings": [{"expect": {"eligibility": "ELIGIBLE"}, "passengers": [{"type": "ADT"}]},
                     {"expect": {"eligibility": "NOT_ELIGIBLE"}, "passengers": [{"type": "ADT"}]}]}}})
    try:
        got = FileSpecSource(root).scenarios("fd/uat/automation")
        check("each booking is a scenario", [s.case_id for s in got],
              ["FD_TC_209#1", "FD_TC_209#2"])
        check("the ids are the form fixes-*.json uses", got[0].case_id.endswith("#1"), True)
        check("each keeps its own expectation",
              [s.expectation.eligibility for s in got], ["ELIGIBLE", "NOT_ELIGIBLE"])
        check("and inherits the file's shared fields", got[0].summary, "two bookings")
    finally:
        shutil.rmtree(root, ignore_errors=True)


def test_the_real_tree() -> None:
    """The counts that matter, against the tree as it actually is."""
    print("the real tree")
    src = FileSpecSource()
    by_name = {s.name: s.count for s in src.describe()}
    check("fd/uat/automation holds the 266", by_name.get("fd/uat/automation"), 266)
    check("fd/uat/po holds the 27", by_name.get("fd/uat/po"), 27)
    check("no duplicate ids anywhere", len(src.index()), sum(by_name.values()))
    check("every set resolves to a known flow",
          all(registry.for_set(n) for n in by_name), True)
    check("every set has a README",
          [s.name for s in src.describe() if not (s.path / "README.md").exists()], [])


def main() -> int:
    for fn in (test_sections, test_registry, test_the_invariant_is_enforced,
               test_not_ready_claims_nothing, test_tree_discovery, test_one_id_one_spec,
               test_superseded_is_not_a_set, test_one_file_many_bookings, test_the_real_tree):
        fn()
        print()
    print(f"{len(FAILED)} failed: {', '.join(FAILED)}" if FAILED else "all checks passed")
    return 1 if FAILED else 0


if __name__ == "__main__":
    raise SystemExit(main())
