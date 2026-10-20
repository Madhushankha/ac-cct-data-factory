"""The nouns: a scenario, a booking, what the engine answered, and what a run found.

These were dicts. A dict is fine until two of them have nearly the same keys and one is the
scenario's claim while the other is the engine's answer -- then every comparison is a guess at
which is which, and a typo in a key reads as a missing value rather than an error.

Each type parses from the shape it arrives in (the kit's spec JSON, a batch manifest row, an
assessment document) and keeps only what the project uses. Nothing here does I/O.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Iterator

from domain.loyalty import LoyaltyRequest
from domain.values import DelayBand, Eligibility, Minutes, Money, SystemCode

__all__ = ["Expectation", "Passenger", "Segment", "Outcome", "Scenario", "Booking",
           "AssessmentRow", "Assessment", "Check", "CaseResult"]


@dataclass(frozen=True, slots=True)
class Expectation:
    """What a scenario says the engine should answer.

    Built from a spec's or a manifest's `expect` block. The values are typed, so a comparison does
    not have to remember that an amount may be a placeholder or a code may lack its prefix.
    """
    regime: str | None
    eligibility: str | None
    system_code: SystemCode | None
    money: Money
    delay: Minutes
    band: DelayBand
    control: str | None
    cause: str | None
    extras: dict[str, Any] = field(default_factory=dict)

    #: `expect` keys that have a home above; anything else lands in `extras`
    _KNOWN = ("regime", "eligibility", "systemCode", "amount", "currency", "delayMin",
              "delayBand", "control", "cause", "ttUi",
              # the stored form's own keys, so re-reading a record does not fill `extras`
              "system_code", "money", "delay", "band", "extras")

    @staticmethod
    def _flat(d: dict[str, Any]) -> dict[str, Any]:
        """Accept the stored shape as well as a spec's or manifest's `expect` block.

        A run record writes the PARSED expectation -- `{"delay": {"value": 240}, "money":
        {"amount": 400.0, ...}, "system_code": {"raw": ...}}` -- and reading it back through the
        manifest keys (`delayMin`, `amount`, `systemCode`) silently produced an expectation that
        stated only its regime and eligibility. Every other check then reported "the scenario
        states no ..." and passed, so `cli judge` scored a stored run 196/264 where the run itself
        scored 176/264: twenty cases, including the 240-against-480 collisions, agreed by default.
        A comparison that loses its expectation must not be able to report agreement.
        """
        if not any(k in d for k in ("system_code", "money", "delay", "band")):
            return d
        out = dict(d)
        code = d.get("system_code")
        if isinstance(code, dict):
            out.setdefault("systemCode", code.get("raw"))
        money = d.get("money")
        if isinstance(money, dict):
            out.setdefault("amount", money.get("amount"))
            out.setdefault("currency", money.get("currency"))
        delay = d.get("delay")
        if isinstance(delay, dict):
            out.setdefault("delayMin", delay.get("value"))
        band = d.get("band")
        if isinstance(band, dict):
            out.setdefault("delayBand", band.get("value"))
        return out

    @classmethod
    def parse(cls, raw: dict[str, Any] | None) -> "Expectation":
        d = cls._flat(raw or {})
        return cls(
            regime=d.get("regime"),
            eligibility=d.get("eligibility"),
            system_code=SystemCode.parse(d.get("systemCode")),
            money=Money.of(d.get("amount"), d.get("currency")),
            delay=Minutes.of(d.get("delayMin")),
            band=DelayBand(d.get("delayBand")),
            control=d.get("control"),
            cause=None if d.get("cause") is None else str(d.get("cause")),
            extras={k: v for k, v in d.items() if k not in cls._KNOWN and v is not None},
        )

    @property
    def states_a_verdict(self) -> bool:
        """Whether this scenario claims an answer at all.

        A set whose expectation nobody has stated must not be able to report a pass. The 41
        table-derived FD cases are exactly that: inputs, and no expected status.
        """
        return bool(self.eligibility)

    @property
    def expects_eligible(self) -> bool:
        return Eligibility.is_eligible(self.eligibility)


@dataclass(frozen=True, slots=True)
class Passenger:
    type: str | None
    first_name: str | None
    last_name: str | None
    residence: str | None = None
    date_of_birth: str | None = None
    aeroplan_number: str | None = None
    aeroplan_tier: str | None = None
    employee: bool = False

    @property
    def full_name(self) -> str:
        return " ".join(x for x in (self.first_name, self.last_name) if x)


@dataclass(frozen=True, slots=True)
class Segment:
    seg: int | None
    bound: int | None
    carrier: str | None
    number: str | None
    origin: str | None
    destination: str | None
    dep_local: str | None
    arr_local: str | None
    dep_date: str | None = None
    status: str | None = None
    cancel_code: str | None = None

    @property
    def flight_key(self) -> str:
        """carrier#number#day#origin -- the identity two bookings must not share."""
        return f"{self.carrier}#{self.number}#{self.dep_date or ''}#{self.origin}"


