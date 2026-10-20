"""Run a small Python file as a one-off ECS task from an ECS service's own task definition and print its marked lines.

  run_inner.py <inner file> <marker> [--cluster C] [--service S] [--task-definition TD]

Defaults: ECS_CLUSTER / ECS_SERVICE (BAT case-intake), AWS_PROFILE (required), AWS_REGION (ca-central-1).
The script travels in the task's command override (zlib + base64). A script over ECS's 8 KB override limit travels
through S3 instead: uploaded to s3://$UAT_INNER_BUCKET/qa-inner/<sha>.py, read by the task, deleted after the task stops.
Output: the task line, then every log line that starts with "<marker> " (marker stripped, two-space indent).
"""
import argparse
import base64
import hashlib
import json
import os
import pathlib
import subprocess
import sys
import time
import zlib

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import uat_config  # noqa: E402

ap = argparse.ArgumentParser()
ap.add_argument("inner")
ap.add_argument("marker")
ap.add_argument("--cluster", default=None)
ap.add_argument("--service", default=None)
ap.add_argument("--task-definition", default=None)
ap.add_argument("--started-by", default="cs-uat-scenarios")
a = ap.parse_args()

PROFILE, REGION = uat_config.aws_profile(), uat_config.aws_region()
P = ["--profile", PROFILE, "--region", REGION, "--output", "json"]


def aws(*args):
    out = subprocess.run(["aws", *args, *P], capture_output=True, text=True, check=True).stdout
    return json.loads(out) if out.strip() else {}


cluster = a.cluster or uat_config.ecs_cluster()
service = a.service or uat_config.ecs_service()
inner, marker = pathlib.Path(a.inner).read_text(), a.marker
packed = base64.b64encode(zlib.compress(inner.encode(), 9)).decode()
svc = aws("ecs", "describe-services", "--cluster", cluster, "--services", service)["services"][0]
td = a.task_definition or svc["taskDefinition"]
net = {"awsvpcConfiguration": svc["networkConfiguration"]["awsvpcConfiguration"]}
container = aws("ecs", "describe-task-definition", "--task-definition", td)["taskDefinition"]["containerDefinitions"][0]
opts = container["logConfiguration"]["options"]
t0 = int(time.time() * 1000) - 60000
s3key = bucket = None
if len(packed) > 7000:
    bucket = uat_config.inner_bucket()
    s3key = f"qa-inner/{hashlib.sha256(inner.encode()).hexdigest()[:16]}.py"
    subprocess.run(["aws", "s3", "cp", "-", f"s3://{bucket}/{s3key}", "--profile", PROFILE, "--region", REGION, "--only-show-errors"],
                   input=inner, text=True, check=True)
    loader = f"import boto3;exec(boto3.client('s3').get_object(Bucket='{bucket}',Key='{s3key}')['Body'].read().decode())"
    override = {"name": container["name"], "command": ["python", "-c", loader]}
else:
    override = {"name": container["name"], "command": [
        "python", "-c", f"import base64,zlib;exec(zlib.decompress(base64.b64decode('{packed}')).decode())"]}
try:
    task = aws("ecs", "run-task", "--cluster", cluster, "--task-definition", td, "--launch-type", "FARGATE",
               "--network-configuration", json.dumps(net), "--overrides", json.dumps({"containerOverrides": [override]}),
               "--started-by", a.started_by)["tasks"][0]["taskArn"]
    subprocess.run(["aws", "ecs", "wait", "tasks-stopped", "--cluster", cluster, "--tasks", task, *P[:4]], check=False)
    stopped = aws("ecs", "describe-tasks", "--cluster", cluster, "--tasks", task)["tasks"][0]
finally:
    if s3key:
        subprocess.run(["aws", "s3", "rm", f"s3://{bucket}/{s3key}", "--profile", PROFILE, "--region", REGION, "--only-show-errors"],
                       check=False)
c = stopped["containers"][0]
print(f"{td.rsplit('/', 1)[-1]} task {task.rsplit('/', 1)[1]} exit={c.get('exitCode')} reason={c.get('reason')} stopped={stopped.get('stoppedReason')}")
grp = opts.get("log_group_name") or opts.get("awslogs-group")
lines = []
for _ in range(18):
    try:
        ev = aws("logs", "filter-log-events", "--log-group-name", grp, "--start-time", str(t0), "--filter-pattern", '"' + marker + '"')["events"]
    except subprocess.CalledProcessError:
        ev = []
    lines = []
    for e in ev:
        m = e["message"]
        try:
            m = json.loads(m).get("log", m)
        except Exception:
            pass
        if m.startswith(marker + " "):
            lines.append(m[len(marker) + 1:])
    if any(line.startswith("done") for line in lines):
        break
    time.sleep(10)
for line in lines:
    print("  " + line)
