"""AC Wallet and Aeroplan: the rules, and the ORDER, against a fake directory.

No AWS, no ACCP, no Kafka. The two things worth proving are the ones that cost real runs:

* the member is minted BEFORE the booking is built, and attached AFTER it exists;
* the booking carries the member's name, even when `--unique-name` would give it another one.

Run:  python tests/test_loyalty.py
"""
from __future__ import annotations

import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from application.seed_pack import SeedPack                                   # noqa: E402
from domain.loyalty import (BASIC, LoyaltyRequest, Member, WALLET_STATES,    # noqa: E402
                            is_basic, wallet_amount)
from domain.models import Scenario                                           # noqa: E402
from flows import registry                                                   # noqa: E402
from ports import LoyaltyDirectory                                           # noqa: E402

from test_seed_pack import (FakeBuilder, FakePublisher, FakeReader,          # noqa: E402
                            FakeStore, answer, scenario)

FAILED: list[str] = []


def check(label: str, got: object, want: object) -> None:
    if got != want:
        FAILED.append(label)
        print(f"  FAIL {label}: got {got!r}, wanted {want!r}")
    else:
        print(f"  ok   {label}")


# ---------------------------------------------------------------------- fakes

class FakeLoyalty:
    """Mints predictable members and records WHEN each call happened."""

    def __init__(self, *, attach_fails: bool = False) -> None:
        self.calls: list[str] = []
        self.attach_fails = attach_fails
        self.minted: list[Member] = []

    def mint(self, scenario):
        self.calls.append(f"mint:{scenario.case_id}")
        want = scenario.loyalty
        out = []
        for i in range(want.members_wanted):
            m = Member(number=f"41190000{len(self.minted) + 1}", first="Test",
                       last=f"Halwenvol{len(self.minted) + 1}", tier=want.tier,
                       wallet_state=(want.per_passenger[i].wallet_state
                                     if want.per_passenger else want.wallet_state))
            self.minted.append(m)
            out.append(m)
        return tuple(out)

    def attach(self, booking, members):
        self.calls.append(f"attach:{booking.case_id}")
        if self.attach_fails:
            return members                       # returned un-attached, which is the honest answer
        from dataclasses import replace
        return tuple(replace(m, profile_id=f"p-{m.number}", cpid=f"c-{m.number}") for m in members)


class RecordingBuilder(FakeBuilder):
    """A builder that notes when it ran, so the order can be asserted."""

    def __init__(self, calls: list[str]) -> None:
        super().__init__()
        self._calls = calls

    def build(self, scenarios, *, env, run_day=None, **kw):
        self._calls.append("build")
        return super().build(scenarios, env=env, run_day=run_day, **kw)


class RecordingPublisher(FakePublisher):
    def __init__(self, calls: list[str]) -> None:
        super().__init__()
        self._calls = calls
        self.forced: dict = {}

    def publish(self, batch, *, dry_run: bool = True, force_names=None, **kw):
        self._calls.append("publish")
        self.forced = dict(force_names or {})
        return super().publish(batch, dry_run=dry_run, **kw)

    def identities(self, batch, *, identity=None, cases=None, force_names=None):
        out = {}
        for b in batch.bookings:
            forced = (force_names or {}).get(b.pnr_id)
            out[b.pnr_id] = forced or ("BUILDER", "NAME")
        return out


def loyalty_scenario(case_id="FD_TC_002", **block) -> Scenario:
    base = scenario(case_id)
    raw = {"id": case_id, "family": "FD",
           "expect": {"eligibility": "ELIGIBLE", "systemCode": "FD-APPR-EL-01", "regime": "APPR",
                      "amount": 400, "currency": "CAD", "delayMin": 240},
           "passengers": [{"type": "ADT", "firstName": "A", "lastName": "B",
                           "aeroplanNumber": "9876543210"}],
           "segments": [{"seg": 1, "bound": 1, "carrier": "AC", "number": "301"}],
           "outcomes": [{"seg": 1, "kind": "delay", "arrDelayMin": 240, "delayCode": "64"}]}
    if block:
        raw["loyalty"] = block
    assert base is not None
    return Scenario.parse(raw)


