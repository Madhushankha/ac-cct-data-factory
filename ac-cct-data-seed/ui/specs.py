"""The spec tree as something a person edits: sets and cases, created, changed, moved and deleted.

Reading goes through `adapters.file_spec_source.FileSpecSource`, so the UI sees exactly the sets
and cases the CLI sees. Writing is here, and follows the tree's own rules (spec/README.md):

* **One id, one spec.** Creating, renaming, cloning or moving a case refuses an id that any set
  already holds, because a duplicate makes `index()` raise and stops every seed.
* **Nothing here destroys a spec.** A deleted case goes to its set's `_superseded/`, the one folder
  inside the tree that both `FileSpecSource` and `builder/apply_patches.py` skip. Everything else is
  kept OUTSIDE `spec/`, in `spec-attic/`: an edited case leaves its previous text in
  `spec-attic/history/`, and an archived set moves to `spec-attic/archived/`. The builder walks
  every folder under `spec/` except `_superseded`, so a history file kept inside the tree would be
  built as a case of its own. Each can be restored.
* **The folder name is the flow id.** A new set must name a flow the registry knows, or
  `python -m cli sets` would fail on it.
"""
from __future__ import annotations

import datetime as _dt
import json
import pathlib
import re
import shutil
from typing import Any

from adapters.file_spec_source import FileSpecSource
from core import paths
from domain.models import Scenario
from flows import registry

ID_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9_.\-]{0,79}$")
PART_RE = re.compile(r"^[a-z0-9][a-z0-9\-]{0,39}$")
SUPERSEDED = "_superseded"


class SpecError(ValueError):
    """A request the tree's rules refuse. The message is shown to the person as it is."""


def _stamp() -> str:
    return _dt.datetime.now(_dt.timezone.utc).strftime("%Y%m%dT%H%M%S")


