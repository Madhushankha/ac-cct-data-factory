# Ask AC baggage chat — Playwright suite

Drives the Ask AC chat (`public-qa-chat/public/index.html`, served locally, backend = the INT/QA
deployment) through the baggage scenarios in `scenarios/*.yaml`. It gets the email OTP itself,
captures a transcript with each message's layout, takes screenshots with the OTP masked, judges replies by meaning
and layout, and writes `out/<run>/report.md` plus Playwright's HTML report.

Built to `PLAYWRIGHT_AUTOMATION_GUIDE.md` (the Ask AC baggage brief, 2026-10-07). Where this differs from the
guide, it is because the widget or this machine does something else; see "Differences from the guide".

## What it drives

- **Chat page.** Default: the hosted INT stable preview (`https://cct-chat-stable.ac-cct-int.cloud.aircanada.com/`).
  Its widget calls the same INT gateway (`rg9r0wtonl`) as the agentic-qa seed pipeline. The suite signs in with
  `CHAT_PASSWORD` from `.env`. `CHAT_URL=local` uses the public-qa copy served by `scripts/serve.js`, whose widget
  calls `bcnxq39777`.
- **Scripted scenarios** (`scenarios/*.yaml`, project `baggage`): fixed paths, judged by meaning and layout.
- **AI customer** (`src/goal.ts`, project `goal`, `GOAL_PLAN=<plan.json>`). Each turn the model gets a screenshot
  of the chat and a numbered list of the controls on screen, and does one user action: click, type, send a
  message, get the email code, upload files, scroll, wait, or finish. Messages and fields are typed key by key,
  then Send or Submit is clicked. Safety stops are enforced in code. A judge compares the end of the chat with
  the case's expected outcome and must quote the assistant. The model is Bedrock `global.anthropic.claude-sonnet-4-6`
  through `BEDROCK_PROFILE` / `AWS_PROFILE` (default `int-cce`).
- **Every chat is recorded:** `out/<run>/videos/run<n>.webm`, next to the transcript, the full-chat screenshot
  (a tall window, or scrolled parts) and the live view (`transcripts/run<n>.live.json`, `screenshots/run<n>_live.png`).
- **From agentic-qa:** the Chat UI Tests page (`/chat-tests`) launches runs, by scenario or by seeded case, and
  shows them live.

## Run it

```bash
npm install
npx playwright install chromium
npm run test:unit                       # offline: OTP parsing, safety walk of every scenario, judge, report
npm run test:smoke                      # live, cheap: both @smoke scenarios
SCENARIO=smoke-menu npm test            # one scenario by id (comma-separated for several)
RUN_NAME=v72-all-paths npm test         # every scenario -> out/<date>_v72-all-paths_<hhmm>/
npm run report                          # rebuild report.md for the newest run
npx playwright show-report out/html     # traces, videos, screenshots of failed tests
```

`playwright.config.ts` starts `scripts/serve.js` (plain Node, no `python3` needed) on
`http://localhost:8765/index.html`. Opening the page as `file://` does not work.

## Layout

```
src/chat.ts         ChatPage: open, consent, language, tap/say/fill/choose, settle(); every action guarded
src/guards.ts       safety stops (GenUC-16a/16/27/23) + forbidden actions; checked at runtime and statically
src/otp.ts          Mailinator client, code parsing, global queue (file lock), 70 s gap, 5/booking/24 h ledger
src/bookings.ts     pools from data/bookings.yaml, claim/release under a lock (no two workers share a booking)
src/transcript.ts   messages from the DOM: who, time, text, layout (plain/info/warning/success), buttons, form, links
src/judge.ts        expectations (meaning + layout), generic defects, known-issue tagging
src/shots.ts        full-chat screenshot, OTP masked, falls back to scrolled parts
src/steps.ts        step library + Run (one scenario end to end -> transcript, result, screenshots)
src/scenario.ts     YAML scenario types, loader, static safety walk
scenarios/*.yaml    one file per path (00a/00b smoke, 01-10 the v77 "all paths" list)
data/bookings.yaml  booking pools (npm run import-seed)
data/known-issues.yaml
scripts/report.ts   results -> results.json + report.md (guide 11.2)
scripts/import-seed.ts  seed report HTML -> a pool with state tags
scripts/otp.ts      hand a code to a run waiting on the manual provider
state/              cross-run state (gitignored): OTP lock + ledger, booking ledger, manual OTP drop box
out/<run>/          results/, transcripts/, screenshots/, results.json, report.md
```

## Scenarios

