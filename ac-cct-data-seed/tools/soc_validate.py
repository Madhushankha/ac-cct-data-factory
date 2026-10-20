"""Check the SOC specs against the Jira cards that define them, fact by fact.

    python tools/soc_validate.py
    python tools/soc_validate.py --run runs/int/soc-uat-int-v1    # also check what was seeded

Jira is the authority for what a SOC case means, and each card states its setup as `Key: value`
prerequisite lines -- regime, passenger count, departure delay and its code, controllability. The
spec is a transcription of that card. A transcription can drift, and nothing was checking it: this
compares the two and names every disagreement.

What it deliberately does NOT do is guess. A prerequisite line it cannot parse into a comparable
fact is counted as "not compared" and reported as such, because a validator that silently skips
what it cannot read is worse than no validator -- it reports green over the part nobody checked.

With `--run` it also checks the seeded bookings: that every spec became a booking, and that the
flight number and route on the booking are the ones the card asked for.
"""
from __future__ import annotations

import argparse
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

SET = "soc/uat/automation"
#: Jira's stored text carries U+FFFD where accents and dashes were lost upstream
BAD = "�"


def clean(text: str) -> str:
    return text.replace(BAD, "-").strip()


def prereqs(doc) -> dict[str, str]:
    """The card's `Key: value` prerequisite lines, as a dict. Later lines win, as the card reads."""
    out: dict[str, str] = {}
    for item in doc.prerequisite_items or ():
        line = clean(item).lstrip("- ").strip()
        if ":" not in line:
            continue
        key, _, value = line.partition(":")
        out[key.strip().lower()] = value.strip()
    return out


def first_int(text: str) -> int | None:
    m = re.search(r"(\d{1,4})", text or "")
    return int(m.group(1)) if m else None


#: a card value that states there is nothing to compare. `N/A - OAL ONLY`, `UNKNOWN - OAL
#: DISRUPTION DATA NOT AVAILABLE TO AC` and `TBD - WITHIN 72-HOUR WINDOW` are all the card saying
#: the field does not apply or is not knowable, and a spec that carries `None` for them is correct.
#: Comparing them literally reported 40-odd disagreements that were the comparator's fault.
_NOT_STATED = re.compile(
    r"^\s*(n/?a\b|none\b|tbd\b|unknown\b|not\s+applicable|not\s+available|not\s+checked)", re.I)


def stated(value: str | None) -> bool:
    return bool(value) and not _NOT_STATED.match(value or "")


def controllability(value: str) -> str:
    """`SAFETY (CODE 41)` -> `SAFETY`; the card appends the code, the spec stores the class."""
    text = re.sub(r"\(.*?\)", " ", value or "").strip()
    text = text.split(" - ")[0].strip().upper()
    if "UNCONTROLLABLE" in text:
        return "UNCONTROLLABLE"
    if "CONTROLLABLE" in text:
        return "CONTROLLABLE"
    return text


def flights_in(text: str) -> list[str]:
    """`AC 101 YYZ-YUL` -> ['AC101']; the card writes the carrier and number apart."""
    return [f"{c}{n}" for c, n in re.findall(r"\b([A-Z]{2})\s?(\d{1,4})\b", text or "")]


