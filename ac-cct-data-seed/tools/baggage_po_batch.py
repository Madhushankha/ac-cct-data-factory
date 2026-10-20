"""A gate batch for `spec/baggage/sit/po`, from the PNRs the kit already published.

`python -m cli gate` reads bookings that are already live, and takes a built batch directory. This
set was never built here -- the kit published it -- so there is no batch to point at. This writes
one from `catalog/baggage-po.json`: the manifest `KitBuilder.load` reads, and nothing else.

Nothing is seeded, built or published by this. The batch is an index: case id, locator, pnrId, and
the legs the booking carries, so the gate knows which 73 Trips to ask for.

Usage:  python tools/baggage_po_batch.py <out dir> [--env int|bat]
"""
from __future__ import annotations

import argparse
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from adapters.file_spec_source import FileSpecSource                        # noqa: E402

SET = "baggage/sit/po"
CATALOG = ROOT / "catalog" / "baggage-po.json"


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("out", type=pathlib.Path, help="directory to write manifest.json into")
    ap.add_argument("--env", default="int", choices=("int", "bat"),
                    help="which environment's published PNRs to bind (default int)")
    args = ap.parse_args(argv[1:])

    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    specs = {p.stem: json.loads(p.read_text(encoding="utf-8"))
             for p in sorted(FileSpecSource().set_named(SET).path.glob("*.json"))}

    rows, unbound = [], []
    for case_id, row in catalog.items():
        seeded = (row.get("seeded") or {}).get(args.env.upper())
        if not seeded:
            unbound.append(case_id)
            continue
        spec = specs[case_id]
        # The legs identify the route and nothing more. `kind`, `minutes` and `code` are left
        # unset deliberately: a manifest's legs are what the run PUBLISHED, and this project
        # published none of these -- the kit did, as ZZ bookings whose flight numbers and dates it
        # chose and did not record in the PNR tables. Copying the old FD seed's 240-minute code-64
        # delay in here would state as "what went out" a disruption from a different booking, and
        # a later reader could not tell that from a real one. The Trip read reports what the
        # engine actually holds.
        flights = [{
            "carrier": seg["carrier"],
            "number": str(seg["number"]),
            "origin": seg["origin"],
            "destination": seg["destination"],
            "depUtc": "",
        } for seg in spec["segments"]]
        rows.append({
            "id": case_id,
            "locator": seeded["pnr"],
            "pnrId": seeded["pnrId"],
            "expect": spec.get("expect") or {},
            "flights": flights,
            "names": [f"{p['firstName']} {p['lastName']}" for p in spec["passengers"]],
            "tickets": seeded.get("tickets") or [],
            "source": {"dataset": row.get("source_dataset"),
                       "case_id": row.get("source_case_id"),
                       "caseNumber": seeded.get("caseNumber")},
        })

    args.out.mkdir(parents=True, exist_ok=True)
    (args.out / "manifest.json").write_text(json.dumps(rows, indent=1) + "\n", encoding="utf-8")
    print(f"wrote {len(rows)} booking(s) to {args.out / 'manifest.json'} ({args.env.upper()})")
    if unbound:
        print(f"  ! not bound in {args.env.upper()}: {', '.join(unbound)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
