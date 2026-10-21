"""Per-case Standards of Care receipts: the expenses each eligible SOC test claims, as files a
receipt reader accepts.

    python tools/soc_receipts.py --run runs/int/<label> [--only SOC_UAT_046,...] [--out <dir>]

Default output: `../ac-cct-data-automation/playwright-baggage/receipts/soc/<CASE_ID>/`, one folder
per eligible case holding one file per expense plus `manifest.json`.

Why per case. The automation used one generic SOC set (SOC_UAT_046's amounts, a fixed date) for
every case, so every other case uploaded receipts dated on the wrong day, at the wrong airport, for
amounts its Jira test does not state. The reader refuses or prices those, and the chat goes down a
path the test does not describe. Here every receipt is built from the case itself:

* **where**: the airport the passenger was stranded at. That is the origin of the first disrupted
  segment, as SEEDED: the run record's published flight key (`AC#859#2026-10-08#YYZ`).
* **when**: the disruption day as seeded, from the same key. Times fall inside the window, from the
  scheduled departure to the end of that day. The reference pack's P05 and P06 show that a receipt
  dated the day before or the day after is out of the one-day window (ML_NE_01). Its P11 shows that a
  folio dated at check-out is ineligible.
* **who**: the pool booking's first and last name. Only the hotel folio prints a guest.
* **what**: the Jira text's `Receipt N: <what> - <amount> <CUR> (<note>)` lines, with the test's own
  line items where it lists them. When a category is mentioned without an amount, an amount under the
  stated cap is chosen and the manifest says so (`amountSource: "chosen"`).

The layout copies the reference pack (soc-sit-int-v37-receipts). Meals, taxi, essentials,
communication and parking are thermal-style JPGs: a light paper on grey, a slight rotation and a
monospace font. Hotels are A4 image-PDF folios. Every receipt carries the merchant, street, city and
postal code, phone, tax registration, date and time, receipt number, itemised lines, subtotal, the
tax lines, `TOTAL <CUR>`, the card line with auth and APPROVED, and a thank-you line. The items plus
the taxes add up to the total to the cent. "TEST RECEIPT - QA ONLY" is printed small at the foot.

Output is deterministic: the RNG is seeded with the case id, and the files carry no timestamps.
Nothing is uploaded, seeded or sent. This only writes files.
"""
from __future__ import annotations

import argparse
import dataclasses
import datetime as dt
import glob
import hashlib
import json
import pathlib
import random
import re
import sys
from typing import Any

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

GENERATOR = "soc_receipts/1"
SUITE = ROOT.parent / "ac-cct-data-automation" / "playwright-baggage"
DEFAULT_OUT = SUITE / "receipts" / "soc"
SPEC_DIR = ROOT / "spec" / "soc" / "uat" / "automation"
JIRA_DIR = ROOT / "jira" / "soc" / "uat" / "automation"
POOLS_DIR = SUITE / "data" / "pools"

CATEGORIES = ("hotel", "meal", "transport", "essentials", "communication", "parking")

#: approximate value of one unit in CAD. Used only to compare a receipt with a cap held in another
#: currency, and to re-denominate the rare Jira amount stated in a currency the stranding airport
#: does not use. EUR comes from SOC_UAT_046's own conversion ($185 CAD = EUR 120).
FX_CAD = {"CAD": 1.0, "EUR": 1.54, "GBP": 1.81, "ILS": 0.37, "USD": 1.38}

#: what the INT reader does, per the reference pack's index.csv (CAD caps, verified there)
INT_CAPS = {"meal": (150_00, "ML_PE_02"), "transport": (250_00, "TR_PE_02"),
            "hotel": (500_00, "AC_PE_02")}
#: the rule code a Jira cap breach maps to, by category (the pack names the first three)
CAP_RULE = {"meal": "ML_PE_02", "transport": "TR_PE_02", "hotel": "AC_PE_02"}

#: words the reader treats as alcohol or tip lines (P03, P04), plus 'gin', which P16 shows matches
#: as a substring ("Lodging tax" is deducted as alcohol). No item or tax line may contain these.
BANNED_SUBSTRINGS = ("gin", "beer", "wine", "vodka", "whisk", "lager", "cider", "rum ", "tip",
                     "gratuit", "pourboire")


# ====================================================================== money

def cents(value: float | str) -> int:
    return int(round(float(str(value).replace(",", "")) * 100))


def money(c: int) -> str:
    return f"{c // 100:,}.{c % 100:02d}" if c >= 0 else "-" + money(-c)


def round_half_up(x: float) -> int:
    return int(x + 0.5 + 1e-9) if x >= 0 else -round_half_up(-x)


# ====================================================================== locales

@dataclasses.dataclass(frozen=True)
class Locale:
    airport: str
    country: str
    currency: str
    city: str                     # "Mississauga, ON L5P 1B2"
    phone: str                    # "905-555-01" + 2 digits
    tax_ids: tuple[str, ...]
    taxes: dict                   # category -> ((label, rate), ...)
    hotel_levy: tuple[str, float, bool] | None   # (label, rate or fixed CAD-cents if rate>=1, in VAT base)
    merchants: dict               # category -> (name, street)
    hotel_street: str
    hotel_city: str
    thanks: str = "Thank you! / Merci!"
    symbol: str = "$"
    note: str = ""
    hotel_note: str = ""


def _ca_taxes(meal, other=None, transport=None, hotel=None):
    other = other or meal
    return {"meal": meal, "essentials": other, "communication": other, "parking": other,
            "transport": transport or meal, "hotel": hotel or other}


HST13 = (("HST 13%", 0.13),)
QC = (("GST/TPS 5%", 0.05), ("QST/TVQ 9.975%", 0.09975))
GST5 = (("GST 5%", 0.05),)

