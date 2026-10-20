"""`python -m ui`: start the seeding UI on this machine and open it in the browser.

    python -m ui                 http://127.0.0.1:8770
    python -m ui --port 9000     another port
    python -m ui --no-browser    do not open a browser tab
"""
from __future__ import annotations

import argparse
import pathlib
import sys
import threading
import webbrowser

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))


def main() -> int:
    ap = argparse.ArgumentParser(prog="python -m ui", description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--port", type=int, default=8770)
    ap.add_argument("--no-browser", action="store_true")
    args = ap.parse_args()
    try:
        import uvicorn
    except ImportError:
        print("The UI needs FastAPI and uvicorn:  pip install -r ui/requirements.txt")
        return 1
    url = f"http://127.0.0.1:{args.port}"
    print(f"ac-cct-data-seed UI on {url}  (Ctrl+C to stop)")
    if not args.no_browser:
        threading.Timer(1.5, lambda: webbrowser.open(url)).start()
    # 127.0.0.1 only: the UI acts with this machine's credentials and is not meant to be shared
    uvicorn.run("ui.server:app", host="127.0.0.1", port=args.port, log_level="warning")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
