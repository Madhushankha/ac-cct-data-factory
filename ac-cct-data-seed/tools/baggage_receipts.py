"""Per-case baggage interim-expense receipts (BAG-05): what a passenger bought while the bag was
missing, as files the receipt reader accepts.

    python tools/baggage_receipts.py --run runs/int/<label> [--only BAG_PO_039,...] [--out <dir>]

Default output: `../ac-cct-data-automation/playwright-baggage/receipts/baggage/<CASE_ID>/`, one
folder per covered case holding one JPG per receipt plus `manifest.json`.

Which cases. There is no Jira snapshot for baggage, so the spec decides: its `source.rule` must be
BAG-05 (interim expenses) and its condition must reach the receipt upload. The conditions that do
not are listed in `SKIP_CONDITIONS` (duplicate claim, OAL last carrier, disputed, no AHL, a closed
file, interim NOT_ELIGIBLE, the customer declining receipts, the delivery question unanswered) and
match the nine scenarios the reference pack (Receipts-bagv65) carries receipts for. A case is also
skipped when the run shows the bag delivered before any expense could arise, or when the engine
answered the bag's interim section NOT_ELIGIBLE.

Every receipt is built from the case itself:

* **where**: the airport the delayed bag was reported missing at (the bag row's `loc`), in that
  airport's currency and sales tax. Merchants are downtown stores, as in the pack.
* **when**: inside the bag's delay window: after the journey's actual arrival and the AHL opening,
  and before the bag was delivered (or the file closed). As in the pack, a delivered bag's receipts
  are dated the arrival day, an undelivered bag's the day after; times fall in store hours.
* **what**: ELIGIBLE categories of the service table (`baggage_interim_expense_categories.py`)
  only: clothing and footwear, personal care, accessories. Never an INELIGIBLE or MANUAL_REVIEW
  word (electronics, charger, luggage, food, ...): `lint` refuses them. Itemised, a subtotal, one
  sales-tax line, `TOTAL <CUR>`; the items plus the tax add up to the total to the cent. Amounts are
  chosen (`amountSource: "chosen"`), realistic, and far under the shared 1519 SDR cap.
* **file name**: the CASE ID, never the PNR (the bagv65 lesson: PNRs rotate on every reseed).

The layout copies the pack (Receipts-bagv65/01_scenarios): a 620-px-wide white JPG, monospace,
store name and address, a `DATE/TIME/STORE/TERMINAL/CARD/INVOICE` block between `=` and `-`
rules, the items in a larger face, SUBTOTAL, the tax line, `TOTAL CAD`, THANK YOU and MERCHANT
COPY. "TEST RECEIPT - QA ONLY" is printed small at the foot (the pack does not; ours always do).

Output is deterministic: the RNG is seeded with the case id, and the files carry no timestamps.
Nothing is uploaded, seeded or sent. This only writes files.
"""
from __future__ import annotations

import argparse
import dataclasses
import datetime as dt
import hashlib
import json
import pathlib
import random
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from tools.soc_receipts import (BANNED_SUBSTRINGS, MARK, SUITE, font, load_pool,   # noqa: E402
                                money, round_half_up)

GENERATOR = "baggage_receipts/1"
DEFAULT_OUT = SUITE / "receipts" / "baggage"
SPEC_DIR = ROOT / "spec" / "baggage" / "sit" / "po"

#: the shared Montreal-convention liability cap, spent by interim AND lost contents together
LIABILITY_CAP_SDR = 1519
#: the lower of the two CAD readings of it in the pack (~2,810 CAD in bagv65's README; a live
#: 2026-09-30 response gave 2,898.85). Only used to keep a case's receipts far below it.
CAP_CAD_APPROX = 2810_00
#: a case's receipts stay under this share of the cap unless the case is about the cap
CAP_SHARE = 0.25

#: upload limits (platform level, Receipts-socv21/04_upload_rules): an image over 10 MB is refused
IMAGE_LIMIT_BYTES = 10 * 1024 * 1024

# ====================================================================== the service table

