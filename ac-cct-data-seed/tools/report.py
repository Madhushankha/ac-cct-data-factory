"""The two pages for a judged run: what was seeded, and what disagreed.

    python tools/report.py --run runs/int/fd-266-int-full \
                           --run runs/bat/fd-266-bat-full \
                           --baseline "<kit>/UAT_344_PNRS.csv" --out reports/

`tools/seed_report.py` and `tools/disagreement_report.py` are the old kit-shaped versions: they
read a builder batch directory and know nothing about a verdict. This one reads the run records
this project writes -- one JSON per case, holding the expectation, both API answers and every
check -- so a page can say what the engine answered and why that counts as a disagreement.

Why the classification matters: a raw "disagree" list is unusable, because most entries are not
rule defects. Three things produce one:

* **the booking never reached the engine** -- no assessment at all, or the Trip holds no segment
* **the engine folded someone else's leg** -- the flight key was already taken, so the verdict is
  about a different flight. Twice today this looked exactly like a rule defect (AC422/2026-09-03
  answered 420 minutes against our 240)
* **the two environments run different rules** -- BAT is on release 45 / 73fc7241, INT on 43 /
  cde224d2, and 73% of BAT's disagreements pass on INT

Only what survives all three is a candidate finding, and the page says which bucket each case is
in rather than leaving the reader to work it out.
"""
from __future__ import annotations

import argparse
import csv
import datetime as _dt
import html
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

# ---------------------------------------------------------------- reading

#: the checks whose actual value belongs in the summary table, in the order a reader wants them
VERDICT_CHECKS = ("fd_eligibility", "fd_systemCode", "fd_amount", "fd_control", "fd_cause")


class Run:
    """One judged run: its records, keyed by case id."""

    def __init__(self, directory: pathlib.Path):
        self.dir = directory
        self.summary = self._read(directory / "_summary.json") or {}
        self.label = self.summary.get("label") or directory.name
        self.env = self.summary.get("env") or directory.parent.name
        self.cases: dict[str, dict] = {}
        for f in sorted(directory.glob("*.json")):
            if f.name.startswith("_"):
                continue
            rec = self._read(f)
            if rec:
                self.cases[str(rec.get("case") or f.stem)] = rec
        self._backfill_published()

    def written_at(self) -> str:
        """When the run was judged, for the filename. The summary's own value, or the mtime."""
        stamp = self.summary.get("written_at")
        if stamp:
            return str(stamp)
        path = self.dir / "_summary.json"
        if path.exists():
            return _dt.datetime.fromtimestamp(path.stat().st_mtime, _dt.UTC).isoformat()
        return _dt.datetime.now(_dt.UTC).isoformat()

    def _backfill_published(self) -> None:
        """Fill `published` from the build manifest for runs recorded before it was stored.

        The two full runs of 19 Oct were judged by code that did not keep what went out, and the
        difference between "the engine holds another booking's leg" and "the engine answers the
        question we asked" lives exactly there.
        """
        if not self.cases or any(r.get("published") for r in self.cases.values()):
            return
        want = {r.get("pnrId") for r in self.cases.values() if r.get("pnrId")}
        best: dict[str, dict] = {}
        for man in sorted((self.dir.parent).glob("build-*/b*/manifest.json")):
            try:
                rows = json.loads(man.read_text(encoding="utf-8"))
            except Exception:                                               # noqa: BLE001
                continue
            rows = [r for r in rows if isinstance(r, dict) and r.get("pnrId") in want]
            if len(rows) > len(best):
                best = {str(r.get("id")): r for r in rows}
        if not best:
            return
        for cid, rec in self.cases.items():
            row = best.get(cid) or best.get(cid.split("#")[0])
            if not row:
                continue
            legs = []
            for leg in row.get("flights") or []:
                if not isinstance(leg, dict):
                    continue
                day = str(leg.get("depUtc") or "")[:10]
                legs.append({"key": f"{leg.get('carrier', '')}#{leg.get('number', '')}#{day}#"
                                    f"{leg.get('origin', '')}",
                             "kind": leg.get("kind"), "minutes": leg.get("minutes"),
                             # a cancellation's code lives in `cancelCode`, a delay's in `code`:
                             # reading only `code` makes every cancellation look codeless, which
                             # is itself a known defect class (an unknown cancel code becomes
                             # disruption type OTHER and the engine answers ND-X02)
                             "code": (leg.get("code") or leg.get("cancelCode")
                                      or leg.get("arrivalCode"))})
            rec["published"] = legs

    @staticmethod
    def _read(path: pathlib.Path) -> dict | None:
        try:
            return json.loads(path.read_text(encoding="utf-8"))
        except Exception:                                                   # noqa: BLE001
            return None

    @property
    def release(self) -> str:
        for rec in self.cases.values():
            eng = rec.get("engine") or {}
            if eng.get("release"):
                return f"release {eng['release']} / {str(eng.get('rulesSha256') or '')[:16]}"
        return str(self.summary.get("release") or "unknown")

    def counts(self) -> dict[str, int]:
        agree = sum(1 for r in self.cases.values() if r.get("agrees") is True)
        judged = sum(1 for r in self.cases.values() if claims(r))
        return {"cases": len(self.cases), "agree": agree,
                "disagree": judged - agree, "not_judged": len(self.cases) - judged}


