"""Environment descriptors for seeding. Every env fact lives here, nothing in the phase code.

Values come from HOWTO_CREATE_PNR_DATA.md §2, LEARNINGS.md §2/§3/§6 and the live INT
inventory read on 2026-09-05 (secret names, cluster endpoints). Override any field with
AQA_SEED_<ENV>_<FIELD> (e.g. AQA_SEED_INT_PROFILE=int-sso).
"""
from __future__ import annotations

import json
import os
from dataclasses import dataclass, field
from functools import lru_cache


@dataclass(frozen=True)
class SeedEnv:
    id: str
    account: str
    profile: str
    region: str
    # Kafka
    msk_secret: str
    bootstrap_fallback: str
    topic_pnr: str
    topic_tkt: str
    topic_fdm: str
    # trip-tracer Aurora (writer endpoint — the reader rejects finalize UPDATEs)
    aurora_host: str
    aurora_db: str
    aurora_secret: str
    # DDS verdict store + pin
    dds_bucket: str
    dds_trace_prefix: str
    dds_by_pnr_url: str
    dds_api_key_secret: str
    rule_engine_host: str
    rule_engine_db: str
    rule_engine_secret: str
    rule_engine_ecs_cluster: str
    rule_engine_ecs_service: str
    # DB identity the pin uses: the service's own admin user (the secret's plain `username` is read-only)
    rule_engine_user: str = "dbadmin"
    rule_engine_password_key: str = "adminpassword"
    # default contact stamped on every seeded PNR (OTP must be readable; the phone is a mock)
    contact_email: str = "lahiru@ae-qa1-aircanada.mailinator.com"
    contact_phone: str = "+123456789"
    # The loyalty feeds that BUILD a customer profile, which is what an AC Wallet decision is made
    # against. They were hardcoded in profile.py, so every env published them to INT's cluster: on
    # BAT that is a cluster without those topics, and Kafka answers "failed to update metadata" only
    # after a 60-second wait, which reads as a network fault rather than a missing topic. An env that
    # does not declare them cannot seed a wallet case, and says so immediately.
    loyalty_topics: dict = field(default_factory=lambda: {
        "gigya_custprofile": "emh-int.MULE-LOYALTY-GIGYA-CUSTPROFILE-INT",
        "ifly_accountstatuschanges": "emh-int.IFLY-ACCOUNTSTATUSCHANGES-UAT",
        "ifly_tierstatusupdates": "emh-int.IFLY-TIERSTATUSUPDATES-UAT",
        "ifly_frozenstagechanges": "emh-int.IFLY-FROZENSTAGECHANGES-UAT",
    }, hash=False, compare=False)
    # where dataset reports (HTML + manifest) are published; empty = publishing disabled for the env
    artifacts_bucket: str = "cct-qa-artifacts-int"
    artifacts_prefix: str = "datasets"
    # OTP for agent runs: "" = fetch the REAL code from the seeded mailinator inbox (validates the e-mail
    # step end to end); a code here (e.g. "123456", which the INT bot accepts) skips the mailbox.
    # Override per env with AQA_SEED_<ENV>_OTP_STATIC_CODE.
    otp_static_code: str = ""
    otp_token_secret: str = "cct-qa/mailinator-token"
    # cascade settle windows (seconds)
    settle: dict = field(default_factory=lambda: {"pnr": 45, "tkt": 30, "fdm_skd": 45, "fdm_delay": 60},
                         hash=False, compare=False)

    def override(self) -> "SeedEnv":
        """Apply AQA_SEED_<ENV>_<FIELD> environment overrides."""
        changes = {}
        for name in self.__dataclass_fields__:
            key = f"AQA_SEED_{self.id.upper()}_{name.upper()}"
            if os.environ.get(key):
                changes[name] = os.environ[key]
        if not changes:
            return self
        from dataclasses import replace
        return replace(self, **changes)