#: our category -> (service table category, the 8-group answer, verdict). ELIGIBLE rows only are
#: ever rendered; the others are here so a test can prove none of their words appear.
CATEGORIES = {
    "clothing": ("clothing_and_footwear", "clothingAndFootwear", "ELIGIBLE"),
    "footwear": ("clothing_and_footwear", "clothingAndFootwear", "ELIGIBLE"),
    "personal_care": ("personal_care", "cosmeticsAndToiletries", "ELIGIBLE"),
    "accessories": ("accessories", "accessories", "ELIGIBLE"),
}
#: words of the INELIGIBLE and MANUAL_REVIEW rows of the service table (and the pack's BP07..BP13,
#: BP18): no item line may contain one. 'bag' is luggage (manual review); 'spray'/'aerosol' are
#: hazardous; food words are perishables; 'iron' is the curling iron (tools/outdoor, BP11).
FORBIDDEN_WORDS = ("electronic", "phone", "charger", "cable", "speaker", "bluetooth", "headphone",
                   "earbud", "battery", "power bank", "adapter", "laptop", "tablet", "camera",
                   "lamp", "pillow", "blanket", "candle", "toy", "game", "book",
                   "lighter", "aerosol", "spray", "perfume", "nail polish", "bleach", "fuel",
                   "fruit", "snack", "food", "sandwich", "coffee", "drink", "water",
                   "tool", "knife", "iron", "curling", "straightener", "dryer", "tent", "flashlight",
                   "luggage", "suitcase", "bag", "backpack", "duffel", "trolley")

#: (label, price in cents). Worded like the pack's rows; every label passes `lint`.
CATALOG = {
    "clothing": [("Cotton shirt, navy", 5400), ("Chino trousers", 6200), ("Socks, 3 pack", 1800),
                 ("Fleece pullover", 7800), ("Jeans, straight", 7200), ("Shirt, oxford", 6800),
                 ("Sweater, merino", 9200), ("Trousers, wool", 7400), ("Underwear, 3 pack", 2900),
                 ("T-shirt, crew neck", 2400), ("Pyjamas, cotton", 4600), ("Shirt, linen", 5800),
                 ("Shorts, cotton", 4200), ("Hoodie, zip", 6400)],
    "footwear": [("Running shoes", 11000), ("Insoles", 1600), ("Walking shoes", 9800),
                 ("Sandals", 3800), ("Socks, wool 2 pack", 2200)],
    "personal_care": [("Shampoo, 400ml", 1299), ("Toothbrush + paste", 1150),
                      ("Deodorant stick", 849), ("Body wash", 799), ("Razor + 4 blades", 1499),
                      ("Hairbrush", 949), ("Conditioner, 400ml", 1299), ("Face moisturiser", 1699),
                      ("Contact lens solution", 1399), ("Dental floss", 449)],
    "accessories": [("Leather belt", 4400), ("Sunglasses", 3600), ("Wool scarf", 3200),
                    ("Baseball cap", 2800), ("Gloves, knit", 2400)],
}
#: how many lines a receipt of each category carries (the pack: 2 or 3)
LINES = {"clothing": (2, 3), "footwear": (2, 2), "personal_care": (3, 4), "accessories": (2, 2)}

# ====================================================================== locales

@dataclasses.dataclass(frozen=True)
class Locale:
    airport: str
    currency: str
    tax: tuple[str, float]                   # one line, as the pack prints it
    stores: dict                             # category -> [(name, street)]
    city: str                                # appended to the street: "Toronto ON"
    fx_cad: float = 1.0                      # one unit in CAD, for the cap check only


_YYZ_STORES = {
    "clothing": [("NORTHGATE APPAREL", "220 Yonge Street"), ("KING STREET TAILORS", "77 King Street West"),
                 ("HARBOURFRONT CLOTHING CO", "18 Queens Quay West")],
    "footwear": [("STRIDE FOOTWEAR", "220 Bloor Street West")],
    "personal_care": [("CITY PHARMACY", "1 Dundas Street West"), ("UNION DRUG MART", "65 Front Street West")],
    "accessories": [("QUEEN WEST ACCESSORIES", "412 Queen Street West")],
}


def _stores(prefix: str, streets: list[str]) -> dict:
    """A city's stores: one per category, named after the city."""
    return {"clothing": [(f"{prefix} OUTFITTERS", streets[0]), (f"{prefix} APPAREL", streets[1])],
            "footwear": [(f"{prefix} SHOE CO", streets[1])],
            "personal_care": [(f"{prefix} PHARMACY", streets[2])],
            "accessories": [(f"{prefix} ACCESSORIES", streets[0])]}


