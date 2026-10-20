"""The whole use case, with fakes: no Kafka, no ECS, no credential, no network.

This is what the ports are for. Every behaviour below was learned by seeding real bookings and
reading output, which took a day; here each is a few lines and runs instantly.

Run:  python tests/test_seed_pack.py
"""
from __future__ import annotations

import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from application.seed_pack import SeedPack                                  # noqa: E402
from domain.models import Assessment, Booking, CaseResult, Scenario         # noqa: E402
from flows.flight_disruption import POLICY                                  # noqa: E402

FAILED: list[str] = []


def check(label: str, got: object, want: object) -> None:
    if got != want:
        FAILED.append(label)
        print(f"  FAIL {label}: got {got!r}, wanted {want!r}")
    else:
        print(f"  ok   {label}")


# --------------------------------------------------------------------- fakes

class FakeBatch:
    def __init__(self, bookings: tuple[Booking, ...]) -> None:
        self._b = bookings
        self.failures = ()

    @property
    def bookings(self):
        return self._b

    @property
    def messages(self):
        return len(self._b) * 21

    def payloads(self):
        for b in self._b:
            yield "emh-int.ALTEA-PNRDATA-INT", "", b"{}"

    def rows(self):
        return tuple({"booking": b.pnr_id, "seq": i, "value": "{}",
                      "topic": "emh-int.ALTEA-PNRDATA-INT"} for i, b in enumerate(self._b, 1))


class FakeBuilder:
    def __init__(self) -> None:
        self.calls = 0

    def build(self, scenarios, *, env, run_day=None, **_):
        self.calls += 1
        self.seen = list(scenarios)
        return FakeBatch(tuple(
            Booking(case_id=s.case_id, locator=f"ZZ{i:04d}", pnr_id=f"ZZ{i:04d}-2026-08-21",
                    expectation=s.expectation)
            for i, s in enumerate(self.seen, 1)))


class FakePublisher:
    def __init__(self, *, accepted: bool = False) -> None:
        self.accepted = accepted
        self.published: list[bool] = []

    def validate(self, batch):
        return (True, "") if self.accepted else (False, "no parser harness on this host")

    def identities(self, batch, *, identity=None, cases=None):
        return {b.pnr_id: ("TEST", "PASSENGER") for b in batch.bookings}

    def publish(self, batch, *, dry_run: bool = True, **_):
        self.published.append(dry_run)

        class R:
            sent = 0 if dry_run else batch.messages
            failures = ()
        return R()


class FakeReader:
    """Answers from a script keyed by pnrId, so a test states what the engine said."""

    def __init__(self, answers: dict[str, dict]) -> None:
        self.answers = answers
        self.batches: list[int] = []

    def read_many(self, ids):
        self.batches.append(len(ids))
        return {i: self.answers.get(i, {}) for i in ids}

    def trip(self, pnr_id):
        return (self.answers.get(pnr_id) or {}).get("trip") or {}

    def assessment(self, pnr_id):
        row = self.answers.get(pnr_id) or {}
        return Assessment.parse(pnr_id, {**(row.get("engine") or {}),
                                         "document": row.get("document")})


class FakeStore:
    def __init__(self) -> None:
        self.cases: list[CaseResult] = []
        self.summary: tuple[str, int] | None = None

    def save_case(self, result):
        self.cases.append(result)

    def save_summary(self, label, results):
        results = tuple(results)
        self.summary = (label, len(results))
        return f"memory://{label}"


# ------------------------------------------------------------------ scenarios

def scenario(case_id: str, **expect) -> Scenario:
    base = {"eligibility": "ELIGIBLE", "systemCode": "FD-APPR-EL-01", "regime": "APPR",
            "amount": 400, "currency": "CAD", "delayMin": 240}
    base.update(expect)
    return Scenario.parse({
        "id": case_id, "family": "FD", "expect": base,
        "passengers": [{"type": "ADT", "firstName": "A", "lastName": "B"}],
        "segments": [{"seg": 1, "bound": 1, "carrier": "AC", "number": "301"}],
        "outcomes": [{"seg": 1, "kind": "delay", "arrDelayMin": 240, "delayCode": "64"}]})


