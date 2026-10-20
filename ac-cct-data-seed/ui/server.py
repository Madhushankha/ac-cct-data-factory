"""The HTTP API behind the seeding UI, and the built web app it serves.

It listens on 127.0.0.1 only: this is a tool for the person at this machine, using that person's
AWS profile and Kafka access, and it is not meant to be reachable from anywhere else.

Reading and editing the spec tree happen here, in-process. Anything that talks to an environment
(plan, seed, gate, judge, doctor) runs as a job: the real CLI in a child process. See `jobs.py`.
"""
from __future__ import annotations

import json
import pathlib
import re
from typing import Any, Literal

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import FileResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field

from adapters.file_spec_source import FileSpecSource
from adapters.jira_docs import FileTestDocs
from core import paths
from flows import registry
from ui import records
from ui.jobs import JobManager
from ui.specs import SpecError, SpecStore

STATIC = pathlib.Path(__file__).resolve().parent / "static"
Env = Literal["int", "crt", "bat"]

app = FastAPI(title="ac-cct-data-seed", docs_url="/api/docs", openapi_url="/api/openapi.json")
specs = SpecStore()
jobs = JobManager()


@app.exception_handler(SpecError)
@app.exception_handler(records.RecordError)
async def _refused(_: Request, ex: Exception) -> JSONResponse:
    return JSONResponse({"detail": str(ex)}, status_code=400)


@app.exception_handler(KeyError)
async def _missing(_: Request, ex: KeyError) -> JSONResponse:
    return JSONResponse({"detail": str(ex.args[0]) if ex.args else "not found"}, status_code=404)


# =========================================================================== overview

@app.get("/api/overview")
def overview() -> dict[str, Any]:
    sets = specs.sets()
    return {
        "root": str(paths.ROOT),
        "sets": sets,
        "flows": _flows(),
        "totals": {"sets": len(sets), "cases": sum(s["count"] for s in sets),
                   "runnable": sum(1 for s in sets if s["state"] == "runnable")},
        "running": [_job(j) for j in jobs.running()],
        "recentJobs": [_job(j) for j in jobs.list(8)],
        "pools": len(records.pools()),
    }


@app.get("/api/flows")
def flows() -> list[dict[str, Any]]:
    return _flows()


def _flows() -> list[dict[str, Any]]:
    return [{"id": p.flow_id, "label": getattr(p, "label", p.flow_id),
             "sections": [p.section, *getattr(p, "also", ())], "lanes": list(p.lanes),
             "needs": list(p.needs), "ready": not p.needs} for p in registry.POLICIES]


# =========================================================================== sets

class NewSet(BaseModel):
    flow: str
    phase: str
    purpose: str


class RenameSet(BaseModel):
    purpose: str


@app.get("/api/sets")
def list_sets() -> dict[str, Any]:
    return {"sets": specs.sets(), "archived": specs.archived_sets()}


@app.post("/api/sets")
def create_set(body: NewSet) -> dict[str, str]:
    name = specs.create_set(body.flow, body.phase, body.purpose)
    records.audit("set.create", set=name)
    return {"name": name}


@app.post("/api/sets/{flow}/{phase}/{purpose}/rename")
def rename_set(flow: str, phase: str, purpose: str, body: RenameSet) -> dict[str, str]:
    name = specs.rename_set(f"{flow}/{phase}/{purpose}", body.purpose)
    records.audit("set.rename", set=f"{flow}/{phase}/{purpose}", to=name)
    return {"name": name}


@app.delete("/api/sets/{flow}/{phase}/{purpose}")
def archive_set(flow: str, phase: str, purpose: str) -> dict[str, str]:
    where = specs.archive_set(f"{flow}/{phase}/{purpose}")
    records.audit("set.archive", set=f"{flow}/{phase}/{purpose}", to=where)
    return {"archived": where}


class RestoreSet(BaseModel):
    id: str


@app.post("/api/sets/restore")
def restore_set(body: RestoreSet) -> dict[str, str]:
    name = specs.restore_set(body.id)
    records.audit("set.restore", set=name)
    return {"name": name}


# =========================================================================== cases

class CaseBody(BaseModel):
    raw: dict[str, Any]


