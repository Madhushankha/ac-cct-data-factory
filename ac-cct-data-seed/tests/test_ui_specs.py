"""The UI's spec store keeps the tree's rules: one id, one spec, and nothing destroyed.

Each case runs against a throwaway spec tree, so nothing here touches `spec/`.

Run:  python tests/test_ui_specs.py
"""
from __future__ import annotations

import json
import pathlib
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from ui.specs import SpecError, SpecStore                                   # noqa: E402

FAILED: list[str] = []

CASE = {"id": "T_001", "family": "FD", "summary": "a delay",
        "passengers": [{"firstName": "A", "lastName": "B", "type": "ADT"}],
        "segments": [{"seg": 1, "bound": 1, "carrier": "AC", "number": "100",
                      "origin": "YYZ", "destination": "YVR"}],
        "outcomes": [{"seg": 1, "kind": "delay", "arrDelayMin": 240, "delayCode": "64"}],
        "expect": {"regime": "APPR", "eligibility": "ELIGIBLE"}}


def check(name: str, ok: bool, detail: str = "") -> None:
    if not ok:
        FAILED.append(f"{name}: {detail}")


def refused(fn, *args, **kw) -> str:
    try:
        fn(*args, **kw)
    except SpecError as ex:
        return str(ex)
    return ""


def builder_sees(spec: pathlib.Path) -> set[str]:
    """What `builder/apply_patches.py` would build: it walks every folder but `_superseded`."""
    sys.path.insert(0, str(ROOT / "builder"))
    try:
        import apply_patches
    except Exception:                                                       # noqa: BLE001
        return set()
    found, _ = apply_patches.discover(tree=str(spec))
    return set(found)


def main() -> int:
    with tempfile.TemporaryDirectory() as tmp:
        spec = pathlib.Path(tmp) / "spec"
        (spec / "fd" / "uat" / "automation").mkdir(parents=True)
        store = SpecStore(spec)

        name = store.create_set("fd", "uat", "ui")
        check("create set", name == "fd/uat/ui", name)
        check("unknown flow refused", "unknown flow" in refused(store.create_set, "xx", "uat", "a"))
        check("existing set refused", "already exists" in refused(store.create_set, "fd", "uat", "ui"))

        store.create("fd/uat/ui", CASE)
        check("create case", (spec / "fd/uat/ui/T_001.json").exists())
        check("duplicate id refused across sets",
              "already exists" in refused(store.create, "fd/uat/automation", CASE))
        check("bad id refused", "case id" in refused(store.create, "fd/uat/ui", {**CASE, "id": "a b"}))

        store.update("T_001", {**CASE, "summary": "edited"})
        saved = json.loads((spec / "fd/uat/ui/T_001.json").read_text(encoding="utf-8"))
        check("update writes", saved["summary"] == "edited", saved.get("summary"))
        history = store.case("T_001")["history"]
        check("update keeps the old text", len(history) == 1, str(history))
        store.revert("T_001", history[0])
        saved = json.loads((spec / "fd/uat/ui/T_001.json").read_text(encoding="utf-8"))
        check("revert restores", saved["summary"] == "a delay", saved.get("summary"))

        store.update("T_001", {**CASE, "id": "T_009"})
        check("rename by id", (spec / "fd/uat/ui/T_009.json").exists()
              and not (spec / "fd/uat/ui/T_001.json").exists())

        store.clone("T_009", "T_010", "fd/uat/automation")
        check("clone into another set", (spec / "fd/uat/automation/T_010.json").exists())

        store.delete("T_010")
        check("delete keeps the file in _superseded",
              (spec / "fd/uat/automation/_superseded/T_010.json").exists())
        check("deleted case is not a case", "T_010" not in store.source.index())
        store.restore("fd/uat/automation", "T_010.json")
        check("restore", "T_010" in store.source.index())

        out = refused(store.import_many, "fd/uat/ui", [{**CASE, "id": "T_020"}, {**CASE, "id": "T_009"}])
        check("a bad item stops the whole import", "nothing imported" in out
              and not (spec / "fd/uat/ui/T_020.json").exists(), out)
        store.import_many("fd/uat/ui", [{**CASE, "id": "T_020"}, [{**CASE, "id": "T_021"}][0]])
        check("import", {"T_020", "T_021"} <= set(store.source.index()))

        # the builder walks every folder under spec/ except _superseded: history and archived sets
        # must live outside the tree, or they would be built as cases of their own
        seen = builder_sees(spec)
        if seen:
            check("history is not built", not any("--" in c for c in seen), str(sorted(seen)))

        where = store.archive_set("fd/uat/ui")
        check("archive moves the set out of the tree", "fd/uat/ui" not in store.source.sets()
              and not (spec / "fd/uat/ui").exists(), where)
        archived = store.archived_sets()
        check("archived set is listed", len(archived) == 1, str(archived))
        store.restore_set(archived[0]["id"])
        check("restore set", "fd/uat/ui" in store.source.sets())

        check("path outside refused", bool(refused(store.revert, "T_009", "../../x.json")))

    for f in FAILED:
        print("FAIL", f)
    print(f"{len(FAILED)} failure(s)" if FAILED else "all checks passed")
    return 1 if FAILED else 0


if __name__ == "__main__":
    raise SystemExit(main())