LOCALES: dict[str, Locale] = {
    "YYZ": Locale("YYZ", "CAD", ("HST 13%", 0.13), _YYZ_STORES, "Toronto ON"),
    "YVR": Locale("YVR", "CAD", ("GST+PST 12%", 0.12),
                  {**_stores("WESTCOAST", ["701 Granville Street", "1055 Robson Street",
                                           "650 West Georgia Street"]),
                   "clothing": [("WESTCOAST OUTFITTERS", "701 Granville Street"),
                                ("ROBSON APPAREL", "1055 Robson Street")]}, "Vancouver BC"),
    "YUL": Locale("YUL", "CAD", ("TPS+TVQ 14.975%", 0.14975),
                  _stores("MONT-ROYAL", ["1500 Rue Sainte-Catherine O", "977 Rue Sainte-Catherine O",
                                         "1001 Boul. De Maisonneuve O"]), "Montreal QC"),
    "YYC": Locale("YYC", "CAD", ("GST 5%", 0.05),
                  _stores("STEPHEN AVE", ["317 7 Ave SW", "120 8 Ave SW", "333 7 Ave SW"]), "Calgary AB"),
    "YEG": Locale("YEG", "CAD", ("GST 5%", 0.05),
                  _stores("JASPER AVE", ["10150 Jasper Ave", "10235 101 St NW", "10025 102A Ave"]),
                  "Edmonton AB"),
    "YOW": Locale("YOW", "CAD", ("HST 13%", 0.13),
                  _stores("RIDEAU", ["50 Rideau Street", "111 Sparks Street", "73 Clarence Street"]),
                  "Ottawa ON"),
    "YHZ": Locale("YHZ", "CAD", ("HST 14%", 0.14),
                  _stores("SPRING GARDEN", ["5640 Spring Garden Rd", "1505 Barrington St",
                                            "5201 Duke St"]), "Halifax NS"),
    "YWG": Locale("YWG", "CAD", ("GST+PST 12%", 0.12),
                  _stores("PORTAGE", ["393 Portage Ave", "201 Portage Ave", "1485 Portage Ave"]),
                  "Winnipeg MB"),
    "LHR": Locale("LHR", "GBP", ("VAT 20%", 0.20),
                  _stores("STRAND", ["210 Oxford Street", "48 Regent Street", "12 Strand"]), "London",
                  fx_cad=1.81),
    "CDG": Locale("CDG", "EUR", ("TVA 20%", 0.20),
                  _stores("RIVOLI", ["120 Rue de Rivoli", "40 Bd Haussmann", "8 Rue Saint-Honore"]),
                  "Paris", fx_cad=1.54),
    "FRA": Locale("FRA", "EUR", ("MwSt 19%", 0.19),
                  _stores("ZEIL", ["Zeil 106", "Goethestrasse 12", "Rossmarkt 7"]), "Frankfurt am Main",
                  fx_cad=1.54),
    "TLV": Locale("TLV", "ILS", ("VAT 18%", 0.18),
                  _stores("DIZENGOFF", ["50 Dizengoff St", "71 Allenby St", "3 Rothschild Blvd"]),
                  "Tel Aviv", fx_cad=0.37),
    "LAX": Locale("LAX", "USD", ("Sales tax 9.5%", 0.095),
                  _stores("WILSHIRE", ["5900 Wilshire Blvd", "6801 Hollywood Blvd", "735 S Figueroa St"]),
                  "Los Angeles CA", fx_cad=1.38),
    "JFK": Locale("JFK", "USD", ("Sales tax 8.875%", 0.08875),
                  _stores("MADISON", ["510 Madison Ave", "1501 Broadway", "34 W 34th St"]),
                  "New York NY", fx_cad=1.38),
}


def locale_for(airport: str) -> tuple[Locale, str]:
    """The locale of an airport, and a note when a generic one is used."""
    if airport in LOCALES:
        return LOCALES[airport], ""
    generic = dataclasses.replace(LOCALES["YYZ"], airport=airport, city=f"{airport} city centre",
                                  stores=_stores(airport, ["1 Main Street", "20 Market Street",
                                                           "5 Station Road"]),
                                  tax=("Sales tax 13%", 0.13))
    return generic, f"no locale for {airport}: a generic CAD/13% receipt was used"


# ====================================================================== which cases

#: a BAG-05 condition that never reaches the receipt upload -> why
SKIP_CONDITIONS = [
    (r"duplicate", "isDuplicateCase: a second claim on the same bag is refused before receipts"),
    (r"not AC last carrier|\bOAL\b", "the last carrier is not AC: no AC interim claim"),
    (r"disputed", "disputed -> GenUC-27: handed off before any receipt step"),
    (r"not isAhlPresent|no open file", "no AHL: there is no delayed-bag file to claim against"),
    (r"closed file", "the AHL is closed: no open delay to buy essentials in"),
    (r"interim NOT_ELIGIBLE", "the case states interim NOT_ELIGIBLE"),
    (r"declin", "the customer declines the receipt invitation: nothing is uploaded"),
    (r"unanswered", "the delivery question is unanswered: the flow stops before receipts"),
]

