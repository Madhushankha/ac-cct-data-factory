#!/bin/bash
# ==============================================================================
# Build & Deploy — CCT Report Viewer  (mirrors ac-cct-rule-engine-platform)
# ==============================================================================
# Builds the Docker image, pushes to ECR, then force-redeploys the ECS service
# (the CloudFormation stack from infrastructure_deploy.sh owns the task-def and
# service; this script just ships a new image). Run infrastructure_deploy.sh
# first for the initial stand-up.
# Usage: ./build_and_deploy.sh [environment]   (default: int)
set -e

ENVIRONMENT=${1:-int}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}
ECR_REPOSITORY=${ECR_REPOSITORY:-cct-report-viewer}
IMAGE_TAG=${IMAGE_TAG:-latest}
BUILD_PLATFORM=${BUILD_PLATFORM:-linux/amd64}
CLUSTER="cct-report-viewer-cluster-${ENVIRONMENT}"
SERVICE="cct-report-viewer-${ENVIRONMENT}-service"

command -v aws >/dev/null    || { echo "[ERROR] aws CLI not installed"; exit 1; }
command -v docker >/dev/null || { echo "[ERROR] docker not installed"; exit 1; }
docker info >/dev/null 2>&1  || { echo "[ERROR] docker daemon not running"; exit 1; }

REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
ECR_IMAGE="${REGISTRY}/${ECR_REPOSITORY}"
GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo local)

echo "[INFO] Ensuring ECR repo exists ..."
aws ecr describe-repositories --repository-names "$ECR_REPOSITORY" --region "$AWS_REGION" >/dev/null 2>&1 \
  || aws ecr create-repository --repository-name "$ECR_REPOSITORY" --region "$AWS_REGION" \
       --image-scanning-configuration scanOnPush=true --encryption-configuration encryptionType=AES256 >/dev/null

echo "[INFO] Logging in to ECR ..."
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$REGISTRY"

echo "[INFO] Building ${ECR_IMAGE}:${IMAGE_TAG} (${BUILD_PLATFORM}) ..."
cd "${SCRIPT_DIR}/.."
DOCKER_BUILDKIT=1 docker build --platform "$BUILD_PLATFORM" -f deploy/Dockerfile \
  -t "${ECR_IMAGE}:${IMAGE_TAG}" -t "${ECR_IMAGE}:${GIT_SHA}" .

echo "[INFO] Pushing ..."
docker push "${ECR_IMAGE}:${IMAGE_TAG}"
docker push "${ECR_IMAGE}:${GIT_SHA}"

echo "[INFO] Force-redeploying ${CLUSTER}/${SERVICE} ..."
if aws ecs describe-services --cluster "$CLUSTER" --services "$SERVICE" --region "$AWS_REGION" \
     --query 'services[0].status' --output text 2>/dev/null | grep -q ACTIVE; then
  aws ecs update-service --cluster "$CLUSTER" --service "$SERVICE" --force-new-deployment \
    --region "$AWS_REGION" --query 'service.{status:status,desired:desiredCount}' --output json
else
  echo "[INFO] Service not up yet — run ./infrastructure_deploy.sh ${ENVIRONMENT} to create the stack."
fi

echo "[SUCCESS] Image ${ECR_IMAGE}:${IMAGE_TAG} pushed."
