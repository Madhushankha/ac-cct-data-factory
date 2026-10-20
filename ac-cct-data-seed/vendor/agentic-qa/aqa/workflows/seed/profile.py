"""Seed a loyalty member: the Gigya and iFly feeds that build an AWS Customer Profile.

A seeded PNR alone can never carry a wallet, because the wallet decision is made against a
*customer profile*, and profiles are not built from bookings. They are built by two other feeds:

    MULE-LOYALTY-GIGYA-CUSTPROFILE  -> creates the profile (name, email, address, username=FF)
    IFLY-ACCOUNTSTATUSCHANGES       -> AccountStatus
    IFLY-TIERSTATUSUPDATES          -> AeroplanTier

Borrowing a real member's number was the first approach and it does not hold up: the wallet check
compares the PNR name against the profile name, so every case seeded for one member has to reuse
that member's name, and nothing about the member's status is ours to choose. Minting our own member
means the whole chain is ours -- number, name, status, tier -- and a case can ask for a state
(suspended, no status, a particular tier) rather than accepting whatever a stranger's record says.

Payload shapes are copied verbatim from real INT/UAT messages, not invented; see feedtpl/. The
iFly INT topics are empty, so their shapes came from the -UAT twins on the same cluster.
"""
from __future__ import annotations

import json
import random
import uuid
from datetime import datetime, timezone
from pathlib import Path

TEMPLATES = Path(__file__).resolve().parent / "fixtures" / "feeds"

#: Aeroplan numbers are nine digits. Real INT members sit in 4115 93xxx; minting there would risk
#: overwriting a stranger's profile, since the Gigya `username` is the profile key. 4119 is the
#: same 411 stock with a free fourth digit -- every candidate is still checked against ACCP before
#: it is used (see `mint_member`).
FF_BAND = (411900000, 411999999)

#: A synthetic address, so a seeded profile never carries the template member's real one.
ADDRESS = {"addressLine1": "1 TEST BLVD", "addressLine2": "SUITE 100",
           "city": "TORONTO", "state": "ON", "zip": "M5V 1A1", "country": "CA"}

_MON = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
TIERS = ("E25K", "E35K", "E50K", "E75K", "SE100K")
#: A Basic member is a member with no elite status: the profile and an active account, but no
#: tier-status update and no AeroplanTier attribute (what a non-elite member's records look like).
BASIC = "BASIC"


def is_basic(tier) -> bool:
    return str(tier or "").strip().upper() in (BASIC, "BASE", "MEMBER", "NONE")

#: The wallet states the payment flow decides on. P04 asks whether every claim passenger has an
#: "eligible, open AC Wallet, not frozen level 2", and ADD-14 assigns the frozen check to Customer
#: Profile -- so the level is a profile fact we can seed. It is NOT AccountStatus: the frozen stage
#: arrives on its own feed as AeroplanFrozenStage and lands in Attributes.FrozenStage, while
#: AccountStatus stays "A". Values are the ones INT really carries (STG1, STG2, NA).
WALLET_STATES = {
    "open":      {"account_status": "A", "frozen_stage": None},
    "frozen_l1": {"account_status": "A", "frozen_stage": "STG1"},   # frozen, but not level 2
    "frozen_l2": {"account_status": "A", "frozen_stage": "STG2"},   # the state P04 refuses
}


def render_ifly_frozen_stage(member: dict, *, stage: str = "STG2", previous: str = "NA",
                             now: datetime | None = None) -> dict:
    """The frozen-stage event. `STG2` is what P04 means by "frozen level 2"."""
    now = now or datetime.now(timezone.utc)
    d = _ifly("ifly_accountstatuschanges", member,
              {"notificationType": "FROZEN_STAGE_CHANGES", "activityDate": _ifly_date(now),
               "previousStatus": previous, "status": stage}, now)
    d["event"]["eventType"] = "FROZEN_STAGE_CHANGES"
    d["message"][0]["type"] = "FROZEN_STAGE_CHANGES"
    return d

