"""Between a scenario spec and the fixture shape `aqa.workflows.seed` renders.

A spec says what the case IS. A fixture is one pipeline's rendering of it, and carries a lot that is
not scenario at all: a point of sale, a canvas path, a cascade budget, a timeline, schema versions.

So the conversion is asymmetric on purpose:

* `fixture_to_spec` lifts the scenario out -- passengers, segments, the outcome and the expected
  verdict -- and records where it came from in `source`. The boilerplate is left behind.
* `spec_to_fixture` goes the other way by loading that `source` fixture and overlaying the spec's
  scenario on top of it. It does not synthesise a fixture from nothing.

That second direction is a transitional dependency, and a deliberate one. The alternative is a
second renderer, and the renderer is where the risk lives: identity reservation that avoids locator,
surname, ticket and flight collisions, the PNR version pair, the FDM shape, the publish order. That
code is proven over thousands of checkpoints. Re-typing it here to feel self-contained would be the
same mistake that left the agentic-qa seeder and the uat-scenarios kit unable to compare results.

When this project owns rendering, `source` goes away and `spec_to_fixture` with it.

Two schema extensions, both because the kit's specs are written for a builder that dates flights
relative to the run day, and these cases carry absolute dates that must not move:

* `depDate` / `arrDate` on a segment: the date its `depLocal` / `arrLocal` time falls on. A full ISO
  datetime cannot go in `depLocal`, because the compact form's `L` line splits `dep-arr` on "-".
* `dob` on a passenger: the fixtures state one, the kit's specs do not, and an identity check
  answers to it.
"""
from __future__ import annotations

import datetime as _dt
import json
import pathlib
from typing import Any

#: fixture `expected` key -> spec `expect` key
_EXPECT = {
    "status": "eligibility", "regime": "regime", "system_code": "systemCode",
    "amount": "amount", "currency": "currency", "delay_minutes": "delayMin",
    "delay_type": "control", "delay_band": "delayBand", "delay_code": "cause",
}


def _date(iso: str | None) -> str | None:
    return iso[:10] if iso else None


def _time(iso: str | None) -> str | None:
    return iso[11:16] if iso and len(iso) >= 16 else None


def fixture_to_spec(fixture: dict, *, spec_id: str, suite: str, family: str = "FD",
                    expected: dict | None = None, assumed: list[str] | None = None) -> dict:
    """The scenario inside a fixture, as a spec.

    `expected` overrides the fixture's own, for the sets that keep their expectation elsewhere --
    the gap-doc cases hold `expected: null` in the fixture and state the verdict in the catalogue,
    and the 8 `FD_UAT_DATA_*` cases state it in neither, only in the dataset manifest that seeded
    them. Passing it in keeps this function from guessing which is authoritative.
    """
    segs_in = fixture.get("segments") or []
    day0 = _date((segs_in[0].get("dep_local") if segs_in else None)) or None

    segments = []
    for i, s in enumerate(segs_in, start=1):
        dep_date = _date(s.get("dep_local"))
        offset = None
        if dep_date and day0:
            offset = (_dt.date.fromisoformat(dep_date) - _dt.date.fromisoformat(day0)).days
        seg: dict[str, Any] = {
            "seg": i,
            # not defaulted: FD_UAT_001 states no bound, and inventing one changes the fixture
            "bound": s.get("bound"),
            "carrier": s.get("carrier"),
            "number": str(s.get("flight_number")) if s.get("flight_number") is not None else None,
            "origin": s.get("origin"),
            "destination": s.get("destination"),
            "depLocal": _time(s.get("dep_local")),
            "arrLocal": _time(s.get("arr_local")),
            "dayOffset": offset,
            "cabin": s.get("cabin"),
            "bookingClass": s.get("booking_class"),
            "status": s.get("status"),
            # the extensions: these cases carry absolute dates, and a 72-hour case stops being one
            # if its flight moves
            "depDate": dep_date,
        }
        arr_date = _date(s.get("arr_local"))
        if arr_date and arr_date != dep_date:
            seg["arrDate"] = arr_date
        for src, dst in (("operating_carrier", "operatingCarrier"),
                         ("cancellation_code", "cancelCode")):
            if s.get(src) is not None:
                seg[dst] = s[src]
        segments.append(seg)

    passengers = []
    for p in fixture.get("passengers") or []:
        pax: dict[str, Any] = {
            "type": p.get("type"),
            "firstName": p.get("first_name"),
            "lastName": p.get("last_name"),
            "residence": p.get("country_of_residence"),
            "employee": bool((fixture.get("meta") or {}).get("office_id")) or None,
        }
        if p.get("date_of_birth"):
            pax["dob"] = p["date_of_birth"]
        loy = p.get("loyalty_number")
        if loy and loy != "MINTED":
            pax["aeroplanNumber"] = str(loy)
        tier = (fixture.get("loyalty") or {}).get("tier")
        if tier:
            pax["aeroplanTier"] = tier
        passengers.append({k: v for k, v in pax.items() if v is not None})

    exp_in = expected if expected is not None else (fixture.get("expected") or {})
    expect = {dst: exp_in.get(src) for src, dst in _EXPECT.items() if exp_in.get(src) is not None}

    # The outcome. A fixture does not say WHICH segment was disrupted -- the delay reaches the
    # booking through the FDM the renderer builds from `expected` -- so this places it on the
    # segment whose arrival the delay is measured against, the last one, and says so in `assumed`.
    outcomes = []
    notes = list(assumed or [])
    mins, code = exp_in.get("delay_minutes"), exp_in.get("delay_code")
    if segments and (mins or code):
        outcomes.append({k: v for k, v in (
            ("seg", segments[-1]["seg"]), ("kind", "delay"),
            ("arrDelayMin", mins or None), ("delayCode", str(code) if code else None),
        ) if v is not None})
        if len(segments) > 1:
            notes.append(f"the delay is placed on segment {segments[-1]['seg']} of "
                         f"{len(segments)}: the fixture states it once for the booking")

    spec = {
        "id": spec_id,
        "family": family,
        "summary": fixture.get("title") or fixture.get("summary") or "",
        "passengers": passengers,
        "segments": segments,
        "flightDaysAgo": None,          # these cases are dated absolutely; see depDate
        "outcomes": outcomes,
        "rebooking": [], "scheduleChanges": [], "paxEvents": [], "vouchers": [], "bags": [],
        "expect": expect,
        "assumed": notes,
        "unsupported": [],
        "source": {
            "repo": "agentic-qa",
            "suite": suite,
            "fixture": f"{fixture.get('case_id') or fixture.get('fixture_id')}.json",
            "case_id": fixture.get("case_id"),
            "source_case_id": fixture.get("source_case_id"),
        },
    }
    return spec


