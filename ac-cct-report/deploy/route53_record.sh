#!/bin/bash
# ==============================================================================
# Route53 friendly name — CCT Report Viewer  (OPTIONAL, run after the stack)
# ==============================================================================
# Upserts an A-alias record (ROUTE53_RECORD_NAME) pointing at the internal ALB
# created by the CloudFormation stack, in the private zone ROUTE53_ZONE_ID.
# Resolves inside the VPC only (corp network / VPN). Writes to a SHARED hosted
# zone — needs route53:ChangeResourceRecordSets (may require the platform role).
# Usage: ./route53_record.sh [environment]   (default: int)
set -e

ENVIRONMENT=${1:-int}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ENV_FILE="${SCRIPT_DIR}/.env.${ENVIRONMENT}"
[ -f "$ENV_FILE" ] || { echo "[ERROR] $ENV_FILE not found"; exit 1; }
set -a
while IFS='=' read -r key value; do
  if [ -n "$key" ] && [[ ! "$key" =~ ^# ]]; then
    value=$(echo "$value" | sed 's/#.*//' | xargs)
    export "$key=$value"
  fi
done < <(grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$ENV_FILE")
set +a

AWS_REGION=${AWS_REGION:-ca-central-1}
ALB_NAME="cct-report-viewer-${ENVIRONMENT}-alb"
: "${ROUTE53_ZONE_ID:?ROUTE53_ZONE_ID required in .env.${ENVIRONMENT}}"
: "${ROUTE53_RECORD_NAME:?ROUTE53_RECORD_NAME required in .env.${ENVIRONMENT}}"

echo "[INFO] Looking up ALB ${ALB_NAME} ..."
read -r ALB_DNS ALB_ZONE < <(aws elbv2 describe-load-balancers --names "$ALB_NAME" \
  --region "$AWS_REGION" \
  --query 'LoadBalancers[0].[DNSName,CanonicalHostedZoneId]' --output text)
[ -n "$ALB_DNS" ] || { echo "[ERROR] ALB ${ALB_NAME} not found — deploy the stack first"; exit 1; }
echo "[INFO] ${ROUTE53_RECORD_NAME}  ->  ${ALB_DNS}  (alias zone ${ALB_ZONE})"

# Single-line JSON on purpose: a heredoc picks up CRLF line endings on Windows
# checkouts and injects a \r that breaks --change-batch JSON parsing.
CHANGE="{\"Changes\":[{\"Action\":\"UPSERT\",\"ResourceRecordSet\":{\"Name\":\"${ROUTE53_RECORD_NAME}\",\"Type\":\"A\",\"AliasTarget\":{\"HostedZoneId\":\"${ALB_ZONE}\",\"DNSName\":\"${ALB_DNS}\",\"EvaluateTargetHealth\":true}}}]}"
aws route53 change-resource-record-sets --hosted-zone-id "$ROUTE53_ZONE_ID" \
  --change-batch "$CHANGE" --query 'ChangeInfo.Status' --output text

echo ""
echo "[SUCCESS] URL (internal / VPN): http://${ROUTE53_RECORD_NAME}"
