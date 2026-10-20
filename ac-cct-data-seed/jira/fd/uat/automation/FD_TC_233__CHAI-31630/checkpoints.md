# FD_TC_233 · CHAI-31630 — checkpoints

**Goal:** Checks the park cycle for internal resourcing. Flight AC 412 YUL ? YYZ arrived 7 hours late. Trip Tracer shows Code 96 (Controllable), and DDS returns FD-APPR-EL-02, CAD 700. In the chat, the customer said the gate agent blamed the weather. The customer leaves the chat before payment. Agent Sarah Martin doesn't want to pay out while the coding is in doubt, and she can't change the code herself. She chooses New Resourcing and asks the lead pool to confirm the code. A lead task is created, the case parks and the "Case Escalated" alert is shown. Lead Nadia Bouchard checks and confirms Code 96, then submits her resourcing notes. The case changes to "Update Pending Action" and appears in Sarah's Assigned Cases list with "?? UPDATE RECEIVED". It does not go to To Be Assigned and no other agent can take it. Sarah opens it (In Progress), keeps the decision and sends "Decision Rendered � Action Required" with the deep link. The customer lives in Canada and picks Cash, so payment goes by Interac and only the email is collected. The customer isn't contacted while the case is parked.

Methods: seed 16, chat 16, api 12, email 4, implied 89, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Checks the park cycle for internal resourcing. Flight AC 412 YUL ? YYZ arrived 7 hours late. Trip Tracer shows Code 96 (Controllable), and D |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: PK001 � single passenger Nicolas Fortier (Adult, Basic Aeroplan 9876543210, good standing) | PNR: PK001 � single passenger Nicolas Fortier (Adult, Basic Aeroplan 9876543210, good standing) |
| CP003 | PREREQUISITES | prerequisite | seed | AC 412 YUL ? YYZ, July 20, 2026 | AC 412 YUL ? YYZ, July 20, 2026 |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival 12:00, actual 19:00 (7h delay) | Scheduled arrival 12:00, actual 19:00 (7h delay) |
| CP005 | PREREQUISITES | prerequisite | seed | Code 96 (Operations Control � Controllable) | Code 96 (Operations Control � Controllable) |
| CP006 | PREREQUISITES | prerequisite | seed | Travelled, arrived late | Travelled, arrived late |
| CP007 | PREREQUISITES | prerequisite | seed | No VOL/INVOL changes | No VOL/INVOL changes |
| CP008 | PREREQUISITES | prerequisite | seed | AC only | AC only |
| CP009 | PREREQUISITES | prerequisite | seed | Claim filed Jul 28, 2026 | Claim filed Jul 28, 2026 |
| CP010 | PREREQUISITES | prerequisite | seed | Case reference: CASE-FD-20260728-001 | Case reference: CASE-FD-20260728-001 |
| CP011 | PREREQUISITES | prerequisite | seed | No duplicate | No duplicate |
| CP012 | PREREQUISITES | prerequisite | implied | CyberSource GREEN | CyberSource GREEN |
| CP013 | PREREQUISITES | prerequisite | seed | Country of residence: Canada | Country of residence: Canada |
| CP014 | PREREQUISITES | prerequisite | seed | Owner agent: Sarah Martin (Agent role, Available) | Owner agent: Sarah Martin (Agent role, Available) |
| CP015 | PREREQUISITES | prerequisite | seed | Lead: Nadia Bouchard (Lead role, in the lead pool) | Lead: Nadia Bouchard (Lead role, in the lead pool) |
| CP016 | PREREQUISITES | prerequisite | seed | Second agent: Marc Dubois (Available) | Second agent: Marc Dubois (Available) |
| CP017 | PREREQUISITES | prerequisite | seed | Resourcing sent: Aug 1, 10:00 | Resourcing sent: Aug 1, 10:00 |
| CP018 | PREREQUISITES | prerequisite | seed | Lead replies: Aug 3, 14:00 | Lead replies: Aug 3, 14:00 |
| CP019 | PART A � INITIAL CLAIM | customer | chat | Given the user opens the agentic chatbot |  |
| CP020 | PART A � INITIAL CLAIM | customer | chat | Then the chatbot displays greeting (GLOB-01) and the user selects "English" | English |
| CP021 | PART A � INITIAL CLAIM | alert | chat | Then the privacy alert is displayed |  |
| CP022 | PART A � INITIAL CLAIM | customer | chat | And the user says "My flight from Montreal to Toronto was delayed about 7 hours, the gate agent said it was the weather. I'd like to check i | My flight from Montreal to Toronto was delayed about 7 hours, the gate agent said it was the weather. I'd like to check if I'm eligible for compensation |
| CP023 | PART A � INITIAL CLAIM | system | implied | When the chatbot identifies flight disruption intent |  |
| CP024 | PART A � INITIAL CLAIM | system | implied | Then third-party check ? NO, and the legal disclaimer is shown and accepted | IDENTIFICATION (GenUC-01): "Nicolas Fortier" + PNR "PK001" ? Trip Tracer PNR FOUND (Auth Flow 1) AUTHENTICATION (GenUC-05): Email n***@gmail.com ? OTP "164930"  |
| CP025 | TRIP TRACER UI VALIDATION (PK001) | verdict | api | Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M | Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M |
| CP026 | TRIP TRACER UI VALIDATION (PK001) | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP027 | TRIP TRACER UI VALIDATION (PK001) | verdict | api | MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE | MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE |
| CP028 | TRIP TRACER UI VALIDATION (PK001) | verdict | api | MR NICOLAS FORTIER / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet | MR NICOLAS FORTIER / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet |
| CP029 | TRIP TRACER UI VALIDATION (PK001) | verdict | api | CYBERSOURCE (GLOB-05): GREEN | CYBERSOURCE (GLOB-05): GREEN |
| CP030 | TRIP TRACER UI VALIDATION (PK001) | verdict | api | CUSTOMER DROPS OFF: closes the chat at "In which country will your reimbursement be deposited?" | CUSTOMER DROPS OFF: closes the chat at "In which country will your reimbursement be deposited?" |
| CP031 | TRIP TRACER UI VALIDATION (PK001) | verdict | api | Then the case is created as ELIGIBLE, CAD 700, with no payment instruction, and the transcript is linked |  |
| CP032 | PART B � AGENT PICKS UP AND FINDS THE CODING QUESTION | system | implied | Given Sarah Martin is Available and clicks "Get Next Case" ? Assigned |  |
| CP033 | PART B � AGENT PICKS UP AND FINDS THE CODING QUESTION | system | implied | And she opens it within 10 minutes ? In Progress |  |
| CP034 | PART B � AGENT PICKS UP AND FINDS THE CODING QUESTION | system | implied | When she reads the transcript ("the gate agent said it was the weather") |  |
| CP035 | PART B � AGENT PICKS UP AND FINDS THE CODING QUESTION | verdict | api | And sees that Trip Tracer shows Code 96 Controllable |  |
| CP036 | PART B � AGENT PICKS UP AND FINDS THE CODING QUESTION | system | implied | Then she does NOT change the flight code or override Decision Assist |  |
| CP037 | PART C � AGENT SENDS NEW RESOURCING AND THE CASE PARKS | system | implied | When Sarah selects "New Resourcing" in the Case Actions panel (kebab menu) |  |
| CP038 | PART C � AGENT SENDS NEW RESOURCING AND THE CASE PARKS | verdict | api | And sends it to the lead pool with the note: "Customer states weather; Trip Tracer shows Code 96 Operations Control on AC 412 YUL-YYZ Jul 20 | Customer states weather; Trip Tracer shows Code 96 Operations Control on AC 412 YUL-YYZ Jul 20. Please confirm coding before payout. |
| CP039 | PART C � AGENT SENDS NEW RESOURCING AND THE CASE PARKS | system | implied | Then a resourcing task is created in the lead / manager pool, linked to the case |  |
| CP040 | PART C � AGENT SENDS NEW RESOURCING AND THE CASE PARKS | system | implied | And the case status changes to "Parked" |  |
| CP041 | PART C � AGENT SENDS NEW RESOURCING AND THE CASE PARKS | system | implied | And the blue "Case Escalated" alert is shown with context and timestamp |  |
| CP042 | PART C � AGENT SENDS NEW RESOURCING AND THE CASE PARKS | system | implied | And the case appears in Sarah's Incomplete / Parked Cases widget |  |
| CP043 | PART C � AGENT SENDS NEW RESOURCING AND THE CASE PARKS | system | implied | And Sarah's active slot is freed and she can pull a new case |  |
| CP044 | PART C � AGENT SENDS NEW RESOURCING AND THE CASE PARKS | system | implied | And the assigned agent stays Sarah Martin |  |
| CP045 | PART C � AGENT SENDS NEW RESOURCING AND THE CASE PARKS | email | email | And no customer notification is sent |  |
| CP046 | PART C � AGENT SENDS NEW RESOURCING AND THE CASE PARKS | system | implied | And the Audit Log records: New Resourcing, target (lead pool), note, In Progress ? Parked, actor and timestamp |  |
| CP047 | PART D � CASE STAYS SAFE WHILE PARKED | system | implied | Given the case is Parked for resourcing |  |
| CP048 | PART D � CASE STAYS SAFE WHILE PARKED | system | implied | Then the 10-minute Assigned timeout and the 24-hour In Progress release do NOT apply |  |
| CP049 | PART D � CASE STAYS SAFE WHILE PARKED | system | implied | And the case does NOT appear in To Be Assigned |  |
| CP050 | PART D � CASE STAYS SAFE WHILE PARKED | system | implied | When Marc Dubois clicks "Get Next Case" |  |
| CP051 | PART D � CASE STAYS SAFE WHILE PARKED | system | implied | Then PK001 is NOT given to him |  |
| CP052 | PART D � CASE STAYS SAFE WHILE PARKED | system | implied | When Sarah switches to "Break / Lunch" and back to Available |  |
| CP053 | PART D � CASE STAYS SAFE WHILE PARKED | system | implied | Then the case stays Parked with her |  |
| CP054 | PART E � LEAD REVIEWS AND REPLIES | system | implied | Given Nadia Bouchard opens the resourcing task from the lead pool |  |
| CP055 | PART E � LEAD REVIEWS AND REPLIES | verdict | api | Then she can see the case context, Sarah's note, the transcript and Trip Tracer |  |
| CP056 | PART E � LEAD REVIEWS AND REPLIES | system | implied | When she confirms that Code 96 (Operations Control) is correct and there was no weather code on AC 412 |  |
| CP057 | PART E � LEAD REVIEWS AND REPLIES | system | implied | And she enters the resourcing notes: "Coding confirmed Code 96 Operations Control, controllable. Proceed with APPR payout." |  |
| CP058 | PART E � LEAD REVIEWS AND REPLIES | system | implied | And she clicks Submit (return to agent with guidance) |  |
| CP059 | PART E � LEAD REVIEWS AND REPLIES | system | implied | Then the resourcing task is marked complete |  |
| CP060 | PART E � LEAD REVIEWS AND REPLIES | system | implied | And the case ownership stays with Sarah (Nadia does not take ownership) |  |
| CP061 | PART F � CASE RETURNS TO THE SAME AGENT | system | implied | Then the case status changes Parked ? "Update Pending Action" straight away |  |
| CP062 | PART F � CASE RETURNS TO THE SAME AGENT | system | implied | And the case leaves Sarah's Parked widget and appears in her Assigned Cases list |  |
| CP063 | PART F � CASE RETURNS TO THE SAME AGENT | system | implied | And the case shows "?? UPDATE RECEIVED" |  |
| CP064 | PART F � CASE RETURNS TO THE SAME AGENT | system | implied | And it does not count against her one-new-case limit |  |
| CP065 | PART F � CASE RETURNS TO THE SAME AGENT | system | implied | And the assigned agent is still Sarah Martin |  |
| CP066 | PART F � CASE RETURNS TO THE SAME AGENT | system | implied | And the case does NOT go to To Be Assigned and Marc still can't pull it |  |
| CP067 | PART F � CASE RETURNS TO THE SAME AGENT | system | implied | And the "Case Escalated" alert is cleared or shows as resolved |  |
| CP068 | PART F � CASE RETURNS TO THE SAME AGENT | system | implied | And the Case ID does not change |  |
| CP069 | PART F � CASE RETURNS TO THE SAME AGENT | system | implied | And the Audit Log records: resourcing completed (by Nadia), notes, Parked ? Update Pending Action |  |
| CP070 | PART G � AGENT CONTINUES AND SENDS THE ELIGIBLE NOTICE | system | implied | When Sarah clicks the case row |  |
| CP071 | PART G � AGENT CONTINUES AND SENDS THE ELIGIBLE NOTICE | system | implied | Then the status changes to "In Progress" |  |
| CP072 | PART G � AGENT CONTINUES AND SENDS THE ELIGIBLE NOTICE | system | implied | And the lead's notes are clearly shown on the case |  |
| CP073 | PART G � AGENT CONTINUES AND SENDS THE ELIGIBLE NOTICE | system | implied | And she keeps the decision ELIGIBLE, FD-APPR-EL-02, CAD 700 (no override) |  |
| CP074 | PART G � AGENT CONTINUES AND SENDS THE ELIGIBLE NOTICE | system | implied | And she adds an internal note: coding confirmed by lead, proceeding to payout |  |
| CP075 | PART G � AGENT CONTINUES AND SENDS THE ELIGIBLE NOTICE | system | implied | When she completes the Advance Case wizard: Step 1 confirm Eligible / CAD 700; Step 2 "Decision Rendered � Action Required to Accept Compens |  |
| CP076 | PART G � AGENT CONTINUES AND SENDS THE ELIGIBLE NOTICE | email | email | Then the notification is sent to n***@gmail.com |  |
| CP077 | PART G � AGENT CONTINUES AND SENDS THE ELIGIBLE NOTICE | system | implied | And the case status becomes "Awaiting Customer Info (Compensation)" |  |
| CP078 | PART H � CUSTOMER COMPLETES PAYOUT | customer | chat | Given the customer opens the deep link |  |
| CP079 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | Then they land straight on the payment step |  |
| CP080 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And country = Canada ? CAD |  |
| CP081 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And Basic Aeroplan is found ? both options offered: Cash CAD 700 (Interac, 5 to 10 business days) or AC Wallet CAD 840 (20% bonus) |  |
| CP082 | PART H � CUSTOMER COMPLETES PAYOUT | customer | chat | And the customer selects "Cash" | Cash |
| CP083 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And only the Interac email n***@gmail.com is confirmed |  |
| CP084 | PART H � CUSTOMER COMPLETES PAYOUT | idv | chat | And Persona IDV ? PASS |  |
| CP085 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the customer submits ? one CAD 700 compensation record is created |  |
| CP086 | PART H � CUSTOMER COMPLETES PAYOUT | email | email | And the eligible notification email is sent via Adobe |  |
| CP087 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the case auto-closes when payout completes | Claims Dashboard Gherkin: |
| CP088 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | Given case "CASE-FD-20260728-001" for claimant "Nicolas Fortier" is "In Progress" with agent "Sarah Martin" |  |
| CP089 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | When Sarah selects "New Resourcing" to the lead pool with a coding question |  |
| CP090 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | Then a resourcing task should be created in the lead pool and linked to the case |  |
| CP091 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the case status should be "Parked" |  |
| CP092 | PART H � CUSTOMER COMPLETES PAYOUT | alert | chat | And the "Case Escalated" alert should be displayed with context and timestamp | Case Escalated |
| CP093 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the case should be in Sarah's "Incomplete / Parked Cases" widget |  |
| CP094 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And Sarah should be able to pull a new case |  |
| CP095 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the case should NOT be in "To Be Assigned" |  |
| CP096 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And another Available agent should NOT be able to pull the case |  |
| CP097 | PART H � CUSTOMER COMPLETES PAYOUT | email | email | And no customer notification should be sent |  |
| CP098 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | When lead "Nadia Bouchard" completes the resourcing notes and submits |  |
| CP099 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | Then the case status should change to "Update Pending Action" |  |
| CP100 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the case should appear in Sarah's "Assigned Cases" list with "?? UPDATE RECEIVED" |  |
| CP101 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the assigned agent should remain "Sarah Martin" |  |
| CP102 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the lead's notes should be visible on the case |  |
| CP103 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the Case ID should not change |  |
| CP104 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | When Sarah clicks the case |  |
| CP105 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | Then the status should change to "In Progress" |  |
| CP106 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP107 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the Claimant should be "Nicolas Fortier", Adult, Authentication "Pass" |  |
| CP108 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the PNR should be "PK001" with Creation Date, Journey ID, Booking Source and Office ID populated |  |
| CP109 | PART H � CUSTOMER COMPLETES PAYOUT | verdict | api | And the Regime should be "APPR" | APPR |
| CP110 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the Aeroplan should be "9876543210", Tier "Basic / Member" |  |
| CP111 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 96) |  |
| CP112 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the flight code should still be 96 and not edited by the agent |  |
| CP113 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And Decision Assist should show ELIGIBLE, FD-APPR-EL-02, CAD 700 and not be greyed out |  |
| CP114 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the Duplicate Check should show "No duplicate found" |  |
| CP115 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And CyberSource should be "GREEN" |  |
| CP116 | PART H � CUSTOMER COMPLETES PAYOUT | idv | chat | And the Audit Log should record in order: created, Assigned, In Progress, New Resourcing (with note), Parked, lead task opened, resourcing c |  |
| CP117 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And Customer Communications should show only the Action Required email and the eligible notification (no customer message during resourcing) |  |
| CP118 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the Final Status should be "Closed" and read-only | Payment Validation Gherkin: |
| CP119 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | Given the case was parked for internal resourcing |  |
| CP120 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | Then no compensation record should exist while the case is Parked |  |
| CP121 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | When the lead confirms the coding and Sarah sends the Action Required notice |  |
| CP122 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the customer completes the deep link |  |
| CP123 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | Then country should be "Canada" and currency "CAD" |  |
| CP124 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And both Cash (CAD 700) and AC Wallet (CAD 840) should be offered |  |
| CP125 | PART H � CUSTOMER COMPLETES PAYOUT | customer | chat | And the customer selects "Cash" ? Interac e-Transfer | Cash |
| CP126 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And only the email "n***@gmail.com" should be collected |  |
| CP127 | PART H � CUSTOMER COMPLETES PAYOUT | idv | chat | And Persona IDV should PASS |  |
| CP128 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And exactly one CAD 700 compensation record should be created |  |
| CP129 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And it should be picked up by the evening batch and sent to Unifier (manual trigger in UAT) |  |
| CP130 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And Unifier should acknowledge |  |
| CP131 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And Interac status should move Pending ? Cached / Rejected / Expired, with Expired after 35 days unclaimed |  |
| CP132 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the Compensation tab should show CAD 700, Cash � Interac, status via talkback |  |
| CP133 | EXPECTED RESULTS | verdict | api | DDS FD-APPR-EL-02, CAD 700. | DDS FD-APPR-EL-02, CAD 700. |
| CP134 | EXPECTED RESULTS | verdict | chat | The agent sends New Resourcing: a lead task is created, the case parks and "Case Escalated" is shown. | The agent sends New Resourcing: a lead task is created, the case parks and "Case Escalated" is shown. |
| CP135 | EXPECTED RESULTS | verdict | chat | The agent's slot is freed, the case stays hers and no one else can pull it. | The agent's slot is freed, the case stays hers and no one else can pull it. |
| CP136 | EXPECTED RESULTS | verdict | chat | When the lead submits resourcing notes, the case moves straight to Update Pending Action with "?? UPDATE RECEIVED" in the same agent's Assig | When the lead submits resourcing notes, the case moves straight to Update Pending Action with "?? UPDATE RECEIVED" in the same agent's Assigned Cases list. |
| CP137 | EXPECTED RESULTS | verdict | chat | The agent opens it (In Progress), keeps the decision and sends Action Required. | The agent opens it (In Progress), keeps the decision and sends Action Required. |
| CP138 | EXPECTED RESULTS | verdict | chat | The customer is paid CAD 700 Cash via Interac (email only), with one compensation record. | The customer is paid CAD 700 Cash via Interac (email only), with one compensation record. |