class CloneBody(BaseModel):
    newId: str
    set: str | None = None


class MoveBody(BaseModel):
    set: str


class ImportBody(BaseModel):
    items: list[Any]
    overwrite: bool = False


class RestoreCase(BaseModel):
    file: str


class RevertBody(BaseModel):
    version: str


def _set(flow: str, phase: str, purpose: str) -> str:
    return f"{flow}/{phase}/{purpose}"


@app.get("/api/sets/{flow}/{phase}/{purpose}/cases")
def list_cases(flow: str, phase: str, purpose: str, env: Env = "int") -> dict[str, Any]:
    name = _set(flow, phase, purpose)
    rows = specs.cases(name)
    done = records.seeded(env)
    for r in rows:
        r["seeded"] = done.get(r["id"])
    return {"set": name, "cases": rows}


@app.post("/api/sets/{flow}/{phase}/{purpose}/cases")
def create_case(flow: str, phase: str, purpose: str, body: CaseBody) -> dict[str, str]:
    case_id = specs.create(_set(flow, phase, purpose), body.raw)
    records.audit("case.create", case=case_id, set=_set(flow, phase, purpose))
    return {"id": case_id}


@app.get("/api/sets/{flow}/{phase}/{purpose}/deleted")
def deleted_cases(flow: str, phase: str, purpose: str) -> list[dict[str, Any]]:
    return specs.deleted(_set(flow, phase, purpose))


@app.post("/api/sets/{flow}/{phase}/{purpose}/restore")
def restore_case(flow: str, phase: str, purpose: str, body: RestoreCase) -> dict[str, str]:
    case_id = specs.restore(_set(flow, phase, purpose), body.file)
    records.audit("case.restore", case=case_id, set=_set(flow, phase, purpose))
    return {"id": case_id}


@app.post("/api/sets/{flow}/{phase}/{purpose}/import")
def import_cases(flow: str, phase: str, purpose: str, body: ImportBody) -> dict[str, Any]:
    items: list[Any] = []
    for item in body.items:
        # one file may hold a single spec or a list of them
        items.extend(item if isinstance(item, list) else [item])
    out = specs.import_many(_set(flow, phase, purpose), items, overwrite=body.overwrite)
    records.audit("case.import", set=_set(flow, phase, purpose), cases=out["imported"])
    return out


@app.get("/api/sets/{flow}/{phase}/{purpose}/export")
def export_cases(flow: str, phase: str, purpose: str) -> JSONResponse:
    name = _set(flow, phase, purpose)
    return JSONResponse(specs.export(name), headers={
        "Content-Disposition": f'attachment; filename="{name.replace("/", "-")}.json"'})


@app.get("/api/cases/{case_id}")
def get_case(case_id: str) -> dict[str, Any]:
    out = specs.case(case_id)
    doc = FileTestDocs().doc(case_id.split("#")[0])
    out["jira"] = _doc(doc) if doc else None
    out["seeded"] = {env: records.seeded(env).get(case_id) for env in records.ENVIRONMENTS}
    return out


@app.put("/api/cases/{case_id}")
def update_case(case_id: str, body: CaseBody) -> dict[str, str]:
    new_id = specs.update(case_id, body.raw)
    records.audit("case.update", case=case_id, **({"renamed": new_id} if new_id != case_id else {}))
    return {"id": new_id}


@app.delete("/api/cases/{case_id}")
def delete_case(case_id: str) -> dict[str, str]:
    where = specs.delete(case_id)
    records.audit("case.delete", case=case_id, kept_as=where)
    return {"deleted": case_id, "keptAs": where}


@app.post("/api/cases/{case_id}/clone")
def clone_case(case_id: str, body: CloneBody) -> dict[str, str]:
    new_id = specs.clone(case_id, body.newId, body.set)
    records.audit("case.clone", case=case_id, to=new_id)
    return {"id": new_id}


@app.post("/api/cases/{case_id}/move")
def move_case(case_id: str, body: MoveBody) -> dict[str, str]:
    where = specs.move(case_id, body.set)
    records.audit("case.move", case=case_id, to=where)
    return {"set": where}


