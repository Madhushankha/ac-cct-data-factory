"""The pages for a judged SOC run: what was seeded, and the Jira test behind each case.

    python tools/soc_report.py --run runs/int/soc-uat-int-v1 --out reports/int/soc/uat/automation/v1

Two pages, because a SOC case is read by two different people:

* `…-seeded.html` — one row per case for whoever needs the data: the PNR, the flight, the
  disruption, what the card expects, and what the engine actually answered in
  `socFlightEligibility`.
* `…-scenarios.html` — one block per case for whoever runs it by hand: the Jira description, the
  ~16 prerequisites the card states, and the full cucumber steps, with the seeded PNR beside them
  so the walk can start immediately.

Why the second page exists at all: SOC's 77 specs each have a Jira test carrying a 100-plus line
Gherkin script, and none of it is visible from a spec file. A tester handed only `SOC_UAT_001` and
a PNR cannot run the case; handed the steps and the PNR, they can.

`soc` is not a flow that can claim a verdict yet (per-passenger-per-segment row shape, receipts,
UAT fixtures), so the engine's answer is reported as **observed** and never as a pass. The
expectation each card states is shown beside it for a human to compare -- which is the point of a
hand-walk, and is not the same thing as a passing check.
"""
from __future__ import annotations

import argparse
import collections
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from tools.report import CSS, FILTER_JS, esc, file_prefix, owner_tag       # noqa: E402

EXTRA_CSS = (".what{font-size:12px;max-width:34em;line-height:1.35}"
             ".tag{display:inline-block;padding:1px 6px;border-radius:9px;font-size:11px;"
             "background:#eef;margin:0 2px 2px 0}"
             "pre.steps{white-space:pre-wrap;font-size:11.5px;line-height:1.45;background:#fafafa;"
             "border:1px solid #e5e5e5;border-radius:6px;padding:10px;max-height:30em;"
             "overflow:auto}"
             "ul.pre{margin:6px 0;padding-left:18px;font-size:12px;line-height:1.5}")


def page(title: str, body: str) -> str:
    return ("<!doctype html><html lang=en><meta charset=utf-8>"
            "<meta name=viewport content='width=device-width,initial-scale=1'>"
            f"<title>{esc(title)}</title><style>{CSS}{EXTRA_CSS}</style>"
            f"<div class=wrap>{body}</div><script>{FILTER_JS}</script></html>")


