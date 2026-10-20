"""Render the raw feed payloads for one case: PNR record, ticket record(s), FDM SKD + delay XML.

Shapes are the ones proven to cascade in INT (dataset fd-int-v3, e.g. A33QEC): an Amadeus-style
processedPnr v1 whose only event is `/ticketingReferences CREATED`, a processedTicket 3.5.0
record with latestEvent 130, and LSB FDM flightDetail envelopes (SKD create, ETD delay).
All ids derive from the pnr_id: <pnr_id>-PT-n (passenger), -ST-n (segment), -OT-23 (contact).
"""
from __future__ import annotations

import copy
import json
import re
from dataclasses import dataclass, field
from datetime import date, datetime, timedelta, timezone
from pathlib import Path

from .catalog import SeedCase
from .identity import Identity

_MON = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]


@dataclass
class Rendered:
    pnr_id: str
    locator: str
    booking_date: str
    pnr_versions: list[dict]          # v0 (creation) then v1 (ticketing added), published in order
    tickets: list[dict]
    fdm_skd: list[tuple[str, str]] = field(default_factory=list)    # (leg_id, xml)
    fdm_delay: list[tuple[str, str]] = field(default_factory=list)  # (leg_id, xml)
    meta: dict = field(default_factory=dict)


# ---- helpers ----------------------------------------------------------------

def _shift(s: str, days: int, minutes: int = 0) -> str:
    """Shift an ISO date or datetime string, preserving its format.

    `minutes` exists for the claim-submission window: whether a claim is inside the 72-hour (AC /
    Star) or 168-hour (other airline) window is measured from the last segment's ARRIVAL to now, in
    hours -- a whole-day shift cannot place a booking 36 hours back. A date string has no clock, so
    it takes the day part only.
    """
    if not s or not (days or minutes):
        return s
    if len(s) == 10:
        return (date.fromisoformat(s) + timedelta(days=days)).isoformat()
    z = s.endswith("Z")
    dt = datetime.fromisoformat(s[:-1] if z else s) + timedelta(days=days, minutes=minutes)
    out = dt.isoformat(timespec="seconds")
    return out + "Z" if z else out


def _z(s: str) -> str:
    return s if s.endswith("Z") else s + "Z"


def is_group(case: SeedCase, pax: list) -> bool:
    """Is this booking a group? One definition, read by the PNR and by meta.

    A group is stated by the fixture, tagged on the case, or implied by size -- Altea treats a
    booking of ten or more as a group.
    """
    sc = case.scenario
    return bool(sc.get("group") or "group" in " ".join(case.tags).lower() or len(pax) > 9)


def bound_of(seg: dict) -> int:
    """Which journey a segment belongs to. A fixture segment states it; everything else is one trip."""
    try:
        return max(1, int(seg.get("bound") or 1))
    except (TypeError, ValueError):
        return 1


def bounds_of(segs: list[dict]) -> list[tuple[int, list[int]]]:
    """[(bound number, [segment indexes])], in bound order. One entry for an ordinary one-way."""
    groups: dict[int, list[int]] = {}
    for n, s in enumerate(segs):
        groups.setdefault(bound_of(s), []).append(n)
    return sorted(groups.items())


def _docs_text(dob: str, gender: str, last: str, first: str) -> str:
    d = date.fromisoformat(dob)
    g = {"MALE": "M", "FEMALE": "F"}.get(gender.upper(), "U")
    return f"////{d.day:02d}{_MON[d.month - 1]}{d.year % 100:02d}/{g}//{last}/{first}"


def _plus_minutes(iso_z: str, minutes: int) -> str:
    dt = datetime.fromisoformat(iso_z.replace("Z", "+00:00")) + timedelta(minutes=minutes)
    return dt.strftime("%Y-%m-%dT%H:%M:%SZ")


# ---- PNR --------------------------------------------------------------------

