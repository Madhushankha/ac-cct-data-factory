"""Expected values per case, parsed from the FD Miro gap-analysis docs (the source of truth).

The docs live in aqa/workflows/docs/gap-docs/fd/. Each UAT card carries a "Test Data (INT)" table
(PNR, route, delay, code, amount, DDS systemCode, DDS result) and an "Expected conditions" prose;
each SIT card carries the outcome (data-out), regime tag and a title with amount / delay band.
UAT cards are read structurally (header, `datagrid` dk/dv pairs, `citem` expected conditions).

`python -m aqa.workflows.seed.gapdoc` rewrites fixtures/fd-<suite>/_gapdoc_expected.json; catalog.py
reads those files first. Re-run it whenever the gap docs are refreshed from Beacon.
"""
from __future__ import annotations

import html as H
import json
import re
from pathlib import Path

from .ids import canonical

GAP_DOCS = Path(__file__).resolve().parents[1] / "docs" / "gap-docs"
DOCS = GAP_DOCS / "fd"                       # kept: FD is what most callers still mean
FIXTURES = Path(__file__).resolve().parent / "fixtures"
FILES = {"uat": DOCS / "FD_UAT_Miro_Gap_Analysis.html", "sit": DOCS / "FD_SIT_Miro_Gap_Analysis.html"}
DOC_FILES = {
    "fd": FILES,
    "baggage": {"uat": GAP_DOCS / "baggage" / "Baggage_UAT_Miro_Gap_Analysis.html",
                "sit": GAP_DOCS / "baggage" / "Baggage_SIT_Miro_Gap_Analysis.html"},
}

_TD_KEYS = ["PNR", "pnrId", "Passenger (claimant)", "Route", "Delay", "Code", "Amount", "Tier", "DDS systemCode",
            "Payment", "Scenario", "DDS result", "Pax", "Passengers", "Legs", "Flight", "Regime"]
_BANDS = {"3 to <6": (240, "DELAY_3_TO_LT_6_HOURS"), "3–<6": (240, "DELAY_3_TO_LT_6_HOURS"),
          "6 to <9": (420, "DELAY_6_TO_LT_9_HOURS"), "6–<9": (420, "DELAY_6_TO_LT_9_HOURS"),
          "9+": (600, "DELAY_GTE_9_HOURS"), "9 hour": (600, "DELAY_GTE_9_HOURS"), ">=9": (600, "DELAY_GTE_9_HOURS")}


# The gap doc writes the APPR eligible codes with the AMOUNT where the rule engine writes a
# sequence number: FD-APPR-EL-400 / -700 / -1000 for what the lookup table calls EL-01 / -02 / -03.
# 68 of the 239 UAT cards carry one, and a code that is not in DDS_FD_SoC_reason_codes_lookup finds
# no row -- so no banner and no customer message. The delay band is what separates the three, and
# the card states it, so the translation is read from the card rather than guessed.
_APPR_EL_BY_BAND = ((360, "FD-APPR-EL-01"), (540, "FD-APPR-EL-02"), (10 ** 6, "FD-APPR-EL-03"))
_AMOUNT_CODE = re.compile(r"^FD-APPR-EL-(\d{3,4})$")


def rule_engine_code(code: str | None, delay_minutes: int | None) -> str | None:
    """The card's systemCode as the rule engine spells it."""
    if not code or not _AMOUNT_CODE.match(code):
        return code
    minutes = delay_minutes if delay_minutes is not None else 240   # the seeder's own default band
    return next(c for hi, c in _APPR_EL_BY_BAND if minutes < hi)


def _txt(s: str) -> str:
    return re.sub(r"\s+", " ", H.unescape(re.sub(r"<[^>]+>", " ", s))).strip()


