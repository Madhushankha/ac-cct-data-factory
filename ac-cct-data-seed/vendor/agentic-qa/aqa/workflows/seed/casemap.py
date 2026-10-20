"""Keep the scenario fixtures aligned with the gap-analysis docs: one file per gap-doc case.

Layout after `python -m aqa.workflows.seed.casemap sync`:

    fixtures/fd-uat/FD_UAT_078.json      one fixture per gap-doc card, named by the case id
    fixtures/fd-uat/_extra/ZFU010.json   package fixtures the doc does not know (loadable by fixture id)
    fixtures/fd-uat/_case_map.json       provenance per case: exact | review | generated | missing
    fixtures/fd-sit/FD_SIT_001.json      same for SIT

Binding rules (in order): a file already named after the case; a package file whose title matches
the card's title one-to-one (exact >= 0.999, review >= 0.80); otherwise a fixture is GENERATED
from the card's own test-data grid (route, claimant, delay, code, amount, regime) so every card is
seedable. Generated fixtures carry `"generated": true` and are tagged `generated`.

Why: the package's fixtures (ZFU001..) number cases differently from the doc from card 10
onward, so numbers can never be trusted; the case id agentic-qa uses is the gap-doc number.
"""
from __future__ import annotations

import difflib
import json
import re
import sys
from pathlib import Path

from .gapdoc import load as load_gapdoc
from .ids import canonical, source

FIXTURES = Path(__file__).resolve().parent / "fixtures"
EXACT, REVIEW = 0.999, 0.80
DEFAULT_ROUTE = {"APPR": "YUL-YYZ", "EU": "CDG-YYZ", "ASL": "TLV-YYZ"}
DEFAULT_FLIGHT_DATE = "2026-06-19"


def _norm(s: str) -> str:
    s = s.lower().replace("–", "-").replace("—", "-").replace("→", "->")
    s = re.sub(r"^\([^)]*\)\s*", "", s)                 # gap-doc header prefix "(AC Wallet) ..."
    s = re.sub(r"^[a-z]+_[a-z0-9_]+:\s*", "", s)         # fixture title prefix "FD_UAT_001: ..."
    s = re.sub(r"[^a-z0-9<>+=/ ]+", " ", s)
    return re.sub(r"\s+", " ", s).strip()


def _dir(suite: str, flow: str = "fd") -> Path:
    return FIXTURES / f"{flow}-{suite}"


def _read(p: Path) -> dict:
    return json.loads(p.read_text(encoding="utf-8"))


