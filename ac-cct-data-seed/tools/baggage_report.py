"""The pages for a judged baggage run: what was seeded, and what the baggage EA answered.

    python tools/baggage_report.py --run runs/int/baggage-po-int-seed-1019 \
                                   --out reports/int/baggage/sit/po/v1

`tools/report.py` is the FD-shaped report and it cannot serve this set, for a reason that is the
whole point of the baggage flow's remaining `needs`: **FD answers per passenger, baggage answers
per bag.** FD's verdict sits on the row (`eligibilityStatus`, `systemCode`); baggage nests its
answer under `bounds[].baggageClaimEligibility[].passengerEligibility[]`, and again under `bags[]`,
where each bag carries its own `lostBaggageEligibility` and `interimExpensesEligibility`. A page
that read the generic shape would show an empty verdict column on all 73 and imply the engine said
nothing, which is false.

So the two pages here say three separate things, and keep them separate on purpose:

* **what the case is testing** -- the kit's SD, SP, BAG rule and condition. There is no Jira test
  for this set, so the spec's own `summary` is the description, and a page of 73 bare ids is not
  reviewable.
* **the bag facts, expected against seen** -- `expectBag` against the bag rows the Trip returned.
  This is the comparison a PO walks, and it is the one this project can actually make.
* **what the engine decided** -- the real `BAG-LB-*` / `BAG-IE-*` codes. Reported as *observed*,
  never as a pass: no spec here states an expected verdict, so there is nothing to compare it
  against. A green tick for a verdict nobody stated is the one result this must never print.

`ahlCount` counts DISTINCT AHL ids, not bags that have one: two bags sharing one AHL is the
intended shape for the "multiple people on one AHL" cases, and counting bags there reports a false
disagreement.
"""
from __future__ import annotations

import argparse
import collections
import datetime as _dt
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from tools.report import (CSS, FILTER_JS, esc, file_prefix, owner_tag,      # noqa: E402
                          passenger)
from tools.booking_identity import cell, identities, lookup                   # noqa: E402

#: the bag facts derivable from a Trip bag row, and therefore comparable
COMPARED = ("bagCount", "ahlCount", "isAhlPresent", "isClosedAhlPresent",
            "isMultipleOpenAhlPresent", "isBagDelivered")
#: stated in `expectBag` but not answerable from a bag row -- named so the page does not imply
#: they were checked
NOT_COMPARED = ("isLastCarrierAC", "isOal", "oldDaysSinceArrival", "closedDaysAgo",
                "deliveredHoursAfterSchedArrival")
CLOSED = "BAG_DELAYED_RECORD_CLOSED"
DELIVERED = "BAG_DELIVERED_TO_CAROUSEL"


def page(title: str, body: str) -> str:
    return ("<!doctype html><html lang=en><meta charset=utf-8>"
            "<meta name=viewport content='width=device-width,initial-scale=1'>"
            f"<title>{esc(title)}</title><style>{CSS}{EXTRA_CSS}</style>"
            f"<div class=wrap>{body}</div><script>{FILTER_JS}</script></html>")


EXTRA_CSS = (".what{font-size:12px;max-width:30em;line-height:1.35}"
             ".bad{color:#b00020;font-weight:600}.good{color:#0a7d33}"
             ".tag{display:inline-block;padding:1px 6px;border-radius:9px;font-size:11px;"
             "background:#eef;margin:0 2px 2px 0}")