#: Where each message has to go. The iFly ones are counter-intuitive: `cct-customer-profile-ifly-int`
#: subscribes to seven topics and every one of them ends `-UAT` (KAFKA_SOURCE_TOPIC on task
#: definition cct-customer-profile-ifly-int:24). The matching `-INT` topics exist, are empty, and
#: nothing reads them -- publishing there succeeds and is silently ignored.
TOPICS = {
    "gigya_custprofile": "emh-int.MULE-LOYALTY-GIGYA-CUSTPROFILE-INT",
    "ifly_accountstatuschanges": "emh-int.IFLY-ACCOUNTSTATUSCHANGES-UAT",
    "ifly_tierstatusupdates": "emh-int.IFLY-TIERSTATUSUPDATES-UAT",
    "ifly_frozenstagechanges": "emh-int.IFLY-FROZENSTAGECHANGES-UAT",
}


def topics_for(env) -> dict:
    """The loyalty feeds for THIS env, not INT's.

    These names used to be read straight from the dict above whatever environment was being seeded.
    INT is the only cluster that carries them, so on BAT every wallet case published into a cluster
    with no such topic and Kafka reported `failed to update metadata` -- but only after waiting a
    full 60 seconds, which reads as a network fault rather than a missing topic. Two of the FD 27
    died that way on BAT's first run, and they were the only two that seed a profile.
    """
    declared = getattr(env, "loyalty_topics", None)
    if declared is None:            # an env written before this field existed
        return TOPICS
    if not declared:
        raise SystemExit(
            f"env {env.id!r} declares no loyalty feed topics, so a customer profile cannot be "
            f"built there and an AC Wallet case cannot be seeded. INT's names belong to INT's "
            f"cluster. Add `loyalty_topics` to the env once the real names are known.")
    return declared


def _ifly_date(dt: datetime) -> str:
    """iFly spells dates `09-SEP-2026 17:26:35`."""
    return f"{dt.day:02d}-{_MON[dt.month - 1]}-{dt.year} {dt:%H:%M:%S}"


def _template(name: str) -> dict:
    return json.loads((TEMPLATES / f"{name}.json").read_text(encoding="utf-8"))


def member_email(base: str, ff: str) -> str:
    """A per-member address for the PROFILE only. The PNR contact keeps the project's mock address,
    because the OTP provider polls a fixed Mailinator inbox from the env registry.

    Plus-addressing does not work here: the ER inputs are configured `applyNormalization: true`,
    which strips the tag, so `lahiru+<ff>@...` is stored and searched as `lahiru@...` -- measured,
    a search for the plus address returned 0 profiles. A distinct local part survives it.

    What this buys: a seeded profile is no longer one of 50+ sharing the mock address, so it cannot
    be handed to a different passenger by the service's `profile_items[0]` fallback. What it does
    not buy: the wallet lookup searches by the PNR's email, so it still will not reach the profile
    this way -- that needs `loyalty_id`, which both ER schema mappings declare as a match key and
    the PNR consumer never populates.
    """
    import os
    if os.environ.get("AQA_PROFILE_PER_MEMBER_EMAIL") != "1":
        # The project's rule: the profile carries the SAME mock address as the PNR, so one inbox
        # holds every code and a tester (or the OTP provider, which polls a fixed inbox) finds it.
        # A per-member local part sends the chat's verification to lahiru<ff>@..., an inbox nobody
        # is watching -- observed on BAT ZZGO6M, where the chat offered `SY***` and no code could
        # be read. The collision this guarded against (many profiles sharing one address, and the
        # service's `profile_items[0]` fallback handing over the wrong one) is handled by the
        # minted surname instead, which is unique per member and is what the wallet lookup
        # disambiguates on. Set AQA_PROFILE_PER_MEMBER_EMAIL=1 to restore the old behaviour.
        return base
    local, _, domain = base.partition("@")
    return f"{local.split('+', 1)[0]}{ff}@{domain}"



