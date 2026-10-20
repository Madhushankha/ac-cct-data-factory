"""Where the outside world is, in one place.

Everything this project needs that it does not own lives here, resolved from the environment with a
default. Before this, seven absolute paths were scattered across six modules -- `core/seed.py`,
`lanes/fdm.py`, `lanes/replay.py`, two tools and `run_pack.py` -- each naming one person's desktop.
That makes a project that only runs on one machine, and makes a path change a hunt.

Four external things, and why each is external rather than vendored:

* **agentic-qa** -- the proven renderer, publisher and environment definitions (topics, brokers, the
  contact defaults). Vendoring it would fork code that is already under test elsewhere.
* **cct-cascade** -- the `/qa builder` and the rule reference data. It is a large repository with a
  Rust workspace in it; this project reads two paths inside it.
* **the kit** -- OPTIONAL, and read by nothing at run time; only for refreshing the vendored
  `builder/seed-pool` when a newer kit is published. The scripts themselves
  are copied into `builder/`, so a run needs no kit checkout.
* **the baggage SIT kit** -- OPTIONAL, read once by `tools/import_baggage_po.py` to build
  `spec/baggage/sit/po/`. Once imported, nothing reads it again.

Set any of them with an environment variable when they are somewhere else:

    AQA_SEED_AGENTIC_QA   the agentic-qa checkout
    AQA_SEED_CASCADE      the cct-cascade checkout       (also honours CASCADE_DIR)
    AQA_SEED_KIT          the uat-scenarios kit folder
    AQA_SEED_BAGGAGE_KIT  the baggage SIT kit folder
    AQA_SEED_AUTOMATION   the automation sub-project (default: ../ac-cct-data-automation)

`require()` fails with the variable name and what is missing, rather than letting a module fail
later on a path that was never going to exist.
"""
from __future__ import annotations

import os
import pathlib

#: this project
ROOT = pathlib.Path(__file__).resolve().parent.parent

_DEFAULTS = {
    "AQA_SEED_AGENTIC_QA": r"C:\Users\mplah\OneDrive\Desktop\agentic-qa-latest\cct-cascade\agentic-qa",
    "AQA_SEED_CASCADE": r"C:\Users\mplah\OneDrive\Desktop\bravo-2026-08-30\cct-cascade",
    "AQA_SEED_KIT": r"C:\Users\mplah\OneDrive\Desktop\agentic-qa-latest"
                    r"\UAT_344_PNR_KIT_20261015 (1)\UAT_344_PNR_KIT\uat-scenarios",
    "AQA_SEED_BAGGAGE_KIT": r"C:\Users\mplah\OneDrive\Desktop\agentic-qa-latest"
                            r"\BAGGAGE_SIT_KIT_20261017\BAGGAGE_SIT_KIT",
}


def _resolve_optional(var: str, *alternates: str) -> pathlib.Path | None:
    """The path a variable names, or None when none of them is set."""
    for name in (var, *alternates):
        value = os.environ.get(name, "").strip()
        if value:
            return pathlib.Path(value).expanduser()
    return None


def _resolve(var: str, *alternates: str) -> pathlib.Path:
    for name in (var, *alternates):
        value = os.environ.get(name, "").strip()
        if value:
            return pathlib.Path(value).expanduser()
    return pathlib.Path(_DEFAULTS[var])


def agentic_qa() -> pathlib.Path:
    """Where `aqa.workflows.seed` is imported from.

    Defaults to the copy in `vendor/agentic-qa` so a seed needs no other checkout. Setting
    `AQA_SEED_AGENTIC_QA` points at a real checkout instead, which is how the vendored copy gets
    refreshed and how a change is tested against the original before being copied in.
    """
    fromenv = _resolve_optional("AQA_SEED_AGENTIC_QA")
    if fromenv is not None:
        return fromenv
    vendored = VENDOR / "agentic-qa"
    return vendored if (vendored / "aqa" / "workflows" / "seed" / "env.py").exists() \
        else pathlib.Path(_DEFAULTS["AQA_SEED_AGENTIC_QA"])


def cascade() -> pathlib.Path:
    """The cct-cascade checkout, which holds the /qa builder and the rule reference data."""
    return _resolve("AQA_SEED_CASCADE", "CASCADE_DIR")


def qa_builder() -> pathlib.Path:
    """TripTracer's `/qa builder`: the thing that rewrites a seed-pool history into a scenario.

    Defaults to `vendor/qa-builder`. `QA_BUILDER_DIR` (which the kit scripts already honour) or
    `AQA_SEED_CASCADE` point at the cascade checkout instead.
    """
    fromenv = _resolve_optional("QA_BUILDER_DIR")
    if fromenv is not None:
        return fromenv
    vendored = VENDOR / "qa-builder"
    if (vendored / "builder.py").exists():
        return vendored
    return cascade() / "tools" / "qa-scenarios" / "service"