def claims(rec: dict) -> bool:
    """Did anything in this record make a claim about the verdict (not just structure)?"""
    return any(c.get("applies") and not c.get("structural") for c in rec.get("checks") or [])


def failed(rec: dict) -> list[dict]:
    return [c for c in rec.get("checks") or []
            if c.get("applies") and c.get("ok") is False]


def check(rec: dict, name: str) -> dict | None:
    for c in rec.get("checks") or []:
        if c.get("name") == name:
            return c
    return None


def passenger(rec: dict) -> str:
    """The name on the booking -- how a test finds its own mail in the shared inbox."""
    doc = rec.get("document") or {}
    for bound in doc.get("bounds") or []:
        for row in bound.get("compensationEligibility") or []:
            for pax in row.get("passengerEligibility") or []:
                if pax.get("passengerName"):
                    return str(pax["passengerName"])
    return ""


def flight_day(rec: dict) -> str:
    doc = rec.get("document") or {}
    for bound in doc.get("bounds") or []:
        itin = bound.get("promisedItinerary") or {}
        for seg in itin.get("associatedSegments") or []:
            if seg.get("departureDatetimeLocal"):
                return str(seg["departureDatetimeLocal"])[:10]
    seg = (rec.get("seen") or {}).get("segments") or []
    return str(seg[0].get("schedDep") or "") if seg else ""


def expected(rec: dict) -> dict[str, str]:
    e = rec.get("expected") or {}
    money = e.get("money") or {}
    return {
        "regime": str(e.get("regime") or ""),
        "eligibility": str(e.get("eligibility") or ""),
        "code": str((e.get("system_code") or {}).get("raw") or ""),
        "amount": (f"{money['amount']:g} {money.get('currency') or ''}".strip()
                   if money.get("amount") is not None else ""),
        "delay": str((e.get("delay") or {}).get("value") or ""),
        "control": str(e.get("control") or ""),
        "cause": str(e.get("cause") or ""),
    }


def actual(rec: dict) -> dict[str, str]:
    """What the engine answered, read off the checks that compared it."""
    out: dict[str, str] = {}
    for name in VERDICT_CHECKS:
        c = check(rec, name)
        if c and c.get("actual") not in (None, ""):
            out[name.replace("fd_", "")] = str(c["actual"])
    return out


# ---------------------------------------------------------------- classifying

BUCKETS = {
    "agree": ("agrees", "the engine answered what the case expects"),
    "not-seeded": ("not seeded", "no booking, or the engine holds no verdict for it"),
    "wrong-leg": ("wrong leg", "the engine folded a flight this case did not publish, so the "
                               "verdict is about someone else's booking"),
    "no-disruption": ("disruption missing", "the booking is there but the engine holds no "
                                            "disruption, so there is nothing to assess"),
    "env-rules": ("environment", "disagrees here and agrees in the other environment: a rules "
                                 "release difference, not a case defect"),
    "finding": ("finding", "the booking and its disruption reached the engine, and the answer "
                           "still differs -- a candidate defect"),
}

ORDER = ("finding", "env-rules", "wrong-leg", "no-disruption", "not-seeded")


