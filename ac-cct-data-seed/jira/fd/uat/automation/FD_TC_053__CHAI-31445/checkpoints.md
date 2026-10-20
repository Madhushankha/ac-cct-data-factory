# FD_TC_053 · CHAI-31445 — checkpoints

**Goal:** Single leg cancelled due to weather WEAT (Weather conditions � Uncontrollable). Customer stayed at origin. Under APPR, uncontrollable cancellation = Not Eligible even for No Travel. Validates that the No Travel Origin + Uncontrollable combination correctly returns Not Eligible.

Methods: seed 5, chat 40, api 21, email 3, dashboard 44, implied 16, manual 11, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Single leg cancelled due to weather WEAT (Weather conditions � Uncontrollable). Customer stayed at origin. Under APPR, uncontrollable cancel |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger, 1 leg AC domestic YUL?YYZ | PNR: Single passenger, 1 leg AC domestic YUL?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Flight status: CANCELLED | Flight status: CANCELLED |
| CP004 | PREREQUISITES | prerequisite | seed | Cancellation code: WEAT (Weather conditions � Uncontrollable) | Cancellation code: WEAT (Weather conditions � Uncontrollable) |
| CP005 | PREREQUISITES | prerequisite | seed | Customer action: Stayed at YUL, did NOT travel | Customer action: Stayed at YUL, did NOT travel |
| CP006 | PREREQUISITES | prerequisite | seed | No Travel status: Origin | No Travel status: Origin |
| CP007 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP008 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP009 | START | customer | chat | Then user selects English |  |
| CP010 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP011 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP012 | START | customer | chat | And the user says "My flight from Montreal to Toronto was cancelled due to bad weather and I didn't take any replacement flight. Can I get c | My flight from Montreal to Toronto was cancelled due to bad weather and I didn't take any replacement flight. Can I get compensation? |
| CP013 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP014 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP015 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP016 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP017 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP018 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP019 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Nathalie Fortin" | Nathalie Fortin |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Nathalie! And, what is your booking reference number? |
| CP021 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC040" | PNR: TC040 |
| CP022 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC040 |  |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP025 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: n***@outlook.com � Phone: +1***901 |
| CP027 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: n***@outlook.com" | Email: n***@outlook.com |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP029 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP030 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP032 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP033 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP034 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP035 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP036 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Nathalie Fortin (Adult) Is this who you'd like to include? |
| CP037 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP038 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP039 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 460 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: May 28, 2026 � Status: CANCELLED Is this the journey you'd like  |
| CP040 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP041 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP042 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP044 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure |  |
| CP045 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure was May 28, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP046 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP047 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 28, 2026; filing June 15, 2026 ? 18 days ? within 366 days ? PROCEED |  |
| CP048 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP049 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 460, Route: YUL ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 12:00 | Promised Itinerary - Flight: AC 460, Route: YUL ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 12:00 |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 460, Route: YUL ? YYZ, Status: CANCELLED | Current Itinerary - Flight: AC 460, Route: YUL ? YYZ, Status: CANCELLED |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Customer Status: NO TRAVEL - ORIGIN (customer never departed, declined rebooking) | Customer Status: NO TRAVEL - ORIGIN (customer never departed, declined rebooking) |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | History - No rebooking accepted | History - No rebooking accepted |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 460 � YUL ? YYZ � WEAT | MSL FLIGHT: AC 460 � YUL ? YYZ � WEAT |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | "Cancellation �weather conditions" | "Cancellation �weather conditions" |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | UNCONTROLLABLE (WEAT) | UNCONTROLLABLE (WEAT) |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Disruption Type: CANCELLATION | Disruption Type: CANCELLATION |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | DDS Gate 9: Uncontrollable ? NOT ELIGIBLE | DDS Gate 9: Uncontrollable ? NOT ELIGIBLE |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | MS NATHALIE FORTIN / NOT ELIGIBLE / UNCONTROLLABLE / CAD 0.00 | MS NATHALIE FORTIN / NOT ELIGIBLE / UNCONTROLLABLE / CAD 0.00 |
| CP062 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP063 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP064 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your flight AC 460 from Montreal (YUL) to Toronto (YYZ) on May 28, 2026 was cancelled. However, you are n |
| CP065 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP066 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP067 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP068 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP069 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to n***@outlook.com |  |
| CP070 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (uncontrollable � severe weather), travel status (No Travel - Or |  |
| CP071 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP072 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP073 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Nathalie Fortin" with PNR "TC040" |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Nathalie Fortin" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC040" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Nathalie Fortin" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "n***@outlook.com" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***901" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Uncontrollable � weather" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Nathalie Fortin + TC040 + YUL?YYZ + FD" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP127 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to uncontrollable weather |  |
| CP128 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP131 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section    Given the eligibilit |  |
| CP133 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP134 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP135 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP136 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP138 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-08. | DDS returns FD-APPR-NE-08. |
| CP139 | EXPECTED RESULTS | verdict | api | Trip Tracer: Flight = CANCELLED; MSL = Leg 1; Cancellation Code = WEAT ; Uncontrollable (Weather); No Travel = TRUE; Status = Origin; APPR;  | Trip Tracer: Flight = CANCELLED; MSL = Leg 1; Cancellation Code = WEAT ; Uncontrollable (Weather); No Travel = TRUE; Status = Origin; APPR; Not Eligible. |
| CP140 | EXPECTED RESULTS | verdict | chat | Compensation: $0. | Compensation: $0. |
| CP141 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Not Eligible; Uncontrollable; No Travel = Origin; DDS = FD-APPR-NE-05. | Claims Dashboard: Not Eligible; Uncontrollable; No Travel = Origin; DDS = FD-APPR-NE-05. |
