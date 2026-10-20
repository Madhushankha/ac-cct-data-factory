"""The domain, tested without a network, an environment or a credential.

Every case here is one that cost real time to find by seeding bookings and reading output. They run
in milliseconds now, which is the point of having types: the five comparator bugs were all findable
at this level and none of them was found here, because this level did not exist.

Run:  python tests/test_domain.py
"""
from __future__ import annotations

import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from domain.models import (Assessment, Booking, Check, Expectation, Scenario)       # noqa: E402
from domain.values import DelayBand, Eligibility, Minutes, Money, SystemCode        # noqa: E402

FAILED: list[str] = []


def check(label: str, got: object, want: object) -> None:
    if got != want:
        FAILED.append(label)
        print(f"  FAIL {label}: got {got!r}, wanted {want!r}")
    else:
        print(f"  ok   {label}")


def test_system_code() -> None:
    print("system codes: the two sides spell them differently")
    full = SystemCode.parse("FD-APPR-ND-X02")
    short = SystemCode.parse("ND-X02")
    check("full parses its regime", (full.regime, full.suffix), ("APPR", "ND-X02"))
    check("short has no regime", (short.regime, short.suffix), (None, "ND-X02"))
    check("short matches full (FD_TC_100)", short.matches(full), True)
    check("full matches short", full.matches(short), True)
    # the real difference the review corrects five times: NE-01 means an employee booking
    check("NE-01 does not match NE-28",
          SystemCode.parse("NE-01").matches(SystemCode.parse("FD-APPR-NE-28")), False)
    check("APPR does not match EU",
          SystemCode.parse("FD-APPR-EL-01").matches(SystemCode.parse("FD-EU-EL-01")), False)
    # a band or a label in the code field is not a code at all
    check("a band is not a code", SystemCode.parse("APPR_3_TO_6_HOURS").is_code, False)
    check("a label is not a code",
          SystemCode.parse("NON_FLIGHT_SEGMENT_DISRUPTION").is_code, False)
    check("a non-code never matches",
          SystemCode.parse("APPR_3_TO_6_HOURS").matches(SystemCode.parse("FD-APPR-EL-01")), False)
    check("absent parses to None", SystemCode.parse(None), None)


def test_money() -> None:
    print("money: absent is not zero")
    absent, placeholder = Money.of(None, None), Money.of(0, "CAD")
    real = Money.of(400, "CAD")
    check("not eligible: absent == placeholder zero",
          absent.equivalent_to(placeholder, eligible=False), True)
    check("eligible: absent != a real figure", absent.equivalent_to(real, eligible=True), False)
    check("eligible: equal figures agree", real.equivalent_to(Money.of(400, "CAD"), eligible=True), True)
    check("eligible: different figures differ",
          real.equivalent_to(Money.of(1000, "CAD"), eligible=True), False)
    check("currency compared when both state one",
          real.equivalent_to(Money.of(400, "EUR"), eligible=True), False)
    check("a non-numeric amount is absent", Money.of("n/a", "CAD").amount, None)
    check("renders readably", str(real), "400 CAD")


def test_band_and_minutes() -> None:
    print("bands label, minutes are the fact")
    check("the engine's band is comparable", DelayBand("DELAY_3_TO_LT_6_HOURS").is_engine_vocabulary, True)
    for prose in ("APPR_3_TO_6_HOURS", "BELOW_THRESHOLD_POST_REPROTECTION",
                  "EU261_TRAVEL_COMPLETED_REST_OF_EUROPE_3_TO_4HR", "DELAY_9_HOURS_PLUS"):
        check(f"{prose[:34]} is not", DelayBand(prose).is_engine_vocabulary, False)
    check("absent is not comparable", DelayBand(None).is_engine_vocabulary, False)
    check("240 equals 240", Minutes.of(240).equals(Minutes.of(240)), True)
    check("absent never equals zero", Minutes.of(None).equals(Minutes.of(0)), False)
    check("a string of digits parses", Minutes.of("420").value, 420)