def rebooked(rec: dict) -> bool:
    """Did the engine hold a different itinerary than the one promised?

    A cancel-and-rebook case shows no delay in the Trip: the Trip lists what the passenger flew,
    which arrived on time on its own schedule. The disruption is the difference between the
    promise and the actual, and only the assessment document holds both. Reading the Trip alone
    called seven of these "disruption missing" and filed them as our seeding problem, when the
    engine had the promise (AC429, cancelled) and the actual (AC433, flown) all along and the real
    disagreement is what it computed from them -- FD_TC_142 pays EUR 600 on a journey the card
    says arrived within the threshold.
    """
    for bound in (rec.get("document") or {}).get("bounds") or []:
        def ids(which: str) -> set[str]:
            itin = bound.get(which) or {}
            return {str(s.get("segmentId")) for s in itin.get("associatedSegments") or []}

        promised, actual = ids("promisedItinerary"), ids("actualItinerary")
        if promised and actual and promised != actual:
            return True
    return False


def from_seen(rec: dict) -> tuple[str | None, str]:
    """The Trip bucket read off the stored observation, for runs with no `tt_*` checks.

    A run judged before the Trip assertions existed still recorded what the Trip held, in `seen`.
    That is the same evidence the assertions compare, so the classification does not need the
    engine read again -- which matters, because a re-read of an aged booking answers a different
    question than the read that produced the verdict.
    """
    seen = rec.get("seen") or {}
    segments = seen.get("segments") or []
    if not segments:
        return "not-seeded", "the Trip holds no segment for this booking"

    delays = [d for d in (seen.get("delays") or []) if d]
    # compare against what was PUBLISHED, not against the card. Where a patch publishes part of
    # the delay on purpose -- FD_TC_009 publishes a 120-minute remainder over a 120-minute
    # involuntary schedule change to reach 240 -- the card and the published value differ by
    # design, and comparing the card would call a rule question a wrong leg.
    legs = rec.get("published") or []
    if legs and not any(leg.get("kind") in ("delay", "cancel") for leg in legs):
        # the scenario is about absent flight status (FD_TC_139, FD_TC_170): there is no
        # disruption to find, and a Trip holding none is the case working as written
        return None, ""
    pub = [leg.get("minutes") for leg in legs
           if leg.get("minutes") and leg.get("kind") == "delay"]
    want = pub[0] if pub else None
    if want is None:
        want = ((rec.get("expected") or {}).get("delay") or {}).get("value")
    if not want:
        return None, ""
    if pub and any(d in pub for d in delays):
        return None, ""                 # the engine holds what we sent; the answer is the question
    # a cancellation carries no delay minutes: the segment status is the disruption
    cancelled = any(str(s.get("status") or "").upper().startswith("CANCEL") for s in segments)
    if not delays:
        if cancelled or rebooked(rec):
            return None, ""
        return "no-disruption", (f"the Trip holds no delay, and no cancelled segment, while the "
                                 f"case published {want} min")
    if want not in delays:
        return "wrong-leg", (f"the Trip holds {delays} min, the case published {want} min -- the "
                             f"engine is answering about a leg this case did not publish")
    return None, ""


def classify(rec: dict, other: dict | None) -> tuple[str, str]:
    """Which bucket this case is in, and the one line that justifies it."""
    if rec.get("agrees") is True:
        return "agree", ""
    if not claims(rec):
        na = [c for c in rec.get("checks") or [] if not c.get("applies")]
        return "not-seeded", (str(na[0].get("detail")) if na else "nothing was judged")

    trip = check(rec, "tt_trip_found")
    if trip and trip.get("ok") is False:
        return "not-seeded", str(trip.get("detail") or "")
    delay = check(rec, "tt_delay")
    if delay and delay.get("ok") is False:
        return "wrong-leg", str(delay.get("detail") or "")
    disr = check(rec, "tt_disruption")
    if disr and disr.get("ok") is False:
        return "no-disruption", str(disr.get("detail") or "")
    if trip is None and delay is None and disr is None:
        bucket, why = from_seen(rec)
        if bucket:
            return bucket, why

    if other is not None and other.get("agrees") is True:
        return "env-rules", "this case agrees in the other environment"
    return "finding", "; ".join(str(c.get("detail") or "") for c in failed(rec)[:3])


