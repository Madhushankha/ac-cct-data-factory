# FD_TC_084 · CHAI-31476 — checkpoints

**Goal:** Two-leg journey. Leg 1 operated on time. Leg 2 was delayed 7h 25m (inside the 6 to 9 hour band) by arrival delay code 47. The aircraft scheduled for AC 477 had a technical fault at YYZ and no planned standby aircraft was available, so the flight waited until the aircraft was repaired and cleared to depart safely (Safety). The customer was stranded at YYZ. They didn't continue, didn't return to YUL and didn't reach YVR. Checks four things: (1) the MSL is Leg 2, (2) code 47 on the connecting leg is classed as Safety, (3) No Travel Incomplete is detected, and (4) neither the 6 to 9 hour delay nor the Aeroplan Basic tier changes the NE-18 result.

Methods: seed 21, chat 50, api 40, email 3, dashboard 44, implied 18, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Two-leg journey. Leg 1 operated on time. Leg 2 was delayed 7h 25m (inside the 6 to 9 hour band) by arrival delay code 47. The aircraft sched |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR TC071: one adult passenger, Jacques Fortier | PNR TC071: one adult passenger, Jacques Fortier |
| CP003 | PREREQUISITES | prerequisite | seed | Two AC domestic legs, YUL?YYZ?YVR, June 1, 2026 | Two AC domestic legs, YUL?YYZ?YVR, June 1, 2026 |
| CP004 | PREREQUISITES | prerequisite | seed | Leg 1 AC 476 YUL?YYZ: operated on time, no delay codes | Leg 1 AC 476 YUL?YYZ: operated on time, no delay codes |
| CP005 | PREREQUISITES | prerequisite | seed | Leg 2 AC 477 YYZ?YVR: scheduled 12:00 ? 14:05 (local) | Leg 2 AC 477 YYZ?YVR: scheduled 12:00 ? 14:05 (local) |
| CP006 | PREREQUISITES | prerequisite | seed | Actual departure 19:25 (445 min late) | Actual departure 19:25 (445 min late) |
| CP007 | PREREQUISITES | prerequisite | seed | Actual arrival 21:30 (445 min late) | Actual arrival 21:30 (445 min late) |
| CP008 | PREREQUISITES | prerequisite | seed | Status: DELAYED (operated) | Status: DELAYED (operated) |
| CP009 | PREREQUISITES | prerequisite | seed | Same aircraft operated after repair (no aircraft swap) | Same aircraft operated after repair (no aircraft swap) |
| CP010 | PREREQUISITES | prerequisite | seed | Cancellation code: NONE | Cancellation code: NONE |
| CP011 | PREREQUISITES | prerequisite | seed | First arrival delay code 47 (TL) | First arrival delay code 47 (TL) |
| CP012 | PREREQUISITES | prerequisite | seed | First departure delay code 47 (TL) | First departure delay code 47 (TL) |
| CP013 | PREREQUISITES | prerequisite | seed | No other delay codes on the MSL | No other delay codes on the MSL |
| CP014 | PREREQUISITES | prerequisite | seed | Customer stranded at YYZ, didn't board Leg 2, Leg 2 coupon not flown | Customer stranded at YYZ, didn't board Leg 2, Leg 2 coupon not flown |
| CP015 | PREREQUISITES | prerequisite | seed | No Travel status: Incomplete | No Travel status: Incomplete |
| CP016 | PREREQUISITES | prerequisite | seed | No rebooking accepted | No rebooking accepted |
| CP017 | PREREQUISITES | prerequisite | seed | Aeroplan: linked, tier code A (Aeroplan Basic) | Aeroplan: linked, tier code A (Aeroplan Basic) |
| CP018 | PREREQUISITES | prerequisite | seed | No expense receipts | No expense receipts |
| CP019 | PREREQUISITES | prerequisite | seed | Fallback: FALSE | Fallback: FALSE |
| CP020 | PREREQUISITES | prerequisite | seed | Regime: APPR | Regime: APPR |
| CP021 | PREREQUISITES | prerequisite | seed | More than 72 hours have passed | More than 72 hours have passed |
| CP022 | PREREQUISITES | prerequisite | seed | Filed within 366 days | Filed within 366 days |
| CP023 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP024 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP025 | START | customer | chat | Then user selects English |  |
| CP026 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP027 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP028 | START | customer | chat | And the user says "I flew from Montreal to Toronto but my connecting flight from Toronto to Vancouver was delayed by more than 7 hours becau | I flew from Montreal to Toronto but my connecting flight from Toronto to Vancouver was delayed by more than 7 hours because the plane had a technical problem an |
| CP029 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP030 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP031 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP032 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP033 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP034 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable." | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP035 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Jacques Fortier" | Jacques Fortier |
| CP036 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, Jacques! And, what is your booking reference number?" | Thanks, Jacques! And, what is your booking reference number? |
| CP037 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC071" | PNR: TC071 |
| CP038 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC071 |  |
| CP039 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP040 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details, linked Aeroplan profile) is revealed to the customer |  |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP042 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: Email: j***@gmail.com / Phone: +1***901 |  |
| CP043 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: j***@gmail.com" | Email: j***@gmail.com |
| CP044 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP045 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP046 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP047 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP048 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP049 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP050 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP051 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP052 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays: "I found 1 passenger on this booking: Jacques Fortier (Adult). Is this who you'd like to include?" | I found 1 passenger on this booking: Jacques Fortier (Adult). Is this who you'd like to include? |
| CP053 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP054 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP055 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Segment 1: Flight AC 476, Montreal (YUL) ? Toronto (YYZ), June 1, 2026 � COMPLETED Segment 2: Flight AC 477, Toronto (YYZ) ? Vanc |
| CP056 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP057 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP058 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 DELAYED |  |
| CP059 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot determines: Claim applies to Segment 2 (AC 477 YYZ?YVR � DELAYED) |  |
| CP060 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP061 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP062 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure of the delayed segment |  |
| CP063 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure June 1, 2026; current date June 15, 2026 ? >72 hours ? PROCEED |  |
| CP064 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP065 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption June 1, 2026; filing June 15, 2026 ? 14 days ? within 366 days ? PROCEED |  |
| CP066 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP067 | TRIAGE & DDS EVALUATION | verdict | api | And DDS identifies MSL = Leg 2 (AC 477 YYZ?YVR) |  |
| CP068 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the cancellation code on MSL ? NONE |  |
| CP069 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the first arrival delay code on MSL ? 47 (TL) |  |
| CP070 | TRIAGE & DDS EVALUATION | verdict | api | And DDS uses the arrival delay code for controllability (no fallback needed) |  |
| CP071 | TRIAGE & DDS EVALUATION | verdict | api | And DDS finds a single delay code on MSL ? Multiple Root Cause Analysis NOT required |  |
| CP072 | TRIAGE & DDS EVALUATION | verdict | api | And DDS calculates arrival delay = 445 min ? delay band 6�9 hours |  |
| CP073 | TRIAGE & DDS EVALUATION | verdict | api | And DDS classifies 47 (TL) as SAFETY under APPR (within carrier's control but required for safety) |  |
| CP074 | TRIAGE & DDS EVALUATION | verdict | api | And DDS does NOT apply the 6�9 hour compensation tier because Safety is not compensable |  |
| CP075 | TRIAGE & DDS EVALUATION | verdict | api | And DDS reads Aeroplan tier code A (Aeroplan Basic) ? tier-based expense rule NOT applied (rule applies to uncontrollable disruptions only) |  |
| CP076 | TRIAGE & DDS EVALUATION | verdict | api | And DDS evaluates and sends results to Trip Tracer UI |  |
| CP077 | TRIP TRACER UI VALIDATION | verdict | api | Segment 1: Flight: AC 476, Route: YUL ? YYZ, Status: COMPLETED (on time, no delay codes) | Segment 1: Flight: AC 476, Route: YUL ? YYZ, Status: COMPLETED (on time, no delay codes) |
| CP078 | TRIP TRACER UI VALIDATION | verdict | api | Segment 2: Flight: AC 477, Route: YYZ ? YVR, Scheduled: 12:00 ? 14:05, Actual: 19:25 ? 21:30, Status: DELAYED (operated) (claim filed) | Segment 2: Flight: AC 477, Route: YYZ ? YVR, Scheduled: 12:00 ? 14:05, Actual: 19:25 ? 21:30, Status: DELAYED (operated) (claim filed) |
| CP079 | TRIP TRACER UI VALIDATION | verdict | api | Segment 2 departure delay = 445 min ; arrival delay = 445 min ? band 6�9 hours | Segment 2 departure delay = 445 min ; arrival delay = 445 min ? band 6�9 hours |
| CP080 | TRIP TRACER UI VALIDATION | verdict | api | Customer Status: NO TRAVEL - INCOMPLETE (started journey, stranded at connection YYZ, Leg 2 coupon not flown) | Customer Status: NO TRAVEL - INCOMPLETE (started journey, stranded at connection YYZ, Leg 2 coupon not flown) |
| CP081 | TRIP TRACER UI VALIDATION | verdict | api | History - No rebooking accepted for connecting segment | History - No rebooking accepted for connecting segment |
| CP082 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP083 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 477 � YYZ ? YVR (Leg 2) | MSL FLIGHT: AC 477 � YYZ ? YVR (Leg 2) |
| CP084 | TRIP TRACER UI VALIDATION | verdict | api | Cancellation code: NONE | Cancellation code: NONE |
| CP085 | TRIP TRACER UI VALIDATION | verdict | api | First arrival delay code: 47 (TL) � "Standby aircraft, lack of planned standby aircraft for technical reasons" | First arrival delay code: 47 (TL) � "Standby aircraft, lack of planned standby aircraft for technical reasons" |
| CP086 | TRIP TRACER UI VALIDATION | verdict | api | First departure delay code: 47 (TL) | First departure delay code: 47 (TL) |
| CP087 | TRIP TRACER UI VALIDATION | verdict | api | No additional delay codes on MSL | No additional delay codes on MSL |
| CP088 | TRIP TRACER UI VALIDATION | verdict | api | Controllability source = first arrival delay code (no cancellation code) | Controllability source = first arrival delay code (no cancellation code) |
| CP089 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE (arrival delay code available) | Fallback: FALSE (arrival delay code available) |
| CP090 | TRIP TRACER UI VALIDATION | verdict | api | APPR causal category: Within carrier control � For Safety ? SAFETY | APPR causal category: Within carrier control � For Safety ? SAFETY |
| CP091 | TRIP TRACER UI VALIDATION | verdict | api | Disruption Type: DELAY (mid-journey) | Disruption Type: DELAY (mid-journey) |
| CP092 | TRIP TRACER UI VALIDATION | verdict | api | No Travel Branch B (Did not remain at origin � intermediate travel) + MSL delayed 3+ hours ? controllability check ? Safety | No Travel Branch B (Did not remain at origin � intermediate travel) + MSL delayed 3+ hours ? controllability check ? Safety |
| CP093 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: LINKED / Tier code A / Aeroplan Basic | Aeroplan: LINKED / Tier code A / Aeroplan Basic |
| CP094 | TRIP TRACER UI VALIDATION | verdict | api | DDS outcome code: FD-APPR-NE-18 | DDS outcome code: FD-APPR-NE-18 |
| CP095 | TRIP TRACER UI VALIDATION | verdict | api | Compensation outcome: NOT ELIGIBLE (no cash compensation, 6�9h tier not applied) | Compensation outcome: NOT ELIGIBLE (no cash compensation, 6�9h tier not applied) |
| CP096 | TRIP TRACER UI VALIDATION | verdict | api | Ticket refund entitlement: PRO-RATED / FULL refund of unused portion (Branch B � Safety) | Ticket refund entitlement: PRO-RATED / FULL refund of unused portion (Branch B � Safety) |
| CP097 | TRIP TRACER UI VALIDATION | verdict | api | Expenses: APPLICABLE under Branch B � Safety (none claimed in this test) | Expenses: APPLICABLE under Branch B � Safety (none claimed in this test) |
| CP098 | TRIP TRACER UI VALIDATION | verdict | api | MR JACQUES FORTIER / NOT ELIGIBLE / SAFETY / CAD 0.00 | MR JACQUES FORTIER / NOT ELIGIBLE / SAFETY / CAD 0.00 |
| CP099 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP100 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP101 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your connecting flight AC 477 from Toronto (YYZ) to Vancouver (YVR) on June 1, 2026 was delayed by more t |
| CP102 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP103 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP104 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP105 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP106 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to j***@gmail.com |  |
| CP107 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (safety � lack of planned standby aircraft for technical reasons |  |
| CP108 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No] | Is there anything I can help you with? |
| CP109 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP110 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Jacques Fortier" with PNR "TC071" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Jacques Fortier" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC071" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Jacques Fortier" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "j***@gmail.com" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***901" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address and Profile ID should be populated |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Linked" with the Aeroplan number masked |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be "Aeroplan Basic" (tier code A) |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: YUL ? YYZ" as completed and "Segment 2: YYZ ? YVR" with claim filed for this flight |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present with no expected ancillary fees |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should show "NOT ELIGIBLE" with reason "Safety � lack of planned standby aircraft for technical |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the arrival delay should show 445 minutes (6�9 hour band) |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the travel status should show "No Travel � Incomplete" with stranded location "YYZ" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS outcome should be "FD-APPR-NE-18" |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to Safety arrival delay Code 47 (TL � lack of planned standby air |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should NOT show a CAD 700 compensation amount for the 6�9 hour band |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should NOT reference the Aeroplan Basic tier as a reason |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Jacques Fortier + TC071 + YYZ?YVR + FD" |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP164 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to Safety arrival delay code 47 (TL � lack of planned standby aircraft for technical reas |  |
| CP165 | PAYMENT VALIDATION | payment | chat | And the arrival delay is in the 6�9 hour band |  |
| CP166 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP167 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP168 | PAYMENT VALIDATION | payment | chat | And no Interac email should have been collected |  |
| CP169 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP170 | PAYMENT VALIDATION | payment | chat | And no CAD 700 tier amount should have been calculated or stored |  |
| CP171 | PAYMENT VALIDATION | payment | chat | And no AC Wallet or Aeroplan-related credit should have been issued |  |
| CP172 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP173 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP174 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-18. | DDS returns FD-APPR-NE-18. |
| CP175 | EXPECTED RESULTS | verdict | chat | Seg 1 AC 476 YUL?YYZ Completed. | Seg 1 AC 476 YUL?YYZ Completed. |
| CP176 | EXPECTED RESULTS | verdict | chat | Seg 2 AC 477 YYZ?YVR DELAYED (445 min, 6�9h band). | Seg 2 AC 477 YYZ?YVR DELAYED (445 min, 6�9h band). |
| CP177 | EXPECTED RESULTS | verdict | chat | Cancellation code = NONE. | Cancellation code = NONE. |
| CP178 | EXPECTED RESULTS | verdict | api | Arrival delay code = 47 (TL, lack of planned standby aircraft for technical reasons), Fallback = FALSE, single code on MSL. | Arrival delay code = 47 (TL, lack of planned standby aircraft for technical reasons), Fallback = FALSE, single code on MSL. |
| CP179 | EXPECTED RESULTS | verdict | api | MSL = Leg 2. | MSL = Leg 2. |
| CP180 | EXPECTED RESULTS | verdict | chat | No Travel = TRUE, Status = Incomplete (stranded at YYZ). | No Travel = TRUE, Status = Incomplete (stranded at YYZ). |
| CP181 | EXPECTED RESULTS | verdict | chat | Controllability: 47 = Within carrier control � For Safety, so no cash compensation and the 6�9h tier isn't applied. | Controllability: 47 = Within carrier control � For Safety, so no cash compensation and the 6�9h tier isn't applied. |
| CP182 | EXPECTED RESULTS | verdict | chat | Outcome: expenses (none claimed) + pro-rated/full refund of the unused portion, CAD 0.00 cash. | Outcome: expenses (none claimed) + pro-rated/full refund of the unused portion, CAD 0.00 cash. |
| CP183 | EXPECTED RESULTS | verdict | chat | Aeroplan Basic (tier A) is shown but doesn't affect the outcome. | Aeroplan Basic (tier A) is shown but doesn't affect the outcome. |
| CP184 | EXPECTED RESULTS | verdict | chat | Fraud: NOT INVOKED. | Fraud: NOT INVOKED. |
| CP185 | EXPECTED RESULTS | verdict | chat | IDV: NOT REQUIRED. | IDV: NOT REQUIRED. |
| CP186 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP187 | EXPECTED RESULTS | verdict | chat | APPR = NE-18; EU = N/A; ASL = N/A. | APPR = NE-18; EU = N/A; ASL = N/A. |