def mint_member(*, first: str, last: str, email: str, phone: str, taken=None, name_taken=None,
                seed: int | None = None, unique_name: bool = True) -> dict:
    """A member identity nobody else holds. `taken(ff) -> bool` checks ACCP for a collision.

    The name is minted too, not just the number. Two runs of one case that reused a name would put
    two same-named profiles in the domain, and the wallet lookup disambiguates candidates by name --
    a tie there is what makes it fall back to `profile_items[0]`. The surname comes from the same
    generator `identity.mint` uses for bookings, so a seeded member reads like the rest of them.

    That generator has only 3,375 names, so a repeat is likely once a few dozen members exist, and a
    repeat is not cosmetic: R5B9L3 (v34) was merged into HEXFZK's (v28) profile because both minted
    MICHAEL HALWENVOL. Every draw is checked with `name_taken(SURNAME) -> bool` (see `surname_taken`)
    and reserved in-process like a booking surname, so parallel workers cannot draw the same one.
    """
    from .identity import _surname, reserve
    rng = random.Random(seed)
    for _ in range(200):
        ff = str(rng.randint(*FF_BAND))
        if taken is None or not taken(ff):
            break
    else:
        raise RuntimeError("could not mint a free Aeroplan number")
    if unique_name:
        for _ in range(200):
            surname = _surname(rng)
            if (name_taken is None or not name_taken(surname)) and reserve("surname", surname):
                break
        else:
            raise RuntimeError("could not mint a free member surname")
        last = surname.title()
        first = (first or "Test").title()
    return {"ff": ff, "first": first, "last": last, "email": member_email(email, ff),
            "phone": phone, "uid": str(uuid.uuid4()), "country": "CA", "language": "EN"}


def account_taken(env):
    """`taken(ff)` for mint_member: an Aeroplan number ACCP already holds.

    Two keys, indexed separately: `_account` is a profile's AccountNumber, and `AeroplanId` is the
    UNIQUE identifier on Gigya and iFly objects -- a second object carrying an existing AeroplanId is
    merged into that profile instead of creating a new member.
    """
    cp, domain = _accp(env), _accp_domain(env)

    def one(key: str, ff: str) -> bool:
        try:
            return bool(cp.search_profiles(DomainName=domain, KeyName=key, Values=[str(ff)],
                                           MaxResults=1).get("Items"))
        except cp.exceptions.ResourceNotFoundException:
            # NOT every domain defines every key. BAT's indexes AeroplanId, CPID and GigyaUID and
            # has no `_account` at all, and ACCP answers an undefined key with the same exception it
            # uses for a missing domain. Treating that as an outage made a healthy environment look
            # unreachable; a key this domain does not have simply cannot hold the number.
            return False

    def taken(ff: str) -> bool:
        return any(one(key, ff) for key in ("_account", "AeroplanId"))
    return taken


def surname_taken(conn):
    """`name_taken(SURNAME)` for mint_member: a surname some trip-tracer passenger already carries.

    ACCP indexes no name key (Gigya: AeroplanId/CPID/GigyaUID; PNRBooking: CPID/PNRId/TravelerId), so
    the passenger table is the only place a used name can be looked up. It covers every member that
    booked a PNR; a member minted without a booking is not in it.
    """
    def taken(surname: str) -> bool:
        if conn is None:
            return False
        cur = conn.cursor()
        cur.execute("select count(*) from passenger where upper(last_name) = %s", (surname.upper(),))
        return cur.fetchone()[0] > 0
    return taken


def render_gigya(member: dict, *, birth: str = "1972-02-03", gender: str = "MALE",
                 now: datetime | None = None) -> dict:
    """The account-created message that makes the profile exist."""
    now = now or datetime.now(timezone.utc)
    iso = now.strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"
    epoch = int(now.timestamp())
    y, mth, day = (int(x) for x in birth.split("-"))
    d = _template("gigya_custprofile")
    eid = str(uuid.uuid4())

    d["event"].update({"eventId": eid, "timestamp": iso})
    d["event"]["saga"]["sagaId"] = member["uid"]
    msg = d["message"][0]
    msg.update({"id": eid, "timestamp": epoch})

    data = msg["data"]
    data.update({"UID": member["uid"], "callId": uuid.uuid4().hex,
                 "created": iso, "registered": iso, "lastUpdated": iso, "time": iso,
                 "createdTimestamp": epoch * 1000, "registeredTimestamp": epoch * 1000,
                 "lastUpdatedTimestamp": epoch * 1000,
                 "isActive": True, "isRegistered": True})
    data["loginIDs"] = {"username": member["ff"], "emails": [],
                        "unverifiedEmails": [member["email"]]}
    data["emails"] = {"verified": [], "unverified": [member["email"]]}

    prof = data["profile"]
    prof.update({"firstName": member["first"], "lastName": member["last"],
                 "email": member["email"], "username": member["ff"],
                 "birthYear": y, "birthMonth": mth, "birthDay": day})

    inner = data.get("data") or {}
    inner["gender"] = "M" if gender.upper().startswith("M") else "F"
    inner["prefLanguage1"] = member["language"]
    if isinstance(inner.get("address"), dict):
        inner["address"].update(ADDRESS)
    data["data"] = inner

    # The template is one real member's message, and their identity survives in four more places
    # than the obvious ones: `identities`, `userInfo`, `userInfo.identities` and the address. Left
    # alone, the published message would carry their UID, name, email and home address alongside
    # ours -- a profile blended from two people, and quite possibly matched onto theirs. Every one
    # of those is rewritten here, and `test_profile_seed` asserts nothing of the template's member
    # survives a render.
    ident = {"providerUID": member["uid"], "firstName": member["first"], "lastName": member["last"],
             "email": member["email"], "username": member["ff"], "nickname": member["ff"]}
    for row in data.get("identities") or []:
        if isinstance(row, dict):
            row.update({k: v for k, v in ident.items() if k in row})
    ui = data.get("userInfo")
    if isinstance(ui, dict):
        ui.update({k: v for k, v in {**ident, "UID": member["uid"],
                                     "loginProviderUID": member["uid"]}.items() if k in ui})
        for row in ui.get("identities") or []:
            if isinstance(row, dict):
                row.update({k: v for k, v in ident.items() if k in row})
    return d


