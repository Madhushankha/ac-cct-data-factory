"""Seed a case from this project.

    python -m core.seed FD_PO_001 --env int

What it does, in order:

1. loads the spec by id from `spec/`
2. asks the flow whether the spec can be run at all, and stops if it cannot -- a case with no
   stated expectation is stopped here rather than seeded and then reported as passing
3. builds the fixture (`convert.spec_to_fixture`) and writes it where the agentic-qa pipeline looks
   for an extra fixture: `fixtures/fd-<suite>/_extra/<ID>.json`
4. runs that pipeline's five phases as a subprocess, on the INT profile
5. records the run under `runs/<env>/<label>/<ID>.json`: the spec id, the locator, the checkpoint
   results and the command, so a run can be read back without the seeder's own directory

Why a subprocess and not an import: the pipeline resolves its environment, AWS profile and
credentials at import time, and it is proven as a process. Driving it the way a person does keeps
this file to orchestration, which is all it should be.

The profile is not a default anywhere here. INT seeding runs on `int-cce`, because `int-sso` lacks
the `profile:*` permissions and fails silently part-way through -- which looks like a data problem
rather than a credentials one.
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

from core import convert, paths, raptor, registry                           # noqa: E402

AQA = paths.agentic_qa()
#: resolved on use, not at import: the fixture tree is not vendored, and this module is the
#: previous generation of the seeder -- `application/seed_pack.py` is the one that does not need it
def FIXTURES():                                                             # noqa: N802
    return paths.fixtures()
PYTHON = sys.executable
#: INT seeding runs on this profile only; see the module docstring.
PROFILE = "int-cce"


def find_spec(spec_id: str) -> pathlib.Path:
    hits = sorted((ROOT / "spec").rglob(f"{spec_id}.json"))
    if not hits:
        raise SystemExit(f"no spec for {spec_id!r} under {ROOT / 'spec'}")
    if len(hits) > 1:
        raise SystemExit(f"{spec_id!r} appears in {len(hits)} places: "
                         + ", ".join(str(h.relative_to(ROOT)) for h in hits))
    return hits[0]


def checkpoints_for(env: str, suite: str, spec_id: str, locator: str | None) -> tuple[str | None, dict]:
    """The locator the pipeline used, and the checkpoints it wrote for it."""
    base = AQA / "data" / "seed" / env / f"fd-{suite}" / spec_id
    if not base.is_dir():
        return locator, {}
    dirs = sorted((d for d in base.iterdir() if d.is_dir()),
                  key=lambda d: d.stat().st_mtime, reverse=True)
    if not dirs:
        return locator, {}
    chosen = next((d for d in dirs if d.name == locator), dirs[0])
    for f in chosen.glob("*.checkpoints.json"):
        return chosen.name, json.loads(f.read_text(encoding="utf-8"))
    return chosen.name, {}


def _pnr_date(fixture: dict) -> str:
    """The date a pnrId carries: the first segment's departure date."""
    segs = fixture.get("segments") or [{}]
    return (segs[0].get("dep_local") or "")[:10]


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="core.seed", description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("spec_id", help="e.g. FD_PO_001")
    ap.add_argument("--env", default="int", choices=("int", "crt", "bat"))
    ap.add_argument("--label", default="", help="names the run folder; defaults to the date")
    ap.add_argument("--phase", default="all", help="a single pipeline phase, or all")
    ap.add_argument("--pin", action="store_true",
                    help="write the expected verdict into execution_traces and S3 as the old "
                         "pipeline did. OFF by default: nothing on INT reads any of it since "
                         "2026-10-13, and reading back a verdict you wrote verifies nothing")
    ap.add_argument("--no-pin", action="store_true", help="accepted and ignored; pinning is off")
    # The identity overrides the pipeline has always had, which this entry point never passed on.
    # A seed with no name given mints a collision-free surname per run, so the same case seeded
    # twice is two different people -- EMILY RENVOLGIL and EMILY KORFENSOR for FD_PO_001. Pinning
    # the name makes a set recognisable to a tester, and the pipeline exempts a pinned surname from
    # its name_uniqueness check because it is meant to recur.
    ap.add_argument("--first-name", default="", help="first name for the first passenger")
    ap.add_argument("--last-name", default="", help="surname for the first passenger (no spaces: "
                                                    "the lookup normalises case but not spacing)")
    ap.add_argument("--keep-names", action="store_true",
                    help="keep the fixture's own surnames where they are absent from the DB")
    ap.add_argument("--email", default="", help="contact email (default: the env's mailinator box)")
    ap.add_argument("--phone", default="", help="contact phone (default: the mock +123456789)")
    ap.add_argument("--dob", default="", help="date of birth for the first passenger")
    ap.add_argument("--loyalty-number", default="", help="a real Aeroplan number, if the tester has one")
    ap.add_argument("--no-flight", action="store_true",
                    help="skip the DEP/ARR/ARRIVAL_CODE lane. Without it the leg stays SCHEDULED "
                         "and the engine has no disruption to assess")
    ap.add_argument("--dry-run", action="store_true",
                    help="write the fixture and print the command, publish nothing")
    a = ap.parse_args(argv)

    spec = json.loads(find_spec(a.spec_id).read_text(encoding="utf-8"))
    flow = registry.get((spec.get("family") or "fd").lower())

    missing = flow.validate(spec)
    if missing:
        print(f"{a.spec_id}: cannot be run as {flow.label}")
        for m in missing:
            print(f"  - {m}")
        return 2

    suite = (spec.get("source") or {}).get("suite", "fd-uat").removeprefix("fd-")
    fixture = convert.spec_to_fixture(spec, FIXTURES())
    fixture["creation_comment"] = (f"generated from ac-cct-data-seed spec {a.spec_id}; "
                                   f"edit the spec, not this file")
    # Beside the other fixtures, not in _extra: catalog._scenario_index picks up every
    # fd-<suite>/FD_*.json, while _fixture_by_id is consulted ONLY for an id that does not start
    # with the flow prefix ("ZFU010"). FD_PO_001 does, so _extra is never looked at for it.
    target = FIXTURES / f"fd-{suite}" / f"{a.spec_id}.json"
    target.write_text(json.dumps(fixture, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"fixture written: {target.relative_to(AQA)}")

    # .cli, not the package: aqa/workflows/seed/__main__.py calls main() without sys.exit(), so
    #  exits 0 even when the pipeline sets rc=3 or rc=4
    cmd = [PYTHON, "-X", "utf8", "-m", "aqa.workflows.seed.cli",
           "--env", a.env, "--suite", suite, "--flow", "fd", "--case", a.spec_id, a.phase]
    if not a.pin:
        cmd.insert(-1, "--no-pin")
    if a.keep_names:
        cmd.insert(-1, "--keep-names")
    for flag, value in (("--first-name", a.first_name), ("--last-name", a.last_name),
                        ("--email", a.email), ("--phone", a.phone), ("--dob", a.dob),
                        ("--loyalty-number", a.loyalty_number)):
        if value:
            cmd[-1:-1] = [flag, value]
    print("$ " + " ".join(cmd[3:]))
    if a.dry_run:
        return 0

    env = {**_os_environ(), "AWS_PROFILE": PROFILE, "AQA_ACCP_PROFILE": PROFILE,
           "AWS_DEFAULT_REGION": "ca-central-1", "PYTHONUTF8": "1"}
    started = _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds")
    proc = subprocess.run(cmd, cwd=AQA, env=env, text=True, capture_output=True)
    tail = (proc.stdout or "").splitlines()
    for line in tail[-25:]:
        print(line)
    if proc.returncode != 0 and proc.stderr:
        print(proc.stderr.strip()[-1500:], file=sys.stderr)

    locator = next((w.strip() for line in tail if "locator" in line.lower()
                    for w in line.split() if w.isalnum() and len(w) == 6 and w.isupper()), None)
    locator, cps = checkpoints_for(a.env, suite, a.spec_id, locator)

    flight: list[dict] = []
    # Gated on the locator, NOT on the return code. A seed without the pin always exits 1, because
    # the pipeline's own DDS checkpoints fail when nothing wrote a verdict -- which is the whole
    # point of running without it. Gating the lane on rc==0 meant it never ran at all.
    if locator:
        if a.no_flight:
            print("flight lane skipped: the leg stays SCHEDULED and cannot be assessed")
        else:
            try:
                from lanes import fdm                                       # noqa: PLC0415
                meta = AQA / "data" / "seed" / a.env / f"fd-{suite}" / a.spec_id / locator / "meta.json"
                flight = fdm.publish(json.loads(meta.read_text(encoding="utf-8")),
                                     a.env, dry_run=False)
            except Exception as ex:                                         # noqa: BLE001
                print(f"flight lane failed: {type(ex).__name__}: {ex}")

    verdict = {"checked": False, "why": "", "via": "", "document": None, "checks": []}
    try:
        reader = raptor.from_env()
        doc = reader.document(fixture.get("identity", {}).get("pnr") and f"{locator}-{_pnr_date(fixture)}"
                              or f"{locator}")
        verdict["via"] = reader.via
        if doc is None:
            verdict["why"] = "the engine holds no assessment for this booking yet"
        else:
            rows = flow.rows(doc)
            verdict.update(checked=True, document=doc,
                           checks=[c.__dict__ for c in flow.checks(spec, rows)])
    except raptor.NoCredential as ex:
        verdict["why"] = str(ex)
    except raptor.RaptorError as ex:
        verdict["why"] = f"the engine could not be read: {ex}"

    # A returncode of 0 is not evidence on its own. A seed that ran produced a locator and
    # checkpoints; one that printed an error did not succeed whatever it exited with.
    errors = [l for l in tail if "[seed] ERROR" in l]
    ok = proc.returncode == 0 and not errors and bool(locator) and bool(cps)
    run = {
        "ok": ok, "errors": errors[:3],
        "spec_id": a.spec_id, "env": a.env, "flow": flow.id, "label": a.label or "adhoc",
        "started_at": started,
        "finished_at": _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds"),
        "command": " ".join(cmd[3:]), "returncode": proc.returncode,
        "pinned": bool(a.pin),
        "flight_lane": flight,
        # The pipeline's own checks prove the BOOKING. The verdict is a separate question with a
        # separate answer, and the two are never summed: a run that seeded perfectly and checked no
        # verdict has proven the data and nothing about the rules.
        "verdict": verdict,
        "locator": locator, "expect": spec.get("expect"), "checkpoints": cps,
        "log_tail": tail[-60:],
    }
    out = ROOT / "runs" / a.env / (a.label or _dt.date.today().isoformat())
    out.mkdir(parents=True, exist_ok=True)
    (out / f"{a.spec_id}.json").write_text(json.dumps(run, indent=1) + "\n", encoding="utf-8")
    print(f"\nrun recorded: {(out / (a.spec_id + '.json')).relative_to(ROOT)}  rc={proc.returncode}")

    rows = cps.get("checkpoints") if isinstance(cps, dict) else None
    if rows:
        p = sum(1 for c in rows if c.get("status") == "pass")
        f = sum(1 for c in rows if c.get("status") == "fail")
        n = len(rows) - p - f
        print(f"checkpoints: {p} pass, {f} fail, {n} n/a")
    return 0 if ok else (proc.returncode or 1)


def _os_environ() -> dict:
    import os
    return dict(os.environ)


if __name__ == "__main__":
    raise SystemExit(main())