def test_expectation() -> None:
    print("expectation: a scenario that claims nothing cannot pass")
    check("no eligibility means no verdict", Expectation.parse({}).states_a_verdict, False)
    check("the 41 table cases (inputs only)",
          Expectation.parse({"amount": 400, "delayMin": 240}).states_a_verdict, False)
    e = Expectation.parse({"regime": "APPR", "eligibility": "ELIGIBLE",
                           "systemCode": "FD-APPR-EL-01", "amount": 400, "currency": "CAD",
                           "delayMin": 240, "delayBand": "DELAY_3_TO_LT_6_HOURS",
                           "control": "CONTROLLABLE", "cause": "64", "noTravel": True})
    check("states a verdict", e.states_a_verdict, True)
    check("expects eligible", e.expects_eligible, True)
    check("code parsed", str(e.system_code), "FD-APPR-EL-01")
    check("cause kept as text", e.cause, "64")
    check("unknown keys land in extras", e.extras, {"noTravel": True})
    check("ttUi is not an extra", "ttUi" in Expectation.parse({"ttUi": ["x"]}).extras, False)


def test_assessment_shapes() -> None:
    print("assessment: tt-api nests under bounds, case-services flattens")
    row = {"passengerEligibility": [{"eligibilityStatus": "ELIGIBLE"}], "regime": "APPR"}
    meta = {"engine": "raptor", "engineRelease": 39, "rulesSha256": "abc"}
    flat = Assessment.parse("P", {**meta, "document": {"compensationEligibility": [row]}})
    nested = Assessment.parse("P", {**meta, "document": {"bounds": [{"compensationEligibility": [row]}]}})
    check("flat shape reads", len(list(flat.blocks("compensationEligibility"))), 1)
    check("bounds shape reads", len(list(nested.blocks("compensationEligibility"))), 1)
    check("engine recorded", (flat.engine, flat.release), ("raptor", 39))
    check("a null document is an answer, not a failure",
          Assessment.parse("P", {"document": None}).has_answer, False)
    check("a missing section yields nothing",
          list(flat.blocks("socFlightEligibility")), [])


def test_scenario_and_checks() -> None:
    print("scenario and checks")
    s = Scenario.parse({
        "id": "FD_TC_001", "family": "FD",
        "passengers": [{"type": "ADT", "firstName": "CATHERINE", "lastName": "BOUCHARD",
                        "aeroplanNumber": "9876543210", "aeroplanTier": "Basic"}],
        "segments": [{"seg": 1, "bound": 1, "carrier": "AC", "number": "301", "origin": "YUL",
                      "destination": "YYZ", "depDate": "2026-09-20"}],
        "outcomes": [{"seg": 1, "kind": "delay", "arrDelayMin": 240, "delayCode": "64"}],
        "expect": {"eligibility": "ELIGIBLE", "systemCode": "FD-APPR-EL-01"}})
    check("case id", s.case_id, "FD_TC_001")
    check("passenger name", s.passengers[0].full_name, "CATHERINE BOUCHARD")
    check("aeroplan carried", s.passengers[0].aeroplan_tier, "Basic")
    check("flight key", s.segments[0].flight_key, "AC#301#2026-09-20#YUL")
    check("has a disruption", s.has_disruption, True)
    check("no outcome means none",
          Scenario.parse({"id": "X", "expect": {}}).has_disruption, False)

    check("n/a is not a pass", Check.na("x", "why").ok, None)
    check("n/a does not disagree", Check.na("x", "why").disagrees, False)
    check("a failed check disagrees", Check.of("x", False, "d").disagrees, True)
    check("eligible is case-insensitive", Eligibility.is_eligible("eligible"), True)


def test_booking_from_manifest() -> None:
    print("booking, from a builder manifest row")
    b = Booking.from_manifest({
        "id": "FD_TC_001", "locator": "ZZSIF8", "pnrId": "ZZSIF8-2026-08-21",
        "expect": {"eligibility": "ELIGIBLE"},
        "flights": [{"carrier": "AC", "number": "301", "origin": "YUL",
                     "destination": "YYZ", "depUtc": "2026-09-20T16:40:00Z"}]})
    check("locator", b.locator, "ZZSIF8")
    check("pnrId", b.pnr_id, "ZZSIF8-2026-08-21")
    check("flight", b.flight, "AC301")
    check("route", b.route, "YUL-YYZ")
    check("flight date", b.flight_date, "2026-09-20")
    check("expectation parsed", b.expectation.expects_eligible, True)


def main() -> int:
    for fn in (test_system_code, test_money, test_band_and_minutes, test_expectation,
               test_assessment_shapes, test_scenario_and_checks, test_booking_from_manifest):
        fn()
        print()
    print(f"{len(FAILED)} failed" if FAILED else "all checks passed")
    return 1 if FAILED else 0


if __name__ == "__main__":
    raise SystemExit(main())