def answer(*, status="ELIGIBLE", code="FD-APPR-EL-01", amount=400, currency="CAD",
           delay=240, regime="APPR", bound=1, trip_delay=240, document=True) -> dict:
    row = {"eligibilityStatus": status, "systemCode": code, "delayMinutes": delay,
           "compensationDetails": ({"amount": amount, "currency": currency}
                                   if amount is not None else None),
           "passengerName": "A B"}
    doc = ({"bounds": [{"compensationEligibility":
                        [{"regime": regime, "boundRph": bound, "passengerEligibility": [row]}]}]}
           if document else None)
    return {"trip": {"counts": {"passengers": 1, "segments": 1},
                     "segments": [{"flight": "AC301", "status": "ARRIVED",
                                   "delayMin": trip_delay}]},
            "engine": {"engine": "raptor", "engineRelease": 39}, "document": doc}


def pack(reader: FakeReader, publisher: FakePublisher | None = None):
    builder, store = FakeBuilder(), FakeStore()
    publisher = publisher or FakePublisher()
    return SeedPack(builder=builder, publisher=publisher, reader=reader, store=store,
                    policy=POLICY, env="int", log=lambda *_: None), builder, publisher, store


# --------------------------------------------------------------------- tests

def test_refuses_a_scenario_with_no_expectation() -> None:
    print("a scenario that states no verdict never reaches the builder")
    reader = FakeReader({})
    p, builder, _, _ = pack(reader)
    out = p.run([Scenario.parse({"id": "FD_TC_X", "expect": {"amount": 400}})], dry_run=True)
    check("nothing built", builder.calls, 0)
    check("refused", [c for c, _ in out.refused], ["FD_TC_X"])
    check("the reason names the field",
          any("eligibility" in w for _, why in out.refused for w in why), True)


def test_dry_run_publishes_nothing() -> None:
    print("a dry run builds and sends nothing")
    p, builder, publisher, store = pack(FakeReader({}))
    out = p.run([scenario("FD_TC_001")], dry_run=True)
    check("built", out.built, 1)
    check("published", out.published, 0)
    check("publisher told it was a dry run", publisher.published, [True])
    check("nothing judged", out.results, ())
    check("nothing stored", store.cases, [])


def test_agreement() -> None:
    print("a booking the engine agrees with")
    reader = FakeReader({"ZZ0001-2026-08-21": answer()})
    p, _, _, store = pack(reader)
    out = p.run([scenario("FD_TC_001")], dry_run=False, settle_seconds=0)
    check("published", out.published, 21)
    check("agrees", out.agree, 1)
    check("no disagreement", out.disagree, 0)
    check("stored", len(store.cases), 1)
    check("one case in the summary", store.summary[1], 1)
    check("the Trip was recorded", store.cases[0].seen["disruption_present"], True)


def test_the_five_bugs_do_not_come_back() -> None:
    print("the comparator bugs, as behaviour of the use case")
    cases = {
        # a scenario writing the short code form
        "short code": (scenario("A", systemCode="ND-X02", eligibility="NO_DETERMINATION",
                                amount=None),
                       answer(status="NO_DETERMINATION", code="FD-APPR-ND-X02", amount=None),
                       True),
        # a not-eligible row has no amount; the scenario's 0 is a placeholder
        "placeholder zero": (scenario("B", eligibility="NOT_ELIGIBLE",
                                      systemCode="FD-APPR-NE-05", amount=0),
                             answer(status="NOT_ELIGIBLE", code="FD-APPR-NE-05", amount=None),
                             True),
        # a band written as prose is not comparable
        "prose band": (scenario("C", delayBand="APPR_3_TO_6_HOURS"), answer(), True),
        # a real code difference still fails
        "NE-01 vs NE-28": (scenario("D", eligibility="NOT_ELIGIBLE", systemCode="NE-01",
                                    amount=0),
                           answer(status="NOT_ELIGIBLE", code="FD-APPR-NE-28", amount=None),
                           False),
        # a real amount difference still fails
        "400 vs 1000": (scenario("E"), answer(amount=1000), False),
    }
    for name, (sc, ans, expected_agreement) in cases.items():
        reader = FakeReader({"ZZ0001-2026-08-21": ans})
        p, _, _, _ = pack(reader)
        out = p.run([sc], dry_run=False, settle_seconds=0)
        check(f"{name} -> {'agrees' if expected_agreement else 'disagrees'}",
              out.agree == 1, expected_agreement)


