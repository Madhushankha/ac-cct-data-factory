# FD_TC_087 · CHAI-31479 — checkpoints

**Goal:** Single leg delayed due to controllable reason (delay code 42 � scheduled maintenance). The MSL departure and arrival delay was only 2 hours 30 minutes � below the 3-hour threshold. The customer chose not to travel and stayed at origin.

Methods: seed 15, chat 42, api 28, email 3, dashboard 44, implied 16, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Single leg delayed due to controllable reason (delay code 42 � scheduled maintenance). The MSL departure and arrival delay was only 2 hours  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC046 � single passenger (Adult) | PNR: TC046 � single passenger (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | 1 leg AC operated | 1 leg AC operated |
| CP004 | PREREQUISITES | prerequisite | seed | Flight AC 480, YUL ? YYZ (domestic) | Flight AC 480, YUL ? YYZ (domestic) |
| CP005 | PREREQUISITES | prerequisite | seed | Sched Dep: 10:00, Sched Arr: 12:00 | Sched Dep: 10:00, Sched Arr: 12:00 |
| CP006 | PREREQUISITES | prerequisite | seed | Flight status: DELAYED (NOT cancelled � flight operated with delay) | Flight status: DELAYED (NOT cancelled � flight operated with delay) |
| CP007 | PREREQUISITES | prerequisite | seed | Delay code: 42 (Scheduled Maintenance � controllable) | Delay code: 42 (Scheduled Maintenance � controllable) |
| CP008 | PREREQUISITES | prerequisite | seed | Actual Dep: 12:30, Actual Arr: 14:30 | Actual Dep: 12:30, Actual Arr: 14:30 |
| CP009 | PREREQUISITES | prerequisite | seed | MSL delay: 2h 30m (150 min � below 3-hour threshold) | MSL delay: 2h 30m (150 min � below 3-hour threshold) |
| CP010 | PREREQUISITES | prerequisite | seed | Customer action: Customer chose not to board the delayed flight, stayed at YUL (origin), did NOT travel | Customer action: Customer chose not to board the delayed flight, stayed at YUL (origin), did NOT travel |
| CP011 | PREREQUISITES | prerequisite | seed | No Travel status: Origin | No Travel status: Origin |
| CP012 | PREREQUISITES | prerequisite | seed | Fallback: FALSE (delay code available) | Fallback: FALSE (delay code available) |
| CP013 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic) | Regime: APPR (domestic) |
| CP014 | PREREQUISITES | prerequisite | seed | Timing: >72hrs elapsed | Timing: >72hrs elapsed |
| CP015 | PREREQUISITES | prerequisite | seed | Filing: Within 366 days | Filing: Within 366 days |
| CP016 | PREREQUISITES | prerequisite | seed | CRITICAL: Flight was DELAYED, not cancelled | CRITICAL: Flight was DELAYED, not cancelled |
| CP017 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP018 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP019 | START | customer | chat | Then user selects English |  |
| CP020 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP021 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP022 | START | customer | chat | And the user says "My flight from Montreal to Toronto was delayed and I decided not to take it. Can I get compensation?" | My flight from Montreal to Toronto was delayed and I decided not to take it. Can I get compensation? |
| CP023 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP024 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP025 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP026 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Thierry Rousseau" | Thierry Rousseau |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Thierry! And, what is your booking reference number? |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC046" | PNR: TC046 |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC046 |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***123 |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP042 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP043 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP044 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP045 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP046 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Thierry Rousseau (Adult) Is this who you'd like to include? |
| CP047 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP049 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 480 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 3, 2026 � Status: DELAYED � Arrival Delay: 2 hours 30 minut |
| CP050 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP051 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP052 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP053 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP054 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure |  |
| CP055 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure was June 3, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP056 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP057 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption June 3, 2026; filing June 15, 2026 ? 12 days ? within 366 days ? PROCEED |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 480, Route: YUL ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 12:00 | Promised Itinerary - Flight: AC 480, Route: YUL ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 12:00 |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 480, Route: YUL ? YYZ, Status: DELAYED (flight operated with delay) | Current Itinerary - Flight: AC 480, Route: YUL ? YYZ, Status: DELAYED (flight operated with delay) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Actual Departure: 12:30, Actual Arrival: 14:30 | Actual Departure: 12:30, Actual Arrival: 14:30 |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Customer Status: NO TRAVEL - ORIGIN (customer chose not to board delayed flight, stayed at YUL) | Customer Status: NO TRAVEL - ORIGIN (customer chose not to board delayed flight, stayed at YUL) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | History - Customer did not board | History - Customer did not board |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 480 � YUL ? YYZ � 42 | MSL FLIGHT: AC 480 � YUL ? YYZ � 42 |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to scheduled maintenance" | "Delayed due to scheduled maintenance" |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42) | CONTROLLABLE (Code 42) |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | Disruption Type: DELAY (NOT cancellation) | Disruption Type: DELAY (NOT cancellation) |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | MSL Delay: Departure delay = 150 min (2h 30m), Arrival delay = 150 min (2h 30m) | MSL Delay: Departure delay = 150 min (2h 30m), Arrival delay = 150 min (2h 30m) |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | No Travel Gate: Was MSL delayed 3+ hours OR cancelled? ? Delay = 150 min (< 180 min) AND NOT cancelled ? NO ? NOT ELIGIBLE | No Travel Gate: Was MSL delayed 3+ hours OR cancelled? ? Delay = 150 min (< 180 min) AND NOT cancelled ? NO ? NOT ELIGIBLE |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | Controllability check NOT REACHED � short-circuited at No Travel gate | Controllability check NOT REACHED � short-circuited at No Travel gate |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE (delay code available) | Fallback: FALSE (delay code available) |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | MR THIERRY ROUSSEAU / NOT ELIGIBLE / DELAY_BELOW_THRESHOLD / CAD 0.00 | MR THIERRY ROUSSEAU / NOT ELIGIBLE / DELAY_BELOW_THRESHOLD / CAD 0.00 |
| CP075 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP076 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP077 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your arrival in Toronto was on time. That means there's no recorded delay for this part of your trip. Based  |
| CP078 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP079 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP080 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP081 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP082 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to t***@gmail.com |  |
| CP083 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (MSL delay below 3-hour threshold � flight delayed 2h 30m, not c |  |
| CP084 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP085 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP086 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Thierry Rousseau" with PNR "TC046" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Thierry Rousseau" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC046" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Thierry Rousseau" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "t***@gmail.com" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***123" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Delay below 3-hour threshold" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to effective delay 2h 30m being less than 3 hours short-circuited |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Thierry Rousseau + TC046 + YUL?YYZ + FD" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP140 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to delay below 3-hour threshold |  |
| CP141 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP142 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP143 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP144 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP145 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP146 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-20. | DDS returns FD-APPR-NE-20. |
| CP147 | EXPECTED RESULTS | verdict | api | Trip Tracer: Flight AC 480 YUL?YYZ = DELAYED (NOT cancelled). | Trip Tracer: Flight AC 480 YUL?YYZ = DELAYED (NOT cancelled). |
| CP148 | EXPECTED RESULTS | verdict | api | Delay code = 42 (Scheduled Maintenance). | Delay code = 42 (Scheduled Maintenance). |
| CP149 | EXPECTED RESULTS | verdict | chat | Controllable. | Controllable. |
| CP150 | EXPECTED RESULTS | verdict | api | MSL delay = 150 min (2h 30m). | MSL delay = 150 min (2h 30m). |
| CP151 | EXPECTED RESULTS | verdict | api | MSL = Leg 1. | MSL = Leg 1. |
| CP152 | EXPECTED RESULTS | verdict | chat | No Travel = TRUE, Status = Origin. | No Travel = TRUE, Status = Origin. |
| CP153 | EXPECTED RESULTS | verdict | api | No Travel Gate: "Was MSL delayed 3+ hours OR cancelled?" ? Delay = 150 min (< 180 min) AND flight NOT cancelled ? NO ? NOT ELIGIBLE. | No Travel Gate: "Was MSL delayed 3+ hours OR cancelled?" ? Delay = 150 min (< 180 min) AND flight NOT cancelled ? NO ? NOT ELIGIBLE. |
| CP154 | EXPECTED RESULTS | verdict | chat | Controllability check NOT reached � short-circuited at No Travel gate. | Controllability check NOT reached � short-circuited at No Travel gate. |
| CP155 | EXPECTED RESULTS | verdict | chat | Compensation: $0. | Compensation: $0. |
| CP156 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP157 | EXPECTED RESULTS | verdict | chat | IDV: NOT REQUIRED. | IDV: NOT REQUIRED. |
| CP158 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP159 | EXPECTED RESULTS | verdict | api | APPR = NE-20 (No Travel Origin + Delay Below 3h); EU = N/A; ASL = N/A. | APPR = NE-20 (No Travel Origin + Delay Below 3h); EU = N/A; ASL = N/A. |