ENVS: dict[str, SeedEnv] = {
    "int": SeedEnv(
        # int-cce (CCE-Developer), not int-sso: int-sso's role holds no `profile:*` on the ACCP
        # domain, so attach_member silently wrote no wallet data (HEXFZK seeded green with
        # AccountNumber=None). int-cce covers everything seeding needs -- Aurora, the MSK and DB
        # secrets, the artifact bucket, ECS exec for the DDS pin and Customer Profiles.
        id="int", account="982081066747", profile="int-cce", region="ca-central-1",
        msk_secret="AmazonMSK_ac-cct-msk-int-cac1",
        bootstrap_fallback=(
            "b-1.accctmskintcac1.z22bz6.c3.kafka.ca-central-1.amazonaws.com:9096,"
            "b-2.accctmskintcac1.z22bz6.c3.kafka.ca-central-1.amazonaws.com:9096,"
            "b-3.accctmskintcac1.z22bz6.c3.kafka.ca-central-1.amazonaws.com:9096"),
        topic_pnr="emh-int.ALTEA-PNRDATA-INT",
        topic_tkt="emh-int.ALTEA-TKT-INT",
        topic_fdm="emh-int.EAI-FDM-INT",
        aurora_host="ac-cct-trip-tracer-rds-cluster-int-cac1.cluster-czy2ye8u22qy.ca-central-1.rds.amazonaws.com",
        aurora_db="trip-tracer",
        aurora_secret="/int-cac1/ac-cct-trip-tracer-rds-cluster-int-cac1/db-credentials",
        dds_bucket="ac-cct-rule-engine-store-int",
        dds_trace_prefix="traces/DDS",
        dds_by_pnr_url="https://rule-engine-platform-service.ac-cct-int.cloud.aircanada.com/rule-engine/dds/output",
        dds_api_key_secret="cct-qa/dds-api-key",
        rule_engine_host="ac-cct-rule-engine-int-cac1-rds-cluster.cluster-czy2ye8u22qy.ca-central-1.rds.amazonaws.com",
        rule_engine_db="postgres",
        rule_engine_secret="/intca1/ac-cct-rule-engine-int-cac1-cluster/db-credentials",
        rule_engine_ecs_cluster="ac-cct-rule-engine-platform-cluster-int",
        rule_engine_ecs_service="ac-cct-rule-engine-platform-int-service",
    ),
    "crt": SeedEnv(
        id="crt", account="050752605169", profile="ac-cct-crt", region="ca-central-1",
        msk_secret="AmazonMSK_ac-cct-msk-crt-cac1",
        bootstrap_fallback=(
            "b-1.accctmskcrtcac1.05hf7o.c4.kafka.ca-central-1.amazonaws.com:9096,"
            "b-2.accctmskcrtcac1.05hf7o.c4.kafka.ca-central-1.amazonaws.com:9096,"
            "b-3.accctmskcrtcac1.05hf7o.c4.kafka.ca-central-1.amazonaws.com:9096"),
        topic_pnr="emh-dev.ALTEA-PNRDATA-UAT",
        topic_tkt="emh-dev.ALTEA-TKT-UAT",
        topic_fdm="emh-dev.EAI-FDM-UAT",
        aurora_host="ac-cct-trip-tracer-rds-cluster-crt-cac1.cluster-cxqe2wacy866.ca-central-1.rds.amazonaws.com",
        aurora_db="trip-tracer",
        aurora_secret="/crt-cac1/ac-cct-trip-tracer-rds-cluster-crt-cac1/db-credentials",
        dds_bucket="cct-ask-ac-crt-logs",
        dds_trace_prefix="traces/DDS",
        dds_by_pnr_url="https://rule-engine-platform-service-be.ac-cct-crt.cloud.aircanada.com/dds/output",
        dds_api_key_secret="cct-qa/dds-api-key",
        rule_engine_host="ac-cct-rule-engine-crt-cac1-rds-cluster.cluster-cxqe2wacy866.ca-central-1.rds.amazonaws.com",
        rule_engine_db="postgres",
        rule_engine_secret="",
        rule_engine_ecs_cluster="ac-cct-crt-ecs-cluster",
        rule_engine_ecs_service="rule-engine-platform-crt-service",
        artifacts_bucket="",
        otp_static_code="",
    ),
    # BAT. Nothing here is a default: `int` stays the default in cli.py and flow_seed.py, and this
    # env is only used when it is asked for by name.
    #
    # THE SOURCE TOPICS ARE NOT NAMED AFTER THIS ENVIRONMENT. They are `emh-dev.*-INT` -- the same
    # raw feeds INT reads -- and only the CASCADE topics carry a -BAT suffix
    # (`DERIVED-PNR-EVENTS-BAT`, `EVENT-DETECTION-FDM-BAT`, ...). Recorded in
    # cct-load-test/analysis/architecture/TT-architecture-e2e-BAT-2026-07-30.md section 6, written
    # against this cluster, and corroborated by that project's FDM load test, where BAT's own Flink
    # app `cct-fdm-bat` is measured consuming `EAI-FDM-INT`.
    #
    # The vendored framework's `bat.yaml` says `emh-bat.ALTEA-PNRDATA-BAT`, which is wrong -- as are
    # three of its four other fields (a `fixed` OTP that contradicts the uniform-mailinator design, a
    # profile name that does not exist, and a literal `bat-placeholder` URL). It was stubbed, never
    # filled in. A wrong topic name does NOT error: the publish succeeds onto a topic no one consumes
    # and the case fails later at `cascade`, looking like a slow environment rather than a typo.
    #
    # Because the raw feeds are shared with INT, a booking seeded for BAT is visible to INT's
    # pipeline as well. That is a property of the platform, not of this seeder.
    "bat": SeedEnv(
        id="bat", account="209479273605", profile="bat-sso", region="ca-central-1",
        msk_secret="AmazonMSK_ac-cct-msk-bat-cac1",
        bootstrap_fallback=(
            "b-1.accctmskbatcac1.b6n18o.c4.kafka.ca-central-1.amazonaws.com:9096,"
            "b-2.accctmskbatcac1.b6n18o.c4.kafka.ca-central-1.amazonaws.com:9096,"
            "b-3.accctmskbatcac1.b6n18o.c4.kafka.ca-central-1.amazonaws.com:9096"),
        topic_pnr="emh-dev.ALTEA-PNRDATA-INT",
        topic_tkt="emh-dev.ALTEA-TKT-INT",
        topic_fdm="emh-dev.EAI-FDM-INT",
        aurora_host="ac-cct-trip-tracer-rds-cluster-bat-cac1.cluster-cnc6sqy2ooev.ca-central-1.rds.amazonaws.com",
        aurora_db="trip-tracer",
        aurora_secret="/bat-cac1/ac-cct-trip-tracer-rds-cluster-bat-cac1/db-credentials",
        # CRT's shape (`cct-ask-ac-<env>-logs`), not INT's `ac-cct-rule-engine-store-int`.
        dds_bucket="cct-ask-ac-bat-logs",
        dds_trace_prefix="traces/DDS",
        # CRT's shape again -- the `-be` backend host and a bare `/dds/output`. INT's
        # `rule-engine-platform-service…/rule-engine/dds/output` answers 403 on BAT whatever key is
        # sent, which reads as an auth failure and is really a wrong host: the first BAT seed lost
        # five checkpoints to it before the three URL shapes were compared side by side.
        dds_by_pnr_url="https://rule-engine-platform-service-be.ac-cct-bat.cloud.aircanada.com/dds/output",
        # A SHARED blob, not a dedicated secret: the key is the `DDS_API_KEY` field inside it, which
        # is how case-intake reads it (`case-intake-bat-fargate-task` mounts
        # `cct-case-mgmt-bat/app-secrets:DDS_API_KEY`). `dds_api_key()` has to know that name or its
        # last-resort `next(iter(...))` hands back whichever field happens to be first -- here
        # CYBERSOURCE_CLIENT_ID, which would 403 and blame the endpoint.
        dds_api_key_secret="cct-case-mgmt-bat/app-secrets",
        rule_engine_host="ac-cct-rule-engine-bat-cac1-rds-cluster.cluster-cnc6sqy2ooev.ca-central-1.rds.amazonaws.com",
        rule_engine_db="postgres",
        rule_engine_secret="/batca1/ac-cct-rule-engine-bat-cac1-cluster/db-credentials",
        rule_engine_ecs_cluster="ac-cct-bat-ecs-cluster",
        rule_engine_ecs_service="ac-cct-bat-rule-engine-platform-ecs-fargate-service",
        # Its own bucket, in its own account. Borrowing INT's looked free -- the prefix already
        # carries the env, so `datasets/bat/...` could not collide with INT's own runs -- but the
        # uploader authenticates as the env it seeded, and a bat-sso PutObject into an INT bucket is
        # a cross-account write that no resource policy admits. Every case uploaded clean and then
        # AccessDenied on its evidence.
        artifacts_bucket="cct-qa-artifacts-bat",
        # -PRE, the PREPROD suffix, on an env called bat reading feeds prefixed emh-dev. Read from
        # KAFKA_SOURCE_TOPIC on `cct-customer-profile-gigya-bat:10` and
        # `cct-customer-profile-ifly-bat:9` in cluster cct-customer-profile-cluster-bat -- the
        # services that actually build this domain's 1.8M profiles. INT does the same thing with a
        # different suffix (its seven iFly topics all end -UAT), so across three environments the
        # loyalty feeds carry three suffixes and none of them is the environment's own name.
        loyalty_topics={
            "gigya_custprofile": "emh-dev.MULE-LOYALTY-GIGYA-CUSTPROFILE-PRE",
            "ifly_accountstatuschanges": "emh-dev.IFLY-ACCOUNTSTATUSCHANGES-PRE",
            "ifly_tierstatusupdates": "emh-dev.IFLY-TIERSTATUSUPDATES-PRE",
            "ifly_frozenstagechanges": "emh-dev.IFLY-FROZENSTAGECHANGES-PRE",
        },
    ),
}