@dataclass(frozen=True, slots=True)
class Outcome:
    """What happened to a segment: a delay, a cancellation, a diversion, or nothing."""
    seg: int | None
    kind: str | None
    arrival_delay: Minutes = Minutes(None)
    departure_delay: Minutes = Minutes(None)
    delay_code: str | None = None
    cancel_code: str | None = None

    @property
    def is_disruption(self) -> bool:
        return bool(self.arrival_delay.value or self.cancel_code or self.kind in ("cancel", "divert"))


@dataclass(frozen=True, slots=True)
class Scenario:
    """One test case: who flew, what happened, and what the engine should say about it."""
    case_id: str
    family: str
    expectation: Expectation
    passengers: tuple[Passenger, ...] = ()
    segments: tuple[Segment, ...] = ()
    outcomes: tuple[Outcome, ...] = ()
    summary: str = ""
    source: dict[str, Any] = field(default_factory=dict)
    #: what the case asks of AC Wallet / Aeroplan, or None when it is not a loyalty case. A wallet
    #: decision is made against a customer profile, which no booking creates, so this is a separate
    #: thing to seed rather than a field on a passenger.
    loyalty: LoyaltyRequest | None = None
    #: the booking office. `...ES` is staff travel and `...AA` an ordinary agency booking, and the
    #: engine decides employee eligibility from it -- so a case about an employee is only that case
    #: if its office says so.
    office_id: str = ""

    @classmethod
    def parse(cls, raw: dict[str, Any]) -> "Scenario":
        return cls(
            case_id=raw.get("id") or raw.get("case_id") or "",
            family=(raw.get("family") or "FD"),
            expectation=Expectation.parse(raw.get("expect")),
            passengers=tuple(
                Passenger(type=p.get("type"), first_name=p.get("firstName"),
                          last_name=p.get("lastName"), residence=p.get("residence"),
                          date_of_birth=p.get("dob"),
                          aeroplan_number=p.get("aeroplanNumber"),
                          aeroplan_tier=p.get("aeroplanTier"),
                          employee=bool(p.get("employee")))
                for p in (raw.get("passengers") or []) if isinstance(p, dict)),
            segments=tuple(
                Segment(seg=s.get("seg"), bound=s.get("bound"), carrier=s.get("carrier"),
                        number=None if s.get("number") is None else str(s.get("number")),
                        origin=s.get("origin"), destination=s.get("destination"),
                        dep_local=s.get("depLocal"), arr_local=s.get("arrLocal"),
                        dep_date=s.get("depDate"), status=s.get("status"),
                        cancel_code=s.get("cancelCode"))
                for s in (raw.get("segments") or []) if isinstance(s, dict)),
            outcomes=tuple(
                Outcome(seg=o.get("seg"), kind=o.get("kind"),
                        arrival_delay=Minutes.of(o.get("arrDelayMin")),
                        departure_delay=Minutes.of(o.get("depDelayMin")),
                        delay_code=None if o.get("delayCode") is None else str(o["delayCode"]),
                        cancel_code=o.get("cancelCode"))
                for o in (raw.get("outcomes") or []) if isinstance(o, dict)),
            summary=(raw.get("summary") or "").strip(),
            source=raw.get("source") or {},
            loyalty=LoyaltyRequest.parse(
                raw.get("loyalty"),
                tuple(p for p in (raw.get("passengers") or []) if isinstance(p, dict))),
            office_id=str(((raw.get("pointOfSale") or raw.get("point_of_sale")) or {})
                          .get("officeId")
                          or ((raw.get("pointOfSale") or raw.get("point_of_sale")) or {})
                          .get("office_id") or ""),
        )

    @property
    def wants_loyalty(self) -> bool:
        """Whether this case needs a member minted and attached before it can be judged."""
        return self.loyalty is not None

    @property
    def has_disruption(self) -> bool:
        return any(o.is_disruption for o in self.outcomes) or any(
            s.cancel_code for s in self.segments)


@dataclass(frozen=True, slots=True)
class Booking:
    """A booking that was seeded: which scenario it is, and how to find it."""
    case_id: str
    locator: str
    pnr_id: str
    expectation: Expectation
    passenger_name: str = ""
    flight: str = ""
    route: str = ""
    flight_date: str = ""
    #: the disruption as PUBLISHED, one entry per leg: `key`, `kind`, `minutes`, `code`.
    #: The expectation says what the card wants; this says what actually went out, and the two
    #: differ by design where a patch publishes only part of the delay (FD_TC_009 publishes a
    #: 120-minute remainder on top of a 120-minute involuntary schedule change to reach 240).
    #: Without it, a comparison of the engine against the card cannot tell a rule question from a
    #: booking that never carried the disruption.
    published: tuple[dict[str, Any], ...] = ()

    @classmethod
    def from_manifest(cls, row: dict[str, Any]) -> "Booking":
        flights = row.get("flights") or [{}]
        f = flights[0] if isinstance(flights[0], dict) else {}
        legs = []
        for leg in flights:
            if not isinstance(leg, dict):
                continue
            day = str(leg.get("depUtc") or "")[:10]
            legs.append({
                "key": f"{leg.get('carrier', '')}#{leg.get('number', '')}#{day}#"
                       f"{leg.get('origin', '')}",
                "kind": leg.get("kind"),
                "minutes": leg.get("minutes"),
                "code": leg.get("code") or leg.get("arrivalCode"),
            })
        return cls(
            case_id=row.get("id") or "",
            locator=row.get("locator") or "",
            pnr_id=row.get("pnrId") or "",
            expectation=Expectation.parse(row.get("expect")),
            flight=f"{f.get('carrier', '')}{f.get('number', '')}",
            route=f"{f.get('origin', '')}-{f.get('destination', '')}",
            flight_date=(f.get("depUtc") or "")[:10],
            published=tuple(legs),
        )


