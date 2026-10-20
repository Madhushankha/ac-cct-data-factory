# vendor — proven code copied in, not re-implemented

Everything a seed run needs is now inside this project. `python -m cli doctor` passes, and a full
build of a booking works, with no other checkout present on the machine.

What is here was **copied, not rewritten**. That distinction is the whole point: identity
reservation, the Kafka publish, the loyalty/AC-Wallet chain and the `/qa builder` are where the hard
lessons live, and two *implementations* of them is exactly how the agentic-qa seeder and the
uat-scenarios kit ended up producing results nobody could compare — one pinning a verdict while the
other computed it. A copy keeps one implementation; it only risks going stale.

## What came from where

| here | copied from | what it gives us |
|---|---|---|
| `agentic-qa/aqa/workflows/seed/` (12 modules, 179 KB) | `agentic-qa-latest/cct-cascade/agentic-qa` | `env` (brokers, topics, contact defaults), `publish` (the producer), `profile` (the whole AC Wallet / Aeroplan chain), `identity` (surname minting and reservation), `airports`, and the modules those import |
| `agentic-qa/.../fixtures/feeds/` (6 files, 48 KB) | same | the Gigya and iFly payload templates `profile.py` renders from — copied verbatim from real INT/UAT messages, never invented |
| `qa-builder/` (7 modules, ~1 MB) | `bravo-2026-08-30/cct-cascade/tools/qa-scenarios/service` | the `/qa builder`: it rewrites one of five anonymised production histories into a scenario, which is what makes the engine actually assess the booking |
| `qa-builder/builder.py`, `playbook.py` | the same repo at **`origin/claude/qa-builder-rebooking-shapes-20261015`** (PR #401), NOT the checked-out branch | `step_customer_rebooking`, without which a voluntary rebooking raises `IndexError` in the builder |

Copied on **2026-10-18**; `builder.py` and `playbook.py` re-taken on **2026-10-19** from PR #401.

**Those two files come from an unmerged branch.** `spec_to_build.py` line 19 and the kit's
`INSTRUCTIONS.md` step 2 both require it: the planner emits a `customer_rebooking` step for a
voluntary rebooking, and only that branch implements it. The cascade working tree is on
`claude/uat-rules-20261015` (PR #400, the rules branch), whose builder has no such step -- four
cases (FD_TC_006, 007, 010, 104) failed with `IndexError: list index out of range` from
`builder.py:659` until these were taken from PR #401. The previous copies are kept in
`qa-builder/_pr400-backup/` for comparison. When PR #401 merges, re-copy from the merged branch and
delete the backup.

## What was deliberately left out

* **`lookup-tables.json` (40 MB)** — TripTracer's rule lookups. Only `builder/gate_compare.py` reads
  it, and this project judges with `flows/` instead, so it would be 40 MB serving nothing. If
  `gate_compare.py` is ever needed, point `LOOKUP_TABLES` at the cascade checkout.
* **agentic-qa's other fixtures** (928 files: `fd-uat`, `fd-sit`, `baggage-sit`, `soc-sit`,
  `baggage-uat`, `fd-automation`) — the old seed data, superseded by `spec/`. Only
  `tools/import_po.py` ever read them, and the 27 PO specs it produced are already in the tree.
* **the uat-scenarios kit** — its scripts are in `builder/`, its seed pool in
  `builder/seed-pool/bookings/`, its 343 specs in `spec/` and its run reports in `reports/`. Nothing
  reads the kit; `doctor` reports it as optional.

## Refreshing a copy

The environment variables still win, so the original can be used without touching these files:

```bash
AQA_SEED_AGENTIC_QA=/path/to/agentic-qa  python -m cli plan fd/uat/automation   # test against it
QA_BUILDER_DIR=/path/to/cascade/tools/qa-scenarios/service  python -m cli ...   # or just the builder
```

That is the intended workflow for a change: run against the real checkout first, then copy the file
in and note the date above. `core/paths.agentic_qa()` and `core/paths.qa_builder()` prefer the
vendored copy and fall back to the variable, so nothing here is load-bearing for *where* code comes
from — only for whether another checkout has to exist.

## The one thing a copy costs

A vendored file does not know its original changed. Nothing in this repository can detect that, so
it is worth re-copying when the upstream work touches the publisher, the loyalty chain or the
builder. The modules here are small (179 KB of Python) precisely so that re-copying is cheap and a
diff is readable.
