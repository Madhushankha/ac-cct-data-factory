"""A Jira test -> a goal-mode chat plan: sample data swapped, text cleaned, rows routed.

Synthetic checkpoints in the snapshot's own shape, plus one real test from `jira/` when it is there.

Run:  python tests/test_goal_plan.py
"""
from __future__ import annotations

import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from domain import goal_plan                                                # noqa: E402
from domain.goal_plan import Booking, build, clean                          # noqa: E402

FAILED: list[str] = []


def check(label: str, got: object, want: object) -> None:
    if got != want:
        FAILED.append(label)
        print(f"  FAIL {label}: got {got!r}, wanted {want!r}")
    else:
        print(f"  ok   {label}")


BOOKING = Booking(pnr="ZZAB12", first="Siena", last="Perbarpav", case_id="SOC_UAT_900", pool="p")


def cp(id_, kind, method, step, expected=None, section="START", requirement=None):
    return {"id": id_, "kind": kind, "method": method, "step": step, "expected": expected,
            "section": section, "requirement": requirement}


DOC = {"key": "CHAI-1", "test_id": "SOC_UAT_900", "title": "APPR � Not Eligible",
       "goal": "Verify not eligible.", "checkpoints": [
           cp("CP001", "goal", "report", "Verify not eligible."),
           cp("CP002", "prerequisite", "seed", "Regime: APPR"),
           cp("CP003", "customer", "chat", "Given the user opens the agentic chatbot"),
           cp("CP004", "bot", "chat", "Then the chatbot displays greeting (GLOB-01):",
              "Hello! Which language?", requirement="GLOB-01"),
           cp("CP005", "customer", "chat", "Then user selects English"),
           cp("CP006", "customer", "chat", 'And the user says "My flight YYZ?YYC was cancelled"'),
           cp("CP007", "customer", "chat", 'And the user provides "[First Name] [Last Name]"',
              section="IDENTIFICATION (GenUC-01)"),
           cp("CP008", "customer", "chat", 'And the user provides "PNR: [PNR Code]"',
              section="IDENTIFICATION (GenUC-01)"),
           cp("CP009", "customer", "chat", 'And the user selects "Email: t***@gmail.com"'),
           cp("CP010", "customer", "chat", 'And the user provides the OTP code "546879"'),
           cp("CP011", "system", "implied", "Then the chatbot checks: third party ? NO"),
           cp("CP012", "payment", "chat", "Then the chatbot shows payout options", "Interac"),
           cp("CP013", "verdict", "api", "Then the system code is SOC-NE-12"),
           cp("CP014", "dashboard", "dashboard", "Scenario: Claims Dashboard validation"),
           cp("CP015", "dashboard", "dashboard", 'And the Status is "Closed → Not Eligible"'),
           cp("CP016", "dashboard", "manual", "And the Chatbot transcript is linked"),
           cp("CP017", "dashboard", "dashboard", "And the moon is full"),
           cp("CP018", "email", "email", "Then an eligibility email is sent", "Your claim"),
           cp("CP019", "customer", "chat", 'And the user confirms "Yes"'),
       ]}
FEATURE = "\n".join([
    "Given the user opens the agentic chatbot",
    "Then the chatbot displays greeting (GLOB-01):",
    '"Hello! Which language?"',
    "Then user selects English",
    'And the user says "My flight YYZ?YYC was cancelled"',
    'And the user provides "[First Name] [Last Name]"',
    'And the user provides "PNR: [PNR Code]"',
])


