"""Canonical test-case ids: one scheme for every flow and suite.

    <FLOW>_<SUITE>_<NNN>            FD_UAT_001, SOC_SIT_012, BAG_GEN_003
    <FLOW>_<SUITE>_<SUB>_<NNN>      FD_UAT_ED_001, FD_UAT_PAY_001 (a named sub-group inside a suite)

FLOW  : FD, SOC, ANC, BAG, BC, NC, NMVP, SC (any upper-case token)
SUITE : UAT | SIT | GEN (general)
NNN   : zero-padded to 3 digits; the number is stable for the life of the case and never reused.
The id names the *case*; every seeded PNR for it gets its own locator, so a case can be seeded
many times (dataset versions) without the id changing.

Upstream sources spell the same cases differently and those spellings stay accepted:
  FD_TC_001 (UAT gap doc + catalogue), FD-SIT-001 (SIT gap doc + catalogue), FD_ED_TC_01 /
  FD_PAY_TC_001 (UAT sub-groups) and the fixture spelling FD_TC_3P_001..016 for the third-party
  cards FD_TC_185..200. `canonical()` maps any of these to ours; `source()` maps ours back.

For FD UAT the number IS the gap-doc card number. The scenario fixtures are a separate
enumeration (see fixtures/fd-uat/_case_map.json, built by casemap.py) and are bound to cards
by content, never by their own number.
"""
from __future__ import annotations

import re

SUITES = ("UAT", "SIT", "GEN")

# the gap doc / catalogue number the 16 third-party FD UAT cases FD_TC_185..200
_3P_FIRST, _3P_LAST = 185, 200

_CANON = re.compile(r"^([A-Z]+)_(UAT|SIT|GEN)_(?:([A-Z0-9]+)_)?(\d+)$", re.I)
_FD_TC = re.compile(r"^FD[_-]TC[_-](?:(3P)[_-])?(\d+)$", re.I)                 # FD UAT source spelling
_FD_SIT = re.compile(r"^FD[_-]SIT[_-](\d+)$", re.I)                            # FD SIT source spelling
_FD_SUB_TC = re.compile(r"^FD[_-]([A-Z]+)[_-]TC[_-](\d+)$", re.I)               # FD_ED_TC_01, FD_PAY_TC_001 (UAT sub-groups)
_GENERIC = re.compile(r"^([A-Z]+)[_-](TC|UAT|SIT|GEN)[_-](?:([A-Z0-9]+)[_-])?(\d+)$", re.I)
# Baggage spells its cases without a flow prefix: the UAT gap doc and the catalogue both number
# them UAT_TC001..039, a spelling no other flow uses. (Careful: ANC's own bag cases are BAG_TC001..,
# which is a different flow and must not land here.)
_BAG_UAT = re.compile(r"^UAT[_-]?TC[_-]?(\d+)$", re.I)
# Baggage SIT names a sub-group per card: BAG-DELAY-01, BAG-LOST-12, BAG-INTERIM-03.
# (?!UAT|SIT|GEN) keeps an id we have already canonicalised — BAG_UAT_001 — out of this rule, which
# would otherwise read it as the sub-group "UAT" and produce BAG_SIT_UAT_001. canonical() must be
# idempotent: the gap docs carry our ids once they have been rewritten.
_BAG_SIT = re.compile(r"^BAG[_-](?!UAT[_-]|SIT[_-]|GEN[_-])([A-Z]+)[_-](\d+)$", re.I)


