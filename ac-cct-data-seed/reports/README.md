# reports/

One directory per report, laid out as **`<env>/<flow>/<phase>/<purpose>/v<n>/`** — the same
`flow/phase/purpose` a spec set has, with the environment in front and a version at the end.

```
reports/<env>/<flow>/<phase>/<purpose>/v<n>/
        int                                   the environment the run read
            fd/uat/automation                 the SET, spelled exactly as `python -m cli sets` spells it
                             v4               the version: v1 is the oldest, the highest is current
```

The path mirrors the set because a report is only meaningful about one set, and the set name is
what tells you how many cases to expect: `fd/uat/automation` is 266, `fd/uat/po` is 27,
`baggage/sit/po` is 73. The earlier layout (`reports/int-1019c/`) buried that in a label and put
the 266-case automation run in a folder named `po`, which named the wrong set.

`v<n>` is a plain counter, not a date: several runs happen on one day, and `-1019b` / `-1019c`
suffixes stopped being orderable as soon as there were three of them. The run label is kept inside
each page, so the version always resolves back to the run that produced it.

## What is here

| path | set | cases | run label | what it is |
|---|---|---|---|---|
| `int/fd/uat/automation/v1` | `fd/uat/automation` | 266 | `fd-266-run` | 2026-10-18, the first INT pass, written by the older kit-shaped generator |
| `int/fd/uat/automation/v2` | `fd/uat/automation` | 264 | `fd-266-int-fixed-b03` | 2026-10-19 04:55 |
| `int/fd/uat/automation/v3` | `fd/uat/automation` | 264 | `fd-266-int-1019b-all` | 2026-10-19 14:35 |
| `int/fd/uat/automation/v4` | `fd/uat/automation` | 264 | `fd-266-int-1019c-b03` | 2026-10-19 18:51, **current**; 219 agree / 45 disagree |
| `bat/fd/uat/automation/v1` | `fd/uat/automation` | 264 | `fd-266-bat-fixed-b03` | 2026-10-19 04:55 |
| `bat/fd/uat/automation/v2` | `fd/uat/automation` | 264 | `fd-266-bat-1019b-b03` | 2026-10-19 13:00 |
| `bat/fd/uat/automation/v3` | `fd/uat/automation` | 264 | `fd-266-bat-1019c-b03` | 2026-10-19 18:51, **current**; 220 agree / 44 disagree |
| `int/baggage/sit/po/v1` | `baggage/sit/po` | 73 | `baggage-po-int-seed-1019` | 2026-10-19 15:32Z, first seed from this project; 73/73 bag facts agree, 73 not judged. Published the builder's `synth-*@synth.test` contact, so **no run can read its mail** |
| `int/baggage/sit/po/v2` | `baggage/sit/po` | 73 | `baggage-po-int-v2` | 2026-10-19 15:55Z; identical results, and the first to carry the Mailinator contact |
| `int/baggage/sit/po/v3` | `baggage/sit/po` | 73 | `baggage-po-int-v3` | 2026-10-19 16:11Z; a second independent dataset of the same 73 cases |
| `int/baggage/sit/po/v4` | `baggage/sit/po` | 73 | `baggage-po-int-v4` | 2026-10-19 16:25Z, **current**; a third |
| `int/baggage/sit/po/<name>` | `baggage/sit/po` | 73 each | `baggage-po-int-<name>` | 2026-10-19/20, one dataset per PO: `fady`, `diana`, `shankave`, `patricia`, `elifue`, `parul`. Each carries that person's own first name, surname and e-mail; 73/73 bag facts agree on every one |
| `bat/fd/uat/automation/v4` | `fd/uat/automation` | 264 | `fd-266-bat-gimhan` | 2026-10-19; Gimhan Ranasinghe's name, e-mail and DOB 1999-02-15 on all 264. 220 agree / 44 disagree, release 46 |
| `int/soc/uat/automation/v1` | `soc/uat/automation` | 77 | `soc-uat-int-v1` | 2026-10-20; the first SOC seed from this project. 59 of 77 as intended |
| `int/soc/uat/automation/v2` | `soc/uat/automation` | 77 | `soc-uat-int-v2` | 2026-10-20, **current**; a fresh set of PNRs, **the same 59 of 77** — which is what proves the 18 are not seeding defects |

`baggage/sit/po` v2, v3 and v4 are **parallel datasets, not corrections**: the same 73 cases seeded
three times, so three runs can work the same conditions without touching each other's bookings.
Every case has three distinct pnrIds across them (0 collisions), and all three got the same verdict
from the engine on all 73 — which is the useful thing to know about them, because it means a
difference between two runs is about the run and not about which dataset it drew from. They were
seeded **sequentially on purpose**: the flight-key avoidance list is built at build time from this
project's own runs, so two concurrent builds can hand the same key to both datasets.

## File names

