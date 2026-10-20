#!/bin/bash
# ==============================================================================
# Public access — CCT Report Viewer  (API Gateway HTTP API + VPC Link → ALB)
# ==============================================================================
# The viewer's ALB is INTERNAL and its VPC has no internet gateway, so CloudFront
# -> ALB (VPC origin) is not possible. AC's pattern for a public dynamic backend
# is API Gateway (regional, public, AWS-managed) with a VPC Link into the private
# ALB — this is how claims-dashboard-service is exposed. This script builds that
# and points the PUBLIC hosted zone at the API Gateway regional domain.
#
# Prereqs already satisfied for INT (documented in INT_HANDOFF.md); re-run pieces
# only if rebuilding. Needs apigatewayv2 + acm + route53 permissions.
# Usage: ./public_access.sh [environment]   (default: int)
set -e

ENVIRONMENT=${1:-int}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env.${ENVIRONMENT}"
[ -f "$ENV_FILE" ] || { echo "[ERROR] $ENV_FILE not found"; exit 1; }
set -a
while IFS='=' read -r key value; do
  if [ -n "$key" ] && [[ ! "$key" =~ ^# ]]; then
    value=$(echo "$value" | sed 's/#.*//' | xargs); export "$key=$value"; fi
done < <(grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$ENV_FILE")
set +a

AWS_REGION=${AWS_REGION:-ca-central-1}
DOMAIN="${PUBLIC_DOMAIN:?PUBLIC_DOMAIN required in .env.${ENVIRONMENT}}"
API_NAME="cct-report-viewer-${ENVIRONMENT}-api"
ALB_NAME="cct-report-viewer-${ENVIRONMENT}-alb"
: "${PUBLIC_ZONE_ID:?PUBLIC_ZONE_ID required}"       # public hosted zone
: "${VPC_LINK_ID:?VPC_LINK_ID required}"             # existing in-VPC API GW v2 VPC link
: "${REGIONAL_CERT_ARN:?REGIONAL_CERT_ARN required}" # ACM cert in ${AWS_REGION} for ${DOMAIN}

echo "[INFO] ALB listener ..."
ALB_ARN=$(aws elbv2 describe-load-balancers --names "$ALB_NAME" --region "$AWS_REGION" \
  --query 'LoadBalancers[0].LoadBalancerArn' --output text)
LISTENER=$(aws elbv2 describe-listeners --load-balancer-arn "$ALB_ARN" --region "$AWS_REGION" \
  --query 'Listeners[?Port==`80`].ListenerArn' --output text)

echo "[INFO] HTTP API ..."
API=$(aws apigatewayv2 get-apis --region "$AWS_REGION" \
  --query "Items[?Name=='${API_NAME}'].ApiId" --output text)
if [ -z "$API" ] || [ "$API" = "None" ]; then
  API=$(aws apigatewayv2 create-api --region "$AWS_REGION" --name "$API_NAME" \
    --protocol-type HTTP --query 'ApiId' --output text)
  INTEG=$(aws apigatewayv2 create-integration --region "$AWS_REGION" --api-id "$API" \
    --integration-type HTTP_PROXY --integration-method ANY --integration-uri "$LISTENER" \
    --connection-type VPC_LINK --connection-id "$VPC_LINK_ID" \
    --payload-format-version 1.0 --query 'IntegrationId' --output text)
  aws apigatewayv2 create-route  --region "$AWS_REGION" --api-id "$API" \
    --route-key '$default' --target "integrations/$INTEG" >/dev/null
  aws apigatewayv2 create-stage  --region "$AWS_REGION" --api-id "$API" \
    --stage-name '$default' --auto-deploy >/dev/null
fi
echo "[INFO] API endpoint: https://${API}.execute-api.${AWS_REGION}.amazonaws.com"

echo "[INFO] Custom domain + mapping ..."
if ! aws apigatewayv2 get-domain-name --region "$AWS_REGION" --domain-name "$DOMAIN" >/dev/null 2>&1; then
  aws apigatewayv2 create-domain-name --region "$AWS_REGION" --domain-name "$DOMAIN" \
    --domain-name-configurations CertificateArn="$REGIONAL_CERT_ARN",EndpointType=REGIONAL,SecurityPolicy=TLS_1_2 >/dev/null
  aws apigatewayv2 create-api-mapping --region "$AWS_REGION" --domain-name "$DOMAIN" \
    --api-id "$API" --stage '$default' >/dev/null
fi
read -r TARGET ZONE < <(aws apigatewayv2 get-domain-name --region "$AWS_REGION" --domain-name "$DOMAIN" \
  --query 'DomainNameConfigurations[0].[ApiGatewayDomainName,HostedZoneId]' --output text)

echo "[INFO] Public DNS A-alias ${DOMAIN} -> ${TARGET}"
CHANGE="{\"Changes\":[{\"Action\":\"UPSERT\",\"ResourceRecordSet\":{\"Name\":\"${DOMAIN}\",\"Type\":\"A\",\"AliasTarget\":{\"HostedZoneId\":\"${ZONE}\",\"DNSName\":\"${TARGET}\",\"EvaluateTargetHealth\":false}}}]}"
aws route53 change-resource-record-sets --hosted-zone-id "$PUBLIC_ZONE_ID" \
  --change-batch "$CHANGE" --query 'ChangeInfo.Status' --output text

echo ""
echo "[SUCCESS] Public URL: https://${DOMAIN}   (login ${DEV_AUTH%%:*} / ****)"
