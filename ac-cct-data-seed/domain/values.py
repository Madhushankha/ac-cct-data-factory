"""The small values that kept being compared wrongly, as types that cannot be.

Five comparator bugs in one day, every one of them a dict field compared as a string:

* a delay band compared literally, when the scenarios write it as prose
  (`BELOW_THRESHOLD_POST_REPROTECTION`) and three different spellings of the nine-hour band exist
* an amount of `None` compared against a placeholder `0`, when a not-eligible row has no amount
* a short system code (`ND-X02`) compared against the engine's full one (`FD-APPR-ND-X02`)
* a guard for the above written into a loop that never compares the field
* a row count asserting `passengers x regimes`, when a row is per passenger per *bound*

Each was a one-line fix in a 200-line function, and each was found by a result looking implausible
rather than by reading the code. Types are the fix that holds: a `SystemCode` knows it has a regime
prefix that may be absent, a `Money` knows absent is not zero, a `DelayBand` knows which spellings
the engine can actually answer with. The comparison then has nowhere to go wrong.

Nothing here does I/O or imports from the rest of the project, so it can be read and tested on its
own.
"""
from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Final

__all__ = ["Regime", "SystemCode", "Money", "DelayBand", "Eligibility", "Minutes"]

#: The regimes an assessment can apply. `MIXED` is a composite the scenarios use and the engine does
#: not: it answers per regime, and the composite row has no place in the current contract.
Regime = str

#: The bands the engine answers with. Anything else in a spec's `delayBand` is the author
#: describing the case, not naming a value -- 18 edge-pack specs say `APPR_3_TO_6_HOURS`, and about
#: 35 others are one-offs. `delayMin` carries the same fact as a number and is always comparable.
ENGINE_BANDS: Final[frozenset[str]] = frozenset({
    "DELAY_3_TO_LT_6_HOURS", "DELAY_6_TO_LT_9_HOURS", "DELAY_GTE_9_HOURS",
    "DELAY_BELOW_3_HOURS", "NOT_APPLICABLE",
})

_CODE = re.compile(r"^(?:FD-(?P<regime>[A-Z]+(?:\([A-Z]+\))?)-)?(?P<suffix>[A-Z]+-[A-Z0-9]+)$")


@dataclass(frozen=True, slots=True)
class SystemCode:
    """A verdict code, which the two sides spell differently.

    The engine always answers in full -- `FD-APPR-ND-X02`. A scenario may state the full form or
    just the suffix -- `ND-X02` -- and FD_TC_100 does exactly that. Comparing the strings reports a
    difference between a code and itself.

    `matches` compares as far as both sides are specific: suffixes always, and the regime only when
    both state one. So `ND-X02` matches `FD-APPR-ND-X02`, while `NE-01` does not match
    `FD-APPR-NE-28` -- that one is a real difference, and it is the error the review table corrects
    five times over, because NE-01 means an employee booking.
    """
    raw: str
    regime: str | None
    suffix: str

    @classmethod
    def parse(cls, value: str | None) -> "SystemCode | None":
        if not value:
            return None
        text = str(value).strip().upper()
        m = _CODE.match(text)
        if not m:
            # not a code at all: NON_FLIGHT_SEGMENT_DISRUPTION, or a band in the code field
            return cls(raw=text, regime=None, suffix="")
        return cls(raw=text, regime=m.group("regime"), suffix=m.group("suffix"))

    @property
    def is_code(self) -> bool:
        """False for a value that is not a code: a band, a label, a sentence."""
        return bool(self.suffix)

    def matches(self, other: "SystemCode | None") -> bool:
        if other is None or not (self.is_code and other.is_code):
            return False
        if self.suffix != other.suffix:
            return False
        if self.regime and other.regime:
            return self.regime == other.regime
        return True

    def __str__(self) -> str:
        return self.raw


@dataclass(frozen=True, slots=True)
class Money:
    """An amount with its currency, where **absent is not zero**.

    A not-eligible row carries no `compensationDetails`, so there is no amount -- correctly, since
    nothing is owed. The scenarios write `amount: 0, currency: "CAD"` as a placeholder. Comparing
    those literally produced 29 false differences in one batch of fifty, and 30 more on currency.

    `equivalent_to` treats absent and zero as the same when nothing is owed, and compares properly
    when something is.
    """
    amount: float | None
    currency: str | None

    @classmethod
    def of(cls, amount: object, currency: object) -> "Money":
        try:
            value = None if amount is None else float(amount)  # type: ignore[arg-type]
        except (TypeError, ValueError):
            value = None
        return cls(amount=value, currency=(str(currency) if currency else None))

    @property
    def is_nothing(self) -> bool:
        return self.amount is None or self.amount == 0

    def equivalent_to(self, other: "Money", *, eligible: bool) -> bool:
        if not eligible:
            # nothing is owed; a placeholder zero and an absent figure say the same thing
            return self.is_nothing and other.is_nothing
        if self.amount is None or other.amount is None:
            return False
        if self.amount != other.amount:
            return False
        if self.currency and other.currency:
            return self.currency.upper() == other.currency.upper()
        return True

    def __str__(self) -> str:
        return "—" if self.amount is None else f"{self.amount:g} {self.currency or ''}".strip()


@dataclass(frozen=True, slots=True)
class DelayBand:
    """A delay band, which is only worth comparing when both sides use the engine's vocabulary."""
    value: str | None

    @property
    def is_engine_vocabulary(self) -> bool:
        return bool(self.value) and str(self.value) in ENGINE_BANDS

    def comparable_with(self, other: "DelayBand") -> bool:
        """Whether comparing these two says anything at all."""
        return self.is_engine_vocabulary and other.value is not None

    def __str__(self) -> str:
        return self.value or "—"


@dataclass(frozen=True, slots=True)
class Minutes:
    """A delay in minutes: the fact a band only labels, and the one always worth comparing."""
    value: int | None

    @classmethod
    def of(cls, raw: object) -> "Minutes":
        try:
            return cls(None if raw is None else int(raw))  # type: ignore[arg-type]
        except (TypeError, ValueError):
            return cls(None)

    def equals(self, other: "Minutes") -> bool:
        return self.value is not None and self.value == other.value

    def __str__(self) -> str:
        return "—" if self.value is None else str(self.value)


class Eligibility:
    """The statuses an assessment can report. Not an enum: the engine may add one, and a value we
    do not know is data to report, not an error to raise."""

    ELIGIBLE: Final = "ELIGIBLE"
    NOT_ELIGIBLE: Final = "NOT_ELIGIBLE"
    NO_DETERMINATION: Final = "NO_DETERMINATION"
    PENDING: Final = "PENDING"

    @staticmethod
    def is_eligible(value: str | None) -> bool:
        return (value or "").strip().upper() == Eligibility.ELIGIBLE
