"""Who each seeded booking actually is, as published: name, contact, Aeroplan number, e-ticket.

    from tools.booking_identity import identities, cell
    ids = identities(records, label="soc-uat-automation-1020T1022", env="int",
                     runs_dir=pathlib.Path("runs/int"))
    cell(lookup(ids, record))       # -> the "passenger" cell for a report row

A tester handed a PNR still has to log in as that passenger, read the OTP from the right inbox and
quote the right ticket, and none of that is in the run record. It lives in two places the seeder
already wrote:

* **the pool file** it handed to the automation suite (`adapters/pool_file.py`), which holds the
  PUBLISHED names -- after the wallet/member rename, so they beat anything in the run record -- the
  Aeroplan number, and a booking's own e-mail/phone when the run was seeded with one inbox per case
* **the built batch** that produced the run (`runs/<env>/build-*/b*/`), whose `messages.jsonl`
  carries the e-ticket as `primaryDocumentNumber` inside each message's escaped JSON value

A booking with no e-mail/phone of its own was stamped with the shared contact
(`adapters/kafka_publisher.py::_rewrite`: own, else the run's, else the environment's), so that is
what is shown -- marked as shared, because a shared inbox means the run must tell its mail apart by
first name.

Nothing here fails a report: a missing pool or batch leaves the fields blank.
"""
from __future__ import annotations

import html
import json
import pathlib
import re
import sys

import yaml

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

#: the environment contact when `aqa`'s ENVS cannot be read -- the value it holds for int
DEFAULT_EMAIL = "lahiru@ae-qa1-aircanada.mailinator.com"
DEFAULT_PHONE = "+123456789"

#: matches the ticket both in a raw line (`\"primaryDocumentNumber\":\"014...\"`) and in plain JSON
_TICKET = re.compile(r'primaryDocumentNumber\\*"\s*:\s*\\*"(\d+)')


def pool_dir() -> pathlib.Path:
    try:
        from adapters.pool_file import POOL_DIR                             # noqa: PLC0415
        return POOL_DIR
    except Exception:                                                       # noqa: BLE001
        return ROOT.parent / "ac-cct-data-automation" / "playwright-baggage" / "data" / "pools"


def pool_name(label: str) -> str:
    """The pool file's name for a run label, as `adapters/pool_file.py::_safe` writes it."""
    return "".join(c if c.isalnum() or c in "-_" else "-" for c in label).strip("-").lower()


def default_contact(env: str) -> tuple[str, str]:
    """The contact the publisher stamps when a booking has none of its own."""
    try:
        from core import paths                                             # noqa: PLC0415
        sys.path.insert(0, str(paths.require("agentic-qa")))
        from aqa.workflows.seed.env import ENVS                            # noqa: PLC0415
        env_def = ENVS[env]
        return (str(env_def.contact_email or DEFAULT_EMAIL),
                str(env_def.contact_phone or DEFAULT_PHONE))
    except Exception:                                                      # noqa: BLE001
        return DEFAULT_EMAIL, DEFAULT_PHONE


def pool_bookings(label: str, directory: pathlib.Path | None = None) -> list[tuple[dict, dict]]:
    """Every (booking, its pool) in the run's pool file(s).

    A run seeded in batches writes one pool per batch (`fd-266-int-1019c-b01.yaml` ...), so the
    `-b*` siblings are read too.
    """
    directory = directory or pool_dir()
    name = pool_name(label)
    files = [directory / f"{name}.yaml", *sorted(directory.glob(f"{name}-b*.yaml"))]
    out = []
    for path in files:
        if not path.is_file():
            continue
        try:
            doc = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
        except Exception:                                                   # noqa: BLE001
            continue
        for pool in (doc.get("pools") or {}).values():
            if not isinstance(pool, dict):
                continue
            for booking in pool.get("bookings") or []:
                if isinstance(booking, dict):
                    out.append((booking, pool))
    return out


def tickets(pnr_ids: set[str], runs_dir: pathlib.Path) -> dict[str, list[str]]:
    """pnrId -> its e-ticket number(s), from the newest built batch that holds the booking.

    The same pnrId can appear in more than one build (a rebuild after a fix); the newest one is the
    one that was published, and `build-MMDDTHHMM` sorts in time order. A multi-passenger booking
    has one ticket per passenger, and a booking can carry more than one document, so every unique
    number is kept, in the order the batch first mentions it.
    """
    owner: dict[str, pathlib.Path] = {}
    for manifest in sorted(runs_dir.glob("build-*/b*/manifest.json")):
        try:
            rows = json.loads(manifest.read_text(encoding="utf-8"))
        except Exception:                                                   # noqa: BLE001
            continue
        for row in rows if isinstance(rows, list) else []:
            if isinstance(row, dict) and row.get("pnrId") in pnr_ids:
                owner[row["pnrId"]] = manifest.parent

    out: dict[str, list[str]] = {}
    by_batch: dict[pathlib.Path, set[str]] = {}
    for pid, batch in owner.items():
        by_batch.setdefault(batch, set()).add(pid)
    for batch, wanted in by_batch.items():
        path = batch / "batch" / "messages.jsonl"
        if not path.is_file():
            continue
        with path.open(encoding="utf-8") as fh:
            for line in fh:
                if "primaryDocumentNumber" not in line:
                    continue
                try:
                    booking = json.loads(line).get("booking")
                except Exception:                                           # noqa: BLE001
                    continue
                if booking not in wanted:
                    continue
                seen = out.setdefault(booking, [])
                for number in _TICKET.findall(line):
                    if number not in seen:
                        seen.append(number)
    return out