def _status(s: str | None) -> str | None:
    if not s:
        return None
    u = s.upper()
    if "PRE TRAVEL" in u or "PRE-TRAVEL" in u:
        return "PRE_TRAVEL"
    if "NOT ELIGIBLE" in u or "NOT_ELIGIBLE" in u or "INELIGIBLE" in u:
        return "NOT_ELIGIBLE"
    if "NO DETERMINATION" in u or "NO_DETERMINATION" in u:
        return "NO_DETERMINATION"
    if "PENDING" in u:
        return "PENDING"
    if "ELIGIBLE" in u:
        return "ELIGIBLE"
    return None


def _amount(s: str | None) -> tuple[float | None, str | None]:
    if not s:
        return None, None
    m = re.search(r"(CAD|USD|EUR|GBP|CHF|ILS)?\s*\$?\s*(\d[\d,]*(?:\.\d+)?)\s*(CAD|USD|EUR|GBP|CHF|ILS)?", s)
    if not m:
        return None, None
    return float(m.group(2).replace(",", "")), (m.group(1) or m.group(3) or "CAD")


def _band(title: str) -> tuple[int | None, str | None]:
    t = title.lower()
    for k, v in _BANDS.items():
        if k.lower() in t:
            return v
    m = re.search(r"(\d+)\s*minute", t)
    if m:
        mins = int(m.group(1))
        band = "DELAY_3_TO_LT_6_HOURS" if mins < 360 else "DELAY_6_TO_LT_9_HOURS" if mins < 540 else "DELAY_GTE_9_HOURS"
        return mins, band
    m = re.search(r"(\d+)\s*(?:h|hr|hour)", t)
    if m:
        mins = int(m.group(1)) * 60
        band = "DELAY_3_TO_LT_6_HOURS" if mins < 360 else "DELAY_6_TO_LT_9_HOURS" if mins < 540 else "DELAY_GTE_9_HOURS"
        return mins, band
    return None, None


def _parse_uat(text: str) -> dict:
    """Walk each card's markup: header title, the `datagrid` (dk/dv pairs) and the `citem` checks."""
    out = {}
    for attrs, body in re.findall(r'<section class="card"([^>]*)>(.*?)</section>', text, re.S):
        src = re.search(r'id="([^"]+)"', attrs).group(1)
        arch = (re.search(r'data-arch="([^"]*)"', attrs) or [None, None])[1]
        grp = (re.search(r'data-grp="([^"]*)"', attrs) or [None, None])[1]
        badges = [_txt(b) for b in re.findall(r'<span class="badge[^"]*">(.*?)</span>', body, re.S)]
        hm = re.search(r"<header[^>]*>(.*?)</header>", body, re.S)
        header = _txt(hm.group(1)) if hm else _txt(body[:300])
        title = re.sub(r"\s*(\d+ gaps?|aligned)\s*▾.*$", "", header).strip()
        title = re.sub(r"^\S+\s+", "", title)                                  # card id
        title = re.sub(r"^(?:(?:P\d|FD-[A-Z0-9-]+|N/A \([^)]*\)|EDGE-[A-Z0-9-]+)\s+)+", "", title, flags=re.I).strip()
        td = dict(zip([_txt(k) for k in re.findall(r'<div class="dk">(.*?)</div>', body, re.S)],
                      [_txt(v) for v in re.findall(r'<div class="dv[^"]*">(.*?)</div>', body, re.S)]))
        checks = [_txt(c) for c in re.findall(r'<label class="citem"><input type="checkbox"><span>(.*?)</span></label>', body, re.S)]
        status = _status(td.get("DDS result")) or {"eligible": "ELIGIBLE", "ne": "NOT_ELIGIBLE", "nd": "NO_DETERMINATION",
                                                    "pending": "PENDING"}.get(arch or "")
        code = td.get("DDS systemCode") or ""
        if not code.startswith("FD-"):
            code = next((b for b in badges if b.startswith("FD-")), None)
        prose_code = next((m.group(1) for m in (re.search(r"DDS returns (FD-[A-Z]+-[A-Z]+-\w+)", c) for c in checks) if m), None)
        msl_leg = next((int(m.group(1)) for m in (re.search(r"MSL = Leg (\d)", c) for c in checks) if m), None)
        amount, currency = _amount(td.get("Amount"))
        delay = (re.search(r"(\d+)\s*m", td.get("Delay", "")) or [None, None])[1]
        dcode = td.get("Code") if re.fullmatch(r"\d{1,3}", td.get("Code", "") or "") else None
        regime = code.split("-")[1] if code and code.startswith("FD-") else None
        route = (td.get("Route", "").split() or [None])[0]
        rm = re.search(r"Regime\s+([A-Z]+)", td.get("Route", ""))
        if rm:
            regime = rm.group(1)
        out[canonical(src)] = {
            "source_case_id": src, "suite": "uat", "group": grp, "arch": arch, "third_party": arch == "thirdparty",
            "title": title, "status": status,
            "system_code": rule_engine_code(code, int(delay) if delay else None),
            "card_system_code": code, "prose_system_code": prose_code,
            "regime": regime, "amount": amount, "currency": currency,
            "delay_minutes": int(delay) if delay else None, "delay_code": dcode, "msl_leg": msl_leg,
            "route": route, "claimant": td.get("Passenger (claimant)"), "tier": td.get("Tier"),
            "payment": td.get("Payment"), "scenario": td.get("Scenario"), "int_pnr": td.get("PNR"),
            "pre_travel": status == "PRE_TRAVEL", "badges": badges, "checks": checks,
        }
    return out


