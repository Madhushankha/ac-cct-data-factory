# ui/ — the seeding UI

A local web app over the spec tree and the CLI. Everything the CLI does, plus editing the data.

```
pip install -r ui/requirements.txt      # once: fastapi, uvicorn, pyyaml
python -m ui                            # http://127.0.0.1:8770, opens a browser tab
```

It listens on 127.0.0.1 only and acts with this machine's AWS profile and Kafka access.

## What it does

| Page | |
|---|---|
| Dashboard | flows and sets with their state, running and recent jobs, environment check, offline tests |
| Sets & cases | create, rename and archive sets; search every case; per set: filter, which cases already have a booking in int/crt/bat, import JSON, export, bulk seed / move / delete |
| Case editor | create, edit (form or raw JSON), clone, move, delete, restore, revert to an earlier save; the flow's own check runs as you type; the linked Jira test beside it |
| Seed | every `plan` / `seed` option as a form. Plan and dry run send nothing; publishing asks you to type the environment name first |
| Jobs | the command's output live, stop a running job |
| Runs | per environment: verdict counts, per-booking documents, re-judge, gate a published batch, delete and restore a run record |
| Pools | the pools handed to automation, which bookings automation has used, delete and restore |
| Reports | report versions per set, open their files |
| Jira | spec/test coverage per set in both directions, search what the tests say, the loyalty audit |
| Activity | every change made through the UI (`ui/audit.log`) |

## Nothing is destroyed

* A deleted case moves to its set's `_superseded/`, which nothing seeds. Restore puts it back.
* Every save keeps the previous text in `spec-attic/history/`; an archived set moves to
  `spec-attic/archived/`. Both are outside `spec/` on purpose: `builder/apply_patches.py` builds
  every folder under `spec/` except `_superseded`, so anything kept inside the tree would be seeded.
* Deleted runs, pools and reports move to a `_trash/` folder beside them.
* Deleting never reaches an environment. A published booking stays published.

## How it is built

* `server.py` — FastAPI. Reads and edits in-process through `adapters/file_spec_source.py` and
  `ui/specs.py`; anything that talks to an environment runs the real CLI as a job.
* `jobs.py` — `python -m cli ...` in a child process; output in `ui/.jobs/`.
* `specs.py` — the spec tree's write rules. `tests/test_ui_specs.py` checks them.
* `records.py` — runs, pools, reports, the audit log.
* `web/` — React + TypeScript (Vite). `npm run build` writes `ui/static/`, which is committed, so
  running the UI needs Python only. To change the screens: `cd ui/web && npm install && npm run dev`
  with `python -m ui --no-browser` running.
