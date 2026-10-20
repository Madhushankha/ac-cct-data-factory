"""Bag state for a seeded baggage booking: rows in trip-tracer's `baggage_updates`.

A baggage case turns on what happened to the bag — was a delayed-bag report (AHL) opened, was the bag
delivered, is it still in transit. The case-intake service reads exactly one thing to decide that:

    SELECT row_to_json(baggage_updates) FROM baggage_updates WHERE pnr_id = %s ORDER BY received_at

(`postgres_adapter._smart_suite_baggage_updates`). It takes the whole row, camel-cases it, and derives
`isAhlPresent`, `isBagDelivered`, `ahlStatus`, `bagLastStatus` and the delivery timestamp from it. So
seeding bag state means writing those rows for our own pnr_id.

They are written directly rather than published, for the same reason `flight_leg` is: the feed that
normally fills them (SmartSuite -> Flink) is not something a test can drive to a chosen state, and
the consumer reads the table anyway. The seed report says which rows were written rather than
ingested.

Event names and column usage were taken from real INT rows, not invented: BAG_CREATED, BAG_ACCEPTED,
BAG_SEEN_AT_STATION, BAG_DELAYED_RECORD_CREATED, BAG_DELIVERED_TO_CAROUSEL, BAG_MISHANDLED,
BAG_DAMAGED_RECORD_CREATED are all present in `baggage_updates` today.
"""
from __future__ import annotations

import json
import random
import uuid
from datetime import datetime, timedelta, timezone

from .render import Rendered

# The bag states a case can ask for. Each is an ordered event sequence; the last event decides
# `bagLastStatus`, which is what the eligibility assessment keys on.
STATES = {
    # no bag on the trip at all -- not "a bag with no report". Live tracking's "no checked bag"
    # card is the only thing that can be tested from it, and a bag row of any kind contradicts it.
    "no_bag":        (),
    "no_ahl":        ("BAG_CREATED", "BAG_ACCEPTED", "BAG_SEEN_AT_STATION"),
    "ahl_open":      ("BAG_CREATED", "BAG_ACCEPTED", "BAG_DELAYED_RECORD_CREATED"),
    "ahl_delivered": ("BAG_CREATED", "BAG_ACCEPTED", "BAG_DELAYED_RECORD_CREATED",
                      "BAG_DELIVERED_TO_CAROUSEL"),
    # A file closed WITHOUT the bag coming back. Delivery is the only way we could close one before,
    # so "there is a closed AHL and the bag is still missing" -- the arm BAG-03a/05a takes when no
    # file is open -- could not be expressed. case-services reads the close from its own event type
    # (BAGGAGE_AHL_CLOSED_EVENT_TYPES = {bag_delayed_record_closed}).
    "ahl_closed":    ("BAG_CREATED", "BAG_ACCEPTED", "BAG_DELAYED_RECORD_CREATED",
                      "BAG_DELAYED_RECORD_CLOSED"),
    # Traced, closed, AND handed back. BAG-03h/i measure their 21 days from the LATER of the close
    # and the delivery, so the window can still be open on a bag traced long ago but returned
    # recently (v23 S25, walk W16b). No other state carries both events, so that clock could not be
    # put the wrong way round on purpose -- which is the only way to prove the service takes the
    # later one. The close comes last in the sequence, but both timestamps are set explicitly from
    # `ahl_closed_days_ago` / `delivered_days_ago`, so their real order is whatever the card says.
    "ahl_closed_delivered": ("BAG_CREATED", "BAG_ACCEPTED", "BAG_DELAYED_RECORD_CREATED",
                             "BAG_DELIVERED_TO_CAROUSEL", "BAG_DELAYED_RECORD_CLOSED"),
    "in_transit":    ("BAG_CREATED", "BAG_ACCEPTED", "BAG_SEEN_AT_STATION"),
    "mishandled":    ("BAG_CREATED", "BAG_ACCEPTED", "BAG_MISHANDLED",
                      "BAG_DELAYED_RECORD_CREATED"),
    "damaged":       ("BAG_CREATED", "BAG_ACCEPTED", "BAG_DAMAGED_RECORD_CREATED"),
}
# Which group a case belongs to, when its own card states no bag condition. Recorded here rather than
# buried in a branch because it is our judgement, not the gap document's: the SIT cards test response
# wording from a state a sibling case established.
GROUP_DEFAULT = {
    "Delayed Bag Report": "ahl_open",
    "Lost Bag Content": "ahl_open",
    "Interim Expenses": "ahl_delivered",
    "Live Baggage Tracking": "in_transit",
    "Claim Payment": "ahl_open",
    "Entry / Other": "no_ahl",
}
# The two suites name the same group differently, and an unmatched name fell through to
# DEFAULT_STATE: the three UAT "Claim Payment / Dispute" cards were seeded with no AHL at all,
# though a payment dispute presupposes a delayed-bag report.
GROUP_ALIASES = {
    "Claim Payment / Dispute": "Claim Payment",     # UAT spelling; SIT says "Claim Payment"
    "Baggage Entry / Other": "Entry / Other",       # UAT spelling; SIT says "Entry / Other"
}
DEFAULT_STATE = "no_ahl"

