"""Builders of the deep QA agent's sidecar (F12 README §5 step 3, contracts.md §2 /tools/build).

A plan plus seed templates (anonymised pool entries, or anonymised PROD case bodies with the same shape) become every
Kafka message of a booking:

1. The seed's history up to the plan's first scenario step is **rewritten** to the plan: identities (ZZ locator,
   synthetic names, e-mails, phones, tickets, CPIDs, DCS ids, bag tags) get fresh values, its flights become the plan's
   segments (carrier, number, airports, local and UTC times, in every feed that names them) and every date moves by
   the same number of days so the booking's lead time, version spacing and sequence numbers stay as they were.
2. From the first step on, the **step builders** append the scenario's own events and, unless the plan opts out, the
   events the playbook says accompany them: the PNR versions of a schedule change, a cancellation with its UN/TK
   rebooking pair, the tickets with their coupons and correlations, check-in and boarding (CM), bag groups and BROCK
   scans, the flights' FDM stream (SKD, gate, OUT/OFF/ON/IN, delays, cancellations, diversions), vouchers, notifications
   and profile links.

Only the paths the Rust parsers read (rust/src/feeds/*, rust/engine/src/booking/*) are rewritten; everything else is
the real template's. Tester placeholders (`{{tester.*}}`) never enter a message here: a synthetic stand-in is used and
the slots that may receive the tester's values at publish time are recorded (`testerSlots`).
"""
import copy
import hashlib
import functools
import json
import random
import re
import subprocess
from datetime import datetime, timedelta, timezone
from pathlib import Path
from zoneinfo import ZoneInfo

from playbook import PHASES, playbook

FIRST = ["ALEX", "JORDAN", "TAYLOR", "MORGAN", "CASEY", "RILEY", "JAMIE", "AVERY", "QUINN", "ROWAN", "SAGE", "DREW",
         "PARKER", "REESE", "EMERSON", "HAYDEN", "LOGAN", "SKYLER", "DAKOTA", "KENDALL"]
LAST = ["TESTER", "SAMPLE", "EXAMPLE", "MOCKWELL", "FAKERSON", "DUMMY", "PLACEHOLD", "SYNTHIA", "NULLMAN", "VOIDSON",
        "STUBBS", "FIXTURE", "PROXY", "SURROGATE", "STANDIN", "DECOY", "PSEUDO", "ANONYMO", "FICTION", "IMAGINE"]

TOPIC = {"PNR": "emh-prd.ALTEA-PNRDATA-PRD", "TKT": "emh-prd.ALTEA-TKT-PRD", "EMD": "emh-prd.ALTEA-TKT-PRD",
         "CM": "emh-prd.ALTEA-CM-PRD", "CM_BAG": "emh-prd.ALTEA-CM-PRD", "PNRCORR": "emh-prd.ALTEA-PNRCORR-PRD",
         "SMART_SUITE": "emh-prd.BROCK-BAGGAGE-PRD", "FDM": "emh-prd.EAI-FDM-PRD", "AACC": "emh-prd.ALTEA-AACC-PRD",
         "ICOUPON": "emh-prd.DBASS-ICOUPON-PRD", "STORMX": "emh-prd.STORMX-EVENTHUB-PRD",
         "CUSTOMER_PROFILE_CPID": "CUSTOMER-PROFILE-EVENTS-PROD", "CLD": "emh-prd.MULE-DAMAGEDBAGGAGE-PRD"}
TOPIC_FEED = {v: k for k, v in TOPIC.items() if k not in ("EMD", "CM_BAG")}

# ponytail: the AC network's airports; an unknown one is Eastern, and the build says so in `notes`.
TZ = {"YUL": "America/Toronto", "YYZ": "America/Toronto", "YTZ": "America/Toronto", "YOW": "America/Toronto",
      "YQB": "America/Toronto", "YHZ": "America/Halifax", "YYT": "America/St_Johns", "YFC": "America/Halifax",
      "YQM": "America/Halifax", "YWG": "America/Winnipeg", "YQR": "America/Regina", "YXE": "America/Regina",
      "YYC": "America/Edmonton", "YEG": "America/Edmonton", "YVR": "America/Vancouver", "YYJ": "America/Vancouver",
      "YLW": "America/Vancouver", "YXS": "America/Vancouver", "YQT": "America/Toronto", "YSB": "America/Toronto",
      "YXU": "America/Toronto", "YKF": "America/Toronto", "YQG": "America/Toronto", "YYB": "America/Toronto",
      "YTS": "America/Toronto", "YAM": "America/Toronto", "YBG": "America/Toronto", "YXX": "America/Vancouver",
      "YYD": "America/Vancouver", "YZF": "America/Edmonton", "YXY": "America/Whitehorse", "YQX": "America/St_Johns",
      "YDF": "America/St_Johns", "YYG": "America/Halifax", "YSJ": "America/Halifax", "YFB": "America/Iqaluit",
      "JFK": "America/New_York", "LGA": "America/New_York", "EWR": "America/New_York", "BOS": "America/New_York",
      "ORD": "America/Chicago", "DFW": "America/Chicago", "IAH": "America/Chicago", "DEN": "America/Denver",
      "LAX": "America/Los_Angeles", "SFO": "America/Los_Angeles", "SEA": "America/Los_Angeles",
      "LAS": "America/Los_Angeles", "PHX": "America/Phoenix", "MIA": "America/New_York", "MCO": "America/New_York",
      "FLL": "America/New_York", "TPA": "America/New_York", "ATL": "America/New_York", "DCA": "America/New_York",
      "IAD": "America/New_York", "PHL": "America/New_York", "MSP": "America/Chicago", "DTW": "America/New_York",
      "SAN": "America/Los_Angeles", "HNL": "Pacific/Honolulu", "MEX": "America/Mexico_City", "CUN": "America/Cancun",
      "PUJ": "America/Santo_Domingo", "MBJ": "America/Jamaica", "NAS": "America/Nassau", "BGI": "America/Barbados",
      "SJU": "America/Puerto_Rico", "PTP": "America/Guadeloupe", "FDF": "America/Martinique", "HAV": "America/Havana",
      "LIM": "America/Lima", "BOG": "America/Bogota", "GRU": "America/Sao_Paulo", "SCL": "America/Santiago",
      "EZE": "America/Argentina/Buenos_Aires", "LHR": "Europe/London", "LGW": "Europe/London", "MAN": "Europe/London",
      "EDI": "Europe/London", "DUB": "Europe/Dublin", "CDG": "Europe/Paris", "NCE": "Europe/Paris", "LYS": "Europe/Paris",
      "FRA": "Europe/Berlin", "MUC": "Europe/Berlin", "ZRH": "Europe/Zurich", "GVA": "Europe/Zurich", "VIE": "Europe/Vienna",
      "AMS": "Europe/Amsterdam", "BRU": "Europe/Brussels", "CPH": "Europe/Copenhagen", "ARN": "Europe/Stockholm",
      "OSL": "Europe/Oslo", "HEL": "Europe/Helsinki", "FCO": "Europe/Rome", "MXP": "Europe/Rome", "VCE": "Europe/Rome",
      "MAD": "Europe/Madrid", "BCN": "Europe/Madrid", "LIS": "Europe/Lisbon", "ATH": "Europe/Athens",
      "IST": "Europe/Istanbul", "TLV": "Asia/Jerusalem", "DXB": "Asia/Dubai", "DOH": "Asia/Qatar", "DEL": "Asia/Kolkata",
      "BOM": "Asia/Kolkata", "NRT": "Asia/Tokyo", "HND": "Asia/Tokyo", "ICN": "Asia/Seoul", "PVG": "Asia/Shanghai",
      "PEK": "Asia/Shanghai", "HKG": "Asia/Hong_Kong", "TPE": "Asia/Taipei", "SIN": "Asia/Singapore",
      "BKK": "Asia/Bangkok", "MNL": "Asia/Manila", "SYD": "Australia/Sydney", "MEL": "Australia/Melbourne",
      "AKL": "Pacific/Auckland", "KHI": "Asia/Karachi", "LHE": "Asia/Karachi"}
DEFAULT_TZ = "America/Toronto"

NUMBER_KEYS = ("number", "flightNumber", "flightnumber", "FlightNumber", "causingFlightNumber", "flight_number",
               "fnNumber")
CARRIER_KEYS = ("carrierCode", "airlineCode", "FlightCarrierCode", "flightCarrierCode", "fnCarrier",
                "causingAirlineCode", "carrier", "issuingCarrier", "airline_id_code")
AIRPORT_KEYS = ("iataCode", "boardPoint", "offPoint", "origin", "destination", "originIataCode", "destinationIataCode",
                "finalDestination", "StationCode", "airportCode", "port_origin", "port_accommodation",
                "departureAirport", "arrivalAirport", "FlightDepartureStationCode", "FlightArrivalStationCode",
                "flightDepartureStationCode", "flightArrivalStationCode", "airport_code", "FaultStation",
                "diversionAirport", "originCityCode", "destinationCityCode", "cityCode")
ORIGIN_KEYS = ("departure", "boardPoint", "FlightDepartureStationCode", "flightDepartureStationCode", "origin",
               "departureAirport", "port_origin", "departureStation")
DEST_KEYS = ("arrival", "offPoint", "FlightArrivalStationCode", "flightArrivalStationCode", "destination",
             "arrivalAirport")

ISO_DATE = re.compile(r"(?<!\d)(\d{4})-(\d{2})-(\d{2})(?!\d)")
EMAIL = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
HEX16 = re.compile(r"(?<![0-9A-Za-z])[0-9A-F]{16}(?![0-9A-Za-z])")
LOCATOR = re.compile(r"(?<![A-Z0-9])ZZ[A-Z0-9]{4}(?![A-Z0-9])")
TESTER = re.compile(r"\{\{\s*tester\.(\w+)\s*\}\}")
TICKET_KEYS = {"primaryDocumentNumber", "documentNumber", "documentNumbers", "ticketNumber", "ticket_number",
               "associatedDocumentNumbers", "ticketIds", "emdIds"}
BAG_TAG_KEYS = {"licensePlate", "BagTag", "bagTagNumber", "bagTag", "bag_tag"}


# ---------------------------------------------------------------- time helpers
def parse_utc(text):
    """ISO text (Z, offset, naive, or 'YYYY-MM-DD HH:MM:SS') to an aware UTC datetime; naive is taken as UTC."""
    t = text.strip().replace(" ", "T")
    if t.endswith("Z"):
        t = t[:-1] + "+00:00"
    d = datetime.fromisoformat(t)
    return d.replace(tzinfo=timezone.utc) if d.tzinfo is None else d.astimezone(timezone.utc)


def iso_utc(d):
    return d.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def iso_local(d):
    return d.strftime("%Y-%m-%dT%H:%M:%S")


def local_to_utc(local_text, airport, notes=None):
    zone = TZ.get(airport)
    if zone is None and notes is not None:
        notes.add(f"airport {airport} has no time zone in the table; Eastern assumed")
    return datetime.fromisoformat(local_text).replace(tzinfo=ZoneInfo(zone or DEFAULT_TZ)).astimezone(timezone.utc)


def utc_to_local(d, airport):
    return d.astimezone(ZoneInfo(TZ.get(airport, DEFAULT_TZ))).replace(tzinfo=None)


# ---------------------------------------------------------------- the plan
class Segment:
    def __init__(self, k, spec, notes):
        self.k = k  # 1-based across bounds
        self.carrier = spec["carrier"].upper()
        self.number = str(spec["number"]).lstrip("0") or "0"
        self.origin = spec["origin"].upper()
        self.destination = spec["destination"].upper()
        self.dep_local = spec["departure"][:16] + ":00" if len(spec["departure"]) == 16 else spec["departure"][:19]
        self.arr_local = spec["arrival"][:16] + ":00" if len(spec["arrival"]) == 16 else spec["arrival"][:19]
        self.dep_utc = local_to_utc(self.dep_local, self.origin, notes)
        self.arr_utc = local_to_utc(self.arr_local, self.destination, notes)
        op = spec.get("operating") or {}
        self.op_carrier = (op.get("carrier") or self.carrier).upper()
        self.op_number = str(op.get("number") or self.number).lstrip("0") or "0"
        self.cabin = spec.get("cabin", "Y")
        self.booking_class = spec.get("bookingClass", "T")
        self.aircraft = spec.get("aircraft", "321")
        self.status = spec.get("status", "HK")

    @property
    def dep_date(self):
        return self.dep_local[:10]

    @property
    def flight_id(self):
        return f"{self.carrier}#{self.number}#{self.dep_date}#{self.origin}"


class Plan:
    def __init__(self, raw):
        self.raw = raw
        self.notes = set()
        self.segments, self.bounds = [], []
        for b in raw.get("bounds") or []:
            bound = []
            for s in b.get("segments") or []:
                seg = Segment(len(self.segments) + 1, s, self.notes)
                self.segments.append(seg)
                bound.append(seg)
            self.bounds.append(bound)
        if not self.segments:
            raise ValueError("the plan has no segments")
        self.passengers = []
        for i, p in enumerate(raw.get("passengers") or [{"firstName": "ALEX", "lastName": "TESTER"}]):
            self.passengers.append({"index": i, "type": p.get("type", "ADT"), **{k: v for k, v in p.items() if k != "type"}})
        booking = raw.get("booking") or {}
        if booking.get("createdAt"):
            self.created = parse_utc(booking["createdAt"])
        else:
            self.created = self.segments[0].dep_utc - timedelta(days=booking.get("createdDaysBefore", 21))
        self.surround = raw.get("surround", True)
        self.steps = []
        for phase in PHASES:
            for step in (raw.get("phases") or {}).get(phase, []) or []:
                self.steps.append({"phase": phase, **step})

    def anchor(self, name):
        """booking, ticketing, departure[:k], arrival[:k], last_arrival -> UTC datetime."""
        base, _, k = name.partition(":")
        k = int(k) if k else 1
        if base == "booking":
            return self.created
        if base == "ticketing":
            return self.created + timedelta(minutes=20)
        if base in ("departure", "arrival"):
            if not 1 <= k <= len(self.segments):
                raise ValueError(f"anchor {name} names a segment the plan does not have (it has {len(self.segments)}; a protecting "
                                 "flight exists only after its flight_cancelled_rebooked step, so time later steps from a planned segment)")
            seg = self.segments[k - 1]
            return seg.dep_utc if base == "departure" else seg.arr_utc
        if base == "last_arrival":
            return self.segments[-1].arr_utc
        raise ValueError(f"unknown anchor {name}")

    def at(self, step):
        at = step.get("at") or {}
        return self.anchor(at.get("anchor", "departure")) + timedelta(minutes=at.get("offsetMinutes", 0))

    def first_step_time(self):
        """The earliest step. A step timed from a segment a rebooking adds later (departure:3 on a plan of two segments) has
        no time until that rebooking has run, and cannot be the earliest one, so it is left out here and timed when it runs."""
        times = []
        for s in self.steps:
            try:
                times.append(self.at(s))
            except ValueError:
                continue
        return min(times, default=None)