def _write(path: pathlib.Path, raw: dict) -> None:
    # indent=1 and real characters, the way the existing specs are written, so a saved file
    # diffs against its previous version line by line instead of as one rewritten blob
    path.write_text(json.dumps(raw, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")


class SpecStore:
    def __init__(self, root: pathlib.Path | None = None, attic: pathlib.Path | None = None) -> None:
        self.root = root or paths.SPEC
        self.attic = attic or self.root.parent / "spec-attic"
        self.source = FileSpecSource(self.root)

    @property
    def archive_root(self) -> pathlib.Path:
        return self.attic / "archived"

    def _history_dir(self, path: pathlib.Path) -> pathlib.Path:
        # by case id alone, so a case keeps its versions when it moves to another set
        return self.attic / "history"

    # ------------------------------------------------------------------ sets

    def sets(self) -> list[dict[str, Any]]:
        out = []
        for s in self.source.describe():
            try:
                policy = registry.for_set(s.name)
                needs = list(policy.needs)
                label = getattr(policy, "label", policy.flow_id)
                # only these stop a case being built and published; the rest of `needs` stop the
                # flow claiming a verdict, and such a set still seeds (see flows/not_ready.py)
                blocks = getattr(policy, "blocks_seeding", None)
                blocks = needs if blocks is None else list(blocks)
            except Exception as ex:                                         # noqa: BLE001
                needs, label = [f"no flow policy: {ex}"], s.flow
                blocks = needs
            state = ("empty" if not s.count else "runnable" if not needs
                     else "blocked" if blocks else "no-verdict")
            out.append({"name": s.name, "flow": s.flow, "phase": s.phase, "purpose": s.purpose,
                        "label": s.label, "flowLabel": label, "count": s.count,
                        "state": state, "needs": needs, "blocks": blocks,
                        "deleted": self._count(s.path / SUPERSEDED)})
        return out

    def archived_sets(self) -> list[dict[str, str]]:
        out = []
        for d in sorted(self.archive_root.glob("*/*/*")):
            if d.is_dir():
                flow, phase = d.parent.parent.name, d.parent.name
                out.append({"id": f"{flow}/{phase}/{d.name}", "flow": flow,
                            "phase": phase, "folder": d.name, "count": self._count(d)})
        return out

    def create_set(self, flow: str, phase: str, purpose: str) -> str:
        flow, phase, purpose = (x.strip().lower() for x in (flow, phase, purpose))
        if flow not in registry.BY_ID:
            raise SpecError(f"unknown flow {flow!r}; the flows are: {', '.join(registry.BY_ID)}")
        for part, what in ((phase, "phase"), (purpose, "purpose")):
            if not PART_RE.match(part):
                raise SpecError(f"{what} must be lower-case letters, digits or '-', not {part!r}")
        path = self.root / flow / phase / purpose
        if path.exists():
            raise SpecError(f"{flow}/{phase}/{purpose} already exists")
        path.mkdir(parents=True)
        return f"{flow}/{phase}/{purpose}"

    def archive_set(self, name: str) -> str:
        s = self.source.set_named(name)
        target = self.archive_root / s.flow / s.phase / f"{s.purpose}-{_stamp()}"
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(s.path), str(target))
        return target.relative_to(self.attic).as_posix()

    def restore_set(self, archived_id: str) -> str:
        src = self._inside(self.archive_root / archived_id, self.archive_root)
        if not src.is_dir() or len(src.relative_to(self.archive_root).parts) != 3:
            raise SpecError(f"{archived_id} is not an archived set")
        flow, phase, folder = src.relative_to(self.archive_root).parts
        purpose = folder.rsplit("-", 1)[0]
        target = self.root / flow / phase / purpose
        if target.exists():
            raise SpecError(f"{target.relative_to(self.root).as_posix()} exists again; "
                            f"rename or archive it first")
        clash = self._ids_in(src) & set(self.source.index())
        if clash:
            raise SpecError(f"restoring would duplicate {len(clash)} case id(s), e.g. "
                            f"{', '.join(sorted(clash)[:4])}")
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(src), str(target))
        return target.relative_to(self.root).as_posix()

    def rename_set(self, name: str, purpose: str) -> str:
        s = self.source.set_named(name)
        purpose = purpose.strip().lower()
        if not PART_RE.match(purpose):
            raise SpecError(f"purpose must be lower-case letters, digits or '-', not {purpose!r}")
        target = s.path.parent / purpose
        if target.exists():
            raise SpecError(f"{s.flow}/{s.phase}/{purpose} already exists")
        shutil.move(str(s.path), str(target))
        return f"{s.flow}/{s.phase}/{purpose}"

    # ------------------------------------------------------------------ identities

    IDENTITY_FIELDS = ("email", "phone", "firstName", "lastName", "dob")

    @property
    def identities_file(self) -> pathlib.Path:
        # in the attic, not the tree: the builder would build any JSON under spec/ as a case
        return self.attic / "identities.json"

    def _identities(self) -> dict[str, dict[str, str]]:
        try:
            return json.loads(self.identities_file.read_text(encoding="utf-8"))
        except (OSError, ValueError):
            return {}

    def identity(self, name: str) -> dict[str, str]:
        """The contact details and name a set is seeded with by default; blanks where none is saved."""
        saved = self._identities().get(name, {})
        return {k: str(saved.get(k, "")) for k in self.IDENTITY_FIELDS}

    def save_identity(self, name: str, values: dict[str, str]) -> dict[str, str]:
        self.source.set_named(name)                          # KeyError -> 404 on an unknown set
        clean = {k: str(values.get(k) or "").strip() for k in self.IDENTITY_FIELDS}
        if clean["dob"] and not re.fullmatch(r"\d{4}[-/]\d{2}[-/]\d{2}", clean["dob"]):
            raise SpecError("date of birth must look like YYYY-MM-DD")
        if clean["email"] and not re.fullmatch(r"[^@\s]+@[^@\s]+\.[^@\s]+", clean["email"]):
            raise SpecError(f"{clean['email']!r} is not an e-mail address")
        every = self._identities()
        if any(clean.values()):
            every[name] = clean
        else:
            every.pop(name, None)
        self.identities_file.parent.mkdir(parents=True, exist_ok=True)
        _write(self.identities_file, every)
        return clean

    # ------------------------------------------------------------------ cases

    def cases(self, set_name: str) -> list[dict[str, Any]]:
        s = self.source.set_named(set_name)
        out = []
        for path in sorted(s.path.glob("*.json")):
            try:
                raw = json.loads(path.read_text(encoding="utf-8"))
            except Exception as ex:                                         # noqa: BLE001
                out.append({"id": path.stem, "error": f"unreadable: {ex}"})
                continue
            out.append(self._row(path.stem, raw))
        return out

    def case(self, case_id: str) -> dict[str, Any]:
        path, set_name = self._locate(case_id)
        raw = json.loads(path.read_text(encoding="utf-8"))
        return {"id": case_id, "set": set_name, "raw": raw,
                "problems": self.problems(raw, set_name),
                "history": [p.name for p in sorted(self._history_dir(path).glob(f"{case_id}--*.json"),
                                                   reverse=True)]}

    def create(self, set_name: str, raw: dict) -> str:
        s = self.source.set_named(set_name)
        case_id = self._new_id(raw)
        self._refuse_duplicate(case_id)
        raw = {**raw, "id": case_id}
        self._parses(raw)
        _write(s.path / f"{case_id}.json", raw)
        return case_id

    def update(self, case_id: str, raw: dict) -> str:
        path, _ = self._locate(case_id)
        new_id = self._new_id({**raw, "id": raw.get("id") or case_id})
        if new_id != case_id:
            self._refuse_duplicate(new_id)
        raw = {**raw, "id": new_id}
        self._parses(raw)
        self._keep_history(path)
        target = path.with_name(f"{new_id}.json")
        _write(target, raw)
        if target != path:
            path.unlink()
        return new_id

    def delete(self, case_id: str) -> str:
        path, _ = self._locate(case_id)
        bin_ = path.parent / SUPERSEDED
        bin_.mkdir(exist_ok=True)
        target = bin_ / path.name
        if target.exists():
            target = bin_ / f"{case_id}--deleted-{_stamp()}.json"
        shutil.move(str(path), str(target))
        return target.name

    def deleted(self, set_name: str) -> list[dict[str, Any]]:
        s = self.source.set_named(set_name)
        out = []
        for p in sorted((s.path / SUPERSEDED).glob("*.json")):
            try:
                raw = json.loads(p.read_text(encoding="utf-8"))
            except Exception:                                               # noqa: BLE001
                raw = {}
            out.append({"file": p.name, **self._row(p.stem.split("--")[0], raw)})
        return out

    def restore(self, set_name: str, file: str) -> str:
        s = self.source.set_named(set_name)
        src = self._inside(s.path / SUPERSEDED / file)
        if not src.is_file():
            raise SpecError(f"{file} is not in {set_name}/{SUPERSEDED}")
        case_id = src.stem.split("--")[0]
        self._refuse_duplicate(case_id)
        shutil.move(str(src), str(s.path / f"{case_id}.json"))
        return case_id

    def revert(self, case_id: str, version: str) -> str:
        path, _ = self._locate(case_id)
        src = self._inside(self._history_dir(path) / version, self.attic)
        if not src.is_file() or not src.name.startswith(f"{case_id}--"):
            raise SpecError(f"no saved version {version} for {case_id}")
        raw = json.loads(src.read_text(encoding="utf-8"))
        self._keep_history(path)
        _write(path, {**raw, "id": case_id})
        return case_id

    def clone(self, case_id: str, new_id: str, set_name: str | None = None) -> str:
        path, here = self._locate(case_id)
        raw = json.loads(path.read_text(encoding="utf-8"))
        return self.create(set_name or here, {**raw, "id": new_id})

    def move(self, case_id: str, set_name: str) -> str:
        path, here = self._locate(case_id)
        if here == set_name:
            return here
        s = self.source.set_named(set_name)
        target = s.path / path.name
        shutil.move(str(path), str(target))
        return s.name

    def import_many(self, set_name: str, items: list[dict], *, overwrite: bool = False) -> dict:
        """Several specs at once. All are checked before any is written, so a bad file in a batch
        leaves the tree as it was rather than half-imported."""
        s = self.source.set_named(set_name)
        index = self.source.index()
        seen, errors, plan = set(), [], []
        for i, raw in enumerate(items, 1):
            try:
                if not isinstance(raw, dict):
                    raise SpecError("not a JSON object")
                case_id = self._new_id(raw)
                if case_id in seen:
                    raise SpecError(f"{case_id} appears twice in this import")
                seen.add(case_id)
                where = index.get(case_id)
                if where and not (overwrite and where == s.name):
                    raise SpecError(f"{case_id} already exists in {where}")
                self._parses({**raw, "id": case_id})
                plan.append((case_id, {**raw, "id": case_id}, where))
            except SpecError as ex:
                errors.append(f"item {i}: {ex}")
        if errors:
            raise SpecError("nothing imported:\n" + "\n".join(errors))
        for case_id, raw, where in plan:
            target = s.path / f"{case_id}.json"
            if where:
                self._keep_history(target)
            _write(target, raw)
        return {"imported": [c for c, _, _ in plan]}

    def export(self, set_name: str) -> list[dict]:
        s = self.source.set_named(set_name)
        return [json.loads(p.read_text(encoding="utf-8")) for p in sorted(s.path.glob("*.json"))]

    # ------------------------------------------------------------------ checks

    def problems(self, raw: dict, set_name: str) -> list[str]:
        """What would stop this case from being seeded, in the flow's own words."""
        try:
            scenario = Scenario.parse(raw)
        except Exception as ex:                                             # noqa: BLE001
            return [f"does not parse: {ex}"]
        try:
            return list(registry.for_set(set_name).validate(scenario))
        except Exception as ex:                                             # noqa: BLE001
            return [f"flow check failed: {ex}"]

    # ------------------------------------------------------------------ internals

    @staticmethod
    def _row(case_id: str, raw: dict) -> dict[str, Any]:
        expect = raw.get("expect") or {}
        bookings = raw.get("bookings") if isinstance(raw.get("bookings"), list) else None
        segs = raw.get("segments") or []
        return {
            "id": case_id,
            "family": raw.get("family"),
            "summary": (raw.get("summary") or "")[:240],
            "passengers": len(raw.get("passengers") or []),
            "segments": len(segs),
            "flights": ", ".join(f"{s.get('carrier', '')}{s.get('number', '')}"
                                 for s in segs[:3] if isinstance(s, dict)),
            "bookings": len(bookings) if bookings else 1,
            "regime": expect.get("regime"),
            "eligibility": expect.get("eligibility"),
            "systemCode": expect.get("systemCode"),
            "amount": expect.get("amount"),
            "currency": expect.get("currency"),
            "loyalty": bool(raw.get("loyalty")),
        }

    def _locate(self, case_id: str) -> tuple[pathlib.Path, str]:
        where = self.source.index().get(case_id)
        if not where:
            raise SpecError(f"no case {case_id!r} in the spec tree")
        return self.source.set_named(where).path / f"{case_id}.json", where

    def _refuse_duplicate(self, case_id: str) -> None:
        where = self.source.index().get(case_id)
        if where:
            raise SpecError(f"{case_id} already exists in {where}. One id, one spec.")

    @staticmethod
    def _new_id(raw: dict) -> str:
        case_id = str(raw.get("id") or "").strip()
        if not ID_RE.match(case_id):
            raise SpecError(f"case id must be letters, digits, '_', '-' or '.', not {case_id!r}")
        return case_id

    @staticmethod
    def _parses(raw: dict) -> None:
        try:
            Scenario.parse(raw)
        except Exception as ex:                                             # noqa: BLE001
            raise SpecError(f"the spec does not parse: {ex}") from ex

    def _keep_history(self, path: pathlib.Path) -> None:
        if path.exists():
            d = self._history_dir(path)
            d.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, d / f"{path.stem}--{_stamp()}.json")

    def _inside(self, path: pathlib.Path, base: pathlib.Path | None = None) -> pathlib.Path:
        base = (base or self.root).resolve()
        resolved = path.resolve()
        if base not in resolved.parents:
            raise SpecError("path is outside the folder it belongs in")
        return resolved

    @staticmethod
    def _count(d: pathlib.Path) -> int:
        return len(list(d.glob("*.json"))) if d.is_dir() else 0

    @staticmethod
    def _ids_in(d: pathlib.Path) -> set[str]:
        return {p.stem for p in d.glob("*.json")}
