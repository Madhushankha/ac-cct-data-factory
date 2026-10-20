"""The flows that cannot claim a verdict yet, as policies that say so.

Each satisfies `ports.FlowPolicy` in full, so a set can be loaded, validated, planned and seeded for
it today. What it refuses to do is claim: `rows` reads the right section honestly, and `judge`
returns one n/a check carrying the reason.

That refusal is the point. A stub that guessed at a comparison would report passes, and a passing
check nobody implemented is worse than a missing one -- it is a missing one that looks finished.

`needs` is written in the terms the person who must supply it would use, because it is read by that
person and not by us. The text here is the single declaration; `flows/pending.py` reads it for the
older dict-based interface rather than keeping a second copy that can drift.
"""
from __future__ import annotations

from typing import Iterable

from domain.models import Assessment, AssessmentRow, Check, Scenario
from domain.values import DelayBand, Minutes, Money, SystemCode


class NotReady:
    """A flow whose section is read but whose verdict is not claimed."""

    flow_id = "?"
    label = "?"
    section = "?"
    lanes: tuple[str, ...] = ()
    needs: tuple[str, ...] = ()
    #: sections beyond `section` this flow will also read once it is ready
    also: tuple[str, ...] = ()

    @property
    def ready(self) -> bool:
        return not self.needs

    @property
    def blocks_seeding(self) -> tuple[str, ...]:
        """Of `needs`, the ones that stop a case being BUILT and PUBLISHED.

        Not the same question as claiming a verdict, and conflating the two cost this project a
        set: baggage refused all 73 of `baggage/sit/po` before the builder ran, for three reasons
        that are about judging an answer and not about producing a booking. A flow that cannot
        judge can still seed -- `judge` already returns n/a and says why -- and seeding is what a
        product owner walking a case by hand needs.

        The default is every need, because a flow with no lane of its own cannot seed either. A
        flow that has grown its seeding lane overrides this with the needs that remain.
        """
        return self.needs

    def validate(self, scenario: Scenario) -> tuple[str, ...]:
        """A scenario can be checked for shape even when the flow cannot judge it."""
        missing: list[str] = []
        if not scenario.passengers:
            missing.append("no passengers")
        if not scenario.segments:
            missing.append("no segments")
        return tuple(missing + [f"{self.flow_id} cannot claim a verdict yet: {n}"
                                for n in self.blocks_seeding])

    def rows(self, assessment: Assessment) -> tuple[AssessmentRow, ...]:
        """The section, read in the generic per-passenger shape.

        This is deliberately the shape the document gives rather than the shape the flow needs: SOC
        answers per segment, baggage per bag, ancillary per EMD, and inventing those row keys here
        would be guessing at the part each flow still has to define.
        """
        out: list[AssessmentRow] = []
        for section in (self.section, *self.also):
            for block in assessment.blocks(section):
                for p in (block.get("passengerEligibility") or []):
                    if not isinstance(p, dict):
                        continue
                    comp = p.get("compensationDetails") or {}
                    out.append(AssessmentRow(
                        key=(section, str(block.get("regime")), str(block.get("boundRph")),
                             str(p.get("passengerName") or p.get("passengerId") or "")),
                        eligibility=p.get("eligibilityStatus"),
                        system_code=SystemCode.parse(p.get("systemCode")),
                        money=Money.of(comp.get("amount"), comp.get("currency")),
                        delay=Minutes.of(p.get("delayMinutes")),
                        band=DelayBand(comp.get("delayBand")),
                        regime=block.get("regime"), bound=block.get("boundRph")))
        return tuple(out)

    def tags(self, scenario: Scenario) -> tuple[str, ...]:
        """What the scenario says it is. Thin on purpose: these flows have no fixtures yet, and a
        richer tag set would be invented rather than derived. Baggage's real vocabulary (`open`,
        `delivered`, `lost`, `no-ahl`, `two-bags`, `outside-21`) comes from the bag's state, which
        is exactly the lane this flow is missing."""
        out = {self.flow_id}
        status = (scenario.expectation.eligibility or "").upper()
        if status:
            out.add(status.lower().replace("_", "-"))
        if scenario.expectation.regime:
            out.add(str(scenario.expectation.regime).lower())
        return tuple(sorted(out))

    def judge(self, scenario: Scenario,
              rows: Iterable[AssessmentRow]) -> tuple[Check, ...]:
        rows = tuple(rows)
        first = self.needs[0] if self.needs else "no reason recorded"
        more = f" (+{len(self.needs) - 1} more; see flows/not_ready.py)" if len(self.needs) > 1 \
            else ""
        return (
            # the row count is still reported: it is a fact about the document, not a claim about
            # whether the answer is right, and it is the first thing that tells us a lane landed
            Check.na(f"{self.flow_id}_section", f"{len(rows)} row(s) in {self.section}"),
            Check.na(f"{self.flow_id}_verdict",
                     f"{self.label} cannot be claimed yet: {first}{more}"),
        )


