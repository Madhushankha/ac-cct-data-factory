"""Publish a batch the uat-scenarios builder produced, in its own order.

    python -m lanes.replay <batch>/messages.jsonl --env int --go

Why this exists. Our renderer writes five messages across three feeds -- two PNR versions, one
ticket, an FDM schedule and an FDM estimate. Cascade's `/qa builder`, driven by the kit's
`scenario_build.py`, writes twenty-one across five for the same case:

    PNR 7 · TKT 4 · PNRCORR 2 · CM 3 · FDM 5 (SKD, ETD, DEP, ARR, ARRIVAL_CODE)

and it spreads them over the booking's real life -- sold on one date, flown a month later, with
ticket coupons changing status after the flight lands. It builds that from one of five anonymised
PROD histories in `seed-pool/`, so what reaches the topic is shaped like a booking the environment
has actually seen rather than like our idea of one.

Each row already carries its own `topic`, `seq`, `at` and `value`, so publishing is just sending
them in sequence. `key` is null throughout: the kit publishes unkeyed, where our seeder keys PNR on
the locator and FDM on the flight number.

**What this does NOT do, and it matters.** The kit never publishes a batch that TripTracer's own
parsers have not accepted -- `event_replay.py check --harness tt-replay-check` runs first, twice at
most, and a batch that still fails is abandoned rather than sent. That harness is a Rust binary this
host cannot build, and the `event_replay.py` in the cascade checkout has not had the kit's
`/qa-builder` exemption patch applied, so neither its check nor its publish path is available here.
Sending a batch with this module therefore skips the validation the kit treats as mandatory, and
skips its consumer-group audit too. The payloads are the builder's own rather than ours, which is
the point, but "unvalidated" is the honest word for it.
"""
from __future__ import annotations

import argparse
import datetime as _dt
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

# after the insert, not before: imported first, `core` resolves against whatever else is
# on sys.path (another checkout of this project, or cct-qa-framework) rather than ours
from core import paths  # noqa: E402
AQA = paths.agentic_qa()


#: the seed pool's anonymised contacts. Readable by nobody, which is the point for a PROD capture
#: and useless for a test a person has to walk: the OTP goes to the booking's e-mail.
_SYNTH_EMAIL = re.compile(r"[\w.+-]+@[\w.-]*synth\.test")
_PHONE_FIELD = re.compile(r'("number"\s*:\s*")(\+?[0-9][0-9 ()-]{5,})(")')


def discover_name(batch: list[dict]) -> tuple[str, str]:
    """The passenger's first and last name, as the PNR states them.

    Taken from the PNR's own `names` array rather than guessed: the builder also emits a TKT block
    whose `firstName` holds the SURNAME (`"firstName":"BOUCHARD","lastName":"BOUCHARD"`), so a
    field-by-field rewrite would silently correct that and produce a booking that differs from what
    the builder actually makes. Replacing by value keeps every occurrence, quirk included.
    """
    for r in batch:
        v = r["value"] if isinstance(r["value"], str) else json.dumps(r["value"])
        m = re.search(r'"names"\s*:\s*\[\s*\{\s*"firstName"\s*:\s*"([^"]*)"\s*,'
                      r'\s*"lastName"\s*:\s*"([^"]*)"', v)
        if m:
            return m.group(1), m.group(2)
    return "", ""


#: digit -> letter, so a case number can ride in a surname without a digit in it. A -> 0 ... J -> 9,
#: which is reversible: automation computes the surname from the case id, or reads the id back off a
#: booking it found.
_DIGIT_LETTER = {str(d): chr(ord("A") + d) for d in range(10)}


def case_token(case_id: str) -> str:
    """The case's number as letters: FD_TC_001 -> AAB, SOC_UAT_064 -> AGE.

    Letters because a surname with digits in it is not a name any feed has seen. Every surname the
    existing seeder mints is alphabetic (RENVOLGIL, KORFENSOR, GILKELJAR), real PNRs carry no
    numerals in a name, and Amadeus-side name validation is not something to discover by seeding
    343 bookings that might all be refused.
    """
    digits = "".join(ch for ch in case_id if ch.isdigit())
    return "".join(_DIGIT_LETTER[d] for d in digits)


