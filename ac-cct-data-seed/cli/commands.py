"""The commands. Each one builds adapters, calls a use case, prints the result.

No command decides anything. `seed` does not know what agreement means, `judge` does not know what a
section is, and `sets` does not know which sets exist -- they ask the flow policy, the use case and
the spec source. When a command starts wanting an `if` about a flow, that `if` belongs in the flow's
policy.
"""
from __future__ import annotations

import argparse
import datetime as _dt
import json
import os as _os
import pathlib
import re as _re
from typing import Sequence

from adapters.file_run_store import FileRunStore
from adapters.file_spec_source import FileSpecSource
from adapters.jira_docs import FileTestDocs
from adapters.kafka_publisher import Identity, KafkaPublisher
from adapters.accp_loyalty import AccpLoyaltyDirectory
from adapters.kit_builder import KitBuilder
from adapters.pool_file import PoolFileSink
from application.seed_pack import SeedPack
from core import paths
from flows import registry

ENVIRONMENTS = ("int", "crt", "bat")


# ------------------------------------------------------------------- reading

def cmd_sets(args) -> int:
    """What the spec tree holds."""
    src = FileSpecSource()
    rows = src.describe()
    width = max((len(s.name) for s in rows), default=10)
    for s in rows:
        policy = registry.for_set(s.name)
        # an empty set says so first: the flow being ready says nothing about whether anyone has
        # written the scenarios, and reporting "ready" for a folder with no specs reads as done
        state = ("empty: no specs written" if not s.count else
                 "runnable" if not policy.needs else
                 f"{policy.flow_id} cannot claim a verdict: {policy.needs[0][:44]}...")
        print(f"  {s.name:<{width}}  {s.count:>4} specs   {state}")
    print(f"\n{len(rows)} set(s), {sum(s.count for s in rows)} spec(s) in {src.root}")
    if args.verify:
        index = src.index()                      # raises on a duplicate id
        print(f"no duplicate ids across the tree ({len(index)} case ids)")
    return 0


def cmd_flows(args) -> int:
    """The flows, which sections each reads, and whether it can claim a verdict."""
    for p in registry.POLICIES:
        sections = ", ".join((p.section, *getattr(p, "also", ())))
        print(f"  {p.flow_id:8} {getattr(p, 'label', p.flow_id):22} {sections}")
        print(f"           lanes: {', '.join(p.lanes) or '(booking only)'}")
        if p.needs:
            for n in p.needs:
                print(f"           needs: {n}")
        else:
            print("           ready: claims a verdict")
    owners = registry.sections()
    missing = [s for s, o in owners.items() if o is None]
    print(f"\nall six sections owned: {not missing}" + (f"; unowned: {missing}" if missing else ""))
    return 0


def cmd_show(args) -> int:
    """One case: what the spec says, and whether this flow could run it."""
    src = FileSpecSource()
    scenario = src.scenario(args.case_id)
    where = src.index().get(args.case_id, "?")
    want = scenario.expectation
    print(f"{scenario.case_id}   set: {where}   family: {scenario.family}")
    if scenario.summary:
        print(f"  {scenario.summary[:300]}")
    print(f"  passengers: {len(scenario.passengers)}  segments: {len(scenario.segments)}  "
          f"outcomes: {len(scenario.outcomes)}")
    print(f"  expects: {want.eligibility} {want.system_code} {want.money} "
          f"regime={want.regime} delay={want.delay}")
    missing = registry.for_set(where).validate(scenario) if where != "?" else ("unknown set",)
    print(f"  runnable: {not missing}" + (f"  ({'; '.join(missing)})" if missing else ""))
    doc = FileTestDocs().doc(args.case_id)
    if not doc:
        print("  jira: no test found for this case id")
        return 0
    print(f"  jira: {doc.key}  {doc.status}  {doc.url}")
    if args.jira:
        print(f"\n  {doc.title}\n\n  goal")
        for line in (doc.goal or doc.description).splitlines():
            print(f"    {line}")
        if doc.prerequisite_items:
            print("\n  prerequisites")
            for item in doc.prerequisite_items:
                print(f"    - {item}")
        if doc.damaged_characters:
            print(f"\n  ({doc.damaged_characters} character(s) arrived damaged from Jira)")
    return 0


