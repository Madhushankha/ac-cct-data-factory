"""Flow lookup, and the one invariant that keeps the six sections honest.

Every section of the assessment document has exactly one flow that reads it. A section nobody reads
is coverage silently missing; a section two flows read is two answers to one question. The check
runs at import, so neither can be introduced without the next run saying so.
"""
from __future__ import annotations

from core.flow import SECTIONS, Flow
from flows.fd import FLOW as FD
from flows.pending import FLOWS as PENDING

ALL: tuple[Flow, ...] = (FD, *PENDING)
BY_ID = {f.id: f for f in ALL}


def get(flow_id: str) -> Flow:
    try:
        return BY_ID[flow_id]
    except KeyError:
        raise KeyError(f"no such flow {flow_id!r}; known: {', '.join(sorted(BY_ID))}") from None


def ready() -> tuple[Flow, ...]:
    """The flows that can claim a verdict today."""
    return tuple(f for f in ALL if f.ready)


def sections_covered() -> dict[str, str | None]:
    """Each section, and the flow that reads it -- None where nothing does."""
    owners: dict[str, str | None] = {s: None for s in SECTIONS}
    for f in ALL:
        if f.section in owners:
            owners[f.section] = f.id
    return owners


def _check_sections() -> None:
    claimed: dict[str, list[str]] = {}
    for f in ALL:
        if f.section not in SECTIONS:
            raise ValueError(f"flow {f.id!r} reads {f.section!r}, which is not an assessment section")
        claimed.setdefault(f.section, []).append(f.id)
    for section, flows in claimed.items():
        if len(flows) > 1:
            raise ValueError(f"section {section!r} is read by {flows}: one section, one flow")
        expected = SECTIONS[section]
        if expected not in flows:
            raise ValueError(f"section {section!r} belongs to {expected!r} but is read by {flows}")


_check_sections()