# ---------------------------------------------------------------- seeds
def read_seed(ref, pool):
    """A pool entry (`ZZxxxx`) or a case body `{"messages": [{"ts", "prodTopic", "value"}]}` -> parsed messages."""
    if isinstance(ref, dict):
        rows = ref["messages"]
    else:
        path = Path(pool) / "bookings" / f"{ref}.jsonl.zst"
        if path.exists():
            text = subprocess.run(["zstd", "-dc", str(path)], capture_output=True, check=True).stdout.decode()
        else:
            text = (Path(pool) / "bookings" / f"{ref}.jsonl").read_text()
        rows = [json.loads(l) for l in text.splitlines() if l.strip()]
    out, bad = [], 0
    for r in rows:
        try:
            v = json.loads(r["value"]) if isinstance(r["value"], str) else r["value"]
        except ValueError:
            bad += 1
            continue
        out.append({"ts": _iso_ts(r["ts"]), "prodTopic": r["prodTopic"], "obj": v})
    out.sort(key=lambda m: m["ts"])
    return out, bad


def _iso_ts(ts):
    """A record's time as ISO UTC. Some pool records carry epoch seconds ('1756765006.560795', pool ZZTQGZ): unparsed,
    they failed the build and sorted before every ISO stamp (TTQ-QA-SEED-EPOCH-TS)."""
    t = str(ts).strip() if ts is not None else ""
    if re.fullmatch(r"\d{9,13}(\.\d+)?", t):
        v = float(t)
        return iso_utc(datetime.fromtimestamp(v / 1000 if v > 1e11 else v, tz=timezone.utc))
    return ts


def feed_of(topic, obj):
    feed = TOPIC_FEED.get(topic, "")
    if feed == "TKT" and isinstance(obj, dict) and "processedEmd" in obj:
        return "EMD"
    if feed == "CM" and isinstance(obj, dict) and ("processedBagsGroup" in obj or "dcsBaggageCorrelations" in obj):
        return "CM_BAG"
    return feed


def kind_of(obj):
    """What a message is, for exemplar lookup and the timeline."""
    if isinstance(obj, list):
        return "brock:" + str((obj[0] if obj else {}).get("Type") or (obj[0] if obj else {}).get("eventType") or "list")
    if not isinstance(obj, dict):
        return "other"
    for key in ("processedPnr", "processedTicket", "processedEmd", "processedDcsPassenger", "processedBagsGroup",
                "correlationPnrTicket", "correlationPnrEmd", "correlationDcsPassengerPnr", "dcsPassengerCorrelations",
                "dcsBaggageCorrelations", "pnrCorrelations", "ticketingCorrelations", "PassengerNotification",
                "RedemptionPassDetails"):
        if key in obj:
            return key
    if "message" in obj and isinstance(obj["message"], dict) and "flightDetail" in obj["message"]:
        return "fdm"
    if "Type" in obj and "BagTag" in obj:
        return "brock:" + str(obj["Type"])
    if "messageType" in obj:
        return "profile:" + str(obj["messageType"])
    if "event_type" in obj:
        return "event:" + str(obj["event_type"])
    return "other"


class Seed:
    """What a seed booking is: its last PNR state, people, flights and every identity value to replace."""

    def __init__(self, messages):
        self.messages = messages
        pnrs = [m["obj"] for m in messages if isinstance(m["obj"], dict) and "processedPnr" in m["obj"]]
        if not pnrs:
            raise ValueError("the seed has no PNR version")
        self.pnr_messages = pnrs
        last = pnrs[-1]["processedPnr"]
        self.locator = last.get("bookingIdentifier") or last["id"].split("-")[0]
        self.pnr_id = last["id"]
        self.creation = last.get("creation", {}).get("dateTime") or pnrs[0]["processedPnr"].get("lastModification", {}).get("dateTime")
        self.travelers = []
        for t in last.get("travelers", []):
            names = (t.get("names") or [{}])[0]
            self.travelers.append({"id": t["id"], "firstName": names.get("firstName", ""), "lastName": names.get("lastName", ""),
                                   "type": t.get("passengerTypeCode", "ADT")})
        self.segments = []
        order = [f["flightSegment"]["id"] for it in last.get("flightItineraries", []) for f in it.get("flights", [])
                 if f.get("flightSegment")] + [fs["id"] for it in last.get("flightItineraries", []) for f in it.get("flights", [])
                                                for fs in (f.get("connectedFlights") or {}).get("flightSegments", [])]
        air = [p for p in last.get("products", []) if p.get("subType") == "AIR" and p.get("airSegment")]
        air.sort(key=lambda p: (order.index(p["id"]) if p["id"] in order else 99, p["airSegment"].get("departure", {}).get("localDateTime", "")))
        for p in air:
            a = p["airSegment"]
            op = a.get("operating") or {}
            self.segments.append({"id": p["id"], "carrier": a.get("carrierCode", ""), "number": str(a.get("number", "")).lstrip("0"),
                                  "origin": a.get("departure", {}).get("iataCode", ""), "destination": a.get("arrival", {}).get("iataCode", ""),
                                  "dep_local": a.get("departure", {}).get("localDateTime", ""), "arr_local": a.get("arrival", {}).get("localDateTime", ""),
                                  "op_carrier": op.get("carrierCode") or a.get("carrierCode", ""), "op_number": str(op.get("number") or a.get("number", "")).lstrip("0")})
        if not self.segments:
            raise ValueError("the seed has no air segment")
        # PROD reuses locators: an owner's folder can hold records of another booking with the same locator
        # (ZZ3SI5: a second PNR id seven months later). Those are not this booking's history.
        self.other_pnr_id = re.compile(r"(?<![A-Z0-9])" + re.escape(self.locator) + r"-\d{4}-\d{2}-\d{2}(?![A-Z0-9])")

    def is_other_booking(self, obj):
        text = json.dumps(obj, separators=(",", ":"))
        return any(pid != self.pnr_id for pid in self.other_pnr_id.findall(text))

    @functools.cached_property
    def originals(self):
        """Every identity value of the seed, by kind. Computed when the rewriter first needs it: it is 90 percent of
        reading a seed, and the pool index never needs it (TTQ-QA-SIDECAR-POOL-INDEX-BLOCKS)."""
        found = {"locators": set(), "names": set(), "emails": set(), "phones": set(), "tickets": set(), "cpids": set(),
                 "dcs": set(), "bagtags": set()}
        found["locators"].add(self.locator)
        for t in self.travelers:
            for part in (t["firstName"] + " " + t["lastName"]).replace("/", " ").split():
                if len(part) >= 3:
                    found["names"].add(part)

        def walk(v, key=""):
            if isinstance(v, dict):
                for k, x in v.items():
                    walk(x, k)
            elif isinstance(v, list):
                for x in v:
                    walk(x, key)
            elif isinstance(v, str):
                if key in TICKET_KEYS and re.fullmatch(r"\d{13}(-.*)?", v):
                    found["tickets"].add(v.split("-")[0])
                elif key in BAG_TAG_KEYS and re.fullmatch(r"\d{10}", v):
                    found["bagtags"].add(v)
                elif key == "cpid" and v.startswith("ZZCPID"):
                    found["cpids"].add(v)
                elif EMAIL.fullmatch(v):
                    found["emails"].add(v)
                elif key in ("phone", "number") and re.fullmatch(r"\+1-555-\d{7}", v):
                    found["phones"].add(v)
                elif re.fullmatch(r"[0-9A-F]{16}(-[A-Z]{3})?", v) and key in ("id", "dcsPassengerId", "bagsGroupId", "dcsPassengerSegmentDeliveryId", "acceptedOnwardId", "informativeOnwardId", "bagId", "responsiblePassenger"):
                    found["dcs"].add(v[:16])
        for m in self.messages:
            walk(m["obj"])
            text = json.dumps(m["obj"])
            found["locators"].update(LOCATOR.findall(text))
            found["emails"].update(e for e in EMAIL.findall(text) if e.endswith("@synth.test"))
            found["phones"].update(re.findall(r"\+1-555-\d{7}", text))
            found["cpids"].update(re.findall(r"ZZCPID[A-Z0-9]{6}", text))
            found["dcs"].update(HEX16.findall(text))
        return found

    def first_departure_date(self):
        return self.segments[0]["dep_local"][:10]


# ---------------------------------------------------------------- the rewrite
class Rewriter:
    """Rewrites one seed's messages to the plan: dates shifted, flights replaced, identities fresh."""

    def __init__(self, seed, plan, rng):
        self.seed, self.plan, self.rng = seed, plan, rng
        self.notes = set(plan.notes)
        self.locator = plan.raw.get("locator") or "ZZ" + "".join(rng.choice("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") for _ in range(4))
        self.day_shift = (datetime.fromisoformat(plan.segments[0].dep_date) - datetime.fromisoformat(seed.first_departure_date())).days
        self.created_shift = plan.created - (parse_utc(seed.creation) + timedelta(days=self.day_shift))
        # Seed segment k -> plan segment k; extra seed segments keep their flights (reported).
        self.segment_map = {}
        for i, s in enumerate(seed.segments):
            if i < len(plan.segments):
                self.segment_map[(s["number"], s["origin"])] = plan.segments[i]
                self.segment_map[(s["op_number"], s["origin"])] = plan.segments[i]
        if len(seed.segments) != len(plan.segments):
            self.notes.add(f"seed has {len(seed.segments)} segments, plan {len(plan.segments)}: unmatched seed flights kept")
        self.airport_map, self.carrier_map, self.number_map = {}, {}, {}
        for s, p in zip(seed.segments, plan.segments):
            self.airport_map.setdefault(s["origin"], p.origin)
            self.airport_map.setdefault(s["destination"], p.destination)
            self.carrier_map.setdefault(s["carrier"], p.carrier)
            self.carrier_map.setdefault(s["op_carrier"], p.op_carrier)
            self.number_map.setdefault(s["number"], p.number)
            self.number_map.setdefault(s["op_number"], p.op_number)
        self.tokens = self._tokens()
        self.token_rx = re.compile(r"(?<![A-Za-z0-9@.])(" + "|".join(re.escape(k) for k in sorted(self.tokens, key=len, reverse=True)) + r")(?![A-Za-z0-9@])") if self.tokens else None
        self.passenger_names = {}  # seed traveler id -> plan passenger (stand-in) names

    def _fresh_digits(self, n):
        return "".join(self.rng.choice("0123456789") for _ in range(n))

    def stand_in(self, i):
        """The synthetic identity a plan passenger travels under in every feed (tester values come at publish).
        A random stand-in never repeats a seed name, so the leak check can tell a survivor from a stand-in."""
        p = self.plan.passengers[i] if i < len(self.plan.passengers) else {}
        taken = self.seed.originals["names"]
        first = p.get("firstName", "")
        last = p.get("lastName", "")
        first = first.upper() if first and not TESTER.search(first) else self.rng.choice([n for n in FIRST if n not in taken] or FIRST)
        last = last.upper() if last and not TESTER.search(last) else self.rng.choice([n for n in LAST if n not in taken] or LAST)
        return first, last

    def _tokens(self):
        o = self.seed.originals
        t = {}
        for loc in o["locators"]:
            t[loc] = self.locator if loc == self.seed.locator else "ZZ" + "".join(self.rng.choice("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") for _ in range(4))
        self.stand_ins = [self.stand_in(i) for i in range(max(len(self.plan.passengers), len(self.seed.travelers)))]
        for i, trav in enumerate(self.seed.travelers):
            first, last = self.stand_ins[i]
            if trav["firstName"]:
                t[trav["firstName"]] = first
            if trav["lastName"]:
                t[trav["lastName"]] = last
        for e in o["emails"]:
            t[e] = f"synth-{self.rng.randrange(10**8)}@synth.test"
        for p in o["phones"]:
            t[p] = "+1-555-" + self._fresh_digits(7)
        for n in o["tickets"]:
            t[n] = n[:3] + self._fresh_digits(10)
        for c in o["cpids"]:
            t[c] = "ZZCPID" + "".join(self.rng.choice("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") for _ in range(6))
        for d in o["dcs"]:
            t[d] = "".join(self.rng.choice("0123456789ABCDEF") for _ in range(16))
        for b in o["bagtags"]:
            t[b] = self._fresh_digits(10)
        return t

    # -- dates
    def shift_dates(self, text):
        def sub(m):
            y, mo, d = int(m.group(1)), int(m.group(2)), int(m.group(3))
            if y < 2000:
                return m.group(0)
            try:
                return (datetime(y, mo, d) + timedelta(days=self.day_shift)).strftime("%Y-%m-%d")
            except ValueError:
                return m.group(0)
        return ISO_DATE.sub(sub, text)

    # -- flights
    def _segment_of(self, d):
        number = next((d[k] for k in NUMBER_KEYS if k in d and isinstance(d[k], (str, int))), None)
        if number is None:
            return None
        number = str(number).lstrip("0") or "0"
        origin = None
        for k in ORIGIN_KEYS:
            v = d.get(k)
            if isinstance(v, dict):
                v = v.get("iataCode")
            if isinstance(v, str) and len(v) == 3:
                origin = v
                break
        for (n, o), seg in self.segment_map.items():
            if n == number and (origin is None or o == origin):
                return seg
        return None

    @staticmethod
    def _fmt_number(original, number):
        if isinstance(original, int):
            return int(number)
        if original.startswith("0") and len(original) > len(number):
            return number.zfill(len(original))
        return number

    def _time_like(self, original, utc, local):
        """Write `utc`/`local` in the format `original` used."""
        if isinstance(original, int):  # AACC HHMM
            return int(local.strftime("%H%M"))
        if not isinstance(original, str):
            return original
        if re.fullmatch(r"\d{4}-\d{2}-\d{2}", original):
            return local.strftime("%Y-%m-%d")
        if re.fullmatch(r"\d{6}", original):  # DDMMYY
            return local.strftime("%d%m%y")
        if original.endswith("Z"):
            return iso_utc(utc)
        if re.search(r"[+-]\d{2}:\d{2}$", original):
            return utc.astimezone(timezone(timedelta(hours=int(original[-6:-3]), minutes=int(original[-2:])))).strftime("%Y-%m-%dT%H:%M:%S") + original[-6:]
        if " " in original:
            return local.strftime("%Y-%m-%d %H:%M:%S")[: len(original)]
        return iso_local(local)

    def _rewrite_segment(self, d, seg):
        for k in NUMBER_KEYS:
            if k in d and isinstance(d[k], (str, int)):
                d[k] = self._fmt_number(d[k], seg.number)
        for k in CARRIER_KEYS:
            if k in d and isinstance(d[k], str):
                d[k] = seg.carrier
        if isinstance(d.get("operating"), dict):
            for k in NUMBER_KEYS:
                if k in d["operating"] and isinstance(d["operating"][k], (str, int)):
                    d["operating"][k] = self._fmt_number(d["operating"][k], seg.op_number)
            for k in CARRIER_KEYS:
                if k in d["operating"]:
                    d["operating"][k] = seg.op_carrier
        if isinstance(d.get("operatingFlight"), dict):
            self._rewrite_segment(d["operatingFlight"], Segment(seg.k, {"carrier": seg.op_carrier, "number": seg.op_number, "origin": seg.origin,
                                                                        "destination": seg.destination, "departure": seg.dep_local, "arrival": seg.arr_local}, self.notes))
        dep_l, arr_l = datetime.fromisoformat(seg.dep_local), datetime.fromisoformat(seg.arr_local)
        for keys, airport, utc, local in ((ORIGIN_KEYS, seg.origin, seg.dep_utc, dep_l), (DEST_KEYS, seg.destination, seg.arr_utc, arr_l)):
            for k in keys:
                v = d.get(k)
                if isinstance(v, dict):
                    if "iataCode" in v:
                        v["iataCode"] = airport
                    for tk in ("localDateTime", "at", "dateTime"):
                        if tk in v and isinstance(v[tk], str):
                            v[tk] = self._time_like(v[tk], utc, local)
                    if "_text" in v and isinstance(v["_text"], str) and "T" in v["_text"]:
                        v["_text"] = self._time_like(v["_text"], utc, local)
                elif isinstance(v, str):
                    d[k] = self._time_like(v, utc, local) if ("T" in v or re.fullmatch(r"\d{4}-\d{2}-\d{2}", v)) else airport
        # Flat date/time fields (AACC, BROCK, iCoupon, StormX, FDM schedule)
        for k, utc, local in (("departureDate", seg.dep_utc, dep_l), ("departureTime", seg.dep_utc, dep_l), ("arrivalDate", seg.arr_utc, arr_l),
                              ("arrivalTime", seg.arr_utc, arr_l), ("FlightDepartureDateLocal", seg.dep_utc, dep_l),
                              ("flightDepartureScheduledDate", seg.dep_utc, dep_l), ("causingFlightDate", seg.dep_utc, dep_l),
                              ("causingFlightDateTimeLocal", seg.dep_utc, dep_l), ("causingFlightDateTimeUTC", seg.dep_utc, dep_l),
                              ("flightDate", seg.dep_utc, dep_l), ("scheduled_depart", seg.dep_utc, dep_l), ("disrupt_depart", seg.dep_utc, dep_l),
                              ("scheduledDepartureTime", seg.dep_utc, dep_l), ("scheduledArrivalTime", seg.arr_utc, arr_l),
                              ("dayOfOrigin", seg.dep_utc, dep_l)):
            if k in d and isinstance(d[k], (str, int)) and not isinstance(d[k], bool):
                d[k] = self._time_like(d[k], utc, local)

    def walk(self, v, key="", in_segment=False):
        if isinstance(v, list):
            if key == "flightItineraries":  # each bound's end points are the plan's, not the airport map's guess
                for b, it in enumerate(x for x in v if isinstance(x, dict)):
                    if b < len(self.plan.bounds) and self.plan.bounds[b]:
                        if "originIataCode" in it:
                            it["originIataCode"] = self.plan.bounds[b][0].origin
                        if "destinationIataCode" in it:
                            it["destinationIataCode"] = self.plan.bounds[b][-1].destination
            for x in v:
                self.walk(x, key, in_segment)
            return v
        if not isinstance(v, dict):
            return v
        seg = self._segment_of(v)
        if seg is not None:
            self._rewrite_segment(v, seg)
            in_segment = True  # its values are final: the global maps must not touch them again
        for k, x in v.items():
            if isinstance(x, (dict, list)):
                self.walk(x, k, in_segment)
            elif isinstance(x, str) and not in_segment:
                if k in AIRPORT_KEYS and x in self.airport_map:
                    v[k] = self.airport_map[x]
                elif k in CARRIER_KEYS and x in self.carrier_map and key not in ("operating", "operatingFlight"):
                    v[k] = self.carrier_map[x]
                elif k == "date" and key == "processingDateTime" and re.fullmatch(r"\d{8}", x):  # AACC DDMMYYYY
                    v[k] = (datetime.strptime(x, "%d%m%Y") + timedelta(days=self.day_shift)).strftime("%d%m%Y")
        return v

    def message(self, m):
        """One seed message rewritten: a new {ts, prodTopic, value, obj}."""
        text = self.shift_dates(json.dumps(m["obj"], separators=(",", ":")))
        obj = self.walk(json.loads(text))
        text = json.dumps(obj, separators=(",", ":"))
        if self.token_rx:
            text = self.token_rx.sub(lambda mm: self.tokens[mm.group(1)], text)
        ts = parse_utc(self.shift_dates(m["ts"])) if m["ts"] else None
        return {"ts": iso_utc(ts) if ts else "", "prodTopic": m["prodTopic"], "value": text, "obj": json.loads(text)}


