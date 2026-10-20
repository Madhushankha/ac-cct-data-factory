# FD_TC_137 · CHAI-31529 — checkpoints

**Goal:** OAL (partner airline) employee travelling on staff booking on an EU route (LHR?YYZ). Despite a 4hr controllable delay on a route where both EU 261 and APPR apply, the OAL employee exclusion overrides all regime assessments. Validates that the employee exclusion is universal � it blocks eligibility under EU 261 just as it does under APPR.

Methods: seed 10, chat 41, api 17, email 3, dashboard 44, implied 14, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | OAL (partner airline) employee travelling on staff booking on an EU route (LHR?YYZ). Despite a 4hr controllable delay on a route where both  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger (Adult) | PNR: single passenger (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Employee Flag: OAL EMPLOYEE BOOKING � partner airline staff travel flag in Trip Tracer | Employee Flag: OAL EMPLOYEE BOOKING � partner airline staff travel flag in Trip Tracer |
| CP004 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 850, LHR?YYZ | Journey: 1 leg AC operated, Flight AC 850, LHR?YYZ |
| CP005 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 16:00 | Scheduled arrival: 16:00 |
| CP006 | PREREQUISITES | prerequisite | seed | Actual arrival: 20:00 (4hr delay) | Actual arrival: 20:00 (4hr delay) |
| CP007 | PREREQUISITES | prerequisite | seed | Arrival Delay code: 42 ( Controllable) | Arrival Delay code: 42 ( Controllable) |
| CP008 | PREREQUISITES | prerequisite | seed | Arrival code: 42 (available, no fallback) | Arrival code: 42 (available, no fallback) |
| CP009 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (UK origin) + APPR (Canada arrival) | Regime: EU 261 (UK origin) + APPR (Canada arrival) |
| CP010 | PREREQUISITES | prerequisite | seed | Timing: >72hrs elapsed | Timing: >72hrs elapsed |
| CP011 | PREREQUISITES | prerequisite | seed | Filing: Within limitation | Filing: Within limitation |
| CP012 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP013 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP014 | START | customer | chat | Then user selects English |  |
| CP015 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP016 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP017 | START | customer | chat | And the user says "My flight from Paris to Toronto was delayed 4 hours. I'd like to check if I'm eligible for compensation" | My flight from Paris to Toronto was delayed 4 hours. I'd like to check if I'm eligible for compensation |
| CP018 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP019 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP020 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP021 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Hans M�ller" | Hans M�ller |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Hans! And, what is your booking reference number? |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC096" | PNR: TC096 |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC096 |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data is revealed � OAL EMPLOYEE BOOKING IDENTIFIER PRESENT |  |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: h***@lufthansa.com � Phone: +49***456 |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: h***@lufthansa.com" | Email: h***@lufthansa.com |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP035 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP037 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Hans M�ller (Adult) [OAL Employee] Is this who you'd like to include? |
| CP042 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP044 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 871 � Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ) � Date: June 4, 2026 � Arrival Delay: 4 hours Is this the |
| CP045 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP050 | EMPLOYEE CHECK | system | implied | Then the system checks: Is passenger an airline employee? ? YES (OAL employee booking identifier present) |  |
| CP051 | EMPLOYEE CHECK | system | implied | Then the system determines: OAL EMPLOYEE ? NOT ELIGIBLE (employee bookings excluded from all regimes) |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 871, Route: CDG ? YYZ, Scheduled Arrival: 13:00 | Promised Itinerary - Flight: AC 871, Route: CDG ? YYZ, Scheduled Arrival: 13:00 |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 871, Route: CDG ? YYZ, Status: ARRIVED LATE, Actual: 17:00, Delay: +4H 00M | Current Itinerary - Flight: AC 871, Route: CDG ? YYZ, Status: ARRIVED LATE, Actual: 17:00, Delay: +4H 00M |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Passenger: OAL EMPLOYEE (OAL employee booking identifier present) | Passenger: OAL EMPLOYEE (OAL employee booking identifier present) |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Regime: EU 261 (EU origin � CDG) � BUT employee exclusion applies | Regime: EU 261 (EU origin � CDG) � BUT employee exclusion applies |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 871 � CDG ? YYZ � 42 � CONTROLLABLE | MSL FLIGHT: AC 871 � CDG ? YYZ � 42 � CONTROLLABLE |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Employee Check: OAL EMPLOYEE ? NOT ELIGIBLE (overrides all other checks) | Employee Check: OAL EMPLOYEE ? NOT ELIGIBLE (overrides all other checks) |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | MR HANS M�LLER / NOT ELIGIBLE / EMPLOYEE_OAL / CAD 0.00 | MR HANS M�LLER / NOT ELIGIBLE / EMPLOYEE_OAL / CAD 0.00 |
| CP061 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP062 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your flight AC 871 from Paris Charles de Gaulle (CDG) to Toronto (YYZ) was delayed by 4 hours. However, b |
| CP063 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP064 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP065 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP066 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP067 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to h***@lufthansa.com |  |
| CP068 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (OAL employee booking), regulation reference, contact informatio |  |
| CP069 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP070 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP071 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Hans M�ller" with PNR "TC096" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Hans M�ller" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC096" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (EU origin � CDG)" but employee exclusion applies |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Hans M�ller" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" and "OAL Employee" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "h***@lufthansa.com" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+49***456" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: CDG ? YYZ" with claim filed for this flight |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "OAL Employee � employee bookings exclude |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to OAL Employee booking overriding all other checks |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Hans M�ller + TC096 + CDG?YYZ + FD" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe to "h***@lufthansa.com" containing Case Reference and flight details a |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP125 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to OAL Employee |  |
| CP126 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP128 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP129 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP131 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-NE-02. | DDS returns FD-EU-NE-02. |
| CP132 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 16:00; Actual = 20:00; Delay = 4hrs; MSL = Leg 1 (AC 850); Code 42; Controllable; Fallback = FALSE; EU-UK + APPR. | Trip Tracer: Promise = 16:00; Actual = 20:00; Delay = 4hrs; MSL = Leg 1 (AC 850); Code 42; Controllable; Fallback = FALSE; EU-UK + APPR. |
| CP133 | EXPECTED RESULTS | verdict | chat | Employee Check: OAL Employee booking flag = TRUE ? NOT ELIGIBLE (employee exclusion overrides all regimes). | Employee Check: OAL Employee booking flag = TRUE ? NOT ELIGIBLE (employee exclusion overrides all regimes). |
| CP134 | EXPECTED RESULTS | verdict | chat | CRITICAL: Despite 4hr controllable delay on a dual-regime route (EU-UK + APPR), employee status blocks eligibility universally. | CRITICAL: Despite 4hr controllable delay on a dual-regime route (EU-UK + APPR), employee status blocks eligibility universally. |
| CP135 | EXPECTED RESULTS | verdict | chat | Compensation: $0. | Compensation: $0. |
| CP136 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP137 | EXPECTED RESULTS | verdict | chat | IDV: NOT REQUIRED. | IDV: NOT REQUIRED. |
| CP138 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP139 | EXPECTED RESULTS | verdict | api | Regime Assessment: APPR = NE (Employee); EU 261 = NE-02 (OAL Employee); ASL = NE (Employee). | Regime Assessment: APPR = NE (Employee); EU 261 = NE-02 (OAL Employee); ASL = NE (Employee). |
| CP140 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Case = CASE-FD-20260520-102; Status = Closed � Not Eligible; Reason = OAL Employee (Lufthansa); Code 42 (Controllable � bu | Claims Dashboard: Case = CASE-FD-20260520-102; Status = Closed � Not Eligible; Reason = OAL Employee (Lufthansa); Code 42 (Controllable � but employee override) |
