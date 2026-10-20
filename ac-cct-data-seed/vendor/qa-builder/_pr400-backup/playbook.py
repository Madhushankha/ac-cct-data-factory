"""The lifecycle playbook the builders and the validator read (F12 contracts.md §2, /tools/playbook).

The built-in table below is the builder's vocabulary (what /tools/build builds and the validator checks), so it is
always the contract. `tools/qa-scenarios/playbook/lifecycle.json` (the measured playbook, its own family names) is
served beside it as `lifecycle` when present (the image copies it to /playbook):

  families: {family: {"feed", "phase", "predecessors": [family...], "surround": [family...], "description"}}
  norms:    {family: {"anchor": "booking|ticketing|departure|arrival", "minMinutes", "maxMinutes", "typicalMinutes"}}

Phases, in order: before_booking, booking, ticketing, changes, day_of_flight, post_flight.
"""
import json
from pathlib import Path

PLAYBOOK_DIR = Path(__file__).resolve().parent.parent / "playbook"
PHASES = ["before_booking", "booking", "ticketing", "changes", "day_of_flight", "post_flight"]

# ponytail: built-in default until the playbook agent's files land; the shape is the contract, the numbers are
# the KB's phase model (kb/source/reference/pnr/lifecycle-phases.md) and the pool's observed spacing.
DEFAULT_FAMILIES = {
    "pnr_creation": {"feed": "PNR", "phase": "booking", "predecessors": [], "surround": ["profile_link"],
                     "description": "The booking's first PNR version (PNR_CREATION)"},
    "profile_link": {"feed": "CUSTOMER_PROFILE_CPID", "phase": "booking", "predecessors": ["pnr_creation"], "surround": [],
                     "description": "Customer profile links each traveler to a CPID"},
    "ticket_issued": {"feed": "TKT", "phase": "ticketing", "predecessors": ["pnr_creation"],
                      "surround": ["pnr_ticketed", "pnr_ticket_correlation"],
                      "description": "An e-ticket per passenger with one coupon per segment"},
    "pnr_ticketed": {"feed": "PNR", "phase": "ticketing", "predecessors": ["ticket_issued"], "surround": [],
                     "description": "The PNR version that carries the FA ticketing references"},
    "pnr_ticket_correlation": {"feed": "PNRCORR", "phase": "ticketing", "predecessors": ["ticket_issued", "pnr_ticketed"],
                               "surround": [], "description": "PNR to ticket coupon correlation"},
    "emd_issued": {"feed": "EMD", "phase": "ticketing", "predecessors": ["ticket_issued"], "surround": [],
                   "description": "An EMD (seat, bag) associated to the ticket"},
    "schedule_change": {"feed": "PNR", "phase": "changes", "predecessors": ["pnr_creation"], "surround": ["notification"],
                        "description": "The airline moves a flight's times (FLIGHT_TIME_UPDATE)"},
    "flight_cancelled_rebooked": {"feed": "PNR", "phase": "changes", "predecessors": ["pnr_creation"],
                                  "surround": ["flight_cancelled", "notification"],
                                  "description": "A segment goes UN and a protecting segment TK (involuntary rebooking)"},
    "rebooking_accepted": {"feed": "PNR", "phase": "changes", "predecessors": ["flight_cancelled_rebooked"], "surround": [],
                           "description": "The UN segment is removed and TK becomes HK"},
    "booking_cancelled": {"feed": "PNR", "phase": "changes", "predecessors": ["pnr_creation"], "surround": [],
                          "description": "Every air segment leaves the booking"},
    "notification": {"feed": "AACC", "phase": "changes", "predecessors": ["pnr_creation"], "surround": [],
                     "description": "An Altea customer notification (AACC) for the booking"},
    "flight_scheduled": {"feed": "FDM", "phase": "day_of_flight", "predecessors": [], "surround": [],
                         "description": "FDM creates the operational leg (SKD)"},
    "departure_gate": {"feed": "FDM", "phase": "day_of_flight", "predecessors": ["flight_scheduled"], "surround": [],
                       "description": "FDM assigns the departure gate"},
    "check_in": {"feed": "CM", "phase": "day_of_flight", "predecessors": ["pnr_creation"], "surround": ["cm_correlation"],
                 "description": "The passenger is accepted on a leg (CHECK_IN)"},
    "cm_correlation": {"feed": "CM", "phase": "day_of_flight", "predecessors": ["pnr_creation"], "surround": [],
                       "description": "DCS passenger to PNR traveler and segment correlation"},
    "bag_checked": {"feed": "CM_BAG", "phase": "day_of_flight", "predecessors": ["check_in"],
                    "surround": ["bag_created", "bag_accepted", "bag_loaded", "bag_unloaded", "bag_delivered"],
                    "description": "A bag group is accepted at check-in"},
    "bag_created": {"feed": "SMART_SUITE", "phase": "day_of_flight", "predecessors": ["bag_checked"], "surround": [],
                    "description": "BROCK BagCreatedEvent"},
    "bag_accepted": {"feed": "SMART_SUITE", "phase": "day_of_flight", "predecessors": ["bag_created"], "surround": [],
                     "description": "BROCK BagAcceptedDeclaration"},
    "bag_loaded": {"feed": "SMART_SUITE", "phase": "day_of_flight", "predecessors": ["bag_accepted"], "surround": [],
                   "description": "BROCK BagLoadedOnAircraftDeclaration"},
    "bag_unloaded": {"feed": "SMART_SUITE", "phase": "post_flight", "predecessors": ["bag_loaded"], "surround": [],
                     "description": "BROCK BagUnloadedEvent"},
    "bag_delivered": {"feed": "SMART_SUITE", "phase": "post_flight", "predecessors": ["bag_unloaded"], "surround": [],
                      "description": "BROCK BagDeliveredToCarouselDeclaration"},
    "bag_mishandled": {"feed": "SMART_SUITE", "phase": "post_flight", "predecessors": ["bag_accepted"], "surround": [],
                       "description": "BROCK BagMishandledDeclaration then the delayed-bag record"},
    "boarding": {"feed": "CM", "phase": "day_of_flight", "predecessors": ["check_in"], "surround": [],
                 "description": "The passenger boards (BOARDING)"},
    "denied_boarding": {"feed": "CM", "phase": "day_of_flight", "predecessors": ["check_in"], "surround": [],
                        "description": "Check-in cancelled for Denied Boarding with an oversales transfer"},
    "no_show": {"feed": "CM", "phase": "day_of_flight", "predecessors": ["check_in"], "surround": [],
                "description": "Check-in cancelled for NOSHOW"},
    "departure_delay": {"feed": "FDM", "phase": "day_of_flight", "predecessors": ["flight_scheduled"], "surround": [],
                        "description": "FDM revises the estimated departure with a delay code"},
    "flight_departed": {"feed": "FDM", "phase": "day_of_flight", "predecessors": ["flight_scheduled"], "surround": [],
                        "description": "FDM off-blocks (DEP)"},
    "flight_arrived": {"feed": "FDM", "phase": "day_of_flight", "predecessors": ["flight_departed"], "surround": [],
                       "description": "FDM on-blocks (ARR)"},
    "flight_cancelled": {"feed": "FDM", "phase": "day_of_flight", "predecessors": ["flight_scheduled"], "surround": [],
                         "description": "FDM cancels the leg (CNL)"},
    "flight_diverted": {"feed": "FDM", "phase": "day_of_flight", "predecessors": ["flight_departed"], "surround": [],
                        "description": "FDM diverts the leg (DIV)"},
    "return_to_ramp": {"feed": "FDM", "phase": "day_of_flight", "predecessors": ["flight_departed"], "surround": [],
                       "description": "FDM returns the leg to the ramp (RTR)"},
    "meal_voucher": {"feed": "ICOUPON", "phase": "day_of_flight", "predecessors": ["pnr_creation"], "surround": [],
                     "description": "iCoupon meal voucher creation"},
    "hotel_voucher": {"feed": "STORMX", "phase": "post_flight", "predecessors": ["pnr_creation"], "surround": [],
                      "description": "StormX hotel voucher accepted"},
}

