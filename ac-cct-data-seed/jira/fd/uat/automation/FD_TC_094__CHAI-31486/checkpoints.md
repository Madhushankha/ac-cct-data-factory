# FD_TC_094 · CHAI-31486 — checkpoints

**Goal:** Flight delayed 6 hours due to safety regulation (Code 81). Safety under APPR is a separate category � not controllable, not uncontrollable. Disruptions required for safety are never eligible regardless of delay. Would be Tier 2 ($700) if controllable, but Safety overrides. This is the Travel Completed counterpart to the No Travel Safety tests (TC_052�057). Validates that Safety classification applies equally to delays as it does to cancellations.

Methods: seed 7, chat 39, api 21, email 3, dashboard 44, implied 16, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Flight delayed 6 hours due to safety regulation (Code 81). Safety under APPR is a separate category � not controllable, not uncontrollable.  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger (Adult) | PNR: single passenger (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 366, YUL?YYZ (domestic) | Journey: 1 leg AC operated, Flight AC 366, YUL?YYZ (domestic) |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 10:00 | Scheduled arrival: 10:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival: 16:00 (6hr delay) | Actual arrival: 16:00 (6hr delay) |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival delay code: 81 (Safety rgeulation, available, no fallback) | Arrival delay code: 81 (Safety rgeulation, available, no fallback) |
| CP007 | PREREQUISITES | prerequisite | seed | Delay: 6hrs (360 min � would be Tier 2 $700 if controllable) | Delay: 6hrs (360 min � would be Tier 2 $700 if controllable) |
| CP008 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic) | Regime: APPR (domestic) |
| CP009 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP010 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP011 | START | customer | chat | Then user selects English |  |
| CP012 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP013 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP014 | START | customer | chat | And the user says "My flight was delayed about 6 hours due to a mechanical safety inspection, I'd like to check if I'm eligible for compensa | My flight was delayed about 6 hours due to a mechanical safety inspection, I'd like to check if I'm eligible for compensation |
| CP015 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP016 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP017 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP018 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP021 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Marie-Claire Dubois" | Marie-Claire Dubois |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Marie-Claire! And, what is your booking reference number? |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC053" | PNR: TC053 |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC053 |  |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: m***@gmail.com � Phone: +1***012 |
| CP029 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: m***@gmail.com" | Email: m***@gmail.com |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP032 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP034 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP035 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP036 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP037 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP038 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Marie-Claire Dubois (Adult) Is this who you'd like to include? |
| CP039 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP040 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP041 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 496 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 6, 2026 � Arrival Delay: 6 hours Is this the journey you'd  |
| CP042 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP046 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP047 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was June 6, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP048 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP049 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption June 6, 2026; filing June 15, 2026 ? 9 days ? within 366 days ? PROCEED |  |
| CP050 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP051 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 496, Route: YUL ? YYZ, Scheduled Arrival: 12:00 | Promised Itinerary - Flight: AC 496, Route: YUL ? YYZ, Scheduled Arrival: 12:00 |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 496, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 12:00 ? Actual: 18:00, Delay: +6H 00M | Current Itinerary - Flight: AC 496, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 12:00 ? Actual: 18:00, Delay: +6H 00M |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 496 � YUL ? YYZ � 43 | MSL FLIGHT: AC 496 � YUL ? YYZ � 43 |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to non-scheduled maintenance / mechanical safety inspection" | "Delayed due to non-scheduled maintenance / mechanical safety inspection" |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +6H 00M � SAFETY | Delay: +6H 00M � SAFETY |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | APPR Gate 8: Delay 6h ? 3h ? PASSES threshold | APPR Gate 8: Delay 6h ? 3h ? PASSES threshold |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | APPR Gate 9: Code 43 = Safety ? NOT ELIGIBLE under APPR | APPR Gate 9: Code 43 = Safety ? NOT ELIGIBLE under APPR |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE | Fallback: FALSE |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | MS MARIE-CLAIRE DUBOIS / NOT ELIGIBLE / SAFETY / CAD 0.00 | MS MARIE-CLAIRE DUBOIS / NOT ELIGIBLE / SAFETY / CAD 0.00 |
| CP062 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP063 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP064 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your departure from Montreal was delayed by 6 hours. However, you are not eligible for expense reimbursem |
| CP065 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP066 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP067 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP068 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP069 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to m***@gmail.com |  |
| CP070 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (safety � mechanical safety inspection), regulation reference (A |  |
| CP071 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP072 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP073 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Marie-Claire Dubois" with PNR "TC053" |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Marie-Claire Dubois" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC053" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Marie-Claire Dubois" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "m***@gmail.com" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***012" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Safety � Code 43 mechanical safety inspe |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to delay 6h passing Gate 8 threshold but Code 43 being Safety at  |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Marie-Claire Dubois + TC053 + YUL?YYZ + FD" |  |
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
| CP127 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to Safety Code 81 |  |
| CP128 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP131 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP133 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-29. | DDS returns FD-APPR-NE-29. |
| CP134 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 10:00; Actual = 16:00; Delay = 6hrs; MSL = Leg 1 (AC 366); Code 81 (Safety Regulation); Safety; Fallback = FALSE; APP | Trip Tracer: Promise = 10:00; Actual = 16:00; Delay = 6hrs; MSL = Leg 1 (AC 366); Code 81 (Safety Regulation); Safety; Fallback = FALSE; APPR. |
| CP135 | EXPECTED RESULTS | verdict | api | CRITICAL: 6hr delay meets Tier 2 (?6hrs, would be $700) BUT Code 81 = Safety ? $0. | CRITICAL: 6hr delay meets Tier 2 (?6hrs, would be $700) BUT Code 81 = Safety ? $0. |
| CP136 | EXPECTED RESULTS | verdict | chat | Safety is an absolute override like Uncontrollable but in its own APPR category. | Safety is an absolute override like Uncontrollable but in its own APPR category. |
| CP137 | EXPECTED RESULTS | verdict | chat | Compensation: $0 � Safety. | Compensation: $0 � Safety. |
| CP138 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP139 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP140 | EXPECTED RESULTS | verdict | api | Regime Assessment: APPR = NE-29 (Delay + Safety); EU = N/A; ASL = N/A. | Regime Assessment: APPR = NE-29 (Delay + Safety); EU = N/A; ASL = N/A. |
| CP141 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Code 81 (Safety Regulation); Delay = 6hrs (would be Tier 2 if controllable); $0; DDS = FD-APPR-NE-29. | Claims Dashboard: Code 81 (Safety Regulation); Delay = 6hrs (would be Tier 2 if controllable); $0; DDS = FD-APPR-NE-29. |
