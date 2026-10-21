"""Wait for a working AWS sign-in instead of failing on an expired one.

Everything that reaches INT goes through the `int-cce` SSO profile, and its session expires on its own
schedule. A seed that starts on an expired session fails part-way -- after minting members, before
publishing -- and the person only learns it from a stack trace. So before such work starts:

    ensure()  ->  `aws sts get-caller-identity --profile int-cce`
                  expired? start `aws sso login --profile int-cce` (it opens the browser, where the
                  PERSON approves), then poll until the identity call works again, and carry on

Nothing here holds or writes a credential: the aws CLI keeps its own SSO cache, and the sign-in is the
person's own, in their own browser. While it waits, `runs/.aws-signin.json` says so, which the UI shows
as "Waiting for AWS sign-in" with a button that starts the same login.
"""
from __future__ import annotations

import datetime as _dt
import json
import subprocess
import time
from typing import Callable

from core import paths

PROFILE = "int-cce"
STATUS = paths.RUNS / ".aws-signin.json"


def signed_in(profile: str = PROFILE, *, run: Callable = subprocess.run) -> bool:
    """Whether the profile's credentials work right now."""
    try:
        r = run(["aws", "sts", "get-caller-identity", "--profile", profile, "--output", "json"],
                capture_output=True, text=True, timeout=45)
    except (OSError, subprocess.TimeoutExpired):
        return False
    return r.returncode == 0


def start_login(profile: str = PROFILE, *, popen: Callable = subprocess.Popen) -> None:
    """Start the SSO login. It opens the browser; the person approves there. Returns at once."""
    flags = getattr(subprocess, "CREATE_NEW_PROCESS_GROUP", 0)
    popen(["aws", "sso", "login", "--profile", profile], stdout=subprocess.DEVNULL,
          stderr=subprocess.DEVNULL, stdin=subprocess.DEVNULL, creationflags=flags)


def status() -> dict:
    try:
        return json.loads(STATUS.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return {"waiting": False}


def _write(state: dict) -> None:
    try:
        STATUS.parent.mkdir(parents=True, exist_ok=True)
        STATUS.write_text(json.dumps(state), encoding="utf-8")
    except OSError:
        pass


def ensure(profile: str = PROFILE, *, wait_s: int = 900, every_s: int = 10, log: Callable = print,
           check: Callable = signed_in, login: Callable = start_login, sleep: Callable = time.sleep) -> bool:
    """True once the profile works; False if nobody signed in within `wait_s`.

    Starts the browser login once, then only polls: starting it again every poll would open a new tab
    each time and invalidate the code the person is about to approve.
    """
    if check(profile):
        return True
    log(f"[aws] the {profile} sign-in has expired: opening the AWS sign-in in the browser. "
        f"Approve it there; this waits up to {wait_s // 60} min and then carries on.")
    _write({"waiting": True, "profile": profile,
            "since": _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds")})
    try:
        login(profile)
        waited = 0
        while waited < wait_s:
            sleep(every_s)
            waited += every_s
            if check(profile):
                log(f"[aws] signed in again after {waited}s; continuing")
                return True
        log(f"[aws] no sign-in within {wait_s // 60} min; stopping before anything is sent")
        return False
    finally:
        _write({"waiting": False, "profile": profile})
