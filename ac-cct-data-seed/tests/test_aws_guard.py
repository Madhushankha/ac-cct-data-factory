"""Waiting for an AWS sign-in instead of failing on an expired one: fakes only, no aws CLI, no network.

Run:  python tests/test_aws_guard.py
"""
from __future__ import annotations

import pathlib
import sys
import tempfile

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from core import aws_guard                                                  # noqa: E402

FAILED: list[str] = []


def check(label: str, got: object, want: object) -> None:
    if got != want:
        FAILED.append(label)
        print(f"  FAIL {label}: got {got!r}, wanted {want!r}")
    else:
        print(f"  ok   {label}")


def main() -> None:
    aws_guard.STATUS = pathlib.Path(tempfile.mkdtemp()) / ".aws-signin.json"
    logins: list[str] = []
    quiet = lambda *_: None                                                 # noqa: E731

    print("a working session")
    check("passes straight through, opening nothing",
          (aws_guard.ensure(check=lambda p: True, login=logins.append, sleep=lambda s: None, log=quiet), logins),
          (True, []))

    print("an expired session that the person signs back into")
    answers = iter([False, False, False, True])
    seen: list[dict] = []
    def sleep(_):
        seen.append(aws_guard.status())
    ok = aws_guard.ensure(check=lambda p: next(answers), login=logins.append, sleep=sleep, log=quiet, every_s=10)
    check("waits, then carries on", ok, True)
    check("opens the sign-in once, not on every poll", logins, ["int-cce"])
    check("says it is waiting while it waits", seen[0].get("waiting"), True)
    check("and stops saying so afterwards", aws_guard.status().get("waiting"), False)

    print("nobody signs in")
    logins.clear()
    check("gives up after the wait, reporting False",
          aws_guard.ensure(check=lambda p: False, login=logins.append, sleep=lambda s: None, log=quiet,
                           wait_s=30, every_s=10), False)
    check("having opened the sign-in once", logins, ["int-cce"])

    print("signed_in reads the aws CLI's exit code")
    class R:
        def __init__(self, rc): self.returncode = rc
    check("0 -> signed in", aws_guard.signed_in(run=lambda *a, **k: R(0)), True)
    check("255 -> expired", aws_guard.signed_in(run=lambda *a, **k: R(255)), False)
    def missing(*a, **k):
        raise OSError("aws not installed")
    check("no aws CLI -> not signed in, no crash", aws_guard.signed_in(run=missing), False)


if __name__ == "__main__":
    main()
    if FAILED:
        print(f"\n{len(FAILED)} check(s) failed")
        sys.exit(1)
    print("\nall checks passed")
