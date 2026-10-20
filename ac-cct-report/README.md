# CCT Report Viewer

A small, standalone web app that shows **test-execution reports from S3**, hosted on **ECS Fargate**,
exposed publicly through **API Gateway**, and gated by **AC SSO (SAML)**.
It is **read-only** — it does not seed data or run tests; it just browses and serves the reports the
`cct-qa-framework` produces.

- **Public URL (INT):** https://cct-report-viewer.ac-cct-int.cloud.aircanada.com
- **Always-works fallback:** https://b32106b160.execute-api.ca-central-1.amazonaws.com
- **Login:** AC SSO (SAML). For a local `basic` run, set `DEV_AUTH` in `.env`.

## What it does

- Lists **envs → flows → runs → report files** from the S3 bucket.
- Shows **Jira tickets per flow** and **Xray test-execution results** (SIT / UAT), and can
  create or update the Jira bug for a failing test case with its evidence attached.
- Streams each report file from S3 through the ECS **task role** — the bucket stays private, no keys in code.
- Every route requires an authenticated session (AC SSO via the shared SAML broker, or a local form login in `basic` mode).

## Architecture

Full detail in [`deploy/ARCHITECTURE.md`](deploy/ARCHITECTURE.md). In brief:

```
browser ─HTTPS─► API Gateway (regional, public) ─► VPC Link ─► INTERNAL ALB :80 ─► Fargate gunicorn :8080 ─► S3
in-VPC  ────────────────────────────────────────────────────► INTERNAL ALB :80 ─► (same)
```

- The ALB is **internal** (private subnets, no public IP); the VPC has **no internet gateway**, so
  CloudFront→ALB is impossible. Public access uses **API Gateway + a VPC Link** — the same pattern
  every AC dynamic backend uses (e.g. `claims-dashboard-service`).
- **Split-horizon DNS:** the one hostname resolves to API Gateway on the public internet and to the
  ALB directly inside the VPC. See ARCHITECTURE.md §4.

## S3 layout (the reports source)

Bucket **`cct-qa-artifacts-int`** (INT, `ca-central-1`), laid out as
**`runs/<ENV>/<FLOW>/<run-id>/`**:

```
s3://cct-qa-artifacts-int/
  runs/int/fd/fd_int_bravo_2026-08-12_200227/
      index.html                 run summary / landing page
      <case>.evidence.html       per-test evidence (drives the test list)
      <case>.quality.html        per-test quality report
      <case>.result.json         raw per-test result (verdict, expected vs actual)
      metrics/report.html        metrics dashboard
      metrics/metrics.json       aggregate metrics
      analysis/analysis.json     aggregate analysis
      bot-issues.html  quality-index.html
  runs/int/anc/…  runs/int/soc/…  runs/int/baggage/…  (9 flows)
  datasets/<env>/<flow>/<version>/    seed data — NOT served by the viewer
  indexes/<env>/{runs,datasets}.json  producer job log — deliberately NOT used
```

**Envs, flows, runs and run versions are all auto-discovered** by listing prefixes, so a new run —
or a new `…-run-v2` — appears with no redeploy and no config. `ENVS` can pin the env list.

The `indexes/*.json` manifests are the producer's job log: they miss runs that exist and list runs
that never produced artifacts, so discovery never reads them.

`datasets/` and `indexes/` sit alongside `runs/`, which is why discovery starts at `RUNS_PREFIX`
rather than the bucket root — and why `/report/<key>` rejects any key outside it.

The task role is granted `s3:GetObject` + `s3:ListBucket` on this bucket via a **bucket policy**
applied by `infrastructure_deploy.sh` (the shared `ask-ac-int` task role has no inline policy for it).

## Environment variables

All are read by `app.py` and set in the CloudFormation task definition (or `.env` for local Docker).

| var | required | default | purpose |
|---|---|---|---|
| `S3_BUCKET` | ✅ | — | reports bucket name (`cct-qa-artifacts-int`) |
| `AWS_REGION` | | `ca-central-1` | bucket region |
| `RUNS_PREFIX` | | `runs` | top-level prefix holding the runs |
| `ENVS` | | *(auto-discover)* | optional comma list pinning the envs (e.g. `int,crt`) |
| `AUTH_MODE` | | `basic` | `saml` = AC SSO via the shared broker; `basic` = local username/password form login |
| `DEV_AUTH` | when `basic` | — | `user:pass` for the form login (set it in `.env`; never commit it) |
| `FLASK_SECRET` | ✅ | dev fallback | **fixed** random string for the session cookie (stable across gunicorn workers) |
| `AUTH_SERVICE_URL` | when `saml` | `https://ac-cct-int.cloud.aircanada.com` | the shared AC auth broker |
| `APP_NAME` | when `saml` | `cct-report-viewer` | this app's name registered with the broker (`/login/<APP_NAME>`) |
| `PORT` | | `8080` | listen port (container/local) |
| `JIRA_BASE_URL` | | `https://aircanada.atlassian.net` | Jira Cloud instance |
| `JIRA_PROJECT` | | `CHAI` | project the tickets live in |
| `JIRA_EMAIL` / `JIRA_API_TOKEN` | for Jira views | — | Jira auth; blank disables the Jira tabs |
| `XRAY_CLIENT_ID` / `XRAY_CLIENT_SECRET` | for exec results | — | Xray Cloud API credentials |
| `JIRA_WRITE` | | `1` | `0` = Jira dashboards read-only, the bug button cannot write |
| `JIRA_DB` | | `/tmp/cct-jira.db` | SQLite case→issue mapping. Must be a FILE, not `:memory:` |
| `JIRA_CACHE_TTL` | | `300` | seconds to cache the Jira/Xray roll-ups |

