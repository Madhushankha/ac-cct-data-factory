# FD_TC_074 · CHAI-31466 — checkpoints

**Goal:** Two-leg journey. Leg 1 operated on time. Leg 2 was delayed more than 3 hours. There's no cancellation code and no arrival delay code, so the rules engine falls back to the first departure delay code, 97. In this scenario, airside operations staff employed by the YYZ airport authority went on strike (uncontrollable). The customer was stranded at the connection (YYZ), chose not to continue, and didn't return to YUL. Checks that the fallback path is used, that No Travel Incomplete plus an uncontrollable fallback code returns Not Eligible under APPR, and that the customer is entitled to a pro-rated or full refund of the unused portion.

Methods: seed 15, chat 37, api 32, email 3, dashboard 40, implied 18, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Two-leg journey. Leg 1 operated on time. Leg 2 was delayed more than 3 hours. There's no cancellation code and no arrival delay code, so the |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR TC063: one adult passenger, two AC domestic legs YUL?YYZ?YVR, May 29, 2026 | PNR TC063: one adult passenger, two AC domestic legs YUL?YYZ?YVR, May 29, 2026 |
| CP003 | PREREQUISITES | prerequisite | seed | Leg 1 AC 466 YUL?YYZ: operated, on time, no delay codes | Leg 1 AC 466 YUL?YYZ: operated, on time, no delay codes |
| CP004 | PREREQUISITES | prerequisite | seed | Leg 2 AC 467 YYZ?YVR: scheduled 11:00 ? 13:05 (local) | Leg 2 AC 467 YYZ?YVR: scheduled 11:00 ? 13:05 (local) |
| CP005 | PREREQUISITES | prerequisite | seed | Actual departure 14:40 (220 min late) | Actual departure 14:40 (220 min late) |
| CP006 | PREREQUISITES | prerequisite | seed | Actual arrival 16:50 (225 min late) | Actual arrival 16:50 (225 min late) |
| CP007 | PREREQUISITES | prerequisite | seed | Status: DELAYED (operated) | Status: DELAYED (operated) |
| CP008 | PREREQUISITES | prerequisite | seed | Cancellation code: NONE | Cancellation code: NONE |
| CP009 | PREREQUISITES | prerequisite | seed | Arrival delay code: NOT AVAILABLE (null/empty) | Arrival delay code: NOT AVAILABLE (null/empty) |
| CP010 | PREREQUISITES | prerequisite | seed | First departure delay code 97 (MI) | First departure delay code 97 (MI) |
| CP011 | PREREQUISITES | prerequisite | seed | Customer action: stranded at YYZ (midpoint) | Customer action: stranded at YYZ (midpoint) |
| CP012 | PREREQUISITES | prerequisite | seed | Didn't board Leg 2, so the Leg 2 coupon wasn't flown | Didn't board Leg 2, so the Leg 2 coupon wasn't flown |
| CP013 | PREREQUISITES | prerequisite | seed | Didn't return to YUL | Didn't return to YUL |
| CP014 | PREREQUISITES | prerequisite | seed | Didn't reach YVR | Didn't reach YVR |
| CP015 | PREREQUISITES | prerequisite | seed | No Travel status: Incomplete | No Travel status: Incomplete |
| CP016 | PREREQUISITES | prerequisite | seed | No rebooking accepted | No rebooking accepted |
| CP017 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP018 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP019 | START | customer | chat | Then user selects English |  |
| CP020 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP021 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP022 | START | customer | chat | And the user says "I flew from Montreal to Toronto but my connecting flight from Toronto to Vancouver was delayed by more than 3 hours becau | I flew from Montreal to Toronto but my connecting flight from Toronto to Vancouver was delayed by more than 3 hours because of a strike by airport workers in To |
| CP023 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP024 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP025 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP026 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable." | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Marc-Andr� Lavoie" | Marc-Andr� Lavoie |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, Marc-Andr�! And, what is your booking reference number?" | Thanks, Marc-Andr�! And, what is your booking reference number? |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC063" | PNR: TC063 |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC063 |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: Email: m***@gmail.com / Phone: +1***345 |  |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: m***@gmail.com" | Email: m***@gmail.com |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP042 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP043 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP044 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP045 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP046 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays: "I found 1 passenger on this booking: Marc-Andr� Lavoie (Adult). Is this who you'd like to include?" | I found 1 passenger on this booking: Marc-Andr� Lavoie (Adult). Is this who you'd like to include? |
| CP047 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP049 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Segment 1: Flight AC 466, Montreal (YUL) ? Toronto (YYZ), May 29, 2026 � COMPLETED Segment 2: Flight AC 467, Toronto (YYZ) ? Vanc |
| CP050 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP051 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP052 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 DELAYED |  |
| CP053 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot determines: Claim applies to Segment 2 (AC 467 YYZ?YVR � DELAYED) |  |
| CP054 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP055 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP056 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure of the delayed segment |  |
| CP057 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure May 29, 2026; current date June 15, 2026 ? >72 hours ? PROCEED |  |
| CP058 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP059 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 29, 2026; filing June 15, 2026 ? 17 days ? within 366 days ? PROCEED |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the cancellation code on MSL ? NONE |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the first arrival delay code on MSL ? NOT AVAILABLE |  |
| CP063 | TRIAGE & DDS EVALUATION | verdict | api | And DDS falls back to the first departure delay code on MSL ? 97 (MI) |  |
| CP064 | TRIAGE & DDS EVALUATION | verdict | api | And DDS evaluates and sends results to Trip Tracer UI |  |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Segment 1: Flight: AC 466, Route: YUL ? YYZ, Status: COMPLETED (on time, no delay codes) | Segment 1: Flight: AC 466, Route: YUL ? YYZ, Status: COMPLETED (on time, no delay codes) |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Segment 2: Flight: AC 467, Route: YYZ ? YVR, Scheduled: 11:00 ? 13:05, Actual: 14:40 ? 16:50, Status: DELAYED (operated) (claim filed) | Segment 2: Flight: AC 467, Route: YYZ ? YVR, Scheduled: 11:00 ? 13:05, Actual: 14:40 ? 16:50, Status: DELAYED (operated) (claim filed) |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Segment 2 departure delay = 220 min (?180) ; arrival delay = 225 min (?180) | Segment 2 departure delay = 220 min (?180) ; arrival delay = 225 min (?180) |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Customer Status: NO TRAVEL - INCOMPLETE (started journey, stranded at connection YYZ, Leg 2 coupon not flown) | Customer Status: NO TRAVEL - INCOMPLETE (started journey, stranded at connection YYZ, Leg 2 coupon not flown) |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | History - No rebooking accepted for connecting segment | History - No rebooking accepted for connecting segment |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 467 � YYZ ? YVR (Leg 2) | MSL FLIGHT: AC 467 � YYZ ? YVR (Leg 2) |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | Cancellation code: NONE | Cancellation code: NONE |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | First arrival delay code: NOT AVAILABLE (null/empty) | First arrival delay code: NOT AVAILABLE (null/empty) |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | First departure delay code: 97 (MI) � "Industrial action outside own airline" | First departure delay code: 97 (MI) � "Industrial action outside own airline" |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | Controllability source = first departure delay code (fallback) | Controllability source = first departure delay code (fallback) |
| CP076 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: TRUE (arrival delay code not available) | Fallback: TRUE (arrival delay code not available) |
| CP077 | TRIP TRACER UI VALIDATION | verdict | api | APPR causal category: Outside carrier control � Others ? UNCONTROLLABLE | APPR causal category: Outside carrier control � Others ? UNCONTROLLABLE |
| CP078 | TRIP TRACER UI VALIDATION | verdict | api | Disruption Type: DELAY (mid-journey) | Disruption Type: DELAY (mid-journey) |
| CP079 | TRIP TRACER UI VALIDATION | verdict | api | No Travel Branch B (Did not remain at origin � intermediate travel) + MSL delayed 3+ hours ? controllability check ? Outside carrier's contr | No Travel Branch B (Did not remain at origin � intermediate travel) + MSL delayed 3+ hours ? controllability check ? Outside carrier's control |
| CP080 | TRIP TRACER UI VALIDATION | verdict | api | DDS outcome code: FD-APPR-NE-13 | DDS outcome code: FD-APPR-NE-13 |
| CP081 | TRIP TRACER UI VALIDATION | verdict | api | Compensation outcome: NOT ELIGIBLE | Compensation outcome: NOT ELIGIBLE |
| CP082 | TRIP TRACER UI VALIDATION | verdict | api | Ticket refund entitlement: PRO-RATED / FULL refund of unused portion (Branch B � outside control) | Ticket refund entitlement: PRO-RATED / FULL refund of unused portion (Branch B � outside control) |
| CP083 | TRIP TRACER UI VALIDATION | verdict | api | Expenses: NOT applicable | Expenses: NOT applicable |
| CP084 | TRIP TRACER UI VALIDATION | verdict | api | MR MARC-ANDR� LAVOIE / NOT ELIGIBLE / UNCONTROLLABLE / CAD 0.00 | MR MARC-ANDR� LAVOIE / NOT ELIGIBLE / UNCONTROLLABLE / CAD 0.00 |
| CP085 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP086 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP087 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your connecting flight AC 467 from Toronto (YYZ) to Vancouver (YVR) on May 29, 2026 was delayed by more t |
| CP088 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP089 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP090 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP091 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP092 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to m***@gmail.com |  |
| CP093 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (uncontrollable � industrial action outside own airline, departu |  |
| CP094 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No] | Is there anything I can help you with? |
| CP095 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP096 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Marc-Andr� Lavoie" with PNR "TC063" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Marc-Andr� Lavoie" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC063" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Marc-Andr� Lavoie" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "m***@gmail.com" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***345" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address, Profile ID and Tier Status should be populated |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: YUL ? YYZ" as completed and "Segment 2: YYZ ? YVR" with claim filed for this flight |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present with no expected ancillary fees |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should show "NOT ELIGIBLE" with reason "Uncontrollable � industrial action outside own airline  |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the travel status should show "No Travel � Incomplete" with stranded location "YYZ" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS outcome should be "FD-APPR-NE-13" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to uncontrollable departure delay Code 97 (MI � industrial action |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Marc-Andr� Lavoie + TC063 + YYZ?YVR + FD" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP146 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to uncontrollable industrial action outside own airline (fallback departure delay code 97 |  |
| CP147 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP148 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP149 | PAYMENT VALIDATION | payment | chat | And no Interac email should have been collected |  |
| CP150 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP151 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP152 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP153 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-13. | DDS returns FD-APPR-NE-13. |
| CP154 | EXPECTED RESULTS | verdict | api | Trip Tracer: Leg 1 = Operated (on time); Leg 2 = DELAYED (departure 220 min late, arrival 225 min late); MSL = Leg 2; no cancellation code;  | Trip Tracer: Leg 1 = Operated (on time); Leg 2 = DELAYED (departure 220 min late, arrival 225 min late); MSL = Leg 2; no cancellation code; arrival delay code = |
| CP155 | EXPECTED RESULTS | verdict | chat | Compensation: CAD 0.00. | Compensation: CAD 0.00. |
| CP156 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Not Eligible; Uncontrollable (Departure Code 97, fallback); No Travel = Incomplete; Stranded location = YYZ; DDS = FD-APPR | Claims Dashboard: Not Eligible; Uncontrollable (Departure Code 97, fallback); No Travel = Incomplete; Stranded location = YYZ; DDS = FD-APPR-NE-13. |
