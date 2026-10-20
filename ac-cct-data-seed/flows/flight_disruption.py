"""Flight disruption: compensation, read from `compensationEligibility`.

FD asks one question of a booking -- what is this passenger owed for this disruption -- so a row is
one passenger under one regime on one bound, and a scenario states the answer once.

This replaces the dict-walking version. Every comparison now goes through a domain value that knows
its own rules, so the five bugs that version shipped cannot be written here:

* `SystemCode.matches` compares suffixes always and regimes only when both sides state one, so a
  scenario's `ND-X02` matches the engine's `FD-APPR-ND-X02` while `NE-01` still differs from `NE-28`
* `Money.equivalent_to(..., eligible=...)` knows a not-eligible row has no amount, so a placeholder
  zero is not a difference
* `DelayBand.comparable_with` refuses to compare prose, and `Minutes` carries the same fact as a
  number
* a missing regime is reported as itself rather than as a string of field differences against some
  other regime's row
* a row count is per passenger per regime-and-bound, not per regime

What this does NOT decide is which engine answered. Two can: the rule-engine platform, where a
verdict could be written ahead of the read, and TripTracer's rebuilt engine, which folds the
booking's event history on every read and stores nothing. The same checks run against either
document, which is the only way the two can be held to the same standard.
"""
from __future__ import annotations

from typing import Any, Iterable

from domain.models import Assessment, AssessmentRow, Check, Scenario
from domain.loyalty import is_basic
from domain.values import DelayBand, Eligibility, Minutes, Money, SystemCode

SECTION = "compensationEligibility"

#: Names that appear in an expectation's `regime` slot but are not regimes, and what they really
#: are. The document carries one block per regime (APPR, ASL, EU); nothing in it can satisfy these,
#: so comparing against them produces a failure about the wrong system. Reported as not applicable
#: with the reason instead -- the same rule as a delay band written as prose.
NOT_A_REGIME = {
    "PAY": "a payment outcome (how the money is paid: BSM e-mail transfer, cheque fallback), "
           "decided by the Claims Dashboard rather than by DDS -- compensationEligibility has no "
           "PAY block and never will",
}

#: What a `MIXED` expectation is about. The document holds one verdict per regime and no combined
#: one, but the cards do say which of them they mean: every MIXED spec's `ttUi` names it --
#: "Most Generous: EU 261 EUR 600 (fixed priority)". So the row to judge is the most generous one,
#: and the only field that cannot be compared is the system code, because `FD-MIXED-EL-01` is the
#: card's own numbering and no regime block will ever answer with it.
#: Six cases (FD_TC_172..175, 177, 178) went unjudged while this was refused outright.
MIXED = "MIXED"