```
<env>-<flow>_<phase>_<purpose>-v<n>-<date>-<owner>-<page>.html

int-baggage_sit_po-v2-2026-10-19-lahiru-seeded.html
bat-fd_uat_automation-v3-2026-10-19-lahiru-disagreements.html
```

The directory already says all of this, and the file name says it again on purpose: a page gets
copied out, attached to a ticket or mailed, and `seeded.html` then tells the reader nothing. Five
things are in the name because all five change what the file means — **which environment**,
**which set**, **which run**, **when** (flight dates are relative to the seeding day, so a set goes
stale), and **whose bookings** these are.

The environment leads because it is what a reader most often gets wrong. INT and BAT run different
rule releases, so one case can legitimately answer differently in each, and an INT and a BAT page
of the same set differ in nothing but their directory — the easiest pair in this tree to confuse
once either is out of it.

The owner matters more than it looks. Every seeded PNR carries one contact address, and a run that
cannot read that inbox cannot drive the case at all: `baggage/sit/po` v1 was published with the
builder's `synth-*@synth.test` address and is unusable for anything mail-driven, while v2 of the
same set carries the Mailinator box. Both are the same 73 cases with the same results, so nothing
but the name and the page itself distinguishes them — which is why v1 is named
`synth-UNUSABLE` and not after a person.

The tag is the inbox name alone (`lahiru`); the domain is identical on every file and adds nothing,
and the full address is stated on the page. A page with **no** owner tag is one whose contact was
never read back from the engine — the older FD versions — because an unverified owner in a filename
is a claim rather than a label.

## The pages

**FD** (`tools/report.py`) writes two:

* `…-seeded.html` — one row per case: what it tests, the PNR, the flight, what was expected, what
  the engine answered, and which checks failed.
* `…-disagreements.html` — only the cases that differ, grouped by *cause* rather than listed flat,
  because most differences are not rule defects (a taken flight key, a release gap between the two
  environments, a scenario that states its expectation wrongly).

**Baggage** (`tools/baggage_report.py`) writes two of its own, because baggage answers per bag
where FD answers per passenger, and the FD reader cannot reach the nesting:

* `…-seeded.html` — one row per case, with the bag facts **expected against seen** (green agrees,
  red does not) and the code the baggage EA returned.
* `…-verdicts.html` — every answered bag, grouped by code, each with its AHL, that AHL's status and
  the bag's last event.

**SOC** (`tools/soc_report.py`) writes three, because a SOC case is read by three different people
and because the engine nests its answer one level deeper than FD —
`socFlightEligibility[].segments[].passengerEligibility[]`, per passenger **per segment**. Reading
it the FD way returns nothing at all, which once looked like "the engine answered nothing":

* `…-seeded.html` — one row per case for whoever needs the data: the PNR, the flight, what the card
  expects, and what the engine answered.
* `…-scenarios.html` — one block per case for whoever runs it by hand: the Jira description, the
  ~16 prerequisites the card states, and the **full cucumber steps** (all 77 have them), with the
  seeded PNR beside them so the walk can start immediately.
* `…-disagreements.html` — only the cases that reach neither the card's system code nor the
  `achievableCode` that `builder/fixes-soc.json` predicted, grouped by **who can act**: the engine
  team (a code no rule emits, or `NOT_ELIGIBLE` where the card wants `NO_DETERMINATION`), the card
  author, or us. Each case shows what the engine *saw* — regime, flight, delay, cause code — which
  is the evidence that the data was right and the disagreement is in the rules.

Every row on all three carries a **description** — what the case is testing. For FD and SOC that is
the Jira test title, and for baggage the kit's own `SD · SP · BAG rule · condition`, because that
set has no Xray test. A page listing 73 bare case ids is not reviewable by anyone who did not write
them.

A SOC page never states a pass. The flow cannot claim a verdict (per-passenger-per-segment row
shape, receipts, UAT fixtures), so `not judged` is printed as its own count and every agreement
number is a comparison a human made, not a check the run asserted.

## Regenerating

```
python tools/report.py --run runs/int/fd-266-int-1019c \
                       --run runs/bat/fd-266-bat-1019c \
                       --out reports/int/fd/uat/automation/v4

python tools/baggage_report.py --run runs/int/baggage-po-int-seed-1019 \
                               --out reports/int/baggage/sit/po/v1

python tools/soc_report.py --run runs/int/soc-uat-int-v2 \
                           --out reports/int/soc/uat/automation/v2
```

FD takes `--run` twice on purpose: the second environment becomes a column, which is what makes a
release difference legible instead of looking like a defect. Write a **new** `v<n>` for a new run
rather than overwriting an old one — the old page is the record of what was true then.

## What a page will not do

State a pass for something nobody expected. The baggage set states no verdict, so its codes are
labelled as observed; `not judged` is printed as its own count on both reports and never folded
into "agree".
