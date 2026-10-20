# FD_TC_229 · CHAI-31626 — checkpoints

**Goal:** Checks that a parked eligible case stays with its owner when the customer replies while that agent is signed out. Flight AC 412 YUL ? YYZ arrived 7 hours late (Code 96, Controllable). DDS returns FD-APPR-EL-02, CAD 700. The customer leaves the chat before payment. Agent Sarah Martin sends "Action Required" with the secure payment link and parks the case. On day 9 Sarah signs out at the end of her shift. Her profile is NOT set to On Leave. That evening the customer replies within the 30-day window. The system must move the case to "Update Pending Action" in Sarah's Assigned Cases list with the "?? UPDATE RECEIVED" tag. It must NOT send the case to "To Be Assigned" or let another agent pull it. When Sarah logs back in the next morning she opens the case (In Progress) and the customer completes payout. The customer lives in Canada and picks Cash, so payment goes by Interac and only the email is collected.

Methods: seed 16, chat 14, api 10, email 1, implied 88, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Checks that a parked eligible case stays with its owner when the customer replies while that agent is signed out. Flight AC 412 YUL ? YYZ ar |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: PK005 � single passenger �milie Pelletier (Adult, Basic Aeroplan 9876543210, good standing) | PNR: PK005 � single passenger �milie Pelletier (Adult, Basic Aeroplan 9876543210, good standing) |
| CP003 | PREREQUISITES | prerequisite | seed | AC 412 YUL ? YYZ, July 20, 2026 | AC 412 YUL ? YYZ, July 20, 2026 |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival 12:00, actual 19:00 (7h delay) | Scheduled arrival 12:00, actual 19:00 (7h delay) |
| CP005 | PREREQUISITES | prerequisite | seed | Code 96 (Operations Control � Controllable) | Code 96 (Operations Control � Controllable) |
| CP006 | PREREQUISITES | prerequisite | seed | Travelled, arrived late | Travelled, arrived late |
| CP007 | PREREQUISITES | prerequisite | seed | No VOL/INVOL changes | No VOL/INVOL changes |
| CP008 | PREREQUISITES | prerequisite | seed | AC only | AC only |
| CP009 | PREREQUISITES | prerequisite | seed | Claim filed Jul 28, 2026 | Claim filed Jul 28, 2026 |
| CP010 | PREREQUISITES | prerequisite | seed | No duplicate | No duplicate |
| CP011 | PREREQUISITES | prerequisite | implied | CyberSource GREEN | CyberSource GREEN |
| CP012 | PREREQUISITES | prerequisite | seed | Country of residence: Canada | Country of residence: Canada |
| CP013 | PREREQUISITES | prerequisite | seed | Owner agent: Sarah Martin (CR agent, active profile, NOT On Leave) | Owner agent: Sarah Martin (CR agent, active profile, NOT On Leave) |
| CP014 | PREREQUISITES | prerequisite | seed | Second agent: Marc Dubois (Available, same queue) | Second agent: Marc Dubois (Available, same queue) |
| CP015 | PREREQUISITES | prerequisite | seed | Park date: Aug 1, 2026 | Park date: Aug 1, 2026 |
| CP016 | PREREQUISITES | prerequisite | seed | Sarah signs out: Aug 10, 18:00 | Sarah signs out: Aug 10, 18:00 |
| CP017 | PREREQUISITES | prerequisite | seed | Customer reply: Aug 10, 21:00 (day 9, within 30 days) | Customer reply: Aug 10, 21:00 (day 9, within 30 days) |
| CP018 | PREREQUISITES | prerequisite | seed | Sarah signs in: Aug 11, 09:00 | Sarah signs in: Aug 11, 09:00 |
| CP019 | PART A � INITIAL CLAIM | customer | chat | Given the user opens the agentic chatbot |  |
| CP020 | PART A � INITIAL CLAIM | customer | chat | Then the chatbot displays greeting (GLOB-01) and the user selects "English" | English |
| CP021 | PART A � INITIAL CLAIM | alert | chat | Then the privacy alert is displayed |  |
| CP022 | PART A � INITIAL CLAIM | customer | chat | And the user says "My flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if I'm eligible for compensation" | My flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if I'm eligible for compensation |
| CP023 | PART A � INITIAL CLAIM | system | implied | When the chatbot identifies flight disruption intent |  |
| CP024 | PART A � INITIAL CLAIM | system | implied | Then third-party check ? NO, and the legal disclaimer is shown and accepted | IDENTIFICATION (GenUC-01): "�milie Pelletier" + PNR "PK005" ? Trip Tracer PNR FOUND (Auth Flow 1) AUTHENTICATION (GenUC-05): Email e***@gmail.com ? OTP "735102" |
| CP025 | TRIP TRACER UI VALIDATION (PK005) | verdict | api | Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M | Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M |
| CP026 | TRIP TRACER UI VALIDATION (PK005) | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP027 | TRIP TRACER UI VALIDATION (PK005) | verdict | api | MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE | MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE |
| CP028 | TRIP TRACER UI VALIDATION (PK005) | verdict | api | MS �MILIE PELLETIER / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet | MS �MILIE PELLETIER / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet |
| CP029 | TRIP TRACER UI VALIDATION (PK005) | verdict | api | CYBERSOURCE (GLOB-05): GREEN | CYBERSOURCE (GLOB-05): GREEN |
| CP030 | TRIP TRACER UI VALIDATION (PK005) | verdict | api | ELIGIBLE RESULT (FD-05a): APPR eligible message for AC 412 | ELIGIBLE RESULT (FD-05a): APPR eligible message for AC 412 |
| CP031 | TRIP TRACER UI VALIDATION (PK005) | verdict | api | CUSTOMER DROPS OFF: closes the chat at "In which country will your reimbursement be deposited?" | CUSTOMER DROPS OFF: closes the chat at "In which country will your reimbursement be deposited?" |
| CP032 | TRIP TRACER UI VALIDATION (PK005) | verdict | api | Then the case is created as ELIGIBLE, CAD 700, with no payment instruction, and is routed to the queue |  |
| CP033 | PART B � AGENT PARKS THE CASE | system | implied | Given Sarah Martin clicks "Get Next Case" ? status Assigned |  |
| CP034 | PART B � AGENT PARKS THE CASE | system | implied | And she opens the case within 10 minutes ? status In Progress |  |
| CP035 | PART B � AGENT PARKS THE CASE | system | implied | When she confirms Decision Assist (ELIGIBLE, FD-APPR-EL-02, CAD 700) |  |
| CP036 | PART B � AGENT PARKS THE CASE | system | implied | And sends "Decision Rendered � Action Required to Accept Compensation" with the secure link to e***@gmail.com |  |
| CP037 | PART B � AGENT PARKS THE CASE | system | implied | And selects "Park Case" in the Case Actions panel |  |
| CP038 | PART B � AGENT PARKS THE CASE | system | implied | Then the status becomes "Parked" (Awaiting Customer Info � Compensation) |  |
| CP039 | PART B � AGENT PARKS THE CASE | system | implied | And the case appears in Sarah's Incomplete / Parked Cases widget |  |
| CP040 | PART B � AGENT PARKS THE CASE | system | implied | And Sarah's active case slot is freed |  |
| CP041 | PART B � AGENT PARKS THE CASE | system | implied | And the assigned agent stays Sarah Martin |  |
| CP042 | PART C � AGENT GOES OFFLINE, NOT ON LEAVE | system | implied | Given Sarah has no case in Assigned or In Progress |  |
| CP043 | PART C � AGENT GOES OFFLINE, NOT ON LEAVE | system | implied | When Sarah clicks "Sign Out" |  |
| CP044 | PART C � AGENT GOES OFFLINE, NOT ON LEAVE | system | implied | Then her session ends and she shows as offline |  |
| CP045 | PART C � AGENT GOES OFFLINE, NOT ON LEAVE | system | implied | And her profile is NOT set to On Leave |  |
| CP046 | PART C � AGENT GOES OFFLINE, NOT ON LEAVE | system | implied | And the case PK005 stays in her Parked list |  |
| CP047 | PART C � AGENT GOES OFFLINE, NOT ON LEAVE | system | implied | And the case status stays "Parked" |  |
| CP048 | PART C � AGENT GOES OFFLINE, NOT ON LEAVE | system | implied | And the assigned agent stays Sarah Martin |  |
| CP049 | PART C � AGENT GOES OFFLINE, NOT ON LEAVE | system | implied | And the case is NOT moved to "To Be Assigned" |  |
| CP050 | PART D � CUSTOMER REPLIES WHILE AGENT IS OFFLINE | system | implied | Given Sarah is still signed out |  |
| CP051 | PART D � CUSTOMER REPLIES WHILE AGENT IS OFFLINE | system | implied | When the customer replies to the Action Required email: "Hi, I'd like to receive my compensation, what do I need to do next?" |  |
| CP052 | PART D � CUSTOMER REPLIES WHILE AGENT IS OFFLINE | system | implied | Then the system changes the status to "Update Pending Action" straight away |  |
| CP053 | PART D � CUSTOMER REPLIES WHILE AGENT IS OFFLINE | system | implied | And the case moves out of Sarah's Parked list into her Assigned Cases list |  |
| CP054 | PART D � CUSTOMER REPLIES WHILE AGENT IS OFFLINE | system | implied | And the case shows the "?? UPDATE RECEIVED" tag |  |
| CP055 | PART D � CUSTOMER REPLIES WHILE AGENT IS OFFLINE | system | implied | And the assigned agent stays Sarah Martin |  |
| CP056 | PART D � CUSTOMER REPLIES WHILE AGENT IS OFFLINE | system | implied | And the case does NOT go to "To Be Assigned" or the global backlog |  |
| CP057 | PART D � CUSTOMER REPLIES WHILE AGENT IS OFFLINE | system | implied | And the case status is NOT "Held - Agent Offline" (that status is only for a disconnect with a saved draft) |  |
| CP058 | PART D � CUSTOMER REPLIES WHILE AGENT IS OFFLINE | system | implied | And the case is NOT closed, NOT made an appeal, and no new case is created |  |
| CP059 | PART D � CUSTOMER REPLIES WHILE AGENT IS OFFLINE | system | implied | And the reply is saved in Customer Communications |  |
| CP060 | PART D � CUSTOMER REPLIES WHILE AGENT IS OFFLINE | system | implied | And the Audit Log records: customer reply received, Parked ? Update Pending Action (system), owner unchanged |  |
| CP061 | PART E � OTHER AGENT CANNOT TAKE THE CASE | system | implied | Given Marc Dubois is Available in the same queue |  |
| CP062 | PART E � OTHER AGENT CANNOT TAKE THE CASE | system | implied | When Marc clicks "Get Next Case" |  |
| CP063 | PART E � OTHER AGENT CANNOT TAKE THE CASE | system | implied | Then PK005 is NOT given to Marc |  |
| CP064 | PART E � OTHER AGENT CANNOT TAKE THE CASE | system | implied | And PK005 does not appear in the unassigned queue |  |
| CP065 | PART F � TIMERS DO NOT RELEASE THE CASE | system | implied | Given the case is "Update Pending Action" and Sarah is still signed out |  |
| CP066 | PART F � TIMERS DO NOT RELEASE THE CASE | system | implied | When 10 minutes pass |  |
| CP067 | PART F � TIMERS DO NOT RELEASE THE CASE | system | implied | Then the 10-minute "Assigned" timeout does NOT return the case to "To Be Assigned" |  |
| CP068 | PART F � TIMERS DO NOT RELEASE THE CASE | system | implied | When 12 hours pass overnight |  |
| CP069 | PART F � TIMERS DO NOT RELEASE THE CASE | system | implied | Then the case is still "Update Pending Action" with Sarah |  |
| CP070 | PART G � AGENT LOGS BACK IN AND HANDLES IT | system | implied | Given Sarah signs in and sets herself Available |  |
| CP071 | PART G � AGENT LOGS BACK IN AND HANDLES IT | system | implied | Then PK005 is at the top of her Assigned Cases list with "?? UPDATE RECEIVED" |  |
| CP072 | PART G � AGENT LOGS BACK IN AND HANDLES IT | system | implied | And this case does not count against her "one new case at a time" limit |  |
| CP073 | PART G � AGENT LOGS BACK IN AND HANDLES IT | system | implied | When Sarah clicks the case row |  |
| CP074 | PART G � AGENT LOGS BACK IN AND HANDLES IT | system | implied | Then the status changes to "In Progress" |  |
| CP075 | PART G � AGENT LOGS BACK IN AND HANDLES IT | system | implied | And she sees the customer's reply |  |
| CP076 | PART G � AGENT LOGS BACK IN AND HANDLES IT | system | implied | And she confirms the decision is unchanged (ELIGIBLE, CAD 700, no override) |  |
| CP077 | PART G � AGENT LOGS BACK IN AND HANDLES IT | system | implied | And she replies with the next step (use the secure link) and adds an internal note: customer replied while agent was offline, case kept with |  |
| CP078 | PART H � CUSTOMER COMPLETES PAYOUT | customer | chat | Given the customer opens the secure link |  |
| CP079 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | Then country = Canada ? CAD |  |
| CP080 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And Basic Aeroplan is found ? both options offered: Cash CAD 700 (Interac, 5 to 10 business days) or AC Wallet CAD 840 (20% bonus) |  |
| CP081 | PART H � CUSTOMER COMPLETES PAYOUT | customer | chat | And the customer selects "Cash" | Cash |
| CP082 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And only the Interac email e***@gmail.com is confirmed |  |
| CP083 | PART H � CUSTOMER COMPLETES PAYOUT | idv | chat | And Persona IDV ? PASS |  |
| CP084 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the claim is submitted ? one CAD 700 compensation record is created |  |
| CP085 | PART H � CUSTOMER COMPLETES PAYOUT | email | email | And the eligible notification email is sent via Adobe (Case Reference, CAD 700, Interac, APPR, AC 412, Code 96) | Claims Dashboard Gherkin: |
| CP086 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | Given case "PK005" for claimant "�milie Pelletier" is "Parked" and owned by agent "Sarah Martin" |  |
| CP087 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And Sarah has signed out and her profile is NOT "On Leave" |  |
| CP088 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | When the customer replies on Aug 10, 2026 at 21:00 |  |
| CP089 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | Then the case status should change to "Update Pending Action" |  |
| CP090 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the case should move from Sarah's "Incomplete / Parked Cases" to her "Assigned Cases" list |  |
| CP091 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the "?? UPDATE RECEIVED" tag should be displayed |  |
| CP092 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the assigned agent should remain "Sarah Martin" |  |
| CP093 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the case should NOT be in "To Be Assigned" |  |
| CP094 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the case should NOT be "Held - Agent Offline" |  |
| CP095 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And another Available agent should NOT be able to pull the case |  |
| CP096 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And no "Appeal Pending" or "Case Closed" banner should be shown |  |
| CP097 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the Case ID should not change |  |
| CP098 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | When Sarah signs in and clicks the case |  |
| CP099 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | Then the status should change to "In Progress" |  |
| CP100 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP101 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the Claimant should be "�milie Pelletier", Adult, Authentication "Pass" |  |
| CP102 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the PNR should be "PK005" with Creation Date, Journey ID, Booking Source and Office ID populated |  |
| CP103 | PART H � CUSTOMER COMPLETES PAYOUT | verdict | api | And the Regime should be "APPR" | APPR |
| CP104 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the Aeroplan should be "9876543210", Tier "Basic / Member" |  |
| CP105 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 96) |  |
| CP106 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And Decision Assist should show ELIGIBLE, FD-APPR-EL-02, CAD 700 |  |
| CP107 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the Duplicate Check should show "No duplicate found" |  |
| CP108 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And CyberSource should be "GREEN" |  |
| CP109 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the Audit Log should record in order: created, Assigned, In Progress, Action Required sent, Parked, agent signed out, customer reply, Up |  |
| CP110 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the case history and notes should be kept |  |
| CP111 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the Final Status should be "Resolved" and read-only | Payment Validation Gherkin: |
| CP112 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | Given the case is ELIGIBLE, CAD 700 and was kept with the same agent |  |
| CP113 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | Then no compensation record should exist before the customer completes the secure link |  |
| CP114 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | When the customer completes the secure link |  |
| CP115 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | Then country should be "Canada" and currency "CAD" |  |
| CP116 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And both Cash (CAD 700) and AC Wallet (CAD 840) should be offered |  |
| CP117 | PART H � CUSTOMER COMPLETES PAYOUT | customer | chat | And the customer selects "Cash" ? Interac e-Transfer | Cash |
| CP118 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And only the email "e***@gmail.com" should be collected |  |
| CP119 | PART H � CUSTOMER COMPLETES PAYOUT | idv | chat | And Persona IDV should PASS |  |
| CP120 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And exactly one CAD 700 compensation record should be created |  |
| CP121 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And it should be picked up by the evening batch and sent to Unifier (manual trigger in UAT) |  |
| CP122 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And Unifier should acknowledge |  |
| CP123 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And Interac status should move Pending ? Cached / Rejected / Expired, with Expired after 35 days unclaimed |  |
| CP124 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the Compensation tab should show CAD 700, Cash � Interac, status via talkback |  |
| CP125 | EXPECTED RESULTS | verdict | api | DDS FD-APPR-EL-02, CAD 700. | DDS FD-APPR-EL-02, CAD 700. |
| CP126 | EXPECTED RESULTS | verdict | chat | The customer replies while the owner agent is signed out (not On Leave). | The customer replies while the owner agent is signed out (not On Leave). |
| CP127 | EXPECTED RESULTS | verdict | chat | The case moves to "Update Pending Action" with "?? UPDATE RECEIVED" in the same agent's Assigned Cases list. | The case moves to "Update Pending Action" with "?? UPDATE RECEIVED" in the same agent's Assigned Cases list. |
| CP128 | EXPECTED RESULTS | verdict | chat | It does not go to the global queue, cannot be pulled by another agent and is not released by timers. | It does not go to the global queue, cannot be pulled by another agent and is not released by timers. |
| CP129 | EXPECTED RESULTS | verdict | chat | When the agent logs back in and clicks it, it becomes In Progress. | When the agent logs back in and clicks it, it becomes In Progress. |
| CP130 | EXPECTED RESULTS | verdict | chat | The customer is paid CAD 700 Cash via Interac (email only), with one compensation record. | The customer is paid CAD 700 Cash via Interac (email only), with one compensation record. |
