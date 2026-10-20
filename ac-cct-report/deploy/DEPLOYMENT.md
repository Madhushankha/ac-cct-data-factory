# CCT Report Viewer — Deployment Guide

The viewer is a single container (Flask + gunicorn) that reads test-execution reports from **S3**
and shows them behind **AWS SSO** (or a local form login). It is stateless and read-only.

## Contents
1. [Local (Docker Compose)](#1-local-docker-compose)
2. [Environment variables](#2-environment-variables)
3. [S3 layout the viewer expects](#3-s3-layout-the-viewer-expects)
4. [Production on AWS ECS Fargate](#4-production-on-aws-ecs-fargate)
5. [AWS SSO (OIDC) setup](#5-aws-sso-oidc-setup)
6. [Health, logs, troubleshooting](#6-health-logs-troubleshooting)

---

## 1. Local (Docker Compose)

```bash
cp .env.example .env          # fill in S3_BUCKET, DEV_AUTH, FLASK_SECRET
docker-compose -f deploy/docker-compose.yml up -d --build  # -> http://localhost:8090
docker-compose -f deploy/docker-compose.yml logs -f        # watch
docker-compose -f deploy/docker-compose.yml down           # stop
```

The compose file mounts `~/.aws` so boto3 can read S3 with your local AWS profile. With SSO creds,
export them into `.env` first, or add `AWS_PROFILE=<profile>` to `.env`.

Manual (no compose):
```bash
docker build -f deploy/Dockerfile -t cct-report-viewer .
docker run -d --name cct-viewer -p 8090:8080 --env-file .env \
  -v "$HOME/.aws:/root/.aws:ro" cct-report-viewer
```

---

## 2. Environment variables

| Var | Purpose | Local | ECS |
|---|---|---|---|
| `S3_BUCKET` | reports bucket | ✓ | ✓ |
| `AWS_REGION` | bucket region (default `ca-central-1`) | ✓ | ✓ |
| `FLOWS` | comma prefixes (`crt-fd-flow,…`) | ✓ | ✓ |
| `FLASK_SECRET` | session cookie signing (fixed random string) | ✓ | ✓ (Secrets Manager) |
| `DEV_AUTH` | `user:pass` local form login | ✓ | — |
| `OIDC_ISSUER` / `OIDC_CLIENT_ID` / `OIDC_CLIENT_SECRET` / `OIDC_REDIRECT_URI` | AWS SSO login | — | ✓ |
| `AWS_ACCESS_KEY_ID` / `…_SECRET_…` / `…_SESSION_TOKEN` | S3 creds (local only) | ✓ | — (task role) |

Auth rule: if `OIDC_*` is set → **AWS SSO**; else if `DEV_AUTH` is set → **local form login**.

---

## 3. S3 layout the viewer expects

```
s3://<S3_BUCKET>/
├── crt-fd-flow/<run-id>/{index.html, *.evidence.html, *.quality.html, metrics/report.html, *.result.json}
├── crt-soc-flow/<run-id>/…
├── crt-anc-flow/…   crt-bag-flow/…   crt-nonmvp-flow/…
```

The `cct-qa-framework` uploads runs here (a separate task). The viewer never writes.

---

## 4. Production on AWS ECS Fargate

```bash
# 1. Build & push to ECR
aws ecr create-repository --repository-name cct-report-viewer
ACCOUNT=$(aws sts get-caller-identity --query Account --output text); REGION=ca-central-1
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT.dkr.ecr.$REGION.amazonaws.com
docker build -f deploy/Dockerfile -t cct-report-viewer .
docker tag cct-report-viewer $ACCOUNT.dkr.ecr.$REGION.amazonaws.com/cct-report-viewer:latest
docker push $ACCOUNT.dkr.ecr.$REGION.amazonaws.com/cct-report-viewer:latest

# 2. IAM: task role from deploy/iam-task-policy.json (replace BUCKET). Execution role: ECR pull + read the secrets.
# 3. Secrets: put FLASK_SECRET and OIDC_CLIENT_SECRET in Secrets Manager.
# 4. Register the task (fill placeholders in deploy/ecs-task-def.json):
aws ecs register-task-definition --cli-input-json file://deploy/ecs-task-def.json

# 5. Run a Fargate service behind an ALB (HTTPS via ACM); target-group health check = /healthz.
#    Point <viewer-domain> (Route53) at the ALB. Set OIDC_REDIRECT_URI to https://<viewer-domain>/callback.
```

Bucket stays **private**; only the task role reads it (scoped to `*-flow/*`).

---

## 5. AWS SSO (OIDC) setup

1. In **IAM Identity Center → Applications**, add a **custom OIDC** application.
2. Set the **callback / redirect URL** to `https://<viewer-domain>/callback`.
3. Note the **issuer URL**, **client id**, **client secret** → set `OIDC_ISSUER` / `OIDC_CLIENT_ID` /
   `OIDC_CLIENT_SECRET` / `OIDC_REDIRECT_URI`.
4. Assign the users/groups who may view reports.

With `OIDC_*` set, `/login` redirects to Identity Center; users sign in with their AWS SSO identity.

---

## 6. Health, logs, troubleshooting

```bash
curl http://localhost:8090/healthz        # {"ok": true}
docker logs -f cct-report-viewer
```

- **Empty flows / runs** → check `S3_BUCKET`, the task role's S3 read policy, and that reports exist
  under `crt-<flow>-flow/<run-id>/`.
- **Session drops / login loops** → `FLASK_SECRET` must be set and stable across the 2 gunicorn workers.
- **403 on a report** → the key must be under a configured `FLOWS` prefix (`require_auth` + prefix check).
- **SSO redirect fails** → confirm `OIDC_REDIRECT_URI` exactly matches the app's registered callback.
