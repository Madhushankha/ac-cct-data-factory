"""The Jira test docs, read from the synced snapshot in `jira/`.

Implements `ports.TestDocs`.

The layout mirrors the spec tree, so a case id joins a spec to the test that defines it:

    spec/fd/uat/automation/FD_TC_118.json
    jira/fd/uat/automation/FD_TC_118__CHAI-31510/{test.json,test.feature,checkpoints.*}

That is the whole point of holding them here. Before this they sat in another checkout under
`jira/automation-uat/{fd,fd-edge,soc}/tests/`, so answering "what does the test actually say for
this case" meant knowing that `fd-edge` is part of the FD UAT automation set and that the folder
name carries the issue key — and a report that wanted the verbatim description had to walk out of
the project to find it.

**This is a snapshot, not the source.** Jira is the source; `aqa.jira.sync` pulls from it with the
GraphQL fields and writes exactly these files. `synced_at` on every doc says when. Nothing here
writes to Jira, and nothing judges a run by it: a run agrees when it means the same thing or carries
the seeded values, so the text is evidence for a person, not an assertion.

**The text arrives damaged.** 6,135 replacement characters across 292 of 343 tests — bullets,
arrows and accents. They are already in Jira's stored fields: `aqa.jira.client` decodes UTF-8 and
`aqa.jira.sync` writes UTF-8 with `ensure_ascii=False`, and the damage shows up identically in the
Xray Gherkin, which comes down a different field. `coverage()` reports it rather than hiding it.
"""
from __future__ import annotations

import pathlib
from dataclasses import dataclass

from core import paths
from domain.testdoc import TestDoc

#: a folder name is `<CASE_ID>__<JIRA_KEY>`
SEPARATOR = "__"


@dataclass(frozen=True, slots=True)
class Coverage:
    """How well a set's specs and its Jira tests line up."""
    set_name: str
    specs: tuple[str, ...]
    docs: tuple[str, ...]
    damaged: int = 0
    _duplicates: tuple[str, ...] = ()

    @property
    def missing_docs(self) -> tuple[str, ...]:
        """Specs with no Jira test: a case being seeded that nothing authoritative defines."""
        return tuple(sorted(set(self.specs) - set(self.docs)))

    @property
    def missing_specs(self) -> tuple[str, ...]:
        """Jira tests with no spec: a defined case nobody can seed."""
        return tuple(sorted(set(self.docs) - set(self.specs)))

    @property
    def duplicate_ids(self) -> tuple[str, ...]:
        """Case ids Jira defines more than once. `SOC_UAT_076` is defined by CHAI-31990 and
        CHAI-31991, which are different tests -- and `SOC_UAT_075` does not exist, so one of them
        is mis-numbered."""
        return self._duplicates

    @property
    def aligned(self) -> bool:
        return not self.missing_docs and not self.missing_specs

    def describe(self) -> list[str]:
        lines = [f"{self.set_name}: {len(self.specs)} spec(s), {len(self.docs)} Jira test(s)"]
        if self.missing_docs:
            lines.append(f"  seeded with no Jira test ({len(self.missing_docs)}): "
                         f"{', '.join(self.missing_docs[:8])}")
        if self.missing_specs:
            lines.append(f"  defined in Jira with no spec ({len(self.missing_specs)}): "
                         f"{', '.join(self.missing_specs[:8])}")
        if self.duplicate_ids:
            lines.append(f"  defined more than once in Jira: "
                         f"{', '.join(self.duplicate_ids)} -- different tests sharing one id")
        if self.damaged:
            lines.append(f"  {self.damaged} replacement character(s) carried over from Jira's own "
                         f"stored text")
        if self.aligned:
            lines.append("  every spec has a Jira test and every Jira test has a spec")
        return lines


class FileTestDocs:
    """Reads `jira/<flow>/<phase>/<purpose>/<CASE>__<KEY>/`. Satisfies `ports.TestDocs`."""

    def __init__(self, root: pathlib.Path | None = None) -> None:
        self.root = root or paths.JIRA

    # ------------------------------------------------------------- the ports

    def doc(self, case_id: str) -> TestDoc | None:
        """One case's test, from whichever set holds it. `None` when Jira defines none."""
        folder = self._folder(case_id)
        return TestDoc.load(folder) if folder else None

    def docs(self, set_name: str) -> tuple[TestDoc, ...]:
        """Every test in a set, by case id."""
        base = self.root / set_name.strip("/")
        if not base.is_dir():
            return ()
        return tuple(TestDoc.load(d) for d in sorted(base.iterdir())
                     if d.is_dir() and (d / "test.json").exists())

    def sets(self) -> tuple[str, ...]:
        """The sets the snapshot covers, in the spec tree's own names."""
        out = []
        for d in sorted(p for p in self.root.rglob("*") if p.is_dir()):
            rel = d.relative_to(self.root).as_posix()
            if len(rel.split("/")) == 3 and any(c.is_dir() for c in d.iterdir()):
                out.append(rel)
        return tuple(out)

    # ------------------------------------------------------------- alignment

    def coverage(self, set_name: str, spec_ids: tuple[str, ...]) -> Coverage:
        """Whether a set's specs and its Jira tests are the same set of cases.

        Both directions matter. A spec with no test is a case being seeded that nothing
        authoritative defines; a test with no spec is a case somebody wrote that cannot be run.
        """
        found = self.docs(set_name)
        # distinct ids on both sides: a spec file holding two bookings parses as `ID#1` and `ID#2`
        # but is one case, and Jira can carry the same test_id twice (SOC_UAT_076 does). Counting
        # rows rather than cases made the two sides look misaligned when they are not.
        return Coverage(set_name=set_name,
                        specs=tuple(sorted({i.split("#")[0] for i in spec_ids})),
                        docs=tuple(sorted({d.case_id for d in found if d.case_id})),
                        damaged=sum(d.damaged_characters for d in found),
                        _duplicates=tuple(sorted(
                            {d.case_id for d in found
                             if [x.case_id for x in found].count(d.case_id) > 1})))

    def search(self, text: str, set_name: str | None = None) -> tuple[TestDoc, ...]:
        """Tests that say something — "AC Wallet", "frozen", a regime. A search, not a judgement."""
        sets = (set_name,) if set_name else self.sets()
        return tuple(d for s in sets for d in self.docs(s) if d.mentions(text))

    # ------------------------------------------------------------- internals

    def _folder(self, case_id: str) -> pathlib.Path | None:
        wanted = case_id.strip().upper()
        for d in self.root.rglob(f"*{SEPARATOR}*"):
            if not d.is_dir() or not (d / "test.json").exists():
                continue
            if d.name.split(SEPARATOR)[0].upper() == wanted:
                return d
        return None
