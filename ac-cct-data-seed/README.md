# ac-cct-data-seed

Seed data for CCT testing, the code that turns it into bookings an engine will assess, and the
automation that then talks to the product as the customer whose booking it is.

One scenario spec per case, one dataset per flow, one command per run.

```
domain/        values and models that know their own rules. No I/O
ports/         Protocols: what the application needs from the outside
flows/         one policy per flow: which section, what a row is, what agreement means
application/   the use cases, composed from ports only
adapters/      the ports implemented against the kit, Kafka, ECS and the filesystem
cli/           thin entry points: parse, build adapters, call a use case, print
spec/          the data: spec/<flow>/<phase>/<purpose>/<CASE_ID>.json
jira/          what the tests say: the synced Xray snapshot, same layout as spec/
vendor/        proven code copied in, so a seed needs no other checkout
reports/       the run reports, latest version per set
ui/            the seeding UI: python -m ui (see ui/README.md)
builder/       the uat-scenarios scripts and their inputs, vendored
runs/          what happened: per run, per booking, the engine's document kept
catalog/       where each case came from and who states its expectation
tests/         python tests/run_all.py - no network, no AWS, no credential
core/ lanes/ tools/   the previous generation, being retired behind the ports
```

Dependencies point inward: [docs/architecture.md](docs/architecture.md) says what each layer may
import, and `tests/test_layering.py` checks it rather than trusting it. The datasets have their own
rules, in [spec/README.md](spec/README.md), and what the tests actually say is in
[jira/README.md](jira/README.md) — Jira is the source of truth for them, and a case id joins the
two trees.

## Two halves, one handoff

Seeding is half a test. Something then has to talk to the product as a customer whose booking
this is, and that is `../ac-cct-data-automation/playwright-baggage` — the Ask AC chat, driven end
to end in a real browser, with the OTP broker, transcripts, screenshots and a Markdown report. It
lived in `automation/` here until the split into ac-cct-data-factory; `core/paths.automation()`
finds the sibling, and `AQA_SEED_AUTOMATION` points somewhere else.

To work on the data without the command line, run `python -m ui`: sets and cases with create,
edit, clone, move, delete and restore, and every seed option as a form. See
[ui/README.md](ui/README.md).

The two meet in **one file**, not in a path walking up out of either project:

```
python -m cli seed <set> --go --pool
   -> ../ac-cct-data-automation/playwright-baggage/data/pools/<run>.yaml
        pnr, first, last, flight, landed, caseId, aeroplan, tags[]
   -> a scenario picks by STATE, never by locator:
        booking: { pool: any, pick: next-unused, need: [eligible, appr] }
```

The suite already merged `data/pools/*.yaml` and documented them as "generated pools, e.g. from
an agentic-qa seed dataset", so this is the seam it was built for. Its other route parses the
seed *report* HTML with regexes to recover the PNRs and re-derive the tags from prose
(`/counts as lost/i.test(what)`); that still reads the 14 historical reports, but a markup change
breaks it silently and a lost tag does not fail — it makes a scenario pick the wrong booking.

Tags come from the flow policy, because only the flow knows what state its cases are in.
AC Wallet adds `wallet`, `wallet-frozen-l2`, `tier-e50k` and the member's real Aeroplan number:
see [docs/ac-wallet.md](docs/ac-wallet.md).

## Why the structure is this shape

