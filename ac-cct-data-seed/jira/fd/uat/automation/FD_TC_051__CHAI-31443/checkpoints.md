# FD_TC_051 · CHAI-31443 — checkpoints

**Goal:** Passenger was DENIED BOARDING on their flight. Denied boarding is handled under SEPARATE APPR provisions (Section 10-11 of APPR) with its own compensation schedule and process � it is NOT part of the flight disruption compensation flow. The FD chatbot is specifically for delay/cancellation disruptions, not denied boarding. Validates: (1) DDS detects the Denied Boarding event flag from Trip Tracer, (2) System correctly classifies denied boarding as outside the FD compensation scope, (3) Customer is redirected to the CORRECT process for denied boarding claims (Customer Relations, separate URL/phone), (4) The case is logged as "Not Eligible (Flight Disruption)" � not "Not Eligible" generically, since the customer MAY be eligible under the denied boarding process. This is a routing/scope test, not a true eligibility denial.

Methods: seed 17, chat 47, api 30, email 3, dashboard 44, implied 10, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Passenger was DENIED BOARDING on their flight. Denied boarding is handled under SEPARATE APPR provisions (Section 10-11 of APPR) with its ow |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC027 � single passenger (Adult) | PNR: TC027 � single passenger (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg, AC operated | Journey: 1 leg, AC operated |
| CP004 | PREREQUISITES | prerequisite | seed | Flight AC 330, YUL ? YYZ (domestic) | Flight AC 330, YUL ? YYZ (domestic) |
| CP005 | PREREQUISITES | prerequisite | seed | Scheduled Departure: 10:00, Scheduled Arrival: 12:00 | Scheduled Departure: 10:00, Scheduled Arrival: 12:00 |
| CP006 | PREREQUISITES | prerequisite | seed | Flight operated normally � Actual Departure: 10:05, Actual Arrival: 12:02 | Flight operated normally � Actual Departure: 10:05, Actual Arrival: 12:02 |
| CP007 | PREREQUISITES | prerequisite | seed | Passenger was NOT on board | Passenger was NOT on board |
| CP008 | PREREQUISITES | prerequisite | seed | Denied Boarding Event: changeIdentifier = DENIED_BOARDING on MSL segment | Denied Boarding Event: changeIdentifier = DENIED_BOARDING on MSL segment |
| CP009 | PREREQUISITES | prerequisite | seed | Denial Type: Involuntary (INVOL) | Denial Type: Involuntary (INVOL) |
| CP010 | PREREQUISITES | prerequisite | seed | Denial Reason: DENIED_BOARDING_OVERSALES (Overbooking) | Denial Reason: DENIED_BOARDING_OVERSALES (Overbooking) |
| CP011 | PREREQUISITES | prerequisite | seed | Passenger had confirmed reservation (HK status), valid ticket, checked in on time, valid travel documentation | Passenger had confirmed reservation (HK status), valid ticket, checked in on time, valid travel documentation |
| CP012 | PREREQUISITES | prerequisite | seed | Boarding Status: NOT BOARDED (denied at gate) | Boarding Status: NOT BOARDED (denied at gate) |
| CP013 | PREREQUISITES | prerequisite | seed | Post-Denial Outcome: Customer was NOT rebooked on an alternate flight | Post-Denial Outcome: Customer was NOT rebooked on an alternate flight |
| CP014 | PREREQUISITES | prerequisite | seed | Travel Status: Did NOT travel on this journey | Travel Status: Did NOT travel on this journey |
| CP015 | PREREQUISITES | prerequisite | seed | Compensation via FD chatbot: NOT applicable � Denied Boarding handled under separate APPR provisions (Sections 10�11), not the Flight Disrup | Compensation via FD chatbot: NOT applicable � Denied Boarding handled under separate APPR provisions (Sections 10�11), not the Flight Disruption compensation fl |
| CP016 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic Canada) | Regime: APPR (domestic Canada) |
| CP017 | PREREQUISITES | prerequisite | seed | Timing: >72hrs elapsed since scheduled departure | Timing: >72hrs elapsed since scheduled departure |
| CP018 | PREREQUISITES | prerequisite | seed | Filing: Within 366-day limitation period | Filing: Within 366-day limitation period |
| CP019 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP020 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP021 | START | customer | chat | Then user selects English |  |
| CP022 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP023 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP024 | START | customer | chat | And the user says "I was denied boarding on my flight due to overbooking, I'd like to check if I'm eligible for compensation" | I was denied boarding on my flight due to overbooking, I'd like to check if I'm eligible for compensation |
| CP025 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP026 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP027 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP028 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Dominique Arsenault" | Dominique Arsenault |
| CP032 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Dominique! And, what is your booking reference number? |
| CP033 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC038" | PNR: TC038 |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC038 |  |
| CP035 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP036 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: d***@gmail.com � Phone: +1***789 |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: d***@gmail.com" | Email: d***@gmail.com |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP041 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP042 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP043 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP044 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP045 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP046 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP047 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP048 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Dominique Arsenault (Adult) Is this who you'd like to include? |
| CP049 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP050 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP051 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 458 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: May 27, 2026 � Status: DEPARTED (passenger not on board � Denied |
| CP052 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP053 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Disruption type? ? DENIED BOARDING |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS determines: DENIED BOARDING ? SEPARATE PROCESS (not handled in flight disruption compensation flow) |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Flight: AC 330 | Flight: AC 330 |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Route: YUL ? YYZ | Route: YUL ? YYZ |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Scheduled Departure: 10:00 | Scheduled Departure: 10:00 |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Scheduled Arrival: 12:00 | Scheduled Arrival: 12:00 |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Flight: AC 330 | Flight: AC 330 |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Route: YUL ? YYZ | Route: YUL ? YYZ |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Status: DEPARTED / ARRIVED (flight operated normally) | Status: DEPARTED / ARRIVED (flight operated normally) |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Actual Departure: 10:05 | Actual Departure: 10:05 |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Actual Arrival: 12:02 | Actual Arrival: 12:02 |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Passenger Status: NOT BOARDED � DENIED BOARDING | Passenger Status: NOT BOARDED � DENIED BOARDING |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | changeIdentifier: DENIED_BOARDING | changeIdentifier: DENIED_BOARDING |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | change_type: INVOLUNTARY | change_type: INVOLUNTARY |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Denial Reason: DENIED_BOARDING_OVERSALES (Overbooking) | Denial Reason: DENIED_BOARDING_OVERSALES (Overbooking) |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | impacted_passenger_id: St�phane Boucher | impacted_passenger_id: St�phane Boucher |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | impacted_segment_id: AC 330 YUL?YYZ | impacted_segment_id: AC 330 YUL?YYZ |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | DDS Gate 6: Denied Boarding = TRUE ? NOT ELIGIBLE for Flight Disruption compensation | DDS Gate 6: Denied Boarding = TRUE ? NOT ELIGIBLE for Flight Disruption compensation |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | Separate APPR DB compensation may apply via Customer Relations | Separate APPR DB compensation may apply via Customer Relations |
| CP076 | TRIP TRACER UI VALIDATION | verdict | api | MR ST�PHANE BOUCHER / NOT ELIGIBLE / DENIED_BOARDING / CAD 0.00 (FD channel) | MR ST�PHANE BOUCHER / NOT ELIGIBLE / DENIED_BOARDING / CAD 0.00 (FD channel) |
| CP077 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP078 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP079 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand you were denied boarding on flight AC 458 from Montreal (YUL) to Toronto (YYZ) on May 27, 2026. However,  |
| CP080 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP081 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP082 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP083 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP084 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to d***@gmail.com |  |
| CP085 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (denied boarding � separate process), regulation reference (APPR |  |
| CP086 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP087 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP088 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Dominique Arsenault" with PNR "TC038" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Dominique Arsenault" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC038" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Dominique Arsenault" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "d***@gmail.com" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***789" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Denied Boarding � separate process" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to denied boarding not handled in FD compensation flow |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Dominique Arsenault + TC038 + YUL?YYZ + FD" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP142 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to Denied Boarding |  |
| CP143 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP144 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP145 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP146 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP147 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP148 | EXPECTED RESULTS | verdict | api | DDS: FD-APPR-NE-06. | DDS: FD-APPR-NE-06. |
| CP149 | EXPECTED RESULTS | verdict | chat | AC 330 YUL?YYZ operated normally (dep 10:05, arr 12:02). | AC 330 YUL?YYZ operated normally (dep 10:05, arr 12:02). |
| CP150 | EXPECTED RESULTS | verdict | chat | Passenger NOT BOARDED. changeIdentifier = DENIED_BOARDING, INVOLUNTARY, DENIED_BOARDING_OVERSALES. | Passenger NOT BOARDED. changeIdentifier = DENIED_BOARDING, INVOLUNTARY, DENIED_BOARDING_OVERSALES. |
| CP151 | EXPECTED RESULTS | verdict | chat | Gate 1: Not employee/infant ? PROCEED. | Gate 1: Not employee/infant ? PROCEED. |
| CP152 | EXPECTED RESULTS | verdict | api | Gate 2: Promised dep 10:00 arr 12:00, flight operated, pax not aboard. | Gate 2: Promised dep 10:00 arr 12:00, flight operated, pax not aboard. |
| CP153 | EXPECTED RESULTS | verdict | chat | Gate 3: No Travel. | Gate 3: No Travel. |
| CP154 | EXPECTED RESULTS | verdict | api | Gate 4: MSL = AC 330. | Gate 4: MSL = AC 330. |
| CP155 | EXPECTED RESULTS | verdict | chat | Gate 5: AC operated ? YES. | Gate 5: AC operated ? YES. |
| CP156 | EXPECTED RESULTS | verdict | chat | Gate 6: DENIED_BOARDING = TRUE ? NOT ELIGIBLE under FD flow (short-circuits Gates 7�10). | Gate 6: DENIED_BOARDING = TRUE ? NOT ELIGIBLE under FD flow (short-circuits Gates 7�10). |
| CP157 | EXPECTED RESULTS | verdict | chat | Scope exclusion � customer may be eligible under APPR Sections 10�11 via Customer Relations: <6hr = CAN$900/CAN$1,000 EMD; 6�<9hr = CAN$1,80 | Scope exclusion � customer may be eligible under APPR Sections 10�11 via Customer Relations: <6hr = CAN$900/CAN$1,000 EMD; 6�<9hr = CAN$1,800/CAN$2,000 EMD; ?9h |
| CP158 | EXPECTED RESULTS | verdict | chat | Compensation (FD): $0. | Compensation (FD): $0. |
| CP159 | EXPECTED RESULTS | verdict | chat | Fraud: NOT INVOKED. | Fraud: NOT INVOKED. |
| CP160 | EXPECTED RESULTS | verdict | chat | IDV: NOT REQUIRED. | IDV: NOT REQUIRED. |
| CP161 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP162 | EXPECTED RESULTS | verdict | chat | APPR = NE-06; EU = N/A; ASL = N/A. | APPR = NE-06; EU = N/A; ASL = N/A. |