@app.post("/api/cases/{case_id}/revert")
def revert_case(case_id: str, body: RevertBody) -> dict[str, str]:
    specs.revert(case_id, body.version)
    records.audit("case.revert", case=case_id, version=body.version)
    return {"id": case_id}


@app.post("/api/validate")
def validate(body: dict[str, Any]) -> dict[str, Any]:
    raw, set_name = body.get("raw") or {}, body.get("set") or ""
    return {"problems": specs.problems(raw, set_name) if set_name else []}


@app.get("/api/search")
def search(q: str) -> list[dict[str, Any]]:
    """Case ids and summaries across every set."""
    q = q.strip().lower()
    out = []
    if not q:
        return out
    for s in specs.sets():
        for row in specs.cases(s["name"]):
            if q in row["id"].lower() or q in (row.get("summary") or "").lower():
                out.append({**row, "set": s["name"]})
                if len(out) >= 100:
                    return out
    return out


# =========================================================================== jira

def _doc(d) -> dict[str, Any]:
    return {k: getattr(d, k, None) for k in (
        "case_id", "key", "status", "url", "title", "goal", "description",
        "prerequisite_items", "synced_at", "damaged_characters")}


@app.get("/api/jira/coverage")
def jira_coverage() -> list[dict[str, Any]]:
    docs, src = FileTestDocs(), FileSpecSource()
    names = sorted(set(docs.sets()) | {s.name for s in src.describe()})
    out = []
    for name in names:
        try:
            ids = tuple(s.case_id.split("#")[0] for s in src.scenarios(name))
        except KeyError:
            ids = ()
        cov = docs.coverage(name, ids)
        out.append({"set": name, "specs": len(cov.specs), "docs": len(cov.docs),
                    "aligned": cov.aligned, "missingDocs": list(cov.missing_docs),
                    "missingSpecs": list(cov.missing_specs),
                    "duplicates": list(cov.duplicate_ids)})
    return out


@app.get("/api/jira/search")
def jira_search(q: str, set: str = "") -> list[dict[str, Any]]:
    found = FileTestDocs().search(q, set or None)
    return [_doc(d) for d in found[:200]]


# =========================================================================== jobs

_DOB = re.compile(r"^\d{4}[-/]\d{2}[-/]\d{2}$")


class Selection(BaseModel):
    set: str
    env: Env = "int"
    limit: int = Field(0, ge=0)
    only: list[str] = []
    part: str = ""
    skipSeeded: bool = False
    label: str = ""
    runDay: str = ""
    readBatch: int = Field(100, ge=1, le=1000)


class SeedRequest(Selection):
    go: bool = False
    confirm: str = ""
    batchSize: int = Field(0, ge=0)
    settle: int = Field(90, ge=0, le=900)
    email: str = ""
    phone: str = ""
    firstName: str = ""
    lastName: str = ""
    dob: str = ""
    wallet: bool = False
    pool: bool = False
    uniqueName: bool = False


def _selection_args(r: Selection) -> list[str]:
    FileSpecSource().set_named(r.set)                       # 404 on an unknown set, before a job
    a = [r.set, "--env", r.env, "--read-batch", str(r.readBatch)]
    if r.limit:
        a += ["--limit", str(r.limit)]
    if r.only:
        a += ["--only", ",".join(c.strip() for c in r.only if c.strip())]
    if r.part:
        if not re.fullmatch(r"\d+/\d+", r.part):
            raise SpecError("part must look like 2/3")
        a += ["--part", r.part]
    if r.skipSeeded:
        a.append("--skip-seeded")
    if r.label:
        if not re.fullmatch(r"[A-Za-z0-9_.\-]{1,80}", r.label):
            raise SpecError("label must be letters, digits, '_', '-' or '.'")
        a += ["--label", r.label]
    if r.runDay:
        if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", r.runDay):
            raise SpecError("run day must be YYYY-MM-DD")
        a += ["--run-day", r.runDay]
    return a


@app.post("/api/jobs/plan")
def job_plan(body: Selection) -> dict[str, Any]:
    job = jobs.start("plan", f"plan {body.set} on {body.env}", ["plan", *_selection_args(body)],
                     params=body.model_dump())
    records.audit("job.plan", job=job.id, set=body.set, env=body.env)
    return _job(job)