def identities(records: list[dict], *, label: str, env: str,
               runs_dir: pathlib.Path | None = None,
               pool_directory: pathlib.Path | None = None) -> dict[str, dict]:
    """{pnrId and locator and case id: {first, last, email, phone, email_shared, phone_shared,
    aeroplan, tickets}} for every record of one run.

    Keyed three ways so each report can look a row up with whatever it holds.
    """
    shared_email, shared_phone = default_contact(env)
    by_case: dict[str, tuple[dict, dict]] = {}
    by_pnr: dict[str, tuple[dict, dict]] = {}
    for booking, pool in pool_bookings(label, pool_directory):
        if booking.get("caseId"):
            by_case[str(booking["caseId"])] = (booking, pool)
        if booking.get("pnr"):
            by_pnr[str(booking["pnr"])] = (booking, pool)

    pnr_ids = {str(r["pnrId"]) for r in records if r.get("pnrId")}
    numbers = tickets(pnr_ids, runs_dir) if runs_dir else {}

    out: dict[str, dict] = {}
    for rec in records:
        cid, loc, pid = (str(rec.get(k) or "") for k in ("case", "locator", "pnrId"))
        booking, pool = (by_case.get(cid) or by_case.get(cid.split("#")[0])
                         or by_pnr.get(loc) or ({}, {}))
        # the pool's own otp inbox is the run-wide address when `--email` overrode the env's
        otp = pool.get("otp") or {}
        run_email = (f"{otp['inbox']}@{otp['domain']}"
                     if otp.get("inbox") and otp.get("domain") else "")
        found = bool(booking)
        ident = {
            "first": str(booking.get("first") or ""),
            "last": str(booking.get("last") or ""),
            "email": str(booking.get("email") or (run_email or shared_email if found else "")),
            "email_shared": found and not booking.get("email"),
            "phone": str(booking.get("phone") or (shared_phone if found else "")),
            "phone_shared": found and not booking.get("phone"),
            "aeroplan": str(booking.get("aeroplan") or ""),
            "tickets": numbers.get(pid, []),
        }
        for key in (pid, loc, cid):
            if key:
                out[key] = ident
    return out


def lookup(ids: dict[str, dict], rec: dict) -> dict:
    for key in ("case", "pnrId", "locator"):
        if rec.get(key) and str(rec[key]) in ids:
            return ids[str(rec[key])]
    return {}


def cell(ident: dict, fallback_name: str = "") -> str:
    """The compact passenger block: name bold, then e-mail, phone, Aeroplan, ticket(s).

    All of it is text inside the row, so the page's filter box matches every field.
    """
    e = html.escape
    name = " ".join(p for p in (ident.get("first"), ident.get("last")) if p) or fallback_name
    lines = [f"<b>{e(name)}</b>" if name else "&mdash;"]
    if ident.get("email"):
        lines.append(f"<div class='idl mono'>{e(ident['email'])}"
                     + (" <span class=why>(shared default)</span>"
                        if ident.get("email_shared") else "") + "</div>")
    if ident.get("phone"):
        lines.append(f"<div class='idl mono'>{e(ident['phone'])}"
                     + (" <span class=why>(shared default)</span>"
                        if ident.get("phone_shared") else "") + "</div>")
    if ident.get("aeroplan"):
        lines.append(f"<div class='idl mono'>Aeroplan {e(ident['aeroplan'])}</div>")
    for number in ident.get("tickets") or []:
        lines.append(f"<div class='idl mono'>ticket {e(number)}</div>")
    return "".join(lines)


def line(ident: dict) -> str:
    """The same fields on one line, for a scenario block's text."""
    e = html.escape
    bits = []
    name = " ".join(p for p in (ident.get("first"), ident.get("last")) if p)
    if name:
        bits.append(f"<b>{e(name)}</b>")
    if ident.get("email"):
        bits.append(f"<span class=mono>{e(ident['email'])}</span>"
                    + (" (shared default)" if ident.get("email_shared") else ""))
    if ident.get("phone"):
        bits.append(f"<span class=mono>{e(ident['phone'])}</span>"
                    + (" (shared default)" if ident.get("phone_shared") else ""))
    if ident.get("aeroplan"):
        bits.append(f"Aeroplan <span class=mono>{e(ident['aeroplan'])}</span>")
    if ident.get("tickets"):
        bits.append("ticket <span class=mono>" + e(", ".join(ident["tickets"])) + "</span>")
    return " &middot; ".join(bits)