def test_clean() -> None:
    print("cleaning Jira's text")
    check("an arrow between airport codes comes back", clean("YYZ?YYC"), "YYZ→YYC")
    check("a ? between words is an arrow", clean("Regular ? NOT ELIGIBLE"),
          "Regular → NOT ELIGIBLE")
    check("a lone replacement character is dropped", clean("V�ronique"), "Vronique")
    check("a real question mark at the end stays", clean("Can I get reimbursed?"),
          "Can I get reimbursed?")
    from domain.testdoc import readable
    check("a title's lost dashes come back as en dashes",
          readable("APPR � Not Eligible � Employee Booking AC"),
          "APPR – Not Eligible – Employee Booking AC")
    check("a line-leading one was a bullet",
          readable("� Regime: APPR\n  � PAX Count: 1"), "• Regime: APPR\n  • PAX Count: 1")
    check("a lost accent inside a word stays visible, never guessed",
          readable("V�ronique"), "V�ronique")
    check("a doubled-quoted value is read, not taken as empty",
          goal_plan.quoted('And the user confirms ""Yes""'), "Yes")


def test_plan() -> None:
    print("the plan")
    plan = build(DOC, FEATURE, BOOKING)
    item = plan.item
    check("identity comes from the booking", (item["pnr"], item["caseId"], item["jiraKey"]),
          ("ZZAB12", "SOC_UAT_900", "CHAI-1"))
    script = [(s["type"], s.get("value")) for s in item["script"]]
    check("customer steps, in order, with the test's sample data replaced", script, [
        ("click", "English"),
        ("say", "My flight YYZ→YYC was cancelled"),
        ("provide", "Siena Perbarpav"),
        ("provide", "ZZAB12"),
        ("click", "Email"),
        ("otp", None),
        ("click", "Yes")])
    check("opening the chat is the harness's job, not a step",
          any("opens" in str(s.get("value")) for s in item["script"]), False)
    check("feature line numbers are carried for the failure report",
          [s.get("line") for s in item["script"]][:4], [4, 5, 6, 7])
    check("a placeholder is not mistaken for the test's sample PNR", item.get("sample"), None)
    judged = [(c["kind"], c["jiraCheckpoint"]) for c in item["checkpoints"]]
    check("only chat-verified bot/payment lines go to the judge", judged,
          [("bot", "CP004"), ("payment", "CP012")])
    check("the bot line's expected text, with its requirement",
          (item["checkpoints"][0]["text"], item["checkpoints"][0]["requirement"]),
          ("Hello! Which language?", "GLOB-01"))
    dash = {d["jiraCheckpoint"]: d for d in item["dashboard"]}
    check("a Scenario heading is not a dashboard check", "CP014" in dash, False)
    check("the case status maps to the API's CP105, with its quoted value",
          (dash["CP015"]["api"], dash["CP015"]["expected"]), ("CP105", "Closed → Not Eligible"))
    check("a manual check is kept, flagged manual", (dash["CP016"]["api"], dash["CP016"]["manual"]),
          ("CP152", True))
    check("an unmappable check is listed, never guessed", plan.unmapped_dashboard, ["CP017"])
    check("email rows are kept for the mailbox check", [e["jiraCheckpoint"] for e in item["emails"]],
          ["CP018"])
    check("a test that pays out may proceed with payment", item["allow"],
          ["payout-country", "payment-proceed"])
    check("unless told not to", build(DOC, FEATURE, BOOKING, allow_payment=False).item.get("allow"),
          None)


def test_idv_and_back_office() -> None:
    print("IDV, back-office lines and example contacts")
    doc = {"key": "CHAI-3", "test_id": "FD_TC_001", "checkpoints": [
        cp("C1", "idv", "chat", "Then system checks that IDV is not completed"),
        cp("C2", "bot", "chat", "Then the chatbot asks to verify your identity", "Please verify your identity with Persona"),
        cp("C3", "customer", "chat", "And the customer opens the Persona link"),
        cp("C4", "verdict", "chat", "CyberSource: GREEN -> auto-approved."),
        cp("C5", "bot", "chat", "Then the chatbot offers:", "Email: c***@gmail.com or Phone: +1***567"),
        cp("C6", "dashboard", "dashboard", "And the IDV status should be verified"),
    ]}
    item = build(doc, "", BOOKING).item
    check("every IDV line is skipped, never judged",
          [s["jiraCheckpoint"] for s in item["skipped"]], ["C1", "C2", "C6"])
    check("and marked why", {s["reason"] for s in item["skipped"]}, {goal_plan.IDV_SKIP})
    check("the chat still gets past Persona", [s["type"] for s in item["script"]], ["click"])
    check("a back-office line goes to the dashboard checks, not the chat judge",
          [d["jiraCheckpoint"] for d in item["dashboard"]], ["C4"])
    check("the test's example contacts are not held against the booking",
          item["checkpoints"][0]["text"], "Email: <the booking's masked e-mail> or Phone: <the booking's masked phone>")