@app.post("/api/jobs/seed")
def job_seed(body: SeedRequest) -> dict[str, Any]:
    a = ["seed", *_selection_args(body), "--settle", str(body.settle)]
    if body.go:
        # publishing writes to topics other services read; the form asks the person to type the
        # environment, and the server checks it, so a stray click cannot publish
        if body.confirm.strip().lower() != body.env:
            raise SpecError(f"to publish, type the environment name ({body.env}) to confirm")
        a.append("--go")
    if body.batchSize:
        a += ["--batch-size", str(body.batchSize)]
    for flag, value in (("--email", body.email), ("--phone", body.phone),
                        ("--first-name", body.firstName), ("--last-name", body.lastName)):
        if value.strip():
            a += [flag, value.strip()]
    if body.dob.strip():
        if not _DOB.match(body.dob.strip()):
            raise SpecError("date of birth must be YYYY-MM-DD or YYYY/MM/DD")
        a += ["--dob", body.dob.strip()]
    for flag, on in (("--wallet", body.wallet), ("--pool", body.pool),
                     ("--unique-name", body.uniqueName)):
        if on:
            a.append(flag)
    title = f"{'seed' if body.go else 'dry-run seed'} {body.set} on {body.env}"
    job = jobs.start("seed", title, a, publishes=body.go, params=body.model_dump(exclude={"confirm"}))
    records.audit("job.seed", job=job.id, set=body.set, env=body.env, publish=body.go)
    return _job(job)


class GateRequest(BaseModel):
    batch: str
    label: str
    env: Env = "int"
    flow: str = "fd"
    readBatch: int = Field(100, ge=1, le=1000)


@app.post("/api/jobs/gate")
def job_gate(body: GateRequest) -> dict[str, Any]:
    batch = (paths.ROOT / body.batch).resolve()
    if paths.ROOT.resolve() not in batch.parents or not (batch / "manifest.json").exists():
        raise SpecError("batch must be a folder inside this project that holds manifest.json")
    if not re.fullmatch(r"[A-Za-z0-9_.\-]{1,80}", body.label):
        raise SpecError("label must be letters, digits, '_', '-' or '.'")
    registry.get(body.flow)
    job = jobs.start("gate", f"gate {body.label} on {body.env}",
                     ["gate", str(batch), "--label", body.label, "--env", body.env,
                      "--flow", body.flow, "--read-batch", str(body.readBatch)],
                     params=body.model_dump())
    records.audit("job.gate", job=job.id, batch=body.batch, env=body.env)
    return _job(job)


class JudgeRequest(BaseModel):
    run: str
    env: Env = "int"
    flow: str = "fd"
    write: bool = False


@app.post("/api/jobs/judge")
def job_judge(body: JudgeRequest) -> dict[str, Any]:
    if not (paths.RUNS / body.env / body.run).is_dir():
        raise SpecError(f"no run {body.run} in {body.env}")
    registry.get(body.flow)
    a = ["judge", body.run, "--env", body.env, "--flow", body.flow]
    if body.write:
        a.append("--write")
    job = jobs.start("judge", f"judge {body.run} on {body.env}", a, params=body.model_dump())
    records.audit("job.judge", job=job.id, run=body.run, env=body.env, write=body.write)
    return _job(job)


class EnvOnly(BaseModel):
    env: Env = "int"


@app.post("/api/jobs/doctor")
def job_doctor(body: EnvOnly) -> dict[str, Any]:
    return _job(jobs.start("doctor", f"doctor on {body.env}", ["doctor", "--env", body.env]))


@app.post("/api/jobs/tests")
def job_tests() -> dict[str, Any]:
    return _job(jobs.start("tests", "offline test suite", ["tests/run_all.py"], module=""))


@app.post("/api/jobs/jira-audit")
def job_jira_audit(body: dict[str, Any]) -> dict[str, Any]:
    a = ["jira", "--audit"]
    if body.get("set"):
        FileSpecSource().set_named(body["set"])
        a += ["--set", body["set"]]
    return _job(jobs.start("jira", "Jira loyalty audit", a))


@app.get("/api/jobs")
def list_jobs() -> list[dict[str, Any]]:
    return [_job(j) for j in jobs.list()]


