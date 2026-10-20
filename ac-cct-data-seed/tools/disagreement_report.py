"""The disagreements, grouped by cause, with each case's Jira test beside it.

    python tools/disagreement_report.py <pack-dir> --out disagreements.html

A flat list of 57 differences reads as 57 defects. It is not: most are errors in how a scenario
states its expectation, a few are documented limits, and a minority are the engine and the scenario
genuinely disagreeing. Those need different people, so the page groups them that way and says, for
each group, who can act.

Every row carries the Jira test id, key, title and goal, read from
`agentic-qa/jira/automation-uat/fd*/tests/<ID>__<KEY>/test.json` -- because "FD_TC_095 differs" is
not reviewable, while "No Determination | Disruption on OAL, CHAI-31487: engine says NOT_ELIGIBLE"
is. The titles also turned out to name the themes better than the field differences did: the
sixteen cases whose titles begin "No Determination" are one rules question, not sixteen.
"""
from __future__ import annotations

import argparse
import collections
import datetime as _dt
import glob
import html
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

# after the insert, not before: imported first, `core` resolved to another checkout's package
# (cct-qa-framework) and this died with ImportError. The `# noqa: E402` had silenced the very
# warning that flags it.
from core import paths  # noqa: E402
# the Jira snapshot is in this project now (jira/<flow>/<phase>/<purpose>/<CASE>__<KEY>/),
# so this no longer reaches into another checkout for it
JIRA = paths.JIRA

#: Each group: how a case is recognised, and who can act on it.
GROUPS = [
    ("band in the systemCode field",
     "The scenario's `expect.systemCode` holds a delay band, not a code. Eligibility, minutes and "
     "cause all agree. A scenario-authoring fix.",
     "scenario owner",
     lambda c: bool(re.match(r"^(APPR|EU261|ASL)_", str(c["expected"].get("systemCode") or "")))),
    ("FD-MIXED composite code",
     "The engine answers per regime (FD-APPR-EL-01); the scenario expects a composite FD-MIXED "
     "code. Those codes are in no live reference table, and the review notes the composite row is "
     "not surfaced because the contract has no place for it.",
     "Remya / contract",
     lambda c: str(c["expected"].get("systemCode") or "").startswith("FD-MIXED-")),
    ("non-code label",
     "The scenario states NON_FLIGHT_SEGMENT_DISRUPTION, which is not a DDS code. The review "
     "already corrects these to FD-APPR-NE-20; the seeded copies still carry the old label.",
     "scenario owner",
     lambda c: str(c["expected"].get("systemCode") or "") == "NON_FLIGHT_SEGMENT_DISRUPTION"),
    ("72-hour window has passed",
     "PE-01 is only returned within 72 hours of arrival. These flights are dated weeks back, so "
     "the window is long shut. Re-seed and gate within hours to exercise them.",
     "nobody: re-seed to test",
     lambda c: c["expected"].get("eligibility") == "PENDING"),
    ("no determination expected, engine decided",
     "The scenario expects NO_DETERMINATION for missing OAL or MSL data; the engine returns a "
     "decision instead. One rules question across the group, not one per case.",
     "rules owner",
     lambda c: c["expected"].get("eligibility") == "NO_DETERMINATION"),
    ("regime differs",
     "The engine assessed a different set of regimes than the scenario expects.",
     "rules owner",
     lambda c: any(x["check"] == "fd_regime" for x in c["disagreements"])),
]


def jira_index() -> dict:
    out = {}
    for f in glob.glob(str(JIRA / "fd/*/*/*/test.json")):
        t = json.loads(pathlib.Path(f).read_text(encoding="utf-8"))
        if t.get("test_id"):
            out[t["test_id"]] = {
                "key": t.get("key", ""), "title": (t.get("title") or "").strip(),
                # verbatim, untrimmed: the description and the prerequisites are what a reviewer
                # needs to judge whether the engine or the scenario is right, and paraphrasing
                # either would be putting words in the scenario author's mouth
                "description": (t.get("description") or "").strip(),
                "goal": (t.get("goal") or "").strip(),
                "prerequisites": (t.get("prerequisites") or "").strip(),
                "prerequisite_items": t.get("prerequisite_items") or [],
                "status": t.get("status", ""), "priority": t.get("priority", "")}
    return out