LOCALES: dict[str, Locale] = {
    "YYZ": Locale("YYZ", "CA", "CAD", "Mississauga, ON L5P 1B2", "905-555-01",
                  ("HST# 786123450 RT0001",), _ca_taxes(HST13),
                  ("Municipal accommodation tax 4%", 0.04, True),
                  {"meal": ("Pearson Pier Kitchen", "6301 Silver Dart Dr, Terminal 1"),
                   "transport": ("Malton Airport Taxi", "6301 Silver Dart Dr, Door D"),
                   "essentials": ("Terminal One Pharmacy", "6301 Silver Dart Dr, Terminal 1"),
                   "communication": ("SkyLink Mobile Kiosk", "6301 Silver Dart Dr, Terminal 1"),
                   "parking": ("Pearson Park & Fly", "5965 Airport Rd"),
                   "hotel": ("Pearson Gateway Suites", "")},
                  "6200 Airport Rd", "Mississauga, ON L4V 1E4"),
    "YUL": Locale("YUL", "CA", "CAD", "Dorval, QC H4Y 1H1", "514-555-01",
                  ("TPS/GST 781204559 RT0001", "TVQ/QST 1219936021 TQ0001"), _ca_taxes(QC),
                  ("Accommodation tax 3.5%", 0.035, True),
                  {"meal": ("Cafe Dorval Depart", "975 Boul. Romeo-Vachon Nord"),
                   "transport": ("Taxi Dorval Express", "975 Boul. Romeo-Vachon Nord"),
                   "essentials": ("Pharmacie Aerogare", "975 Boul. Romeo-Vachon Nord"),
                   "communication": ("Kiosque Mobile Dorval", "975 Boul. Romeo-Vachon Nord"),
                   "parking": ("Stationnement Aerogare Dorval", "800 Place Leigh-Capreol"),
                   "hotel": ("Hotel Aerogare Dorval", "")},
                  "2050 Chemin de la Cote-de-Liesse", "Dorval, QC H9P 1B2"),
    "YYC": Locale("YYC", "CA", "CAD", "Calgary, AB T2E 6W5", "403-555-01",
                  ("GST# 784512309 RT0001",),
                  _ca_taxes(GST5), ("Tourism levy 4%", 0.04, False),
                  {"meal": ("Bow Valley Airport Grill", "2000 Airport Rd NE, Gate A"),
                   "transport": ("Calgary Airport Cab Co.", "2000 Airport Rd NE, Door 7"),
                   "essentials": ("Chinook Travel Pharmacy", "2000 Airport Rd NE"),
                   "communication": ("Prairie Mobile Kiosk", "2000 Airport Rd NE"),
                   "parking": ("YYC Park & Jet Lot", "2525 Barlow Trail NE"),
                   "hotel": ("Barlow Trail Airport Inn", "")},
                  "2001 Airport Rd NE", "Calgary, AB T2E 6Z8"),
    "YVR": Locale("YVR", "CA", "CAD", "Richmond, BC V7B 1Y7", "604-555-01",
                  ("GST# 789012345 RT0001", "PST# PST-1234-5678"),
                  {"meal": GST5, "transport": GST5,
                   "essentials": (("GST 5%", 0.05), ("PST 7%", 0.07)),
                   "communication": (("GST 5%", 0.05), ("PST 7%", 0.07)),
                   "parking": (("GST 5%", 0.05), ("PST 7%", 0.07)),
                   "hotel": (("GST 5%", 0.05), ("PST 8%", 0.08))},
                  ("Municipal regional district tax 3%", 0.03, True),
                  {"meal": ("Sea Island Kitchen", "3211 Grant McConachie Way"),
                   "transport": ("Richmond Airport Taxi", "3211 Grant McConachie Way"),
                   "essentials": ("Sea Island Pharmacy", "3211 Grant McConachie Way"),
                   "communication": ("Fraser Mobile Kiosk", "3211 Grant McConachie Way"),
                   "parking": ("Sea Island Park & Fly", "4900 Miller Rd"),
                   "hotel": ("Sea Island Airport Hotel", "")},
                  "3031 Grant McConachie Way", "Richmond, BC V7B 0A6"),
    "YOW": Locale("YOW", "CA", "CAD", "Ottawa, ON K1V 9B4", "613-555-01",
                  ("HST# 786543210 RT0001",), _ca_taxes(HST13),
                  ("Municipal accommodation tax 4%", 0.04, True),
                  {"meal": ("Uplands Departures Cafe", "1000 Airport Pkwy Private"),
                   "transport": ("Uplands Airport Taxi", "1000 Airport Pkwy Private"),
                   "essentials": ("Rideau Travel Pharmacy", "1000 Airport Pkwy Private"),
                   "communication": ("Capital Mobile Kiosk", "1000 Airport Pkwy Private"),
                   "parking": ("Uplands Park & Fly", "1200 Airport Pkwy"),
                   "hotel": ("Uplands Airport Suites", "")},
                  "2400 Alert Rd", "Ottawa, ON K1V 1S1"),
    "YHZ": Locale("YHZ", "CA", "CAD", "Goffs, NS B2T 1K2", "902-555-01",
                  ("HST# 787654321 RT0001",), _ca_taxes((("HST 14%", 0.14),)),
                  ("Marketing levy 3%", 0.03, True),
                  {"meal": ("Harbour Gate Kitchen", "1 Bell Blvd, Departures"),
                   "transport": ("Enfield Airport Taxi", "1 Bell Blvd, Door 3"),
                   "essentials": ("Bell Blvd Pharmacy", "1 Bell Blvd"),
                   "communication": ("Atlantic Mobile Kiosk", "1 Bell Blvd"),
                   "parking": ("Bell Blvd Park & Fly", "40 Bell Blvd"),
                   "hotel": ("Goffs Airport Hotel", "")},
                  "60 Bell Blvd", "Enfield, NS B2T 1K3"),
    "LHR": Locale("LHR", "GB", "GBP", "Hounslow TW6 1AP", "020 7946 01",
                  ("VAT Reg No. GB 284 5512 07",),
                  {c: (("VAT 20%", 0.20),) for c in CATEGORIES}, None,
                  {"meal": ("Bath Road Kitchen", "Terminal 3 Departures, Heathrow"),
                   "transport": ("Heathrow Cabs Ltd", "Bath Road, Harlington"),
                   "essentials": ("Terminal Three Chemist", "Terminal 3 Departures, Heathrow"),
                   "communication": ("Airside Mobile Kiosk", "Terminal 3 Departures, Heathrow"),
                   "parking": ("Northside Airport Parking", "Northern Perimeter Rd"),
                   "hotel": ("Heathrow Bath Road Hotel", "")},
                  "140 Bath Road", "Hayes UB3 5AN", thanks="Thank you for your visit", symbol="",
                  note="UK prices: net + VAT 20% shown as separate lines"),
    "CDG": Locale("CDG", "FR", "EUR", "95700 Roissy-en-France", "01 70 55 01",
                  ("SIRET 812 345 678 00012", "TVA FR12812345678"),
                  {"meal": (("TVA 10%", 0.10),), "transport": (("TVA 10%", 0.10),),
                   "hotel": (("TVA 10%", 0.10),), "essentials": (("TVA 20%", 0.20),),
                   "communication": (("TVA 20%", 0.20),), "parking": (("TVA 20%", 0.20),)},
                  ("Taxe de sejour (1 nuit)", 325, False),
                  {"meal": ("Brasserie Roissy Depart", "Terminal 2E, Porte K"),
                   "transport": ("Taxi Roissy Express", "Terminal 2E, Porte 10"),
                   "essentials": ("Pharmacie Terminal 2", "Terminal 2E, Niveau Depart"),
                   "communication": ("Kiosque Mobile Roissy", "Terminal 2E, Niveau Depart"),
                   "parking": ("Parking Roissy Pole", "Rue des Vignes"),
                   "hotel": ("Hotel Roissy Aeroport", "")},
                  "5 Allee du Verger", "95700 Roissy-en-France", thanks="Merci / Thank you",
                  symbol=""),
    "FRA": Locale("FRA", "DE", "EUR", "60549 Frankfurt am Main", "069 555 01",
                  ("USt-IdNr. DE281234567",),
                  {"meal": (("MwSt 19%", 0.19),), "transport": (("MwSt 7%", 0.07),),
                   "hotel": (("MwSt 7%", 0.07),), "essentials": (("MwSt 19%", 0.19),),
                   "communication": (("MwSt 19%", 0.19),), "parking": (("MwSt 19%", 0.19),)},
                  None,
                  {"meal": ("Main Airport Bistro", "Terminal 1, Halle B"),
                   "transport": ("Taxi Flughafen Frankfurt", "Terminal 1, Ankunft B"),
                   "essentials": ("Flughafen Apotheke T1", "Terminal 1, Halle B"),
                   "communication": ("Mobile Kiosk T1", "Terminal 1, Halle B"),
                   "parking": ("Parkhaus P36", "Hugo-Eckener-Ring"),
                   "hotel": ("Airport Ring Hotel", "")},
                  "Hugo-Eckener-Ring 15", "60549 Frankfurt am Main", thanks="Danke / Thank you",
                  symbol=""),
    "TLV": Locale("TLV", "IL", "ILS", "Lod 7015001, Israel", "03-555-01",
                  ("VAT No. 514123456",),
                  {c: (("VAT 18%", 0.18),) for c in CATEGORIES}, None,
                  {"meal": ("Terminal 3 Cafe", "Ben Gurion Airport, Terminal 3"),
                   "transport": ("Airport City Taxi", "Ben Gurion Airport, Terminal 3"),
                   "essentials": ("Terminal 3 Pharm", "Ben Gurion Airport, Terminal 3"),
                   "communication": ("Mobile Point T3", "Ben Gurion Airport, Terminal 3"),
                   "parking": ("Ben Gurion Parking", "Ben Gurion Airport"),
                   "hotel": ("Airport City Hotel", "")},
                  "Airport City, 1 Hamelacha St", "Lod 7019900, Israel", thanks="Toda / Thank you",
                  symbol="", hotel_note="VAT 18% charged on the hotel too (non-resident exemption not modelled)"),
    "HFA": Locale("HFA", "IL", "ILS", "Haifa 3303001, Israel", "04-555-01",
                  ("VAT No. 514765432",),
                  {c: (("VAT 18%", 0.18),) for c in CATEGORIES}, None,
                  {"meal": ("Haifa Airport Cafe", "Haifa Airport, Departures"),
                   "transport": ("Haifa Bay Taxi", "Haifa Airport, Exit 1"),
                   "essentials": ("Bay Pharm Haifa", "Haifa Airport, Departures"),
                   "communication": ("Mobile Point Haifa", "Haifa Airport, Departures"),
                   "parking": ("Haifa Airport Parking", "Haifa Airport"),
                   "hotel": ("Haifa Bay Hotel", "")},
                  "12 HaHistadrut Blvd", "Haifa 3303001, Israel", thanks="Toda / Thank you",
                  symbol="", hotel_note="VAT 18% charged on the hotel too (non-resident exemption not modelled)"),
}


