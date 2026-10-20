# FD_TC_045 · CHAI-31437 — checkpoints

**Goal:** Passenger is an Air Canada employee travelling on a staff/employee booking. Employee bookings are NOT eligible for compensation under ANY regime � APPR, EU 261, or ASL. The employee exclusion is a universal override that applies BEFORE controllability or delay assessment � even though the flight has a 4hr controllable delay (which would normally yield $400), the employee flag terminates eligibility immediately. Validates that: (1) DDS detects the employee booking flag from Trip Tracer, (2) Employee exclusion overrides all other eligible conditions (controllable code, sufficient delay, valid route), (3) No payment flow is triggered (CyberSource NOT invoked, IDV NOT required), (4) All three regimes return Not Eligible simultaneously. This is a PRE-ASSESSMENT exclusion � DDS should check employee status before running the full delay/controllability/tier logic.

Methods: seed 12, chat 41, api 23, email 3, dashboard 44, implied 16, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Passenger is an Air Canada employee travelling on a staff/employee booking. Employee bookings are NOT eligible for compensation under ANY re |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC022 � single passenger (Adult) | PNR: TC022 � single passenger (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Employee Flag: AC EMPLOYEE BOOKING � staff travel flag present in Trip Tracer PNR data | Employee Flag: AC EMPLOYEE BOOKING � staff travel flag present in Trip Tracer PNR data |
| CP004 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 326, YUL?YYZ (domestic Canada) | Journey: 1 leg AC operated, Flight AC 326, YUL?YYZ (domestic Canada) |
| CP005 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 14:00 | Scheduled arrival: 14:00 |
| CP006 | PREREQUISITES | prerequisite | seed | Actual arrival: 18:00 (4hr delay) | Actual arrival: 18:00 (4hr delay) |
| CP007 | PREREQUISITES | prerequisite | seed | Disruption code: 42(Scheduled Maintenance� Controllable) | Disruption code: 42(Scheduled Maintenance� Controllable) |
| CP008 | PREREQUISITES | prerequisite | seed | Arrival code: 42(available, no fallback needed) | Arrival code: 42(available, no fallback needed) |
| CP009 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic Canada) | Regime: APPR (domestic Canada) |
| CP010 | PREREQUISITES | prerequisite | seed | Booking changes: None | Booking changes: None |
| CP011 | PREREQUISITES | prerequisite | seed | Timing: >72hrs elapsed | Timing: >72hrs elapsed |
| CP012 | PREREQUISITES | prerequisite | seed | Filing: Within 1-year limitation | Filing: Within 1-year limitation |
| CP013 | PREREQUISITES | prerequisite | seed | Key distinction: Despite controllable 4hr delay on valid domestic route (normally $400 Tier 1), the employee flag overrides everything | Key distinction: Despite controllable 4hr delay on valid domestic route (normally $400 Tier 1), the employee flag overrides everything |
| CP014 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP015 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP016 | START | customer | chat | Then user selects English |  |
| CP017 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP018 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP019 | START | customer | chat | And the user says "My flight was delayed about 4 hours due to a maintenance issue, I'd like to check if I'm eligible for compensation" | My flight was delayed about 4 hours due to a maintenance issue, I'd like to check if I'm eligible for compensation |
| CP020 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP021 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP022 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP023 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Antoine Lefevre" | Antoine Lefevre |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Antoine! And, what is your booking reference number? |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC035" | PNR: TC035 |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC035 |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer flags: EMPLOYEE BOOKING DETECTED (AC employee flag present on PNR) |  |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: a***@aircanada.ca � Phone: +1***234 |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: a***@aircanada.ca" | Email: a***@aircanada.ca |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP038 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP040 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP041 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP042 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP043 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP044 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Antoine Lefevre (Adult) [EMPLOYEE] Is this who you'd like to include? |
| CP045 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP047 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 454 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: May 22, 2026 � Arrival Delay: 4 hours Is this the journey you'd  |
| CP048 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP049 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP050 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP052 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP053 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 22, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP054 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP055 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 22, 2026; filing June 15, 2026 ? 24 days ? within 366 days ? PROCEED |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Is passenger an AC employee? ? YES (employee flag on PNR) |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS short-circuits: EMPLOYEE ? NOT ELIGIBLE (employee check gate � before controllability or delay checks) |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 454, Route: YUL ? YYZ, Scheduled Arrival: 14:00 | Promised Itinerary - Flight: AC 454, Route: YUL ? YYZ, Scheduled Arrival: 14:00 |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 454, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 14:00 ? Actual: 18:00, Delay: +4H 00M | Current Itinerary - Flight: AC 454, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 14:00 ? Actual: 18:00, Delay: +4H 00M |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Passenger Flag: AC EMPLOYEE | Passenger Flag: AC EMPLOYEE |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 454 � YUL ? YYZ � 42 | MSL FLIGHT: AC 454 � YUL ? YYZ � 42 |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to scheduled maintenance" | "Delayed due to scheduled maintenance" |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +4H 00M � CONTROLLABLE | Delay: +4H 00M � CONTROLLABLE |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | DDS Gate: EMPLOYEE CHECK ? NOT ELIGIBLE (short-circuited before delay/controllability gates) | DDS Gate: EMPLOYEE CHECK ? NOT ELIGIBLE (short-circuited before delay/controllability gates) |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | MR ANTOINE LEFEVRE / NOT ELIGIBLE / EMPLOYEE / CAD 0.00 | MR ANTOINE LEFEVRE / NOT ELIGIBLE / EMPLOYEE / CAD 0.00 |
| CP069 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP070 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP071 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your flight AC 454 from Montreal (YUL) to Toronto (YYZ) on May 22, 2026 was delayed by 4 hours. However,  |
| CP072 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP073 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP074 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP075 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP076 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to a***@aircanada.ca |  |
| CP077 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (employee booking), regulation reference (APPR), contact informa |  |
| CP078 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP079 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP080 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Antoine Lefevre" with PNR "TC035" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Antoine Lefevre" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC035" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Antoine Lefevre" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" and "EMPLOYEE" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "a***@aircanada.ca" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***234" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "AC Employee" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to employee check gate short-circuiting before delay and controll |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Antoine Lefevre + TC035 + YUL?YYZ + FD" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP134 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to AC Employee |  |
| CP135 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP136 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP138 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP139 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP140 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-01. | DDS returns FD-APPR-NE-01. |
| CP141 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 14:00; Actual = 18:00; Delay = 4hrs; MSL = Leg 1 (AC 326); Code 42; Controllable; APPR; Fallback = FALSE. | Trip Tracer: Promise = 14:00; Actual = 18:00; Delay = 4hrs; MSL = Leg 1 (AC 326); Code 42; Controllable; APPR; Fallback = FALSE. |
| CP142 | EXPECTED RESULTS | verdict | chat | Employee Check: AC Employee booking flag = TRUE ? NOT ELIGIBLE (employee exclusion overrides all regime assessments). | Employee Check: AC Employee booking flag = TRUE ? NOT ELIGIBLE (employee exclusion overrides all regime assessments). |
| CP143 | EXPECTED RESULTS | verdict | chat | CRITICAL: Despite controllable cause + 4hr delay + valid route (normally $400), employee status blocks eligibility. | CRITICAL: Despite controllable cause + 4hr delay + valid route (normally $400), employee status blocks eligibility. |
| CP144 | EXPECTED RESULTS | verdict | api | DDS should NOT calculate compensation amount � exclusion applies before tier calculation. | DDS should NOT calculate compensation amount � exclusion applies before tier calculation. |
| CP145 | EXPECTED RESULTS | verdict | chat | Compensation: $0 � Not Eligible (AC Employee). | Compensation: $0 � Not Eligible (AC Employee). |
| CP146 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED (CyberSource only runs for eligible cases). | Fraud Screening: NOT INVOKED (CyberSource only runs for eligible cases). |
| CP147 | EXPECTED RESULTS | verdict | chat | IDV: NOT REQUIRED. | IDV: NOT REQUIRED. |
| CP148 | EXPECTED RESULTS | verdict | chat | Payment: N/A (no payment flow triggered). | Payment: N/A (no payment flow triggered). |
| CP149 | EXPECTED RESULTS | verdict | api | Regime Assessment: APPR = NE-01 (Employee); EU = NE (Employee); ASL = NE (Employee) � all regimes blocked by universal employee exclusion. | Regime Assessment: APPR = NE-01 (Employee); EU = NE (Employee); ASL = NE (Employee) � all regimes blocked by universal employee exclusion. |
| CP150 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Case = CASE-FD-20260508-022; Status = Closed � Not Eligible; Reason = AC Employee;$0; No payment; No IDV; No fraud screeni | Claims Dashboard: Case = CASE-FD-20260508-022; Status = Closed � Not Eligible; Reason = AC Employee;$0; No payment; No IDV; No fraud screening; DDS = FD-APPR-NE |
