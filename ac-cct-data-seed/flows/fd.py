"""Flight disruption: compensation, read from `compensationEligibility`.

FD asks one question of the booking -- what is this passenger owed for this disruption -- so a row
is one passenger, and a spec's `expect` states the answer once.

What this does NOT decide is which engine answers. Two do: the rule-engine platform, where a
verdict can be written ahead of the read, and TripTracer's rebuilt engine, which folds the booking's
event history on every read and stores nothing. This module reads a document and compares it; where
that document came from is the caller's business, and the same checks run against either. That is
deliberate -- the comparison is the only thing both engines can be held to.
"""
from __future__ import annotations

from core.flow import Check, Flow, Row

#: The bands the engine actually returns. A spec value outside this set is a LABEL the scenario
#: author wrote, not a value the engine could answer, so comparing it would manufacture a
#: disagreement out of a naming difference.
#:
#: Measured across the imported specs: 107 use these names, 18 of the edge pack use APPR_3_TO_6_HOURS
#: or APPR_6_TO_LT_9_HOURS, and about 35 are one-offs -- three spellings of the nine-hour band alone
#: (DELAY_GTE_9_HOURS, DELAY_GE_9_HOURS, DELAY_9_HOURS_PLUS), plus prose like
#: BELOW_THRESHOLD_POST_REPROTECTION. `delayMin` is the fact and is compared always; the band is
#: compared only when the spec states one the engine recognises.
ENGINE_BANDS = frozenset({
    "DELAY_3_TO_LT_6_HOURS", "DELAY_6_TO_LT_9_HOURS", "DELAY_GTE_9_HOURS",
    "DELAY_BELOW_3_HOURS", "NOT_APPLICABLE",
})

#: `expect` fields this flow compares, and the row field each is compared against.
_COMPARED = (("eligibility", "status"), ("systemCode", "code"),
             ("amount", "amount"), ("currency", "currency"))


def _num(v) -> float | None:
    try:
        return float(v)
    except (TypeError, ValueError):
        return None


