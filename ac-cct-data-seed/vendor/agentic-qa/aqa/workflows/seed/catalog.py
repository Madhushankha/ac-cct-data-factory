"""Load one FD case from the local scenario fixtures + the imported catalogue.

Case ids are canonical (FD_UAT_001 / FD_SIT_001, see ids.py); FD_TC_001 / FD-SIT-001 are accepted.

Scenario JSON (schema v2) lives in fixtures/fd-<suite>/ beside this module, together with
the PNR mapping and testing-guide markdown. It supplies passengers, segments, ticketing and
the case title. The expected verdict (status, systemCode, amount) is not in the scenario
file; it comes from the aqa catalogue table `catalog_cases` (gap-doc import) with a
title-parse fallback.
"""
from __future__ import annotations

import json
import os
import re
import sqlite3
from dataclasses import dataclass, field
from pathlib import Path

from .ids import canonical, source

FIXTURES = Path(__file__).resolve().parent / "fixtures"

SUITE_DIRS = {"uat": "fd-uat", "sit": "fd-sit", "automation": "fd-automation"}   # automation: built from Jira tests      # kept: FD is what an unqualified caller means
# a fixture file is named after its case, so the prefix tells us which files belong to a flow
FLOW_PREFIX = {"fd": "FD_", "baggage": "BAG_", "soc": "SOC_"}


def suite_dir(suite: str, flow: str = "fd") -> Path:
    return FIXTURES / f"{flow}-{suite}"

APPR_BANDS = [  # (min_minutes, max_minutes, amount, delayBand literal verified in kb dds-output-schema)
    (180, 360, 400, "DELAY_3_TO_LT_6_HOURS"),
    (360, 540, 700, "DELAY_6_TO_LT_9_HOURS"),
    (540, 10 ** 6, 1000, "DELAY_GTE_9_HOURS"),
]


@dataclass
class Expected:
    status: str = "ELIGIBLE"          # ELIGIBLE | NOT_ELIGIBLE | NO_DETERMINATION | PENDING
    system_code: str = "FD-APPR-EL-01"
    regime: str = "APPR"
    amount: float | None = 400.0
    currency: str = "CAD"
    delay_minutes: int = 240
    delay_band: str = "DELAY_3_TO_LT_6_HOURS"
    delay_type: str = "CONTROLLABLE"
    # 64 (operational requirements), not 43. The rule engine's delay_safety_codes_lookup holds 43,
    # so pairing it with CONTROLLABLE was a contradiction the document carried on 195 of 247 cases:
    # APPR pays nothing for a safety-required delay, so an ELIGIBLE APPR verdict cannot come from
    # code 43. 64 is in delay_controllable_codes_lookup and agrees with delay_type above.
    delay_code: str = "64"
    # Left deliberately empty: the reason belongs to the SYSTEM CODE, and verdicts.reason_for reads
    # it from the rule engine's own table. A default sentence here is how every refusal came to
    # carry "arrival delay 3 to less than 6 hours, within carrier control" -- which describes an
    # ELIGIBLE outcome.
    reason: str = ""
    source: str = "title"            # gapdoc | catalog | title  (where the verdict came from)
    pre_travel: bool = False         # gap doc says the flight is in the future: no DDS verdict is served
    route: str | None = None         # gap-doc INT test-data route, for the booking-shape check


@dataclass
class SeedCase:
    case_id: str
    suite: str
    title: str
    scenario: dict
    expected: Expected
    source_file: str
    tags: list[str] = field(default_factory=list)


def _scenario_index(suite: str, flow: str = "fd") -> dict[str, Path]:
    """case_id (gap-doc number) -> fixture file. Files are named after the case (casemap.py sync)."""
    d = suite_dir(suite, flow)
    out: dict[str, Path] = {}
    for p in sorted(d.glob(f"{FLOW_PREFIX.get(flow, flow.upper() + '_')}*.json")):
        out[canonical(p.stem)] = p
    return out


