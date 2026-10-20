"""The three flows whose data or lanes do not exist yet.

Each states what is missing in the terms the person who must supply it would use, and nothing else.
A stub that guessed at an implementation would be worse than this: it would report passes.

They are real `Flow`s, so a spec can be loaded, validated and rendered for them today. What they
refuse to do is claim a verdict: `rows` reads the right section, and `checks` reports n/a with the
reason, because the lane that would make the section answer has not been built.
"""
from __future__ import annotations

from core.flow import Check, Flow, Row
from flows.not_ready import NEEDS


class _Stub(Flow):
    """Reads its section honestly; refuses to claim anything while `needs` is non-empty."""

    #: of `needs`, the ones that stop a case being built and published. Judging is a different
    #: question, answered by `checks`. See `flows/not_ready.py` for why these were separated.
    blocks_seeding: tuple[str, ...] | None = None

    def validate(self, spec: dict) -> list[str]:
        missing = []
        if not spec.get("passengers"):
            missing.append("no passengers")
        if not spec.get("segments"):
            missing.append("no segments")
        blocking = self.needs if self.blocks_seeding is None else self.blocks_seeding
        return missing + [f"flow not ready: {n}" for n in blocking]

    def rows(self, document: dict) -> list[Row]:
        out = []
        for block in (document.get(self.section) or []):
            for p in (block.get("passengerEligibility") or []):
                out.append(Row(key=(str(block.get("regime")),
                                    str(p.get("passengerName") or p.get("passengerId") or "")),
                               status=p.get("eligibilityStatus"), code=p.get("systemCode"),
                               extra={"regime": block.get("regime"), "block": block}))
        return out

    def checks(self, spec: dict, rows: list[Row]) -> list[Check]:
        return [Check.na(f"{self.id}_verdict",
                         f"{self.label} cannot be claimed yet: {self.needs[0]}"
                         + (f" (+{len(self.needs) - 1} more)" if len(self.needs) > 1 else ""))]


class StandardsOfCare(_Stub):
    id = "soc"
    label = "Standards of Care"
    section = "socFlightEligibility"
    lanes = ("flight_status",)
    needs = NEEDS["soc"]
    #: the builder consumes every block the SOC specs use (schedule changes, pax events, vouchers,
    #: cancellation codes); what is left in `needs` blocks judging only
    blocks_seeding: tuple[str, ...] = ()


class Baggage(_Stub):
    id = "baggage"
    label = "Baggage"
    section = "baggageClaimEligibility"
    lanes = ("bag_events",)
    needs = NEEDS["baggage"]
    #: `builder/bag_build.py` is the bag-event lane; what is left in `needs` blocks judging only
    blocks_seeding: tuple[str, ...] = ()


class Ancillary(_Stub):
    id = "anc"
    label = "Ancillary refunds"
    #: two sections, bag fees and seat fees. `section` names the one `rows` reads; the other is
    #: read the same way once the lane exists, which is why they share a flow rather than splitting.
    section = "baggageRefundEligibility"
    lanes = ("emd",)
    needs = NEEDS["anc"]


FLOWS = (StandardsOfCare(), Baggage(), Ancillary())