def _case_receipts(receipts_dir: pathlib.Path, suite: pathlib.Path, case_id: str) -> list[dict] | None:
    """`<receipts_dir>/<CASE>/manifest.json` (tools/soc_receipts.py or tools/baggage_receipts.py),
    each entry's `file` made the path the suite resolves: relative to playwright-baggage when
    inside it, absolute otherwise."""
    manifest = receipts_dir / case_id / "manifest.json"
    if not manifest.exists():
        return None
    entries = []
    for r in json.loads(manifest.read_text(encoding="utf-8")).get("receipts") or []:
        path = (receipts_dir / case_id / r["file"]).resolve()
        try:
            rel = path.relative_to(suite.resolve()).as_posix()
        except ValueError:
            rel = path.as_posix()
        entries.append({**r, "file": rel})
    return entries


#: the suite's receipts folder per flow (the set's first path segment); anything else reads soc's
RECEIPTS_BY_FLOW = {"soc": "soc", "baggage": "baggage"}


def default_receipts_dir(suite: pathlib.Path, set_name: str) -> pathlib.Path:
    """`receipts/baggage` for a baggage set (tools/baggage_receipts.py), `receipts/soc` otherwise."""
    flow = set_name.strip("/").split("/")[0].lower()
    return suite / "receipts" / RECEIPTS_BY_FLOW.get(flow, "soc")


