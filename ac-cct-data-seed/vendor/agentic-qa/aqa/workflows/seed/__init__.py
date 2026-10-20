"""Seed-data pipeline for flow tests (FD first): index -> render -> publish -> cascade -> finalize -> pin -> verify.

Written from the CCT_Agent_New reference package (HOWTO_CREATE_PNR_DATA.md, LEARNINGS.md,
scenarios/fd-*) and the payload shapes already proven in the INT dataset
s3://cct-qa-artifacts-int/datasets/int/fd/fd-int-v3. It does not import cct-qa-framework.

Two sources must be seeded for a PNR the assistant can use:

1. Booking: raw PNR (v0 creation, then v1 with ticketing) + ticket + FDM events published to
   the env's raw Kafka topics; the Flink -> transformer -> ingestion cascade materialises trip /
   trip_details / passenger / flight_segment / ticket / eds_pnr_output in trip-tracer Aurora
   (~15-60 s). flight_leg rows are written by finalize while INT's FDM ingestion is broken.
2. Verdict: a DDS output document put in the rule-engine S3 store and pinned as an
   execution_traces row, served by GET /rule-engine/dds/output/<pnrId>.
   trip-tracer's dds_pnr_output is a decoy; the bot does not read it.

A case is DONE only when checkpoints (see checkpoints.py) print PASS on every area.
"""
