"""The authoritative statement of a test: what Jira says it is.

Jira is the source of truth for these tests. A test's description defines the seed data, the chat
and the checks, and the FD gap document does not — disagreeing with the gap doc is not a defect,
disagreeing with the Xray test is.

So this is deliberately not "a nicer version" of the Jira text. It is the text, split only where the
descriptions already split themselves (`goal ... Prerequisites: a. b. c.`), with the items kept one
by one because a prerequisite list is a list of facts a seeded booking has to satisfy.

Two things not to do with it, both learned:

**Do not compare wording.** A run agrees with a test when it means the same thing or carries the
seeded values; only a real content or flow gap is a failure. `TestDoc` therefore exposes the text
and the items, and offers no equality.

**Do not treat the text as clean.** The synced snapshot carries 6,135 replacement characters across
292 of 343 tests — bullets, arrows and accents that were already damaged in Jira's stored fields
(our client decodes UTF-8 and the sync writes UTF-8, so nothing here introduced them).
`TestDoc.damaged_characters` counts them so a reader knows what it is holding.
"""
from __future__ import annotations

import json
import pathlib
import re
from dataclasses import dataclass, field
from typing import Any

#: the character a lost bullet, arrow or accent arrives as
REPLACEMENT = "�"


@dataclass(frozen=True, slots=True)
class TestDoc:
    """One Jira/Xray test, as synced."""
    case_id: str
    key: str                                   # the Jira issue, e.g. CHAI-31510
    title: str = ""
    summary: str = ""
    description: str = ""
    goal: str = ""
    prerequisites: str = ""
    prerequisite_items: tuple[str, ...] = ()
    status: str = ""
    priority: str = ""
    labels: tuple[str, ...] = ()
    scenario_type: str = ""
    execution: str = ""                        # the Xray execution, e.g. CHAI-31809
    synced_at: str = ""
    gherkin: str = ""
    source: dict[str, Any] = field(default_factory=dict, repr=False)

    @classmethod
    def parse(cls, raw: dict[str, Any], *, gherkin: str = "") -> "TestDoc":
        items = raw.get("prerequisite_items") or []
        return cls(
            case_id=str(raw.get("test_id") or ""),
            key=str(raw.get("key") or ""),
            title=str(raw.get("title") or ""),
            summary=str(raw.get("summary") or ""),
            description=str(raw.get("description") or ""),
            goal=str(raw.get("goal") or ""),
            prerequisites=str(raw.get("prerequisites") or ""),
            prerequisite_items=tuple(str(i) for i in items if str(i).strip()),
            status=str(raw.get("status") or ""),
            priority=str(raw.get("priority") or ""),
            labels=tuple(str(x) for x in (raw.get("labels") or [])),
            scenario_type=str(raw.get("scenario_type") or ""),
            execution=str(raw.get("execution") or ""),
            synced_at=str(raw.get("synced_at") or ""),
            gherkin=gherkin,
            source=raw,
        )

    @classmethod
    def load(cls, directory: pathlib.Path) -> "TestDoc":
        """A `<CASE>__<KEY>/` folder: `test.json`, and `test.feature` when it is there."""
        raw = json.loads((directory / "test.json").read_text(encoding="utf-8"))
        feature = directory / "test.feature"
        return cls.parse(raw, gherkin=feature.read_text(encoding="utf-8")
                         if feature.exists() else "")

    # ------------------------------------------------------------------ facts

    @property
    def url(self) -> str:
        return f"https://aircanada.atlassian.net/browse/{self.key}" if self.key else ""

    @property
    def damaged_characters(self) -> int:
        """Replacement characters in the text, which came with it from Jira."""
        return sum(part.count(REPLACEMENT) for part in
                   (self.summary, self.description, self.goal, self.prerequisites, self.gherkin))

    @property
    def is_scenario(self) -> bool:
        """Whether this is a scenario test rather than a non-scenario card."""
        return self.scenario_type.strip().lower() == "scenario"

    def loyalty_hints(self) -> "LoyaltyHints":
        """What this test says about AC Wallet and the member it needs. Evidence, not input."""
        text = " ".join((self.summary, self.title, self.description, self.prerequisites,
                         " ".join(self.prerequisite_items)))
        low = text.lower()
        frozen: bool | None = None
        if _NOT_FROZEN.search(text):
            frozen = False
        if _FROZEN.search(_NOT_FROZEN.sub(" ", text)):
            frozen = True
        # every tier phrase the text uses, not the first one found. FD_TC_026 says both
        # "star alliance gold (aeroplan 50k/75k)" and "super elite", and taking the first match
        # reported it as SE100K -- a wrong hint is worse than none, because somebody acts on it.
        named = {v for k, v in _TIERS.items() if k in low}
        # the bare numbers too: FD_TC_026 writes "star alliance gold (aeroplan 50k/75k)" and
        # "super elite", which is three signals in one test. One phrase matching the table while
        # two more sit beside it is not an unambiguous tier.
        for number in re.findall(r"\b(\d{2,3})k\b", low):
            named.add({"25": "E25K", "35": "E35K", "50": "E50K",
                       "75": "E75K", "100": "SE100K"}.get(number, f"{number}K"))
        tier = named.pop() if len(named) == 1 else None
        unmapped = ""
        if len(named) > 1 or (tier is None and named):
            unmapped = "ambiguous: " + ", ".join(sorted(named | ({tier} if tier else set())))
        # only an alliance STATUS is a tier hint. "star alliance carrier", "partner" and "oal"
        # describe who operated the flight, and reporting those as tier questions made 4 of 14
        # audit rows noise.
        if not unmapped and tier is None:
            status = re.search(r"star alliance (gold|silver|elite)", low)
            if status:
                unmapped = status.group(0)
        if not unmapped and tier is None and "vip" in low:
            unmapped = "vip profile"
        return LoyaltyHints(frozen=frozen, tier=tier, unmapped_tier=unmapped,
                            mentions_wallet="wallet" in low)

    def mentions(self, text: str) -> bool:
        """Whether the test says something, anywhere in its own words. Case-insensitive.

        Used for questions like "which tests talk about AC Wallet" — a search, never a judgement.
        """
        needle = text.strip().lower()
        if not needle:
            return False
        return any(needle in part.lower() for part in
                   (self.summary, self.title, self.description, self.goal, self.prerequisites))


