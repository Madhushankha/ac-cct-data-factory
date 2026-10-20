# FD_TC_232 · CHAI-31629 — checkpoints

**Goal:** Checks the full park and Welcome Back cycle. Flight AC 412 YUL ? YYZ arrived 7 hours late (Code 96, Controllable). DDS returns FD-APPR-EL-02, CAD 700. In the chat, the customer said they "may have been moved to a later flight", but Trip Tracer shows no booking change. Agent Sarah Martin needs to confirm which flight was actually taken before paying out. She sends a "Welcome Back � Additional Details" request with a structured question and parks the case as Awaiting Customer Info. On Aug 8 the customer opens the deep link and goes straight to the question, without repeating earlier steps or starting a new claim. They confirm they flew AC 412 as booked. The case moves to "Update Pending Action" in Sarah's Assigned Cases list with "?? UPDATE RECEIVED". Sarah opens it (In Progress), confirms the decision and sends "Welcome Back � Payout". The customer goes straight to payment. They live in Canada and pick Cash, so payment goes by Interac and only the email is collected. Opening the same link again afterwards shows the case status only.

Methods: seed 15, chat 22, api 12, email 4, implied 83, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Checks the full park and Welcome Back cycle. Flight AC 412 YUL ? YYZ arrived 7 hours late (Code 96, Controllable). DDS returns FD-APPR-EL-02 |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: PK002 � single passenger Olivier Bergeron (Adult, Basic Aeroplan 9876543210, good standing) | PNR: PK002 � single passenger Olivier Bergeron (Adult, Basic Aeroplan 9876543210, good standing) |
| CP003 | PREREQUISITES | prerequisite | seed | AC 412 YUL ? YYZ, July 20, 2026 | AC 412 YUL ? YYZ, July 20, 2026 |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival 12:00, actual 19:00 (7h delay) | Scheduled arrival 12:00, actual 19:00 (7h delay) |
| CP005 | PREREQUISITES | prerequisite | seed | Code 96 (Operations Control � Controllable) | Code 96 (Operations Control � Controllable) |
| CP006 | PREREQUISITES | prerequisite | seed | Travelled, arrived late | Travelled, arrived late |
| CP007 | PREREQUISITES | prerequisite | seed | Trip Tracer: no VOL/INVOL change | Trip Tracer: no VOL/INVOL change |
| CP008 | PREREQUISITES | prerequisite | seed | AC only | AC only |
| CP009 | PREREQUISITES | prerequisite | seed | Claim filed Jul 28, 2026 | Claim filed Jul 28, 2026 |
| CP010 | PREREQUISITES | prerequisite | seed | Case reference: CASE-FD-20260728-002 | Case reference: CASE-FD-20260728-002 |
| CP011 | PREREQUISITES | prerequisite | seed | No duplicate | No duplicate |
| CP012 | PREREQUISITES | prerequisite | implied | CyberSource GREEN | CyberSource GREEN |
| CP013 | PREREQUISITES | prerequisite | seed | Country of residence: Canada | Country of residence: Canada |
| CP014 | PREREQUISITES | prerequisite | seed | Owner agent: Sarah Martin (Available, not On Leave) | Owner agent: Sarah Martin (Available, not On Leave) |
| CP015 | PREREQUISITES | prerequisite | seed | Second agent: Marc Dubois (Available) | Second agent: Marc Dubois (Available) |
| CP016 | PREREQUISITES | prerequisite | seed | Park date: Aug 1 | Park date: Aug 1 |
| CP017 | PREREQUISITES | prerequisite | seed | Customer returns: Aug 8, 11:00 (day 7, within 30 days) | Customer returns: Aug 8, 11:00 (day 7, within 30 days) |
| CP018 | PART A � INITIAL CLAIM | customer | chat | Given the user opens the agentic chatbot |  |
| CP019 | PART A � INITIAL CLAIM | customer | chat | Then the chatbot displays greeting (GLOB-01) and the user selects "English" | English |
| CP020 | PART A � INITIAL CLAIM | alert | chat | Then the privacy alert is displayed |  |
| CP021 | PART A � INITIAL CLAIM | customer | chat | And the user says "My flight from Montreal to Toronto was delayed about 7 hours, I think I may have been moved to a later flight, I'd like t | My flight from Montreal to Toronto was delayed about 7 hours, I think I may have been moved to a later flight, I'd like to check if I'm eligible for compensatio |
| CP022 | PART A � INITIAL CLAIM | system | implied | When the chatbot identifies flight disruption intent |  |
| CP023 | PART A � INITIAL CLAIM | system | implied | Then third-party check ? NO, and the legal disclaimer is shown and accepted | IDENTIFICATION (GenUC-01): "Olivier Bergeron" + PNR "PK002" ? Trip Tracer PNR FOUND (Auth Flow 1) AUTHENTICATION (GenUC-05): Email o***@gmail.com ? OTP "370528" |
| CP024 | TRIP TRACER UI VALIDATION (PK002) | verdict | api | Current: AC 412, ARRIVED LATE, 12:00 ? 19:00, +7H 00M | Current: AC 412, ARRIVED LATE, 12:00 ? 19:00, +7H 00M |
| CP025 | TRIP TRACER UI VALIDATION (PK002) | verdict | api | Booking changes: None (no VOL / INVOL) | Booking changes: None (no VOL / INVOL) |
| CP026 | TRIP TRACER UI VALIDATION (PK002) | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP027 | TRIP TRACER UI VALIDATION (PK002) | verdict | api | MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE | MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE |
| CP028 | TRIP TRACER UI VALIDATION (PK002) | verdict | api | MR OLIVIER BERGERON / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet | MR OLIVIER BERGERON / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet |
| CP029 | TRIP TRACER UI VALIDATION (PK002) | verdict | api | CYBERSOURCE (GLOB-05): GREEN | CYBERSOURCE (GLOB-05): GREEN |
| CP030 | TRIP TRACER UI VALIDATION (PK002) | verdict | api | CUSTOMER DROPS OFF: closes the chat before payment | CUSTOMER DROPS OFF: closes the chat before payment |
| CP031 | TRIP TRACER UI VALIDATION (PK002) | verdict | api | Then case CASE-FD-20260728-002 is created as ELIGIBLE, CAD 700, with no payment instruction, and the transcript is linked |  |
| CP032 | PART B � AGENT REQUESTS INFO AND PARKS | system | implied | Given Sarah Martin clicks "Get Next Case" ? Assigned ? opens it within 10 minutes ? In Progress |  |
| CP033 | PART B � AGENT REQUESTS INFO AND PARKS | system | implied | When she reads the transcript and sees "may have been moved to a later flight" |  |
| CP034 | PART B � AGENT REQUESTS INFO AND PARKS | verdict | api | And Trip Tracer shows no booking change |  |
| CP035 | PART B � AGENT REQUESTS INFO AND PARKS | system | implied | Then she decides to confirm the flight taken before payout |  |
| CP036 | PART B � AGENT REQUESTS INFO AND PARKS | system | implied | When she triggers "Welcome Back � Additional Details" |  |
| CP037 | PART B � AGENT REQUESTS INFO AND PARKS | system | implied | And defines the request with a structured question: "Which flight did you travel on? (AC 412 as booked / a different flight)", plus an optio |  |
| CP038 | PART B � AGENT REQUESTS INFO AND PARKS | email | email | Then a Welcome Back email with a deep link is sent to o***@gmail.com |  |
| CP039 | PART B � AGENT REQUESTS INFO AND PARKS | system | implied | And the link shows no readable case or customer data (key only) |  |
| CP040 | PART B � AGENT REQUESTS INFO AND PARKS | system | implied | And the case status becomes "Awaiting Customer Info" |  |
| CP041 | PART B � AGENT REQUESTS INFO AND PARKS | system | implied | When Sarah selects "Park Case" |  |
| CP042 | PART B � AGENT REQUESTS INFO AND PARKS | system | implied | Then the status becomes "Parked" |  |
| CP043 | PART B � AGENT REQUESTS INFO AND PARKS | system | implied | And the case moves to Sarah's Incomplete / Parked Cases widget |  |
| CP044 | PART B � AGENT REQUESTS INFO AND PARKS | system | implied | And Sarah's active slot is freed |  |
| CP045 | PART B � AGENT REQUESTS INFO AND PARKS | system | implied | And the assigned agent stays Sarah Martin |  |
| CP046 | PART B � AGENT REQUESTS INFO AND PARKS | email | email | And the Audit Log records: Welcome Back type (Additional Details), question sent, notification sent, Parked, actor and timestamp |  |
| CP047 | PART C � CUSTOMER RETURNS THROUGH THE DEEP LINK | system | implied | Given the case is Parked |  |
| CP048 | PART C � CUSTOMER RETURNS THROUGH THE DEEP LINK | customer | chat | When the customer clicks the deep link |  |
| CP049 | PART C � CUSTOMER RETURNS THROUGH THE DEEP LINK | system | implied | Then the system resolves the key and loads the case context |  |
| CP050 | PART C � CUSTOMER RETURNS THROUGH THE DEEP LINK | system | implied | And Case Services returns "Waiting on customer details" |  |
| CP051 | PART C � CUSTOMER RETURNS THROUGH THE DEEP LINK | system | implied | And the customer lands straight on the Additional Details question |  |
| CP052 | PART C � CUSTOMER RETURNS THROUGH THE DEEP LINK | system | implied | And the customer is NOT asked to repeat greeting, identification, passenger or journey selection |  |
| CP053 | PART C � CUSTOMER RETURNS THROUGH THE DEEP LINK | system | implied | And no new FD claim is started |  |
| CP054 | PART C � CUSTOMER RETURNS THROUGH THE DEEP LINK | idv | chat | And no IDV is asked for at this step (not a payment step) |  |
| CP055 | PART C � CUSTOMER RETURNS THROUGH THE DEEP LINK | customer | chat | When the customer selects "AC 412 as booked" and types "I was told I might be moved but I stayed on AC 412" | AC 412 as booked I was told I might be moved but I stayed on AC 412 |
| CP056 | PART C � CUSTOMER RETURNS THROUGH THE DEEP LINK | system | implied | And submits |  |
| CP057 | PART C � CUSTOMER RETURNS THROUGH THE DEEP LINK | system | implied | Then the chatbot confirms the information has been added to the case |  |
| CP058 | PART C � CUSTOMER RETURNS THROUGH THE DEEP LINK | system | implied | And the answer is attached to the case as a structured field plus the free-text note |  |
| CP059 | PART D � CASE RETURNS TO THE SAME AGENT | system | implied | Then the status changes Parked ? "Update Pending Action" straight away |  |
| CP060 | PART D � CASE RETURNS TO THE SAME AGENT | system | implied | And the case leaves Sarah's Parked widget and appears in her Assigned Cases list |  |
| CP061 | PART D � CASE RETURNS TO THE SAME AGENT | system | implied | And the case shows "?? UPDATE RECEIVED" |  |
| CP062 | PART D � CASE RETURNS TO THE SAME AGENT | system | implied | And it does not count against her one-new-case limit |  |
| CP063 | PART D � CASE RETURNS TO THE SAME AGENT | system | implied | And the assigned agent stays Sarah Martin |  |
| CP064 | PART D � CASE RETURNS TO THE SAME AGENT | system | implied | And the case does NOT go to "To Be Assigned" |  |
| CP065 | PART D � CASE RETURNS TO THE SAME AGENT | system | implied | And Marc Dubois cannot pull the case with "Get Next Case" |  |
| CP066 | PART D � CASE RETURNS TO THE SAME AGENT | system | implied | And no Appeal Pending or Case Closed banner is shown |  |
| CP067 | PART D � CASE RETURNS TO THE SAME AGENT | system | implied | And the Case ID does not change |  |
| CP068 | PART D � CASE RETURNS TO THE SAME AGENT | system | implied | And the Audit Log records: Welcome Back response received (channel: deep link), Parked ? Update Pending Action |  |
| CP069 | PART E � AGENT CONTINUES AND TRIGGERS PAYOUT | system | implied | When Sarah clicks the case row |  |
| CP070 | PART E � AGENT CONTINUES AND TRIGGERS PAYOUT | system | implied | Then the status changes to "In Progress" |  |
| CP071 | PART E � AGENT CONTINUES AND TRIGGERS PAYOUT | system | implied | And the customer's answer is clearly shown |  |
| CP072 | PART E � AGENT CONTINUES AND TRIGGERS PAYOUT | verdict | api | And she confirms it matches Trip Tracer (AC 412, no change) |  |
| CP073 | PART E � AGENT CONTINUES AND TRIGGERS PAYOUT | system | implied | And she keeps the decision ELIGIBLE, FD-APPR-EL-02, CAD 700 (no override) |  |
| CP074 | PART E � AGENT CONTINUES AND TRIGGERS PAYOUT | system | implied | When she triggers "Welcome Back � Payout" |  |
| CP075 | PART E � AGENT CONTINUES AND TRIGGERS PAYOUT | system | implied | Then the amount and type are filled in by the system (CAD 700) and she cannot type or change the payout structure |  |
| CP076 | PART E � AGENT CONTINUES AND TRIGGERS PAYOUT | email | email | And a Welcome Back payout email is sent to o***@gmail.com |  |
| CP077 | PART E � AGENT CONTINUES AND TRIGGERS PAYOUT | system | implied | And the case is Awaiting Customer Info (Compensation) |  |
| CP078 | PART F � CUSTOMER COMPLETES PAYOUT THROUGH WELCOME BACK | customer | chat | When the customer clicks the deep link again |  |
| CP079 | PART F � CUSTOMER COMPLETES PAYOUT THROUGH WELCOME BACK | system | implied | Then they land straight on the payment step (earlier steps not shown) |  |
| CP080 | PART F � CUSTOMER COMPLETES PAYOUT THROUGH WELCOME BACK | system | implied | And country of residence = Canada ? CAD |  |
| CP081 | PART F � CUSTOMER COMPLETES PAYOUT THROUGH WELCOME BACK | system | implied | And Basic Aeroplan is found ? both options offered: Cash CAD 700 (Interac, 5 to 10 business days) or AC Wallet CAD 840 (20% bonus) |  |
| CP082 | PART F � CUSTOMER COMPLETES PAYOUT THROUGH WELCOME BACK | customer | chat | And the customer selects "Cash" | Cash |
| CP083 | PART F � CUSTOMER COMPLETES PAYOUT THROUGH WELCOME BACK | system | implied | And only the Interac email o***@gmail.com is confirmed |  |
| CP084 | PART F � CUSTOMER COMPLETES PAYOUT THROUGH WELCOME BACK | idv | chat | And Persona IDV runs (payment step) ? PASS, and the result is saved to the case |  |
| CP085 | PART F � CUSTOMER COMPLETES PAYOUT THROUGH WELCOME BACK | system | implied | And the customer submits ? one CAD 700 compensation record is created |  |
| CP086 | PART F � CUSTOMER COMPLETES PAYOUT THROUGH WELCOME BACK | email | email | And the eligible notification email is sent via Adobe |  |
| CP087 | PART G � LINK REUSE AND EXPIRED LINK | customer | chat | When the customer opens the same deep link after payout |  |
| CP088 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | Then they are NOT sent back to the question or payment step |  |
| CP089 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And they see the latest case status only |  |
| CP090 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | When a changed or invalid key is used |  |
| CP091 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | Then a fallback message says the link is not valid, and no case data is shown | Claims Dashboard Gherkin: |
| CP092 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | Given case "CASE-FD-20260728-002" for claimant "Olivier Bergeron" is owned by "Sarah Martin" |  |
| CP093 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | When Sarah sends "Welcome Back � Additional Details" and parks the case |  |
| CP094 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | Then the status should be "Parked" and the case should be in her "Incomplete / Parked Cases" widget |  |
| CP095 | PART G � LINK REUSE AND EXPIRED LINK | customer | chat | When the customer answers through the deep link |  |
| CP096 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | Then the answer should be attached to the case |  |
| CP097 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And the status should change to "Update Pending Action" |  |
| CP098 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And the case should appear in Sarah's "Assigned Cases" list with "?? UPDATE RECEIVED" |  |
| CP099 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And the assigned agent should remain "Sarah Martin" |  |
| CP100 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And the case should NOT be in "To Be Assigned" |  |
| CP101 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And another Available agent should NOT be able to pull the case |  |
| CP102 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And no new case should be created and the Case ID should not change |  |
| CP103 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | When Sarah clicks the case |  |
| CP104 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | Then the status should change to "In Progress" |  |
| CP105 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And the Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP106 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And the Claimant should be "Olivier Bergeron", Adult, Authentication "Pass" |  |
| CP107 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And the PNR should be "PK002" with Creation Date, Journey ID, Booking Source and Office ID populated |  |
| CP108 | PART G � LINK REUSE AND EXPIRED LINK | verdict | api | And the Regime should be "APPR" | APPR |
| CP109 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And the Aeroplan should be "9876543210", Tier "Basic / Member" |  |
| CP110 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 96) |  |
| CP111 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And Decision Assist should show ELIGIBLE, FD-APPR-EL-02, CAD 700 and not be greyed out |  |
| CP112 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And the Duplicate Check should show "No duplicate found" |  |
| CP113 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And CyberSource should be "GREEN" |  |
| CP114 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And Customer Communications should show both Welcome Back emails, the customer's answer and the eligible notification in date order |  |
| CP115 | PART G � LINK REUSE AND EXPIRED LINK | idv | chat | And the Audit Log should record in order: created, Assigned, In Progress, Welcome Back (Additional Details) sent, Parked, customer answer, U |  |
| CP116 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And the Final Status should be "Resolved" and read-only | Payment Validation Gherkin: |
| CP117 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | Given the case is ELIGIBLE, CAD 700 and Sarah has triggered "Welcome Back � Payout" |  |
| CP118 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | Then the payout amount should be filled in by the system and not editable as free text |  |
| CP119 | PART G � LINK REUSE AND EXPIRED LINK | customer | chat | When the customer opens the deep link |  |
| CP120 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | Then they should land straight on payment |  |
| CP121 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And country should be "Canada" and currency "CAD" |  |
| CP122 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And both Cash (CAD 700) and AC Wallet (CAD 840) should be offered |  |
| CP123 | PART G � LINK REUSE AND EXPIRED LINK | customer | chat | And the customer selects "Cash" ? Interac e-Transfer | Cash |
| CP124 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And only the email "o***@gmail.com" should be collected |  |
| CP125 | PART G � LINK REUSE AND EXPIRED LINK | idv | chat | And Persona IDV should PASS and be saved to the case |  |
| CP126 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And exactly one CAD 700 compensation record should be created |  |
| CP127 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And it should be picked up by the evening batch and sent to Unifier (manual trigger in UAT) |  |
| CP128 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And Unifier should acknowledge |  |
| CP129 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And Interac status should move Pending ? Cached / Rejected / Expired, with Expired after 35 days unclaimed |  |
| CP130 | PART G � LINK REUSE AND EXPIRED LINK | system | implied | And the Compensation tab should show CAD 700, Cash � Interac, status via talkback |  |
| CP131 | EXPECTED RESULTS | verdict | api | DDS FD-APPR-EL-02, CAD 700. | DDS FD-APPR-EL-02, CAD 700. |
| CP132 | EXPECTED RESULTS | verdict | chat | The agent sends Welcome Back � Additional Details and parks the case. | The agent sends Welcome Back � Additional Details and parks the case. |
| CP133 | EXPECTED RESULTS | verdict | chat | The customer uses the deep link and goes straight to the question, with no restart and no new case. | The customer uses the deep link and goes straight to the question, with no restart and no new case. |
| CP134 | EXPECTED RESULTS | verdict | chat | Their answer is attached, and the case moves to Update Pending Action with "?? UPDATE RECEIVED" in the same agent's Assigned Cases list. | Their answer is attached, and the case moves to Update Pending Action with "?? UPDATE RECEIVED" in the same agent's Assigned Cases list. |
| CP135 | EXPECTED RESULTS | verdict | chat | The agent opens it (In Progress) and sends Welcome Back � Payout with a system-filled amount. | The agent opens it (In Progress) and sends Welcome Back � Payout with a system-filled amount. |
| CP136 | EXPECTED RESULTS | verdict | chat | The customer goes straight to payment and is paid CAD 700 Cash via Interac (email only), with one compensation record. | The customer goes straight to payment and is paid CAD 700 Cash via Interac (email only), with one compensation record. |
| CP137 | EXPECTED RESULTS | verdict | chat | Reusing the link afterwards shows status only. | Reusing the link afterwards shows status only. |
