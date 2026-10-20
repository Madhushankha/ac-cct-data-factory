# FD_TC_082 · CHAI-31474 — checkpoints

**Goal:** Multi-leg journey where connecting flight cancelled due to safety regulation (PERF). Customer stranded at midpoint (YYZ) � did not rebook, did not return to origin, did not reach destination. This is the most complex No Travel status (Incomplete) combined with Safety. Validates: (1) MSL correctly identifies Leg 2 as the disrupted leg, (2) PERF on the connecting leg produces Safety classification, (3) No Travel Incomplete status detected when customer is stranded at midpoint.

Methods: seed 9, chat 45, api 21, email 3, dashboard 44, implied 18, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Multi-leg journey where connecting flight cancelled due to safety regulation (PERF). Customer stranded at midpoint (YYZ) � did not rebook, d |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC039 � single passenger (Adult) | PNR: TC039 � single passenger (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 2 legs: Leg 1 AC 348 YUL?YYZ (Completed); Leg 2 AC 349 YYZ?YVR (CANCELLED) | Journey: 2 legs: Leg 1 AC 348 YUL?YYZ (Completed); Leg 2 AC 349 YYZ?YVR (CANCELLED) |
| CP004 | PREREQUISITES | prerequisite | seed | Cancellation code: PERF (Safety Regulation) | Cancellation code: PERF (Safety Regulation) |
| CP005 | PREREQUISITES | prerequisite | seed | Customer action: Stranded at YYZ (midpoint) | Customer action: Stranded at YYZ (midpoint) |
| CP006 | PREREQUISITES | prerequisite | seed | Did NOT return to YUL | Did NOT return to YUL |
| CP007 | PREREQUISITES | prerequisite | seed | Did NOT reach YVR | Did NOT reach YVR |
| CP008 | PREREQUISITES | prerequisite | seed | No Travel status: Incomplete | No Travel status: Incomplete |
| CP009 | PREREQUISITES | prerequisite | seed | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP010 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic) | Regime: APPR (domestic) |
| CP011 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP012 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP013 | START | customer | chat | Then user selects English |  |
| CP014 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP015 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP016 | START | customer | chat | And the user says "I flew from Montreal to Toronto but my connecting flight from Toronto to Vancouver was cancelled due to a safety issue an | I flew from Montreal to Toronto but my connecting flight from Toronto to Vancouver was cancelled due to a safety issue and I didn't take any replacement. Can I  |
| CP017 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP018 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP019 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP020 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Jacques Fortier" | Jacques Fortier |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Jacques! And, what is your booking reference number? |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC045" | PNR: TC045 |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC045 |  |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: j***@gmail.com � Phone: +1***901 |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: j***@gmail.com" | Email: j***@gmail.com |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP034 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP036 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP037 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP039 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Jacques Fortier (Adult) Is this who you'd like to include? |
| CP041 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP043 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Segment 1: Flight AC 476, Montreal (YUL) ? Toronto (YYZ), June 1, 2026 � COMPLETED � Segment 2: Flight AC 477, Toronto (YYZ) ?  |
| CP044 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP046 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 CANCELLED |  |
| CP047 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot determines: Claim applies to Segment 2 (AC 477 YYZ?YVR � CANCELLED) |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure of cancelled segment |  |
| CP051 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure was June 1, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP053 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption June 1, 2026; filing June 15, 2026 ? 14 days ? within 366 days ? PROCEED |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Segment 1: Flight: AC 476, Route: YUL ? YYZ, Status: COMPLETED | Segment 1: Flight: AC 476, Route: YUL ? YYZ, Status: COMPLETED |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Segment 2: Flight: AC 477, Route: YYZ ? YVR, Status: CANCELLED (claim filed) | Segment 2: Flight: AC 477, Route: YYZ ? YVR, Status: CANCELLED (claim filed) |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Customer Status: NO TRAVEL - INCOMPLETE (started journey, stranded at connection YYZ) | Customer Status: NO TRAVEL - INCOMPLETE (started journey, stranded at connection YYZ) |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | History - No rebooking accepted for connecting segment | History - No rebooking accepted for connecting segment |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 477 � YYZ ? YVR � PERF | MSL FLIGHT: AC 477 � YYZ ? YVR � PERF |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | "Cancellation � safety regulation" | "Cancellation � safety regulation" |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | SAFETY (PERF) | SAFETY (PERF) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Disruption Type: CANCELLATION (mid-journey) | Disruption Type: CANCELLATION (mid-journey) |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | DDS Gate 9: Safety ? NOT ELIGIBLE under APPR | DDS Gate 9: Safety ? NOT ELIGIBLE under APPR |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | MR JACQUES FORTIER / NOT ELIGIBLE / SAFETY / CAD 0.00 | MR JACQUES FORTIER / NOT ELIGIBLE / SAFETY / CAD 0.00 |
| CP068 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP069 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP070 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your connecting flight AC 477 from Toronto (YYZ) to Vancouver (YVR) on June 1, 2026 was cancelled. Howeve |
| CP071 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP072 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP073 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP074 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP075 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to j***@gmail.com |  |
| CP076 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (safety � safety regulation), travel status (No Travel - Incompl |  |
| CP077 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP078 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP079 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Jacques Fortier" with PNR "TC045" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Jacques Fortier" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC045" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Jacques Fortier" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "j***@gmail.com" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***901" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: YUL ? YYZ" as completed and "Segment 2: YYZ ? YVR" with claim filed for this flight |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Safety � Code 81" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to Safety Code 81 safety regulation |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Jacques Fortier + TC045 + YYZ?YVR + FD" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP133 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to Safety PERF |  |
| CP134 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP135 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP136 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP137 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP138 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP139 | EXPECTED RESULTS | verdict | api | DDS: FD-APPR-NE-18. | DDS: FD-APPR-NE-18. |
| CP140 | EXPECTED RESULTS | verdict | chat | Seg 1 AC 476 YUL?YYZ Completed. | Seg 1 AC 476 YUL?YYZ Completed. |
| CP141 | EXPECTED RESULTS | verdict | chat | Seg 2 AC 477 YYZ?YVR CANCELLED. | Seg 2 AC 477 YYZ?YVR CANCELLED. |
| CP142 | EXPECTED RESULTS | verdict | chat | Cancellation code = PERF (Safety). | Cancellation code = PERF (Safety). |
| CP143 | EXPECTED RESULTS | verdict | api | MSL = Leg 2 (YYZ?YVR). | MSL = Leg 2 (YYZ?YVR). |
| CP144 | EXPECTED RESULTS | verdict | chat | No Travel = TRUE, Status = Incomplete (stranded at YYZ). | No Travel = TRUE, Status = Incomplete (stranded at YYZ). |
| CP145 | EXPECTED RESULTS | verdict | api | No Travel Gate: MSL cancelled ? YES ? Check controllability. | No Travel Gate: MSL cancelled ? YES ? Check controllability. |
| CP146 | EXPECTED RESULTS | verdict | chat | Controllability: PERF = Safety ? No cash compensation. | Controllability: PERF = Safety ? No cash compensation. |
| CP147 | EXPECTED RESULTS | verdict | chat | Outcome: Expenses + pro-rated/full ticket refund, $0 cash. | Outcome: Expenses + pro-rated/full ticket refund, $0 cash. |
| CP148 | EXPECTED RESULTS | verdict | chat | Fraud: NOT INVOKED. | Fraud: NOT INVOKED. |
| CP149 | EXPECTED RESULTS | verdict | chat | IDV: NOT REQUIRED. | IDV: NOT REQUIRED. |
| CP150 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP151 | EXPECTED RESULTS | verdict | chat | APPR = NE-18 (No Travel Incomplete + Safety); EU = N/A; ASL = N/A. | APPR = NE-18 (No Travel Incomplete + Safety); EU = N/A; ASL = N/A. |
