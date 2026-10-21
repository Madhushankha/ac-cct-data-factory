"""Per-case baggage interim-expense receipts: totals that add up to the cent, purchases inside the
bag's delay window, ELIGIBLE categories only, files named by case id, the same bytes on every run,
and the cases that never reach the upload skipped.

Synthetic run records throughout, plus the seeded baggage-sit-po-1020T1020 run when it is here. An
OCR round trip runs when an OCR engine is on the machine (the SOC test's helper: tesseract, or
Windows.Media.Ocr). Nothing is installed and nothing leaves the machine.

Run:  python tests/test_baggage_receipts.py
"""
from __future__ import annotations

import datetime as dt
import hashlib
import importlib.util
import json
import pathlib
import random
import re
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from tools import baggage_receipts as br                                     # noqa: E402

FAILED: list[str] = []


def check(label: str, got: object, want: object) -> None:
    if got != want:
        FAILED.append(label)
        print(f"  FAIL {label}: got {got!r}, wanted {want!r}")
    else:
        print(f"  ok   {label}")


def record(case: str = "BAG_PO_039", delivered: str | None = "Oct 16, 2026 08:40 PM",
           closed: str | None = None, arr: str = "Oct 16, 2026 12:40 AM",
           ahl: str = "Oct 16, 2026 02:40 AM", loc: str = "YYZ") -> dict:
    """A run record shaped like runs/int/baggage-sit-po-*/<CASE>.json."""
    events = [["BAG_CREATED", "Oct 15, 2026 01:40 PM"], ["BAG_DELAYED_RECORD_CREATED", ahl]]
    if delivered:
        events.append(["BAG_DELIVERED_TO_CAROUSEL", delivered])
    if closed:
        events.append(["BAG_DELAYED_RECORD_CLOSED", closed])
    return {"case": case, "locator": "ZZTEST", "flight": "AC7751", "route": f"YVR-{loc}",
            "seen": {"segments": [{"flight": "AC7751", "from": "YVR", "to": loc,
                                   "schedArr": "Oct 15, 2026 08:40 PM", "actualArr": arr}],
                     "baggage": [{"tag": "0014084752", "bound": "OUTBOUND", "loc": loc,
                                  "ahl": f"{loc}AC91042", "ahlAt": ahl, "events": events}]},
            "document": {"bounds": []}}


POOL = {"BAG_PO_039": {"pnr": "ZZTEST", "first": "Ulrik", "last": "Malpavtav", "caseId": "BAG_PO_039"}}


def case(rec: dict | None = None, cid: str = "BAG_PO_039") -> br.Case:
    c, why = br.load_case(rec or record(cid), {cid: {**POOL["BAG_PO_039"], "caseId": cid}})
    assert c is not None, why
    return c


def adds_up(r: dict) -> bool:
    return (round(r["subtotal"] + sum(t["amount"] for t in r["taxes"]), 2) == r["total"]
            and round(sum(i["amount"] for i in r["items"]), 2) == r["subtotal"]
            and all(i["amount"] > 0 for i in r["items"]))


# ---------------------------------------------------------------------- amounts

def test_amounts() -> None:
    print("items + tax = total, to the cent, every locale and category")
    bad, over = [], []
    c = case()
    for code, loc in br.LOCALES.items():
        for cat in br.CATEGORIES:
            for seed in range(25):
                r = br.build_receipt(c, cat, loc, dt.datetime(2026, 10, 16, 12, 0), 1,
                                     random.Random(seed), "4217", set())
                if r.subtotal + r.tax[1] != r.total or min(a for _, a in r.items) <= 0:
                    bad.append(f"{code}/{cat}/{seed}")
                if abs(r.tax[1] - r.subtotal * loc.tax[1]) > 0.5:
                    over.append(f"{code}/{cat}/{seed} {r.tax}")
                if br.lint(r):
                    bad.append(f"{code}/{cat}/{seed} lint {br.lint(r)}")
    check("every receipt adds up and lints clean", bad[:5], [])
    check("the tax line is the rate on the subtotal, rounded half up", over[:5], [])


# ---------------------------------------------------------------------- categories

INELIGIBLE = ("electronic", "phone", "charger", "cable", "speaker", "battery", "luggage", "suitcase",
              "curling", "iron", "fruit", "snack", "lighter", "aerosol", "tool", "formula")