def locale_for(airport: str) -> tuple[Locale, str]:
    """The locale of an airport, and a note when a generic one is used."""
    if airport in LOCALES:
        return LOCALES[airport], ""
    base = LOCALES["YYZ"]
    generic = dataclasses.replace(
        base, airport=airport, city=f"{airport} Airport", tax_ids=("Tax reg. 000000000",),
        taxes={c: (("Sales tax 13%", 0.13),) for c in CATEGORIES},
        merchants={c: (f"{airport} {v[0].split(' ', 1)[-1]}", f"{airport} Airport")
                   for c, v in base.merchants.items()},
        hotel_street=f"1 Airport Rd", hotel_city=f"{airport} Airport")
    return generic, f"no locale for {airport}: a generic CAD/13% receipt was used"


# ====================================================================== Jira parsing

_CUR = r"(?P<cur>CAD|EUR|GBP|ILS|USD)"
_AMT = r"(?P<amt>\d[\d,]*(?:\.\d{1,2})?)"
_RECEIPT_LINE = re.compile(
    rf"Receipt\s+(?P<n>\d+)\s*:\s*(?P<what>.+?)\s+\S\s+[^\d\s]{{0,3}}\s?{_AMT}\s*{_CUR}\b\s*"
    r"(?:\((?P<note>[^)]*)\))?", re.I)
_BLOCK_HEAD = re.compile(r"^\W*Receipt\s+(\d+)\s*\S\s*[A-Za-z]", re.I)
_LINE_ITEM = re.compile(rf"Line item(?:\s*\d+)?\s*:\s*(?P<what>.+?)\s+\S\s+[^\d\s]{{0,3}}\s?{_AMT}\s*{_CUR}?", re.I)
_TOTAL_APPROVED = re.compile(r"Total Approved\s*(?:is)?\s*:?\s*(?P<v>[^\n(]*\d[^\n(]*(?:\([^)\n]*\))?)",
                             re.I)
_CAP_LINES = {
    "meal": re.compile(r"\bMeals?\s*:\s*up to\s*[^\d\s]{0,3}\s?" + _AMT, re.I),
    "hotel": re.compile(r"Hotel accommodation\s*:.*?(?P<nights>\d+)\s*nights?,\s*[^\d\s]{0,3}\s?"
                        + _AMT + r"(?:\.\d+)?\s*(?:[A-Z]{3}\s*)?max", re.I),
    "transport": re.compile(r"Ground transportation\s*:\s*up to\s*[^\d\s]{0,3}\s?" + _AMT, re.I),
    "communication": re.compile(r"\bCommunication\s*:\s*up to\s*[^\d\s]{0,3}\s?" + _AMT, re.I),
    "parking": re.compile(r"\bParking\s*:\s*up to\s*[^\d\s]{0,3}\s?" + _AMT, re.I),
    "essentials": re.compile(r"Essential items\s*:\s*up to\s*[^\d\s]{0,3}\s?" + _AMT, re.I),
}


def category_of(text: str) -> str | None:
    t = text.lower()
    if re.search(r"hotel|accommodation|room\b", t):
        return "hotel"
    if re.search(r"essential|toiletr|pharmac|cable|emergency item|charger", t):
        return "essentials"
    if re.search(r"parking", t):
        return "parking"
    if re.search(r"communication|wi-?fi|phone call|sim\b|internet", t):
        return "communication"
    if re.search(r"taxi|transport|transfer|uber|\bcab\b|\bvan\b|shuttle", t):
        return "transport"
    if re.search(r"meal|dinner|lunch|breakfast|food|sandwich|coffee|snack", t):
        return "meal"
    return None


@dataclasses.dataclass
class Expense:
    n: int
    category: str
    amount: int                     # cents
    currency: str
    what: str
    note: str = ""
    items: list[tuple[str, int]] = dataclasses.field(default_factory=list)   # Jira line items
    source: str = "jira"            # jira | jira-total-approved | chosen
    pax: int = 1
    nights: int = 1


def parse_expenses(text: str) -> list[Expense]:
    """`Receipt N: <what> - <amount> <CUR> (<note>)` lines of a Jira test, with the line items
    of the matching `Receipt N - <Category>:` block when the test lists them. The first listing of
    each receipt number wins (tests repeat them in summaries)."""
    found: dict[int, Expense] = {}
    for m in _RECEIPT_LINE.finditer(text):
        n = int(m.group("n"))
        if n in found:
            continue
        what, note = m.group("what").strip(" -*"), (m.group("note") or "").strip()
        cat = category_of(what) or category_of(note)
        if not cat:
            continue
        pax = re.search(r"\bfor\s+(\d+)\b", note, re.I)
        nights = re.search(r"(\d+)\s+nights?", f"{what} {note}", re.I)
        found[n] = Expense(n, cat, cents(m.group("amt")), m.group("cur").upper(), what, note,
                           pax=int(pax.group(1)) if pax else 1,
                           nights=int(nights.group(1)) if nights else 1)
    # line items, per "Receipt N - Category:" block
    block = None
    for line in text.splitlines():
        head = _BLOCK_HEAD.match(line)
        if head and not _RECEIPT_LINE.search(line):
            block = int(head.group(1))
            continue
        if re.match(r"^\W*(RECEIPT VALIDATION|EXPENSE BREAKDOWN|Total receipts)", line, re.I):
            block = None
        li = _LINE_ITEM.search(line)
        if li and block in found:
            exp = found[block]
            if all(name != li.group("what").strip() for name, _ in exp.items):
                exp.items.append((li.group("what").strip(), cents(li.group("amt"))))
    out = []
    for exp in sorted(found.values(), key=lambda e: e.n):
        # keep the line items only when they add up to the receipt (they describe it)
        if exp.items and sum(a for _, a in exp.items) != exp.amount:
            exp.items = []
        out.append(exp)
    return out


