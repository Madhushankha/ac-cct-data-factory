# FD_TC_230 · CHAI-31627 — checkpoints

**Goal:** Checks that a parked case isn't left with an agent who is on vacation. Flight AC 412 YUL ? YYZ arrived 7 hours late (Code 96, Controllable). DDS returns FD-APPR-EL-02, CAD 700. The customer leaves the chat before payment. Agent Sarah Martin sends "Action Required" with the secure payment link and parks the case. On Aug 12 a supervisor sets Sarah to On Leave (Aug 12 � Aug 26). The pre-leave sweep must remove Sarah's ownership right away and move the case to "To Be Assigned", keeping all history. On Aug 14 (day 13, within 30 days) the customer replies. The case is already in the queue. The next Available agent, Marc Dubois, gets it with "Get Next Case", opens it within 10 minutes (In Progress) and completes the case. The customer lives in Canada and picks Cash, so payment goes by Interac and only the email is collected. When Sarah comes back, the case must not return to her.

Methods: seed 17, chat 14, api 11, email 1, implied 92, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Checks that a parked case isn't left with an agent who is on vacation. Flight AC 412 YUL ? YYZ arrived 7 hours late (Code 96, Controllable). |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: PK004 � single passenger Mathieu Roy (Adult, Basic Aeroplan 9876543210, good standing) | PNR: PK004 � single passenger Mathieu Roy (Adult, Basic Aeroplan 9876543210, good standing) |
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
| CP013 | PREREQUISITES | prerequisite | seed | Owner agent: Sarah Martin | Owner agent: Sarah Martin |
| CP014 | PREREQUISITES | prerequisite | seed | Supervisor: Nadia Bouchard | Supervisor: Nadia Bouchard |
| CP015 | PREREQUISITES | prerequisite | seed | Next agent: Marc Dubois (Available, same queue, qualified for FD) | Next agent: Marc Dubois (Available, same queue, qualified for FD) |
| CP016 | PREREQUISITES | prerequisite | seed | Park date: Aug 1 | Park date: Aug 1 |
| CP017 | PREREQUISITES | prerequisite | seed | On Leave set: Aug 12, 09:00 (leave Aug 12 � Aug 26) | On Leave set: Aug 12, 09:00 (leave Aug 12 � Aug 26) |
| CP018 | PREREQUISITES | prerequisite | seed | Customer reply: Aug 14, 10:00 | Customer reply: Aug 14, 10:00 |
| CP019 | PREREQUISITES | prerequisite | seed | Marc pulls the case: Aug 14, 10:15 | Marc pulls the case: Aug 14, 10:15 |
| CP020 | PART A � INITIAL CLAIM | customer | chat | Given the user opens the agentic chatbot |  |
| CP021 | PART A � INITIAL CLAIM | customer | chat | Then the chatbot displays greeting (GLOB-01) and the user selects "English" | English |
| CP022 | PART A � INITIAL CLAIM | alert | chat | Then the privacy alert is displayed |  |
| CP023 | PART A � INITIAL CLAIM | customer | chat | And the user says "My flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if I'm eligible for compensation" | My flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if I'm eligible for compensation |
| CP024 | PART A � INITIAL CLAIM | system | implied | When the chatbot identifies flight disruption intent |  |
| CP025 | PART A � INITIAL CLAIM | system | implied | Then third-party check ? NO, and the legal disclaimer is shown and accepted | IDENTIFICATION (GenUC-01): "Mathieu Roy" + PNR "PK004" ? Trip Tracer PNR FOUND (Auth Flow 1) AUTHENTICATION (GenUC-05): Email m***@gmail.com ? OTP "284615" ? CO |
| CP026 | TRIP TRACER UI VALIDATION (PK004) | verdict | api | Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M | Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M |
| CP027 | TRIP TRACER UI VALIDATION (PK004) | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP028 | TRIP TRACER UI VALIDATION (PK004) | verdict | api | MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE | MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE |
| CP029 | TRIP TRACER UI VALIDATION (PK004) | verdict | api | MR MATHIEU ROY / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet | MR MATHIEU ROY / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet |
| CP030 | TRIP TRACER UI VALIDATION (PK004) | verdict | api | CYBERSOURCE (GLOB-05): GREEN | CYBERSOURCE (GLOB-05): GREEN |
| CP031 | TRIP TRACER UI VALIDATION (PK004) | verdict | api | ELIGIBLE RESULT (FD-05a): APPR eligible message for AC 412 | ELIGIBLE RESULT (FD-05a): APPR eligible message for AC 412 |
| CP032 | TRIP TRACER UI VALIDATION (PK004) | verdict | api | CUSTOMER DROPS OFF: closes the chat at "In which country will your reimbursement be deposited?" | CUSTOMER DROPS OFF: closes the chat at "In which country will your reimbursement be deposited?" |
| CP033 | TRIP TRACER UI VALIDATION (PK004) | verdict | api | Then the case is created as ELIGIBLE, CAD 700, with no payment instruction, and is routed to the queue |  |
| CP034 | PART B � OWNER AGENT PARKS THE CASE | system | implied | Given Sarah Martin clicks "Get Next Case" ? status Assigned |  |
| CP035 | PART B � OWNER AGENT PARKS THE CASE | system | implied | And she opens it within 10 minutes ? status In Progress |  |
| CP036 | PART B � OWNER AGENT PARKS THE CASE | system | implied | When she confirms Decision Assist (ELIGIBLE, FD-APPR-EL-02, CAD 700) |  |
| CP037 | PART B � OWNER AGENT PARKS THE CASE | system | implied | And sends "Decision Rendered � Action Required to Accept Compensation" with the secure link to m***@gmail.com |  |
| CP038 | PART B � OWNER AGENT PARKS THE CASE | system | implied | And adds an internal note "Awaiting customer payout action" |  |
| CP039 | PART B � OWNER AGENT PARKS THE CASE | system | implied | And selects "Park Case" in the Case Actions panel |  |
| CP040 | PART B � OWNER AGENT PARKS THE CASE | system | implied | Then the status becomes "Parked" (Awaiting Customer Info � Compensation) |  |
| CP041 | PART B � OWNER AGENT PARKS THE CASE | system | implied | And the case appears in Sarah's Incomplete / Parked Cases widget |  |
| CP042 | PART B � OWNER AGENT PARKS THE CASE | system | implied | And the assigned agent = Sarah Martin |  |
| CP043 | PART C � SUPERVISOR SETS OWNER TO ON LEAVE | system | implied | Given PK004 is Parked and owned by Sarah Martin |  |
| CP044 | PART C � SUPERVISOR SETS OWNER TO ON LEAVE | system | implied | When supervisor Nadia Bouchard sets Sarah's profile to "On Leave" with start Aug 12 and end Aug 26 |  |
| CP045 | PART C � SUPERVISOR SETS OWNER TO ON LEAVE | system | implied | Then the pre-leave sweep runs straight away |  |
| CP046 | PART C � SUPERVISOR SETS OWNER TO ON LEAVE | system | implied | And PK004 disappears from Sarah's Incomplete / Parked Cases widget |  |
| CP047 | PART C � SUPERVISOR SETS OWNER TO ON LEAVE | system | implied | And Sarah's ownership is removed (assigned agent = blank) |  |
| CP048 | PART C � SUPERVISOR SETS OWNER TO ON LEAVE | system | implied | And the case status changes to "To Be Assigned" |  |
| CP049 | PART C � SUPERVISOR SETS OWNER TO ON LEAVE | system | implied | And the case shows in the global backlog |  |
| CP050 | PART C � SUPERVISOR SETS OWNER TO ON LEAVE | system | implied | And the original creation date (Jul 28), the Action Required email, Sarah's internal note and all audit entries are kept |  |
| CP051 | PART C � SUPERVISOR SETS OWNER TO ON LEAVE | system | implied | And Decision Assist still shows ELIGIBLE, FD-APPR-EL-02, CAD 700 |  |
| CP052 | PART C � SUPERVISOR SETS OWNER TO ON LEAVE | system | implied | And the secure payment link stays valid (within 30 days) |  |
| CP053 | PART C � SUPERVISOR SETS OWNER TO ON LEAVE | system | implied | And the Audit Log records: agent set On Leave (by Nadia), ownership removed (system sweep), Parked ? To Be Assigned |  |
| CP054 | PART D � CUSTOMER REPLIES WHILE OWNER IS ON LEAVE | system | implied | Given PK004 is "To Be Assigned" with no owner |  |
| CP055 | PART D � CUSTOMER REPLIES WHILE OWNER IS ON LEAVE | system | implied | When the customer replies to the Action Required email: "Hi, I'd like to receive my compensation, what do I need to do next?" |  |
| CP056 | PART D � CUSTOMER REPLIES WHILE OWNER IS ON LEAVE | system | implied | Then the reply is saved in Customer Communications |  |
| CP057 | PART D � CUSTOMER REPLIES WHILE OWNER IS ON LEAVE | system | implied | And the case stays in the global backlog, ready for the next available agent |  |
| CP058 | PART D � CUSTOMER REPLIES WHILE OWNER IS ON LEAVE | system | implied | And the case is NOT sent to Sarah's workspace |  |
| CP059 | PART D � CUSTOMER REPLIES WHILE OWNER IS ON LEAVE | system | implied | And no "?? UPDATE RECEIVED" item appears for Sarah |  |
| CP060 | PART D � CUSTOMER REPLIES WHILE OWNER IS ON LEAVE | system | implied | And the case is NOT closed, NOT made an appeal, and no new case is created |  |
| CP061 | PART D � CUSTOMER REPLIES WHILE OWNER IS ON LEAVE | system | implied | And the Audit Log records: customer reply received (case unassigned, owner on leave) |  |
| CP062 | PART E � AWAY AGENT CANNOT PULL | system | implied | Given Julie Tremblay's status is "Break / Lunch" |  |
| CP063 | PART E � AWAY AGENT CANNOT PULL | system | implied | Then "Get Next Case" is blocked for Julie |  |
| CP064 | PART E � AWAY AGENT CANNOT PULL | system | implied | And PK004 is NOT given to Julie |  |
| CP065 | PART F � NEXT AVAILABLE AGENT GETS THE CASE | system | implied | Given Marc Dubois is Available and qualified for FD cases |  |
| CP066 | PART F � NEXT AVAILABLE AGENT GETS THE CASE | system | implied | When Marc clicks "Get Next Case" |  |
| CP067 | PART F � NEXT AVAILABLE AGENT GETS THE CASE | system | implied | Then PK004 is given to Marc |  |
| CP068 | PART F � NEXT AVAILABLE AGENT GETS THE CASE | system | implied | And the status becomes "Assigned" |  |
| CP069 | PART F � NEXT AVAILABLE AGENT GETS THE CASE | system | implied | And the assigned agent = Marc Dubois |  |
| CP070 | PART F � NEXT AVAILABLE AGENT GETS THE CASE | system | implied | When Marc opens the case within 10 minutes |  |
| CP071 | PART F � NEXT AVAILABLE AGENT GETS THE CASE | system | implied | Then the status becomes "In Progress" |  |
| CP072 | PART F � NEXT AVAILABLE AGENT GETS THE CASE | verdict | api | And Marc sees the full history: DDS decision, Action Required email, Sarah's note and the customer's reply |  |
| CP073 | PART F � NEXT AVAILABLE AGENT GETS THE CASE | system | implied | And the 24-hour In Progress clock starts |  |
| CP074 | PART G � NEXT AGENT HANDLES THE REPLY | system | implied | When Marc reviews the reply |  |
| CP075 | PART G � NEXT AGENT HANDLES THE REPLY | system | implied | Then he confirms the decision is unchanged (ELIGIBLE, CAD 700, no override) |  |
| CP076 | PART G � NEXT AGENT HANDLES THE REPLY | system | implied | And he replies to the customer with the next step (use the secure link) |  |
| CP077 | PART G � NEXT AGENT HANDLES THE REPLY | system | implied | And he adds an internal note: case reassigned from Sarah Martin (On Leave), customer reply handled |  |
| CP078 | PART H � CUSTOMER COMPLETES PAYOUT | customer | chat | Given the customer opens the secure link |  |
| CP079 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | Then country = Canada ? CAD |  |
| CP080 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And Basic Aeroplan is found ? both options offered: Cash CAD 700 (Interac, 5 to 10 business days) or AC Wallet CAD 840 (20% bonus) |  |
| CP081 | PART H � CUSTOMER COMPLETES PAYOUT | customer | chat | And the customer selects "Cash" | Cash |
| CP082 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And only the Interac email m***@gmail.com is confirmed |  |
| CP083 | PART H � CUSTOMER COMPLETES PAYOUT | idv | chat | And Persona IDV ? PASS |  |
| CP084 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And the claim is submitted ? one CAD 700 compensation record is created |  |
| CP085 | PART H � CUSTOMER COMPLETES PAYOUT | email | email | And the eligible notification email is sent via Adobe (Case Reference, CAD 700, Interac, APPR, AC 412, Code 96) |  |
| CP086 | PART H � CUSTOMER COMPLETES PAYOUT | system | implied | And Marc resolves the case |  |
| CP087 | PART I � OWNER RETURNS FROM LEAVE | system | implied | Given Sarah's leave has ended and she signs in |  |
| CP088 | PART I � OWNER RETURNS FROM LEAVE | system | implied | Then PK004 does NOT appear in her Parked or Assigned Cases lists |  |
| CP089 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And the case owner stays Marc Dubois | Claims Dashboard Gherkin: |
| CP090 | PART I � OWNER RETURNS FROM LEAVE | system | implied | Given case "PK004" for claimant "Mathieu Roy" is "Parked" and owned by agent "Sarah Martin" |  |
| CP091 | PART I � OWNER RETURNS FROM LEAVE | system | implied | When a supervisor sets Sarah's profile to "On Leave" from Aug 12 to Aug 26, 2026 |  |
| CP092 | PART I � OWNER RETURNS FROM LEAVE | system | implied | Then PK004 should disappear from Sarah's "Incomplete / Parked Cases" widget straight away |  |
| CP093 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And the assigned agent should be removed |  |
| CP094 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And the case status should change to "To Be Assigned" |  |
| CP095 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And the original creation date, notes and audit entries should be kept |  |
| CP096 | PART I � OWNER RETURNS FROM LEAVE | system | implied | When the customer replies on Aug 14, 2026 |  |
| CP097 | PART I � OWNER RETURNS FROM LEAVE | system | implied | Then the reply should be shown in Customer Communications |  |
| CP098 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And the case should stay "To Be Assigned" in the global backlog |  |
| CP099 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And no "?? UPDATE RECEIVED" item should appear in Sarah's workspace |  |
| CP100 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And an agent in "Break / Lunch" should NOT be able to pull the case |  |
| CP101 | PART I � OWNER RETURNS FROM LEAVE | system | implied | When Available agent "Marc Dubois" clicks "Get Next Case" |  |
| CP102 | PART I � OWNER RETURNS FROM LEAVE | system | implied | Then PK004 should be assigned to Marc with status "Assigned" |  |
| CP103 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And if Marc opens it within 10 minutes the status should change to "In Progress" |  |
| CP104 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And the Case ID should not change |  |
| CP105 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And no "Appeal Pending" or "Case Closed" banner should be shown |  |
| CP106 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And the Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP107 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And the Claimant should be "Mathieu Roy", Adult, Authentication "Pass" |  |
| CP108 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And the PNR should be "PK004" with Creation Date, Journey ID, Booking Source and Office ID populated |  |
| CP109 | PART I � OWNER RETURNS FROM LEAVE | verdict | api | And the Regime should be "APPR" | APPR |
| CP110 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And the Aeroplan should be "9876543210", Tier "Basic / Member" |  |
| CP111 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 96) |  |
| CP112 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And Decision Assist should show ELIGIBLE, FD-APPR-EL-02, CAD 700 and not be greyed out |  |
| CP113 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And the Duplicate Check should show "No duplicate found" |  |
| CP114 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And CyberSource should be "GREEN" |  |
| CP115 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And the Audit Log should record in order: created, Assigned (Sarah), In Progress, Action Required sent, Parked, On Leave set, ownership remo |  |
| CP116 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And the Final Status should be "Resolved" and read-only |  |
| CP117 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And when Sarah returns from leave, PK004 should not appear in her workspace | Payment Validation Gherkin: |
| CP118 | PART I � OWNER RETURNS FROM LEAVE | system | implied | Given the case is ELIGIBLE, CAD 700 and was reassigned because the owner went on leave |  |
| CP119 | PART I � OWNER RETURNS FROM LEAVE | system | implied | Then no compensation record should exist before the customer completes the secure link |  |
| CP120 | PART I � OWNER RETURNS FROM LEAVE | system | implied | When the customer completes the secure link |  |
| CP121 | PART I � OWNER RETURNS FROM LEAVE | system | implied | Then country should be "Canada" and currency "CAD" |  |
| CP122 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And both Cash (CAD 700) and AC Wallet (CAD 840) should be offered |  |
| CP123 | PART I � OWNER RETURNS FROM LEAVE | customer | chat | And the customer selects "Cash" ? Interac e-Transfer | Cash |
| CP124 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And only the email "m***@gmail.com" should be collected |  |
| CP125 | PART I � OWNER RETURNS FROM LEAVE | idv | chat | And Persona IDV should PASS |  |
| CP126 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And exactly one CAD 700 compensation record should be created |  |
| CP127 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And it should be picked up by the evening batch and sent to Unifier (manual trigger in UAT) |  |
| CP128 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And Unifier should acknowledge |  |
| CP129 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And Interac status should move Pending ? Cached / Rejected / Expired, with Expired after 35 days unclaimed |  |
| CP130 | PART I � OWNER RETURNS FROM LEAVE | system | implied | And the Compensation tab should show CAD 700, Cash � Interac, status via talkback |  |
| CP131 | EXPECTED RESULTS | verdict | api | DDS FD-APPR-EL-02, CAD 700. | DDS FD-APPR-EL-02, CAD 700. |
| CP132 | EXPECTED RESULTS | verdict | chat | When the owner is set to On Leave, the parked case is removed from her straight away and returns to "To Be Assigned" with all history kept. | When the owner is set to On Leave, the parked case is removed from her straight away and returns to "To Be Assigned" with all history kept. |
| CP133 | EXPECTED RESULTS | verdict | chat | The customer's reply is added to the unowned case in the queue. | The customer's reply is added to the unowned case in the queue. |
| CP134 | EXPECTED RESULTS | verdict | chat | The next Available agent gets it (Assigned ? In Progress within 10 minutes) and completes it. | The next Available agent gets it (Assigned ? In Progress within 10 minutes) and completes it. |
| CP135 | EXPECTED RESULTS | verdict | chat | Away agents can't pull it, and it doesn't go back to the original agent when she returns. | Away agents can't pull it, and it doesn't go back to the original agent when she returns. |
| CP136 | EXPECTED RESULTS | verdict | chat | The customer is paid CAD 700 Cash via Interac (email only), with one compensation record. | The customer is paid CAD 700 Cash via Interac (email only), with one compensation record. |
