"""The passenger identity a report shows per booking: pool names, contact, Aeroplan, e-ticket.

No network: a fake pool file, build manifest and `messages.jsonl` in a temporary directory.

Run:  python tests/test_booking_identity.py
"""
from __future__ import annotations

import json
import pathlib
import sys
import tempfile

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

import yaml                                                                  # noqa: E402

from tools import booking_identity                                           # noqa: E402
from tools.booking_identity import cell, identities, lookup, pool_name       # noqa: E402

FAILED: list[str] = []


def check(label: str, got: object, want: object) -> None:
    if got != want:
        FAILED.append(label)
        print(f"  FAIL {label}: got {got!r}, wanted {want!r}")
    else:
        print(f"  ok   {label}")


LABEL = "soc-uat-automation-1020T1022"
RECORDS = [
    {"case": "SOC_UAT_001", "locator": "ZZS2TO", "pnrId": "ZZS2TO-2026-09-07"},
    {"case": "SOC_UAT_002", "locator": "ZZU33K", "pnrId": "ZZU33K-2026-09-08"},
]


def message(booking: str, value: dict) -> str:
    """A batch line as the builder writes it: the Kafka value is JSON escaped inside a string."""
    return json.dumps({"booking": booking, "feed": "TKT", "value": json.dumps(value)})


def fixture(root: pathlib.Path, *, with_pool: bool = True) -> tuple[pathlib.Path, pathlib.Path]:
    pools, runs = root / "pools", root / "runs" / "int"
    pools.mkdir(parents=True)
    if with_pool:
        doc = {"pools": {pool_name(LABEL): {
            "otp": {"provider": "mailinator", "domain": "ae-qa1-aircanada.mailinator.com",
                    "inbox": "lahiru"},
            "bookings": [
                {"pnr": "ZZS2TO", "first": "Pierre", "last": "Dornevtav",
                 "caseId": "SOC_UAT_001", "aeroplan": "411905629"},
                {"pnr": "ZZU33K", "first": "Karl", "last": "Rilbrebar", "caseId": "SOC_UAT_002",
                 "email": "lahiru-soc-uat-002@ae-qa1-aircanada.mailinator.com",
                 "phone": "+15559546477"}]}}}
        (pools / f"{pool_name(LABEL)}.yaml").write_text(yaml.safe_dump(doc), encoding="utf-8")

    batch = runs / "build-1020T1553" / "b01"
    (batch / "batch").mkdir(parents=True)
    (batch / "manifest.json").write_text(json.dumps(
        [{"id": r["case"], "pnrId": r["pnrId"], "locator": r["locator"], "passengers": 1}
         for r in RECORDS]), encoding="utf-8")
    pnr = {"ticketingReferences": [{"documents": [
        {"primaryDocumentNumber": "0146898350774",
         "coupons": [{"documentNumber": "0146898350774"}]}]}]}
    two = {"documents": [{"primaryDocumentNumber": "0140000000001"},
                         {"primaryDocumentNumber": "0140000000002"}]}
    lines = [message("ZZS2TO-2026-09-07", pnr), message("ZZS2TO-2026-09-07", pnr),
             message("ZZU33K-2026-09-08", two),
             message("ZZOTHR-2026-09-09", {"primaryDocumentNumber": "0149999999999"})]
    (batch / "batch" / "messages.jsonl").write_text("\n".join(lines) + "\n", encoding="utf-8")
    return pools, runs


def test_identity() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        pools, runs = fixture(pathlib.Path(tmp))
        ids = identities(RECORDS, label=LABEL, env="int", runs_dir=runs, pool_directory=pools)
        one, two = lookup(ids, RECORDS[0]), lookup(ids, RECORDS[1])
        check("the published name comes from the pool", (one["first"], one["last"]),
              ("Pierre", "Dornevtav"))
        check("keyed by pnrId and locator too", (ids["ZZS2TO-2026-09-07"] is one,
                                                 ids["ZZS2TO"] is one), (True, True))
        check("no own e-mail -> the shared inbox, marked shared",
              (one["email"], one["email_shared"]),
              ("lahiru@ae-qa1-aircanada.mailinator.com", True))
        check("no own phone -> the shared default, marked shared", one["phone_shared"], True)
        check("an own e-mail is not marked shared",
              (two["email"], two["email_shared"]),
              ("lahiru-soc-uat-002@ae-qa1-aircanada.mailinator.com", False))
        check("an own phone is not marked shared", (two["phone"], two["phone_shared"]),
              ("+15559546477", False))
        check("the Aeroplan number", (one["aeroplan"], two["aeroplan"]), ("411905629", ""))
        check("the ticket read out of the escaped JSON, once", one["tickets"],
              ["0146898350774"])
        check("several tickets on one booking, in order", two["tickets"],
              ["0140000000001", "0140000000002"])
        html = cell(one)
        check("the cell carries every field",
              all(s in html for s in ("Pierre Dornevtav", "411905629", "0146898350774",
                                      "shared default")), True)


def test_missing_pool() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        pools, runs = fixture(pathlib.Path(tmp), with_pool=False)
        ids = identities(RECORDS, label=LABEL, env="int", runs_dir=runs, pool_directory=pools)
        one = lookup(ids, RECORDS[0])
        check("no pool -> blank name and contact, not a crash",
              (one["first"], one["last"], one["email"], one["phone"], one["aeroplan"]),
              ("", "", "", "", ""))
        check("the ticket still comes from the batch", one["tickets"], ["0146898350774"])
        check("the cell falls back to the engine's name", "PIERRE" in cell(one, "PIERRE"), True)
        none = identities(RECORDS, label=LABEL, env="int", runs_dir=pathlib.Path(tmp) / "nope",
                          pool_directory=pathlib.Path(tmp) / "nope")
        check("no pool and no batch -> empty tickets", lookup(none, RECORDS[1])["tickets"], [])


def test_escaping() -> None:
    html = cell({"first": "<script>", "last": "O'Neil", "tickets": ["1&2"]})
    check("everything is escaped", ("<script>" in html, "&lt;script&gt;" in html,
                                    "1&amp;2" in html), (False, True, True))
    check("pool name as the seeder writes it", booking_identity.pool_name(LABEL),
          "soc-uat-automation-1020t1022")


if __name__ == "__main__":
    test_identity()
    test_missing_pool()
    test_escaping()
    if FAILED:
        print(f"\n{len(FAILED)} check(s) failed")
        sys.exit(1)
    print("\nall checks passed")
