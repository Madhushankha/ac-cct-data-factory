# The chat automation as one container, for AWS (ECS Fargate in INT) runs against BAT or INT.
# Build from playwright-baggage:   docker build -f cloud/Dockerfile -t cct-qa-chat-runner .
FROM mcr.microsoft.com/playwright:v1.64.0-noble
RUN apt-get update && apt-get install -y --no-install-recommends unzip curl ca-certificates \
    && curl -sSL -o /tmp/awscli.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
    && unzip -q /tmp/awscli.zip -d /tmp && /tmp/aws/install && rm -rf /tmp/aws /tmp/awscli.zip \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY . .
ENV TASK_ROLE=1 CI=1 HEADED=0
ENTRYPOINT ["/bin/bash", "/app/cloud/run-shard.sh"]