#: SD -> (categories, the pack's expected outcome per receipt, note). The pack's bagv65 rows, with
#: the categories narrowed to clothing/footwear, personal care and accessories.
SCENARIOS = {
    "SD-05.12": (["clothing"], ["PAID IN FULL (no per-category cap on interim expenses)"],
                 "the clean path (bagv65 B01)"),
    "SD-05.1": (["clothing"], ["PAID IN FULL, priced against the selected bound only"],
                "more than one bound (bagv65 B02); dated inside the bag's bound's delay window"),
    "SD-05.9": (["personal_care"], ["PAID IN FULL under cosmeticsAndToiletries, against ONE chosen AHL"],
                "two open AHLs (bagv65 B03)"),
    "SD-05.14": (["footwear"], ["PAID IN FULL (bought inside the delay window, before the stated "
                                "delivery date)"], "customer states the delivery date (bagv65 B04)"),
    "SD-05.10": (["clothing", "personal_care"],
                 ["PAID IN FULL under clothingAndFootwear", "PAID IN FULL under cosmeticsAndToiletries"],
                 "bag undelivered and undecided (bagv65 B05 used baby_items)"),
    "SD-05.20": (["clothing"], ["INELIGIBLE or capped at the remaining 1519 SDR balance - not paid twice"],
                 "treaty cap already spent (bagv65 B06 used equipment)"),
    "SD-05.15": (["clothing"], ["PAID IN FULL as INTERIM_EXPENSES_DELAYED_BAG (claimIntent must not "
                                "flip to lost contents)"], "undelivered past the lost line (bagv65 B07)"),
    "SD-05.16": (["accessories", "clothing"],
                 ["PAID IN FULL under accessories",
                  "PAID IN FULL - every line clothing_and_footwear, IB_EL_01"],
                 "delivery not confirmed, ADD-02 (bagv65 B08 + B09)"),
    "SD-05.18": (["clothing", "clothing"],
                 ["ELIGIBLE - every line IB_EL_01 INCLUDED", "ELIGIBLE - every line IB_EL_01 INCLUDED"],
                 "bagv65 B10/B11: the pack saw IB_ND_01 NO_DETERMINATION on every line until "
                 "case-services used the SDR cap as the threshold"),
}
DEFAULT_SCENARIO = (["clothing", "personal_care"],
                    ["PAID IN FULL under clothingAndFootwear", "PAID IN FULL under cosmeticsAndToiletries"],
                    "no bagv65 row for this condition: clothing and personal care chosen")
#: cases about the cap: the receipt says so but its amount stays ordinary (the cap is spent before)
CAP_CASES = {"SD-05.20"}


def classify(spec: dict) -> tuple[bool, str]:
    """(is an interim-expense case that reaches the upload, why not)."""
    src = spec.get("source") or {}
    rule = src.get("rule") or ""
    if rule != "BAG-05":
        return False, f"not an interim-expense case ({rule or 'no BAG rule'}: {src.get('sd') or ''})"
    cond = f"{src.get('condition') or ''} {spec.get('summary') or ''}"
    for rx, why in SKIP_CONDITIONS:
        if re.search(rx, cond, re.I):
            return False, why
    bag = spec.get("expectBag") or {}
    shape = (spec.get("bagPlan") or {}).get("shape") or bag.get("bagEventShape") or ""
    if shape in ("no_ahl", "no_bag") or not bag.get("isAhlPresent", True):
        return False, f"bag shape {shape}: no open AHL"
    if "closed" in shape:
        return False, f"bag shape {shape}: the file is closed"
    if bag.get("isOal"):
        return False, "the last carrier is OAL"
    return True, ""


# ====================================================================== case facts

def _local(s: str | None) -> dt.datetime | None:
    """'Oct 16, 2026 12:40 AM' (a run record's local time at that airport) -> datetime."""
    if not s:
        return None
    try:
        return dt.datetime.strptime(s.strip(), "%b %d, %Y %I:%M %p")
    except ValueError:
        return None


@dataclasses.dataclass
class Case:
    case_id: str
    kit_case: str
    sd: str
    rule: str
    condition: str
    pnr: str
    first: str
    last: str
    airport: str                  # where the bag was reported missing
    flight: str                   # the flight the bag arrived on (late)
    arrival: dt.datetime          # actual arrival, local
    ahl_opened: dt.datetime | None
    ahl: str
    window_end: dt.datetime | None   # delivery (or closure), local; None while undelivered
    delivered: bool
    interim_code: str | None      # what the engine answered for the bag's interim section


