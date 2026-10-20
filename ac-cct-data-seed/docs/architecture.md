# The shape of this project

Six layers, and dependencies point one way: inward. The domain knows nothing about Kafka, ECS or the
filesystem; the adapters know everything about them and nothing about each other.

```
cli/            thin entry points: parse, build adapters, call a use case, print
  |
application/    the use cases: seed a pack, judge a run. Composed from ports only
  |
ports/          Protocols: what the application needs from the outside
  |      \
flows/          one policy per flow: which section, what a row is, what agreement means
  |
domain/         values and models that know their own rules. No I/O, no imports outward
                                        ^
adapters/  ------------------------------'   implement the ports against real services
```

`core/`, `lanes/` and `tools/` are the previous generation, still in use and still working. They are
being retired behind the ports; `core/paths.py` is not — it stays as the one place the outside world
is named.

`automation/` is the other half of a test, and the only thing it shares with the layers above is a
file: a pool of seeded bookings written by `adapters/pool_file.py` and read by the suite's own
`src/bookings.ts`. It has its own language, its own dependencies and its own tests, and nothing in
`domain/`, `ports/` or `application/` knows it exists. `src/external.ts` there is the mirror of
`core/paths.py`: one place naming what lives outside, for the same reason.

## Why it is this shape

Every layer here is a defect that cost real time.

**The domain exists because comparisons were written as dict walks**, and shipped five bugs that
produced about ninety false disagreements in one run: a delay band compared as prose; a row count
computed as passengers × regimes; an amount compared literally on rows that are not eligible and so
have no amount; a band guard written into a loop that never compared the band; and a regime fallback
that reported field differences instead of the missing regime. Each is now a type that knows its own
rule — `SystemCode.matches`, `Money.equivalent_to(..., eligible=...)`, `DelayBand.comparable_with` —
so the comparison cannot be written the wrong way round again. `tests/test_domain.py` states each.

**The ports exist because nothing could be tested without AWS.** Those five bugs were found by
seeding real bookings and reading output, a day's work. `tests/test_seed_pack.py` runs the whole use
case against four fakes in under a second, and each of the five is one case in it.

**The flow policies exist because one comparator cannot serve four flows.** FD answers per bound,
SOC per passenger per segment, baggage per bag, ancillary per EMD. A reader built for one shape
passes a document holding the right number of wrong rows for another — which looks like agreement.

**The handoff is a file because it used to be a parser.** The automation half recovered the PNRs,
the passenger, the contact address and the state tags by running regexes over the seed report's
HTML — re-deriving from prose what the seeder had held as data one process earlier. A missing tag
there does not fail a run; it makes a scenario pick the wrong booking and report a real-looking
result. `ports.BookingSink` is the declared shape instead.

**`ports.LoyaltyDirectory` has two methods because the order is a finding.** A member is minted
before the booking is built (the booking must carry the member's name) and attached after the
booking's own customer profile exists (publishing ours first leaves the booking pointing at a
rival empty profile, which then wins the wallet lookup). Both halves of that cost a run to learn;
[ac-wallet.md](ac-wallet.md) has the detail.

**The registry's import-time check exists** because a section nobody reads is coverage silently
missing, and a section two flows read is two answers to one question. That is how one seeder came to
pin a verdict while another computed it, leaving their results incomparable.

## What each layer may import

| layer | may import | must not |
|---|---|---|
| `domain/` | nothing of ours | anything outward |
| `ports/` | `domain` | adapters, application, flows |
| `flows/` | `domain`, `ports` | adapters |
| `application/` | `domain`, `ports` | adapters, `cli` |
| `adapters/` | `domain`, `ports`, `core.paths` | application, flows, other adapters |
| `cli/` | everything | — it is the only place that chooses an adapter |

`tests/test_layering.py` reads the imports and fails on a violation, so this table is checked
rather than merely written down. Two modules are exempted by name — `flows/fd.py` and
`flows/pending.py` import `core.flow`, the old dict-based interface — and the exemption list is
itself checked, so it cannot outlive what it excuses.

The one rule worth stating alone: **`application/` never imports `adapters/`.** When it does, the
use case can no longer be tested without the thing the adapter talks to, and the ports have stopped
earning their keep.

## Adding a flow

1. Write a policy satisfying `ports.FlowPolicy` — `flow_id`, `section`, `lanes`, `needs`, and
   `validate` / `rows` / `judge`.
2. Add it to `POLICIES` in `flows/registry.py`.
3. Claim its section in `domain/sections.py`.
4. Create `spec/<flow_id>/<phase>/<purpose>/` and put specs in it.

Nothing else changes: not the builder, not the publisher, not the reader, not the store, not the
CLI. If something else has to change, the port is wrong and the port is what to fix.

A flow that cannot judge yet subclasses `flows.not_ready.NotReady` and lists what it needs in a
person's terms. It will seed bookings and read its section; it will not claim a verdict. That
refusal matters: a check nobody implemented that reports a pass is worse than a missing one, because
it looks finished.

## The Jira snapshot

`jira/` holds what the tests say, synced from Jira by `aqa.jira.sync` and laid out to mirror
`spec/`, so a case id joins a spec to the test that defines it. It is read by
`adapters/jira_docs.py` behind `ports.TestDocs`, and it takes **no part in judging**: a run
agrees with a test when it means the same thing or carries the seeded values, so the text is
evidence for a person rather than a string to compare. `tests/test_jira_docs.py` checks that
both trees describe the same set of cases, in both directions.

## Adding a suite

A new automation suite is a sibling under `automation/`, with its own `package.json`. It consumes
a pool file and nothing else from this side, so the Python half does not change: a new flow's
bookings arrive in the same shape with that flow's tags on them.

## Adding a dataset

Create the folder and put specs in it. `spec/<flow>/<phase>/<purpose>/<CASE_ID>.json`, and
`python -m cli sets` will find it. There is no registry of sets to update, and no code lists them —
see [spec/README.md](../spec/README.md) for the three rules the tree enforces.

## What is still the old shape

* `core/seed.py`, `core/gate.py`, `core/batch.py` — superseded by `application/seed_pack.py` plus
  the adapters, but still what `tools/` calls.
* `core/flow.py` and `flows/fd.py` — the dict-based flow interface, kept while `tools/` uses it.
  Its section map now comes from `domain/sections.py` and its `needs` text from
  `flows/not_ready.py`, so the two generations cannot drift apart on either.
* `lanes/fdm.py`, `lanes/fdm_bare.py` — superseded by the builder's own FDM, which produces a leg
  the engine will actually assess. These produced one that stopped at ETD, so the engine saw
  `status: SCHEDULED, delayMin: 0` and answered `NE-20` for every case.

## The one thing this cannot do

It publishes without the parser check. The kit never does: `event_replay.py check --harness
tt-replay-check` runs first and a batch that fails it twice is abandoned. That harness is a Rust
binary needing 1.98.1 and a complete MinGW — rustup's bundled toolchain ships no `as.exe`, so
`dlltool` cannot build the import libraries — and the `event_replay.py` in the cascade checkout has
not had the kit's `/qa-builder` exemption patch applied.

`KafkaPublisher.validate` therefore returns `(False, reason)` and every run says so in its output.
The payloads are the builder's own, which is the point; the validation step is missing, and a run
that silently skipped it would be claiming more than it knows.
