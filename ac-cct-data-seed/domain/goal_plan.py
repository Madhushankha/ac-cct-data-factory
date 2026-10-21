"""A Jira/Xray test turned into a goal-mode chat plan for the automation suite.

The suite's AI customer (`playwright-baggage/src/goal.ts`, `GoalItem`) already knows how to follow a
test: give it the Cucumber customer steps in order as `script`, the assistant lines the test expects
as `checkpoints`, and the test's sample data as `sample`, and it plays the steps on the seeded
booking and has an AI judge check each expected line against the transcript (with the quote
verified). What was missing is the producer. This is it, from the synced snapshot in `jira/`:

    checkpoints.json  -> one row per Gherkin line, already classified (kind + method)
    test.feature      -> the same lines, for the line numbers a failure cites
    a pool booking    -> the PNR and name the chat really uses

Three things are done to the Jira text on the way, because it is not usable as is:

* **Sample data is replaced.** `[First Name] [Last Name]`, `PNR: [PNR Code]`, the example name the
  test happens to use, the example OTP (546879) and masked contacts (`t***@gmail.com`) all describe a
  booking that does not exist. The customer types the seeded booking's values instead; the OTP and
  the email/phone choice become the steps the harness knows how to perform.
* **Damaged characters are cleaned.** The snapshot carries replacement characters where Jira lost
  bullets and arrows (see `domain/testdoc.py`). A ` ? ` between words was an arrow and becomes one;
  a lone replacement character is dropped.
* **Only chat-checkable rows go to the judge.** Bot, alert, verdict, payment and identity lines
  verified "by chat" are judged against the transcript. Dashboard rows are kept apart, mapped where
  possible to the Claims Dashboard testing API's item ids, for the post-chat check; email rows are
  kept for the mailbox check. Seed prerequisites and implied system steps are not chat evidence.

Pure functions over dicts: no file, network or adapter is touched here.
"""
from __future__ import annotations

import re
from dataclasses import dataclass, field
from typing import Any

from domain.testdoc import readable

#: the character a lost bullet, arrow or accent arrives as
_REPLACEMENT = "�"

#: checkpoint kinds the AI judge checks against the chat transcript (method must be "chat")
JUDGED_KINDS = ("bot", "alert", "verdict", "payment", "idv")

#: Jira dashboard checks -> the Claims Dashboard testing API item that answers them
#: (GET /v1/testing/cases/{caseNumber}/verification, items CP102..CP156). A STARTING table: the two
#: numberings are unrelated (Jira's CP ids are per test and sequential), so this matches on what a
#: row talks about. Unmatched rows keep `api: None` and are reported as unmapped, never guessed.
DASHBOARD_MAP: tuple[tuple[str, str], ...] = (
    (r"\bstatus is\b|case status", "CP105"),
    (r"chatbot transcript|transcript", "CP152"),
    (r"attachment|receipt", "CP153"),
    (r"ac wallet|wallet", "CP133"),
    (r"compensation (amount|chosen)|chosen compensation|payment method|interac|payout", "CP132"),
    (r"eligib", "CP136"),
    (r"decision assist", "CP134"),
    (r"\bdds\b", "CP135"),
    (r"aeroplan tier|tier", "CP127"),
    (r"aeroplan", "CP126"),
    (r"claimant (full )?name|customer name|passenger name", "CP112"),
    (r"claimant type|passenger type", "CP113"),
    (r"authenticat|verified customer", "CP114"),
    (r"\bemail\b", "CP123"),
    (r"\bphone\b", "CP124"),
    (r"address", "CP125"),
    (r"pnr creation", "CP116"),
    (r"journey|bound", "CP117"),
    (r"booking source", "CP118"),
    (r"office", "CP119"),
    (r"regime|appr|eu261|\bdot\b", "CP120"),
    (r"\bpnr\b|booking reference", "CP115"),
    (r"sub-?topic|topic|intent", "CP103"),
    (r"final status|resolved", "CP154"),
    (r"case status|status", "CP105"),
    (r"case (created|number)|case id", "CP102"),
    (r"created date|creation date", "CP106"),
    (r"updated date|last updated", "CP107"),
    (r"\bsla\b", "CP108"),
    (r"team|queue|assign", "CP109"),
    (r"banner", "CP110"),
    (r"ancillary fees? section|ancillary section", "CP129"),
    (r"ancillary", "CP130"),
    (r"duplicate", "CP138"),
    (r"related case", "CP140"),
    (r"cybersource|fraud", "CP141"),
    (r"acknowledg", "CP147"),
    (r"adobe|eligible email", "CP148"),
    (r"communication", "CP151"),
    (r"agent note|notes", "CP149"),
    (r"audit|timeline|transition", "CP150"),
)


