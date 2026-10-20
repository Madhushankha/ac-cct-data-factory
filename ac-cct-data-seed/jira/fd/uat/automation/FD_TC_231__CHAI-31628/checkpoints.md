# FD_TC_231 · CHAI-31628 — checkpoints

**Goal:** Checks that the appeal flow only works for Closed cases. Flight AC 412 YUL ? YYZ arrived 7 hours late (Code 96, Controllable). DDS returns FD-APPR-EL-02, CAD 700. The customer leaves the chat before payment. Agent Sarah Martin sends Action Required with the secure payment link and parks the case (Awaiting Customer Info � Compensation). On Aug 12, day 11, the customer goes back to the chatbot, asks to appeal the case and quotes the case number. They give a reason and upload a document. The system sees that the case is Parked, not Closed, and refuses to accept it as an appeal. The bot tells the customer the case is still open and that their information has been added to it. The case goes to Update Pending Action with "?? UPDATE RECEIVED" for Sarah. There is no Re-opened state, no appeal flag, no appeal count, no "Appeal received" email, no new case and no reassignment. Sarah then finishes the case. The customer lives in Canada and picks Cash, so payment goes by Interac and only the email is collected.

Methods: seed 16, chat 15, api 10, email 3, implied 82, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Checks that the appeal flow only works for Closed cases. Flight AC 412 YUL ? YYZ arrived 7 hours late (Code 96, Controllable). DDS returns F |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: PK003 � single passenger Laurence Gauthier (Adult, Basic Aeroplan 9876543210, good standing) | PNR: PK003 � single passenger Laurence Gauthier (Adult, Basic Aeroplan 9876543210, good standing) |
| CP003 | PREREQUISITES | prerequisite | seed | AC 412 YUL ? YYZ, July 20, 2026 | AC 412 YUL ? YYZ, July 20, 2026 |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival 12:00, actual 19:00 (7h delay) | Scheduled arrival 12:00, actual 19:00 (7h delay) |
| CP005 | PREREQUISITES | prerequisite | seed | Code 96 (Operations Control � Controllable) | Code 96 (Operations Control � Controllable) |
| CP006 | PREREQUISITES | prerequisite | seed | Travelled, arrived late | Travelled, arrived late |
| CP007 | PREREQUISITES | prerequisite | seed | No VOL/INVOL changes | No VOL/INVOL changes |
| CP008 | PREREQUISITES | prerequisite | seed | AC only | AC only |
| CP009 | PREREQUISITES | prerequisite | seed | Claim filed Jul 28, 2026 | Claim filed Jul 28, 2026 |
| CP010 | PREREQUISITES | prerequisite | seed | Case reference: CASE-FD-20260728-003 | Case reference: CASE-FD-20260728-003 |
| CP011 | PREREQUISITES | prerequisite | seed | No duplicate | No duplicate |
| CP012 | PREREQUISITES | prerequisite | implied | CyberSource GREEN | CyberSource GREEN |
| CP013 | PREREQUISITES | prerequisite | seed | Country of residence: Canada | Country of residence: Canada |
| CP014 | PREREQUISITES | prerequisite | seed | Owner agent: Sarah Martin (Available, not On Leave) | Owner agent: Sarah Martin (Available, not On Leave) |
| CP015 | PREREQUISITES | prerequisite | seed | Second agent: Marc Dubois (Available) | Second agent: Marc Dubois (Available) |
| CP016 | PREREQUISITES | prerequisite | seed | Park date: Aug 1 | Park date: Aug 1 |
| CP017 | PREREQUISITES | prerequisite | seed | Appeal attempt: Aug 12, 10:00 via chatbot | Appeal attempt: Aug 12, 10:00 via chatbot |
| CP018 | PREREQUISITES | prerequisite | seed | Maximum Appeals Allowed setting: configured (for example 1) | Maximum Appeals Allowed setting: configured (for example 1) |
| CP019 | PART A � INITIAL CLAIM | customer | chat | Given the user opens the agentic chatbot |  |
| CP020 | PART A � INITIAL CLAIM | customer | chat | Then the chatbot displays greeting (GLOB-01) and the user selects "English" | English |
| CP021 | PART A � INITIAL CLAIM | alert | chat | Then the privacy alert is displayed |  |
| CP022 | PART A � INITIAL CLAIM | customer | chat | And the user says "My flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if I'm eligible for compensation" | My flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if I'm eligible for compensation |
| CP023 | PART A � INITIAL CLAIM | system | implied | When the chatbot identifies flight disruption intent |  |
| CP024 | PART A � INITIAL CLAIM | system | implied | Then third-party check ? NO, and the legal disclaimer is shown and accepted | IDENTIFICATION (GenUC-01): "Laurence Gauthier" + PNR "PK003" ? Trip Tracer PNR FOUND (Auth Flow 1) AUTHENTICATION (GenUC-05): Email l***@gmail.com ? OTP "903174 |
| CP025 | TRIP TRACER UI VALIDATION (PK003) | verdict | api | Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M | Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M |
| CP026 | TRIP TRACER UI VALIDATION (PK003) | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP027 | TRIP TRACER UI VALIDATION (PK003) | verdict | api | MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE | MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE |
| CP028 | TRIP TRACER UI VALIDATION (PK003) | verdict | api | MS LAURENCE GAUTHIER / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet | MS LAURENCE GAUTHIER / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet |
| CP029 | TRIP TRACER UI VALIDATION (PK003) | verdict | api | CYBERSOURCE (GLOB-05): GREEN | CYBERSOURCE (GLOB-05): GREEN |
| CP030 | TRIP TRACER UI VALIDATION (PK003) | verdict | api | ELIGIBLE RESULT (FD-05a): APPR eligible message for AC 412 | ELIGIBLE RESULT (FD-05a): APPR eligible message for AC 412 |
| CP031 | TRIP TRACER UI VALIDATION (PK003) | verdict | api | CUSTOMER DROPS OFF: closes the chat at "In which country will your reimbursement be deposited?" | CUSTOMER DROPS OFF: closes the chat at "In which country will your reimbursement be deposited?" |
| CP032 | TRIP TRACER UI VALIDATION (PK003) | verdict | api | Then case CASE-FD-20260728-003 is created as ELIGIBLE, CAD 700, with no payment instruction |  |
| CP033 | PART B � AGENT PARKS THE CASE | system | implied | Given Sarah Martin clicks "Get Next Case" ? Assigned ? opens within 10 minutes ? In Progress |  |
| CP034 | PART B � AGENT PARKS THE CASE | system | implied | When she confirms Decision Assist (ELIGIBLE, FD-APPR-EL-02, CAD 700) |  |
| CP035 | PART B � AGENT PARKS THE CASE | system | implied | And sends "Decision Rendered � Action Required to Accept Compensation" with the secure link |  |
| CP036 | PART B � AGENT PARKS THE CASE | system | implied | And selects "Park Case" |  |
| CP037 | PART B � AGENT PARKS THE CASE | system | implied | Then the status becomes "Parked" (Awaiting Customer Info � Compensation) |  |
| CP038 | PART B � AGENT PARKS THE CASE | system | implied | And the case is in Sarah's Incomplete / Parked Cases widget |  |
| CP039 | PART C � CUSTOMER TRIES TO APPEAL THROUGH THE CHATBOT | system | implied | Given the case is Parked and not Closed |  |
| CP040 | PART C � CUSTOMER TRIES TO APPEAL THROUGH THE CHATBOT | customer | chat | When the customer opens the chatbot, selects English and says "I want to appeal my case CASE-FD-20260728-003. I also had to pay for a hotel  | I want to appeal my case CASE-FD-20260728-003. I also had to pay for a hotel that night and I don't agree with the amount |
| CP041 | PART C � CUSTOMER TRIES TO APPEAL THROUGH THE CHATBOT | system | implied | And completes identification and OTP authentication |  |
| CP042 | PART C � CUSTOMER TRIES TO APPEAL THROUGH THE CHATBOT | system | implied | And uploads "hotel_receipt.pdf" |  |
| CP043 | PART C � CUSTOMER TRIES TO APPEAL THROUGH THE CHATBOT | system | implied | Then the system finds the existing case CASE-FD-20260728-003 |  |
| CP044 | PART C � CUSTOMER TRIES TO APPEAL THROUGH THE CHATBOT | system | implied | And the system checks the case status ? Parked (not Closed) |  |
| CP045 | PART C � CUSTOMER TRIES TO APPEAL THROUGH THE CHATBOT | system | implied | And the appeal is NOT accepted (BR-4) |  |
| CP046 | PART C � CUSTOMER TRIES TO APPEAL THROUGH THE CHATBOT | system | implied | And the chatbot tells the customer the case is still open, that an appeal can only be made after a decision is closed, and that their messag |  |
| CP047 | PART C � CUSTOMER TRIES TO APPEAL THROUGH THE CHATBOT | system | implied | And no appeal reference or "Appeal received" confirmation is given |  |
| CP048 | PART C � CUSTOMER TRIES TO APPEAL THROUGH THE CHATBOT | system | implied | And the chatbot does not start a new FD claim for the same passenger and journey |  |
| CP049 | PART D � SYSTEM HANDLES IT AS A CASE UPDATE | system | implied | Then the customer's message and hotel_receipt.pdf are added to the existing case (Customer Communications and Attachments) |  |
| CP050 | PART D � SYSTEM HANDLES IT AS A CASE UPDATE | system | implied | And the case status changes Parked ? "Update Pending Action" |  |
| CP051 | PART D � SYSTEM HANDLES IT AS A CASE UPDATE | system | implied | And the case moves to Sarah's Assigned Cases list with "?? UPDATE RECEIVED" |  |
| CP052 | PART D � SYSTEM HANDLES IT AS A CASE UPDATE | system | implied | And the assigned agent stays Sarah Martin |  |
| CP053 | PART D � SYSTEM HANDLES IT AS A CASE UPDATE | system | implied | And the case does NOT change to "Re-opened" |  |
| CP054 | PART D � SYSTEM HANDLES IT AS A CASE UPDATE | system | implied | And no "Re-opened due to appeal" flag or Appeal Pending banner is shown |  |
| CP055 | PART D � SYSTEM HANDLES IT AS A CASE UPDATE | system | implied | And the appeal counter on the case stays 0 |  |
| CP056 | PART D � SYSTEM HANDLES IT AS A CASE UPDATE | system | implied | And the case does NOT go to "To Be Assigned" and is NOT given to Marc Dubois |  |
| CP057 | PART D � SYSTEM HANDLES IT AS A CASE UPDATE | email | email | And no "Appeal received" notification is sent | Appeal received |
| CP058 | PART D � SYSTEM HANDLES IT AS A CASE UPDATE | system | implied | And the Audit Log records: chatbot appeal attempt rejected (case not Closed), update added, Parked ? Update Pending Action, with actor, time |  |
| CP059 | PART E � OWNER AGENT HANDLES THE UPDATE | system | implied | Given Sarah is Available |  |
| CP060 | PART E � OWNER AGENT HANDLES THE UPDATE | system | implied | When she clicks the case row |  |
| CP061 | PART E � OWNER AGENT HANDLES THE UPDATE | system | implied | Then the status changes to "In Progress" |  |
| CP062 | PART E � OWNER AGENT HANDLES THE UPDATE | system | implied | And she can see the new message and the receipt separately from the original decision |  |
| CP063 | PART E � OWNER AGENT HANDLES THE UPDATE | system | implied | And she confirms the flight disruption decision is unchanged (ELIGIBLE, CAD 700, no override) |  |
| CP064 | PART E � OWNER AGENT HANDLES THE UPDATE | system | implied | And she tells the customer that the hotel expense can't be added to this APPR compensation payout. She gives the next step for expense reimb |  |
| CP065 | PART E � OWNER AGENT HANDLES THE UPDATE | system | implied | And she tells the customer to use the secure link to complete payout |  |
| CP066 | PART E � OWNER AGENT HANDLES THE UPDATE | system | implied | And she adds an internal note: appeal attempt on a parked case, handled as an update |  |
| CP067 | PART F � CUSTOMER COMPLETES PAYOUT | customer | chat | Given the customer opens the secure link |  |
| CP068 | PART F � CUSTOMER COMPLETES PAYOUT | system | implied | Then country = Canada ? CAD |  |
| CP069 | PART F � CUSTOMER COMPLETES PAYOUT | system | implied | And Basic Aeroplan is found ? both options offered: Cash CAD 700 (Interac, 5 to 10 business days) or AC Wallet CAD 840 (20% bonus) |  |
| CP070 | PART F � CUSTOMER COMPLETES PAYOUT | customer | chat | And the customer selects "Cash" | Cash |
| CP071 | PART F � CUSTOMER COMPLETES PAYOUT | system | implied | And only the Interac email l***@gmail.com is confirmed |  |
| CP072 | PART F � CUSTOMER COMPLETES PAYOUT | idv | chat | And Persona IDV ? PASS |  |
| CP073 | PART F � CUSTOMER COMPLETES PAYOUT | system | implied | And the claim is submitted ? one CAD 700 compensation record is created |  |
| CP074 | PART F � CUSTOMER COMPLETES PAYOUT | email | email | And the eligible notification email is sent via Adobe |  |
| CP075 | PART F � CUSTOMER COMPLETES PAYOUT | system | implied | And Sarah resolves the case ? status Closed |  |
| CP076 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | Given the case is now Closed |  |
| CP077 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | Then the case is eligible for appeal intake through the chatbot |  |
| CP078 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the appeal counter is still 0, so the rejected attempt in Part C did not use up an appeal | Claims Dashboard Gherkin: |
| CP079 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | Given case "CASE-FD-20260728-003" for claimant "Laurence Gauthier" is "Parked" and owned by "Sarah Martin" |  |
| CP080 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | When the customer submits an appeal through the chatbot quoting this case number with a reason and a document |  |
| CP081 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | Then the appeal should NOT be accepted because the case is not "Closed" |  |
| CP082 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the case should NOT change to "Re-opened" |  |
| CP083 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And no new case should be created |  |
| CP084 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the Case ID should not change |  |
| CP085 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the message and document should be added to the existing case |  |
| CP086 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the case status should change to "Update Pending Action" |  |
| CP087 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the case should appear in Sarah's "Assigned Cases" list with "?? UPDATE RECEIVED" |  |
| CP088 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the assigned agent should remain "Sarah Martin" |  |
| CP089 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the case should NOT be in "To Be Assigned" or given to another agent |  |
| CP090 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And no "Appeal Pending" banner or "re-opened due to appeal" flag should be shown |  |
| CP091 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the appeal counter should remain 0 |  |
| CP092 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | email | email | And no "Appeal received" notification should be sent | Appeal received |
| CP093 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | When Sarah clicks the case |  |
| CP094 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | Then the status should change to "In Progress" |  |
| CP095 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the new customer information should be clearly visible |  |
| CP096 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP097 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the Claimant should be "Laurence Gauthier", Adult, Authentication "Pass" |  |
| CP098 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the PNR should be "PK003" with Creation Date, Journey ID, Booking Source and Office ID populated |  |
| CP099 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | verdict | api | And the Regime should be "APPR" | APPR |
| CP100 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the Aeroplan should be "9876543210", Tier "Basic / Member" |  |
| CP101 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 96) |  |
| CP102 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And Decision Assist should show ELIGIBLE, FD-APPR-EL-02, CAD 700 |  |
| CP103 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the Duplicate Check should show "No duplicate found" |  |
| CP104 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And CyberSource should be "GREEN" |  |
| CP105 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the Attachments tab should show "hotel_receipt.pdf" |  |
| CP106 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the Audit Log should record: created, Parked, appeal attempt rejected (not Closed), update added, Update Pending Action, In Progress, pa |  |
| CP107 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the Final Status should be "Closed" and read-only | Payment Validation Gherkin: |
| CP108 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | Given the appeal attempt was not accepted and the decision is ELIGIBLE, CAD 700 |  |
| CP109 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | Then no compensation record should exist before the customer completes the secure link |  |
| CP110 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the uploaded hotel receipt should NOT change the CAD 700 APPR amount |  |
| CP111 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | When the customer completes the secure link |  |
| CP112 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | Then country should be "Canada" and currency "CAD" |  |
| CP113 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And both Cash (CAD 700) and AC Wallet (CAD 840) should be offered |  |
| CP114 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | customer | chat | And the customer selects "Cash" ? Interac e-Transfer | Cash |
| CP115 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And only the email "l***@gmail.com" should be collected |  |
| CP116 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | idv | chat | And Persona IDV should PASS |  |
| CP117 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And exactly one CAD 700 compensation record should be created |  |
| CP118 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And it should be picked up by the evening batch and sent to Unifier (manual trigger in UAT) |  |
| CP119 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And Unifier should acknowledge |  |
| CP120 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And Interac status should move Pending ? Cached / Rejected / Expired, with Expired after 35 days unclaimed |  |
| CP121 | PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE | system | implied | And the Compensation tab should show CAD 700, Cash � Interac, status via talkback |  |
| CP122 | EXPECTED RESULTS | verdict | api | DDS FD-APPR-EL-02, CAD 700. | DDS FD-APPR-EL-02, CAD 700. |
| CP123 | EXPECTED RESULTS | verdict | chat | An appeal on a Parked case is not accepted because only Closed cases can be appealed. | An appeal on a Parked case is not accepted because only Closed cases can be appealed. |
| CP124 | EXPECTED RESULTS | verdict | chat | There is no Re-opened state, no appeal flag, no appeal count, no Appeal received email, no new case and no reassignment. | There is no Re-opened state, no appeal flag, no appeal count, no Appeal received email, no new case and no reassignment. |
| CP125 | EXPECTED RESULTS | verdict | chat | The customer's message and document are added to the same case, which goes to Update Pending Action with "?? UPDATE RECEIVED" for the same a | The customer's message and document are added to the same case, which goes to Update Pending Action with "?? UPDATE RECEIVED" for the same agent. |
| CP126 | EXPECTED RESULTS | verdict | chat | The agent handles the update and the customer is paid CAD 700 Cash via Interac (email only), with one compensation record. | The agent handles the update and the customer is paid CAD 700 Cash via Interac (email only), with one compensation record. |
| CP127 | EXPECTED RESULTS | verdict | chat | The appeal option becomes available only after the case is Closed. | The appeal option becomes available only after the case is Closed. |
