# CCT Report Viewer — INT Architecture

End-to-end picture of what runs, how a request reaches it, and *why* each choice
was made. Companion to `INT_HANDOFF.md` (operational values) and the scripts.

## 1. What it is

A read-only Flask app (gunicorn) that lists and streams test-execution reports
from `s3://cct-qa-results/<SUITE>/<FLOW>/<run-id>/…` (e.g. `UAT/FD/<run>/`). One
container, port 8080, health check `/healthz`. Login is basic-auth
(credentials in `deploy/.env.int`, never in git) until AUTH_MODE=saml is flipped on.

**Suite dimension.** The top level of the bucket is the test suite — **SIT** vs
**UAT** — surfaced as a toggle in the UI header. Suites and flows are
auto-discovered by listing prefixes, so a new suite/flow/run appears without a
redeploy. The API threads `suite` through every endpoint
(`/api/flows|runs|files|runsummary|analytics`, `/download`), and raw-key routes
(`/report/<key>`, `/download?file=`) validate that the key sits under a real
`<suite>/<flow>/<run>/` prefix — segments are charset-restricted so a crafted
path can't traverse out (this replaced the old fixed `FLOWS` allowlist).

## 2. Request path (runtime)

```
                    ┌─────────────────── PUBLIC (browser, anywhere) ───────────────────┐
                    │                                                                   │
 browser ──HTTPS──► Route53 PUBLIC zone (Z0279944320JHG5REM2SF)                         │
 https://cct-report-viewer.ac-cct-int.cloud.aircanada.com                               │
                    │  A-alias                                                          │
                    ▼                                                                   │
        API Gateway HTTP API  b32106b160  (regional, public, TLS via ACM cert)          │
        custom domain d-qpt9kiep1f.execute-api.ca-central-1.amazonaws.com               │
                    │  route  ANY $default  →  HTTP_PROXY integration                   │
                    ▼                                                                   │
        VPC Link  zz8214  (managed ENIs INSIDE vpc-0761edb89dad92a02)                   │
                    │  forwards to the ALB listener :80                                 │
                    ▼                                                                   │
        INTERNAL ALB  cct-report-viewer-int-alb  :80 ──► target group :8080             │
                    │                                                                   │
                    ▼                                                                   │
        Fargate task (gunicorn :8080)  ──► reads S3 cct-qa-results (task-role creds)    │
                    └───────────────────────────────────────────────────────────────────┘

 in-VPC caller ──► Route53 PRIVATE zone (Z0174357H0BLFDJP0T1T) ──A-alias──► same ALB directly
```

**Public** requests go browser → API Gateway → VPC Link → ALB → app.
**In-VPC** callers skip API Gateway and hit the ALB directly (see DNS below).

## 3. Why API Gateway and NOT CloudFront

The ALB is **internal** (private subnets, `assignPublicIp: DISABLED`) and the VPC
`vpc-0761edb89dad92a02` **has no internet gateway** — by design. CloudFront can
only reach an internal ALB through a *VPC origin*, and AWS requires the VPC to
have an internet gateway for that. It doesn't, so CloudFront→ALB is impossible.

That is exactly why **no AC app** fronts an ALB with CloudFront. Their dynamic
backends use **API Gateway** (a public, AWS-managed front that reaches into the
private VPC over a VPC Link) — e.g. `claims-dashboard-service`. We mirror that
proven pattern. CloudFront in this account only fronts *static S3* frontends.

## 4. DNS — split-horizon, and the "host" question

The **same hostname** `cct-report-viewer.ac-cct-int.cloud.aircanada.com` exists in
two Route53 zones, and the answer you get depends on where you ask from:

| Zone | Type | Alias target | Who resolves it | Path |
|------|------|--------------|-----------------|------|
| PUBLIC `Z0279944320JHG5REM2SF` | A-alias | API Gateway domain | the internet | browser → API GW → VPC Link → ALB |
| PRIVATE `Z0174357H0BLFDJP0T1T` (bound to our VPC) | A-alias | internal ALB | only inside the VPC | ALB direct |

Inside the VPC the private zone wins (Route53 split-horizon), so in-VPC traffic
takes the short path straight to the ALB and never touches API Gateway. Outside,
only the public zone is visible, so browsers go through API Gateway. One name,
one login, two optimal paths — nobody has to remember two URLs.

