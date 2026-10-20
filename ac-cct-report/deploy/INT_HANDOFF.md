# CCT Report Viewer — INT deployment (DEPLOYED)

Deployed to INT via CloudFormation, mirroring `ac-cct-rule-engine-platform/deploy`
(reuses the shared `ask-ac-int` IAM roles — the SSO role cannot create IAM roles,
org SCP `p-w8p5eioi`).

## Live

- **Public URL (browser, anywhere):** `https://cct-report-viewer.ac-cct-int.cloud.aircanada.com`
- **Internal URL (in-VPC direct):**
  `http://internal-cct-report-viewer-int-alb-182128214.ca-central-1.elb.amazonaws.com`
- **Login:** AC SSO (SAML). Basic-auth credentials, if used, live in `deploy/.env.int`.
- **Status:** ECS service `ACTIVE`, 1/1 running, target group **healthy**, gunicorn on :8080;
  verified `HTTP 200` through API Gateway → VPC Link → ALB.

## Public access (API Gateway HTTP API + VPC Link)

CloudFront → the internal ALB is **not possible** here: a CloudFront VPC origin
requires an internet gateway and this VPC has none (by design — it's why every
AC dynamic app is fronted by API Gateway, not CloudFront-to-ALB). So the public
path mirrors `claims-dashboard-service`:

```
browser → https://cct-report-viewer.ac-cct-int.cloud.aircanada.com
        → API Gateway HTTP API  b32106b160  (regional, public)
        → VPC Link  zz8214  (reused; account at the 10-link limit)
        → internal ALB listener :80 → Fargate viewer :8080
```

- **HTTP API:** `cct-report-viewer-int-api` (`b32106b160`), `$default` stage, route
  `ANY $default` → HTTP_PROXY integration to the ALB listener via the VPC link.
- **Custom domain:** `cct-report-viewer.ac-cct-int.cloud.aircanada.com` (REGIONAL,
  TLS 1.2) → regional target `d-qpt9kiep1f.execute-api.ca-central-1.amazonaws.com`.
- **ACM cert (regional, ca-central-1):**
  `arn:aws:acm:ca-central-1:982081066747:certificate/04cfb4de-0272-4998-bfc3-cb5a34b7371d`
  (DNS-validated; validation CNAME left in the public zone).
- **DNS (split-horizon):**
  - **Public** zone `Z0279944320JHG5REM2SF`: `A`-alias → the API Gateway domain (browser path).
  - **Private** zone `Z0174357H0BLFDJP0T1T`: `A`-alias → the internal ALB (in-VPC direct).
  - Same hostname both places; inside the VPC the private zone wins.

Rebuild/repoint with `./deploy/public_access.sh int` (values in `.env.int`).

## What got created (CloudFormation stack `cct-report-viewer-int`)

- ECS cluster `cct-report-viewer-cluster-int`, service `cct-report-viewer-int-service`
- Task def `cct-report-viewer-int-fargate-task` (image
  `982081066747.dkr.ecr.ca-central-1.amazonaws.com/cct-report-viewer:latest`, X86_64)
- Internal ALB `cct-report-viewer-int-alb` (:80 → target group `cct-report-viewer-int-tg` :8080, HC `/healthz`)
- Security groups `cct-report-viewer-alb-sg-int` (:80 from `10.0.0.0/8`) and
  `cct-report-viewer-svc-sg-int` (:8080 from the ALB SG only)
- Log group `/ecs/cct-report-viewer-int`

## What it reuses / touches outside the stack

- **IAM roles (reused, not created):**
  - exec `arn:aws:iam::982081066747:role/ask-ac-int-ECSTaskExecutionRole-CUSwhqRhpsJ9`
  - task `arn:aws:iam::982081066747:role/ask-ac-int-ECSTaskRole-NdehCTOwD0hW`
- **Bucket policy on `cct-qa-results`** (applied by `infrastructure_deploy.sh`):
  grants that task role `s3:GetObject` + `s3:ListBucket` (the shared role had no
  policy for this bucket). Sid `CctReportViewerTaskRoleRead`.
- **Networking (same as rule-engine INT):** VPC `vpc-0761edb89dad92a02`, private
  subnets `subnet-09fb607cb53831fd4,subnet-0d18260c4ab214b73,subnet-0b41d8610a3d0bc54`.

## Redeploy / operate

```bash
# ship a new image + roll the service
AWS_PROFILE=int-sso ./deploy/build_and_deploy.sh int
# change infra / env (updates the stack)
AWS_PROFILE=int-sso ./deploy/infrastructure_deploy.sh int
# logs
AWS_PROFILE=int-sso aws logs tail /ecs/cct-report-viewer-int --follow --region ca-central-1
```

Config lives in `deploy/.env.int` (gitignored). Change `FLASK_SECRET` from the
placeholder for a real deployment.

## Optional follow-ups

- **Friendly DNS:** `./deploy/route53_record.sh int` — upserts
  `cct-report-viewer.ac-cct-int.cloud.aircanada.com` as an A-alias to the
  internal ALB in the private zone `Z0174357H0BLFDJP0T1T` (the one bound to
  `vpc-0761edb89dad92a02`). Resolves inside the VPC only. Writes to a **shared**
  hosted zone, so it may need the platform/DNS role
  (`route53:ChangeResourceRecordSets`). Values live in `deploy/.env.int`
  (`ROUTE53_ZONE_ID`, `ROUTE53_RECORD_NAME`).
- **SSO:** once the IAM Identity Center OIDC app exists, set `AUTH_MODE=sso` +
  `OIDC_*` in `.env.int` and re-run `infrastructure_deploy.sh` — no code change.
