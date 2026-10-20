# ac-cct-data-factory

End-to-end chat automation for CCT SIT/UAT testing: seed test data per scenario, drive the Ask AC
chat as the customer, validate, and report. Flows today: Flight Disruption, Standard of Care,
Baggage, Ancillary.

| Sub-project | What it is | Start here |
|---|---|---|
| [`ac-cct-data-seed/`](ac-cct-data-seed/) | specs per flow, the seeder (`python -m cli`), and the seeding UI (`python -m ui`) | [README](ac-cct-data-seed/README.md), [ui/README](ac-cct-data-seed/ui/README.md) |
| [`ac-cct-data-automation/`](ac-cct-data-automation/) | the Playwright suite that talks to the product as the customer whose booking was seeded | [playwright-baggage/README](ac-cct-data-automation/playwright-baggage/README.md) |
| [`ac-cct-report/`](ac-cct-report/) | the report viewer: S3 reports, Jira/Xray results, AC SSO | [README](ac-cct-report/README.md) |

## How the halves meet

Seeding writes one pool file per run; automation picks bookings from it by state:

```
ac-cct-data-seed:        python -m cli seed <set> --go --pool
  -> ac-cct-data-automation/playwright-baggage/data/pools/<run>.yaml
ac-cct-data-automation:  booking: { pool: any, pick: next-unused, need: [eligible, appr] }
```

The seeder finds the automation folder as its sibling; `AQA_SEED_AUTOMATION` points elsewhere.
The suite finds `public-qa-chat/` and `baggage/` in this folder's parent or in
`agentic-qa-latest/` beside it; `AQA_WORKSPACE` points elsewhere.

## Where this came from

Copied on 2026-10-20 from the working projects in `agentic-qa-latest/` (which were not changed):

* `ac-cct-data-seed` — everything except `automation/`, with only the latest run per set and
  environment (`runs/<env>/_seeded-history/manifest.json` keeps every seeded case id from the full
  history, so `--skip-seeded` still knows them) and the latest report version per set.
* `ac-cct-data-automation/playwright-baggage` — from `ac-cct-data-seed/automation/`, which is newer
  than the separate `ac-cct-agent-automation` checkout; the 12 latest pools, no old `out/` runs.
* `ac-cct-report` — from `cct-report-viewer`.

`.env` files hold credentials and are not committed; copy them in by hand on a new machine.
