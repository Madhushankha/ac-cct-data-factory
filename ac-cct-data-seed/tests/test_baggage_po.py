"""The baggage PO set: 73 hand-walked cases, each bound to a PNR that is already published.

No network, no AWS, and no kit checkout: everything asserted here is in the repository. What the
checks are for is the two ways this set could rot without anyone noticing --

* a spec losing its binding, so a PO has a scenario and no PNR to walk it on;
* a spec acquiring a verdict, so the set starts reporting passes the baggage flow cannot judge.

`expect.eligibility` is `null` on all 73 deliberately. That does NOT make them unseedable: since
`builder/bag_build.py` became the bag-event lane, both flow interfaces accept all 73 for building
and publishing, and both still refuse to claim a verdict for them. The pair of assertions below is
the point -- seedable and unjudgeable at once -- because the earlier version of this file asserted
the opposite and would have hidden the lane working.

Run:  python tests/test_baggage_po.py
"""
from __future__ import annotations

import json
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from adapters.file_spec_source import FileSpecSource                     # noqa: E402
from core import registry as flow_registry                               # noqa: E402
from domain.models import Scenario                                       # noqa: E402
from flows import registry as policy_registry                            # noqa: E402

SET = "baggage/sit/po"
COUNT = 73
ROOT = pathlib.Path(__file__).resolve().parent.parent
CATALOG = ROOT / "catalog" / "baggage-po.json"
#: the facts a PO checks, which Case Intake's baggage EA answers
BAG_FACTS = ("bagEventShape", "bagCount", "ahlCount", "isAhlPresent", "isClosedAhlPresent",
             "isMultipleOpenAhlPresent", "isBagDelivered", "isLastCarrierAC")
#: every environment whose PNRs were published, and what a walk needs from each
ENVS = ("INT", "BAT")
BINDING = ("pnr", "pnrId", "lastNames", "tickets", "caseNumber")

FAILED: list[str] = []


def check(label: str, got: object, want: object) -> None:
    if got != want:
        FAILED.append(label)
        print(f"  FAIL {label}: got {got!r}, wanted {want!r}")
    else:
        print(f"  ok   {label}")


def specs() -> list[dict]:
    path = FileSpecSource().set_named(SET).path
    return [json.loads(p.read_text(encoding="utf-8")) for p in sorted(path.glob("*.json"))]


def test_the_set_is_discovered() -> None:
    print("the set is discovered, and is a set of its own")
    src = FileSpecSource()
    found = {s.name: s for s in src.describe()}
    check(f"{SET} is in the tree", SET in found, True)
    check(f"{SET} holds {COUNT}", found[SET].count if SET in found else None, COUNT)
    check("its flow is baggage", found[SET].flow if SET in found else None, "baggage")
    check("its phase is sit", found[SET].phase if SET in found else None, "sit")
    check("its purpose is po", found[SET].purpose if SET in found else None, "po")
    # index() raises DuplicateCaseId, so reaching this line at all proves one id, one spec
    check("its ids are unique across the whole tree",
          sum(1 for s in src.index().values() if s == SET), COUNT)


def test_ids_are_contiguous() -> None:
    print("the ids are BAG_PO_001..073, one per file, in the kit's order")
    got = [s["id"] for s in specs()]
    check("ids", got, [f"BAG_PO_{n:03d}" for n in range(1, COUNT + 1)])
    check("every family is BAG", sorted({s["family"] for s in specs()}), ["BAG"])


def test_every_spec_loads_as_a_scenario() -> None:
    print("every spec parses into a domain Scenario with a passenger and a segment")
    scenarios = FileSpecSource().scenarios(SET)
    check("scenarios parsed", len(scenarios), COUNT)
    check("all have passengers", [s.case_id for s in scenarios if not s.passengers], [])
    check("all have segments", [s.case_id for s in scenarios if not s.segments], [])
    check("all have a summary", [s.case_id for s in scenarios if not s.summary], [])


def test_no_case_states_a_verdict() -> None:
    print("no case states a verdict, so none of them can report a pass")
    scenarios = FileSpecSource().scenarios(SET)
    check("none states a verdict",
          [s.case_id for s in scenarios if s.expectation.states_a_verdict], [])
    check("none expects to be eligible",
          [s.case_id for s in scenarios if s.expectation.expects_eligible], [])


def test_both_interfaces_accept_every_case_for_seeding() -> None:
    print("validated twice: both flow interfaces accept all 73 for seeding, and agree")
    by_spec = flow_registry.get("baggage")
    by_scenario = policy_registry.get("baggage")
    refused_dict, refused_parsed, disagreed = [], [], []
    for spec in specs():
        a = list(by_spec.validate(spec))
        b = list(by_scenario.validate(Scenario.parse(spec)))
        if a:
            refused_dict.append((spec["id"], a))
        if b:
            refused_parsed.append((spec["id"], b))
        if bool(a) != bool(b):
            disagreed.append(spec["id"])
    check("none refused by the spec-dict interface", refused_dict, [])
    check("none refused by the parsed-scenario interface", refused_parsed, [])
    check("the two interfaces agree on every case", disagreed, [])