@app.get("/api/jobs/{job_id}")
def get_job(job_id: str, offset: int = 0) -> dict[str, Any]:
    job = jobs.get(job_id)
    if not job:
        raise HTTPException(404, f"no job {job_id}")
    text, end = jobs.log(job_id, offset)
    return {**_job(job), "log": text, "offset": end}


@app.post("/api/jobs/{job_id}/cancel")
def cancel_job(job_id: str) -> dict[str, Any]:
    ok = jobs.cancel(job_id)
    records.audit("job.cancel", job=job_id, stopped=ok)
    return {"stopped": ok}


@app.delete("/api/jobs/{job_id}")
def delete_job(job_id: str) -> dict[str, Any]:
    if not jobs.delete(job_id):
        raise SpecError("a running job cannot be removed; stop it first")
    return {"deleted": job_id}


def _job(j) -> dict[str, Any]:
    return {"id": j.id, "kind": j.kind, "title": j.title, "status": j.status,
            "started": j.started, "ended": j.ended, "exitCode": j.exit_code,
            "publishes": j.publishes, "command": " ".join(j.argv[1:]), "params": j.params}


# =========================================================================== runs

@app.get("/api/runs/{env}")
def list_runs(env: Env) -> dict[str, Any]:
    return {"runs": records.runs(env), "trash": records.trashed_runs(env),
            "seeded": len(records.seeded(env))}


@app.get("/api/runs/{env}/{label}")
def run_detail(env: Env, label: str) -> dict[str, Any]:
    return records.run_detail(env, label)


@app.get("/api/runs/{env}/{label}/files/{name}")
def run_file(env: Env, label: str, name: str) -> dict:
    return records.run_file(env, label, name)


@app.delete("/api/runs/{env}/{label}")
def trash_run(env: Env, label: str) -> dict[str, str]:
    where = records.trash_run(env, label)
    records.audit("run.delete", env=env, run=label, kept_as=where)
    return {"keptAs": where}


@app.post("/api/runs/{env}/restore")
def restore_run(env: Env, body: RestoreCase) -> dict[str, str]:
    name = records.restore_run(env, body.file)
    records.audit("run.restore", env=env, run=name)
    return {"label": name}


@app.get("/api/seeded/{env}")
def seeded(env: Env) -> dict[str, Any]:
    return records.seeded(env)


# =========================================================================== pools

@app.get("/api/pools")
def list_pools() -> dict[str, Any]:
    return {"dir": str(records.pool_dir()), "pools": records.pools(),
            "trash": records.trashed_pools()}


@app.get("/api/pools/{file}")
def pool_detail(file: str) -> dict[str, Any]:
    return records.pool_detail(file)


@app.delete("/api/pools/{file}")
def trash_pool(file: str) -> dict[str, str]:
    where = records.trash_pool(file)
    records.audit("pool.delete", pool=file, kept_as=where)
    return {"keptAs": where}


@app.post("/api/pools/restore")
def restore_pool(body: RestoreCase) -> dict[str, str]:
    name = records.restore_pool(body.file)
    records.audit("pool.restore", pool=name)
    return {"file": name}


# =========================================================================== reports

@app.get("/api/reports")
def list_reports() -> list[dict[str, Any]]:
    return records.reports()


@app.get("/api/reports/file/{rel:path}")
def report_file(rel: str) -> FileResponse:
    return FileResponse(records.report_file(rel))


@app.delete("/api/reports/{rel:path}")
def trash_report(rel: str) -> dict[str, str]:
    where = records.trash_report(rel)
    records.audit("report.delete", report=rel, kept_as=where)
    return {"keptAs": where}


# =========================================================================== audit

@app.get("/api/audit")
def audit() -> list[dict]:
    return records.audit_tail()


# =========================================================================== the web app

if (STATIC / "assets").is_dir():
    app.mount("/assets", StaticFiles(directory=STATIC / "assets"), name="assets")


@app.get("/{rest:path}", include_in_schema=False)
def spa(rest: str):
    if rest.startswith("api/"):
        raise HTTPException(404)
    index = STATIC / "index.html"
    if not index.exists():
        return JSONResponse({"detail": "the web app is not built: cd ui/web && npm install && "
                                       "npm run build"}, status_code=503)
    return FileResponse(index)