# ---------------------------------------------------------------------- tests

def test_the_request() -> None:
    print("what a case asks for")
    marker = loyalty_scenario().loyalty
    check("a passenger marker is enough to be a loyalty case", marker is not None, True)
    check("and the fixture number is read as a marker", marker.is_marker, True)
    check("the default wallet is open", marker.wallet_state, "open")
    check("frozen level 2 is the refused state",
          LoyaltyRequest.parse({"wallet_state": "frozen_l2"}).expects_refusal, True)
    check("frozen level 1 is not refused",
          LoyaltyRequest.parse({"wallet_state": "frozen_l1"}).expects_refusal, False)
    check("a frozen member's account still reads A",
          LoyaltyRequest.parse({"wallet_state": "frozen_l2"}).records["account_status"], "A")
    check("basic means no tier update at all",
          LoyaltyRequest.parse({"tier": BASIC}).needs_tier_update, False)
    check("an elite tier does get one",
          LoyaltyRequest.parse({"tier": "SE100K"}).needs_tier_update, True)
    check("'frozen' with no level is refused as ambiguous",
          bool(LoyaltyRequest.parse({"wallet_state": "frozen"}).validate()), True)
    check("an unknown tier is refused",
          bool(LoyaltyRequest.parse({"tier": "E99K"}).validate()), True)
    check("no loyalty block and no marker is not a loyalty case",
          Scenario.parse({"id": "X", "expect": {"eligibility": "ELIGIBLE"},
                          "passengers": [{"type": "ADT"}]}).loyalty, None)


def test_wallet_top_up() -> None:
    print("the wallet top-up")
    check("700 cash is 840 in the wallet", wallet_amount(700), 840.0)
    check("400 cash is 480", wallet_amount(400), 480.0)
    check("no amount stays no amount", wallet_amount(None), None)
    check("basic words all mean basic",
          [is_basic(x) for x in ("BASIC", "base", "None", "", None)], [True] * 5)
    check("a tier is not basic", is_basic("E50K"), False)


def test_the_name_rule() -> None:
    print("the name rule")
    m = Member(number="411900001", first="Marc-Andre", last="Bouchard")
    check("the same name matches", m.matches_booking_name("MARC-ANDRE", "BOUCHARD"), True)
    check("case and spacing do not matter", m.matches_booking_name("marc-andre", " bouchard "),
          True)
    check("a case-derived surname does NOT match",
          m.matches_booking_name("MARC-ANDRE", "BOUCHARDEAB"), False)
    check("an un-attached member says so", m.attached, False)
    from dataclasses import replace
    check("an attached one says that", replace(m, profile_id="p1").attached, True)


def test_tags() -> None:
    print("the tags a suite picks by")
    fd = registry.get("fd")
    tags = fd.tags(loyalty_scenario())
    check("a wallet case is marked", "wallet" in tags, True)
    check("the state is a tag", "wallet-open" in tags, True)
    check("so is the tier", "tier-e50k" in tags, True)
    refused = fd.tags(loyalty_scenario(wallet_state="frozen_l2"))
    check("the refused case is findable", "wallet-refused" in refused, True)
    check("and names its state", "wallet-frozen-l2" in refused, True)
    plain = fd.tags(scenario("FD_TC_900"))
    check("a non-loyalty case carries no wallet tag",
          [t for t in plain if t.startswith("wallet")], [])


def test_the_order() -> None:
    print("the order: mint, build, publish, attach")
    calls: list[str] = []
    loyalty = FakeLoyalty()
    loyalty.calls = calls                        # one shared list, so the order is comparable
    publisher = RecordingPublisher(calls)
    pack = SeedPack(builder=RecordingBuilder(calls), publisher=publisher,
                    reader=FakeReader({"ZZ0001-2026-08-21": answer()}),
                    store=FakeStore(), policy=registry.get("fd"), loyalty=loyalty,
                    env="int", log=lambda *_: None)
    out = pack.run([loyalty_scenario()], dry_run=False, settle_seconds=0)
    check("minted before the build", calls.index("mint:FD_TC_002") < calls.index("build"), True)
    check("published before the attach",
          calls.index("publish") < calls.index("attach:FD_TC_002"), True)
    check("one member", len(out.members), 1)
    check("attached", out.members[0].attached, True)
    check("the booking was told to carry the member's name",
          publisher.forced.get("ZZ0001-2026-08-21"), ("Test", "Halwenvol1"))