def test_categories() -> None:
    print("ELIGIBLE categories only")
    check("every category we render is ELIGIBLE in the service table",
          sorted({v[2] for v in br.CATEGORIES.values()}), ["ELIGIBLE"])
    check("and maps to one of the service's groups",
          sorted({v[1] for v in br.CATEGORIES.values()}),
          ["accessories", "clothingAndFootwear", "cosmeticsAndToiletries"])
    words = [label.lower() for items in br.CATALOG.values() for label, _ in items]
    check("no catalogue line names an ineligible or manual-review good",
          [w for w in words if any(x in w for x in INELIGIBLE)], [])
    check("every scenario renders known categories only",
          sorted({c for cats, _, _ in [*br.SCENARIOS.values(), br.DEFAULT_SCENARIO] for c in cats}
                 - set(br.CATEGORIES)), [])
    r = br.Receipt("clothing", "M", "S", "C", dt.datetime(2026, 10, 16, 12), "1", "01", "4217", "X",
                   "CAD", [("USB-C phone charger", 2999), ("Bluetooth speaker", 5999),
                           ("Toiletry bag", 1999)], ("HST 13%", 0), 0)
    check("lint refuses electronics, a charger and a bag (luggage)", len(br.lint(r)) >= 3, True)


# ---------------------------------------------------------------------- the window

def test_window() -> None:
    print("purchase times inside the bag's delay window")
    c = case()
    lo, hi, note = br.purchase_slot(c)
    check("a delivered bag: the arrival day, after the AHL, before delivery",
          (lo.date().isoformat(), lo >= c.ahl_opened, hi <= c.window_end, note),
          ("2026-10-16", True, True, ""))
    u = case(record(delivered=None))
    lo, hi, _ = br.purchase_slot(u)
    check("an undelivered bag: the day after arrival (as the pack dates it)", lo.date().isoformat(),
          "2026-10-17")
    late = case(record(arr="Oct 16, 2026 07:10 PM", ahl="Oct 16, 2026 09:10 PM",
                       delivered="Oct 18, 2026 10:00 AM"))
    lo, hi, _ = br.purchase_slot(late)
    check("a late arrival rolls to the next day the stores open, still before delivery",
          (lo.strftime("%Y-%m-%d %H:%M"), hi <= late.window_end), ("2026-10-17 09:00", True))
    times = br.schedule(3, dt.datetime(2026, 10, 16, 19, 30), dt.datetime(2026, 10, 16, 20, 30),
                        random.Random(4))
    check("three receipts in a one-hour slot: ordered, 20 minutes apart, inside it",
          (times == sorted(times), all(dt.datetime(2026, 10, 16, 19, 30) <= t
                                       <= dt.datetime(2026, 10, 16, 20, 30) for t in times),
           all((b - a).total_seconds() >= 20 * 60 for a, b in zip(times, times[1:]))),
          (True, True, True))


# ---------------------------------------------------------------------- skipping

def spec_for(sd: str) -> pathlib.Path | None:
    return next((p for p in sorted(br.SPEC_DIR.glob("BAG_PO_*.json"))
                 if (json.loads(p.read_text(encoding="utf-8")).get("source") or {}).get("sd") == sd),
                None)


def test_skipped() -> None:
    print("cases that never reach the receipt upload")
    synth = {"source": {"rule": "BAG-03", "sd": "SD-03.1", "condition": "more than one bound"}}
    check("a non-BAG-05 case is not interim", br.classify(synth)[0], False)
    for cond, word in (("isDuplicateCase", "isDuplicateCase"), ("declines the receipt invitation",
                                                               "declines"),
                       ("closed file, none open", "closed"), ("not AC last carrier", "not AC"),
                       ("delivery question unanswered", "unanswered"),
                       ("delivered, interim NOT_ELIGIBLE", "NOT_ELIGIBLE")):
        ok, why = br.classify({"source": {"rule": "BAG-05", "condition": cond},
                               "expectBag": {"isAhlPresent": True}})
        check(f"BAG-05 '{cond}' is skipped, and says why", (ok, word in why), (False, True))
    ok, _ = br.classify({"source": {"rule": "BAG-05", "condition": "interim ELIGIBLE"},
                         "bagPlan": {"shape": "ahl_delivered"}, "expectBag": {"isAhlPresent": True}})
    check("BAG-05 'interim ELIGIBLE' is covered", ok, True)
    early = record(arr="Oct 16, 2026 12:40 AM", ahl="Oct 16, 2026 02:40 AM",
                   delivered="Oct 16, 2026 03:10 AM")
    got, why = br.load_case(early, POOL)
    check("a bag delivered before any expense could arise is skipped",
          (got, "before any expense" in why), (None, True))
    with tempfile.TemporaryDirectory() as tmp:
        run = pathlib.Path(tmp) / "baggage-test-run"
        run.mkdir()
        cases = [p.stem for p in (spec_for("SD-05.13"), spec_for("SD-03.1")) if p]
        for cid in cases:
            (run / f"{cid}.json").write_text(json.dumps(record(cid)), encoding="utf-8")
        res = br.run(run, pathlib.Path(tmp) / "out", set())
        check("a run of declined and lost-bag cases writes nothing and lists them skipped",
              (res["covered"], sorted(c for c, _ in res["skipped"]),
               (pathlib.Path(tmp) / "out").exists()), ([], sorted(cases), False))


