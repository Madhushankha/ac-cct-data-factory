"""What the application needs from the outside, as protocols rather than imports.

Before this, each step reached straight for a concrete thing: the publisher imported agentic-qa's
Kafka producer, the gate imported boto3 and ran an ECS task, the seeder subprocessed a CLI. Three
consequences, all felt today:

* **nothing could be tested without AWS**, so the comparator's five bugs were found by seeding real
  bookings and squinting at the output;
* **nothing could be swapped** -- reading the verdict through a different route, or publishing
  through the kit's own `event_replay.py`, meant editing the step rather than passing a different
  implementation;
* **the steps knew too much**, so `gate.py` grew an ECS runner, an inner script, a log parser and
  the judging, in one file.

A protocol is a promise about shape, checked by the type checker and satisfiable by a fake. The
adapters in `adapters/` implement them against the real services; a test implements them in four
lines.

Nothing here imports an adapter: the direction of dependency is inward, so the domain and the
application never learn what Kafka or ECS are.
"""
from __future__ import annotations

from typing import Iterable, Protocol, runtime_checkable

from domain.loyalty import Member
from domain.testdoc import TestDoc
from domain.models import Assessment, Booking, CaseResult, Check, Scenario

__all__ = ["SpecSource", "ScenarioBuilder", "BuiltBatch", "Publisher", "PublishResult",
           "AssessmentReader", "RunStore", "FlowPolicy", "BookingSink", "LoyaltyDirectory", "TestDocs"]


@runtime_checkable
class SpecSource(Protocol):
    """Where scenarios come from: a folder of JSON, a kit's spec directory, a database."""

    def sets(self) -> Iterable[str]:
        """The named sets this source offers, e.g. `fd/uat/automation`."""

    def scenarios(self, set_name: str) -> Iterable[Scenario]:
        """Every scenario in one set, parsed."""


@runtime_checkable
class BuiltBatch(Protocol):
    """A batch of bookings, built and ready to publish."""

    @property
    def bookings(self) -> tuple[Booking, ...]: ...

    @property
    def messages(self) -> int: ...

    def payloads(self) -> Iterable[tuple[str, str, bytes]]:
        """`(topic, key, value)` in the order the booking's life happened.

        Order is data, not metadata: the engine folds a history, so a PNR that was always ticketed
        or a flight that was always late tells it nothing happened.
        """


@runtime_checkable
class ScenarioBuilder(Protocol):
    """Turns scenarios into publishable bookings.

    The implementation that matters drives cascade's `/qa builder`, which rewrites one of five
    anonymised production histories into the scenario -- about 24 messages across five feeds, spread
    over the booking's real life. A simpler implementation that synthesises a few messages is
    possible and was what we had; it produced bookings the engine would not assess.
    """

    def build(self, scenarios: Iterable[Scenario], *, env: str, run_day: str,
              spec_set: str | None = None) -> BuiltBatch:
        """`spec_set` lets an implementation prepare only that set.

        It is optional because it is an optimisation, not a meaning: the scenarios passed in are
        what gets built either way. Without it the kit builder patches and dates the whole spec
        tree and then filters, which also makes the flight days a set gets depend on which other
        sets exist."""


@runtime_checkable
class PublishResult(Protocol):
    @property
    def sent(self) -> int: ...

    @property
    def failures(self) -> tuple[str, ...]: ...


@runtime_checkable
class Publisher(Protocol):
    """Sends a built batch to an environment.

    `validate` exists because the kit never publishes a batch TripTracer's own parsers have not
    accepted, and an implementation that cannot validate should say so rather than silently skip it.
    """

    def validate(self, batch: BuiltBatch) -> tuple[bool, str]:
        """`(accepted, why)`. An implementation without a validator returns `(False, reason)`."""

    def publish(self, batch: BuiltBatch, *, dry_run: bool = True,
                identity: object | None = None,
                cases: dict[str, str] | None = None) -> PublishResult:
        """`identity` rewrites the contact and the passenger name; `cases` maps pnrId to case id
        so a per-case surname can be derived. Both optional: an implementation that cannot rewrite
        an identity ignores them."""

    def identities(self, batch: BuiltBatch, *, identity: object | None = None,
                   cases: dict[str, str] | None = None) -> dict[str, tuple[str, str]]:
        """The name each booking will actually carry, keyed by pnrId.

        The publisher is asked because it is what decides: the builder takes the name from one of
        five anonymised production histories, and `--unique-name` then rewrites the surname per
        case so one shared inbox can tell the scenarios apart. Anything downstream that needs the
        name -- a chat run identifying a customer, for one -- needs the name after that rewrite,
        not the one in the spec.
        """


@runtime_checkable
class AssessmentReader(Protocol):
    """Reads what the engine sees and what it decides.

    Two reads, in this order, because the second is only meaningful after the first: the Trip says
    whether the booking and its disruption arrived, and the assessment says whether the engine
    agrees. Without the Trip, a correct NOT_ELIGIBLE for a flight that never flew looks like a rule
    defect -- which cost an hour before the ordering was enforced.
    """

    def trip(self, pnr_id: str) -> dict:
        """What the engine holds for this booking: counts, segments, status, delay, cause."""

    def assessment(self, pnr_id: str) -> Assessment:
        """The engine's decision. A null document means no bound is assessed yet, which is an
        answer rather than a failure."""