class StandardsOfCare(NotReady):
    flow_id = "soc"
    label = "Standards of Care"
    section = "socFlightEligibility"
    lanes = ("flight_status",)
    #: nothing below stops a SOC case being BUILT. The builder already consumes every block the
    #: 77 specs use -- `scheduleChanges` and their notice hours, `paxEvents` (including voluntary
    #: changes), `vouchers`, and `cancelCode` in both the PNR and the FDM feed -- so a SOC booking
    #: is as publishable as an FD one. What the three needs below gate is the VERDICT, which
    #: `judge` reports as n/a per case rather than comparing with FD's per-passenger shape.
    blocks_seeding: tuple[str, ...] = ()
    needs = (
        "a row shape of its own: SOC answers per passenger PER SEGMENT, and the FD comparison "
        "would pass a document holding the right number of wrong rows",
        "receipts: the eligible cases answer receipt_validation_required until a receipt is "
        "uploaded, and nothing uploads one",
        "UAT fixtures: the 77 specs are the SIT set, and no UAT card layout is parsed yet",
    )


class Baggage(NotReady):
    flow_id = "baggage"
    label = "Baggage"
    section = "baggageClaimEligibility"
    #: interim expenses are the essentials bought while the bag is missing, so that section is
    #: decided by the bag's delay and belongs here rather than with SOC
    also = ("interimExpensesEligibility",)
    lanes = ("bag_events",)
    #: the bag-event lane exists now (`builder/bag_build.py` publishes the BROCK SmartSuite
    #: history: the AHL opened after the ACTUAL arrival, the carousel delivery, the closure, the
    #: station scan with no record), so nothing below stops a baggage case being built and
    #: published. What remains stops it being JUDGED, which `judge` reports as n/a per case.
    blocks_seeding: tuple[str, ...] = ()
    needs = (
        "a row shape of its own: baggage answers per bag, not per passenger",
        "receipts, for the interim-expenses section: the essentials bought while the bag was "
        "missing are claimed against it",
        # "a set: no baggage scenario has been written" was here until `baggage/sit/po` was
        # imported: 73 scenarios now exist (tools/import_baggage_po.py). They are hand-walked
        # rather than run, because the three needs above still gate judging, not having a set.
    )


class Ancillary(NotReady):
    flow_id = "anc"
    label = "Ancillary refunds"
    #: two sections, bag fees and seat fees. One flow, because the same question is asked of both
    #: in the same shape -- which is also why they are not split into two policies.
    section = "baggageRefundEligibility"
    also = ("seatFeeRefundEligibility",)
    lanes = ("emd",)
    needs = (
        "an EMD publishing lane: both ancillary sections are keyed by EMD number, and no EMD "
        "record reaches a seeded booking today",
        "a row shape of its own: ancillary answers per EMD",
        "a set: no ancillary scenario exists",
    )


POLICIES = (StandardsOfCare(), Baggage(), Ancillary())
NEEDS = {p.flow_id: p.needs for p in POLICIES}