@dataclass(frozen=True, slots=True)
class Booking:
    """The seeded booking a test is played on, as the pool hands it over."""
    pnr: str
    first: str
    last: str
    case_id: str = ""
    pool: str = ""


@dataclass(slots=True)
class Plan:
    """One `GoalItem` for the suite, plus what the post-chat checks need."""
    item: dict[str, Any]
    unmapped_dashboard: list[str] = field(default_factory=list)
    notes: list[str] = field(default_factory=list)


# ------------------------------------------------------------------ text

def clean(text: str | None) -> str:
    """Jira's damaged text made readable: arrows back, lone replacement characters dropped."""
    t = readable(text)                                              # bullets, title dashes, YYZ�YYC
    t = re.sub(r"\s\?\s", " → ", t)                          # "Regular ? NOT ELIGIBLE"
    t = re.sub(rf"(?<=[A-Z]{{3}})[?{_REPLACEMENT}](?=[A-Z]{{3}}\b)", "→", t)   # "YYZ?YYC"
    t = t.replace(_REPLACEMENT, "")
    return re.sub(r"[ \t]+", " ", t).strip()


def quoted(step: str) -> str | None:
    """The first quoted value of a Gherkin line, with or without a colon before it. Some tests
    double the quotes (`""Yes""`), which a plain `"(.*?)"` reads as an empty value."""
    m = re.search(r'"+([^"]+)"+', step or "")
    if m:
        return m.group(1)
    return "" if '""' in (step or "") else None


# ------------------------------------------------------------------ customer steps

_NAME_PLACEHOLDER = re.compile(r"\[\s*first name\s*\]|\[\s*last name\s*\]", re.I)
_PNR_PLACEHOLDER = re.compile(r"\[\s*pnr(?: code)?\s*\]", re.I)
_PERSON = re.compile(r"^[A-Z][^\d\s:]+(?:[ -][A-Z][^\d\s:]+){1,3}$")


def script_step(cp: dict[str, Any], booking: Booking, sample: dict[str, str]) -> dict[str, Any] | None:
    """One customer checkpoint as a `ScriptStep`, with the test's sample data swapped for the
    booking's. `None` for a line the harness does itself (opening the chat)."""
    step = clean(cp.get("step"))
    low = step.lower()
    value = clean(quoted(step) if quoted(step) is not None else cp.get("expected"))
    section = str(cp.get("section") or "").lower()
    if "opens the agentic chatbot" in low or "opens the chatbot" in low:
        return None
    if re.search(r"\botp\b|verification code", low):
        if value:
            sample.setdefault("otp", value)
        return {"type": "otp"}
    if "persona" in low:
        return {"type": "click", "value": "Get verified"}
    if re.search(r"selects?\s+\"?english", low):
        return {"type": "click", "value": "English"}
    if re.search(r"\b(says|types)\b", low):
        return {"type": "say", "value": _swap(value, booking, sample)}
    if re.search(r"\bprovides?\b", low):
        return {"type": "provide", "value": _provided(value, section, booking, sample)}
    if re.search(r"\b(selects?|confirms?|clicks?)\b", low):
        if re.match(r"(email|e-mail|phone|sms|text)\s*:", value, re.I):
            # a masked contact option from the test's example booking: pick the channel on screen
            sample.setdefault("contact", value)
            return {"type": "click", "value": value.split(":")[0].strip().title()}
        if value:
            return {"type": "click", "value": _swap(value, booking, sample)}
        return {"type": "assumed", "value": "the button the assistant offers",
                "reason": f"the test says only: {step[:120]}"}
    return {"type": "assumed", "value": value or step,
            "reason": "a customer line of a shape this builder does not recognise"}


