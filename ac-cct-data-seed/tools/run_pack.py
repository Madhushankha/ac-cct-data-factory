"""Seed a whole pack: build, publish, gate, report.

    python tools/run_pack.py --pack fd --env int --go
    python tools/run_pack.py --pack fd --limit 25            # plan only, publish nothing
    python tools/run_pack.py --pack fd --env int --go --batch 60

Five steps, in order, with the counts printed as each finishes:

1. **plan**     the kit's `apply_patches.py` then `spec_to_build.py`: every scenario dated relative
                to today and given its own flight day, walked earlier until `carrier#number#day#origin`
                collides with neither this run nor `taken-acc.json`
2. **build**    `scenario_build.py` per batch -- cascade's `/qa builder` rewrites one of five
                anonymised PROD histories into the scenario: ~24 messages across PNR, TKT, PNRCORR,
                CM and FDM, spread over the booking's real life
3. **publish**  `lanes.replay --contact --unique-name`: the environment's own inbox, and a surname
                that encodes the case id so automation reading one shared mailbox can tell which
                scenario a message belongs to
4. **gate**     `core.gate --manifest` per batch, at most 25 bookings a task: the Trip first (did it
                land?), then the verdict (does the engine agree?), each booking against its own
                expectation
5. **report**   `seed_report.py`: one HTML row per case -- PNR, identity, flight, expectation, what
                the engine saw and whether it agreed

Measured on INT, 2026-10-16, for 25 scenarios: build 14 s, publish 3 min 30 s (597 messages), gate
one task ~2 min, fold ~70 s. So a 266-scenario pack is roughly an hour, nearly all of it publishing.

Four scenarios cannot pass whatever is seeded, and this does not pretend otherwise: FD_TC_210
needs a `DBCP` denied-boarding keyword, FD_TC_178 an `ASL_regulatory_data_missing_lookup` table and
EU261 distance bands, SOC_UAT_031 a UK point-of-sale rule. All four are proposed contracts awaiting
a decision (UAT_RULES_AND_DATA_REVIEW section 2.4), and FD_ED_TC_03 has no booking by design.

**It publishes without the parser check.** The kit never does: `event_replay.py check --harness
tt-replay-check` runs first and a batch that fails twice is abandoned. That harness needs Rust and a
full MinGW (rustup's bundled one has no `as.exe`), so it is unavailable here. The payloads are the
builder's own, which is the point, but the validation step is missing and the report says so.
"""
from __future__ import annotations

import argparse
import datetime as _dt
import json
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from core import paths                                                     # noqa: E402

KIT = paths.BUILDER            # the kit's scripts, vendored into this project
BUILDER_SVC = paths.qa_builder()   # vendor/qa-builder unless QA_BUILDER_DIR says otherwise
PYTHON = sys.executable
#: the ECS command override holds 8 KiB, so a gate task reads at most this many bookings
GATE_MAX = 100
PACKS = {"fd": ("FD_",), "soc": ("SOC_",), "all": ("FD_", "SOC_")}


def run(cmd: list[str], cwd: pathlib.Path, env: dict | None = None, tail: int = 3) -> str:
    """Run a step and show the last few lines. A failing step stops the pack."""
    p = subprocess.run(cmd, cwd=cwd, text=True, capture_output=True,
                       env={**_environ(), **(env or {})})
    out = (p.stdout or "") + (p.stderr or "")
    for line in out.strip().splitlines()[-tail:]:
        print(f"    {line}")
    if p.returncode != 0:
        raise SystemExit(f"step failed ({p.returncode}): {' '.join(cmd[-3:])}")
    return out


def _environ() -> dict:
    import os
    return dict(os.environ)


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="run_pack", description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--pack", default="fd", choices=sorted(PACKS))
    ap.add_argument("--env", default="int", choices=("int", "crt", "bat"))
    ap.add_argument("--batch", type=int, default=50,
                    help=f"scenarios per build/publish batch. Keep at or below {GATE_MAX} so each "
                         f"batch gates in one task")
    ap.add_argument("--limit", type=int, default=0, help="only the first N scenarios")
    ap.add_argument("--run-day", default="", help="YYYY-MM-DD; defaults to today (UTC)")
    ap.add_argument("--go", action="store_true", help="publish. Without it, plan and build only")
    ap.add_argument("--work", default="", help="where run output goes")
    a = ap.parse_args(argv)

    work = pathlib.Path(a.work) if a.work else ROOT / "runs" / a.env / f"pack-{_stamp()}"
    work.mkdir(parents=True, exist_ok=True)
    kit_env = {"CASCADE_DIR": str(CASCADE), "UAT_WORK_DIR": str(work), "UAT_ENV": a.env,
               "PYTHONUTF8": "1"}
    run_day = a.run_day or _dt.datetime.now(_dt.timezone.utc).date().isoformat()
    print(f"pack {a.pack} · env {a.env} · run day {run_day} · work {work}")

    print("\n1. plan")
    run([PYTHON, "-X", "utf8", "apply_patches.py", str(work / "specs-patched")], KIT, kit_env)
    run([PYTHON, "-X", "utf8", "spec_to_build.py", run_day, str(work / "all-builds.json"),
         "--taken", "taken-acc.json", "--specs", str(work / "specs-patched")], KIT, kit_env)

    builds = json.loads((work / "all-builds.json").read_text(encoding="utf-8"))
    prefixes = PACKS[a.pack]
    mine = [b for b in builds if any(b["id"].startswith(p) for p in prefixes)]
    if a.limit:
        mine = mine[:a.limit]
    batches = [mine[i:i + a.batch] for i in range(0, len(mine), a.batch)]
    print(f"   {len(mine)} scenario(s) in {len(batches)} batch(es) of up to {a.batch}")

    manifests: list[pathlib.Path] = []
    for n, batch in enumerate(batches, start=1):
        tag = f"b{n:02d}"
        spec_file = work / f"{tag}-builds.json"
        spec_file.write_text(json.dumps(batch, indent=1), encoding="utf-8")
        print(f"\n2. build {tag} ({len(batch)} scenarios)")
        run([PYTHON, "-X", "utf8", "scenario_build.py", str(spec_file), "-",
             str(work / tag), a.env], KIT, kit_env)
        manifests.append(work / tag / "manifest.json")

        if not a.go:
            continue
        print(f"3. publish {tag}")
        run([PYTHON, "-X", "utf8", "-m", "lanes.replay",
             str(work / tag / "batch" / "messages.jsonl"), "--env", a.env,
             "--contact", "--unique-name", "--go"], ROOT, tail=2)

    if not a.go:
        print(f"\nbuilt, nothing published. Add --go to publish.\n  manifests: {len(manifests)}")
        return 0

    print(f"\n4. gate ({len(manifests)} task(s), the Trip then the verdict)")
    for man in manifests:
        run([PYTHON, "-X", "utf8", "-m", "core.gate", "--manifest", str(man), "--env", a.env],
            ROOT, tail=4)

    print("\n5. report")
    out = work / "seeded.html"
    run([PYTHON, "-X", "utf8", "tools/seed_report.py", *[str(m.parent) for m in manifests],
         "--out", str(out), "--env", a.env], ROOT, tail=2)
    print(f"\n{out}")
    return 0


def _stamp() -> str:
    return _dt.datetime.now(_dt.timezone.utc).strftime("%m%dT%H%M")


if __name__ == "__main__":
    raise SystemExit(main())