def _pnr_versions(case: SeedCase, ident: Identity, segs: list[dict], pax: list[dict], email: str, phone: str,
                  issuance_date: str, fare: dict) -> list[dict]:
    pid = ident.pnr_id
    created = f"{ident.booking_date}T06:00:00Z"
    pos = case.scenario.get("point_of_sale", {})
    office = {"id": pos.get("office_id", "YULAC010V"), "systemCode": pos.get("system_code", "1A"),
              "iataNumber": pos.get("iata_number", "01424012"), "agentType": pos.get("agent_type", "AIRLINE")}
    contact_id = f"{pid}-OT-23"

    travelers, tkt_refs = [], []
    for i, p in enumerate(pax):
        tid = f"{pid}-PT-{i + 1}"
        gender = (p.get("gender") or "UNKNOWN").upper()
        name = {"firstName": p["first_name"], "lastName": p["last_name"]}
        trav = {"type": "stakeholder", "id": tid, "names": [name], "gender": gender,
                "passengerTypeCode": p.get("type", "ADT"),
                "contacts": {"collection": [{"type": "contact", "id": contact_id, "ref": "processedPnr.contacts"}]}}
        if p.get("date_of_birth"):
            trav["identityDocuments"] = [{
                "code": "DOCS", "subType": "SPECIAL_SERVICE_REQUEST", "status": "HK",
                "document": {"gender": gender, "birthDate": p["date_of_birth"], "name": name,
                             "countryOfResidence": p.get("country_of_residence", "CA")},
                "text": _docs_text(p["date_of_birth"], gender, p["last_name"], p["first_name"])}]
            trav["birthDate"] = p["date_of_birth"]
            trav["dateOfBirth"] = p["date_of_birth"]   # the spelling a real Altea traveler uses
        travelers.append(trav)

        coupons = []
        for n, s in enumerate(segs):
            # `product` ties the coupon to its air segment. A real accepted INT booking carries it
            # and nothing else links ticket to segment, which is what "missing eticket or air
            # segments" is really complaining about -- `soldSegment` alone describes the flight but
            # never references the product, so the consumer cannot pair them. Both are sent: trip
            # tracer reads soldSegment, the profile consumer reads product.
            coupons.append({"number": str(n + 1), "status": "O", "fareBasisCode": "YFLEX",
                            "sequenceNumber": n + 1,
                            "product": {"type": "product", "id": f"{pid}-ST-{n + 1}",
                                        "ref": "processedPnr.products"},
                            "soldSegment": {"flightNumber": str(s["flight_number"]),
                                            "departure": {"iataCode": s["origin"]},
                                            "arrival": {"iataCode": s["destination"]},
                                            "carrierCode": s["carrier"]}})
        route = " ".join(f"{s['origin']} {s['carrier']}" for s in segs)
        fare_calc = f"{route} {segs[-1]['destination']} {fare['amount']}"
        # The customer-profile PNR consumer decides a booking is ticketed by looking for an
        # ETICKET document, and drops the whole message otherwise ("skipping message: missing
        # eticket or air segments", observed on every seeded PNR). Trip-tracer never needed these,
        # so they were absent and no seeded booking ever produced a customer profile. Shape and
        # field names are copied from a real accepted INT message, not invented.
        first_seg_ref = {"type": "product", "id": f"{pid}-ST-1", "ref": "processedPnr.products"}
        tkt_refs.append({"id": f"{pid}-OT-{50 + i}", "type": "ticketing-reference",
                         "referenceTypeCode": "FA", "isInfant": p.get("type", "ADT") == "INF",
                         "traveler": {"type": "stakeholder", "id": tid, "ref": "processedPnr.travelers"},
                         "products": {"collection": [first_seg_ref]},
                         "documents": [{
            "documentType": "ETICKET",
            "quotationTotalFare": {"amount": str(fare["amount"]), "currency": fare["currency"]},
            "issuingOriginatorOffice": {"id": office["id"], "iataNumber": office["iataNumber"],
                                        "systemCode": office["systemCode"]},
            "primaryDocumentNumber": ident.tickets[i], "issuanceLocalDate": issuance_date, "status": "ISSUED",
            "fareCalculation": fare_calc, "fareCalculationMode": "AUTO", "endorsementFreeFlow": "NONREF",
            "displayedFormsOfPayment": [{"method": "CREDIT_CARD", "fopIndicator": "CC",
                                         "paymentCard": {"vendorCode": "VI"},
                                         "authorization": {"approvalCode": "123456"}}],
            "coupons": coupons,
            "issuingOriginator": {"author": {"carrier": {"IATANumber": office["iataNumber"]},
                                             "deliveringSystem": {"systemIdentification": office["systemCode"]},
                                             "officeId": office["id"]}}}]})

    pay_methods = [{"type": "payment-method", "id": f"{pid}-OT-{62 + i}", "isInfant": False,
                    "formsOfPayment": [{"code": "na", "fopIndicator": "OLD", "freeText": "CCVI+AGTN"},
                                       {"code": "STD", "fopIndicator": "NEW",
                                        "freeText": f"AGTN{office['iataNumber']}/AC/01"}],
                    "travelers": {"collection": [{"type": "stakeholder", "id": t["id"],
                                                  "ref": "processedPnr.travelers"}]}}
                   for i, t in enumerate(travelers)]
    fare_elements = [{"type": "fare-element", "code": "FE", "id": f"{pid}-OT-66",
                      "text": f"PAX {fare['currency']}{fare['amount']} NONREF - AC ONLY -BG:AC"},
                     {"type": "fare-element", "code": "FZ", "id": f"{pid}-OT-20",
                      "text": f"RA{office['iataNumber']}"}]

    # Products, in the order a real Altea record carries them: the SSRs, then the air segments.
    seg_ids = [f"{pid}-ST-{n + 1}" for n in range(len(segs))]
    bounds = bounds_of(segs)
    seg_refs = [{"type": "product", "id": sid, "ref": "processedPnr.products"} for sid in seg_ids]
    trav_refs = [{"type": "stakeholder", "id": t["id"], "ref": "processedPnr.travelers"} for t in travelers]

    # FOID service products -> trip-tracer's special_service_request rows, linked to passenger + segment.
    ssr_products = []
    for i, t in enumerate(travelers):
        foid = ident.tickets[i][-5:] if i < len(ident.tickets) else f"{i + 1:05d}"
        ssr_products.append({
            "type": "product", "subType": "SERVICE", "id": f"{pid}-OT-{11 + i}",
            "service": {"code": "FOID", "subType": "SPECIAL_SERVICE_REQUEST",
                        "serviceProvider": {"code": segs[0]["carrier"]}, "status": "HK", "nip": 1,
                        "text": f"IDAB{foid}"},
            "products": {"collection": [seg_refs[0]]},
            "travelers": {"collection": [{"type": "stakeholder", "id": t["id"], "ref": "processedPnr.travelers"}]}})
    # FQTV service products -> the loyalty identity. A booking carries the passenger's Aeroplan
    # number as an FQTV SSR whose text is "AC-<number>"; the customer-profile-pnr consumer reads it
    # off the ALTEA-PNRDATA feed and writes PNRBooking.LoyaltyMembershipId, which is the first thing
    # the wallet check looks at. Without one, a seeded passenger has no loyalty identity at all and
    # walletOffered can only ever be false.
    for i, t in enumerate(travelers):
        number = str(pax[i].get("loyalty_number") or "").strip()
        if not number:
            continue
        ssr_products.append({
            "type": "product", "subType": "SERVICE", "id": f"{pid}-OT-{31 + i}",
            "service": {"code": "FQTV", "subType": "SPECIAL_SERVICE_REQUEST",
                        "serviceProvider": {"code": "AC"}, "status": "HK", "nip": 1,
                        "membership": {"number": number, "programCode": "AC"},
                        "text": f"AC-{number}"},
            "products": {"collection": [seg_refs[0]]},
            "travelers": {"collection": [{"type": "stakeholder", "id": t["id"], "ref": "processedPnr.travelers"}]}})
    # GRPF -> the group marker. The rule engine decides a booking is a group from the SSR codes in
    # its `group_ssr_codes_lookup` (GRPF "Group Fare", GPRS "Group Reservation") -- not from
    # bookingSubtype and not from the passenger count. A seeded group carried neither code, so no
    # consumer could tell it from an ordinary twelve-passenger booking. One SSR for the booking,
    # referencing every traveller, which is how a group fare is held.
    if is_group(case, pax):
        ssr_products.append({
            "type": "product", "subType": "SERVICE", "id": f"{pid}-OT-{41}",
            "service": {"code": "GRPF", "subType": "SPECIAL_SERVICE_REQUEST",
                        "serviceProvider": {"code": segs[0]["carrier"]}, "status": "HK",
                        "nip": len(travelers), "text": f"GRP{len(travelers)}"},
            "products": {"collection": [seg_refs[0]]},
            "travelers": {"collection": trav_refs}})
    ssr_refs = [{"type": "product", "id": x["id"], "ref": "processedPnr.products"} for x in ssr_products]

    air_products = []
    for n, s in enumerate(segs):
        cabin = s.get("cabin", "Y")
        air_products.append({"type": "product", "subType": "AIR", "id": seg_ids[n], "airSegment": {
            "number": str(s["flight_number"]), "carrierCode": s["carrier"],
            "departure": {"iataCode": s["origin"], "localDateTime": s["dep_local"]},
            "arrival": {"iataCode": s["destination"], "localDateTime": s["arr_local"]},
            "aircraft": {"code": s.get("aircraft", "321")},
            "class": cabin, "cabin": cabin, "cabinClass": cabin,
            # trip-tracer builds flight_segment.flight_id (CARRIER#NUMBER#DATE#ORIGIN) and the
            # operating_* columns from this block; without it the id comes out as "##<date>#<origin>".
            "operating": {"carrierCode": s["carrier"], "number": str(s["flight_number"]), "class": cabin},
            "bookingDateTime": created, "status": s.get("status", "HK"),
            "isOpenNumber": False, "isInformational": False},
            # travelers -> flight_segment.passenger_id; without it the array is empty and the bot's
            # trip_tracer_search returns a booking with no passengers and no segments.
            "travelers": {"collection": trav_refs},
            "products": {"collection": ssr_refs}})
    products = ssr_products + air_products

    login = {"numericSign": pos.get("agent_numeric_sign", "0001"), "initials": pos.get("agent_initials", "FD"),
             "dutyCode": pos.get("duty_code", "SU"), "countryCode": pos.get("agent_country", "CA"),
             "cityCode": pos.get("agent_city", office["id"][:3])}
    base = {
        "type": "pnr", "id": pid, "bookingIdentifier": ident.locator,
        "owner": {"office": office, "login": login},
        "creation": {"dateTime": created, "pointOfSale": {"office": office, "login": login},
                     "comment": case.scenario.get("creation_comment", "")},
        "lastModification": {"dateTime": created, "pointOfSale": {"office": office, "login": login},
                             "comment": case.scenario.get("last_modification_comment", "")},
        "queuingOffice": {"id": office["id"]},
        "nip": len(travelers),
        "pnrReferences": [{"systemId": office["systemCode"], "recordLocator": ident.locator}],
        "travelers": travelers,
        "products": products,
        # ONE ENTRY PER BOUND. A JOURNEY_SERVER_BOUND is what trip-tracer counts a journey by
        # (flight_segment.bound_rph), and this used to be a single entry spanning every segment --
        # so a return trip seeded as one journey, the eligibility assessment carried one bound, and
        # GenUC-08 (journey selection) could never be reached by any seeded booking.
        "flightItineraries": [{"type": "JOURNEY_SERVER_BOUND", "originIataCode": segs[ix[0]]["origin"],
                               "destinationIataCode": segs[ix[-1]]["destination"],
                               "flights": [{"flightSegment": seg_refs[i]} for i in ix]}
                              for _, ix in bounds],
        # The fixture's own contact language, defaulting to EN. It was hardcoded, so a case written
        # to test a French-language notification seeded an English contact and tested nothing the
        # English cases did not already cover.
        "contacts": [{"type": "contact", "id": contact_id, "email": {"address": email},
                      "language": case.scenario.get("contact_language", "EN"),
                      "purpose": ["NOTIFICATION"],
                      "travelers": {"collection": [{"type": "stakeholder", "id": t["id"], "ref": "processedPnr.travelers"}
                                                   for t in travelers]},
                      "phone": {"number": phone}}],
    }

    def wrap(pnr: dict, version: str, events: list[dict], trigger_suffix: str, at: str) -> dict:
        return {
            "meta": {"triggerEventLog": {"id": f"{pid}-{trigger_suffix}"}, "version": "1.13.0"},
            "processedPnr": {**pnr, "version": version},
            "events": {"recordDomain": "PNR", "recordId": pid, "originFeedTimeStamp": at, "events": events},
        }

    # v0: the booking itself. PNRCreationDetector keys on version 0 + a CREATED event at the record root.
    v0 = wrap(base, "0", [{"origin": "COMPARISON", "eventType": "CREATED", "currentPath": ""}], "CR", created)
    # v1: ticketing references attached -> TicketingReferencesDetector emits PNR_TICKETED (is_ticketed=true).
    ticketed = {**base, "lastModification": {**base["lastModification"], "dateTime": _plus_minutes(created, 1)},
                "ticketingReferences": tkt_refs, "latestEvent": {"code": "TKTREF_CREATED", "dateTimeGMT": created},
        "paymentMethods": pay_methods, "fareElements": fare_elements}
    v1 = wrap(ticketed, "1", [{"origin": "COMPARISON", "eventType": "UPDATED", "currentPath": "", "previousPath": ""},
                              {"origin": "COMPARISON", "eventType": "CREATED", "currentPath": "/ticketingReferences"}],
              "TKR", _plus_minutes(created, 1))

    # v2: an involuntary rebooking, if the fixture asks for one. A cancelled leg plus a replacement
    # to a different airport is the only way a booking can say "the customer ended up somewhere else"
    # -- a diversion is a FLIGHT landing elsewhere and comes through FDM, but a reaccommodation
    # rewrites the itinerary and comes through here. Without it the "new destination (new contract)"
    # cards seeded the trip exactly as it was sold, so nothing downstream could see a changed
    # destination and FD-APPR-ND-03 could not be reached by any seeded booking.
    rb = case.scenario.get("rebooking")
    if not rb:
        return [v0, v1]
    idx = rb.get("segment_index", len(segs) - 1)
    at = rb.get("at") or _plus_minutes(created, 2 * 24 * 60)
    reb = copy.deepcopy(ticketed)
    airs = [p for p in reb["products"] if p.get("subType") == "AIR"]
    old = airs[idx]
    old_dest = old["airSegment"]["arrival"]["iataCode"]
    # The original leg is not deleted: it stays on the record as unable/cancelled, which is what the
    # downstream "original destination vs actual destination" comparison reads.
    old["airSegment"]["status"] = rb.get("cancelled_status", "UN")
    new_id = f"{pid}-ST-{len(airs) + 1}"
    new = copy.deepcopy(old)
    new["id"] = new_id
    new["airSegment"]["status"] = "HK"
    new["airSegment"]["arrival"] = {"iataCode": rb["new_destination"],
                                    "localDateTime": rb.get("new_arr_local")
                                    or old["airSegment"]["arrival"]["localDateTime"]}
    # The replacement leg needs its OWN flight number, continuing the minted sequence
    # (ident.flight_number + n, line ~565) rather than the fixture's static one -- otherwise it
    # inherits the cancelled leg's number and trip-tracer writes two rows with the same flight_id.
    # `operating` matters as much as `number`: flight_id is built from the operating block.
    new_fn = str(ident.flight_number + len(segs))
    new["airSegment"]["number"] = new_fn
    if isinstance(new["airSegment"].get("operating"), dict):
        new["airSegment"]["operating"] = {**new["airSegment"]["operating"], "number": new_fn}
    reb["products"].append(new)
    new_ref = {"type": "product", "id": new_id, "ref": "processedPnr.products"}
    for it in reb.get("flightItineraries", []):
        if it.get("destinationIataCode") == old_dest:
            it["destinationIataCode"] = rb["new_destination"]
            it["flights"] = [*it.get("flights", []), {"flightSegment": new_ref}]
    reb["lastModification"] = {**reb["lastModification"], "dateTime": at,
                               "comment": rb.get("comment", "INVOL REACCOM")}
    reb["latestEvent"] = {"code": "SEGMENT_CHANGED", "dateTimeGMT": at}
    # The COMPARISON events are JSON-Patch paths to the ELEMENT that changed, not to its container:
    # add -> CREATED at the new index, replace -> UPDATED with currentPath and previousPath. Pointing
    # at "/products" instead of "/products/<i>" is why the first attempt published a correct v2 that
    # trip-tracer ignored: the segments stayed at last_pnr_version 0 and no YOW row was ever written.
    i_old = reb["products"].index(old)
    i_new = len(reb["products"]) - 1
    events = [{"origin": "COMPARISON", "eventType": "UPDATED", "currentPath": "", "previousPath": ""},
              # The whole product, not /airSegment/status: at field granularity the consumer added
              # the new leg but left the cancelled one HK at version 0.
              {"origin": "COMPARISON", "eventType": "UPDATED",
               "currentPath": f"/products/{i_old}", "previousPath": f"/products/{i_old}"},
              {"origin": "COMPARISON", "eventType": "CREATED", "currentPath": f"/products/{i_new}"}]
    for j, it in enumerate(reb.get("flightItineraries", [])):
        if it.get("destinationIataCode") == rb["new_destination"]:
            events.append({"origin": "COMPARISON", "eventType": "UPDATED",
                           "currentPath": f"/flightItineraries/{j}/destinationIataCode",
                           "previousPath": f"/flightItineraries/{j}/destinationIataCode"})
    v2 = wrap(reb, "2", events, "REB", at)
    return [v0, v1, v2]


