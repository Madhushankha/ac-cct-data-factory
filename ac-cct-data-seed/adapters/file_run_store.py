"""Where a run's record goes: one folder per run, one file per booking.

Implements `ports.RunStore`.

A run is not data. Nothing in it is a source of truth, and the engine's document is the only part
worth keeping: a verdict is derived, and derived things age. Four comparator fixes landed after one
batch of readings was taken, and a page rebuilt from the stored verdict came out byte-identical to
one written before them -- so the store keeps the DOCUMENT and the judgement is recomputed whenever
anything reads it.

The old seeder kept its runs beside its data and accumulated 344 manifests and 162 MB there, with
nothing to prune them. Here a run folder is named by its label and dated, and `prune` exists.
"""
from __future__ import annotations

import datetime as _dt
import json
import pathlib
import shutil
from dataclasses import asdict, is_dataclass
from typing import Any, Iterable

from core import paths
from domain.models import CaseResult


def _plain(value: Any) -> Any:
    """A dataclass tree as JSON-safe data, keeping the engine's document intact."""
    if is_dataclass(value) and not isinstance(value, type):
        return {k: _plain(v) for k, v in asdict(value).items()}
    if isinstance(value, dict):
        return {k: _plain(v) for k, v in value.items()}
    if isinstance(value, (list, tuple)):
        return [_plain(v) for v in value]
    return value


class FileRunStore:
    """Satisfies `ports.RunStore`."""

    def __init__(self, env: str = "int", label: str | None = None,
                 root: pathlib.Path | None = None) -> None:
        self.env = env
        self.label = label or f"run-{_dt.datetime.now(_dt.timezone.utc).strftime('%m%dT%H%M')}"
        self.root = (root or paths.RUNS) / env / self.label
        self.root.mkdir(parents=True, exist_ok=True)

    # ------------------------------------------------------------ the ports

    def save_case(self, result: CaseResult) -> pathlib.Path:
        """One booking's record: the engine's document, what it saw, and the checks as judged now."""
        path = self.root / f"{result.booking.case_id or result.booking.locator}.json"
        path.write_text(json.dumps({
            "case": result.booking.case_id,
            "locator": result.booking.locator,
            "pnrId": result.booking.pnr_id,
            "flight": result.booking.flight,
            "route": result.booking.route,
            "expected": _plain(result.booking.expectation),
            # what went OUT, beside what the card wants: the only way a later reader can tell a
            # rule question from a booking the engine never received the disruption for
            "published": [_plain(leg) for leg in result.booking.published],
            "engine": {"engine": result.assessment.engine,
                       "release": result.assessment.release,
                       "rulesSha256": result.assessment.rules_sha256},
            "seen": _plain(result.seen),
            # the durable evidence; the judgement below is derived from it
            "document": result.assessment.document,
            "checks": [_plain(c) for c in result.checks],
            "agrees": result.agrees,
            "saved_at": _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds"),
        }, indent=1), encoding="utf-8")
        return path

    def save_summary(self, label: str, results: Iterable[CaseResult]) -> str:
        results = tuple(results)
        agreeing = [r for r in results if r.agrees]
        disagreeing = [r for r in results if r.judged and not r.agrees]
        unjudged = [r for r in results if not r.judged]
        path = self.root / "_summary.json"
        path.write_text(json.dumps({
            "label": label, "env": self.env,
            "written_at": _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds"),
            "bookings": len(results),
            "agree": len(agreeing), "disagree": len(disagreeing), "not_judged": len(unjudged),
            "engine": next((r.assessment.engine for r in results if r.assessment.engine), None),
            "release": next((r.assessment.release for r in results if r.assessment.release), None),
            "disagreeing": [
                {"case": r.booking.case_id, "pnrId": r.booking.pnr_id,
                 "checks": [{"check": c.name, "detail": c.detail} for c in r.disagreements]}
                for r in disagreeing],
            "agreeing": [r.booking.case_id for r in agreeing],
        }, indent=1), encoding="utf-8")
        return str(path)

    # ----------------------------------------------------------- housekeeping

    def documents(self) -> dict[str, dict]:
        """Every booking's engine document in this run, for re-judging without re-reading."""
        out: dict[str, dict] = {}
        for f in sorted(self.root.glob("*.json")):
            if f.name.startswith("_"):
                continue
            row = json.loads(f.read_text(encoding="utf-8"))
            if row.get("pnrId"):
                out[row["pnrId"]] = row
        return out

    def rejudge(self, rows: list[tuple[str, dict, tuple]]) -> int:
        """Replace the stored checks with a fresh judgement of the same documents.

        The document is the evidence and the checks are derived from it, so this rewrites only the
        derivation and leaves the engine's answer untouched. `judged_at` records when, because a
        record whose verdict was produced by a different comparator than its neighbours is worse
        than one that says so.
        """
        by_pnr = {row.get("pnrId"): row for row in (r for _, r, _ in rows)}
        written = 0
        for f in sorted(self.root.glob("*.json")):
            if f.name.startswith("_"):
                continue
            row = json.loads(f.read_text(encoding="utf-8"))
            if row.get("pnrId") not in by_pnr:
                continue
            checks = next(c for p, _, c in rows if p == row["pnrId"])
            claims = [c for c in checks if c.applies and not c.structural]
            row["checks"] = [_plain(c) for c in checks]
            row["agrees"] = bool(claims) and not any(c.disagrees for c in checks)
            row["judged_at"] = _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds")
            f.write_text(json.dumps(row, indent=1), encoding="utf-8")
            written += 1
        return written

    @staticmethod
    def prune(env: str = "int", keep: int = 20, root: pathlib.Path | None = None) -> list[str]:
        """Delete all but the newest `keep` runs for an environment.

        Exists because the old seeder had no such thing and accumulated 162 MB of run manifests in
        its data directory, including one left half-written by a failed run.
        """
        base = (root or paths.RUNS) / env
        if not base.is_dir():
            return []
        runs = sorted((d for d in base.iterdir() if d.is_dir()),
                      key=lambda d: d.stat().st_mtime, reverse=True)
        removed = []
        for d in runs[keep:]:
            shutil.rmtree(d, ignore_errors=True)
            removed.append(d.name)
        return removed