# ---------------------------------------------------------------- JSON diff -> Altea comparison events + inverse patch
def diff(old, new, path=""):
    """(events, inverse_ops): the feed's COMPARISON events for new vs old and the JSON patch that turns new back
    into old (`previousRecord`); object and array values in the patch are JSON-encoded strings, as the feed does."""
    events, ops = [], []

    def enc(v):
        return json.dumps(v) if isinstance(v, (dict, list)) else v

    def rec(o, n, p):
        changed = False
        if isinstance(o, dict) and isinstance(n, dict):
            for k in n:
                if k not in o:
                    events.append({"currentPath": f"{p}/{k}", "eventType": "CREATED", "origin": "COMPARISON"})
                    ops.append({"op": "remove", "path": f"{p}/{k}"})
                    changed = True
                elif rec(o[k], n[k], f"{p}/{k}"):
                    changed = True
            for k in o:
                if k not in n:
                    events.append({"previousPath": f"{p}/{k}", "eventType": "DELETED", "origin": "COMPARISON"})
                    ops.append({"op": "add", "path": f"{p}/{k}", "value": enc(o[k])})
                    changed = True
        elif isinstance(o, list) and isinstance(n, list):
            for i in range(min(len(o), len(n))):
                if rec(o[i], n[i], f"{p}/{i}"):
                    changed = True
            for i in range(len(n) - 1, len(o) - 1, -1):
                events.append({"currentPath": f"{p}/{i}", "eventType": "CREATED", "origin": "COMPARISON"})
                ops.append({"op": "remove", "path": f"{p}/{i}"})
                changed = True
            for i in range(len(n), len(o)):
                events.append({"previousPath": f"{p}/{i}", "eventType": "DELETED", "origin": "COMPARISON"})
                ops.append({"op": "add", "path": f"{p}/{i}", "value": enc(o[i])})
                changed = True
        elif o != n:
            events.append({"currentPath": p, "previousPath": p, "eventType": "UPDATED", "origin": "COMPARISON"})
            ops.append({"op": "replace", "path": p, "value": enc(o)})
            changed = True
        if changed and isinstance(o, (dict, list)) and isinstance(n, (dict, list)):
            events.append({"currentPath": p, "previousPath": p, "eventType": "UPDATED", "origin": "COMPARISON"})
        return changed

    rec(old, new, path)
    return events, ops


def trigger_id(*parts):
    h = hashlib.sha256("|".join(str(p) for p in parts).encode()).hexdigest()
    return f"{h[:32]}-{h[32:48]}"