def case_pack(case_id: str) -> str:
    """One letter for which pack the case is from, so two packs cannot collide on a number.

    FD_TC_007 and FD_ED_TC_007 would otherwise both end in AAG.
    """
    up = case_id.upper()
    return "E" if "_ED_" in up else "S" if up.startswith("SOC") else ""


def case_surname(case_id: str, base: str = "") -> str:
    """A surname that identifies the SCENARIO, for automation reading one shared inbox.

    One Mailinator box takes every scenario's mail, so what distinguishes them has to be inside the
    message, and the passenger name is what a reader has. The specs cannot serve: 343 of them carry
    406 passenger rows with only 295 distinct names, and 44 names are reused -- CATHERINE BOUCHARD
    covers nine cases (FD_TC_001 to 004 among them), MARC-ANDRE LAVOIE fifteen. A minted random
    surname is no better: unique, but unknowable before the run.

    So: the spec's own surname, then the pack letter, then the number as letters.

        FD_TC_001     BOUCHARD -> BOUCHARDAAB
        FD_ED_TC_07   GAGNON   -> GAGNONEAG
        SOC_UAT_064   FORTIN   -> FORTINSAGE

    Unique by construction, identical on every run, computable from the case id alone, alphabetic,
    and with no space in it -- the lookup normalises case but not spacing.
    """
    stem = (base or "".join(ch for ch in case_id if ch.isalpha())).upper()
    return f"{stem}{case_pack(case_id)}{case_token(case_id)}"


def with_name(value: str, old: tuple[str, str], new: tuple[str, str]) -> str:
    """Rename the passenger everywhere the old name appears, by value.

    `fullName` is covered without a rule of its own, because replacing each part also fixes the
    string they are concatenated into. Order matters only in that both parts are replaced
    independently; a first name that equals the surname (the TKT quirk) therefore stays equal.
    """
    out = value
    for before, after in zip(old, new):
        if before and after and before != after:
            out = out.replace(before, after)
    return out


def with_contact(value: str, email: str, phone: str) -> str:
    """The same message with the synthetic contact replaced by one a tester can read.

    Only two things are rewritten, both in place and both the same kind of value they replace: an
    address matching `*@synth.test`, and the digits inside a `"number"` field. Nothing else in the
    payload is touched -- the builder's output is the thing we want, and a broader substitution on
    a PNR would be a good way to corrupt it quietly.
    """
    out = _SYNTH_EMAIL.sub(email, value)
    if phone:
        out = _PHONE_FIELD.sub(lambda m: m.group(1) + phone + m.group(3), out)
    return out


def rows(path: pathlib.Path) -> list[dict]:
    out = [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]
    # `seq` is the builder's own ordering of the booking's life; the fold depends on it
    return sorted(out, key=lambda r: r.get("seq") or 0)


def cases_by_booking(messages: pathlib.Path) -> dict[str, str]:
    """pnrId -> scenario id, from the manifest beside the batch.

    Per booking, not per batch: a batch holds up to 120 scenarios and each needs its OWN
    scenario-unique surname. Taking the first manifest row and applying its name to every booking
    would give 25 cases one identity and defeat the point of the exercise.
    """
    man = messages.parent.parent / "manifest.json"
    if not man.exists():
        return {}
    return {r["pnrId"]: r.get("id", "") for r in json.loads(man.read_text(encoding="utf-8"))
            if r.get("pnrId")}


def discover_name_for(batch: list[dict], booking: str) -> tuple[str, str]:
    """That one booking's passenger name, as its own PNR states it."""
    return discover_name([r for r in batch if r.get("booking") == booking])


