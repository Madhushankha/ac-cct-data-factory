"""What the rule engine knows about a verdict code and a delay code.

A seeded DDS document asserts three things it was previously free to invent: why the claim was
refused, whether the delay was the carrier's fault, and what caused it. All three are decided by
lookup tables the rule engine owns, so the seed reads them rather than guessing:

* `FD_{APPR,EU,ASL}_reason_codes_lookup` — the reason behind each system code ("Employee booking
  AC"). Every seeded case used to carry one hardcoded sentence instead, *"arrival delay 3 to less
  than 6 hours, within carrier control"* — which is the description of an ELIGIBLE APPR outcome, so
  244 of 247 cases printed an eligibility reason on a refusal.
* `delay_{controllable,uncontrollable,safety}_codes_lookup` — a delay code is exactly one of the
  three. Code 43 is SAFETY, and the seeder's own default paired it with `delay_type: CONTROLLABLE`
  on 195 cases: APPR pays nothing for a safety delay, so those cases claimed a verdict their own
  delay code forbids.
* `delay_disruption_reason_lookup` / `delay_customer_friendly_reason_lookup` — the cause, and how it
  is said to the customer. `build_dds` hardcoded "CREW"/"WEATHER" and "Your flight was delayed.",
  which is how a case could refuse a claim as outside our control and then name a maintenance issue.

The snapshot beside this module is captured from the rule-engine repo rather than fetched, so the
seeder has no runtime dependency on a sibling checkout; `_captured` says when.
"""
from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path

SNAPSHOT = Path(__file__).resolve().parent / "fixtures" / "feeds" / "fd_reference.json"

# Star Alliance, as case-intake holds it. Used to decide whether a carrier makes a segment a Star
# segment, another airline's, or Air Canada's own.
STAR_ALLIANCE = {"A3", "AC", "AV", "BR", "CA", "CM", "ET", "JP", "LH", "LO", "LX", "NH", "NZ",
                 "OS", "OU", "SK", "SN", "SQ", "TG", "TK", "TP", "UA"}

# Codes whose meaning names a carrier: seeding one on an itinerary that does not carry that kind of
# leg produces a document the rule engine could not have produced.
CARRIER_CODES = {
    "FD-APPR-ND-01": "OAL", "FD-EU-ND-01": "OAL", "FD-ASL-ND-01": "OAL",
    "FD-APPR-ND-02": "STAR", "FD-EU-ND-02": "STAR", "FD-ASL-ND-02": "STAR",
    "FD-APPR-NE-05": "OAL_ONLY", "FD-EU-NE-04": "OAL_ONLY", "FD-ASL-NE-05": "OAL_ONLY",
    "FD-APPR-ND-06": "OAL", "FD-EU-ND-06": "OAL", "FD-ASL-ND-06": "OAL",
}


@lru_cache(maxsize=1)
def _snap() -> dict:
    return json.loads(SNAPSHOT.read_text(encoding="utf-8"))


def employee_codes() -> set[str]:
    """The system codes whose own reason says the booking was an employee one."""
    return {k for k, v in _snap()["reason_by_code"].items() if "employee booking" in v.lower()}


def employee_marker(office_id: str | None, keywords=()) -> str | None:
    """What marks this booking as employee travel, or None.

    The rule engine reads three tables and nothing else: `employee_office_id_suffixes_lookup` and
    `employee_travel_suffixes_lookup` (ES, OT, EP, EE, EC) and `employee_special_keywords_lookup`
    (STDP, STFD, STFS). A seeded "Employee booking" case carried none of them -- its office id ended
    `AA` like every other case -- so the only thing separating it from an ordinary refusal was the
    verdict we pinned ourselves.
    """
    snap = _snap()
    tail = (office_id or "").strip().upper()[-2:]
    if tail in snap["employee_office_suffixes"]:
        return f"office id ends {tail} ({snap['employee_office_suffixes'][tail]})"
    for k in keywords:
        k = str(k or "").strip().upper()
        if k in snap["employee_keywords"]:
            return f"keyword {k} ({snap['employee_keywords'][k]})"
    return None


def reason_for(system_code: str) -> str | None:
    """The rule engine's own reason for this system code, or None if it does not hold one."""
    return _snap()["reason_by_code"].get((system_code or "").strip())


def delay_controllability(code: str | int | None) -> str | None:
    """CONTROLLABLE | UNCONTROLLABLE | SAFETY, or None when the tables do not hold the code."""
    c = str(code or "").strip()
    snap = _snap()
    for name, label in (("delay_controllable", "CONTROLLABLE"),
                        ("delay_uncontrollable", "UNCONTROLLABLE"),
                        ("delay_safety", "SAFETY")):
        if c in snap[name]:
            return label
    return None


def disruption_reason(code: str | int | None) -> str | None:
    """The cause category the rule engine derives from the delay code (MECHANICAL, CREW, ...)."""
    return _snap()["delay_disruption_reason"].get(str(code or "").strip())


def customer_text(code: str | int | None) -> str | None:
    """How the cause is said to the customer, in the rule engine's own words."""
    return _snap()["delay_customer_text"].get(str(code or "").strip())


def carrier_type(carrier: str | None) -> str:
    """AC | STAR | OAL for one carrier code."""
    c = (carrier or "").upper()
    return "AC" if c == "AC" else ("STAR" if c in STAR_ALLIANCE else "OAL")


def carrier_fits_code(system_code: str, carriers: list[str]) -> tuple[bool, str]:
    """Does the itinerary carry the kind of leg this system code names?

    `carriers` is the operating carrier of every segment, in order; the last one is the most
    significant leg for the codes that name one. Returns (ok, why) — ok is True for any code that
    names no carrier, so this only ever fails on a code that does.
    """
    want = CARRIER_CODES.get((system_code or "").strip())
    if not want:
        return True, "this code names no carrier"
    kinds = [carrier_type(c) for c in carriers]
    if want == "OAL_ONLY":
        ok = bool(kinds) and all(k == "OAL" for k in kinds)
        return ok, f"every leg must be another airline's; got {carriers}"
    ok = bool(kinds) and kinds[-1] == want
    return ok, f"the most significant leg must be {want}; got {carriers[-1] if carriers else '—'}"