def classify(case: dict) -> tuple[str, str, str]:
    for name, why, owner, test in GROUPS:
        if test(case):
            return name, why, owner
    return ("the engine and the scenario disagree",
            "Facts seeded correctly and the verdict still differs. These are the findings worth "
            "raising as defects.", "rules owner")


def page(groups: dict, *, total: int, agree: int, engine: str) -> str:
    def esc(v) -> str:
        return html.escape("" if v is None else str(v))

    sections = []
    for (name, why, owner), cases in groups.items():
        rows = []
        for c in cases:
            e = c["expected"]
            diffs = "<br>".join(f'<span class="chk">{esc(x["check"].replace("fd_", ""))}</span> '
                                f'{esc(x["detail"])}' for x in c["disagreements"])
            pre = "".join(f"<li>{esc(x)}</li>" for x in (c.get("prerequisite_items") or []))
            desc = c.get("description") or c.get("goal") or ""
            detail = ""
            if desc or pre:
                detail = ('<details><summary>description and prerequisites</summary>'
                          + (f'<p class="verbatim">{esc(desc)}</p>' if desc else "")
                          + (f'<ul class="pre">{pre}</ul>' if pre else "")
                          + '</details>')
            rows.append(
                "<tr>"
                f'<td class="mono">{esc(c["case"])}<div class="key">{esc(c.get("jira"))}</div>'
                f'<div class="key">{esc(c.get("status"))} · {esc(c.get("priority"))}</div></td>'
                f'<td><b>{esc(c.get("title"))}</b>{detail}</td>'
                f'<td class="mono">{esc(c["pnr"])}<div class="key">{esc(c["pnrId"])}</div></td>'
                f'<td class="mono">{esc(e.get("eligibility"))}<div class="key">'
                f'{esc(e.get("systemCode"))}</div>'
                f'<div class="key">{esc(e.get("amount"))} {esc(e.get("currency"))}</div></td>'
                f'<td class="diff">{diffs}</td></tr>')
        sections.append(
            f'<section><h2>{esc(name)} <span class="count">{len(cases)}</span></h2>'
            f'<p class="why">{esc(why)}</p>'
            f'<p class="owner">who can act: <b>{esc(owner)}</b></p>'
            '<div class="tablewrap"><table><thead><tr><th>test</th><th>what it tests</th>'
            '<th>booking</th><th>scenario expects</th><th>what differs</th></tr></thead>'
            f'<tbody>{"".join(rows)}</tbody></table></div></section>')

    return f"""<!doctype html>
<meta charset="utf-8"><title>FD disagreements — INT</title>
<style>
 body{{font:14px/1.55 system-ui,sans-serif;margin:0;padding:24px;color:#1b1d21;background:#fff;
   max-width:1500px}}
 h1{{font-size:21px;margin:0 0 6px}}
 .lede{{color:#5e636e;max-width:70em;margin:0 0 22px}}
 .lede b{{color:#1b1d21}}
 section{{margin:0 0 30px}}
 h2{{font-size:15px;margin:0 0 4px;padding-bottom:4px;border-bottom:2px solid #7a1f2b}}
 .count{{background:#7a1f2b;color:#fff;border-radius:9px;padding:1px 8px;font-size:12px;
   vertical-align:2px}}
 .why{{color:#5e636e;font-size:13px;margin:6px 0 2px;max-width:70em}}
 .owner{{font-size:12px;margin:0 0 10px;color:#5e636e}}
 .tablewrap{{overflow-x:auto;border:1px solid #e4e2dc;border-radius:3px}}
 table{{border-collapse:collapse;width:100%;font-size:12.5px}}
 th,td{{text-align:left;padding:7px 9px;border-bottom:1px solid #eeece6;vertical-align:top}}
 th{{font-size:10.5px;letter-spacing:.06em;text-transform:uppercase;color:#5e636e;
   white-space:nowrap;background:#fbfaf8}}
 tr:last-child td{{border-bottom:0}}
 .mono{{font-family:ui-monospace,Menlo,Consolas,monospace;white-space:nowrap}}
 .key{{font-size:11px;color:#8a8d94;font-family:ui-monospace,Menlo,monospace}}
 .goal{{font-size:11.5px;color:#74767c;margin-top:3px;max-width:34em}}
 .diff{{font-family:ui-monospace,Menlo,Consolas,monospace;font-size:11.5px;max-width:40em}}
 .chk{{color:#8a2b2b;font-weight:600}}
 details{{margin-top:5px}}
 summary{{cursor:pointer;font-size:11.5px;color:#7a1f2b;user-select:none}}
 .verbatim{{font-size:12px;color:#3b3f46;margin:6px 0;white-space:pre-wrap;max-width:52em;
   background:#fbfaf8;border-left:2px solid #d9d7d0;padding:7px 10px}}
 .pre{{font-size:11.5px;color:#4a4e55;margin:4px 0 0;padding-left:1.1em;max-width:52em}}
 .pre li{{margin:1px 0}}
</style>
<h1>FD scenarios: where the engine and the scenario disagree</h1>
<p class="lede">
 <b>{total}</b> bookings seeded to INT and read from TripTracer's Raptor engine
 (<span class="mono">{esc(engine)}</span>): <b>{agree}</b> agree with their scenario,
 <b>{total - agree}</b> differ. Every booking's facts — status, delay and cause — were seeded
 exactly as its scenario asked; these are differences in the <b>verdict</b> or in how the scenario
 <b>states</b> it.<br><br>
 Grouped by cause, because the groups need different people. The last group is the one that reads
 as defects. Nothing here was pinned: the engine computed every answer from the booking's event
 history, so a disagreement is real rather than a comparison against something we wrote.
 Generated {esc(_dt.datetime.now(_dt.timezone.utc).strftime('%Y-%m-%d %H:%M'))}Z.
</p>
{"".join(sections)}
"""


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="disagreement_report", description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("pack", help="a pack directory holding validated.json")
    ap.add_argument("--out", default="disagreements.html")
    a = ap.parse_args(argv)

    pack = pathlib.Path(a.pack)
    data = json.loads((pack / "validated.json").read_text(encoding="utf-8"))
    jira = jira_index()
    for c in data["disagreeing"]:
        meta = jira.get(c["case"], {})
        c.setdefault("jira", meta.get("key", ""))
        c.setdefault("title", meta.get("title", ""))
        c.setdefault("goal", meta.get("goal", ""))
        c.setdefault("description", meta.get("description", ""))
        c.setdefault("prerequisites", meta.get("prerequisites", ""))
        c.setdefault("prerequisite_items", meta.get("prerequisite_items", []))
        c.setdefault("status", meta.get("status", ""))
        c.setdefault("priority", meta.get("priority", ""))

    groups: dict[tuple[str, str, str], list] = collections.defaultdict(list)
    for c in data["disagreeing"]:
        groups[classify(c)].append(c)
    ordered = dict(sorted(groups.items(), key=lambda kv: -len(kv[1])))

    total = data["agree"] + data["disagree"]
    out = pathlib.Path(a.out)
    out.write_text(page(ordered, total=total, agree=data["agree"],
                        engine="raptor release 39"), encoding="utf-8")
    print(f"{data['disagree']} disagreeing cases in {len(ordered)} group(s) -> {out}")
    for (name, _, owner), cases in ordered.items():
        print(f"   {len(cases):3d}  {name}  ({owner})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
