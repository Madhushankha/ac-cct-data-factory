# FD_TC_142 · CHAI-31534 — checkpoints

**Goal:** EU Mainland flight (CDG?YYZ, AC-operated) cancelled due to controllable reason (cancellation code CREW), but the re-routing delay to next available flight was only 2 hours � below the 3-hour EU 261 threshold (Gate 8). Despite controllable cause and cancellation, insufficient delay = NOT ELIGIBLE. Validates: (1) EU 261 3-hour threshold applies to No Travel Origin scenarios, (2) Threshold overrides controllability � even with CREW (controllable) cancellation code, delay below 3h = NE, (3) Cancellation code CREW correctly classified as Controllable but threshold still blocks eligibility.

Methods: seed 11, chat 40, api 10, email 3, dashboard 44, implied 16, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | EU Mainland flight (CDG?YYZ, AC-operated) cancelled due to controllable reason (cancellation code CREW), but the re-routing delay to next av |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Arnaud Picard (Adult) | PNR: single passenger Arnaud Picard (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 871, CDG?YYZ | Journey: 1 leg AC operated, Flight AC 871, CDG?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Flight status: CANCELLED | Flight status: CANCELLED |
| CP005 | PREREQUISITES | prerequisite | seed | Cancellation code: CREW (Crew unavailability � Controllable) | Cancellation code: CREW (Crew unavailability � Controllable) |
| CP006 | PREREQUISITES | prerequisite | seed | Original scheduled arrival: 13:00 | Original scheduled arrival: 13:00 |
| CP007 | PREREQUISITES | prerequisite | seed | Next available rebooking arrival: 15:00 (2hr delay � below 3hr threshold) | Next available rebooking arrival: 15:00 (2hr delay � below 3hr threshold) |
| CP008 | PREREQUISITES | prerequisite | seed | Customer action: Stayed at CDG, did NOT accept rebooking, did NOT travel | Customer action: Stayed at CDG, did NOT accept rebooking, did NOT travel |
| CP009 | PREREQUISITES | prerequisite | seed | No Travel status: Origin | No Travel status: Origin |
| CP010 | PREREQUISITES | prerequisite | seed | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP011 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (EU Mainland � CDG origin) | Regime: EU 261 (EU Mainland � CDG origin) |
| CP012 | PREREQUISITES | prerequisite | seed | Result: NOT ELIGIBLE (delay below 3hr threshold despite controllable cause) | Result: NOT ELIGIBLE (delay below 3hr threshold despite controllable cause) |
| CP013 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP014 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP015 | START | customer | chat | Then user selects English |  |
| CP016 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP017 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP018 | START | customer | chat | And the user says "My flight from Paris to Toronto was disrupted and I decided not to take any replacement flight. Can I get compensation?" | My flight from Paris to Toronto was disrupted and I decided not to take any replacement flight. Can I get compensation? |
| CP019 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP020 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP021 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP022 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Arnaud Picard" | Arnaud Picard |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Arnaud! And, what is your booking reference number? |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC102" | PNR: TC102 |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC102 |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: a***@gmail.com Phone: +33***456 |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: a***@gmail.com" | Email: a***@gmail.com |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP036 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP038 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Arnaud Picard (Adult) Is this who you'd like to include? |
| CP043 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP045 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 871 Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ) Date: May 28, 2026 Status: Disrupted (MSL delay: 2 hours) Is  |
| CP046 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP047 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure |  |
| CP051 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure was May 28, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED |  |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction � CDG origin) = 5 years ? within limitation ? PROCEED |  |
| CP053 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = CDG (Paris, EU Mainland) ? EU 261 (EU Mainland) |  |
| CP054 | REGIME DETERMINATION | system | implied | And the system checks: Customer did NOT travel ? No Travel Origin (remained at CDG) |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC102 | Cancellation � crew unavailability |
| CP058 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP059 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your arrival in Toronto was on time. That means there's no recorded delay for this part of your trip. Based  |
| CP060 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP061 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP062 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP063 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP064 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to a***@gmail.com |  |
| CP065 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (CDG?YYZ CANCELLED), not eligible reason (MSL delay below 3-hour threshold despite co |  |
| CP066 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP067 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP068 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Arnaud Picard" with PNR "TC102" |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation" |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Arnaud Picard" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC102" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (EU Mainland)" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Arnaud Picard" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "a***@gmail.com" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+33***456" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: CDG ? YYZ" with claim filed for this flight as cancelled |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "MSL delay 2h � below EU 261 minimum 3-ho |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to delay 2h being less than 3h EU 261 threshold |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Arnaud Picard + TC102 + CDG?YYZ + FD" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe to "a***@gmail.com" containing Case Reference and flight details CDG t |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP122 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to MSL delay below 3-hour threshold |  |
| CP123 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP124 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP125 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP126 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP128 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-NE-13. | DDS returns FD-EU-NE-13. |
| CP129 | EXPECTED RESULTS | verdict | api | Trip Tracer: CANCELLED; MSL = Leg 1 (AC 871 CDG?YYZ); Cancellation Code = CREW; Re-routing delay = 2hrs (below 3hr threshold � Gate 8); No T | Trip Tracer: CANCELLED; MSL = Leg 1 (AC 871 CDG?YYZ); Cancellation Code = CREW; Re-routing delay = 2hrs (below 3hr threshold � Gate 8); No Travel = Origin (cust |
| CP130 | EXPECTED RESULTS | verdict | chat | CRITICAL: Despite controllable cancellation code CREW, delay is below 3hr threshold ? NE. | CRITICAL: Despite controllable cancellation code CREW, delay is below 3hr threshold ? NE. |
| CP131 | EXPECTED RESULTS | verdict | chat | Threshold applies regardless of controllability. | Threshold applies regardless of controllability. |
| CP132 | EXPECTED RESULTS | verdict | chat | Result: NOT ELIGIBLE, �0. | Result: NOT ELIGIBLE, �0. |
| CP133 | EXPECTED RESULTS | verdict | chat | CyberSource: NOT triggered. | CyberSource: NOT triggered. |
| CP134 | EXPECTED RESULTS | verdict | chat | Payment: NONE. | Payment: NONE. |
| CP135 | EXPECTED RESULTS | verdict | api | DDS = FD-EU-NE-13. | DDS = FD-EU-NE-13. |
