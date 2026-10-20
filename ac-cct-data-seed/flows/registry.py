"""Which policy answers for a flow, and the invariant that keeps the six sections honest.

Adding a flow is: write a policy satisfying `ports.FlowPolicy`, and add it to `POLICIES` below.
Nothing else changes -- not the builder, not the publisher, not the reader, not the store, not the
CLI. That is what the ports are for.

The invariant runs at import, so neither of these can be introduced quietly:

* **a section no flow reads** is coverage that is silently missing;
* **a section two flows read** is two answers to one question, which is how one seeder came to pin a
  verdict while another computed it, leaving their results incomparable.

`domain/sections.py` holds who owns what. A policy's `section` and `also` are checked against it
rather than trusted, because a policy declaring the wrong section would otherwise read a document
that answers a different question and report agreement about it.
"""
from __future__ import annotations

from domain.sections import SECTIONS
from flows.flight_disruption import POLICY as FD
from flows.not_ready import POLICIES as NOT_READY
from ports import FlowPolicy

#: every flow this project knows. Order is the order a report lists them in.
POLICIES: tuple[FlowPolicy, ...] = (FD, *NOT_READY)

BY_ID: dict[str, FlowPolicy] = {p.flow_id: p for p in POLICIES}


def get(flow_id: str) -> FlowPolicy:
    """The policy for a flow id, raising with the known ids rather than returning None."""
    try:
        return BY_ID[flow_id]
    except KeyError:
        raise KeyError(f"no such flow {flow_id!r}; known: {', '.join(sorted(BY_ID))}") from None


def for_set(set_name: str) -> FlowPolicy:
    """The policy for a spec set: `fd/uat/automation` -> the FD policy.

    The set's first path segment IS the flow id, which is why the spec tree uses `anc` rather than
    `ancillary`: a mapping table between folder names and flow ids is a place for them to drift.
    """
    return get(set_name.strip("/").split("/")[0])


def ready() -> tuple[FlowPolicy, ...]:
    """The flows that can claim a verdict today."""
    return tuple(p for p in POLICIES if not p.needs)


def sections() -> dict[str, str | None]:
    """Each of the six sections, and the flow that reads it -- None where nothing does."""
    owners: dict[str, str | None] = {s: None for s in SECTIONS}
    for p in POLICIES:
        for section in (p.section, *getattr(p, "also", ())):
            if section in owners:
                owners[section] = p.flow_id
    return owners


def _check() -> None:
    claimed: dict[str, list[str]] = {}
    for p in POLICIES:
        if not isinstance(p, FlowPolicy):
            raise TypeError(f"{p!r} does not satisfy ports.FlowPolicy")
        for section in (p.section, *getattr(p, "also", ())):
            if section not in SECTIONS:
                raise ValueError(f"flow {p.flow_id!r} reads {section!r}, which is not one of the "
                                 f"six assessment sections")
            claimed.setdefault(section, []).append(p.flow_id)
    for section, flows in claimed.items():
        if len(flows) > 1:
            raise ValueError(f"section {section!r} is read by {flows}: one section, one flow")
        if SECTIONS[section] != flows[0]:
            raise ValueError(f"section {section!r} belongs to {SECTIONS[section]!r} but is read by "
                             f"{flows[0]!r}; domain/sections.py is the record")
    unread = [s for s, owner in sections().items() if owner is None]
    if unread:
        raise ValueError(f"no flow reads {unread}: that is coverage silently missing")


_check()
