# FD_TC_048 · CHAI-31440 — checkpoints

**Goal:** An AC-operated itinerary where the original flight is involuntarily cancelled with code DAMA (ANA). A third-party ground vehicle damaged the aircraft, and it needed maintenance before it could fly. The customer is rebooked onto a later AC flight and arrives 7 hours late at YVR. Checks five things: (1) DDS confirms the leg is AC-operated, so there's no OAL redirect, (2) DDS uses the cancellation code DAMA (ANA) and classes it as uncontrollable, (3) the 7-hour delay is calculated from the original promise to the actual arrival on the rebooked flight, (4) Elite 35K status is recognised but doesn't override the uncontrollable outcome, and (5) the result is Not Eligible at CAD 0 with no payment flow.

Methods: seed 13, chat 39, api 29, email 3, dashboard 46, implied 19, manual 9, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | An AC-operated itinerary where the original flight is involuntarily cancelled with code DAMA (ANA). A third-party ground vehicle damaged the |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR TC084: one passenger, Richard Clarke (Adult, Aeroplan Elite 35K 9876543210, good standing) | PNR TC084: one passenger, Richard Clarke (Adult, Aeroplan Elite 35K 9876543210, good standing) |
| CP003 | PREREQUISITES | prerequisite | seed | Ticket stock 014- (AC issued) | Ticket stock 014- (AC issued) |
| CP004 | PREREQUISITES | prerequisite | seed | Original flight: AC 123 YYZ ? YVR, May 26, 2026, scheduled departure 09:00, scheduled arrival 14:00 | Original flight: AC 123 YYZ ? YVR, May 26, 2026, scheduled departure 09:00, scheduled arrival 14:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Operating carrier: Air Canada (AC) | Operating carrier: Air Canada (AC) |
| CP006 | PREREQUISITES | prerequisite | seed | Cancelled at D-1 | Cancelled at D-1 |
| CP007 | PREREQUISITES | prerequisite | seed | Cancellation code: DAMA (ANA), aircraft damage by external source requiring maintenance, uncontrollable | Cancellation code: DAMA (ANA), aircraft damage by external source requiring maintenance, uncontrollable |
| CP008 | PREREQUISITES | prerequisite | seed | Fallback: FALSE | Fallback: FALSE |
| CP009 | PREREQUISITES | prerequisite | seed | INVOL rebooking onto AC 127 YYZ ? YVR, actual arrival 21:00 (7h, 6 to under 9 hour band) | INVOL rebooking onto AC 127 YYZ ? YVR, actual arrival 21:00 (7h, 6 to under 9 hour band) |
| CP010 | PREREQUISITES | prerequisite | seed | Status: Arrived | Status: Arrived |
| CP011 | PREREQUISITES | prerequisite | seed | Filed June 5, 2026 (D+10, more than 72 hours after arrival, within 366 days) | Filed June 5, 2026 (D+10, more than 72 hours after arrival, within 366 days) |
| CP012 | PREREQUISITES | prerequisite | seed | No duplicate | No duplicate |
| CP013 | PREREQUISITES | prerequisite | seed | No expense receipts | No expense receipts |
| CP014 | PREREQUISITES | prerequisite | implied | CyberSource: not invoked | CyberSource: not invoked |
| CP015 | PREREQUISITES | prerequisite | implied | RDS: no flags | RDS: no flags |
| CP016 | PREREQUISITES | prerequisite | seed | Country of residence: Canada | Country of residence: Canada |
| CP017 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP018 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP019 | START | customer | chat | Then user selects English |  |
| CP020 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP021 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP022 | START | customer | chat | And the user says "My Air Canada flight from Toronto to Vancouver was cancelled because the aircraft was damaged and needed maintenance. I w | My Air Canada flight from Toronto to Vancouver was cancelled because the aircraft was damaged and needed maintenance. I was rebooked and arrived 7 hours late. I |
| CP023 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP024 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP025 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your cancelled flight and see if you are eligible for compensation | No problem, I can help you create a claim for your cancelled flight and see if you are eligible for compensation. |
| CP026 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable." | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Richard Clarke" | Richard Clarke |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, Richard! And, what is your booking reference number?" | Thanks, Richard! And, what is your booking reference number? |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC084" | PNR: TC084 |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC084 |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details, Aeroplan Elite 35K profile) is revealed to the customer |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: Email: r***@gmail.com / Phone: +1***678 |  |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: r***@gmail.com" | Email: r***@gmail.com |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP042 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP043 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP044 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP045 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP046 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays: "I found 1 passenger on this booking: Richard Clarke (Adult - Aeroplan Elite 35K). Is this who you'd like to inclu | I found 1 passenger on this booking: Richard Clarke (Adult - Aeroplan Elite 35K). Is this who you'd like to include? |
| CP047 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP049 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Original Flight: AC 123 (Cancelled) Rebooked Flight: AC 127 (Operated by Air Canada) Route: Toronto (YYZ) ? Vancouver (YVR) Date: |
| CP050 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP051 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP052 | OPERATING CARRIER CHECK | system | implied | Then the system checks the operating carrier on all segments |  |
| CP053 | OPERATING CARRIER CHECK | system | implied | And the system finds: original AC 123 and rebooked AC 127 are both operated by Air Canada |  |
| CP054 | OPERATING CARRIER CHECK | verdict | api | And the system determines: AC-operated itinerary ? NO OAL redirect ? proceed to DDS |  |
| CP055 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP056 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP057 | 72-HOUR CHECK | system | implied | Then the system calculates: Arrival May 26, 2026; filing June 5, 2026 ? >72 hours ? PROCEED |  |
| CP058 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP059 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 26, 2026; filing June 5, 2026 ? 10 days ? within 366 days ? PROCEED |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS identifies MSL = AC 123 YYZ?YVR (cancelled leg) |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the cancellation code on MSL ? DAMA (ANA) ? used for controllability (no fallback needed) |  |
| CP063 | TRIAGE & DDS EVALUATION | verdict | api | And DDS classifies DAMA (ANA) as OUTSIDE CARRIER CONTROL ? UNCONTROLLABLE (aircraft damage by external source) |  |
| CP064 | TRIAGE & DDS EVALUATION | verdict | api | And DDS detects INVOL rebooking: AC 123 ? AC 127 YYZ?YVR |  |
| CP065 | TRIAGE & DDS EVALUATION | verdict | api | And DDS calculates delay = 21:00 (actual arrival on AC 127) ? 14:00 (original promise on AC 123) = 7 hours ? band 6 to <9 hours |  |
| CP066 | TRIAGE & DDS EVALUATION | verdict | api | And DDS does NOT apply the CAD 700 Tier 2 amount because the cause is uncontrollable |  |
| CP067 | TRIAGE & DDS EVALUATION | verdict | api | And DDS reads Aeroplan Elite 35K status ? recognised, does NOT override the uncontrollable outcome |  |
| CP068 | TRIAGE & DDS EVALUATION | verdict | api | And DDS returns NOT ELIGIBLE (FD-APPR-NE-TBC) and sends results to Trip Tracer UI |  |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 123, Route: YYZ ? YVR, Scheduled Departure: 09:00, Scheduled Arrival: 14:00 (CANCELLED) | Promised Itinerary - Flight: AC 123, Route: YYZ ? YVR, Scheduled Departure: 09:00, Scheduled Arrival: 14:00 (CANCELLED) |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 127, Route: YYZ ? YVR, Status: ARRIVED, Actual Arrival: 21:00 | Current Itinerary - Flight: AC 127, Route: YYZ ? YVR, Status: ARRIVED, Actual Arrival: 21:00 |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | History - Change 1: INVOL � AC 123 cancelled at D-1 (DAMA � ANA). Customer rebooked onto AC 127 YYZ?YVR | History - Change 1: INVOL � AC 123 cancelled at D-1 (DAMA � ANA). Customer rebooked onto AC 127 YYZ?YVR |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | Operating carrier: Air Canada (AC) on all segments ? OAL redirect NOT applied | Operating carrier: Air Canada (AC) on all segments ? OAL redirect NOT applied |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | Ticket stock: 014- (AC issued) | Ticket stock: 014- (AC issued) |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | Delay Calculation: 21:00 ? 14:00 = 7 hrs ? DELAY_6_TO_LT_9_HOURS | Delay Calculation: 21:00 ? 14:00 = 7 hrs ? DELAY_6_TO_LT_9_HOURS |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP076 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 123 � YYZ ? YVR � Cancellation Code: DAMA (ANA) � "Cancelled due to aircraft damage requiring maintenance" | MSL FLIGHT: AC 123 � YYZ ? YVR � Cancellation Code: DAMA (ANA) � "Cancelled due to aircraft damage requiring maintenance" |
| CP077 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP078 | TRIP TRACER UI VALIDATION | verdict | api | APPR causal category: Outside carrier control ? UNCONTROLLABLE | APPR causal category: Outside carrier control ? UNCONTROLLABLE |
| CP079 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: 9876543210 (Elite 35K � linked) | Aeroplan: 9876543210 (Elite 35K � linked) |
| CP080 | TRIP TRACER UI VALIDATION | verdict | api | DDS outcome code: FD-APPR-NE-TBC | DDS outcome code: FD-APPR-NE-TBC |
| CP081 | TRIP TRACER UI VALIDATION | verdict | api | MR RICHARD CLARKE / NOT ELIGIBLE / DELAY_6_TO_LT_9_HOURS / UNCONTROLLABLE / CAD 0.00 | MR RICHARD CLARKE / NOT ELIGIBLE / DELAY_6_TO_LT_9_HOURS / UNCONTROLLABLE / CAD 0.00 |
| CP082 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP083 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP084 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your flight AC 123 from Toronto (YYZ) to Vancouver (YVR) on May 26, 2026 was cancelled and you were reboo |
| CP085 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP086 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP087 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP088 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP089 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to r***@gmail.com |  |
| CP090 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (AC 123 cancelled ? AC 127 YYZ?YVR), not eligible reason (uncontrollable � DAMA (ANA) |  |
| CP091 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No] | Is there anything I can help you with? |
| CP092 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP093 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Richard Clarke" with PNR "TC084" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date should be populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Richard Clarke" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC084" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ticket Stock should be "014-" (Air Canada issued) |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier should be "Air Canada (AC)" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Richard Clarke" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant", "Adult" and "Elite 35K" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "r***@gmail.com" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***678" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address and Profile ID should be populated |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "9876543210" linked and in good standing |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be "Elite 35K" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YYZ ? YVR" (AC 123 cancelled; rebooked on AC 127) with claim filed for this flight |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Code should show "Cancellation Code DAMA (ANA) � aircraft damage requiring maintenance � Uncontrollable" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present with no expected ancillary fees |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should show "NOT ELIGIBLE � Uncontrollable (DAMA � ANA) � CAD 0" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the delay should show 7 hours (6 to <9 hour band) with no CAD 700 amount |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS outcome should be "FD-APPR-NE-TBC" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should NOT reference OAL redirect or United Airlines |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should NOT use the Elite 35K tier as a reason |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Richard Clarke + TC084 + YYZ?YVR + FD" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no manual-review queue item should exist for this case |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP148 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-TBC. | DDS returns FD-APPR-NE-TBC. |
| CP149 | EXPECTED RESULTS | verdict | api | Trip Tracer: MSL = Leg 1 (AC 123, cancelled). | Trip Tracer: MSL = Leg 1 (AC 123, cancelled). |
| CP150 | EXPECTED RESULTS | verdict | chat | Operating carrier = Air Canada, so there's no OAL redirect. | Operating carrier = Air Canada, so there's no OAL redirect. |
| CP151 | EXPECTED RESULTS | verdict | chat | Cancellation code = DAMA (ANA), uncontrollable, Fallback = FALSE. | Cancellation code = DAMA (ANA), uncontrollable, Fallback = FALSE. |
| CP152 | EXPECTED RESULTS | verdict | chat | Scheduled arrival 14:00, actual arrival on AC 127 21:00, delay 7 hours (6 to under 9 hour band). | Scheduled arrival 14:00, actual arrival on AC 127 21:00, delay 7 hours (6 to under 9 hour band). |
| CP153 | EXPECTED RESULTS | verdict | chat | Ticket stock 014-. | Ticket stock 014-. |
| CP154 | EXPECTED RESULTS | verdict | chat | Aeroplan Elite 35K is recognised, with no effect on the outcome. | Aeroplan Elite 35K is recognised, with no effect on the outcome. |
| CP155 | EXPECTED RESULTS | verdict | chat | Compensation: CAD 0. | Compensation: CAD 0. |
| CP156 | EXPECTED RESULTS | verdict | chat | CyberSource: not invoked. | CyberSource: not invoked. |
| CP157 | EXPECTED RESULTS | verdict | chat | IDV: not required. | IDV: not required. |
| CP158 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP159 | EXPECTED RESULTS | verdict | dashboard | Claims Dashboard: Closed � Not Eligible, DAMA (ANA), AC operated. | Claims Dashboard: Closed � Not Eligible, DAMA (ANA), AC operated. |