def jira_index() -> dict[str, tuple[str, str]]:
    """case id -> (Jira key, title), from the synced Xray tests.

    The Jira test is the authority for what a case means -- the gap doc is not -- so a page that
    names a disagreement should name the test someone has to open. The kit's own report carried
    this and ours did not.
    """
    try:
        from adapters.jira_docs import FileTestDocs
    except Exception:                                                       # noqa: BLE001
        return {}
    out: dict[str, tuple[str, str]] = {}
    try:
        docs = FileTestDocs()
        for set_name in docs.sets():
            for doc in docs.docs(set_name):
                out[doc.case_id] = (doc.key, doc.title or doc.summary or "")
    except Exception:                                                       # noqa: BLE001
        return out
    return out


def file_prefix(out: pathlib.Path, when: str = "", owner: str = "") -> str:
    """The name a page is saved under: `<env>-<flow>_<phase>_<purpose>-v<n>-<date>-<owner>`.

    Taken from the output directory, which already mirrors the set:
    `reports/int/baggage/sit/po/v2` -> `int-baggage_sit_po-v2-2026-10-19-lahiru`.

    Five things belong in the name because all five change what the file means, and a directory of
    `seeded.html` files tells you none of them once one is copied, mailed or attached to a ticket:
    which **environment** it was read from, which set it is about, which run, when (flight dates
    are relative to the seeding day, so a set goes stale), and whose bookings these are -- every
    seeded PNR carries one contact, and a run that cannot read that inbox cannot drive the case.

    The environment leads because it is the thing a reader most often gets wrong: INT and BAT run
    different rule releases, so the same case legitimately answers differently in each, and two
    pages that differ only in their directory are the easiest pair in this tree to confuse.

    The owner is the inbox name alone (`lahiru`), not the address: the domain is the same on every
    file and adds nothing, and the full address is stated on the page.
    """
    parts = [p for p in out.as_posix().split("/") if p not in ("", ".", "reports")]
    version = parts[-1] if parts and parts[-1].startswith("v") else ""
    env = parts[0] if parts else ""
    # between the env (first) and the version (last) is the set
    spec_set = parts[1:-1] if version else parts[1:]
    bits = [b for b in (env, "_".join(spec_set) or "set") if b]
    if version:
        bits.append(version)
    if when:
        bits.append(when[:10])
    if owner:
        bits.append(owner)
    return "-".join(bits)


def owner_tag(env: str) -> str:
    """Whose bookings these are, as the inbox name alone: `lahiru`."""
    try:
        from core import paths                                             # noqa: PLC0415
        sys.path.insert(0, str(paths.require("agentic-qa")))
        from aqa.workflows.seed.env import ENVS                            # noqa: PLC0415
        email = str(ENVS[env].contact_email)
    except Exception:                                                      # noqa: BLE001
        return ""
    inbox, _, _domain = email.partition("@")
    return inbox


def descriptions() -> dict[str, str]:
    """case id -> what the case is testing, in one line, read from the spec tree.

    The Jira test title is the authority for an FD case and `jira_index` reads it; this is the
    fallback for anything Jira does not cover, and the only source for a set with no Xray tests at
    all. For `baggage/sit/po` the spec's own `summary` IS the description -- "SD-03.24 · SP-03.24 ·
    open AHL, bag NOT delivered" -- because the kit stated the condition and no Jira test exists.

    A page that lists 73 case ids with no sentence beside them is not reviewable, which is the same
    reason `jira_index` was added for FD.
    """
    try:
        from adapters.file_spec_source import FileSpecSource                 # noqa: PLC0415
    except Exception:                                                       # noqa: BLE001
        return {}
    out: dict[str, str] = {}
    try:
        src = FileSpecSource()
        for spec_set in src.describe():
            for path in sorted(spec_set.path.glob("*.json")):
                try:
                    spec = json.loads(path.read_text(encoding="utf-8"))
                except Exception:                                           # noqa: BLE001, PERF203
                    continue
                cid = spec.get("id") or path.stem
                text = (spec.get("summary") or "").strip()
                if not text:
                    source = spec.get("source") or {}
                    text = " · ".join(p for p in (source.get("sd"), source.get("sp"),
                                                  source.get("rule"), source.get("condition"))
                                      if p)
                if text:
                    out[str(cid)] = text
    except Exception:                                                       # noqa: BLE001
        return out
    return out