def load(directory: pathlib.Path) -> tuple[list[dict], dict]:
    """Every case record in a run, and the run's own summary."""
    records = []
    summary = {}
    for path in sorted(directory.glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        if path.name.startswith("_"):
            summary = data
            continue
        records.append(data)
    return records, summary


def specs() -> dict[str, dict]:
    """case id -> its spec, for the expectation and the description."""
    from adapters.file_spec_source import FileSpecSource                    # noqa: PLC0415
    out = {}
    for spec_set in FileSpecSource().describe():
        if spec_set.flow != "baggage":
            continue
        for path in sorted(spec_set.path.glob("*.json")):
            spec = json.loads(path.read_text(encoding="utf-8"))
            out[str(spec.get("id") or path.stem)] = spec
    return out


def description(spec: dict) -> str:
    """What the case is testing: the kit's own words, which no Jira test restates."""
    text = (spec.get("summary") or "").strip()
    if text:
        return text
    source = spec.get("source") or {}
    return " · ".join(p for p in (source.get("sd"), source.get("sp"), source.get("rule"),
                                  source.get("condition")) if p)


def seen_facts(bags: list[dict]) -> dict:
    """The bag facts, derived from the rows the Trip returned.

    Both AHL counts are over DISTINCT ids: a bag row carries the id of the AHL it belongs to, so
    two bags on one AHL yield one record, not two.
    """
    open_ahls = {b["ahl"] for b in bags
                 if b.get("ahl") and CLOSED not in {e for e, _ in b.get("events") or []}}
    return {
        "bagCount": len(bags),
        "ahlCount": len({b["ahl"] for b in bags if b.get("ahl")}),
        "isAhlPresent": any(b.get("ahl") for b in bags),
        "isClosedAhlPresent": any(CLOSED in {e for e, _ in b.get("events") or []} for b in bags),
        "isMultipleOpenAhlPresent": len(open_ahls) > 1,
        "isBagDelivered": any(DELIVERED in {e for e, _ in b.get("events") or []} for b in bags),
    }


def verdicts(record: dict) -> list[dict]:
    """The baggage EA's answer, dug out of the nesting FD's reader cannot follow.

    One entry per bound-and-passenger that carries bags. The bound with no bag is skipped rather
    than reported as a verdict: on a return trip the outbound answers "no AHL" about a bag that was
    never on it, which is true and not what the case is about.
    """
    out = []
    for bound in (record.get("document") or {}).get("bounds") or []:
        for block in bound.get("baggageClaimEligibility") or []:
            for pax in block.get("passengerEligibility") or []:
                if not pax.get("bags"):
                    continue
                out.append({
                    "bound": block.get("boundRph"),
                    "route": f"{block.get('boundOrigin')}-{block.get('boundDestination')}",
                    "code": pax.get("systemCode"),
                    "lost": pax.get("isEligibleForLostBagReimbursement"),
                    "interim": pax.get("isEligibleForInterimExpenses"),
                    "reason": pax.get("reason"),
                    "days": pax.get("daysSinceJourneyEnd"),
                    "bags": [{
                        "tag": b.get("bagTagNumber"),
                        "ahl": b.get("ahlCaseId"),
                        "status": b.get("ahlStatus"),
                        "last": b.get("bagLastStatus"),
                        "lost": (b.get("lostBaggageEligibility") or {}).get("systemCode"),
                        "interim": (b.get("interimExpensesEligibility") or {}).get("systemCode"),
                    } for b in pax.get("bags") or []],
                })
    return out


def stamped_contact(env: str) -> tuple[str, str]:
    """The contact the publisher stamps on every booking in this environment.

    Not read from the run record, which does not store it: it is one value for the whole run, so a
    per-case column would be 73 copies of it. It is on the page because a booking carrying the
    builder's synthetic `synth-*@synth.test` address is unusable -- the suite fetches OTP and
    notification mail from the Mailinator box, and nothing can ever arrive at `synth.test`.
    """
    try:
        from core import paths                                             # noqa: PLC0415
        sys.path.insert(0, str(paths.require("agentic-qa")))
        from aqa.workflows.seed.env import ENVS                            # noqa: PLC0415
        env_def = ENVS[env]
        return str(env_def.contact_email), str(env_def.contact_phone)
    except Exception:                                                      # noqa: BLE001
        return "", ""


def contact_line(env: str) -> str:
    email, phone = stamped_contact(env)
    if not email:
        return ""
    return (f"<p class=why>Contact stamped on every booking in <b>{esc(env)}</b>: "
            f"<span class=mono>{esc(email)}</span> / <span class=mono>{esc(phone)}</span>. "
            "The phone is a mock; the address must be the Mailinator box or no run can read its "
            "mail.</p>")


def cards(records: list[dict], agreed: int, codes: collections.Counter) -> str:
    bits = [("cases", len(records)), ("bag facts agree", f"{agreed}/{len(records)}"),
            ("verdicts observed", sum(codes.values()))]
    cells = "".join(f"<div class=card><b>{esc(v)}</b><span>{esc(k)}</span></div>"
                    for k, v in bits)
    top = "".join(f"<span class=tag>{esc(c or '-')} &times;{n}</span>"
                  for c, n in codes.most_common())
    return f"<div class=cards>{cells}</div><p class=why>engine codes: {top}</p>"


def seeded_page(records: list[dict], summary: dict, label: str, env: str,
                spec_by_id: dict[str, dict], ids: dict[str, dict] | None = None) -> str:
    cols = ["case", "what it tests", "shape", "PNR", "pnrId", "passenger",
            "flight", "route", "bag facts", "engine answered"]
    head = "".join(f"<th>{esc(c)}</th>" for c in cols)

    rows, agreed = [], 0
    codes: collections.Counter = collections.Counter()
    for record in sorted(records, key=lambda r: r["case"]):
        cid = record["case"]
        spec = spec_by_id.get(cid, {})
        want = spec.get("expectBag") or {}
        bags = (record.get("seen") or {}).get("baggage") or []
        got = seen_facts(bags)
        bad = [k for k in COMPARED if k in want and got[k] != want[k]]
        if not bad:
            agreed += 1
        found = verdicts(record)
        for v in found:
            codes[v["code"]] += 1

        facts = " ".join(
            f"<span class='{'bad' if k in bad else 'good'}'>{esc(k.replace('is', ''))}"
            f"={esc(got[k])}</span>" for k in COMPARED if k in want)
        answered = "<br>".join(
            f"<span class=mono>bound {esc(v['bound'])} {esc(v['route'])}: "
            f"<b>{esc(v['code'])}</b> &mdash; {esc(v['reason'])}</span>" for v in found) or "&mdash;"
        rows.append("<tr>" + "".join([
            f"<td class=mono>{esc(cid)}</td>",
            f"<td class=what>{esc(description(spec))}</td>",
            f"<td class=mono>{esc(want.get('bagEventShape'))}</td>",
            f"<td class=mono>{esc(record.get('locator'))}</td>",
            f"<td class=mono>{esc(record.get('pnrId'))}</td>",
            # as published (tools/booking_identity.py); the engine's answer only holds the name
            f"<td>{cell(lookup(ids or {}, record), passenger(record))}</td>",
            f"<td class=mono>{esc(record.get('flight'))}</td>",
            f"<td class=mono>{esc(record.get('route'))}</td>",
            f"<td class=mono>{facts}</td>",
            f"<td>{answered}</td>"]) + "</tr>")

    body = [f"<h1>Seeded baggage set &mdash; {esc(label)} ({esc(env)})</h1>",
            f"<p class=why>{len(records)} case(s), written "
            f"{esc(summary.get('written_at') or _dt.datetime.now(_dt.UTC).isoformat())}; engine "
            f"{esc(summary.get('engine'))} release {esc(summary.get('release'))}. "
            f"The run's own judgement is <b>{esc(summary.get('not_judged'))} not judged</b> &mdash; "
            "the baggage flow does not claim a verdict, so the codes below are what the engine "
            "answered, not a result anyone expected in advance.</p>",
            contact_line(env),
            cards(records, agreed, codes),
            "<input id=q type=search placeholder='filter any column'>",
            f"<table><thead><tr>{head}</tr></thead><tbody>{''.join(rows)}</tbody></table>",
            "<p class=leg>Bag facts are <b>expected vs seen</b>: green agrees, red does not. "
            f"Compared: {esc(', '.join(COMPARED))}. "
            f"Stated but NOT compared, because a bag row cannot answer them: "
            f"{esc(', '.join(NOT_COMPARED))}.</p>"]
    return page(f"Seeded {label}", "".join(body))


def verdict_page(records: list[dict], label: str, env: str,
                 spec_by_id: dict[str, dict]) -> str:
    """Every bag the engine answered about, one block per case."""
    by_code: dict[str, list[tuple[str, dict]]] = collections.defaultdict(list)
    for record in sorted(records, key=lambda r: r["case"]):
        for v in verdicts(record):
            by_code[v["code"] or "(none)"].append((record["case"], v))

    body = [f"<h1>Baggage verdicts &mdash; {esc(label)} ({esc(env)})</h1>",
            "<p class=why>Grouped by the code the baggage EA returned. These are "
            "<b>observations</b>: no spec in this set states an expected verdict, so nothing here "
            "is a pass or a failure. What makes them worth reading is the bag beneath each one "
            "&mdash; the AHL, its status, and the bag's last event &mdash; which is where a "
            "wrong answer would show.</p>"]
    for code in sorted(by_code, key=lambda c: -len(by_code[c])):
        items = by_code[code]
        body.append(f"<h2><span class=tag>{esc(code)}</span> {len(items)} bound(s)</h2>")
        for cid, v in items:
            spec = spec_by_id.get(cid, {})
            bags = "".join(
                f"<div class=chk>bag {esc(b['tag'])} &mdash; AHL {esc(b['ahl']) or '&mdash;'} "
                f"({esc(b['status'])}), last {esc(b['last'])}; lost={esc(b['lost'])} "
                f"interim={esc(b['interim'])}</div>" for b in v["bags"])
            body.append(
                f"<details><summary class=mono>{esc(cid)} &nbsp; bound {esc(v['bound'])} "
                f"{esc(v['route'])} &nbsp; {esc(v['lost'])}/{esc(v['interim'])}</summary>"
                f"<div class=what>{esc(description(spec))}</div>"
                f"<div class=why>{esc(v['reason'])} &mdash; {esc(v['days'])} day(s) since journey "
                f"end</div>{bags}</details>")
    return page(f"Verdicts {label}", "".join(body))


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--run", required=True, help="a run directory under runs/<env>/")
    ap.add_argument("--owner", default="", help="owner tag for the file name; defaults to the env contact, pass it when the run published something else")
    ap.add_argument("--out", required=True, help="directory for the pages")
    args = ap.parse_args(argv)

    run = pathlib.Path(args.run)
    records, summary = load(run)
    if not records:
        print(f"[report] no case records in {run}")
        return 1
    label = summary.get("label") or run.name
    env = summary.get("env") or run.parent.name
    spec_by_id = specs()
    ids = identities(records, label=label, env=env, runs_dir=run.parent)

    out = pathlib.Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    prefix = file_prefix(out, when=str(summary.get("written_at") or ""), owner=(args.owner or owner_tag(env)))
    pages = {f"{prefix}-seeded.html": seeded_page(records, summary, label, env, spec_by_id, ids),
             f"{prefix}-verdicts.html": verdict_page(records, label, env, spec_by_id)}
    for name, text in pages.items():
        (out / name).write_text(text, encoding="utf-8")
        print(f"[report] {out / name}")

    agreed = sum(1 for r in records
                 if not [k for k in COMPARED
                         if k in (spec_by_id.get(r["case"], {}).get("expectBag") or {})
                         and seen_facts((r.get("seen") or {}).get("baggage") or [])[k]
                         != spec_by_id[r["case"]]["expectBag"][k]])
    print(f"[report] {env}/{label}: {len(records)} case(s), {agreed} agree on every compared "
          f"bag fact, {summary.get('not_judged')} not judged by the flow")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