# ---- ticket -----------------------------------------------------------------

def _ticket(ident: Identity, i: int, p: dict, segs: list[dict], issuance_date: str, fare: dict) -> dict:
    tkt = ident.tickets[i]
    tid = f"{tkt}-{issuance_date}"
    event_at = f"{ident.booking_date}T20:00:00Z"
    return {
        "meta": {"triggerEventLog": {"id": f"{ident.pnr_id}-TKT-{i + 1}"}, "version": "3.5.0"},
        "processedTicket": {
            "id": tid, "version": str(int(datetime.now(timezone.utc).timestamp() * 1000)),
            "latestEvent": {"code": "130", "dateTimeGMT": event_at},
            "documentType": "T", "primaryDocumentNumber": tkt, "documentNumbers": [tkt], "numberOfBooklets": 1,
            "issuanceLocalDate": issuance_date, "issuanceType": "F",
            "validatingCarrierCode": "AC", "validatingCarrierRecordLocator": ident.locator,
            "pnrReferences": [{"systemId": "AC", "recordLocator": ident.locator},
                              {"systemId": "1A", "recordLocator": ident.locator}],
            "traveler": {"name": {"firstName": p["first_name"], "lastName": p["last_name"]},
                         "passengerTypeCode": p.get("type", "ADT")},
            "price": {"currency": fare.get("currency", "CAD"), "total": str(fare.get("amount", "500.00"))},
            "coupons": [{"id": f"{tid}-{n + 1}", "number": n + 1, "status": "OPEN_FOR_USE", "fareBasisCode": "YFLEX"}
                        for n in range(len(segs))],
        },
        "events": {"recordDomain": "TICKET", "recordId": tid,
                   "originFeedTimeStamp": f"{ident.booking_date}T19:49:38",
                   "events": [{"origin": "COMPARISON", "eventType": "CREATED"}]},
    }