def spec_to_fixture(spec: dict, fixtures_root: pathlib.Path) -> dict:
    """The spec as a fixture the agentic-qa pipeline can render, built on its `source` fixture.

    Only the scenario is overlaid, and only where the spec states it. Everything the fixture holds
    that a spec does not describe -- point of sale, canvas, cascade budget, timeline -- is left
    exactly as it was, because changing it would change what the case means in ways no spec records.
    """
    src = spec.get("source") or {}
    if not src.get("fixture"):
        raise ValueError(f"{spec.get('id')}: no source fixture, so no fixture can be built yet")
    path = fixtures_root / src["suite"] / src["fixture"]
    if not path.exists():
        raise FileNotFoundError(f"{spec.get('id')}: source fixture missing at {path}")
    fx = json.loads(path.read_text(encoding="utf-8"))

    # only case_id:  is the fixture's own identity (FD_UAT_001's is "ZFU001") and
    # casemap.py maps cases to fixtures by it, so overwriting it breaks that mapping
    fx["case_id"] = spec["id"]
    fx["source_case_id"] = src.get("source_case_id") or src.get("case_id")
    if spec.get("summary"):
        fx["title"] = spec["summary"]

    for i, seg in enumerate(spec.get("segments") or []):
        if i >= len(fx.get("segments") or []):
            break
        tgt = fx["segments"][i]
        dep_date = seg.get("depDate") or _date(tgt.get("dep_local"))
        arr_date = seg.get("arrDate") or dep_date
        if seg.get("depLocal") and dep_date:
            tgt["dep_local"] = f"{dep_date}T{seg['depLocal']}:00"
        if seg.get("arrLocal") and arr_date:
            tgt["arr_local"] = f"{arr_date}T{seg['arrLocal']}:00"
        for key, fkey in (("carrier", "carrier"), ("number", "flight_number"),
                          ("origin", "origin"), ("destination", "destination"),
                          ("status", "status"), ("bound", "bound"), ("cabin", "cabin")):
            if seg.get(key) is not None:
                tgt[fkey] = seg[key]

    for i, pax in enumerate(spec.get("passengers") or []):
        if i >= len(fx.get("passengers") or []):
            break
        tgt = fx["passengers"][i]
        for key, fkey in (("type", "type"), ("firstName", "first_name"),
                          ("lastName", "last_name"), ("residence", "country_of_residence"),
                          ("dob", "date_of_birth"), ("aeroplanNumber", "loyalty_number")):
            if pax.get(key) is not None:
                tgt[fkey] = pax[key]

    exp = spec.get("expect") or {}
    if exp:
        out = dict(fx.get("expected") or {})
        for fkey, skey in _EXPECT.items():
            if exp.get(skey) is not None:
                out[fkey] = exp[skey]
        fx["expected"] = out
    return fx
