# spec — the datasets, one tree

Every scenario this project can seed lives here, and nowhere else.

```
spec/<flow>/<phase>/<purpose>/<CASE_ID>.json
```

| part | what it is | values today |
|---|---|---|
| flow | the flow id, which resolves straight to a policy in `flows/` | `fd`, `soc`, `baggage`, `anc` |
| phase | where the set is used | `uat`, `sit` |
| purpose | what it is for | `automation` (a suite runs it end to end), `po` (a product owner walks it by hand) |

So `spec/fd/uat/automation` is "the FD UAT automation set". Adding a set is creating a folder:
nothing registers it, and no list of sets exists in code. `adapters/file_spec_source.py` discovers
them, and `python -m cli sets` prints what it found.

## Three rules

**One id, one spec.** A case id appears in exactly one set. Before this tree, the kit copied
`specs/` and then `specs-nobooking/` into one directory, so for 19 scenarios the winner was decided
by directory order alone — the authored booking beat the empty "no booking data" shell, which was
the right outcome that nothing anywhere stated. A duplicate id now raises, in both the spec source
and `builder/apply_patches.py`.

**A folder starting with `_` is not a set.** That is what makes it safe to keep a superseded spec
beside the one that replaced it: see `fd/uat/automation/_superseded/`.

**The folder name is the flow id.** `anc`, not `ancillary`, because `flows/registry.py` looks the
policy up by that name and a mapping table between the two is a place for them to drift apart.

## What is here

| set | specs | source | state |
|---|---|---|---|
| `fd/uat/automation` | 266 | Jira CHAI-31809 Xray tests, via the kit's specs + `builder/fixes-*.json` | seeded and judged on INT |
| `fd/uat/po` | 27 | the `fd-uat` fixtures, imported by `tools/import_po.py`; binding recorded in `catalog/fd-po.json` | imported, not yet seeded from here |
| `fd/sit/po` | 0 | the 132-case SIT set | not imported |
| `soc/uat/automation` | 77 | the kit's SOC specs | not seeded: the SOC policy cannot claim a verdict yet (`flows/pending.py` says why) |
| `soc/uat/po` | 0 | — | not imported |
| `baggage/sit/po` | 73 | the baggage SIT kit's `baggage-sit-v55` cases, imported by `tools/import_baggage_po.py`; binding recorded in `catalog/baggage-po.json` | seeded from here (all 73 on INT, 2026-10-19) and bag facts agree 73/73; the verdict is still not claimed — no case states one |
| `baggage/uat/automation` | 0 | — | no set exists; `baggage/sit/po` is the only baggage set today |
| `anc/uat/automation` | 0 | — | no set exists; the flow needs an EMD lane first |

Empty sets are listed rather than hidden. A folder with a README and no specs is a set someone
intends to fill, and hiding it makes the gap invisible.

## What defines a case

A spec says how to seed a case. What the case *is* lives in `jira/`, in the same layout —
`jira/fd/uat/automation/FD_TC_118__CHAI-31510/` for `spec/fd/uat/automation/FD_TC_118.json`.
Jira is the source of truth for the tests; `python -m cli jira` checks that every spec has one
and every one has a spec.

## The spec shape

`SPEC_SCHEMA.md` in the kit describes it. Briefly: `id`, `family`, `passengers`, `segments`,
`outcomes`, and `expect` — what the engine should answer. A file holding a `bookings` list is
several scenarios in one spec, addressed as `ID#1`, `ID#2`, which is how `builder/fixes-*.json`
patches them too. Only `FD_TC_209` is written that way today.

`expect.eligibility` is what a flow needs to *judge* a case: a scenario with no stated verdict
cannot pass or fail, and a set whose expectation nobody has stated must not be able to report a
pass. That is separate from whether the case can be built, which is why a flow states
`blocks_seeding` and `needs` separately — the first stops a booking being published, the second
stops an answer being claimed.

`baggage/sit/po` states no `expect.eligibility` on purpose, so the baggage flow still refuses to
claim a verdict for its 73 cases. It does **not** refuse to seed them: both flow interfaces accept
all 73, and all 73 were published to INT on 2026-10-19 (1947 messages, 0 failed), bag events
included. Their expectation is the bag facts in `expectBag`, which the Trip now returns and which
agree 73/73; Case Intake's baggage EA answers the verdict itself as `BAG-LB-*` / `BAG-IE-*`, nested
per bag where the generic reader cannot yet follow it. See `spec/baggage/sit/po/README.md`.
