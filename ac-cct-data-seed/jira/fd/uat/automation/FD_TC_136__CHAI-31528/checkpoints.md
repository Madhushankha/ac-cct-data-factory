# FD_TC_136 · CHAI-31528 — checkpoints

**Goal:** Customer is an Air Canada employee travelling on an employee booking. Employee bookings are NOT eligible for compensation under ANY regime (EU 261, APPR, ASL). Validates that DDS correctly detects the employee booking flag in the PNR and returns Not Eligible regardless of delay duration or controllability. Mirrors APPR employee test (TC_043) but under EU 261.

Methods: seed 5, chat 38, api 17, email 3, dashboard 44, implied 14, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer is an Air Canada employee travelling on an employee booking. Employee bookings are NOT eligible for compensation under ANY regime ( |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (AC employee), 1 leg AC operated LHR?YYZ | PNR: Single passenger (AC employee), 1 leg AC operated LHR?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Employee booking flag: TRUE in PNR | Employee booking flag: TRUE in PNR |
| CP004 | PREREQUISITES | prerequisite | seed | Itinerary: Scheduled arrival 16:00, Actual arrival 20:00 (4hr delay) | Itinerary: Scheduled arrival 16:00, Actual arrival 20:00 (4hr delay) |
| CP005 | PREREQUISITES | prerequisite | seed | Disruption code: 42 (Controllable) | Disruption code: 42 (Controllable) |
| CP006 | PREREQUISITES | prerequisite | seed | Booking type: Employee/staff travel | Booking type: Employee/staff travel |
| CP007 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP008 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP009 | START | customer | chat | Then user selects English |  |
| CP010 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP011 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP012 | START | customer | chat | And the user says "My flight from Paris to Toronto was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensati | My flight from Paris to Toronto was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation |
| CP013 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP014 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP015 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP016 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP017 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP018 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP019 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Marc Lefebvre" | Marc Lefebvre |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Marc! And, what is your booking reference number? |
| CP021 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC095" | PNR: TC095 |
| CP022 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC095 |  |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data is revealed � EMPLOYEE BOOKING IDENTIFIER PRESENT (AC Employee) |  |
| CP025 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: m***@aircanada.ca � Phone: +33***345 |
| CP027 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: m***@aircanada.ca" | Email: m***@aircanada.ca |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP029 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP030 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP032 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP033 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP034 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP035 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP036 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Marc Lefebvre (Adult) [AC Employee] Is this who you'd like to include? |
| CP037 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP038 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP039 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 871 � Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ) � Date: June 3, 2026 � Arrival Delay: 4 hours Is this the |
| CP040 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP041 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP042 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP044 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP045 | EMPLOYEE CHECK | system | implied | Then the system checks: Is passenger an AC employee? ? YES (employee booking identifier present) |  |
| CP046 | EMPLOYEE CHECK | system | implied | Then the system determines: AC EMPLOYEE ? NOT ELIGIBLE (employee bookings excluded from all regimes) |  |
| CP047 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP048 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 871, Route: CDG ? YYZ, Scheduled Arrival: 13:00 | Promised Itinerary - Flight: AC 871, Route: CDG ? YYZ, Scheduled Arrival: 13:00 |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 871, Route: CDG ? YYZ, Status: ARRIVED LATE, Actual: 17:00, Delay: +4H 00M | Current Itinerary - Flight: AC 871, Route: CDG ? YYZ, Status: ARRIVED LATE, Actual: 17:00, Delay: +4H 00M |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | Passenger: AC EMPLOYEE (employee booking identifier present) | Passenger: AC EMPLOYEE (employee booking identifier present) |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Regime: EU 261 (EU origin � CDG) � BUT employee exclusion applies | Regime: EU 261 (EU origin � CDG) � BUT employee exclusion applies |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 871 � CDG ? YYZ � 42 � CONTROLLABLE | MSL FLIGHT: AC 871 � CDG ? YYZ � 42 � CONTROLLABLE |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | Employee Check: AC EMPLOYEE ? NOT ELIGIBLE (overrides all other checks) | Employee Check: AC EMPLOYEE ? NOT ELIGIBLE (overrides all other checks) |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | MR MARC LEFEBVRE / NOT ELIGIBLE / EMPLOYEE_AC / CAD 0.00 | MR MARC LEFEBVRE / NOT ELIGIBLE / EMPLOYEE_AC / CAD 0.00 |
| CP056 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP057 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your flight AC 871 from Paris Charles de Gaulle (CDG) to Toronto (YYZ) was delayed by 4 hours. However, b |
| CP058 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP059 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP060 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP061 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP062 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to m***@aircanada.ca |  |
| CP063 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (AC employee booking), regulation reference, contact information |  |
| CP064 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP065 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP066 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Marc Lefebvre" with PNR "TC095" |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Marc Lefebvre" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC095" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (EU origin � CDG)" but employee exclusion applies |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Marc Lefebvre" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" and "AC Employee" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "m***@aircanada.ca" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+33***345" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: CDG ? YYZ" with claim filed for this flight |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "AC Employee � employee bookings excluded |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to AC Employee booking overriding all other checks including cont |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Marc Lefebvre + TC095 + CDG?YYZ + FD" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe to "m***@aircanada.ca" containing Case Reference and flight details an |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP120 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to AC Employee |  |
| CP121 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP122 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP123 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP124 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP125 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP126 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-NE-01. | DDS returns FD-EU-NE-01. |
| CP127 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 16:00; Actual = 20:00; Delay = 4hrs; MSL = Leg 1; Code 42; Controllable; EU 261. | Trip Tracer: Promise = 16:00; Actual = 20:00; Delay = 4hrs; MSL = Leg 1; Code 42; Controllable; EU 261. |
| CP128 | EXPECTED RESULTS | verdict | chat | Employee check: Employee booking flag = TRUE ? NOT ELIGIBLE (overrides all other checks). | Employee check: Employee booking flag = TRUE ? NOT ELIGIBLE (overrides all other checks). |
| CP129 | EXPECTED RESULTS | verdict | chat | CRITICAL: Even though delay is 4hrs, controllable, employee bookings are excluded. | CRITICAL: Even though delay is 4hrs, controllable, employee bookings are excluded. |
| CP130 | EXPECTED RESULTS | verdict | api | DDS should NOT even calculate compensation for employee bookings. | DDS should NOT even calculate compensation for employee bookings. |
| CP131 | EXPECTED RESULTS | verdict | chat | Compensation: $0. | Compensation: $0. |
| CP132 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Not Eligible; Reason = Employee booking; Employee flag = TRUE; DDS = FD-EU-NE-01. | Claims Dashboard: Not Eligible; Reason = Employee booking; Employee flag = TRUE; DDS = FD-EU-NE-01. |
