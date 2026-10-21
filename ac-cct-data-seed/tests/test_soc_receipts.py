"""Per-case SOC receipts: amounts that add up to the cent, dates inside the disruption window, the
fields a reader requires, one receipt per file, and the same bytes on every run.

Synthetic cases throughout, plus SOC_UAT_046's real Jira text and run record when they are synced.
An OCR round trip runs when an OCR engine is on the machine: tesseract if installed, otherwise the
Windows built-in engine (Windows.Media.Ocr via PowerShell). Nothing is installed and nothing leaves
the machine.

Run:  python tests/test_soc_receipts.py
"""
from __future__ import annotations

import datetime as dt
import hashlib
import json
import pathlib
import random
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from tools import soc_receipts as sr                                         # noqa: E402

FAILED: list[str] = []


def check(label: str, got: object, want: object) -> None:
    if got != want:
        FAILED.append(label)
        print(f"  FAIL {label}: got {got!r}, wanted {want!r}")
    else:
        print(f"  ok   {label}")


SYNTHETIC = "\n".join([
    'And the user says "My flight was cancelled and I paid for food, a hotel and a taxi."',
    "• Meals: up to $30.00 per person × 2 = $60.00",
    "• Hotel accommodation: Rate of day (up to 3 nights, $500 maximum)",
    "• Ground transportation: up to $200.00",
    "• Essential items: up to $30.00",
    "• Receipt 1: Hotel receipt – $620.00 CAD (1 night near YYZ)",
    "• Receipt 2: Meal receipt – $52.00 CAD (dinner for 2)",
    "• Receipt 3: Taxi receipt – $60.00 CAD (airport to hotel + hotel to airport)",
    "• Receipt 4: Essential items – $28.00 CAD (toiletries)",
    "Receipt 3 – Transport:",
    "• Line item 1: Taxi airport?hotel – $35.00 CAD",
    "• Line item 2: Taxi hotel?airport – $25.00 CAD",
    "• Total Approved: $600.00 CAD (Hotel $500 + Meals $52 + Transport $60 + Essentials $28)",
])


def case(airport: str = "YYZ", text: str = SYNTHETIC, dep: str = "17:10", cid: str = "SOC_UAT_900",
         regime: str = "APPR") -> sr.Case:
    return sr.Case(cid, "CHAI-900", "APPR – Eligible – test", regime, "ELIGIBLE", "ZZTEST", "Isabella",
                   "Ostcastav", airport, dt.date(2026, 10, 8), dep, "AC859", 1, text)


def adds_up(r: sr.Receipt) -> bool:
    return r.subtotal + sum(a for _, a in r.taxes) == r.total and all(a > 0 for _, a in r.items)


# ---------------------------------------------------------------------- amounts

def test_amounts() -> None:
    print("items + taxes = total, to the cent, for every locale and category")
    rng = random.Random(1)
    failures, tax_off = [], []
    totals = [100 + 37 * k for k in range(0, 1800, 7)]           # 1.00 .. ~466 in odd steps
    totals += [5200, 6000, 2800, 18500, 16500, 60000, 58000, 17500, 62000]
    for code in sr.LOCALES:
        c = case(code)
        for cat in sr.CATEGORIES:
            for total in (t for t in totals if cat != "hotel" or t >= 5000):   # a hotel under 50 is not real
                exp = sr.Expense(1, cat, total, sr.LOCALES[code].currency, cat)
                try:
                    r = sr.build_receipt(c, exp, sr.LOCALES[code], "19:00", 1, rng)
                except ValueError as exc:
                    failures.append(f"{code}/{cat}/{sr.money(total)}: {exc}")
                    continue
                if not adds_up(r):
                    failures.append(f"{code}/{cat}/{sr.money(total)} does not add up")
                # each sales tax within a cent per line of the rate on its base
                base = r.subtotal + (r.taxes[0][1] if r.kind == "folio" and sr.LOCALES[code].hotel_levy
                                     and sr.LOCALES[code].hotel_levy[2] else 0)
                for label, amount in r.taxes:
                    m = re.search(r"(\d+(?:\.\d+)?)%", label)
                    if m and not label.lower().startswith(("municipal", "accommodation", "tourism",
                                                           "marketing", "taxe")):
                        if abs(amount - base * float(m.group(1)) / 100) > len(r.items) + 0.5:
                            tax_off.append(f"{code}/{cat}/{sr.money(total)} {label}={amount}")
    check("every total is reachable and adds up (no rounding gap left)", failures[:5], [])
    check("every tax line is the rate on its base, within a cent per line", tax_off[:5], [])