def test_a_failed_attach_is_not_a_pass() -> None:
    print("a member that could not be attached")
    loyalty = FakeLoyalty(attach_fails=True)
    pack = SeedPack(builder=FakeBuilder(), publisher=RecordingPublisher([]),
                    reader=FakeReader({"ZZ0001-2026-08-21": answer()}),
                    store=FakeStore(), policy=registry.get("fd"), loyalty=loyalty,
                    env="int", log=lambda *_: None)
    out = pack.run([loyalty_scenario()], dry_run=False, settle_seconds=0)
    check("the member is reported un-attached", out.members[0].attached, False)
    check("and the run says so out loud",
          any("NOT attached" in line for line in out.describe()), True)


def test_without_a_directory() -> None:
    print("a wallet case seeded with no loyalty directory")
    said: list[str] = []
    pack = SeedPack(builder=FakeBuilder(), publisher=FakePublisher(),
                    reader=FakeReader({"ZZ0001-2026-08-21": answer()}),
                    store=FakeStore(), policy=registry.get("fd"), loyalty=None,
                    env="int", log=lambda *a: said.append(" ".join(str(x) for x in a)))
    out = pack.run([loyalty_scenario()], dry_run=False, settle_seconds=0)
    check("it still seeds", out.built, 1)
    check("no members", out.members, ())
    check("but it warns that a wallet checkpoint would mean nothing",
          any("WITHOUT one" in s for s in said), True)


def test_a_mixed_case_needs_two_members() -> None:
    print("a mixed-wallet case")
    raw = {"id": "FD_TC_MIX", "family": "FD",
           "expect": {"eligibility": "ELIGIBLE", "regime": "APPR", "amount": 400},
           "passengers": [{"type": "ADT", "aeroplanNumber": "9876543210"},
                          {"type": "ADT", "aeroplanNumber": "9876543211",
                           "wallet_state": "frozen_l2"}],
           "segments": [{"seg": 1, "bound": 1}],
           "outcomes": [{"seg": 1, "kind": "delay", "arrDelayMin": 240}]}
    s = Scenario.parse(raw)
    check("two members wanted", s.loyalty.members_wanted, 2)
    check("one of them frozen at level 2",
          [p.wallet_state for p in s.loyalty.per_passenger], ["open", "frozen_l2"])
    check("the case is tagged as needing more than one",
          "wallet-multi-member" in registry.get("fd").tags(s), True)
    loyalty = FakeLoyalty()
    check("the fake mints both", len(loyalty.mint(s)), 2)


def test_the_adapter_is_a_directory() -> None:
    print("the real adapter")
    from adapters.accp_loyalty import AccpLoyaltyDirectory
    d = AccpLoyaltyDirectory("int")
    check("satisfies the port", isinstance(d, LoyaltyDirectory), True)
    ready, why = d.check()
    check("it checks the credentials rather than failing later", isinstance(ready, bool), True)
    if not ready:
        check("and the reason names the variable", "AQA_ACCP_PROFILE" in why, True)
    check("every wallet state is implementable", sorted(WALLET_STATES),
          ["frozen_l1", "frozen_l2", "open"])


def main() -> int:
    for fn in (test_the_request, test_wallet_top_up, test_the_name_rule, test_tags,
               test_the_order, test_a_failed_attach_is_not_a_pass, test_without_a_directory,
               test_a_mixed_case_needs_two_members, test_the_adapter_is_a_directory):
        fn()
        print()
    print(f"{len(FAILED)} failed: {', '.join(FAILED)}" if FAILED else "all checks passed")
    return 1 if FAILED else 0


if __name__ == "__main__":
    raise SystemExit(main())
