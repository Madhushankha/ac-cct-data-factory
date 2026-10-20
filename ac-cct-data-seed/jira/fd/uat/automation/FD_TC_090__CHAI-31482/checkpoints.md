# FD_TC_090 · CHAI-31482 — checkpoints

**Goal:** Original flight AC 364 YUL?YYZ was CANCELLED due to SKD (Schedule / Commercial Cancellation � Controllable). Customer accepts rebooking to AC 412 YUL?YYZ. The rebooked flight arrives 2 hours 30 minutes after the original promised arrival time (below the APPR 3-hour minimum threshold). Passenger holds a Basic Aeroplan profile (9876543210) linked to the booking. Validates that: (1) DDS correctly identifies the cancellation as SKD (Controllable), (2) Rebooking is captured in the change history as INVOL, (3) Delay is calculated as rebooked actual arrival minus original scheduled arrival = 2h 30m, (4) DDS applies APPR Gate 8 threshold check � 2h 30m < 3h ? FAILS THRESHOLD ? NOT ELIGIBLE, (5) NOT ELIGIBLE result is returned even though SKD is a controllable cancellation, (6) AC Wallet is NOT offered as no compensation is payable, (7) Basic Aeroplan profile is recognized but does not affect eligibility outcome.

Methods: seed 10, chat 43, api 29, email 3, dashboard 45, implied 20, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Original flight AC 364 YUL?YYZ was CANCELLED due to SKD (Schedule / Commercial Cancellation � Controllable). Customer accepts rebooking to A |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC051 � single passenger V�ronique Gagnon (Adult - Basic Aeroplan Member) | PNR: TC051 � single passenger V�ronique Gagnon (Adult - Basic Aeroplan Member) |
| CP003 | PREREQUISITES | prerequisite | seed | Original itinerary: Flight AC 364, YUL?YYZ (domestic), Scheduled arrival: 14:00 | Original itinerary: Flight AC 364, YUL?YYZ (domestic), Scheduled arrival: 14:00 |
| CP004 | PREREQUISITES | prerequisite | seed | Original flight CANCELLED (SKD � Schedule / Commercial Cancellation � Controllable) | Original flight CANCELLED (SKD � Schedule / Commercial Cancellation � Controllable) |
| CP005 | PREREQUISITES | prerequisite | seed | Customer accepts INVOL rebooking to AC 412 YUL?YYZ | Customer accepts INVOL rebooking to AC 412 YUL?YYZ |
| CP006 | PREREQUISITES | prerequisite | seed | Rebooked flight AC 412 actual arrival at YYZ: 16:30 (2h 30min after original 14:00 promise = 150 min) | Rebooked flight AC 412 actual arrival at YYZ: 16:30 (2h 30min after original 14:00 promise = 150 min) |
| CP007 | PREREQUISITES | prerequisite | seed | Delay: 2h 30min (150 min � below APPR 3h minimum threshold) | Delay: 2h 30min (150 min � below APPR 3h minimum threshold) |
| CP008 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic) | Regime: APPR (domestic) |
| CP009 | PREREQUISITES | prerequisite | seed | Timing: >72hrs elapsed | Timing: >72hrs elapsed |
| CP010 | PREREQUISITES | prerequisite | seed | Filing: Within 366 days | Filing: Within 366 days |
| CP011 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked (9876543210), Basic Member in good standing | Aeroplan: Linked (9876543210), Basic Member in good standing |
| CP012 | PREREQUISITES | prerequisite | implied | CyberSource: NOT invoked (not eligible) | CyberSource: NOT invoked (not eligible) |
| CP013 | PREREQUISITES | prerequisite | implied | RDS: No flags | RDS: No flags |
| CP014 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP015 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP016 | START | customer | chat | Then user selects English |  |
| CP017 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP018 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP019 | START | customer | chat | And the user says "My flight from Montreal to Toronto was cancelled and I was rebooked to another flight. I arrived about 2 and a half hours | My flight from Montreal to Toronto was cancelled and I was rebooked to another flight. I arrived about 2 and a half hours later than originally scheduled. I'd l |
| CP020 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP021 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP022 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP023 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "V�ronique Gagnon" | V�ronique Gagnon |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, V�ronique! And, what is your booking reference number? |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC051" | PNR: TC051 |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC051 |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: v***@gmail.com � Phone: +1***890 |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: v***@gmail.com" | Email: v***@gmail.com |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "371928" | 371928 |
| CP037 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP039 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP041 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP043 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � V�ronique Gagnon (Adult - Aeroplan Member) Is this who you'd like to include? |
| CP044 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP046 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Original Flight: AC 364 � CANCELLED (Schedule/Commercial) � Rebooked Flight: AC 412 � Route: Montreal (YUL) ? Toronto (YYZ) � D |
| CP047 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP050 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP051 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP052 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was June 4, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP053 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP054 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Flight date June 4, 2026; filing June 15, 2026 ? 11 days ? within 366 days ? PROCEED |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Was the flight cancelled? ? YES (AC 364 � SKD Schedule / Commercial Cancellation) |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Change history = INVOL � AC 364 cancelled (SKD) ? customer rebooked to AC 412 |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Was the customer rebooked? ? YES (AC 412 YUL?YYZ) |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Actual arrival at final destination on rebooked flight = 16:30 |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Original promised arrival = 14:00 |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS calculates: Delay = 16:30 ? 14:00 = 2h 30m (150 min) |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Was the rebooked arrival delayed ? 3 hours vs original promise? ? NO (2h 30m = 150 min < 180 min threshold) |  |
| CP063 | TRIAGE & DDS EVALUATION | verdict | api | And DDS applies: APPR Gate 8 � Delay threshold check: 2h 30m < 3h ? FAILS THRESHOLD |  |
| CP064 | TRIAGE & DDS EVALUATION | verdict | api | And DDS determines: CANCELLATION + REBOOKING BUT ARRIVED < 3H LATE ? NOT ELIGIBLE |  |
| CP065 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 364, Route: YUL ? YYZ, Scheduled Arrival: 14:00 (CANCELLED � SKD) | Promised Itinerary - Flight: AC 364, Route: YUL ? YYZ, Scheduled Arrival: 14:00 (CANCELLED � SKD) |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Change History - INVOL: AC 364 CANCELLED (SKD � Schedule / Commercial Cancellation � Controllable). Customer accepted rebooking to AC 412 YU | Change History - INVOL: AC 364 CANCELLED (SKD � Schedule / Commercial Cancellation � Controllable). Customer accepted rebooking to AC 412 YUL?YYZ. |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 412, Route: YUL ? YYZ, Status: ARRIVED, Actual Arrival: 16:30 at YYZ | Current Itinerary - Flight: AC 412, Route: YUL ? YYZ, Status: ARRIVED, Actual Arrival: 16:30 at YYZ |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 364 � YUL ? YYZ � SKD (Schedule / Commercial Cancellation � Controllable) | MSL FLIGHT: AC 364 � YUL ? YYZ � SKD (Schedule / Commercial Cancellation � Controllable) |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | Rebooked Flight: AC 412 � YUL ? YYZ � Arrived 16:30 | Rebooked Flight: AC 412 � YUL ? YYZ � Arrived 16:30 |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | Delay Calculation: Original promise = 14:00; Rebooked actual = 16:30; Delay = +2H 30M | Delay Calculation: Original promise = 14:00; Rebooked actual = 16:30; Delay = +2H 30M |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | APPR Gate 8: Delay 2h 30m < 3h ? FAILS threshold ? NOT ELIGIBLE | APPR Gate 8: Delay 2h 30m < 3h ? FAILS threshold ? NOT ELIGIBLE |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE | Fallback: FALSE |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | Sister City: FALSE | Sister City: FALSE |
| CP076 | TRIP TRACER UI VALIDATION | verdict | api | MS V�RONIQUE GAGNON / NOT ELIGIBLE / BELOW_THRESHOLD_POST_REBOOKING / CAD 0.00 | MS V�RONIQUE GAGNON / NOT ELIGIBLE / BELOW_THRESHOLD_POST_REBOOKING / CAD 0.00 |
| CP077 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP078 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP079 | AC WALLET CHECK � NOT TRIGGERED | system | implied | Then the chatbot notes: AC Wallet offer is ONLY triggered for ELIGIBLE cases |  |
| CP080 | AC WALLET CHECK � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? AC Wallet NOT offered despite Basic Aeroplan linkage (9876543210) |  |
| CP081 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I can see that your original flight AC 364 from Montreal to Toronto was cancelled due to a schedule change, and you we |
| CP082 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP083 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP084 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP085 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP086 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to v***@gmail.com |  |
| CP087 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (AC 364 cancelled SKD ? rebooked AC 412 YUL?YYZ), not eligible reason (rebooked arriv |  |
| CP088 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP089 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP090 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "V�ronique Gagnon" with PNR "TC051" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "V�ronique Gagnon" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC051" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "V�ronique Gagnon" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "v***@gmail.com" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***890" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "9876543210" linked and in good standing (Basic Member) |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be "Basic / Member" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" (original AC 364 cancelled SKD; rebooked AC 412) |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Change History should show "INVOL � AC 364 cancelled (SKD) ? rebooked AC 412 YUL?YYZ" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Cancellation SKD (Controllable) � Rebook |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" � rebooked arrival 2h 30m (150 min) fails APPR Gate 8 threshold (mini |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "V�ronique Gagnon + TC051 + YUL?YYZ + FD" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And AC Wallet should NOT have been offered despite Basic Aeroplan linkage as it only applies to eligible cases |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP145 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to rebooked arrival below APPR 3h threshold (SKD cancellation, rebooked AC 412, 2h 30m) |  |
| CP146 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP147 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP148 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP149 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP150 | PAYMENT VALIDATION | payment | chat | And AC Wallet should NOT have been offered despite Basic Aeroplan linkage (9876543210) � AC Wallet only applies to eligible cases |  |
| CP151 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP152 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-01. | DDS returns FD-APPR-NE-01. |
| CP153 | EXPECTED RESULTS | verdict | api | Trip Tracer: Original promise = 14:00 (AC 364 CANCELLED � SKD Schedule / Commercial Cancellation � Controllable); INVOL rebooking ? AC 412 Y | Trip Tracer: Original promise = 14:00 (AC 364 CANCELLED � SKD Schedule / Commercial Cancellation � Controllable); INVOL rebooking ? AC 412 YUL?YYZ; Rebooked act |
| CP154 | EXPECTED RESULTS | verdict | chat | APPR Gate 8: 2h 30m < 3h ? FAILS ? NOT ELIGIBLE. | APPR Gate 8: 2h 30m < 3h ? FAILS ? NOT ELIGIBLE. |
| CP155 | EXPECTED RESULTS | verdict | chat | CRITICAL: SKD IS controllable and cancellation IS confirmed � however rebooked arrival is within 3h of original promise ? $0. | CRITICAL: SKD IS controllable and cancellation IS confirmed � however rebooked arrival is within 3h of original promise ? $0. |
| CP156 | EXPECTED RESULTS | verdict | chat | Below 3h threshold on rebooked arrival is the sole NE reason. | Below 3h threshold on rebooked arrival is the sole NE reason. |
| CP157 | EXPECTED RESULTS | verdict | chat | Aeroplan Basic (9876543210) recognized but AC Wallet NOT offered (NE case). | Aeroplan Basic (9876543210) recognized but AC Wallet NOT offered (NE case). |
| CP158 | EXPECTED RESULTS | verdict | chat | Compensation: $0 � Below APPR threshold post-rebooking. | Compensation: $0 � Below APPR threshold post-rebooking. |
| CP159 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP160 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP161 | EXPECTED RESULTS | verdict | api | DDS = FD-APPR-NE-01. | DDS = FD-APPR-NE-01. |