def test_lint() -> None:
    print("no line trips the reader's alcohol/tip keywords")
    rng = random.Random(2)
    r = sr.build_receipt(case(), sr.Expense(1, "essentials", 2500, "CAD", "cable",
                                            items=[("Phone charging cable", 2500)]),
                         sr.LOCALES["YYZ"], "19:00", 1, rng)
    check("'charging' (holds 'gin', P16) is reworded", [l for l, _ in r.items], ["1 x Phone USB cable"])
    check("lint finds nothing on it", sr.lint(r), [])
    bad = sr.Receipt("thermal", "hotel", "M", "S", "C", "P", [], dt.date(2026, 1, 1), "10:00", "N",
                     "CAD", "$", [("Room", 100)], [("Lodging tax 3%", 3)], 103, "4242", "A", "T")
    check("a 'Lodging tax' line would be caught", bool(sr.lint(bad)), True)


# ---------------------------------------------------------------------- parsing

def test_parse_synthetic() -> None:
    print("parsing a Jira text")
    exps = sr.parse_expenses(SYNTHETIC)
    check("one expense per Receipt N line, categorised",
          [(e.category, e.amount, e.currency) for e in exps],
          [("hotel", 62000, "CAD"), ("meal", 5200, "CAD"), ("transport", 6000, "CAD"),
           ("essentials", 2800, "CAD")])
    check("a 'for 2' meal knows its covers", exps[1].pax, 2)
    check("the test's line items are kept when they add up",
          exps[2].items, [("Taxi airport?hotel", 3500), ("Taxi hotel?airport", 2500)])
    caps = sr.parse_caps(SYNTHETIC)
    check("caps, with 'per person x 2 = $60' read as the product",
          {k: v["amount"] for k, v in caps.items()},
          {"meal": 6000, "hotel": 50000, "transport": 20000, "essentials": 3000})
    check("the hotel cap's nights", caps["hotel"]["nights"], 3)
    check("the stated total approved", sr.total_approved(SYNTHETIC),
          "$600.00 CAD (Hotel $500 + Meals $52 + Transport $60 + Essentials $28)")
    check("categories the customer mentions", sr.mentioned_categories(SYNTHETIC),
          ["hotel", "meal", "transport"])


def jira_046() -> str | None:
    folder = sr.jira_folder("SOC_UAT_046")
    if folder is None:
        return None
    return ((folder / "test.feature").read_text(encoding="utf-8", errors="replace") + "\n"
            + str(json.loads((folder / "test.json").read_text(encoding="utf-8")).get("description") or ""))


def test_parse_046() -> None:
    text = jira_046()
    if text is None:
        print("SOC_UAT_046's Jira text: not synced here, skipped")
        return
    print("SOC_UAT_046's real Jira text")
    exps = sr.parse_expenses(text)
    check("hotel 185 / meals 52 / transport 60 / essentials 28 CAD",
          [(e.category, e.amount / 100, e.currency) for e in exps],
          [("hotel", 185.0, "CAD"), ("meal", 52.0, "CAD"), ("transport", 60.0, "CAD"),
           ("essentials", 28.0, "CAD")])
    check("its caps (EUR under the EU regime)",
          {k: v["amount"] / 100 for k, v in sr.parse_caps(text).items()},
          {"meal": 60.0, "hotel": 500.0, "transport": 200.0, "communication": 30.0,
           "parking": 50.0, "essentials": 30.0})
    check("its stated total approved is carried", (sr.total_approved(text) or "").startswith("~"), True)


# ---------------------------------------------------------------------- a case's files

