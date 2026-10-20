"""The limits a seeding run obeys, and where each number comes from.

Every value here was measured against a real environment by the uat-scenarios kit, which seeded 344
scenarios on BAT on 2026-10-15. A limit without its reason gets raised by the next person in a
hurry, so the reason travels with it.

Two of these are not performance tuning but correctness:

* `CASE_PARALLEL` -- 16 concurrent reads made TripTracer answer "unavailable", and an unavailable
  answer is indistinguishable from a blocked case in a report. Exceeding this does not slow a run
  down, it makes the results wrong.
* `RUN_TAG` uniqueness -- case intake keys requests by run tag. Re-sending a batch under a tag that
  already ran returns 409 `idempotency_key_payload_mismatch`, so a retry that reuses a tag destroys
  the evidence of the first attempt.
"""
from __future__ import annotations

import datetime as _dt
from dataclasses import dataclass

#: messages per second to a shared topic. The kit publishes at this rate across 344 bookings.
PUBLISH_RATE = 50

#: bookings built and published per batch.
BATCH_SIZE = 120

#: concurrent cases that will go on to READ TripTracer or DDS. Six is the proven ceiling; the kit's
#: own note is blunt about it -- "16 at once overloads BAT TripTracer, and its 'TripTracer
#: unavailable' answers show up as BLOCKED".
CASE_PARALLEL = 6

#: concurrent cases when nothing reads back yet (index/publish only). The agentic-qa runner has run
#: 10 at a time routinely, and 50 is its hard maximum; nobody has measured what INT Flink takes
#: above 10, so 10 stays the default rather than becoming a floor.
SEED_PARALLEL = 10

#: seconds to wait after the last publish before reading, for the ingest to fold the events.
#:
#: The kit uses 90 and that is what this said. Measured on INT on 2026-10-16 it is far too short:
#: a DEP and an ARR published for AC#9485#2026-06-19#YYZ were still absent from the Trip at three
#: polls 20s apart and at a separate read seven minutes later, and had folded by about ten minutes.
#: A 90-second read on INT reports "not ingested" for a message that simply has not landed yet,
#: which is the error that sent a whole investigation down the wrong path.
GATE_WAIT = 90
GATE_WAIT_INT = 660

#: the DDS pin runs through ECS exec / SSM, which is rate limited; the agentic-qa runner holds it
#: behind this many slots.
PIN_SLOTS = 3

#: a consumer report older than this many minutes is refreshed; the publish itself refuses one
#: older than six hours.
CONSUMER_REPORT_MAX_AGE_MIN = 300

#: how many times the parser check may run before a batch is abandoned. The first pass drops the
#: bookings TripTracer's parsers refuse; the second checks what is left. There is no third: a batch
#: that still fails is not published.
PARSER_CHECK_TRIES = 2

#: a task-start throttle may be retried once, after this long. Nothing else is ever retried -- a
#: batch that RAN must not be sent again under the same tag.
THROTTLE_RETRY_SECONDS = 60


@dataclass(frozen=True)
class Limits:
    """The limits for one run, so a caller can lower them without editing this module."""
    publish_rate: int = PUBLISH_RATE
    batch_size: int = BATCH_SIZE
    parallel: int = SEED_PARALLEL
    read_parallel: int = CASE_PARALLEL
    gate_wait: int = GATE_WAIT
    pin_slots: int = PIN_SLOTS

    def checked(self) -> "Limits":
        """Raise on a value that is wrong rather than merely bold."""
        if self.read_parallel > CASE_PARALLEL:
            raise ValueError(
                f"read_parallel={self.read_parallel} exceeds the measured ceiling of "
                f"{CASE_PARALLEL}: above it TripTracer answers 'unavailable', which a report "
                f"cannot tell apart from a blocked case")
        if self.parallel > 50:
            raise ValueError(f"parallel={self.parallel} exceeds the runner's maximum of 50")
        if self.parallel < 1 or self.read_parallel < 1:
            raise ValueError("parallel and read_parallel must be at least 1")
        return self


def run_tag(now: _dt.datetime | None = None) -> str:
    """A tag that has not been used before, in the kit's own format (UTC MMDDHHMM).

    Used once. Case intake keys its idempotency on this, so reusing one turns a rerun into a 409
    against the first attempt's payload.
    """
    return (now or _dt.datetime.now(_dt.timezone.utc)).strftime("%m%d%H%M")


def run_day(now: _dt.datetime | None = None) -> _dt.date:
    """The run day, which is the UTC date -- and the trap that comes with it.

    After about 20:00 Eastern, UTC has already moved to tomorrow, so a flight pinned to "yesterday"
    may not have landed and TripTracer returns no result for it. The kit hit this on SOC_UAT_076.
    A caller that knows better passes its own date.
    """
    return (now or _dt.datetime.now(_dt.timezone.utc)).date()


def flight_key(carrier: str, number: str | int, day: _dt.date | str, origin: str) -> str:
    """The identity two bookings must not share: carrier, number, day and origin.

    The kit keeps a list of these (`taken-acc.json`) because an environment that already holds
    another booking on the same flight makes the checkpoints read THAT flight's data. The failure
    looks like bad seed data and is not.
    """
    return f"{carrier}#{number}#{day}#{origin}"
