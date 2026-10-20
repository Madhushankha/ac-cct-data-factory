"""Publish rendered payloads to the env's raw Kafka topics, in cascade order with settle waits.

Order matters: PNR first (creates trip/passenger/segment/eds), then the ticket record(s), then
the FDM SKD leg(s) so flight_leg exists, then the FDM delay so flight_leg_updates carries the
DEPARTURE_DELAY. Keys follow the existing injectors: locator for PNR, document number for
tickets, flight number for FDM.
"""
from __future__ import annotations

import json
import os
import time
from pathlib import Path

from .env import SeedEnv, kafka_config
from .render import Rendered

CAFILE = Path(__file__).resolve().parent / "certs" / "AmazonRootCA1.pem"
STEPS = ("pnr", "tkt", "skd", "delay")


def producer(env: SeedEnv):
    from kafka import KafkaProducer
    cfg = kafka_config(env)
    cafile = os.environ.get("AQA_SEED_CAFILE") or (str(CAFILE) if CAFILE.exists() else None)
    if cafile:
        cfg["ssl_cafile"] = cafile
    return KafkaProducer(**cfg, acks="all", retries=3, max_in_flight_requests_per_connection=1,
                         request_timeout_ms=30000)


def _send(p, topic: str, key: str, value, log) -> dict:
    data = json.dumps(value).encode("utf-8") if isinstance(value, dict) else value.encode("utf-8")
    md = p.send(topic, value=data, key=key.encode("utf-8")).get(timeout=60)
    rec = {"topic": md.topic, "partition": md.partition, "offset": md.offset, "key": key, "bytes": len(data)}
    log(f"  -> {md.topic} p{md.partition} @{md.offset} key={key}")
    return rec


def _wait_trip(conn, pnr_id: str, timeout: int, log) -> bool:
    """Poll trip_details for the PNR (the FK anchor for ticket / passenger rows)."""
    cur = conn.cursor()
    t0 = time.time()
    while time.time() - t0 < timeout:
        cur.execute("select 1 from trip_details where pnr_id = %s", (pnr_id,))
        if cur.fetchone():
            log(f"  trip_details present after {int(time.time() - t0)}s")
            return True
        time.sleep(4)
    log(f"  trip_details still missing after {timeout}s")
    return False


def publish(env: SeedEnv, r: Rendered, *, conn=None, steps=STEPS, wait: bool = True, log=print) -> list[dict]:
    """Send v0 PNR -> (trip appears) -> v1 PNR -> ticket(s) -> FDM SKD -> FDM delay.

    With `conn` the PNR settle is a poll on trip_details instead of a blind sleep, so the ticket
    record is never published before its FK anchor exists.
    """
    p = producer(env)
    out: list[dict] = []
    settle = env.settle
    try:
        if "pnr" in steps:
            for i, v in enumerate(r.pnr_versions):
                ver = v["processedPnr"]["version"]
                log(f"[publish] PNR {r.pnr_id} v{ver}")
                out.append({"step": f"pnr_v{ver}", **_send(p, env.topic_pnr, r.locator, v, log)})
                if wait and i == 0:
                    if conn is not None:
                        _wait_trip(conn, r.pnr_id, settle["pnr"] * 3, log)
                    else:
                        log(f"  settle {settle['pnr']}s"); time.sleep(settle["pnr"])
                elif wait:
                    log(f"  settle {settle['tkt']}s"); time.sleep(settle["tkt"])
        if "tkt" in steps:
            for t in r.tickets:
                num = t["processedTicket"]["primaryDocumentNumber"]
                log(f"[publish] ticket {num}")
                out.append({"step": "tkt", **_send(p, env.topic_tkt, num, t, log)})
            if wait and r.tickets:
                log(f"  settle {settle['tkt']}s"); time.sleep(settle["tkt"])
        if "skd" in steps:
            for leg, xml in r.fdm_skd:
                log(f"[publish] FDM SKD {leg}")
                out.append({"step": "skd", "leg": leg, **_send(p, env.topic_fdm, leg.split("#")[1], xml, log)})
            if wait and r.fdm_skd:
                log(f"  settle {settle['fdm_skd']}s"); time.sleep(settle["fdm_skd"])
        if "delay" in steps:
            for leg, xml in r.fdm_delay:
                log(f"[publish] FDM delay {leg}")
                out.append({"step": "delay", "leg": leg, **_send(p, env.topic_fdm, leg.split("#")[1], xml, log)})
            if wait and r.fdm_delay:
                log(f"  settle {settle['fdm_delay']}s"); time.sleep(settle["fdm_delay"])
    finally:
        p.flush(timeout=30)
        p.close(timeout=10)
    return out
