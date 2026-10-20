"""What runs left behind: run records, built batches, report pages and the pools handed to automation.

All of it is local files. Deleting here never deletes anything outside this machine: a booking that
was published stays in the environment whatever happens to its record, so a removed run only stops
the UI and `--skip-seeded` from knowing about it. That is why nothing is deleted outright: a run,
pool or report goes to a `_trash/` folder next to it, and can be put back.
"""
from __future__ import annotations

import datetime as _dt
import json
import os
import pathlib
import re
import shutil
from typing import Any

import yaml

from core import paths

ENVIRONMENTS = ("int", "crt", "bat")
TRASH = "_trash"
REPORTS = paths.ROOT / "reports"


class RecordError(ValueError):
    pass


def _mtime(p: pathlib.Path) -> str:
    return _dt.datetime.fromtimestamp(p.stat().st_mtime, _dt.timezone.utc).isoformat(
        timespec="seconds")


def _stamp() -> str:
    return _dt.datetime.now(_dt.timezone.utc).strftime("%Y%m%dT%H%M%S")


def _inside(base: pathlib.Path, rel: str) -> pathlib.Path:
    p = (base / rel).resolve()
    if p != base.resolve() and base.resolve() not in p.parents:
        raise RecordError("path is outside the folder")
    return p


def _trash(path: pathlib.Path, base: pathlib.Path) -> str:
    bin_ = base / TRASH
    bin_.mkdir(exist_ok=True)
    target = bin_ / f"{path.name}--{_stamp()}"
    shutil.move(str(path), str(target))
    return target.name


def _untrash(base: pathlib.Path, name: str) -> str:
    src = _inside(base / TRASH, name)
    if not src.exists():
        raise RecordError(f"{name} is not in the trash")
    original = name.rsplit("--", 1)[0]
    target = base / original
    if target.exists():
        raise RecordError(f"{original} exists again; remove it first")
    shutil.move(str(src), str(target))
    return original


# ---------------------------------------------------------------------- runs

def runs(env: str) -> list[dict[str, Any]]:
    base = paths.RUNS / env
    if not base.is_dir():
        return []
    out = []
    for d in base.iterdir():
        if not d.is_dir() or d.name.startswith("_"):
            continue
        summary = d / "_summary.json"
        info: dict[str, Any] = {"label": d.name, "updated": _mtime(d),
                                "kind": "build" if d.name.startswith("build-") else "run"}
        if summary.exists():
            try:
                s = json.loads(summary.read_text(encoding="utf-8"))
                info.update({k: s.get(k) for k in ("bookings", "agree", "disagree",
                                                   "not_judged", "engine", "release",
                                                   "written_at")})
            except Exception:                                               # noqa: BLE001
                pass
        if info["kind"] == "build":
            info["manifests"] = sum(1 for _ in d.rglob("manifest.json"))
        else:
            info["records"] = sum(1 for p in d.glob("*.json") if not p.name.startswith("_"))
        out.append(info)
    return sorted(out, key=lambda r: r["updated"], reverse=True)


def run_detail(env: str, label: str) -> dict[str, Any]:
    d = _inside(paths.RUNS / env, label)
    if not d.is_dir():
        raise RecordError(f"no run {label} in {env}")
    summary = {}
    if (d / "_summary.json").exists():
        summary = json.loads((d / "_summary.json").read_text(encoding="utf-8"))
    cases = []
    for p in sorted(d.glob("*.json")):
        if p.name.startswith("_"):
            continue
        try:
            row = json.loads(p.read_text(encoding="utf-8"))
        except Exception:                                                   # noqa: BLE001
            continue
        if not isinstance(row, dict):
            continue
        checks = row.get("checks") or []
        cases.append({
            "case": row.get("case") or p.stem, "locator": row.get("locator"),
            "pnrId": row.get("pnrId"), "flight": row.get("flight"), "route": row.get("route"),
            "agrees": row.get("agrees"),
            "disagreements": [c.get("name") for c in checks
                              if isinstance(c, dict) and c.get("disagrees")],
            "file": p.name})
    batches = []
    for m in sorted(d.rglob("manifest.json")):
        try:
            rows = json.loads(m.read_text(encoding="utf-8"))
        except Exception:                                                   # noqa: BLE001
            rows = []
        batches.append({"path": m.parent.relative_to(paths.ROOT).as_posix(),
                        "bookings": len(rows) if isinstance(rows, list) else 0,
                        "rows": [{"id": r.get("id"), "pnrId": r.get("pnrId"),
                                  "locator": r.get("locator")}
                                 for r in (rows if isinstance(rows, list) else [])[:500]
                                 if isinstance(r, dict)]})
    return {"label": label, "env": env, "summary": summary, "cases": cases, "batches": batches}


def run_file(env: str, label: str, name: str) -> dict:
    p = _inside(paths.RUNS / env / label, name)
    if not p.is_file():
        raise RecordError(f"no file {name}")
    return json.loads(p.read_text(encoding="utf-8"))


def trash_run(env: str, label: str) -> str:
    d = _inside(paths.RUNS / env, label)
    if not d.is_dir() or label.startswith("_"):
        raise RecordError(f"no run {label} in {env}")
    return _trash(d, paths.RUNS / env)


def trashed_runs(env: str) -> list[str]:
    bin_ = paths.RUNS / env / TRASH
    return sorted((p.name for p in bin_.iterdir()), reverse=True) if bin_.is_dir() else []


def restore_run(env: str, name: str) -> str:
    return _untrash(paths.RUNS / env, name)


