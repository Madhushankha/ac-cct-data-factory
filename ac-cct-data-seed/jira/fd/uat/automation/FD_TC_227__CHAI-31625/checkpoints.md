# FD_TC_227 · CHAI-31625 — checkpoints

**Goal:** Checks what happens when a customer replies too late to a parked, eligible case. AC 412 YUL ? YYZ arrived 7 hours late for a controllable reason (Code 63, late flight deck crew boarding and departure procedures). DDS returns FD-APPR-EL-02, CAD 700. The customer leaves the chat before the payment step. The agent sends "Decision Rendered � Action Required" and parks the case. There's no reply within 30 days, so the case closes. The customer replies on day 35, and the same case must reopen as an Appeal. It must not be handled as a normal customer response or opened as a new case. The agent upholds the decision as Eligible. Basic Aeroplan is linked, so Cash (CAD 700) and AC Wallet (CAD 840) are both offered. The customer is a Canada resident and picks Cash, so payment goes by Interac and only the email is collected.

Methods: seed 18, chat 24, api 20, email 1, dashboard 21, implied 39, manual 7, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Checks what happens when a customer replies too late to a parked, eligible case. AC 412 YUL ? YYZ arrived 7 hours late for a controllable re |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR PK008: one passenger, Julien Gagnon (Adult, Basic Aeroplan member 9876543210, good standing) | PNR PK008: one passenger, Julien Gagnon (Adult, Basic Aeroplan member 9876543210, good standing) |
| CP003 | PREREQUISITES | prerequisite | seed | One AC domestic leg: AC 412 YUL ? YYZ, July 20, 2026 | One AC domestic leg: AC 412 YUL ? YYZ, July 20, 2026 |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival 12:00, actual 19:00 (7h, 420 min) | Scheduled arrival 12:00, actual 19:00 (7h, 420 min) |
| CP005 | PREREQUISITES | prerequisite | seed | Cancellation code: NONE | Cancellation code: NONE |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival delay code: 63 (FT, late crew boarding / departure procedures, controllable) | Arrival delay code: 63 (FT, late crew boarding / departure procedures, controllable) |
| CP007 | PREREQUISITES | prerequisite | seed | Fallback: FALSE | Fallback: FALSE |
| CP008 | PREREQUISITES | prerequisite | seed | Travelled, arrived late | Travelled, arrived late |
| CP009 | PREREQUISITES | prerequisite | seed | No VOL or INVOL changes | No VOL or INVOL changes |
| CP010 | PREREQUISITES | prerequisite | seed | AC only | AC only |
| CP011 | PREREQUISITES | prerequisite | seed | Claim filed July 28, 2026 (more than 72 hrs, within 366 days) | Claim filed July 28, 2026 (more than 72 hrs, within 366 days) |
| CP012 | PREREQUISITES | prerequisite | seed | No duplicate | No duplicate |
| CP013 | PREREQUISITES | prerequisite | seed | Not an employee, not an infant | Not an employee, not an infant |
| CP014 | PREREQUISITES | prerequisite | implied | CyberSource GREEN | CyberSource GREEN |
| CP015 | PREREQUISITES | prerequisite | seed | Country of residence: Canada | Country of residence: Canada |
| CP016 | PREREQUISITES | prerequisite | seed | Park start Aug 1, 2026 | Park start Aug 1, 2026 |
| CP017 | PREREQUISITES | prerequisite | seed | 30-day window ends Aug 31, 2026 | 30-day window ends Aug 31, 2026 |
| CP018 | PREREQUISITES | prerequisite | seed | Customer reply Sep 5, 2026 (day 35) | Customer reply Sep 5, 2026 (day 35) |
| CP019 | PREREQUISITES | prerequisite | seed | Test access: agent and lead in Claims Dashboard, with the ability to trigger or simulate the 30-day expiry in UAT | Test access: agent and lead in Claims Dashboard, with the ability to trigger or simulate the 30-day expiry in UAT |
| CP020 | PREREQUISITES | prerequisite | seed | Payment: Interac only, email only | Payment: Interac only, email only |
| CP021 | PART A � INITIAL CLAIM | customer | chat | Given the user opens the agentic chatbot |  |
| CP022 | PART A � INITIAL CLAIM | bot | chat | Then the chatbot displays greeting (GLOB-01): "Hello! I will be your virtual assistant today. I can assist you in English or French. Which l | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP023 | PART A � INITIAL CLAIM | customer | chat | Then user selects "English" | English |
| CP024 | PART A � INITIAL CLAIM | alert | chat | Then the privacy alert is displayed |  |
| CP025 | PART A � INITIAL CLAIM | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP026 | PART A � INITIAL CLAIM | customer | chat | And the user says "My flight from Montreal to Toronto was delayed about 7 hours because the crew was late, I'd like to check if I'm eligible | My flight from Montreal to Toronto was delayed about 7 hours because the crew was late, I'd like to check if I'm eligible for compensation |
| CP027 | PART A � INITIAL CLAIM | system | implied | When the chatbot identifies flight disruption intent |  |
| CP028 | PART A � INITIAL CLAIM | system | implied | Then the chatbot checks third-party submission ? NO |  |
| CP029 | PART A � INITIAL CLAIM | bot | chat | Then the chatbot shows the legal disclaimer and the user agrees to start | Julien Gagnon PK008 552190 Your verification was successful. Let's proceed to the next step. I found 1 passenger on this booking: Julien Gagnon (Adult - Aeropla |
| CP030 | DDS EVALUATION | verdict | api | And DDS checks the cancellation code on MSL ? NONE |  |
| CP031 | DDS EVALUATION | verdict | api | And DDS checks the first arrival delay code on MSL ? 63 (FT) ? no fallback needed |  |
| CP032 | DDS EVALUATION | verdict | api | And DDS classifies 63 (FT) as WITHIN CARRIER CONTROL ? CONTROLLABLE |  |
| CP033 | DDS EVALUATION | verdict | api | And DDS calculates 420 min ? 6 to under 9 hrs ? Tier 2 |  |
| CP034 | DDS EVALUATION | verdict | api | And DDS returns ELIGIBLE, FD-APPR-EL-02, CAD 700 |  |
| CP035 | TRIP TRACER UI VALIDATION | verdict | api | Current: AC 412, ARRIVED LATE, 12:00 ? 19:00, Delay +7H 00M | Current: AC 412, ARRIVED LATE, 12:00 ? 19:00, Delay +7H 00M |
| CP036 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP037 | TRIP TRACER UI VALIDATION | verdict | api | MSL: AC 412 � YUL ? YYZ � 63 (FT) "Late crew boarding or departure procedures" | MSL: AC 412 � YUL ? YYZ � 63 (FT) "Late crew boarding or departure procedures" |
| CP038 | TRIP TRACER UI VALIDATION | verdict | api | Cancellation code: NONE ; Fallback: FALSE | Cancellation code: NONE ; Fallback: FALSE |
| CP039 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +7H 00M � CONTROLLABLE | Delay: +7H 00M � CONTROLLABLE |
| CP040 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: 9876543210 (Basic � linked) | Aeroplan: 9876543210 (Basic � linked) |
| CP041 | TRIP TRACER UI VALIDATION | verdict | api | MR JULIEN GAGNON / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet / [expiry date] | MR JULIEN GAGNON / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet / [expiry date] |
| CP042 | TRIP TRACER UI VALIDATION | verdict | api | CYBERSOURCE (GLOB-05): GREEN | CYBERSOURCE (GLOB-05): GREEN |
| CP043 | TRIP TRACER UI VALIDATION | verdict | api | ELIGIBLE RESULT (FD-05a): chatbot shows the APPR eligible message for AC 412, about 7 hours | ELIGIBLE RESULT (FD-05a): chatbot shows the APPR eligible message for AC 412, about 7 hours |
| CP044 | TRIP TRACER UI VALIDATION | verdict | api | CUSTOMER DROPS OFF: at the country of residence / payment step, the customer closes the chat without choosing a payout or completing IDV | CUSTOMER DROPS OFF: at the country of residence / payment step, the customer closes the chat without choosing a payout or completing IDV |
| CP045 | TRIP TRACER UI VALIDATION | verdict | api | Then the case is created with DDS = ELIGIBLE, CAD 700, and no payment instruction |  |
| CP046 | TRIP TRACER UI VALIDATION | verdict | api | And the case is routed to the agent queue to complete payout |  |
| CP047 | PART B � AGENT SENDS ACTION REQUIRED AND PARKS | system | implied | Given the agent pulls the case from My Activities (Assigned ? In Progress) |  |
| CP048 | PART B � AGENT SENDS ACTION REQUIRED AND PARKS | system | implied | When the agent reviews Decision Assist (ELIGIBLE, FD-APPR-EL-02, CAD 700) and confirms the assessment |  |
| CP049 | PART B � AGENT SENDS ACTION REQUIRED AND PARKS | idv | chat | And the agent sends "Decision Rendered � Action Required to Accept Compensation" with the secure deep link for IDV/payment | Decision Rendered � Action Required to Accept Compensation |
| CP050 | PART B � AGENT SENDS ACTION REQUIRED AND PARKS | system | implied | Then the case status becomes "Awaiting Customer Info (Compensation)" |  |
| CP051 | PART B � AGENT SENDS ACTION REQUIRED AND PARKS | system | implied | And the agent parks the case |  |
| CP052 | PART B � AGENT SENDS ACTION REQUIRED AND PARKS | system | implied | And the "Parked" banner is displayed |  |
| CP053 | PART B � AGENT SENDS ACTION REQUIRED AND PARKS | system | implied | And the 30-day customer response window starts (Aug 1 ? Aug 31) |  |
| CP054 | PART B � AGENT SENDS ACTION REQUIRED AND PARKS | system | implied | And the Audit Log records the notification, the park action, the date and the agent |  |
| CP055 | PART C � NO RESPONSE WITHIN 30 DAYS | system | implied | Given no customer response is received by the end of day 30 |  |
| CP056 | PART C � NO RESPONSE WITHIN 30 DAYS | system | implied | Then the case is closed for no response |  |
| CP057 | PART C � NO RESPONSE WITHIN 30 DAYS | system | implied | And the Parked banner is removed |  |
| CP058 | PART C � NO RESPONSE WITHIN 30 DAYS | system | implied | And the "Case Closed" banner is displayed |  |
| CP059 | PART C � NO RESPONSE WITHIN 30 DAYS | system | implied | And the secure payment link can no longer be used |  |
| CP060 | PART C � NO RESPONSE WITHIN 30 DAYS | system | implied | And no compensation record exists |  |
| CP061 | PART C � NO RESPONSE WITHIN 30 DAYS | system | implied | And the Audit Log records the closure reason (no customer response within 30 days) |  |
| CP062 | PART D � CUSTOMER REPLIES ON DAY 35 | system | implied | Given the customer comes back through the chatbot quoting the case reference, 35 days after the park date |  |
| CP063 | PART D � CUSTOMER REPLIES ON DAY 35 | system | implied | Then the system recognises that the reply is outside the 30-day window |  |
| CP064 | PART D � CUSTOMER REPLIES ON DAY 35 | system | implied | And the system does NOT treat it as a normal "Customer Response" on an open case |  |
| CP065 | PART D � CUSTOMER REPLIES ON DAY 35 | system | implied | And the system does NOT create a new separate FD case for the same passenger and journey |  |
| CP066 | PART D � CUSTOMER REPLIES ON DAY 35 | system | implied | And the original case is reopened with case type / source = Appeal |  |
| CP067 | PART D � CUSTOMER REPLIES ON DAY 35 | system | implied | And the "Appeal Pending" banner is displayed |  |
| CP068 | PART D � CUSTOMER REPLIES ON DAY 35 | system | implied | And the case status is "Appeal Review" (reopened) |  |
| CP069 | PART D � CUSTOMER REPLIES ON DAY 35 | system | implied | And the customer's reply is attached to Customer Communications |  |
| CP070 | PART D � CUSTOMER REPLIES ON DAY 35 | system | implied | And the case is routed to the appeal-handling queue / agent |  |
| CP071 | PART D � CUSTOMER REPLIES ON DAY 35 | system | implied | And the case history from before the reopen is kept under the same case ID |  |
| CP072 | PART D � CUSTOMER REPLIES ON DAY 35 | system | implied | And the SLA restarts for appeal handling |  |
| CP073 | PART E � AGENT HANDLES THE APPEAL | system | implied | Given the agent opens the reopened case from My Activities |  |
| CP074 | PART E � AGENT HANDLES THE APPEAL | verdict | api | When the agent reviews the original decision, notification, Trip Tracer, coding and prior payments |  |
| CP075 | PART E � AGENT HANDLES THE APPEAL | system | implied | Then the agent confirms there is no prior payment for this passenger and journey |  |
| CP076 | PART E � AGENT HANDLES THE APPEAL | verdict | api | And the agent confirms Code 63 and the 7h delay are unchanged in Trip Tracer |  |
| CP077 | PART E � AGENT HANDLES THE APPEAL | system | implied | And the agent confirms the APPR filing limit is still met (claim filed Jul 28, 2026, within 366 days) |  |
| CP078 | PART E � AGENT HANDLES THE APPEAL | system | implied | And the agent keeps the decision as ELIGIBLE, CAD 700 (no override needed) |  |
| CP079 | PART E � AGENT HANDLES THE APPEAL | system | implied | And the agent records an internal note: late customer reply handled as appeal, decision upheld as eligible |  |
| CP080 | PART E � AGENT HANDLES THE APPEAL | system | implied | And the agent sends "Decision Rendered � Action Required" again with a new secure link |  |
| CP081 | PART F � CUSTOMER COMPLETES PAYOUT | customer | chat | Given the customer opens the new secure link |  |
| CP082 | PART F � CUSTOMER COMPLETES PAYOUT | system | implied | Then country of residence = Canada ? Currency = CAD |  |
| CP083 | PART F � CUSTOMER COMPLETES PAYOUT | system | implied | And Aeroplan is checked: Basic Member, good standing |  |
| CP084 | PART F � CUSTOMER COMPLETES PAYOUT | system | implied | And both options are offered: Cash CAD 700 via Interac e-Transfer, or AC Wallet CAD 840 (20% bonus) |  |
| CP085 | PART F � CUSTOMER COMPLETES PAYOUT | customer | chat | And the customer selects "Cash" | Cash |
| CP086 | PART F � CUSTOMER COMPLETES PAYOUT | system | implied | And only the Interac email (j***@gmail.com) is confirmed; no other payment details are collected |  |
| CP087 | PART F � CUSTOMER COMPLETES PAYOUT | idv | chat | And Persona IDV runs ? PASS |  |
| CP088 | PART F � CUSTOMER COMPLETES PAYOUT | system | implied | And the claim is submitted ? compensation record CAD 700 is created |  |
| CP089 | PART F � CUSTOMER COMPLETES PAYOUT | email | email | And an eligible notification email is sent via Adobe (Case Reference, CAD 700, Interac, APPR, AC 412 YUL ? YYZ, Code 63) |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given case "PK008" for claimant "Julien Gagnon" was parked on Aug 1, 2026 awaiting customer compensation action |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no customer response was received within 30 days |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the case should have been closed for no response on Aug 31, 2026 |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the customer replies on Sep 5, 2026 |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the same case should be reopened (no new case ID) |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case type / source should show "Appeal" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the "Appeal Pending" banner should be displayed |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the "Customer Response" banner should NOT be shown as a normal in-window response |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the status should be "Appeal Review" / "Reopened" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Topic/Sub-topic should remain "Travel Disruptions � Delay" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Julien Gagnon", Claimant Type "Adult", Authentication "Pass" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "PK008" with PNR Creation Date, Journey ID, Booking Source and Booking Office ID populated |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "9876543210" linked, Tier Status "Basic / Member" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 63) |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should show ELIGIBLE, FD-APPR-EL-02, CAD 700 |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should show no separate duplicate case created by the late reply |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record in order: case created, Action Required sent, parked, 30-day window expired, closed, customer late reply, re |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show both Action Required emails, the customer's late reply and the eligible notification |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcripts should be linked |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" after payment |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be read-only after resolution |  |
| CP113 | PAYMENT VALIDATION | payment | chat | Given the case was closed with no payment instruction |  |
| CP114 | PAYMENT VALIDATION | payment | chat | Then no compensation record should exist before the appeal |  |
| CP115 | PAYMENT VALIDATION | payment | chat | When the appeal is upheld and the customer completes the new secure link |  |
| CP116 | PAYMENT VALIDATION | payment | chat | Then country of residence should be "Canada" and currency "CAD" |  |
| CP117 | PAYMENT VALIDATION | payment | chat | And both Cash (CAD 700) and AC Wallet (CAD 840) should be offered |  |
| CP118 | PAYMENT VALIDATION | payment | chat | And the customer selects "Cash" ? Interac e-Transfer |  |
| CP119 | PAYMENT VALIDATION | payment | chat | And only the email "j***@gmail.com" should be collected |  |
| CP120 | PAYMENT VALIDATION | payment | chat | And exactly one compensation record of CAD 700 should be created |  |
| CP121 | PAYMENT VALIDATION | payment | manual | And it should be picked up by the daily evening batch file and dispatched to Unifier |  |
| CP122 | PAYMENT VALIDATION | payment | manual | And Unifier should acknowledge |  |
| CP123 | PAYMENT VALIDATION | payment | manual | And the Interac end-of-day status should move Pending ? Cashed / Rejected / Expired |  |
| CP124 | PAYMENT VALIDATION | payment | manual | And an unclaimed Interac payment should expire after 35 days |  |
| CP125 | PAYMENT VALIDATION | payment | manual | And the Compensation tab should show CAD 700, Cash � Interac, status updated via talkback |  |
| CP126 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-02, CAD 700 (APPR, Code 63 controllable, 7h). | DDS returns FD-APPR-EL-02, CAD 700 (APPR, Code 63 controllable, 7h). |
| CP127 | EXPECTED RESULTS | verdict | chat | The case parks, then closes after 30 days with no response. | The case parks, then closes after 30 days with no response. |
| CP128 | EXPECTED RESULTS | verdict | chat | The late reply on day 35 reopens the same case as an Appeal (Appeal Pending, Appeal Review). | The late reply on day 35 reopens the same case as an Appeal (Appeal Pending, Appeal Review). |
| CP129 | EXPECTED RESULTS | verdict | chat | It isn't a new case and isn't a normal customer response. | It isn't a new case and isn't a normal customer response. |
| CP130 | EXPECTED RESULTS | verdict | chat | The appeal is upheld as Eligible, and the customer is paid CAD 700 cash by Interac (email only). | The appeal is upheld as Eligible, and the customer is paid CAD 700 cash by Interac (email only). |
| CP131 | EXPECTED RESULTS | verdict | chat | There's one compensation record and a full audit trail. | There's one compensation record and a full audit trail. |
