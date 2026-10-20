"""Every module that extends `sys.path` must do so BEFORE importing anything of ours.

Three modules got this wrong, all the same way, and all three failed only when run rather than when
read:

* `tools/disagreement_report.py` imported `core` above its `sys.path.insert`, so Python resolved
  `core` to a DIFFERENT checkout on this machine (`cct-qa-framework/core`) and died with
  `ImportError: cannot import name 'paths'`.
* `tools/import_po.py` and `core/seed.py` carried `# noqa: E402, paths` -- naming `paths` in a
  comment instead of importing it -- so both raised `NameError` on first use. `core/seed.py` had
  never been importable at all, which is why nothing noticed.

In each case a `# noqa: E402` silenced the one warning that flags the problem. A comment cannot
import a module and cannot reorder a file, so this checks the thing itself.

Run:  python tests/test_import_order.py
"""
from __future__ import annotations

import ast
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

#: our own top-level packages. An import of one of these before the path is set is the bug.
OURS = {"core", "domain", "ports", "flows", "adapters", "application", "cli", "lanes",
        "tools", "spec", "builder"}

#: `# noqa: E402, paths` -- a module named inside a suppression comment, which is how two files
#: came to reference something they never imported
NOQA_NAMES = re.compile(r"#\s*noqa:[^\n]*\b(" + "|".join(sorted(OURS)) + r")\b")

FAILED: list[str] = []


def path_insert_line(tree: ast.Module, source: str) -> int | None:
    """The line where the module puts its OWN root on `sys.path`.

    Only that one matters. A module that inserts an EXTERNAL path (agentic-qa, the qa-builder) is
    reaching for somebody else's code and its own imports are unaffected -- the adapters all do
    this inside a method, and flagging them would make this check noise.
    """
    lines = source.splitlines()
    for node in ast.walk(tree):
        if (isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute)
                and node.func.attr == "insert"
                and isinstance(node.func.value, ast.Attribute)
                and node.func.value.attr == "path"):
            text = lines[node.lineno - 1] if node.lineno <= len(lines) else ""
            if "ROOT" in text or "parent.parent" in text:
                return node.lineno
    return None


def first_party_imports(tree: ast.Module) -> list[tuple[int, str]]:
    out = []
    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom) and node.module and node.level == 0:
            top = node.module.split(".")[0]
            if top in OURS:
                out.append((node.lineno, node.module))
        elif isinstance(node, ast.Import):
            for a in node.names:
                if a.name.split(".")[0] in OURS:
                    out.append((node.lineno, a.name))
    return out


def main() -> int:
    checked = 0
    for path in sorted(ROOT.rglob("*.py")):
        rel = path.relative_to(ROOT).as_posix()
        if any(part in ("vendor", "builder", "node_modules", "__pycache__", "runs", "reference")
               for part in path.relative_to(ROOT).parts):
            continue
        text = path.read_text(encoding="utf-8")
        checked += 1

        for m in NOQA_NAMES.finditer(text):
            line = text[:m.start()].count("\n") + 1
            FAILED.append(f"{rel}:{line} names {m.group(1)!r} in a noqa comment -- a comment "
                          f"cannot import it")

        try:
            tree = ast.parse(text)
        except SyntaxError as ex:
            FAILED.append(f"{rel}: does not parse: {ex}")
            continue

        inserted = path_insert_line(tree, text)
        if inserted is None:
            continue
        for line, module in first_party_imports(tree):
            if line < inserted:
                FAILED.append(f"{rel}:{line} imports {module!r} before sys.path is extended on "
                              f"line {inserted} -- it will resolve against another checkout")

    print(f"checked {checked} modules")
    if FAILED:
        for f in FAILED:
            print(f"  FAIL {f}")
        print(f"\n{len(FAILED)} problem(s)")
        return 1
    print("every module extends sys.path before importing ours, and no noqa comment "
          "stands in for an import")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