def parse_caps(text: str) -> dict[str, dict]:
    """The caps the test's entitlement display states, as {category: {amount (cents), nights}}."""
    caps = {}
    for cat, rx in _CAP_LINES.items():
        m = rx.search(text)
        if m:
            caps[cat] = {"amount": cents(m.group("amt"))}
            # "up to $30.00 per person x 2 = $60.00": the claim's cap is the product
            rest = text[m.end():].split("\n", 1)[0]
            product = re.search(r"per person.*?=\s*[^\d\s]{0,3}\s?(\d[\d,]*(?:\.\d{1,2})?)", rest, re.I)
            if product:
                caps[cat]["amount"] = cents(product.group(1))
            if cat == "hotel":
                caps[cat]["nights"] = int(m.group("nights"))
    return caps


def total_approved(text: str) -> str | None:
    m = _TOTAL_APPROVED.search(text)
    if not m:
        return None
    from domain.goal_plan import clean
    return re.sub(r"\s+", " ", clean(m.group("v"))).strip(" .") or None


def mentioned_categories(text: str) -> list[str]:
    """Categories the customer's opening line mentions ("buy food, pay for a hotel, a taxi")."""
    m = re.search(r'user says:?\s*"+([^"]+)"', text, re.I)
    said = (m.group(1) if m else "").lower()
    cats = []
    for cat, rx in (("hotel", r"hotel"), ("meal", r"food|meal|eat|dinner|lunch|breakfast"),
                    ("transport", r"taxi|cab|uber|transport"),
                    ("essentials", r"toiletr|essential|pharmac"),
                    ("communication", r"phone call|wi-?fi"), ("parking", r"parking")):
        if re.search(rx, said):
            cats.append(cat)
    return cats


# ====================================================================== case facts

@dataclasses.dataclass
class Case:
    case_id: str
    jira_key: str | None
    title: str
    regime: str
    eligibility: str
    pnr: str
    first: str
    last: str
    airport: str
    date: dt.date
    window_from: str              # HH:MM local
    flight: str
    pax: int
    text: str                     # the Jira feature (+ description)


def _regime_currency(regime: str) -> str:
    return {"EU": "EUR", "ASL": "ILS"}.get((regime or "").upper(), "CAD")


def disrupted(spec: dict, record: dict) -> tuple[str, dt.date, str, str]:
    """(stranded airport, seeded disruption date, scheduled departure HH:MM, flight) of the first
    disrupted segment, from the run record's published keys and seeded document."""
    outcomes = {o["seg"]: o for o in spec.get("outcomes") or []}
    segs = sorted(spec.get("segments") or [], key=lambda s: s["seg"])
    idx = next((i for i, s in enumerate(segs)
                if (outcomes.get(s["seg"]) or {}).get("kind", "ontime") != "ontime"), 0)
    published = record.get("published") or []
    key = published[idx]["key"] if idx < len(published) else (published[0]["key"] if published else "")
    parts = key.split("#")
    airport = parts[3] if len(parts) == 4 else segs[idx]["origin"]
    date = dt.date.fromisoformat(parts[2]) if len(parts) == 4 else None
    flight = f"{parts[0]}{parts[1]}" if len(parts) == 4 else segs[idx]["carrier"] + segs[idx]["number"]
    dep = segs[idx].get("depLocal") or "08:00"
    for bound in ((record.get("document") or {}).get("bounds") or []):
        for seg in ((bound.get("promisedItinerary") or {}).get("associatedSegments") or []):
            if seg.get("flightId") == key and seg.get("departureDatetimeLocal"):
                local = dt.datetime.fromisoformat(seg["departureDatetimeLocal"])
                dep, date = local.strftime("%H:%M"), date or local.date()
    if date is None:
        raise ValueError(f"no seeded date for {spec.get('id')}: published={published}")
    return airport, date, dep, flight


def load_pool(label: str) -> dict[str, dict]:
    path = POOLS_DIR / f"{label.lower()}.yaml"
    if not path.exists():
        return {}
    import yaml
    rows = {}
    for pool in ((yaml.safe_load(path.read_text(encoding="utf-8")) or {}).get("pools") or {}).values():
        for row in pool.get("bookings") or []:
            if row.get("caseId"):
                rows[str(row["caseId"]).upper()] = row
            if row.get("pnr"):
                rows.setdefault(str(row["pnr"]).upper(), row)
    return rows


def jira_folder(case_id: str) -> pathlib.Path | None:
    hits = sorted(pathlib.Path(p) for p in glob.glob(str(JIRA_DIR / f"{case_id}__*")))
    return hits[0] if hits else None


def load_case(record: dict, pool: dict[str, dict]) -> tuple[Case | None, str]:
    """A run record -> the case facts, or (None, why it is skipped)."""
    case_id = str(record.get("case") or "").split("#")[0]
    spec_path = SPEC_DIR / f"{case_id}.json"
    if not spec_path.exists():
        return None, "no spec"
    spec = json.loads(spec_path.read_text(encoding="utf-8"))
    expect = spec.get("expect") or {}
    folder = jira_folder(case_id)
    test = json.loads((folder / "test.json").read_text(encoding="utf-8")) if folder else {}
    from domain.goal_plan import clean
    title = clean(str(test.get("title") or test.get("summary") or ""))
    elig = str(expect.get("eligibility") or "")
    if elig != "ELIGIBLE":
        return None, f"not eligible ({elig or 'no expectation'})"
    verdict = (re.split(r"\s+[–—-]\s+", title) + [""])[1] if re.search(r"\s[–—-]\s", title) else title
    if re.match(r"\s*(not eligible|no determination|pending)", verdict, re.I):
        return None, f"spec says ELIGIBLE but the Jira title disagrees: {title[:60]}"
    feature = (folder / "test.feature").read_text(encoding="utf-8", errors="replace") if folder else ""
    text = feature + "\n" + str(test.get("description") or "")
    airport, date, dep, flight = disrupted(spec, record)
    row = pool.get(case_id.upper()) or pool.get(str(record.get("locator") or "").upper()) or {}
    return Case(case_id, test.get("key"), title, str(expect.get("regime") or ""), elig,
                str(record.get("locator") or row.get("pnr") or ""),
                str(row.get("first") or ""), str(row.get("last") or ""),
                airport, date, dep, flight, len(spec.get("passengers") or [1]), text), ""


# ====================================================================== the receipt model

@dataclasses.dataclass
class Receipt:
    kind: str                      # thermal | folio
    category: str
    merchant: str
    street: str
    city: str
    phone: str
    tax_ids: list[str]
    date: dt.date
    time: str
    number: str
    currency: str
    symbol: str
    items: list[tuple[str, int]]   # (label, cents)
    taxes: list[tuple[str, int]]
    total: int
    card: str
    auth: str
    thanks: str
    header: list[tuple[str, str]] = dataclasses.field(default_factory=list)   # extra L/R rows
    guest: str = ""
    nights: int = 1
    rate: int = 0
    tax_mode: str = "subtotal"

    @property
    def subtotal(self) -> int:
        return sum(a for _, a in self.items)


MARK = "TEST RECEIPT - QA ONLY"


def thermal_rows(r: Receipt) -> list[tuple[str, str, str]]:
    """The thermal receipt as (style, left, right) rows; also the text model the tests read."""
    rows = [("title", r.merchant, ""), ("center", r.street, ""), ("center", r.city, ""),
            ("center", f"Tel. {r.phone}", "")]
    rows += [("center", t, "") for t in r.tax_ids]
    rows += [("rule", "", ""), ("lr", f"Date: {r.date.isoformat()}", f"Time: {r.time}")]
    rows += [("lr", a, b) for a, b in r.header]
    rows += [("rule", "", "")]
    rows += [("lr", label, money(a)) for label, a in r.items]
    rows += [("rule", "", ""), ("lr", "Subtotal", money(r.subtotal))]
    rows += [("lr", label, money(a)) for label, a in r.taxes]
    rows += [("rule", "", ""), ("bold", f"TOTAL {r.currency}", f"{r.symbol}{money(r.total)}"),
             ("gap", "", ""), ("lr", f"VISA **** {r.card}", money(r.total)),
             ("lr", f"Auth: {r.auth}   APPROVED", ""), ("gap", "", ""),
             ("center", r.thanks, ""), ("gap", "", ""), ("small", MARK, "")]
    return rows


