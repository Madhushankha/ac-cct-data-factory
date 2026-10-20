"""The layering in `docs/architecture.md`, checked instead of described.

A documented rule nobody checks is a rule that was true once. This reads the imports and fails on a
violation, so the diagram and the code cannot come apart.

The rule that matters most: **`application/` must not import `adapters/`.** When it does, the use
case can no longer be tested without the service the adapter talks to, and `tests/test_seed_pack.py`
— which runs the whole thing against fakes — stops being possible.

Run:  python tests/test_layering.py
"""
from __future__ import annotations

import ast
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

#: layer -> the top-level packages of ours it must not import
FORBIDDEN = {
    "domain": {"ports", "adapters", "application", "flows", "cli", "core", "lanes", "tools"},
    "ports": {"adapters", "application", "flows", "cli", "core", "lanes", "tools"},
    "flows": {"adapters", "application", "cli", "lanes", "tools"},
    "application": {"adapters", "cli", "lanes", "tools"},
    "adapters": {"application", "flows", "cli", "lanes", "tools"},
}

#: `core/` is the previous generation. An adapter may name `core.paths`, which is where the outside
#: world is declared; nothing may reach for the rest of it.
CORE_ALLOWED = {"core.paths", "core"}

#: The two modules of the old dict-based flow interface, which import `core.flow` by design. They
#: are listed one by one rather than exempting `flows/` wholesale, so a NEW violation still fails.
LEGACY = {
    ("flows/fd.py", "core.flow"),
    ("flows/pending.py", "core.flow"),
}

FAILED: list[str] = []


def imports_of(path: pathlib.Path) -> list[str]:
    out = []
    for node in ast.walk(ast.parse(path.read_text(encoding="utf-8"))):
        if isinstance(node, ast.Import):
            out += [a.name for a in node.names]
        elif isinstance(node, ast.ImportFrom) and node.module and node.level == 0:
            out.append(node.module)
    return out


def main() -> int:
    checked = 0
    for layer, forbidden in FORBIDDEN.items():
        for path in sorted((ROOT / layer).glob("*.py")):
            rel = path.relative_to(ROOT).as_posix()
            checked += 1
            for name in imports_of(path):
                top = name.split(".")[0]
                if (rel, name) in LEGACY:
                    continue
                if top in forbidden:
                    FAILED.append(f"{rel} imports {name}: layer {layer!r} must not")
                elif top == "core" and name not in CORE_ALLOWED:
                    FAILED.append(f"{rel} imports {name}: only core.paths is allowed outside core")

    # the legacy exemptions must stay real: an entry for a module that no longer breaks the rule is
    # an exemption nobody will notice has become unnecessary
    for rel, module in sorted(LEGACY):
        path = ROOT / rel
        if not path.exists():
            FAILED.append(f"{rel} is listed as legacy but does not exist: drop the exemption")
        elif module not in imports_of(path):
            FAILED.append(f"{rel} no longer imports {module}: drop the exemption")

    print(f"checked {checked} modules across {len(FORBIDDEN)} layers, "
          f"{len(LEGACY)} legacy exemption(s)")
    if FAILED:
        for line in FAILED:
            print(f"  FAIL {line}")
        print(f"\n{len(FAILED)} violation(s)")
        return 1
    print("every layering rule in docs/architecture.md holds")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
