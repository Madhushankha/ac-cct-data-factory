# FD_TC_089 · CHAI-31481 — checkpoints

**Goal:** Flight delayed 2 hours 30 minutes due to Code 64 (Flight Crew Shortage � Controllable) on a domestic AC operated flight (YUL?YYZ). Despite a confirmed controllable disruption code, the 2h 30min delay falls below the APPR minimum qualifying threshold of 3 hours, making the passenger NOT ELIGIBLE for compensation. Passenger holds a Basic Aeroplan profile linked to the booking. Validates that: (1) DDS correctly identifies that the delay exists and has a valid controllable code (Code 64), (2) DDS applies the APPR 3-hour minimum threshold gate and fails the claim because 2h 30m < 3h, (3) NOT ELIGIBLE result is returned even though the delay is controllable, (4) AC Wallet is NOT offered as no compensation is payable, (5) Basic Aeroplan profile is recognized but does not affect eligibility outcome.

Methods: seed 11, chat 40, api 26, email 3, dashboard 44, implied 20, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Flight delayed 2 hours 30 minutes due to Code 64 (Flight Crew Shortage � Controllable) on a domestic AC operated flight (YUL?YYZ). Despite a |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC051 � single passenger V�ronique Gagnon (Adult - Basic Aeroplan Member) | PNR: TC051 � single passenger V�ronique Gagnon (Adult - Basic Aeroplan Member) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 364, YUL?YYZ (domestic) | Journey: 1 leg AC operated, Flight AC 364, YUL?YYZ (domestic) |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 14:00 | Scheduled arrival: 14:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival: 16:30 (2h 30min delay, 150 min) | Actual arrival: 16:30 (2h 30min delay, 150 min) |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival delay code: 64 (Flight Crew Shortage � Controllable, available, no fallback) | Arrival delay code: 64 (Flight Crew Shortage � Controllable, available, no fallback) |
| CP007 | PREREQUISITES | prerequisite | seed | Delay: 2h 30min (150 min � below APPR 3h minimum threshold) | Delay: 2h 30min (150 min � below APPR 3h minimum threshold) |
| CP008 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic) | Regime: APPR (domestic) |
| CP009 | PREREQUISITES | prerequisite | seed | Booking changes: None | Booking changes: None |
| CP010 | PREREQUISITES | prerequisite | seed | Timing: >72hrs elapsed | Timing: >72hrs elapsed |
| CP011 | PREREQUISITES | prerequisite | seed | Filing: Within limitation | Filing: Within limitation |
| CP012 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked (9876543210), Basic Member in good standing | Aeroplan: Linked (9876543210), Basic Member in good standing |
| CP013 | PREREQUISITES | prerequisite | implied | CyberSource: NOT invoked (not eligible) | CyberSource: NOT invoked (not eligible) |
| CP014 | PREREQUISITES | prerequisite | implied | RDS: No flags | RDS: No flags |
| CP015 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP016 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP017 | START | customer | chat | Then user selects English |  |
| CP018 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP019 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP020 | START | customer | chat | And the user says "My flight from Montreal to Toronto was delayed about 2 and a half hours due to crew issues. I'd like to check if I'm elig | My flight from Montreal to Toronto was delayed about 2 and a half hours due to crew issues. I'd like to check if I'm eligible for compensation |
| CP021 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP022 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP023 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP024 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "V�ronique Gagnon" | V�ronique Gagnon |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, V�ronique! And, what is your booking reference number? |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC051" | PNR: TC051 |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC051 |  |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: v***@gmail.com � Phone: +1***890 |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: v***@gmail.com" | Email: v***@gmail.com |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "371928" | 371928 |
| CP038 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP040 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP041 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP042 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP043 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP044 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � V�ronique Gagnon (Adult - Aeroplan Member) Is this who you'd like to include? |
| CP045 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP047 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 364 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 4, 2026 � Arrival Delay: 2 hours 30 minutes Is this the jou |
| CP048 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP049 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP050 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP052 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP053 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was June 4, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP054 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP055 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Flight date June 4, 2026; filing June 15, 2026 ? 11 days ? within 366 days ? PROCEED |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Was the flight cancelled? ? NO |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Arrival delay code present? ? YES (Code 64 � Flight Crew Shortage, Controllable) |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Was the flight delayed ? 3 hours at destination? ? NO (2h 30m = 150 min < 180 min threshold) |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | And DDS applies: APPR Gate 8 � Delay threshold check: 2h 30m < 3h ? FAILS THRESHOLD |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS determines: DELAY EXISTS BUT BELOW APPR MINIMUM THRESHOLD ? NOT ELIGIBLE |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 364, Route: YUL ? YYZ, Scheduled Arrival: 14:00 | Promised Itinerary - Flight: AC 364, Route: YUL ? YYZ, Scheduled Arrival: 14:00 |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 364, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 14:00 ? Actual: 16:30, Delay: +2H 30M | Current Itinerary - Flight: AC 364, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 14:00 ? Actual: 16:30, Delay: +2H 30M |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 364 � YUL ? YYZ � 64 | MSL FLIGHT: AC 364 � YUL ? YYZ � 64 |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to flight crew shortage" | "Delayed due to flight crew shortage" |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +2H 30M � CONTROLLABLE | Delay: +2H 30M � CONTROLLABLE |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | APPR Gate 8: Delay 2h 30m < 3h ? FAILS threshold ? NOT ELIGIBLE | APPR Gate 8: Delay 2h 30m < 3h ? FAILS threshold ? NOT ELIGIBLE |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE | Fallback: FALSE |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | MS V�RONIQUE GAGNON / NOT ELIGIBLE / BELOW_THRESHOLD / CAD 0.00 | MS V�RONIQUE GAGNON / NOT ELIGIBLE / BELOW_THRESHOLD / CAD 0.00 |
| CP072 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP073 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP074 | AC WALLET CHECK � NOT TRIGGERED | system | implied | Then the chatbot notes: AC Wallet offer is ONLY triggered for ELIGIBLE cases |  |
| CP075 | AC WALLET CHECK � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? AC Wallet NOT offered despite Basic Aeroplan linkage (9876543210) |  |
| CP076 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your departure from Montreal was delayed by 2 hours and 30 minutes due to a crew shortage. However, you a |
| CP077 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP078 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP079 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP080 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP081 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to v***@gmail.com |  |
| CP082 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (AC 364 YUL?YYZ), not eligible reason (delay 2h 30m below 3h APPR threshold � Code 64 |  |
| CP083 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP084 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP085 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "V�ronique Gagnon" with PNR "TC051" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "V�ronique Gagnon" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC051" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "V�ronique Gagnon" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "v***@gmail.com" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***890" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "9876543210" linked and in good standing (Basic Member) |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be "Basic / Member" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Delay 2h 30m below APPR 3h minimum thres |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" � delay 2h 30m (150 min) fails APPR Gate 8 threshold (minimum 3h / 18 |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "V�ronique Gagnon + TC051 + YUL?YYZ + FD" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And AC Wallet should NOT have been offered despite Basic Aeroplan linkage as it only applies to eligible cases |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP139 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to delay below APPR 3h threshold (Code 64, 2h 30m) |  |
| CP140 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP141 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP142 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP143 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP144 | PAYMENT VALIDATION | payment | chat | And AC Wallet should NOT have been offered despite Basic Aeroplan linkage (9876543210) � AC Wallet only applies to eligible cases |  |
| CP145 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP146 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-01. | DDS returns FD-APPR-NE-01. |
| CP147 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 14:00; Actual = 16:30; Delay = 2h 30m (150 min); MSL = Leg 1 (AC 364); Code 64 (Flight Crew Shortage � Controllable); | Trip Tracer: Promise = 14:00; Actual = 16:30; Delay = 2h 30m (150 min); MSL = Leg 1 (AC 364); Code 64 (Flight Crew Shortage � Controllable); Fallback = FALSE; A |
| CP148 | EXPECTED RESULTS | verdict | api | CRITICAL: Code 64 IS controllable and delay IS confirmed � however 2h 30m < 3h APPR minimum threshold ? $0. | CRITICAL: Code 64 IS controllable and delay IS confirmed � however 2h 30m < 3h APPR minimum threshold ? $0. |
| CP149 | EXPECTED RESULTS | verdict | api | Delay duration below threshold is the sole NE reason. | Delay duration below threshold is the sole NE reason. |
| CP150 | EXPECTED RESULTS | verdict | chat | Aeroplan Basic (9876543210) recognized but AC Wallet NOT offered (NE case). | Aeroplan Basic (9876543210) recognized but AC Wallet NOT offered (NE case). |
| CP151 | EXPECTED RESULTS | verdict | chat | Compensation: $0 � Below APPR threshold. | Compensation: $0 � Below APPR threshold. |
| CP152 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP153 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP154 | EXPECTED RESULTS | verdict | api | Regime Assessment: APPR = NE-01 (Delay below 3h threshold); EU = N/A; ASL = N/A. | Regime Assessment: APPR = NE-01 (Delay below 3h threshold); EU = N/A; ASL = N/A. |
| CP155 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Code 64 (Crew Shortage, Controllable); Delay = 2h 30m (below 3h gate); $0; DDS = FD-APPR-NE-01. | Claims Dashboard: Code 64 (Crew Shortage, Controllable); Delay = 2h 30m (below 3h gate); $0; DDS = FD-APPR-NE-01. |