DEFAULT_NORMS = {
    "profile_link": {"anchor": "booking", "minMinutes": 0, "maxMinutes": 1440, "typicalMinutes": 30},
    "ticket_issued": {"anchor": "booking", "minMinutes": 0, "maxMinutes": 10080, "typicalMinutes": 20},
    "pnr_ticketed": {"anchor": "ticketing", "minMinutes": 0, "maxMinutes": 60, "typicalMinutes": 1},
    "pnr_ticket_correlation": {"anchor": "ticketing", "minMinutes": 0, "maxMinutes": 60, "typicalMinutes": 2},
    "emd_issued": {"anchor": "ticketing", "minMinutes": 0, "maxMinutes": 43200, "typicalMinutes": 60},
    "schedule_change": {"anchor": "departure", "minMinutes": -259200, "maxMinutes": -60, "typicalMinutes": -20160},
    "flight_cancelled_rebooked": {"anchor": "departure", "minMinutes": -43200, "maxMinutes": 120, "typicalMinutes": -300},
    "rebooking_accepted": {"anchor": "departure", "minMinutes": -43200, "maxMinutes": 1440, "typicalMinutes": -180},
    "booking_cancelled": {"anchor": "departure", "minMinutes": -259200, "maxMinutes": 0, "typicalMinutes": -1440},
    "notification": {"anchor": "departure", "minMinutes": -259200, "maxMinutes": 1440, "typicalMinutes": -1440},
    "flight_scheduled": {"anchor": "departure", "minMinutes": -43200, "maxMinutes": -60, "typicalMinutes": -10080},
    "departure_gate": {"anchor": "departure", "minMinutes": -1440, "maxMinutes": 0, "typicalMinutes": -120},
    "cm_correlation": {"anchor": "departure", "minMinutes": -2880, "maxMinutes": 0, "typicalMinutes": -1440},
    "check_in": {"anchor": "departure", "minMinutes": -1440, "maxMinutes": -20, "typicalMinutes": -180},
    "bag_checked": {"anchor": "departure", "minMinutes": -300, "maxMinutes": -30, "typicalMinutes": -120},
    "bag_created": {"anchor": "departure", "minMinutes": -300, "maxMinutes": -30, "typicalMinutes": -120},
    "bag_accepted": {"anchor": "departure", "minMinutes": -300, "maxMinutes": -25, "typicalMinutes": -115},
    "bag_loaded": {"anchor": "departure", "minMinutes": -120, "maxMinutes": 0, "typicalMinutes": -40},
    "bag_unloaded": {"anchor": "arrival", "minMinutes": 0, "maxMinutes": 90, "typicalMinutes": 15},
    "bag_delivered": {"anchor": "arrival", "minMinutes": 5, "maxMinutes": 120, "typicalMinutes": 30},
    "bag_mishandled": {"anchor": "arrival", "minMinutes": 0, "maxMinutes": 2880, "typicalMinutes": 60},
    "boarding": {"anchor": "departure", "minMinutes": -60, "maxMinutes": 0, "typicalMinutes": -25},
    "denied_boarding": {"anchor": "departure", "minMinutes": -90, "maxMinutes": 0, "typicalMinutes": -20},
    "no_show": {"anchor": "departure", "minMinutes": -60, "maxMinutes": 60, "typicalMinutes": 0},
    "departure_delay": {"anchor": "departure", "minMinutes": -1440, "maxMinutes": 600, "typicalMinutes": -60},
    "flight_departed": {"anchor": "departure", "minMinutes": -15, "maxMinutes": 720, "typicalMinutes": 5},
    "flight_arrived": {"anchor": "arrival", "minMinutes": -60, "maxMinutes": 720, "typicalMinutes": 2},
    "flight_cancelled": {"anchor": "departure", "minMinutes": -43200, "maxMinutes": 180, "typicalMinutes": -240},
    "flight_diverted": {"anchor": "departure", "minMinutes": 20, "maxMinutes": 900, "typicalMinutes": 120},
    "return_to_ramp": {"anchor": "departure", "minMinutes": 0, "maxMinutes": 240, "typicalMinutes": 30},
    "meal_voucher": {"anchor": "departure", "minMinutes": -600, "maxMinutes": 1440, "typicalMinutes": 60},
    "hotel_voucher": {"anchor": "departure", "minMinutes": -600, "maxMinutes": 2880, "typicalMinutes": 240},
}


