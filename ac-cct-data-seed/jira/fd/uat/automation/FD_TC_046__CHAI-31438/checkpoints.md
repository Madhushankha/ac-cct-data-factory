# FD_TC_046 · CHAI-31438 — checkpoints

**Goal:** Passenger is an employee of a PARTNER airline (Other Airline � OAL), NOT Air Canada, travelling on an OAL employee booking. OAL employee bookings are also NOT eligible for compensation, same as AC employee bookings. Validates that the employee exclusion extends beyond AC's own employees to include partner airline staff travel.

Methods: seed 11, chat 40, api 22, email 3, dashboard 44, implied 16, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Passenger is an employee of a PARTNER airline (Other Airline � OAL), NOT Air Canada, travelling on an OAL employee booking. OAL employee boo |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC023 � single passenger Thomas Weber (Adult) | PNR: TC023 � single passenger Thomas Weber (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Employee Flag: OAL EMPLOYEE BOOKING � partner airline staff travel flag in Trip Tracer | Employee Flag: OAL EMPLOYEE BOOKING � partner airline staff travel flag in Trip Tracer |
| CP004 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 327, YUL?YYZ (domestic Canada) | Journey: 1 leg AC operated, Flight AC 327, YUL?YYZ (domestic Canada) |
| CP005 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 14:00 | Scheduled arrival: 14:00 |
| CP006 | PREREQUISITES | prerequisite | seed | Actual arrival: 18:00 (4hr delay) | Actual arrival: 18:00 (4hr delay) |
| CP007 | PREREQUISITES | prerequisite | seed | Disruption code: 42(Scheduled Maintenance � Controllable) | Disruption code: 42(Scheduled Maintenance � Controllable) |
| CP008 | PREREQUISITES | prerequisite | seed | Arrival code: 42(available) | Arrival code: 42(available) |
| CP009 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic) | Regime: APPR (domestic) |
| CP010 | PREREQUISITES | prerequisite | seed | Booking changes: None | Booking changes: None |
| CP011 | PREREQUISITES | prerequisite | seed | Timing: >72hrs elapsed | Timing: >72hrs elapsed |
| CP012 | PREREQUISITES | prerequisite | seed | Filing: Within limitation | Filing: Within limitation |
| CP013 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP014 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP015 | START | customer | chat | Then user selects English |  |
| CP016 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP017 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP018 | START | customer | chat | And the user says "My flight was delayed about 4 hours due to a maintenance issue, I'd like to check if I'm eligible for compensation" | My flight was delayed about 4 hours due to a maintenance issue, I'd like to check if I'm eligible for compensation |
| CP019 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP020 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP021 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP022 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Thomas Bennett" | Thomas Bennett |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Thomas! And, what is your booking reference number? |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC036" | PNR: TC036 |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC036 |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer flags: OAL EMPLOYEE BOOKING DETECTED (partner airline employee flag present on PNR) |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@lufthansa.com � Phone: +1***345 |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@lufthansa.com" | Email: t***@lufthansa.com |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP037 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP039 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP041 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP043 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Thomas Bennett (Adult) [OAL EMPLOYEE] Is this who you'd like to include? |
| CP044 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP046 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 455 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: May 23, 2026 � Arrival Delay: 4 hours Is this the journey you'd  |
| CP047 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP050 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP051 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP052 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 23, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP053 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP054 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 23, 2026; filing June 15, 2026 ? 23 days ? within 366 days ? PROCEED |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Is passenger an airline employee? ? YES (OAL employee flag on PNR) |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | And DDS short-circuits: EMPLOYEE (OAL) ? NOT ELIGIBLE (employee check gate � before controllability or delay checks) |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 455, Route: YUL ? YYZ, Scheduled Arrival: 14:00 | Promised Itinerary - Flight: AC 455, Route: YUL ? YYZ, Scheduled Arrival: 14:00 |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 455, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 14:00 ? Actual: 18:00, Delay: +4H 00M | Current Itinerary - Flight: AC 455, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 14:00 ? Actual: 18:00, Delay: +4H 00M |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Passenger Flag: OAL EMPLOYEE (partner airline) | Passenger Flag: OAL EMPLOYEE (partner airline) |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 455 � YUL ? YYZ � 42 | MSL FLIGHT: AC 455 � YUL ? YYZ � 42 |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to scheduled maintenance" | "Delayed due to scheduled maintenance" |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +4H 00M � CONTROLLABLE | Delay: +4H 00M � CONTROLLABLE |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | DDS Gate: EMPLOYEE CHECK ? NOT ELIGIBLE (short-circuited before delay/controllability gates) | DDS Gate: EMPLOYEE CHECK ? NOT ELIGIBLE (short-circuited before delay/controllability gates) |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | MR THOMAS BENNETT / NOT ELIGIBLE / OAL EMPLOYEE / CAD 0.00 | MR THOMAS BENNETT / NOT ELIGIBLE / OAL EMPLOYEE / CAD 0.00 |
| CP068 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP069 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP070 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your flight AC 455 from Montreal (YUL) to Toronto (YYZ) on May 23, 2026 was delayed by 4 hours. However,  |
| CP071 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP072 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP073 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP074 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP075 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to t***@lufthansa.com |  |
| CP076 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (OAL employee booking), regulation reference (APPR), contact inf |  |
| CP077 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP078 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP079 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Thomas Bennett" with PNR "TC036" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Thomas Bennett" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC036" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Thomas Bennett" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" and "OAL EMPLOYEE" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "t***@lufthansa.com" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***345" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "OAL Employee" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to employee check gate short-circuiting before delay and controll |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Thomas Bennett + TC036 + YUL?YYZ + FD" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP133 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to OAL Employee |  |
| CP134 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP135 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP136 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP137 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP138 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP139 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-02. | DDS returns FD-APPR-NE-02. |
| CP140 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 14:00; Actual = 18:00; Delay = 4hrs; MSL = Leg 1 (AC 327); Code 42; Controllable; APPR; Fallback = FALSE. | Trip Tracer: Promise = 14:00; Actual = 18:00; Delay = 4hrs; MSL = Leg 1 (AC 327); Code 42; Controllable; APPR; Fallback = FALSE. |
| CP141 | EXPECTED RESULTS | verdict | chat | Employee Check: OAL Employee booking flag = TRUE ? NOT ELIGIBLE (employee exclusion � partner airline staff). | Employee Check: OAL Employee booking flag = TRUE ? NOT ELIGIBLE (employee exclusion � partner airline staff). |
| CP142 | EXPECTED RESULTS | verdict | chat | Compensation: $0. | Compensation: $0. |
| CP143 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP144 | EXPECTED RESULTS | verdict | chat | IDV: NOT REQUIRED. | IDV: NOT REQUIRED. |
| CP145 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP146 | EXPECTED RESULTS | verdict | api | Regime Assessment: APPR = NE-02 (OAL Employee); EU = NE (Employee); ASL = NE (Employee). | Regime Assessment: APPR = NE-02 (OAL Employee); EU = NE (Employee); ASL = NE (Employee). |
| CP147 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Case = CASE-FD-20260508-023; Status = Closed � Not Eligible; Reason = OAL Employee (Lufthansa); $0; No payment; DDS = FD-A | Claims Dashboard: Case = CASE-FD-20260508-023; Status = Closed � Not Eligible; Reason = OAL Employee (Lufthansa); $0; No payment; DDS = FD-APPR-NE-02. |