def test_generate() -> None:
    print("a case's receipts")
    with tempfile.TemporaryDirectory() as a, tempfile.TemporaryDirectory() as b:
        m = sr.generate(case(), pathlib.Path(a))
        sr.generate(case(), pathlib.Path(b))
        folder = pathlib.Path(a) / "SOC_UAT_900"
        files = sorted(p.name for p in folder.iterdir() if p.name != "manifest.json")
        check("one file per receipt, named in the manifest",
              files, sorted(r["file"] for r in m["receipts"]))
        check("hotel as PDF, the rest as JPG", [r["file"].rsplit(".", 1)[1] for r in m["receipts"]],
              ["pdf", "jpg", "jpg", "jpg"])
        pdf = (folder / m["receipts"][0]["file"]).read_bytes()
        pages = len(re.findall(rb"/Type\s*/Page(?![s\w])", pdf))
        check("the folio PDF is a single page (one receipt per file)", pages, 1)
        lo = dt.datetime.fromisoformat(m["window"]["from"])
        hi = dt.datetime.fromisoformat(m["window"]["to"])
        inside = [lo <= dt.datetime.fromisoformat(f"{r['date']} {r['time']}") <= hi for r in m["receipts"]]
        check("every receipt is dated the disruption day, timed inside the window", all(inside), True)
        check("totals are the Jira amounts", [r["total"] for r in m["receipts"]], [620.0, 52.0, 60.0, 28.0])
        check("each manifest receipt adds up",
              all(round(r["subtotal"] + sum(t["amount"] for t in r["taxes"]), 2) == r["total"]
                  and round(sum(i["amount"] for i in r["items"]), 2) == r["subtotal"]
                  for r in m["receipts"]), True)
        check("over the cap: the cap rule; under it: paid in full",
              [r["expected"] for r in m["receipts"]],
              ["partial: capped at CAD 500.00 (AC_PE_02)", "paid in full", "paid in full",
               "paid in full"])
        check("the INT reader's own caps beside it (index.csv)",
              [r["expectedInt"].split(" ")[0] for r in m["receipts"]][:3],
              ["PARTIALLY_ELIGIBLE,", "PAID", "PAID"])
        digest = lambda d: {p.name: hashlib.sha256(p.read_bytes()).hexdigest()   # noqa: E731
                            for p in (pathlib.Path(d) / "SOC_UAT_900").iterdir()}
        check("deterministic: the same bytes on a second run", digest(a), digest(b))
        other = sr.generate(case(cid="SOC_UAT_901"), pathlib.Path(b))
        check("another case id draws different numbers",
              other["receipts"][1]["time"] != m["receipts"][1]["time"]
              or other["receipts"][1]["items"] != m["receipts"][1]["items"], True)


def test_mandatory_fields() -> None:
    print("the fields a reader requires, in the text model")
    rng = random.Random(3)
    c = case()
    for exp in sr.parse_expenses(SYNTHETIC):
        r = sr.build_receipt(c, exp, sr.LOCALES["YYZ"], "19:30", exp.n, rng)
        text = "\n".join(sr.text_lines(r))
        need = {"merchant": r.merchant in text, "street": r.street in text, "city": r.city in text,
                "phone": "Tel. " in text, "tax id": "HST# 786123450" in text,
                "date": "2026-10-08" in text, "receipt no": r.number in text,
                "items": all(label in text for label, _ in r.items),
                "total": f"TOTAL CAD" in text and sr.money(r.total) in text,
                "payment": "VISA **** 4242" in text, "test mark": sr.MARK in text}
        if r.kind == "thermal":
            need |= {"time": "Time: 19:30" in text, "subtotal": "Subtotal" in text,
                     "approved": "APPROVED" in text}
        else:
            need |= {"guest": "ISABELLA OSTCASTAV" in text, "arrival": "Arrival:" in text,
                     "departure": "2026-10-09" in text, "invoice dated the disruption day":
                     "Invoice date: 2026-10-08" in text, "rate": "/ night" in text}
        check(f"{exp.category}: every field present", [k for k, v in need.items() if not v], [])


def test_window_late_departure() -> None:
    print("a departure late in the evening")
    times = sr.schedule([sr.Expense(i, c, 1000, "CAD", c) for i, c in
                         enumerate(["hotel", "meal", "transport", "essentials"], 1)],
                        "23:20", random.Random(4))
    check("all four still fit before midnight, after the departure",
          all("23:20" < t <= "23:50" for t in times.values()), True)


def test_not_eligible_skipped() -> None:
    print("not-eligible cases")
    spec = next((p for p in sorted(sr.SPEC_DIR.glob("SOC_UAT_*.json"))
                 if json.loads(p.read_text(encoding="utf-8"))["expect"].get("eligibility") == "NOT_ELIGIBLE"),
                None)
    if spec is None:
        print("  no NOT_ELIGIBLE spec here, skipped")
        return
    got, why = sr.load_case({"case": spec.stem, "locator": "ZZNONE", "published": []}, {})
    check("a NOT_ELIGIBLE spec gives no case", got, None)
    check("and says why", why.startswith("not eligible"), True)
    with tempfile.TemporaryDirectory() as tmp:
        run = pathlib.Path(tmp) / "soc-test-run"
        run.mkdir()
        (run / f"{spec.stem}.json").write_text(json.dumps({"case": spec.stem, "locator": "ZZNONE"}),
                                               encoding="utf-8")
        res = sr.run(run, pathlib.Path(tmp) / "out", set())
        check("a run of it writes nothing and lists it skipped",
              (res["covered"], [c for c, _ in res["skipped"]], (pathlib.Path(tmp) / "out").exists()),
              ([], [spec.stem], False))


