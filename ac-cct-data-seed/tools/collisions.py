"""Record the flight keys an environment already held, so a reseed stops landing on them.

    python tools/collisions.py runs/int/fd-266-int-full            # show
    python tools/collisions.py runs/int/fd-266-int-full --write     # record, and print the cases

A key is proven occupied when the engine answers about a delay this case never published: we sent
AC476#2026-09-19#YUL with 410 minutes and the engine holds 430, so the leg it folded is not ours.
`builder/taken-acc.json` cannot know this -- it is a snapshot of what the kit published -- and
neither can our own manifests, which only know what we sent. A read is the only evidence.

The keys go to `runs/<env>/taken-extra.json`, which `KitBuilder._taken_file` merges into the
`--taken` list it hands the planner, so the next build of those cases picks a different day.
"""
from __future__ import annotations

import argparse
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))
sys.path.insert(0, str(ROOT / "tools"))

import report as R                                                          # noqa: E402


def collisions(run: R.Run) -> list[tuple[str, str, list, list]]:
    """(case, key, what the engine holds, what we published) for every proven collision."""
    out = []
    for cid, rec in sorted(run.cases.items()):
        bucket, _ = R.classify(rec, None)
        if bucket != "wrong-leg":
            continue
        held = [d for d in ((rec.get("seen") or {}).get("delays") or []) if d]
        pub = [leg.get("minutes") for leg in rec.get("published") or []
               if leg.get("minutes") and leg.get("kind") == "delay"]
        keys = [str(leg.get("key")) for leg in rec.get("published") or []
                if leg.get("kind") == "delay" and leg.get("key")]
        out.append((cid, keys[0] if keys else "", held, pub))
    return out


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("run", help="a run directory under runs/<env>/")
    ap.add_argument("--write", action="store_true",
                    help="add the keys to runs/<env>/taken-extra.json")
    a = ap.parse_args(argv)

    directory = pathlib.Path(a.run)
    run = R.Run(directory)
    if not run.cases:
        print(f"no case records in {directory}")
        return 2
    found = collisions(run)
    if not found:
        print(f"{run.env}/{run.label}: no proven collisions")
        return 0

    print(f"{run.env}/{run.label}: {len(found)} case(s) answered about a leg they did not publish")
    for cid, key, held, pub in found:
        print(f"  {cid:<14} {key:<24} engine holds {held} min, we published {pub} min")

    target = directory.parent / "taken-extra.json"
    if not a.write:
        print(f"\n--write would add {len({k for _, k, _, _ in found if k})} key(s) to {target}")
        return 0

    keys = {k for _, k, _, _ in found if k}
    try:
        keys |= {str(k) for k in json.loads(target.read_text(encoding="utf-8"))}
    except Exception:                                                       # noqa: BLE001
        pass
    target.write_text(json.dumps(sorted(keys), indent=1), encoding="utf-8")
    print(f"\n{target}: {len(keys)} key(s) recorded as occupied")
    print("reseed those cases with:")
    print(f"  python -m cli seed <set> --env {run.env} --go "
          f"--only {','.join(cid.split('#')[0] for cid, *_ in found)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