def test_the_flow_still_cannot_claim_a_verdict() -> None:
    print("seedable is not judgeable: both interfaces still refuse to claim an answer")
    by_spec = flow_registry.get("baggage")
    by_scenario = policy_registry.get("baggage")
    check("the flow is not ready", by_spec.ready, False)
    check("it still names what it needs", bool(by_scenario.needs), True)
    check("nothing it still needs blocks seeding", list(by_scenario.blocks_seeding), [])

    spec = specs()[0]
    dict_checks = by_spec.checks(spec, [])
    check("the dict interface claims nothing",
          [(c.applies, c.ok) for c in dict_checks], [(False, None)])
    judged = by_scenario.judge(Scenario.parse(spec), [])
    check("the policy claims nothing",
          [bool(c.applies) for c in judged], [False] * len(judged))
    check("and it says why", any("row shape" in (c.detail or "") for c in judged), True)


def test_every_spec_states_its_bag_facts() -> None:
    print("every spec states the bag facts a PO checks, and keeps its provenance")
    missing_facts, missing_source = [], []
    for spec in specs():
        bag = spec.get("expectBag") or {}
        if any(k not in bag for k in BAG_FACTS):
            missing_facts.append(spec["id"])
        src = spec.get("source") or {}
        if not (src.get("case_id") and src.get("dataset") and src.get("condition")):
            missing_source.append(spec["id"])
    check("all state every bag fact", missing_facts, [])
    check("all record case_id, dataset and condition", missing_source, [])
    check("all record what the old FD-flow seed claimed",
          [s["id"] for s in specs() if not (s["source"] or {}).get("oldExpectedDds")], [])


def test_the_six_sp_cases_carry_their_sp_code() -> None:
    print("the SP code is a field, not a sentence: the six cases that have one state it")
    by_id = {s["id"]: s for s in specs()}
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    with_sp = sorted(cid for cid, row in catalog.items() if row.get("sp"))
    check("exactly six cases carry an SP code", len(with_sp), 6)
    check("the catalog and the specs agree on it",
          [cid for cid in with_sp if by_id[cid]["source"]["sp"] != catalog[cid]["sp"]], [])
    check("each SP is the one stated in the condition",
          [cid for cid in with_sp if catalog[cid]["sp"] not in catalog[cid]["condition"]], [])
    check("each SP shares its SD's numbering",
          [cid for cid in with_sp
           if catalog[cid]["sp"][3:] != (catalog[cid]["sd"] or "")[3:]], [])
    check("they are exactly the cases with no BAG rule",
          with_sp, sorted(cid for cid, row in catalog.items() if not row["rule"]))


def test_the_catalog_binds_every_case_to_both_environments() -> None:
    print("the catalog binds every case to a published PNR on INT and on BAT")
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    ids = [s["id"] for s in specs()]
    check("the catalog covers exactly the set", sorted(catalog), sorted(ids))

    unbound, incomplete, not_passed = [], [], []
    for cid, row in catalog.items():
        for env in ENVS:
            seeded = (row.get("seeded") or {}).get(env)
            if not seeded:
                unbound.append(f"{cid}/{env}")
                continue
            if any(not seeded.get(k) for k in BINDING):
                incomplete.append(f"{cid}/{env}")
            if seeded.get("result") != "PASS":
                not_passed.append(f"{cid}/{env}")
    check("every case is bound in both environments", unbound, [])
    check("every binding holds a PNR, names, tickets and a case number", incomplete, [])
    check("every binding was verified PASS", not_passed, [])

    check("every PNR is distinct within an environment",
          [env for env in ENVS
           if len({row["seeded"][env]["pnrId"] for row in catalog.values()}) != COUNT], [])
    check("the catalog agrees with the specs on the source case",
          [s["id"] for s in specs()
           if catalog[s["id"]]["source_case_id"] != s["source"]["case_id"]], [])
    check("every case is runnable now that the bag-event lane exists",
          [cid for cid, row in catalog.items() if not row["runnable"]], [])
    check("every case records both validation passes",
          [cid for cid, row in catalog.items()
           if set(row["missing"]) != {"spec_dict", "parsed_scenario"}], [])


def main() -> int:
    for fn in (test_the_set_is_discovered, test_ids_are_contiguous,
               test_every_spec_loads_as_a_scenario, test_no_case_states_a_verdict,
               test_both_interfaces_accept_every_case_for_seeding,
               test_the_flow_still_cannot_claim_a_verdict,
               test_every_spec_states_its_bag_facts, test_the_six_sp_cases_carry_their_sp_code,
               test_the_catalog_binds_every_case_to_both_environments):
        fn()
        print()
    print(f"{len(FAILED)} failed: {', '.join(FAILED)}" if FAILED else "all checks passed")
    return 1 if FAILED else 0


if __name__ == "__main__":
    raise SystemExit(main())