def cmd_goal_plan(args) -> int:
    """A goal-mode plan for the automation: each Jira test of a set, played on its pool booking.

    Joins `jira/<set>/<CASE>__<KEY>/` (checkpoints.json + test.feature) to the seeded pool by case
    id and writes the JSON the suite's `GOAL_PLAN` reads. Writes nothing else and sends nothing.
    """
    import yaml
    from domain import goal_plan

    pools_dir = paths.AUTOMATION / "playwright-baggage" / "data" / "pools"
    pool_path = pathlib.Path(args.pool)
    if not pool_path.exists():
        pool_path = pools_dir / f"{args.pool}.yaml"
    if not pool_path.exists():
        print(f"no pool {args.pool!r} (looked for {pool_path})")
        return 1
    pools = (yaml.safe_load(pool_path.read_text(encoding="utf-8")) or {}).get("pools") or {}
    by_case: dict[str, goal_plan.Booking] = {}
    for pool_name, pool in pools.items():
        for row in pool.get("bookings") or []:
            case = str(row.get("caseId") or "")
            if case and row.get("pnr"):
                by_case[case.upper()] = goal_plan.Booking(
                    pnr=str(row["pnr"]), first=str(row.get("first") or pool.get("first") or ""),
                    last=str(row.get("last") or pool.get("last") or ""), case_id=case,
                    pool=pool_name)
    base = paths.JIRA / args.set.strip("/")
    if not base.is_dir():
        print(f"no Jira snapshot for {args.set} ({base})")
        return 1
    only = {c.strip().upper() for c in args.only.split(",") if c.strip()}
    # passengers per case, from the specs: a 1-passenger booking never gets the "how many people" question
    try:
        pax = {s.case_id.split("#")[0].upper(): len(s.passengers)
               for s in FileSpecSource().scenarios(args.set.strip("/"))}
    except KeyError:
        pax = {}
    suite = paths.AUTOMATION / "playwright-baggage"
    receipts_dir = (pathlib.Path(args.receipts_dir) if args.receipts_dir
                    else default_receipts_dir(suite, args.set))
    items, missing, unmapped, notes, with_receipts = [], [], 0, [], 0
    for folder in sorted(d for d in base.iterdir() if (d / "checkpoints.json").exists()):
        case_id = folder.name.split("__")[0].upper()
        if only and case_id not in only and folder.name.upper() not in only:
            continue
        booking = by_case.get(folder.name.upper()) or by_case.get(case_id)
        if booking is None:
            missing.append(folder.name)
            continue
        feature = folder / "test.feature"
        receipts = _case_receipts(receipts_dir, suite, case_id)
        plan = goal_plan.build(json.loads((folder / "checkpoints.json").read_text(encoding="utf-8")),
                               feature.read_text(encoding="utf-8") if feature.exists() else "",
                               booking, allow_payment=False if args.no_payment else None,
                               passengers=pax.get(case_id), receipts=receipts)
        with_receipts += bool(receipts)
        items.append(plan.item)
        unmapped += len(plan.unmapped_dashboard)
        notes += [f"{folder.name}: {n}" for n in plan.notes]
    if not items:
        print(f"no test of {args.set} has a booking in {pool_path.name}")
        return 1
    out = pathlib.Path(args.out) if args.out else (
        paths.AUTOMATION / "playwright-baggage" / "data" / "plans"
        / f"{args.set.replace('/', '-')}--{pool_path.stem}.json")
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(items, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
    steps = sum(len(i["script"]) for i in items)
    judged = sum(len(i["checkpoints"]) for i in items)
    dash = sum(len(i.get("dashboard") or ()) for i in items)
    print(f"{len(items)} chat(s) -> {out}")
    print(f"  {steps} customer step(s), {judged} chat checkpoint(s) for the judge, "
          f"{dash} dashboard check(s) ({unmapped} not yet mapped to an API item)")
    print(f"  {with_receipts} chat(s) carry their own receipts from {receipts_dir}")
    if missing:
        print(f"  {len(missing)} test(s) have no booking in the pool, e.g. {', '.join(missing[:4])}")
    for n in notes[:10]:
        print(f"  note: {n}")
    print(f"  run:  GOAL_PLAN={out} npx playwright test --project=goal")
    return 0


def cmd_jira(args) -> int:
    """Whether every spec has a Jira test and every Jira test has a spec.

    Both directions are findings: a spec with no test is a case being seeded that nothing
    authoritative defines, and a test with no spec is a defined case nobody can run.
    """
    docs, src = FileTestDocs(), FileSpecSource()
    if args.find:
        found = docs.search(args.find, args.set or None)
        print(f"{len(found)} test(s) mention {args.find!r}")
        for d in found[:40]:
            print(f"  {d.case_id:12} {d.key:12} {d.title[:84]}")
        if len(found) > 40:
            print(f"  ... and {len(found) - 40} more")
        return 0
    if args.audit:
        return _audit_loyalty(docs, src, args.set or None)
    names = [args.set] if args.set else list(docs.sets())
    ok = True
    for name in names:
        try:
            spec_ids = tuple(s.case_id.split("#")[0] for s in src.scenarios(name))
        except KeyError:
            spec_ids = ()
        cover = docs.coverage(name, spec_ids)
        for line in cover.describe():
            print(line)
        ok = ok and cover.aligned
    return 0 if ok else 2


def _audit_loyalty(docs, src, only: str | None) -> int:
    """Where a Jira test states a wallet state or tier that the spec does not express.

    Nothing is changed. The hints are read from prose, and prose is evidence for a person: deriving
    seed data from it automatically is the same mistake as reading a delay band out of a system
    code. `FD_ED_TC_13` is why this exists -- its test says `Aeroplan account status: FROZEN` and
    its spec carries no loyalty block, so it seeds an open wallet and the fallback-to-cash it exists
    to prove never fires.
    """
    rows = []
    for name in ([only] if only else docs.sets()):
        try:
            by_id = {s.case_id.split("#")[0]: s for s in src.scenarios(name)}
        except KeyError:
            continue
        for doc in docs.docs(name):
            hint = doc.loyalty_hints()
            scenario = by_id.get(doc.case_id)
            if scenario is None or not hint.says_anything:
                continue
            want = scenario.loyalty
            notes = []
            if hint.frozen is True and (want is None or want.wallet_state == "open"):
                notes.append("jira says the account is FROZEN; the spec seeds an open wallet")
            if hint.tier and want is not None and want.tier.upper() != hint.tier:
                notes.append(f"jira names tier {hint.tier}; the spec seeds {want.tier}")
            if hint.tier and want is None:
                notes.append(f"jira names tier {hint.tier}; the spec is not a loyalty case")
            if hint.unmapped_tier:
                notes.append(f"jira's tier is not a single Aeroplan tier ({hint.unmapped_tier})")
            if hint.mentions_wallet and want is None:
                notes.append("jira talks about AC Wallet; the spec asks for no member")
            if notes:
                rows.append((doc.case_id, doc.key, notes))
    print(f"{len(rows)} case(s) where the Jira test says more about loyalty than the spec does\n")
    for case, key, notes in rows[:60]:
        print(f"  {case:12} {key:12} {notes[0]}")
        for extra in notes[1:]:
            print(f"  {'':12} {'':12} {extra}")
    if len(rows) > 60:
        print(f"  ... and {len(rows) - 60} more")
    print("\nNothing was changed: a loyalty block is seed input, and only the test owner should "
          "decide what it says.")
    return 0


def cmd_gate(args) -> int:
    """Read and judge bookings that are already published, without republishing anything.

    Needed because publishing and reading can fail independently: a BAT run published 2,757
    messages and then lost its gate read to a container-name mismatch. Republishing to recover the
    verdicts would have been 124 bookings of duplicate traffic for nothing.
    """
    from adapters.kit_builder import KitBuilder

    batch = KitBuilder.load(pathlib.Path(args.batch))
    src = FileSpecSource()
    policy = registry.get(args.flow)
    scenarios = []
    for b in batch.bookings:
        try:
            scenarios.append(src.scenario(b.case_id))
        except KeyError:
            pass
    pack = SeedPack(builder=KitBuilder(), publisher=KafkaPublisher(args.env),
                    reader=_reader(args.env),
                    store=FileRunStore(env=args.env, label=args.label),
                    policy=policy, env=args.env)
    pack.read_batch = args.read_batch
    # judge the spec the batch was BUILT from. `apply_patches.py` rewrites outcomes as well as
    # expectations -- FD_TC_009 publishes a 120-minute remainder over a 120-minute involuntary
    # schedule change where its source spec says 240 -- so a gate reading the source spec compares
    # the Trip's correct 120 against 240 and reports the engine as holding another booking's leg.
    # Two revalidation passes disagreed with the seeding run on exactly those four cases.
    scenarios = list(pack._as_built(batch, tuple(scenarios)))
    print(f"[gate] {len(batch.bookings)} booking(s) from {args.batch}")
    results = pack.judge(batch.bookings, scenarios=tuple(scenarios))
    for r in results:
        pack.store.save_case(r)
    where = pack.store.save_summary(args.label, results)
    agree = sum(1 for r in results if r.agrees)
    judged = sum(1 for r in results if r.judged)
    print(f"  {agree} agree, {judged - agree} disagree, {len(results) - judged} not judged")
    engines = {(r.assessment.engine, r.assessment.release, r.assessment.rules_sha256)
               for r in results if r.assessment.engine}
    for e, rel, sha in sorted(engines):
        print(f"  engine {e} release {rel} rules {str(sha)[:16]}")
    print(f"  summary: {where}")
    return 2 if judged - agree else 0


def cmd_doctor(args) -> int:
    """Whether the outside world this project needs is actually there."""
    ok = True
    # the kit is listed last and never fails the check: nothing at run time reads it, and its
    # scripts, seed pool, specs and reports are all vendored into this project now
    for what, required in (("agentic-qa", True), ("qa-builder", True),
                           ("cascade", False), ("kit", False)):
        try:
            print(f"  {what:12} {paths.require(what)}"
                  + ("" if required else "   (optional: nothing reads it)"))
        except SystemExit as ex:
            if required:
                ok = False
                print(f"  {what:12} MISSING: {str(ex).splitlines()[0]}")
            else:
                print(f"  {what:12} absent, which is fine: nothing reads it")
    print(f"  {'spec tree':12} {paths.SPEC}  ({len(FileSpecSource().describe())} sets)")
    print(f"  {'builder':12} {paths.BUILDER}")
    print(f"  {'runs':12} {paths.RUNS}")
    accepted, note = KafkaPublisher(args.env).validate(None)
    print(f"  {'validator':12} {'available' if accepted else note}")
    wallet_ok, wallet_note = AccpLoyaltyDirectory(args.env).check()
    print(f"  {'ac wallet':12} {'ready' if wallet_ok else wallet_note}")
    docs = FileTestDocs()
    synced = [d.synced_at for s in docs.sets() for d in docs.docs(s)[:1] if d.synced_at]
    print(f"  {'jira docs':12} {paths.JIRA}  ({len(docs.sets())} set(s)"
          + (f", synced {min(synced)[:10]}" if synced else "") + ")")
    return 0 if ok else 1


# ------------------------------------------------------------------- running

def _pack(args):
    src = FileSpecSource()
    spec_set = src.set_named(args.set)
    scenarios = src.scenarios(spec_set.name)
    if args.only:
        wanted = {c.strip() for c in args.only.split(",") if c.strip()}
        # match the base id too: a spec holding several bookings parses as `ID#1`, `ID#2`, and an
        # exact match on `ID` selected neither -- which is how FD_TC_209 went missing from BAT
        picked = tuple(s for s in scenarios
                       if s.case_id in wanted or s.case_id.split("#")[0] in wanted)
        unmatched = wanted - {s.case_id for s in picked} - {
            s.case_id.split("#")[0] for s in picked}
        if unmatched:
            print(f"[select] no scenario for: {', '.join(sorted(unmatched))}")
        scenarios = picked
    if getattr(args, "part", ""):
        n, _, m = args.part.partition("/")
        n, m = int(n), int(m or 1)
        if not 1 <= n <= m:
            raise SystemExit(f"--part {args.part}: n must be between 1 and m")
        # contiguous blocks that cover the set exactly: no gaps, no overlap, whatever m is
        size, rem = divmod(len(scenarios), m)
        start = (n - 1) * size + min(n - 1, rem)
        end = start + size + (1 if n <= rem else 0)
        scenarios = scenarios[start:end]
        print(f"[select] part {n} of {m}: {len(scenarios)} scenario(s) "
              f"({scenarios[0].case_id}..{scenarios[-1].case_id})" if scenarios else "")
    if args.limit:
        scenarios = scenarios[:args.limit]
    already = _already_seeded(args.env)
    repeats = [s for s in scenarios if s.case_id.split("#")[0] in already]
    if repeats:
        if getattr(args, "skip_seeded", False):
            scenarios = tuple(s for s in scenarios
                              if s.case_id.split("#")[0] not in already)
            print(f"[select] skipping {len(repeats)} case(s) already seeded in {args.env}")
        else:
            # said, not blocked: a second booking for a case is legitimate, but it is also how 63
            # loyalty cases ended up with two bookings each on BAT, the wrong one of which a wallet
            # checkpoint would find
            print(f"[select] {len(repeats)} of these already have a booking in {args.env} "
                  f"(e.g. {', '.join(sorted(c.case_id for c in repeats)[:4])}); seeding again "
                  f"creates a SECOND booking. Pass --skip-seeded to seed only what is missing.")
    stamp = _dt.datetime.now(_dt.timezone.utc).strftime("%m%dT%H%M")
    label = args.label or f"{spec_set.flow}-{spec_set.phase}-{spec_set.purpose}-{stamp}"
    pack = SeedPack(
        builder=KitBuilder(),
        publisher=KafkaPublisher(args.env),
        reader=_reader(args.env),
        store=FileRunStore(env=args.env, label=label),
        policy=registry.for_set(spec_set.name),
        sink=PoolFileSink() if getattr(args, "pool", False) else None,
        loyalty=AccpLoyaltyDirectory(args.env) if getattr(args, "wallet", False) else None,
        wallet_for_all=bool(getattr(args, "wallet", False)),
        env=args.env)
    pack.read_batch = args.read_batch
    return pack, scenarios, label


def _already_seeded(env: str) -> set[str]:
    """Case ids that already have a booking in this environment, from the run records."""
    out: set[str] = set()
    base = paths.RUNS / env
    if not base.is_dir():
        return out
    for manifest in base.rglob("manifest.json"):
        try:
            rows = json.loads(manifest.read_text(encoding="utf-8"))
        except Exception:                                                   # noqa: BLE001
            continue
        for r in rows if isinstance(rows, list) else []:
            if isinstance(r, dict) and r.get("pnrId") and r.get("id"):
                out.add(str(r["id"]).split("#")[0])
    return out


def _reader(env: str):
    from adapters.ecs_assessment_reader import EcsAssessmentReader
    return EcsAssessmentReader(env_name=env if env in ("int", "bat") else "int")


def cmd_plan(args) -> int:
    """Patch and date a set, publishing nothing: the cheap check that a set is buildable."""
    pack, scenarios, label = _pack(args)
    for line in pack.run(scenarios, label=label, run_day=args.run_day or None,
                         dry_run=True, spec_set=args.set).describe():
        print(line)
    return 0


def cmd_seed(args) -> int:
    """Build, publish, settle, read and judge a set."""
    if args.go or getattr(args, "wallet", False):
        # an expired int-cce session fails a seed part-way (after minting, before publishing): check
        # first, and if it has expired open the sign-in and wait for the person to approve it
        from core import aws_guard
        if not aws_guard.ensure():
            return 1
    if getattr(args, "wallet", False):
        # ACCP is reached only through int-cce, for every environment (see accp_loyalty.check).
        # Setting it here, when nothing else has, is what lets wallets be the default; an explicit
        # value is left alone so a wrong one is still refused below rather than overridden.
        _os.environ.setdefault("AQA_ACCP_PROFILE", "int-cce")
    pack, scenarios, label = _pack(args)
    if args.go and args.batch_size:
        from core import aws_guard
        pack.before_batch = aws_guard.ensure   # renews the sign-in between batches of a long seed
    if getattr(args, "wallet", False) and pack.loyalty is not None:
        ready, why = pack.loyalty.check()
        if not ready:
            # refused here rather than mid-run: without profile:* every ACCP write is declined,
            # nothing is attached, and the run still produces bookings and verdicts
            print(f"--wallet cannot work: {why}")
            return 1
    dob = (args.dob or "").strip().replace("/", "-") or None
    if dob and not _re.fullmatch(r"\d{4}-\d{2}-\d{2}", dob):
        print(f"--dob must be YYYY-MM-DD or YYYY/MM/DD, not {args.dob!r}")
        return 1
    identity = Identity(email=args.email or None, phone=args.phone or None, dob=dob,
                        first_name=args.first_name or None,
                        last_name=(args.last_name or "").replace(" ", "") or None,
                        unique_name=args.unique_name,
                        inbox_tag=(_dt.datetime.now(_dt.timezone.utc).strftime("%m%dT%H%M")
                                   if getattr(args, "inbox_per_case", False) else None))
    if identity.first_name and pack.loyalty is not None and hasattr(pack.loyalty, "first_name"):
        pack.loyalty.first_name = identity.first_name.title()
    if identity.inbox_tag and pack.loyalty is not None and hasattr(pack.loyalty, "contact_for"):
        # the wallet profile carries the booking's own inbox and phone, not the shared default
        from adapters.kafka_publisher import case_inbox, case_phone
        tag = identity.inbox_tag
        pack.loyalty.contact_for = lambda case: (identity.email or case_inbox(case, tag),
                                                 identity.phone or case_phone(case, tag))
    out = pack.run(scenarios, label=label, run_day=args.run_day or None,
                   dry_run=not args.go, settle_seconds=args.settle, spec_set=args.set,
                   identity=identity, batch_size=args.batch_size)
    for line in out.describe():
        print(line)
    if out.summary_path:
        print(f"  summary: {out.summary_path}")
    return 2 if out.disagree else 0


def cmd_judge(args) -> int:
    """Re-judge a stored run from the engine's documents, without reading the engine again.

    A judgement ages and a document does not: four comparator fixes landed after one set of
    readings, and a report rebuilt from the stored verdict reproduced the pre-fix numbers exactly.
    """
    from dataclasses import replace as dreplace

    from domain.models import Assessment, Expectation

    store = FileRunStore(env=args.env, label=args.run)
    documents = store.documents()
    if not documents:
        print(f"no stored documents in {store.root}")
        return 1
    src, policy = FileSpecSource(), registry.get(args.flow)
    agree = disagree = unjudged = 0
    findings: dict[str, int] = {}
    rewritten: list[tuple[str, dict, tuple]] = []
    for pnr_id, row in sorted(documents.items()):
        assessment = Assessment.parse(pnr_id, {"document": row.get("document"),
                                               **(row.get("engine") or {})})
        try:
            scenario = src.scenario(row["case"]) if row.get("case") else None
        except KeyError:
            scenario = None
        if scenario is None or not assessment.has_answer:
            unjudged += 1
            continue
        # the stored record keeps the expectation the booking was BUILT with (from the manifest,
        # i.e. the patched spec). Prefer it over the source spec on disk, which may describe a
        # different case after fixes-*.json was applied.
        built = Expectation.parse(row.get('expected'))
        if built.states_a_verdict and built != scenario.expectation:
            scenario = dreplace(scenario, expectation=built)
        # the Trip assertions belong to a judgement, not to the reading: the record keeps what the
        # Trip held in `seen`, so they can be reproduced here rather than lost. Without this a
        # re-judge silently drops the one check that distinguishes "the engine answered about
        # another booking's leg" from "the engine answered our question and we disagree".
        seen = row.get("seen") or {}
        segments = seen.get("segments") or []
        delays = [d for d in (seen.get("delays") or []) if d]
        trip_checks = SeedPack._trip_checks(
            scenario, {"segments": segments}, segments, delays,
            rebooked=SeedPack._rebooked(row.get("document")),
            published=tuple(row.get("published") or ()))
        checks = (*trip_checks, *policy.judge(scenario, policy.rows(assessment)))
        if getattr(args, "write", False):
            # the document is the evidence and the checks are derived from it, so a re-judge may
            # replace them -- otherwise the pages keep reporting the verdict of whichever
            # comparator happened to run on the night of the seeding
            rewritten.append((pnr_id, row, checks))
        bad = [c for c in checks if c.disagrees]
        # the same rule as `CaseResult.judged`: a case whose only applicable check is structural
        # (the section exists, the row count fits) has had nothing about its verdict verified, and
        # must not be counted as agreeing
        if not any(c.applies and not c.structural for c in checks):
            unjudged += 1
            continue
        if bad:
            disagree += 1
            for c in bad:
                findings[c.name] = findings.get(c.name, 0) + 1
        else:
            agree += 1
    print(f"{args.run}: {agree} agree, {disagree} disagree, {unjudged} not judged "
          f"({len(documents)} documents)")
    for name, count in sorted(findings.items(), key=lambda kv: -kv[1]):
        print(f"  {name:22} {count}")
    if rewritten:
        store.rejudge(rewritten)
        print(f"  rewrote the checks on {len(rewritten)} record(s) in {store.root}")
    return 0


# ------------------------------------------------------------------ dispatch

def build_parser() -> argparse.ArgumentParser:
    ap = argparse.ArgumentParser(prog="python -m cli", description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="command", required=True)

    p = sub.add_parser("sets", help="what the spec tree holds")
    p.add_argument("--verify", action="store_true", help="also check for duplicate case ids")
    p.set_defaults(fn=cmd_sets)

    p = sub.add_parser("flows", help="the flows, and which can claim a verdict")
    p.set_defaults(fn=cmd_flows)

    p = sub.add_parser("doctor", help="are the external paths and the validator there")
    p.add_argument("--env", default="int", choices=ENVIRONMENTS)
    p.set_defaults(fn=cmd_doctor)

    p = sub.add_parser("show", help="one case: its spec and whether it is runnable")
    p.add_argument("case_id")
    p.add_argument("--jira", action="store_true",
                   help="also print what the Jira test says: goal and prerequisites")
    p.set_defaults(fn=cmd_show)

    p = sub.add_parser("jira", help="the Jira tests: coverage against the specs, or a search")
    p.add_argument("--set", default="", help="one set, e.g. fd/uat/automation")
    p.add_argument("--find", default="", help="only tests whose own words mention this")
    p.add_argument("--audit", action="store_true",
                   help="where a test states a wallet state or tier the spec does not express")
    p.set_defaults(fn=cmd_jira)

    p = sub.add_parser("goal-plan",
                       help="a goal-mode chat plan: each Jira test of a set on its pool booking")
    p.add_argument("set", help="a set with a Jira snapshot, e.g. soc/uat/automation")
    p.add_argument("--pool", required=True,
                   help="a pool name in the suite's data/pools (without .yaml), or a path")
    p.add_argument("--only", default="", help="comma-separated case ids")
    p.add_argument("--out", default="", help="where to write the plan; defaults to the suite's "
                                             "data/plans/<set>--<pool>.json")
    p.add_argument("--no-payment", action="store_true",
                   help="never let a chat proceed with payment, even where the test pays out")
    p.add_argument("--receipts-dir", default="",
                   help="per-case receipts (tools/soc_receipts.py, tools/baggage_receipts.py): "
                        "<dir>/<CASE>/manifest.json; defaults to the suite's receipts/baggage for "
                        "a baggage set and receipts/soc otherwise")
    p.set_defaults(fn=cmd_goal_plan)

    for name, fn, helptext in (("plan", cmd_plan, "patch and date a set, publish nothing"),
                               ("seed", cmd_seed, "build, publish, read and judge a set")):
        p = sub.add_parser(name, help=helptext)
        p.add_argument("set", help="a set from the spec tree, e.g. fd/uat/automation")
        p.add_argument("--env", default="int", choices=ENVIRONMENTS)
        p.add_argument("--limit", type=int, default=0, help="only the first N scenarios")
        p.add_argument("--only", default="", help="comma-separated case ids")
        p.add_argument("--part", default="",
                       help="seed one part of the set, e.g. 2/3. Contiguous and gap-free, so "
                            "parts 1..m cover the set exactly")
        p.add_argument("--skip-seeded", action="store_true",
                       help="skip cases that already have a booking in this environment instead "
                            "of creating a second one")
        p.add_argument("--label", default="", help="the run label; defaults to set + timestamp")
        p.add_argument("--run-day", default="", help="YYYY-MM-DD; defaults to today (UTC)")
        p.add_argument("--read-batch", type=int, default=100,
                       help="bookings per read task; the 8 KiB command override caps this")
        if name == "seed":
            p.add_argument("--go", action="store_true",
                           help="publish. Without it nothing is sent, which is the default "
                                "because these topics are read by other services")
            p.add_argument("--batch-size", type=int, default=0,
                           help="build, publish and judge this many cases at a time (e.g. 100). "
                                "Each batch is recorded before the next starts, so an expiring "
                                "token costs one batch instead of the whole set")
            p.add_argument("--settle", type=int, default=90,
                           help="seconds to let the ingest fold the events (66-81s on INT)")
            p.add_argument("--email", default="", help="rewrite the booking contact e-mail")
            p.add_argument("--phone", default="", help="rewrite the booking contact phone")
            p.add_argument("--first-name", default="", help="rewrite every passenger first name")
            # `Identity.last_name` was always honoured by the publisher's rename, but no flag
            # reached it: a set seeded for one person needs their own surname on the booking, not
            # the builder's anonymised one, because that name is how they find their own case.
            # Spaces are stripped -- the booking lookup normalises case but not spacing.
            p.add_argument("--last-name", default="",
                           help="rewrite every passenger last name (spaces are stripped)")
            # the seed pool's histories carry 1980-01-01 on every booking, so a set seeded for a
            # tester who identifies by date of birth needs theirs. `YYYY/MM/DD` is accepted as
            # well as ISO because that is how a date gets typed.
            p.add_argument("--dob", default="",
                           help="rewrite every passenger date of birth (YYYY-MM-DD or YYYY/MM/DD)")
            # on by default: every dataset is seeded with wallets, so a run that should not have
            # them says --no-wallet rather than every run having to remember --wallet
            p.add_argument("--wallet", action=argparse.BooleanOptionalAction, default=True,
                           help="mint and attach an AC Wallet / Aeroplan member for EVERY case "
                                "(an open E50K wallet where the spec asks for none). On by "
                                "default; --no-wallet turns it off. Uses AQA_ACCP_PROFILE=int-cce "
                                "(set here when unset) and refuses up front if ACCP is unusable. "
                                "A dry run mints nothing")
            p.add_argument("--pool", action="store_true",
                           help="hand the seeded bookings to the automation half as a pool file, "
                                "so its scenarios can pick them by state")
            p.add_argument("--inbox-per-case", action="store_true",
                           help="give every booking its own Mailinator inbox "
                                "(lahiru-<case>-<run stamp>@ae-qa1-aircanada.mailinator.com) instead of "
                                "the shared one, and write it into the pool, so automation reads "
                                "each booking's OTP and mail without queueing behind other runs. "
                                "Overrides --email")
            p.add_argument("--unique-name", action="store_true",
                           help="give each case its own surname, derived from the case id, so one "
                                "shared inbox can tell the scenarios apart")
        p.set_defaults(fn=fn)

    p = sub.add_parser("gate", help="read and judge bookings already published")
    p.add_argument("batch", help="a built batch directory (holds manifest.json)")
    p.add_argument("--label", required=True, help="the run label to store the result under")
    p.add_argument("--env", default="int", choices=ENVIRONMENTS)
    p.add_argument("--flow", default="fd")
    p.add_argument("--read-batch", type=int, default=100,
                   help="bookings per read task; the 8 KiB command override caps this")
    p.set_defaults(fn=cmd_gate)

    p = sub.add_parser("judge", help="re-judge a stored run from its documents")
    p.add_argument("run", help="a run label under runs/<env>/")
    p.add_argument("--env", default="int", choices=ENVIRONMENTS)
    p.add_argument("--flow", default="fd", help="which flow policy to judge with")
    p.add_argument("--write", action="store_true",
                   help="replace the checks stored on each record with this judgement, so the "
                        "report pages stop reporting the comparator that ran at seeding time")
    p.set_defaults(fn=cmd_judge)
    return ap


def main(argv: Sequence[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    return args.fn(args)