def bag_window(record: dict) -> dict | None:
    """The delayed bag's facts from a run record: the first bag row with an AHL, the segment it
    arrived on, and its delivery/closure. None when no bag has an AHL."""
    seen = record.get("seen") or {}
    bags = [b for b in seen.get("baggage") or [] if b.get("ahl")]
    if not bags:
        return None
    bag = bags[0]
    airport = bag.get("loc") or ""
    ahl_at = _local(bag.get("ahlAt"))
    segs = [s for s in seen.get("segments") or [] if s.get("to") == airport]
    arrivals = [(_local(s.get("actualArr")) or _local(s.get("schedArr")), s) for s in segs]
    arrivals = [(t, s) for t, s in arrivals if t]
    if ahl_at:
        before = [(t, s) for t, s in arrivals if t <= ahl_at]
        arrivals = before or arrivals
    arrival, seg = max(arrivals, key=lambda x: x[0]) if arrivals else (ahl_at, {})
    events = {e: _local(at) for e, at in bag.get("events") or []}
    delivered = events.get("BAG_DELIVERED_TO_CAROUSEL")
    closed = events.get("BAG_DELAYED_RECORD_CLOSED")
    end = min([t for t in (delivered, closed) if t], default=None)
    code = None
    for bound in (record.get("document") or {}).get("bounds") or []:
        for block in bound.get("baggageClaimEligibility") or []:
            for pax in block.get("passengerEligibility") or []:
                for b in pax.get("bags") or []:
                    if b.get("ahlCaseId") == bag.get("ahl") and code is None:
                        code = (b.get("interimExpensesEligibility") or {}).get("systemCode")
    return {"airport": airport, "arrival": arrival, "ahl_opened": ahl_at, "ahl": bag.get("ahl"),
            "end": end, "delivered": delivered is not None, "flight": seg.get("flight") or "",
            "interim_code": code, "open_ahls": len({b.get("ahl") for b in bags})}


def load_case(record: dict, pool: dict[str, dict]) -> tuple[Case | None, str]:
    """A run record -> the case facts, or (None, why it is skipped)."""
    case_id = str(record.get("case") or "").split("#")[0]
    spec_path = SPEC_DIR / f"{case_id}.json"
    if not spec_path.exists():
        return None, "no spec"
    spec = json.loads(spec_path.read_text(encoding="utf-8"))
    ok, why = classify(spec)
    if not ok:
        return None, why
    w = bag_window(record)
    if w is None or w["arrival"] is None:
        return None, "the run shows no bag with an AHL"
    if str(w["interim_code"] or "").startswith("BAG-IE-NE"):
        return None, f"the engine answered the bag's interim section {w['interim_code']}"
    if w["end"] is not None and w["end"] <= max(w["arrival"], w["ahl_opened"] or w["arrival"]) \
            + dt.timedelta(minutes=60):
        return None, "the bag was delivered before any expense could arise"
    src = spec.get("source") or {}
    row = pool.get(case_id.upper()) or pool.get(str(record.get("locator") or "").upper()) or {}
    return Case(case_id, str(src.get("case_id") or ""), str(src.get("sd") or ""),
                str(src.get("rule") or ""), str(src.get("condition") or ""),
                str(record.get("locator") or row.get("pnr") or ""),
                str(row.get("first") or ""), str(row.get("last") or ""),
                w["airport"], w["flight"] or str(record.get("flight") or ""), w["arrival"],
                w["ahl_opened"], str(w["ahl"] or ""), w["end"], w["delivered"], w["interim_code"]), ""


# ====================================================================== when

OPEN, CLOSE = dt.time(9, 0), dt.time(20, 30)


def purchase_slot(case: Case) -> tuple[dt.datetime, dt.datetime, str]:
    """[earliest, latest] purchase time inside the delay window and store hours, and a note.

    As in the pack: a delivered bag's receipts are dated the first day the stores are open inside
    the window (usually the arrival day); an undelivered bag's the day after arrival."""
    earliest = max(case.arrival, case.ahl_opened or case.arrival) + dt.timedelta(minutes=30)
    latest = case.window_end - dt.timedelta(minutes=30) if case.window_end else None
    first_day = earliest.date() if case.window_end else case.arrival.date() + dt.timedelta(days=1)
    for k in range(0, 5):
        day = first_day + dt.timedelta(days=k)
        lo = max(earliest, dt.datetime.combine(day, OPEN))
        hi = dt.datetime.combine(day, CLOSE)
        if latest is not None:
            hi = min(hi, latest)
        if hi - lo >= dt.timedelta(minutes=45):
            return lo, hi, ""
        if latest is not None and dt.datetime.combine(day, OPEN) > latest:
            break
    if latest is not None and latest > earliest:
        return earliest, latest, "the delay window holds no store hours: timed outside them"
    raise ValueError(f"{case.case_id}: no time inside the delay window")