def seeded(env: str) -> dict[str, dict]:
    """Every case that has a booking in `env`, the way `seed --skip-seeded` decides it."""
    out: dict[str, dict] = {}
    base = paths.RUNS / env
    if not base.is_dir():
        return out
    for manifest in base.rglob("manifest.json"):
        if TRASH in manifest.parts:
            continue
        try:
            rows = json.loads(manifest.read_text(encoding="utf-8"))
        except Exception:                                                   # noqa: BLE001
            continue
        for r in rows if isinstance(rows, list) else []:
            if isinstance(r, dict) and r.get("pnrId") and r.get("id"):
                cid = str(r["id"]).split("#")[0]
                out[cid] = {"pnrId": r["pnrId"], "locator": r.get("locator"),
                            "run": manifest.relative_to(base).parts[0]}
    return out


# ---------------------------------------------------------------------- pools

def pool_dir() -> pathlib.Path:
    from adapters.pool_file import POOL_DIR
    return POOL_DIR


def _ledger() -> dict:
    p = pool_dir().parent.parent / "state" / "booking-ledger.json"
    try:
        return json.loads(p.read_text(encoding="utf-8"))
    except Exception:                                                       # noqa: BLE001
        return {}


def pools() -> list[dict[str, Any]]:
    d = pool_dir()
    if not d.is_dir():
        return []
    out = []
    for p in sorted(d.glob("*.yaml"), key=lambda p: p.stat().st_mtime, reverse=True):
        try:
            doc = yaml.safe_load(p.read_text(encoding="utf-8")) or {}
        except Exception as ex:                                             # noqa: BLE001
            out.append({"file": p.name, "error": str(ex), "updated": _mtime(p)})
            continue
        for name, pool in (doc.get("pools") or {}).items():
            out.append({"file": p.name, "name": name, "updated": _mtime(p),
                        "dataset": (pool or {}).get("dataset"),
                        "seededAt": (pool or {}).get("seededAt"),
                        "bookings": len((pool or {}).get("bookings") or [])})
    return out


def pool_detail(file: str) -> dict[str, Any]:
    p = _inside(pool_dir(), file)
    if not p.is_file():
        raise RecordError(f"no pool {file}")
    doc = yaml.safe_load(p.read_text(encoding="utf-8")) or {}
    used = _used_locators()
    pools_ = []
    for name, pool in (doc.get("pools") or {}).items():
        rows = [{**b, "used": str(b.get("pnr", "")).upper() in used}
                for b in ((pool or {}).get("bookings") or []) if isinstance(b, dict)]
        pools_.append({"name": name, "dataset": (pool or {}).get("dataset"),
                       "seededAt": (pool or {}).get("seededAt"), "bookings": rows})
    return {"file": file, "pools": pools_}


def _used_locators() -> set[str]:
    """Locators the automation suite has already used, from its booking ledger (best effort: the
    ledger is the suite's own file and its shape belongs to it)."""
    found: set[str] = set()

    def walk(v: Any) -> None:
        if isinstance(v, dict):
            for k, x in v.items():
                if isinstance(k, str) and re.fullmatch(r"[A-Z0-9]{6}", k.upper()):
                    found.add(k.upper())
                walk(x)
        elif isinstance(v, list):
            for x in v:
                walk(x)
        elif isinstance(v, str) and re.fullmatch(r"[A-Z0-9]{6}", v):
            found.add(v)
    walk(_ledger())
    return found


def trash_pool(file: str) -> str:
    p = _inside(pool_dir(), file)
    if not p.is_file():
        raise RecordError(f"no pool {file}")
    return _trash(p, pool_dir())


def trashed_pools() -> list[str]:
    bin_ = pool_dir() / TRASH
    return sorted((p.name for p in bin_.iterdir()), reverse=True) if bin_.is_dir() else []


def restore_pool(name: str) -> str:
    return _untrash(pool_dir(), name)


# ---------------------------------------------------------------------- reports

def reports() -> list[dict[str, Any]]:
    out = []
    if not REPORTS.is_dir():
        return out
    for v in REPORTS.glob("*/*/*/*/v*"):
        if not v.is_dir() or TRASH in v.parts or not re.fullmatch(r"v\d+", v.name):
            continue
        env, flow, phase, purpose = v.relative_to(REPORTS).parts[:4]
        files = sorted(f.relative_to(v).as_posix() for f in v.rglob("*") if f.is_file())
        out.append({"path": v.relative_to(REPORTS).as_posix(), "env": env,
                    "set": f"{flow}/{phase}/{purpose}", "version": int(v.name[1:]),
                    "updated": _mtime(v), "files": files[:200], "fileCount": len(files)})
    return sorted(out, key=lambda r: (r["env"], r["set"], -r["version"]))


def report_file(rel: str) -> pathlib.Path:
    p = _inside(REPORTS, rel)
    if not p.is_file():
        raise RecordError(f"no report file {rel}")
    return p


def trash_report(rel: str) -> str:
    v = _inside(REPORTS, rel)
    if not v.is_dir() or not re.fullmatch(r"v\d+", v.name):
        raise RecordError(f"{rel} is not a report version")
    return _trash(v, v.parent)


# ---------------------------------------------------------------------- audit

AUDIT = pathlib.Path(__file__).resolve().parent / "audit.log"


def audit(action: str, **detail: Any) -> None:
    line = {"at": _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds"),
            "user": os.environ.get("USERNAME") or os.environ.get("USER") or "",
            "action": action, **detail}
    with AUDIT.open("a", encoding="utf-8") as f:
        f.write(json.dumps(line, ensure_ascii=False) + "\n")


def audit_tail(n: int = 200) -> list[dict]:
    if not AUDIT.exists():
        return []
    lines = AUDIT.read_text(encoding="utf-8").splitlines()[-n:]
    out = []
    for line in reversed(lines):
        try:
            out.append(json.loads(line))
        except Exception:                                                   # noqa: BLE001
            pass
    return out
