"""Publishing a built batch to an environment's topics.

Implements `ports.Publisher`.

Transport is agentic-qa's producer and the environment's own topic names -- proven code, and the
same cluster the kit publishes to (`emh-int.EAI-FDM-INT` on INT is both). Only the payloads were
ever the question, and those come from the builder.

Two things this does beyond sending bytes:

**It can rewrite the identity.** The seed pool's contacts are `*@synth.test` addresses nobody can
read, and an OTP goes to the booking's e-mail. One inbox takes every scenario's mail, so the
passenger's surname is what tells automation which scenario a message belongs to -- and the
scenarios cannot serve: 343 of them carry 406 passenger rows with only 295 distinct names, one name
covering nine cases. `unique_name` derives a surname from the case id, alphabetically, because no
feed has ever carried a digit in a name.

**It admits what it cannot do.** `validate` returns `(False, reason)`: the kit never publishes a
batch TripTracer's own parsers have not accepted, and that harness needs a Rust toolchain this host
cannot complete. Saying so is the honest alternative to silently skipping the step.
"""
from __future__ import annotations

import datetime as _dt
import json
import re
import sys
from dataclasses import dataclass, field
from typing import Any

from core import paths
from ports import BuiltBatch

#: the seed pool's anonymised contacts, which no tester can read
_SYNTH_EMAIL = re.compile(r"[\w.+-]+@[\w.-]*synth\.test")
#: the SSR contact elements a booking's history carries: CTCE (e-mail) and CTCM (mobile). The builder
#: fills their text with "SYNTHETIC TEXT", and the chat reads CTCE as "the e-mail on file" -- it offered
#: `SY***` for the OTP on every booking that has one (FD_TC_002/003/004/014/015/016/030, BAT 2026-10-21).
#: Bounded and inside one SSR object: `"code":"CTCE"` ... `"text":"SYNTHETIC TEXT"` without leaving it.
_SSR_CONTACT = re.compile(r'("code"\s*:\s*"(CTCE|CTCM)"(?:(?!"code"\s*:\s*"[A-Z]{4}")[^\]]){0,600}?"text"\s*:\s*")SYNTHETIC TEXT(")')


def ssr_email(email: str) -> str:
    """IATA CTCE free text: upper case, `@` written as `//`."""
    return email.upper().replace("@", "//")


_PHONE_FIELD = re.compile(r'("number"\s*:\s*")(\+?[0-9][0-9 ()-]{5,})(")')
#: `"id":"YULAC08AA"` inside an `office` object, in both shapes the builder emits
_OFFICE = re.compile(r'("office"\s*:\s*\{[^{}]*?"id"\s*:\s*")([A-Z0-9]{6,12})(")')
#: the traveller's date of birth, which the PNR carries under two spellings -- `birthDate` is the
#: builder's and `dateOfBirth` is the one a real Altea traveller uses. Both are rewritten together
#: or the booking contradicts itself. The value comes from the seed pool's own histories
#: (1980-01-01 on every FD automation booking), the same as the name, email and phone this
#: rewrite already replaces, so this is where a tester's real date of birth belongs too.
_DOB_FIELD = re.compile(r'("(?:birthDate|dateOfBirth)"\s*:\s*")(\d{4}-\d{2}-\d{2})(")')
_NAMES = re.compile(r'"names"\s*:\s*\[\s*\{\s*"firstName"\s*:\s*"([^"]*)"\s*,'
                    r'\s*"lastName"\s*:\s*"([^"]*)"')

#: digit -> letter, so a case number can ride in a surname without a digit in it, and can be read
#: back off a booking that was found rather than predicted
_DIGIT_LETTER = {str(d): chr(ord("A") + d) for d in range(10)}


def case_surname(case_id: str, base: str = "") -> str:
    """A surname that identifies the scenario: BOUCHARD + FD_TC_001 -> BOUCHARDAAB.

    The pack letter (E for the edge set, S for SOC) is there because FD_TC_007 and FD_ED_TC_007
    would otherwise both end in AAG.
    """
    up = case_id.upper()
    pack = "E" if "_ED_" in up else "S" if up.startswith("SOC") else ""
    token = "".join(_DIGIT_LETTER[c] for c in case_id if c.isdigit())
    stem = (base or "".join(c for c in case_id if c.isalpha())).upper()
    return f"{stem}{pack}{token}"


#: the private Mailinator domain: any inbox name on it exists without being created
MAILINATOR_DOMAIN = "ae-qa1-aircanada.mailinator.com"


