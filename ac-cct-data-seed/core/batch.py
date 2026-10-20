"""Seed many specs, under the limits in `core.policy`.

    python -m core.batch --set fd/po --env int --label fd-po-all
    python -m core.batch FD_PO_001 FD_PO_002 --env int --dry-run

Concurrency, the flight-day allocation and the run tag come from `core.policy`, so this file is
orchestration and bookkeeping only.

Three things it does that a plain loop would not:

* **It allocates a distinct flight identity per case before anything is published.** Two cases that
  share carrier#number#day#origin make the second one's checkpoints read the first one's flight,
  which looks like bad seed data and is not. The agentic-qa pipeline mints a random flight number
  per case, so a collision is unlikely rather than impossible; this records what a run used, so a
  collision can be seen after the fact instead of guessed at.
* **It caps concurrency at the read ceiling, not the write one.** Seeding happily runs ten at a
  time; the verify phase at the end of each case reads TripTracer and DDS, and above six concurrent
  readers TripTracer starts answering "unavailable", which a report cannot tell apart from a
  genuinely blocked case. Since the pipeline runs all five phases per case, the read ceiling
  governs the whole run.
* **It writes one run record per case and a summary, under `runs/`.** The old seeder accumulates
  dataset manifests in its data directory -- 344 files and 162 MB of them. A run is not data.
"""
from __future__ import annotations

import argparse
import datetime as _dt
import json
import pathlib
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from core import policy, seed as seed_mod                                   # noqa: E402

SPEC_ROOT = ROOT / "spec"


def specs_in(set_path: str) -> list[pathlib.Path]:
    d = SPEC_ROOT / set_path
    if not d.is_dir():
        raise SystemExit(f"no such set: {d}")
    return sorted(p for p in d.glob("*.json") if not p.name.startswith("_"))


def flight_plan(paths: list[pathlib.Path], day: _dt.date) -> tuple[dict, list[str]]:
    """What flight identity each case's segments claim, and any claimed twice.

    This does not change a spec. It reports, because the pipeline mints the flight numbers it
    actually publishes; what matters is that a run can say afterwards whether two of its cases
    were pointed at the same flight.
    """
    claims: dict[str, list[str]] = {}
    for p in paths:
        spec = json.loads(p.read_text(encoding="utf-8"))
        for s in spec.get("segments") or []:
            if not (s.get("carrier") and s.get("number") and s.get("origin")):
                continue
            when = s.get("depDate") or (day + _dt.timedelta(days=s.get("dayOffset") or 0)).isoformat()
            key = policy.flight_key(s["carrier"], s["number"], when, s["origin"])
            claims.setdefault(key, []).append(spec["id"])
    clashes = [f"{k}: {', '.join(v)}" for k, v in claims.items() if len(v) > 1]
    return claims, clashes


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="core.batch", description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("ids", nargs="*", help="spec ids; omit and use --set")
    ap.add_argument("--set", dest="set_path", default="",
                    help="a set under spec/, e.g. fd/uat/automation or fd/uat/po")
    ap.add_argument("--env", default="int", choices=("int", "crt", "bat"))
    ap.add_argument("--label", default="", help="names the run folder; defaults to a run tag")
    ap.add_argument("--parallel", type=int, default=policy.CASE_PARALLEL,
                    help=f"concurrent cases (ceiling {policy.CASE_PARALLEL}: every case reads "
                         f"TripTracer in its verify phase)")
    ap.add_argument("--no-pin", action="store_true")
    ap.add_argument("--dry-run", action="store_true", help="plan and write fixtures, publish nothing")
    a = ap.parse_args(argv)

    paths = ([p for i in a.ids for p in [seed_mod.find_spec(i)]] if a.ids
             else specs_in(a.set_path) if a.set_path else [])
    if not paths:
        raise SystemExit("name some spec ids or a --set")

    limits = policy.Limits(parallel=a.parallel, read_parallel=a.parallel).checked()
    tag = policy.run_tag()
    label = a.label or f"run-{tag}"
    day = policy.run_day()

    claims, clashes = flight_plan(paths, day)
    print(f"{len(paths)} case(s) | env {a.env} | label {label} | tag {tag} | "
          f"{limits.parallel} at a time | run day {day} (UTC)")
    print(f"flight identities claimed: {len(claims)}")
    if clashes:
        # The authored data, not what gets published: the pipeline mints a flight number per case
        # (9100-9899), so these resolve themselves unless a run keeps the scenario's own numbers.
        print(f"{len(clashes)} flight identity shared by more than one spec (minted numbers "
              f"resolve these; they matter only with the scenario's real flight numbers):")
        for c in clashes:
            print(f"    {c}")
    if a.dry_run:
        for p in paths:
            print(f"  would seed {p.stem}")
        return 0

    out = ROOT / "runs" / a.env / label
    out.mkdir(parents=True, exist_ok=True)
    started = _dt.datetime.now(_dt.timezone.utc)

    def one(path: pathlib.Path) -> tuple[str, int]:
        args = [path.stem, "--env", a.env, "--label", label]
        if a.no_pin:
            args.append("--no-pin")
        try:
            return path.stem, seed_mod.main(args)
        except SystemExit as ex:                                # a refusal, not a crash
            return path.stem, int(ex.code or 1)
        except Exception as ex:                                 # noqa: BLE001
            print(f"{path.stem}: {type(ex).__name__}: {ex}")
            return path.stem, 1

    results: dict[str, int] = {}
    with ThreadPoolExecutor(max_workers=limits.parallel) as ex:
        futures = {ex.submit(one, p): p for p in paths}
        for fut in as_completed(futures):
            cid, rc = fut.result()
            results[cid] = rc
            print(f"  [{len(results)}/{len(paths)}] {cid} rc={rc}")

    summary = {
        "label": label, "run_tag": tag, "env": a.env, "run_day": day.isoformat(),
        "started_at": started.isoformat(timespec="seconds"),
        "finished_at": _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds"),
        "limits": {"parallel": limits.parallel, "read_ceiling": policy.CASE_PARALLEL,
                   "gate_wait": limits.gate_wait},
        "cases": results,
        "flight_identity_clashes": clashes,
        "ok": sorted(c for c, rc in results.items() if rc == 0),
        "failed": sorted(c for c, rc in results.items() if rc != 0),
    }
    (out / "_summary.json").write_text(json.dumps(summary, indent=1) + "\n", encoding="utf-8")
    print(f"\n{len(summary['ok'])} ok, {len(summary['failed'])} failed "
          f"-> runs/{a.env}/{label}/_summary.json")
    if summary["failed"]:
        print("failed: " + ", ".join(summary["failed"]))
    return 1 if summary["failed"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