def test_single_passenger() -> None:
    print("a 1-passenger booking")
    doc = {"key": "CHAI-4", "test_id": "FD_TC_001", "checkpoints": [
        cp("Q1", "bot", "chat", "Then the chatbot asks:", "How many people are on your claim?", requirement="GenUC-06"),
        cp("Q2", "bot", "chat", "Then the chatbot shows the passengers on your booking", "Catherine Bouchard"),
        cp("Q3", "bot", "chat", "Then the chatbot shows the flight card", "Departure"),
    ]}
    one = build(doc, "", BOOKING, passengers=1).item
    check("the passenger-count question and list are not applicable",
          ([s["jiraCheckpoint"] for s in one["skipped"]], {s["reason"] for s in one["skipped"]}),
          (["Q1", "Q2"], {goal_plan.SINGLE_PAX_SKIP}))
    check("and the rest is still judged", [c["jiraCheckpoint"] for c in one["checkpoints"]], ["Q3"])
    check("with two passengers they are judged",
          len(build(doc, "", BOOKING, passengers=2).item["checkpoints"]), 3)


def test_example_names() -> None:
    print("a test's own example name and PNR")
    doc = {"key": "CHAI-2", "test_id": "FD_TC_024", "checkpoints": [
        cp("CP1", "customer", "chat", 'And the user provides "Dominique Arsenault"',
           section="IDENTIFICATION (GenUC-01)"),
        cp("CP2", "customer", "chat", 'And the user provides "PNR: TC024"',
           section="IDENTIFICATION (GenUC-01)"),
        cp("CP3", "customer", "chat", 'And the user says "Dominique here, booking TC024"'),
    ]}
    item = build(doc, "", BOOKING).item
    check("the example name and PNR become the booking's everywhere",
          [s["value"] for s in item["script"]],
          ["Siena Perbarpav", "ZZAB12", "Siena here, booking ZZAB12"])
    check("and are recorded as the sample, for the AI's mapping",
          item["sample"], {"name": "Dominique Arsenault", "pnr": "TC024", "first": "Dominique"})


RECEIPTS = [
    {"file": "receipts/soc/SOC_UAT_900/SOC_UAT_900_1_hotel_YYZ.pdf", "category": "hotel",
     "currency": "CAD", "total": 620.0, "expected": "partial: capped at CAD 500.00 (AC_PE_02)",
     "approved": 500.0, "cap": {"amount": 500.0, "currency": "CAD"}, "date": "2026-10-08"},
    {"file": "receipts/soc/SOC_UAT_900/SOC_UAT_900_2_meal_YYZ.jpg", "category": "meal",
     "currency": "CAD", "total": 52.0, "expected": "paid in full", "approved": None,
     "cap": {"amount": 60.0, "currency": "EUR"}},
]


