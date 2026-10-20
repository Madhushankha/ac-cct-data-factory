"""Write the page an automation run reads: which booking is which scenario, and what it must answer.

    python tools/seed_report.py <batch-dir> [<batch-dir> ...] --out seeded.html [--gate <gate.json>]

One row per seeded case, carrying the four things a test needs to start:

* **the PNR** -- the locator and the `pnrId` the APIs take
* **the identity** -- the passenger name, which is how a run finds ITS message in the shared
  Mailinator box. One inbox takes every scenario's mail, so the name is the discriminator: the
  surname encodes the case id (`BOUCHARDAAB` for FD_TC_001), alphabetically, because no feed has
  ever carried a digit in a name
* **the flight** -- carrier, number, route, date, and the disruption
* **the expectation** -- what the engine should answer, from the scenario's own manifest

and, where a gate result is given, what the engine actually answered, so the page is a record of a
verified set rather than a list of hopes.

The page states its own provenance at the top, because a seeded set is only as trustworthy as what
produced it: which pack, which builder, whether the parser check ran, and when the data was seeded
(flight dates are relative to the run, so a set goes stale).
"""
from __future__ import annotations

import argparse
import datetime as _dt
import html
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from lanes.replay import case_surname, cases_by_booking, discover_name_for, rows  # noqa: E402


def collect(batch_dirs: list[pathlib.Path], unique_name: bool = True) -> list[dict]:
    out = []
    for d in batch_dirs:
        messages = d / "batch" / "messages.jsonl"
        manifest = d / "manifest.json"
        if not (messages.exists() and manifest.exists()):
            print(f"  ! {d}: no batch/messages.jsonl or manifest.json, skipped")
            continue
        batch = rows(messages)
        cases = cases_by_booking(messages)
        for row in json.loads(manifest.read_text(encoding="utf-8")):
            pnr_id = row.get("pnrId") or ""
            case_id = cases.get(pnr_id, row.get("id", ""))
            first, last = discover_name_for(batch, pnr_id)
            seeded_last = case_surname(case_id, last) if unique_name else last
            flight = (row.get("flights") or [{}])[0]
            out.append({
                "case": case_id,
                "pnr": row.get("locator", ""),
                "pnrId": pnr_id,
                "first": first,
                "last": seeded_last,
                "spec_last": last,
                "flight": f"{flight.get('carrier', '')}{flight.get('number', '')}",
                "route": f"{flight.get('origin', '')}-{flight.get('destination', '')}",
                "date": (flight.get("depUtc") or "")[:10],
                "kind": flight.get("kind", ""),
                "minutes": flight.get("minutes"),
                "code": flight.get("code"),
                "expect": row.get("expect") or {},
            })
    return sorted(out, key=lambda r: r["case"])


def fold_gate(cases: list[dict], gate_path: pathlib.Path | None) -> None:
    """What the engine answered, re-judged now rather than read from the file.

    The gate stores the judgement it made at the time, and judgements age: four comparator bugs
    were fixed after these readings were taken, each of which had been reporting differences that
    were not there. Reusing the stored verdict produced a page byte-identical to one written before
    those fixes. The engine's DOCUMENT is the durable evidence, so this re-judges from it.
    """
    if not gate_path or not gate_path.exists():
        return
    from core import gate as gate_mod                                       # noqa: PLC0415
    gate = json.loads(gate_path.read_text(encoding="utf-8"))
    for row in cases:
        g = gate.get(row["pnrId"])
        if not g:
            continue
        spec = {"id": row["case"], "family": "fd", "expect": row.get("expect") or {},
                "passengers": [{}], "segments": [{}], "outcomes": [{}]}
        j = gate_mod.judge(spec, g)
        seen = j.get("seen") or {}
        segs = seen.get("segments") or [{}]
        row["seen_status"] = segs[0].get("status")
        row["seen_delay"] = segs[0].get("delayMin")
        row["seen_cause"] = segs[0].get("causeCode")
        row["agree"] = j.get("agree")
        row["disagree"] = j.get("disagree")
        row["why"] = j.get("why", "")


