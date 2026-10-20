# SOC_UAT_076 · CHAI-31990 — checkpoints

**Goal:** Verify 72-hour hold applied when last leg landed < 72h ago under ASL regime.

Methods: seed 18, chat 56, api 3, email 1, dashboard 16, implied 22, manual 6, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify 72-hour hold applied when last leg landed < 72h ago under ASL regime. |  |
| CP002 | PREREQUISITES | prerequisite | seed | Regime: ASL | Regime: ASL |
| CP003 | PREREQUISITES | prerequisite | seed | Carrier: AC (AC 085 TLV?YYZ) | Carrier: AC (AC 085 TLV?YYZ) |
| CP004 | PREREQUISITES | prerequisite | seed | Promised Itinerary: AC 085 TLV?YYZ, Dep: [today-1] 16:00, Arr: [today-1] 22:00 | Promised Itinerary: AC 085 TLV?YYZ, Dep: [today-1] 16:00, Arr: [today-1] 22:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual Itinerary: AC 085 TLV?YYZ, Dep: [today-1] 22:00, Arr: [today] 04:00 | Actual Itinerary: AC 085 TLV?YYZ, Dep: [today-1] 22:00, Arr: [today] 04:00 |
| CP006 | PREREQUISITES | prerequisite | seed | Delay Length: 360 min (6 hours) | Delay Length: 360 min (6 hours) |
| CP007 | PREREQUISITES | prerequisite | seed | Controllability: TBD | Controllability: TBD |
| CP008 | PREREQUISITES | prerequisite | seed | within 72-hour window | within 72-hour window |
| CP009 | PREREQUISITES | prerequisite | seed | Departure delay code: TBD | Departure delay code: TBD |
| CP010 | PREREQUISITES | prerequisite | seed | pending RE evaluation | pending RE evaluation |
| CP011 | PREREQUISITES | prerequisite | seed | Note: Under ASL, controllability won't matter for SOC even after 72h (same as EU), but system still waits for complete data | Note: Under ASL, controllability won't matter for SOC even after 72h (same as EU), but system still waits for complete data |
| CP012 | PREREQUISITES | prerequisite | seed | Passenger Type: Regular | Passenger Type: Regular |
| CP013 | PREREQUISITES | prerequisite | seed | Check Order: 72-hour check ? FAIL (< 72h) ? PENDING | Check Order: 72-hour check ? FAIL (< 72h) ? PENDING |
| CP014 | PREREQUISITES | prerequisite | seed | Geographic Check: Origin = TLV (Israel) ? | Geographic Check: Origin = TLV (Israel) ? |
| CP015 | PREREQUISITES | prerequisite | seed | PAX Count: 1 adult | PAX Count: 1 adult |
| CP016 | PREREQUISITES | prerequisite | seed | Class of Booking: PY | Class of Booking: PY |
| CP017 | PREREQUISITES | prerequisite | seed | Revenue Booking: YES | Revenue Booking: YES |
| CP018 | PREREQUISITES | prerequisite | seed | ACR Issued: N/A (pending) | ACR Issued: N/A (pending) |
| CP019 | PREREQUISITES | prerequisite | seed | Journey Completed: < 72h (last leg arrived yesterday) | Journey Completed: < 72h (last leg arrived yesterday) |
| CP020 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP021 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP022 | START | customer | chat | Then user selects English |  |
| CP023 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP024 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP025 | START | customer | chat | And the user says "I just landed yesterday from Tel Aviv to Eilat. My flight was delayed by about 5 hours. I had to buy food and pay for a t | I just landed yesterday from Tel Aviv to Eilat. My flight was delayed by about 5 hours. I had to buy food and pay for a taxi. Can I get reimbursed for what I sp |
| CP026 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP027 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP028 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP032 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP033 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP035 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP040 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP041 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP042 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP043 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP044 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP045 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 084 � Route: Tel Aviv (TLV) ? Eilat (VDA) � Date: June 8, 2026 � Departure Delay: 5 hours Is this the journey you'd  |
| CP046 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP047 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination | 72-HOUR CHECK: ? FLOW STOPS HERE � PENDING |
| CP050 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey: | � Last leg Departure: June 8, 2026 � Current date: June 9, 2026 � Hours elapsed: ~24 hours � 24 hours < 72 hours ? WITHIN 72-HOUR WINDOW ? PENDING ? |
| CP052 | ? FLOW DOES NOT PROCEED TO | system | implied | ? Claim Time Limit Check � SKIPPED | ? Triage Eligibility Check (SoC-02b) � SKIPPED ? Airline Company Routing � SKIPPED ? DDS Evaluation � SKIPPED ? Geographic Check � SKIPPED ? Fraud Screening � S |
| CP053 | SHELL CASE CREATION | system | implied | Then the system creates a SHELL case in Case Services |  |
| CP054 | SHELL CASE CREATION | system | implied | And the shell case includes: | � Case type: Shell (pending � awaiting 72-hour window closure) � Passenger: [First Name] [Last Name] � PNR: [PNR Code] � Journey: AC 084 TLV?VDA, June 8, 2026 � |
| CP055 | SHELL CASE CREATION | system | implied | And the case is placed in the polling queue for 72-hour retrigger | DDS RESPONSE CODE = SoC-ASL-PE-01 (PENDING) |
| CP056 | PENDING RESULT | bot | chat | Then the chatbot displays: "Thank you for submitting your claim details. Your flight AC 084 from Tel Aviv to Eilat arrived recently, and we  | Thank you for submitting your claim details. Your flight AC 084 from Tel Aviv to Eilat arrived recently, and we need a little more time to gather all the necess |
| CP057 | PENDING RESULT | bot | chat | Then the chatbot responds: | Here's what will happen next: � We've created a reference for your claim: [Shell Case Reference] � Our system will automatically evaluate your eligibility once  |
| CP058 | DEEP LINK NOTIFICATION | system | implied | NOTE: The following happens AUTOMATICALLY after 72 hours � the passenger does not need to take any action. | After 72 hours (approximately June 11, 2026): |
| CP059 | DEEP LINK NOTIFICATION | system | implied | Then the system's polling queue triggers a re-evaluation |  |
| CP060 | DEEP LINK NOTIFICATION | system | implied | And the Rules Engine (RE) retrieves complete flight data: | � Actual departure time: confirmed � Actual Departure time: confirmed � Departure delay code: populated � Operating data: complete � Geographic check: TLV?VDA = |
| CP061 | DEEP LINK NOTIFICATION | email | email | Then the DDS evaluates eligibility with complete data: | � Regime: ASL (TLV?VDA = Israel?Israel confirmed) � Geographic check: PASSED ? (both origin and destination in Israel) � Controllability: NOT CHECKED (ASL regim |
| CP062 | WELCOME BACK FLOW | system | implied | Then the passenger receives an email from Air Canada: | "Good news! We've reviewed the details of your flight AC 084 from Tel Aviv to Eilat, and you are eligible for expense reimbursement under Israeli aviation regul |
| CP063 | WELCOME BACK FLOW | system | implied | And the email includes: | � Deep link to chatbot with pre-populated claim data � Case reference number � Expiry date for completing the claim |
| CP064 | WELCOME BACK FLOW | system | implied | Then the passenger clicks the deep link |  |
| CP065 | WELCOME BACK FLOW | system | implied | And the chatbot opens with pre-populated data: | "Welcome back, [First Name]! We've determined that you are eligible for expense reimbursement for your flight AC 084 from Tel Aviv to Eilat on June 8, 2026. To  |
| CP066 | WELCOME BACK FLOW | system | implied | Then the chatbot proceeds to: | � Receipt upload flow � OCR validation � Expense breakdown � Case creation � Payment flow (Same as EL-01 detailed steps from receipt upload onwards) |
| CP067 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP068 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP069 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-ASL-PE-01 � 72-Hour Hold Pending ASL |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "System Processing ??" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the SLA is 72-hour processing window |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is "N/A (system processing � not assigned to agent)" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 084 TLV ? VDA as the claimed flight |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (5 hours � preliminary)" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "TBD � pending 72-hour data completion" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is approximately 300 min (preliminary) |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PRELIMINARY ? (TLV ? VDA = Israel ? Israel)" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT APPLICABLE (ASL � will not be checked even after 72h)" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-ASL-PE-01 (PENDING)" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Polling Status is "ACTIVE" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "PENDING" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the last leg Departure is June 8, 2026 and filing is June 9, 2026 with approximately 24h elapsed which is less than 72h so PENDING |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And all checks after 72h gate are SKIPPED |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Current Status is "System Processing" and the case is NOT in read-only mode |  |
| CP088 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-ASL-PE-01 � During Pending Phase |  |
| CP089 | PAYMENT VALIDATION | payment | chat | Given the case SoC-ASL-PE-01 is PENDING |  |
| CP090 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered at this stage |  |
| CP091 | PAYMENT VALIDATION | payment | chat | And a shell case is created in System Processing Queue |  |
| CP092 | PAYMENT VALIDATION | payment | chat | And the route is AC 084 TLV ? VDA with delay 480 min (8 hrs) filed less than 72 hrs since Departure |  |
| CP093 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP094 | PAYMENT VALIDATION | payment | chat | And no receipts are uploaded |  |
| CP095 | PAYMENT VALIDATION | payment | chat | And no CyberSource fraud check is triggered |  |
| CP096 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP097 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP098 | PAYMENT VALIDATION | payment | chat | And no GL account or cost center is assigned |  |
| CP099 | PAYMENT VALIDATION | payment | chat | And the system polls DDS for up to 14 days |  |
| CP100 | PAYMENT VALIDATION | payment | chat | And after 72h if DDS returns ELIGIBLE then a deep link email is sent to customer |  |
| CP101 | PAYMENT VALIDATION | payment | chat | And the customer returns to chatbot and uploads receipts for OCR validation |  |
| CP102 | PAYMENT VALIDATION | payment | chat | And SOC is Cash only (no AC Wallet / e-credit for SOC) |  |
| CP103 | PAYMENT VALIDATION | payment | chat | And country of residence is asked to determine currency and payment method |  |
| CP104 | PAYMENT VALIDATION | payment | chat | And if Israel then ILS with BSM (HSBC) or manual banking details per country mapping |  |
| CP105 | PAYMENT VALIDATION | payment | chat | And ASL regime controllability is NOT checked (weather, ATC etc. IRRELEVANT under ASL) |  |
| CP106 | PAYMENT VALIDATION | payment | chat | And entitlements are applied based on delay category for 1 adult PY no ACR: Meals ?110, Hotel rate of day 3 nights max ?1,800 cap, Transport |  |
| CP107 | PAYMENT VALIDATION | payment | chat | And receipts are validated against entitlement thresholds |  |
| CP108 | PAYMENT VALIDATION | payment | chat | And compensation record is created with GL accounts per category and cost center CR 503 |  |
| CP109 | PAYMENT VALIDATION | payment | chat | And currency conversion logging includes ILS amount, CAD equivalent, exchange rate, source, and date for PRISM/Exposure reporting |  |
| CP110 | PAYMENT VALIDATION | payment | chat | And approval threshold check is based on total approved amount converted to CAD equivalent |  |
| CP111 | PAYMENT VALIDATION | payment | manual | And batch file is triggered to Unifier and end-of-day report is generated |  |
| CP112 | PAYMENT VALIDATION | payment | manual | And Claims Dashboard Compensation tab is populated with amount ILS, Cash, payment method per country, status via talkback |  |
| CP113 | PAYMENT VALIDATION | payment | manual | And after 72h if DDS returns NOT ELIGIBLE then rejection email is sent and case is auto-closed with no compensation record, no batch file, a |  |
| CP114 | PAYMENT VALIDATION | payment | chat | And Claims Dashboard shows NOT ELIGIBLE with no payout section |  |
| CP115 | PAYMENT VALIDATION | payment | chat | And if no DDS answer after 14 days then the case is sent to agent queue for manual handling |  |
| CP116 | PAYMENT VALIDATION | payment | chat | And Claims Dashboard while pending shows Case status = "Pending / System Processing" with no payout section |  |
| CP117 | EXPECTED RESULTS | verdict | chat | SoC-ASL-PE-01. | SoC-ASL-PE-01. |
| CP118 | EXPECTED RESULTS | verdict | chat | PENDING. | PENDING. |
| CP119 | EXPECTED RESULTS | verdict | chat | Last leg <72h ago. | Last leg <72h ago. |
| CP120 | EXPECTED RESULTS | verdict | chat | Shell case created. | Shell case created. |
| CP121 | EXPECTED RESULTS | verdict | chat | Placed in polling queue. | Placed in polling queue. |
| CP122 | EXPECTED RESULTS | verdict | api | After 72h: RE retrigger ? DDS evaluation (no controllability check under ASL) ? deep link sent if eligible. | After 72h: RE retrigger ? DDS evaluation (no controllability check under ASL) ? deep link sent if eligible. |
| CP123 | EXPECTED RESULTS | verdict | chat | No receipt upload at this stage. | No receipt upload at this stage. |