def _provided(value: str, section: str, booking: Booking, sample: dict[str, str]) -> str:
    """What the customer types for a `provides` line: during identification the name and the
    booking reference are always the booking's, whatever the test's example says."""
    full = f"{booking.first} {booking.last}".strip()
    if _PNR_PLACEHOLDER.search(value) or re.match(r"\s*pnr\s*:", value, re.I):
        example = re.sub(r"(?i)^\s*pnr\s*:\s*", "", value)
        if not _PNR_PLACEHOLDER.search(example):
            sample.setdefault("pnr", example)          # a real example, e.g. TC024
        return booking.pnr
    if _NAME_PLACEHOLDER.search(value):
        return full
    if "identif" in section and _PERSON.match(value):
        sample.setdefault("name", value)
        return full
    return _swap(value, booking, sample)


def _swap(value: str, booking: Booking, sample: dict[str, str]) -> str:
    """Placeholders and the sample name/PNR inside free text, replaced by the booking's."""
    full = f"{booking.first} {booking.last}".strip()
    v = re.sub(r"\[\s*first name\s*\]\s*\[\s*last name\s*\]", full, value, flags=re.I)
    v = re.sub(r"\[\s*first name\s*\]", booking.first, v, flags=re.I)
    v = re.sub(r"\[\s*last name\s*\]", booking.last, v, flags=re.I)
    v = _PNR_PLACEHOLDER.sub(booking.pnr, v)
    if sample.get("name"):
        v = v.replace(sample["name"], full)
        # the example's first name on its own ("Dominique here") is the customer too
        first = sample["name"].split()[0]
        v = re.sub(rf"\b{re.escape(first)}\b", booking.first, v)
    if sample.get("pnr"):
        v = v.replace(sample["pnr"], booking.pnr)
    return v


# ------------------------------------------------------------------ the plan

#: identity verification (Persona / IDV) cannot be automated: the chat still passes the step so the
#: flow continues, but nothing about it counts. Kept in the plan as `skipped`, visible in reports.
_IDV = re.compile(r"\bidv\b|persona|identity verification|verify (your|the customer'?s?) identity|"
                  r"identity (check|has been|verified)", re.I)
IDV_SKIP = "IDV not automated"

#: the bot asks how many people are on the claim, and lists them, only when the booking has more than
#: one passenger -- on a single-passenger booking it goes straight to the journey, as it should
_PAX_QUESTION = re.compile(r"how many (people|passengers)|people (are )?on (your|the) claim|"
                           r"who (would you like to|should we) include|passengers? (list|on (your|this) booking)", re.I)
SINGLE_PAX_SKIP = "not applicable (1 passenger)"

#: lines filed under chat that describe what the SYSTEM did, which no transcript shows
_NOT_IN_CHAT = re.compile(r"\bsystem checks?\b|cybersource|\bdispatched\b|auto-approved|"
                          r"\bfraud\b|then the system\b", re.I)
_MASKED_EMAIL = re.compile(r"\b[a-z0-9]\*{2,}@[\w.-]+\b", re.I)
_MASKED_PHONE = re.compile(r"\+\d?\*{2,}\d+")


def _masked_contacts(text: str) -> str:
    """The test's example masked contacts (c***@gmail.com, +1***567) belong to a booking that does not
    exist; the judge must accept whatever masked contact the seeded booking shows."""
    text = _MASKED_EMAIL.sub("<the booking's masked e-mail>", text)
    return _MASKED_PHONE.sub("<the booking's masked phone>", text)