def _fixture_by_id(suite: str, fixture_id: str, flow: str = "fd") -> Path | None:
    """A package fixture the doc does not know, parked under _extra/ (ZFU010)."""
    p = suite_dir(suite, flow) / "_extra" / f"{fixture_id.upper()}.json"
    return p if p.exists() else None


def _expected_from_catalog(case_id: str, suite: str, db_path: str | None) -> Expected | None:
    db = db_path or os.environ.get("AQA_DB", "./data/aqa.db")
    if not Path(db).exists():
        return None
    con = sqlite3.connect(db)
    try:
        row = con.execute("select verdict, system_code, title from catalog_cases where flow='fd' and suite=? "
                          "and case_id in (?, ?)", (suite, source(case_id), canonical(case_id))).fetchone()
    finally:
        con.close()
    if not row:
        return None
    verdict, code, title = row
    exp = _expected_from_title(title or "")
    if verdict:
        v = verdict.upper().replace(" ", "_")
        exp.status = {"ELIGIBLE": "ELIGIBLE", "NOT_ELIGIBLE": "NOT_ELIGIBLE", "NOT ELIGIBLE": "NOT_ELIGIBLE",
                      "NO_DETERMINATION": "NO_DETERMINATION", "PENDING": "PENDING"}.get(v, exp.status)
    if code and code.startswith("FD-"):
        exp.system_code = code
        exp.regime = code.split("-")[1]
    if exp.status != "ELIGIBLE":
        exp.amount = None
    return exp


def _band_for(minutes: int | None) -> str:
    for lo, hi, _amt, band in APPR_BANDS:
        if minutes is not None and lo <= minutes < hi:
            return band
    return "NOT_APPLICABLE"


def _expected_from_gapdoc(case_id: str, suite: str, title: str, flow: str = "fd") -> Expected | None:
    """The gap-analysis doc is the source of truth; see gapdoc.py."""
    from .gapdoc import load
    g = load(suite, flow).get(canonical(case_id))
    if not g:
        return None
    exp = _expected_from_title(title)
    status = g.get("status")
    # process cases (fraud, duplicate, routing, outage...) carry no verdict: the booking is an eligible
    # APPR shell so the flow can reach the step under test
    exp.source = "gapdoc" if status else "gapdoc-process"
    if status == "PRE_TRAVEL":          # built as an eligible shell (HOWTO §7 "Forced TC063")
        exp.pre_travel, status = True, "ELIGIBLE"
    if status:
        exp.status = status
    if g.get("system_code"):
        exp.system_code = g["system_code"]
        exp.regime = g["system_code"].split("-")[1]
    elif g.get("regime") or exp.status != "ELIGIBLE":
        exp.system_code = f"FD-{g.get('regime') or exp.regime}-{ {'NOT_ELIGIBLE': 'NE', 'NO_DETERMINATION': 'ND', 'PENDING': 'PE'}.get(exp.status, 'EL') }-01"
    if g.get("regime"):
        exp.regime = g["regime"]
    if g.get("delay_minutes"):
        exp.delay_minutes = int(g["delay_minutes"])
    exp.delay_band = g.get("delay_band") or _band_for(exp.delay_minutes)
    if g.get("delay_code"):
        exp.delay_code = str(g["delay_code"])
    # The CODE decides controllability, not the title's wording. `_expected_from_title` guesses from
    # words like "weather", and a card that states code 81 (uncontrollable) under a title that says
    # neither produced a document claiming a controllable delay on an uncontrollable code.
    from .verdicts import delay_controllability
    exp.delay_type = delay_controllability(exp.delay_code) or exp.delay_type
    if g.get("amount") is not None:
        exp.amount = float(g["amount"])
        if g.get("currency"):
            exp.currency = g["currency"]
    if exp.status != "ELIGIBLE":
        exp.amount = None
    exp.route = g.get("route")
    return exp