def test_missing_regime_is_its_own_finding() -> None:
    print("a regime the engine did not assess is reported as that")
    reader = FakeReader({"ZZ0001-2026-08-21": answer(regime="APPR", code="FD-APPR-ND-03",
                                                     status="NO_DETERMINATION", amount=None)})
    p, _, _, store = pack(reader)
    out = p.run([scenario("FD_TC_118", regime="EU", systemCode="FD-EU-EL-10")],
                dry_run=False, settle_seconds=0)
    names = [c.name for c in store.cases[0].disagreements]
    check("the regime is the finding", names, ["fd_regime"])
    check("the fields are not compared against the wrong row",
          all(c.applies is False for c in store.cases[0].checks
              if c.name in ("fd_systemCode", "fd_amount", "fd_eligibility")), True)


def test_no_assessment_is_not_a_failure() -> None:
    print("a booking with no assessment yet")
    reader = FakeReader({"ZZ0001-2026-08-21": answer(document=False)})
    p, _, _, store = pack(reader)
    out = p.run([scenario("FD_TC_001")], dry_run=False, settle_seconds=0)
    check("not judged", out.not_judged, 1)
    check("not counted as agreeing", out.agree, 0)
    check("not counted as disagreeing", out.disagree, 0)
    # by name, not by position: the Trip checks now come first in the tuple
    check("says why", any("no verdict" in c.detail for c in store.cases[0].checks), True)


def test_reads_are_batched() -> None:
    print("reads are batched, because a task is mostly container startup")
    ids = {f"ZZ{i:04d}-2026-08-21": answer() for i in range(1, 8)}
    reader = FakeReader(ids)
    p, _, _, _ = pack(reader)
    p.read_batch = 3
    p.run([scenario(f"FD_TC_{i:03d}") for i in range(1, 8)], dry_run=False, settle_seconds=0)
    check("7 bookings in batches of 3", reader.batches, [3, 3, 1])


def test_unvalidated_publish_is_reported() -> None:
    print("a publish without the parser check says so")
    p, _, _, _ = pack(FakeReader({"ZZ0001-2026-08-21": answer()}))
    out = p.run([scenario("FD_TC_001")], dry_run=False, settle_seconds=0)
    check("not validated", out.validated, False)
    check("the note survives into the outcome", "parser harness" in out.validation_note, True)
    check("and into the description",
          any("NOT validated" in line for line in out.describe()), True)


def main() -> int:
    for fn in (test_refuses_a_scenario_with_no_expectation, test_dry_run_publishes_nothing,
               test_agreement, test_the_five_bugs_do_not_come_back,
               test_missing_regime_is_its_own_finding, test_no_assessment_is_not_a_failure,
               test_reads_are_batched, test_unvalidated_publish_is_reported):
        fn()
        print()
    print(f"{len(FAILED)} failed: {', '.join(FAILED)}" if FAILED else "all checks passed")
    return 1 if FAILED else 0


if __name__ == "__main__":
    raise SystemExit(main())


def test_a_stored_expectation_survives_being_read_back():
    """`cli judge` reads the expectation a run wrote. Losing a field there invents agreement.

    The record stores the PARSED expectation (`delay: {value: 240}`), and parsing that through the
    manifest's keys (`delayMin`) produced an expectation that stated only regime and eligibility:
    every other check reported "the scenario states no ..." and passed. Twenty cases of the 19 Oct
    INT run agreed that way, including collisions where the engine held 480 minutes against the
    240 we published.
    """
    from adapters.file_run_store import _plain
    from domain.models import Expectation

    original = Expectation.parse({
        "regime": "APPR", "eligibility": "ELIGIBLE", "systemCode": "FD-APPR-EL-01",
        "amount": 400, "currency": "CAD", "delayMin": 240,
        "delayBand": "DELAY_3_TO_LT_6_HOURS", "control": "CONTROLLABLE", "cause": "42",
    })
    again = Expectation.parse(_plain(original))

    assert again.delay.value == 240
    assert again.money.amount == 400
    assert again.money.currency == "CAD"
    assert again.band.value == "DELAY_3_TO_LT_6_HOURS"
    assert again.system_code is not None and again.system_code.raw == "FD-APPR-EL-01"
    assert again.control == "CONTROLLABLE" and again.cause == "42"
    assert again == original, "a stored expectation must read back as the same expectation"