def feature_lines(feature: str) -> list[str]:
    return [clean(line) for line in (feature or "").splitlines()]


def _line_of(step: str, lines: list[str], start: int) -> tuple[int | None, int]:
    """The 1-based feature line a checkpoint came from, searching forward from `start`."""
    want = clean(step)[:60]
    if not want:
        return None, start
    for i in range(start, len(lines)):
        if want and want in lines[i]:
            return i + 1, i + 1
    return None, start


def dashboard_api_id(cp: dict[str, Any]) -> str | None:
    text = f"{cp.get('step') or ''} {cp.get('expected') or ''}".lower()
    for pattern, api in DASHBOARD_MAP:
        if re.search(pattern, text):
            return api
    return None


#: how a receipt category is named to the judge
_RECEIPT_NAMES = {"hotel": "hotel", "meal": "meal", "transport": "taxi/transport",
                  "essentials": "essential items", "communication": "communication",
                  "parking": "parking",
                  # baggage interim expenses (tools/baggage_receipts.py)
                  "clothing": "clothing", "footwear": "footwear", "personal_care": "personal care",
                  "accessories": "accessories"}


def receipt_rows(receipts: list[dict[str, Any]]) -> tuple[list[dict], list[dict], list[dict]]:
    """A case's receipt manifest entries (tools/soc_receipts.py, tools/baggage_receipts.py) -> what
    the plan item uploads, the judged checkpoints the chat must show for them, and the Claims
    Dashboard attachment row. `file` must already be the path the suite resolves (relative to
    playwright-baggage). An entry's own `judge` text, when it has one, is the checkpoint as is."""
    files, judged = [], []
    for r in receipts:
        cur, total = str(r.get("currency") or ""), float(r.get("total") or 0)
        files.append({"file": r["file"], "category": r.get("category"), "total": total,
                      "currency": cur})
        name = _RECEIPT_NAMES.get(str(r.get("category")), str(r.get("category") or "the"))
        cap = r.get("cap") or {}
        if r.get("judge"):
            text = str(r["judge"])
        elif r.get("approved") is not None and str(r.get("expected", "")).startswith("partial"):
            text = (f"The assistant accepts the {name} receipt for {cur} {total:.2f} and approves it "
                    f"capped at {cap.get('currency', cur)} {float(r['approved']):.2f} "
                    f"(or shows the capped amount in the expense summary)")
        else:
            text = (f"The assistant accepts the {name} receipt for {cur} {total:.2f} and approves it "
                    f"(or shows it in the expense summary)")
        judged.append({"kind": "receipt", "requirement": "RR-01", "text": text, "line": None,
                       "jiraCheckpoint": None, "file": r["file"]})
    dashboard = [{"jiraCheckpoint": None, "api": "CP153",
                  "check": f"The Attachments tab shows the {len(files)} uploaded receipt(s)",
                  "expected": str(len(files)), "manual": False, "source": "receipts"}] if files else []
    return files, judged, dashboard