# ---- FDM --------------------------------------------------------------------

def leg_id(s: dict) -> str:
    return f"{s['carrier']}#{s['flight_number']}#{s['origin']}#{s['dep_local'][:10]}"


_FDM_TEMPLATE = """<?xml version="1.0" encoding="UTF-8"?>
<!-- {comment} -->
<env:envelope xmlns:env="http://www.lsb.de/apc/ops/Envelope" xmlns:fld="http://www.lsb.de/apc/customer/aca/flightDetail">
  <sender>FDM-OPS</sender>
  <receiver>MessageBroker</receiver>
  <created>{created}</created>
  <messages>
    <fld:flightDetail>
      <identifier>
        <flight><fnCarrier>{carrier}</fnCarrier><fnNumber>{fn}</fnNumber></flight>
        <dayOfOrigin>{day}</dayOfOrigin>
      </identifier>
      <leg modified="{leg_mode}">
        <state modified="{mode}">{state}</state>
        <callSign>ACA{fn}</callSign>{change_info}
        <schedule>
          <departureAirport>{origin}</departureAirport>
          <departure>{dep}</departure>
          <arrivalAirport>{destination}</arrivalAirport>
          <arrival>{arr}</arrival>
          <serviceType>J</serviceType>
          <aircraftOwner>{carrier}</aircraftOwner>
          <aircraftSubtype>{aircraft}</aircraftSubtype>
          <aircraftConfiguration>J16Y120P01</aircraftConfiguration>
          <rotationIdentifier><registration>{carrier}{fn}</registration></rotationIdentifier>
          <employerCabin>{carrier}</employerCabin>
          <employerCockpit>{carrier}</employerCockpit>
          <seats><seatsF>16</seatsF><seatsC>0</seatsC><seatsY>120</seatsY></seats>
        </schedule>
        <actuals>{actuals}</actuals>
        <misc><depStand>D</depStand><depGate>15</depGate><arrGate>25</arrGate><arrStand>C15</arrStand></misc>
        <lastUpdate><userId>TS099991</userId><timestamp>{created}</timestamp></lastUpdate>
      </leg>
    </fld:flightDetail>
  </messages>
</env:envelope>
"""


