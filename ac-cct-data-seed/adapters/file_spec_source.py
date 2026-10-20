"""Where scenarios come from: the project's spec tree.

Implements `ports.SpecSource`.

The tree is the layout a person uses to find a set, and the only thing that defines what a set is:

    spec/<flow>/<phase>/<purpose>/<CASE_ID>.json

* **flow** is the flow id -- `fd`, `soc`, `baggage`, `anc` -- so the directory name resolves to a
  policy in `flows.registry` with no mapping table in between.
* **phase** is where the set is used: `uat`, `sit`, `bat`.
* **purpose** is what it is for: `automation` for a set an automated suite runs end to end, `po`
  for the cases a product owner walks through by hand.

So `spec/fd/uat/automation` is "the FD UAT automation set", and adding a set is creating a folder.
Nothing registers it, and no code lists the sets.

Two rules the tree enforces, both from defects:

**One id, one spec.** The kit copied `specs/` and then `specs-nobooking/` into one output directory,
so for 19 scenarios the winner was decided by directory order. The outcome happened to be right --
the authored booking beat the empty "no booking data" shell -- and nothing anywhere said so. A
duplicate id now raises, and the superseded file lives in a `_superseded/` folder that is never
read.

**A folder beginning with `_` is not a set.** That is what makes keeping the losers next to the
winners safe.
"""
from __future__ import annotations

import json
import pathlib
from dataclasses import dataclass
from typing import Iterable, Iterator

from core import paths
from domain.models import Scenario

#: a directory whose name starts with this is kept for the record and never built
PRIVATE = "_"
IGNORE = {"__pycache__"}


class DuplicateCaseId(ValueError):
    """Two sets claim the same case id. One id, one spec."""


@dataclass(frozen=True, slots=True)
class SpecSet:
    """One set: where it is, and what it holds."""
    name: str                       # "fd/uat/automation"
    flow: str                       # "fd"
    phase: str                      # "uat"
    purpose: str                    # "automation"
    path: pathlib.Path
    count: int

    @property
    def label(self) -> str:
        return f"{self.flow.upper()} {self.phase.upper()} {self.purpose}"


class FileSpecSource:
    """Reads sets from the spec tree. Satisfies `ports.SpecSource`."""

    def __init__(self, root: pathlib.Path | None = None) -> None:
        self.root = root or paths.SPEC

    # ------------------------------------------------------------- discovery

    def sets(self) -> tuple[str, ...]:
        """Every set in the tree, as `flow/phase/purpose`, in tree order."""
        return tuple(s.name for s in self.describe())

    def describe(self) -> tuple[SpecSet, ...]:
        """Every set with its flow, phase, purpose and size -- including the empty ones.

        Empty sets are listed on purpose: a folder with a README and no specs is a set someone
        intends to fill, and hiding it makes the gap invisible.
        """
        out: list[SpecSet] = []
        for d in sorted(p for p in self.root.rglob("*") if p.is_dir()):
            rel = d.relative_to(self.root).as_posix()
            parts = rel.split("/")
            if len(parts) != 3 or any(p.startswith(PRIVATE) or p in IGNORE for p in parts):
                continue
            flow, phase, purpose = parts
            out.append(SpecSet(name=rel, flow=flow, phase=phase, purpose=purpose, path=d,
                               count=len(list(d.glob("*.json")))))
        return tuple(out)

    def set_named(self, name: str) -> SpecSet:
        for s in self.describe():
            if s.name == name.strip("/"):
                return s
        known = ", ".join(s.name for s in self.describe()) or "(none)"
        raise KeyError(f"no such set {name!r}; the tree holds: {known}")

    # ------------------------------------------------------------- scenarios

    def scenarios(self, set_name: str) -> tuple[Scenario, ...]:
        """One set, parsed into domain scenarios, sorted by case id.

        A spec file holding a `bookings` list is several scenarios in one file; the kit writes those
        for cases where one test needs two bookings, and they are given `#n` suffixes exactly as
        the builder addresses them in `fixes-*.json`.
        """
        return tuple(self._parse_dir(self.set_named(set_name).path))

    def scenario(self, case_id: str) -> Scenario:
        """One case by id, from whichever set holds it."""
        for s in self.describe():
            path = s.path / f"{case_id}.json"
            if path.exists():
                return next(iter(self._parse_file(path)))
        raise KeyError(f"no spec for {case_id!r} in {self.root}")

    def index(self) -> dict[str, str]:
        """`case_id -> set name` for the whole tree, raising on a duplicate id."""
        out: dict[str, str] = {}
        for s in self.describe():
            for path in sorted(s.path.glob("*.json")):
                case_id = path.stem
                if case_id in out:
                    raise DuplicateCaseId(
                        f"{case_id} is in both {out[case_id]} and {s.name}. One id, one spec: move "
                        f"the one that should not be built into a _superseded/ folder.")
                out[case_id] = s.name
        return out

    # ------------------------------------------------------------- internals

    def _parse_dir(self, directory: pathlib.Path) -> Iterator[Scenario]:
        for path in sorted(directory.glob("*.json")):
            yield from self._parse_file(path)

    @staticmethod
    def _parse_file(path: pathlib.Path) -> Iterable[Scenario]:
        # utf-8 explicitly: Windows defaults to cp1252 and FD_TC_238 holds a character it cannot
        # decode, which failed here while working on the kit's own host
        raw = json.loads(path.read_text(encoding="utf-8"))
        rows = raw["bookings"] if isinstance(raw.get("bookings"), list) else [raw]
        for i, row in enumerate(rows, 1):
            row = {**{k: v for k, v in raw.items() if k != "bookings"}, **row} if len(rows) > 1 \
                else row
            row.setdefault("id", path.stem)
            if len(rows) > 1:
                row["id"] = f"{path.stem}#{i}"
            yield Scenario.parse(row)
