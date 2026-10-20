"""AC Wallet / Aeroplan members, through agentic-qa's proven loyalty seeder.

Implements `ports.LoyaltyDirectory`.

This wraps `aqa.workflows.seed.profile` rather than reimplementing it, which is deliberate: that
module is where the wallet chain was actually worked out — the feeds that build a profile, the band
to mint numbers in, the collision checks against both ACCP and the database, and the two incidents
that set the order (`R5B9L3` merged into `HEXFZK`'s profile over a duplicated surname; a rival empty
profile winning the wallet lookup when ours was published first). Writing that again here would fork
knowledge that is already right somewhere else.

What this adds is the shape: typed values in, typed values out, behind a port a test can fake.

**Three feeds build a member**, none of them the booking:

    MULE-LOYALTY-GIGYA-CUSTPROFILE  the profile    (name, email, address, username = the FF number)
    IFLY-ACCOUNTSTATUSCHANGES       AccountStatus
    IFLY-TIERSTATUSUPDATES          AeroplanTier   (omitted for a Basic member, which has none)

plus `AeroplanFrozenStage` on its own feed for a frozen wallet, which lands in
`Attributes.FrozenStage` while `AccountStatus` stays `"A"`.

**Credentials.** ACCP reads and writes need `profile:*`, which the seed role does not hold. Runs
must use `AWS_PROFILE=int-cce` with `AQA_ACCP_PROFILE=int-cce`; `int-sso` lacks `profile:*` and the
failure is silent — the member is simply never attached and the case reports a wallet verdict
nothing wrote. `check()` says so before a run rather than after.

**`profile.seed_member` is not used.** It publishes the member's feeds before the PNR, which is the
approach `attach_member` documents as wrong, and it has no call sites in agentic-qa either. The live
path is mint-then-attach, which is what this exposes.
"""
from __future__ import annotations

import os
import sys
from dataclasses import dataclass, field, replace
from typing import Any

from core import paths
from domain.loyalty import Member, is_basic
from domain.models import Booking, Scenario

#: The variable agentic-qa reads for the ACCP-capable profile, and the only value that works on INT.
ACCP_PROFILE_ENV = "AQA_ACCP_PROFILE"
INT_PROFILE = "int-cce"


class LoyaltyUnavailable(RuntimeError):
    """The loyalty chain cannot be driven: no agentic-qa, or no ACCP credentials."""


