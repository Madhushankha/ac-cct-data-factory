"""The project's spec tree + fixes-*.json specPatch -> one flat directory of patched specs.

Merge rules unchanged from the kit: dicts merge, lists and scalars replace, and an `"id#n"` patch
addresses `bookings[n-1]`.

Two things differ from the kit's version, both deliberate:

**It reads the project's spec tree, not a flat `specs/` beside this file.** Sets live at
`spec/<flow>/<phase>/<purpose>/`, which is where a person looks for "the FD UAT automation set". A
set is a directory of `<CASE_ID>.json`; the tree is walked, so adding a set is adding a folder.

**A duplicate id is an error, not a silent override.** The kit copied `specs/` and then
`specs-nobooking/` into the same output, so for 19 scenarios the second copy won by directory order
alone -- and the loser was the empty "no booking data" shell while the winner was the authored
booking. The outcome was right and nothing said so. Here a directory named `_superseded` is skipped
entirely, and any other duplicate id raises instead of picking one.

`open()` is given an explicit encoding throughout. Windows defaults to cp1252, and `FD_TC_238`
holds a character it cannot decode -- which failed on this host while working on the kit's own.
"""
import copy
import glob
import json
import os
import shutil
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import uat_config  # noqa: E402

#: the canonical spec tree, as a path relative to this file
SPEC_TREE = os.path.normpath(os.path.join(HERE, "..", "spec"))

#: a directory with this name holds specs kept for the record and never built
SKIP_DIRS = {"_superseded", "__pycache__"}


def merge(a, b):
    if isinstance(a, dict) and isinstance(b, dict):
        out = dict(a)
        for k, v in b.items():
            out[k] = merge(a.get(k), v) if k in a else v
        return out
    return copy.deepcopy(b)


def discover(tree=SPEC_TREE, only=None):
    """Every spec in the tree as `{case_id: path}`, raising on a duplicate id.

    `only` keeps just the sets whose path contains one of the given fragments, so a run can take
    `fd/uat/automation` without the SOC set coming along.
    """
    found, where = {}, {}
    for base, dirs, files in os.walk(tree):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        rel = os.path.relpath(base, tree).replace(os.sep, "/")
        if only and not any(frag in rel for frag in only):
            continue
        for name in sorted(files):
            if not name.endswith(".json"):
                continue
            case_id = name[:-5]
            if case_id in found:
                raise SystemExit(
                    f"duplicate spec id {case_id!r}: {where[case_id]} and {rel}/{name}. "
                    f"One id, one spec -- move the one that should not be built into a "
                    f"_superseded/ folder.")
            found[case_id] = os.path.join(base, name)
            where[case_id] = rel
    return found, where


def main(out, only=None):
    specs, where = discover(only=only)
    # ids that exist somewhere in the tree, so a fix naming a filtered-out set is not reported as
    # dangling: only a fix for an id no set holds at all is a finding worth a line.
    known = set(discover()[0]) if only else set(specs)
    shutil.rmtree(out, ignore_errors=True)
    os.makedirs(out)
    for case_id, path in sorted(specs.items()):
        shutil.copy(path, os.path.join(out, case_id + ".json"))
    n = 0
    for fx in sorted(glob.glob(f"{HERE}/fixes-*.json")):
        with open(fx, encoding="utf-8") as fh:
            per = json.load(fh).get("perScenario") or {}
        for sid, p in per.items():
            patch = p.get("specPatch")
            if not patch or p.get("conflict"):
                continue
            base, _, idx = sid.partition("#")
            path = f"{out}/{base}.json"
            if not os.path.exists(path):
                if base not in known:
                    print("no spec in any set:", sid, file=sys.stderr)
                continue
            with open(path, encoding="utf-8") as fh:
                d = json.load(fh)
            if idx and isinstance(d.get("bookings"), list):
                d["bookings"][int(idx) - 1] = merge(d["bookings"][int(idx) - 1], patch)
            else:
                d = merge(d, patch)
            with open(path, "w", encoding="utf-8") as fh:
                json.dump(d, fh, indent=1)
            n += 1
    sets = {}
    for case_id in specs:
        sets[where[case_id]] = sets.get(where[case_id], 0) + 1
    print(json.dumps({"specs": len(specs), "patched": n, "sets": sets, "out": out}))


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    only = [a.split("=", 1)[1] for a in sys.argv[1:] if a.startswith("--only=")]
    main(args[0] if args else str(uat_config.work_dir() / "specs-patched"), only or None)
