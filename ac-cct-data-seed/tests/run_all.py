"""Every test, one command:  python tests/run_all.py

None of them touches the network, AWS, Kafka or a credential. That is the point of the ports: the
whole seed-and-judge use case runs against fakes, so the comparator rules can be changed and
checked in a second rather than by seeding bookings and reading output.
"""
from __future__ import annotations

import pathlib
import subprocess
import sys

HERE = pathlib.Path(__file__).resolve().parent


def main() -> int:
    failures = []
    for path in sorted(HERE.glob("test_*.py")):
        proc = subprocess.run([sys.executable, str(path)], text=True, capture_output=True,
                              env={**_env(), "PYTHONIOENCODING": "utf-8"})
        tail = (proc.stdout or proc.stderr or "").strip().splitlines()
        print(f"{path.name:30} {'ok  ' if proc.returncode == 0 else 'FAIL'} "
              f"{tail[-1][:80] if tail else ''}")
        if proc.returncode != 0:
            failures.append((path.name, "\n".join(tail[-12:])))
    for name, output in failures:
        print(f"\n--- {name}\n{output}")
    print(f"\n{len(failures)} file(s) failed" if failures else "\nall test files passed")
    return 1 if failures else 0


def _env() -> dict:
    import os
    return dict(os.environ)


if __name__ == "__main__":
    raise SystemExit(main())
