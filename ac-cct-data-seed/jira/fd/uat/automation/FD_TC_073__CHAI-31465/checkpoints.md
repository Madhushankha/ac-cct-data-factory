# FD_TC_073 · CHAI-31465 — checkpoints

**Goal:** Two-leg journey. Leg 1 operated on time. Leg 2 was delayed more than 3 hours. There's no cancellation code and no arrival delay code, so the rules engine falls back to the first departure delay code, 93. In this scenario, the aircraft for AC 467 arrived late at YYZ on its previous flight, AC 603 from YHZ (uncontrollable). The customer was stranded at the connection (YYZ), chose not to continue, and didn't return to YUL. Checks that the fallback path is used, that No Travel Incomplete plus an uncontrollable fallback code returns Not Eligible under APPR, and that the customer is entitled to a pro-rated or full refund of the unused portion.

Methods: seed 17, chat 37, api 33, email 3, dashboard 40, implied 18, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Two-leg journey. Leg 1 operated on time. Leg 2 was delayed more than 3 hours. There's no cancellation code and no arrival delay code, so the |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR TC062: one adult passenger, two AC domestic legs YUL?YYZ?YVR, May 29, 2026 | PNR TC062: one adult passenger, two AC domestic legs YUL?YYZ?YVR, May 29, 2026 |
| CP003 | PREREQUISITES | prerequisite | seed | Leg 1 AC 466 YUL?YYZ: operated, on time, no delay codes | Leg 1 AC 466 YUL?YYZ: operated, on time, no delay codes |
| CP004 | PREREQUISITES | prerequisite | seed | Leg 2 AC 467 YYZ?YVR: scheduled 11:00 ? 13:05 (local) | Leg 2 AC 467 YYZ?YVR: scheduled 11:00 ? 13:05 (local) |
| CP005 | PREREQUISITES | prerequisite | seed | Actual departure 14:40 (220 min late) | Actual departure 14:40 (220 min late) |
| CP006 | PREREQUISITES | prerequisite | seed | Actual arrival 16:50 (225 min late) | Actual arrival 16:50 (225 min late) |
| CP007 | PREREQUISITES | prerequisite | seed | Status: DELAYED (operated) | Status: DELAYED (operated) |
| CP008 | PREREQUISITES | prerequisite | seed | Inbound aircraft rotation: AC 603 YHZ?YYZ arrived late | Inbound aircraft rotation: AC 603 YHZ?YYZ arrived late |
| CP009 | PREREQUISITES | prerequisite | seed | AC 603 isn't on the customer's PNR | AC 603 isn't on the customer's PNR |
| CP010 | PREREQUISITES | prerequisite | seed | Cancellation code: NONE | Cancellation code: NONE |
| CP011 | PREREQUISITES | prerequisite | seed | Arrival delay code: NOT AVAILABLE (null/empty) | Arrival delay code: NOT AVAILABLE (null/empty) |
| CP012 | PREREQUISITES | prerequisite | seed | First departure delay code 93 (RA) | First departure delay code 93 (RA) |
| CP013 | PREREQUISITES | prerequisite | seed | Customer action: stranded at YYZ (midpoint) | Customer action: stranded at YYZ (midpoint) |
| CP014 | PREREQUISITES | prerequisite | seed | Didn't board Leg 2, so the Leg 2 coupon wasn't flown | Didn't board Leg 2, so the Leg 2 coupon wasn't flown |
| CP015 | PREREQUISITES | prerequisite | seed | Didn't return to YUL | Didn't return to YUL |
| CP016 | PREREQUISITES | prerequisite | seed | Didn't reach YVR | Didn't reach YVR |
| CP017 | PREREQUISITES | prerequisite | seed | No Travel status: Incomplete | No Travel status: Incomplete |
| CP018 | PREREQUISITES | prerequisite | seed | No rebooking accepted | No rebooking accepted |
| CP019 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP020 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP021 | START | customer | chat | Then user selects English |  |
| CP022 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP023 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP024 | START | customer | chat | And the user says "I flew from Montreal to Toronto but my connecting flight from Toronto to Vancouver was delayed by more than 3 hours becau | I flew from Montreal to Toronto but my connecting flight from Toronto to Vancouver was delayed by more than 3 hours because the plane arrived late from its prev |
| CP025 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP026 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP027 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP028 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable." | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Marc-Andr� Lavoie" | Marc-Andr� Lavoie |
| CP032 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, Marc-Andr�! And, what is your booking reference number?" | Thanks, Marc-Andr�! And, what is your booking reference number? |
| CP033 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC062" | PNR: TC062 |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC062 |  |
| CP035 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP036 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: Email: m***@gmail.com / Phone: +1***345 |  |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: m***@gmail.com" | Email: m***@gmail.com |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP041 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP042 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP043 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP044 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP045 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP046 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP047 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP048 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays: "I found 1 passenger on this booking: Marc-Andr� Lavoie (Adult). Is this who you'd like to include?" | I found 1 passenger on this booking: Marc-Andr� Lavoie (Adult). Is this who you'd like to include? |
| CP049 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP050 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP051 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Segment 1: Flight AC 466, Montreal (YUL) ? Toronto (YYZ), May 29, 2026 � COMPLETED Segment 2: Flight AC 467, Toronto (YYZ) ? Vanc |
| CP052 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP053 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP054 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 DELAYED |  |
| CP055 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot determines: Claim applies to Segment 2 (AC 467 YYZ?YVR � DELAYED) |  |
| CP056 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP057 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP058 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure of the delayed segment |  |
| CP059 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure May 29, 2026; current date June 15, 2026 ? >72 hours ? PROCEED |  |
| CP060 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP061 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 29, 2026; filing June 15, 2026 ? 17 days ? within 366 days ? PROCEED |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP063 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the cancellation code on MSL ? NONE |  |
| CP064 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the first arrival delay code on MSL ? NOT AVAILABLE |  |
| CP065 | TRIAGE & DDS EVALUATION | verdict | api | And DDS falls back to the first departure delay code on MSL ? 93 (RA) |  |
| CP066 | TRIAGE & DDS EVALUATION | verdict | api | And DDS does NOT trace the upline root cause of the inbound flight AC 603 |  |
| CP067 | TRIAGE & DDS EVALUATION | verdict | api | And DDS evaluates and sends results to Trip Tracer UI |  |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Segment 1: Flight: AC 466, Route: YUL ? YYZ, Status: COMPLETED (on time, no delay codes) | Segment 1: Flight: AC 466, Route: YUL ? YYZ, Status: COMPLETED (on time, no delay codes) |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | Segment 2: Flight: AC 467, Route: YYZ ? YVR, Scheduled: 11:00 ? 13:05, Actual: 14:40 ? 16:50, Status: DELAYED (operated) (claim filed) | Segment 2: Flight: AC 467, Route: YYZ ? YVR, Scheduled: 11:00 ? 13:05, Actual: 14:40 ? 16:50, Status: DELAYED (operated) (claim filed) |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Segment 2 departure delay = 220 min (?180) ; arrival delay = 225 min (?180) | Segment 2 departure delay = 220 min (?180) ; arrival delay = 225 min (?180) |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | Customer Status: NO TRAVEL - INCOMPLETE (started journey, stranded at connection YYZ, Leg 2 coupon not flown) | Customer Status: NO TRAVEL - INCOMPLETE (started journey, stranded at connection YYZ, Leg 2 coupon not flown) |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | History - No rebooking accepted for connecting segment | History - No rebooking accepted for connecting segment |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 467 � YYZ ? YVR (Leg 2) | MSL FLIGHT: AC 467 � YYZ ? YVR (Leg 2) |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | Cancellation code: NONE | Cancellation code: NONE |
| CP076 | TRIP TRACER UI VALIDATION | verdict | api | First arrival delay code: NOT AVAILABLE (null/empty) | First arrival delay code: NOT AVAILABLE (null/empty) |
| CP077 | TRIP TRACER UI VALIDATION | verdict | api | First departure delay code: 93 (RA) � "Aircraft rotation, late arrival of aircraft from another flight or previous sector" | First departure delay code: 93 (RA) � "Aircraft rotation, late arrival of aircraft from another flight or previous sector" |
| CP078 | TRIP TRACER UI VALIDATION | verdict | api | Controllability source = first departure delay code (fallback) | Controllability source = first departure delay code (fallback) |
| CP079 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: TRUE (arrival delay code not available) | Fallback: TRUE (arrival delay code not available) |
| CP080 | TRIP TRACER UI VALIDATION | verdict | api | APPR causal category: Outside carrier control ? UNCONTROLLABLE | APPR causal category: Outside carrier control ? UNCONTROLLABLE |
| CP081 | TRIP TRACER UI VALIDATION | verdict | api | Disruption Type: DELAY (mid-journey) | Disruption Type: DELAY (mid-journey) |
| CP082 | TRIP TRACER UI VALIDATION | verdict | api | No Travel Branch B (Did not remain at origin � intermediate travel) + MSL delayed 3+ hours ? controllability check ? Outside carrier's contr | No Travel Branch B (Did not remain at origin � intermediate travel) + MSL delayed 3+ hours ? controllability check ? Outside carrier's control |
| CP083 | TRIP TRACER UI VALIDATION | verdict | api | DDS outcome code: FD-APPR-NE-13 | DDS outcome code: FD-APPR-NE-13 |
| CP084 | TRIP TRACER UI VALIDATION | verdict | api | Compensation outcome: NOT ELIGIBLE | Compensation outcome: NOT ELIGIBLE |
| CP085 | TRIP TRACER UI VALIDATION | verdict | api | Ticket refund entitlement: PRO-RATED / FULL refund of unused portion (Branch B � outside control) | Ticket refund entitlement: PRO-RATED / FULL refund of unused portion (Branch B � outside control) |
| CP086 | TRIP TRACER UI VALIDATION | verdict | api | Expenses: NOT applicable | Expenses: NOT applicable |
| CP087 | TRIP TRACER UI VALIDATION | verdict | api | MR MARC-ANDR� LAVOIE / NOT ELIGIBLE / UNCONTROLLABLE / CAD 0.00 | MR MARC-ANDR� LAVOIE / NOT ELIGIBLE / UNCONTROLLABLE / CAD 0.00 |
| CP088 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP089 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP090 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your connecting flight AC 467 from Toronto (YYZ) to Vancouver (YVR) on May 29, 2026 was delayed by more t |
| CP091 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP092 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP093 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP094 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP095 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to m***@gmail.com |  |
| CP096 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (uncontrollable � aircraft rotation, late arrival of aircraft fr |  |
| CP097 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No] | Is there anything I can help you with? |
| CP098 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP099 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Marc-Andr� Lavoie" with PNR "TC062" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Marc-Andr� Lavoie" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC062" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Marc-Andr� Lavoie" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "m***@gmail.com" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***345" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address, Profile ID and Tier Status should be populated |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: YUL ? YYZ" as completed and "Segment 2: YYZ ? YVR" with claim filed for this flight |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present with no expected ancillary fees |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should show "NOT ELIGIBLE" with reason "Uncontrollable � aircraft rotation, late arrival of air |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the travel status should show "No Travel � Incomplete" with stranded location "YYZ" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS outcome should be "FD-APPR-NE-13" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to uncontrollable departure delay Code 93 (RA � aircraft rotation |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Marc-Andr� Lavoie + TC062 + YYZ?YVR + FD" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP149 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to uncontrollable aircraft rotation, late arrival of aircraft from another flight (fallba |  |
| CP150 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP151 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP152 | PAYMENT VALIDATION | payment | chat | And no Interac email should have been collected |  |
| CP153 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP154 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP155 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP156 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-13. | DDS returns FD-APPR-NE-13. |
| CP157 | EXPECTED RESULTS | verdict | api | Trip Tracer: Leg 1 = Operated (on time); Leg 2 = DELAYED (departure 220 min late, arrival 225 min late); MSL = Leg 2; no cancellation code;  | Trip Tracer: Leg 1 = Operated (on time); Leg 2 = DELAYED (departure 220 min late, arrival 225 min late); MSL = Leg 2; no cancellation code; arrival delay code = |
| CP158 | EXPECTED RESULTS | verdict | chat | Compensation: CAD 0.00. | Compensation: CAD 0.00. |
| CP159 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Not Eligible; Uncontrollable (Departure Code 93, fallback); No Travel = Incomplete; Stranded location = YYZ; DDS = FD-APPR | Claims Dashboard: Not Eligible; Uncontrollable (Departure Code 93, fallback); No Travel = Incomplete; Stranded location = YYZ; DDS = FD-APPR-NE-13. |