@runtime_checkable
class RunStore(Protocol):
    """Where a run's record goes. A run is not data: nothing in it is a source of truth."""

    def save_case(self, result: CaseResult) -> None: ...

    def save_summary(self, label: str, results: Iterable[CaseResult]) -> str:
        """Returns where the summary landed."""


@runtime_checkable
class FlowPolicy(Protocol):
    """What differs per flow: which section, what a row is, and what counts as agreement.

    Four members and three methods. Adding a flow is adding one of these and registering it; the
    machinery around it does not change.
    """

    @property
    def flow_id(self) -> str: ...

    @property
    def section(self) -> str:
        """The assessment section this flow reads, e.g. `compensationEligibility`."""

    @property
    def lanes(self) -> tuple[str, ...]:
        """Publish lanes beyond the booking itself, e.g. `flight_status`, `bag_events`, `emd`."""

    @property
    def needs(self) -> tuple[str, ...]:
        """Empty when the flow can claim a verdict; otherwise what is missing, in a person's
        terms. A flow with a non-empty `needs` may still seed bookings -- it may not claim."""

    def validate(self, scenario: Scenario) -> tuple[str, ...]:
        """What this scenario is missing for this flow. Empty means it can be run."""

    def rows(self, assessment: Assessment) -> tuple:
        """This flow's section, as rows."""

    def judge(self, scenario: Scenario, rows: tuple) -> tuple[Check, ...]:
        """This flow's claims about those rows, given what the scenario expects."""

    def tags(self, scenario: Scenario) -> tuple[str, ...]:
        """The states a test would pick this booking BY, in the vocabulary the suites use.

        The automation half asks for a booking by state -- `need: [eligible, appr]`, or for baggage
        `need: [open, lost]` -- rather than by case id, so a scenario keeps working when the data is
        reseeded under new locators. Only the flow knows what states its cases are in, which is why
        this lives here and not in the adapter that writes them out.
        """


@runtime_checkable
class BookingSink(Protocol):
    """Where seeded bookings are handed to whatever will drive them.

    Seeding is only half of a test: something then has to talk to the product as a customer whose
    booking this is. That half is the Playwright suite under `automation/`, and it picks bookings by
    state tag out of a pool file -- a shape it already supports and documents as "generated pools,
    e.g. from an agentic-qa seed dataset".

    Before this the handoff went through the seed REPORT: the suite parsed the HTML with regexes to
    recover the PNRs, the passenger, the contact address and the state tags -- re-deriving from
    prose (`/counts as lost/i.test(what)`) what the seeder had as data. A presentation change broke
    it silently, and a missing tag does not fail: it makes a scenario pick the wrong booking.
    """

    def hand_off(self, name: str, bookings: Iterable[Booking], *,
                 tags: dict[str, tuple[str, ...]] | None = None,
                 names: dict[str, tuple[str, str]] | None = None,
                 aeroplan: dict[str, str] | None = None,
                 dataset: str = "", email: str = "") -> str:
        """Write the pool. Returns where it landed."""


@runtime_checkable
class LoyaltyDirectory(Protocol):
    """Where AC Wallet / Aeroplan members come from. Two moments, and the order is the finding.

    A wallet decision is made against a customer profile, and no booking creates one carrying a
    loyalty identity. So a loyalty case needs two things at two different times:

    1. **`mint`, BEFORE the booking is built.** The member's number and NAME are decided here,
       because the booking has to carry the same name: the wallet lookup disambiguates candidates by
       name, and a tie falls back to the first profile it finds. Two cases that minted
       `MICHAEL HALWENVOL` were merged into one profile.
    2. **`attach`, AFTER the booking's profile exists.** Publishing our own profile first looked
       right and is not: the booking does not attach to it. It asks Entity Resolution who the
       traveller is, ER is never given the loyalty id, so it answers "new person" and a second,
       empty profile appears -- and the empty one WINS the wallet lookup, because `PNRId`/`CPID`
       terms are tried before the account number. Enriching the booking's own profile leaves exactly
       one record, which is what a member who has never been booked already looks like.

    The implementation that matters wraps agentic-qa's `aqa.workflows.seed.profile`, where all of
    that was learned. A test implements this in a few lines and needs no AWS.
    """

    def mint(self, scenario: Scenario) -> tuple[Member, ...]:
        """Identities nobody else holds: one per loyalty passenger, never one shared.

        Not one shared, because the payment flow asks whether EVERY claim passenger has an eligible
        wallet -- so a mixed case needs independent members, one of them in a different state.
        """

    def attach(self, booking: Booking, members: tuple[Member, ...]) -> tuple[Member, ...]:
        """Enrich the booking's own customer profile. Returns the members with what was learned.

        A member that could not be attached is returned un-attached rather than reported as done:
        `Member.attached` is false, and a run that claims a wallet verdict on one is claiming
        something nothing wrote.
        """


@runtime_checkable
class TestDocs(Protocol):
    """Where the authoritative statement of a test comes from.

    Jira is the source of truth for these tests: the description defines the seed data, the chat and
    the checks. The FD gap document does not — disagreeing with the gap doc is not a defect.

    This is read-only and deliberately not part of judging. A run agrees with a test when it means
    the same thing or carries the seeded values, so the text is evidence for a person to read, not
    an assertion to compare strings against.
    """

    def doc(self, case_id: str) -> TestDoc | None:
        """One case's test, or None when Jira defines none for it."""

    def docs(self, set_name: str) -> tuple[TestDoc, ...]:
        """Every test in a set."""