def _ifly(kind: str, member: dict, data: dict, now: datetime) -> dict:
    d = _template(kind)
    eid = str(uuid.uuid4())
    iso = now.strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"
    d["event"].update({"eventId": eid, "timestamp": iso})
    d["event"]["saga"]["sagaId"] = str(uuid.uuid4())
    msg = d["message"][0]
    msg.update({"id": eid, "timestamp": int(now.timestamp())})
    msg["data"].update({"membershipNumber": member["ff"], **data})
    return d


def render_ifly_account_status(member: dict, *, status: str = "A",
                               now: datetime | None = None) -> dict:
    """Account status. `A` is what iFly really publishes -- see the note in the seeding doc about
    the consumer comparing it against the literal `active`."""
    now = now or datetime.now(timezone.utc)
    return _ifly("ifly_accountstatuschanges", member,
                 {"activityDate": _ifly_date(now), "status": status}, now)


def render_ifly_tier(member: dict, *, tier: str = "E50K", old_tier: str = "E25K",
                     now: datetime | None = None) -> dict:
    """Aeroplan tier. The card decides the tier; the feed carries the member's name with it."""
    now = now or datetime.now(timezone.utc)
    stamp = _ifly_date(now)
    return _ifly("ifly_tierstatusupdates", member,
                 {"processedDate": stamp, "version": stamp,
                  "memberFirstName": member["first"], "memberLastName": member["last"],
                  "oldTier": old_tier, "newTier": tier,
                  "tierStartDate": f"{now.day:02d}-{_MON[now.month - 1]}-{now.year}",
                  "tierEndDate": f"31-DEC-{now.year + 1}"}, now)


def plan(member: dict, *, status: str = "A", tier: str = "E50K") -> dict:
    """What would be published, without touching Kafka (used by the report and the tests)."""
    return {"aeroplan_number": member["ff"], "gigya_uid": member["uid"],
            "name": f"{member['first']} {member['last']}",
            "account_status": status, "tier": tier,
            "messages": ["gigya_custprofile", "ifly_accountstatuschanges", "ifly_tierstatusupdates"]}


def wanted(scenario: dict) -> dict | None:
    """The loyalty state a case asks for, or None when it is not a loyalty case.

    A case asks by carrying a `loyalty` block, or simply by giving a passenger a `loyalty_number`
    in the fixture. The number in the fixture is only a marker that the case needs a member -- the
    seeder mints a fresh one per run, so two runs of the same case never share a profile.
    """
    block = dict(scenario.get("loyalty") or {})
    if not block and not any(p.get("loyalty_number") for p in scenario.get("passengers") or []):
        return None
    # A case names a wallet state; account_status/frozen_stage follow from it. An older fixture
    # that set account_status directly still works.
    state = block.get("wallet_state") or "open"
    block.setdefault("wallet_state", state)
    mapped = WALLET_STATES.get(state, WALLET_STATES["open"])
    block.setdefault("account_status", mapped["account_status"])
    block.setdefault("frozen_stage", mapped["frozen_stage"])
    block.setdefault("tier", "E50K")
    return block