# ---------------------------------------------------------------------- a case's files

def test_generate() -> None:
    print("a case's receipts")
    with tempfile.TemporaryDirectory() as a, tempfile.TemporaryDirectory() as b:
        c = case(record("BAG_PO_043", delivered=None, arr="Oct 11, 2026 12:40 AM",
                        ahl="Oct 11, 2026 02:40 AM"), cid="BAG_PO_043")
        m = br.generate(c, pathlib.Path(a))
        br.generate(c, pathlib.Path(b))
        folder = pathlib.Path(a) / "BAG_PO_043"
        files = sorted(p.name for p in folder.iterdir() if p.name != "manifest.json")
        check("one file per receipt, named in the manifest", files, sorted(r["file"] for r in m["receipts"]))
        check("named by CASE ID, never the PNR",
              all(re.fullmatch(r"BAG_PO_043_\d_[a-z_]+_YYZ\.jpg", f) and "ZZTEST" not in f for f in files),
              True)
        check("SD-05.16 carries accessories + clothing, as bagv65 B08 + B09",
              [r["category"] for r in m["receipts"]], ["accessories", "clothing"])
        check("each manifest receipt adds up to the cent", all(adds_up(r) for r in m["receipts"]), True)
        w = m["window"]
        start = max(dt.datetime.fromisoformat(w["from"]), dt.datetime.fromisoformat(w["ahlOpened"]))
        inside = [start < dt.datetime.fromisoformat(f"{r['date']} {r['time']}")
                  and (w["to"] is None or dt.datetime.fromisoformat(f"{r['date']} {r['time']}")
                       < dt.datetime.fromisoformat(w["to"])) for r in m["receipts"]]
        check("every receipt is timed inside the delay window", all(inside), True)
        check("the shared cap is carried, and the case is far below it",
              (m["liabilityCapSDR"], m["claimedCADApprox"] < 2810 * br.CAP_SHARE), (1519, True))
        check("every manifest field the SOC shape has, per receipt", sorted(
            {"file", "path", "category", "currency", "total", "items", "taxes", "date", "time",
             "merchant", "city", "airport", "expected", "rule", "amountSource", "window"}
            - set(m["receipts"][0])), [])
        check("CAD at a Canadian airport", {r["currency"] for r in m["receipts"]}, {"CAD"})
        check("JPG only, each far under the 10 MB image limit",
              all(f.endswith(".jpg") and (folder / f).stat().st_size < 1_000_000 for f in files), True)
        digest = lambda d: {p.name: hashlib.sha256(p.read_bytes()).hexdigest()   # noqa: E731
                            for p in (pathlib.Path(d) / "BAG_PO_043").iterdir()}
        check("deterministic: the same bytes on a second run", digest(a), digest(b))
        other = br.generate(case(record("BAG_PO_037", delivered=None), cid="BAG_PO_037"), pathlib.Path(b))
        check("another case id draws different items",
              other["receipts"][0]["items"] != m["receipts"][1]["items"], True)


def test_foreign_airport() -> None:
    print("a bag missing at a non-Canadian airport")
    with tempfile.TemporaryDirectory() as tmp:
        c = case(record(loc="LHR"))
        m = br.generate(c, pathlib.Path(tmp))
        check("priced in the local currency", {r["currency"] for r in m["receipts"]}, {"GBP"})
        check("and still adds up", all(adds_up(r) for r in m["receipts"]), True)


def test_text_model() -> None:
    print("the fields the pack prints, in the text model")
    c = case()
    r = br.build_receipt(c, "clothing", br.LOCALES["YYZ"], dt.datetime(2026, 10, 16, 18, 42), 1,
                         random.Random(3), "4217", set())
    text = "\n".join(br.text_lines(r))
    need = {"merchant": r.merchant in text, "street": r.street in text, "DATE": "DATE  2026-10-16" in text,
            "TIME": "TIME  18:42" in text, "STORE": "STORE" in text, "TERMINAL": "TERMINAL" in text,
            "card": "VISA ****4217" in text, "invoice": r.invoice in text, "subtotal": "SUBTOTAL" in text,
            "tax": "HST 13%" in text, "total": f"TOTAL CAD  {br.money(r.total)}" in text,
            "thanks": "THANK YOU" in text, "merchant copy": "MERCHANT COPY" in text,
            "test mark": br.MARK in text}
    check("every field present", [k for k, v in need.items() if not v], [])


