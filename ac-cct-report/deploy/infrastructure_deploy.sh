#!/bin/bash
# ==============================================================================
# Infrastructure Deploy — CCT Report Viewer  (mirrors ac-cct-rule-engine-platform)
# ==============================================================================
# Deploys the CloudFormation stack (SGs, internal ALB, target group, cluster,
# task-def, service, log group) reusing the shared ask-ac-int IAM roles, and
# grants the reused TASK role S3 read on the reports bucket via a bucket policy.
# Usage: ./infrastructure_deploy.sh [environment]   (default: int)
set -e

ENVIRONMENT=${1:-int}
STACK_NAME="cct-report-viewer-${ENVIRONMENT}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Load .env.<env> ───────────────────────────────────────────────────────────
ENV_FILE="${SCRIPT_DIR}/.env.${ENVIRONMENT}"
[ -f "$ENV_FILE" ] || { echo "[ERROR] $ENV_FILE not found"; exit 1; }
echo "[INFO] Loading ${ENV_FILE}"
set -a
while IFS='=' read -r key value; do
  if [ -n "$key" ] && [[ ! "$key" =~ ^# ]]; then
    value=$(echo "$value" | sed 's/#.*//' | xargs)
    export "$key=$value"
  fi
done < <(grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$ENV_FILE")
set +a

AWS_REGION=${AWS_REGION:-ca-central-1}
CF_TEMPLATE="${SCRIPT_DIR}/cloudformation/main.yaml"

# ── Pre-flight ────────────────────────────────────────────────────────────────
command -v aws >/dev/null || { echo "[ERROR] aws CLI not installed"; exit 1; }
aws sts get-caller-identity >/dev/null || { echo "[ERROR] AWS creds not configured"; exit 1; }
[ -f "$CF_TEMPLATE" ] || { echo "[ERROR] template missing: $CF_TEMPLATE"; exit 1; }

IMAGE_URI=${CONTAINER_IMAGE:-${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}}
: "${EXISTING_VPC_ID:?EXISTING_VPC_ID required}"
: "${SUBNET_IDS:?SUBNET_IDS required}"
: "${EXISTING_EXECUTION_ROLE_ARN:?EXISTING_EXECUTION_ROLE_ARN required}"
: "${EXISTING_TASK_ROLE_ARN:?EXISTING_TASK_ROLE_ARN required}"
: "${FLASK_SECRET:?FLASK_SECRET required}"
echo "[INFO] Image: ${IMAGE_URI}"

# ── Step 0: grant the reused TASK role read access to the reports bucket ──────
# The shared ask-ac-int task role has no policy for ${S3_BUCKET}; add a bucket
# policy (bucket-side grant, does NOT modify the shared role).
echo "[INFO] Granting ${EXISTING_TASK_ROLE_ARN} read on s3://${S3_BUCKET} ..."
# Read anywhere in the bucket; WRITE only under ${MAPPING_PREFIX}/ — that is the one thing the
# viewer persists (the test-case -> Jira-issue mapping). It must not be able to write near runs/.
BUCKET_POLICY=$(cat <<JSON
{ "Version":"2012-10-17","Statement":[
  { "Sid":"CctReportViewerTaskRoleRead","Effect":"Allow",
    "Principal":{"AWS":"${EXISTING_TASK_ROLE_ARN}"},
    "Action":["s3:GetObject","s3:ListBucket"],
    "Resource":["arn:aws:s3:::${S3_BUCKET}","arn:aws:s3:::${S3_BUCKET}/*"] },
  { "Sid":"CctReportViewerTaskRoleWriteMappings","Effect":"Allow",
    "Principal":{"AWS":"${EXISTING_TASK_ROLE_ARN}"},
    "Action":["s3:PutObject"],
    "Resource":["arn:aws:s3:::${S3_BUCKET}/${MAPPING_PREFIX:-mappings}/*"] } ] }
JSON
)
aws s3api put-bucket-policy --bucket "${S3_BUCKET}" --policy "$BUCKET_POLICY" --region "$AWS_REGION"
echo "[SUCCESS] Bucket policy applied"

# ── Step 1: deploy the CloudFormation stack ──────────────────────────────────
PARAMS="ParameterKey=Environment,ParameterValue=${ENVIRONMENT}"
PARAMS="${PARAMS} ParameterKey=ContainerImage,ParameterValue=${IMAGE_URI}"
PARAMS="${PARAMS} ParameterKey=ContainerCpu,ParameterValue=${CONTAINER_CPU:-256}"
PARAMS="${PARAMS} ParameterKey=ContainerMemory,ParameterValue=${CONTAINER_MEMORY:-512}"
PARAMS="${PARAMS} ParameterKey=DesiredCount,ParameterValue=${DESIRED_COUNT:-1}"
PARAMS="${PARAMS} ParameterKey=ExistingVpcId,ParameterValue=${EXISTING_VPC_ID}"
PARAMS="${PARAMS} ParameterKey=SubnetIds,ParameterValue=\"${SUBNET_IDS}\""
PARAMS="${PARAMS} ParameterKey=AllowedCidr,ParameterValue=${ALLOWED_CIDR:-10.0.0.0/8}"
PARAMS="${PARAMS} ParameterKey=ExistingExecutionRoleArn,ParameterValue=${EXISTING_EXECUTION_ROLE_ARN}"
PARAMS="${PARAMS} ParameterKey=ExistingTaskRoleArn,ParameterValue=${EXISTING_TASK_ROLE_ARN}"
PARAMS="${PARAMS} ParameterKey=S3Bucket,ParameterValue=${S3_BUCKET}"
PARAMS="${PARAMS} ParameterKey=RunsPrefix,ParameterValue=${RUNS_PREFIX:-runs}"
PARAMS="${PARAMS} ParameterKey=MappingPrefix,ParameterValue=${MAPPING_PREFIX:-mappings}"
PARAMS="${PARAMS} ParameterKey=AuthMode,ParameterValue=${AUTH_MODE:-basic}"
PARAMS="${PARAMS} ParameterKey=DevAuth,ParameterValue=${DEV_AUTH}"
PARAMS="${PARAMS} ParameterKey=AuthServiceUrl,ParameterValue=${AUTH_SERVICE_URL:-https://ac-cct-int.cloud.aircanada.com}"
PARAMS="${PARAMS} ParameterKey=AppName,ParameterValue=${APP_NAME:-cct-report-viewer}"
PARAMS="${PARAMS} ParameterKey=FlaskSecret,ParameterValue=${FLASK_SECRET}"
PARAMS="${PARAMS} ParameterKey=JiraBaseUrl,ParameterValue=${JIRA_BASE_URL:-https://aircanada.atlassian.net}"
PARAMS="${PARAMS} ParameterKey=JiraProject,ParameterValue=${JIRA_PROJECT:-CHAI}"
PARAMS="${PARAMS} ParameterKey=JiraEmail,ParameterValue=${JIRA_EMAIL}"
PARAMS="${PARAMS} ParameterKey=JiraApiToken,ParameterValue=${JIRA_API_TOKEN}"
PARAMS="${PARAMS} ParameterKey=XrayBaseUrl,ParameterValue=${XRAY_BASE_URL:-https://xray.cloud.getxray.app}"
PARAMS="${PARAMS} ParameterKey=XrayClientId,ParameterValue=${XRAY_CLIENT_ID}"
PARAMS="${PARAMS} ParameterKey=XrayClientSecret,ParameterValue=${XRAY_CLIENT_SECRET}"
PARAMS="${PARAMS} ParameterKey=JiraWrite,ParameterValue=${JIRA_WRITE:-0}"

echo "[INFO] Validating template ..."
aws cloudformation validate-template --template-body "$(cat "${CF_TEMPLATE}")" --region "$AWS_REGION" >/dev/null
echo "[SUCCESS] Template valid"

STACK_STATUS=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$AWS_REGION" \
  --query 'Stacks[0].StackStatus' --output text 2>/dev/null || echo "")

if [ -z "$STACK_STATUS" ]; then
  echo "[INFO] Creating stack ${STACK_NAME}"
  aws cloudformation create-stack --stack-name "$STACK_NAME" --template-body "$(cat "${CF_TEMPLATE}")" \
    --parameters ${PARAMS} --capabilities CAPABILITY_IAM --region "$AWS_REGION"
  aws cloudformation wait stack-create-complete --stack-name "$STACK_NAME" --region "$AWS_REGION"
elif [[ "$STACK_STATUS" == "ROLLBACK_COMPLETE" || "$STACK_STATUS" == "*_FAILED" ]]; then
  echo "[WARN] Stack in ${STACK_STATUS}; deleting + recreating"
  aws cloudformation delete-stack --stack-name "$STACK_NAME" --region "$AWS_REGION"
  aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME" --region "$AWS_REGION"
  aws cloudformation create-stack --stack-name "$STACK_NAME" --template-body "$(cat "${CF_TEMPLATE}")" \
    --parameters ${PARAMS} --capabilities CAPABILITY_IAM --region "$AWS_REGION"
  aws cloudformation wait stack-create-complete --stack-name "$STACK_NAME" --region "$AWS_REGION"
else
  echo "[INFO] Updating stack ${STACK_NAME}"
  aws cloudformation update-stack --stack-name "$STACK_NAME" --template-body "$(cat "${CF_TEMPLATE}")" \
    --parameters ${PARAMS} --capabilities CAPABILITY_IAM --region "$AWS_REGION" 2>&1 \
    || echo "[INFO] No updates needed"
  aws cloudformation wait stack-update-complete --stack-name "$STACK_NAME" --region "$AWS_REGION" 2>/dev/null || true
fi

echo ""
echo "[SUCCESS] ============================================================"
echo "[SUCCESS] CCT Report Viewer infrastructure deployed"
echo "[SUCCESS] ============================================================"
aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$AWS_REGION" \
  --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' --output table
echo ""
echo "[INFO] Logs: aws logs tail /ecs/cct-report-viewer-${ENVIRONMENT} --follow --region ${AWS_REGION}"
