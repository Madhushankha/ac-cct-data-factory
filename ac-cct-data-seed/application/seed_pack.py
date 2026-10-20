"""Seed a pack: build, publish, read, judge, record.

The use case, composed from ports. It knows the order of the steps and what each one means; it does
not know what Kafka or ECS are, which is why it can be run against fakes in a unit test.

The order is not arbitrary:

1. **validate before building** -- a scenario that states no expected verdict is stopped here rather
   than seeded and later reported as passing. A set whose expectation nobody has stated must not be
   able to report a pass.
2. **validate the batch before publishing**, and say so when the validator is unavailable. The kit
   never publishes what TripTracer's parsers have not accepted; we currently cannot, and a run that
   quietly skipped that step would be claiming more than it knows.
3. **read the Trip before the verdict** -- the Trip says whether the booking and its disruption
   arrived, which is what distinguishes "our data is wrong" from "the rules disagree". Reading them
   the other way round cost an hour on a correct NOT_ELIGIBLE for a flight that never flew.
4. **judge from the document, never from a stored verdict** -- judgements age. Four comparator
   fixes landed after one set of readings, and a report rebuilt from the stored verdict reproduced
   the pre-fix numbers exactly.

Batching follows the costs: publishing is per message (~2.5/s measured), so batch size barely
changes it, while a read task spends about 60 of its 70 seconds starting a container -- so reads are
batched as wide as the 8 KiB command override allows.
"""
from __future__ import annotations

import datetime as _dt
from dataclasses import dataclass, field, replace
from typing import Iterable, Sequence

from domain.loyalty import Member
from domain.models import Booking, CaseResult, Scenario
from ports import (AssessmentReader, BookingSink, BuiltBatch, FlowPolicy,
                   LoyaltyDirectory, Publisher, RunStore, ScenarioBuilder)


@dataclass(frozen=True, slots=True)
class PackOutcome:
    """What a run did, in the terms someone asking "did it work?" means."""
    label: str
    built: int = 0
    build_failures: tuple[str, ...] = ()
    published: int = 0
    publish_failures: tuple[str, ...] = ()
    validated: bool = False
    validation_note: str = ""
    results: tuple[CaseResult, ...] = ()
    refused: tuple[tuple[str, tuple[str, ...]], ...] = ()
    summary_path: str = ""
    pool_path: str = ""
    members: tuple[Member, ...] = ()

    @property
    def agree(self) -> int:
        return sum(1 for r in self.results if r.agrees)

    @property
    def disagree(self) -> int:
        return sum(1 for r in self.results if r.judged and not r.agrees)

    @property
    def not_judged(self) -> int:
        return sum(1 for r in self.results if not r.judged)

    def describe(self) -> list[str]:
        lines = [f"{self.label}: built {self.built}, published {self.published}"]
        if self.refused:
            lines.append(f"  refused before building: {len(self.refused)}")
            for case, why in self.refused[:5]:
                lines.append(f"    {case}: {'; '.join(why)}")
        if not self.validated:
            lines.append(f"  NOT validated: {self.validation_note}")
        if self.build_failures:
            lines.append(f"  build failures: {', '.join(self.build_failures[:5])}")
        if self.publish_failures:
            lines.append(f"  publish failures: {len(self.publish_failures)}")
        if self.results:
            lines.append(f"  judged: {self.agree} agree, {self.disagree} disagree, "
                         f"{self.not_judged} not judged")
        if self.members:
            attached = sum(1 for m in self.members if m.attached)
            lines.append(f"  loyalty: {len(self.members)} member(s), {attached} attached to a "
                         f"customer profile")
            for m in self.members:
                if not m.attached and not m.preexisting:
                    lines.append(f"    {m.number} NOT attached: that case has no wallet data")
        if self.pool_path:
            lines.append(f"  handed to automation: {self.pool_path}")
        return lines