def _divert_reasons(s: dict) -> tuple[str, str]:
    """(diversionReason, changeReason) for a diverted leg.

    Trip tracer persists `changeInfo/changeReason` and ignores `diversionReason` entirely: a message
    carrying only the latter stored `{"legState":"DIV","diversionAirport":...,"changeReason":""}`,
    which is what INT held for AC#9866 (SOC-UAT-011/ARPT) and AC#9181 (TC_16/TECH) -- the card's code
    never reached the database at all. So the code has to ride out as changeReason.

    It does NOT go in diversionReason. A card that diverts a flight back to its origin names the
    cause with a four-letter C49 CANCELLATION code, which is a different codelist from the diversion
    reasons; "MEC" stays the default there, as in `flight-diverted-mec-enriched/base.xml`, so nothing
    that validates that field sees a value from the wrong list. `diversion_reason` overrides both
    when a scenario names the cause itself.
    """
    stated = s.get("diversion_reason")
    if stated:
        return stated, stated
    return "MEC", (s.get("cancellation_code") or "MEC")


def _fdm(s: dict, created: str, *, delay: tuple[str, int] | None,
         cancel: str | None = None) -> str:
    """One FDM leg message: the schedule is the promise, `actuals` is what happened.

    A segment carrying `diverted_to` lands somewhere other than its scheduled arrivalAirport. The
    contract already says how -- leg state DIV, a changeInfo/diversionReason, and a diversionAirport
    inside actuals -- and `contrail/fixtures/lfd/fdm/flight-diverted-mec-enriched/base.xml` is a real
    message in that shape. Before this, the seeder could only ever say "same two airports, running
    late", so the sister-city cards seeded a booking that arrived exactly where it was promised.

    `cancel` is a 4-letter C49 cancellation code (TECH, PERF, ARPT, WEAT, CREW, ...). A cancelled
    flight never departed, so it carries NO `actuals` block at all -- which is what the SoC cards
    mean by "delayCodeList must be empty" -- and the reason rides in changeInfo instead. Shape taken
    from `contrail/fixtures/lfd/fdm/flight-cancelled/base.xml`, where the leg element and the state
    are both CNL. Without it the seeder could only ever say a flight was LATE, so eight SoC cards
    whose whole subject is the fallback from an empty delay list to the cancellation code could not
    be expressed at all.
    """
    fn, day = s["flight_number"], s["dep_local"][:10]
    dep, arr = _z(s["dep_utc"]), _z(s["arr_utc"])
    divert = s.get("diverted_to")
    change_info = ""
    if cancel:
        # No actuals: the flight did not operate, so there is nothing actual to report. The engine
        # finds an empty delay list and falls back to this code to decide controllability.
        leg_mode, mode, state, actuals = "CNL", "UPD", "CNL", ""
        change_info = ("\n        <changeInfo>"
                       f"<changeReason>{cancel}</changeReason></changeInfo>")
        comment = f"CANCEL leg {leg_id(s)} reason {cancel}"
    elif delay:
        code, mins = delay
        leg_mode = mode = "UPD"
        state = "ETD"
        actuals = (f'<estimatedTimeDeparture modified="NEW">{_plus_minutes(dep, mins)}</estimatedTimeDeparture>'
                   f'<estimatedTimeArrival modified="NEW">{_plus_minutes(arr, mins)}</estimatedTimeArrival>'
                   f'<delay modified="NEW"><delayCode>{code}</delayCode><delayTime>{mins}</delayTime>'
                   f'<subDelayCode>00</subDelayCode></delay>')
        comment = f"DELAY leg {leg_id(s)} code {code} {mins}min"
        if divert:   # a delayed leg that also landed elsewhere

            # The diversion rides on the UPD, not the SKD: the SKD message creates the leg as it was
            # sold, and the diversion is something that happened to it afterwards.
            state = "DIV"
            reason, changed = _divert_reasons(s)
            change_info = ("\n        <changeInfo>"
                           f"<diversionReason>{reason}</diversionReason>"
                           f"<changeReason>{changed}</changeReason></changeInfo>")
            actuals += (f'<estimatedTimeTouchdown modified="UPD">{_plus_minutes(arr, mins)}</estimatedTimeTouchdown>'
                        f'<diversionAirport modified="NEW">{divert}</diversionAirport>')
            comment = f"DIVERT leg {leg_id(s)} to {divert} ({reason}), code {code} {mins}min"
    elif divert:
        # Diverted with no delay to report. The arrival is still an estimate because the aircraft
        # did land, just not where it was sold to; the delay list stays empty on purpose.
        leg_mode = mode = "UPD"
        state = "DIV"
        reason, changed = _divert_reasons(s)
        change_info = ("\n        <changeInfo>"
                       f"<diversionReason>{reason}</diversionReason>"
                       f"<changeReason>{changed}</changeReason></changeInfo>")
        actuals = (f'<estimatedTimeArrival modified="UPD">{arr}</estimatedTimeArrival>'
                   f'<diversionAirport modified="NEW">{divert}</diversionAirport>')
        comment = f"DIVERT leg {leg_id(s)} to {divert} ({reason}), no delay"
    else:
        leg_mode = mode = "NEW"
        state, actuals = "SKD", ""
        comment = f"SKD create leg {leg_id(s)}"
    return _FDM_TEMPLATE.format(comment=comment, created=created, carrier=s["carrier"], fn=fn, day=day,
                                mode=mode, leg_mode=leg_mode, state=state,
                                origin=s["origin"], destination=s["destination"],
                                dep=dep, arr=arr, aircraft=s.get("aircraft", "320"), actuals=actuals,
                                change_info=change_info)


# ---- entry ------------------------------------------------------------------

def _segments_for_route(route: str, template: dict) -> list[dict]:
    """Rebuild the itinerary from a gap-doc route (YUL-YOW-YYZ): one 2 h leg per hop, 1 h connections,
    starting at the template segment's departure, everything else copied from the template."""
    stops = route.split("-")
    dep = datetime.fromisoformat(template["dep_local"])
    dep_utc = datetime.fromisoformat(template["dep_utc"].replace("Z", ""))
    out = []
    for i in range(len(stops) - 1):
        d, du = dep + timedelta(hours=3 * i), dep_utc + timedelta(hours=3 * i)
        a, au = d + timedelta(hours=2), du + timedelta(hours=2)
        s = dict(template)
        s.update({"origin": stops[i], "destination": stops[i + 1],
                  "dep_local": d.isoformat(timespec="seconds"), "arr_local": a.isoformat(timespec="seconds"),
                  "dep_utc": du.strftime("%Y-%m-%dT%H:%M:%SZ"), "arr_utc": au.strftime("%Y-%m-%dT%H:%M:%SZ")})
        out.append(s)
    return out