def baseline(path: pathlib.Path | None) -> dict[str, dict]:
    """The kit's own per-case result, by case id.

    Prefer its `reports/` directory over `UAT_344_PNRS.csv`. The two disagree, and not by a
    little: the CSV's `triptracer_check` column says 264 of 267 PASS, while `validated.json` over
    the same 267 says 205 agree / 57 disagree. They are not two readings of one run --

    * every one of the 57 disagreeing cases carries a DIFFERENT pnrId in the CSV than in the
      report, so the two describe two separate seedings (14:11 and 20:30 on 16 Oct)
    * and the CSV's check is the weaker one: 32 FD rows record an engine system code that differs
      from the expected code and 29 of those are still marked PASS -- FD_ED_TC_18 expects NE-01,
      the engine answered FD-APPR-NE-28, the column says PASS; FD_TC_172..175 expect FD-MIXED-*
      and got FD-EU-* / FD-APPR-*, all PASS. It compares regime and eligibility, not the code

    So `validated.json` is the only kit number comparable to this project's, and a page that puts
    the CSV's 264 beside our own figure is comparing two different questions.
    """
    if not path:
        return {}
    if path.is_dir():
        path = path / "validated.json"
    if not path.is_file():
        return {}

    out: dict[str, dict] = {}
    if path.suffix.lower() == ".json":
        try:
            doc = json.loads(path.read_text(encoding="utf-8"))
        except Exception:                                                   # noqa: BLE001
            return {}
        # `agreeing` is a list of case ids; `disagreeing` is a list of rich records carrying the
        # case, its expectation and the checks that failed. Keying the record itself would make
        # every disagreement a case id no run can ever match.
        def _id(entry) -> str:
            return str(entry.get("case") or "") if isinstance(entry, dict) else str(entry)

        for case in doc.get("agreeing") or []:
            if _id(case):
                out[_id(case)] = {"triptracer_check": "agree", "triptracer_mismatches": ""}
        for case in doc.get("disagreeing") or []:
            cid = _id(case)
            if not cid:
                continue
            why = ""
            if isinstance(case, dict):
                why = "; ".join(str(c.get("detail") or "")
                                for c in case.get("disagreements") or case.get("checks") or [])
            out[cid] = {"triptracer_check": "disagree", "triptracer_mismatches": why}
        detail = path.parent / "disagreements.json"
        if detail.is_file():
            try:
                for row in json.loads(detail.read_text(encoding="utf-8")) or []:
                    cid = str(row.get("case") or "")
                    if not cid:
                        continue
                    eng = row.get("engine") or {}
                    out.setdefault(cid, {"triptracer_check": "disagree"})
                    out[cid]["triptracer_mismatches"] = "; ".join(
                        str(c.get("detail") or "") for c in row.get("checks") or []) or (
                        f"engine {eng.get('status')} {eng.get('code')}")
                    out[cid]["kit_pnrId"] = str(row.get("pnrId") or "")
            except Exception:                                               # noqa: BLE001
                pass
        return out

    with path.open(encoding="utf-8-sig", newline="") as fh:
        for row in csv.DictReader(fh):
            if row.get("scenario"):
                out[row["scenario"].strip()] = row
    return out


# ---------------------------------------------------------------- rendering