# WHEN each event happens, as (anchor, hours): "dep" is the flight's departure, "arr" its arrival.
#
# A delayed-bag report cannot exist before the bag fails to arrive, and case-services enforces
# exactly that: `_ahl_opened_within_21_days` requires 0 <= (AHL created - final arrival) <= 21 days,
# and any AHL outside it is answered NOT_ELIGIBLE / BAG_NE_AHL_OUTSIDE_21_DAY_REPORTING_WINDOW for
# both interim expenses and lost contents -- before either eligibility rule is reached.
#
# The events used to walk forward from DEPARTURE in three-hour steps, so on a 12.5-hour flight the
# AHL was opened 6.5 hours before the plane landed. 39 of the 42 AHL-bearing SIT cards did this, and
# it is why neither `isEligibleForInterimExpenses` nor `isEligibleForLostBagReimbursement` returned
# ELIGIBLE once across a 109-conversation run: no bag ever got past the gate in front of them.
EVENT_AT = {
    "BAG_CREATED": ("dep", -2),                 # checked in
    "BAG_ACCEPTED": ("dep", -1),                # accepted into the system
    "BAG_SEEN_AT_STATION": ("dep", 1),          # scanned on the way
    "BAG_MISHANDLED": ("arr", 1),               # noticed missing at the belt
    "BAG_DELAYED_RECORD_CREATED": ("arr", 2),   # the AHL: raised after the bag fails to arrive
    "BAG_DAMAGED_RECORD_CREATED": ("arr", 2),
    "BAG_DELIVERED_TO_CAROUSEL": ("arr", 48),   # overridden by the plan's delivery_at
    "BAG_DELAYED_RECORD_CLOSED": ("arr", 72),   # the file closed with the bag still gone
}

# A card that says Air Canada was not the last carrier is testing the redirect to the airline that
# was: case-intake returns NO_DETERMINATION (BAG-IE-ND-04) as soon as the last segment's operating
# carrier is not AC. Lufthansa, because the routes these cards use are the European ones.
OTHER_AIRLINE = "LH"


def last_carrier_override(bag: dict | None) -> str | None:
    """The carrier the final segment must be operated by, or None to leave it as Air Canada."""
    return OTHER_AIRLINE if (bag or {}).get("last_carrier_ac") is False else None


def group_of(bag: dict | None) -> str:
    """The card's feature group, under the one name the tables here are keyed by."""
    feature = (bag or {}).get("feature") or ""
    return GROUP_ALIASES.get(feature, feature)


# Where the arrival has to sit relative to today for a case's 21-day check to come out as its card
# says. The fixtures carry fixed dates, so a "recent arrival" scenario ages out of the window as the
# calendar moves; the booking is shifted per case instead of being re-dated by hand.
DAYS_WITHIN_WINDOW = 3        # comfortably inside the 21 days, and past the 72-hour rule
DAYS_BEYOND_WINDOW = 30       # past 21 days, still inside the 51-day submission window
# Past the 51 days a content claim must be filed in (ADD-131). Nothing in either suite was ever
# older than 30 days, so `content_deadline_passed` could not be reached by construction.
DAYS_BEYOND_DEADLINE = 60