def canonical(case_id: str) -> str:
    cid = case_id.strip()
    m = _BAG_UAT.match(cid)
    if m:
        return f"BAG_UAT_{int(m.group(1)):03d}"
    m = _BAG_SIT.match(cid)
    if m:
        return f"BAG_SIT_{m.group(1).upper()}_{int(m.group(2)):03d}"
    m = _FD_TC.match(cid)
    if m:
        n = int(m.group(2))
        if m.group(1):                       # fixture spelling FD_TC_3P_n == gap-doc card FD_TC_(184+n)
            n = n + _3P_FIRST - 1
        return f"FD_UAT_{n:03d}"
    m = _FD_SIT.match(cid)
    if m:
        return f"FD_SIT_{int(m.group(1)):03d}"
    m = _FD_SUB_TC.match(cid)
    if m:
        return f"FD_UAT_{m.group(1).upper()}_{int(m.group(2)):03d}"
    m = _CANON.match(cid)
    if m:
        flow, suite, sub, n = m.groups()
        if flow.upper() == "FD" and suite.upper() == "UAT" and (sub or "").upper() == "3P":
            return f"FD_UAT_{int(n) + _3P_FIRST - 1:03d}"
        return f"{flow.upper()}_{suite.upper()}_{sub.upper() + '_' if sub else ''}{int(n):03d}"
    m = _GENERIC.match(cid)
    if m:
        flow, suite, sub, n = m.groups()
        suite = "UAT" if suite.upper() == "TC" else suite.upper()
        return f"{flow.upper()}_{suite}_{sub.upper() + '_' if sub else ''}{int(n):03d}"
    return cid.upper().replace("-", "_")


_REVERSE: dict[str, str] | None = None


def _reverse_map() -> dict[str, str]:
    """canonical -> source spelling, as recorded by gapdoc.py (covers odd widths like FD_ED_TC_01)."""
    global _REVERSE
    if _REVERSE is None:
        import json
        from pathlib import Path
        _REVERSE = {}
        for p in (Path(__file__).resolve().parent / "fixtures").glob("*/_gapdoc_expected.json"):
            try:
                for k, v in json.loads(p.read_text(encoding="utf-8")).items():
                    if v.get("source_case_id"):
                        _REVERSE[k] = v["source_case_id"]
            except (OSError, ValueError):
                continue
    return _REVERSE


def source(case_id: str) -> str:
    """Our id -> the spelling used by the gap docs / catalogue import (FD only; others are identity)."""
    cid = canonical(case_id)
    if _reverse_map().get(cid) and _reverse_map()[cid] != cid:
        return _reverse_map()[cid]
    m = _CANON.match(cid)
    if not m:
        return cid
    flow, suite, sub, n = m.groups()
    if flow == "FD" and suite == "UAT":
        return f"FD_TC_{n}" if not sub else f"FD_{sub}_TC_{n}"
    if flow == "FD" and suite == "SIT":
        return f"FD-SIT-{n}"
    return cid


def parts(case_id: str) -> dict:
    """{'flow','suite','sub','n'} of a canonical id, or {} when it does not follow the scheme."""
    m = _CANON.match(canonical(case_id))
    if not m:
        return {}
    flow, suite, sub, n = m.groups()
    return {"flow": flow.upper(), "suite": suite.upper(), "sub": (sub or "").upper() or None, "n": int(n)}


def suite_of(case_id: str) -> str | None:
    p = parts(case_id)
    return p["suite"].lower() if p else None


def flow_of(case_id: str) -> str | None:
    p = parts(case_id)
    return p["flow"].lower() if p else None


def aliases(case_id: str) -> list[str]:
    """Every spelling a store might use for this case (canonical, source, zero-width variants)."""
    cid = canonical(case_id)
    out = [cid, source(cid)]
    m = _CANON.match(cid)
    if m and m.group(1).upper() == "FD":
        flow, suite, sub, n = m.groups()
        if suite.upper() == "UAT":
            if sub:
                out += [f"FD_{sub}_TC_{int(n):03d}", f"FD_{sub}_TC_{int(n):02d}", f"FD_{sub}_TC_{int(n)}"]
            else:
                out += [f"FD_TC_{int(n):03d}"]
                if _3P_FIRST <= int(n) <= _3P_LAST:
                    out.append(f"FD_TC_3P_{int(n) - _3P_FIRST + 1:03d}")
        else:
            out += [f"FD-SIT-{int(n):03d}", f"FD_SIT_{int(n):03d}"]
    seen, uniq = set(), []
    for x in out:
        if x not in seen:
            seen.add(x)
            uniq.append(x)
    return uniq
