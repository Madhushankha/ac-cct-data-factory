# AC Wallet and Aeroplan

A wallet decision is **not** made against a booking. It is made against a **customer profile**, and
no booking creates one carrying a loyalty identity. So a case that wants AC Wallet needs a member,
and a member is a separate thing to seed — at two different moments in the run.

## The order, and why it is that way

```
mint      before the booking is built     number and NAME decided here
build     the booking                     carries the member's name
publish   the feeds                       the name goes out with the PNR
settle    the ingest folds the events     the booking creates a customer profile
attach    after the profile exists        enrich THAT profile, not a new one
```

Both halves of that order are findings, not preferences:

**Mint first, because the name has to match.** The wallet lookup disambiguates candidate profiles by
name, and a tie falls back to the first profile it finds. Two cases that minted
`MICHAEL HALWENVOL` were merged into one profile — booking `R5B9L3` into `HEXFZK`'s. So the booking's
passenger name and the member's name must be the same name, and that name must be unique. A minted
surname is checked against both ACCP and the database before it is used.

That is also why a minted member's name **beats `--unique-name`**. The case-derived surname exists so
one shared inbox can tell scenarios apart; a minted member surname is already unique, so letting it
win costs nothing. `domain/loyalty.Member.matches_booking_name` is the check, and
`adapters/kafka_publisher._renames` is where the precedence lives.

**Attach last, because publishing our own profile first does not work.** It looked right and is not:
the booking does not attach to the profile we published. It asks Entity Resolution who the traveller
is, ER is never given the loyalty id, so it answers "new person" and a second, empty profile
appears — and the empty one wins the wallet lookup, because `PNRId` and `CPID` terms are tried
before the account number. Enriching the booking's own profile leaves exactly one record, which is
what a member who has never been booked already looks like.

(`aqa.workflows.seed.profile.seed_member` publishes before the PNR. It has no call sites in
agentic-qa and its docstring contradicts `attach_member`'s; the live path is mint-then-attach, and
that is what `ports.LoyaltyDirectory` exposes.)

## Three feeds build a member — none of them the booking

| feed | what it creates |
|---|---|
| `MULE-LOYALTY-GIGYA-CUSTPROFILE` | the profile: name, email, address, `username` = the Aeroplan number |
| `IFLY-ACCOUNTSTATUSCHANGES` | `AccountStatus` |
| `IFLY-TIERSTATUSUPDATES` | `AeroplanTier` — **omitted for a Basic member**, which has none |
| `AeroplanFrozenStage` | `Attributes.FrozenStage` for a frozen wallet |

Numbers are minted in **4119**. Real INT members sit in 4115 93xxx, and the Gigya `username` is the
profile key, so minting there could overwrite a stranger's profile.

## Four rules worth knowing

**A fixture's Aeroplan number is a marker, not an identity.** 63 of our specs carry `9876543210` —
not 63 cases sharing a member. It means "this case wants one", and a fresh member is minted per run
so two runs of one case never share a profile. `LoyaltyRequest.is_marker` decides, by checking the
number against the minted band. A number inside 4119 is treated as real.

**Frozen is not account status.** `AccountStatus` stays `"A"` for a frozen member; the freeze arrives
on its own feed and lands in `Attributes.FrozenStage`. The payment flow refuses **level 2 only**, so
a case that asks for "frozen" without saying which level is asking for the one state that decides
nothing — `LoyaltyRequest.validate` refuses it rather than guessing.

**A Basic member is not a member with tier Basic.** It is an active account with no tier update at
all. Sending one produces records a real non-elite member does not have.

**One member per loyalty passenger, never one shared.** The payment flow asks whether *every* claim
passenger has an eligible wallet, so a mixed case needs independent members with one of them in a
different state. `LoyaltyRequest.members_wanted` says how many.

## The top-up

Taking compensation as wallet credit pays **+20%**: CAD 700 cash is CAD 840 in the wallet, 400 is
480. That is `domain.loyalty.wallet_amount`, and it is **derived**: no spec has a wallet field, and
the figure appears only in the UI lines (`AC Wallet CAD 840 (20% top-up)` against `amount: 700`).
Both documented pairs are ×1.2, which is where the number comes from.

## Credentials — the failure that is silent

ACCP reads and writes need `profile:*`, which the seed role does not hold. A run must use:

```bash
AWS_PROFILE=int-cce AQA_ACCP_PROFILE=int-cce python -m cli seed fd/uat/automation --go --wallet
```

With the wrong profile every ACCP write is declined, **nothing is attached, and the run still
produces bookings and verdicts** — one case was reported green with no wallet data behind it. So
`--wallet` refuses up front: `AccpLoyaltyDirectory.check()` runs before anything is seeded, and
`python -m cli doctor` reports it too. A member that could not be attached is reported as
un-attached rather than quietly counted.

## What is expressible today, and what is not

| | state |
|---|---|
| 72 loyalty cases | 63 in `fd/uat/automation`, 2 in `fd/uat/po`, 7 in `soc/uat/automation` |
| wallet states | all three implementable: `open`, `frozen_l1`, `frozen_l2` |
| tiers | `E25K` … `SE100K`, and `BASIC` |
| **cases that state a wallet state** | **none** — no spec carries a `loyalty` block, so all 72 default to `open` + `E50K` |
| the refused case (`frozen_l2`) | has no spec, so the one outcome the payment flow must refuse is not covered |
| mixed-wallet cases | one case has two loyalty passengers; the rest have one |

The gap worth closing first is a `frozen_l2` case: the machinery refuses it, nothing exercises it. A
spec asks by carrying a block —

```json
"loyalty": { "wallet_state": "frozen_l2", "tier": "SE100K" }
```

— and `python -m cli show <case>` will print what the flow made of it.

## Picking a wallet booking in automation

The seeded pool carries the state tags and the real number:

```yaml
- pnr: ZZ6I3V
  first: Sophie
  last: Tremblay
  tags: [wallet, wallet-open, tier-e50k, eligible, appr, delayed, el-01, aeroplan, fd]
  aeroplan: '411900002'
```

so a scenario picks one by state and quotes the number the profile actually carries:

```yaml
booking: { pool: any, pick: next-unused, need: [wallet, eligible], avoid: [wallet-refused] }
```