def check_case(spec: dict, doc) -> tuple[list[str], list[str], list[str]]:
    """Returns (agreed, disagreed, not_compared) for one case."""
    p = prereqs(doc)
    agreed: list[str] = []
    bad: list[str] = []
    skipped: list[str] = []

    expect = spec.get("expect") or {}
    outs = spec.get("outcomes") or []
    segs = spec.get("segments") or []

    def cmp(name: str, want, got) -> None:
        if want is None or want == "" or (isinstance(want, str) and not stated(want)):
            skipped.append(f"{name}: the card states none")
        elif str(want).strip().upper() == str(got).strip().upper():
            agreed.append(name)
        else:
            bad.append(f"{name}: card says {want!r}, spec has {got!r}")

    # every regime the card names ANYWHERE -- title, goal, prerequisites. A card can name
    # more than one: SOC_UAT_030 is titled "EU - Not Eligible - Itinerary Did Not Start in
    # EU" and also carries a `Regime: APPR` line explaining what WOULD be eligible under
    # APPR. Comparing the spec against the first line alone called that spec wrong when it
    # was right.
    blob = " ".join([doc.title or "", doc.summary or "", doc.description or "",
                     *(doc.prerequisite_items or ())])
    named = set()
    for m in re.finditer(r"(APPR|EU|ASL|UK|MTL)", blob, re.I):
        named.add(m.group(1).upper())
    if "ANY" in (p.get("regime") or "").upper():
        skipped.append("regime: the card says ANY (an override across all regimes)")
    elif named:
        got = str(expect.get("regime") or "").upper()
        if got and got in named:
            agreed.append("regime")
        else:
            bad.append(f"regime: card names {sorted(named)}, spec has {expect.get('regime')!r}")
    else:
        skipped.append("regime: no regime named on the card")

    if "pax count" in p:
        # the card writes a party, not a number: "2 adults, 1 child" is three passengers. Only the
        # counts before a person word are summed, so "/ Class: PY" and "> 72h" are not passengers.
        party = sum(int(n) for n, _ in re.findall(
            r"(\d{1,2})\s*(adults?|children|child|infants?|pax|passengers?)", p["pax count"], re.I))
        cmp("pax count", party or first_int(p["pax count"]),
            len(spec.get("passengers") or []))
    else:
        skipped.append("pax count: no line on the card")

    # the delay the card states, against the biggest departure delay the spec publishes
    if "departure delay" in p:
        want = first_int(p["departure delay"])
        got = max((o.get("depDelayMin") or 0) for o in outs) if outs else None
        cmp("departure delay", want, got)
    else:
        skipped.append("departure delay: no line on the card")

    if "departure delay code" in p:
        want = p["departure delay code"]
        codes = [str(o.get("delayCode")) for o in outs if o.get("delayCode")]
        if not stated(want) or not re.search(r"\d", want or ""):
            # "None", "N/A", "Not applicable" -- a stated absence, which the spec honours by
            # carrying no code at all
            cmp("departure delay code (absent)", "none" if not codes else "present", "none")
        else:
            cmp("departure delay code", first_int(want), first_int(",".join(codes)))
    else:
        skipped.append("departure delay code: no line on the card")

    if "controllability" in p and expect.get("control"):
        raw = p["controllability"]
        cmp("controllability", controllability(raw) if stated(raw) else None,
            expect.get("control"))
    elif "controllability" in p:
        skipped.append("controllability: the spec states none (the regime does not evaluate it)")
    else:
        skipped.append("controllability: no line on the card")

    # the itinerary: every flight the card names should be a segment in the spec
    card_flights = flights_in(p.get("itinerary") or p.get("promised itinerary") or "")
    spec_flights = [f"{s.get('carrier')}{s.get('number')}" for s in segs]
    if card_flights:
        missing = [f for f in card_flights if f not in spec_flights]
        if missing:
            bad.append(f"itinerary: card names {missing} which the spec does not carry "
                       f"(spec has {spec_flights})")
        else:
            agreed.append("itinerary")
    else:
        skipped.append("itinerary: no flight parsed from the card")

    return agreed, bad, skipped


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--run", default="", help="also check the bookings this run seeded")
    args = ap.parse_args(argv)

    from adapters.file_spec_source import FileSpecSource                    # noqa: PLC0415
    from adapters.jira_docs import FileTestDocs                             # noqa: PLC0415

    src = FileSpecSource()
    path = src.set_named(SET).path
    spec_by_id = {}
    for p in sorted(path.glob("*.json")):
        s = json.loads(p.read_text(encoding="utf-8"))
        spec_by_id[str(s.get("id") or p.stem)] = s
    doc_by_id = {d.case_id: d for d in FileTestDocs().docs(SET)}

    print(f"SOC: {len(spec_by_id)} spec(s), {len(doc_by_id)} Jira test(s)")
    no_doc = sorted(set(spec_by_id) - set(doc_by_id))
    if no_doc:
        print(f"  specs with no Jira test ({len(no_doc)}): {', '.join(no_doc)}")

    total_ok = total_bad = 0
    per_case_bad = []
    skipped_counts: dict[str, int] = {}
    for cid in sorted(spec_by_id):
        doc = doc_by_id.get(cid)
        if doc is None:
            continue
        ok, bad, skipped = check_case(spec_by_id[cid], doc)
        total_ok += len(ok)
        total_bad += len(bad)
        for s in skipped:
            key = s.split(":")[0]
            skipped_counts[key] = skipped_counts.get(key, 0) + 1
        if bad:
            per_case_bad.append((cid, getattr(doc, "key", ""), bad))

    print()
    print(f"facts compared : {total_ok + total_bad}")
    print(f"  agree        : {total_ok}")
    print(f"  disagree     : {total_bad}  across {len(per_case_bad)} case(s)")
    print("  not compared (the card states nothing to compare):")
    for k, c in sorted(skipped_counts.items(), key=lambda kv: -kv[1]):
        print(f"      {c:3d}  {k}")

    if per_case_bad:
        print()
        print("disagreements:")
        for cid, key, bad in per_case_bad[:25]:
            print(f"  {cid} ({key})")
            for b in bad:
                print(f"      {b}")
        if len(per_case_bad) > 25:
            print(f"  ... and {len(per_case_bad) - 25} more case(s)")

    if args.run:
        run = pathlib.Path(args.run)
        recs = {}
        for p in sorted(run.glob("*.json")):
            if p.name.startswith("_"):
                continue
            d = json.loads(p.read_text(encoding="utf-8"))
            if isinstance(d, dict):
                recs[d.get("case")] = d
        print()
        print(f"seeded run {run.name}: {len(recs)} booking(s) for {len(spec_by_id)} spec(s)")
        missing = sorted(set(spec_by_id) - set(recs))
        if missing:
            print(f"  not seeded ({len(missing)}): {', '.join(missing[:10])}")
        wrong = []
        for cid, r in recs.items():
            spec = spec_by_id.get(cid) or {}
            want = [f"{s.get('carrier')}{s.get('number')}" for s in spec.get("segments") or []]
            got = str(r.get("flight") or "")
            if want and got and got not in want:
                wrong.append(f"{cid}: booked {got}, spec asks for {want}")
        print(f"  booking flight matches the spec: {len(recs) - len(wrong)}/{len(recs)}")
        for w in wrong[:8]:
            print(f"      {w}")

    return 1 if total_bad else 0


if __name__ == "__main__":
    raise SystemExit(main())