#: Phrases that say a member's wallet is frozen, and ones that say it explicitly is not. Both are
#: needed: "not frozen" contains "frozen", and reading the first as the second is how an audit
#: would report every healthy case as a defect.
_FROZEN = re.compile(r"(?<!not )(?<!NOT )\bfrozen\b", re.I)
_NOT_FROZEN = re.compile(r"\bnot\s+frozen\b", re.I)

#: Tier names as the tests write them, mapped to what the loyalty feeds call them. `Star Alliance
#: Gold` is an alliance status rather than an Aeroplan tier, so it is reported as itself and left
#: for a person: Gold spans more than one Aeroplan tier, and guessing one would seed the wrong
#: member silently.
_TIERS = {
    "e25k": "E25K", "elite 25k": "E25K",
    "e35k": "E35K", "elite 35k": "E35K",
    "e50k": "E50K", "elite 50k": "E50K",
    "e75k": "E75K", "elite 75k": "E75K",
    "se100k": "SE100K", "super elite": "SE100K", "elite 100k": "SE100K",
}


@dataclass(frozen=True, slots=True)
class LoyaltyHints:
    """What a test's own words say about the member it needs.

    A HINT, read from prose, and never used to seed. Its only job is to let an audit ask "does the
    spec express what the test says?" -- `FD_ED_TC_13` says `Aeroplan account status: FROZEN` and
    its spec carries no loyalty block at all, so it would be seeded with an open wallet and the
    fallback-to-cash it exists to prove would never fire.

    Deriving the seed data from this automatically would be the same mistake as reading a delay band
    out of a system code: prose is evidence that a person should act on, not input.
    """
    frozen: bool | None = None
    tier: str | None = None
    unmapped_tier: str = ""
    mentions_wallet: bool = False

    @property
    def says_anything(self) -> bool:
        return (self.frozen is not None or self.tier is not None
                or bool(self.unmapped_tier) or self.mentions_wallet)