# The default arrival age per feature group, for a card that states no 21-day intent of its own.
GROUP_DAYS = {
    # a lost-bag content claim needs the bag deemed lost, which is 21 days after arrival
    "Lost Bag Content": DAYS_BEYOND_WINDOW,
}


def days_before_today(bag: dict | None) -> int | None:
    """How many days ago the bag should have arrived.

    Never None any more. Leaving the fixture's own date alone meant the booking aged with the
    calendar: in baggage-uat-int-v9, 25 of 39 cases arrived 87-89 days before the run, outside both
    the 21-day AHL window and the 51-day submission window, which is what none of those cards
    describe. A card that states `within_21_days` still decides for itself; the rest take their
    group's default, so every seeded baggage journey is a plausible recent one.
    """
    bag = bag or {}
    # A card can name the age outright, which the two window flags cannot express: the 21-day
    # boundary itself needs 20, 21, 22, 23, and the 51-day deadline needs something past it.
    stated = bag.get("arrival_days")
    if stated is not None:
        return max(0, int(stated))
    if bag.get("beyond_51"):
        return DAYS_BEYOND_DEADLINE
    within = bag.get("within_21_days")
    if within is True:
        return DAYS_WITHIN_WINDOW
    if within is False:
        return DAYS_BEYOND_WINDOW
    return GROUP_DAYS.get(group_of(bag), DAYS_WITHIN_WINDOW)


def flight_date_for(bag: dict | None, today=None) -> str | None:
    """The arrival date this case needs, as YYYY-MM-DD, or None when the card does not say."""
    from datetime import date, timedelta
    days = days_before_today(bag)
    if days is None:
        return None
    return ((today or date.today()) - timedelta(days=days)).isoformat()


def state_for(bag: dict) -> str:
    """The bag state a case needs: what its own card says, else its group's default."""
    bag = bag or {}
    # A card can name its state outright. Without this the only levers were `delivered` and
    # `ahl_state`, and neither can say "an AHL is open and the bag is NOT delivered" for a group
    # whose default is delivered -- which is why 13 SIT cards seeded the opposite of their title
    # (INT_009 "not delivered" seeded a delivered bag, LOST_004 "<=21d" seeded 30 days).
    explicit = bag.get("state")
    if explicit in STATES:
        return explicit
    if bag.get("delivered"):
        return "ahl_delivered"
    if bag.get("ahl_state") == "absent":
        return "no_ahl"
    # The group default outranks a bare "an AHL exists". `ahl_delivered` already contains the
    # AHL-created event, so it satisfies that card too -- while the other order silently dropped the
    # delivery from four Interim Expenses cards (017/018/035/039), and interim expenses can only be
    # ELIGIBLE once every bag is delivered, so those cards could never reach the outcome they name.
    group = GROUP_DEFAULT.get(group_of(bag))
    if group:
        return group
    if bag.get("ahl_state") == "found":
        return "ahl_open"
    return DEFAULT_STATE


def ahl_reference(bag: dict, locator: str, origin: str) -> str:
    """The AHL the card names, or one shaped like a real WorldTracer reference (YYZAC12345)."""
    stated = (bag or {}).get("ahl")
    if stated:
        return str(stated).upper()
    digits = "".join(c for c in locator if c.isdigit()) or "00000"
    return f"{origin[:3].upper()}AC{digits[:5]:0>5}"


def _tag(rng: random.Random) -> str:
    return f"00{rng.randint(14000000, 14999999)}"


def _ahl_series(base: str, count: int) -> list[str]:
    """`count` distinct WorldTracer-shaped references, counting up from the first."""
    if count <= 1:
        return [base]
    head, tail = base[:5], base[5:]
    if not tail.isdigit():                      # a card stated its own reference in another shape
        return [base] + [f"{base}{k}" for k in range(1, count)]
    return [f"{head}{int(tail) + k:0{len(tail)}d}" for k in range(count)]


