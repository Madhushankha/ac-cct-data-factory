"""Handing seeded bookings to the automation half, as a pool file.

Implements `ports.BookingSink`.

The Playwright suite under `automation/` picks a booking by STATE, not by name:

    booking: { pool: any, pick: next-unused, need: [eligible, appr], avoid: [partner] }

so a scenario keeps working when the data is reseeded under new locators. It reads those pools from
`automation/playwright-baggage/data/pools/*.yaml`, merged by `src/bookings.ts`, which has always
documented them as "generated pools (one file each, e.g. from an agentic-qa seed dataset)". This
writes that file. The two halves were built to meet here; nothing new is invented.

**Why not the seed report.** The suite's other route, `npm run import-seed`, parses the seed REPORT:
regexes over `<div class="pnr">` and `<td class="pick">` to recover the PNRs, the passenger, the
contact address and the state tags -- re-deriving from prose (`/counts as lost/i.test(what)`) what
the seeder held as data one process earlier. It works, and it is how the existing baggage pools were
made, but a markup change breaks it silently and a lost tag does not fail: it makes a scenario pick
the wrong booking and report a real-looking result. That route stays for the 14 historical reports;
new runs come through here.

**The tags come from the flow policy**, because only the flow knows what state its cases are in.
This adapter writes what it is given and decides nothing about it.

The file is written with `yaml.safe_dump`, so a passenger name with a colon in it, or a note holding
`|`, cannot produce a file the suite reads differently from what we meant.
"""
from __future__ import annotations

import datetime as _dt
import pathlib
from typing import Iterable

import yaml

from core import paths
from domain.models import Booking

#: the suite's own pool directory, which `src/bookings.ts` merges on every run
POOL_DIR = paths.AUTOMATION / "playwright-baggage" / "data" / "pools"

#: One inbox takes every scenario's mail, so the surname is what tells a run which scenario a
#: message belongs to -- see `adapters/kafka_publisher.case_surname`. A pool whose bookings carry
#: their own `last` needs no pool-level name, which is why `first`/`last` are written per booking.
MAILINATOR_DOMAIN = "ae-qa1-aircanada.mailinator.com"


class PoolFileSink:
    """Writes a booking pool the automation suite can pick from. Satisfies `ports.BookingSink`."""

    def __init__(self, directory: pathlib.Path | None = None, *, log=print) -> None:
        self.directory = directory or POOL_DIR
        self.log = log

    def hand_off(self, name: str, bookings: Iterable[Booking], *,
                 tags: dict[str, tuple[str, ...]] | None = None,
                 names: dict[str, tuple[str, str]] | None = None,
                 aeroplan: dict[str, str] | None = None,
                 dataset: str = "", email: str = "") -> str:
        """Write `<name>.yaml`. One file per run, so a run can be handed over or dropped alone.

        `names` maps pnrId to the name the booking actually carries, which the publisher resolves:
        the builder takes it from one of five anonymised histories, and `--unique-name` then
        rewrites the surname per case. A chat run identifies the customer by that name, so handing
        over the spec's name instead would fail to find the booking.
        """
        bookings = [b for b in bookings if b.locator]
        if not bookings:
            self.log("[pool] nothing to hand off: no booking has a locator")
            return ""
        tags = tags or {}
        self.directory.mkdir(parents=True, exist_ok=True)
        path = self.directory / f"{_safe(name)}.yaml"

        rows = []
        names, aeroplan = names or {}, aeroplan or {}
        missing_names = []
        for b in bookings:
            first, last = names.get(b.pnr_id) or ("", "")
            if not first and not last:
                first, _, last = (b.passenger_name or "").partition(" ")
            if not (first or last):
                missing_names.append(b.case_id or b.locator)
            row: dict[str, object] = {"pnr": b.locator}
            if first:
                row["first"] = first.title()
            if last:
                row["last"] = last.strip().title()
            row["tags"] = list(tags.get(b.case_id) or ())
            if b.flight:
                row["flight"] = b.flight
            if b.flight_date:
                # the suite calls this `landed`: the day the disruption happened, which is what a
                # customer says in the chat
                row["landed"] = b.flight_date
            row["caseId"] = b.case_id
            # the member minted for this case. A chat run quoting an Aeroplan number has to quote
            # the one the booking's profile actually carries, not the marker in the fixture.
            if aeroplan.get(b.case_id):
                row["aeroplan"] = aeroplan[b.case_id]
            if b.route:
                row["note"] = f"{b.route} | {b.case_id}"
            rows.append(row)

        pool = {
            "dataset": dataset or name,
            "source": "ac-cct-data-seed (seeded, not parsed from a report)",
            "seededAt": _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds"),
            "otp": _otp(email),
            "bookings": rows,
        }
        path.write_text(
            "# Written by ac-cct-data-seed: one pool per seeded run.\n"
            "# Scenarios pick by state, never by locator:\n"
            "#   booking: { pool: %s, pick: next-unused, need: [eligible, appr] }\n"
            "# Regenerate by re-seeding; do not hand-edit (the next run overwrites it).\n"
            % _safe(name)
            + yaml.safe_dump({"pools": {_safe(name): pool}}, sort_keys=False, allow_unicode=True,
                             width=10_000),
            encoding="utf-8")
        self.log(f"[pool] {len(rows)} booking(s) -> {path}")
        if missing_names:
            # said rather than left blank: a chat run identifies the customer by name, and an empty
            # one makes the scenario fail at identification with nothing explaining why
            self.log(f"[pool] no passenger name for {len(missing_names)}: "
                     f"{', '.join(missing_names[:5])} -- those bookings cannot be identified in a "
                     f"chat run")
        return str(path)


def _otp(email: str) -> dict[str, str]:
    """How the run gets the one-time code for these bookings.

    A `*.mailinator.com` contact is fetched automatically by the suite; anything else means a person
    has to drop the code in, which the suite waits for. Saying which, honestly, is the difference
    between a run that takes minutes and one that hangs for ten of them per booking.
    """
    if email and email.lower().rstrip().endswith("mailinator.com"):
        inbox, _, domain = email.partition("@")
        return {"provider": "mailinator", "domain": domain, "inbox": inbox}
    if email:
        return {"provider": "manual", "sentTo": email}
    return {"provider": "mailinator", "domain": MAILINATOR_DOMAIN, "inbox": "lahiru"}


def _safe(name: str) -> str:
    return "".join(c if c.isalnum() or c in "-_" else "-" for c in name).strip("-").lower()