def _parse_sit(text: str) -> dict:
    out = {}
    for attrs, body in re.findall(r'<section class="card"([^>]*)>(.*?)</section>', text, re.S):
        src = re.search(r'id="([^"]+)"', attrs).group(1)
        feat = (re.search(r'data-feat="([^"]*)"', attrs) or [None, None])[1]
        dout = (re.search(r'data-out="([^"]*)"', attrs) or [None, None])[1]
        gaps = (re.search(r'data-gaps="([^"]*)"', attrs) or [None, "0"])[1]
        full = _txt(body)
        tcname = (re.search(r'<span class="tcname">(.*?)</span>', body, re.S) or [None, ""])[1]
        title = _txt(tcname) if tcname else full[:120]
        rg = (re.search(r"rg:([A-Z]+)", full) or [None, None])[1]
        rg = {"A": "APPR", "E": "EU", "S": "ASL"}.get(rg, rg)   # the SIT doc abbreviates the regime tag
        tm = re.search(r"(APPR|EU(?:/UK)? ?261|ASL)", title)
        if tm:                                                   # the title names the regime explicitly
            rg = "EU" if tm.group(1).startswith("EU") else tm.group(1)
        codes = sorted(set(re.findall(r"FD-(?:APPR|EU|ASL)-[A-Z]{2}-\w+", full)))
        am = re.search(r"(CAD|EUR|USD|GBP|ILS)\s*\$?\s*\d[\d,]*|\$\s*\d[\d,]*\s*(?:CAD|EUR|USD|GBP|ILS)?", title)
        amount, currency = _amount(am.group(0)) if am else (None, None)
        delay, band = _band(title)
        status = _status(dout) or _status(feat) or _status(title)
        out[canonical(src)] = {
            "source_case_id": src, "suite": "sit", "feature": feat, "outcome": dout, "gaps": int(gaps or 0),
            "title": title, "status": status, "system_code": codes[0] if len(codes) == 1 else None,
            "codes_seen": codes, "regime": rg, "amount": amount, "currency": currency,
            "delay_minutes": delay, "delay_band": band,
            "group_booking": "group" in title.lower(), "third_party": "third" in title.lower(),
        }
    return out


# Baggage carries no test-data grid and no verdict field: eligibility is decided live from bag state,
# so what the cards do carry is the *conditions* a seeded booking has to satisfy. These read them.
_BAG_FLIGHT = re.compile(r"\b(AC)\s?(\d{2,4})\s+([A-Z]{3})\s*(?:→|->|-)\s*([A-Z]{3})(?:\s+(\w{3}\s+\d{1,2},?\s+\d{4}))?")
_BAG_AHL = re.compile(r"AHL\s*(?:found|reference|number)?\s*:?\s*([A-Z]{3}[A-Z]{2}\d{4,6})", re.I)