def journey_segments(meta: dict, bag: dict | None = None) -> list[dict]:
    """The legs the bag travelled on: the journey the card names, else the last one.

    On a one-way booking every segment is bound 1 and this is the whole itinerary, exactly as
    before. On a return, a delayed bag belongs to ONE journey -- which is the whole point of asking
    the customer which journey they mean, so the rows say so rather than spanning both.
    """
    segs = meta["segments"]
    want = (bag or {}).get("bound")
    last = int(segs[-1].get("bound") or 1)
    number = int(want) if want else last
    return [s for s in segs if int(s.get("bound") or 1) == number] or segs


def _delivery_at(bag: dict, arrival: datetime) -> str:
    """When the bag was handed back.

    A card states this from the customer's side -- "the bag came back three days ago" -- which is a
    distance from TODAY. The default is a distance from the ARRIVAL, and the two only agree when the
    flight landed exactly two days before the delivery. Where a card says which it means, honour it,
    but never before the AHL that reports the bag missing (arrival + 2h).
    """
    stated = (bag or {}).get("delivered_days_ago")
    if stated is not None:
        # `arr_utc` gives an aware arrival, but a caller reading a shifted `arr_local` gives a naive
        # one, and comparing the two raises rather than answering. Match whichever came in: the value
        # is a wall-clock instant either way, and the arrival is the thing it has to sit after.
        now = datetime.now(timezone.utc if arrival.tzinfo else None)
        want = now.replace(hour=arrival.hour, minute=arrival.minute, second=0, microsecond=0) \
            - timedelta(days=max(0, int(stated)))
        floor = arrival + timedelta(hours=EVENT_AT["BAG_DELAYED_RECORD_CREATED"][1] + 1)
        return max(want, floor).isoformat()
    return (arrival + timedelta(days=2)).isoformat()


def _days_ago_at(stated, arrival: datetime, *, floor_hours: int) -> str | None:
    """A date the card states as a distance from TODAY, clamped to sit after `floor_hours`.

    The same reading `_delivery_at` gives `delivered_days_ago`, factored out because the AHL close
    date needs it too. A card says "traced 25 days ago" from the customer's side; the default
    offsets in EVENT_AT are distances from the flight, and the two only coincide when the flight
    landed exactly that long before. Returns None when the card states nothing.
    """
    if stated is None:
        return None
    now = datetime.now(timezone.utc if arrival.tzinfo else None)
    want = now.replace(hour=arrival.hour, minute=arrival.minute, second=0, microsecond=0)         - timedelta(days=max(0, int(stated)))
    return max(want, arrival + timedelta(hours=floor_hours)).isoformat()


def _closed_ats(bag: dict, arrival: datetime, state: str) -> list[str]:
    """The AHL close date per bag, as a list. Empty when the state closes no file.

    `ahl_closed_days_ago` is a number for the ordinary case and a LIST when the bags on one file were
    closed at different times (SP-03.28). A bag beyond the end of the list reuses the last entry, so
    a three-bag case with two dates does not silently lose its third.
    """
    if "BAG_DELAYED_RECORD_CLOSED" not in STATES[state]:
        return []
    stated = (bag or {}).get("ahl_closed_days_ago")
    floor = EVENT_AT["BAG_DELAYED_RECORD_CREATED"][1] + 1
    if stated is None:
        return []
    days = list(stated) if isinstance(stated, (list, tuple)) else [stated]
    return [_days_ago_at(d, arrival, floor_hours=floor) for d in days]


