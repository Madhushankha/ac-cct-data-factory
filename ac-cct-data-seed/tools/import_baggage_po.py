"""Import the 73 baggage SIT cases as BAG_PO_001..073, with the PNRs already published.

The order is the kit's own -- the order `baggage-sit-v55-cases.json` holds, which is also the row
order of both PNR tables -- so a reader comparing this set against the kit's reports, or against
the old INT seed report, sees the same order.

**Why this is a PO set and not an automation one.** Nothing here can be seeded or judged from this
project today: `flows/not_ready.py` says the baggage flow still wants a bag-event lane and a
per-bag row shape, so every case lands `runnable: false` and `expect.eligibility` is left unstated
rather than invented. What the set carries instead is a hand-walk: 73 conditions, the bag facts
Case Intake must return for each, and the PNR that is already live on INT and on BAT.

**Two expectations, and only one of them is real.** The old INT seed ran these cases through the FD
flow and pinned `NOT_ELIGIBLE / FD-BAG-NE-01 / 240 min code 64` into the classic stores for all 73
-- the same answer regardless of the bag, written by `dbadmin` rather than decided. That is kept
under `source.oldExpectedDds` as the record of what the old run claimed, and nowhere else: the kit
states plainly that its bookings do not reproduce it. The expectation a PO checks is `expectBag`,
which Case Intake's baggage EA answers as `BAG-LB-*` / `BAG-IE-*`.

The kit's own `case_to_spec.build_spec` is imported rather than copied: it reads the facts out of
each case's verified checks (bag shape, counts, closure and delivery timing, carrier, the day
offsets), and a second transcription of that regex would be a second thing to keep right.

Usage:  python tools/import_baggage_po.py
        AQA_SEED_BAGGAGE_KIT=<kit> python tools/import_baggage_po.py   # kit somewhere else
"""
from __future__ import annotations

import csv
import importlib.util
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from core import paths, registry                                            # noqa: E402
from domain.models import Scenario                                          # noqa: E402
from flows import registry as policies                                      # noqa: E402

OUT = ROOT / "spec" / "baggage" / "sit" / "po"
CATALOG = ROOT / "catalog" / "baggage-po.json"
#: the dataset the cases and their verified checks come from
DATASET = "baggage-sit-int-v55"
#: the environments whose published PNR tables are bound in, and the file each is read from
ENVS = {"INT": "INT_BAGGAGE_PNRS.csv", "BAT": "BAT_BAGGAGE_PNRS.csv"}
#: what a PO is checking, since no spec here states a verdict
EXPECTATION_FROM = ("Case Intake baggage EA at run time (BAG-LB-* / BAG-IE-*); the spec states bag "
                    "facts in expectBag and no eligibility")


