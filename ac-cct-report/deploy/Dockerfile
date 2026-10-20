# CCT Report Viewer — container for ECS Fargate.
FROM python:3.12-slim

WORKDIR /app
ENV PYTHONUNBUFFERED=1 PORT=8080

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py jira_client.py jira_flows.json ./
COPY static ./static

EXPOSE 8080
# gunicorn serves the Flask app; ECS health check hits /healthz
# ONE worker, many threads: the app only ever waits on S3/Jira/Xray (no CPU work), so extra
# processes buy nothing and cost a split cache — two workers each keep their own Jira roll-up
# cache and their own SQLite handle, so a warm dashboard goes cold on every other request.
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "1", "--threads", "8", "--timeout", "120", "app:app"]