def build(doc: dict[str, Any], feature: str, booking: Booking, *,
          allow_payment: bool | None = None, passengers: int | None = None,
          receipts: list[dict[str, Any]] | None = None) -> Plan:
    """One test's checkpoints.json (+ its feature text) and a booking -> a goal plan item.

    `receipts`: the case's receipt manifest entries (tools/soc_receipts.py), `file` relative to the
    suite. They become the item's `receipts` (what `upload_files` attaches), one judged checkpoint
    of kind "receipt" each, and a CP153 attachments row with the expected count."""
    lines = feature_lines(feature)
    sample: dict[str, str] = {}
    script, judged, dashboard, emails, skipped = [], [], [], [], []
    unmapped: list[str] = []
    cursor = 0
    for cp in doc.get("checkpoints") or []:
        kind, method = cp.get("kind"), cp.get("method")
        line, cursor = _line_of(str(cp.get("step") or ""), lines, cursor)
        if kind != "customer" and (kind == "idv" or _IDV.search(
                f"{cp.get('step') or ''} {cp.get('expected') or ''} {cp.get('section') or ''}")):
            skipped.append({"jiraCheckpoint": cp.get("id"), "kind": kind,
                            "check": clean(cp.get("expected") or cp.get("step")), "line": line,
                            "reason": IDV_SKIP})
            continue
        if passengers == 1 and kind != "customer" and _PAX_QUESTION.search(
                f"{cp.get('step') or ''} {cp.get('expected') or ''}"):
            skipped.append({"jiraCheckpoint": cp.get("id"), "kind": kind,
                            "check": clean(cp.get("expected") or cp.get("step")), "line": line,
                            "reason": SINGLE_PAX_SKIP})
            continue
        if kind == "customer":
            st = script_step(cp, booking, sample)
            if st:
                if line:
                    st["line"] = line
                script.append(st)
        elif kind in JUDGED_KINDS and method == "chat":
            text = clean(cp.get("expected") or cp.get("step"))
            if _NOT_IN_CHAT.search(f"{cp.get('step') or ''} {text}"):
                # a back-office fact the customer never sees: judging it on the chat can only
                # report "not reached". It belongs to the dashboard/API checks.
                dashboard.append({"jiraCheckpoint": cp.get("id"), "api": dashboard_api_id(cp),
                                  "check": text, "expected": None, "manual": False})
                continue
            judged.append({"kind": kind, "requirement": cp.get("requirement"),
                           "text": _masked_contacts(text), "line": line,
                           "jiraCheckpoint": cp.get("id")})
        elif kind == "dashboard" or method == "dashboard":
            step = clean(cp.get("step"))
            if re.match(r"(scenario\b|given the agent opens)", step, re.I):
                continue                      # a heading or the agent opening the page: no check
            api = dashboard_api_id(cp)
            dashboard.append({"jiraCheckpoint": cp.get("id"), "api": api, "check": step,
                              "expected": clean(cp.get("expected") or quoted(step)) or None,
                              "manual": method == "manual"})
            if api is None:
                unmapped.append(str(cp.get("id")))
        elif kind == "email" or method == "email":
            emails.append({"jiraCheckpoint": cp.get("id"), "check": clean(cp.get("step")),
                           "expected": clean(cp.get("expected")) or None})
    files: list[dict] = []
    if receipts:
        files, receipt_judged, receipt_dash = receipt_rows(receipts)
        judged += receipt_judged
        dashboard += receipt_dash
    pays = any(c["kind"] == "payment" for c in judged)
    allow = ["payout-country", "payment-proceed"] if (pays if allow_payment is None
                                                      else allow_payment) else []
    item: dict[str, Any] = {
        "pnr": booking.pnr, "caseId": booking.case_id or doc.get("test_id"),
        "pool": booking.pool or None, "jiraKey": doc.get("key"),
        "title": clean(doc.get("title")), "goal": clean(doc.get("goal")) or None,
        "script": script, "checkpoints": judged,
        "sample": {k: v for k, v in sample.items() if k in ("name", "pnr", "first")},
        "allow": allow,
        # not read by goal.ts today: carried for the post-chat dashboard and mailbox checks
        "dashboard": dashboard, "emails": emails,
        # this case's own receipts; goal.ts `upload_files` attaches these instead of the generic set
        "receipts": files,
        # shown in reports as skipped, never judged
        "skipped": skipped,
    }
    if sample.get("name"):
        item["sample"]["first"] = sample["name"].split()[0]
    notes = []
    if not script:
        notes.append("no customer steps: the chat would run on the goal alone")
    if any(s["type"] == "assumed" for s in script):
        notes.append(f"{sum(s['type'] == 'assumed' for s in script)} customer step(s) not "
                     f"recognised, passed on as 'assumed'")
    return Plan(item={k: v for k, v in item.items() if v not in (None, [], {})} | {
        "script": script, "checkpoints": judged}, unmapped_dashboard=unmapped, notes=notes)
