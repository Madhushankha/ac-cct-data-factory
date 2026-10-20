"""The compact form carries every spec, or it is not a transport format.

Run against the spec corpus:  python tests/test_compact_roundtrip.py [specs-dir]

The assertion is `decode(encode(spec)) == carried(spec)` for every spec, with the UI lines included
so nothing is excused. A spec the form cannot carry must raise NotCompactable and be counted, never
encoded into something smaller than the truth.
"""
from __future__ import annotations

import json
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
from spec import compact                                                    # noqa: E402


def diff(a: dict, b: dict, path: str = "") -> list[str]:
    """Every leaf that differs, named by its path, so a failure says which field moved."""
    out = []
    if type(a) is not type(b) and not (isinstance(a, (int, float)) and isinstance(b, (int, float))):
        return [f"{path}: {type(a).__name__} {a!r} != {type(b).__name__} {b!r}"]
    if isinstance(a, dict):
        for k in sorted(set(a) | set(b)):
            if k not in a:
                out.append(f"{path}.{k}: missing on the left, right has {b[k]!r}")
            elif k not in b:
                out.append(f"{path}.{k}: missing on the right, left has {a[k]!r}")
            else:
                out += diff(a[k], b[k], f"{path}.{k}")
    elif isinstance(a, list):
        if len(a) != len(b):
            out.append(f"{path}: {len(a)} items != {len(b)}")
        else:
            for i, (x, y) in enumerate(zip(a, b)):
                out += diff(x, y, f"{path}[{i}]")
    elif a != b:
        out.append(f"{path}: {a!r} != {b!r}")
    return out


def main(argv: list[str]) -> int:
    root = pathlib.Path(argv[1]) if len(argv) > 1 else pathlib.Path(__file__).parent.parent / "spec"
    files = sorted(root.rglob("*.json"))
    if not files:
        print(f"no specs under {root}")
        return 2

    ok = refused = 0
    failures: list[tuple[str, list[str]]] = []
    sizes: list[tuple[int, int]] = []

    for f in files:
        spec = json.loads(f.read_text(encoding="utf-8"))
        if not isinstance(spec, dict) or "id" not in spec:
            continue
        try:
            text = compact.encode(spec, ui=True)
        except compact.NotCompactable as ex:
            refused += 1
            print(f"  refused: {ex}")
            continue
        back = compact.decode(text)
        d = diff(compact.carried(spec, ui=True), compact.carried(back, ui=True), spec["id"])
        if d:
            failures.append((spec["id"], d))
        else:
            ok += 1
        sizes.append((len(json.dumps(spec)), len(compact.encode(spec, ui=False))))

    for cid, d in failures[:10]:
        print(f"\nFAIL {cid}")
        for line in d[:8]:
            print(f"    {line}")

    print(f"\nround trip: {ok} ok, {len(failures)} failed, {refused} refused (of {len(sizes) + refused})")
    if sizes:
        js = sum(a for a, _ in sizes) / len(sizes)
        cp = sum(b for _, b in sizes) / len(sizes)
        print(f"average size: {js:.0f} chars json -> {cp:.0f} chars compact "
              f"({cp / js:.0%}; ~{js / 3.7:.0f} -> ~{cp / 3.7:.0f} tokens)")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
