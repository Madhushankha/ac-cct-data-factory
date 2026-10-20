"""What a flow has to supply, and what it must not.

Four things differ per flow and nothing else does:

1. **Which spec fields it needs.** FD needs an outcome on a segment; baggage needs a bag; ancillary
   needs an EMD. A spec that cannot express the flow's question is a data error, and saying so at
   load time is cheaper than a run that fails at the verdict.
2. **Which extra lanes it publishes.** Every flow publishes a booking (PNR, TKT). Beyond that: FD
   adds flight status and the delay code, baggage adds bag events, ancillary adds EMDs.
3. **Which section of the assessment it reads, and the shape of a row in it.** This is the real
   split. FD asks one question of the whole booking -- one status, one code, one amount. SOC asks
   per passenger PER SEGMENT. Baggage asks per bag, ancillary per EMD. A reader built for one shape
   passes a document holding the right number of wrong rows for another.
4. **Its own claims.** The checks that only make sense for it.

Everything else is shared and must stay single: the spec schema and its compact form, identity
reservation, the booking publish, the runner, the evidence, and the booking-level checks (contact,
tickets, passengers, segments, times). Two implementations of those are how one seeder ended up
pinning a verdict while another computed it, and why their results cannot be compared.

A flow that is not ready says so in `needs`. A flow with a non-empty `needs` can still render and
publish bookings; what it cannot do is claim a verdict, and the runner refuses to report a pass for
one rather than printing a tick for a check that never ran.
"""
from __future__ import annotations

import abc
from dataclasses import dataclass, field
from typing import Any

#: The six sections, and which flow owns each. Declared in `domain/sections.py`, which is
#: also what `flows/registry.py` checks its policies against -- one declaration, so the two
#: registries cannot come to disagree about who reads what.
from domain.sections import SECTIONS  # noqa: E402


@dataclass(frozen=True)
class Row:
    """One row of an assessment section, in the terms every flow shares.

    `key` is what the row is ABOUT, and its meaning is the flow's: a passenger for FD, a passenger
    and segment for SOC, a bag for baggage, an EMD for ancillary. Keeping it opaque here is what
    lets one comparison serve all four.
    """
    key: tuple[str, ...]
    status: str | None = None
    code: str | None = None
    amount: float | None = None
    currency: str | None = None
    extra: dict[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class Check:
    """One claim, its outcome, and what was actually seen.

    `applies=False` is a first-class result, not a pass. A check that could not run reports n/a and
    says why; a green tick for a check that never ran is the one result this must never print.
    """
    name: str
    applies: bool
    ok: bool | None
    detail: str
    expected: str = ""
    actual: str = ""

    @classmethod
    def na(cls, name: str, why: str) -> "Check":
        return cls(name=name, applies=False, ok=None, detail=why)


class Flow(abc.ABC):
    """One flow's implementation. Four members and three methods, nothing more."""

    #: short id, as used in a spec's `family` and on the command line
    id: str = ""
    label: str = ""
    #: the assessment section this flow reads; must be a key of SECTIONS
    section: str = ""
    #: publish lanes beyond the booking itself
    lanes: tuple[str, ...] = ()
    #: empty when the flow can claim a verdict; otherwise what is missing, in the user's terms
    needs: tuple[str, ...] = ()

    @property
    def ready(self) -> bool:
        return not self.needs

    @abc.abstractmethod
    def validate(self, spec: dict) -> list[str]:
        """What this spec is missing for this flow. Empty means it can be run."""

    @abc.abstractmethod
    def rows(self, document: dict) -> list[Row]:
        """The flow's own section of an assessment document, as rows."""

    @abc.abstractmethod
    def checks(self, spec: dict, rows: list[Row]) -> list[Check]:
        """This flow's claims about those rows, given what the spec expects."""

    def __repr__(self) -> str:                                      # pragma: no cover - diagnostics
        return f"<{type(self).__name__} {self.id} section={self.section} ready={self.ready}>"