#: every per-booking inbox starts with the owner's name, so the team can tell whose they are
INBOX_PREFIX = "lahiru"


def case_inbox(case_id: str, tag: str, domain: str = MAILINATOR_DOMAIN,
               prefix: str = INBOX_PREFIX) -> str:
    """A Mailinator address only this case's booking uses: BAG_PO_001 + 1020T1531 ->
    lahiru-bag-po-001-1020t1531@ae-qa1-aircanada.mailinator.com.

    One shared inbox makes a run fetch codes one at a time, 70 s apart, and tell mail apart by
    first name -- which twelve baggage cases share. An inbox per booking removes both: whatever
    lands in it is that booking's OTP, eligibility or payment mail.
    """
    slug = "-".join(p for p in _re_slug.split(f"{prefix}-{case_id}-{tag}".lower()) if p)
    return f"{slug[:60].strip('-')}@{domain}"


_re_slug = re.compile(r"[^a-z0-9]+")


def case_phone(case_id: str, tag: str) -> str:
    """A contact phone only this case's booking uses: +1 555 followed by 7 digits from the case and run.

    A shared e-mail was not the only thing merging bookings into one customer profile: with its own
    inbox, FD_TC_001's member still landed on the profile 68 baggage bookings share, because they all
    carried +123456789 too. 555 numbers are fictional, so nobody real is ever texted.
    """
    import hashlib
    digits = int(hashlib.sha256(f"{case_id}|{tag}".encode()).hexdigest(), 16) % 10_000_000
    return f"+1555{digits:07d}"


@dataclass(frozen=True, slots=True)
class Sent:
    """Satisfies `ports.PublishResult`."""
    sent: int
    failures: tuple[str, ...] = ()
    offsets: tuple[int, ...] = field(default=(), repr=False)


@dataclass(frozen=True, slots=True)
class Identity:
    """Who the booking belongs to, when the scenario's own values will not do."""
    email: str | None = None
    phone: str | None = None
    dob: str | None = None
    first_name: str | None = None
    last_name: str | None = None
    unique_name: bool = False
    #: when set, every booking gets its own Mailinator inbox, `case_inbox(case, inbox_tag)`, in place
    #: of `email`. The tag (the run's stamp) keeps a reseed from sharing an inbox with the last run.
    inbox_tag: str | None = None

    @property
    def rewrites_anything(self) -> bool:
        return any((self.email, self.phone, self.dob, self.first_name, self.last_name,
                    self.unique_name))


