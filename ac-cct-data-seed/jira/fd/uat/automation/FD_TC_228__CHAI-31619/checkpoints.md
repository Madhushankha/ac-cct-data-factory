# FD_TC_228 · CHAI-31619 — checkpoints

**Goal:** Checks that a parked eligible case goes back to the agent when the customer replies in time. Flight AC 412 YUL ? YYZ arrived 7 hours late for a controllable reason (Code 96). DDS returns FD-APPR-EL-02, CAD 700. The customer leaves the chat before finishing payment, so the case is created as Eligible with no payment instruction. The agent sends "Decision Rendered � Action Required" with the secure IDV/payment link and parks the case (Awaiting Customer Info � Compensation). On day 19, which is inside the 30-day window, the customer replies. The system must unpark the case automatically, show the Customer Response banner and set the status to Assigned for the same agent. It must not close the case, must not treat the reply as an appeal, and must not create a new case. The agent then pulls the case and the customer completes payout. Basic Aeroplan is linked, so Cash (CAD 700) and AC Wallet (CAD 840) are both offered. The customer lives in Canada and picks Cash, so payment goes by Interac and only the email is collected.

Methods: seed 14, chat 30, api 12, email 1, implied 93, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Checks that a parked eligible case goes back to the agent when the customer replies in time. Flight AC 412 YUL ? YYZ arrived 7 hours late fo |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: PK006 � single passenger Chlo� Lavoie (Adult, Basic Aeroplan Member 9876543210, good standing) | PNR: PK006 � single passenger Chlo� Lavoie (Adult, Basic Aeroplan Member 9876543210, good standing) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC domestic YUL ? YYZ (AC 412), July 20, 2026 | Journey: 1 leg AC domestic YUL ? YYZ (AC 412), July 20, 2026 |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival 12:00, actual arrival 19:00 (7h delay) | Scheduled arrival 12:00, actual arrival 19:00 (7h delay) |
| CP005 | PREREQUISITES | prerequisite | seed | Arrival delay code 96 (Operations Control � Controllable) | Arrival delay code 96 (Operations Control � Controllable) |
| CP006 | PREREQUISITES | prerequisite | seed | Status: Travelled, arrived late | Status: Travelled, arrived late |
| CP007 | PREREQUISITES | prerequisite | seed | No VOL/INVOL changes | No VOL/INVOL changes |
| CP008 | PREREQUISITES | prerequisite | seed | AC only | AC only |
| CP009 | PREREQUISITES | prerequisite | seed | Claim filed July 28, 2026 (more than 72 hrs, within 366 days) | Claim filed July 28, 2026 (more than 72 hrs, within 366 days) |
| CP010 | PREREQUISITES | prerequisite | seed | No duplicate | No duplicate |
| CP011 | PREREQUISITES | prerequisite | seed | Not employee, not infant | Not employee, not infant |
| CP012 | PREREQUISITES | prerequisite | implied | CyberSource GREEN | CyberSource GREEN |
| CP013 | PREREQUISITES | prerequisite | seed | Country of residence: Canada | Country of residence: Canada |
| CP014 | PREREQUISITES | prerequisite | seed | Park date: Aug 1, 2026 | Park date: Aug 1, 2026 |
| CP015 | PREREQUISITES | prerequisite | seed | 30-day window ends: Aug 31, 2026 | 30-day window ends: Aug 31, 2026 |
| CP016 | PREREQUISITES | prerequisite | seed | Customer reply: Aug 20, 2026 (day 19) | Customer reply: Aug 20, 2026 (day 19) |
| CP017 | PART A � INITIAL CLAIM | customer | chat | Given the user opens the agentic chatbot |  |
| CP018 | PART A � INITIAL CLAIM | bot | chat | Then the chatbot displays greeting (GLOB-01): "Hello! I will be your virtual assistant today. I can assist you in English or French. Which l | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP019 | PART A � INITIAL CLAIM | customer | chat | Then user selects "English" | English |
| CP020 | PART A � INITIAL CLAIM | alert | chat | Then the privacy alert is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI to a | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP021 | PART A � INITIAL CLAIM | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP022 | PART A � INITIAL CLAIM | customer | chat | And the user says "My flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if I'm eligible for compensation" | My flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if I'm eligible for compensation |
| CP023 | PART A � INITIAL CLAIM | system | implied | When the chatbot identifies flight disruption intent |  |
| CP024 | PART A � INITIAL CLAIM | system | implied | Then the chatbot checks third-party submission ? NO |  |
| CP025 | PART A � INITIAL CLAIM | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP026 | LEGAL DISCLAIMER | bot | chat | Then the chatbot shows the automated decision-making disclaimer and asks "Would you like to get started?" | Would you like to get started? |
| CP027 | LEGAL DISCLAIMER | customer | chat | And the user confirms "Yes" | Yes |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | Then the chatbot asks for full name ? user provides "Chlo� Lavoie" | Chlo� Lavoie |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | Then the chatbot responds: "Thanks, Chlo�! And, what is your booking reference number?" ? user provides "PK006" | Thanks, Chlo�! And, what is your booking reference number? PK006 |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | Then Trip Tracer returns PNR FOUND (Auth Flow 1) |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot offers OTP by Email c***@gmail.com or Phone +1456 |  |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects Email ? enters OTP "418263" ? CORRECT (attempt 1 of 5) | 418263 |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP034 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | system | implied | Then group booking identifier = NOT PRESENT |  |
| CP035 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays: "I found 1 passenger on this booking: Chlo� Lavoie (Adult - Aeroplan Member). Is this who you'd like to include?"  | I found 1 passenger on this booking: Chlo� Lavoie (Adult - Aeroplan Member). Is this who you'd like to include? Yes |
| CP036 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | system | implied | Then PAX count = 1 ? 9 or fewer ? PROCEED |  |
| CP037 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot displays: Flight AC 412, Montreal (YUL) ? Toronto (YYZ), July 20, 2026, Arrival Delay 7 hours ? user "Yes" | Yes |
| CP038 | CHECKS | system | implied | Then single leg ? skip GenUC-18 |  |
| CP039 | CHECKS | system | implied | And duplicate check ? NO existing case |  |
| CP040 | CHECKS | system | implied | And 72-hour check ? more than 72 hours ? PROCEED |  |
| CP041 | CHECKS | system | implied | And APPR filing limit ? 8 days (within 366 days) ? PROCEED |  |
| CP042 | DDS EVALUATION | verdict | api | Regime APPR; Code 96 Controllable; 420 min ? 6 to under 9 hrs; ELIGIBLE; FD-APPR-EL-02; CAD 700 |  |
| CP043 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary: AC 412, Status ARRIVED LATE, 12:00 ? 19:00, Delay +7H 00M | Current Itinerary: AC 412, Status ARRIVED LATE, 12:00 ? 19:00, Delay +7H 00M |
| CP044 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP045 | TRIP TRACER UI VALIDATION | verdict | api | MSL Flight: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" | MSL Flight: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" |
| CP046 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +7H 00M � CONTROLLABLE | Delay: +7H 00M � CONTROLLABLE |
| CP047 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: 9876543210 (Basic Member � linked) | Aeroplan: 9876543210 (Basic Member � linked) |
| CP048 | TRIP TRACER UI VALIDATION | verdict | api | MS CHLO� LAVOIE / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet / [expiry date] | MS CHLO� LAVOIE / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet / [expiry date] |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | FRAUD SCREENING � CYBERSOURCE (GLOB-05): GREEN LIGHT | FRAUD SCREENING � CYBERSOURCE (GLOB-05): GREEN LIGHT |
| CP050 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: "I've checked your flight details, and it looks like flight AC 412 from Montreal (YUL) to Toronto (YYZ) was delay | I've checked your flight details, and it looks like flight AC 412 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7 hours. Based on the Air Passenger  |
| CP051 | CUSTOMER DROPS OFF | bot | chat | When the chatbot asks "In which country will your reimbursement be deposited?" | In which country will your reimbursement be deposited? |
| CP052 | CUSTOMER DROPS OFF | system | implied | Then the customer closes the chat without answering |  |
| CP053 | CUSTOMER DROPS OFF | verdict | api | And the case is created with DDS = ELIGIBLE, CAD 700, and no payment instruction |  |
| CP054 | CUSTOMER DROPS OFF | system | implied | And the case is routed to the agent queue to complete payout |  |
| CP055 | PART B � AGENT SENDS ACTION REQUIRED AND PARKS | system | implied | Given the agent pulls the case from My Activities (Assigned ? In Progress) |  |
| CP056 | PART B � AGENT SENDS ACTION REQUIRED AND PARKS | system | implied | When the agent reviews Decision Assist (ELIGIBLE, FD-APPR-EL-02, CAD 700) and confirms it |  |
| CP057 | PART B � AGENT SENDS ACTION REQUIRED AND PARKS | idv | chat | And the agent sends "Decision Rendered � Action Required to Accept Compensation" with the secure IDV/payment link to c@gmail.com | Decision Rendered � Action Required to Accept Compensation |
| CP058 | PART B � AGENT SENDS ACTION REQUIRED AND PARKS | system | implied | Then the case status becomes "Awaiting Customer Info (Compensation)" |  |
| CP059 | PART B � AGENT SENDS ACTION REQUIRED AND PARKS | system | implied | And the agent parks the case |  |
| CP060 | PART B � AGENT SENDS ACTION REQUIRED AND PARKS | system | implied | And the "Parked" banner is displayed |  |
| CP061 | PART B � AGENT SENDS ACTION REQUIRED AND PARKS | system | implied | And the 30-day customer response window starts (Aug 1 ? Aug 31) |  |
| CP062 | PART B � AGENT SENDS ACTION REQUIRED AND PARKS | system | implied | And the case is no longer in the agent's active work list while parked |  |
| CP063 | PART B � AGENT SENDS ACTION REQUIRED AND PARKS | system | implied | And the Audit Log records the notification, park action, date and agent |  |
| CP064 | PART C � CUSTOMER REPLIES ON DAY 19 | system | implied | Given the customer replies to the Action Required email / case link on Aug 20, 2026 |  |
| CP065 | PART C � CUSTOMER REPLIES ON DAY 19 | system | implied | And the reply says "I'd like to receive my compensation, please confirm the next step" |  |
| CP066 | PART C � CUSTOMER REPLIES ON DAY 19 | system | implied | Then the system recognises the reply is within the 30-day window |  |
| CP067 | PART C � CUSTOMER REPLIES ON DAY 19 | system | implied | And the case is unparked automatically |  |
| CP068 | PART C � CUSTOMER REPLIES ON DAY 19 | system | implied | And the "Parked" banner is removed |  |
| CP069 | PART C � CUSTOMER REPLIES ON DAY 19 | system | implied | And the "Customer Response" banner is displayed |  |
| CP070 | PART C � CUSTOMER REPLIES ON DAY 19 | system | implied | And the case status changes to "Assigned" |  |
| CP071 | PART C � CUSTOMER REPLIES ON DAY 19 | system | implied | And the case is assigned back to the same agent who parked it |  |
| CP072 | PART C � CUSTOMER REPLIES ON DAY 19 | system | implied | And the case appears in that agent's My Activities / queue |  |
| CP073 | PART C � CUSTOMER REPLIES ON DAY 19 | system | implied | And the reply is attached to Customer Communications |  |
| CP074 | PART C � CUSTOMER REPLIES ON DAY 19 | system | implied | And the case is NOT closed |  |
| CP075 | PART C � CUSTOMER REPLIES ON DAY 19 | system | implied | And the case is NOT reopened as an Appeal (no "Appeal Pending" banner) |  |
| CP076 | PART C � CUSTOMER REPLIES ON DAY 19 | system | implied | And no new FD case is created for the same passenger and journey |  |
| CP077 | PART C � CUSTOMER REPLIES ON DAY 19 | system | implied | And the original secure link is still valid (window not expired) |  |
| CP078 | PART C � CUSTOMER REPLIES ON DAY 19 | system | implied | And the Audit Log records: customer reply received, unpark (system), status Awaiting Customer Info ? Assigned |  |
| CP079 | PART D � AGENT HANDLES THE RESPONSE | system | implied | Given the agent pulls the case from My Activities |  |
| CP080 | PART D � AGENT HANDLES THE RESPONSE | system | implied | Then the status changes Assigned ? In Progress |  |
| CP081 | PART D � AGENT HANDLES THE RESPONSE | system | implied | When the agent reviews the customer reply |  |
| CP082 | PART D � AGENT HANDLES THE RESPONSE | system | implied | Then the agent confirms the decision is unchanged: ELIGIBLE, FD-APPR-EL-02, CAD 700 (no override) |  |
| CP083 | PART D � AGENT HANDLES THE RESPONSE | system | implied | And the agent tells the customer to use the secure link to finish the payment step (or re-sends it if needed) |  |
| CP084 | PART D � AGENT HANDLES THE RESPONSE | system | implied | And the agent records an internal note: customer responded within 30 days, case unparked, proceeding to payout |  |
| CP085 | PART E � CUSTOMER COMPLETES PAYOUT | customer | chat | Given the customer opens the secure link |  |
| CP086 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | Then country of residence = Canada ? Currency = CAD |  |
| CP087 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the Aeroplan check shows Basic Member, good standing |  |
| CP088 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And both options are offered: "Cash: $700 CAD will be sent via Interac e-Transfer and takes 5 to 10 business days to process." / "AC Wallet: |  |
| CP089 | PART E � CUSTOMER COMPLETES PAYOUT | customer | chat | And the customer selects "Cash" | Cash |
| CP090 | PART E � CUSTOMER COMPLETES PAYOUT | customer | chat | And the customer confirms the Interac email c***@gmail.com; no other payment details are collected |  |
| CP091 | PART E � CUSTOMER COMPLETES PAYOUT | idv | chat | And Persona IDV runs ? IDV PASS |  |
| CP092 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the customer reviews "Deposit Amount: $700 CAD, Payment Method: Interac e-Transfer (c***@gmail.com)" and submits |  |
| CP093 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | Then a compensation record for CAD 700 is created |  |
| CP094 | PART E � CUSTOMER COMPLETES PAYOUT | email | email | And an eligible notification email is sent via Adobe (Case Reference, CAD 700, Interac e-Transfer, APPR, AC 412 YUL ? YYZ, Code 96) | Claims Dashboard Gherkin: |
| CP095 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | Given case "PK006" for claimant "Chlo� Lavoie" was parked on Aug 1, 2026 as "Awaiting Customer Info (Compensation)" |  |
| CP096 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | When the customer replies on Aug 20, 2026 (within 30 days) |  |
| CP097 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | Then the case should be unparked automatically |  |
| CP098 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the "Parked" banner should be removed |  |
| CP099 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the "Customer Response" banner should be displayed |  |
| CP100 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the status should be "Assigned" |  |
| CP101 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the assignee should be the agent who parked the case |  |
| CP102 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And no "Appeal Pending" banner should be displayed |  |
| CP103 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the case should keep the same Case ID (no new case) |  |
| CP104 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP105 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP106 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the Created and Last Updated dates should be populated |  |
| CP107 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the SLA countdown should be tracking correctly |  |
| CP108 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the Claimant Name should be "Chlo� Lavoie", Claimant Type "Adult", Authentication "Pass" |  |
| CP109 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the PNR should be "PK006" with PNR Creation Date, Journey ID, Booking Source and Booking Office ID populated |  |
| CP110 | PART E � CUSTOMER COMPLETES PAYOUT | verdict | api | And the Regime should be "APPR" | APPR |
| CP111 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the Tags should include "Claimant" and "Adult" |  |
| CP112 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the Email should be "c***@gmail.com" and the Phone "+1456" |  |
| CP113 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the Address should be populated |  |
| CP114 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the Aeroplan should be "9876543210" linked, Tier Status "Basic / Member" |  |
| CP115 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 96) |  |
| CP116 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the Ancillary Fee section should be present and empty |  |
| CP117 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the Decision Assist panel should show ELIGIBLE, FD-APPR-EL-02, CAD 700 and should NOT be greyed out |  |
| CP118 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the Duplicate Check should show "No duplicate found" and no Duplicate Warning Banner |  |
| CP119 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the Related Cases tab should show no related cases |  |
| CP120 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the CyberSource result should be "GREEN" |  |
| CP121 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | When the agent pulls the case from My Activities |  |
| CP122 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | Then the status should change from "Assigned" to "In Progress" |  |
| CP123 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the Audit Log should record in order: case created, Action Required sent, parked, customer reply, unparked, Assigned, In Progress, payou |  |
| CP124 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And Customer Communications should show the Action Required email, the customer reply and the eligible notification in date order |  |
| CP125 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the chatbot transcript should be accessible and linked |  |
| CP126 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the Attachments tab should be empty |  |
| CP127 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the Final Status should be "Resolved" after payment |  |
| CP128 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the case should be read-only after resolution |  |
| CP129 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the agent should not be able to access Case Search as it is for leads and management only | Payment Validation Gherkin: |
| CP130 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | Given the case was unparked within 30 days and the decision is ELIGIBLE, CAD 700 |  |
| CP131 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | Then no compensation record should exist before the customer completes the secure link |  |
| CP132 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | When the customer completes the secure link |  |
| CP133 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | Then country of residence should be "Canada" and currency "CAD" |  |
| CP134 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And both Cash (CAD 700) and AC Wallet (CAD 840) should be offered |  |
| CP135 | PART E � CUSTOMER COMPLETES PAYOUT | customer | chat | And the customer selects "Cash" ? payment method = Interac e-Transfer | Cash |
| CP136 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And AC Wallet should NOT be dispatched |  |
| CP137 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And only the email "c@gmail.com" should be collected |  |
| CP138 | PART E � CUSTOMER COMPLETES PAYOUT | idv | chat | And Persona IDV should PASS before payout |  |
| CP139 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And exactly one compensation record of CAD 700 should be created |  |
| CP140 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And it should be picked up by the daily evening batch file and dispatched to Unifier |  |
| CP141 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And in UAT the batch file should be triggered manually with the Unifier team |  |
| CP142 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And Unifier should send an acknowledgement back |  |
| CP143 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the Interac end-of-day status should move Pending ? Cached / Rejected / Expired |  |
| CP144 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And an unclaimed Interac payment should be set to Expired after 35 days |  |
| CP145 | PART E � CUSTOMER COMPLETES PAYOUT | system | implied | And the Compensation tab should show CAD 700, Cash � Interac e-Transfer, status updated via talkback |  |
| CP146 | EXPECTED RESULTS | verdict | api | DDS FD-APPR-EL-02, CAD 700 (APPR, Code 96 Controllable, 7h, Tier 2). | DDS FD-APPR-EL-02, CAD 700 (APPR, Code 96 Controllable, 7h, Tier 2). |
| CP147 | EXPECTED RESULTS | verdict | chat | The case parks on Aug 1. | The case parks on Aug 1. |
| CP148 | EXPECTED RESULTS | verdict | chat | The customer replies on day 19, inside the 30-day window. | The customer replies on day 19, inside the 30-day window. |
| CP149 | EXPECTED RESULTS | verdict | chat | The case unparks automatically, shows the Customer Response banner and goes back to Assigned for the same agent. | The case unparks automatically, shows the Customer Response banner and goes back to Assigned for the same agent. |
| CP150 | EXPECTED RESULTS | verdict | chat | It is not closed, not treated as an appeal and no new case is created. | It is not closed, not treated as an appeal and no new case is created. |
| CP151 | EXPECTED RESULTS | verdict | chat | The agent pulls it (In Progress) and the customer is paid CAD 700 Cash via Interac (email only), with one compensation record and a full aud | The agent pulls it (In Progress) and the customer is paid CAD 700 Cash via Interac (email only), with one compensation record and a full audit trail. |