@dataclass
class AccpLoyaltyDirectory:
    """Mints and attaches members through agentic-qa. Satisfies `ports.LoyaltyDirectory`."""
    env_name: str = "int"
    log: Any = print
    #: set once, so a batch of cases shares one collision check against ACCP and the database
    _checks: tuple = field(default=(), repr=False)

    # ------------------------------------------------------------ the ports

    def mint(self, scenario: Scenario) -> tuple[Member, ...]:
        """One member per loyalty passenger, each with a number and surname nobody else holds."""
        request = scenario.loyalty
        if request is None:
            return ()
        problems = request.validate()
        if problems:
            raise ValueError(f"{scenario.case_id}: {'; '.join(problems)}")
        if request.preexisting:
            # a real tester's member: writing our blank Gigya uid and our address onto their live
            # identity is not ours to do, so it is passed through untouched
            self.log(f"[loyalty] {scenario.case_id}: member {request.fixture_number} is "
                     f"pre-existing, left untouched")
            return (Member(number=str(request.fixture_number or ""), first="", last="",
                           tier=request.tier, wallet_state=request.wallet_state,
                           preexisting=True),)

        profile = self._profile()
        number_taken, name_taken = self._collision_checks()
        wanted = request.per_passenger or (request,)
        first_names = [p.first_name or "Test" for p in scenario.passengers] or ["Test"]
        out: list[Member] = []
        for i, one in enumerate(wanted):
            px_first = first_names[i] if i < len(first_names) else first_names[0]
            raw = profile.mint_member(first=px_first, last="Member",
                                      email=self._contact_email(scenario),
                                      phone="+123456789",
                                      taken=number_taken, name_taken=name_taken)
            out.append(Member(number=raw["ff"], first=raw["first"], last=raw["last"],
                              email=raw.get("email", ""), tier=one.tier,
                              wallet_state=one.wallet_state))
            self.log(f"[loyalty] {scenario.case_id}: minted {raw['ff']} {raw['first']} "
                     f"{raw['last']} tier={one.tier} wallet={one.wallet_state}")
        return tuple(out)

    def attach(self, booking: Booking, members: tuple[Member, ...]) -> tuple[Member, ...]:
        """Enrich the booking's own profile, once it exists. Un-attached members say so."""
        if not members:
            return ()
        profile = self._profile()
        env = self._env()
        out: list[Member] = []
        for member in members:
            if member.preexisting:
                out.append(member)
                continue
            spec = {"aeroplan_number": member.number, "tier": member.tier,
                    "wallet_state": member.wallet_state,
                    **self._records(member)}
            result = profile.attach_member(env, _Rendered(booking), spec, log=self.log)
            if not result:
                # said rather than swallowed: no attach means no wallet data, and a wallet verdict
                # read afterwards is about a profile nothing wrote
                self.log(f"[loyalty] {member.number} NOT attached to {booking.pnr_id}: the case "
                         f"has no wallet data")
                out.append(member)
                continue
            out.append(replace(member,
                               profile_id=str(result.get("profile_id") or ""),
                               cpid=str(result.get("cpid") or "")))
        return tuple(out)

    # -------------------------------------------------------------- pre-flight

    def check(self) -> tuple[bool, str]:
        """Whether a loyalty run can work at all, said before the run rather than after.

        The failure this prevents: with the wrong AWS profile every ACCP write is refused, nothing
        is attached, and the run still produces bookings and verdicts — one of which was reported
        green with no wallet data behind it.

        The requirement is `int-cce` for EVERY environment, not only INT. ACCP is one directory,
        reached with credentials that hold `profile:*`, and `int-cce` is the only profile that does
        — a BAT wallet run proved it: `AWS_PROFILE=bat-sso` for BAT's own MSK secret alongside
        `AQA_ACCP_PROFILE=int-cce` attached 3 of 3 members. This check used to apply that rule to
        INT alone, so BAT passed it with the variable unset and inherited exactly the silent
        failure the check exists to stop.
        """
        try:
            self._profile()
        except LoyaltyUnavailable as ex:
            return False, str(ex)
        got = os.environ.get(ACCP_PROFILE_ENV, "").strip()
        if got != INT_PROFILE:
            where = "INT" if self.env_name == "int" else f"{self.env_name.upper()} (ACCP is shared)"
            return False, (f"{ACCP_PROFILE_ENV}={got or '(unset)'}; {where} needs {INT_PROFILE}. "
                           f"ACCP needs profile:*, which int-sso does not hold, and the failure is "
                           f"silent: members are never attached and the wallet verdict is empty.")
        return True, f"{ACCP_PROFILE_ENV}={got}"

    # ------------------------------------------------------------ internals

    @staticmethod
    def _records(member: Member) -> dict[str, str | None]:
        from domain.loyalty import WALLET_STATES
        return dict(WALLET_STATES.get(member.wallet_state, WALLET_STATES["open"]))

    def _profile(self):
        try:
            sys.path.insert(0, str(paths.require("agentic-qa")))
            from aqa.workflows.seed import profile                           # noqa: PLC0415
        except SystemExit as ex:
            raise LoyaltyUnavailable(str(ex)) from None
        except ImportError as ex:
            raise LoyaltyUnavailable(f"agentic-qa's loyalty seeder is not importable: {ex}") from None
        return profile

    def _env(self):
        sys.path.insert(0, str(paths.require("agentic-qa")))
        from aqa.workflows.seed.env import ENVS                              # noqa: PLC0415
        return ENVS[self.env_name]

    def _collision_checks(self):
        """`(number_taken, name_taken)`: a number ACCP holds, or a surname a passenger already
        carries, would merge this member into someone else's profile."""
        if self._checks:
            return self._checks
        profile = self._profile()
        try:
            number_taken = profile.account_taken(self._env())
        except Exception as ex:                                              # noqa: BLE001
            self.log(f"[loyalty] cannot check numbers against ACCP ({type(ex).__name__}); "
                     f"minting without that check risks writing onto another profile")
            number_taken = None
        self._checks = (number_taken, None)
        return self._checks

    def _contact_email(self, scenario: Scenario) -> str:
        for p in scenario.passengers:
            if getattr(p, "email", ""):
                return str(p.email)
        return "lahiru@ae-qa1-aircanada.mailinator.com"


@dataclass(frozen=True, slots=True)
class _Rendered:
    """What `profile.attach_member` reads off a seeded booking: just its `pnr_id`."""
    booking: Booking

    @property
    def pnr_id(self) -> str:
        return self.booking.pnr_id