def schedule(n: int, lo: dt.datetime, hi: dt.datetime, rng: random.Random) -> list[dt.datetime]:
    """n purchase times, in order and at least 20 minutes apart, inside [lo, hi]."""
    span = int((hi - lo).total_seconds() // 60)
    gap = min(20, span // max(1, n))
    first = rng.randint(min(60, span // 3), max(min(60, span // 3), span // 2)) if n == 1 else \
        rng.randint(0, max(0, span - gap * (n - 1)) // 2)
    times, t = [], lo + dt.timedelta(minutes=first)
    for i in range(n):
        if i:
            room = int((hi - t).total_seconds() // 60) - gap * (n - 1 - i)
            t += dt.timedelta(minutes=max(gap, min(room, rng.randint(gap, gap + 50))))
        times.append(min(t, hi))
    return times


# ====================================================================== the receipt

@dataclasses.dataclass
class Receipt:
    category: str
    merchant: str
    street: str
    city: str
    when: dt.datetime
    store: str
    terminal: str
    card: str
    invoice: str
    currency: str
    items: list[tuple[str, int]]
    tax: tuple[str, int]
    total: int

    @property
    def subtotal(self) -> int:
        return sum(a for _, a in self.items)


def rows(r: Receipt) -> list[tuple[str, str, str]]:
    """The receipt as (style, left, right) rows; also the text model the tests read."""
    out = [("title", r.merchant, ""), ("addr", f"{r.street}, {r.city}", ""), ("rule2", "", "")]
    for k, v in (("DATE", r.when.date().isoformat()), ("TIME", r.when.strftime("%H:%M")),
                 ("STORE", r.store), ("TERMINAL", r.terminal), ("CARD", f"VISA ****{r.card}"),
                 ("INVOICE", r.invoice)):
        out.append(("kv", k, v))
    out.append(("rule1", "", ""))
    out += [("item", label, money(a)) for label, a in r.items]
    out += [("rule1", "", ""), ("item", "SUBTOTAL", money(r.subtotal)),
            ("item", r.tax[0], money(r.tax[1])), ("total", f"TOTAL {r.currency}", money(r.total)),
            ("rule2", "", ""), ("foot", "THANK YOU", ""), ("foot", "MERCHANT COPY", ""),
            ("mark", MARK, "")]
    return out


def text_lines(r: Receipt) -> list[str]:
    out = []
    for style, left, right in rows(r):
        if style == "rule1":
            out.append("-" * 40)
        elif style == "rule2":
            out.append("=" * 40)
        else:
            out.append(f"{left}  {right}".strip() if right else left)
    return out


def lint(r: Receipt) -> list[str]:
    """Item lines that would read as another category, an ineligible good, alcohol or a tip."""
    bad = []
    for label, _ in r.items:
        low = f" {label.lower()} "
        bad += [f"{label!r} contains {w!r}" for w in FORBIDDEN_WORDS if re.search(rf"\b{w}", low)]
        bad += [f"{label!r} contains {w!r}" for w in BANNED_SUBSTRINGS if w in low]
    return bad


def build_receipt(case: Case, category: str, loc: Locale, when: dt.datetime, idx: int,
                  rng: random.Random, card: str, used: set[str]) -> Receipt:
    stores = [s for s in loc.stores[category] if s[0] not in used] or loc.stores[category]
    name, street = stores[0]
    used.add(name)
    lo, hi = LINES[category]
    picks = rng.sample(CATALOG[category], rng.randint(lo, hi))
    scale = 1.0 / loc.fx_cad if loc.currency != "CAD" else 1.0
    items = []
    for label, cad in picks:
        price = cad if scale == 1.0 else max(100, int(round(cad * scale / 50.0)) * 50 - 1)
        items.append((label, price))
    sub = sum(a for _, a in items)
    tax = round_half_up(sub * loc.tax[1])
    prefix = "".join(w[0] for w in re.findall(r"[A-Z][A-Z-]+", name)[:2]) or "QA"
    invoice = f"{prefix}-{rng.randint(10000, 99999)}{idx}"
    return Receipt(category, name, street, loc.city, when, str(rng.randint(1001, 9899)),
                   f"{rng.randint(1, 12):02d}", card, invoice, loc.currency, items,
                   (loc.tax[0], tax), sub + tax)


# ====================================================================== rendering

def render(r: Receipt, path: pathlib.Path) -> None:
    """The pack's layout: 620 px wide, white, unrotated, monospace (Lucida Console: Windows OCR
    reads Consolas's 0 as 'e')."""
    from PIL import Image, ImageDraw
    ink, mid, grey = (20, 20, 20), (50, 50, 50), (110, 110, 110)
    # items at 20 px: Windows OCR reads Lucida Console's 0 as 'o' at 19 px ("92 . oo"), exactly at 20+
    ft, fa, fk, fi, fl = font("mono", 23), font("mono", 14), font("mono", 15), font("mono", 20), \
        font("mono", 23)
    fm = font("mono", 11)
    x0, right, W = 38, 582, 620
    model = rows(r)
    height = 52
    step = {"title": 30, "addr": 26, "rule2": 22, "kv": 24, "rule1": 26, "item": 30, "total": 34,
            "foot": 24, "mark": 26}
    height += sum(step[s] for s, _, _ in model) + 18
    im = Image.new("RGB", (W, height), (255, 255, 255))
    d = ImageDraw.Draw(im)
    y = 38
    for style, left, val in model:
        if style == "title":
            d.text((x0, y), left, font=ft, fill=ink)
        elif style == "addr":
            d.text((x0, y), left, font=fa, fill=grey)
        elif style in ("rule1", "rule2"):
            ch = "-" if style == "rule1" else "="
            n = int((398 - x0) // d.textlength(ch, font=fk))
            d.text((x0, y - 4), ch * n, font=fk, fill=grey)
        elif style == "kv":
            d.text((x0, y), left, font=fk, fill=mid)
            d.text((182, y), val, font=fk, fill=mid)
        elif style in ("item", "total"):
            f = fl if style == "total" else fi
            if style == "total":
                y += 2
            d.text((x0, y), left, font=f, fill=ink)
            d.text((right - d.textlength(val, font=f), y), val, font=f, fill=ink)
        elif style == "foot":
            d.text((x0, y), left, font=fk, fill=grey)
        elif style == "mark":
            d.text((x0, y + 6), left, font=fm, fill=(170, 170, 170))
        y += step[style]
    path.parent.mkdir(parents=True, exist_ok=True)
    im.save(path, "JPEG", quality=90, optimize=False)


# ====================================================================== a case's receipts

def judge_text(category: str, expected: str, cur: str, total: int) -> str:
    name = category.replace("_", " ")
    if expected.startswith("INELIGIBLE or capped"):
        return (f"The assistant does not pay the {name} receipt for {cur} {money(total)} in full: "
                f"the shared {LIABILITY_CAP_SDR} SDR liability cap is already spent, so it is refused "
                f"or capped at the remaining balance (never paid twice)")
    return (f"The assistant accepts the {name} receipt for {cur} {money(total)} as an interim "
            f"expense for the delayed bag and approves it (or shows it in the expense summary)")


def generate(case: Case, out_dir: pathlib.Path, label: str = "") -> dict:
    rng = random.Random(int(hashlib.sha256(case.case_id.encode()).hexdigest()[:12], 16))
    loc, loc_note = locale_for(case.airport)
    cats, expects, scen_note = SCENARIOS.get(case.sd, DEFAULT_SCENARIO)
    notes = [n for n in (scen_note, loc_note) if n]
    lo, hi, slot_note = purchase_slot(case)
    if slot_note:
        notes.append(slot_note)
    times = schedule(len(cats), lo, hi, rng)
    card = f"{rng.randint(1000, 9999)}"
    folder = out_dir / case.case_id
    folder.mkdir(parents=True, exist_ok=True)
    for old in folder.glob(f"{case.case_id}_*"):
        old.unlink()
    window = {"from": case.arrival.strftime("%Y-%m-%d %H:%M"),
              "ahlOpened": case.ahl_opened.strftime("%Y-%m-%d %H:%M") if case.ahl_opened else None,
              "to": case.window_end.strftime("%Y-%m-%d %H:%M") if case.window_end else None,
              "bagDelivered": case.delivered, "timezone": f"local at {case.airport}",
              "purchase": [lo.strftime("%Y-%m-%d %H:%M"), hi.strftime("%Y-%m-%d %H:%M")]}
    entries, used, claimed = [], set(), 0
    for i, (cat, when) in enumerate(zip(cats, times), 1):
        r = build_receipt(case, cat, loc, when, i, rng, card, used)
        bad = lint(r)
        if bad:
            raise ValueError(f"{case.case_id} receipt {i}: {bad}")
        name = f"{case.case_id}_{i}_{cat}_{case.airport}.jpg"
        path = folder / name
        render(r, path)
        if path.stat().st_size >= IMAGE_LIMIT_BYTES:
            raise ValueError(f"{name} is over the 10 MB image upload limit")
        claimed += int(r.total * loc.fx_cad)
        try:
            rel = path.resolve().relative_to(SUITE.resolve()).as_posix()
        except ValueError:
            rel = None
        service, group, verdict = CATEGORIES[cat]
        expected = expects[i - 1] if i - 1 < len(expects) else expects[-1]
        entries.append({
            "file": name, "path": rel, "category": cat, "serviceCategory": service, "group": group,
            "categoryVerdict": verdict, "currency": r.currency,
            "total": round(r.total / 100, 2), "subtotal": round(r.subtotal / 100, 2),
            "taxes": [{"label": r.tax[0], "amount": round(r.tax[1] / 100, 2)}],
            "items": [{"label": l, "amount": round(a / 100, 2)} for l, a in r.items],
            "date": r.when.date().isoformat(), "time": r.when.strftime("%H:%M"),
            "merchant": r.merchant, "street": r.street, "city": r.city, "airport": case.airport,
            "receiptNumber": r.invoice, "expected": expected,
            "rule": f"{case.rule} · {case.sd} · {case.condition}".strip(" ·"),
            "amountSource": "chosen", "window": window,
            "judge": judge_text(cat, expected, r.currency, r.total),
            "approved": None, "cap": None,
        })
    limit = CAP_CAD_APPROX if case.sd in CAP_CASES else int(CAP_CAD_APPROX * CAP_SHARE)
    if claimed >= limit:
        raise ValueError(f"{case.case_id}: receipts total ~CAD {money(claimed)}, over {money(limit)}")
    manifest = {
        "generator": GENERATOR, "case": case.case_id, "kitCase": case.kit_case, "sd": case.sd,
        "rule": case.rule, "condition": case.condition, "run": label, "pnr": case.pnr,
        "passenger": f"{case.first} {case.last}".strip(), "airport": case.airport,
        "flight": case.flight, "ahl": case.ahl, "engineInterim": case.interim_code,
        "liabilityCapSDR": LIABILITY_CAP_SDR,
        "claimedCADApprox": round(claimed / 100, 2),
        "window": window, "receipts": entries, "notes": notes,
    }
    (folder / "manifest.json").write_text(json.dumps(manifest, indent=1, ensure_ascii=False) + "\n",
                                          encoding="utf-8")
    return manifest


# ====================================================================== CLI

def run(run_dir: pathlib.Path, out_dir: pathlib.Path, only: set[str]) -> dict:
    label = run_dir.name
    pool = load_pool(label)
    covered, skipped, errors = [], [], []
    for path in sorted(run_dir.glob("*.json")):
        if path.name.startswith("_"):
            continue
        record = json.loads(path.read_text(encoding="utf-8"))
        cid = str(record.get("case") or path.stem).split("#")[0]
        if only and cid.upper() not in only:
            continue
        try:
            case, why = load_case(record, pool)
            if case is None:
                skipped.append((cid, why))
                continue
            if not case.first:
                errors.append((cid, f"no pool booking for {case.pnr} in {label.lower()}.yaml"))
                continue
            covered.append(generate(case, out_dir, label))
        except Exception as exc:                                   # noqa: BLE001
            errors.append((cid, f"{type(exc).__name__}: {exc}"))
    return {"covered": covered, "skipped": skipped, "errors": errors}


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--run", required=True, help="a run folder, e.g. runs/int/baggage-sit-po-1020T1020")
    ap.add_argument("--only", default="", help="comma-separated case ids")
    ap.add_argument("--out", default="", help=f"default: {DEFAULT_OUT}")
    ap.add_argument("--verbose", action="store_true", help="list every skipped case and why")
    args = ap.parse_args(argv)
    run_dir = pathlib.Path(args.run)
    if not run_dir.is_absolute():
        run_dir = (ROOT / run_dir) if (ROOT / run_dir).exists() else run_dir
    if not run_dir.is_dir():
        print(f"no run folder {run_dir}")
        return 1
    out = pathlib.Path(args.out) if args.out else DEFAULT_OUT
    only = {c.strip().upper() for c in args.only.split(",") if c.strip()}
    res = run(run_dir, out, only)
    for m in res["covered"]:
        files = ", ".join(f"{r['file']} ({r['currency']} {r['total']:.2f} on {r['date']} {r['time']})"
                          for r in m["receipts"])
        print(f"{m['case']} {m['sd']} {m['pnr']} {m['passenger']} @ {m['airport']}: {files}")
    print(f"\n{len(res['covered'])} interim-expense case(s) covered -> {out}")
    print(f"{len(res['skipped'])} case(s) skipped")
    interim = [(c, w) for c, w in res["skipped"] if not w.startswith("not an interim-expense case")]
    for cid, why in (res["skipped"] if args.verbose else interim):
        print(f"    {cid}: {why}")
    if not args.verbose and len(interim) < len(res["skipped"]):
        print(f"    ({len(res['skipped']) - len(interim)} not BAG-05; --verbose lists them)")
    for cid, err in res["errors"]:
        print(f"ERROR {cid}: {err}")
    return 1 if res["errors"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