def seed_member(env, scenario: dict, *, log=print) -> dict:
    """Mint a member and publish the feeds that build its profile. Returns the member.

    Published before the PNR on purpose: the booking has to find a profile to attach to, and the
    Gigya profile appears within seconds. The account status and tier come from the case, so a card
    that needs a frozen account gets one rather than borrowing whatever a real member happens to be.
    """
    import json as _json
    from datetime import datetime, timezone
    from .publish import producer

    spec = wanted(scenario) or {}
    px = (scenario.get("passengers") or [{}])[0]
    base = px.get("email") or env.contact_email or "lahiru@ae-qa1-aircanada.mailinator.com"
    member = mint_member(first=(px.get("first_name") or "Test").title(),
                         last=(px.get("last_name") or "Member").title(),
                         email=base, phone=px.get("phone") or "+123456789")
    now = datetime.now(timezone.utc)
    topics = topics_for(env)
    sends = [(topics["gigya_custprofile"],
              render_gigya(member, birth=px.get("date_of_birth") or "1972-02-03",
                           gender=(px.get("gender") or "MALE").upper(), now=now)),
             (topics["ifly_accountstatuschanges"],
              render_ifly_account_status(member, status=spec["account_status"], now=now))]
    if spec["account_status"] == "A" and not is_basic(spec.get("tier")):
        sends.append((topics["ifly_tierstatusupdates"],
                      render_ifly_tier(member, tier=spec["tier"], now=now)))
    p = producer(env)
    for topic, payload in sends:
        md = p.send(topic, value=_json.dumps(payload).encode("utf-8"),
                    key=member["ff"].encode()).get(timeout=60)
        log(f"  -> {md.topic} p{md.partition} @{md.offset}")
    p.flush()
    log(f"[profile] member {member['ff']} {member['first']} {member['last']} "
        f"status={spec['account_status']}"
        + (f" tier={spec['tier']}" if spec["account_status"] == "A" else "")
        + f" email={member['email']}")
    return {**member, **spec, "aeroplan_number": member["ff"]}


#: ACCP reads and writes need `profile:*`, which the seed role (Arc75-temp) does not hold -- only
#: CCE-Developer does. Every env in `ENVS` already names such a profile, so this is now only an
#: override for an env object that carries none (the bare stand-in `_wallet_profile` builds when it
#: is called without one). Setting it does NOT redirect another env's ACCP traffic: `_accp` reads
#: `env.profile` first, because a domain and the credentials used to reach it have to be the same
#: account.
ACCP_PROFILE_ENV = "AQA_ACCP_PROFILE"
ACCP_DOMAIN_ENV = "AQA_ACCP_DOMAIN"


def _accp(env):
    """The ACCP client for THIS env's account.

    The env comes first and the variable is the fallback, not the other way round. `_accp_domain`
    has always derived the domain from the env while this took its credentials from
    `AQA_ACCP_PROFILE`, and nothing made the two agree: a server started with
    `AQA_ACCP_PROFILE=int-cce` asked INT for `ac-cct-bat`, got `ResourceNotFoundException`, and
    every caller below read that as "this domain does not define that key" and moved on. Both AC
    Wallet cases on fd-uat-bat-v4 came out of that -- a member never attached, reported as
    "0 profile(s)", which is true about the wrong account. On INT `env.profile` is `int-cce`
    already, so the variable was never carrying anything the env did not know.
    """
    import os
    import boto3
    name = getattr(env, "profile", None) or os.environ.get(ACCP_PROFILE_ENV)
    session = boto3.Session(profile_name=name, region_name=env.region) if name \
        else boto3.Session(region_name=env.region)
    return session.client("customer-profiles")


def _accp_domain(env) -> str:
    import os
    return os.environ.get(ACCP_DOMAIN_ENV) or f"ac-cct-{env.id}"


def accp_assert_domain(cp, domain: str) -> None:
    """Fail loudly when the domain itself is absent, before any key lookup can mask it.

    ACCP answers a missing domain and an undefined key with the SAME exception, and the key case is
    legitimately common (BAT indexes AeroplanId/CPID/GigyaUID, INT indexes `_account`), so every
    lookup below has to swallow it. That swallow is what let a wrong-account client look like a
    domain with unusual keys. One `get_domain` up front separates the two for good.
    """
    try:
        cp.get_domain(DomainName=domain)
    except cp.exceptions.ResourceNotFoundException as exc:
        raise RuntimeError(
            f"ACCP domain {domain} is not visible to this client -- {exc}. The client is built from "
            f"the env's own profile; check that profile points at the account that owns {domain}."
        ) from exc