def _route_of(segs: list[dict]) -> str:
    return "-".join([segs[0]["origin"]] + [s["destination"] for s in segs])


# Where a SOC clock case's first departure has to sit, relative to the DAY it is seeded. Whole
# days, never hours, and that is the whole point: trip-tracer derives `flight_segment.flight_id`
# from the departure converted to UTC through the ORIGIN airport's timezone, while the seed writes
# dep_local and dep_utc as the same wall clock. A leg sitting near midnight therefore lands on a
# different DATE once the real offset is applied -- FRA (+2) at 01:35 becomes 23:35 the day before,
# YYC (-6) at 18:00 becomes 00:00 the day after -- and `segment_flight_id` fails.
#
# Shifting by whole days keeps every leg at the time of day the fixture chose (08:15 for the first,
# the rest spaced from it), which is what makes them safe. An arbitrary minute offset moved later
# legs across midnight and broke four cases on v19.
#
# The margins are deliberate: +2 days is at least 8 hours in the future even when seeded just
# before midnight, -1 day is inside the 72-hour hold from any hour of the day, and -12 days clears
# the hold by a week and a half.
SOC_CLOCK_DAYS = {"not_landed": +2, "in_hold": -1, "settled": -12}


def soc_clock_state(sc: dict) -> str | None:
    """Which of the three clock states this fixture asserts, or None when it is not a SOC case."""
    clocks = ((sc.get("soc") or {}).get("clocks") or {})
    if not clocks:
        return None
    if clocks.get("has_passed_expected_arrival") is False:
        return "not_landed"
    return "in_hold" if clocks.get("is_within_window") else "settled"


def soc_clock_shift(sc: dict, segs: list[dict]) -> int:
    """Whole DAYS to shift the fixture so its first departure lands where its clock state needs it.

    Returns 0 for anything that is not a SOC case, so FD and baggage render exactly as before.
    """
    state = soc_clock_state(sc)
    if not state or not segs:
        return 0
    dep = (segs[0].get("dep_local") or segs[0].get("dep_utc") or "")[:10]
    try:
        current = date.fromisoformat(dep)
    except ValueError:
        return 0
    want = datetime.now(timezone.utc).date() + timedelta(days=SOC_CLOCK_DAYS[state])
    return (want - current).days