def get_env(env_id: str) -> SeedEnv:
    try:
        return ENVS[env_id.lower()].override()
    except KeyError:
        raise SystemExit(f"unknown env {env_id!r}; known: {', '.join(ENVS)}")


# ---- AWS helpers (one session per env, secrets read once) -------------------

@lru_cache(maxsize=8)
def session(env: SeedEnv):
    import boto3
    return boto3.Session(profile_name=env.profile, region_name=env.region)


@lru_cache(maxsize=32)
def secret_json(env: SeedEnv, secret_id: str) -> dict:
    raw = session(env).client("secretsmanager").get_secret_value(SecretId=secret_id)["SecretString"]
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return {"value": raw}


def kafka_config(env: SeedEnv) -> dict:
    """kafka-python client kwargs: SASL_SSL + SCRAM-SHA-512 from the MSK secret."""
    sec = secret_json(env, env.msk_secret)
    boot = sec.get("sourceBootstrapServers") or env.bootstrap_fallback
    return {
        "bootstrap_servers": [b.strip() for b in boot.split(",") if b.strip()],
        "security_protocol": "SASL_SSL",
        "sasl_mechanism": "SCRAM-SHA-512",
        "sasl_plain_username": sec["username"],
        "sasl_plain_password": sec["password"],
    }


def aurora_connect(env: SeedEnv, *, autocommit: bool = True):
    import psycopg2
    sec = secret_json(env, env.aurora_secret)
    conn = psycopg2.connect(host=env.aurora_host, port=5432, dbname=env.aurora_db,
                            user=sec["username"], password=sec["password"],
                            sslmode="require", connect_timeout=20)
    conn.autocommit = autocommit
    return conn


def dds_api_key(env: SeedEnv) -> str:
    # `DDS_API_KEY` is the field name the SERVICES use, and on BAT the key lives inside a shared
    # app-secrets blob rather than a secret of its own. Without it the fallback below returns
    # whichever field is first in that blob -- CYBERSOURCE_CLIENT_ID -- and the DDS call 403s with
    # the endpoint taking the blame for a lookup error.
    sec = secret_json(env, env.dds_api_key_secret)
    return (sec.get("value") or sec.get("api_key") or sec.get("apiKey") or sec.get("DDS_API_KEY")
            or next(iter(sec.values())))