CSS = """
:root{--bg:#fff;--fg:#14171a;--mut:#596069;--line:#e3e6ea;--pass:#0f7b36;--fail:#b3261e;
       --warn:#8a5a00;--env:#2d5fa8;--card:#f7f8fa}
@media (prefers-color-scheme:dark){:root{--bg:#15181b;--fg:#e8eaed;--mut:#9aa2ab;--line:#2c3237;
       --pass:#4cc26e;--fail:#ff6b5e;--warn:#e0a52c;--env:#6fa8ff;--card:#1c2024}}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--fg);font:14px/1.5 -apple-system,Segoe UI,Roboto,
     Helvetica,Arial,sans-serif;padding:24px 16px 64px}
.wrap{max-width:1500px;margin:0 auto}
h1{font-size:22px;margin:0 0 4px} h2{font-size:16px;margin:28px 0 8px}
.prov{color:var(--mut);font-size:12px;margin-bottom:18px}
.prov code{background:var(--card);padding:1px 5px;border-radius:4px}
.cards{display:flex;flex-wrap:wrap;gap:10px;margin:14px 0 6px}
.card{background:var(--card);border:1px solid var(--line);border-radius:8px;padding:10px 14px;
      min-width:120px}
.card b{display:block;font-size:22px;font-weight:600} .card span{color:var(--mut);font-size:12px}
table{border-collapse:collapse;width:100%;font-size:13px}
th,td{border-bottom:1px solid var(--line);padding:6px 8px;text-align:left;vertical-align:top}
th{position:sticky;top:0;background:var(--bg);font-weight:600;font-size:12px;color:var(--mut)}
tr:hover td{background:var(--card)}
.mono{font-family:ui-monospace,SFMono-Regular,Consolas,monospace;font-size:12px}
.b{display:inline-block;padding:1px 7px;border-radius:10px;font-size:11px;font-weight:600;
   white-space:nowrap}
.b.agree{background:rgba(15,123,54,.14);color:var(--pass)}
.b.finding{background:rgba(179,38,30,.14);color:var(--fail)}
.b.env-rules{background:rgba(45,95,168,.14);color:var(--env)}
.b.wrong-leg,.b.no-disruption,.b.not-seeded{background:rgba(138,90,0,.16);color:var(--warn)}
.why{color:var(--mut);font-size:12px}
.what{font-size:12px;max-width:34em;line-height:1.35}
details{margin:8px 0;border:1px solid var(--line);border-radius:8px;padding:8px 12px;
        background:var(--card)}
summary{cursor:pointer;font-weight:600}
.chk{font-size:12px;margin:3px 0} .chk.no{color:var(--fail)} .chk.yes{color:var(--pass)}
.leg{color:var(--mut);font-size:12px;margin:10px 0 0}
input[type=search]{width:260px;padding:5px 8px;border:1px solid var(--line);border-radius:6px;
  background:var(--bg);color:var(--fg);margin:8px 0}
@media(max-width:760px){body{padding:16px}table{font-size:12px}}
"""

FILTER_JS = """
const q=document.getElementById('q');
if(q)q.addEventListener('input',function(){var v=q.value.toLowerCase();
  document.querySelectorAll('tbody tr').forEach(function(r){
    r.style.display=r.textContent.toLowerCase().indexOf(v)>=0?'':'none';});});
"""


def esc(v) -> str:
    """Escape, and repair the mojibake Jira's stored text carries.

    The synced tests hold 8,516 U+FFFD replacement characters -- accents and dashes lost long
    before this project saw them ("Mixed Regime � EU Eligible"). Rendering them raw makes the
    page look broken and a publisher refuses the file outright, so a spaced one becomes the dash it
    almost certainly was and the rest are dropped.
    """
    text = "" if v is None else str(v)
    if "�" in text:
        text = text.replace(" � ", " - ").replace("�", "")
    return html.escape(text)


def page(title: str, body: str) -> str:
    return ("<!doctype html><html lang=en><meta charset=utf-8>"
            "<meta name=viewport content='width=device-width,initial-scale=1'>"
            f"<title>{esc(title)}</title><style>{CSS}</style>"
            f"<div class=wrap>{body}</div><script>{FILTER_JS}</script></html>")


