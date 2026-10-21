"""One Mailinator inbox per booking: the address, the publisher's rewrite, and the pool entry.

No Kafka and no network: the publisher is exercised through `emails` and `_rewrite`, which decide
what goes out, and the pool through a temporary directory.

Run:  python tests/test_inbox_per_case.py
"""
from __future__ import annotations

import pathlib
import sys
import tempfile

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

import yaml                                                                  # noqa: E402

from adapters.kafka_publisher import Identity, KafkaPublisher, case_inbox   # noqa: E402
from adapters.pool_file import PoolFileSink                                 # noqa: E402
from domain.models import Booking, Expectation                              # noqa: E402

FAILED: list[str] = []


def check(label: str, got: object, want: object) -> None:
    if got != want:
        FAILED.append(label)
        print(f"  FAIL {label}: got {got!r}, wanted {want!r}")
    else:
        print(f"  ok   {label}")


NAMES = '{"names": [{"firstName": "SIENA", "lastName": "PERBARPAV"}]}'


class Batch:
    """Two bookings with a passenger, and one FDM row (a flight key, no passenger)."""
    def rows(self):
        return ({"booking": "ZZ0001-2026-08-21", "seq": 1, "value": NAMES},
                {"booking": "ZZ0002-2026-08-21", "seq": 2, "value": NAMES},
                {"booking": "AC#422#2026-10-07#YUL", "seq": 3, "value": "{}"})


class Env:
    contact_email = "lahiru@ae-qa1-aircanada.mailinator.com"
    contact_phone = "+123456789"


def publisher() -> KafkaPublisher:
    p = KafkaPublisher("int", log=lambda *_: None)
    p._env = Env()                       # no agentic-qa needed: the env only supplies defaults
    return p


def test_address() -> None:
    print("the address")
    check("case id and tag, lower-case, dashes",
          case_inbox("BAG_PO_001", "1020T1531"),
          "lahiru-bag-po-001-1020t1531@ae-qa1-aircanada.mailinator.com")
    check("a '#n' case suffix and odd characters collapse to single dashes",
          case_inbox("SOC_UAT_076__CHAI-31991#2", "1020T1531"),
          "lahiru-soc-uat-076-chai-31991-2-1020t1531@ae-qa1-aircanada.mailinator.com")
    check("the inbox name stays short enough for Mailinator",
          len(case_inbox("X" * 200, "T").partition("@")[0]) <= 60, True)


def test_publisher() -> None:
    print("the publisher")
    p, cases = publisher(), {"ZZ0001-2026-08-21": "BAG_PO_001", "ZZ0002-2026-08-21": "BAG_PO_002"}
    check("no tag: no per-booking addresses (the shared contact stays the default)",
          p.emails(Batch(), identity=Identity(), cases=cases), {})
    got = p.emails(Batch(), identity=Identity(inbox_tag="1020T1531"), cases=cases)
    check("a tag gives every passenger booking its own address, and skips the FDM row", got, {
        "ZZ0001-2026-08-21": "lahiru-bag-po-001-1020t1531@ae-qa1-aircanada.mailinator.com",
        "ZZ0002-2026-08-21": "lahiru-bag-po-002-1020t1531@ae-qa1-aircanada.mailinator.com"})
    text = '{"email": "synth-1@synth.test"}'
    check("the booking's own address replaces the synthetic contact",
          p._rewrite(text, Identity(email="other@x.mailinator.com"), None, None,
                     got["ZZ0001-2026-08-21"]),
          '{"email": "lahiru-bag-po-001-1020t1531@ae-qa1-aircanada.mailinator.com"}')
    check("without one, the shared contact still goes out",
          p._rewrite(text, Identity(), None, None, None),
          '{"email": "lahiru@ae-qa1-aircanada.mailinator.com"}')


def test_pool() -> None:
    print("the pool")
    b1 = Booking(case_id="BAG_PO_001", locator="ZZ0001", pnr_id="ZZ0001-2026-08-21",
                 expectation=Expectation.parse(None))
    b2 = Booking(case_id="BAG_PO_002", locator="ZZ0002", pnr_id="ZZ0002-2026-08-21",
                 expectation=Expectation.parse(None))
    own = "lahiru-bag-po-001-1020t1531@ae-qa1-aircanada.mailinator.com"
    with tempfile.TemporaryDirectory() as d:
        path = PoolFileSink(pathlib.Path(d), log=lambda *_: None).hand_off(
            "t", [b1, b2], names={b1.pnr_id: ("SIENA", "X"), b2.pnr_id: ("LEILA", "Y")},
            emails={b1.pnr_id: own})
        pool = yaml.safe_load(pathlib.Path(path).read_text(encoding="utf-8"))["pools"]["t"]
    rows = {r["caseId"]: r for r in pool["bookings"]}
    check("the pool keeps the shared inbox as its default",
          pool["otp"], {"provider": "mailinator", "domain": "ae-qa1-aircanada.mailinator.com",
                        "inbox": "lahiru"})
    check("a booking with its own inbox records the address", rows["BAG_PO_001"].get("email"), own)
    check("and an otp the suite reads as its own, without the queue", rows["BAG_PO_001"].get("otp"),
          {"provider": "mailinator", "domain": "ae-qa1-aircanada.mailinator.com",
           "inbox": "lahiru-bag-po-001-1020t1531", "own": True})
    check("a booking without one carries neither", ("email" in rows["BAG_PO_002"],
                                                    "otp" in rows["BAG_PO_002"]), (False, False))


if __name__ == "__main__":
    test_address()
    test_publisher()
    test_pool()
    if FAILED:
        print(f"\n{len(FAILED)} check(s) failed")
        sys.exit(1)
    print("\nall checks passed")
