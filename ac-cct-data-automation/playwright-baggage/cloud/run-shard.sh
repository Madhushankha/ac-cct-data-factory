#!/bin/bash
# One ECS task = one slice of a goal plan.
#   PLAN_S3   s3://.../plan.json   the goal plan (written by the launcher)
#   SHARD     i/n                  which slice this task runs (Playwright --shard)
#   RUN_S3    s3://.../<run-id>/   where this task's evidence goes (shard-<i>/ under it)
#   ENV       int | bat            the chat under test (src/envs.ts)
#   WORKERS   chats in parallel inside this task (default 2)
# Credentials: the task role (TASK_ROLE=1). The uat2 login arrives as UAT2_USER / UAT2_PASS from
# Secrets Manager via the task definition; nothing secret is baked into the image.
set -uo pipefail
cd /app
# secrets the task role (cct-qa-task-role) may read: cct-qa/*. Loaded into the environment, never printed.
#   cct-qa/uat2-basic-auth      {"user": "...", "pass": "..."}   the BAT chat page's login (BAT runs)
#   cct-qa/bat-dashboard-key    {"TESTING_CASE_INFO_API_KEY": "..."}   BAT Claims Dashboard checks
secret() { aws secretsmanager get-secret-value --secret-id "$1" --query SecretString --output text 2>/dev/null; }
if [ "${ENV:-int}" = "bat" ]; then
  s=$(secret cct-qa/uat2-basic-auth) && {
    export UAT2_USER=$(printf '%s' "$s" | node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(0,"utf8")).user||"")')
    export UAT2_PASS=$(printf '%s' "$s" | node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(0,"utf8")).pass||"")'); }
  [ -n "${UAT2_USER:-}" ] || echo "warning: no cct-qa/uat2-basic-auth secret; the BAT page will answer 401"
  k=$(secret cct-qa/bat-dashboard-key) && export TESTING_CASE_INFO_API_KEY=$(printf '%s' "$k" | node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(0,"utf8")).TESTING_CASE_INFO_API_KEY||"")')
fi
aws s3 cp "$PLAN_S3" /app/data/plans/cloud-plan.json --only-show-errors || { echo "cannot read $PLAN_S3"; exit 2; }
i="${SHARD%%/*}"
export GOAL_PLAN=/app/data/plans/cloud-plan.json RUN_NAME="cloud-shard-$i" WORKERS="${WORKERS:-2}"
npx playwright test --project=goal --shard="$SHARD" --reporter=list
code=$?
run_dir=$(ls -td out/*_cloud-shard-"$i"_* 2>/dev/null | head -1)
if [ -n "$run_dir" ]; then
  npx tsx scripts/evidence.ts "$run_dir" >/dev/null 2>&1 || true
  aws s3 cp "$run_dir" "${RUN_S3%/}/shard-$i/" --recursive --exclude "*.webm" --exclude "test-results/*" --only-show-errors
  echo "uploaded $run_dir -> ${RUN_S3%/}/shard-$i/"
  # and in the report viewer's layout (index.html + <case>.evidence.html + <case>.result.json), one viewer
  # run per shard: RUN_ID-s<i> under runs/<ENV>/<FLOW>/<SUITE>/
  if [ -n "${RUN_ID:-}" ] && [ -n "${FLOW:-}" ]; then
    npx tsx scripts/upload.ts "$run_dir" --flow "$FLOW" ${SUITE:+--suite "$SUITE"} --env "${ENV:-int}" --run-id "${RUN_ID}-s$i" || true
  fi
fi
exit $code