# The builder's families are what /tools/build builds and what the validator checks, so they stay the contract. The
# measured playbook (tools/qa-scenarios/playbook/lifecycle.json, 79 families named by the parsers) is a different
# vocabulary: loading it in their place made `families` the whole document, so the ordering rule found no predecessors
# and the timing rule no norms, and both passed everything (TTQ-QA-SIDECAR-PLAYBOOK-SHAPE). It rides alongside instead,
# each builder family naming its measured counterpart.
MEASURED_AS = {
    "pnr_creation": "pnr.creation", "profile_link": "profile.link", "ticket_issued": "ticket.issued",
    "pnr_ticketed": "pnr.ticketing-reference", "pnr_ticket_correlation": "pnrcorr.ticket", "emd_issued": "emd.issued",
    "schedule_change": "pnr.itinerary-change", "flight_cancelled_rebooked": "pnr.itinerary-change",
    "rebooking_accepted": "pnr.itinerary-change", "booking_cancelled": "pnr.itinerary-change",
    "flight_scheduled": "flight.scheduled", "departure_gate": "flight.gate-update", "check_in": "cm.checkin",
    "cm_correlation": "cm.correlation", "bag_checked": "cmbag.group", "bag_created": "bag.created",
    "bag_accepted": "bag.accepted", "bag_loaded": "bag.loading", "bag_unloaded": "bag.unloaded",
    "bag_delivered": "bag.delivered", "bag_mishandled": "bag.mishandled", "boarding": "cm.boarding",
    "denied_boarding": "cm.offload", "no_show": "cm.offload", "departure_delay": "flight.departure-estimate",
    "flight_departed": "flight.off-blocks", "flight_arrived": "flight.arrived", "flight_cancelled": "flight.cancelled",
    "flight_diverted": "flight.diverted", "return_to_ramp": "flight.return-to-ramp", "meal_voucher": "voucher.meal-issued",
    "hotel_voucher": "voucher.hotel-accepted",
}
LIFECYCLE_FIELDS = ("phase", "feed", "name", "requires", "followed_by", "timing")


