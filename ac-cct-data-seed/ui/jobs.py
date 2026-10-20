"""Long commands run as jobs: the CLI in a child process, its output kept and streamed.

A seed takes minutes and talks to Kafka and ECS, so the UI does not run it inside the web server.
It runs exactly the command a person would type (`python -m cli seed fd/uat/automation --go ...`),
which keeps one code path for seeding: the CLI's. The UI only builds the argument list from a form,
shows the output as it arrives, and can stop the process.

Every job's command and output are written to `ui/.jobs/<id>.log` and `<id>.json`, so a job that
finished while nobody was looking can still be read, and the list survives a server restart.
"""
from __future__ import annotations

import datetime as _dt
import json
import os
import pathlib
import subprocess
import sys
import threading
import uuid
from dataclasses import asdict, dataclass, field

from core import paths

JOBS_DIR = pathlib.Path(__file__).resolve().parent / ".jobs"

#: exit codes the CLI uses: 0 fine, 2 "ran, and some cases disagree", anything else failed
FINISHED_WITH_FINDINGS = 2


def _now() -> str:
    return _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds")


@dataclass
class Job:
    id: str
    kind: str
    title: str
    argv: list[str]
    started: str
    status: str = "running"              # running | ok | findings | failed | cancelled
    ended: str | None = None
    exit_code: int | None = None
    publishes: bool = False
    params: dict = field(default_factory=dict)

    @property
    def log_path(self) -> pathlib.Path:
        return JOBS_DIR / f"{self.id}.log"

    def save(self) -> None:
        (JOBS_DIR / f"{self.id}.json").write_text(json.dumps(asdict(self), indent=1),
                                                  encoding="utf-8")


class JobManager:
    def __init__(self) -> None:
        JOBS_DIR.mkdir(exist_ok=True)
        self._procs: dict[str, subprocess.Popen] = {}
        self._lock = threading.Lock()
        # a job recorded as running by a server that has since stopped did not finish
        for meta in JOBS_DIR.glob("*.json"):
            job = self._load(meta)
            if job and job.status == "running":
                job.status, job.ended = "failed", job.ended or _now()
                with job.log_path.open("a", encoding="utf-8") as f:
                    f.write("\n[ui] the server stopped while this job was running\n")
                job.save()

    def start(self, kind: str, title: str, cli_args: list[str], *, publishes: bool = False,
              params: dict | None = None, module: str = "cli") -> Job:
        argv = [sys.executable, "-u", "-m", module, *cli_args] if module else \
            [sys.executable, "-u", *cli_args]
        job = Job(id=_dt.datetime.now().strftime("%m%d-%H%M%S-") + uuid.uuid4().hex[:4],
                  kind=kind, title=title, argv=argv, started=_now(), publishes=publishes,
                  params=params or {})
        job.save()
        log = job.log_path.open("w", encoding="utf-8")
        log.write(f"$ {' '.join(_quote(a) for a in argv[1:])}\n\n")
        log.flush()
        env = {**os.environ, "PYTHONIOENCODING": "utf-8", "PYTHONUNBUFFERED": "1"}
        flags = getattr(subprocess, "CREATE_NEW_PROCESS_GROUP", 0)
        proc = subprocess.Popen(argv, cwd=str(paths.ROOT), stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL, env=env,
                                text=True, encoding="utf-8", errors="replace", bufsize=1,
                                creationflags=flags)
        with self._lock:
            self._procs[job.id] = proc
        threading.Thread(target=self._pump, args=(job, proc, log), daemon=True).start()
        return job

    def _pump(self, job: Job, proc: subprocess.Popen, log) -> None:
        try:
            for line in proc.stdout:                                        # type: ignore[union-attr]
                log.write(line)
                log.flush()
            code = proc.wait()
        finally:
            log.close()
        with self._lock:
            self._procs.pop(job.id, None)
        current = self._load(JOBS_DIR / f"{job.id}.json") or job
        if current.status != "cancelled":
            current.status = ("ok" if code == 0 else
                              "findings" if code == FINISHED_WITH_FINDINGS else "failed")
        current.exit_code, current.ended = code, _now()
        current.save()

    def cancel(self, job_id: str) -> bool:
        with self._lock:
            proc = self._procs.get(job_id)
        if not proc:
            return False
        job = self.get(job_id)
        if job:
            job.status = "cancelled"
            job.save()
        with (JOBS_DIR / f"{job_id}.log").open("a", encoding="utf-8") as f:
            f.write("\n[ui] stopped by the user\n")
        proc.terminate()
        try:
            proc.wait(timeout=10)
        except subprocess.TimeoutExpired:
            proc.kill()
        return True

    def get(self, job_id: str) -> Job | None:
        return self._load(JOBS_DIR / f"{job_id}.json")

    def list(self, limit: int = 100) -> list[Job]:
        jobs = [j for j in (self._load(p) for p in JOBS_DIR.glob("*.json")) if j]
        return sorted(jobs, key=lambda j: j.started, reverse=True)[:limit]

    def log(self, job_id: str, offset: int = 0) -> tuple[str, int]:
        path = JOBS_DIR / f"{job_id}.log"
        if not path.exists():
            return "", offset
        with path.open("rb") as f:
            f.seek(offset)
            chunk = f.read()
        return chunk.decode("utf-8", errors="replace"), offset + len(chunk)

    def delete(self, job_id: str) -> bool:
        if job_id in self._procs:
            return False
        found = False
        for suffix in (".json", ".log"):
            p = JOBS_DIR / f"{job_id}{suffix}"
            if p.exists():
                p.unlink()
                found = True
        return found

    def running(self) -> list[Job]:
        return [j for j in self.list() if j.status == "running"]

    @staticmethod
    def _load(path: pathlib.Path) -> Job | None:
        try:
            return Job(**json.loads(path.read_text(encoding="utf-8")))
        except Exception:                                                   # noqa: BLE001
            return None


def _quote(arg: str) -> str:
    return f'"{arg}"' if (" " in arg or not arg) else arg
