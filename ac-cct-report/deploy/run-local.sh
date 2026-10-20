#!/bin/bash
# CCT Report Viewer — run locally in Docker.
#   - creates .env from .env.example if missing
#   - if AWS_PROFILE is an SSO profile, exports temporary creds into the container
#   - builds + runs the container, prints the URL + login
# Usage:  AWS_PROFILE=int-sso ./deploy/run-local.sh        (from the project root)
set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

# must run from the project root (so the build context is correct)
[ -f "app.py" ] || { echo -e "${RED}Run this from the project root: ./deploy/run-local.sh${NC}"; exit 1; }

PORT="${PORT:-8090}"
NAME="${NAME:-cct-report-viewer}"

if [ ! -f ".env" ]; then
  echo -e "${YELLOW}Creating .env from .env.example — edit it if needed.${NC}"
  cp .env.example .env
fi

echo -e "${GREEN}Building image…${NC}"
docker build -f deploy/Dockerfile -t "$NAME:local" .

# temporary AWS creds for S3 (SSO profiles need this; a static profile can just mount ~/.aws)
CRED_ARGS=()
if [ -n "$AWS_PROFILE" ]; then
  echo -e "${GREEN}Exporting AWS creds from profile $AWS_PROFILE…${NC}"
  eval "$(aws configure export-credentials --profile "$AWS_PROFILE" --format env 2>/dev/null)" || true
  CRED_ARGS=(-e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN)
fi

docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run -d --name "$NAME" -p "$PORT:8080" --env-file .env "${CRED_ARGS[@]}" "$NAME:local" >/dev/null

sleep 3
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  CCT Report Viewer is running${NC}"
echo -e "${GREEN}========================================${NC}"
echo "  URL:   http://localhost:$PORT"
echo "  Login: see DEV_AUTH in .env"
echo "  Logs:  docker logs -f $NAME"
echo "  Stop:  docker rm -f $NAME"