def test_receipts() -> None:
    print("a case's own receipts")
    plain = build(DOC, FEATURE, BOOKING).item
    check("no manifest: no receipts key, nothing added", ("receipts" in plain,
          [c for c in plain["checkpoints"] if c["kind"] == "receipt"]), (False, []))
    plan = build(DOC, FEATURE, BOOKING, receipts=RECEIPTS)
    item = plan.item
    check("the item names the files goal.ts uploads, in its shape", item["receipts"], [
        {"file": "receipts/soc/SOC_UAT_900/SOC_UAT_900_1_hotel_YYZ.pdf", "category": "hotel",
         "total": 620.0, "currency": "CAD"},
        {"file": "receipts/soc/SOC_UAT_900/SOC_UAT_900_2_meal_YYZ.jpg", "category": "meal",
         "total": 52.0, "currency": "CAD"}])
    rc = [c for c in item["checkpoints"] if c["kind"] == "receipt"]
    check("one judged receipt checkpoint per file, after the test's own", (
        len(rc), [c["kind"] for c in item["checkpoints"]][-2:]), (2, ["receipt", "receipt"]))
    check("a capped receipt is judged at the cap", rc[0]["text"],
          "The assistant accepts the hotel receipt for CAD 620.00 and approves it capped at CAD "
          "500.00 (or shows the capped amount in the expense summary)")
    check("a receipt under its cap is judged paid in full", rc[1]["text"],
          "The assistant accepts the meal receipt for CAD 52.00 and approves it (or shows it in the "
          "expense summary)")
    check("receipt checkpoints carry RR-01 and their file",
          (rc[1]["requirement"], rc[1]["file"].endswith("_meal_YYZ.jpg")), ("RR-01", True))
    att = [d for d in item["dashboard"] if d.get("source") == "receipts"]
    check("one CP153 attachments row with the expected count",
          [(d["api"], d["expected"]) for d in att], [("CP153", "2")])
    check("the receipt rows are mapped, not counted as unmapped", plan.unmapped_dashboard, ["CP017"])


def test_cli_receipts() -> None:
    print("goal-plan reads <receipts dir>/<CASE>/manifest.json")
    import tempfile
    from cli.commands import _case_receipts
    with tempfile.TemporaryDirectory() as tmp:
        suite = pathlib.Path(tmp) / "playwright-baggage"
        folder = suite / "receipts" / "soc" / "SOC_UAT_900"
        folder.mkdir(parents=True)
        (folder / "manifest.json").write_text(json.dumps({"receipts": [
            {"file": "SOC_UAT_900_1_hotel_YYZ.pdf", "category": "hotel", "currency": "CAD",
             "total": 185.0, "expected": "paid in full"}]}), encoding="utf-8")
        got = _case_receipts(suite / "receipts" / "soc", suite, "SOC_UAT_900")
        check("a manifest inside the suite gives paths relative to it",
              [r["file"] for r in got], ["receipts/soc/SOC_UAT_900/SOC_UAT_900_1_hotel_YYZ.pdf"])
        check("no manifest for a case: None", _case_receipts(suite / "receipts" / "soc", suite,
                                                             "SOC_UAT_901"), None)
        outside = _case_receipts(suite / "receipts" / "soc", pathlib.Path(tmp) / "elsewhere",
                                 "SOC_UAT_900")
        check("outside the suite: an absolute path", pathlib.PurePosixPath(
            outside[0]["file"]).is_absolute() or ":" in outside[0]["file"], True)


def test_real_snapshot() -> None:
    folder = next((ROOT / "jira" / "soc" / "uat" / "automation").glob("SOC_UAT_007__*"), None)
    if folder is None:
        print("the real snapshot: not synced here, skipped")
        return
    print("a real Jira test")
    plan = build(json.loads((folder / "checkpoints.json").read_text(encoding="utf-8")),
                 (folder / "test.feature").read_text(encoding="utf-8"), BOOKING)
    types = [s["type"] for s in plan.item["script"]]
    check("it has an OTP step and no step left unrecognised",
          ("otp" in types, "assumed" in types), (True, False))
    # the EXPECTED RESULTS summary rows come from the description, not the feature, so only the
    # bot's own lines are held to having one
    check("every bot line has a feature line",
          all(c["line"] for c in plan.item["checkpoints"] if c["kind"] == "bot"), True)
    check("no replacement character survives into what the AI or judge reads",
          goal_plan._REPLACEMENT in json.dumps(plan.item, ensure_ascii=False), False)


if __name__ == "__main__":
    test_clean()
    test_plan()
    test_idv_and_back_office()
    test_single_passenger()
    test_example_names()
    test_receipts()
    test_cli_receipts()
    test_real_snapshot()
    if FAILED:
        print(f"\n{len(FAILED)} check(s) failed")
        sys.exit(1)
    print("\nall checks passed")