def folio_rows(r: Receipt) -> list[tuple[str, str, str]]:
    rows = [("title", r.merchant, ""), ("text", r.street, ""), ("text", f"{r.city}   Tel. {r.phone}", ""),
            ("small", "  ".join(r.tax_ids), ""), ("head", "FOLIO / INVOICE", ""),
            ("text", f"Folio No: {r.number}", ""), ("text", f"Invoice date: {r.date.isoformat()}", ""),
            ("field", "Guest:", r.guest), ("field", "Room:", r.header[0][1] if r.header else ""),
            ("field", "Arrival:", r.date.isoformat()),
            ("field", "Departure:", (r.date + dt.timedelta(days=r.nights)).isoformat()),
            ("field", "Nights:", str(r.nights)), ("field", "Rooms:", "1"), ("field", "Adults:", "1"),
            ("field", "Rate:", f"{r.currency} {money(r.rate)} / night"),
            ("th", "Date | Description", "Amount")]
    first = True
    for label, a in r.items + r.taxes:
        rows.append(("line", (r.date.isoformat() + " | " if first else " | ") + label, money(a)))
        first = False
    rows += [("total", f"TOTAL {r.currency}", money(r.total)),
             ("pay", f"Payment VISA **** {r.card}", money(-r.total)), ("pay", "Balance due", "0.00"),
             ("foot", r.thanks, ""), ("small", MARK, "")]
    return rows


def text_lines(r: Receipt) -> list[str]:
    rows = thermal_rows(r) if r.kind == "thermal" else folio_rows(r)
    out = []
    for style, left, right in rows:
        if style == "rule":
            out.append("-" * 38)
        elif style != "gap":
            out.append(f"{left}  {right}".strip() if right else left)
    return out


# ====================================================================== amounts that add up

def _split(total: int, weights: list[int]) -> list[int]:
    """`total` cents over `weights`, largest remainder, every part >= 1 cent."""
    wsum = sum(weights) or 1
    raw = [total * w / wsum for w in weights]
    parts = [int(x) for x in raw]
    for i in sorted(range(len(raw)), key=lambda i: raw[i] - parts[i], reverse=True)[:total - sum(parts)]:
        parts[i] += 1
    return parts


def _taxes(amounts: list[int], rates, levy, per_line: bool) -> list[tuple[str, int]]:
    """Tax lines for item amounts. A levy (hotel) comes first; when it is in the VAT base the
    sales taxes are computed on items + levy."""
    out, base_extra = [], 0
    s = sum(amounts)
    if levy:
        label, rate, in_base = levy
        lv = rate if rate >= 1 else (sum(round_half_up(a * rate) for a in amounts) if per_line
                                     else round_half_up(s * rate))
        out.append((label, int(lv)))
        base_extra = int(lv) if in_base else 0
    for label, rate in rates:
        if per_line:
            v = sum(round_half_up(a * rate) for a in amounts) + round_half_up(base_extra * rate)
        else:
            v = round_half_up((s + base_extra) * rate)
        out.append((label, v))
    return out


def solve(total: int, weights: list[int], rates, levy=None, unit: int = 1
          ) -> tuple[list[int], list[tuple[str, int]], str]:
    """Item amounts and tax lines whose sum is exactly `total`. Subtotal-level rounding first; if
    no subtotal reaches the total (a rounding gap), per-line rounding over shifted splits, which
    is what many POS systems do. `unit`: the subtotal must be a multiple of it (nights)."""
    eff = sum(r for _, r in rates)
    if levy:
        eff = (1 + (levy[1] if levy[1] < 1 else 0)) * (1 + eff) - 1 if levy[2] else eff + (
            levy[1] if levy[1] < 1 else 0)
    fixed = levy[1] if levy and levy[1] >= 1 else 0
    fixed_total = fixed * (1 + (sum(r for _, r in rates) if levy and levy[2] else 0))
    s0 = int((total - fixed_total) / (1 + eff))
    order = sorted(range(-400, 401), key=abs)
    for d in order:
        s = s0 + d
        if s <= 0 or s % unit:
            continue
        parts = _split(s, weights)
        taxes = _taxes(parts, rates, levy, per_line=False)
        if s + sum(v for _, v in taxes) == total:
            return parts, taxes, "subtotal"
    if len(weights) > 1:
        for d in order[:300]:
            s = s0 + d
            if s <= 0:
                continue
            base = _split(s, weights)
            for j in range(1, len(base)):
                for shift in sorted(range(-150, 151), key=abs):
                    parts = base[:]
                    parts[0] += shift
                    parts[j] -= shift
                    if min(parts) <= 0:
                        continue
                    taxes = _taxes(parts, rates, levy, per_line=True)
                    if s + sum(v for _, v in taxes) == total:
                        return parts, taxes, "per-line"
    raise ValueError(f"no item split reaches {money(total)} with {rates} {levy}")


# ====================================================================== building receipts

MENUS = {
    "breakfast": [("Breakfast sandwich", 8), ("Coffee (large)", 3), ("Yogurt parfait", 5),
                  ("Orange juice", 4), ("Oatmeal bowl", 6)],
    "lunch": [("Chicken wrap", 11), ("Iced tea", 3), ("Soup of the day", 7), ("Club sandwich", 14),
              ("Bottled water", 3)],
    "dinner": [("Grilled chicken plate", 22), ("Pasta primavera", 19), ("Caesar salad", 12),
               ("Sparkling water", 4), ("Soft drink", 4), ("Fish tacos", 18)],
}
ESSENTIALS = [("Toothbrush", 5), ("Toothpaste", 5), ("Deodorant", 6), ("Toiletry kit", 18),
              ("Phone cable USB-C", 15), ("Hand soap", 4), ("Razor", 7)]


#: the second line added when a single-line receipt cannot reach its total (see build_receipt)
EXTRA_LINE = {"meal": "1 x Bottled water", "transport": "Airport pickup fee",
              "essentials": "1 x Travel tissues", "communication": "1 x SIM activation",
              "parking": "Payment terminal fee"}


def _hhmm(minutes: int) -> str:
    return f"{minutes // 60:02d}:{minutes % 60:02d}"


#: preferred minutes after the scheduled departure, per category (the order a stranded day goes)
OFFSETS = {"communication": 25, "parking": 40, "essentials": 70, "meal": 150, "transport": 260,
           "hotel": 300}


