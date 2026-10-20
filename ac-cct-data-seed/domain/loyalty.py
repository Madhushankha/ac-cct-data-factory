"""AC Wallet and Aeroplan: what a loyalty case asks for, as types.

A wallet decision is not made against a booking. It is made against a **customer profile**, and no
booking creates one with a loyalty identity on it — so a case that wants a wallet needs a member
minted and attached, which is two separate moments in a run (see `ports.LoyaltyDirectory`).

Four facts live here because every one of them was learned the hard way, and each is a rule a type
can hold rather than a comment somebody has to remember:

**A fixture's Aeroplan number is a marker, not an identity.** 63 of our specs carry `9876543210`.
That is not 63 cases sharing one member: it means "this case wants a member", and a fresh one is
minted per run so two runs of one case never share a profile. `LoyaltyRequest.is_marker` says so,
and `Member.number` is the real one.

**A member's NAME matters as much as its number.** The wallet lookup disambiguates candidates by
name, and a tie makes it fall back to the first profile it finds. Two cases that minted
`MICHAEL HALWENVOL` ended up merged into one profile — a real incident, booking R5B9L3 into
HEXFZK's. So the booking's passenger name and the member's name must be the SAME name, and that
name must be unique. `Member.matches_booking_name` is the check.

**Frozen is not account status.** `AccountStatus` stays `"A"` for a frozen member; the freeze
arrives on its own feed as `AeroplanFrozenStage` and lands in `Attributes.FrozenStage`. The payment
flow refuses level 2 only. A case asking for "frozen" without saying which level is asking for the
one state that does not decide anything.

**A Basic member is not a member with tier Basic.** It is a profile with an active account and NO
tier-status update at all — no `AeroplanTier` attribute. Sending a tier update for a Basic member
produces records a real non-elite member does not have.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Any

#: Elite tiers, lowest to highest. Order matters: a case asking for "at least E50K" is a range.
TIERS: tuple[str, ...] = ("E25K", "E35K", "E50K", "E75K", "SE100K")

#: A member with no elite status: an active account and no tier update. Not a tier.
BASIC = "BASIC"
_BASIC_WORDS = frozenset({BASIC, "BASE", "MEMBER", "NONE", ""})

#: The wallet states the payment flow decides on, and the records each one needs.
#: `frozen_stage` is a separate feed from `account_status`; see the module docstring.
WALLET_STATES: dict[str, dict[str, str | None]] = {
    "open": {"account_status": "A", "frozen_stage": None},
    "frozen_l1": {"account_status": "A", "frozen_stage": "STG1"},
    "frozen_l2": {"account_status": "A", "frozen_stage": "STG2"},
}

#: The one state the payment flow refuses: every claim passenger must have an open wallet that is
#: not frozen at level 2.
REFUSED_STATE = "frozen_l2"

#: Taking compensation as AC Wallet credit instead of cash pays a 20% top-up. Derived, not stated:
#: no spec has a wallet field, and the figure appears only in the UI lines -- `AC Wallet CAD 840
#: (20% top-up)` against `amount: 700`, and `AC Wallet selected ($480)` against `amount: 400`. Both
#: are x1.2, which is where this number comes from. It is a derived expectation and says so, rather
#: than being parsed back out of prose per case.
WALLET_BONUS = 0.20


def wallet_amount(cash: float | None, bonus: float = WALLET_BONUS) -> float | None:
    """What the same compensation is worth taken as wallet credit. `None` in, `None` out."""
    if cash is None:
        return None
    value = float(cash) * (1 + bonus)
    # money, so two decimals; the UI lines are all whole dollars and this keeps them whole
    return round(value, 2)


#: Minted numbers live in 4119. Real INT members sit in 4115 93xxx, and the Gigya `username` is the
#: profile key, so minting there could overwrite a stranger's profile.
MINT_BAND = (411900000, 411999999)


def is_basic(tier: object) -> bool:
    return str(tier or "").strip().upper() in _BASIC_WORDS


@dataclass(frozen=True, slots=True)
class LoyaltyRequest:
    """The loyalty state a case asks for. `None` when the case is not a loyalty case."""
    wallet_state: str = "open"
    tier: str = "E50K"
    #: the number the fixture carried, kept only to say whether it was a marker or a real member
    fixture_number: str | None = None
    #: a real tester's member, which must be left alone rather than written onto
    preexisting: bool = False
    #: one request per loyalty passenger; a mixed case puts one of them in a different state
    per_passenger: tuple["LoyaltyRequest", ...] = ()

    @classmethod
    def parse(cls, raw: Any, passengers: tuple[dict, ...] = ()) -> "LoyaltyRequest | None":
        """A `loyalty` block, or a passenger carrying a loyalty number, or neither.

        A bare passenger marker is enough: that is how most of our fixtures ask, and demanding a
        block would make 63 specs silently non-loyalty cases.
        """
        block = dict(raw or {}) if isinstance(raw, dict) else {}
        markers = [p for p in passengers
                   if isinstance(p, dict) and (p.get("loyalty_number") or p.get("aeroplanNumber"))]
        if not block and not markers:
            return None
        number = (block.get("aeroplan_number") or block.get("number")
                  or (markers[0].get("loyalty_number") or markers[0].get("aeroplanNumber")
                      if markers else None))
        state = str(block.get("wallet_state") or "open").strip().lower()
        if state not in WALLET_STATES:
            # "frozen" alone does not decide anything, and guessing a level would invent the
            # difference between a case that passes and the one case that must be refused
            state = "open" if state in ("", "none") else state
        per = tuple(
            cls(wallet_state=str(p.get("wallet_state") or state).strip().lower(),
                tier=str(p.get("tier") or block.get("tier") or "E50K"),
                fixture_number=str(p.get("loyalty_number") or p.get("aeroplanNumber") or ""))
            for p in markers) if len(markers) > 1 else ()
        return cls(wallet_state=state, tier=str(block.get("tier") or "E50K"),
                   fixture_number=None if number is None else str(number),
                   preexisting=bool(block.get("preexisting")), per_passenger=per)

    # ------------------------------------------------------------------ rules

    @property
    def is_known_state(self) -> bool:
        return self.wallet_state in WALLET_STATES

    @property
    def records(self) -> dict[str, str | None]:
        """The account status and frozen stage this state needs."""
        return dict(WALLET_STATES.get(self.wallet_state, WALLET_STATES["open"]))

    @property
    def needs_tier_update(self) -> bool:
        """A Basic member gets no tier update at all, which is what a real one looks like."""
        return self.records["account_status"] == "A" and not is_basic(self.tier)

    @property
    def expects_refusal(self) -> bool:
        """Whether the payment flow should refuse this member's wallet."""
        return self.wallet_state == REFUSED_STATE

    @property
    def is_marker(self) -> bool:
        """Whether the fixture's number is a placeholder rather than a real member.

        A number outside the minted band and shared across cases is a marker. The one number our
        fixtures use most, `9876543210`, is not a valid Aeroplan number at all.
        """
        if self.preexisting:
            return False
        n = (self.fixture_number or "").strip()
        if not n.isdigit() or len(n) != 9:
            return True
        return not (MINT_BAND[0] <= int(n) <= MINT_BAND[1])

    @property
    def members_wanted(self) -> int:
        """How many independent members this case needs.

        One per loyalty passenger, never one shared: the payment flow asks whether EVERY claim
        passenger has an eligible wallet, so a shared member cannot express a mixed case.
        """
        return max(1, len(self.per_passenger))

    def validate(self) -> tuple[str, ...]:
        problems: list[str] = []
        if not self.is_known_state:
            problems.append(
                f"wallet_state {self.wallet_state!r} is not one of "
                f"{', '.join(WALLET_STATES)}: 'frozen' without a level does not decide anything")
        if not is_basic(self.tier) and self.tier.upper() not in TIERS:
            problems.append(f"tier {self.tier!r} is not one of {', '.join(TIERS)} or {BASIC}")
        return tuple(problems)


@dataclass(frozen=True, slots=True)
class Member:
    """A loyalty member that exists: minted by us, or a real one we were told to leave alone."""
    number: str
    first: str
    last: str
    email: str = ""
    tier: str = ""
    wallet_state: str = "open"
    profile_id: str = ""
    cpid: str = ""
    preexisting: bool = False

    @property
    def name(self) -> str:
        return f"{self.first} {self.last}".strip()

    @property
    def is_minted(self) -> bool:
        return not self.preexisting

    @property
    def attached(self) -> bool:
        """Whether the member reached a customer profile. Un-attached means no wallet data."""
        return bool(self.profile_id or self.cpid)

    def matches_booking_name(self, first: str, last: str) -> bool:
        """The wallet lookup compares the PNR name against the profile name.

        Case and spacing are normalised because the feeds do not agree on either; the surname has
        to match exactly otherwise, which is the whole point of minting both from one source.
        """
        def norm(s: str) -> str:
            return "".join(str(s or "").upper().split())
        return norm(self.last) == norm(last) and (
            not first or not self.first or norm(self.first) == norm(first))
