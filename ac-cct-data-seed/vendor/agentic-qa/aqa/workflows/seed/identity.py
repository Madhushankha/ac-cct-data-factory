"""Fresh, collision-free identities: locator, pnr_id, ticket numbers, passenger names, flight.

Rules (HOWTO §6-§8, LEARNINGS §10.2/§10.3):
- never a ZZ-prefixed locator (eds/Flink drops them); never reuse a locator that exists in trip;
- ticket numbers are 014 + 10 digits and globally unique in ticket.primary_document_number
  (a duplicate INSERT silently no-ops), so every set mints a fresh prefix and a serial range
  checked free for exactly the numbers it will issue;
- passenger surnames must be absent from the passenger table (name uniqueness checkpoint);
- flight numbers default to the synthetic band 9000-9999 so a seeded leg never collides with a
  real FDM test-feed flight on the same date;
- the database only knows a value once its PNR has been published, so parallel workers also
  reserve every minted locator, surname, ticket prefix and (flight number, date) in-process:
  two cases minting in the same second can never pick the same one.
"""
from __future__ import annotations

import random
import string
import threading
from dataclasses import dataclass

_RESERVED_LOCK = threading.Lock()
_RESERVED: dict[str, set] = {"locator": set(), "surname": set(), "ticket_prefix": set(), "flight": set()}

# How far up a ticket prefix we will issue serials. INT holds ~3,300 rows below this across
# every 014 prefix and ~578,000 above it, so the low band is where a free number is findable.
SERIAL_BAND = 300


def reserve(kind: str, value) -> bool:
    """Claim `value` for this process; False when another worker already holds it."""
    with _RESERVED_LOCK:
        if value in _RESERVED[kind]:
            return False
        _RESERVED[kind].add(value)
        return True


def reserved(kind: str) -> set:
    with _RESERVED_LOCK:
        return set(_RESERVED[kind])


def clear_reservations() -> None:   # tests only
    with _RESERVED_LOCK:
        for v in _RESERVED.values():
            v.clear()

_ALPHA = string.ascii_uppercase
_ALNUM = string.ascii_uppercase + string.digits
# Three syllables from fifteen is 3,375 names, and every seeded passenger takes one for good: the
# check is against the whole `passenger` table, not this run. Several hundred PNRs a day walked that
# down until 200 random draws could all collide and minting failed outright -- six cases of one
# baggage run died on it. Thirty syllables give 27,000 at three, and `_surname` falls back to four
# (810,000) when the short space is crowded, which is still twelve characters.
_SYLL = ["BAR", "DEN", "KOR", "MAL", "NEV", "RIL", "SOR", "TAV", "VOL", "WEN", "ZAR", "LUN", "PER",
         "QUI", "HAL", "BRE", "CAS", "DOR", "FEN", "GIL", "HOV", "JAR", "KEL", "MOR", "NAL", "OST",
         "PAV", "REN", "TUL", "VAS"]


@dataclass
class Identity:
    locator: str
    booking_date: str
    flight_date: str
    pnr_id: str
    surnames: list[str]
    tickets: list[str]
    flight_number: int
    ticket_prefix: str


def _rand_locator(rng: random.Random) -> str:
    while True:
        loc = rng.choice(_ALPHA) + "".join(rng.choice(_ALNUM) for _ in range(5))
        if not loc.startswith("ZZ"):
            return loc


def _surname(rng: random.Random, parts: int = 3) -> str:
    return "".join(rng.choice(_SYLL) for _ in range(parts))[:12]


def mint(conn, *, npax: int, booking_date: str, flight_date: str, seed: int | None = None,
         flight_number: int | None = None, prefer_surnames: list[str] | None = None) -> Identity:
    """Mint an identity checked against trip-tracer (conn may be None for offline dry runs).

    prefer_surnames: scenario surnames to keep when they are still absent from the passenger table;
    a taken one is replaced by a minted syllable surname.
    """
    rng = random.Random(seed)
    cur = conn.cursor() if conn is not None else None

    def taken(sql: str, *args) -> bool:
        if cur is None:
            return False
        cur.execute(sql, args)
        return cur.fetchone()[0] > 0

    # locator / pnr_id
    for _ in range(200):
        loc = _rand_locator(rng)
        if not taken("select count(*) from trip where pnr = %s", loc) and reserve("locator", loc):
            break
    else:
        raise RuntimeError("could not mint a free locator")
    pnr_id = f"{loc}-{booking_date}"

    # surnames: one per passenger, DB-absent (prefer the scenario's own when still unused)
    surnames: list[str] = []
    for i in range(npax):
        want = (prefer_surnames[i].upper() if prefer_surnames and i < len(prefer_surnames) else None)
        if (want and want not in surnames and not taken("select count(*) from passenger where upper(last_name) = %s", want)
                and reserve("surname", want)):
            surnames.append(want)
            continue
        for attempt in range(200):
            # The first fifty draws stay short, because a three-syllable name reads better; after
            # that the short space is evidently crowded and a fourth syllable is worth more than
            # another fifty collisions.
            s = _surname(rng, 3 if attempt < 50 else 4)
            if (s not in surnames and not taken("select count(*) from passenger where upper(last_name) = %s", s)
                    and reserve("surname", s)):
                surnames.append(s)
                break
        else:
            raise RuntimeError("could not mint a free surname")

    # Ticket numbers: a 6-digit 014xxx prefix plus a 7-digit serial. Only the numbers this booking
    # will actually issue have to be free — an earlier rule demanded the whole 000001-000300 band be
    # empty, which asked for 300 slots to hand out two or three and exhausted every prefix in INT
    # after a few hundred seeded cases (all 700 of 014300-014999 were dead, over 3,303 rows).
    # The band stays low because that is where INT is sparse: the real ticket stock sits above 300.
    prefix = start = None
    for _ in range(300):
        cand, first = f"014{rng.randint(0, 999):03d}", rng.randint(1, SERIAL_BAND - npax + 1)
        if taken("select count(*) from ticket where primary_document_number between %s and %s",
                 f"{cand}{first:07d}", f"{cand}{first + npax - 1:07d}"):
            continue
        if reserve("ticket_prefix", cand):        # one prefix per booking, so tickets never interleave
            prefix, start = cand, first
            break
    if prefix is None:
        raise RuntimeError("could not find a free ticket number range")
    tickets = [f"{prefix}{start + i:07d}" for i in range(npax)]

    # flight number: a leg id is carrier + number + date, so two cases on the same date must not share one
    if flight_number:
        fn = flight_number
        reserve("flight", (fn, flight_date))
    else:
        for _ in range(800):
            fn = rng.randint(9100, 9899)
            if reserve("flight", (fn, flight_date)):
                break
        else:
            raise RuntimeError("could not mint a free flight number")
    return Identity(locator=loc, booking_date=booking_date, flight_date=flight_date, pnr_id=pnr_id,
                    surnames=surnames, tickets=tickets, flight_number=fn, ticket_prefix=prefix)