**Six assessment sections, four flows.** The engine's document carries
`compensationEligibility` (FD), `socFlightEligibility` (SOC), `baggageClaimEligibility` with
`interimExpensesEligibility` (baggage — interim expenses are the essentials bought while the bag is
missing, so the bag's delay decides them), and `baggageRefundEligibility` with
`seatFeeRefundEligibility` (ancillary, both keyed by EMD). Each needs its own fixtures, its own publish lane and its own idea
of a row — FD asks one question of a booking, SOC asks per passenger *per segment*, baggage per bag,
ancillary per EMD. A comparator built for one shape passes a document holding the right number of
wrong rows for another, so `flows/` holds one policy per flow against `ports.FlowPolicy`, and
`flows/registry.py` refuses at import if two flows claim one section or none does.

**Everything else is shared, deliberately.** Identity reservation, the booking publish, the runner,
the evidence, and the booking-level checks do not care which flow is under test. Two
implementations of those is how the agentic-qa seeder and the uat-scenarios kit ended up unable to
compare results — one wrote the verdict it then read back, the other let the engine compute it.

## The data, per flow

Every dataset lives in one tree, `spec/<flow>/<phase>/<purpose>/`, described in
[spec/README.md](spec/README.md). `python -m cli sets` prints what it holds; nothing registers a
set, so adding one is creating a folder.

| set | cases | expectation stated by | status |
|---|---|---|---|
| `fd/uat/automation` | 266 | Jira CHAI-31809, via the kit's specs + `fixes-*.json` | 265 seeded on INT, 262 judged: 215 agree, 46 disagree, 1 not judged |
| `fd/uat/po` | 27 | the dataset manifest that seeded them | imported; binding in `catalog/fd-po.json` |
| `fd/sit/po` | 0 of 132 | the SIT fixtures | not imported |
| `soc/uat/automation` | 77 | the kit's specs | not seeded: the SOC policy cannot claim a verdict yet |
| `soc/uat/po` | 0 | — | 5 of 17 reviewed cards are seedable |
| `baggage/uat/automation` | 0 | — | needs a bag-event lane first |
| `anc/uat/automation` | 0 | — | needs an EMD lane first |

A set whose expected verdict nobody has stated must not be able to report a pass, so the flow policy
refuses a scenario with no `expect.eligibility` before the builder runs. That is why the 41
table-derived cases have no set: their source gives inputs only, and nobody has stated what the
engine should answer for them.

## A run, end to end

```bash
python -m cli sets                                  # what the spec tree holds
python -m cli flows                                 # the flows, and which can claim a verdict
python -m cli doctor                                # are the external paths and the validator there
python -m cli show FD_TC_118 --jira                 # its spec, and what the Jira test says
python -m cli jira                                  # do the specs and the Jira tests agree?
python -m cli jira --find "AC Wallet"               # which tests talk about it
python -m cli plan fd/uat/automation                # patch, date and build; publish nothing
python -m cli seed fd/uat/automation --go --unique-name --email <inbox>
python -m cli judge <run-label>                     # re-judge a stored run, no re-reading

# with an AC Wallet member per case, and handed to the automation half
AWS_PROFILE=int-cce AQA_ACCP_PROFILE=int-cce \
  python -m cli seed fd/uat/automation --go --wallet --pool --unique-name

cd automation/playwright-baggage && npm test        # the chat, in a real browser
```

`seed` without `--go` sends nothing, which is the default because these topics are read by other
services. The five steps, in order:

1. **plan** — `builder/apply_patches.py` then `builder/spec_to_build.py`: every scenario dated
   relative to today and given its own flight day, walked earlier until `carrier#number#day#origin`
   collides with neither this run nor `builder/taken-acc.json`
2. **build** — `builder/scenario_build.py` drives cascade's `/qa builder`, rewriting one of five
   anonymised PROD histories into the scenario: ~24 messages across PNR, TKT, PNRCORR, CM and FDM,
   spread over the booking's real life
3. **publish** — `lanes/replay.py --contact --unique-name`: the environment's own inbox, and a
   surname that encodes the case id so automation reading one shared mailbox can tell which scenario
   a message belongs to
4. **gate** — `core/gate.py`: the Trip first (did the booking and the disruption arrive?), then the
   verdict, each booking against its own expectation, up to 100 per task
5. **report** — `tools/seed_report.py` and `tools/disagreement_report.py`

Measured on INT, 2026-10-16: build 14 s per 25 · publish ~2.5 messages/s · fold 66–81 s · gate one
task ~2 min. 262 scenarios took about an hour, nearly all of it publishing.

## What the engine needs, and what it ignores

It stores nothing: a booking's event history is folded on every read. So there is nothing to pin,
and nothing written to a database is visible — `flight_leg` rows and bag rows included. A seeded
flight must therefore report its whole life: `SKD` → `ETD` → `DEP` → `ARR`, plus the Snowflake
`ARRIVAL_CODE` record, or APPR reads the departure code as a fallback (`EL-07/08/09` rather than
`EL-01/02/03`). Sending only `SKD` and `ETD` leaves the leg at `status: SCHEDULED`, `delayMin: 0`,
and every case answers `NE-20`.

## Outside this project

Nothing, for a seed run. `python -m cli doctor` passes and a booking builds with no other checkout
on the machine: the `aqa.workflows.seed` modules and TripTracer's `/qa builder` are copied into
`vendor/` (1 MB), with provenance and what was left out in [vendor/README.md](vendor/README.md).

Three variables still override those copies, which is how a change is tested against the original
before being copied in:

| variable | points at | when you need it |
|---|---|---|
| `AQA_SEED_AGENTIC_QA` | an agentic-qa checkout | testing or refreshing the vendored seed modules |
| `QA_BUILDER_DIR` | cascade's `tools/qa-scenarios/service` | testing or refreshing the `/qa builder` |
| `LOOKUP_TABLES` | cascade's `rules/lookup-tables.json` (40 MB) | only `builder/gate_compare.py`, which this project does not use |

`paths.require()` checks for a file that proves the directory is the right one, and names the
variable to set when it is not.

## Known limits

- **Publishing is unvalidated.** The kit never publishes a batch TripTracer's own parsers have not
  accepted (`event_replay.py check --harness tt-replay-check`). That harness needs Rust 1.98.1 and a
  full MinGW — rustup's bundled one has no `as.exe` — so the check is unavailable here.
- **The verdict read needs a task role.** The TripTracer token is signed with a key only
  case-intake's task role can read, so `core/gate.py` runs inside a one-off task on that service.
  Registering this project's own principal is the alternative: `docs/triptracer-principal.md`.
- **Four scenarios cannot pass whatever is seeded** — `FD_TC_210` needs a `DBCP` keyword,
  `FD_TC_178` an `ASL_regulatory_data_missing_lookup` table and EU261 distance bands,
  `SOC_UAT_031` a UK point-of-sale rule. All are proposed contracts awaiting a decision.
- **`FD_TC_104` cannot be built** — `IndexError` in cascade's `/qa builder`.
- **`FD_ED_TC_03` has no booking by design** — the test is that TripTracer answers not-found.
- **Flight dates are relative to the run**, so a seeded set ages. The 72-hour PENDING cases
  (`FD_TC_103`, `150`, `171`) only answer `PE-01` within hours of seeding.
