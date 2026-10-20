# baggage/sit/po — 73 baggage SIT cases, walked by hand

`BAG_PO_001` … `BAG_PO_073`, imported from the baggage SIT kit (`BAGGAGE_SIT_KIT_20261017`) by
`tools/import_baggage_po.py`. The ids are the kit's own order, which is also the row order of both
published PNR tables, so this set, the kit's reports and the old seed report all list the same
cases in the same order.

| SD group | cases |
|---|---|
| SD-02 | 7 |
| SD-03 | 28 |
| SD-05 | 20 |
| SD-06 | 1 (two passengers on one AHL) |
| SD-07 | 9 |
| SD-08 | 7 |
| SD-16 | 1 |

Bag shapes: `ahl_open` 51, `ahl_delivered` 10, `ahl_closed` 7, `no_ahl` 3,
`ahl_closed_delivered` 1, `no_bag` 1.

## The PNRs are already live — they are not seeded from here

`catalog/baggage-po.json` is the binding: for each `BAG_PO_*` it holds the INT and the BAT PNR, the
pnrId, the passenger last name, the ticket number(s), the bag shape, and the case number the kit's
own check created. Both tables were published 2026-10-16 and verified 73/73 PASS by the kit.

That catalog is the table to walk from. The specs state the scenario; they deliberately state no
environment, because a PNR belongs to an environment and a spec does not.

## Seedable from here, and seeded — but still not judgeable

Every case lands `runnable: true`. The catalog records the validation twice, because the project
carries two flow interfaces and a spec that satisfies one is not thereby proved against the other:

* `missing.spec_dict` — `core.registry` → `flows/pending.py`, reading the spec as written on disk;
* `missing.parsed_scenario` — `flows.registry` → `flows/not_ready.py`, reading a parsed
  `domain.models.Scenario`.

Both accept all 73 for seeding, and both still refuse to claim a verdict. That split is deliberate:
`blocks_seeding` is what stops a booking being built, `needs` is what stops an answer being
claimed, and for baggage the first is now empty while the second is not. Two things emptied it —
importing this set (which removed "no set exists") and `builder/bag_build.py` becoming the
bag-event lane. What `needs` still holds is the per-bag row shape and receipts for interim
expenses.

**Seeded to INT on 2026-10-19** (`runs/int/baggage-po-int-seed-1019/`):

```
python -m cli seed baggage/sit/po --env int --go --label baggage-po-int-seed-1019
```

73 runnable, 0 refused · 73 built, 0 failed, 77 flights · **1947 messages published, 0 failed** ·
settle 90s · read on one ECS task, exit 0. The 1947 split across six INT topics, including 248 on
`emh-int.BROCK-BAGGAGE-INT` — the bag events this set exists for.

Note this mints a **second** booking per case: all 73 already had one from the kit's own publish.
`--skip-seeded` seeds only what is missing, which for this set is nothing.

## What a PO actually checks

Not `expect`. `expect.eligibility` is `null` and that is the honest value: this project cannot
compute a baggage verdict yet, and inventing one would let the set report a pass nobody stated.

The expectation is `expectBag` — the facts Case Intake's baggage eligibility assessment must return
for the case, which it answers with a `BAG-LB-*` / `BAG-IE-*` code:

`isAhlPresent`, `isClosedAhlPresent`, `isMultipleOpenAhlPresent`, `isBagDelivered`,
`isLastCarrierAC`, bag and AHL counts, and the closure/delivery timing that drives the 21-day and
51-day windows.

`bagPlan` beside it is how the bag was built (shape, counts, which segment, AHL timing). It is what
`builder/bag_build.py` reads to emit the BROCK events, so it is no longer dormant: `bags: 2,
ahls: 1` is why `BAG_PO_028` and `BAG_PO_056` put two bag rows on one AHL id.

## `source.oldExpectedDds` is a record, not an expectation

Every case carries `NOT_ELIGIBLE · FD-BAG-NE-01 · — · 240 min code 64` under `source`. That is what
the **old INT seed** claimed on 2026-09-30, and it is kept only as the record of that run.

It was never a baggage verdict. agentic-qa has no baggage lane, so those 73 bookings were seeded
through the **FD** flow and the answer was written straight into the classic stores as `dbadmin` —
the same FD code for all 73 regardless of the bag, and a code the rule engine's own reason table
does not hold (`ne_nd_reason_text` is n/a on all 73 in that report). The kit says it plainly: *"Old
FD-BAG-NE-01 not reproduced. The old INT seed forced that DDS answer into classic stores, so these
bookings don't reproduce it."*

The 240-minute code-64 flight delay in `outcomes` is from that same FD scaffolding. It is a true
fact about the booking, and it is not what the case is about.

## Before you walk one

* **Every PNR already has a BAGGAGE case** from the kit's own verification (the case numbers are in
  the catalog). Opening a second claim on the same bag goes through the **duplicate-claim rules**,
  so a case walked twice does not answer the question it was built to answer. For a clean re-test,
  generate a fresh set with the kit's `publish_env.sh`.
* **Read the contact off the Trip, not from here, and do not assume it is the FD one.** No spec in
  this tree states an email or phone — `fd/uat/po` doesn't either; the seeder supplies them. The
  old INT seed used `lahiru@ae-qa1-aircanada.mailinator.com` / `+123456789` on all 73, the usual FD
  contact. These PNRs are different bookings: nothing in the kit sets a contact at all, so theirs
  comes from `/qa-builder`'s own stand-ins, which its README says of names, emails and phones
  alike. The catalog therefore binds the last name and tickets — what a lookup needs — and not an
  email.