def render(case: SeedCase, ident: Identity, *, email: str, phone: str, dob: str | None = None,
           first_name: str | None = None, last_name: str | None = None,
           shift_days: int = 0, shift_minutes: int = 0, keep_flight: bool = False, msl_index: int = -1,
           route_from_gapdoc: bool = True) -> Rendered:
    sc = case.scenario
    src_segments = sc["segments"]
    gap_route = getattr(case.expected, "route", None) or ""
    gap_route = gap_route.split()[0] if gap_route else ""
    # A fixture can refuse the gap-doc route. The card's route is one hop per airport pair, which
    # cannot express a journey that goes out and comes back to where it started -- and a "no travel
    # return" case is exactly that, so rebuilding from the route would discard the mid-point.
    if sc.get("fixture_route"):
        route_from_gapdoc = False
    if route_from_gapdoc and re.fullmatch(r"[A-Z]{3}(-[A-Z]{3})+", gap_route) and gap_route != _route_of(src_segments):
        src_segments = _segments_for_route(gap_route, src_segments[0])
    # A SOC case whose whole point is WHEN it is re-anchors to the run, not to the day its fixture
    # was written. Generating the dates baked them in: SOC_SIT_018 ("the aircraft has NOT landed")
    # was written with a +36h departure and seeded 33 hours later, by which time the flight had
    # left 7 hours earlier -- a booking asserting the opposite of what it was for. `soc_clocks`
    # caught it, but only after the PNR existed. The offset is derived here so a fixture of any
    # age seeds a correct clock, and the caller's own --shift-days / --flight-date still win.
    if not shift_days and not shift_minutes:
        shift_days = soc_clock_shift(sc, src_segments)
    segs = []
    for n, s in enumerate(src_segments):
        s = dict(s)
        for k in ("dep_local", "arr_local", "dep_utc", "arr_utc", "booking_datetime"):
            if s.get(k):
                s[k] = _shift(s[k], shift_days, shift_minutes)
        s["carrier"] = (s.get("operating_carrier") or s.get("carrier") or "AC")[:2]
        if not keep_flight:
            s["flight_number"] = ident.flight_number + n
        s["flight_number"] = int(s["flight_number"])
        segs.append(s)

    # A baggage card can say Air Canada was not the last carrier -- the whole scenario is the
    # redirect to the airline that was. The fixture recorded it and the checkpoint asserted it, but
    # nothing ever wrote it, so BAG_UAT_003 seeded an AC segment and could not test its own case.
    # Applied here, after the gap-doc route may have rebuilt the list, so the final segment is final.
    from . import bags as _bags                      # deferred: bags imports Rendered from here
    # A fixture that names the carrier outright outranks the baggage flag's stand-in: `last_carrier_ac
    # is false` only says "not AC", and bags.py picks Lufthansa for it, so a card that means WestJet
    # has to be able to say so while still carrying the flag the checkpoint asserts.
    other = sc.get("last_carrier") or _bags.last_carrier_override(sc.get("baggage"))
    if other and segs:
        # The OPERATING carrier changes; the marketing one does not. That is the codeshare shape a
        # "disruption on Star / on another airline" card describes -- an Air Canada ticket on a leg
        # someone else flew -- and operatingCarrierCode is the field the rule engine reads to decide
        # starCarriers / oalCarriers. Applied here, after the gap-doc route may have rebuilt the
        # list, so the final segment is final.
        segs[-1].setdefault("marketing_carrier", segs[-1].get("carrier") or "AC")
        segs[-1]["carrier"] = segs[-1]["operating_carrier"] = other

    pax = []
    for i, p in enumerate(sc["passengers"]):
        p = dict(p)
        p["first_name"] = p["first_name"].upper()
        # A passenger bound to a real loyalty account keeps that account's name: the wallet check
        # compares the PNR name against the profile's, so a minted surname fails `nameMatchesFfp`
        # and no other check can make up for it. Everyone else gets the minted, collision-free one.
        p["last_name"] = (p["last_name"].upper() if p.get("loyalty_number")
                          else ident.surnames[i].upper())
        # The tester's own date of birth, when one was given. FIRST passenger only, and only an
        # adult: a CHD's or INF's date of birth is not contact detail, it is the scenario -- an
        # infant-fare case reseeded with a 1988 birthday would stop being that case. The PNR carries
        # it three ways (the APD document, `birthDate` and `dateOfBirth`), all from this one field.
        if dob and i == 0 and (p.get("type") or "ADT").upper() == "ADT" and p.get("date_of_birth"):
            p["date_of_birth"] = dob
        # The tester's own name, when one was given -- first passenger only, like the date of birth.
        # This OVERRIDES the minted surname above, which is the point: `identity.mint` guarantees a
        # DB-absent surname so a booking can be found by name alone, and a real tester's name cannot
        # honour that. `name_pinned` is what tells `name_uniqueness` the recurrence is intended,
        # exactly as `loyalty_number` does -- without it every booking in the set would be reported
        # as a collision.
        if i == 0 and (first_name or last_name):
            if first_name:
                p["first_name"] = first_name.upper()
            if last_name:
                p["last_name"] = last_name.upper()
            p["name_pinned"] = True
        pax.append(p)

    tk = sc.get("ticketing", {})
    fare = tk.get("fare", {"amount": "500.00", "currency": "CAD"})
    issuance = _shift(tk.get("issuance_local_date") or ident.booking_date, shift_days)

    exp = case.expected
    msl_i = len(segs) + msl_index if msl_index < 0 else msl_index
    # A card that names its journey is about THAT journey's flight, not the booking's last leg: on a
    # return trip the two are different, and the verdict has to sit where the disruption (or the
    # bag) was. `dds.msl_bound` says it for a flight-disruption case, `baggage.bound` for a bag one.
    bag_bound = (sc.get("baggage") or {}).get("bound") or (sc.get("dds") or {}).get("msl_bound")
    if bag_bound:
        on_bound = [i for i, s in enumerate(segs) if bound_of(s) == int(bag_bound)]
        if on_bound:
            msl_i = on_bound[-1]
    msl = segs[msl_i]
    created = f"{ident.booking_date}T06:00:00Z"
    skd = [(leg_id(s), _fdm(s, created, delay=None)) for s in segs]
    # A cancelled leg gets a CNL message in place of the delay one, never both: the SoC cards that
    # turn on the cancellation-code fallback require the delay list to be empty, and a leg carrying
    # both would hand the engine a delay to read instead.
    # A leg that was DIVERTED is not a leg that was cancelled: SOC-UAT-011 says in as many words
    # "record as operated but returned to origin", and TC_16 flew and came back. Those carry a
    # cancellation-style reason code without being cancellations, so the diversion message wins and
    # the code rides on it as the diversion reason. Only a leg with no diversion is a cancellation.
    cancelled = [s for s in segs if s.get("cancellation_code") and not s.get("diverted_to")]
    delay = []
    if cancelled:
        delay = [(leg_id(s), _fdm(s, _plus_minutes(created, 60), delay=None,
                                  cancel=s["cancellation_code"])) for s in cancelled]
    elif exp.delay_minutes:
        delay = [(leg_id(msl), _fdm(msl, _plus_minutes(created, 60), delay=(exp.delay_code, exp.delay_minutes)))]
    else:
        # No delay and no cancellation, but still something to report: a diversion with an EMPTY
        # delay list, which is exactly what the "falls back to the cancellation code" cards describe.
        # delay=None keeps the <delay> element out: a zero-minute entry with a blank code would be a
        # delay the engine could read, and the fallback would never fire.
        diverted = [s for s in segs if s.get("diverted_to")]
        delay = [(leg_id(s), _fdm(s, _plus_minutes(created, 60), delay=None))
                 for s in diverted]

    # Where an involuntary rebooking put the customer, if the fixture declares one. It rides on
    # the last segment of the metadata so build_dds can see the journey ended elsewhere.
    rebooked_to = (sc.get("rebooking") or {}).get("new_destination")

    meta = {
        "case_id": case.case_id, "source_case_id": sc.get("source_case_id"), "suite": case.suite, "title": case.title,
        "locator": ident.locator, "pnr_id": ident.pnr_id, "booking_date": ident.booking_date,
        "flight_date": msl["dep_local"][:10], "shift_days": shift_days, "shift_minutes": shift_minutes,
        # what the claim-submission window is measured from: the last segment's arrival
        "last_arrival_utc": _z(segs[-1]["arr_utc"]),
        "claim_window": dict(sc.get("claim_window") or {}),
        "passengers": [{"id": f"{ident.pnr_id}-PT-{i + 1}", "first": p["first_name"], "last": p["last_name"],
                        "type": p.get("type", "ADT"), "dob": p.get("date_of_birth"),
                        # Carried so the checkpoint can read it back: it only reaches the PNR when a
                        # date of birth is present, which is easy to lose and impossible to see.
                        **({"country_of_residence": p["country_of_residence"]}
                           if p.get("country_of_residence") else {}),
                        **({"loyalty_number": p["loyalty_number"]} if p.get("loyalty_number") else {}),
                        **({"name_pinned": True} if p.get("name_pinned") else {})}
                       for i, p in enumerate(pax)],
        "tickets": ident.tickets[: len(pax)], "ticket_prefix": ident.ticket_prefix,
        "segments": [{"id": f"{ident.pnr_id}-ST-{n + 1}", "leg_id": leg_id(s), "bound": bound_of(s),
                      "carrier": s["carrier"],
                      "marketing_carrier": s.get("marketing_carrier") or s["carrier"],
                      "flight_number": s["flight_number"], "origin": s["origin"], "destination": s["destination"],
                      "dep_local": s["dep_local"], "arr_local": s["arr_local"], "dep_utc": _z(s["dep_utc"]),
                      "arr_utc": _z(s["arr_utc"]), "cabin": s.get("cabin", "Y"), "status": s.get("status", "HK"),
                      # Where the journey actually ended, when that is not where it was sold to end.
                      # build_dds reads these to make actualItinerary differ from promisedItinerary;
                      # absent on every ordinary segment, which leaves those documents unchanged.
                      **({"diverted_to": s["diverted_to"]} if s.get("diverted_to") else {}),
                      # Why it diverted, which finalize writes into the stand-in LEG_STATUS as the
                      # changeReason. Without it here that row carried an empty reason and the
                      # cancellation checkpoint read `('DIV', None)` back.
                      **({"diversion_reason": s["diversion_reason"]}
                         if s.get("diversion_reason") else {}),
                      **({"cancellation_code": s["cancellation_code"]}
                         if s.get("cancellation_code") else {}),
                      **({"rebooked_to": rebooked_to, "cancelled": True}
                         if rebooked_to and n == len(segs) - 1 else {})}
                     for n, s in enumerate(segs)]
                    # The replacement leg the v2 adds. It is a real row in flight_segment, so the
                    # metadata has to list it or every check that compares the booking against the
                    # scenario reports a segment the seeder itself created.
                    + ([{"id": f"{ident.pnr_id}-ST-{len(segs) + 1}",
                         "leg_id": leg_id({**segs[-1], "flight_number": ident.flight_number + len(segs)}),
                         "bound": bound_of(segs[-1]), "carrier": segs[-1]["carrier"],
                         "marketing_carrier": segs[-1].get("marketing_carrier") or segs[-1]["carrier"],
                         "flight_number": ident.flight_number + len(segs),
                         "origin": segs[-1]["origin"], "destination": rebooked_to,
                         "dep_local": segs[-1]["dep_local"],
                         # The replacement's ARRIVAL, which is not the cancelled leg's. v2 keeps the
                         # old leg's local clock and swaps only the airport, so the INSTANT moves
                         # whenever the two are in different zones: 14:00 is 21:00Z at YVR (UTC-7)
                         # and 18:00Z at YOW (UTC-4). Copying `arr_utc` made the metadata claim
                         # 21:00Z while trip tracer computed 18:00Z from what was actually
                         # published -- three hours apart, the exact YVR/YOW offset. Nothing noticed
                         # until `segment_promised_arrival` met a reaccommodation for the first
                         # time; no check had ever read a promised TIME. The fixture supplies the
                         # new leg's own clock because only the generator knows airport zones; a
                         # rebooking without it keeps the old behaviour.
                         "arr_local": (sc.get("rebooking") or {}).get("new_arr_local")
                                      or segs[-1]["arr_local"],
                         "dep_utc": _z(segs[-1]["dep_utc"]),
                         "arr_utc": _z((sc.get("rebooking") or {}).get("new_arr_utc")
                                       or segs[-1]["arr_utc"]),
                         "cabin": segs[-1].get("cabin", "Y"), "status": "HK",
                         # `replacement` keeps it out of the PROMISED itinerary: the customer was
                         # never sold this leg. `cancelled` on the leg it replaced keeps that one
                         # out of the ACTUAL itinerary. Without the pair, adding the row here made
                         # promised and actual both read YOW and the distinction vanished again.
                         "replacement": True, "rebooked_to": rebooked_to}] if rebooked_to else []),
        "msl_segment_index": msl_i,
        "email": email, "phone": phone,
        # the office that made the booking: its last two letters are how the rule engine tells
        # employee travel from an ordinary ticket
        "office_id": (sc.get("point_of_sale") or {}).get("office_id", ""),
        "route": _route_of(segs), "route_source": "gapdoc" if src_segments is not sc["segments"] else "fixture",
        "expected": dict(exp.__dict__), "tags": case.tags,
        "general": dict(sc.get("general") or {}),
        # the bag conditions the gap-doc card stated (baggage cases only); finalize seeds from these
        "baggage": _baggage_block(case),
        # the SOC per-leg outcomes the seed-data document stated (SOC cases only); finalize builds
        # socFlightEligibility from these. Absent for every FD and baggage fixture, which is what
        # keeps their document byte-identical to what it was before SOC existed.
        "soc": dict(case.scenario.get("soc") or {}),
        "loyalty": dict(case.scenario.get("loyalty") or {}),
        # optional DDS shaping (partner/OAL routing, per-passenger results, no-travel): absent for
        # every ordinary recipe, and build_dds defaults each key to the value it hardcoded before.
        "dds": dict(sc.get("dds") or {}),
        "group": is_group(case, pax),
    }
    return Rendered(pnr_id=ident.pnr_id, locator=ident.locator, booking_date=ident.booking_date,
                    pnr_versions=_pnr_versions(case, ident, segs, pax, email, phone, issuance, fare),
                    tickets=[_ticket(ident, i, p, segs, issuance, fare) for i, p in enumerate(pax)],
                    fdm_skd=skd, fdm_delay=delay, meta=meta)