def _expected_from_title(title: str) -> Expected:
    t = title.lower()
    exp = Expected()
    m = re.search(r"delay\s*(\d+)\s*[–-]\s*<?\s*(\d+)", t)
    if m:
        lo = int(m.group(1)) * 60
        exp.delay_minutes = lo + 60
    elif re.search(r"9\s*\+?\s*hr|9hr\+|>=\s*9", t):
        exp.delay_minutes = 600
    for lo, hi, amt, band in APPR_BANDS:
        if lo <= exp.delay_minutes < hi:
            exp.amount, exp.delay_band = float(amt), band
    if "uncontrollable" in t or "weather" in t:
        exp.delay_type, exp.delay_code = "UNCONTROLLABLE", "71"
    if "not eligible" in t or "ineligible" in t:
        exp.status, exp.amount, exp.system_code = "NOT_ELIGIBLE", None, "FD-APPR-NE-01"
    if "no determination" in t:
        exp.status, exp.amount, exp.system_code = "NO_DETERMINATION", None, "FD-APPR-ND-01"
    if "pending" in t or "welcome back" in t:
        exp.status, exp.amount, exp.system_code = "PENDING", None, "FD-APPR-PE-01"
    return exp


def load_case(case_id: str, suite: str = "uat", *, db_path: str | None = None,
              flow: str = "fd") -> SeedCase:
    """case_id is a gap-doc case (FD_UAT_010) or a fixture id (ZFU011) for an unbound template."""
    idx = _scenario_index(suite, flow)
    prefix = FLOW_PREFIX.get(flow, flow.upper() + "_")
    # An unbound template is loaded as "WAL001" but recorded as "FD_UAT_X_WAL001"; a dataset replays
    # the recorded id, so that form has to resolve back to the same fixture.
    m = re.match(rf"^{re.escape(prefix)}(?:UAT|SIT|GEN)_X_(.+)$", case_id, re.I)
    if m:
        case_id = m.group(1)
    fx = _fixture_by_id(suite, case_id, flow) if not case_id.upper().startswith(prefix) else None
    if fx is not None:
        path = fx
        case_id = f"{prefix}{suite.upper()}_X_{case_id.upper()}"   # unbound template: no gap-doc number
    else:
        case_id = canonical(case_id)
        if case_id not in idx:
            from .casemap import load as load_map
            st = (load_map(suite, flow).get(case_id) or {}).get("status")
            why = "has no fixture yet (run `python -m aqa.workflows.seed.casemap sync`)" if st == "missing" else "is not a known case"
            raise SystemExit(f"{case_id} {why}; {len(idx)} seedable {suite} cases")
        path = idx[case_id]
    scenario = json.loads(path.read_text(encoding="utf-8"))
    title = scenario.get("description") or scenario.get("title", "")
    stated = scenario.get("expected")
    if isinstance(stated, dict) and stated.get("status"):
        # the fixture says what it expects; nothing is inferred from its wording
        expected = Expected(**{k: v for k, v in stated.items() if k in Expected.__dataclass_fields__})
        expected.source = "fixture"
        # `summary` is the one-line form for a table; `description` is free to be a paragraph
        return SeedCase(case_id=case_id, suite=suite,
                        title=(scenario.get("summary") or scenario.get("title")
                               or scenario.get("description", "")),
                        scenario=scenario, expected=expected, source_file=str(path),
                        tags=scenario.get("tags", []))
    expected = _expected_from_gapdoc(case_id, suite, title, flow)
    if expected is None:
        expected = _expected_from_catalog(case_id, suite, db_path)
        if expected is not None:
            expected.source = "catalog"
    if expected is None:
        expected = _expected_from_title(title)
    title = scenario.get("description") or re.sub(r"^\S+:\s*", "", scenario.get("title", ""))
    return SeedCase(case_id=case_id, suite=suite, title=title,
                    scenario=scenario, expected=expected, source_file=str(path), tags=scenario.get("tags", []))


def list_cases(suite: str = "uat", flow: str = "fd") -> list[str]:
    return sorted(_scenario_index(suite, flow))