**On the Host header:** API Gateway's `HTTP_PROXY` integration forwards the
request (including `Host: cct-report-viewer.ac-cct-int…`) to the ALB. The Flask
app doesn't pin/validate `Host`, so it serves normally regardless of which
hostname or path came in — that's why both the friendly domain and the raw
`…execute-api…` endpoint work against the same backend.

**TTL gotcha we hit:** the public zone's SOA negative-cache TTL is 86400 (24h).
A DNS query made *before* the record existed cached NXDOMAIN for a day on that
resolver (Cloudflare 1.1.1.1 / WARP). Lesson: create the record first, then
resolve. The raw `https://b32106b160.execute-api.ca-central-1.amazonaws.com/` is
the always-works fallback (its hostname is never negatively cached).

## 5. Build & infra layer

- **Image:** `982081066747.dkr.ecr.ca-central-1.amazonaws.com/cct-report-viewer:latest`
  (x86_64), built/pushed by `build_and_deploy.sh`.
- **CloudFormation stack `cct-report-viewer-int`** (`infrastructure_deploy.sh` →
  `cloudformation/main.yaml`): SGs, internal ALB + target group (`/healthz`),
  ECS cluster + service + task-def, log group. **Reuses the shared `ask-ac-int`
  IAM roles** — the SSO role can't create IAM roles (org SCP `p-w8p5eioi`), and
  the reference platform does the same.
- **S3 access:** the shared task role had no policy for `cct-qa-results`, so a
  **bucket policy** on that bucket grants it `GetObject`/`ListBucket`
  (bucket-side grant; the shared role is untouched).
- **Public layer** (`public_access.sh`): API Gateway HTTP API + integration +
  route + `$default` stage, regional custom domain + ACM cert, public DNS alias.
  The **VPC Link is reused** (`zz8214`) because the account is at the 10-link
  service-quota limit; it's pure network plumbing and the ALB SG already admits
  the whole VPC CIDR on :80.

## 6. Resource inventory (INT)

| Thing | ID / name |
|-------|-----------|
| ECS cluster / service | `cct-report-viewer-cluster-int` / `cct-report-viewer-int-service` |
| Task definition | `cct-report-viewer-int-fargate-task` |
| Internal ALB | `cct-report-viewer-int-alb` (`a85979808ea49a1d`) |
| API Gateway HTTP API | `b32106b160` (`cct-report-viewer-int-api`) |
| API custom domain | `d-qpt9kiep1f.execute-api.ca-central-1.amazonaws.com` |
| VPC Link (reused) | `zz8214` |
| Regional cert (ca-central-1) | `…/certificate/04cfb4de-0272-4998-bfc3-cb5a34b7371d` |
| Public / private zone | `Z0279944320JHG5REM2SF` / `Z0174357H0BLFDJP0T1T` |
| Exec / task role (reused) | `ask-ac-int-ECSTaskExecutionRole-CUSwhqRhpsJ9` / `ask-ac-int-ECSTaskRole-NdehCTOwD0hW` |

## 7. Authentication (AC SSO — SAML, not OIDC)

`AUTH_MODE=saml` puts the viewer behind the **shared AC auth broker** (Microsoft
Entra SAML fronted by an API Gateway at `ac-cct-int.cloud.aircanada.com`) — the
same broker `askac`, `bravo`, `acpedia` and `claims-dashboard` use.

```
/login  -> <broker>/login/cct-report-viewer -> Microsoft SAML -> broker validates
        -> sets JWT cookie cct_auth_token (Domain=.ac-cct-int.cloud.aircanada.com)
        -> back to https://cct-report-viewer.ac-cct-int.cloud.aircanada.com/callback
/callback -> GET <broker>/auth/validate (with the cookie) -> 200 {user{…}} | 401
```

The app never parses the SAML assertion or the JWT — the broker owns both. This
is **not** OIDC/IAM Identity Center: there is no discovery document, no code
exchange, no token/userinfo endpoint (an earlier OIDC implementation was removed
because it could not work against this broker).

`/callback` distinguishes **401** (token rejected) from **503** (broker
unreachable) on purpose: the tasks' only default route is the transit gateway
`tgw-040d00704a8a525c2` — there is no NAT — so egress failure is a plausible
runtime fault and must not be misreported as a bad token. Egress to the broker
was verified working from the running tasks.

`AUTH_MODE=basic` keeps the local username/password form login for dev.

**Security posture:** in `basic` mode the public URL is gated only by a shared
password — acceptable for INT, which is why `saml` is the intended production
setting. Flipping between them is env-only.