def _bag_conditions(checks: list[str], title: str, search: str) -> dict:
    """The booking + bag state a case needs, read from its own checks rather than assumed."""
    blob = " ".join(checks) + " " + title
    low = blob.lower()

    def has(*words: str) -> bool:
        return any(w in low for w in words)

    within = None
    if "21-day check: pass" in low or "within window" in low or "within 21 days" in low:
        within = True
    elif "21-day check: fail" in low or "beyond" in low or "after the 21-day" in low or ">21 day" in low:
        within = False

    last_ac = None
    if has("last carrier: air canada", "air canada is last carrier", "last carrier ac"):
        last_ac = True
    elif has("not last carrier", "another airline was the last", "oal last carrier", "ac not last carrier"):
        last_ac = False

    ahl = None
    m = _BAG_AHL.search(blob)
    if m:
        ahl = m.group(1).upper()
    # A card that says "No AHL found" contains "ahl found", so the negatives are tested first or
    # they never match. An explicit reference still wins: a card naming one has a file, whatever
    # else it says.
    absent = has("no ahl", "no delayed bag report", "report not found", "ahl not found",
                 "ahl: not found", "ahl search: not found", "ahl search result: not found")
    if ahl:
        ahl_state = "found"
    elif absent:
        ahl_state = "absent"
    elif has("ahl found", "delayed bag report found", "existing ahl"):
        ahl_state = "found"
    else:
        ahl_state = None

    fm = _BAG_FLIGHT.search(blob)
    flight = {"carrier": fm.group(1), "number": fm.group(2), "origin": fm.group(3),
              "destination": fm.group(4), "date_text": (fm.group(5) or "").strip()} if fm else None

    return {"within_21_days": within, "last_carrier_ac": last_ac, "ahl": ahl, "ahl_state": ahl_state,
            "flight": flight, "route": f"{flight['origin']}-{flight['destination']}" if flight else None,
            "delivered": has("already delivered", "bag was delivered"),
            "duplicate_claim": has("claim already exists", "duplicate claim"),
            "over_300": has("over $300", "above $300", "$300/item", "exceeds $300"),
            "multi_pax": has("multiple people", "multiple passengers", "same ahl"),
            "third_party": has("on behalf of", "third-party", "third party")}


def _bag_outcome(title: str, search: str, checks: list[str]) -> str | None:
    """The routing outcome the card ends on. Baggage decides routes, not compensation amounts."""
    blob = f"{title} {search} {' '.join(checks[-6:])}".lower()
    for needle, out in (("manual handling", "MANUAL_HANDLING"), ("manual review", "MANUAL_HANDLING"),
                        ("redirect", "REDIRECT"), ("other airline", "REDIRECT"), ("oal", "REDIRECT"),
                        ("bag recovery site", "MICROSITE"), ("microsite", "MICROSITE"),
                        ("claim payment", "CLAIM_PAID"), ("payment", "CLAIM_PAID"),
                        ("tracking", "TRACKED"), ("live baggage", "TRACKED"),
                        ("not eligible", "NOT_ELIGIBLE"), ("not applicable", "NOT_ELIGIBLE"),
                        ("blocked", "NOT_ELIGIBLE"), ("end flow", "END_FLOW"), ("end", "END_FLOW")):
        if needle in blob:
            return out
    return None