# ---------------------------------------------------------------- the build
class Build:
    def __init__(self, plan, seeds, pool, exemplars=None, seed_value=None):
        self.plan = Plan(plan) if not isinstance(plan, Plan) else plan
        self.rng = random.Random(seed_value if seed_value is not None else random.randrange(1 << 62))
        self.pool = pool
        self.exemplars = exemplars or Exemplars(pool)
        self.messages = []  # {ts, prodTopic, value, obj, family, phase, origin}
        self.notes = set()
        self.seed_stats = {}
        seed_msgs, bad = read_seed(seeds[0], pool)
        self.seed = Seed(seed_msgs)
        self.rw = Rewriter(self.seed, self.plan, self.rng)
        self.locator = self.rw.locator
        self.pnr_id = None
        self.ticket_numbers = {}  # passenger index -> ticket number
        self.dcs = {}  # passenger index -> {"id", "etag", "record": last CM message obj, "segdel": {k: id}}
        self.cpids = {}
        self._fdm_done = set()  # (event, segment k) of every FDM event a step or the surround built
        self._pending_rebookings = []  # (replaced k, protecting k) pairs flight_cancelled_rebooked made and nothing has settled
        self.bags = {}  # passenger index -> [{"tag", "bagId", "group"}]
        self._bag_tail = []  # (passenger, bag, legs) whose loading, unloading and carousel come after every step
        self.seed_stats["badJson"] = bad
        self._rewrite_seed()
        self._run_steps()
        self._surround_bag_tail()
        self.messages.sort(key=lambda m: (m["ts"], m.get("seq", 0)))
        self.tester_slots = self._tester_slots()

    # -- helpers
    def seg(self, k):
        return self.plan.segments[k - 1]

    def passenger_name(self, i):
        return self.rw.stand_ins[i] if i < len(self.rw.stand_ins) else self.rw.stand_in(i)

    def traveler_id(self, i):
        """Plan passenger i's traveler id: the seed's travelers keep theirs (a booking's ids need not start at
        PT-1: ZZ3SI5's first traveler is PT-2), an added passenger gets the next number."""
        ids = getattr(self, "_pt_ids", [])
        if i < len(ids):
            return ids[i]
        used = {int(m.group(1)) for t in ids if (m := re.search(r"-PT-(\d+)$", t))}
        return f"{self.pnr_id}-PT-{max(used | {0}) + 1 + (i - len(ids))}"

    @staticmethod
    def _flying(s):
        """A segment the booking holds as confirmed: not a protecting TK still to be accepted, not one a rebooking removed (XX)."""
        return s.status not in ("TK", "XX")

    def _pnr_at(self, at):
        """The PNR version the booking holds at `at`: the latest at or before it. Build order is not time order (the changes phase
        builds before the day of the flight, whatever their times), so what a record may name is decided by this, not by what the
        plan holds once every step has run."""
        ts = iso_utc(at)
        versions = [m for m in self.messages if "processedPnr" in m["obj"] and m["ts"] <= ts]
        return max(versions, key=lambda m: (m["ts"], m["seq"]))["obj"]["processedPnr"] if versions else None

    def _held(self, s, at):
        """Does the booking hold segment s as flying at `at`: its air product is in the PNR then and is not a protecting TK still to
        be accepted. A segment no PNR version ever carried (a seed whose ids the plan cannot match) keeps the plan's own status."""
        product = self._product_at(s, at)
        if product is not None:
            return (product.get("airSegment") or {}).get("status") != "TK"
        return False if self._in_a_pnr(s) else self._flying(s)  # absent: not in the booking yet, or it has left

    def _product_at(self, s, at):
        pnr = self._pnr_at(at)
        sid = self.segment_id(s.k)
        return next((p for p in (pnr or {}).get("products", []) if p.get("id") == sid and p.get("subType") == "AIR"), None)

    def _in_a_pnr(self, s):
        sid = self.segment_id(s.k)
        return any(p.get("id") == sid for m in self.messages if "processedPnr" in m["obj"] for p in m["obj"]["processedPnr"].get("products", []))

    def _held_segments(self, at):
        return [s for s in self.plan.segments if self._held(s, at)]

    def segment_id(self, k):
        return self._st_ids.get(k, f"{self.pnr_id}-ST-{k}")

    def add(self, feed, at, obj, family, phase, origin="step"):
        self.messages.append({"ts": iso_utc(at), "prodTopic": TOPIC[feed], "value": json.dumps(obj, separators=(",", ":")),
                              "obj": obj, "family": family, "phase": phase, "origin": origin, "seq": len(self.messages)})

    def last_pnr(self):
        return next(m["obj"] for m in reversed(self.messages) if "processedPnr" in m["obj"])

    def exemplar(self, kind):
        """A real message of this kind: the seed's own first, then the pool's."""
        for m in self.messages:
            if kind_of(m["obj"]) == kind:
                return copy.deepcopy(m["obj"])
        return self.exemplars.get(kind)

    # -- 1. the seed's history up to the first step
    def _rewrite_seed(self):
        cut = self.plan.first_step_time()
        kept = dropped = 0
        # The booking's creation moves to the plan's: every retained message keeps its spacing after it, and the
        # seed's history ends where the scenario's first step begins.
        shift = self.rw.created_shift
        other = 0
        for m in self.seed.messages:
            if self.seed.is_other_booking(m["obj"]):
                other += 1
                continue
            r = self.rw.message(m)
            obj = r["obj"]
            feed = feed_of(r["prodTopic"], obj)
            at = parse_utc(r["ts"]) + shift if r["ts"] else self.plan.created
            if cut and at >= cut:
                dropped += 1
                continue
            kept += 1
            text = r["value"]
            if abs(shift) >= timedelta(minutes=1):
                text = self._shift_datetimes(text, shift, feed)
                obj = json.loads(text)
            self.messages.append({"ts": iso_utc(at), "prodTopic": r["prodTopic"], "value": text, "obj": obj,
                                  "family": self._seed_family(feed, obj), "phase": self._phase_of(at), "origin": "seed", "seq": len(self.messages)})
        self.seed_stats.update(kept=kept, dropped=dropped, otherBooking=other, dayShift=self.rw.day_shift)
        if not any("processedPnr" in m["obj"] for m in self.messages):
            # Name the step and the times: the bare message had the agent retry eight builds in one run (2026-10-14).
            first = min(self.plan.steps, key=self.plan.at)
            # In the seed's own frame, as the pool index reports it (historyGapDays).
            seed_pnrs = [parse_utc(m["ts"]) for m in self.seed.messages if "processedPnr" in m["obj"] and m["ts"]]
            gap = (min(seed_pnrs) - parse_utc(self.seed.creation)).days if seed_pnrs and self.seed.creation else 0
            if gap >= 1:
                raise ValueError(
                    f"seed {self.seed.locator}'s retained history starts {gap} days after its creation, so none of its PNR "
                    f"versions comes before the plan's first step {first.get('family')} at {iso_utc(self.plan.at(first))} "
                    f"(the booking is created at {iso_utc(self.plan.created)}). Pick a seed whose history starts at its "
                    "creation (pool historyGapDays 0)")
            raise ValueError(
                f"no PNR version of the seed is before the plan's first step: {first.get('family')} ({first['phase']}) at "
                f"{iso_utc(self.plan.at(first))}, while the booking is created at {iso_utc(self.plan.created)}. The seed "
                "supplies the booking's creation and its early history, so every step must come after the creation: "
                "drop pnr_creation and before_booking steps, and time the first step from anchor booking with a positive "
                "offsetMinutes, or later")
        pnr0 = self.messages[0]["obj"] if self.messages and "processedPnr" in self.messages[0]["obj"] else None
        self.pnr_id = self.last_pnr()["processedPnr"]["id"]
        self._pt_ids = [t["id"] for t in self.last_pnr()["processedPnr"].get("travelers", []) if t.get("id")]
        self._st_ids = {}
        for k, s in enumerate(self.plan.segments, 1):
            if k - 1 < len(self.seed.segments):
                self._st_ids[k] = self.rw.token_rx.sub(lambda mm: self.rw.tokens[mm.group(1)], self.rw.shift_dates(self.seed.segments[k - 1]["id"]))
        self._match_retained_segments()
        self._align_pnr_id_date()
        self._align_passengers()
        self._ensure_contacts()
        self._adopt_seed_identities()
        if pnr0 is None:
            self.notes.add("the seed's first retained message is not a PNR version")

    def _match_retained_segments(self):
        """The plan's segments take the ids of the air products the retained history ends with, not the seed's last state: the seed's
        later versions (cut at the first step) may number its segments differently (ZZ6GMP ends with ST-1 and ST-3, its retained
        history has ST-1 and ST-2), and a step looking for segment 2 by the seed's id found nothing."""
        pnr = self.last_pnr()["processedPnr"]
        air = [p for p in pnr.get("products", []) if p.get("subType") == "AIR" and p.get("airSegment")]
        order = [(f.get("flightSegment") or {}).get("id") for it in pnr.get("flightItineraries", []) for f in it.get("flights", [])]
        air.sort(key=lambda p: (order.index(p["id"]) if p["id"] in order else 99, p["airSegment"].get("departure", {}).get("localDateTime", "")))
        used = set()
        for seg in self.plan.segments:
            same = [p for p in air if p["id"] not in used and str(p["airSegment"].get("number", "")).lstrip("0") == seg.number
                    and p["airSegment"].get("departure", {}).get("iataCode") == seg.origin]
            if same:
                self._st_ids[seg.k] = same[0]["id"]
                used.add(same[0]["id"])
        for seg, p in zip(self.plan.segments, air):  # the plan's own order for the rest
            if seg.k not in self._st_ids and p["id"] not in used:
                self._st_ids[seg.k] = p["id"]
                used.add(p["id"])

    def _shift_datetimes(self, text, shift, feed):
        """Move every datetime (not plain dates) by `shift`, except the flights' own times, which are the plan's."""
        keep = {s.dep_local for s in self.plan.segments} | {s.arr_local for s in self.plan.segments} | \
               {iso_utc(s.dep_utc) for s in self.plan.segments} | {iso_utc(s.arr_utc) for s in self.plan.segments}
        rx = re.compile(r"\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}(?::\d{2}(?:\.\d+)?)?(?:Z|[+-]\d{2}:\d{2})?")

        def sub(m):
            v = m.group(0)
            if v in keep or feed == "FDM":
                return v
            try:
                d = parse_utc(v) + shift
            except ValueError:
                return v
            if v.endswith("Z"):
                return iso_utc(d) if len(v) == 20 else d.strftime("%Y-%m-%dT%H:%M:%S.") + v[20:]
            if re.search(r"[+-]\d{2}:\d{2}$", v):
                off = timezone(timedelta(hours=int(v[-6:-3]), minutes=int(v[-2:])))
                return d.astimezone(off).strftime("%Y-%m-%dT%H:%M:%S") + (v[19:-6] if "." in v else "") + v[-6:]
            return (d.strftime("%Y-%m-%d %H:%M:%S") if " " in v else iso_local(d))[: len(v)]
        return rx.sub(sub, text)

    def _seed_family(self, feed, obj):
        kind = kind_of(obj)
        return {"processedPnr": "pnr_version", "processedTicket": "ticket_issued", "processedEmd": "emd_issued",
                "processedDcsPassenger": "check_in", "processedBagsGroup": "bag_checked", "correlationPnrTicket": "pnr_ticket_correlation",
                "pnrCorrelations": "pnr_ticket_correlation", "correlationPnrEmd": "pnr_ticket_correlation",
                "correlationDcsPassengerPnr": "cm_correlation", "dcsPassengerCorrelations": "cm_correlation",
                "dcsBaggageCorrelations": "bag_checked", "PassengerNotification": "notification", "RedemptionPassDetails": "meal_voucher",
                "fdm": "flight_ops"}.get(kind) or ("bag_scan" if kind.startswith("brock") else "profile_link" if kind.startswith("profile") else "hotel_voucher" if feed == "STORMX" else feed.lower())

    def _phase_of(self, at):
        if at <= self.plan.created + timedelta(minutes=5):
            return "booking"
        if at < self.plan.segments[0].dep_utc - timedelta(hours=24):
            return "changes"
        if at <= self.plan.segments[-1].arr_utc:
            return "day_of_flight"
        return "post_flight"

    def _align_passengers(self):
        """The plan's passengers in every PNR version: extra plan passengers are cloned from the first traveler,
        extra seed travelers stay (reported)."""
        want = len(self.plan.passengers)
        for m in self.messages:
            pnr = m["obj"].get("processedPnr") if isinstance(m["obj"], dict) else None
            if not pnr:
                continue
            travelers = pnr.get("travelers", [])
            if len(travelers) < want and travelers:
                for i in range(len(travelers), want):
                    t = copy.deepcopy(travelers[0])
                    t["id"] = self.traveler_id(i)
                    if t["id"] not in self._pt_ids:
                        self._pt_ids.append(t["id"])
                    first, last = self.passenger_name(i)
                    t["names"] = [{"firstName": first, "lastName": last}]
                    t["passengerTypeCode"] = self.plan.passengers[i].get("type", "ADT")
                    t.pop("identityDocuments", None)
                    t.pop("contacts", None)
                    travelers.append(t)
                    for p in pnr.get("products", []):
                        coll = (p.get("travelers") or {}).get("collection")
                        if coll and p.get("subType") == "AIR":
                            coll.append({"id": t["id"], "ref": "processedPnr.travelers", "type": "stakeholder"})
                pnr["nip"] = want
            elif len(travelers) > want:
                self.notes.add(f"seed has {len(travelers)} travelers, plan {want}: extra travelers kept")
            for i, t in enumerate(travelers[:want]):
                first, last = self.passenger_name(i)
                for n in t.get("names", []):
                    n["firstName"], n["lastName"] = first, last
                for doc in t.get("identityDocuments", []):
                    name = (doc.get("document") or {}).get("name")
                    if isinstance(name, dict):
                        name.update(firstName=first, lastName=last, fullName=f"{first} {last}")
            m["value"] = json.dumps(m["obj"], separators=(",", ":"))

    def _ensure_contacts(self):
        """Every plan passenger with an e-mail or phone has a NOTIFICATION contact in every PNR version (the elements
        an OTP reads); the stand-in is synthetic until publish."""
        for i, p in enumerate(self.plan.passengers):
            if not (p.get("email") or p.get("phone")):
                continue
            email = f"synth-{self.rng.randrange(10**8)}@synth.test"
            phone = "+1-555-" + "".join(self.rng.choice("0123456789") for _ in range(7))
            for m in self.messages:
                pnr = m["obj"].get("processedPnr") if isinstance(m["obj"], dict) else None
                if not pnr:
                    continue
                tid = self.traveler_id(i)
                contacts = pnr.setdefault("contacts", [])
                have = {k for c in contacts for k in ("email", "phone") if k in c and any(t.get("id") == tid for t in (c.get("travelers") or {}).get("collection", []))}
                n = 900 + i * 2
                for kind, present in (("email", p.get("email")), ("phone", p.get("phone"))):
                    if not present or kind in have:
                        continue
                    cid = f"{self.pnr_id}-OT-{n}"
                    n += 1
                    body = {"address": email} if kind == "email" else {"category": "PERSONAL", "deviceType": "MOBILE", "number": phone}
                    contacts.append({"id": cid, kind: body, "purpose": ["NOTIFICATION"], "type": "contact",
                                     "travelers": {"collection": [{"id": tid, "ref": "processedPnr.travelers", "type": "stakeholder"}]}})
                    for t in pnr.get("travelers", []):
                        if t.get("id") == tid:
                            t.setdefault("contacts", {"collection": []}).setdefault("collection", []).append({"id": cid, "ref": "processedPnr.contacts", "type": "contact"})
                m["value"] = json.dumps(m["obj"], separators=(",", ":"))

    def _adopt_seed_identities(self):
        """Tickets, DCS passengers, CPIDs and bags the retained seed history already gave the plan's passengers."""
        pnr = self.last_pnr()["processedPnr"]
        by_traveler = {t["id"]: i for i, t in enumerate(pnr.get("travelers", []))}
        for m in self.messages:
            o = m["obj"]
            if not isinstance(o, dict):
                continue
            if "processedTicket" in o:
                t = o["processedTicket"]
                name = (t.get("traveler") or {}).get("name") or {}
                for i in range(len(self.plan.passengers)):
                    if self.passenger_name(i) == (name.get("firstName"), name.get("lastName")):
                        self.ticket_numbers.setdefault(i, t.get("primaryDocumentNumber"))
            corr = o.get("correlationDcsPassengerPnr") or (o.get("dcsPassengerCorrelations") or {}).get("correlationDcsPassengerPnr")
            if corr:
                for rows in (corr.get("correlatedData") or {}).values():
                    for row in rows:
                        i = by_traveler.get(row.get("pnrTravelerId"))
                        if i is not None:
                            d = self.dcs.setdefault(i, {"id": corr.get("dcsPassengerId"), "etag": None, "record": None, "segdel": {}})
                            for k in range(1, len(self.plan.segments) + 1):
                                if row.get("pnrAirSegmentId") == self.segment_id(k):
                                    d["segdel"][k] = row.get("dcsPassengerSegmentDeliveryId")
                            d.setdefault("corr", set()).add(row.get("dcsPassengerSegmentDeliveryId"))
            if "processedDcsPassenger" in o:
                for i, d in self.dcs.items():
                    if d["id"] == o["processedDcsPassenger"].get("id"):
                        d["record"] = o
                        d["etag"] = o["processedDcsPassenger"].get("etag")
            if o.get("messageType") == "passenger.profile.link":
                for row in o.get("payload", []):
                    i = by_traveler.get(row.get("passengerId"))
                    if i is not None:
                        self.cpids[i] = row.get("cpid")

    # -- 2. the steps
    def _run_steps(self):
        flights_touched = set()
        for step in self.plan.steps:
            fam = step["family"]
            at = self.plan.at(step)
            params = step.get("params") or {}
            builder = getattr(self, "step_" + fam, None)
            if builder is None:
                self.notes.add(f"unknown family {fam}: step skipped")
                continue
            known = _known_params().get(fam, [])
            ignored = sorted(set(params) - set(known))
            if ignored:
                self.notes.add(f"{fam}: params {ignored} are not read by the builder, which used its defaults (it reads {known})")
            builder(at, params, step["phase"], step.get("surround", self.plan.surround))
            if fam in ("flight_cancelled", "flight_cancelled_rebooked", "flight_diverted", "return_to_ramp", "departure_delay"):
                flights_touched.add(params.get("segment", 1))
        if self.plan.surround and self.plan.steps:
            self._surround_flight_ops(flights_touched)

    # ---- PNR versions
    def _new_pnr_version(self, at, mutate, trigger=None, family="pnr_version", phase="changes", origin="step"):
        prev = self.last_pnr()
        new = copy.deepcopy(prev)
        old_pnr = copy.deepcopy(prev["processedPnr"])
        pnr = new["processedPnr"]
        mutate(pnr)
        pnr["version"] = str(int(str(old_pnr.get("version", "0"))) + 1)
        pnr["lastModification"] = copy.deepcopy(old_pnr.get("lastModification") or {})
        pnr["lastModification"]["dateTime"] = iso_utc(at)
        events, ops = diff(old_pnr, pnr)
        new["previousRecord"] = ops
        new["events"] = {"events": events, "originFeedTimeStamp": iso_utc(at), "recordDomain": "PNR", "recordId": pnr["id"]}
        new.setdefault("meta", {})["triggerEventLog"] = {"id": trigger_id(pnr["id"], pnr["version"], iso_utc(at))}
        new["meta"].pop("subscribedCustomerTrigger", None)
        if trigger:
            new["meta"]["subscribedCustomerTrigger"] = [{"dateTime": iso_utc(at), "id": trigger_id("trigger", pnr["id"], pnr["version"]), "origin": "PNR", **trigger}]
        self.add("PNR", at, new, family, phase, origin)
        return new

    def _air_product(self, pnr, k):
        sid = self.segment_id(k)
        return next((p for p in pnr.get("products", []) if p.get("id") == sid and p.get("subType") == "AIR"), None)

    def _air_segment_body(self, seg, status):
        return {"departure": {"iataCode": seg.origin, "localDateTime": seg.dep_local}, "arrival": {"iataCode": seg.destination, "localDateTime": seg.arr_local},
                "carrierCode": seg.carrier, "number": seg.number, "aircraft": {"code": seg.aircraft}, "class": seg.booking_class, "cabin": seg.cabin,
                "operating": {"carrierCode": seg.op_carrier, "number": seg.op_number}, "bookingDateTime": iso_utc(self.plan.created), "status": status,
                "isOpenNumber": False, "isInformational": False}

    def _next_st(self, pnr):
        n = 0
        for p in pnr.get("products", []):
            m = re.search(r"-ST-(\d+)$", p.get("id", ""))
            if m:
                n = max(n, int(m.group(1)))
        return n + 1

    def step_schedule_change(self, at, params, phase, surround):
        k = params.get("segment", 1)
        seg = self.seg(k)
        dep_delta = params.get("departureDeltaMinutes", 90)
        arr_delta = params.get("arrivalDeltaMinutes", dep_delta)
        new_dep = iso_local(datetime.fromisoformat(seg.dep_local) + timedelta(minutes=dep_delta))
        new_arr = iso_local(datetime.fromisoformat(seg.arr_local) + timedelta(minutes=arr_delta))
        old_dep, old_arr = seg.dep_local, seg.arr_local
        changes = []

        def mutate(pnr):
            p = self._air_product(pnr, k)
            if p is None:
                self.notes.add(f"schedule_change: segment {k} is not in the PNR")
                return
            idx = pnr["products"].index(p)
            p["airSegment"]["departure"]["localDateTime"] = new_dep
            p["airSegment"]["arrival"]["localDateTime"] = new_arr
            changes.extend([{"elementId": p["id"], "elementType": "AirSegment", "path": f"/products/{idx}/airSegment/departure/localDateTime", "previousValue": old_dep, "value": new_dep},
                            {"elementId": p["id"], "elementType": "AirSegment", "path": f"/products/{idx}/airSegment/arrival/localDateTime", "previousValue": old_arr, "value": new_arr}])
        self._new_pnr_version(at, mutate, {"triggerEventName": "AirSegmentDepartureDateTimeChanged", "changeLog": changes}, "schedule_change", phase)
        seg.dep_local, seg.arr_local = new_dep, new_arr
        seg.dep_utc, seg.arr_utc = local_to_utc(new_dep, seg.origin), local_to_utc(new_arr, seg.destination)
        if surround:
            self._notification(at + timedelta(minutes=3), "SC", phase, previous=[(seg, old_dep, old_arr, "HK")], origin="surround")

    # ---- rebookings
    def _replacement_segment(self, seg, rep, who):
        """The segment that replaces `seg`, added to the plan (so departure:k, arrival:k and params.segment name it from now on).
        params.replacement may change the carrier, number, origin and destination and must give the times; without times the
        replaced flight's move to the next day. An origin or destination the replacement names is used as given (YYZ-YVR
        rebooked to YYZ-YEG): the booking is then really re-routed."""
        rep = {} if rep is None else rep
        if not isinstance(rep, dict):
            raise ValueError(f"{who}: params.replacement is an object {{carrier?, number?, origin?, destination?, departure, arrival}}; got {rep!r}")
        for key in ("origin", "destination"):
            if key in rep and not (isinstance(rep[key], str) and re.fullmatch(r"[A-Za-z]{3}", rep[key])):
                raise ValueError(f"{who}: params.replacement.{key} is a 3-letter IATA code; got {rep[key]!r}")
        spec = {"carrier": rep.get("carrier", seg.carrier), "number": rep.get("number", seg.number),
                "origin": rep.get("origin") or seg.origin, "destination": rep.get("destination") or seg.destination,
                "departure": rep.get("departure") or iso_local(datetime.fromisoformat(seg.dep_local) + timedelta(days=1)),
                "arrival": rep.get("arrival") or iso_local(datetime.fromisoformat(seg.arr_local) + timedelta(days=1)),
                "cabin": seg.cabin, "bookingClass": seg.booking_class, "aircraft": seg.aircraft}
        new_seg = Segment(len(self.plan.segments) + 1, spec, self.notes)
        self.plan.segments.append(new_seg)
        for bound in self.plan.bounds:  # the bound keeps its order: the replacement sits where the replaced flight was
            if seg in bound:
                bound.insert(bound.index(seg) + 1, new_seg)
        return new_seg

    @staticmethod
    def _next_ot(pnr):
        n = 0
        for m in re.finditer(r"-OT-(\d+)\"", json.dumps(pnr)):
            n = max(n, int(m.group(1)))
        return n + 1

    def _add_segment_product(self, pnr, old, new_seg, status):
        """The replacement's own air product (its own ST id), right after `old`: in the bound's flights and with one delivery
        record per traveler, as the replaced segment has. Returns its id."""
        idx = pnr["products"].index(old)
        new_id = f"{self.pnr_id}-ST-{self._next_st(pnr)}"
        q = copy.deepcopy(old)
        q["id"] = new_id
        q["airSegment"] = self._air_segment_body(new_seg, status)
        q.pop("products", None)
        pnr["products"].insert(idx + 1, q)
        for it in pnr.get("flightItineraries", []):
            flights = it.get("flights", [])
            for pos, f in enumerate(flights):
                if (f.get("flightSegment") or {}).get("id") == old["id"]:
                    flights.insert(pos + 1, {"flightSegment": {"id": new_id, "ref": "processedPnr.products", "type": "product"}})
                    break
        deliveries = (pnr.get("deliveryData") or {}).get("segmentDeliveries", [])
        ot = self._next_ot(pnr)
        for d in list(deliveries):
            if (d.get("product") or {}).get("id") == old["id"]:
                e = copy.deepcopy(d)
                e["id"] = f"{self.pnr_id}-OT-{ot}"
                ot += 1
                e["product"]["id"] = new_id
                deliveries.append(e)
        return new_id

    @staticmethod
    def _remove_segment_product(pnr, old, moved_to=None):
        """The air product leaves the PNR with its place in the flights and its delivery records. With `moved_to` (a customer's
        own rebooking) the services and loyalty requests that named it name the new segment instead."""
        pnr["products"].remove(old)
        for it in pnr.get("flightItineraries", []):
            it["flights"] = [f for f in it.get("flights", []) if (f.get("flightSegment") or {}).get("id") != old["id"]]
        if pnr.get("deliveryData"):
            pnr["deliveryData"]["segmentDeliveries"] = [d for d in pnr["deliveryData"].get("segmentDeliveries", []) if (d.get("product") or {}).get("id") != old["id"]]
        if moved_to:
            for owner in [*pnr.get("products", []), *pnr.get("loyaltyRequests", [])]:
                refs = (owner.get("products") or {}).get("collection")
                if refs:
                    for ref in refs:
                        if ref.get("id") == old["id"]:
                            ref["id"] = moved_to
                    seen, unique = set(), []
                    for ref in refs:
                        if ref.get("id") not in seen:
                            seen.add(ref.get("id"))
                            unique.append(ref)
                    owner["products"]["collection"] = unique

    def _refresh_bound_ends(self, pnr, ids):
        """Every bound's end points follow its first and last flight the booking still holds (not UN): YYZ-YVR rebooked to YYZ-YEG
        ends in YEG. (`ids` names the products the step changed; a seed with a bound per segment may carry end points that were
        never the bound's own, so all of them are made consistent.)"""
        for it in pnr.get("flightItineraries", []):
            flight_ids = [(f.get("flightSegment") or {}).get("id") for f in it.get("flights", [])]
            if not flight_ids:
                continue
            air = [p for p in (next((x for x in pnr.get("products", []) if x.get("id") == i), None) for i in flight_ids)
                   if p and p.get("airSegment") and p["airSegment"].get("status") != "UN"]
            if not air:
                continue
            if "originIataCode" in it:
                it["originIataCode"] = air[0]["airSegment"]["departure"]["iataCode"]
            if "destinationIataCode" in it:
                it["destinationIataCode"] = air[-1]["airSegment"]["arrival"]["iataCode"]

    def step_flight_cancelled_rebooked(self, at, params, phase, surround):
        k = params.get("segment", 1)
        seg = self.seg(k)
        new_seg = self._replacement_segment(seg, params.get("replacement"), "flight_cancelled_rebooked")
        new_seg.status = "TK"
        changes = []
        new_id = [None]

        def mutate(pnr):
            p = self._air_product(pnr, k)
            if p is None:
                self.notes.add(f"flight_cancelled_rebooked: segment {k} is not in the PNR")
                return
            idx = pnr["products"].index(p)
            prior = p["airSegment"]["status"]
            p["airSegment"]["status"] = "UN"
            changes.append({"elementId": p["id"], "elementType": "AirSegment", "path": f"/products/{idx}/airSegment/status", "previousValue": prior, "value": "UN"})
            new_id[0] = self._add_segment_product(pnr, p, new_seg, "TK")
            self._refresh_bound_ends(pnr, {p["id"], new_id[0]})
        self._new_pnr_version(at, mutate, {"triggerEventName": "AirSegmentStatusChanged", "changeLog": changes}, "flight_cancelled_rebooked", phase)
        if new_id[0]:
            self._st_ids[new_seg.k] = new_id[0]
        self._pending_rebookings.append((k, new_seg.k))
        if surround:
            self._fdm(seg, at - timedelta(minutes=10), "flight_cancelled", phase, {"changeReason": params.get("reason", "WX")}, origin="surround")
            self._notification(at + timedelta(minutes=2), "RC", phase, previous=[(seg, seg.dep_local, seg.arr_local, "UN")], origin="surround")
        if params.get("acceptAfterMinutes") is not None:
            self.step_rebooking_accepted(at + timedelta(minutes=params["acceptAfterMinutes"]), {}, phase, surround)

    def step_rebooking_accepted(self, at, params, phase, surround):
        pending = self._pending_rebookings
        if not pending:
            self.notes.add("rebooking_accepted without a preceding flight_cancelled_rebooked")
            return
        removed = {old for old, _ in pending}
        kept = [new for _, new in pending if new not in removed]  # a protecting flight itself cancelled and rebooked is gone too
        changes = []

        def mutate(pnr):
            for old_k in sorted(removed):
                old = self._air_product(pnr, old_k)
                if old is not None:
                    self._remove_segment_product(pnr, old)
            for new_k in kept:
                new = self._air_product(pnr, new_k)
                if new is not None:
                    idx = pnr["products"].index(new)
                    previous = new["airSegment"]["status"]
                    new["airSegment"]["status"] = "HK"
                    changes.append({"elementId": new["id"], "elementType": "AirSegment", "path": f"/products/{idx}/airSegment/status", "previousValue": previous, "value": "HK"})
            self._refresh_bound_ends(pnr, {self.segment_id(i) for i in removed | set(kept)})
        self._new_pnr_version(at, mutate, {"triggerEventName": "AirSegmentStatusChanged", "changeLog": changes}, "rebooking_accepted", phase)
        for new_k in kept:
            self.seg(new_k).status = "HK"
        for old_k in removed:
            self.seg(old_k).status = "XX"
        self._pending_rebookings = []

    def step_customer_rebooking(self, at, params, phase, surround):
        """The customer moves themselves (a voluntary change): one PNR version removes the old air product and adds the new one HK,
        with no UN and no TK, which is how the engines tell it from an airline's rebooking. After a flight_cancelled_rebooked the
        customer declines the airline's protection and picks their own flight (SELFREACC): params.segment names the cancelled
        flight (UN) or its protecting one (TK) and both leave the PNR beside the replacement."""
        k = params.get("segment", 1)
        seg = self.seg(k)
        new_seg = self._replacement_segment(seg, params.get("replacement"), "customer_rebooking")
        drop = {k}
        grew = True
        while grew:  # the pairs this segment belongs to, and the pairs those belong to
            grew = False
            for old_k, new_k in self._pending_rebookings:
                if ({old_k, new_k} & drop) and not {old_k, new_k} <= drop:
                    drop |= {old_k, new_k}
                    grew = True
        new_id = [None]

        def mutate(pnr):
            p = self._air_product(pnr, k)
            if p is None:
                self.notes.add(f"customer_rebooking: segment {k} is not in the PNR")
                return
            new_id[0] = self._add_segment_product(pnr, p, new_seg, "HK")
            gone = {self.segment_id(i) for i in drop}
            for dk in sorted(drop):
                old = self._air_product(pnr, dk)
                if old is not None:
                    self._remove_segment_product(pnr, old, moved_to=new_id[0])
            self._refresh_bound_ends(pnr, gone | {new_id[0]})
        self._new_pnr_version(at, mutate, None, "customer_rebooking", phase)
        if new_id[0]:
            self._st_ids[new_seg.k] = new_id[0]
            for dk in drop:
                self.seg(dk).status = "XX"
                self.seg(dk).voluntary = True
            self._pending_rebookings = [pr for pr in self._pending_rebookings if not set(pr) & drop]

    def step_booking_cancelled(self, at, params, phase, surround):
        def mutate(pnr):
            pnr["products"] = [p for p in pnr.get("products", []) if p.get("subType") != "AIR"]
            for it in pnr.get("flightItineraries", []):
                it["flights"] = []
            if pnr.get("deliveryData"):
                pnr["deliveryData"]["segmentDeliveries"] = []
        self._new_pnr_version(at, mutate, None, "booking_cancelled", phase)

    # ---- ticketing
    def step_ticket_issued(self, at, params, phase, surround):
        pax = self._each_passenger(params)
        numbers = {}
        for i in pax:
            if i in self.ticket_numbers and not params.get("reissue"):
                continue
            number = "014" + "".join(self.rng.choice("0123456789") for _ in range(10))
            self.ticket_numbers[i] = number
            numbers[i] = number
            self.add("TKT", at + timedelta(seconds=i), self._ticket(i, number, at), "ticket_issued", phase)
        if not numbers:
            self.notes.add("ticket_issued: every passenger already holds a ticket from the seed")
            return
        if surround:
            self._pnr_ticketed(at + timedelta(minutes=1), numbers, phase)
            self._pnr_ticket_correlation(at + timedelta(minutes=2), numbers, phase)

    def _ticket(self, i, number, at):
        first, last = self.passenger_name(i)
        date = at.strftime("%Y-%m-%d")
        x = self.exemplar("processedTicket") or {"processedTicket": {}, "meta": {"version": "3.5.0"}}
        t = x["processedTicket"]
        t.update(primaryDocumentNumber=number, documentNumbers=[number], id=f"{number}-{date}", documentType="T", issuanceType="F",
                 issuanceLocalDate=date, version=str(int(at.timestamp() * 1000)), numberOfBooklets=1,
                 traveler={"name": {"firstName": first, "lastName": last}, "passengerTypeCode": self.plan.passengers[i].get("type", "ADT")},
                 pnrReferences=[{"systemId": "1A", "recordLocator": self.locator}], validatingCarrierRecordLocator=self.locator,
                 validatingCarrierCode=self.plan.segments[0].carrier, latestEvent={"code": "130", "dateTimeGMT": at.strftime("%Y-%m-%dT%H:%M:%S")})
        t.pop("originalDocuments", None)
        t.pop("ticketRefund", None)
        coupons = []
        for seg in self.plan.segments:
            if not self._held(seg, at):
                continue
            body = {"bookingClass": seg.booking_class, "stopOver": False, "arrival": {"iataCode": seg.destination, "at": seg.arr_local},
                    "carrierCode": seg.carrier, "flightnumber": seg.number, "departure": {"iataCode": seg.origin, "at": seg.dep_local},
                    "operating": {"carrierCode": seg.op_carrier, "flightnumber": seg.op_number}}
            n = len(coupons) + 1
            coupons.append({"sequenceNumber": n, "number": str(n), "documentNumber": number, "id": f"{number}-{date}-{n}", "fareBasisCode": "TLOWC1",
                            "isNonRefundable": True, "isNonExchangeable": False, "isCodeshare": seg.carrier != seg.op_carrier,
                            "validityDates": {"notValidAfterDate": seg.dep_date, "notValidBeforeDate": seg.dep_date},
                            "soldSegment": body, "currentSegment": copy.deepcopy(body), "reservationStatus": "CONFIRMED", "status": "OPEN_FOR_USE",
                            "baggageAllowance": {"quantity": 1}})
        t["coupons"] = coupons
        t.setdefault("price", {"total": "412.00", "totalTaxes": "62.00", "currency": "CAD", "detailedPrices": [{"amount": "412.00", "currency": "CAD", "elementaryPriceType": "TotalFare"}]})
        t["originCityCode"], t["destinationCityCode"] = self.plan.segments[0].origin, self.plan.segments[-1].destination
        x["events"] = {"recordId": t["id"], "recordDomain": "TICKET", "originFeedTimeStamp": at.strftime("%Y-%m-%dT%H:%M:%S"),
                       "events": [{"origin": "COMPARISON", "eventType": "CREATED"}]}
        x["meta"] = {"triggerEventLog": {"id": trigger_id("tkt", number, date)}, "version": x.get("meta", {}).get("version", "3.5.0")}
        x.pop("previousRecord", None)
        return x

    def _pnr_ticketed(self, at, numbers, phase):
        date = at.strftime("%Y-%m-%d")

        def mutate(pnr):
            refs = pnr.setdefault("ticketingReferences", [])
            n = 500 + len(refs)
            for i, number in numbers.items():
                refs.append({"id": f"{self.pnr_id}-OT-{n}", "type": "ticketing-reference", "referenceTypeCode": "FA", "isInfant": False,
                             "traveler": {"id": self.traveler_id(i), "ref": "processedPnr.travelers", "type": "stakeholder"},
                             "products": {"collection": [{"id": self.segment_id(s.k), "ref": "processedPnr.products", "type": "product"} for s in self._held_segments(at)]},
                             "documents": [{"documentType": "ETICKET", "primaryDocumentNumber": number, "issuanceLocalDate": date, "status": "ISSUED", "numberOfBooklets": 1,
                                            "issuingOriginatorOffice": {"id": "YULAC08IB", "iataNumber": "07512374", "systemCode": "AC"},
                                            "coupons": [{"sequenceNumber": j + 1, "product": {"id": self.segment_id(s.k), "ref": "processedPnr.products", "type": "product"}}
                                                        for j, s in enumerate(self._held_segments(at))]}]})
                n += 1
        self._new_pnr_version(at, mutate, None, "pnr_ticketed", phase, origin="surround")

    def _pnr_ticket_correlation(self, at, numbers, phase):
        pnr = self.last_pnr()["processedPnr"]
        refs = {(r.get("traveler") or {}).get("id"): r["id"] for r in pnr.get("ticketingReferences", [])}
        date = at.strftime("%Y-%m-%d")
        ticket_ids = [f"{n}-{date}" for n in numbers.values()]
        correlated = {}
        for i, number in numbers.items():
            tid = f"{number}-{date}"
            correlated[tid] = [{"ticketCouponId": f"{tid}-{j + 1}", "pnrTravelerId": self.traveler_id(i), "pnrAirSegmentId": self.segment_id(s.k),
                                "pnrTicketingReferenceId": refs.get(self.traveler_id(i), "")}
                               for j, s in enumerate(self._held_segments(at))]
        obj = {"correlationPnrTicket": {"pnrId": self.pnr_id, "ticketIds": ticket_ids, "correlatedData": correlated},
               "dictionaries": {"pnrs": {self.pnr_id: {"type": "pnr", "id": self.pnr_id, "version": str(pnr["version"])}},
                                "tickets": {tid: {"type": "air-travel-document", "id": tid, "version": str(int(at.timestamp() * 1000))} for tid in ticket_ids}},
               "events": {"recordId": self.pnr_id, "recordDomain": "PNR_TICKET", "originFeedTimeStamp": iso_utc(at),
                          "events": [{"origin": "COMPARISON", "eventType": "CREATED", "currentPath": "/correlationPnrTicket"}]},
               "meta": {"triggerEventLog": {"id": trigger_id("corr", self.pnr_id, date)}, "version": "1.13.0"}}
        self.add("PNRCORR", at, obj, "pnr_ticket_correlation", phase, "surround")

    # ---- CM
    def _dcs(self, i):
        d = self.dcs.get(i)
        if d is None:
            d = self.dcs[i] = {"id": "".join(self.rng.choice("0123456789ABCDEF") for _ in range(16)), "etag": None, "record": None, "segdel": {}}
        for k in range(1, len(self.plan.segments) + 1):
            d["segdel"].setdefault(k, "".join(self.rng.choice("0123456789ABCDEF") for _ in range(16)))
        return d

    def _cm_correlation(self, i, at, phase, include=()):
        d = self._dcs(i)
        pnr = self._pnr_at(at) or self.last_pnr()["processedPnr"]
        segments = [s for s in self.plan.segments if s in self._held_segments(at) or s.k in include]
        rows = [{"dcsPassengerSegmentDeliveryId": d["segdel"][s.k], "pnrTravelerId": self.traveler_id(i), "pnrAirSegmentId": self.segment_id(s.k)}
                for s in segments]
        d.setdefault("corr", set()).update(r["dcsPassengerSegmentDeliveryId"] for r in rows)
        obj = {"correlationDcsPassengerPnr": {"dcsPassengerId": d["id"], "pnrIds": [self.pnr_id], "correlatedData": {self.pnr_id: rows}},
               "dictionaries": {"dcsPassengers": {d["id"]: {"id": d["id"], "type": "dcs-passenger", "version": str(int(at.timestamp()))}},
                                "pnrs": {self.pnr_id: {"id": self.pnr_id, "type": "pnr", "version": str(pnr["version"])}}},
               "events": {"recordId": d["id"], "recordDomain": "DCSPASSENGER_PNR", "originFeedTimeStamp": iso_utc(at),
                          "events": [{"origin": "COMPARISON", "eventType": "CREATED", "currentPath": "/correlationDcsPassengerPnr"}]},
               "meta": {"triggerEventLog": {"id": trigger_id("cmcorr", d["id"], iso_utc(at))}, "version": "2.2.0"}}
        self.add("CM", at, obj, "cm_correlation", phase, "surround")
        d["correlated"] = True

    def _cm_segment(self, i, seg, d):
        return {"id": d["segdel"][seg.k], "dcsProductType": "ACTIVE_SYNCHRONISED",
                "segment": {"number": seg.number, "carrierCode": seg.carrier, "class": seg.booking_class, "cabin": seg.cabin, "statusCode": "HK",
                            "departure": {"iataCode": seg.origin, "at": iso_utc(seg.dep_utc)}, "arrival": {"iataCode": seg.destination, "at": iso_utc(seg.arr_utc)},
                            "operating": {"number": seg.op_number, "carrierCode": seg.op_carrier}},
                "legDeliveries": [{"id": f"{d['segdel'][seg.k]}-{seg.origin}", "operatingFlight": {"number": seg.op_number, "carrierCode": seg.op_carrier},
                                   "departure": {"iataCode": seg.origin, "at": seg.dep_date}, "arrival": {"iataCode": seg.destination},
                                   "travelCabinCode": seg.cabin, "acceptance": {"status": "NOT_ACCEPTED"},
                                   "boarding": {"boardingStatus": "NOT_BOARDED", "boardingPassPrint": {"channel": "NONE", "status": "NOT_PRINTED"}}}],
                "passengerDisruption": {"productState": {"status": "NOT_DISRUPTED"}}}

    def _cm_update(self, i, at, mutate, family, phase, origin="step"):
        """A new DCS passenger record for passenger i: CREATED when it is the first, else an UPDATED diff."""
        d = self._dcs(i)
        if not d.get("correlated") and d["record"] is None:
            self._cm_correlation(i, at - timedelta(minutes=1), phase)
        first, last = self.passenger_name(i)
        if d["record"] is None:
            x = self.exemplar("processedDcsPassenger") or {"meta": {"version": "2.2.0"}, "processedDcsPassenger": {}}
            p = x["processedDcsPassenger"]
            p.update(id=d["id"], recordLocator=self.locator, isMasterRecord=True, cprFeedType="MARKETING_SBR",
                     passenger={"name": {"firstName": first, "lastName": last}, "flightPassengerType": "ADULT" if self.plan.passengers[i].get("type", "ADT") == "ADT" else "CHILD", "gender": "UNKNOWN"},
                     segmentDeliveries=[self._cm_segment(i, s, d) for s in self._held_segments(at)], services=[])
            p.pop("flightTransfers", None)
            x.pop("previousRecord", None)
            mutate(p)
            p["etag"] = str(int(at.timestamp() * 1000))
            x["lastModification"] = {"dateTime": at.strftime("%Y-%m-%dT%H:%M:%S.000Z"), "triggerEventName": "1AINTERNAL", "user": {"officeID": "YULAC08AP"}}
            x["events"] = {"recordId": d["id"], "recordDomain": "DcsPassenger", "originFeedTimeStamp": x["lastModification"]["dateTime"],
                           "events": [{"origin": "COMPARISON", "eventType": "CREATED", "currentPath": ""}]}
            x["meta"] = {"triggerEventLog": {"id": trigger_id("cm", d["id"], p["etag"])}, "version": x.get("meta", {}).get("version", "2.2.0")}
        else:
            x = copy.deepcopy(d["record"])
            old = copy.deepcopy(x["processedDcsPassenger"])
            p = x["processedDcsPassenger"]
            # a segment the PNR no longer holds at this time leaves the passenger's deliveries with the update
            gone = {d["segdel"].get(s.k) for s in self.plan.segments if self._product_at(s, at) is None and self._in_a_pnr(s)}
            p["segmentDeliveries"] = [s for s in p.get("segmentDeliveries", []) if s.get("id") not in gone]
            mutate(p)
            p["etag"] = str(int(at.timestamp() * 1000))
            events, ops = diff(old, p)
            x["previousRecord"] = ops
            x["lastModification"] = {"dateTime": at.strftime("%Y-%m-%dT%H:%M:%S.000Z"), "triggerEventName": "1AINTERNAL", "user": {"officeID": "YULAC08AP"}}
            x["events"] = {"recordId": d["id"], "recordDomain": "DcsPassenger", "originFeedTimeStamp": x["lastModification"]["dateTime"], "events": events}
            x["meta"] = {"triggerEventLog": {"id": trigger_id("cm", d["id"], p["etag"])}, "version": x.get("meta", {}).get("version", "2.2.0")}
        # a delivery of a segment the correlation does not name yet (a protecting flight, a replacement) is correlated before it
        ks = {s.k for s in self.plan.segments}
        mine = {d["segdel"][k]: k for k in ks if k in d["segdel"]}
        missing = {mine[sid] for sid in (s.get("id") for s in x["processedDcsPassenger"].get("segmentDeliveries", [])) if sid in mine and sid not in d.setdefault("corr", set())}
        if missing:
            self._cm_correlation(i, at - timedelta(seconds=2), phase, include=missing)
        d["record"] = x
        d["etag"] = x["processedDcsPassenger"]["etag"]
        self.add("CM", at, x, family, phase, origin)

    def _leg(self, p, k, i=0):
        """Passenger i's delivery of segment k. Matched by the segment's own delivery id, not by flight number and origin:
        a replacement with the same carrier, number and origin as the flight it replaces (AC506 12:45 moved to 10:45) is a
        different segment, and a lookup by number returned the old one's delivery."""
        seg = self.seg(k)
        d = self._dcs(i)
        for s in p.get("segmentDeliveries", []):
            if s.get("id") == d["segdel"][k]:
                return s, s["legDeliveries"][0]
        s = self._cm_segment(i, seg, d)
        p.setdefault("segmentDeliveries", []).append(s)
        return s, s["legDeliveries"][0]

    def _each_passenger(self, params):
        """The step's passengers: params.passengers as 0-based indexes into plan.passengers, or everyone. An index the plan
        does not have is the plan's error, named (a 1-based list raised IndexError, a 500, in the e2e run of 2026-10-14)."""
        n = len(self.plan.passengers)
        pax = params.get("passengers")
        if not pax:
            return list(range(n))
        if not isinstance(pax, list) or not all(isinstance(i, int) and not isinstance(i, bool) and 0 <= i < n for i in pax):
            raise ValueError(f"params.passengers lists 0-based indexes into plan.passengers (0 to {n - 1}); got {pax!r}")
        return pax

    def step_check_in(self, at, params, phase, surround):
        k = params.get("segment", 1)
        for n, i in enumerate(self._each_passenger(params)):
            def mutate(p, i=i):
                _, leg = self._leg(p, k, i)
                leg["acceptance"] = {"status": "ACCEPTED", "channel": params.get("channel", "WEB"), "acceptanceType": "PRIMARY", "isAdvanceAccepted": True}
                leg["seating"] = {"seat": {"number": params.get("seat") or f"{self.rng.randrange(12, 36)}{'ABCDEF'[i % 6]}"}}
                leg["boarding"] = {"boardingStatus": "NOT_BOARDED", "boardingPassPrint": {"channel": "MOBILE", "status": "PRINTED"}}
            self._cm_update(i, at + timedelta(seconds=n * 20), mutate, "check_in", phase)

    def step_boarding(self, at, params, phase, surround):
        k = params.get("segment", 1)
        for n, i in enumerate(self._each_passenger(params)):
            def mutate(p):
                _, leg = self._leg(p, k, i)
                leg.setdefault("boarding", {})["boardingStatus"] = "BOARDED"
                leg["boarding"]["boardingZone"] = str(params.get("zone", 3))
            self._cm_update(i, at + timedelta(seconds=n * 15), mutate, "boarding", phase)

    def step_denied_boarding(self, at, params, phase, surround):
        k = params.get("segment", 1)
        for n, i in enumerate(self._each_passenger(params)):
            def mutate(p):
                s, leg = self._leg(p, k, i)
                leg["acceptance"] = {"status": "NOT_ACCEPTED", "cancellationReason": "Denied Boarding", "channel": "JFE"}
                leg["boarding"] = {"boardingStatus": "NOT_BOARDED"}
                s["passengerDisruption"] = {"productState": {"status": "DISRUPTED"}}
                p.setdefault("flightTransfers", []).append({"id": "".join(self.rng.choice("0123456789ABCDEF") for _ in range(16)),
                                                            "disruptionTransferReason": params.get("reason", "DENIED_BOARDING_OVERSALES"),
                                                            "status": "TRANSFERRED", "fromSegment": {"id": s["id"]}})
            self._cm_update(i, at + timedelta(seconds=n * 15), mutate, "denied_boarding", phase)

    def step_no_show(self, at, params, phase, surround):
        k = params.get("segment", 1)
        for n, i in enumerate(self._each_passenger(params)):
            def mutate(p):
                _, leg = self._leg(p, k, i)
                leg["acceptance"] = {"status": "NOT_ACCEPTED", "cancellationReason": "NOSHOW"}
                leg["boarding"] = {"boardingStatus": "NOT_BOARDED"}
            self._cm_update(i, at + timedelta(seconds=n * 15), mutate, "no_show", phase)

    # ---- bags
    def _brock(self, at, kind, i, bag, seg, extra, family, phase, origin="step"):
        first, last = self.passenger_name(i)
        x = self.exemplar("brock:" + kind)
        x = x[0] if isinstance(x, list) else (x or {})
        legs = [{"BagCategory": "", "BagType": "CheckedBag", "FlightArrivalStationCode": s.destination, "FlightCarrierCode": s.op_carrier,
                 "FlightDepartureDateLocal": s.dep_date, "FlightDepartureStationCode": s.origin, "FlightLegTypeId": 0, "FlightNumber": s.op_number.zfill(4),
                 "Weight": "", "WeightUnitTypeId": 1} for s in self._held_segments(at)]
        x.update({"Type": kind, "BagTag": bag["tag"], "BagId": bag["bagId"], "EventStoreId": self.rng.randrange(10**9, 10**10), "PNR": self.locator,
                  "PassengerName": f"{last}/{first}", "SourceSystemId": 1, "StationCode": seg.origin, "BagTagStatus": "Active",
                  "Timestamp": at.strftime("%Y-%m-%dT%H:%M:%S.0000000+00:00"), "BagFlightLegs": legs,
                  "FlightLegs": [{k: v for k, v in l.items() if k.startswith("Flight")} for l in legs],
                  "FlightCarrierCode": seg.op_carrier, "FlightNumber": seg.op_number.zfill(4), "FlightDepartureStationCode": seg.origin,
                  "FlightArrivalStationCode": seg.destination, "FlightDepartureDateLocal": seg.dep_date, **extra})
        x.setdefault("Version", "1.47.0+qa")
        self.add("SMART_SUITE", at, x, family, phase, origin)

    def step_bag_checked(self, at, params, phase, surround):
        k = params.get("segment", 1)
        seg = self.seg(k)
        for n, i in enumerate(self._each_passenger(params)):
            d = self._dcs(i)
            bags = self.bags.setdefault(i, [])
            group = "".join(self.rng.choice("0123456789ABCDEF") for _ in range(16))
            new = []
            for _ in range(params.get("count", 1)):
                bag = {"tag": "0014" + "".join(self.rng.choice("0123456789") for _ in range(6)), "bagId": self.rng.randrange(10**8, 10**9), "group": group}
                bags.append(bag)
                new.append(bag)
            t = at + timedelta(seconds=n * 30)
            x = self.exemplar("processedBagsGroup") or {"meta": {"version": "2.2.0"}}
            legs = [s for s in self._held_segments(t) if s.k >= k]
            x["processedBags"] = [{"id": f"{bag['bagId']:X}".rjust(16, "A"), "bagType": "STANDARD", "systemSource": "AUTOMATIC",
                                   "bagTag": {"licensePlate": bag["tag"], "systemSource": "AUTOMATIC", "issuingCarrier": seg.carrier, "finalDestination": legs[-1].destination},
                                   "legs": [{"id": s.origin, "operatingFlight": {"carrierCode": s.op_carrier, "flightNumber": s.op_number}, "boardPoint": {"iataCode": s.origin, "localDateTime": s.dep_date},
                                             "offPoint": {"iataCode": s.destination}, "acceptanceStatus": "FULLY_ACCEPTED", "authorityToLoad": True, "authorityToTransport": True,
                                             "activationStatus": "ACTIVE", "travelClassCode": s.cabin, "checkinLocation": {"trackedLocation": {"identifier": "CKIN"}}} for s in legs]} for bag in new]
            x["processedBagsGroup"] = {"id": group, "etag": str(int(t.timestamp() * 1000)), "checkedBagsCount": len(new),
                                       "checkedBags": {"collection": [{"id": b["id"], "type": "bag"} for b in x["processedBags"]]},
                                       "responsiblePassenger": {"id": d["id"], "type": "dcs-passenger"},
                                       "itinerary": [{"id": s.origin, "boardPoint": {"iataCode": s.origin}, "offPoint": {"iataCode": s.destination}} for s in legs]}
            x["baggageAllowances"] = [{"allowanceType": "ADULT_ALLOWANCE", "quantity": 1, "boardPoint": {"iataCode": legs[0].origin}, "offPoint": {"iataCode": legs[-1].destination}}]
            x["lastModification"] = {"dateTime": t.strftime("%Y-%m-%dT%H:%M:%S.000Z"), "triggerEventName": "MFNDCR", "user": {"officeId": f"{seg.origin}AC002A", "id": "AC000000"}}
            x["events"] = {"recordId": group, "recordDomain": "DcsBaggage", "originFeedTimeStamp": x["lastModification"]["dateTime"],
                           "events": [{"origin": "COMPARISON", "eventType": "CREATED", "currentPath": ""}]}
            x["meta"] = {"triggerEventLog": {"id": trigger_id("bags", group)}, "version": "2.2.0"}
            x.pop("previousRecord", None)
            self.add("CM_BAG", t, x, "bag_checked", phase)
            corr = {"dcsBaggageCorrelations": {"correlationBagsGroupPnr": {"pnrIds": [self.pnr_id], "bagsGroupId": group,
                                                                           "correlatedData": {self.pnr_id: [{"bagId": b["id"], "pnrTravelerId": self.traveler_id(i),
                                                                                                             "bagLegCorrelations": [{"bagLegDeliveryId": s.origin, "pnrAirSegmentId": self.segment_id(s.k)} for s in legs]} for b in x["processedBags"]]}},
                                               "dictionaries": {"pnrs": {self.pnr_id: {"id": self.pnr_id, "type": "pnr", "version": str(self.last_pnr()["processedPnr"]["version"])}},
                                                                "bagsGroups": {group: {"id": group, "type": "bags-group", "version": x["processedBagsGroup"]["etag"]}}}},
                    "events": {"recordId": group, "recordDomain": "DCSBAGGAGE_PNR", "originFeedTimeStamp": x["lastModification"]["dateTime"],
                               "events": [{"origin": "COMPARISON", "eventType": "CREATED", "currentPath": "/correlationBagsGroupPnr"}]},
                    "meta": {"triggerEventLog": {"id": trigger_id("bagcorr", group)}, "version": "2.2.0"}}
            self.add("CM_BAG", t + timedelta(seconds=2), corr, "bag_checked", phase, "surround")
            if surround:
                for bag in new:
                    self._brock(t + timedelta(seconds=5), "BagCreatedEvent", i, bag, seg, {}, "bag_created", phase, "surround")
                    self._brock(t + timedelta(minutes=1), "BagAcceptedDeclaration", i, bag, seg, {}, "bag_accepted", phase, "surround")
                    self._bag_tail.append((i, bag, legs))

    def _surround_bag_tail(self):
        """Each bag's loading, unloading and carousel, after every step, from its flights' actual times: emitted with the
        bag step, they missed a delay planned later and were unloaded three hours before a delayed flight landed
        (TTQ-QA-BAGS-BEFORE-DELAYED-ARRIVAL)."""
        late = lambda s: timedelta(minutes=getattr(s, "delay_minutes", 0) or 0)
        for i, bag, legs in self._bag_tail:
            for s in legs:
                self._brock(s.dep_utc + late(s) - timedelta(minutes=35), "BagLoadedOnAircraftDeclaration", i, bag, s, {"ContainerName": "AKE12345AC"}, "bag_loaded", "day_of_flight", "surround")
                self._brock(s.arr_utc + late(s) + timedelta(minutes=12), "BagUnloadedEvent", i, bag, s, {}, "bag_unloaded", "post_flight", "surround")
            last = legs[-1]
            self._brock(last.arr_utc + late(last) + timedelta(minutes=25), "BagDeliveredToCarouselDeclaration", i, bag, last, {"CarouselFriendlyName": "Carousel 4", "StationCode": last.destination}, "bag_delivered", "post_flight", "surround")

    def step_bag_mishandled(self, at, params, phase, surround):
        k = params.get("segment", len(self.plan.segments))
        seg = self.seg(k)
        for i in self._each_passenger(params):
            for bag in self.bags.get(i, []):
                self._brock(at, "BagMishandledDeclaration", i, bag, seg, {"MishandledType": params.get("type", "Delayed"), "FaultStation": seg.origin, "StationCode": seg.destination}, "bag_mishandled", phase)
                self._brock(at + timedelta(minutes=20), "BagDelayedBagRecordCreated", i, bag, seg, {"StationCode": seg.destination, "ForwardFlightRoute": f"{seg.origin}-{seg.destination}"}, "bag_mishandled", phase, "surround")
                self._brock(at + timedelta(hours=26), "BagDelayedBagDeliveredEvent", i, bag, seg, {"StationCode": seg.destination}, "bag_mishandled", "post_flight", "surround")
            if not self.bags.get(i):
                self.notes.add(f"bag_mishandled: passenger {i} checked no bag")

    # ---- FDM
    def _fdm(self, seg, at, event, phase, extra=None, origin="step"):
        extra = extra or {}
        self._fdm_done.add((event, seg.k))
        # The leg as the EAI-FDM XML lands in JSON (`_text`, `_attributes`); both engines read the leg's own
        # lastUpdate.timestamp as the update time of what the message reports.
        leg = {"_attributes": {"modified": "UPD"}, "state": {"_text": "SKD", "_attributes": {"modified": "UPD"}},
               "schedule": {"serviceType": {"_text": "J"}, "departureAirport": {"_text": seg.origin}, "arrivalAirport": {"_text": seg.destination},
                            "departure": {"_text": iso_utc(seg.dep_utc)}, "arrival": {"_text": iso_utc(seg.arr_utc)}},
               "aircraft": {"aircraftSubtype": {"_text": seg.aircraft}, "registration": {"_text": "C-FQAA"}, "aircraftOwner": {"_text": seg.op_carrier}},
               "lastUpdate": {"timestamp": {"_text": iso_utc(at)}}}
        actuals = {}
        if event == "flight_scheduled":
            leg["_attributes"]["modified"] = "NEW"
            leg["state"]["_attributes"]["modified"] = "NEW"
        elif event == "departure_gate":
            leg["depGate"] = {"_text": extra.get("gate", "A12"), "_attributes": {"modified": "NEW"}}
        elif event == "departure_delay":
            minutes = extra.get("minutes", 45)
            leg["state"]["_text"] = "ETD"
            est = seg.dep_utc + timedelta(minutes=minutes)
            leg["estimatedTimeDeparture"] = {"_text": iso_utc(est), "_attributes": {"modified": "UPD"}}
            leg["estimatedTimeArrival"] = {"_text": iso_utc(seg.arr_utc + timedelta(minutes=minutes)), "_attributes": {"modified": "UPD"}}
            actuals["delay"] = [{"modified": "NEW", "delayCode": str(extra.get("code", "93")), "delayTime": str(minutes)}]
        elif event == "flight_departed":
            leg["state"]["_text"] = "DEP"
            off = extra.get("offblockTime") or iso_utc(seg.dep_utc + timedelta(minutes=extra.get("minutes", 4)))
            actuals["offblockTime"] = {"_text": off, "_attributes": {"modified": "NEW"}}
            actuals["airborneTime"] = {"_text": iso_utc(parse_utc(off) + timedelta(minutes=14)), "_attributes": {"modified": "NEW"}}
        elif event == "flight_arrived":
            leg["state"]["_text"] = "ARR"
            on = extra.get("onblockTime") or iso_utc(seg.arr_utc + timedelta(minutes=extra.get("minutes", 2)))
            actuals["landingTime"] = {"_text": iso_utc(parse_utc(on) - timedelta(minutes=8)), "_attributes": {"modified": "NEW"}}
            actuals["onblockTime"] = {"_text": on, "_attributes": {"modified": "NEW"}}
        elif event == "flight_cancelled":
            leg["_attributes"]["modified"] = "CNL"
            leg["state"]["_text"] = "CNL"
            leg["changeReason"] = {"_text": extra.get("changeReason", "WX")}
            actuals["cancel"] = [{"modified": "NEW", "legCancelCodePrimary": str(extra.get("code", "WX"))}]
        elif event == "flight_diverted":
            leg["state"]["_text"] = "DIV"
            leg["diversionAirport"] = {"_text": extra.get("airport", "YOW")}
            leg["changeReason"] = {"_text": extra.get("changeReason", "WX")}
            leg["estimatedTimeArrival"] = {"_text": iso_utc(seg.arr_utc + timedelta(minutes=extra.get("minutes", 120))), "_attributes": {"modified": "UPD"}}
        elif event == "return_to_ramp":
            leg["state"]["_text"] = "RTR"
            leg["returnToRampTime"] = {"_text": iso_utc(at)}
            leg["changeReason"] = {"_text": extra.get("changeReason", "TD")}
        if actuals:
            leg["actuals"] = actuals
        obj = {"created": iso_utc(at), "message": {"flightDetail": {"identifier": {"flight": {"fnCarrier": {"_text": seg.op_carrier}, "fnNumber": {"_text": seg.op_number}},
                                                                                   "dayOfOrigin": {"_text": seg.dep_date}}, "legs": {"leg": [leg]}}}}
        self.add("FDM", at, obj, event, phase, origin)

    def step_flight_scheduled(self, at, params, phase, surround):
        self._fdm(self.seg(params.get("segment", 1)), at, "flight_scheduled", phase, params)

    def step_departure_gate(self, at, params, phase, surround):
        self._fdm(self.seg(params.get("segment", 1)), at, "departure_gate", phase, params)

    def step_departure_delay(self, at, params, phase, surround):
        seg = self.seg(params.get("segment", 1))
        self._fdm(seg, at, "departure_delay", phase, params)
        seg.delay_minutes = params.get("minutes", 45)

    def step_flight_departed(self, at, params, phase, surround):
        self._fdm(self.seg(params.get("segment", 1)), at, "flight_departed", phase, {"offblockTime": iso_utc(at), **params})

    def step_flight_arrived(self, at, params, phase, surround):
        self._fdm(self.seg(params.get("segment", 1)), at, "flight_arrived", phase, {"onblockTime": iso_utc(at), **params})

    def step_flight_cancelled(self, at, params, phase, surround):
        self._fdm(self.seg(params.get("segment", 1)), at, "flight_cancelled", phase, params)

    def step_flight_diverted(self, at, params, phase, surround):
        self._fdm(self.seg(params.get("segment", 1)), at, "flight_diverted", phase, params)

    def step_return_to_ramp(self, at, params, phase, surround):
        self._fdm(self.seg(params.get("segment", 1)), at, "return_to_ramp", phase, params)

    def _surround_flight_ops(self, touched):
        """Every flown segment gets its operational stream unless the plan already placed those events."""
        # A flight is told apart by its segment (k), not its number: a rebooking can move AC506 12:45 to AC506 10:45 the same day, and
        # the replacement then needs its own stream. The seed's own FDM messages carry no k, so they match by number.
        seeded = {(m["family"], m["obj"]["message"]["flightDetail"]["identifier"]["flight"]["fnNumber"]["_text"]) for m in self.messages
                  if m["prodTopic"] == TOPIC["FDM"] and "message" in m["obj"] and m["origin"] == "seed"}
        has = lambda event, seg: (event, seg.k) in self._fdm_done or (event, seg.op_number) in seeded
        for seg in self.plan.segments:
            if seg.status == "TK" or getattr(seg, "voluntary", False):  # a flight the customer left is not this booking's
                continue
            cancelled = has("flight_cancelled", seg)
            delay = timedelta(minutes=getattr(seg, "delay_minutes", 0))
            plan = [("flight_scheduled", seg.dep_utc - timedelta(days=7), {})]
            if not cancelled:
                plan += [("departure_gate", seg.dep_utc - timedelta(minutes=95), {}),
                         ("flight_departed", seg.dep_utc + delay + timedelta(minutes=4), {"offblockTime": iso_utc(seg.dep_utc + delay + timedelta(minutes=4))}),
                         ("flight_arrived", seg.arr_utc + delay + timedelta(minutes=2), {"onblockTime": iso_utc(seg.arr_utc + delay + timedelta(minutes=2))})]
            for event, at, extra in plan:
                if not has(event, seg):
                    self._fdm(seg, at, event, self._phase_of(at), extra, origin="surround")

    # ---- notifications, vouchers, profile
    def _aacc_flight(self, seg, dep_local, arr_local, status):
        d, a = datetime.fromisoformat(dep_local), datetime.fromisoformat(arr_local)
        return {"elementProperties": {"name": "ST", "type": "ST", "identifier": seg.k}, "flightInformation": {
            "departureDate": int(d.strftime("%d%m%y")), "departureTime": int(d.strftime("%H%M")), "arrivalDate": int(a.strftime("%d%m%y")), "arrivalTime": int(a.strftime("%H%M")),
            "boardPoint": seg.origin, "offPoint": seg.destination, "airlineCode": seg.carrier, "flightNumber": int(seg.number), "bookingClass": seg.booking_class,
            "segmentStatusCode": status}}

    def _notification(self, at, action, phase, previous=None, origin="step"):
        x = self.exemplar("PassengerNotification") or {"PassengerNotification": {}}
        n = x["PassengerNotification"]
        n["processingData"] = {**(n.get("processingData") or {}), "processingDateTime": {"date": at.strftime("%d%m%Y"), "time": at.strftime("%H%M%S")}, "pNROwnerGDS": "AC", "pNRNumberInParty": len(self.plan.passengers)}
        n["triggerData"] = {"actionCode": action, "scenario": (n.get("triggerData") or {}).get("scenario", "EML1")}
        n["recordLocator"] = [{"recordNumber": self.locator}]
        first, last = self.passenger_name(0)
        n["activeData"] = {**(n.get("activeData") or {}), "travellerInfo": {"elementProperties": {"name": "NM", "type": "PT", "identifier": 1},
                                                                           "travellerInformation": {"surname": last, "givenName": first, "type": self.plan.passengers[0].get("type", "ADT")}},
                           "flightInfo": [self._aacc_flight(s, s.dep_local, s.arr_local, s.status) for s in self.plan.segments if s.status != "XX"]}
        for key in ("impactedElementsNotificationContact", "impactedElementsFrequentFlyer", "impactedElementsTicket", "impactedServiceElements"):
            n["activeData"].pop(key, None)
        if previous:
            n["previousData"] = {"flightInfo": [self._aacc_flight(s, dep, arr, st) for s, dep, arr, st in previous]}
        else:
            n.pop("previousData", None)
        self.add("AACC", at, x, "notification", phase, origin)

    def step_notification(self, at, params, phase, surround):
        self._notification(at, params.get("actionCode", "DY"), phase)

    def step_meal_voucher(self, at, params, phase, surround):
        seg = self.seg(params.get("segment", 1))
        for i in self._each_passenger(params):
            first, last = self.passenger_name(i)
            x = self.exemplar("RedemptionPassDetails") or {}
            vid = f"{self.rng.randrange(10**6, 10**7)}-{self.rng.randrange(100, 999)}"
            x.update(event_type="meal_voucher_creation", voucher_id=vid, airportCode=seg.origin, currency=params.get("currency", "CAD"), voucherValue=params.get("value", 15),
                     issuance_date=at.strftime("%Y-%m-%dT%H:%M:%S.000Z"), authorization_date=at.strftime("%Y-%m-%dT%H:%M:%S.000Z"), causingAirlineCode=seg.op_carrier,
                     causingFlightNumber=seg.op_number, causingFlightDate=seg.dep_date, causingFlightDateTimeLocal=seg.dep_local.replace("T", " "), causingFlightDateTimeUTC=iso_utc(seg.dep_utc),
                     issuer_sign="SYSTEM", authorizer_sign="SYSTEM", issuer_station="SYSTEM")
            x["RedemptionPassDetails"] = {**(x.get("RedemptionPassDetails") or {}), "PNR": self.locator, "airlineCode": seg.op_carrier, "first_name": first, "last_name": last,
                                          "flightNumber": seg.op_number, "flightDate": seg.dep_date, "origin": seg.origin, "destination": seg.destination,
                                          "ticket_number": self.ticket_numbers.get(i, ""), "expiry_date": (at + timedelta(days=3)).strftime("%Y-%m-%dT%H:%M:%S.000Z"),
                                          "sk_element": f"SK MLV {seg.op_carrier}{seg.op_number}/{datetime.fromisoformat(seg.dep_local).strftime('%d%b').upper()} MEAL 1 X CAD{params.get('value', 15)}.00"}
            self.add("ICOUPON", at + timedelta(seconds=i), x, "meal_voucher", phase)

    def step_hotel_voucher(self, at, params, phase, surround):
        seg = self.seg(params.get("segment", 1))
        for i in self._each_passenger(params):
            first, last = self.passenger_name(i)
            x = self.exemplar("event:hotel_voucher_accepted") or self.exemplar("event:hotel_voucher_offered") or {"data": {"passenger": {}, "voucher": {"hotel_voucher": {}}}}
            x.update(event_type=params.get("status", "hotel_voucher_accepted"), message_type="voucher", message_timestamp=f"{at.timestamp():.6f}", id=trigger_id("stormx", self.locator, i, iso_utc(at)))
            vid = "-".join(["".join(self.rng.choice("0123456789abcdef") for _ in range(n)) for n in (8, 4, 4, 4, 12)])
            p = x.setdefault("data", {}).setdefault("passenger", {})
            p.update(pax_record_locator=self.locator, pax_record_locator_group=f"{self.locator}-RNSDP-AUTO", first_name=first, last_name=last, voucher_id=vid,
                     flight_number=seg.op_number, port_origin=seg.origin, port_accommodation=seg.destination if params.get("at", "destination") == "destination" else seg.origin,
                     scheduled_depart=datetime.fromisoformat(seg.dep_local).strftime("%Y-%m-%d %H:%M"), disrupt_depart=(datetime.fromisoformat(seg.dep_local) + timedelta(hours=params.get("delayHours", 10))).strftime("%Y-%m-%d %H:%M"),
                     disrupt_type=params.get("reason", "WEATHER"), hotel_accommodation=True, hotel_accommodation_status="accepted", number_of_nights=params.get("nights", 1),
                     create_date=at.strftime("%Y-%m-%d %H:%M:%S.000000"), modified_date=at.strftime("%Y-%m-%d %H:%M:%S.000000"), emails=[], phone_numbers=[], notifications=[],
                     pnr_create_date=self.plan.created.strftime("%Y-%m-%d"), context_id=f"{self.traveler_id(i)}-AUTO", airline_pay=True, life_stage="adult", ticket_level="economy")
            h = x["data"].setdefault("voucher", {}).setdefault("hotel_voucher", {})
            h.update(airport_code=p["port_accommodation"], check_in_date=at.strftime("%Y-%m-%d"), check_out_date=(at + timedelta(days=p["number_of_nights"])).strftime("%Y-%m-%d"),
                     hotel_name=h.get("hotel_name") or "SYNTHETIC AIRPORT HOTEL", address1=h.get("address1") or "1 SYNTHETIC ST")
            x.pop("rm_element", None)
            self.add("STORMX", at + timedelta(seconds=i), x, "hotel_voucher", phase)

    def step_profile_link(self, at, params, phase, surround):
        rows = []
        for i in self._each_passenger(params):
            cpid = self.cpids.setdefault(i, "ZZCPID" + "".join(self.rng.choice("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") for _ in range(6)))
            rows.append({"cpid": cpid, "passengerId": self.traveler_id(i)})
        mid = hashlib.sha256(f"{self.locator}|profile|{iso_utc(at)}".encode()).hexdigest()
        self.add("CUSTOMER_PROFILE_CPID", at, {"version": "1.0", "id": mid, "messageId": mid, "messageType": "passenger.profile.link",
                                               "timestamp": at.strftime("%Y-%m-%dT%H:%M:%S.000Z"), "metadata": {"batchSize": len(rows)}, "payload": rows}, "profile_link", phase)

    # -- tester slots: where the tester's own values may go at publish (PNR feed only)
    def _tester_slots(self):
        slots = []
        for i, p in enumerate(self.plan.passengers):
            fields = {k: TESTER.search(str(v)).group(1) for k, v in p.items() if isinstance(v, str) and TESTER.search(v)}
            if not fields:
                continue
            tid = self.traveler_id(i)
            for mi, m in enumerate(self.messages):
                pnr = m["obj"].get("processedPnr") if isinstance(m["obj"], dict) else None
                if not pnr:
                    continue
                for ti, t in enumerate(pnr.get("travelers", [])):
                    if t.get("id") != tid:
                        continue
                    base = f"/processedPnr/travelers/{ti}"
                    for ni, _ in enumerate(t.get("names", [])):
                        for k in ("firstName", "lastName"):
                            if k in fields:
                                slots.append({"message": mi, "pointer": f"{base}/names/{ni}/{k}", "placeholder": fields[k]})
                    for di, doc in enumerate(t.get("identityDocuments", [])):
                        d = doc.get("document") or {}
                        if "dateOfBirth" in fields and "birthDate" in d:
                            slots.append({"message": mi, "pointer": f"{base}/identityDocuments/{di}/document/birthDate", "placeholder": fields["dateOfBirth"]})
                        if "document" in fields and "number" in d:
                            slots.append({"message": mi, "pointer": f"{base}/identityDocuments/{di}/document/number", "placeholder": fields["document"]})
                        for k in ("firstName", "lastName"):
                            if k in fields and k in (d.get("name") or {}):
                                slots.append({"message": mi, "pointer": f"{base}/identityDocuments/{di}/document/name/{k}", "placeholder": fields[k]})
                for li, loy in enumerate(pnr.get("loyaltyRequests", [])):
                    if "loyaltyNumber" in fields and any(t.get("id") == tid for t in (loy.get("travelers") or {}).get("collection", [])) and "number" in (loy.get("membership") or {}):
                        slots.append({"message": mi, "pointer": f"/processedPnr/loyaltyRequests/{li}/membership/number", "placeholder": fields["loyaltyNumber"]})
                for ci, c in enumerate(pnr.get("contacts", [])):
                    if not any(t.get("id") == tid for t in (c.get("travelers") or {}).get("collection", [])):
                        continue
                    if "email" in fields and "address" in (c.get("email") or {}):
                        slots.append({"message": mi, "pointer": f"/processedPnr/contacts/{ci}/email/address", "placeholder": fields["email"]})
                    if "phone" in fields and "number" in (c.get("phone") or {}):
                        slots.append({"message": mi, "pointer": f"/processedPnr/contacts/{ci}/phone/number", "placeholder": fields["phone"]})
        return slots

    def _align_pnr_id_date(self):
        """The PNR id is the locator and the booking's creation date (TripTracer keys the owner by it). Plain dates move
        with the departure alignment only, the creation also with the plan's lead time, so the id named another day
        than the creation whenever the two lead times differed (three of the 2026-10-14 runs; TTQ-QA-PNR-ID-DATE)."""
        wanted = f"{self.locator}-{self.plan.created.strftime('%Y-%m-%d')}"
        old = self.pnr_id
        if not old or old == wanted or not old.startswith(self.locator + "-"):
            return
        for m in self.messages:
            if old in m["value"]:
                m["value"] = m["value"].replace(old, wanted)
                m["obj"] = json.loads(m["value"])
        self.pnr_id = wanted
        self._pt_ids = [i.replace(old, wanted) for i in self._pt_ids]
        self._st_ids = {k: v.replace(old, wanted) for k, v in self._st_ids.items()}

    def drop_after(self, now):
        """A booking has no events after now (README section 6): events dated after `now` (ISO UTC) are not built. Surround
        events of a flight next week (gate, off-blocks, on-blocks) were published dated in the future
        (TTQ-QA-FUTURE-EVENTS-PUBLISHED). Returns how many were dropped."""
        future = [m for m in self.messages if m["ts"] > now]
        if future:
            self.messages = [m for m in self.messages if m["ts"] <= now]
            self.notes.add(f"{len(future)} events dated after now were not built (a booking has no events after now): "
                           f"{sorted({m['family'] for m in future})}")
        return len(future)

    # -- summaries
    def summary(self):
        by_phase, by_family = {}, {}
        for m in self.messages:
            by_phase[m["phase"]] = by_phase.get(m["phase"], 0) + 1
            by_family[m["family"]] = by_family.get(m["family"], 0) + 1
        return {"events": len(self.messages), "byPhase": by_phase, "byFamily": by_family, "locators": [self.locator],
                "seed": self.seed_stats, "notes": sorted(self.notes | self.rw.notes), "testerSlots": len(self.tester_slots)}

    def timeline(self):
        """The built timeline for review: types and offsets from first departure, ZZ identities, no tester values
        (none are in the build; the slots are named by placeholder only)."""
        dep = self.plan.segments[0].dep_utc
        rows = []
        for m in self.messages:
            at = parse_utc(m["ts"])
            rows.append({"at": m["ts"], "offsetMinutes": int((at - dep).total_seconds() // 60), "phase": m["phase"], "family": m["family"],
                         "feed": feed_of(m["prodTopic"], m["obj"]), "kind": kind_of(m["obj"]), "origin": m["origin"]})
        return {"locator": self.locator, "pnrId": self.pnr_id, "passengers": [{"name": f"{f} {l}", "tester": bool(TESTER.search(json.dumps(self.plan.passengers[i])))}
                                                                            for i, (f, l) in enumerate(self.rw.stand_ins[: len(self.plan.passengers)])],
                "itinerary": [{"flight": f"{s.carrier}{s.number}", "from": s.origin, "to": s.destination, "departs": s.dep_local, "status": s.status} for s in self.plan.segments],
                "tickets": sorted(set(self.ticket_numbers.values())), "events": rows,
                "testerSlots": sorted({s["placeholder"] for s in self.tester_slots})}


class Exemplars:
    """Real messages of each kind from the anonymised pool, for the builders of events the seed lacks."""

    def __init__(self, pool):
        self.pool = Path(pool) if pool else None
        self.cache = {}
        self.scanned = False

    def get(self, kind):
        if kind in self.cache:
            return copy.deepcopy(self.cache[kind])
        if not self.scanned:
            self.scan(kind)
        return copy.deepcopy(self.cache.get(kind))

    def scan(self, want=None):
        """Walk the pool once, keeping the first message of each kind (a few seconds for 400 bookings)."""
        self.scanned = True
        if not self.pool or not (self.pool / "bookings").exists():
            return
        for f in sorted((self.pool / "bookings").iterdir()):
            if not f.name.endswith((".jsonl.zst", ".jsonl")):
                continue
            try:
                msgs, _ = read_seed(f.name.split(".")[0], self.pool)
            except Exception:  # noqa: BLE001
                continue
            for m in msgs:
                k = kind_of(m["obj"])
                if k not in self.cache:
                    self.cache[k] = m["obj"]
            if want and want in self.cache and len(self.cache) > 20:
                return


def pool_index(pool, limit=None):
    """Structural summaries of the pool's bookings for /tools/pool: feeds, segments, passengers, versions, lead days."""
    out = []
    pool = Path(pool)
    tags = json.loads((pool / "tags.json").read_text()) if (pool / "tags.json").exists() else {}
    by_loc = {}
    for t, locs in tags.items():
        for l in locs:
            by_loc.setdefault(l, []).append(t)
    for f in sorted((pool / "bookings").iterdir()):
        if not f.name.endswith((".jsonl.zst", ".jsonl")):
            continue
        loc = f.name.split(".")[0]
        try:
            msgs, bad = read_seed(loc, pool)
            seed = Seed(msgs)
        except Exception as e:  # noqa: BLE001
            out.append({"ref": loc, "error": str(e)[:120]})
            continue
        feeds = {}
        for m in msgs:
            fd = feed_of(m["prodTopic"], m["obj"])
            feeds[fd] = feeds.get(fd, 0) + 1
        try:
            lead = (datetime.fromisoformat(seed.first_departure_date()) - parse_utc(seed.creation).replace(tzinfo=None)).days
        except Exception:  # noqa: BLE001
            lead = None
        # Days from the booking's creation to its first retained PNR version: a seed whose history starts late cannot
        # carry a plan's early steps (the build says so), so the agent picks by it.
        try:
            first_pnr = min(parse_utc(m["ts"]) for m in msgs if "processedPnr" in m["obj"] and m["ts"])
            gap = max(0, (first_pnr - parse_utc(seed.creation)).days)
        except Exception:  # noqa: BLE001
            gap = None
        out.append({"ref": loc, "tags": by_loc.get(loc, []), "feeds": feeds, "segments": len(seed.segments), "passengers": len(seed.travelers),
                    "pnrVersions": len(seed.pnr_messages), "leadDays": lead, "historyGapDays": gap, "events": len(msgs), "badJson": bad,
                    "route": [f"{s['origin']}-{s['destination']}" for s in seed.segments], "carriers": sorted({s["carrier"] for s in seed.segments})})
        if limit and len(out) >= limit:
            break
    return out


def step_params():
    """{family: [param names]} as the builder reads them: each step method's own params.get / params[...] and those of
    the helpers it hands params to. Derived from the code so the playbook never drifts from the builder; the agent
    sent `protection` for a cancellation's replacement flight and the builder silently used its default (2026-10-14,
    TTQ-QA-STEP-PARAMS-UNSTATED)."""
    import inspect
    keys = lambda src: set(re.findall(r'params\.get\("(\w+)"', src)) | set(re.findall(r'params\["(\w+)"\]', src))
    out = {}
    for name, fn in inspect.getmembers(Build, inspect.isfunction):
        if not name.startswith("step_"):
            continue
        src = inspect.getsource(fn)
        found = keys(src)
        for helper in set(re.findall(r"self\.(_\w+)\([^)]*params", src)):
            if hasattr(Build, helper):
                # a helper may name it `extra` (_fdm)
                found |= keys(inspect.getsource(getattr(Build, helper)).replace("extra.get(", "params.get("))
        out[name[len("step_"):]] = sorted(found)
    return out


_known_params = functools.lru_cache(maxsize=1)(step_params)