def load(directory: pathlib.Path) -> tuple[list[dict], dict]:
    records, summary = [], {}
    for path in sorted(directory.glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        if path.name.startswith("_"):
            summary = data if isinstance(data, dict) else {}
            continue
        if isinstance(data, dict):
            records.append(data)
    return records, summary


def specs() -> dict[str, dict]:
    from adapters.file_spec_source import FileSpecSource                    # noqa: PLC0415
    out = {}
    for spec_set in FileSpecSource().describe():
        if spec_set.flow != "soc":
            continue
        for path in sorted(spec_set.path.glob("*.json")):
            spec = json.loads(path.read_text(encoding="utf-8"))
            out[str(spec.get("id") or path.stem)] = spec
    return out


def jira() -> dict[str, object]:
    """case id -> its synced Jira test, which is the authority for what the case means."""
    try:
        from adapters.jira_docs import FileTestDocs                         # noqa: PLC0415
        return {d.case_id: d for d in FileTestDocs().docs("soc/uat/automation")}
    except Exception:                                                       # noqa: BLE001
        return {}


def answered(record: dict) -> list[dict]:
    """The engine's SOC answer, which nests per bound and then per passenger.

    SOC answers per passenger PER SEGMENT, which is exactly the row shape the flow does not read
    yet, so this digs it out for the page rather than relying on the flow's comparison.
    """
    out = []
    for bound in (record.get("document") or {}).get("bounds") or []:
        for block in bound.get("socFlightEligibility") or []:
            # the `segments` level is the whole reason SOC needs a row shape of its own: the
            # answer hangs off a SEGMENT and then a passenger, where FD's hangs off a passenger.
            # Reading it the FD way returned nothing at all on all 77 cases.
            for seg in block.get("segments") or []:
                for pax in seg.get("passengerEligibility") or []:
                    out.append({
                        "bound": block.get("boundRph") if block.get("boundRph") is not None
                        else bound.get("bound"),
                        "regime": block.get("regime"),
                        "flight": f"{seg.get('carrierCode') or ''}{seg.get('flightNumber') or ''}",
                        "route": f"{seg.get('departureAirport')}-{seg.get('arrivalAirport')}",
                        "pax": pax.get("passengerName"),
                        "status": pax.get("eligibilityStatus"),
                        "code": pax.get("systemCode"),
                        "delay": pax.get("delayMinutes"),
                        "band": pax.get("delayCategory"),
                        "control": pax.get("delayType"),
                        "cause": pax.get("delayOrCancelCode"),
                        "reason": pax.get("reason") or pax.get("reasonEnglish"),
                        "categories": pax.get("expenseCategories") or [],
                    })
    return out


def expectation(spec: dict) -> str:
    e = spec.get("expect") or {}
    bits = [e.get("regime"), e.get("eligibility"), e.get("systemCode")]
    if e.get("soc"):
        bits.append(f"soc={json.dumps(e['soc'])[:48]}")
    return " · ".join(str(b) for b in bits if b)


def seeded_page(records, summary, label, env, spec_by_id, doc_by_id) -> str:
    cols = ["case", "Jira", "what it verifies", "PNR", "pnrId", "flight", "route",
            "card expects", "engine answered", "prereqs"]
    head = "".join(f"<th>{esc(c)}</th>" for c in cols)
    rows, codes = [], collections.Counter()
    for r in sorted(records, key=lambda r: r["case"]):
        cid = r["case"]
        spec = spec_by_id.get(cid, {})
        doc = doc_by_id.get(cid)
        got = answered(r)
        for g in got:
            codes[g["code"]] += 1
        answer = "<br>".join(
            f"<span class=mono>bound {esc(g['bound'])} {esc(g['regime'])}: "
            f"<b>{esc(g['status'])}</b> {esc(g['code'] or '')}</span>" for g in got) or "&mdash;"
        rows.append("<tr>" + "".join([
            f"<td class=mono>{esc(cid)}</td>",
            f"<td class=mono>{esc(getattr(doc, 'key', '')) or '&mdash;'}</td>",
            f"<td class=what>{esc(getattr(doc, 'title', '') or spec.get('summary') or '')}</td>",
            f"<td class=mono>{esc(r.get('locator'))}</td>",
            f"<td class=mono>{esc(r.get('pnrId'))}</td>",
            f"<td class=mono>{esc(r.get('flight'))}</td>",
            f"<td class=mono>{esc(r.get('route'))}</td>",
            f"<td class=mono>{esc(expectation(spec))}</td>",
            f"<td>{answer}</td>",
            f"<td class=mono>{len(getattr(doc, 'prerequisite_items', ()) or ())}</td>"]) + "</tr>")

    cards = "".join(f"<div class=card><b>{esc(v)}</b><span>{esc(k)}</span></div>" for k, v in
                    (("cases", len(records)),
                     ("answers observed", sum(codes.values())),
                     ("not judged", summary.get("not_judged", len(records)))))
    top = "".join(f"<span class=tag>{esc(c or '-')} &times;{n}</span>" for c, n in
                  codes.most_common(8))
    body = [f"<h1>Seeded SOC set &mdash; {esc(label)} ({esc(env)})</h1>",
            f"<p class=why>{len(records)} case(s); engine {esc(summary.get('engine'))} release "
            f"{esc(summary.get('release'))}. The SOC flow cannot claim a verdict yet, so the "
            "engine's answers below are <b>observed</b>, not passes: compare them against what "
            "each card expects.</p>",
            f"<div class=cards>{cards}</div><p class=why>engine codes: {top or '&mdash;'}</p>",
            "<input id=q type=search placeholder='filter any column'>",
            f"<table><thead><tr>{head}</tr></thead><tbody>{''.join(rows)}</tbody></table>"]
    return page(f"Seeded {label}", "".join(body))


def scenarios_page(records, label, env, spec_by_id, doc_by_id) -> str:
    by_case = {r["case"]: r for r in records}
    body = [f"<h1>SOC scenarios &mdash; {esc(label)} ({esc(env)})</h1>",
            "<p class=why>One block per case: what Jira says to verify, the prerequisites the "
            "card states, and the cucumber steps to walk &mdash; with the seeded booking beside "
            "them. Open a case to read its script.</p>",
            "<input id=q type=search placeholder='filter by case, Jira key or title'>"]
    for cid in sorted(by_case):
        r, doc = by_case[cid], doc_by_id.get(cid)
        spec = spec_by_id.get(cid, {})
        pre = "".join(f"<li>{esc(i)}</li>"
                      for i in (getattr(doc, "prerequisite_items", ()) or ()))
        steps = esc(getattr(doc, "gherkin", "") or "")
        got = answered(r)
        answer = ", ".join(f"{g['status']} {g['code'] or ''}".strip() for g in got) or "—"
        body.append(
            f"<details><summary class=mono>{esc(cid)} &nbsp; "
            f"{esc(getattr(doc, 'key', ''))} &nbsp; {esc(r.get('locator'))} &nbsp; "
            f"{esc(r.get('flight'))} {esc(r.get('route'))} &nbsp; "
            f"{esc(getattr(doc, 'title', ''))}</summary>"
            f"<div class=what><b>Verify:</b> {esc(getattr(doc, 'goal', '') or '')}</div>"
            f"<div class=why>booking <span class=mono>{esc(r.get('pnrId'))}</span> &mdash; "
            f"card expects <span class=mono>{esc(expectation(spec))}</span> &mdash; "
            f"engine answered <span class=mono>{esc(answer)}</span></div>"
            + (f"<div class=why><b>Prerequisites</b></div><ul class=pre>{pre}</ul>" if pre else "")
            + (f"<div class=why><b>Cucumber steps</b></div><pre class=steps>{steps}</pre>"
               if steps else "<div class=why>no steps synced</div>")
            + "</details>")
    return page(f"Scenarios {label}", "".join(body))


def fixes() -> dict[str, dict]:
    """`builder/fixes-soc.json`'s per-scenario analysis: what it predicted is reachable, and why.

    This file is the second authority after the Jira card. It records, per case, an
    `achievableCode` the engine was expected to return instead of the card's, with a confidence --
    and `engine-limited` where the card's code is not emitted by any SOC rule at all. Judging a
    case against the card alone ignores that analysis and reports a gap the project had already
    explained.
    """
    path = ROOT / "builder" / "fixes-soc.json"
    try:
        return json.loads(path.read_text(encoding="utf-8")).get("perScenario") or {}
    except Exception:                                                       # noqa: BLE001
        return {}


#: who can act on a disagreement, keyed by what the evidence shows
OWNERS = {
    "engine-code-missing": ("The engine cannot emit this code",
                            "Engine team, or correct the card to the code the engine does return. "
                            "`fixes-soc.json` states it: the code is absent from the regime's "
                            "reason-code lookup, or no rule emits it."),
    "nd-vs-ne": ("Engine answers NOT_ELIGIBLE where the card wants NO_DETERMINATION",
                 "Engine team -- a rules decision. The data is right: the partner leg is seeded, "
                 "delayed and published with no AC delay code, which is the condition the card "
                 "describes. The engine reads 'no disruption' where the card wants 'cause "
                 "unknown'. This is the group most likely to be a real product finding."),
    "prediction-missed": ("The predicted achievable code did not occur",
                          "Us, as bookkeeping: these `achievableCode` values were medium or low "
                          "confidence guesses made before the set was ever run. The measured "
                          "answer is now known and can replace the guess."),
}


def classify(card: str, achievable: str, confidence: str, got: set[str]) -> str:
    """Which bucket a disagreement is in, from the evidence rather than a hand-kept list."""
    if str(confidence).lower() == "engine-limited":
        return "engine-code-missing"
    if ("-ND-" in card.upper() or "-PE-" in card.upper()) and not any(
            "-ND-" in g or "-PE-" in g for g in got):
        return "nd-vs-ne"
    if achievable:
        return "prediction-missed"
    return "engine-code-missing"


def disagreements_page(records, label, env, spec_by_id, doc_by_id) -> str:
    """Only the cases that reach neither the card's code nor the predicted achievable one."""
    fx = fixes()
    buckets: dict[str, list] = collections.defaultdict(list)
    agreed = 0
    for rec in sorted(records, key=lambda r: r["case"]):
        cid = rec["case"]
        spec = spec_by_id.get(cid, {})
        want = spec.get("expect") or {}
        card = str(want.get("systemCode") or "").upper()
        fix = fx.get(cid) or {}
        ach = str(fix.get("achievableCode") or "").upper()
        rows = answered(rec)
        got = {str(a["code"]).upper() for a in rows}
        if (card and card in got) or (ach and ach in got):
            agreed += 1
            continue
        buckets[classify(card, ach, fix.get("confidence") or "", got)].append(
            (cid, rec, spec, doc_by_id.get(cid), fix, rows))

    total = len(records)
    bad = total - agreed
    cards_html = "".join(
        f"<div class=card><b>{esc(v)}</b><span>{esc(k)}</span></div>"
        for k, v in (("cases", total), ("as intended", agreed), ("disagree", bad)))
    body = [f"<h1>SOC disagreements &mdash; {esc(label)} ({esc(env)})</h1>",
            f"<div class=cards>{cards_html}</div>",
            "<p class=why>Grouped by what the evidence shows, and by who can act. A case counts as "
            "intended when the engine returns either the Jira card's system code or the "
            "<code>achievableCode</code> that <code>builder/fixes-soc.json</code> predicted for it. "
            "<b>None of these is a seeding defect</b> &mdash; re-seeding reproduces them exactly, "
            "which is how they were separated from data problems.</p>",
            "<input id=q type=search placeholder='filter by case, Jira key or code'>"]

    for key in ("nd-vs-ne", "engine-code-missing", "prediction-missed"):
        items = buckets.get(key) or []
        if not items:
            continue
        title, who = OWNERS[key]
        body.append(f"<h2>{esc(title)} &mdash; {len(items)} case(s)</h2>"
                    f"<p class=why><b>Who can fix it:</b> {esc(who)}</p>")
        for cid, rec, spec, doc, fix, rows in items:
            want = spec.get("expect") or {}
            # what the engine saw, which is the evidence that the data was right
            seen = "; ".join(
                f"{a['regime']} {a['flight']} {a['route']} delay={a['delay']} "
                f"cause={a['cause'] or 'none'} -> {a['status']} {a['code']}" for a in rows[:4])
            unsup = (spec.get("unsupported") or [""])[0]
            body.append(
                f"<details><summary class=mono>{esc(cid)} &nbsp; "
                f"{esc(getattr(doc, 'key', ''))} &nbsp; card wants "
                f"<b>{esc(want.get('eligibility'))} / {esc(want.get('systemCode'))}</b></summary>"
                f"<div class=what>{esc(getattr(doc, 'title', ''))}</div>"
                + (f"<div class=why>predicted achievable: <span class=mono>"
                   f"{esc(fix.get('achievableCode'))}</span> (confidence "
                   f"{esc(fix.get('confidence'))})</div>" if fix.get("achievableCode") else "")
                + (f"<div class=why><b>fixes-soc note:</b> {esc(fix.get('note'))}</div>"
                   if fix.get("note") else "")
                + (f"<div class=why><b>the spec declares unsupported:</b> {esc(unsup)}</div>"
                   if unsup else "")
                + f"<div class=why><b>what the engine saw and answered:</b></div>"
                f"<div class=chk>{esc(seen) or 'no answer at all'}</div>"
                f"<div class=why>booking <span class=mono>{esc(rec.get('pnrId'))}</span> "
                f"&mdash; {esc(rec.get('flight'))} {esc(rec.get('route'))}</div>"
                "</details>")

    body.append("<p class=leg>A case with no engine answer at all is listed under the code it "
                "could not produce. Nothing here is counted as a pass: the SOC flow cannot claim "
                "a verdict, so every number above is a comparison a human made, not a check the "
                "run asserted.</p>")
    return page(f"Disagreements {label}", "".join(body))


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--run", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--owner", default="", help="owner tag for the file name")
    args = ap.parse_args(argv)

    run = pathlib.Path(args.run)
    records, summary = load(run)
    if not records:
        print(f"[report] no case records in {run}")
        return 1
    label = summary.get("label") or run.name
    env = summary.get("env") or run.parent.name
    spec_by_id, doc_by_id = specs(), jira()

    out = pathlib.Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    prefix = file_prefix(out, when=str(summary.get("written_at") or ""),
                         owner=(args.owner or owner_tag(env)))
    pages = {
        f"{prefix}-seeded.html": seeded_page(records, summary, label, env, spec_by_id, doc_by_id),
        f"{prefix}-scenarios.html": scenarios_page(records, label, env, spec_by_id, doc_by_id),
        f"{prefix}-disagreements.html": disagreements_page(records, label, env, spec_by_id,
                                                           doc_by_id),
    }
    for name, text in pages.items():
        (out / name).write_text(text, encoding="utf-8")
        print(f"[report] {out / name}")

    with_steps = sum(1 for r in records
                     if getattr(doc_by_id.get(r["case"]), "gherkin", ""))
    with_answer = sum(1 for r in records if answered(r))
    print(f"[report] {env}/{label}: {len(records)} case(s), {with_steps} with cucumber steps, "
          f"{with_answer} with a SOC answer from the engine")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