def publish(path: pathlib.Path, env_name: str = "int", *, dry_run: bool = True,
            contact: bool = False, email: str = "", phone: str = "",
            first_name: str = "", last_name: str = "", unique_name: bool = False,
            log=print) -> list[dict]:
    batch = rows(path)
    if not batch:
        log(f"[replay] {path} holds no messages")
        return []
    bookings = sorted({r.get("booking") for r in batch})
    feeds: dict[str, int] = {}
    for r in batch:
        feeds[r.get("feed") or "?"] = feeds.get(r.get("feed") or "?", 0) + 1
    log(f"[replay] {len(batch)} message(s) for {', '.join(bookings)}"
        + ("  (dry run, nothing sent)" if dry_run else ""))
    log("         " + " · ".join(f"{k} {v}" for k, v in sorted(feeds.items())))
    if dry_run:
        for r in batch:
            log(f"    seq{r.get('seq'):<3} {r.get('feed'):<8} {r.get('topic')}")
        return [{"seq": r.get("seq"), "feed": r.get("feed"), "topic": r.get("topic"),
                 "sent": False} for r in batch]

    sys.path.insert(0, str(AQA))
    from aqa.workflows.seed.env import ENVS                                 # noqa: PLC0415
    from aqa.workflows.seed.publish import producer                         # noqa: PLC0415
    env = ENVS[env_name]
    if contact:
        email = email or env.contact_email
        phone = phone or env.contact_phone
    if email or phone:
        log(f"[replay] contact -> {email or '(unchanged)'} / {phone or '(unchanged)'}")
    # One rename per BOOKING. `renames[pnrId] = (old, new)`.
    renames: dict[str, tuple[tuple[str, str], tuple[str, str]]] = {}
    if unique_name or first_name or last_name:
        cases = cases_by_booking(path)
        for booking in bookings:
            old = discover_name_for(batch, booking)
            if not any(old):
                log(f"[replay] {booking}: no passenger name found, left alone")
                continue
            surname = (case_surname(cases.get(booking, booking), old[1]) if unique_name
                       else (last_name or old[1]))
            renames[booking] = (old, (first_name or old[0], surname))
        for booking, (old, new) in sorted(renames.items())[:4]:
            log(f"[replay] {booking}: {old[0]} {old[1]} -> {new[0]} {new[1]}")
        if len(renames) > 4:
            log(f"[replay] ... and {len(renames) - 4} more")
    p = producer(env)
    out = []
    try:
        for r in batch:
            value = r["value"]
            if not isinstance(value, str):
                value = json.dumps(value)
            if email or phone:
                value = with_contact(value, email, phone)
            rename = renames.get(r.get("booking"))
            if rename:
                value = with_name(value, rename[0], rename[1])
            body = value.encode()
            key = (r.get("key") or "")
            md = p.send(r["topic"], value=body,
                        key=key.encode() if key else None).get(timeout=60)
            at = _dt.datetime.now(_dt.timezone.utc).strftime("%H:%M:%SZ")
            log(f"    sent {at} seq{r.get('seq'):<3} {r.get('feed'):<8} "
                f"{r['topic']} -> offset {md.offset}")
            out.append({"seq": r.get("seq"), "feed": r.get("feed"), "topic": r["topic"],
                        "sent": True, "offset": md.offset, "at": at})
        p.flush(timeout=60)
    finally:
        p.close(timeout=10)
    return out


if __name__ == "__main__":
    ap = argparse.ArgumentParser(prog="lanes.replay", description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("messages", help="a builder batch's messages.jsonl")
    ap.add_argument("--env", default="int")
    ap.add_argument("--unique-name", action="store_true",
                    help="give the passenger a surname derived from the case id "
                         "(BOUCHARD001 for FD_TC_001), so automation reading one shared inbox can "
                         "tell which scenario a message belongs to. The specs cannot: 44 of their "
                         "names are reused, one across nine cases")
    ap.add_argument("--first-name", default="", help="rename the passenger's first name")
    ap.add_argument("--last-name", default="", help="rename the passenger's surname (no spaces)")
    ap.add_argument("--email", default="", help="an explicit contact e-mail")
    ap.add_argument("--phone", default="", help="an explicit contact phone")
    ap.add_argument("--contact", action="store_true",
                    help="replace the seed pool's synth.test address and synthetic phone with the "
                         "environment's own contact, so a tester can read the OTP")
    ap.add_argument("--go", action="store_true",
                    help="actually publish. Without it, a dry run. Note the module docstring: this "
                         "path skips the parser validation the kit treats as mandatory")
    a = ap.parse_args()
    raise SystemExit(0 if publish(pathlib.Path(a.messages), a.env, dry_run=not a.go,
                                  contact=a.contact, email=a.email, phone=a.phone,
                                  first_name=a.first_name, last_name=a.last_name,
                                  unique_name=a.unique_name) else 1)