def page(cases: list[dict], *, env: str, email: str, validated: bool) -> str:
    def esc(v) -> str:
        return html.escape("" if v is None else str(v))

    gated = [c for c in cases if c.get("agree") is not None]
    agree = sum(1 for c in gated if not c.get("disagree"))
    rows_html = []
    for c in cases:
        verdict = (f'<span class="ok">{c["agree"]} agree</span>' if c.get("disagree") == 0
                   else f'<span class="bad">{c.get("disagree")} disagree</span>'
                   if c.get("disagree") else
                   f'<span class="na">{esc(c.get("why") or "not gated")}</span>')
        seen = (f'{esc(c.get("seen_status"))} · {esc(c.get("seen_delay"))} min'
                if c.get("seen_status") else '<span class="na">—</span>')
        e = c["expect"]
        rows_html.append(
            "<tr>"
            f'<td class="mono">{esc(c["case"])}</td>'
            f'<td class="mono pnr">{esc(c["pnr"])}</td>'
            f'<td class="mono">{esc(c["pnrId"])}</td>'
            f'<td>{esc(c["first"])} <b>{esc(c["last"])}</b></td>'
            f'<td class="mono">{esc(c["flight"])} {esc(c["route"])} {esc(c["date"])}</td>'
            f'<td class="num">{esc(c.get("minutes"))}</td>'
            f'<td class="mono">{esc(c.get("code"))}</td>'
            f'<td>{esc(e.get("eligibility"))}</td>'
            f'<td class="mono">{esc(e.get("systemCode"))}</td>'
            f'<td class="num">{esc(e.get("amount"))} {esc(e.get("currency"))}</td>'
            f"<td>{seen}</td><td>{verdict}</td></tr>")

    note = ('<span class="bad">published without the parser check</span>' if not validated
            else '<span class="ok">parser-checked before publish</span>')
    return f"""<!doctype html>
<meta charset="utf-8"><title>Seeded scenarios — {esc(env.upper())}</title>
<style>
 body{{font:14px/1.5 system-ui,sans-serif;margin:0;padding:24px;color:#1b1d21;background:#fff}}
 h1{{font-size:20px;margin:0 0 4px}}
 .meta{{color:#5e636e;font-size:13px;margin-bottom:18px}}
 .meta b{{color:#1b1d21}}
 table{{border-collapse:collapse;width:100%;font-size:13px}}
 th,td{{text-align:left;padding:6px 8px;border-bottom:1px solid #e4e2dc;vertical-align:top}}
 th{{font-size:11px;letter-spacing:.06em;text-transform:uppercase;color:#5e636e;white-space:nowrap}}
 .mono{{font-family:ui-monospace,Menlo,Consolas,monospace;font-size:12px;white-space:nowrap}}
 .pnr{{font-weight:600}}
 .num{{text-align:right;font-variant-numeric:tabular-nums;white-space:nowrap}}
 .ok{{color:#1f5c47;font-weight:600}} .bad{{color:#8a2b2b;font-weight:600}} .na{{color:#8a8d94}}
 tbody tr:nth-child(odd){{background:#fbfaf8}}
</style>
<h1>Seeded scenarios — {esc(env.upper())}</h1>
<div class="meta">
 <b>{len(cases)}</b> bookings · gated <b>{len(gated)}</b> · agreeing <b>{agree}</b> ·
 seeded {esc(_dt.datetime.now(_dt.timezone.utc).strftime('%Y-%m-%d %H:%M'))}Z · {note}<br>
 One inbox for every scenario: <b class="mono">{esc(email)}</b> — the <b>surname</b> identifies the
 case (A=0 … J=9, so BOUCHARDAAB is FD_TC_001; E and S mark the edge and SOC packs).<br>
 Flight dates are relative to the seed run, so this set ages: re-seed rather than re-use it later.
</div>
<table><thead><tr>
 <th>case</th><th>PNR</th><th>pnrId</th><th>passenger</th><th>flight</th><th>delay</th><th>code</th>
 <th>expected</th><th>system code</th><th>amount</th><th>engine saw</th><th>verdict</th>
</tr></thead><tbody>
{chr(10).join(rows_html)}
</tbody></table>
"""


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="seed_report", description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("batches", nargs="+", help="builder batch directories (each with batch/ and manifest.json)")
    ap.add_argument("--out", default="seeded.html")
    ap.add_argument("--env", default="int")
    ap.add_argument("--gate", default="", help="a core.gate result json, to fold in what the engine answered")
    ap.add_argument("--email", default="lahiru@ae-qa1-aircanada.mailinator.com")
    ap.add_argument("--validated", action="store_true",
                    help="state on the page that the batch passed the parser check")
    a = ap.parse_args(argv)

    cases = collect([pathlib.Path(b) for b in a.batches])
    if not cases:
        raise SystemExit("no cases found in those batch directories")
    fold_gate(cases, pathlib.Path(a.gate) if a.gate else None)
    out = pathlib.Path(a.out)
    out.write_text(page(cases, env=a.env, email=a.email, validated=a.validated), encoding="utf-8")
    gated = [c for c in cases if c.get("agree") is not None]
    print(f"{len(cases)} case(s), {len(gated)} gated -> {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