class KafkaPublisher:
    """Sends a batch through agentic-qa's producer. Satisfies `ports.Publisher`."""

    def __init__(self, env_name: str = "int", *, log=print) -> None:
        self.env_name = env_name
        self.log = log
        self._env = None

    # ------------------------------------------------------------- validate

    def validate(self, batch: BuiltBatch) -> tuple[bool, str]:
        """Whether TripTracer's parsers have accepted this batch. They have not.

        `event_replay.py check --harness tt-replay-check` is the kit's gate and it is mandatory
        there: a batch that fails it twice is abandoned rather than published. The harness is a Rust
        binary requiring 1.98.1 and a complete MinGW -- rustup's bundled one ships no `as.exe`, so
        `dlltool` cannot build the import libraries -- and `event_replay.py` in the cascade checkout
        has not had the kit's `/qa-builder` exemption patch applied either.
        """
        return False, ("not validated: tt-replay-check is unavailable on this host (Rust 1.98.1 "
                       "plus a full MinGW), and event_replay.py lacks the /qa-builder patch")

    # -------------------------------------------------------------- publish

    def publish(self, batch: BuiltBatch, *, dry_run: bool = True,
                identity: Identity | None = None,
                cases: dict[str, str] | None = None,
                force_names: dict[str, tuple[str, str]] | None = None,
                offices: dict[str, str] | None = None) -> Sent:
        """Send the batch. Dry run by default: this writes to topics other services read.

        `cases` maps pnrId to case id, for `identity.unique_name`. Renaming is per BOOKING: a batch
        holds up to a hundred scenarios and each needs its own identity, so applying one name to the
        whole batch would give them all one identity and defeat the purpose.
        """
        rows = list(batch.rows()) if hasattr(batch, "rows") else []
        payloads = list(batch.payloads())
        if not payloads:
            self.log("[publish] nothing to send")
            return Sent(sent=0)

        identity = identity or Identity()
        renames = self._renames(rows, identity, cases or {}, force_names or {})
        self.log(f"[publish] {len(payloads)} message(s) -> {self.env_name}"
                 + ("  (dry run, nothing sent)" if dry_run else ""))
        # always say which contact is going out, not only when something was overridden. The batch
        # file on disk keeps the builder's synthetic address -- the rewrite happens per message on
        # the way out -- so a reader checking that file is misled unless the log states the truth.
        emails = self.emails(batch, identity=identity, cases=cases)
        # with an inbox per booking, the phone is per booking too: both are what the profile
        # service matches a traveller on
        phones = self.phones(batch, identity=identity, cases=cases)
        if emails:
            sample = next(iter(emails.values()))
            self.log(f"[publish] contact -> one inbox and phone per booking ({len(emails)}, e.g. "
                     f"{sample} {next(iter(phones.values()), identity.phone or '')}); "
                     f"{len(renames)} booking(s) renamed")
        else:
            self.log(f"[publish] contact -> {identity.email or self._env_def().contact_email}; "
                     f"{len(renames)} booking(s) renamed")
        if dry_run:
            return Sent(sent=0)

        producer = self._producer()
        offsets: list[int] = []
        failures: list[str] = []
        try:
            for row, (topic, key, body) in zip(sorted(rows, key=lambda r: r.get("seq") or 0),
                                               payloads):
                text = body.decode("utf-8", "replace")
                text = self._rewrite(text, identity, renames.get(row.get("booking")),
                                     (offices or {}).get(row.get("booking")),
                                     emails.get(row.get("booking")), phones.get(row.get("booking")))
                try:
                    md = producer.send(topic, value=text.encode(),
                                       key=key.encode() if key else None).get(timeout=60)
                    offsets.append(md.offset)
                except Exception as ex:                                     # noqa: BLE001
                    failures.append(f"seq{row.get('seq')} {topic}: {type(ex).__name__}: {ex}")
            producer.flush(timeout=60)
        finally:
            producer.close(timeout=10)
        self.log(f"[publish] {len(offsets)} sent, {len(failures)} failed "
                 f"at {_dt.datetime.now(_dt.timezone.utc).strftime('%H:%M:%SZ')}")
        return Sent(sent=len(offsets), failures=tuple(failures), offsets=tuple(offsets))

    # ------------------------------------------------------------ identities

    def identities(self, batch: BuiltBatch, *, identity: Identity | None = None,
                   cases: dict[str, str] | None = None,
                   force_names: dict[str, tuple[str, str]] | None = None,
                   ) -> dict[str, tuple[str, str]]:
        """What name each booking ends up with: the builder's, or the rewrite that replaces it."""
        rows = list(batch.rows()) if hasattr(batch, "rows") else []
        identity = identity or Identity()
        out: dict[str, tuple[str, str]] = {}
        renames = self._renames(rows, identity, cases or {}, force_names or {})
        for booking in sorted({r.get("booking") for r in rows if r.get("booking")}):
            before = self._name_of(rows, booking)
            # the FDM feed groups its rows under a flight key (`AC#422#2026-10-07#YUL`) rather than
            # a pnrId, and those rows carry no passenger. No name means not a booking.
            if not any(before):
                continue
            out[booking] = renames[booking][1] if booking in renames else before
        return out

    def emails(self, batch: BuiltBatch, *, identity: Identity | None = None,
               cases: dict[str, str] | None = None) -> dict[str, str]:
        """pnrId -> the booking's own contact address, when `identity.inbox_tag` asks for one.
        Empty otherwise: every booking then carries the one shared contact."""
        identity = identity or Identity()
        if not identity.inbox_tag:
            return {}
        cases = cases or {}
        rows = list(batch.rows()) if hasattr(batch, "rows") else []
        return {b: case_inbox(cases.get(b, b), identity.inbox_tag)
                for b in sorted({r.get("booking") for r in rows if r.get("booking")})
                if any(self._name_of(rows, b))}

    def phones(self, batch: BuiltBatch, *, identity: Identity | None = None,
               cases: dict[str, str] | None = None) -> dict[str, str]:
        """pnrId -> the booking's own contact phone, alongside its own inbox. An explicit `--phone`
        wins: whoever passed one wants that number on every booking."""
        identity = identity or Identity()
        if identity.phone:
            return {}
        cases = cases or {}
        return {b: case_phone(cases.get(b, b), identity.inbox_tag or "")
                for b in self.emails(batch, identity=identity, cases=cases)}

    # ------------------------------------------------------------ internals

    def _env_def(self) -> Any:
        if self._env is None:
            sys.path.insert(0, str(paths.require("agentic-qa")))
            from aqa.workflows.seed.env import ENVS                         # noqa: PLC0415
            self._env = ENVS[self.env_name]
        return self._env

    def _producer(self) -> Any:
        sys.path.insert(0, str(paths.require("agentic-qa")))
        from aqa.workflows.seed.publish import producer                     # noqa: PLC0415
        return producer(self._env_def())

    def _renames(self, rows: list[dict], identity: Identity, cases: dict[str, str],
                 force_names: dict[str, tuple[str, str]] | None = None,
                 ) -> dict[str, tuple[tuple[str, str], tuple[str, str]]]:
        """Which name each booking ends up with, and what it is replacing.

        `force_names` wins over everything, including `--unique-name`. It carries the name of a
        loyalty member minted for that booking, and the booking MUST match it: the wallet lookup
        disambiguates profiles by name, so a case-derived surname here would leave the booking
        pointing at no member -- and the run would still produce a wallet verdict, about nothing.
        A minted member surname is already unique (checked against ACCP and the database), so
        nothing is lost by letting it win.
        """
        force_names = force_names or {}
        out: dict[str, tuple[tuple[str, str], tuple[str, str]]] = {}
        if not (identity.rewrites_anything or force_names):
            return out
        for booking in sorted({r.get("booking") for r in rows if r.get("booking")}):
            old = self._name_of(rows, booking)
            if not any(old):
                continue
            forced = force_names.get(booking)
            if forced and (forced[0] or forced[1]):
                out[booking] = (old, (forced[0] or old[0], forced[1] or old[1]))
                continue
            surname = (case_surname(cases.get(booking, booking), old[1])
                       if identity.unique_name else (identity.last_name or old[1]))
            out[booking] = (old, (identity.first_name or old[0], surname))
        return out

    @staticmethod
    def _name_of(rows: list[dict], booking: str) -> tuple[str, str]:
        """The passenger's name as that booking's PNR states it.

        From the PNR's `names` array, not field by field: the builder also emits a ticket block
        whose `firstName` holds the surname, and a per-field rewrite would silently correct that,
        producing a booking unlike the one the builder makes.
        """
        for r in rows:
            if r.get("booking") != booking:
                continue
            value = r.get("value")
            text = value if isinstance(value, str) else json.dumps(value)
            m = _NAMES.search(text)
            if m:
                return m.group(1), m.group(2)
        return "", ""

    def _rewrite(self, text: str, identity: Identity,
                 rename: tuple[tuple[str, str], tuple[str, str]] | None,
                 office_id: str | None = None, own_email: str | None = None,
                 own_phone: str | None = None) -> str:
        env = self._env_def()
        # the environment's contact is the DEFAULT, not a reward for overriding something else.
        # Guarding it behind `rewrites_anything` meant a plain `cli seed` published the builder's
        # synthetic `synth-*@synth.test` addresses, and mail sent to those can never be read: the
        # suite fetches from the mailinator box, so a booking that does not carry it is unusable.
        email = own_email or identity.email or env.contact_email
        phone = own_phone or identity.phone or env.contact_phone
        if email:
            text = _SYNTH_EMAIL.sub(email, text)
        if email or phone:
            def _ssr(m: re.Match) -> str:
                if m.group(2) == "CTCE" and email:
                    return m.group(1) + ssr_email(email) + m.group(3)
                if m.group(2) == "CTCM" and phone:
                    return m.group(1) + re.sub(r"\D", "", phone) + m.group(3)
                return m.group(0)
            text = _SSR_CONTACT.sub(_ssr, text)
        if phone:
            text = _PHONE_FIELD.sub(lambda m: m.group(1) + phone + m.group(3), text)
        if identity.dob:
            text = _DOB_FIELD.sub(lambda m: m.group(1) + identity.dob + m.group(3), text)
        if rename:
            # by value, so every occurrence changes together and the builder's own quirks survive
            for before, after in zip(rename[0], rename[1]):
                if before and after and before != after:
                    text = text.replace(before, after)
        if office_id:
            # every office the seed-pool history carries becomes the one the case asks for. The
            # engine reads staff travel off this id (`...ES`), so a case about an employee that
            # keeps the pool's `...AA` office is simply not that case.
            text = _OFFICE.sub(lambda m: m.group(1) + office_id + m.group(3), text)
        return text
