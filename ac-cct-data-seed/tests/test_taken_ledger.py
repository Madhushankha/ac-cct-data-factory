"""A built flight stays avoided after its build folder is gone.

The avoid list used to come only from manifests still on disk. A BAT seed whose build folder went
missing dropped 2,552 keys, and the next run put 97 of 99 bookings on flights that already held a
booking. `remember_used` writes each build's keys to `runs/<env>/taken-used.json` as it is built.

Run:  python tests/test_taken_ledger.py
"""
from __future__ import annotations

import json
import pathlib
import shutil
import sys
import tempfile

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from adapters import kit_builder                                            # noqa: E402
from adapters.kit_builder import KitBuilder                                 # noqa: E402

FAILED: list[str] = []


def check(label: str, got: object, want: object) -> None:
    if got != want:
        FAILED.append(label)
        print(f"  FAIL {label}: got {got!r}, wanted {want!r}")
    else:
        print(f"  ok   {label}")


ROWS = [
    {"pnrId": "ZZ0001-2026-05-14",
     "flights": [{"carrier": "AC", "number": "7412", "depUtc": "2026-06-13T16:40:00Z", "origin": "YUL"}]},
    {"pnrId": "ZZ0002-2026-05-14",
     "flights": [{"carrier": "AC", "number": "7375", "depUtc": "2026-06-13T16:40:00Z", "origin": "YUL"},
                 {"carrier": "AC", "number": "8001", "depUtc": "", "origin": "YYZ"}]},   # no day: skipped
    {"flights": [{"carrier": "AC", "number": "9", "depUtc": "2026-06-13", "origin": "YVR"}]},  # no pnrId
]


def main() -> int:
    tmp = pathlib.Path(tempfile.mkdtemp())
    real_runs = kit_builder.paths.RUNS
    kit_builder.paths.RUNS = tmp
    try:
        build = tmp / "bat" / "build-x" / "b01"
        build.mkdir(parents=True)
        (build / "manifest.json").write_text(json.dumps(ROWS), encoding="utf-8")

        KitBuilder.remember_used("bat", build / "manifest.json")
        want = {"AC#7412#2026-06-13#YUL", "AC#7375#2026-06-13#YUL"}
        check("the build's keys go to the ledger",
              set(json.loads((tmp / "bat" / "taken-used.json").read_text())), want)

        shutil.rmtree(tmp / "bat" / "build-x")
        check("still avoided once the build folder is gone", KitBuilder.keys_used("bat"), want)

        other = tmp / "bat" / "build-y" / "b01"
        other.mkdir(parents=True)
        (other / "manifest.json").write_text(json.dumps(
            [{"pnrId": "ZZ0003-2026-05-14", "flights": [
                {"carrier": "AC", "number": "7597", "depUtc": "2026-06-13T10:00:00Z", "origin": "YUL"}]}]),
            encoding="utf-8")
        KitBuilder.remember_used("bat", other / "manifest.json")
        check("a second build adds to the ledger, not replaces it",
              len(json.loads((tmp / "bat" / "taken-used.json").read_text())), 3)
        check("the ledger is per environment", KitBuilder.keys_used("int"), set())

        KitBuilder.remember_used("bat", tmp / "missing.json")   # a failed build: no manifest
        check("a missing manifest changes nothing", len(KitBuilder.keys_used("bat")), 3)
    finally:
        kit_builder.paths.RUNS = real_runs
        shutil.rmtree(tmp, ignore_errors=True)

    print(f"\n{len(FAILED)} failed" if FAILED else "\nall passed")
    return 1 if FAILED else 0


if __name__ == "__main__":
    raise SystemExit(main())
