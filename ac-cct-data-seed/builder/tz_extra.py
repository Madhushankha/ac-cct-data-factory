"""Airports the /qa builder's time-zone table lacks (it assumes Eastern for them)."""
import builder

EXTRA = {"CEB": "Asia/Manila", "HFA": "Asia/Jerusalem", "VDA": "Asia/Jerusalem", "YHM": "America/Toronto"}
for k, v in EXTRA.items():
    builder.TZ.setdefault(k, v)