class FlightDisruption(Flow):
    id = "fd"
    label = "Flight Disruption"
    section = "compensationEligibility"
    lanes = ("flight_status", "delay_code")
    needs = ()

    def _blocks(self, document: dict) -> list[dict]:
        """This flow's section, from either document shape, top level first."""
        top = document.get(self.section)
        if top:
            return [b for b in top if isinstance(b, dict)]
        out = []
        for bound in (document.get("bounds") or []):
            if isinstance(bound, dict):
                out += [b for b in (bound.get(self.section) or []) if isinstance(b, dict)]
        return out

    def validate(self, spec: dict) -> list[str]:
        """A spec can state an FD question when it has a passenger, a segment and an outcome.

        `expect.eligibility` is required because a case with no stated answer cannot pass or fail,
        and a set whose expectation nobody has stated must not be able to report a pass. The
        41 table-derived cases are exactly that, and they fail here by design until someone states
        their verdicts.
        """
        missing = []
        if not spec.get("passengers"):
            missing.append("no passengers")
        if not spec.get("segments"):
            missing.append("no segments")
        if not (spec.get("outcomes") or spec.get("rebooking") or spec.get("scheduleChanges")):
            missing.append("no outcome, rebooking or schedule change: nothing was disrupted")
        exp = spec.get("expect") or {}
        if not exp.get("eligibility"):
            missing.append("expect.eligibility is not stated, so no verdict can be claimed")
        return missing

    def rows(self, document: dict) -> list[Row]:
        """One row per passenger per regime block of `compensationEligibility`.

        The regime is part of the key rather than a filter: a booking can be assessed under more
        than one, and dropping the extra blocks would hide a regime the engine applied and the
        spec did not expect.

        Two document shapes arrive here and both are read. tt-api's own answer to
        `POST /api/dds-evaluations` nests the sections under `bounds[]`; case-services flattens
        them to the top level (`_normalize_dds_output`) before its consumers see them, which is the
        shape the by-PNR endpoint returns and the shape the kit's gate reads. Accepting only one of
        them would mean finding no rows in a real document and reporting the section as absent --
        a wrong answer that looks exactly like a correct one.
        """
        out = []
        for block in self._blocks(document):
            regime = block.get("regime")
            for p in (block.get("passengerEligibility") or []):
                comp = p.get("compensationDetails") or {}
                out.append(Row(
                    key=(str(regime), str(p.get("passengerName") or p.get("passengerId") or "")),
                    status=p.get("eligibilityStatus"),
                    code=p.get("systemCode"),
                    amount=_num(comp.get("amount")),
                    currency=comp.get("currency"),
                    extra={"regime": regime, "bound": block.get("boundRph"),
                           "delayMinutes": p.get("delayMinutes"),
                           "delayType": p.get("delayType"),
                           "delayBand": comp.get("delayBand"),
                           "cause": p.get("delayOrCancelCode")},
                ))
        return out

    def checks(self, spec: dict, rows: list[Row]) -> list[Check]:
        exp = spec.get("expect") or {}
        out: list[Check] = []

        if not exp.get("eligibility"):
            return [Check.na("fd_verdict", "the spec states no expected eligibility, so there is "
                                           "nothing to compare: this case carries inputs only")]

        out.append(Check("fd_section_present", True, bool(rows),
                         f"{len(rows)} compensation row(s)", expected="at least 1",
                         actual=str(len(rows))))
        if not rows:
            return out

        want_regime = exp.get("regime")
        matching = [r for r in rows if want_regime is None or r.extra.get("regime") == want_regime]
        out.append(Check("fd_regime", want_regime is not None, bool(matching),
                         f"regimes in the document: {sorted({str(r.extra.get('regime')) for r in rows})}",
                         expected=str(want_regime),
                         actual=", ".join(sorted({str(r.extra.get("regime")) for r in rows})))
                   if want_regime is not None else
                   Check.na("fd_regime", "the spec states no regime"))

        # When the spec names a regime the engine did not assess, the finding is THAT -- not a
        # string of field differences against some other regime's row. Comparing a spec's
        # FD-EU-EL-10 against an APPR row reports a code difference and hides the real one: the
        # engine produced no EU assessment at all. So the fields report n/a with that reason.
        if want_regime is not None and not matching:
            present = ", ".join(sorted({str(x.extra.get("regime")) for x in rows})) or "none"
            for name in ("eligibility", "systemCode", "amount", "currency", "delayMin",
                         "control", "delayBand", "cause"):
                out.append(Check.na(f"fd_{name}",
                                    f"the engine assessed no {want_regime} bound "
                                    f"(it assessed: {present}), so there is no row to compare"))
            return out

        r = (matching or rows)[0]
        # A row that is not eligible carries NO compensationDetails, so amount and currency are
        # absent -- correctly, because there is nothing owed. The scenarios write `amount: 0` and a
        # currency as placeholders, and comparing those literally made 29 of 31 amount differences
        # and all 30 currency differences in one batch out of nothing. An absent figure on a
        # not-eligible row IS zero.
        not_eligible = (r.status or "").upper() != "ELIGIBLE"
        for exp_key, row_attr in _COMPARED:
            want = exp.get(exp_key)
            got = getattr(r, row_attr)
            if want is None:
                out.append(Check.na(f"fd_{exp_key}", f"the spec states no {exp_key}"))
                continue
            # A not-eligible row carries no band either, for the same reason it carries no amount.
            if exp_key == "delayBand" and got is None and not_eligible:
                out.append(Check.na("fd_delayBand",
                                    "not eligible, so the row states no band"))
                continue
            # The scenarios write a system code both ways: FD_TC_100 expects 'ND-X02' where the
            # engine answers 'FD-APPR-ND-X02' -- the same code, short. Compare the suffix when the
            # expectation omits the FD-<regime>- prefix, and the whole string when it does not.
            if exp_key == "systemCode" and want and got and not str(want).upper().startswith("FD-"):
                same = str(got).upper().endswith(str(want).upper())
                out.append(Check("fd_systemCode", True, same,
                                 f"code={got!r} expected {want!r} (compared as a suffix: the "
                                 f"spec omits the FD-<regime>- prefix)",
                                 expected=str(want), actual=str(got)))
                continue
            if (exp_key in ("amount", "currency") and got is None and not_eligible
                    and (exp_key == "currency" or _num(want) in (0, None))):
                out.append(Check.na(f"fd_{exp_key}",
                                    f"not eligible, so the row carries no {exp_key}; "
                                    f"the spec's {want!r} is a placeholder"))
                continue
            same = (_num(want) == _num(got)) if _num(want) is not None else str(want) == str(got)
            out.append(Check(f"fd_{exp_key}", True, same, f"{row_attr}={got!r} expected {want!r}",
                             expected=str(want), actual=str(got)))

        for exp_key, extra_key in (("delayMin", "delayMinutes"), ("control", "delayType"),
                                   ("delayBand", "delayBand"), ("cause", "cause")):
            want = exp.get(exp_key)
            got = r.extra.get(extra_key)
            if want is None:
                out.append(Check.na(f"fd_{exp_key}", f"the spec states no {exp_key}"))
                continue
            # A not-eligible row carries no compensationDetails, so no band -- correctly, because
            # there is nothing to band. The guard for this was first written into the loop above,
            # where `delayBand` is never compared, so it did nothing: ten cases that agreed on
            # status, code AND minutes were still reported as disagreeing (FD_TC_047: NOT_ELIGIBLE,
            # FD-APPR-NE-05, 420 min on both sides).
            if exp_key == "delayBand" and got is None and not_eligible:
                out.append(Check.na("fd_delayBand", "not eligible, so the row states no band"))
                continue
            if exp_key == "delayBand" and str(want) not in ENGINE_BANDS:
                # a label, not a value the engine answers with: the minutes carry the same fact and
                # are compared above
                out.append(Check.na("fd_delayBand",
                                    f"the spec's band {want!r} is not one the engine returns; "
                                    f"delayMin is the comparison that matters"))
                continue
            same = (_num(want) == _num(got)) if _num(want) is not None else str(want) == str(got)
            out.append(Check(f"fd_{exp_key}", True, same, f"{extra_key}={got!r} expected {want!r}",
                             expected=str(want), actual=str(got)))

        # One row per passenger per BLOCK, and a block is a regime on a bound -- not a regime on
        # its own. This read `passengers x regimes` and so failed any multi-bound booking: ZZCN8V
        # returned 45 legitimate rows for one passenger across three regimes, which is fifteen
        # bounds, and the check called it a defect. A spec that states no passengers (several edge
        # cases do) cannot support the arithmetic at all, so it reports n/a rather than guessing.
        pax = len([p for p in (spec.get("passengers") or []) if p])
        blocks = len({(r.extra.get("regime"), r.extra.get("bound")) for r in rows})
        if not pax:
            out.append(Check.na("fd_row_count", "the spec states no passengers to count against"))
            return out
        out.append(Check("fd_row_count", True, len(rows) == pax * blocks,
                         f"{len(rows)} row(s) for {pax} passenger(s) across {blocks} "
                         f"regime/bound block(s)",
                         expected=f"{pax * blocks}", actual=str(len(rows))))
        return out


FLOW = FlightDisruption()