def plan(r: Rendered, bag: dict | None = None) -> dict:
    """What will be written, without touching the database (used by the report and the tests)."""
    bag = bag or {}
    meta = r.meta
    legs = journey_segments(meta, bag)
    seg = legs[-1]                                   # the bag follows its journey's final leg
    state = state_for(bag)
    rng = random.Random(r.locator)
    # UTC: every downstream comparison is against flight_segment.arrival_datetime, which is UTC
    arrival = datetime.fromisoformat(seg["arr_utc"].replace("Z", "+00:00"))
    # "Does the PAX have more than one AHL in OPEN status?" is a branch in both BAG-03 and BAG-05,
    # and one bag carrying one reference could never produce it. `ahl_count` raises separate files;
    # `bag_count` raises more bags against the same file (BAG-05's single- vs multi-bag wording).
    n_ahl = max(1, int(bag.get("ahl_count") or 1))
    n_bags = 0 if state == "no_bag" else max(1, int(bag.get("bag_count") or n_ahl))
    ahls = _ahl_series(ahl_reference(bag, r.locator, seg["origin"]), n_ahl)
    return {
        "state": state,
        "events": list(STATES[state]),
        "ahl": ahls[0],
        "ahls": ahls,
        "bags_per_passenger": n_bags,
        "bag_tag": _tag(rng),
        "bag_id": rng.randint(6000000, 6999999),
        "carrier": seg["carrier"], "flight_number": str(seg["flight_number"]),
        "origin": seg["origin"], "destination": seg["destination"],
        "bound": int(seg.get("bound") or 1),
        "departure_date": seg["dep_local"][:10],
        # when the AHL is raised, which the service compares against this journey's arrival
        "ahl_at": (arrival + timedelta(hours=EVENT_AT["BAG_DELAYED_RECORD_CREATED"][1])).isoformat()
                  if "BAG_DELAYED_RECORD_CREATED" in STATES[state] else None,
        # When the bag came back. A fixed "arrival + 2 days" cannot say what a card means by "the bag
        # was returned three days ago": that is measured from TODAY, not from the flight, so on a
        # booking that landed four days ago it lands a day late. `delivered_days_ago` states it the
        # way the cards do, and is clamped inside the journey so a bag is never delivered before it
        # was lost.
        "delivery_at": (_delivery_at(bag, arrival)
                        if "BAG_DELIVERED_TO_CAROUSEL" in STATES[state] else None),
        # When tracing was closed. BAG-03h/i measure the 21 days from the LATER of this and the
        # delivery, so a card that wants the window still open on a long-traced bag (v23 S25) has to
        # be able to set the two independently. Without it the close was always arrival + 72h, which
        # made "closed 30 days ago" unreachable on any recent booking.
        "closed_at": _closed_ats(bag, arrival, state)[0] if _closed_ats(bag, arrival, state) else None,
        # One close date PER BAG. SP-03.28 asserts that one stale bag does not close a claim whose
        # other bag is recent, which needs two DIFFERENT dates on one file -- a single value gave both
        # bags the same one, so the case seeded two recent bags and the assertion had nothing to bite
        # on. `ahl_closed_days_ago` therefore takes a list as well as a number.
        "closed_ats": _closed_ats(bag, arrival, state),
        "passengers": len(meta["passengers"]),
    }


