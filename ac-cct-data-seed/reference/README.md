# Reference, unmodified

Files copied verbatim from `UAT_344_PNR_KIT_20261015 (1)/uat-scenarios`, the project we build
against. Nothing here is imported or run; they are read.

| file | why it is here |
|---|---|
| `scenario_fdm.py` | the FDM lifecycle in the shape the live feed carries, and the Snowflake `ARRIVAL_CODE` record. `lanes/fdm.py` is built from it. Its docstring records the same failure we hit: the builder's own FDM JSON left TripTracer showing "ETD —" and no delay code. |
| `inner_gate_tpl.py` | reading the Trip and the verdict from inside a one-off case-intake task, which is the only place the TripTracer signing key exists. `core/gate.py` is built from it. |
| `uat_config.py` | how the kit resolves its outside pieces, and the failure messages it gives when one is missing. |

The kit's own measured limits live in `core/policy.py` with the reason attached to each.