def schedule(expenses: list[Expense], start: str, rng: random.Random) -> dict[int, str]:
    """A time for each receipt, all inside [scheduled departure, 23:50] of the disruption day."""
    h, m = map(int, start.split(":"))
    lo, hi = h * 60 + m + 5, 23 * 60 + 50
    lo = min(lo, hi - 5 * len(expenses))
    wanted = sorted(((max(lo + OFFSETS.get(e.category, 120), _meal_floor(e)) + rng.randint(0, 9), e.n)
                     for e in expenses))
    if wanted and wanted[-1][0] > hi:
        step = max(1, (hi - lo) // (len(wanted) + 1))
        wanted = [(lo + step * (i + 1), n) for i, (_, n) in enumerate(wanted)]
    return {n: _hhmm(min(t, hi)) for t, n in wanted}


def _meal_floor(e: Expense) -> int:
    """The earliest sensible minute for a meal the Jira names (a dinner is not eaten at 09:40)."""
    if e.category != "meal":
        return 0
    words = f"{e.what} {e.note} {' '.join(n for n, _ in e.items)}".lower()
    return 18 * 60 + 15 if "dinner" in words else 11 * 60 + 45 if "lunch" in words else 0


def _items_for(exp: Expense, time: str, rng: random.Random) -> list[str] | list[tuple[str, int]]:
    """Item labels and weights."""
    if exp.items:
        return [(_tidy(name), amount) for name, amount in exp.items]
    if exp.category == "meal":
        h = int(time[:2])
        menu = MENUS["breakfast" if h < 11 else "lunch" if h < 16 else "dinner"]
        main = [x for x in menu if x[1] >= 6]
        drink = [x for x in menu if x[1] < 6]
        a, b = rng.choice(main), rng.choice(drink)
        n = max(1, exp.pax)
        return [(f"{n} x {a[0]}", a[1] * n), (f"{n} x {b[0]}", b[1] * n)]
    if exp.category == "essentials":
        picks = rng.sample(ESSENTIALS, 3 if exp.pax < 2 else 4)
        return [(f"1 x {name}", w) for name, w in picks]
    if exp.category == "communication":
        return [("1 x Airport Wi-Fi 24h pass", 3), ("1 x Prepaid calling credit", 2)]
    if exp.category == "parking":
        return [("Daily parking (1 day)", 1)]
    if exp.category == "transport":
        return [("Metered fare", 1)]
    return [("Room charge x 1 night(s)", 1)]


def _tidy(name: str) -> str:
    """A Jira line-item name as a receipt line: arrows spelled, no banned substrings."""
    from domain.goal_plan import clean
    t = clean(name).replace("→", "->")
    t = re.sub(r"(?<=\w)\?(?=\w)", " -> ", t)
    t = re.sub(r"\bcharging\b", "USB", t, flags=re.I)     # "charging" holds 'gin' (P16)
    t = re.sub(r"\s+", " ", t).strip()
    return t if re.match(r"\d+\s*x\s", t) else f"1 x {t}"


def lint(r: Receipt) -> list[str]:
    """Item/tax lines that would trip the reader's alcohol/tip keyword match."""
    bad = []
    for label, _ in r.items + r.taxes:
        low = f" {label.lower()} "
        bad += [f"{label!r} contains {w!r}" for w in BANNED_SUBSTRINGS if w in low]
    return bad


def build_receipt(case: Case, exp: Expense, loc: Locale, time: str, idx: int,
                  rng: random.Random) -> Receipt:
    cat = exp.category
    name, street = loc.merchants[cat]
    phone = f"{loc.phone}{rng.randint(10, 99)}"
    number = f"QA-{case.case_id.split('_')[-1]}-{idx:03d}"
    auth = "".join(rng.choice("0123456789ABCDEF") for _ in range(6))
    rates = loc.taxes[cat]
    if cat == "hotel":
        nights = max(1, exp.nights)
        levy = loc.hotel_levy
        labels = [f"Room charge x {nights} night(s)"]
        try:
            parts, taxes, mode = solve(exp.amount, [1], rates, levy, unit=nights)
        except ValueError:
            # a rounding gap no single room rate reaches: a small facility fee, rounded per line
            labels.append("Facility fee")
            parts, taxes, mode = solve(exp.amount, [96, 4], rates, levy)
            if parts[0] % nights:
                parts = [parts[0] - parts[0] % nights, parts[1] + parts[0] % nights]
                taxes = _taxes(parts, rates, levy, per_line=(mode == "per-line"))
                if sum(parts) + sum(v for _, v in taxes) != exp.amount:
                    raise
        room = parts[0]
        return Receipt("folio", cat, name, loc.hotel_street, loc.hotel_city, phone, list(loc.tax_ids),
                       case.date, time, number, exp.currency, "", list(zip(labels, parts)),
                       taxes, exp.amount, "4242", auth, "Thank you for staying with us.",
                       header=[("Room", str(rng.randint(2, 9) * 100 + rng.randint(1, 30)))],
                       guest=f"{case.first} {case.last}".upper().strip(), nights=nights,
                       rate=room // nights, tax_mode=mode)
    labelled = _items_for(exp, time, rng)
    try:
        parts, taxes, mode = solve(exp.amount, [w for _, w in labelled], rates)
    except ValueError:
        if len(labelled) > 1:
            raise
        # one line and a rounding gap no single price reaches: a small second line, per-line tax
        extra = EXTRA_LINE[cat]
        labelled = [(labelled[0][0], 92), (extra, 8)]
        parts, taxes, mode = solve(exp.amount, [92, 8], rates)
    items = list(zip([l for l, _ in labelled], parts))
    header = [(f"Receipt: {number}", f"Till {rng.randint(1, 6)}")]
    if cat == "transport":
        hotel = loc.merchants["hotel"][0]
        km = 8 + rng.randint(0, 140) / 10
        header = [(f"Trip: {number}", f"Taxi #{rng.randint(101, 989)}"),
                  (f"Driver ID: {rng.randint(10000, 99999)}", ""),
                  (f"From: {case.airport} airport, door {rng.randint(1, 12)}", ""),
                  (f"To:   {hotel}"[:38], ""), (f"Distance: {km:.1f} km", "")]
    elif cat == "parking":
        header = [(f"Ticket: {number}", f"Lot {rng.choice('ABCDE')}"),
                  (f"Entry: {case.date.isoformat()} {_hhmm(max(0, int(time[:2]) * 60 - 600))}", "")]
    thanks = "Merci / Thank you" if cat == "transport" and loc.airport == "YUL" else loc.thanks
    return Receipt("thermal", cat, name, street, loc.city, phone, list(loc.tax_ids), case.date, time,
                   number, exp.currency, loc.symbol, items, taxes, exp.amount, "4242", auth, thanks,
                   header=header, tax_mode=mode)


# ====================================================================== rendering

FONT_DIRS = [pathlib.Path("C:/Windows/Fonts"), pathlib.Path("/usr/share/fonts/truetype/dejavu"),
             pathlib.Path("/Library/Fonts")]
#: Lucida Console first: its zero has no slash or dot. Consolas (the reference pack's font) reads
#: back from Windows OCR as "e" for every 0 ("$52.ee"); Lucida Console reads back exactly.
FONTS = {"mono": ["lucon.ttf", "consola.ttf", "DejaVuSansMono.ttf", "cour.ttf"],
         "mono_bold": ["lucon.ttf", "consolab.ttf", "DejaVuSansMono-Bold.ttf", "courbd.ttf"],
         "sans": ["arial.ttf", "DejaVuSans.ttf", "Arial.ttf"],
         "sans_bold": ["arialbd.ttf", "DejaVuSans-Bold.ttf", "Arial Bold.ttf"]}


def font(kind: str, size: int):
    from PIL import ImageFont
    for d in FONT_DIRS:
        for name in FONTS[kind]:
            if (d / name).exists():
                return ImageFont.truetype(str(d / name), size)
    return ImageFont.load_default(size)


def render_thermal(r: Receipt, path: pathlib.Path, rng: random.Random) -> None:
    from PIL import Image, ImageDraw
    rows = thermal_rows(r)
    f, fb, fs = font("mono", 20), font("mono_bold", 20), font("mono", 13)
    ft = font("mono_bold", 24)
    bold = 1 if fb.path.lower().endswith("lucon.ttf") else 0      # no bold face: stroke it
    line_h, pad_x, pad_top = 30, 28, 34
    paper_w = 470
    height = pad_top + 24
    for style, _, _ in rows:
        height += {"title": 38, "gap": 22, "rule": 26, "small": 20}.get(style, line_h)
    paper = Image.new("RGB", (paper_w, height + 20), (251, 248, 241))
    d = ImageDraw.Draw(paper)
    y = pad_top
    for style, left, right in rows:
        if style == "title":
            w = d.textlength(left, font=ft)
            d.text(((paper_w - w) / 2, y), left, font=ft, fill=(20, 20, 20), stroke_width=bold,
                   stroke_fill=(20, 20, 20))
            y += 38
        elif style == "center":
            w = d.textlength(left, font=f)
            d.text(((paper_w - w) / 2, y), left, font=f, fill=(25, 25, 25))
            y += line_h
        elif style == "rule":
            dashes = int((paper_w - 2 * pad_x + 8) // d.textlength("-", font=f))
            d.text((pad_x - 4, y - 4), "-" * dashes, font=f, fill=(60, 60, 60))
            y += 26
        elif style == "gap":
            y += 22
        elif style == "small":
            w = d.textlength(left, font=fs)
            d.text(((paper_w - w) / 2, y), left, font=fs, fill=(150, 150, 150))
            y += 20
        else:
            ff = fb if style == "bold" else f
            sw = bold if style == "bold" else 0
            d.text((pad_x, y), left, font=ff, fill=(25, 25, 25), stroke_width=sw, stroke_fill=(25, 25, 25))
            if right:
                w = d.textlength(right, font=ff)
                d.text((paper_w - pad_x - w, y), right, font=ff, fill=(25, 25, 25), stroke_width=sw,
                       stroke_fill=(25, 25, 25))
            y += line_h
    angle = rng.uniform(-1.3, 1.3)
    paper = paper.convert("RGBA").rotate(angle, resample=Image.BICUBIC, expand=True)
    bg = Image.new("RGB", (paper.width + 120, paper.height + 110), (204, 203, 198))
    bg.paste(paper, (60 + rng.randint(-6, 6), 50 + rng.randint(-6, 6)), paper)
    path.parent.mkdir(parents=True, exist_ok=True)
    bg.save(path, "JPEG", quality=90, optimize=False)


def render_folio(r: Receipt, path: pathlib.Path) -> None:
    from PIL import Image, ImageDraw
    W, H, s = 1240, 1754, 1240 / 920             # A4 at 150 dpi; reference coordinates are 920 wide
    im = Image.new("RGB", (W, H), (255, 255, 255))
    d = ImageDraw.Draw(im)
    navy, ink, grey = (22, 30, 60), (25, 25, 25), (90, 90, 90)
    X = lambda v: int(v * s)                       # noqa: E731
    f = lambda k, n: font(k, X(n))                 # noqa: E731
    d.text((X(67), X(68)), r.merchant, font=f("sans_bold", 32), fill=navy)
    d.text((X(67), X(113)), r.street, font=f("sans", 18), fill=ink)
    d.text((X(67), X(139)), f"{r.city}   Tel. {r.phone}", font=f("sans", 18), fill=ink)
    d.text((X(67), X(165)), "  ".join(r.tax_ids), font=f("sans", 15), fill=grey)
    d.text((X(611), X(68)), "FOLIO / INVOICE", font=f("sans_bold", 18), fill=navy)
    d.text((X(611), X(98)), f"Folio No: {r.number}", font=f("sans", 18), fill=ink)
    d.text((X(611), X(124)), f"Invoice date: {r.date.isoformat()}", font=f("sans", 18), fill=ink)
    d.line((X(67), X(208), X(857), X(208)), fill=navy, width=X(2))
    fields = [("Guest:", r.guest), ("Room:", r.header[0][1] if r.header else ""),
              ("Arrival:", r.date.isoformat()),
              ("Departure:", (r.date + dt.timedelta(days=r.nights)).isoformat()),
              ("Nights:", str(r.nights)), ("Rooms:", "1"), ("Adults:", "1"),
              ("Rate:", f"{r.currency} {money(r.rate)} / night")]
    y = 232
    for k, v in fields:
        d.text((X(67), X(y)), k, font=f("sans_bold", 18), fill=ink)
        d.text((X(246), X(y)), v, font=f("sans", 18), fill=ink)
        y += 31
    y += 12
    d.line((X(67), X(y), X(857), X(y)), fill=(140, 140, 140), width=1)
    y += 10
    d.text((X(67), X(y)), "Date", font=f("sans_bold", 18), fill=ink)
    d.text((X(246), X(y)), "Description", font=f("sans_bold", 18), fill=ink)
    d.text((X(730), X(y)), "Amount", font=f("sans_bold", 18), fill=ink)
    y += 36
    right = X(857)
    fr = f("sans", 18)
    for i, (label, a) in enumerate(r.items + r.taxes):
        if i == 0:
            d.text((X(67), X(y)), r.date.isoformat(), font=fr, fill=ink)
        d.text((X(246), X(y)), label, font=fr, fill=ink)
        v = money(a)
        d.text((right - d.textlength(v, font=fr), X(y)), v, font=fr, fill=ink)
        y += 33
    y += 8
    d.line((X(521), X(y), X(857), X(y)), fill=ink, width=X(1.5))
    y += 10
    fb = f("sans_bold", 18)
    for label, v, ff in ((f"TOTAL {r.currency}", money(r.total), fb),
                         (f"Payment VISA **** {r.card}", money(-r.total), fr), ("Balance due", "0.00", fr)):
        d.text((X(521), X(y)), label, font=ff, fill=ink)
        d.text((right - d.textlength(v, font=ff), X(y)), v, font=ff, fill=ink)
        y += 33
    d.text((X(67), X(1208)), f"{r.thanks}", font=f("sans", 16), fill=grey)
    d.text((X(67), X(1240)), MARK, font=f("sans", 11), fill=(170, 170, 170))
    path.parent.mkdir(parents=True, exist_ok=True)
    # no creation/modification date in the file: the same inputs give the same bytes
    stamp = dt.datetime.combine(r.date, dt.time(12, 0)).timetuple()
    im.save(path, "PDF", resolution=150, title=path.stem, creationDate=stamp, modDate=stamp)


# ====================================================================== a case's receipts

def chosen_amount(cat: str, cap_cents: int | None, cap_cur: str, cur: str, rng: random.Random) -> int:
    """A realistic amount for a category the test mentions without one, under its cap."""
    lo, hi = {"meal": (18, 38), "hotel": (150, 210), "transport": (35, 60), "essentials": (14, 26),
              "communication": (9, 18), "parking": (20, 35)}[cat]
    cad = rng.uniform(lo, hi)
    if cap_cents:
        cad = min(cad, cap_cents / 100 * FX_CAD[cap_cur] * 0.85)
    return int(round(cad / FX_CAD[cur])) * 100 or 100


def _to(amount: int, cur: str, target: str) -> float:
    return amount / 100 * FX_CAD[cur] / FX_CAD[target]


def expectation(exp: Expense, cap: dict | None, cap_cur: str) -> tuple[str, int | None]:
    """What the test expects for this receipt under the Jira's cap: 'paid in full' or the cap rule,
    and the approved amount in the cap's currency (None when paid in full)."""
    if not cap:
        return "paid in full (no cap stated in the Jira)", None
    if exp.category == "hotel" and exp.nights > cap.get("nights", 3):
        return "AC_NE_05 (more than the stated nights)", 0
    claimed = _to(exp.amount, exp.currency, cap_cur)
    if claimed <= cap["amount"] / 100 + 0.005:
        return "paid in full", None
    rule = CAP_RULE.get(exp.category, "capped (no rule code in the reference pack)")
    return f"partial: capped at {cap_cur} {money(cap['amount'])} ({rule})", cap["amount"]


def expectation_int(exp: Expense) -> str:
    """What the INT reader did with the same kind of receipt in the reference pack (index.csv)."""
    if exp.category in ("essentials", "communication"):
        return "NO_DETERMINATION -> manual review (exploratory on INT: P15 essentials, P17 communication)"
    if exp.category == "parking":
        return "not covered by the reference pack"
    cap, rule = INT_CAPS[exp.category]
    if exp.category == "hotel" and exp.nights > 3:
        return "INELIGIBLE (AC_NE_05 - more than 3 nights)"
    cad = _to(exp.amount, exp.currency, "CAD")
    return "PAID IN FULL" if cad <= cap / 100 + 0.005 else f"PARTIALLY_ELIGIBLE, CAD {money(cap)} ({rule})"


def plan_case(case: Case, rng: random.Random) -> tuple[list[Expense], list[str]]:
    """The expenses to render for a case, and notes on anything chosen."""
    notes = []
    loc, _ = locale_for(case.airport)
    exps = parse_expenses(case.text)
    caps = parse_caps(case.text)
    cap_cur = _regime_currency(case.regime)
    if not exps:
        cats = mentioned_categories(case.text) or ["meal"]
        for i, cat in enumerate(cats, 1):
            amt = chosen_amount(cat, (caps.get(cat) or {}).get("amount"), cap_cur, loc.currency, rng)
            exps.append(Expense(i, cat, amt, loc.currency, f"{cat} (chosen)", source="chosen"))
        notes.append(f"the Jira states no expense amounts: chose {', '.join(cats)} under the stated caps")
    for e in exps:
        if e.currency != loc.currency:
            jira = f"{e.currency} {money(e.amount)}"
            e.amount = int(round(_to(e.amount, e.currency, loc.currency) * 100))
            e.currency = loc.currency
            e.items = []
            e.source = "jira-converted"
            notes.append(f"receipt {e.n}: the Jira states {jira} but the passenger is stranded at "
                         f"{case.airport} ({loc.currency}); issued as {loc.currency} {money(e.amount)} "
                         f"at an approximate rate")
        if e.category == "meal" and re.search(r"breakfast", f"{e.what} {e.note}", re.I) and re.search(
                r"dinner|lunch", f"{e.what} {e.note}", re.I):
            notes.append(f"receipt {e.n}: the Jira's meal spans more than one sitting; issued as one "
                         f"receipt on the disruption day (a next-day receipt is outside the window, P05)")
    return exps, notes


def generate(case: Case, out_dir: pathlib.Path, label: str = "") -> dict:
    rng = random.Random(int(hashlib.sha256(case.case_id.encode()).hexdigest()[:12], 16))
    loc, loc_note = locale_for(case.airport)
    exps, notes = plan_case(case, rng)
    if loc_note:
        notes.append(loc_note)
    if loc.note:
        notes.append(loc.note)
    if loc.hotel_note and any(e.category == "hotel" for e in exps):
        notes.append(loc.hotel_note)
    caps = parse_caps(case.text)
    cap_cur = _regime_currency(case.regime)
    times = schedule(exps, case.window_from, rng)
    folder = out_dir / case.case_id
    folder.mkdir(parents=True, exist_ok=True)
    for old in folder.glob(f"{case.case_id}_*"):
        old.unlink()
    entries = []
    for i, exp in enumerate(exps, 1):
        r = build_receipt(case, exp, loc, times[exp.n], i, rng)
        bad = lint(r)
        if bad:
            raise ValueError(f"{case.case_id} receipt {i}: {bad}")
        ext = "pdf" if r.kind == "folio" else "jpg"
        name = f"{case.case_id}_{i}_{exp.category}_{case.airport}.{ext}"
        path = folder / name
        if r.kind == "folio":
            render_folio(r, path)
        else:
            render_thermal(r, path, rng)
        expected, approved = expectation(exp, caps.get(exp.category), cap_cur)
        cap = caps.get(exp.category)
        try:
            rel = path.resolve().relative_to(SUITE.resolve()).as_posix()
        except ValueError:
            rel = None
        entries.append({
            "file": name, "path": rel, "category": exp.category, "currency": r.currency,
            "total": round(r.total / 100, 2), "subtotal": round(r.subtotal / 100, 2),
            "taxes": [{"label": l, "amount": round(a / 100, 2)} for l, a in r.taxes],
            "items": [{"label": l, "amount": round(a / 100, 2)} for l, a in r.items],
            "date": r.date.isoformat(), "time": r.time, "merchant": r.merchant,
            "city": r.city, "airport": case.airport, "receiptNumber": r.number,
            "expected": expected,
            "approved": round(approved / 100, 2) if approved is not None else None,
            "cap": ({"amount": round(cap["amount"] / 100, 2), "currency": cap_cur,
                     **({"nights": cap["nights"]} if "nights" in cap else {}), "source": "jira"}
                    if cap else None),
            "expectedInt": expectation_int(exp),
            "amountSource": exp.source,
            "jira": f"Receipt {exp.n}: {exp.what}" + (f" ({exp.note})" if exp.note else ""),
            **({"nights": exp.nights, "guest": r.guest} if r.kind == "folio" else {}),
            **({"pax": exp.pax} if exp.pax > 1 else {}),
            "taxMode": r.tax_mode,
        })
    manifest = {
        "generator": GENERATOR, "case": case.case_id, "jiraKey": case.jira_key, "title": case.title,
        "run": label, "pnr": case.pnr, "passenger": f"{case.first} {case.last}".strip(),
        "regime": case.regime, "airport": case.airport, "flight": case.flight,
        "disruptionDate": case.date.isoformat(),
        "window": {"from": f"{case.date.isoformat()} {case.window_from}",
                   "to": f"{case.date.isoformat()} 23:59"},
        "jiraTotalApproved": total_approved(case.text),
        "receipts": entries, "notes": notes,
    }
    (folder / "manifest.json").write_text(json.dumps(manifest, indent=1, ensure_ascii=False) + "\n",
                                          encoding="utf-8")
    return manifest


# ====================================================================== CLI

def run(run_dir: pathlib.Path, out_dir: pathlib.Path, only: set[str]) -> dict:
    label = run_dir.name
    pool = load_pool(label)
    covered, skipped, no_amounts, errors = [], [], [], []
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
            m = generate(case, out_dir, label)
        except Exception as exc:                                   # noqa: BLE001
            errors.append((cid, f"{type(exc).__name__}: {exc}"))
            continue
        covered.append(m)
        if any(r["amountSource"] == "chosen" for r in m["receipts"]):
            no_amounts.append(cid)
    return {"covered": covered, "skipped": skipped, "noAmounts": no_amounts, "errors": errors}


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--run", required=True, help="a run folder, e.g. runs/int/soc-uat-046-own")
    ap.add_argument("--only", default="", help="comma-separated case ids")
    ap.add_argument("--out", default="", help=f"default: {DEFAULT_OUT}")
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
        files = ", ".join(f"{r['file']} ({r['currency']} {r['total']:.2f}, {r['expected']})"
                          for r in m["receipts"])
        print(f"{m['case']} {m['pnr']} {m['passenger']} @ {m['airport']} {m['disruptionDate']}: {files}")
        for n in m["notes"]:
            print(f"    note: {n}")
    print(f"\n{len(res['covered'])} eligible case(s) covered -> {out}")
    print(f"{len(res['skipped'])} case(s) skipped"
          + (f": {', '.join(c for c, _ in res['skipped'])}" if res["skipped"] else ""))
    if res["noAmounts"]:
        print(f"{len(res['noAmounts'])} eligible case(s) whose Jira states no expense amounts "
              f"(amounts chosen): {', '.join(res['noAmounts'])}")
    for cid, err in res["errors"]:
        print(f"ERROR {cid}: {err}")
    return 1 if res["errors"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
