# SOC_UAT_024 · CHAI-31939 — checkpoints

**Goal:** Verify that when the customer's last leg landed < 72 hours ago, the system applies the 72-hour hold, creates a shell case, and sends the customer away with email confirmation.

Methods: seed 11, chat 55, api 3, email 1, dashboard 51, implied 22, manual 7, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify that when the customer's last leg landed < 72 hours ago, the system applies the 72-hour hold, creates a shell case, and sends the cus |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 201 YYZ?YUL | � Itinerary: Single segment � AC 201 YYZ?YUL |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 201 YYZ?YUL | � SOC Segment (per SoC Flight Identifier): AC 201 YYZ?YUL |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 201 YYZ?YUL, Dep: [today-1] 08:00 | � Promised Itinerary: AC 201 YYZ?YUL, Dep: [today-1] 08:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 201 YYZ?YUL, Dep: [today-1] 14:00 | � Actual Itinerary: AC 201 YYZ?YUL, Dep: [today-1] 14:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 360 min (6 hours) | � Departure Delay: 360 min (6 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Controllability: TBD � within 72-hour window | � Controllability: TBD � within 72-hour window |
| CP009 | PREREQUISITES | prerequisite | seed | � Departure delay code: TBD � pending RE evaluation | � Departure delay code: TBD � pending RE evaluation |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP011 | PREREQUISITES | prerequisite | seed | � Check Order: 72-hour check ? FAIL (< 72h) ? PENDING | � Check Order: 72-hour check ? FAIL (< 72h) ? PENDING |
| CP012 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: < 72h | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: < 72h |
| CP013 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP014 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP015 | START | customer | chat | Then user selects English |  |
| CP016 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP017 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP018 | START | customer | chat | And the user says "I just landed yesterday and my flight was delayed by about 6 hours. I had to buy food and pay for a taxi. Can I get reimb | I just landed yesterday and my flight was delayed by about 6 hours. I had to buy food and pay for a taxi. Can I get reimbursed for what I spent? |
| CP019 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP020 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP021 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP034 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP036 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP037 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP038 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 201 � Route: Toronto (YYZ) ? Montreal (YUL) � Date: June 7, 2026 � Departure Delay: 6 hours Is this the journey you' |
| CP039 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP040 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP041 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP042 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination | 72-HOUR CHECK: ? FLOW STOPS HERE � PENDING |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey: | � Last leg Departure: June 7, 2026 � Current date: June 8, 2026 � Hours elapsed: ~24 hours � 24 hours < 72 hours ? WITHIN 72-HOUR WINDOW ? PENDING ? |
| CP045 | ? FLOW DOES NOT PROCEED TO | system | implied | ? Claim Time Limit Check � SKIPPED | ? Triage Eligibility Check (SoC-02b) � SKIPPED ? Airline Company Routing � SKIPPED ? DDS Evaluation � SKIPPED ? Fraud Screening � SKIPPED ? Receipt Upload � SKI |
| CP046 | SHELL CASE CREATION | system | implied | Then the system creates a SHELL case in Case Services |  |
| CP047 | SHELL CASE CREATION | system | implied | And the shell case includes: | � Case type: Shell (pending � awaiting 72-hour window closure) � Passenger: [First Name] [Last Name] � PNR: [PNR Code] � Journey: AC 201 YYZ?YUL, June 7, 2026 � |
| CP048 | SHELL CASE CREATION | system | implied | And the case is placed in the polling queue for 72-hour retrigger | DDS RESPONSE CODE = SoC-APPR-PE-01 (PENDING) |
| CP049 | PENDING RESULT | bot | chat | Then the chatbot displays: "Thank you for submitting your claim details. Your flight AC 201 from Toronto to Montreal arrived recently, and w | Thank you for submitting your claim details. Your flight AC 201 from Toronto to Montreal arrived recently, and we need a little more time to gather all the nece |
| CP050 | PENDING RESULT | bot | chat | Then the chatbot responds: | Here's what will happen next: � We've created a reference for your claim: [Shell Case Reference] � Our system will automatically evaluate your eligibility once  |
| CP051 | DEEP LINK NOTIFICATION | system | implied | NOTE: The following happens AUTOMATICALLY after 72 hours � the passenger does not need to take any action. | After 72 hours (approximately June 10, 2026): |
| CP052 | DEEP LINK NOTIFICATION | system | implied | Then the system's polling queue triggers a re-evaluation |  |
| CP053 | DEEP LINK NOTIFICATION | system | implied | And the Rules Engine (RE) retrieves complete flight data: | � Actual departure time: confirmed � Actual Departure time: confirmed � Departure delay code: populated (e.g., 41 � Crew Scheduling) � Operating data: complete |
| CP054 | DEEP LINK NOTIFICATION | email | email | Then the DDS evaluates eligibility with complete data: | � If ELIGIBLE: Deep link email sent to passenger ? passenger clicks link ? returns to chatbot ? enters Welcome Back flow ? uploads receipts ? OCR validation ? c |
| CP055 | WELCOME BACK FLOW | system | implied | Then the passenger receives an email from Air Canada: | "Good news! We've reviewed the details of your flight AC 201 from Toronto to Montreal, and you are eligible for expense reimbursement. Please click the link bel |
| CP056 | WELCOME BACK FLOW | system | implied | And the email includes: | � Deep link to chatbot with pre-populated claim data � Case reference number � Expiry date for completing the claim |
| CP057 | WELCOME BACK FLOW | system | implied | Then the passenger clicks the deep link |  |
| CP058 | WELCOME BACK FLOW | system | implied | And the chatbot opens with pre-populated data: | "Welcome back, [First Name]! We've determined that you are eligible for expense reimbursement for your flight AC 201 from Toronto to Montreal on June 7, 2026. T |
| CP059 | WELCOME BACK FLOW | system | implied | Then the chatbot proceeds to: | � Receipt upload flow � OCR validation � Expense breakdown � Case creation � Payment flow (Same as EL-08 detailed steps from receipt upload onwards) |
| CP060 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP061 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP062 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP063 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-PE-01 � 72-Hour Hold Pending |  |
| CP064 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP065 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "System Processing ??" |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date is populated as June 8, 2026 |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date is populated as June 8, 2026 |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the SLA is 72-hour processing window |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is "N/A (system processing � not assigned to agent)" |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (Auth Flow 1) |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is pending (DDS not yet run) |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date is populated |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID is populated |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source is populated |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID is populated |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "TBD (pending evaluation)" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Regular" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 201 YYZ ? YUL as the claimed flight |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (6 hours � preliminary)" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 201 YYZ ? YUL |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 201 |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "TBD � pending 72-hour data completion" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is approximately 360 min (preliminary � subject to confirmation) |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed Departure)" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "TBD � pending Departure delay code" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-PE-01 (PENDING)" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Polling Status is "ACTIVE � system will re-evaluate after 72h" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "NOT YET PERFORMED" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "PENDING" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the last leg Departure is June 7, 2026 |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the filing date is June 8, 2026 |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the hours elapsed is approximately 24 hours |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And 24 hours is less than 72 hours so the case is WITHIN 72-HOUR WINDOW and PENDING |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the scheduled DDS Run is approximately June 10, 2026 |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the flow is STOPPED at 72-hour check with the following SKIPPED: Claim Time Limit Check, Triage Eligibility Check (SoC-02b), Airline Com |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (pending eligibility determination)" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "N/A (pending)" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered (pending) |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system processing queue is visible to management only (not agents) |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And agents cannot see or action cases in system processing queue |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And once 72h passes the case moves to appropriate queue |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Current Status is "System Processing (Pending � 72-hour hold)" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is NOT in read-only mode (will be updated after DDS runs post-72h) |  |
| CP116 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-PE-01 � 72-Hour Hold Pending |  |
| CP117 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-PE-01 is PENDING |  |
| CP118 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered at this stage |  |
| CP119 | PAYMENT VALIDATION | payment | chat | And a shell case is created in System Processing Queue |  |
| CP120 | PAYMENT VALIDATION | payment | chat | And the route is AC 201 YYZ ? YVR with delay 360 min (6 hrs) filed less than 72 hrs since Departure |  |
| CP121 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP122 | PAYMENT VALIDATION | payment | chat | And no receipts are uploaded |  |
| CP123 | PAYMENT VALIDATION | payment | chat | And no CyberSource fraud check is triggered |  |
| CP124 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP125 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP126 | PAYMENT VALIDATION | payment | chat | And no GL account or cost center is assigned |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And the system polls DDS for up to 14 days |  |
| CP128 | PAYMENT VALIDATION | payment | chat | And after 72h if DDS returns ELIGIBLE then a deep link email is sent to customer |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And the customer returns to chatbot and uploads receipts for OCR validation |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And SOC is Cash only (no AC Wallet / e-credit for SOC) |  |
| CP131 | PAYMENT VALIDATION | payment | manual | And country of residence is asked and Canada maps to CAD with Interac via Unifier |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And entitlements are applied based on delay category for 1 adult PY no ACR: Meals $30, Hotel rate of day 3 nights max $500 cap, Transport $2 |  |
| CP133 | PAYMENT VALIDATION | payment | chat | And receipts are validated against entitlement thresholds |  |
| CP134 | PAYMENT VALIDATION | payment | chat | And compensation record is created with GL accounts per category and cost center CR 503 |  |
| CP135 | PAYMENT VALIDATION | payment | chat | And approval threshold check is based on total approved amount |  |
| CP136 | PAYMENT VALIDATION | payment | manual | And batch file is triggered to Unifier and end-of-day report is generated |  |
| CP137 | PAYMENT VALIDATION | payment | manual | And Claims Dashboard Compensation tab is populated with amount CAD, Cash, Interac, status via talkback |  |
| CP138 | PAYMENT VALIDATION | payment | chat | And after 72h if DDS returns NOT ELIGIBLE then rejection email is sent to passenger |  |
| CP139 | PAYMENT VALIDATION | payment | manual | And the case is auto-closed with no compensation record, no batch file, and no payment |  |
| CP140 | PAYMENT VALIDATION | payment | chat | And Claims Dashboard shows NOT ELIGIBLE with no payout section |  |
| CP141 | PAYMENT VALIDATION | payment | chat | And if no DDS answer after 14 days then the case is sent to agent queue for manual handling |  |
| CP142 | PAYMENT VALIDATION | payment | chat | And the agent investigates and manually determines outcome |  |
| CP143 | PAYMENT VALIDATION | payment | chat | And Claims Dashboard while pending shows Case status = "Pending / System Processing" with no payout section |  |
| CP144 | EXPECTED RESULTS | verdict | chat | SoC-APPR-PE-01. | SoC-APPR-PE-01. |
| CP145 | EXPECTED RESULTS | verdict | chat | PENDING. | PENDING. |
| CP146 | EXPECTED RESULTS | verdict | chat | Last leg <72h ago. | Last leg <72h ago. |
| CP147 | EXPECTED RESULTS | verdict | chat | Shell case created. | Shell case created. |
| CP148 | EXPECTED RESULTS | verdict | chat | Placed in polling queue. | Placed in polling queue. |
| CP149 | EXPECTED RESULTS | verdict | chat | Passenger informed of pending status. | Passenger informed of pending status. |
| CP150 | EXPECTED RESULTS | verdict | api | After 72h window: RE retrigger ? DDS evaluation ? deep link sent if eligible. | After 72h window: RE retrigger ? DDS evaluation ? deep link sent if eligible. |
| CP151 | EXPECTED RESULTS | verdict | chat | No receipt upload at this stage. | No receipt upload at this stage. |
