"""Import the 27 default-set cases as FD_PO_001..027.

The order is the dataset's own, not alphabetical: FD_PO_001 is the first case of the set as it has
been seeded since v108, so a reader comparing a run against an older one sees the same order.

Expectations come from the dataset manifest rather than the fixture, because for these cases the
fixture holds none: the 19 gap-doc cases state theirs in `_gapdoc_expected.json` and the catalogue,
and the 8 `FD_UAT_DATA_*` cases state theirs in neither. The manifest is what the seeder resolved
and verified against, so it is the one source that covers all 27, and `catalog/fd-po.json` records
that for each case rather than leaving it to be inferred.

Usage:  python tools/import_po.py [manifest.json]
"""
from __future__ import annotations

import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from core import convert, paths, registry                                   # noqa: E402

AQA = paths.agentic_qa()
#: not vendored; `paths.fixtures()` raises with the variable to set. Resolved inside main() so
#: importing this module (the tests do) never depends on another checkout.
DEFAULT_MANIFEST = AQA / "data" / "seed" / "datasets" / "fd-uat-int-v134.json"
OUT = ROOT / "spec" / "fd" / "uat" / "po"



def main(argv: list[str]) -> int:
    manifest_path = pathlib.Path(argv[1]) if len(argv) > 1 else DEFAULT_MANIFEST
    fixtures = paths.fixtures()                      # raises, naming the variable, if absent
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    gapdoc = json.loads((fixtures / "fd-uat" / "_gapdoc_expected.json").read_text(
        encoding="utf-8"))
    fd = registry.get("fd")

    catalog = {}
    problems: list[str] = []
    for n, case in enumerate(manifest["cases"], start=1):
        src_id = case["case_id"]
        spec_id = f"FD_PO_{n:03d}"
        fixture_path = fixtures / "fd-uat" / f"{src_id}.json"
        if not fixture_path.exists():
            problems.append(f"{spec_id}: no fixture at {fixture_path.name}")
            continue
        fixture = json.loads(fixture_path.read_text(encoding="utf-8"))

        expected = case.get("expected") or {}
        authority = ("gap-doc card" if src_id in gapdoc else
                     "dataset manifest only (no gap-doc card)")

        spec = convert.fixture_to_spec(
            fixture, spec_id=spec_id, suite="fd-uat", expected=expected,
            assumed=[f"expectation taken from {manifest['id']} ({authority})"])
        (OUT / f"{spec_id}.json").write_text(
            json.dumps(spec, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")

        missing = fd.validate(spec)
        catalog[spec_id] = {
            "source_case_id": src_id,
            "source_fixture": f"fd-uat/{src_id}.json",
            "expectation_from": authority,
            "expectation_resolved_in": manifest["id"],
            "binding_status": fixture.get("binding_status"),
            "runnable": not missing,
            "missing": missing,
        }
        if missing:
            problems.append(f"{spec_id} ({src_id}): {'; '.join(missing)}")

    (ROOT / "catalog" / "fd-po.json").write_text(
        json.dumps(catalog, indent=1) + "\n", encoding="utf-8")

    runnable = sum(1 for v in catalog.values() if v["runnable"])
    print(f"wrote {len(catalog)} specs to spec/fd/uat/po/ and catalog/fd-po.json")
    print(f"runnable: {runnable} of {len(catalog)}")
    gap = sum(1 for v in catalog.values() if v["expectation_from"] == "gap-doc card")
    print(f"expectation from a gap-doc card: {gap}; from the manifest only: {len(catalog) - gap}")
    for p in problems:
        print(f"  ! {p}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