@dataclass(frozen=True, slots=True)
class AssessmentRow:
    """One row of an assessment section: what the engine decided, and for whom.

    `key` is what the row is ABOUT, and its meaning belongs to the flow: a passenger and regime for
    FD, a passenger and segment for SOC, a bag for baggage, an EMD for ancillary. Keeping it opaque
    is what lets one comparison serve all four.
    """
    key: tuple[str, ...]
    eligibility: str | None
    system_code: SystemCode | None
    money: Money
    delay: Minutes
    band: DelayBand
    regime: str | None = None
    bound: Any = None
    control: str | None = None
    cause: str | None = None
    #: which block of the section this row came from. The same (regime, bound) pair can appear in
    #: more than one block, so counting distinct pairs undercounts the rows a document should hold.
    block: int = 0

    @property
    def is_eligible(self) -> bool:
        return Eligibility.is_eligible(self.eligibility)


@dataclass(frozen=True, slots=True)
class Assessment:
    """An engine's answer for one booking: the rows, and which engine answered.

    The document arrives in two shapes -- the sections nested under `bounds[]`, as tt-api answers,
    or flattened to the top level, as case-services normalises it before its consumers see it.
    `blocks` reads either, because accepting only one means finding no rows in a real document and
    reporting the section as absent: a wrong answer indistinguishable from a correct one.
    """
    pnr_id: str
    engine: str | None
    release: Any
    rules_sha256: str | None
    document: dict[str, Any] | None

    @classmethod
    def parse(cls, pnr_id: str, payload: dict[str, Any] | None) -> "Assessment":
        p = payload or {}
        meta = p.get("engine") if isinstance(p.get("engine"), dict) else p
        return cls(pnr_id=pnr_id, engine=(meta or {}).get("engine"),
                   release=(meta or {}).get("engineRelease"),
                   rules_sha256=(meta or {}).get("rulesSha256"),
                   document=p.get("document"))

    @property
    def has_answer(self) -> bool:
        """A null document is a real answer: the bound is not ready, so there is no assessment."""
        return bool(self.document)

    def blocks(self, section: str) -> Iterator[dict[str, Any]]:
        doc = self.document or {}
        top = doc.get(section)
        if top:
            yield from (b for b in top if isinstance(b, dict))
            return
        for bound in (doc.get("bounds") or []):
            if isinstance(bound, dict):
                yield from (b for b in (bound.get(section) or []) if isinstance(b, dict))


@dataclass(frozen=True, slots=True)
class Check:
    """One claim, its outcome, and what was actually seen.

    `applies=False` is a first-class result, not a pass: a check that could not run says why. A
    green tick for a check that never ran is the one result this must never print.
    """
    name: str
    applies: bool
    ok: bool | None
    detail: str
    expected: str = ""
    actual: str = ""
    #: True for a check about the document's SHAPE rather than its verdict -- that a section is
    #: present, that the row count fits. Those must not be able to carry a pass on their own: a
    #: case whose only applicable check is "the section exists" has not been verified at all.
    structural: bool = False

    @classmethod
    def na(cls, name: str, why: str) -> "Check":
        return cls(name=name, applies=False, ok=None, detail=why)

    @classmethod
    def of(cls, name: str, ok: bool, detail: str, *, expected: object = "",
           actual: object = "", structural: bool = False) -> "Check":
        return cls(name=name, applies=True, ok=ok, detail=detail,
                   expected=str(expected), actual=str(actual), structural=structural)

    @property
    def disagrees(self) -> bool:
        return self.applies and self.ok is False


@dataclass(frozen=True, slots=True)
class CaseResult:
    """What a run found for one booking: what the engine saw, and whether it agreed."""
    booking: Booking
    assessment: Assessment
    checks: tuple[Check, ...]
    seen: dict[str, Any] = field(default_factory=dict)

    @property
    def agrees(self) -> bool:
        return self.judged and not any(c.disagrees for c in self.checks)

    @property
    def judged(self) -> bool:
        """Whether a claim about the VERDICT actually ran.

        Not merely "some check applied": the four PAY/MIXED cases have every verdict check n/a and
        only `fd_section_present` applying, and counting those as agreeing would report a pass for
        a case nothing verified -- the one result this must never print.
        """
        return any(c.applies and not c.structural for c in self.checks)

    @property
    def disagreements(self) -> tuple[Check, ...]:
        return tuple(c for c in self.checks if c.disagrees)
