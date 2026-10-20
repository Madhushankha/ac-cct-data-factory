# FD_TC_177 · CHAI-31569 — checkpoints

**Goal:** Dual-regime route (LHR?YYZ, EU + APPR) where the disruption cause is extraordinary/uncontrollable under BOTH regimes (Code 72 � Weather). Both regimes return Not Eligible. Validates that the system handles a scenario where multiple regimes are assessed but NONE produce an eligible outcome � final result is definitively Not Eligible with $0 compensation.

Methods: seed 5, chat 46, api 20, email 3, dashboard 39, implied 19, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Dual-regime route (LHR?YYZ, EU + APPR) where the disruption cause is extraordinary/uncontrollable under BOTH regimes (Code 72 � Weather). Bo |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Roger Whitehall), 1 leg AC operated LHR?YYZ | PNR: Single passenger (Roger Whitehall), 1 leg AC operated LHR?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: Scheduled arrival 16:00, Actual arrival 20:00 (4hr delay) | Itinerary: Scheduled arrival 16:00, Actual arrival 20:00 (4hr delay) |
| CP004 | PREREQUISITES | prerequisite | seed | Disruption code: 72 (Weather � extraordinary under EU 261, uncontrollable under APPR) | Disruption code: 72 (Weather � extraordinary under EU 261, uncontrollable under APPR) |
| CP005 | PREREQUISITES | prerequisite | seed | Flight distance: LHR?YYZ = ~5,550km (>3500km) | Flight distance: LHR?YYZ = ~5,550km (>3500km) |
| CP006 | PREREQUISITES | prerequisite | seed | Flight status: Arrived (operated) | Flight status: Arrived (operated) |
| CP007 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP008 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP009 | START | customer | chat | Then user selects English |  |
| CP010 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP011 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP012 | START | customer | chat | And the user says "My flight from London to Toronto was delayed 4 hours due to severe weather. I'd like to check if I'm eligible for compens | My flight from London to Toronto was delayed 4 hours due to severe weather. I'd like to check if I'm eligible for compensation |
| CP013 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP014 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP015 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP016 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP017 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP018 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP019 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Roger Whitehall" | Roger Whitehall |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Roger! And, what is your booking reference number? |
| CP021 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC151" | PNR: TC151 |
| CP022 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC151 |  |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP025 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: r***@gmail.com � Phone: +44***789 |
| CP027 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: r***@gmail.com" | Email: r***@gmail.com |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP029 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP030 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP032 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP033 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP034 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP035 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP036 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Roger Whitehall (Adult) Is this who you'd like to include? |
| CP037 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP038 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP039 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 855 � Route: London Heathrow (LHR) ? Toronto (YYZ) � Date: June 5, 2026 � Arrival Delay: 4 hours Is this the journey |
| CP040 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP041 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP042 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP044 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP045 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (UK = 6 years) and APPR ? within limitation ? PROCEED |  |
| CP046 | REGIME DETERMINATION � DUAL REGIME | system | implied | Then the system determines applicable regimes: |  |
| CP047 | REGIME DETERMINATION � DUAL REGIME | system | implied | And the system checks: Origin airport = LHR (London, UK) ? EU 261 applies |  |
| CP048 | REGIME DETERMINATION � DUAL REGIME | system | implied | And the system checks: Destination airport = YYZ (Toronto, Canada) ? APPR applies |  |
| CP049 | REGIME DETERMINATION � DUAL REGIME | verdict | api | And the system determines: DUAL REGIME � EU 261 + APPR |  |
| CP050 | TRIAGE & DDS EVALUATION � BOTH NOT ELIGIBLE | verdict | api | Then the DDS evaluation is done in backend |  |
| CP051 | TRIAGE & DDS EVALUATION � BOTH NOT ELIGIBLE | verdict | api | And DDS assesses BOTH regimes independently: |  |
| CP052 | EU 261 ASSESSMENT | system | implied | ? Origin: LHR (UK) ? EU 261 applies | ? Distance: LHR?YYZ = ~5,550 km ? Long-haul (>3500km) ? Delay: 4 hours ? ?4h threshold ? Code: 72 (Weather) ? EU 261 Controllability: EXTRAORDINARY CIRCUMSTANCE |
| CP053 | APPR ASSESSMENT | system | implied | ? Destination: YYZ (Canada) ? APPR applies | ? Delay: 4 hours ? 3�6h tier ? Code: 72 (Weather) ? APPR Controllability: UNCONTROLLABLE (weather is uncontrollable under APPR) ? APPR Result: NOT ELIGIBLE (unc |
| CP054 | DUAL REGIME � BOTH NOT ELIGIBLE | system | implied | ? EU 261: NOT ELIGIBLE (extraordinary circumstances) | ? APPR: NOT ELIGIBLE (uncontrollable) ? Any regime eligible? ? NO ? Final Result: DEFINITIVELY NOT ELIGIBLE � $0 COMPENSATION |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 855, Route: LHR ? YYZ, Scheduled Arrival: 16:00 | Promised Itinerary - Flight: AC 855, Route: LHR ? YYZ, Scheduled Arrival: 16:00 |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 855, Route: LHR ? YYZ, Status: ARRIVED LATE, Actual: 20:00, Delay: +4H 00M | Current Itinerary - Flight: AC 855, Route: LHR ? YYZ, Status: ARRIVED LATE, Actual: 20:00, Delay: +4H 00M |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Dual Regime: EU 261 + APPR | Dual Regime: EU 261 + APPR |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | EU 261: NOT ELIGIBLE � Extraordinary Circumstances (Code 72 � Weather) | EU 261: NOT ELIGIBLE � Extraordinary Circumstances (Code 72 � Weather) |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | APPR: NOT ELIGIBLE � Uncontrollable (Code 72 � Weather) | APPR: NOT ELIGIBLE � Uncontrollable (Code 72 � Weather) |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Both Regimes: NOT ELIGIBLE | Both Regimes: NOT ELIGIBLE |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Final Result: NOT ELIGIBLE � $0 | Final Result: NOT ELIGIBLE � $0 |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 855 � LHR ? YYZ � 72 | MSL FLIGHT: AC 855 � LHR ? YYZ � 72 |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | EXTRAORDINARY / UNCONTROLLABLE (Code 72) | EXTRAORDINARY / UNCONTROLLABLE (Code 72) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | MR ROGER WHITEHALL / NOT ELIGIBLE / BOTH_REGIMES_NOT_ELIGIBLE / $0 | MR ROGER WHITEHALL / NOT ELIGIBLE / BOTH_REGIMES_NOT_ELIGIBLE / $0 |
| CP065 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP066 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your flight AC 855 from London Heathrow (LHR) to Toronto (YYZ) on June 5, 2026 was delayed by 4 hours. Ho |
| CP067 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP068 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP069 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP070 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP071 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to r***@gmail.com |  |
| CP072 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (extraordinary circumstances / uncontrollable � weather, both re |  |
| CP073 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP074 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP075 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Roger Whitehall" with PNR "TC151" |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Roger Whitehall" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC151" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 + APPR (Dual Regime � BOTH Not Eligible)" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Roger Whitehall" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: LHR ? YYZ" with claim filed for this flight |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Assessment 1 should show EU 261 with disruption code 72 Weather and classification under EU rules as Extraordinary circumstances and eli |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Assessment 2 should show APPR with disruption code 72 Weather and classification under APPR rules as Uncontrollable and eligibility NOT  |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And BOTH regimes should be assessed and BOTH should return Not Eligible |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should NOT keep searching for an eligible regime as when all applicable regimes are NE the final answer is definitively NE |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Compensation should be $0 with no regime providing eligibility |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And BOTH regimes should be assessed and logged as BOTH Not Eligible |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the final determination should be Not Eligible definitively with no eligible regime |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Roger Whitehall + TC151 + LHR?YYZ + FD" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for ELIGIBLE cases and both regimes are NE |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe containing Case Reference and flight details and not eligible reason e |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record dual-regime assessment with EU 261 NE extraordinary and APPR NE uncontrollable |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP124 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" with both regimes returning Not Eligible |  |
| CP125 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP126 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And no payment method should have been determined |  |
| CP128 | PAYMENT VALIDATION | payment | chat | And no bank details should have been collected |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And no IDV should have been required |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP131 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And CyberSource should NOT have been triggered as it only runs for ELIGIBLE cases and both regimes are NE |  |
| CP133 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" for both regimes with no compensation record and no payout section |  |
| CP134 | PAYMENT VALIDATION | payment | chat | And both regimes should be assessed independently with EU 261 Not Eligible due to extraordinary circumstances weather Code 72 and APPR Not E |  |
| CP135 | PAYMENT VALIDATION | payment | chat | And the system should NOT keep searching for an eligible regime as when all applicable regimes are NE the final answer is definitively NE |  |
| CP136 | PAYMENT VALIDATION | payment | chat | And the Total Compensation should be $0 |  |
| CP137 | EXPECTED RESULTS | verdict | api | DDS returns FD-MIXED-NE-02. | DDS returns FD-MIXED-NE-02. |
| CP138 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 16:00; Actual = 20:00; Delay = 4hrs; MSL = Leg 1; Code 72; EU = Extraordinary; APPR = Uncontrollable; Regime = EU 261 | Trip Tracer: Promise = 16:00; Actual = 20:00; Delay = 4hrs; MSL = Leg 1; Code 72; EU = Extraordinary; APPR = Uncontrollable; Regime = EU 261 + APPR. |
| CP139 | EXPECTED RESULTS | verdict | chat | Dual Assessment: EU 261 = NOT ELIGIBLE (extraordinary � weather); APPR = NOT ELIGIBLE (uncontrollable � weather). | Dual Assessment: EU 261 = NOT ELIGIBLE (extraordinary � weather); APPR = NOT ELIGIBLE (uncontrollable � weather). |
| CP140 | EXPECTED RESULTS | verdict | chat | CRITICAL: Both regimes assessed, both return NE. | CRITICAL: Both regimes assessed, both return NE. |
| CP141 | EXPECTED RESULTS | verdict | chat | System must NOT keep searching for an eligible regime � when all applicable regimes are NE, the final answer is definitively NE. | System must NOT keep searching for an eligible regime � when all applicable regimes are NE, the final answer is definitively NE. |
| CP142 | EXPECTED RESULTS | verdict | chat | Compensation: $0 � no regime provides eligibility. | Compensation: $0 � no regime provides eligibility. |
| CP143 | EXPECTED RESULTS | verdict | api | Claims Dashboard: EU 261 = Not Eligible (extraordinary); APPR = Not Eligible (uncontrollable); Both assessed, both NE; Final = Not Eligible; | Claims Dashboard: EU 261 = Not Eligible (extraordinary); APPR = Not Eligible (uncontrollable); Both assessed, both NE; Final = Not Eligible; DDS = FD-MIXED-NE-0 |
