"""The scenario builder: cascade's `/qa builder`, driven by the vendored kit scripts.

Implements `ports.ScenarioBuilder` and `ports.BuiltBatch`.

Why this one and not a simpler synthesiser. Our own renderer wrote five messages across three feeds
-- two PNR versions, a ticket, an FDM schedule and an FDM estimate -- and the engine would not
assess the result: the leg stayed at `status: SCHEDULED`, `delayMin: 0`, `cause: UNKNOWN`, so every
case answered `FD-APPR-NE-20`. This builder rewrites one of five anonymised production histories
into the scenario and emits about 24 messages across PNR, TKT, PNRCORR, CM and FDM, spread over the
booking's real life -- sold in one month, flown the next, coupons changing status after it lands.
The same case built this way returned 11 of 11 fields agreeing.

The three steps are the kit's own, run as processes because that is how they are written and proven:

    apply_patches.py    spec/<flow>/<phase>/<purpose>/ + fixes-*.json  ->  specs-patched/
    spec_to_build.py    dates each scenario and gives it its own flight day
    scenario_build.py   drives the /qa builder, fixes the shapes the lower environments need

`spec_to_build` walking the flight day earlier until `carrier#number#day#origin` is free -- against
both this run and `taken-acc.json` -- is not tidiness: an environment that already holds another
booking on that flight makes the checkpoints read THAT flight's data, and the failure looks like bad
seed data.
"""
from __future__ import annotations

import datetime as _dt
import json
import pathlib
import subprocess
import sys
from dataclasses import dataclass, field
from typing import Iterable, Iterator

from core import paths
from domain.models import Booking, Scenario

#: feeds the builder emits, and the environment-specific topic each goes to
TOPIC_SUFFIX = {"int": "-INT", "crt": "-UAT", "bat": "-INT"}


class BuildFailed(RuntimeError):
    """A step failed. Carries the step and its last output rather than a bare exit code."""


@dataclass(frozen=True, slots=True)
class KitBatch:
    """A built batch: the bookings, their messages, and where they live.

    Satisfies `ports.BuiltBatch`.
    """
    directory: pathlib.Path
    _bookings: tuple[Booking, ...]
    #: where `apply_patches.py` wrote the specs this batch was built from. The patches change
    #: expectations, so a comparison that reads the source spec judges a different case.
    patched_dir: pathlib.Path | None = None
    _rows: tuple[dict, ...] = field(default=(), repr=False)
    failures: tuple[dict, ...] = ()

    @property
    def bookings(self) -> tuple[Booking, ...]:
        return self._bookings

    @property
    def messages(self) -> int:
        return len(self._rows)

    @property
    def manifest_path(self) -> pathlib.Path:
        return self.directory / "manifest.json"

    def payloads(self) -> Iterator[tuple[str, str, bytes]]:
        """`(topic, key, value)` in the builder's own `seq` order.

        The order is the booking's life, and the engine folds a history: a PNR that was always
        ticketed, or a flight that was always late, tells it nothing happened. The kit publishes
        unkeyed, which is kept here.
        """
        for row in sorted(self._rows, key=lambda r: r.get("seq") or 0):
            value = row["value"]
            body = value.encode() if isinstance(value, str) else json.dumps(value).encode()
            yield row["topic"], (row.get("key") or ""), body

    def rows(self) -> tuple[dict, ...]:
        return self._rows

    def patched(self) -> dict[str, dict]:
        """The patched spec per case id, as the builder received it."""
        out: dict[str, dict] = {}
        if not (self.patched_dir and self.patched_dir.is_dir()):
            return out
        for f in sorted(self.patched_dir.glob("*.json")):
            try:
                out[f.stem] = json.loads(f.read_text(encoding="utf-8"))
            except Exception:                                               # noqa: BLE001
                continue
        return out


