"""Build one report folder for a whole flow from many runs: each case's latest valid run, one status word each.

    python scripts/build_final.py <out-dir> <source> [<source> ...]

A source is either a run folder (results/run<n>.json, evidence/run<n>.html, chat/run<n>.html, ...) or a
finished report folder (<case>.result.json, <case>.evidence.html, ...). Later sources win over earlier ones
for the same case, unless the later run is broken and the earlier one is not.

Statuses (the same words for every case):
  Pass                  the AI customer reached the test's goal and no bot checkpoint differs
  Pass, with differences  the goal was reached; some bot checkpoints differ in wording or detail
  Fail                  the bot would not do what the test asks ("cannot reach"), stopped answering, or
                        broke a chat rule (a raw link in its text)
  Stopped (safety)      the chat stopped at a step the test does not cover (payout country, manual review)
  Incomplete            the chat used all its turns without reaching an end (often the bot's own ending
                        was not recognised); full screenshots are there
  Broken run            our side failed (frozen, no result, actions kept failing)
"""
from __future__ import annotations

import html
import json
import pathlib
import re
import shutil
import sys

OUT = pathlib.Path(sys.argv[1])
SOURCES = [pathlib.Path(s) for s in sys.argv[2:]]


def outcome(r: dict) -> tuple[str, str]:
    notes = r.get("notes") or []
    ai = next((n for n in notes if n.startswith("AI customer:")), "")
    cps = r.get("checkpoints") or []
    fails = sum(1 for c in cps if c.get("status") == "fail")
    fl = r.get("failures") or []

    if "goal_reached" in ai:
        return ("Pass" if fails == 0 else "Pass, with differences"), ai.split("—", 1)[-1].strip()
    if "cannot_reach" in ai:
        return "Fail", ai.split("—", 1)[-1].strip()
    if any("safety stop" in n for n in notes):
        return "Stopped (safety)", next(n for n in notes if "safety stop" in n)
    got = next((str(f.get("got", "")) for f in fl if f.get("kind") != "wording" and f.get("got")), "")
    if re.match(r"raw URL in the text|no new assistant message", got):
        return "Fail", ("bot stopped answering: " if got.startswith("no new") else "bot wrote a raw link: ") + got[:160]
    if got.startswith("turn budget used up"):
        return "Incomplete", got[:200]
    if not cps and not ai:
        return "Broken run", got[:200] or "no result"
    return "Broken run", (got or str(r.get("endedAt_step", "")))[:200]


def runs(src: pathlib.Path):
    """(case, result, files{kind: path}) for every case in a source."""
    if (src / "results").is_dir():
        for f in sorted((src / "results").glob("run*.json")):
            r = json.loads(f.read_text(encoding="utf-8"))
            n = f.stem
            files = {"evidence.html": src / "evidence" / f"{n}.html", "chat.html": src / "chat" / f"{n}.html",
                     "dashboard.json": src / "dashboard" / f"{n}.json", "emails.json": src / "emails" / f"{n}.json",
                     "result.json": f}
            yield r.get("caseId"), r, {k: v for k, v in files.items() if v.exists()}
    else:
        for f in sorted(src.glob("*.result.json")):
            case = f.name[: -len(".result.json")]
            r = json.loads(f.read_text(encoding="utf-8"))
            files = {k: src / f"{case}.{k}" for k in ("evidence.html", "chat.html", "dashboard.json", "emails.json", "result.json")}
            yield case, r, {k: v for k, v in files.items() if v.exists()}


best: dict[str, tuple[str, str, dict, dict, str]] = {}
for src in SOURCES:
    for case, r, files in runs(src):
        if not case:
            continue
        status, why = outcome(r)
        prev = best.get(case)
        if prev and status == "Broken run" and prev[0] != "Broken run":
            continue
        best[case] = (status, why, r, files, src.as_posix())

if OUT.exists():
    shutil.rmtree(OUT)
OUT.mkdir(parents=True)
rows = []
for case in sorted(best, key=lambda c: (re.sub(r"\d+", lambda m: m.group().zfill(4), c))):
    status, why, r, files, src = best[case]
    for k, p in files.items():
        shutil.copyfile(p, OUT / f"{case}.{k}")
    cps = r.get("checkpoints") or []
    score = f"{sum(1 for c in cps if c.get('status') == 'pass')}/{len(cps)}" if cps else "—"
    rows.append({"case": case, "status": status, "pnr": r.get("booking"), "ccd": r.get("caseNumber") or "",
                 "checkpoints": score, "why": why, "source": src, "evidence": "evidence.html" in files})

(OUT / "summary.json").write_text(json.dumps(rows, indent=1), encoding="utf-8")
order = ["Pass", "Pass, with differences", "Fail", "Stopped (safety)", "Incomplete", "Broken run"]
counts = {s: sum(1 for x in rows if x["status"] == s) for s in order}
cls = {"Pass": "ok", "Pass, with differences": "warn", "Fail": "bad", "Stopped (safety)": "stop", "Incomplete": "stop", "Broken run": "broken"}
trs = "\n".join(
    f'<tr class="{cls[x["status"]]}"><td>{html.escape(x["case"])}</td><td>{html.escape(x["status"])}</td>'
    f'<td>{html.escape(x["pnr"] or "")}</td><td>{html.escape(x["ccd"])}</td><td>{x["checkpoints"]}</td>'
    f'<td>{html.escape(x["why"][:160])}</td>'
    f'<td>{f"<a href=\"{x["case"]}.evidence.html\">evidence</a>" if x["evidence"] else "—"}</td></tr>'
    for x in rows)
(OUT / "index.html").write_text(f"""<!doctype html><meta charset="utf-8"><title>FD BAT 266</title>
<style>body{{font:14px system-ui;margin:16px}}table{{border-collapse:collapse;width:100%}}td,th{{border:1px solid #ccc;padding:4px 6px;vertical-align:top}}
.ok td:nth-child(2){{background:#d8f5d8}}.warn td:nth-child(2){{background:#fff3c4}}.bad td:nth-child(2){{background:#fbd5d5}}
.stop td:nth-child(2){{background:#e3e8f5}}.broken td:nth-child(2){{background:#eee}}</style>
<h1>FD BAT: {len(rows)} cases</h1>
<p>{" · ".join(f"{s}: <b>{n}</b>" for s, n in counts.items())}</p>
<table><tr><th>Case</th><th>Status</th><th>PNR</th><th>Claim</th><th>Bot checkpoints passed</th><th>Why</th><th>Evidence</th></tr>
{trs}</table>""", encoding="utf-8")
print(len(rows), "cases", counts)
