# jira — what the tests actually say

**Jira is the source of truth for these tests.** A test's description defines the seed data, the
chat and the checks. The FD gap document does not: disagreeing with the gap doc is not a defect,
disagreeing with the Xray test is.

This is a **synced snapshot**, not the source and not hand-written. `aqa.jira.sync` pulls each test
from Jira and writes exactly these files; `synced_at` in every `test.json` says when. Nothing here
writes back to Jira.

## Layout

It mirrors `spec/`, so a case id joins a spec to the test that defines it:

```
spec/fd/uat/automation/FD_TC_118.json
jira/fd/uat/automation/FD_TC_118__CHAI-31510/
    test.json          summary, title, description split into goal + prerequisite_items, status
    test.feature       the Xray Gherkin
    checkpoints.json   the generated checkpoints a run is evaluated against
    checkpoints.md     the same, for a person
```

`fd` and `fd-edge` in the old layout are **one set** here, because that is what they are: the
266-case FD UAT automation set is `FD_TC_001..239` plus `FD_ED_TC_01..27`, and `spec/` already held
them together. Each set also carries `_<flow>-index.json` and `_<flow>-execution.json` as synced.

| set | Jira tests | execution |
|---|---|---|
| `fd/uat/automation` | 266 | CHAI-31809 (FD), CHAI-31811 (edge) |
| `soc/uat/automation` | 77 files, 76 distinct ids | CHAI-31996 |

## Use it

```bash
python -m cli jira                          # every spec has a test, every test has a spec?
python -m cli jira --set fd/uat/automation
python -m cli jira --find "AC Wallet"       # which tests talk about it
python -m cli show FD_TC_118 --jira         # the spec, and what the test says
```

`adapters/jira_docs.FileTestDocs` is the reader, `domain/testdoc.TestDoc` the value, and
`ports.TestDocs` the shape. It is read-only and takes no part in judging: a run agrees with a test
when it means the same thing or carries the seeded values, so the text is evidence for a person,
never a string to compare.

## Two defects in the source, carried faithfully

**`SOC_UAT_076` is defined twice.** `CHAI-31990` is "ASL • Pending • 72 Hours" and `CHAI-31991` is
"Override • Pending" — different tests sharing one id — and **`SOC_UAT_075` does not exist**: the
SOC ids run 1–77 with exactly that one gap. So `CHAI-31991` is almost certainly mis-numbered and
should be `SOC_UAT_075`.

Our spec for it is named `SOC_UAT_076__CHAI-31991.json`, carrying the issue key so it at least
points unambiguously at one test. It is deliberately **not** renumbered to 075 here: Jira is the
source, and renumbering on our side would be us deciding something the test owner has not. `python
-m cli jira` reports it on every run until it is settled there.

**6,135 characters arrived damaged** (8,516 counting the Gherkin and goal text; 292 of 343
`test.json` files). They are bullets, arrows and accents — `ASL • Eligible` reads `ASL ? Eligible`,
`PTP→YUL` reads `PTP?YUL`, `Montréal` reads `Montr?al`.

This is not our sync: `aqa.jira.client` decodes UTF-8, `aqa.jira.sync` writes UTF-8 with
`ensure_ascii=False`, and the damage appears identically in the Xray Gherkin, which comes down a
different field. The replacement characters are already in Jira's stored text — consistent with the
descriptions having been imported from a source that mangled `•` (0x95 in cp1252) on the way in.

It has not broken a judgement, because we compare meaning and seeded values rather than wording. It
does mean the prerequisite bullets no longer delimit cleanly, so `prerequisite_items` is the
reliable way to read them. `TestDoc.damaged_characters` counts what a doc is carrying.

## The audit: where a test says more than its spec

```bash
python -m cli jira --audit
```

reads what each test says about AC Wallet and reports where the spec does not express it. Ten cases
today, and the first one matters:

| case | what Jira says | what the spec seeds |
|---|---|---|
| `FD_ED_TC_13` | `Aeroplan account status: FROZEN`, wallet falls back to Interac | an open wallet |
| `FD_TC_006` | tier E75K | E50K (the default) |
| `FD_TC_023/024/109` | tier E25K | E50K |
| `FD_TC_047/048` | tier E35K | E50K |
| `FD_TC_026` | `star alliance gold (aeroplan 50k/75k)` and `super elite` | E50K |
| `FD_TC_027` | `VIP Profile` — a flag, not a tier | E50K |
| `SOC_UAT_015` | two tiers named | E50K |

`FD_ED_TC_13` would seed an **open** wallet, so the fallback-to-cash the test exists to prove could
never fire — and the case could pass for the wrong reason. The others seed a member one tier away
from the one the test names.

**The audit changes nothing.** A `loyalty` block is seed input, and the hints are read from prose:
deriving input from prose automatically is the same mistake as reading a delay band out of a system
code. Two of the ten are ambiguous in the source itself (`FD_TC_026` names three tiers,
`FD_TC_027` names a profile flag), which is exactly why a person decides. The fix is one line in
the spec:

```json
"loyalty": { "wallet_state": "frozen_l2", "tier": "E50K" }
rozen_l2\, 	ier\: \E50K\ }
```

## Not copied

The old location also holds things that are not the tests, and they were left there:

* `report/` — 345 generated HTML run reports. Run output belongs under `runs/`, not beside the
  definitions.
* `*.zip` — `FD-UAT-266.zip`, `SOC-UAT-77.zip`, `report.zip`: raw exports, redundant with the
  per-test files.
* `analysis/` — working files and two ad-hoc scripts (`merge_final.py`, `pass3_check.py`).