```yaml
id: lost-no-expenses
title: Lost contents, no expenses -> contents -> payment
booking: { pool: any, pick: next-unused, need: [lost], avoid: [partner, waiting, closed] }   # or { pnr: WESDIF }
first_message: "My bag is lost and I want to claim for what was inside it."
steps:
  - notice: "yes"                 # yes | no | skip ; records whether the notice showed
  - identify: true
  - verify: true                  # OTP through the broker
  - journey: one                  # one | no | { match: "AC9558" }
  - expect: { step: BAG-03c.S5, any_of: ["been delivered"], buttons: ["Yes, it was delivered!", "No, I still haven't received it!"] }
  - delivery: "no"                # yes | no | { answer: "yes", date: "2026-10-03" }
  - readiness: "yes"
  - contents: { category: Clothing, cad: true, item: Shirt, qty: 1, amount: 80 }   # or items: [...], cad: false + currency
  - confirm: true                 # true | change
  - expect: { step: BAG-06.S20, layout: success, text: "submission was successful" }
  - stop: payout-country          # payout-country | payment-proceed | manual-review | third-party | end
known: []
```

Other steps: `upload: [receipts/x.pdf]`, `say: "text"`, `tap: "label"`, `choose: [labels]`, `wait: 5`.

`expect` fields: `text`, `any_of`, `all_of`, `none_of` (case-insensitive regexes; meaning, never exact
wording), `layout` (plain/info/warning/success), `box` + `box_kind`, `buttons`, `no_buttons`, `form`,
`links`, `before` (order), `absent` (must not show), `optional` (a miss becomes a note), `kind`, `severity`, `timeout`.
An `expect` is judged against the bot messages since the last action. A missed meaning ends the run,
because every later step would fail as a result of it.

## OTP

| Pool `otp.provider` | How the code arrives |
|---|---|
| `mailinator` | Shared private inbox, read through the API. Token from `MAILINATOR_API_TOKEN` (env or `.env`), else Secrets Manager `cct-qa/mailinator-token` via the aws CLI. Matching = "new message since I asked" + first name, so same-name bookings (all v77 = IDRIS) cannot read each other's code. |
| `manual` | The code goes to a real mailbox (all local seed sets: `toula.voulgaris@aircanada.ca`, …). The run prints `code requested for <PNR>` and waits up to 10 min: `npm run otp -- <PNR> 123456`. |
| `fixed` | Local backend only: `ALLOW_FIXED_OTP=1 OTP_FIXED_CODE=123456`. Never QA. |

All providers share one queue: one code request at a time across every worker and run, at least 70 s apart,
and no booking gets more than 5 codes in 24 h (`state/otp-ledger.json`). A wrong code or "couldn't be sent" is
reported as `blocked (OTP: …)` and not retried at once.

## Safety

The suite stops at GenUC-16a (payout country), GenUC-16 (`Yes, proceed`), GenUC-27 (manual-review email) and
GenUC-23 (third-party relationship). This is enforced three ways:

1. `src/guards.ts` refuses forbidden taps and form fills whatever the scenario says.
2. After every action, a stop that is visible ends the run unless the scenario's next step is that `stop`.
3. `npm run test:unit` walks every scenario statically: no forbidden taps, no actions after a stop, no
   bank details, and the upload files exist.

## Bookings

`npm run import-seed -- ../../baggage/*-bag-sit-test-bookings.html` rebuilds the pools. Eleven local sets are
imported (600 bookings). Tags come from the report: `open`, `lost` (open, 21+ days), `recent`, `delivered`,
`closed`, `no-ahl`, `two-bags`, `two-journeys`, `partner`, `waiting`, `outside-21`, `duplicate`, `cap-spent`.
`next-unused` skips bookings used before, reserved by another worker, or with a confirmed claim (those go to
the duplicate-claim road). Usage is kept in `state/booking-ledger.json`.

**All local pools use the `manual` OTP provider.** For unattended runs, add the guide's v77 set (Mailinator inbox)
to `data/bookings.yaml` as shown in its header and run with `booking: { pool: v77, … }`.

## Differences from the guide

- **Message text comes from the DOM, not the console.** The widget's `ac-chat:message` event carries only
  `{participantRole, messageId}` (checked in `ac-chat.js`). The list of messages is found from the
  session-id footers, because class names are styled-components hashes.
- **Screenshots target the panel** (`#ac-chat-widget-container > div`). The container itself has no box and
  `root.screenshot()` times out ("element is not visible").
- **The amount field is matched by its aria-label `Amount in <currency>`.** It has no placeholder, so the
  EUR road uses the same selector.
- **The booking ledger lives in `state/booking-ledger.json`, not in `bookings.yaml`.** Parallel workers
  write it under a lock, and the hand-edited YAML is left alone.
- **On a wrong OTP the run is blocked rather than re-requesting a code.** This keeps the 5-codes-a-day
  budget safe; re-run the scenario later.

## Verified so far (2026-10-08)

- `npm run test:unit`: 36/36 offline checks pass.
- `smoke-menu` live on public-qa/INT: chat opens, the transcript, screenshot and report are produced. It also
  found that the vague opening gets a plain clarifying question ("Would you like help with Baggage Tracing, or
  reporting a Delay/Lost bag?"), not the guide's "Choose one option" menu. This is recorded as a note.
- **Not yet run live:** anything from the identity form onward (identity, OTP, journey, contents, upload,
  stops). Those selectors come from the guide (✅ from the manual runs) and from the widget source. Check
  them on the first runs with a pool you can get codes for. The ⚠️ items are the quantity picker's
  starting value and the multi-select element type.