def _write(p: Path, j: dict) -> None:
    p.write_text(json.dumps(j, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def _fixture_title(j: dict) -> str:
    return j.get("description") or re.sub(r"^\S+:\s*", "", j.get("title", ""))


def _files(suite: str, flow: str = "fd") -> dict[Path, dict]:
    """Every fixture file in the suite folder and its _extra/ (not the underscore metadata files)."""
    out = {}
    for p in sorted(_dir(suite, flow).glob("*.json")) + sorted((_dir(suite, flow) / "_extra").glob("*.json")):
        if p.name.startswith("_"):
            continue
        out[p] = _read(p)
    return out


# ---- generation from a card ---------------------------------------------------

def _split_name(full: str | None) -> tuple[str, str]:
    parts = (full or "ALEX MORGAN").strip().upper().split()
    return (parts[0], " ".join(parts[1:]) or "MORGAN") if parts else ("ALEX", "MORGAN")


def generate_fixture(cid: str, card: dict, suite: str) -> dict:
    """A single-passenger booking built from the card's test-data grid (or regime defaults)."""
    regime = card.get("regime") if card.get("regime") in DEFAULT_ROUTE else "APPR"
    route = card.get("route") if re.fullmatch(r"[A-Z]{3}(-[A-Z]{3})+", card.get("route") or "") else DEFAULT_ROUTE[regime]
    stops = route.split("-")
    first, last = _split_name(card.get("claimant"))
    date = DEFAULT_FLIGHT_DATE
    segs = []
    for i in range(len(stops) - 1):
        dep_h, arr_h = 10 + 3 * i, 12 + 3 * i
        segs.append({"carrier": "AC", "operating_carrier": "AC", "flight_number": str(100 + i),
                     "operating_flight_number": str(100 + i), "origin": stops[i], "destination": stops[i + 1],
                     "dep_local": f"{date}T{dep_h:02d}:00:00", "arr_local": f"{date}T{arr_h:02d}:00:00",
                     "dep_utc": f"{date}T{dep_h:02d}:00:00Z", "arr_utc": f"{date}T{arr_h:02d}:00:00Z",
                     "booking_datetime": "2026-06-01T10:00:00Z", "aircraft": "320", "cabin": "Y", "status": "HK",
                     "arrival_terminal": "1"})
    status = (card.get("status") or "ELIGIBLE").lower()
    tags = ["synthetic", f"fd-{suite}", cid, regime.lower(), status.replace("_", "-"), "int-env", "generated"]
    if card.get("third_party"):
        tags.append("third-party")
    return {
        "case_id": cid, "fixture_id": cid, "source_case_id": card.get("source_case_id") or source(cid),
        "generated": True, "generated_from": "gap-doc test-data grid" if card.get("int_pnr") else "regime default (card has no test data)",
        "$schema_version": 2, "scenario_id": f"{cid}-{date}",
        "title": f"{cid}: {card['title'][:70]}", "description": card["title"],
        "canvas": "_canvas/pnr_creation_domestic_ac.json", "contains_pii": False,
        "identity": {"pnr": cid, "booking_date": date, "type": "PNR"},
        "point_of_sale": {"office_id": "YYZAC08AA", "iata_number": "01424012", "system_code": "1A", "agent_type": "AIRLINE",
                          "agent_numeric_sign": "0001", "agent_initials": "FD", "duty_code": "SU", "agent_country": "CA",
                          "agent_city": "YYZ"},
        "last_modification_comment": f"SIM-{cid}-{suite.upper()}", "creation_comment": f"SIM-{cid}-{suite.upper()}",
        "passengers": [{"type": "ADT", "first_name": first, "last_name": last, "gender": "UNKNOWN",
                        "date_of_birth": "1985-03-15", "email": "", "phone": ""}],
        "segments": segs,
        "ticketing": {"issuance_local_date": "2026-06-01", "fare": {"amount": "500.00", "currency": "CAD"},
                      "ticket_numbers": ["0142420000001"]},
        "timeline": [{"version": 0, "at": "2026-06-01T10:00:00Z", "action": "bootstrap", "description": "Pre-ticketing stub"},
                     {"version": 1, "at": "2026-06-01T10:00:01Z", "action": "ticketing_added", "description": "Ticketing reference attached"}],
        "expected_cascade": {"db_end_state": {"trip": {"rows": 1, "status": "ACTIVE"}, "passenger": {"rows": 1},
                                              "flight_segment": {"rows": len(segs)}}, "total_cascade_budget_ms": 30000},
        "classification": {"primary_code": f"FD-{suite.upper()}", "primary_name": f"Flight Disruption {suite.upper()}", "confidence": "high"},
        "tags": tags,
    }


# ---- binding ----------------------------------------------------------------

def bind(suite: str) -> tuple[dict, dict[Path, str]]:
    """Return (case -> binding, file -> case) without touching the disk."""
    cards = load_gapdoc(suite)
    files = _files(suite)
    result: dict[str, dict] = {}
    file_of: dict[Path, str] = {}
    # 1) files already named / stamped with a case id
    for p, j in files.items():
        cid = canonical(p.stem) if re.match(r"^FD_(UAT|SIT)_", p.stem) else (j.get("case_id") and canonical(j["case_id"]))
        if cid and cid in cards and cid not in result and p.parent.name != "_extra":
            result[cid] = {"file": p.name, "fixture_id": j.get("fixture_id") or p.stem, "score": 1.0,
                           "status": "generated" if j.get("generated") else j.get("binding_status", "exact"),
                           "card_title": cards[cid]["title"], "fixture_title": _fixture_title(j)}
            file_of[p] = cid
    # 2) SIT: the package numbering equals the doc numbering
    if suite == "sit":
        for p, j in files.items():
            if p in file_of:
                continue
            cid = canonical(j.get("case_id") or j.get("source_case_id") or "")
            if cid in cards and cid not in result:
                result[cid] = {"file": p.name, "fixture_id": j.get("fixture_id") or j.get("identity", {}).get("pnr"),
                               "score": 1.0, "status": "exact", "card_title": cards[cid]["title"], "fixture_title": _fixture_title(j)}
                file_of[p] = cid
    # 3) title matching for the rest (package fixtures with their own numbering)
    pairs = []
    for p, j in files.items():
        if p in file_of or p.parent.name == "_extra":
            continue
        a = _norm(_fixture_title(j))
        for cid, card in cards.items():
            if cid in result:
                continue
            b = _norm(card["title"])
            if not a or not b:
                continue
            r = difflib.SequenceMatcher(None, a, b).ratio()
            if r < 0.95 and len(a) >= 25 and (b.startswith(a) or a.startswith(b)):
                r = max(r, 0.95)
            if r >= REVIEW:
                pairs.append((r, str(p), cid))
    pairs.sort(key=lambda x: (-x[0], x[1], x[2]))
    for r, ps, cid in pairs:
        p = Path(ps)
        if p in file_of or cid in result:
            continue
        j = files[p]
        result[cid] = {"file": p.name, "fixture_id": j.get("fixture_id") or j.get("identity", {}).get("pnr") or p.stem,
                       "score": round(r, 3), "status": "exact" if r >= EXACT else "review",
                       "card_title": cards[cid]["title"], "fixture_title": _fixture_title(j)}
        file_of[p] = cid
    for cid, card in cards.items():
        result.setdefault(cid, {"file": None, "status": "missing", "card_title": card["title"]})
    return result, file_of


def sync(suite: str, *, generate: bool = True) -> dict:
    """Rename bound files to <case_id>.json, park unbound files in _extra/, generate missing cards."""
    cards = load_gapdoc(suite)
    result, file_of = bind(suite)
    d = _dir(suite)
    extra = d / "_extra"
    files = _files(suite)
    # rename / stamp bound files
    for p, cid in file_of.items():
        j = files[p]
        target = d / f"{cid}.json"
        j = {"case_id": cid, "fixture_id": j.get("fixture_id") or j.get("identity", {}).get("pnr") or p.stem,
             "source_case_id": source(cid), "binding_status": result[cid]["status"],
             **{k: v for k, v in j.items() if k not in ("case_id", "fixture_id", "source_case_id", "binding_status")}}
        j["title"] = re.sub(r"^\S+:\s*", "", j.get("title", "")) if j.get("title", "").startswith(("FD_", "ZFU", "ZFE")) else j.get("title", "")
        j["title"] = f"{cid}: {j['title']}"
        j["tags"] = [cid if (re.match(r"^(FD[_-]|fixture:)", t)) else t for t in j.get("tags", [])]
        if cid not in j["tags"]:
            j["tags"].append(cid)
        if p != target:
            p.unlink()
        _write(target, j)
        result[cid]["file"] = target.name
    # park unbound package files
    moved = []
    for p, j in files.items():
        if p in file_of or p.parent.name == "_extra":
            continue
        extra.mkdir(exist_ok=True)
        fid = j.get("fixture_id") or j.get("identity", {}).get("pnr") or p.stem.split("-")[0]
        j = {"case_id": None, "fixture_id": fid, "source_case_id": None, "binding_status": "unbound",
             **{k: v for k, v in j.items() if k not in ("case_id", "fixture_id", "source_case_id", "binding_status")}}
        j["tags"] = [f"fixture:{fid}" if re.match(r"^(FD[_-]|fixture:)", t) else t for t in j.get("tags", [])]
        _write(extra / f"{fid}.json", j)
        p.unlink()
        moved.append(fid)
    # generate the missing cards
    generated = []
    if generate:
        for cid, v in result.items():
            if v["status"] == "missing":
                j = generate_fixture(cid, cards[cid], suite)
                _write(d / f"{cid}.json", j)
                result[cid] = {"file": f"{cid}.json", "fixture_id": cid, "score": None, "status": "generated",
                               "card_title": cards[cid]["title"], "fixture_title": j["description"]}
                generated.append(cid)
    result["_extra"] = sorted(p.stem for p in extra.glob("*.json")) if extra.exists() else []
    (d / "_case_map.json").write_text(json.dumps(result, indent=1, ensure_ascii=False), encoding="utf-8")
    st = {}
    for k, v in result.items():
        if k != "_extra":
            st[v["status"]] = st.get(v["status"], 0) + 1
    st["extra_files"] = len(result["_extra"])
    st["renamed_or_stamped"] = len(file_of)
    st["generated_now"] = len(generated)
    return st


def load(suite: str, flow: str = "fd") -> dict:
    p = _dir(suite, flow) / "_case_map.json"
    return json.loads(p.read_text(encoding="utf-8")) if p.exists() else {}


def markdown(suite: str) -> str:
    m = load(suite)
    rows = ["| Case | Status | Score | File | Card title | Fixture title |", "|---|---|---|---|---|---|"]
    for cid in sorted(k for k in m if k != "_extra"):
        v = m[cid]
        rows.append(f"| {cid} | {v['status']} | {v.get('score') if v.get('score') is not None else ''} | {v.get('file') or '—'} | "
                    f"{v['card_title'][:70].replace('|', '/')} | {(v.get('fixture_title') or '')[:70].replace('|', '/')} |")
    rows.append("")
    rows.append(f"Extra package fixtures under _extra/ ({len(m.get('_extra', []))}): " + ", ".join(m.get("_extra", [])))
    return "\n".join(rows)


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "sync"
    for suite in ("uat", "sit"):
        if cmd == "sync":
            print(suite, sync(suite))
        else:
            r, _ = bind(suite)
            print(suite, {s: sum(1 for k, v in r.items() if v["status"] == s) for s in ("exact", "review", "generated", "missing")})
