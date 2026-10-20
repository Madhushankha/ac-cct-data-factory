"""`python -m cli`. Dispatch only: each command lives in its own module under `cli/`."""
from __future__ import annotations

import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from cli import commands                                                    # noqa: E402

if __name__ == "__main__":
    raise SystemExit(commands.main(sys.argv[1:]))
