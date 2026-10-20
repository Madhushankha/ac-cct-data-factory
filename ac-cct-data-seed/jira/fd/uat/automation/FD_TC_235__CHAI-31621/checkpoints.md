# FD_TC_235 · CHAI-31621 — checkpoints

**Goal:** Checks the Decision Assist override from Eligible to Not Eligible on a 3-passenger case. Flight AC 412 YUL ? YYZ arrived 7 hours late (Code 96, Controllable). DDS returns FD-APPR-EL-02 for each passenger: CAD 700 each, CAD 2,100 in total (AC Wallet CAD 2,520). The claimant leaves the chat before payment, so the case goes to agent Sarah Martin. She finds legacy/airport records showing CAD 700 APPR compensation was already paid to each of the 3 passengers for AC 412. Those records aren't linked in the Claims Dashboard. Sarah overrides each passenger to Not Eligible and enters a reason of 50 to 500 characters. The original Eligible recommendation stays read-only for each passenger. The override is audited per passenger with before/after values, and the case total goes from CAD 2,100 to CAD 0. One "Decision Rendered � Not Eligible" notice is sent for the case, and the case closes as Closed � Not Eligible. No payment records are created. The test also checks that each passenger shows the correct result and that only permitted users can override.

Methods: seed 14, chat 11, api 16, email 1, implied 78, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Checks the Decision Assist override from Eligible to Not Eligible on a 3-passenger case. Flight AC 412 YUL ? YYZ arrived 7 hours late (Code  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: OV003 � 3 passengers: Catherine Bouchard (Adult - Claimant, Basic Aeroplan 9876543210, good standing), Alexandre Bouchard (Adult), Soph | PNR: OV003 � 3 passengers: Catherine Bouchard (Adult - Claimant, Basic Aeroplan 9876543210, good standing), Alexandre Bouchard (Adult), Sophie Bouchard (Child) |
| CP003 | PREREQUISITES | prerequisite | seed | AC 412 YUL ? YYZ, July 20, 2026 | AC 412 YUL ? YYZ, July 20, 2026 |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival 12:00, actual 19:00 (7h delay) | Scheduled arrival 12:00, actual 19:00 (7h delay) |
| CP005 | PREREQUISITES | prerequisite | seed | Code 96 (Operations Control � Controllable) | Code 96 (Operations Control � Controllable) |
| CP006 | PREREQUISITES | prerequisite | seed | Travelled, arrived late | Travelled, arrived late |
| CP007 | PREREQUISITES | prerequisite | seed | No VOL/INVOL changes | No VOL/INVOL changes |
| CP008 | PREREQUISITES | prerequisite | seed | AC only | AC only |
| CP009 | PREREQUISITES | prerequisite | seed | Not a group booking (3 pax, 9 or fewer) | Not a group booking (3 pax, 9 or fewer) |
| CP010 | PREREQUISITES | prerequisite | seed | Claim filed Jul 28, 2026 | Claim filed Jul 28, 2026 |
| CP011 | PREREQUISITES | prerequisite | seed | Case reference: CASE-FD-20260728-103 | Case reference: CASE-FD-20260728-103 |
| CP012 | PREREQUISITES | prerequisite | seed | Claims Dashboard duplicate check: none found | Claims Dashboard duplicate check: none found |
| CP013 | PREREQUISITES | prerequisite | seed | Prior payments (outside the Claims Dashboard): LEG-APPR-55831 (Catherine), LEG-APPR-55832 (Alexandre), LEG-APPR-55833 (Sophie), each CAD 700 | Prior payments (outside the Claims Dashboard): LEG-APPR-55831 (Catherine), LEG-APPR-55832 (Alexandre), LEG-APPR-55833 (Sophie), each CAD 700, issued Jul 22, 202 |
| CP014 | PREREQUISITES | prerequisite | implied | CyberSource GREEN | CyberSource GREEN |
| CP015 | PREREQUISITES | prerequisite | seed | Country of residence: Canada | Country of residence: Canada |
| CP016 | PREREQUISITES | prerequisite | seed | Users: Sarah Martin (has case.render_decision), Paul Girard (no case.render_decision) | Users: Sarah Martin (has case.render_decision), Paul Girard (no case.render_decision) |
| CP017 | PART A � INITIAL CLAIM | customer | chat | Given the user opens the agentic chatbot |  |
| CP018 | PART A � INITIAL CLAIM | customer | chat | Then the chatbot displays greeting (GLOB-01) and the user selects "English" | English |
| CP019 | PART A � INITIAL CLAIM | alert | chat | Then the privacy alert is displayed |  |
| CP020 | PART A � INITIAL CLAIM | customer | chat | And the user says "Our flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if my family and I are eligible for comp | Our flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if my family and I are eligible for compensation |
| CP021 | PART A � INITIAL CLAIM | system | implied | When the chatbot identifies flight disruption intent |  |
| CP022 | PART A � INITIAL CLAIM | system | implied | Then third-party check ? NO, and the legal disclaimer is shown and accepted | IDENTIFICATION (GenUC-01): "Catherine Bouchard" + PNR "OV003" ? Trip Tracer PNR FOUND (Auth Flow 1) AUTHENTICATION (GenUC-05): Email c***@gmail.com ? OTP "64021 |
| CP023 | TRIP TRACER UI VALIDATION (OV003) | verdict | api | Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M | Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M |
| CP024 | TRIP TRACER UI VALIDATION (OV003) | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP025 | TRIP TRACER UI VALIDATION (OV003) | verdict | api | MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE | MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE |
| CP026 | TRIP TRACER UI VALIDATION (OV003) | verdict | api | MS CATHERINE BOUCHARD / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet | MS CATHERINE BOUCHARD / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet |
| CP027 | TRIP TRACER UI VALIDATION (OV003) | verdict | api | MR ALEXANDRE BOUCHARD / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet | MR ALEXANDRE BOUCHARD / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet |
| CP028 | TRIP TRACER UI VALIDATION (OV003) | verdict | api | MISS SOPHIE BOUCHARD / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet | MISS SOPHIE BOUCHARD / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet |
| CP029 | TRIP TRACER UI VALIDATION (OV003) | verdict | api | Total: CAD 2,100.00 Cash / CAD 2,520.00 AC Wallet | Total: CAD 2,100.00 Cash / CAD 2,520.00 AC Wallet |
| CP030 | TRIP TRACER UI VALIDATION (OV003) | verdict | api | CYBERSOURCE (GLOB-05): GREEN | CYBERSOURCE (GLOB-05): GREEN |
| CP031 | TRIP TRACER UI VALIDATION (OV003) | verdict | api | ELIGIBLE RESULT (FD-05a): APPR eligible message for AC 412 for all 3 passengers | ELIGIBLE RESULT (FD-05a): APPR eligible message for AC 412 for all 3 passengers |
| CP032 | TRIP TRACER UI VALIDATION (OV003) | verdict | api | CUSTOMER DROPS OFF: closes the chat at "In which country will your reimbursement be deposited?" | CUSTOMER DROPS OFF: closes the chat at "In which country will your reimbursement be deposited?" |
| CP033 | TRIP TRACER UI VALIDATION (OV003) | verdict | api | Then one case is created for all 3 passengers as ELIGIBLE, CAD 2,100 total, with no payment instruction, and is routed to the agent queue |  |
| CP034 | PART B � AGENT REVIEWS THE CASE | system | implied | Given Sarah Martin clicks "Get Next Case" ? Assigned ? opens it within 10 minutes ? In Progress |  |
| CP035 | PART B � AGENT REVIEWS THE CASE | system | implied | Then Decision Assist shows the FD badge, "Recommended: Eligible" (green), the reasoning list and the "Last run" timestamp |  |
| CP036 | PART B � AGENT REVIEWS THE CASE | system | implied | And the recommendation lists each passenger: Catherine CAD 700, Alexandre CAD 700, Sophie CAD 700, total CAD 2,100 |  |
| CP037 | PART B � AGENT REVIEWS THE CASE | system | implied | When Sarah checks the compensation history, ops notes and legacy payment lookup for each passenger |  |
| CP038 | PART B � AGENT REVIEWS THE CASE | system | implied | Then she finds LEG-APPR-55831, 55832 and 55833: CAD 700 APPR compensation paid to each passenger for AC 412, Jul 20, issued Jul 22, 2026 |  |
| CP039 | PART B � AGENT REVIEWS THE CASE | verdict | api | And she confirms the Trip Tracer coding (Code 96, 7h) is correct |  |
| CP040 | PART B � AGENT REVIEWS THE CASE | system | implied | And she does NOT edit the flight code |  |
| CP041 | PART C � PERMISSION CHECK | system | implied | Given Paul Girard (no case.render_decision permission) opens the case |  |
| CP042 | PART C � PERMISSION CHECK | system | implied | Then the "Override" button is NOT displayed for any passenger |  |
| CP043 | PART C � PERMISSION CHECK | system | implied | And Paul cannot change eligibility, amount or payout method |  |
| CP044 | PART D � OVERRIDE FORM VALIDATION | system | implied | Given Sarah clicks "Override" |  |
| CP045 | PART D � OVERRIDE FORM VALIDATION | system | implied | Then the override form opens with: new eligibility (Eligible / Not Eligible / Partial), new amount, new payout method and override reason (r |  |
| CP046 | PART D � OVERRIDE FORM VALIDATION | system | implied | When she selects "Not Eligible" and leaves the reason empty |  |
| CP047 | PART D � OVERRIDE FORM VALIDATION | system | implied | Then she cannot confirm and a required-field message is shown |  |
| CP048 | PART D � OVERRIDE FORM VALIDATION | system | implied | When she enters a reason under 50 characters |  |
| CP049 | PART D � OVERRIDE FORM VALIDATION | system | implied | Then she cannot confirm |  |
| CP050 | PART D � OVERRIDE FORM VALIDATION | system | implied | When she enters a reason over 500 characters |  |
| CP051 | PART D � OVERRIDE FORM VALIDATION | system | implied | Then she cannot confirm |  |
| CP052 | PART E � OVERRIDE ALL 3 PASSENGERS TO NOT ELIGIBLE | system | implied | When Sarah sets Catherine Bouchard to "Not Eligible", amount 0, no payout method |  |
| CP053 | PART E � OVERRIDE ALL 3 PASSENGERS TO NOT ELIGIBLE | system | implied | And sets Alexandre Bouchard to "Not Eligible", amount 0, no payout method |  |
| CP054 | PART E � OVERRIDE ALL 3 PASSENGERS TO NOT ELIGIBLE | system | implied | And sets Sophie Bouchard to "Not Eligible", amount 0, no payout method |  |
| CP055 | PART E � OVERRIDE ALL 3 PASSENGERS TO NOT ELIGIBLE | system | implied | And enters the reason: "All 3 passengers already received CAD 700 APPR compensation each for AC 412 YUL-YYZ Jul 20 2026 via airport/legacy p |  |
| CP056 | PART E � OVERRIDE ALL 3 PASSENGERS TO NOT ELIGIBLE | system | implied | And clicks Confirm |  |
| CP057 | PART E � OVERRIDE ALL 3 PASSENGERS TO NOT ELIGIBLE | system | implied | Then the override is saved for all 3 passengers |  |
| CP058 | PART E � OVERRIDE ALL 3 PASSENGERS TO NOT ELIGIBLE | system | implied | And Decision Assist shows the agent decision "Not Eligible" for each passenger |  |
| CP059 | PART E � OVERRIDE ALL 3 PASSENGERS TO NOT ELIGIBLE | system | implied | And the original recommendation (Eligible, CAD 700 each, FD-APPR-EL-02) stays visible as read-only for each passenger |  |
| CP060 | PART E � OVERRIDE ALL 3 PASSENGERS TO NOT ELIGIBLE | system | implied | And the stored values show, per passenger: suggested = Eligible / CAD 700, approved = Not Eligible / CAD 0, difference = ?CAD 700 |  |
| CP061 | PART E � OVERRIDE ALL 3 PASSENGERS TO NOT ELIGIBLE | system | implied | And the stored case totals show: suggested CAD 2,100, approved CAD 0, difference ?CAD 2,100 |  |
| CP062 | PART E � OVERRIDE ALL 3 PASSENGERS TO NOT ELIGIBLE | system | implied | And the Audit Log has an override entry for each passenger with agent ID, timestamp, before/after values and reason |  |
| CP063 | PART E � OVERRIDE ALL 3 PASSENGERS TO NOT ELIGIBLE | system | implied | And no passenger is left with an Eligible amount or a payout method |  |
| CP064 | PART E � OVERRIDE ALL 3 PASSENGERS TO NOT ELIGIBLE | system | implied | And Sarah adds an internal note referencing all 3 legacy payment references |  |
| CP065 | PART F � ADVANCE CASE AND NOTIFY THE CUSTOMER | system | implied | When Sarah clicks "Advance Case" |  |
| CP066 | PART F � ADVANCE CASE AND NOTIFY THE CUSTOMER | system | implied | Then Step 1 shows the decision Not Eligible (overridden) for all 3 passengers, total CAD 0, and the reason summary |  |
| CP067 | PART F � ADVANCE CASE AND NOTIFY THE CUSTOMER | system | implied | When she selects the template "Decision Rendered � Not Eligible" (English) |  |
| CP068 | PART F � ADVANCE CASE AND NOTIFY THE CUSTOMER | system | implied | And enters customer text saying compensation for this disruption has already been issued to all 3 passengers, without internal references or |  |
| CP069 | PART F � ADVANCE CASE AND NOTIFY THE CUSTOMER | system | implied | And sends it |  |
| CP070 | PART F � ADVANCE CASE AND NOTIFY THE CUSTOMER | email | email | Then one notification is sent via Adobe to c***@gmail.com for the case (not one per passenger) |  |
| CP071 | PART F � ADVANCE CASE AND NOTIFY THE CUSTOMER | system | implied | And the notification lists all 3 passengers as Not Eligible |  |
| CP072 | PART F � ADVANCE CASE AND NOTIFY THE CUSTOMER | system | implied | And no secure payment / Welcome Back link is included |  |
| CP073 | PART F � ADVANCE CASE AND NOTIFY THE CUSTOMER | system | implied | And the case status becomes "Closed � Not Eligible" |  |
| CP074 | PART G � AFTER CLOSURE | system | implied | Given the case is Closed � Not Eligible |  |
| CP075 | PART G � AFTER CLOSURE | system | implied | Then Decision Assist is read-only for all passengers and the Override button can't be used |  |
| CP076 | PART G � AFTER CLOSURE | system | implied | And no compensation / payment record exists for any passenger | Claims Dashboard Gherkin: |
| CP077 | PART G � AFTER CLOSURE | system | implied | Given case "CASE-FD-20260728-103" for claimant "Catherine Bouchard" (PNR "OV003") covers 3 passengers |  |
| CP078 | PART G � AFTER CLOSURE | verdict | api | And the DDS recommendation is "Eligible", "FD-APPR-EL-02", CAD 700 per passenger, CAD 2,100 total | Eligible FD-APPR-EL-02 |
| CP079 | PART G � AFTER CLOSURE | system | implied | And agent "Sarah Martin" has the "case.render_decision" permission |  |
| CP080 | PART G � AFTER CLOSURE | system | implied | When a user without "case.render_decision" opens the case |  |
| CP081 | PART G � AFTER CLOSURE | system | implied | Then the "Override" button should not be displayed |  |
| CP082 | PART G � AFTER CLOSURE | system | implied | When Sarah overrides and the reason is empty, under 50 characters or over 500 characters |  |
| CP083 | PART G � AFTER CLOSURE | system | implied | Then the override should not be saved |  |
| CP084 | PART G � AFTER CLOSURE | system | implied | When Sarah sets all 3 passengers to "Not Eligible" with a valid reason and confirms |  |
| CP085 | PART G � AFTER CLOSURE | system | implied | Then each passenger should show agent decision "Not Eligible" with amount 0 and no payout method |  |
| CP086 | PART G � AFTER CLOSURE | system | implied | And each passenger should keep the original "Recommended: Eligible � CAD 700" as read-only |  |
| CP087 | PART G � AFTER CLOSURE | system | implied | And suggested value, approved value and difference should be stored per passenger and for the case total |  |
| CP088 | PART G � AFTER CLOSURE | system | implied | And the Audit Log should record, for each passenger, agent ID, timestamp, before/after values and reason |  |
| CP089 | PART G � AFTER CLOSURE | system | implied | And the flight code should still be 96 (not edited) |  |
| CP090 | PART G � AFTER CLOSURE | system | implied | And there should be only one case for the 3 passengers and the Case ID should not change |  |
| CP091 | PART G � AFTER CLOSURE | system | implied | And the Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP092 | PART G � AFTER CLOSURE | system | implied | And the Claimant should be "Catherine Bouchard", Adult, Authentication "Pass" |  |
| CP093 | PART G � AFTER CLOSURE | system | implied | And the PNR should be "OV003" with Creation Date, Journey ID, Booking Source and Office ID populated |  |
| CP094 | PART G � AFTER CLOSURE | verdict | api | And the Regime should be "APPR" | APPR |
| CP095 | PART G � AFTER CLOSURE | system | implied | And the passengers should be listed as Catherine Bouchard (Adult, Claimant, Aeroplan 9876543210, Basic / Member), Alexandre Bouchard (Adult) |  |
| CP096 | PART G � AFTER CLOSURE | system | implied | And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 96) |  |
| CP097 | PART G � AFTER CLOSURE | system | implied | And the Eligibility and Compensation section should show "Not Eligible (Agent Override)" for each passenger and total CAD 0 |  |
| CP098 | PART G � AFTER CLOSURE | system | implied | And the Duplicate Check should show "No duplicate found" (the prior payments are outside the Claims Dashboard) |  |
| CP099 | PART G � AFTER CLOSURE | system | implied | And CyberSource should be "GREEN" |  |
| CP100 | PART G � AFTER CLOSURE | system | implied | When Sarah sends "Decision Rendered � Not Eligible" |  |
| CP101 | PART G � AFTER CLOSURE | system | implied | Then Customer Communications should show one Not Eligible notification for the case with template ID, version, language, timestamp and deliv |  |
| CP102 | PART G � AFTER CLOSURE | system | implied | And no payment link should be sent |  |
| CP103 | PART G � AFTER CLOSURE | system | implied | And the status should be "Closed � Not Eligible" |  |
| CP104 | PART G � AFTER CLOSURE | system | implied | And the case should be read-only after closure |  |
| CP105 | PART G � AFTER CLOSURE | system | implied | And the agent should not be able to access Case Search as it is for leads and management only | Payment Validation Gherkin: |
| CP106 | PART G � AFTER CLOSURE | verdict | api | Given the DDS recommendation was Eligible (CAD 700 per passenger, CAD 2,100 total) and the agent overrode all 3 passengers to Not Eligible |  |
| CP107 | PART G � AFTER CLOSURE | system | implied | Then no Cash or AC Wallet option should be offered |  |
| CP108 | PART G � AFTER CLOSURE | system | implied | And no country of residence, Interac email, bank or card details should be collected |  |
| CP109 | PART G � AFTER CLOSURE | idv | chat | And Persona IDV for payout should not be triggered |  |
| CP110 | PART G � AFTER CLOSURE | system | implied | And no payment record should be created for any of the 3 passengers |  |
| CP111 | PART G � AFTER CLOSURE | system | implied | And nothing should be picked up by the evening batch file |  |
| CP112 | PART G � AFTER CLOSURE | system | implied | And nothing should be sent to Unifier or EIP |  |
| CP113 | PART G � AFTER CLOSURE | system | implied | And the Compensation tab should show no payout for any passenger and a case total of CAD 0 |  |
| CP114 | PART G � AFTER CLOSURE | system | implied | And none of the prior payments (LEG-APPR-55831 / 55832 / 55833) should be paid again |  |
| CP115 | EXPECTED RESULTS | verdict | api | DDS FD-APPR-EL-02, Eligible, CAD 700 per passenger (CAD 2,100 total). | DDS FD-APPR-EL-02, Eligible, CAD 700 per passenger (CAD 2,100 total). |
| CP116 | EXPECTED RESULTS | verdict | chat | An authorized agent overrides all 3 passengers to Not Eligible with a required 50 to 500-character reason. | An authorized agent overrides all 3 passengers to Not Eligible with a required 50 to 500-character reason. |
| CP117 | EXPECTED RESULTS | verdict | chat | The original recommendation is kept read-only per passenger. | The original recommendation is kept read-only per passenger. |
| CP118 | EXPECTED RESULTS | verdict | chat | Suggested vs approved values and differences are stored per passenger and for the case total (?CAD 2,100), and each override is audited. | Suggested vs approved values and differences are stored per passenger and for the case total (?CAD 2,100), and each override is audited. |
| CP119 | EXPECTED RESULTS | verdict | chat | Users without permission can't override, and invalid reasons are blocked. | Users without permission can't override, and invalid reasons are blocked. |
| CP120 | EXPECTED RESULTS | verdict | chat | One "Decision Rendered � Not Eligible" notice is sent for the case with no payment link. | One "Decision Rendered � Not Eligible" notice is sent for the case with no payment link. |
| CP121 | EXPECTED RESULTS | verdict | chat | The single case closes as Closed � Not Eligible with no payment records. | The single case closes as Closed � Not Eligible with no payment records. |
