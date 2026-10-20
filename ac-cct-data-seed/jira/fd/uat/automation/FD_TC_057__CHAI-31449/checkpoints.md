# FD_TC_057 · CHAI-31449 — checkpoints

**Goal:** A single-leg flight is delayed more than 3 hours because of delay code 51 (bird strike found, so the aircraft needs a damage inspection; uncontrollable). The customer chooses not to travel and stays at the origin. Checks that No Travel Origin plus an uncontrollable damage code returns Not Eligible under APPR, with a full ticket refund entitlement.

Methods: seed 11, chat 37, api 28, email 3, dashboard 39, implied 15, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | A single-leg flight is delayed more than 3 hours because of delay code 51 (bird strike found, so the aircraft needs a damage inspection; unc |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR TC044: one adult passenger, one AC domestic leg YUL?YYZ, AC 460, May 28, 2026 | PNR TC044: one adult passenger, one AC domestic leg YUL?YYZ, AC 460, May 28, 2026 |
| CP003 | PREREQUISITES | prerequisite | seed | Scheduled 10:00 ? 12:00 | Scheduled 10:00 ? 12:00 |
| CP004 | PREREQUISITES | prerequisite | seed | Actual departure 14:20 (260 min late) | Actual departure 14:20 (260 min late) |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival 16:25 (265 min late) | Actual arrival 16:25 (265 min late) |
| CP006 | PREREQUISITES | prerequisite | seed | No cancellation code | No cancellation code |
| CP007 | PREREQUISITES | prerequisite | seed | First arrival delay code 51 (DF) | First arrival delay code 51 (DF) |
| CP008 | PREREQUISITES | prerequisite | seed | First departure delay code 51 (DF) | First departure delay code 51 (DF) |
| CP009 | PREREQUISITES | prerequisite | seed | Passenger not boarded and coupon not flown | Passenger not boarded and coupon not flown |
| CP010 | PREREQUISITES | prerequisite | seed | Customer stayed at YUL | Customer stayed at YUL |
| CP011 | PREREQUISITES | prerequisite | seed | No Travel status: Origin | No Travel status: Origin |
| CP012 | PREREQUISITES | prerequisite | seed | No rebooking accepted | No rebooking accepted |
| CP013 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP014 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP015 | START | customer | chat | Then user selects English |  |
| CP016 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP017 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP018 | START | customer | chat | And the user says "My flight from Montreal to Toronto was delayed by more than 4 hours because the aircraft had a bird strike and needed an  | My flight from Montreal to Toronto was delayed by more than 4 hours because the aircraft had a bird strike and needed an inspection, so I decided not to travel  |
| CP019 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP020 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP021 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP022 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable." | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Nathalie Fortin" | Nathalie Fortin |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, Nathalie! And, what is your booking reference number?" | Thanks, Nathalie! And, what is your booking reference number? |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC044" | PNR: TC044 |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC044 |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: Email: n***@outlook.com / Phone: +1***901 |  |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: n***@outlook.com" | Email: n***@outlook.com |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP036 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP038 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays: "I found 1 passenger on this booking: Nathalie Fortin (Adult). Is this who you'd like to include?" | I found 1 passenger on this booking: Nathalie Fortin (Adult). Is this who you'd like to include? |
| CP043 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP045 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 460 Route: Montreal (YUL) ? Toronto (YYZ) Date: May 28, 2026 Status: DELAYED Is this the journey you'd like to check? |
| CP046 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP047 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the system calculates: Scheduled departure May 28, 2026; current date June 15, 2026 ? >72 hours ? PROCEED |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 28, 2026; filing June 15, 2026 ? 18 days ? within 366 days ? PROCEED |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | And DDS evaluates and sends results to Trip Tracer UI |  |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 460, Route: YUL ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 12:00 | Promised Itinerary - Flight: AC 460, Route: YUL ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 12:00 |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Actual Itinerary - Flight: AC 460, Route: YUL ? YYZ, Actual Departure: 14:20, Actual Arrival: 16:25, Status: DELAYED (operated) | Actual Itinerary - Flight: AC 460, Route: YUL ? YYZ, Actual Departure: 14:20, Actual Arrival: 16:25, Status: DELAYED (operated) |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Departure delay = 260 min (?180) ; Arrival delay = 265 min (?180) | Departure delay = 260 min (?180) ; Arrival delay = 265 min (?180) |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Customer Status: NO TRAVEL - ORIGIN (not boarded, coupon not flown, remained at YUL) | Customer Status: NO TRAVEL - ORIGIN (not boarded, coupon not flown, remained at YUL) |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | History - No rebooking accepted | History - No rebooking accepted |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 460 � YUL ? YYZ (only segment) | MSL FLIGHT: AC 460 � YUL ? YYZ (only segment) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Cancellation code: NONE | Cancellation code: NONE |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | First arrival delay code: 51 (DF) � "Damage during flight operations" | First arrival delay code: 51 (DF) � "Damage during flight operations" |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | First departure delay code: 51 (DF) | First departure delay code: 51 (DF) |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Controllability source = first arrival delay code (no cancellation code) | Controllability source = first arrival delay code (no cancellation code) |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | APPR causal category: Outside carrier control � others ? UNCONTROLLABLE | APPR causal category: Outside carrier control � others ? UNCONTROLLABLE |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Disruption Type: DELAY | Disruption Type: DELAY |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | No Travel Branch A (Remained at Origin) + MSL delayed 3+ hours ? controllability check ? Outside carrier's control | No Travel Branch A (Remained at Origin) + MSL delayed 3+ hours ? controllability check ? Outside carrier's control |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | Compensation outcome: NOT ELIGIBLE | Compensation outcome: NOT ELIGIBLE |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Ticket refund entitlement: FULL refund (Branch A � outside control) | Ticket refund entitlement: FULL refund (Branch A � outside control) |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | Expenses: NOT applicable | Expenses: NOT applicable |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE (arrival delay code available) | Fallback: FALSE (arrival delay code available) |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | MS NATHALIE FORTIN / NOT ELIGIBLE / UNCONTROLLABLE / CAD 0.00 | MS NATHALIE FORTIN / NOT ELIGIBLE / UNCONTROLLABLE / CAD 0.00 |
| CP074 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP075 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP076 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your flight AC 460 from Montreal (YUL) to Toronto (YYZ) on May 28, 2026 was delayed by more than 3 hours  |
| CP077 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP078 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP079 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP080 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP081 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to n***@outlook.com |  |
| CP082 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (uncontrollable � damage during flight operations, delay code 51 |  |
| CP083 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No] | Is there anything I can help you with? |
| CP084 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP085 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Nathalie Fortin" with PNR "TC044" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Nathalie Fortin" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC044" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Nathalie Fortin" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "n***@outlook.com" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***901" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address, Profile ID and Tier Status should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present with no expected ancillary fees |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should show "NOT ELIGIBLE" with reason "Uncontrollable � damage during flight operations (Code  |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the travel status should show "No Travel � Origin" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to uncontrollable arrival delay Code 51 (DF � damage during fligh |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Nathalie Fortin + TC044 + YUL?YYZ + FD" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP134 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to uncontrollable damage during flight operations (delay code 51) |  |
| CP135 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP136 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And no Interac email should have been collected |  |
| CP138 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP139 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP140 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP141 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-08. | DDS returns FD-APPR-NE-08. |
| CP142 | EXPECTED RESULTS | verdict | api | Trip Tracer: Flight = DELAYED (departure 260 min late, arrival 265 min late); MSL = Leg 1; no cancellation code; arrival delay code = 51 (DF | Trip Tracer: Flight = DELAYED (departure 260 min late, arrival 265 min late); MSL = Leg 1; no cancellation code; arrival delay code = 51 (DF, damage during flig |
| CP143 | EXPECTED RESULTS | verdict | chat | Compensation: CAD 0.00. | Compensation: CAD 0.00. |
| CP144 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Not Eligible; Uncontrollable (Code 51); No Travel = Origin; DDS = FD-APPR-NE-08. | Claims Dashboard: Not Eligible; Uncontrollable (Code 51); No Travel = Origin; DDS = FD-APPR-NE-08. |
