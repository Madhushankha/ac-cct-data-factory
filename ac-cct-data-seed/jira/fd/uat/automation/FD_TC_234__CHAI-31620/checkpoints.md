# FD_TC_234 · CHAI-31620 — checkpoints

**Goal:** Checks the Decision Assist override from Eligible to Not Eligible for a single passenger. Flight AC 412 YUL ? YYZ arrived 7 hours late (Code 96, Controllable). DDS returns FD-APPR-EL-02, CAD 700. The customer leaves the chat before payment, so the case goes to agent Sarah Martin. She finds a record showing that CAD 700 APPR compensation was already paid for AC 412 on Jul 22 through an airport/legacy channel. This record isn't linked in the Claims Dashboard, so the automatic duplicate check didn't catch it. Sarah overrides the decision to Not Eligible and enters a reason of 50 to 500 characters. The original Eligible recommendation stays visible as read-only, and the override is audited with before/after values. She sends "Decision Rendered � Not Eligible" and the case closes as Closed � Not Eligible. No compensation record is created and nothing is paid. Also checks that the reason length is enforced and that only permitted users can override.

Methods: seed 13, chat 10, api 13, email 1, implied 71, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Checks the Decision Assist override from Eligible to Not Eligible for a single passenger. Flight AC 412 YUL ? YYZ arrived 7 hours late (Code |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: OV001 � single passenger Antoine Leblanc (Adult, Basic Aeroplan 9876543210, good standing) | PNR: OV001 � single passenger Antoine Leblanc (Adult, Basic Aeroplan 9876543210, good standing) |
| CP003 | PREREQUISITES | prerequisite | seed | AC 412 YUL ? YYZ, July 20, 2026 | AC 412 YUL ? YYZ, July 20, 2026 |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival 12:00, actual 19:00 (7h delay) | Scheduled arrival 12:00, actual 19:00 (7h delay) |
| CP005 | PREREQUISITES | prerequisite | seed | Code 96 (Operations Control � Controllable) | Code 96 (Operations Control � Controllable) |
| CP006 | PREREQUISITES | prerequisite | seed | Travelled, arrived late | Travelled, arrived late |
| CP007 | PREREQUISITES | prerequisite | seed | No VOL/INVOL changes | No VOL/INVOL changes |
| CP008 | PREREQUISITES | prerequisite | seed | AC only | AC only |
| CP009 | PREREQUISITES | prerequisite | seed | Claim filed Jul 28, 2026 (within 366 days) | Claim filed Jul 28, 2026 (within 366 days) |
| CP010 | PREREQUISITES | prerequisite | seed | Case reference: CASE-FD-20260728-101 | Case reference: CASE-FD-20260728-101 |
| CP011 | PREREQUISITES | prerequisite | seed | Claims Dashboard duplicate check: no duplicate (the prior payment is outside CD) | Claims Dashboard duplicate check: no duplicate (the prior payment is outside CD) |
| CP012 | PREREQUISITES | prerequisite | seed | Prior payment evidence: legacy / airport record of CAD 700 APPR paid Jul 22, 2026 (reference LEG-APPR-55821) | Prior payment evidence: legacy / airport record of CAD 700 APPR paid Jul 22, 2026 (reference LEG-APPR-55821) |
| CP013 | PREREQUISITES | prerequisite | implied | CyberSource GREEN | CyberSource GREEN |
| CP014 | PREREQUISITES | prerequisite | seed | Country of residence: Canada | Country of residence: Canada |
| CP015 | PREREQUISITES | prerequisite | seed | Users: Sarah Martin (Agent with case.render_decision), Paul Girard (read-only user without case.render_decision) | Users: Sarah Martin (Agent with case.render_decision), Paul Girard (read-only user without case.render_decision) |
| CP016 | PART A � INITIAL CLAIM | customer | chat | Given the user opens the agentic chatbot |  |
| CP017 | PART A � INITIAL CLAIM | customer | chat | Then the chatbot displays greeting (GLOB-01) and the user selects "English" | English |
| CP018 | PART A � INITIAL CLAIM | alert | chat | Then the privacy alert is displayed |  |
| CP019 | PART A � INITIAL CLAIM | customer | chat | And the user says "My flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if I'm eligible for compensation" | My flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if I'm eligible for compensation |
| CP020 | PART A � INITIAL CLAIM | system | implied | When the chatbot identifies flight disruption intent |  |
| CP021 | PART A � INITIAL CLAIM | system | implied | Then third-party check ? NO, and the legal disclaimer is shown and accepted | IDENTIFICATION (GenUC-01): "Antoine Leblanc" + PNR "OV001" ? Trip Tracer PNR FOUND (Auth Flow 1) AUTHENTICATION (GenUC-05): Email a***@gmail.com ? OTP "581204"  |
| CP022 | TRIP TRACER UI VALIDATION (OV001) | verdict | api | Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M | Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M |
| CP023 | TRIP TRACER UI VALIDATION (OV001) | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP024 | TRIP TRACER UI VALIDATION (OV001) | verdict | api | MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE | MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE |
| CP025 | TRIP TRACER UI VALIDATION (OV001) | verdict | api | MR ANTOINE LEBLANC / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet | MR ANTOINE LEBLANC / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet |
| CP026 | TRIP TRACER UI VALIDATION (OV001) | verdict | api | CYBERSOURCE (GLOB-05): GREEN | CYBERSOURCE (GLOB-05): GREEN |
| CP027 | TRIP TRACER UI VALIDATION (OV001) | verdict | api | ELIGIBLE RESULT (FD-05a): APPR eligible message for AC 412 | ELIGIBLE RESULT (FD-05a): APPR eligible message for AC 412 |
| CP028 | TRIP TRACER UI VALIDATION (OV001) | verdict | api | CUSTOMER DROPS OFF: closes the chat at "In which country will your reimbursement be deposited?" | CUSTOMER DROPS OFF: closes the chat at "In which country will your reimbursement be deposited?" |
| CP029 | TRIP TRACER UI VALIDATION (OV001) | verdict | api | Then the case is created as ELIGIBLE, CAD 700, with no payment instruction, and is routed to the agent queue |  |
| CP030 | PART B � AGENT REVIEWS THE CASE | system | implied | Given Sarah Martin clicks "Get Next Case" ? Assigned ? opens it within 10 minutes ? In Progress |  |
| CP031 | PART B � AGENT REVIEWS THE CASE | system | implied | Then Decision Assist shows the FD badge, "Recommended: Eligible" (green), the reasoning list, "Last run: [timestamp]" and "CAD $700.00" with |  |
| CP032 | PART B � AGENT REVIEWS THE CASE | system | implied | When Sarah checks the Compensation history, ops notes and legacy payment lookup |  |
| CP033 | PART B � AGENT REVIEWS THE CASE | system | implied | Then she finds LEG-APPR-55821: CAD 700 APPR compensation paid to Antoine Leblanc for AC 412, Jul 20, 2026, issued Jul 22, 2026 |  |
| CP034 | PART B � AGENT REVIEWS THE CASE | verdict | api | And she confirms that Trip Tracer coding (Code 96, 7h) is correct and doesn't need changing |  |
| CP035 | PART B � AGENT REVIEWS THE CASE | system | implied | And she does NOT edit the flight code |  |
| CP036 | PART C � PERMISSION CHECK | system | implied | Given Paul Girard (no case.render_decision permission) opens the same case |  |
| CP037 | PART C � PERMISSION CHECK | system | implied | Then the "Override" button is NOT displayed |  |
| CP038 | PART C � PERMISSION CHECK | system | implied | And Paul cannot change eligibility, amount or payout method |  |
| CP039 | PART D � OVERRIDE FORM VALIDATION | system | implied | Given Sarah clicks "Override" next to the recommendation |  |
| CP040 | PART D � OVERRIDE FORM VALIDATION | system | implied | Then an inline form opens with: new eligibility (Eligible / Not Eligible / Partial), new amount, new payout method, override reason (require |  |
| CP041 | PART D � OVERRIDE FORM VALIDATION | system | implied | When she selects "Not Eligible" and leaves the reason empty |  |
| CP042 | PART D � OVERRIDE FORM VALIDATION | system | implied | Then she cannot confirm and a required-field message is shown |  |
| CP043 | PART D � OVERRIDE FORM VALIDATION | system | implied | When she enters a 30-character reason ("Already paid at airport, close") |  |
| CP044 | PART D � OVERRIDE FORM VALIDATION | system | implied | Then she cannot confirm (below the 50-character minimum) |  |
| CP045 | PART D � OVERRIDE FORM VALIDATION | system | implied | When she pastes a 520-character reason |  |
| CP046 | PART D � OVERRIDE FORM VALIDATION | system | implied | Then she cannot confirm (above the 500-character maximum) |  |
| CP047 | PART E � OVERRIDE TO NOT ELIGIBLE | system | implied | When Sarah selects new eligibility "Not Eligible" |  |
| CP048 | PART E � OVERRIDE TO NOT ELIGIBLE | system | implied | And the new amount is 0 / "�" and no payout method is selected |  |
| CP049 | PART E � OVERRIDE TO NOT ELIGIBLE | system | implied | And she enters the reason: "Passenger already received CAD 700 APPR compensation for AC 412 YUL-YYZ Jul 20 2026 via airport/legacy payment L |  |
| CP050 | PART E � OVERRIDE TO NOT ELIGIBLE | system | implied | And she clicks Confirm |  |
| CP051 | PART E � OVERRIDE TO NOT ELIGIBLE | system | implied | Then the override is saved to the case |  |
| CP052 | PART E � OVERRIDE TO NOT ELIGIBLE | system | implied | And Decision Assist shows the agent decision "Not Eligible" |  |
| CP053 | PART E � OVERRIDE TO NOT ELIGIBLE | system | implied | And the original recommendation "Recommended: Eligible � CAD 700 � FD-APPR-EL-02" stays visible as read-only context |  |
| CP054 | PART E � OVERRIDE TO NOT ELIGIBLE | system | implied | And the stored values show suggested = Eligible / CAD 700, approved = Not Eligible / CAD 0, difference = ?CAD 700 |  |
| CP055 | PART E � OVERRIDE TO NOT ELIGIBLE | system | implied | And the Audit Log records: Override, agent ID (Sarah Martin), timestamp, before (Eligible, CAD 700, Cash/AC Wallet) and after (Not Eligible, |  |
| CP056 | PART E � OVERRIDE TO NOT ELIGIBLE | system | implied | And Sarah adds an internal note referencing LEG-APPR-55821 |  |
| CP057 | PART F � ADVANCE CASE AND NOTIFY THE CUSTOMER | system | implied | When Sarah clicks "Advance Case" |  |
| CP058 | PART F � ADVANCE CASE AND NOTIFY THE CUSTOMER | system | implied | Then Step 1 shows the decision Not Eligible (overridden) with the reason summary |  |
| CP059 | PART F � ADVANCE CASE AND NOTIFY THE CUSTOMER | system | implied | When she selects the template "Decision Rendered � Not Eligible" (English) |  |
| CP060 | PART F � ADVANCE CASE AND NOTIFY THE CUSTOMER | system | implied | And enters customer text saying compensation for this disruption has already been issued, without internal references or payment details |  |
| CP061 | PART F � ADVANCE CASE AND NOTIFY THE CUSTOMER | system | implied | And sends it |  |
| CP062 | PART F � ADVANCE CASE AND NOTIFY THE CUSTOMER | email | email | Then the notification is sent via Adobe to a***@gmail.com |  |
| CP063 | PART F � ADVANCE CASE AND NOTIFY THE CUSTOMER | system | implied | And no secure payment / Welcome Back link is included |  |
| CP064 | PART F � ADVANCE CASE AND NOTIFY THE CUSTOMER | system | implied | And the case status becomes "Closed � Not Eligible" |  |
| CP065 | PART G � AFTER CLOSURE | system | implied | Given the case is Closed � Not Eligible |  |
| CP066 | PART G � AFTER CLOSURE | system | implied | Then Decision Assist is read-only and the Override button can't be used |  |
| CP067 | PART G � AFTER CLOSURE | system | implied | And no compensation record exists | Claims Dashboard Gherkin: |
| CP068 | PART G � AFTER CLOSURE | verdict | api | Given case "CASE-FD-20260728-101" for claimant "Antoine Leblanc" (PNR "OV001") has a DDS recommendation of "Eligible", "FD-APPR-EL-02", "CAD | CASE-FD-20260728-101 Antoine Leblanc OV001 Eligible FD-APPR-EL-02 CAD 700 |
| CP069 | PART G � AFTER CLOSURE | system | implied | And agent "Sarah Martin" has the "case.render_decision" permission |  |
| CP070 | PART G � AFTER CLOSURE | system | implied | When a user without "case.render_decision" opens the case |  |
| CP071 | PART G � AFTER CLOSURE | system | implied | Then the "Override" button should not be displayed |  |
| CP072 | PART G � AFTER CLOSURE | system | implied | When Sarah clicks "Override" and selects "Not Eligible" |  |
| CP073 | PART G � AFTER CLOSURE | system | implied | And the override reason is empty, under 50 characters or over 500 characters |  |
| CP074 | PART G � AFTER CLOSURE | system | implied | Then the override should not be saved |  |
| CP075 | PART G � AFTER CLOSURE | system | implied | When Sarah enters a valid reason of 50 to 500 characters and confirms |  |
| CP076 | PART G � AFTER CLOSURE | system | implied | Then the agent decision should be "Not Eligible" with amount 0 and no payout method |  |
| CP077 | PART G � AFTER CLOSURE | system | implied | And the original "Recommended: Eligible � CAD 700" should remain visible as read-only |  |
| CP078 | PART G � AFTER CLOSURE | system | implied | And the suggested value, approved value and difference should be stored |  |
| CP079 | PART G � AFTER CLOSURE | system | implied | And the Audit Log should record agent ID, timestamp, before/after values and reason |  |
| CP080 | PART G � AFTER CLOSURE | system | implied | And the flight code should still be 96 (not edited) |  |
| CP081 | PART G � AFTER CLOSURE | system | implied | And the Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP082 | PART G � AFTER CLOSURE | system | implied | And the Claimant should be "Antoine Leblanc", Adult, Authentication "Pass" |  |
| CP083 | PART G � AFTER CLOSURE | system | implied | And the PNR should be "OV001" with Creation Date, Journey ID, Booking Source and Office ID populated |  |
| CP084 | PART G � AFTER CLOSURE | verdict | api | And the Regime should be "APPR" | APPR |
| CP085 | PART G � AFTER CLOSURE | system | implied | And the Aeroplan should be "9876543210", Tier "Basic / Member" |  |
| CP086 | PART G � AFTER CLOSURE | system | implied | And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 96) |  |
| CP087 | PART G � AFTER CLOSURE | system | implied | And the Eligibility and Compensation section should show "Not Eligible (Agent Override)" |  |
| CP088 | PART G � AFTER CLOSURE | system | implied | And CyberSource should be "GREEN" |  |
| CP089 | PART G � AFTER CLOSURE | system | implied | When Sarah sends "Decision Rendered � Not Eligible" |  |
| CP090 | PART G � AFTER CLOSURE | system | implied | Then Customer Communications should show the Not Eligible notification with template ID, version, language, timestamp and delivery status |  |
| CP091 | PART G � AFTER CLOSURE | system | implied | And no payment link should be sent |  |
| CP092 | PART G � AFTER CLOSURE | system | implied | And the status should be "Closed � Not Eligible" |  |
| CP093 | PART G � AFTER CLOSURE | system | implied | And the case should be read-only after closure |  |
| CP094 | PART G � AFTER CLOSURE | system | implied | And the agent should not be able to access Case Search as it is for leads and management only | Payment Validation Gherkin: |
| CP095 | PART G � AFTER CLOSURE | verdict | api | Given the DDS recommendation was "Eligible, CAD 700" and the agent overrode it to "Not Eligible" | Eligible, CAD 700 Not Eligible |
| CP096 | PART G � AFTER CLOSURE | system | implied | Then no Cash or AC Wallet option should be offered to the customer |  |
| CP097 | PART G � AFTER CLOSURE | system | implied | And no country of residence, Interac email, bank or card details should be collected |  |
| CP098 | PART G � AFTER CLOSURE | idv | chat | And Persona IDV for payout should not be triggered |  |
| CP099 | PART G � AFTER CLOSURE | system | implied | And no compensation record should be created |  |
| CP100 | PART G � AFTER CLOSURE | system | implied | And nothing should be picked up by the evening batch file |  |
| CP101 | PART G � AFTER CLOSURE | system | implied | And nothing should be sent to Unifier or EIP |  |
| CP102 | PART G � AFTER CLOSURE | system | implied | And the Compensation tab should show no payout for this case |  |
| CP103 | PART G � AFTER CLOSURE | system | implied | And the prior payment LEG-APPR-55821 should not be duplicated |  |
| CP104 | EXPECTED RESULTS | verdict | api | DDS FD-APPR-EL-02, Eligible, CAD 700. | DDS FD-APPR-EL-02, Eligible, CAD 700. |
| CP105 | EXPECTED RESULTS | verdict | chat | An authorized agent overrides it to Not Eligible with a required 50 to 500-character reason. | An authorized agent overrides it to Not Eligible with a required 50 to 500-character reason. |
| CP106 | EXPECTED RESULTS | verdict | chat | The original recommendation is kept as read-only, and suggested vs approved values and the difference are stored. | The original recommendation is kept as read-only, and suggested vs approved values and the difference are stored. |
| CP107 | EXPECTED RESULTS | verdict | chat | The override is audited with before/after values. | The override is audited with before/after values. |
| CP108 | EXPECTED RESULTS | verdict | chat | Users without permission can't override, and invalid reasons are blocked. | Users without permission can't override, and invalid reasons are blocked. |
| CP109 | EXPECTED RESULTS | verdict | chat | The "Decision Rendered � Not Eligible" notice is sent with no payment link, and the case closes as Closed � Not Eligible with no payout. | The "Decision Rendered � Not Eligible" notice is sent with no payment link, and the case closes as Closed � Not Eligible with no payout. |
