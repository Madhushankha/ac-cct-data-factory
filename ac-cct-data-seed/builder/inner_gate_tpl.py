# Runs INSIDE a one-off case-intake ECS task (run_inner.py): reads each PNR's Trip (Raptor engine) and its DDS
# eligibility with the service's own settings and prints one UATGATE line per PNR. __IDS__ is replaced by the pnrIds.
import json, time, urllib.request
from case_intake_service.config.loader import get_settings
from case_intake_service.container import Container
from case_intake_service.infrastructure.providers.trip_tracer.service_token import signer_from_settings
M = 'UATGATE'
def out(*a): print(M, *a, flush=True)
s = get_settings(); c = Container(s); sig = signer_from_settings(s); base = s.trip_tracer_live_api_base_url.rstrip('/')
dds = c.dds_client()
for pid in __IDS__:
    t0 = time.monotonic(); r = {"pnrId": pid}
    try:
        req = urllib.request.Request(f"{base}/api/service/trips/{pid}?engine=raptor", headers={"Accept": "application/json", "Authorization": "Bearer " + sig.token(), "User-Agent": "case-intake-uat-gate"})
        t = json.load(urllib.request.urlopen(req, timeout=30))['trip']
        r["counts"] = {k: len(t.get(k) or []) for k in ('passengers', 'segments', 'tickets', 'ancillaries')}
        r["segs"] = [{k: sg.get(k) for k in ('flight', 'from', 'to', 'delayMin', 'status', 'cause', 'causeCode', 'regimes')} for sg in (t.get('segments') or [])]
    except Exception as e:
        r["tripErr"] = f"{type(e).__name__}: {str(e)[:120]}"
    try:
        d = dds.get_eligibility(pid) or {}
        r["comp"] = [{"regime": x.get('regime'), "pax": p.get('passengerName'), "status": p.get('eligibilityStatus'), "code": p.get('systemCode'),
                      "delayMin": p.get('delayMinutes'), "delayType": p.get('delayType'), "cause": p.get('delayOrCancelCode'),
                      "amount": (p.get('compensationDetails') or {}).get('amount'), "currency": (p.get('compensationDetails') or {}).get('currency'),
                      "band": (p.get('compensationDetails') or {}).get('delayBand')}
                     for x in (d.get('compensationEligibility') or []) for p in (x.get('passengerEligibility') or [])]
        r["soc"] = [{"regime": x.get('regime'), "status": p.get('eligibilityStatus'), "code": p.get('systemCode')}
                    for x in (d.get('socFlightEligibility') or []) for p in (x.get('passengerEligibility') or [])]
        # one row per distinct regime/status/code (multi-passenger bookings would otherwise crowd out a regime)
        r["soc"] = [dict(t) for t in dict.fromkeys(tuple(sorted(s.items())) for s in r["soc"])][:12]
    except Exception as e:
        r["ddsErr"] = f"{type(e).__name__}: {str(e)[:120]}"
    out(json.dumps(r, separators=(",", ":")))
    time.sleep(max(0, 0.22 - (time.monotonic() - t0)))
out('done')