def _baggage_block(case) -> dict:
    """The bag conditions the gap-doc card stated, carried into meta for finalize and verify."""
    return dict(case.scenario.get("baggage") or {})


def write(r: Rendered, out_dir: Path) -> Path:
    out_dir.mkdir(parents=True, exist_ok=True)
    for v in r.pnr_versions:
        (out_dir / f"01_pnr_v{v['processedPnr']['version']}.json").write_text(json.dumps(v, indent=2), encoding="utf-8")
    for i, t in enumerate(r.tickets):
        (out_dir / f"02_ticket_{i + 1}.json").write_text(json.dumps(t, indent=2), encoding="utf-8")
    for n, (_, xml) in enumerate(r.fdm_skd):
        (out_dir / f"03_fdm_skd_leg{n + 1}.xml").write_text(xml, encoding="utf-8")
    for n, (_, xml) in enumerate(r.fdm_delay):
        (out_dir / f"04_fdm_delay_leg{n + 1}.xml").write_text(xml, encoding="utf-8")
    (out_dir / "meta.json").write_text(json.dumps(r.meta, indent=2), encoding="utf-8")
    return out_dir


def load(out_dir: Path) -> Rendered:
    meta = json.loads((out_dir / "meta.json").read_text(encoding="utf-8"))
    pnr_versions = [json.loads(p.read_text(encoding="utf-8")) for p in sorted(out_dir.glob("01_pnr_v*.json"))]
    tickets = [json.loads(p.read_text(encoding="utf-8")) for p in sorted(out_dir.glob("02_ticket_*.json"))]
    legs = [s["leg_id"] for s in meta["segments"]]
    skd = [(legs[n], p.read_text(encoding="utf-8")) for n, p in enumerate(sorted(out_dir.glob("03_fdm_skd_leg*.xml")))]
    msl = legs[meta["msl_segment_index"]]
    delay = [(msl, p.read_text(encoding="utf-8")) for p in sorted(out_dir.glob("04_fdm_delay_leg*.xml"))]
    return Rendered(pnr_id=meta["pnr_id"], locator=meta["locator"], booking_date=meta["booking_date"],
                    pnr_versions=pnr_versions, tickets=tickets, fdm_skd=skd, fdm_delay=delay, meta=meta)
