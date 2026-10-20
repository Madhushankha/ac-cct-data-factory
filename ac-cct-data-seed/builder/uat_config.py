"""Where the pipeline's outside pieces live: environment variables, with a clear error when a required one is missing.

Required where used:
  CASCADE_DIR       cct-cascade checkout on branch claude/qa-builder-rebooking-shapes-20261015 (cascade PR #401)
  AWS_PROFILE       AWS SSO profile for the target environment (BAT) - only for steps that call AWS
Optional:
  QA_BUILDER_DIR    the /qa builder (default $CASCADE_DIR/tools/qa-scenarios/service)
  EVENT_REPLAY      event_replay.py (default $CASCADE_DIR/tools/scripts/lower-env-event-replay/event_replay.py)
  LOOKUP_TABLES     TripTracer rules lookup tables (default $CASCADE_DIR/apps/trip-tracer-event-processor/rules/lookup-tables.json)
  QA_POOL_DIR       seed templates (default ./seed-pool)
  UAT_WORK_DIR      run outputs (default ./work, gitignored)
  AWS_REGION        default ca-central-1
  ECS_CLUSTER       default ac-cct-bat-ecs-cluster
  ECS_SERVICE       default ac-cct-bat-case-intake-ecs-fargate-service
  UAT_INNER_BUCKET  S3 bucket the case-intake task can read, for inner scripts over ECS's 8 KB override limit
"""
import os
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent


def die(msg):
    print(f"error: {msg}", file=sys.stderr)
    raise SystemExit(2)


def required(name, hint):
    v = os.environ.get(name, "").strip()
    if not v:
        die(f"{name} is not set: {hint} (see qa/uat-scenarios/README.md)")
    return v


def cascade_dir():
    d = Path(required("CASCADE_DIR", "point it at a cct-cascade checkout on branch claude/qa-builder-rebooking-shapes-20261015")).expanduser()
    if not d.is_dir():
        die(f"CASCADE_DIR={d} is not a directory")
    return d


def _path(env, default_fn, what):
    v = os.environ.get(env, "").strip()
    p = Path(v).expanduser() if v else default_fn()
    if not p.exists():
        die(f"{what} not found at {p} (set {env} or CASCADE_DIR)")
    return p


def builder_dir():
    p = _path("QA_BUILDER_DIR", lambda: cascade_dir() / "tools/qa-scenarios/service", "the /qa builder")
    if not (p / "builder.py").exists():
        die(f"{p} has no builder.py (QA_BUILDER_DIR / CASCADE_DIR)")
    return p


def lookup_tables():
    return _path("LOOKUP_TABLES", lambda: cascade_dir() / "apps/trip-tracer-event-processor/rules/lookup-tables.json",
                 "lookup-tables.json")


def pool_dir():
    return _path("QA_POOL_DIR", lambda: HERE / "seed-pool", "the seed pool")


def work_dir():
    v = os.environ.get("UAT_WORK_DIR", "").strip()
    p = Path(v).expanduser() if v else HERE / "work"
    p.mkdir(parents=True, exist_ok=True)
    return p


def aws_profile():
    return required("AWS_PROFILE", "an AWS SSO profile for BAT (aws sso login --profile <name> first)")


def aws_region():
    return os.environ.get("AWS_REGION", "").strip() or "ca-central-1"


def ecs_cluster():
    return os.environ.get("ECS_CLUSTER", "").strip() or "ac-cct-bat-ecs-cluster"


def ecs_service():
    return os.environ.get("ECS_SERVICE", "").strip() or "ac-cct-bat-case-intake-ecs-fargate-service"


def inner_bucket():
    return required("UAT_INNER_BUCKET", "this inner script is over ECS's 8 KB override limit and travels through S3; "
                                        "name a bucket the case-intake task role can read (BAT: the case-data bucket)")


def use_builder():
    """Put the /qa builder and this folder on sys.path (spec_to_build.py, scenario_build.py)."""
    sys.path.insert(0, str(builder_dir()))
    sys.path.insert(0, str(HERE))
