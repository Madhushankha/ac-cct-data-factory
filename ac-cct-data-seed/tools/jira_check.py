"""Does each spec agree with the Jira test it claims to implement?

    python tools/jira_check.py fd/uat/automation
    python tools/jira_check.py fd/uat/automation --only FD_TC_095,FD_TC_096

The Jira/Xray test is the authority for what a case means -- not the gap doc, and not the spec
file. The spec is a transcription of it, and a transcription can drift: a code changed in Jira
after the spec was written, or a spec says ELIGIBLE where its test describes a refusal. Every
disagreement found here is a case that cannot be judged safely, because the engine would be
measured against the wrong answer.

The Jira text is prose, so the comparison is deliberately narrow: only the things it states
unambiguously -- the system code, the eligibility word, and the award with its currency. Where the
test does not state one, nothing is claimed. Matching the MEANING is enough; wording is not
compared, because Jira's own stored text carries thousands of replacement characters and would
produce noise rather than findings.
"""
from __future__ import annotations

import argparse
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from adapters.file_spec_source import FileSpecSource                        # noqa: E402
from adapters.jira_docs import FileTestDocs                                 # noqa: E402

#: a full system code, or the suffix form the specs often use (`NE-01`)
CODE = re.compile(r"\bFD-(?:APPR|EU|ASL|MIXED)-(?:EL|NE|ND|PE)-\d+\b", re.I)
SUFFIX = re.compile(r"\b(?:EL|NE|ND|PE)-\d{2}\b", re.I)
MONEY = re.compile(r"\b(CAD|EUR|USD|GBP|ILS)\s*\$?\s*([\d,]+(?:\.\d+)?)\b", re.I)
ALT_MONEY = re.compile(r"\b([\d,]+(?:\.\d+)?)\s*(CAD|EUR|USD|GBP|ILS)\b", re.I)

ELIGIBILITY = (
    ("NO_DETERMINATION", re.compile(r"no[\s_-]*determination", re.I)),
    ("PENDING", re.compile(r"\bpending\b", re.I)),
    ("NOT_ELIGIBLE", re.compile(r"not[\s_-]*eligible", re.I)),
    ("ELIGIBLE", re.compile(r"\beligible\b", re.I)),
)


def text_of(doc) -> str:
    parts = [doc.title, doc.summary, doc.goal, doc.description, doc.prerequisites,
             getattr(doc, "gherkin", "") or ""]
    parts += list(getattr(doc, "prerequisite_items", ()) or ())
    return "\n".join(str(p) for p in parts if p)


def codes_in(text: str) -> set[str]:
    """Every system code the test names, as upper-case suffixes so prefix style does not matter."""
    out = {m.group(0).upper().split("-")[-2] + "-" + m.group(0).upper().split("-")[-1]
           for m in CODE.finditer(text)}
    out |= {m.group(0).upper() for m in SUFFIX.finditer(text)}
    return out


def eligibility_in(text: str) -> str | None:
    """The eligibility the test states, longest phrase first so NOT_ELIGIBLE beats ELIGIBLE."""
    for name, pattern in ELIGIBILITY:
        if pattern.search(text):
            return name
    return None


def amounts_in(text: str) -> set[tuple[str, float]]:
    out: set[tuple[str, float]] = set()
    for pattern, cur, amt in ((MONEY, 1, 2), (ALT_MONEY, 2, 1)):
        for m in pattern.finditer(text):
            raw = (m.group(amt) or "").replace(",", "").strip(".")
            if not raw:
                continue
            try:
                out.add((m.group(cur).upper(), float(raw)))
            except ValueError:          # "CAD ." and friends: Jira prose, not an amount
                continue
    return out


def check(case_id: str, expectation, doc) -> list[str]:
    """What the spec claims that its Jira test does not support."""
    text = text_of(doc)
    problems: list[str] = []

    want_code = expectation.system_code
    if want_code is not None and want_code.is_code:
        suffix = str(want_code.raw).upper().split("-")
        suffix = "-".join(suffix[-2:])
        found = codes_in(text)
        if found and suffix not in found:
            problems.append(f"code: the spec expects {want_code.raw}, the test names "
                            f"{', '.join(sorted(found))}")

    want_elig = str(expectation.eligibility or "").upper().replace(" ", "_")
    said = eligibility_in(text)
    # a test that names more than one verdict is not stating one: "Infant Without Seat | Not
    # Eligible | Adult Eligible" is about a case whose DDS answer is ELIGIBLE for the adult, and
    # "FD Eligible | Agent override to Not Eligible" is eligible at DDS and refused later by an
    # agent. Both read as contradictions to a single-verdict matcher and neither is one.
    named = {name for name, pattern in ELIGIBILITY if pattern.search(text)}
    if len(named) > 1:
        said = None
    if want_elig and said and want_elig != said:
        # a test that says "customer disagrees with the NE decision" is about a refusal even when
        # the word eligible appears, so only an outright opposite is reported
        opposites = {("ELIGIBLE", "NOT_ELIGIBLE"), ("NOT_ELIGIBLE", "ELIGIBLE"),
                     ("ELIGIBLE", "NO_DETERMINATION"), ("NO_DETERMINATION", "ELIGIBLE")}
        if (want_elig, said) in opposites:
            problems.append(f"eligibility: the spec expects {want_elig}, the test says {said}")

    amount, currency = expectation.money.amount, expectation.money.currency
    if amount and currency:
        found = amounts_in(text)
        if found and (str(currency).upper(), float(amount)) not in found:
            problems.append(f"amount: the spec expects {amount:g} {currency}, the test names "
                            f"{', '.join(f'{c} {a:g}' for c, a in sorted(found))}")
    return problems


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("set_name", help="a spec set, e.g. fd/uat/automation")
    ap.add_argument("--only", default="", help="comma-separated case ids")
    ap.add_argument("--quiet", action="store_true", help="only the counts")
    a = ap.parse_args(argv)

    specs = FileSpecSource().scenarios(a.set_name)
    docs = FileTestDocs()
    wanted = {c.strip() for c in a.only.split(",") if c.strip()}
    checked = no_doc = clean = 0
    findings: dict[str, list[str]] = {}

    for scenario in specs:
        base = scenario.case_id.split("#")[0]
        if wanted and base not in wanted and scenario.case_id not in wanted:
            continue
        doc = docs.doc(base)
        if doc is None:
            no_doc += 1
            continue
        checked += 1
        problems = check(scenario.case_id, scenario.expectation, doc)
        if problems:
            findings[f"{scenario.case_id} ({doc.key})"] = problems
        else:
            clean += 1

    if not a.quiet:
        for case, problems in sorted(findings.items()):
            print(f"{case}")
            for p in problems:
                print(f"    {p}")
    print(f"\n{a.set_name}: {checked} case(s) checked against their Jira test, "
          f"{clean} agree, {len(findings)} disagree, {no_doc} without a test")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