class KitBuilder:
    """Drives the vendored kit scripts. Satisfies `ports.ScenarioBuilder`."""

    def __init__(self, *, builder_dir: pathlib.Path | None = None,
                 python: str | None = None, log=print) -> None:
        self.builder = builder_dir or paths.BUILDER
        self.python = python or sys.executable
        self.log = log

    # ---------------------------------------------------------------- plan

    def plan(self, *, work: pathlib.Path, env: str, run_day: str | None = None,
             spec_set: str | None = None) -> list[dict]:
        """Patch and date the scenarios of a set, returning the build plans.

        Dates are relative to the run day, which is the UTC date. After about 20:00 Eastern that has
        already moved to tomorrow, and a flight pinned to "yesterday" may not have landed -- so a
        caller that knows better passes its own.

        `spec_set` is a set name from the spec tree, e.g. `fd/uat/automation`. Without one the whole
        tree is patched, which costs nothing but plans scenarios from flows this run is not seeding.
        """
        work.mkdir(parents=True, exist_ok=True)
        day = run_day or _dt.datetime.now(_dt.timezone.utc).date().isoformat()
        patched = work / "specs-patched"
        patch_args = ["apply_patches.py", str(patched)]
        if spec_set:
            patch_args.append(f"--only={spec_set}")
        self._run(patch_args, work, env)
        plans = work / "all-builds.json"
        taken = self._taken_file(work, env)
        self._run(["spec_to_build.py", day, str(plans),
                   "--taken", str(taken), "--specs", str(patched)], work, env)
        return json.loads(plans.read_text(encoding="utf-8"))

    # --------------------------------------------------------------- build

    def build(self, scenarios: Iterable[Scenario], *, env: str,
              run_day: str | None = None, work: pathlib.Path | None = None,
              tag: str = "b01", spec_set: str | None = None) -> KitBatch:
        """Build the given scenarios. They must already be planned (see `plan`)."""
        work = work or (paths.RUNS / env / f"build-{_dt.datetime.now().strftime('%m%dT%H%M')}")
        wanted = {s.case_id for s in scenarios}
        plans = [p for p in self.plan(work=work, env=env, run_day=run_day, spec_set=spec_set)
                 if p.get("id") in wanted]
        if not plans:
            raise BuildFailed(f"none of {len(wanted)} scenario(s) are in the plan")
        return self.build_plans(plans, env=env, work=work, tag=tag)

    def build_plans(self, plans: list[dict], *, env: str, work: pathlib.Path,
                    tag: str = "b01") -> KitBatch:
        """Build from plans already produced, which is what a batched run wants."""
        plan_file = work / f"{tag}-builds.json"
        plan_file.write_text(json.dumps(plans, indent=1), encoding="utf-8")
        out = work / tag
        patched = work / "specs-patched"
        # a bag cannot be added after the fact: its events hang off the flight's ACTUAL arrival and
        # its check-in sits 150 minutes before departure, so the bag steps have to be in the plan
        # the builder walks. `bag_build.py` injects them and then runs `scenario_build.main`
        # unchanged, so a set with no bagPlan builds byte-for-byte as it did before.
        if self._wants_bags(plans, patched):
            self._run(["bag_build.py", str(plan_file), str(patched), str(out), env], work, env)
        else:
            self._run(["scenario_build.py", str(plan_file), "-", str(out), env], work, env)
        self.remember_used(env, out / "manifest.json")
        return self.load(out, patched_dir=patched)

    @staticmethod
    def _wants_bags(plans: list[dict], patched: pathlib.Path) -> bool:
        """Whether any planned scenario states a `bagPlan`, read from the specs as patched."""
        for p in plans:
            spec = patched / f"{p.get('id')}.json"
            if not spec.exists():
                continue
            try:
                if (json.loads(spec.read_text(encoding="utf-8")) or {}).get("bagPlan"):
                    return True
            except Exception:                                               # noqa: BLE001
                continue
        return False

    def _taken_file(self, work: pathlib.Path, env: str) -> pathlib.Path:
        """The snapshot merged with the flight keys our own runs have already used here.

        Without this the picker reuses a day it used an hour ago: the keys a run consumes are not
        written anywhere the next run reads, so two bookings land on one leg and the engine can
        only hold one of them.
        """
        snapshot = self.builder / "taken-acc.json"
        keys = set()
        try:
            keys |= {str(k) for k in json.loads(snapshot.read_text(encoding="utf-8"))}
        except Exception:                                                   # noqa: BLE001
            pass
        keys |= self.keys_used(env)
        proven = self.keys_proven_taken(env)
        keys |= proven
        merged = work / "taken-merged.json"
        merged.write_text(json.dumps(sorted(keys)), encoding="utf-8")
        self.log(f"    taken: {len(keys)} flight key(s) avoided "
                 f"({len(self.keys_used(env))} from this project's own runs, "
                 f"{len(proven)} proven occupied by a read)")
        return merged

    @staticmethod
    def keys_proven_taken(env: str) -> set[str]:
        """Keys an engine read proved were already in use, from `runs/<env>/taken-extra.json`.

        The snapshot and our own manifests only know what WE published. A key can be occupied by
        a booking nobody here recorded -- a different kit, another tester, a previous reset -- and
        the only evidence is a verdict about a delay we never sent. `tools/collisions.py` writes
        those keys here, so a reseed of the affected case picks a different day.
        """
        path = paths.RUNS / env / "taken-extra.json"
        try:
            return {str(k) for k in json.loads(path.read_text(encoding="utf-8"))}
        except Exception:                                                   # noqa: BLE001
            return set()

    @staticmethod
    def _manifest_keys(rows) -> set[str]:
        """The `carrier#number#day#origin` keys a build manifest's bookings fly on."""
        out: set[str] = set()
        for r in rows if isinstance(rows, list) else []:
            if not (isinstance(r, dict) and r.get("pnrId")):
                continue
            for f in r.get("flights") or []:
                carrier, number = f.get("carrier"), f.get("number")
                day = str(f.get("depUtc") or "")[:10]
                origin = f.get("origin")
                if carrier and number and day and origin:
                    out.add(f"{carrier}#{number}#{day}#{origin}")
        return out

    @staticmethod
    def ledger(env: str) -> pathlib.Path:
        return paths.RUNS / env / "taken-used.json"

    @classmethod
    def remember_used(cls, env: str, manifest: pathlib.Path) -> None:
        """Add a build's flight keys to `runs/<env>/taken-used.json` the moment it is built.

        Scanning manifests alone forgot a whole BAT seed once its build folder was gone: 2,552
        keys dropped out of the avoid list, the next run landed 97 of 99 bookings on flights that
        already held a booking, and the engine judged them on the older booking's delay.
        """
        try:
            keys = cls._manifest_keys(json.loads(manifest.read_text(encoding="utf-8")))
        except Exception:                                                   # noqa: BLE001
            return
        if not keys:
            return
        path = cls.ledger(env)
        try:
            known = {str(k) for k in json.loads(path.read_text(encoding="utf-8"))}
        except Exception:                                                   # noqa: BLE001
            known = set()
        if keys <= known:
            return
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(sorted(known | keys), indent=0), encoding="utf-8")

    @classmethod
    def keys_used(cls, env: str) -> set[str]:
        """Every flight key this project has published in an environment: the ledger, plus any
        manifest still on disk (runs from before the ledger existed)."""
        out: set[str] = set()
        try:
            out |= {str(k) for k in json.loads(cls.ledger(env).read_text(encoding="utf-8"))}
        except Exception:                                                   # noqa: BLE001
            pass
        base = paths.RUNS / env
        if not base.is_dir():
            return out
        for manifest in base.rglob("manifest.json"):
            try:
                out |= cls._manifest_keys(json.loads(manifest.read_text(encoding="utf-8")))
            except Exception:                                               # noqa: BLE001
                continue
        return out

    @staticmethod
    def load(directory: pathlib.Path,
             patched_dir: pathlib.Path | None = None) -> KitBatch:
        """A batch the builder already wrote, read back."""
        manifest = directory / "manifest.json"
        messages = directory / "batch" / "messages.jsonl"
        if not manifest.exists():
            raise BuildFailed(f"{directory} holds no manifest.json")
        rows = tuple(json.loads(line) for line in
                     messages.read_text(encoding="utf-8").splitlines() if line.strip()) \
            if messages.exists() else ()
        failed_path = directory / "build-failed.json"
        failures = tuple(json.loads(failed_path.read_text(encoding="utf-8"))) \
            if failed_path.exists() else ()
        bookings = tuple(Booking.from_manifest(r)
                         for r in json.loads(manifest.read_text(encoding="utf-8"))
                         if r.get("pnrId"))
        if patched_dir is None:
            # a batch read back from disk: its sibling specs-patched is the one it was built from
            guess = directory.parent / "specs-patched"
            patched_dir = guess if guess.is_dir() else None
        return KitBatch(directory=directory, _bookings=bookings, _rows=rows, failures=failures,
                        patched_dir=patched_dir)

    # ------------------------------------------------------------ internals

    def _run(self, args: list[str], work: pathlib.Path, env: str) -> str:
        import os
        cmd = [self.python, "-X", "utf8", *args]
        proc = subprocess.run(
            cmd, cwd=self.builder, text=True, capture_output=True,
            env={**os.environ,
                 # the vendored /qa builder by default; `uat_config.builder_dir()` reads this, so
                 # no cascade checkout is needed. AQA_SEED_CASCADE still overrides it.
                 "QA_BUILDER_DIR": str(paths.require("qa-builder")),
                 "UAT_WORK_DIR": str(work), "UAT_ENV": env, "PYTHONUTF8": "1"})
        output = ((proc.stdout or "") + (proc.stderr or "")).strip()
        for line in output.splitlines()[-2:]:
            self.log(f"    {line}")
        if proc.returncode != 0:
            raise BuildFailed(f"{args[0]} exited {proc.returncode}: {output[-700:]}")
        return output