def write_events(conn, r: Rendered, bag: dict | None = None, log=print) -> dict:
    """Write one bag per passenger through its event sequence. Returns what was written."""
    p = plan(r, bag)
    meta = r.meta
    journey = journey_segments(meta, bag)
    seg = journey[-1]
    # UTC, not the local clock. `baggage_updates.timestamp` is compared against
    # `flight_segment.arrival_datetime`, which is UTC, and the two differ by the whole time-zone
    # offset: on the SIT international leg arr_local is 10:30 and arr_utc is 13:30. Anchoring to the
    # local reading stamped the AHL an hour BEFORE the aircraft landed -- the same defect as walking
    # forward from departure, just smaller, and invisible because the checkpoint used the same
    # wrong clock.
    dep = datetime.fromisoformat(seg["dep_utc"].replace("Z", "+00:00"))
    arr = datetime.fromisoformat(seg["arr_utc"].replace("Z", "+00:00"))
    legs = json.dumps([{"FlightDepartureStationCode": s["origin"],
                        "FlightArrivalStationCode": s["destination"],
                        "FlightDepartureDateLocal": s["dep_local"][:10],
                        "FlightCarrierCode": s["carrier"],
                        "FlightNumber": str(s["flight_number"])} for s in journey])
    cur = conn.cursor()
    cur.execute("delete from baggage_updates where pnr_id = %s", (r.pnr_id,))
    rows = 0
    for i, (pax, j) in enumerate((pax, j) for pax in meta["passengers"]
                                 for j in range(p["bags_per_passenger"])):
        tag = p["bag_tag"] if i == 0 else f"{int(p['bag_tag']) + i:010d}"
        bag_id = p["bag_id"] + i
        ahl = p["ahls"][j % len(p["ahls"])]
        name = f"{pax['last']}/{pax['first']}".upper()
        for n, event in enumerate(p["events"]):
            # each event sits where the flight puts it -- see EVENT_AT
            anchor, hours = EVENT_AT.get(event, ("dep", n * 3))
            at = (dep if anchor == "dep" else arr) + timedelta(hours=hours)
            delivery = None
            if event == "BAG_DELIVERED_TO_CAROUSEL" and p["delivery_at"]:
                at = datetime.fromisoformat(p["delivery_at"])
                delivery = at
            # The close carries no delivery timestamp: `ahl_closed` is the file shut WITH the bag
            # still gone, so stamping one here would say the opposite of what the state means.
            if event == "BAG_DELAYED_RECORD_CLOSED" and p.get("closed_ats"):
                # this BAG's own close date -- see plan()["closed_ats"]
                ats = p["closed_ats"]
                at = datetime.fromisoformat(ats[min(j, len(ats) - 1)])
            cur.execute(
                """insert into baggage_updates
                   (id, bag_tag_number, event_type, timestamp, event_time, pnr_id, bag_id,
                    flight_departure_station_code, flight_arrival_station_code,
                    flight_departure_date_local, flight_carrier_code, flight_number,
                    flight_leg_type_id, bag_tag_status, passenger_name, source_system_id,
                    flight_legs, bag_flight_legs, bag_category, tracer_reference_id,
                    delivery_timestamp,
                    station_code, fault_station, carrier_code, inbound_carrier_code,
                    event_store_id, master_bag_id, commodity_id,
                    received_at, is_success)
                   values (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,
                           %s,%s,%s,%s,%s,%s,%s, now(), true)""",
                (str(uuid.uuid4()), tag, event, at, int(at.timestamp() * 1000), r.pnr_id, bag_id,
                 seg["origin"], seg["destination"], p["departure_date"], seg["carrier"],
                 str(seg["flight_number"]), 0,
                 "Active" if event != "BAG_DELIVERED_TO_CAROUSEL" else "Delivered",
                 name, 501, legs, legs, "B",
                 ahl if event in ("BAG_DELAYED_RECORD_CREATED", "BAG_MISHANDLED",
                                 "BAG_DELAYED_RECORD_CLOSED") else None,
                 delivery,
                 # The columns the LIVE pipeline fills and this did not. Measured on INT against
                 # 2ACRDF-2026-10-14, a booking nobody seeded whose bags arrived through the feed
                 # today: its rows carry station_code, event_store_id, commodity_id, master_bag_id
                 # and carrier_code, and leave the flight and passenger columns null, while ours did
                 # the exact opposite. Whether TripTracer's Trip needs them is not knowable from
                 # here -- its source is not on this machine and its API needs a signed service
                 # token -- so this makes a seeded row a superset of a real one rather than a
                 # different shape, which removes one variable from the question.
                 seg["destination"] if anchor == "arr" else seg["origin"],
                 seg["origin"], seg["carrier"], seg["carrier"],
                 # unique per row, and stable for a given bag and event, as the feed's own ids are
                 int(bag_id) * 100 + n, int(bag_id),
                 # the fixtures' own value (contrail/fixtures/smartsuite base.json CommodityId)
                 1001,
                 ))
            rows += 1
    log(f"[bags] {p['state']}: {rows} event row(s) for "
        f"{p['passengers'] * p['bags_per_passenger']} bag(s), AHL {', '.join(p['ahls'])}"
        + (f", delivered {p['delivery_at'][:10]}" if p["delivery_at"] else ""))
    return {**p, "rows": rows}