def load_kit_converter(kit: pathlib.Path):
    """The kit's `baggage/case_to_spec.py`, imported as a module.

    Pure stdlib and side-effect free on import (its `main` is guarded), so importing it is safer
    than copying the hundred lines of regex that read each case's checks.
    """
    path = kit / "baggage" / "case_to_spec.py"
    spec = importlib.util.spec_from_file_location("kit_case_to_spec", path)
    if spec is None or spec.loader is None:
        raise SystemExit(f"cannot import {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def sd_of(case: dict) -> tuple[str | None, bool]:
    """The case's SD, and whether it had to be read out of the condition text.

    Six cases (`BAG_SIT_SD_03_24..28`, `BAG_SIT_SD_16_1`) carry `sd: null` and `rule: null` and
    state the SD inside the condition instead -- "SD-16.1 · SP-16.1 · S24 - claim total at or over
    the shared cap". Dropping it would leave those six with no SD at all, so it is recovered and
    the recovery is recorded in `assumed`.
    """
    if case.get("sd"):
        return case["sd"], False
    found = re.match(r"\s*(SD-\d+\.\d+)", case.get("condition") or "")
    return (found.group(1) if found else None), True


def sp_of(case: dict) -> str | None:
    """The case's SP code, where it has one.

    Six cases carry a second identifier beside the SD -- "SD-03.24 · SP-03.24 · open AHL, bag NOT
    delivered..." -- and it is stated only inside the condition text. Buried there it cannot be
    looked up, so it is lifted into a field of its own. The other 67 have none.
    """
    found = re.search(r"(SP-\d+\.\d+)", case.get("condition") or "")
    return found.group(1) if found else None


def summary_of(sd: str | None, rule: str | None, condition: str) -> str:
    """The case as the kit's own reports title it:  SD-02.1 · BAG-02 · more than one bound.

    The six cases whose SD was recovered state it at the front of the condition already, so
    prefixing it again would read "SD-16.1 · SD-16.1 · SP-16.1 · S24 - ...". Their condition alone
    is the title the old seed report gives them.
    """
    head = None if sd and condition.lstrip().startswith(sd) else sd
    return " · ".join(p for p in (head, rule, condition) if p)


def read_pnrs(kit: pathlib.Path) -> dict[str, dict[str, dict]]:
    """`case id -> env -> the published row`, for every environment in `ENVS`.

    utf-8-sig: both tables are written with a BOM, and without it the first header is `﻿env`
    and every lookup of `case` misses.
    """
    out: dict[str, dict[str, dict]] = {}
    for env, name in ENVS.items():
        with (kit / name).open(encoding="utf-8-sig", newline="") as handle:
            for row in csv.DictReader(handle):
                out.setdefault(row["case"], {})[env] = {
                    "pnr": row["pnr"],
                    "pnrId": row["pnrId"],
                    "lastNames": row["lastNames"],
                    "tickets": [t for t in row["tickets"].split(",") if t],
                    "bagShape": row["bagShape"],
                    "result": row["result"],
                    "caseNumber": row["caseNumber"],
                }
    return out


def validate_twice(spec: dict) -> tuple[dict[str, list[str]], str | None]:
    """Validate each spec through BOTH flow interfaces, and report if they disagree.

    This project carries two of them, and a spec that satisfies one is not thereby proved against
    the other:

    * `core.registry` -> `flows/pending.py`, which reads the spec dict as written on disk;
    * `flows.registry` -> `flows/not_ready.py`, which reads a parsed `domain.models.Scenario`.

    Running both also proves the file parses into a Scenario at all -- a spec that imports cleanly
    but whose passengers or segments do not survive `Scenario.parse` would pass the dict check and
    fail the moment anything real loaded it.

    Both are expected to refuse these cases while the baggage flow has no bag-event lane. What
    would be a finding is one of them NOT refusing, or the two refusing for different reasons: that
    is returned as the second value rather than quietly averaged away.
    """
    by_spec = list(registry.get("baggage").validate(spec))
    by_scenario = list(policies.get("baggage").validate(Scenario.parse(spec)))
    missing = {"spec_dict": by_spec, "parsed_scenario": by_scenario}
    disagreement = None
    if bool(by_spec) != bool(by_scenario):
        disagreement = (f"one interface refuses and the other does not: "
                        f"spec_dict={len(by_spec)} reason(s), "
                        f"parsed_scenario={len(by_scenario)} reason(s)")
    return missing, disagreement


def main(argv: list[str]) -> int:
    kit = paths.require("baggage-kit")
    converter = load_kit_converter(kit)
    cases = json.loads((kit / "baggage" / "baggage-sit-v55-cases.json").read_text(encoding="utf-8"))
    old = json.loads((kit / "baggage" / "old-seed-pax-flights.json").read_text(encoding="utf-8"))
    published = read_pnrs(kit)

    OUT.mkdir(parents=True, exist_ok=True)
    catalog: dict[str, dict] = {}
    problems: list[str] = []

    for n, case in enumerate(cases, start=1):
        src_id = case["id"]
        spec_id = f"BAG_PO_{n:03d}"
        sd, recovered = sd_of(case)
        sp = sp_of(case)
        spec = converter.build_spec(case, old[src_id])

        spec["id"] = spec_id
        spec["summary"] = summary_of(sd, case.get("rule"), case["condition"])
        spec["source"] = {
            "repo": "BAGGAGE_SIT_KIT_20261017",
            "dataset": DATASET,
            "case_id": src_id,
            "sd": sd,
            "sp": sp,
            "rule": case.get("rule"),
            "condition": case["condition"],
            "oldPnrId": case["pnrId"],
            "oldFlights": case["flights"],
            "oldRoute": case["route"],
            # kept as the record of what the old FD-flow seed claimed, not as an expectation:
            # the kit's bookings do not reproduce it
            "oldExpectedDds": case.get("expectedDds"),
            # the old run's own log lines for this case: the arrival shift that put it inside or
            # outside the 21-day window, and the bag rows it wrote with the AHL it used. That AHL
            # is the OLD one -- the kit's bookings mint their own from `bagPlan.ahlNumberSeed` --
            # so it is provenance, not something to check a live booking against.
            "seedNotes": case.get("seedNotes") or [],
        }
        spec["assumed"] = list(spec.get("assumed") or []) + [
            f"no verdict is stated: {EXPECTATION_FROM}",
        ] + ([f"sd read out of the condition text ({sd}): the case carries sd=null, rule=null"]
             if recovered else [])

        (OUT / f"{spec_id}.json").write_text(
            json.dumps(spec, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")

        missing, disagreement = validate_twice(spec)
        if disagreement:
            problems.append(f"{spec_id} ({src_id}): {disagreement}")
        seeded = published.get(src_id, {})
        catalog[spec_id] = {
            "source_case_id": src_id,
            "source_dataset": DATASET,
            "sd": sd,
            "sp": sp,
            "rule": case.get("rule"),
            "condition": case["condition"],
            "bag_shape": spec["expectBag"]["bagEventShape"],
            "expectation_from": EXPECTATION_FROM,
            "seeded": seeded,
            "runnable": not (missing["spec_dict"] or missing["parsed_scenario"]),
            # validated twice, through both flow interfaces; see validate_twice()
            "missing": missing,
        }
        for env in ENVS:
            if env not in seeded:
                problems.append(f"{spec_id} ({src_id}): no published {env} PNR")

    CATALOG.write_text(json.dumps(catalog, indent=1) + "\n", encoding="utf-8")

    runnable = sum(1 for v in catalog.values() if v["runnable"])
    print(f"wrote {len(catalog)} specs to spec/baggage/sit/po/ and catalog/baggage-po.json")
    print(f"runnable from this project: {runnable} of {len(catalog)}")
    agreed = sum(1 for v in catalog.values()
                 if bool(v["missing"]["spec_dict"]) == bool(v["missing"]["parsed_scenario"]))
    print(f"validated twice (spec dict + parsed scenario), both agree: {agreed} of {len(catalog)}")
    bound = {env: sum(1 for v in catalog.values() if env in v["seeded"]) for env in ENVS}
    print("bound to a published PNR: "
          + ", ".join(f"{env} {count}" for env, count in bound.items()))
    shapes: dict[str, int] = {}
    for v in catalog.values():
        shapes[v["bag_shape"]] = shapes.get(v["bag_shape"], 0) + 1
    print("bag shapes: " + ", ".join(f"{k} {c}" for k, c in sorted(shapes.items())))
    for p in problems:
        print(f"  ! {p}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
