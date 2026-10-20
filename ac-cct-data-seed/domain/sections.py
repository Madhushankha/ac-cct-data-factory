"""The six sections of an assessment document, and which flow owns each.

This is a fact about the engine's output, not a configuration choice: the document has these six
sections and no others, and every one of them has exactly one flow that reads it. A section nobody
reads is coverage silently missing. A section two flows read is two answers to one question, and the
first time that happened one seeder pinned a verdict while another computed it, which is why their
results could not be compared.

`interimExpensesEligibility` belongs to BAGGAGE: interim expenses are the essentials a passenger
buys while their bag is missing, so the section is decided by the bag's delay and not by the
flight's. It sat with SOC here until that was corrected -- SOC also deals in receipts, which is what
made the wrong assignment look reasonable.
"""
from __future__ import annotations

from types import MappingProxyType

#: section -> the flow id that owns it. Read-only: a flow claims its section by declaring it, and
#: `flows.registry` checks the claims against this at import.
SECTIONS = MappingProxyType({
    "compensationEligibility": "fd",
    "socFlightEligibility": "soc",
    "interimExpensesEligibility": "baggage",
    "baggageClaimEligibility": "baggage",
    "baggageRefundEligibility": "anc",
    "seatFeeRefundEligibility": "anc",
})

#: Sections a flow may legitimately read in addition to the one it owns. Baggage and ancillary each
#: own two: one flow, one question, asked of two sections that answer it in the same shape.
ALSO: dict[str, tuple[str, ...]] = {
    "baggage": ("interimExpensesEligibility",),
    "anc": ("seatFeeRefundEligibility",),
}


def owner(section: str) -> str:
    """Which flow reads this section. Raises rather than guessing."""
    try:
        return SECTIONS[section]
    except KeyError:
        raise KeyError(f"{section!r} is not an assessment section; the six are: "
                       f"{', '.join(SECTIONS)}") from None


def owned_by(flow_id: str) -> tuple[str, ...]:
    """Every section this flow reads, the one it names first."""
    return tuple(s for s, f in SECTIONS.items() if f == flow_id)
