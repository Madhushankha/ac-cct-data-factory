"""Airport timezones, and the one conversion that matters.

The PNR a seed publishes carries LOCAL times (`localDateTime`), and trip tracer derives the instant
by converting them through the airport's own timezone -- that derived value is what lands in
`flight_segment.arrival_datetime` and what `flight_id` is built from. A fixture's stored `arr_utc`
is therefore a claim ABOUT that instant rather than anything that was sent, and it cannot stay true:
render shifts a fixture's dates to the run date, and an offset that held in June (TLV +3) does not
hold in October (TLV +2). FD_UAT_126 states 22:40 local arriving FRA-TLV with arr_utc 20:40, which
is Israel standard time on a date Israel is on daylight time.

So anything that needs the instant computes it here, from the local clock and the airport, the same
way the service that will read it does.

Los_Angeles and Denver stand in for Vancouver and Edmonton DELIBERATELY: in tzdata 2026.3 British
Columbia and Alberta have stopped observing daylight time (America/Vancouver reports MST all year),
while trip tracer still puts YVR on PST in winter. These times exist to be read by that service, so
they follow its clock; the two stand-ins keep the DST rule and the same standard offsets.
"""
from __future__ import annotations

from datetime import datetime
from zoneinfo import ZoneInfo

TZ = {
    # Canada
    "YUL": "America/Toronto", "YYZ": "America/Toronto", "YOW": "America/Toronto",
    "YTZ": "America/Toronto", "YHM": "America/Toronto", "YQB": "America/Toronto",
    "YKF": "America/Toronto", "YHZ": "America/Halifax", "YYT": "America/St_Johns",
    "YWG": "America/Winnipeg", "YXE": "America/Regina", "YQR": "America/Regina",
    "YYC": "America/Denver", "YEG": "America/Denver", "YVR": "America/Los_Angeles",
    "YYJ": "America/Los_Angeles",
    # United States
    "LAX": "America/Los_Angeles", "SFO": "America/Los_Angeles", "SEA": "America/Los_Angeles",
    "DEN": "America/Denver", "ORD": "America/Chicago", "DFW": "America/Chicago",
    "JFK": "America/New_York", "EWR": "America/New_York", "LGA": "America/New_York",
    "BOS": "America/New_York", "MIA": "America/New_York", "FLL": "America/New_York",
    # Europe, Middle East
    "LHR": "Europe/London", "LGW": "Europe/London", "MAN": "Europe/London",
    "EDI": "Europe/London", "DUB": "Europe/Dublin", "CDG": "Europe/Paris",
    "FRA": "Europe/Berlin", "MUC": "Europe/Berlin", "ZRH": "Europe/Zurich",
    "BRU": "Europe/Brussels", "AMS": "Europe/Amsterdam", "FCO": "Europe/Rome",
    "MAD": "Europe/Madrid", "BCN": "Europe/Madrid", "LIS": "Europe/Lisbon",
    "ATH": "Europe/Athens", "TLV": "Asia/Jerusalem",
    # elsewhere
    "PTP": "America/Guadeloupe", "GRU": "America/Sao_Paulo", "SYD": "Australia/Sydney",
}


def to_utc(airport: str, local: str | datetime) -> datetime | None:
    """The instant a local clock reading at this airport names, or None if the airport is unknown.

    Unknown returns None rather than guessing: a wrong zone is a wrong instant, and a check that
    cannot be made honestly is better reported as not made.
    """
    zone = TZ.get((airport or "").strip().upper())
    if not zone:
        return None
    if isinstance(local, str):
        try:
            local = datetime.fromisoformat(local.replace("Z", "").strip())
        except ValueError:
            return None
    from datetime import timezone
    return local.replace(tzinfo=ZoneInfo(zone)).astimezone(timezone.utc)
