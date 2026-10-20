# FD_TC_077 · CHAI-31469 — checkpoints

**Goal:** A single-leg flight is delayed more than 3 hours by arrival delay code 03. The inbound aircraft arrived late after an unscheduled maintenance fix upline, which falls under Safety. The customer chose not to travel and stayed at the origin. Under APPR, Safety is its own category, separate from controllable and uncontrollable, and it never pays cash compensation. Checks that DDS classifies code 03 as Safety and returns NE-14, and that the customer's linked Aeroplan Basic profile (tier A) is shown but doesn't change the outcome.

Methods: seed 20, chat 47, api 34, email 3, dashboard 42, implied 15, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | A single-leg flight is delayed more than 3 hours by arrival delay code 03. The inbound aircraft arrived late after an unscheduled maintenanc |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR TC065: one adult passenger, �mile Gagnon | PNR TC065: one adult passenger, �mile Gagnon |
| CP003 | PREREQUISITES | prerequisite | seed | One AC domestic leg: AC 470, YUL?YYZ, May 31, 2026 | One AC domestic leg: AC 470, YUL?YYZ, May 31, 2026 |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled 10:00 ? 12:00 | Scheduled 10:00 ? 12:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual departure 14:15 (255 min late) | Actual departure 14:15 (255 min late) |
| CP006 | PREREQUISITES | prerequisite | seed | Actual arrival 16:20 (260 min late) | Actual arrival 16:20 (260 min late) |
| CP007 | PREREQUISITES | prerequisite | seed | Status: DELAYED (operated) | Status: DELAYED (operated) |
| CP008 | PREREQUISITES | prerequisite | seed | Cancellation code: NONE | Cancellation code: NONE |
| CP009 | PREREQUISITES | prerequisite | seed | First arrival delay code 03 (UM) | First arrival delay code 03 (UM) |
| CP010 | PREREQUISITES | prerequisite | seed | First departure delay code 03 (UM) | First departure delay code 03 (UM) |
| CP011 | PREREQUISITES | prerequisite | seed | Inbound aircraft rotation: AC 409 YYZ?YUL, delayed by TN43 maintenance (not on the customer's PNR) | Inbound aircraft rotation: AC 409 YYZ?YUL, delayed by TN43 maintenance (not on the customer's PNR) |
| CP012 | PREREQUISITES | prerequisite | seed | Passenger not boarded, coupon not flown | Passenger not boarded, coupon not flown |
| CP013 | PREREQUISITES | prerequisite | seed | Customer stayed at YUL | Customer stayed at YUL |
| CP014 | PREREQUISITES | prerequisite | seed | No Travel status: Origin | No Travel status: Origin |
| CP015 | PREREQUISITES | prerequisite | seed | No rebooking accepted | No rebooking accepted |
| CP016 | PREREQUISITES | prerequisite | seed | Aeroplan: linked, tier code A (Aeroplan Basic) | Aeroplan: linked, tier code A (Aeroplan Basic) |
| CP017 | PREREQUISITES | prerequisite | seed | No expense receipts | No expense receipts |
| CP018 | PREREQUISITES | prerequisite | seed | Fallback: FALSE | Fallback: FALSE |
| CP019 | PREREQUISITES | prerequisite | seed | Regime: APPR | Regime: APPR |
| CP020 | PREREQUISITES | prerequisite | seed | More than 72 hours have passed | More than 72 hours have passed |
| CP021 | PREREQUISITES | prerequisite | seed | Filed within 366 days | Filed within 366 days |
| CP022 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP023 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP024 | START | customer | chat | Then user selects English |  |
| CP025 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP026 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP027 | START | customer | chat | And the user says "My flight from Montreal to Toronto was delayed by more than 4 hours because the plane arrived late after a maintenance is | My flight from Montreal to Toronto was delayed by more than 4 hours because the plane arrived late after a maintenance issue on its previous flight, so I decide |
| CP028 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP029 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP030 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP031 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP032 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP033 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable." | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP034 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "�mile Gagnon" | �mile Gagnon |
| CP035 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, �mile! And, what is your booking reference number?" | Thanks, �mile! And, what is your booking reference number? |
| CP036 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC065" | PNR: TC065 |
| CP037 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC065 |  |
| CP038 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP039 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details, linked Aeroplan profile) is revealed to the customer |  |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: Email: e***@gmail.com / Phone: +1***567 |  |
| CP042 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: e***@gmail.com" | Email: e***@gmail.com |
| CP043 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP044 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP045 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP046 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP047 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP048 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP049 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP050 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP051 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays: "I found 1 passenger on this booking: �mile Gagnon (Adult). Is this who you'd like to include?" | I found 1 passenger on this booking: �mile Gagnon (Adult). Is this who you'd like to include? |
| CP052 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP053 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP054 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 470 Route: Montreal (YUL) ? Toronto (YYZ) Date: May 31, 2026 Status: DELAYED Is this the journey you'd like to check? |
| CP055 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP056 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP057 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP058 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP059 | 72-HOUR CHECK | system | implied | Then the system calculates: Scheduled departure May 31, 2026; current date June 15, 2026 ? >72 hours ? PROCEED |  |
| CP060 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP061 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 31, 2026; filing June 15, 2026 ? 15 days ? within 366 days ? PROCEED |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP063 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the cancellation code on MSL ? NONE |  |
| CP064 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the first arrival delay code on MSL ? 03 (UM) |  |
| CP065 | TRIAGE & DDS EVALUATION | verdict | api | And DDS uses the arrival delay code for controllability (no fallback needed) |  |
| CP066 | TRIAGE & DDS EVALUATION | verdict | api | And DDS classifies 03 (UM) as SAFETY under APPR |  |
| CP067 | TRIAGE & DDS EVALUATION | verdict | api | And DDS reads Aeroplan tier code A (Aeroplan Basic) ? tier-based expense rule NOT applied (rule applies to uncontrollable disruptions only) |  |
| CP068 | TRIAGE & DDS EVALUATION | verdict | api | And DDS evaluates and sends results to Trip Tracer UI |  |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 470, Route: YUL ? YYZ, Date: May 31, 2026, Scheduled Departure: 10:00, Scheduled Arrival: 12:00 | Promised Itinerary - Flight: AC 470, Route: YUL ? YYZ, Date: May 31, 2026, Scheduled Departure: 10:00, Scheduled Arrival: 12:00 |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Actual Itinerary - Flight: AC 470, Route: YUL ? YYZ, Actual Departure: 14:15, Actual Arrival: 16:20, Status: DELAYED (operated) | Actual Itinerary - Flight: AC 470, Route: YUL ? YYZ, Actual Departure: 14:15, Actual Arrival: 16:20, Status: DELAYED (operated) |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | Departure delay = 255 min (?180) ; Arrival delay = 260 min (?180) | Departure delay = 255 min (?180) ; Arrival delay = 260 min (?180) |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | Customer Status: NO TRAVEL - ORIGIN (not boarded, coupon not flown, remained at YUL) | Customer Status: NO TRAVEL - ORIGIN (not boarded, coupon not flown, remained at YUL) |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | History - No rebooking accepted | History - No rebooking accepted |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 470 � YUL ? YYZ (only segment) | MSL FLIGHT: AC 470 � YUL ? YYZ (only segment) |
| CP076 | TRIP TRACER UI VALIDATION | verdict | api | Cancellation code: NONE | Cancellation code: NONE |
| CP077 | TRIP TRACER UI VALIDATION | verdict | api | First arrival delay code: 03 (UM) � "Late positioning due to upline mechanical/safety" | First arrival delay code: 03 (UM) � "Late positioning due to upline mechanical/safety" |
| CP078 | TRIP TRACER UI VALIDATION | verdict | api | First departure delay code: 03 (UM) | First departure delay code: 03 (UM) |
| CP079 | TRIP TRACER UI VALIDATION | verdict | api | Controllability source = first arrival delay code (no cancellation code) | Controllability source = first arrival delay code (no cancellation code) |
| CP080 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE (arrival delay code available) | Fallback: FALSE (arrival delay code available) |
| CP081 | TRIP TRACER UI VALIDATION | verdict | api | APPR causal category: Within carrier control � For Safety ? SAFETY | APPR causal category: Within carrier control � For Safety ? SAFETY |
| CP082 | TRIP TRACER UI VALIDATION | verdict | api | Disruption Type: DELAY | Disruption Type: DELAY |
| CP083 | TRIP TRACER UI VALIDATION | verdict | api | No Travel Branch A (Remained at Origin) + MSL delayed 3+ hours ? controllability check ? Safety | No Travel Branch A (Remained at Origin) + MSL delayed 3+ hours ? controllability check ? Safety |
| CP084 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: LINKED / Tier code A / Aeroplan Basic | Aeroplan: LINKED / Tier code A / Aeroplan Basic |
| CP085 | TRIP TRACER UI VALIDATION | verdict | api | DDS outcome code: FD-APPR-NE-14 | DDS outcome code: FD-APPR-NE-14 |
| CP086 | TRIP TRACER UI VALIDATION | verdict | api | Compensation outcome: NOT ELIGIBLE (no cash compensation) | Compensation outcome: NOT ELIGIBLE (no cash compensation) |
| CP087 | TRIP TRACER UI VALIDATION | verdict | api | Ticket refund entitlement: FULL refund (Branch A � Safety) | Ticket refund entitlement: FULL refund (Branch A � Safety) |
| CP088 | TRIP TRACER UI VALIDATION | verdict | api | Expenses: APPLICABLE under Branch A � Safety (none claimed in this test) | Expenses: APPLICABLE under Branch A � Safety (none claimed in this test) |
| CP089 | TRIP TRACER UI VALIDATION | verdict | api | MR �MILE GAGNON / NOT ELIGIBLE / SAFETY / CAD 0.00 | MR �MILE GAGNON / NOT ELIGIBLE / SAFETY / CAD 0.00 |
| CP090 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP091 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP092 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your flight AC 470 from Montreal (YUL) to Toronto (YYZ) on May 31, 2026 was delayed by more than 3 hours  |
| CP093 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP094 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP095 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP096 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP097 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to e***@gmail.com |  |
| CP098 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (safety � late positioning due to upline mechanical/safety, arri |  |
| CP099 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No] | Is there anything I can help you with? |
| CP100 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP101 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "�mile Gagnon" with PNR "TC065" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "�mile Gagnon" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC065" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "�mile Gagnon" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "e***@gmail.com" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***567" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address and Profile ID should be populated |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Linked" with the Aeroplan number masked |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be "Aeroplan Basic" (tier code A) |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present with no expected ancillary fees |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should show "NOT ELIGIBLE" with reason "Safety � late positioning due to upline mechanical/safe |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the travel status should show "No Travel � Origin" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS outcome should be "FD-APPR-NE-14" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to Safety arrival delay Code 03 (UM � late positioning due to upl |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should NOT reference the Aeroplan Basic tier as a reason |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "�mile Gagnon + TC065 + YUL?YYZ + FD" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP153 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to Safety arrival delay code 03 (UM) |  |
| CP154 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP155 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP156 | PAYMENT VALIDATION | payment | chat | And no Interac email should have been collected |  |
| CP157 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP158 | PAYMENT VALIDATION | payment | chat | And no AC Wallet or Aeroplan-related credit should have been issued |  |
| CP159 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP160 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP161 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-14. | DDS returns FD-APPR-NE-14. |
| CP162 | EXPECTED RESULTS | verdict | chat | AC 470 YUL?YYZ DELAYED (departure 255 min late, arrival 260 min late). | AC 470 YUL?YYZ DELAYED (departure 255 min late, arrival 260 min late). |
| CP163 | EXPECTED RESULTS | verdict | chat | Cancellation code = NONE. | Cancellation code = NONE. |
| CP164 | EXPECTED RESULTS | verdict | chat | Arrival delay code = 03 (UM), Fallback = FALSE. | Arrival delay code = 03 (UM), Fallback = FALSE. |
| CP165 | EXPECTED RESULTS | verdict | api | MSL = Leg 1. | MSL = Leg 1. |
| CP166 | EXPECTED RESULTS | verdict | chat | No Travel = TRUE, Status = Origin. | No Travel = TRUE, Status = Origin. |
| CP167 | EXPECTED RESULTS | verdict | chat | Controllability: 03 = Within carrier control � For Safety, so no cash compensation. | Controllability: 03 = Within carrier control � For Safety, so no cash compensation. |
| CP168 | EXPECTED RESULTS | verdict | chat | Branch A + Safety entitlement: expenses (none claimed) + full ticket refund, CAD 0.00 cash compensation. | Branch A + Safety entitlement: expenses (none claimed) + full ticket refund, CAD 0.00 cash compensation. |
| CP169 | EXPECTED RESULTS | verdict | chat | Aeroplan Basic (tier A) is shown but doesn't affect the outcome. | Aeroplan Basic (tier A) is shown but doesn't affect the outcome. |
| CP170 | EXPECTED RESULTS | verdict | chat | Fraud: NOT INVOKED. | Fraud: NOT INVOKED. |
| CP171 | EXPECTED RESULTS | verdict | chat | IDV: NOT REQUIRED. | IDV: NOT REQUIRED. |
| CP172 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