@dataclass
class SeedPack:
    """Seed and judge a set of scenarios. Every collaborator is a port."""
    builder: ScenarioBuilder
    publisher: Publisher
    reader: AssessmentReader
    store: RunStore
    policy: FlowPolicy
    #: where the seeded bookings are handed to whatever will drive them. Optional: a run that only
    #: wants to know whether the engine agrees needs no handoff.
    sink: BookingSink | None = None
    #: where AC Wallet / Aeroplan members come from. Optional: a case with no loyalty block
    #: needs none, and a run without this seeds those cases and says plainly that the wallet
    #: cases went out without a member.
    loyalty: LoyaltyDirectory | None = None
    env: str = "int"
    log: object = field(default=print)

    #: bookings per read task; the adapter enforces its own ceiling too
    read_batch: int = 100

    def run(self, scenarios: Sequence[Scenario], *, label: str | None = None,
            run_day: str | None = None, dry_run: bool = True,
            settle_seconds: int = 90, spec_set: str | None = None,
            identity: object | None = None, batch_size: int = 0) -> PackOutcome:
        """Seed and judge. With `batch_size`, do it in batches of that many cases.

        A batch is built, published and recorded before the next one starts, so a token expiring
        mid-run costs one batch rather than the whole set.
        """
        if batch_size and len(scenarios) > batch_size:
            return self._in_batches(scenarios, batch_size, label=label, run_day=run_day,
                                    dry_run=dry_run, settle_seconds=settle_seconds,
                                    spec_set=spec_set, identity=identity)
        label = label or f"pack-{_dt.datetime.now(_dt.timezone.utc).strftime('%m%dT%H%M')}"
        say = self.log if callable(self.log) else print

        runnable, refused = self._triage(scenarios)
        if not runnable:
            return PackOutcome(label=label, refused=refused)
        say(f"[pack] {len(runnable)} runnable, {len(refused)} refused")

        # 1. MINT, before the booking is built. The member's name is decided here because the
        #    booking has to carry the same one: the wallet lookup disambiguates profiles by
        #    name, and a tie falls back to the first profile it finds.
        members_by_case = self._mint(runnable, say)

        batch = self.builder.build(runnable, env=self.env, run_day=run_day,
                                   spec_set=spec_set)
        say(f"[pack] built {len(batch.bookings)} booking(s), {batch.messages} message(s)")

        accepted, note = self.publisher.validate(batch)
        if not accepted:
            say(f"[pack] {note}")

        # pnrId -> case id, so a per-case surname can be derived: one inbox takes every
        # scenario's mail, and the surname is what tells automation which scenario a message is for
        cases = {b.pnr_id: b.case_id for b in batch.bookings if b.pnr_id}
        # 2. the booking carries its member's name, which beats --unique-name. A minted
        #    surname is already unique, so nothing is given up by letting it win.
        forced = {
            b.pnr_id: (members_by_case[b.case_id][0].first, members_by_case[b.case_id][0].last)
            for b in batch.bookings
            if members_by_case.get(b.case_id) and not members_by_case[b.case_id][0].preexisting}
        # the office each case needs, where it states one
        by_case_office = {s.case_id: s.office_id for s in runnable if s.office_id}
        offices = {b.pnr_id: by_case_office[b.case_id] for b in batch.bookings
                   if b.case_id in by_case_office}
        if offices:
            say(f"[publish] {len(offices)} booking(s) take the case's own office "
                f"(e.g. {sorted(set(offices.values()))[:3]})")
        sent = self.publisher.publish(batch, dry_run=dry_run, identity=identity, cases=cases,
                                      force_names=forced, offices=offices)
        if dry_run:
            return PackOutcome(label=label, built=len(batch.bookings), validated=accepted,
                               validation_note=note, refused=refused)

        if settle_seconds:
            say(f"[pack] waiting {settle_seconds}s for the ingest to fold the events")
            self._sleep(settle_seconds)

        # 3. ATTACH, only now. Publishing our own profile first leaves the booking pointing at
        #    a rival empty profile, which then wins the wallet lookup.
        members = self._attach(batch.bookings, members_by_case, say)

        # judge what was BUILT: apply_patches rewrites expectations, so the source spec can
        # describe a different case from the booking that went out
        results = tuple(self.judge(batch.bookings,
                                   scenarios=self._as_built(batch, runnable)))
        for r in results:
            self.store.save_case(r)
        summary = self.store.save_summary(label, results)

        # the handoff: the seeded bookings, with the states a suite picks them by. The flow supplies
        # the tags because only it knows what state its cases are in.
        pool = ""
        if self.sink is not None:
            by_case = {s.case_id: s for s in runnable}
            tags = {b.case_id: self.policy.tags(by_case[b.case_id])
                    for b in batch.bookings if b.case_id in by_case}
            pool = self.sink.hand_off(
                label, batch.bookings, tags=tags, dataset=label,
                # the publisher decides the name, so the publisher is asked for it
                names=self.publisher.identities(batch, identity=identity, cases=cases,
                                                force_names=forced),
                aeroplan={case: m[0].number for case, m in members_by_case.items() if m},
                email=getattr(identity, "email", "") or "")
        return PackOutcome(label=label, built=len(batch.bookings), pool_path=pool,
                           members=members,
                           build_failures=tuple(str(f.get("id")) for f in
                                                getattr(batch, "failures", ()) or ()),
                           published=sent.sent, publish_failures=sent.failures,
                           validated=accepted, validation_note=note,
                           results=results, refused=refused, summary_path=summary)

    # ------------------------------------------------------------------ judge

    def judge(self, bookings: Iterable[Booking], *,
              scenarios: Sequence[Scenario] = ()) -> list[CaseResult]:
        """Read each booking and compare, in read-batches.

        The scenario is looked up by case id where one was given, so the comparison uses the
        scenario's own passengers and segments rather than the manifest's summary of them.
        """
        bookings = list(bookings)
        by_case = {s.case_id: s for s in scenarios}
        out: list[CaseResult] = []
        for chunk in self._chunks(bookings, self.read_batch):
            ids = [b.pnr_id for b in chunk]
            if hasattr(self.reader, "read_many"):
                self.reader.read_many(ids)                      # one task for the chunk
            for booking in chunk:
                out.append(self._judge_one(booking, by_case.get(booking.case_id)))
        return out

    def _judge_one(self, booking: Booking, scenario: Scenario | None) -> CaseResult:
        trip = self.reader.trip(booking.pnr_id)
        assessment = self.reader.assessment(booking.pnr_id)
        segments = (trip.get("segments") or [])
        delays = [s.get("delayMin") for s in segments if s.get("delayMin")]
        seen = {"tripCounts": trip.get("counts"), "segments": segments[:4],
                # asked explicitly, because a verdict read without it is misleading: an itinerary
                # the engine holds with no delay produces a correct NOT_ELIGIBLE for the wrong
                # reason
                "disruption_present": bool(delays), "delays": delays}
        # the bags, where the Trip holds any. A baggage case's whole expectation is about them, so
        # dropping them here would store a record that cannot answer what the case asked.
        if trip.get("baggage"):
            seen["baggage"] = trip["baggage"]

        trip_checks = self._trip_checks(scenario, trip, segments, delays,
                                        rebooked=self._rebooked(assessment.document),
                                        published=booking.published)

        if not assessment.has_answer:
            return CaseResult(booking=booking, assessment=assessment, seen=seen,
                              checks=(*trip_checks,
                                      self._na("no assessment: the engine holds no verdict for "
                                               "this booking yet"),))
        # the booking's expectation comes from the manifest, which the planner filled from the
        # PATCHED spec -- the one that was actually built. Where it differs from the source spec on
        # disk, the built one is the case that exists: FD_ED_TC_08 was built expecting EL-02 while
        # its source spec still says EL-01, and judging the source scored this pipeline 205/267
        # where the kit, judging the built expectation, scored 264/267.
        basis = scenario
        if basis is None:
            basis = Scenario(case_id=booking.case_id, family=self.policy.flow_id,
                             expectation=booking.expectation)
        elif booking.expectation.states_a_verdict and                 booking.expectation != basis.expectation:
            basis = replace(basis, expectation=booking.expectation)
        rows = self.policy.rows(assessment)
        return CaseResult(booking=booking, assessment=assessment, seen=seen,
                          checks=(*trip_checks, *self.policy.judge(basis, rows)))

    @staticmethod
    def _as_built(batch, runnable: Sequence[Scenario]) -> tuple[Scenario, ...]:
        """The patched scenarios where the batch has them, the source ones otherwise."""
        patched = batch.patched() if hasattr(batch, "patched") else {}
        if not patched:
            return tuple(runnable)
        out, changed = [], 0
        for s in runnable:
            raw = patched.get(s.case_id) or patched.get(s.case_id.split("#")[0])
            if not raw:
                out.append(s)
                continue
            rebuilt = Scenario.parse({**raw, "id": s.case_id})
            if rebuilt.expectation != s.expectation:
                changed += 1
            out.append(rebuilt)
        if changed:
            print(f"[judge] {changed} expectation(s) come from the patched spec, not the source")
        return tuple(out)

    def _in_batches(self, scenarios: Sequence[Scenario], size: int, **kw) -> PackOutcome:
        """One build-publish-judge cycle per batch, accumulated into a single outcome."""
        say = self.log if callable(self.log) else print
        label = kw.pop("label", None) or "pack"
        chunks = list(self._chunks(list(scenarios), size))
        say(f"[pack] {len(scenarios)} scenario(s) in {len(chunks)} batch(es) of up to {size}")
        built = published = 0
        results, refused, failures, pools = [], [], [], []
        for i, chunk in enumerate(chunks, 1):
            say(f"[pack] === batch {i} of {len(chunks)}: {len(chunk)} case(s)")
            out = self.run(chunk, label=f"{label}-b{i:02d}", **kw)
            built += out.built
            published += out.published
            results.extend(out.results)
            refused.extend(out.refused)
            failures.extend(out.build_failures)
            if out.pool_path:
                pools.append(out.pool_path)
        return PackOutcome(label=label, built=built, published=published,
                           build_failures=tuple(failures), results=tuple(results),
                           refused=tuple(refused),
                           validated=False,
                           validation_note="per batch; see each batch's own run record",
                           pool_path="; ".join(pools))

    # ---------------------------------------------------------------- loyalty

    def _mint(self, scenarios, say) -> dict[str, tuple[Member, ...]]:
        """Members for the cases that ask for one, before anything is built."""
        wanting = [s for s in scenarios if s.wants_loyalty]
        if not wanting:
            return {}
        if self.loyalty is None:
            # not passed over silently: a wallet case without a member still produces a booking and
            # a verdict, and that verdict is about a profile which does not exist
            say(f"[loyalty] {len(wanting)} case(s) ask for an AC Wallet member and no loyalty "
                f"directory is configured: they go out WITHOUT one, so a wallet checkpoint on them "
                f"means nothing")
            return {}
        out: dict[str, tuple[Member, ...]] = {}
        for s in wanting:
            minted = tuple(self.loyalty.mint(s))
            if minted and len(minted) < s.loyalty.members_wanted:
                say(f"[loyalty] {s.case_id} wants {s.loyalty.members_wanted} members and got "
                    f"{len(minted)}: a mixed-wallet case cannot be expressed with fewer")
            if minted:
                out[s.case_id] = minted
        say(f"[loyalty] minted {sum(len(v) for v in out.values())} member(s) "
            f"for {len(out)} case(s)")
        return out

    def _attach(self, bookings, members_by_case: dict[str, tuple[Member, ...]],
                say) -> tuple[Member, ...]:
        """Enrich each booking's own profile, now that the booking has made one."""
        if not members_by_case or self.loyalty is None:
            return ()
        out: list[Member] = []
        for booking in bookings:
            minted = members_by_case.get(booking.case_id)
            if minted:
                out.extend(self.loyalty.attach(booking, minted))
        say(f"[loyalty] {sum(1 for m in out if m.attached)} of {len(out)} member(s) attached "
            f"to a customer profile")
        return tuple(out)

    # -------------------------------------------------------------- internals

    def _triage(self, scenarios: Iterable[Scenario]):
        runnable, refused = [], []
        for s in scenarios:
            missing = tuple(self.policy.validate(s))
            if missing:
                refused.append((s.case_id, missing))
            else:
                runnable.append(s)
        return runnable, tuple(refused)

    @staticmethod
    def _chunks(items: list, size: int):
        for i in range(0, len(items), max(1, size)):
            yield items[i:i + size]

    @staticmethod
    def _rebooked(document: dict | None) -> bool:
        """Does the engine hold a different itinerary than the one promised?

        A cancel-and-rebook booking shows no delay in the Trip: the Trip lists the leg the
        passenger actually flew, which left and arrived on its own schedule. Comparing that
        against the cancelled leg's minutes fails by construction -- FD_TC_040 publishes a
        300-minute delay and a replacement, and the Trip holds the replacement at 0. Only the
        assessment document carries both halves, so it decides whether the delay assertions
        apply at all.
        """
        for bound in (document or {}).get("bounds") or []:
            def ids(which: str) -> set[str]:
                itin = bound.get(which) or {}
                return {str(s.get("segmentId")) for s in itin.get("associatedSegments") or []}

            promised, actual = ids("promisedItinerary"), ids("actualItinerary")
            if promised and actual and promised != actual:
                return True
        return False

    @staticmethod
    def _trip_checks(scenario, trip: dict, segments: list, delays: list,
                     rebooked: bool = False, published: tuple = ()) -> tuple:
        """What the Trip API says the engine holds for this booking.

        These are claims, not context: a verdict about a leg we did not publish is not a verdict
        about this case, however well the numbers happen to line up. The exception is a rebooking,
        where the Trip legitimately holds a different leg than the one the disruption was on.
        """
        from domain.models import Check

        out = [Check.of("tt_trip_found", bool(segments),
                        f"{len(segments)} segment(s) in the Trip",
                        expected="at least 1", actual=len(segments), structural=True)]
        if not segments:
            return tuple(out)

        # what went OUT decides this, not what either spec says: `apply_patches.py` rewrites
        # outcomes, so the source spec can state 240 for a booking that published 120, and a
        # comparison against the source calls the engine's correct answer a foreign leg.
        wanted = [leg.get("minutes") for leg in published or ()
                  if leg.get("minutes") and leg.get("kind") == "delay"]
        if not wanted:
            wanted = [o.arrival_delay.value for o in (scenario.outcomes if scenario else ())
                      if o.arrival_delay.value] if scenario else []
        if not wanted:
            out.append(Check.na("tt_delay", "the scenario states no arrival delay to compare"))
            return tuple(out)
        if rebooked:
            # the engine holds the replacement leg, not the disrupted one: the delay it reports is
            # the new flight's own, and the disruption lives in promised-vs-actual instead
            out.append(Check.na("tt_delay", "the booking was rebooked: the Trip holds the "
                                            "replacement leg, whose delay is not this case's"))
            return tuple(out)

        # a case can be ABOUT absent data: FD_TC_139 and FD_TC_170 publish an on-time leg and no
        # status for the next one, because the scenario is "OAG data never received" and the card
        # expects a no-determination. Asserting a disruption there contradicts the case.
        if published and not any(leg.get("kind") in ("delay", "cancel") for leg in published):
            out.append(Check.na("tt_disruption", "the scenario publishes no disruption: it is "
                                                 "about the absence of flight status"))
            out.append(Check.na("tt_delay", "the scenario publishes no delay to compare"))
            return tuple(out)

        out.append(Check.of("tt_disruption", bool(delays),
                            f"delays in the Trip: {delays or 'none'}",
                            expected="a disrupted segment", actual=delays or "none",
                            structural=True))
        if not delays:
            out.append(Check.na("tt_delay", "the Trip holds no delay to compare"))
            return tuple(out)

        # the engine must hold the delay we published. A different number means it folded a leg
        # that is not ours -- the flight key was already in use.
        out.append(Check.of(
            "tt_delay", any(d in wanted for d in delays),
            f"the Trip holds {delays}, the scenario published {wanted}"
            + ("" if any(d in wanted for d in delays)
               else "; the engine is holding a leg this case did not publish"),
            expected=wanted, actual=delays, structural=True))
        return tuple(out)

    @staticmethod
    def _na(why: str):
        from domain.models import Check
        return Check.na("verdict", why)

    @staticmethod
    def _sleep(seconds: int) -> None:
        import time
        time.sleep(seconds)