class FlightDisruption:
    """The FD policy. Satisfies `ports.FlowPolicy`."""

    flow_id = "fd"
    label = "Flight Disruption"
    section = SECTION
    lanes: tuple[str, ...] = ("flight_status", "delay_code")
    needs: tuple[str, ...] = ()

    @property
    def ready(self) -> bool:
        return not self.needs

    # ---------------------------------------------------------------- validate

    def validate(self, scenario: Scenario) -> tuple[str, ...]:
        """What this scenario is missing before it can be run as an FD case.

        `states_a_verdict` is required because a case with no stated answer cannot pass or fail, and
        a set whose expectation nobody has stated must not be able to report a pass.
        """
        missing: list[str] = []
        if not scenario.passengers:
            missing.append("no passengers")
        if not scenario.segments:
            missing.append("no segments")
        # a disruption is required only when compensation is expected. A case can assert the
        # opposite -- FD_TC_104 is "moved voluntarily, arrived exactly on the new schedule, no
        # delay" expecting NE-27, and refusing it for having no disruption refuses the case for
        # being the case it is. Its rebooking also arrives via fixes-*.json, which this does not
        # see: validation reads the source spec, the builder builds the patched one.
        if not scenario.has_disruption and scenario.expectation.expects_eligible:
            missing.append("no outcome, rebooking or cancellation, yet compensation is expected")
        if not scenario.expectation.states_a_verdict:
            missing.append("expect.eligibility is not stated, so no verdict can be claimed")
        return tuple(missing)

    # ------------------------------------------------------------------- tags

    def tags(self, scenario: Scenario) -> tuple[str, ...]:
        """What this case IS, in the words a suite picks by: `need: [eligible, appr, delayed]`.

        Derived from the scenario rather than from a run, so a tag is stable across reseeds -- the
        point of picking by state instead of by locator. The vocabulary is deliberately small; a tag
        nobody selects on is noise, and a tag that restates the case id is worse than none.
        """
        want = scenario.expectation
        out: set[str] = {self.flow_id}

        status = (want.eligibility or "").upper()
        if status:
            out.add({"ELIGIBLE": "eligible", "NOT_ELIGIBLE": "not-eligible",
                     "NO_DETERMINATION": "no-determination",
                     "PENDING": "pending"}.get(status, status.lower().replace("_", "-")))
        if want.regime:
            out.add(str(want.regime).lower())
        if want.system_code is not None and want.system_code.is_code:
            out.add(want.system_code.suffix.lower())

        for outcome in scenario.outcomes:
            kind = (outcome.kind or "").lower()
            if kind:
                out.add({"delay": "delayed", "cancel": "cancelled",
                         "cancellation": "cancelled"}.get(kind, kind.replace("_", "-")))
        if any(s.cancel_code for s in scenario.segments):
            out.add("cancelled")

        # the delay band a tester reasons in, from the scenario's own minutes. Not the engine's
        # band: that is a verdict, and these tags describe the booking, not the answer.
        minutes = next((o.arrival_delay.value for o in scenario.outcomes
                        if o.arrival_delay.value), None)
        if minutes:
            out.add("delay-3-6" if 180 <= minutes < 360 else
                    "delay-6-9" if 360 <= minutes < 540 else
                    "delay-9-plus" if minutes >= 540 else "delay-under-3")
        if len({s.bound for s in scenario.segments if s.bound is not None}) > 1:
            out.add("two-bounds")
        if len(scenario.passengers) > 1:
            out.add("multi-pax")
        if any(p.aeroplan_number for p in scenario.passengers):
            out.add("aeroplan")

        # AC Wallet: a case that wants a member, the state that member's wallet is in, and the tier.
        # `wallet-frozen-l2` is the one state the payment flow refuses, so a suite can pick exactly
        # the case that must be turned down -- and `wallet` marks the cases where a wallet
        # checkpoint means anything at all.
        want_loyalty = scenario.loyalty
        if want_loyalty is not None:
            out.add("wallet")
            out.add(f"wallet-{want_loyalty.wallet_state.replace('_', '-')}")
            out.add("tier-basic" if is_basic(want_loyalty.tier)
                    else f"tier-{want_loyalty.tier.lower()}")
            if want_loyalty.expects_refusal:
                out.add("wallet-refused")
            if want_loyalty.members_wanted > 1:
                out.add("wallet-multi-member")
        return tuple(sorted(out))

    # ------------------------------------------------------------------- rows

    def rows(self, assessment: Assessment) -> tuple[AssessmentRow, ...]:
        """One row per passenger per regime-and-bound block.

        The regime is part of the key rather than a filter: a booking can be assessed under more
        than one, and dropping the others would hide a regime the engine applied and the scenario
        did not expect.
        """
        out: list[AssessmentRow] = []
        for index, block in enumerate(assessment.blocks(self.section)):
            regime = block.get("regime")
            bound = block.get("boundRph")
            for p in (block.get("passengerEligibility") or []):
                if not isinstance(p, dict):
                    continue
                comp = p.get("compensationDetails") or {}
                out.append(AssessmentRow(
                    key=(str(regime), str(bound), str(p.get("passengerName")
                                                      or p.get("passengerId") or "")),
                    eligibility=p.get("eligibilityStatus"),
                    system_code=SystemCode.parse(p.get("systemCode")),
                    money=Money.of(comp.get("amount"), comp.get("currency")),
                    delay=Minutes.of(p.get("delayMinutes")),
                    band=DelayBand(comp.get("delayBand")),
                    regime=regime, bound=bound,
                    control=p.get("delayType"),
                    cause=(None if p.get("delayOrCancelCode") in (None, "")
                           else str(p["delayOrCancelCode"])),
                    block=index,
                ))
        return tuple(out)

    # ------------------------------------------------------------------ judge

    def judge(self, scenario: Scenario,
              rows: Iterable[AssessmentRow]) -> tuple[Check, ...]:
        rows = tuple(rows)
        want = scenario.expectation
        out: list[Check] = []

        if not want.states_a_verdict:
            return (Check.na("fd_verdict",
                             "the scenario states no expected eligibility, so there is nothing to "
                             "compare: this case carries inputs only"),)

        out.append(Check.of("fd_section_present", bool(rows),
                            f"{len(rows)} compensation row(s)", expected="at least 1",
                            actual=len(rows), structural=True))
        if not rows:
            return tuple(out)

        regimes = sorted({str(r.regime) for r in rows})
        wanted_regime = str(want.regime or "").upper()
        if wanted_regime == MIXED:
            row = self._most_generous(self._bound_rows(scenario, rows))
            out.append(Check.na("fd_regime",
                                f"MIXED is a composite: the document answers per regime "
                                f"({', '.join(regimes)}) and the card means the most generous of "
                                f"them, so {row.regime} is the row judged here"))
            for check in self._compare(want, row):
                # the card's own MIXED numbering cannot match a per-regime code
                out.append(Check.na("fd_systemCode",
                                    f"the card's {want.system_code} is MIXED numbering; the "
                                    f"{row.regime} row answered {row.system_code}")
                           if check.name == "fd_systemCode" else check)
            out.append(self._row_count(scenario, rows))
            return tuple(out)
        if wanted_regime in NOT_A_REGIME:
            # said once, with the reason, rather than as a string of field differences against a
            # regime block that was never going to exist
            out.append(Check.na("fd_regime",
                                f"{wanted_regime} is not a regime: {NOT_A_REGIME[wanted_regime]}"))
            for name in ("eligibility", "systemCode", "amount", "currency", "delayMin",
                         "control", "delayBand", "cause", "row_count"):
                out.append(Check.na(f"fd_{name}",
                                    f"the expectation is about {wanted_regime}, which this "
                                    f"section does not decide"))
            return tuple(out)
        if want.regime is None:
            out.append(Check.na("fd_regime", "the scenario states no regime"))
            matching = rows
        else:
            matching = tuple(r for r in rows if r.regime == want.regime)
            out.append(Check.of("fd_regime", bool(matching),
                                f"regimes in the document: {', '.join(regimes)}",
                                expected=want.regime, actual=", ".join(regimes)))
            if not matching:
                # The finding is the missing regime. Comparing a scenario's FD-EU-EL-10 against an
                # APPR row would report a code difference and hide the real one.
                for name in ("eligibility", "systemCode", "amount", "currency", "delayMin",
                             "control", "delayBand", "cause"):
                    out.append(Check.na(
                        f"fd_{name}",
                        f"the engine assessed no {want.regime} bound (it assessed: "
                        f"{', '.join(regimes)}), so there is no row to compare"))
                return tuple(out)

        row = self._row_for(scenario, matching)
        out.extend(self._compare(want, row))
        out.append(self._row_count(scenario, rows))
        return tuple(out)

    # --------------------------------------------------------------- internals

    @classmethod
    def _bound_rows(cls, scenario: Scenario,
                    rows: tuple[AssessmentRow, ...]) -> tuple[AssessmentRow, ...]:
        """The rows for the bound the disruption is on, or all of them when that cannot be told."""
        disrupted = {o.seg for o in scenario.outcomes if o.seg is not None}
        bounds = {str(s.bound) for s in scenario.segments
                  if s.seg in disrupted and s.bound is not None}
        if not bounds:
            return rows
        picked = tuple(r for r in rows if r.bound is not None and str(r.bound) in bounds)
        return picked or rows

    @staticmethod
    def _most_generous(rows: tuple[AssessmentRow, ...]) -> AssessmentRow:
        """The row a MIXED card is about: the largest award, eligibility breaking the tie.

        The engine applies a fixed priority between regimes and the cards state the result of it
        ("Most Generous: EU 261 EUR 600"). Comparing the amount is what decides whether that
        priority was applied, so the row with the money is the row to judge; where nothing is
        owed, an eligible row still beats a not-eligible one.
        """
        def rank(row: AssessmentRow) -> tuple[float, int]:
            amount = row.money.amount if row.money and row.money.amount else 0.0
            return (float(amount), 1 if row.is_eligible else 0)

        return max(rows, key=rank)

    @staticmethod
    def _row_for(scenario: Scenario, matching: tuple[AssessmentRow, ...]) -> AssessmentRow:
        """The row for the bound the scenario's disruption is on.

        Taking the first matching row judged the wrong bound on every multi-journey case:
        FD_PO_026 and FD_PO_027 put the delay on bound 2, the engine answered for bound 1 as well,
        and the comparison read bound 1's `delayMinutes=0, control=''` as a defect.
        """
        disrupted = {o.seg for o in scenario.outcomes if o.seg is not None}
        bounds = {s.bound for s in scenario.segments
                  if s.seg in disrupted and s.bound is not None}
        if bounds:
            for r in matching:
                if r.bound is not None and str(r.bound) in {str(b) for b in bounds}:
                    return r
        return matching[0]

    def _compare(self, want: Any, row: AssessmentRow) -> list[Check]:
        out: list[Check] = []

        out.append(Check.of("fd_eligibility",
                            str(want.eligibility).upper() == str(row.eligibility).upper(),
                            f"status={row.eligibility!r} expected {want.eligibility!r}",
                            expected=want.eligibility, actual=row.eligibility))

        if want.system_code is None:
            out.append(Check.na("fd_systemCode", "the scenario states no system code"))
        elif not want.system_code.is_code:
            out.append(Check.na(
                "fd_systemCode",
                f"the scenario's {want.system_code} is not a code the engine can answer with "
                f"(the engine said {row.system_code}); the eligibility comparison is the one that "
                f"holds"))
        else:
            out.append(Check.of("fd_systemCode", want.system_code.matches(row.system_code),
                                f"code={row.system_code} expected {want.system_code}",
                                expected=want.system_code, actual=row.system_code))

        eligible = row.is_eligible and want.expects_eligible
        if want.money.amount is None and want.money.currency is None:
            out.append(Check.na("fd_amount", "the scenario states no amount"))
        else:
            out.append(Check.of("fd_amount", want.money.equivalent_to(row.money, eligible=eligible),
                                f"amount={row.money} expected {want.money}"
                                + ("" if eligible else "; not eligible, so no amount is owed"),
                                expected=want.money, actual=row.money))

        if want.delay.value is None:
            out.append(Check.na("fd_delayMin", "the scenario states no delay"))
        else:
            out.append(Check.of("fd_delayMin", want.delay.equals(row.delay),
                                f"delayMinutes={row.delay} expected {want.delay}",
                                expected=want.delay, actual=row.delay))

        if not want.band.comparable_with(row.band):
            out.append(Check.na(
                "fd_delayBand",
                f"the scenario's band {want.band} is not one the engine returns"
                if want.band.value and not want.band.is_engine_vocabulary else
                f"not eligible, so the row states no band" if not row.is_eligible else
                "the scenario states no band"))
        else:
            out.append(Check.of("fd_delayBand", str(want.band) == str(row.band),
                                f"delayBand={row.band} expected {want.band}",
                                expected=want.band, actual=row.band))

        for name, wanted, got in (("control", want.control, row.control),
                                  ("cause", want.cause, row.cause)):
            if wanted is None:
                out.append(Check.na(f"fd_{name}", f"the scenario states no {name}"))
            else:
                out.append(Check.of(f"fd_{name}", str(wanted) == str(got or ""),
                                    f"{name}={got!r} expected {wanted!r}",
                                    expected=wanted, actual=got))
        return out

    @staticmethod
    def _row_count(scenario: Scenario, rows: tuple[AssessmentRow, ...]) -> Check:
        """One row per passenger per block, where a block is a regime ON A BOUND.

        Counting `passengers x regimes` failed every multi-bound booking: one returned 45
        legitimate rows for a single passenger across three regimes, which is fifteen bounds.
        """
        pax = len(scenario.passengers)
        if not pax:
            return Check.na("fd_row_count", "the scenario states no passengers to count against")
        # count BLOCKS, not distinct (regime, bound) pairs: a document can carry the same pair in
        # several blocks, and FD_PO_016 held 15 rows for 3 passengers across 5 such blocks while
        # only 3 distinct pairs existed -- which this check called a defect.
        blocks = len({r.block for r in rows})
        return Check.of("fd_row_count", len(rows) == pax * blocks,
                        f"{len(rows)} row(s) for {pax} passenger(s) across {blocks} block(s)",
                        expected=pax * blocks, actual=len(rows), structural=True)


POLICY = FlightDisruption()