def test_goal_plan_dir() -> None:
    print("goal plans read the flow's own receipts")
    from cli.commands import default_receipts_dir
    suite = pathlib.Path("/suite")
    check("a baggage set reads receipts/baggage, a SOC set receipts/soc",
          (default_receipts_dir(suite, "baggage/sit/po").as_posix(),
           default_receipts_dir(suite, "soc/uat/automation").as_posix()),
          ("/suite/receipts/baggage", "/suite/receipts/soc"))
    from domain.goal_plan import receipt_rows
    with tempfile.TemporaryDirectory() as tmp:
        m = br.generate(case(record("BAG_PO_048", delivered=None), cid="BAG_PO_048"), pathlib.Path(tmp))
    files, judged, dash = receipt_rows([{**r, "file": f"receipts/baggage/BAG_PO_048/{r['file']}"}
                                        for r in m["receipts"]])
    check("the plan item keeps the {file, category, total, currency} shape",
          sorted(files[0]), ["category", "currency", "file", "total"])
    check("a judged receipt checkpoint per file, worded from the manifest",
          ([j["kind"] for j in judged], "1519 SDR" in judged[0]["text"]), (["receipt"], True))
    check("and the CP153 attachments row", (dash[0]["api"], dash[0]["expected"]), ("CP153", "1"))


# ---------------------------------------------------------------------- the seeded run

RUN = ROOT / "runs" / "int" / "baggage-sit-po-1020T1020"


def test_seeded_run() -> None:
    if not (RUN / "BAG_PO_039.json").exists() or not br.load_pool(RUN.name):
        print("the seeded baggage-sit-po-1020T1020 run: not here, skipped")
        return
    print("the seeded baggage-sit-po-1020T1020 run")
    with tempfile.TemporaryDirectory() as tmp:
        res = br.run(RUN, pathlib.Path(tmp), set())
        sds = sorted(m["sd"] for m in res["covered"])
        check("the nine BAG-05 scenarios bagv65 carries receipts for", sds,
              sorted(["SD-05.1", "SD-05.9", "SD-05.10", "SD-05.12", "SD-05.14", "SD-05.15",
                      "SD-05.16", "SD-05.18", "SD-05.20"]))
        check("no errors", res["errors"], [])
        m = next(m for m in res["covered"] if m["sd"] == "SD-05.12")
        check("SD-05.12: delivered the evening of arrival, so dated the arrival day at YYZ",
              (m["airport"], {r["date"] for r in m["receipts"]}, m["window"]["to"]),
              ("YYZ", {"2026-10-16"}, "2026-10-16 20:40"))
        check("the pool's passenger", m["passenger"], "Ulrik Malpavtav")


# ---------------------------------------------------------------------- OCR

def _ocr_helper():
    spec = importlib.util.spec_from_file_location("_soc_receipt_tests", ROOT / "tests" / "test_soc_receipts.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.ocr


def test_ocr_roundtrip() -> None:
    try:
        ocr = _ocr_helper()
    except Exception as exc:                                               # noqa: BLE001
        print(f"OCR round trip: the SOC helper did not load ({exc}), skipped")
        return
    with tempfile.TemporaryDirectory() as tmp:
        m = br.generate(case(), pathlib.Path(tmp))
        r = m["receipts"][0]
        got = ocr(pathlib.Path(tmp) / "BAG_PO_039" / r["file"], pathlib.Path(tmp))
        if got is None:
            print("OCR round trip: no tesseract and no Windows OCR here, skipped")
            return
        engine, text = got
        print(f"OCR round trip ({engine})")
        flat = re.sub(r"\s+", "", text)
        check("the total is read back", f"{r['total']:.2f}" in flat, True)
        check("the date is read back", r["date"] in flat, True)
        check("every word of the merchant is read back",
              [w for w in r["merchant"].split() if w.lower() not in flat.lower()], [])
        check("every item amount is read back",
              [i["label"] for i in r["items"] if f"{i['amount']:.2f}" not in flat], [])


if __name__ == "__main__":
    test_amounts()
    test_categories()
    test_window()
    test_skipped()
    test_generate()
    test_foreign_airport()
    test_text_model()
    test_goal_plan_dir()
    test_seeded_run()
    test_ocr_roundtrip()
    if FAILED:
        print(f"\n{len(FAILED)} check(s) failed")
        sys.exit(1)
    print("\nall checks passed")