def fixtures() -> pathlib.Path:
    """agentic-qa's fixture tree, which is NOT vendored.

    The 928 fixture files were left out on purpose: `spec/` supersedes them, and only two callers
    ever read them -- `core/seed.py` (the previous generation of the seeder) and
    `tools/import_po.py` (a one-shot import that has already run). Both need a real agentic-qa
    checkout, so this raises and names the variable rather than failing later on a path that was
    never going to exist.
    """
    base = _resolve_optional("AQA_SEED_AGENTIC_QA")
    if base is None or not (base / "aqa" / "workflows" / "seed" / "fixtures" / "fd-uat").is_dir():
        raise SystemExit(
            "agentic-qa's fixture tree is not available. It is deliberately not vendored (see "
            "vendor/README.md): spec/ supersedes it.\n"
            "Set AQA_SEED_AGENTIC_QA to an agentic-qa checkout to use this tool.")
    return base / "aqa" / "workflows" / "seed" / "fixtures"


def kit() -> pathlib.Path:
    """The uat-scenarios kit. OPTIONAL and used by nothing at run time.

    Everything the kit supplied now lives in this project: its scripts in `builder/`, its five
    anonymised seed-pool bookings in `builder/seed-pool/bookings/`, its 343 specs in `spec/` and
    its run reports in `reports/`. A seed does not read the kit, and the checkout can be deleted.

    It stays named here for one job: refreshing `builder/seed-pool` or the vendored scripts when a
    newer kit is published. `require("kit")` is therefore the only external path that may be
    absent without anything being wrong.
    """
    return _resolve("AQA_SEED_KIT")


def baggage_kit() -> pathlib.Path:
    """The baggage SIT kit (BAGGAGE_SIT_KIT_20261017). OPTIONAL and read by nothing at run time.

    Read once, by `tools/import_baggage_po.py`, which imports the kit's own `case_to_spec` rather
    than copying its hundred lines of regex in here: the kit is the record of what the old INT seed
    held, and a second transcription of it is a second thing to keep right.

    Its 73 cases and the two published PNR tables now live in `spec/baggage/sit/po/` and
    `catalog/baggage-po.json`, so a hand-walk needs no kit checkout.
    """
    return _resolve("AQA_SEED_BAGGAGE_KIT")


#: inside this project
BUILDER = ROOT / "builder"
SPEC = ROOT / "spec"
RUNS = ROOT / "runs"
CATALOG = ROOT / "catalog"
#: proven code copied in rather than imported across checkouts. See `vendor/README.md` for
#: what came from where, and what was deliberately left out.
VENDOR = ROOT / "vendor"
#: the synced Jira/Xray test docs, laid out to mirror `spec/` so a case id joins the two.
#: A snapshot: Jira is the source, `aqa.jira.sync` writes these, and `synced_at` on each doc
#: says when it was last pulled.
JIRA = ROOT / "jira"


def automation() -> pathlib.Path:
    """The automation half: the Playwright suites that drive the product as a customer.

    In ac-cct-data-factory it is the sibling sub-project `ac-cct-data-automation`, and the handoff
    is still one file (a pool) that this side writes and that side reads. `AQA_SEED_AUTOMATION`
    points somewhere else; without it the sibling is used when it exists, and `automation/` inside
    this project (the layout before the split) otherwise.
    """
    fromenv = _resolve_optional("AQA_SEED_AUTOMATION")
    if fromenv is not None:
        return fromenv
    sibling = ROOT.parent / "ac-cct-data-automation"
    return sibling if sibling.is_dir() else ROOT / "automation"


#: where the suites are; see `automation()`
AUTOMATION = automation()


def require(what: str) -> pathlib.Path:
    """One of the external paths, checked. Raises with the variable to set and what was missing.

    `what` is "agentic-qa", "cascade" or "kit". Each is checked for a file that proves it is the
    right directory rather than merely an existing one -- a path that exists but holds something
    else is the failure that wastes an afternoon.
    """
    proofs = {
        "agentic-qa": (agentic_qa(), "aqa/workflows/seed/env.py", "AQA_SEED_AGENTIC_QA"),
        "qa-builder": (qa_builder(), "builder.py", "QA_BUILDER_DIR"),
        "cascade": (cascade(), "tools/qa-scenarios/service/builder.py", "AQA_SEED_CASCADE"),
        "kit": (kit(), "scenario_build.py", "AQA_SEED_KIT"),
        "baggage-kit": (baggage_kit(), "baggage/case_to_spec.py", "AQA_SEED_BAGGAGE_KIT"),
    }
    if what not in proofs:
        raise KeyError(f"no such external path {what!r}; known: {', '.join(sorted(proofs))}")
    base, proof, var = proofs[what]
    if not (base / proof).exists():
        raise SystemExit(
            f"{what} not found: {base} does not contain {proof}.\n"
            f"Set {var} to the right directory (see core/paths.py).")
    return base