On ECS the **task role** supplies AWS credentials for S3 — do **not** set access keys there. For local
Docker, mount `~/.aws` or paste temporary creds (see `.env.example`).

## Run locally

```bash
pip install -r requirements.txt
AUTH_MODE=basic DEV_AUTH=<user>:<pass> S3_BUCKET=cct-qa-artifacts-int \
  AWS_PROFILE=int-sso FLASK_SECRET=dev python app.py
# http://localhost:8080   (login with your DEV_AUTH; S3 calls use your AWS profile)
```
Or containerised: `./deploy/run-local.sh` (reads `.env`; see `.env.example`).

## Deploy (INT)

The deploy mirrors `ac-cct-rule-engine-platform` (CloudFormation + `.env.<env>` + shell scripts).
Config lives in `deploy/.env.int`.

```bash
# 1. stand up / update the stack FIRST when config changed — build_and_deploy.sh
#    force-rolls the service, so pushing first would run new code on old config.
AWS_PROFILE=int-sso ./deploy/infrastructure_deploy.sh int

# 2. build + push the image (and roll the service): SGs, internal ALB, ECS service, log group,
#    + the cct-qa-artifacts-int bucket policy for the task role
AWS_PROFILE=int-sso ./deploy/build_and_deploy.sh int

# 3. public access: API Gateway HTTP API + VPC Link + custom domain + public DNS
AWS_PROFILE=int-sso ./deploy/public_access.sh int

# optional: internal-only friendly DNS (A-alias → ALB in the private zone)
AWS_PROFILE=int-sso ./deploy/route53_record.sh int
```

Operational values, resource IDs, and the handoff notes are in
[`deploy/INT_HANDOFF.md`](deploy/INT_HANDOFF.md); the deploy guide is
[`deploy/DEPLOYMENT.md`](deploy/DEPLOYMENT.md).

## SSO (AC SAML)

Auth is handled by the **shared Air Canada auth broker** — Microsoft (Entra/Azure AD) SAML behind
`https://ac-cct-int.cloud.aircanada.com`. It is **not** OIDC / IAM Identity Center; the app never
sees a SAML assertion or parses the JWT, it just rides the broker's session:

```
/login      -> https://ac-cct-int.cloud.aircanada.com/login/cct-report-viewer
broker      -> Microsoft SAML -> validates -> sets cookie cct_auth_token
                (Domain=.ac-cct-int.cloud.aircanada.com, shared across subdomains)
broker      -> https://cct-report-viewer.ac-cct-int.cloud.aircanada.com/callback
/callback   -> GET <broker>/auth/validate with that cookie -> 200 {user{…}} | 401
/logout     -> clears the local session, then the broker's /logout
```

Registered with the broker:

| | |
|---|---|
| Login | `https://ac-cct-int.cloud.aircanada.com/login/cct-report-viewer` |
| Callback | `https://cct-report-viewer.ac-cct-int.cloud.aircanada.com/callback` |

Toggle with `AUTH_MODE` in `deploy/.env.int` (`saml` ⇄ `basic`) and re-run
`infrastructure_deploy.sh int` — no code change.

**Note on `/callback` responses:** `401` means the broker rejected the token; **`503` means the
broker was unreachable** (network/egress). They're deliberately distinct — the ECS tasks sit in
private subnets whose only default route is a transit gateway, so "can't reach SSO" must not be
mistaken for "bad token". Egress was verified working from the tasks.

## Repo layout

```
app.py                          Flask server (auth + S3 API + file streaming + /api/jira/*)
jira_client.py                  Jira/Xray reads, the case→issue mapping store, and the bug writes
jira_flows.json                 flow → Jira component → Xray Test Execution map (edit, no redeploy)
static/index.html               UI: Reports | Jira tickets | Test executions | Case mapping
requirements.txt                Flask, boto3, requests, gunicorn
.env.example                    local config template
deploy/
  Dockerfile                    container image (gunicorn :8080, health /healthz)
  docker-compose.yml            local container run
  run-local.sh                  local run helper
  cloudformation/main.yaml      the INT stack (SGs, ALB, ECS, log group)
  .env.int                      INT config (gitignored)
  infrastructure_deploy.sh      deploy the stack + bucket policy
  build_and_deploy.sh           build/push image + roll service
  public_access.sh              API Gateway + VPC Link + custom domain + public DNS
  route53_record.sh             optional internal-only friendly DNS
  ARCHITECTURE.md               full end-to-end architecture + rationale
  INT_HANDOFF.md                live URLs, resource IDs, operate/redeploy
  DEPLOYMENT.md                 deploy guide
```

## Security notes

- The bucket stays **private**; only the task role reads it, scoped to `*-flow/*`.
- Every report access requires an authenticated session, including `/report/<key>`.
- `FLASK_SECRET`, `JIRA_API_TOKEN` and `XRAY_CLIENT_SECRET` reach the task as plaintext env
  vars today; move them to Secrets Manager before prod.
- INT runs `AUTH_MODE=saml`, so the public URL is gated by AC SSO.
- `JIRA_WRITE=0` in INT: the Jira views are read-only and the bug button cannot write.
- Nothing in the codebase issues an HTTP DELETE against Jira.