def attach_member(env, r, spec: dict, *, log=print, attempts: int = 6) -> dict | None:
    """Finish the customer profile the PNR just created, instead of building a rival one.

    Publishing Gigya first looked right and is not: the booking does not attach to that profile, it
    asks Entity Resolution who the traveller is, and ER is never given the loyalty id -- so it
    answers "new person" and a second, empty profile appears. The empty one then wins the wallet
    lookup, because `PNRId`/`CPID` terms are tried before `_account`.

    Seeding the booking first and enriching *its* profile leaves exactly one record, which is the
    shape a member who has never been booked already has. `AccountStatus` is the one field a
    PutProfileObject does not populate, so it still goes through the iFly feed -- keyed on the
    Aeroplan number, which by then is on the profile, so it lands there rather than making another.
    """
    import json as _json
    import time
    from datetime import datetime, timezone
    from .publish import producer

    ff, domain = spec["aeroplan_number"], _accp_domain(env)
    try:
        cp = _accp(env)
        accp_assert_domain(cp, domain)
    except Exception as exc:  # noqa: BLE001
        log(f"[profile] ACCP client unavailable ({exc}); member {ff} left unattached")
        return None

    found = None
    for _ in range(attempts):                      # the consumer creates it seconds after publish
        try:
            items = cp.search_profiles(DomainName=domain, KeyName="PNRId",
                                       Values=[r.pnr_id], MaxResults=5).get("Items") or []
        except Exception as exc:  # noqa: BLE001
            log(f"[profile] ACCP search failed ({exc}); member {ff} left unattached")
            return None
        if items:
            found = items[0]
            break
        time.sleep(5)
    if not found:
        log(f"[profile] no profile for {r.pnr_id} yet; member {ff} left unattached")
        return None

    cpid = (found.get("Attributes") or {}).get("CPID")
    pid = found.get("ProfileId")
    first, last = found.get("FirstName") or "", found.get("LastName") or ""
    # The address matters: `countryPresent` is one of the five wallet checks, and a booking-created
    # profile has no Address at all -- the PNRBooking object carries no country either, so the
    # check's last fallback misses too. Gigya maps Country -> _profile.Address.Country.
    objects = [("Gigya", {"CPID": cpid, "AeroplanId": ff, "GigyaUID": spec.get("gigya_uid") or "",
                          "FirstName": first, "LastName": last,
                          "AddressLine1": ADDRESS["addressLine1"],
                          "AddressLine2": ADDRESS["addressLine2"],
                          "City": ADDRESS["city"], "Province": ADDRESS["state"],
                          "PostalCode": ADDRESS["zip"], "Country": ADDRESS["country"]}),
               ("iFly", {"CPID": cpid, "AeroplanId": ff,
                         **({} if is_basic(spec.get("tier")) else {
                             "AeroplanTier": spec.get("tier") or "E50K",
                             "TierStatusUpdateTimestamp":
                                 datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.000Z")})})]
    for kind, obj in objects:
        cp.put_profile_object(DomainName=domain, ObjectTypeName=kind, Object=_json.dumps(obj))

    member = {"ff": ff, "first": first, "last": last, "uid": spec.get("gigya_uid") or ""}
    topics = topics_for(env)
    p = producer(env)
    p.send(topics["ifly_accountstatuschanges"],
           value=_json.dumps(render_ifly_account_status(
               member, status=spec.get("account_status", "A"))).encode("utf-8"),
           key=ff.encode()).get(timeout=60)
    if spec.get("frozen_stage"):
        p.send(topics["ifly_frozenstagechanges"],
               value=_json.dumps(render_ifly_frozen_stage(
                   member, stage=spec["frozen_stage"])).encode("utf-8"),
               key=ff.encode()).get(timeout=60)
    p.flush()
    log(f"[profile] member {ff} attached to profile {pid} "
        f"(status {spec.get('account_status', 'A')}, tier {spec.get('tier') or 'E50K'})")
    return {"profile_id": pid, "cpid": cpid, "aeroplan_number": ff}