def provenance(runs: list[Run], base: dict) -> str:
    now = _dt.datetime.now(_dt.timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    bits = [f"written {now}"]
    for r in runs:
        c = r.counts()
        bits.append(f"<code>{esc(r.env)}</code> {esc(r.label)} &mdash; {c['cases']} case(s), "
                    f"{esc(r.release)}, seeded {esc(str(r.summary.get('written_at') or '')[:16])}")
    if base:
        bits.append(f"kit baseline: {len(base)} row(s)")
    bits.append("both APIs per booking: "
                "<code>GET /api/service/trips/{pnrId}?engine=raptor</code> then "
                "<code>POST /api/dds-evaluations?engine=raptor</code>")
    return "<div class=prov>" + " &middot; ".join(bits) + "</div>"


def cards(run: Run, buckets: dict[str, int]) -> str:
    c = run.counts()
    items = [("cases", c["cases"]), ("agree", c["agree"]), ("disagree", c["disagree"])]
    items += [(BUCKETS[k][0], v) for k, v in buckets.items() if k != "agree" and v]
    return "<div class=cards>" + "".join(
        f"<div class=card><b>{v}</b><span>{esc(k)}</span></div>" for k, v in items) + "</div>"


def badge(bucket: str) -> str:
    return f"<span class='b {bucket}'>{esc(BUCKETS[bucket][0])}</span>"


def seeded_page(runs: list[Run], base: dict) -> str:
    primary, others = runs[0], runs[1:]
    jira = jira_index()
    desc = descriptions()
    cols = ["case", "Jira", "what it tests", "verdict", "PNR", "pnrId", "passenger", "flight",
            "route", "date", "expected", "engine answered", "failed checks"]
    cols += [o.env for o in others]
    if base:
        cols.append("kit")
    head = "".join(f"<th>{esc(c)}</th>" for c in cols)

    rows: list[str] = []
    buckets: dict[str, int] = {}
    for cid in sorted(primary.cases):
        rec = primary.cases[cid]
        other = next((o.cases.get(cid) for o in others if o.cases.get(cid)), None)
        bucket, _ = classify(rec, other)
        buckets[bucket] = buckets.get(bucket, 0) + 1
        e, a = expected(rec), actual(rec)
        exp = f"{e['regime']} {e['eligibility']} {e['code']}".strip()
        if e["amount"]:
            exp += f" &mdash; {esc(e['amount'])}"
        got = " ".join(filter(None, (a.get("eligibility", ""), a.get("systemCode", ""),
                                     a.get("amount", "")))) or "&mdash;"
        key, title = jira.get(cid) or jira.get(cid.split("#")[0]) or ("", "")
        # the Jira title where there is one, the spec's own summary otherwise: the point is that
        # every row says what it is testing, not that it says where the words came from
        what = title or desc.get(cid) or desc.get(cid.split("#")[0]) or ""
        cells = [f"<td class=mono>{esc(cid)}</td>",
                 f"<td class=mono title='{esc(title)}'>{esc(key) or '&mdash;'}</td>",
                 f"<td class=what>{esc(what) or '&mdash;'}</td>",
                 f"<td>{badge(bucket)}</td>",
                 f"<td class=mono>{esc(rec.get('locator'))}</td>",
                 f"<td class=mono>{esc(rec.get('pnrId'))}</td>",
                 f"<td>{esc(passenger(rec))}</td>",
                 f"<td class=mono>{esc(rec.get('flight'))}</td>",
                 f"<td class=mono>{esc(rec.get('route'))}</td>",
                 f"<td class=mono>{esc(flight_day(rec))}</td>",
                 f"<td class=mono>{exp}</td>",
                 f"<td class=mono>{esc(got) if got != '&mdash;' else got}</td>",
                 # which checks failed, not just the verdict fields: FD_TC_002's eligibility, code
                 # and amount all agree and only `row_count` fails, so the two columns above read
                 # as identical and the row looks wrongly flagged without this one
                 f"<td class=mono>{esc(', '.join(c['name'].replace('fd_', '').replace('tt_', 'trip:') for c in failed(rec))) or '&mdash;'}</td>"]
        for o in others:
            orec = o.cases.get(cid)
            if orec is None:
                cells.append("<td class=why>not seeded</td>")
            else:
                ob, _ = classify(orec, rec)
                cells.append(f"<td>{badge(ob)}</td>")
        if base:
            row = base.get(cid) or base.get(cid.split("#")[0])
            cells.append(f"<td class=mono>{esc((row or {}).get('triptracer_check') or '-')}</td>")
        rows.append("<tr>" + "".join(cells) + "</tr>")

    body = [f"<h1>Seeded set &mdash; {esc(primary.label)} ({esc(primary.env)})</h1>",
            provenance(runs, base), cards(primary, buckets),
            "<input id=q type=search placeholder='filter any column'>",
            f"<table><thead><tr>{head}</tr></thead><tbody>{''.join(rows)}</tbody></table>",
            "<p class=leg>The surname carries the case id (BOUCHARDEAB for FD_ED_TC_01): one "
            "Mailinator box takes every scenario's mail, so the name is how a run finds its own. "
            "Flight dates are relative to the seeding day &mdash; a set goes stale.</p>"]
    return page(f"Seeded {primary.label}", "".join(body))


def disagreements_page(runs: list[Run], base: dict) -> str:
    primary, others = runs[0], runs[1:]
    grouped: dict[str, list[tuple[str, dict, str]]] = {k: [] for k in ORDER}
    for cid in sorted(primary.cases):
        rec = primary.cases[cid]
        other = next((o.cases.get(cid) for o in others if o.cases.get(cid)), None)
        bucket, why = classify(rec, other)
        if bucket != "agree":
            grouped[bucket].append((cid, rec, why))

    jira = jira_index()
    desc = descriptions()
    body = [f"<h1>Disagreements &mdash; {esc(primary.label)} ({esc(primary.env)})</h1>",
            provenance(runs, base),
            cards(primary, {k: len(v) for k, v in grouped.items()})]
    for bucket in ORDER:
        items = grouped[bucket]
        if not items:
            continue
        body.append(f"<h2>{badge(bucket)} {len(items)} case(s)</h2>"
                    f"<p class=why>{esc(BUCKETS[bucket][1])}</p>")
        for cid, rec, why in items:
            e = expected(rec)
            lines = []
            for c in rec.get("checks") or []:
                if not c.get("applies"):
                    lines.append(f"<div class=chk>- {esc(c.get('name'))}: "
                                 f"{esc(c.get('detail'))}</div>")
                    continue
                cls = "yes" if c.get("ok") else "no"
                mark = "ok" if c.get("ok") else "FAIL"
                lines.append(f"<div class='chk {cls}'>{mark} {esc(c.get('name'))}: "
                             f"{esc(c.get('detail'))}</div>")
            kit = base.get(cid) or base.get(cid.split("#")[0]) or {}
            extra = ""
            if kit:
                extra = (f"<div class=why>kit: {esc(kit.get('triptracer_check'))}"
                         + (f" &mdash; {esc(kit.get('triptracer_mismatches'))}"
                            if kit.get("triptracer_mismatches") else "") + "</div>")
            for o in others:
                orec = o.cases.get(cid)
                if orec is not None:
                    ob, owhy = classify(orec, rec)
                    extra += (f"<div class=why>{esc(o.env)}: {esc(BUCKETS[ob][0])}"
                              + (f" &mdash; {esc(owhy)}" if owhy else "") + "</div>")
            key, title = jira.get(cid) or jira.get(cid.split("#")[0]) or ("", "")
            what = title or desc.get(cid) or desc.get(cid.split("#")[0]) or ""
            body.append(
                f"<details><summary class=mono>{esc(cid)} &nbsp; {esc(key)} &nbsp; "
                f"{esc(rec.get('pnrId'))} &nbsp; "
                f"{esc(rec.get('flight'))} {esc(rec.get('route'))} {esc(flight_day(rec))}</summary>"
                + (f"<div class=what>{esc(what)}</div>" if what else "")
                + f"<div class=why>expects {esc(e['regime'])} {esc(e['eligibility'])} "
                f"{esc(e['code'])} {esc(e['amount'])} &mdash; delay {esc(e['delay'])} min, "
                f"{esc(e['control'])}/{esc(e['cause'])}</div>"
                f"<div class=why>{esc(why)}</div>{''.join(lines)}{extra}</details>")
    return page(f"Disagreements {primary.label}", "".join(body))


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--run", action="append", required=True,
                    help="a run directory; the first is the subject, later ones are compared")
    ap.add_argument("--owner", default="", help="owner tag for the file name; defaults to the env contact, pass it when the run published something else")
    ap.add_argument("--baseline", default="", help="the kit's UAT_344_PNRS.csv")
    ap.add_argument("--out", default="reports", help="directory for the two pages")
    a = ap.parse_args(argv)

    runs = [Run(pathlib.Path(d)) for d in a.run]
    for r in runs:
        if not r.cases:
            print(f"[report] {r.dir}: no case records")
    if not runs[0].cases:
        return 2
    base = baseline(pathlib.Path(a.baseline) if a.baseline else None)

    out = pathlib.Path(a.out)
    out.mkdir(parents=True, exist_ok=True)
    prefix = file_prefix(out, when=runs[0].written_at(), owner=(a.owner or owner_tag(runs[0].env)))
    pages = {f"{prefix}-seeded.html": seeded_page(runs, base),
             f"{prefix}-disagreements.html": disagreements_page(runs, base)}
    for name, text in pages.items():
        (out / name).write_text(text, encoding="utf-8")
    for r in runs:
        c = r.counts()
        print(f"[report] {r.env}/{r.label}: {c['cases']} case(s), {c['agree']} agree, "
              f"{c['disagree']} disagree, {c['not_judged']} not judged")
    for name in pages:
        print(f"[report] {out / name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