def test_seeded_046() -> None:
    run = ROOT / "runs" / "int" / "soc-uat-046-own"
    if not (run / "SOC_UAT_046.json").exists() or jira_046() is None:
        print("the seeded SOC_UAT_046 run: not here, skipped")
        return
    print("the seeded SOC_UAT_046 run")
    record = json.loads((run / "SOC_UAT_046.json").read_text(encoding="utf-8"))
    c, why = sr.load_case(record, sr.load_pool("soc-uat-046-own"))
    if c is None:
        check("the case loads", why, "")
        return
    check("stranded at YYZ on the seeded day, from the published key",
          (c.airport, c.date.isoformat(), c.window_from), ("YYZ", "2026-10-08", "17:10"))
    check("the pool's passenger and booking", (c.pnr, c.first, c.last),
          ("ZZTZUF", "Isabella", "Ostcastav"))


# ---------------------------------------------------------------------- OCR

PS_OCR = r"""param([string]$Path)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$null = [Windows.Storage.StorageFile, Windows.Storage, ContentType = WindowsRuntime]
$null = [Windows.Media.Ocr.OcrEngine, Windows.Foundation, ContentType = WindowsRuntime]
$null = [Windows.Graphics.Imaging.BitmapDecoder, Windows.Graphics, ContentType = WindowsRuntime]
$asTask = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
function Await($op, [Type]$t) { $task = $asTask.MakeGenericMethod($t).Invoke($null, @($op)); $task.Wait(-1) | Out-Null; $task.Result }
$file = Await ([Windows.Storage.StorageFile]::GetFileFromPathAsync($Path)) ([Windows.Storage.StorageFile])
$stream = Await ($file.OpenAsync([Windows.Storage.FileAccessMode]::Read)) ([Windows.Storage.Streams.IRandomAccessStream])
$decoder = Await ([Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync($stream)) ([Windows.Graphics.Imaging.BitmapDecoder])
$bitmap = Await ($decoder.GetSoftwareBitmapAsync()) ([Windows.Graphics.Imaging.SoftwareBitmap])
$engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromUserProfileLanguages()
$result = Await ($engine.RecognizeAsync($bitmap)) ([Windows.Media.Ocr.OcrResult])
$result.Lines | ForEach-Object { $_.Text }
"""


def ocr(image: pathlib.Path, workdir: pathlib.Path) -> tuple[str, str] | None:
    """(engine, text) from whichever OCR engine exists here, or None."""
    if shutil.which("tesseract"):
        proc = subprocess.run(["tesseract", str(image), "-", "--psm", "6"], capture_output=True, text=True)
        if proc.returncode == 0:
            return "tesseract", proc.stdout
    if sys.platform == "win32" and shutil.which("powershell"):
        script = workdir / "ocr.ps1"
        script.write_text(PS_OCR, encoding="utf-8")
        proc = subprocess.run(["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
                               str(script), "-Path", str(image)], capture_output=True, text=True,
                              timeout=120)
        if proc.returncode == 0 and proc.stdout.strip():
            return "Windows.Media.Ocr", proc.stdout
    return None


def test_ocr_roundtrip() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        m = sr.generate(case(), pathlib.Path(tmp))
        meal = next(r for r in m["receipts"] if r["category"] == "meal")
        got = ocr(pathlib.Path(tmp) / "SOC_UAT_900" / meal["file"], pathlib.Path(tmp))
        if got is None:
            print("OCR round trip: no tesseract and no Windows OCR here, skipped")
            return
        engine, text = got
        print(f"OCR round trip ({engine})")
        flat = re.sub(r"\s+", "", text)
        check("the total is read back", f"{meal['total']:.2f}" in flat, True)
        check("the date is read back", meal["date"] in flat, True)
        check("the merchant is read back", re.sub(r"\s+", "", meal["merchant"]).lower() in flat.lower(),
              True)


if __name__ == "__main__":
    test_amounts()
    test_lint()
    test_parse_synthetic()
    test_parse_046()
    test_generate()
    test_mandatory_fields()
    test_window_late_departure()
    test_not_eligible_skipped()
    test_seeded_046()
    test_ocr_roundtrip()
    if FAILED:
        print(f"\n{len(FAILED)} check(s) failed")
        sys.exit(1)
    print("\nall checks passed")