def _lifecycle():
    """The measured playbook's families by id, or {} when the file is not beside the sidecar."""
    path = PLAYBOOK_DIR / "lifecycle.json"
    if not path.exists():
        return {}
    return {f["id"]: {k: f[k] for k in LIFECYCLE_FIELDS if k in f} for f in json.loads(path.read_text()).get("families", [])}


def playbook(family=None):
    """`{"source", "phases", "families", "norms", "lifecycle"}`: the builder's families (each with `measured`, its
    playbook family id) and norms, and the measured playbook's families; narrowed to one family (and its surround)
    when asked. `family` may be a builder family or a playbook id, with `-` or `_` alike; a name that matches neither
    returns everything with a note (the model asked for "denied-boarding" and got an empty answer, 2026-10-14)."""
    families, norms, lifecycle = DEFAULT_FAMILIES, DEFAULT_NORMS, _lifecycle()
    families = {k: {**v, **({"measured": MEASURED_AS[k]} if MEASURED_AS.get(k) in lifecycle else {})} for k, v in families.items()}
    if family:
        wanted = family.strip().lower()
        family = next((k for k in [*families, *lifecycle] if k.replace("-", "_") == wanted.replace("-", "_")), None)
        if family is None:
            return {"source": "file" if (PLAYBOOK_DIR / "lifecycle.json").exists() else "built-in", "phases": PHASES,
                    "note": f"no family is named {wanted!r}; every family follows (builder names in families, measured ids in lifecycle)",
                    "families": families, "norms": norms, "lifecycle": lifecycle}
    if family:
        keep = {family, *families.get(family, {}).get("surround", [])} | {k for k, v in MEASURED_AS.items() if v == family}
        families = {k: v for k, v in families.items() if k in keep}
        norms = {k: v for k, v in norms.items() if k in keep}
        ids = {family, *(MEASURED_AS.get(k) for k in keep)}
        lifecycle = {k: v for k, v in lifecycle.items() if k in ids}
    return {"source": "file" if (PLAYBOOK_DIR / "lifecycle.json").exists() else "built-in",
            "phases": PHASES, "families": families, "norms": norms, "lifecycle": lifecycle}