def _parse_bag_uat(text: str) -> dict:
    out = {}
    for attrs, body in re.findall(r'<section class="card"([^>]*)>(.*?)</section>', text, re.S):
        src = re.search(r'id="([^"]+)"', attrs).group(1)
        feat = (re.search(r'data-feat="([^"]*)"', attrs) or [None, None])[1]
        search = (re.search(r'data-search="([^"]*)"', attrs) or [None, ""])[1]
        gaps = (re.search(r'data-gaps="([^"]*)"', attrs) or [None, "0"])[1]
        tcid = _txt((re.search(r'<span class="tcid">(.*?)</span>', body, re.S) or [None, ""])[1])
        title = _txt((re.search(r'<span class="tcname">(.*?)</span>', body, re.S) or [None, ""])[1])
        checks = [_txt(c) for c in
                  re.findall(r'<label class="citem"><input type="checkbox"><span>(.*?)</span></label>', body, re.S)]
        bubbles = [_txt(b) for b in re.findall(r'class="intbub"[^>]*>(.*?)</div>', body, re.S)]
        cond = _bag_conditions(checks, title, search)
        out[canonical(src)] = {
            "source_case_id": src, "suite": "uat", "card_id": tcid, "feature": feat,
            "title": title, "gaps": int(gaps or 0), "status": _bag_outcome(title, search, checks),
            "system_code": None, "amount": None, "currency": None, "regime": "BAG",
            "checks": checks, "opening_turn": bubbles[0] if bubbles else None, **cond,
        }
    return out


def _parse_bag_sit(text: str) -> dict:
    out = {}
    for attrs, body in re.findall(r'<section class="card"([^>]*)>(.*?)</section>', text, re.S):
        src = re.search(r'id="([^"]+)"', attrs).group(1)
        # accept the document as delivered (BAG-DELAY-01) and after the ids are rewritten
        # (BAG_SIT_DELAY_001); a group header matches neither and is not a case
        if not re.match(r"^(?:BAG[_-][A-Z]+[_-]\d+|BAG_SIT_[A-Z]+_\d+)$", src, re.I):
            continue
        feat = (re.search(r'data-feat="([^"]*)"', attrs) or [None, None])[1]
        search = (re.search(r'data-search="([^"]*)"', attrs) or [None, ""])[1]
        gaps = (re.search(r'data-gaps="([^"]*)"', attrs) or [None, "0"])[1]
        title = _txt((re.search(r'<span class="tcname">(.*?)</span>', body, re.S) or [None, ""])[1])
        checks = [_txt(c) for c in
                  re.findall(r'<label class="citem"><input type="checkbox"><span>(.*?)</span></label>', body, re.S)]
        cond = _bag_conditions(checks, title, search)
        out[canonical(src)] = {
            "source_case_id": src, "suite": "sit", "card_id": src, "feature": feat,
            "title": title, "gaps": int(gaps or 0), "status": _bag_outcome(title, search, checks),
            "system_code": None, "amount": None, "currency": None, "regime": "BAG",
            "checks": checks, **cond,
        }
    return out


_PARSERS = {("fd", "uat"): _parse_uat, ("fd", "sit"): _parse_sit,
            ("baggage", "uat"): _parse_bag_uat, ("baggage", "sit"): _parse_bag_sit}


def parse(suite: str, flow: str = "fd") -> dict:
    text = DOC_FILES[flow][suite].read_text(encoding="utf-8")
    return _PARSERS[(flow, suite)](text)


def fixtures_dir(suite: str, flow: str = "fd") -> Path:
    return FIXTURES / f"{flow}-{suite}"


def write_all(flow: str = "fd") -> dict[str, int]:
    counts = {}
    for suite in DOC_FILES[flow]:
        data = parse(suite, flow)
        d = fixtures_dir(suite, flow)
        d.mkdir(parents=True, exist_ok=True)
        (d / "_gapdoc_expected.json").write_text(json.dumps(data, indent=1, ensure_ascii=False), encoding="utf-8")
        counts[suite] = len(data)
    return counts


def load(suite: str, flow: str = "fd") -> dict:
    p = fixtures_dir(suite, flow) / "_gapdoc_expected.json"
    return json.loads(p.read_text(encoding="utf-8")) if p.exists() else {}


if __name__ == "__main__":
    import sys
    print(write_all(sys.argv[1] if len(sys.argv) > 1 else "fd"))