* **Passenger names are synthetic** and differ per case (`RILGILTAV`, `ZARSORREN`, …). The last name
  in the catalog is the one the live booking carries — `lastNames` is what the lookup needs.
* **Six cases state their SD inside the condition.** `BAG_PO_024`…`BAG_PO_028` and `BAG_PO_073`
  arrive with `sd: null` and `rule: null`; the SD was recovered from the condition text and each
  says so in `assumed`. They have no BAG-\* rule, which is why `rule` is null in the catalog.

## Proven live on INT, and what the two APIs cannot answer

`python -m cli gate <batch> --label baggage-po-int-1019 --env int --flow baggage`, 2026-10-19,
against the INT PNRs in the catalog (build the batch with `tools/baggage_po_batch.py`). The gate
makes the same two reads per booking that FD is validated with, and writes nothing:

1. `GET /api/service/trips/{pnrId}?engine=raptor` — the Trip;
2. `POST /api/dds-evaluations?engine=raptor` — the verdict.

Result, stored under `runs/int/baggage-po-int-1019/`: **73 of 73 answered on both**. Every booking
was found (77 segments across the 73 — the four multi-bound cases carry two), every one is
`ARRIVED` and carries its 240-minute delay, and the three structural Trip checks pass on all 73.
Engine `raptor` release 46, rules `73fc724143b8155c`.

Two things that run settles:

* **The bookings are live and readable.** The kit's ZZ bookings keep the old seed's flight numbers
  (`AC9250`/`AC9251` for `BAG_PO_001`) on dates of their own — the Trip is where those dates are
  recorded, because the kit does not ship them.
* **`POST /api/dds-evaluations` does return the baggage verdict.** An earlier version of this
  section said it did not, on the grounds that the document "holds one section, `bounds`". That was
  a reading error: `Assessment.blocks()` falls back to looking *inside* each bound, and
  `baggageClaimEligibility` is nested there — 77 blocks across the 73, in that gate run and in the
  seed run alike. The codes are real: `BAG-LB-ND-01` 30, `BAG-LB-EL-01` 22, `BAG-LB-NE-01` 11,
  `BAG-IE-ND-04` 5, four cases with no bag-carrying bound, and one with two.

So `baggage_section` and `baggage_verdict` do come back n/a 73 times, but **not** because the
answer is missing. They are n/a because of the row shape. `flows/not_ready.py` reads the generic
per-passenger shape, where `eligibilityStatus` and `systemCode` sit on the row; baggage nests them
one level down under `passengerEligibility[]`, and again per bag under `bags[]`, each bag carrying
its own `lostBaggageEligibility` and `interimExpensesEligibility`. That is exactly the need the
flow states — *"a row shape of its own: baggage answers per bag, not per passenger"* — now
confirmed against a live document rather than assumed. `interimExpensesEligibility` exists only
inside a bag; there is no bound-level section of that name.

The Trip projection in `adapters/ecs_assessment_reader.py` now carries bags (tag, bound, status,
loc, ahl id and time, and the event list), so `expectBag` is checkable from the gate. Measured on
the seed run: **73/73 agree** on `bagCount`, `ahlCount`, `isAhlPresent`, `isClosedAhlPresent`,
`isMultipleOpenAhlPresent`, `isBagDelivered` and the event list. 72 of the 73 Trips carry bag rows;
the 73rd is the `no_bag` case. `ahlCount` counts **distinct** AHL ids, not bags holding one — two
bags on one AHL is the intended shape for `BAG_PO_028` and `BAG_PO_056`.

Five `expectBag` fields are not checkable from a bag row and were not compared: `isLastCarrierAC`,
`isOal`, `oldDaysSinceArrival`, `closedDaysAgo`, `deliveredHoursAfterSchedArrival`.

## What the kit does not contain

Audited against `BAGGAGE_SIT_KIT_20261017` (22 files, 436 KB):

* **No EA answers.** `REMOTE_INT_REPORT.*` and `REMOTE_BAT_REPORT.*` are written by
  `ci_baggage_remote.py` and are not shipped, so the `BAG-LB-*` / `BAG-IE-*` codes behind the kit's
  "73/73 PASS" were not in hand at import time. That is *why* no spec here states a verdict — it
  was not a choice this import made. The codes are now obtainable from INT directly (see above),
  and the two runs agree on all 73, but they are still not written into `expect`: a verdict copied
  from the engine it is meant to check would prove nothing.
* **No built bookings.** There is no `int/` or `bat/` build directory, so the ZZ bookings' flight
  numbers and dates exist only on the environments themselves.
* **`BAGGAGE_EA_API_CONTRACT.md` is referenced and missing.** `baggage/case_to_spec.py` cites it
  for what each `requestInputs` entry means — which inputs ride on the EA request or the claim, and
  which are chatbot dialogue. Worth asking the team for; `requestInputs` is imported verbatim, so
  nothing was lost, but the key to reading it is not here.

Everything the kit *does* hold for these 73 is imported: the cases, both PNR tables, and each
case's `seedNotes` (the old run's arrival-shift and bag-row lines, under `source.seedNotes`).

## Provenance

The import was checked against the old seed report (`baggage-sit-int-v55-seed-report.html`), which
is an independent rendering of the same run: 1453 field comparisons across all 73 cases — PNR,
route, segments, passengers, bag shape, bag and AHL counts, delivery, closure days, days since
arrival, delay and cause — with no mismatches. Re-running the import is byte-identical.
