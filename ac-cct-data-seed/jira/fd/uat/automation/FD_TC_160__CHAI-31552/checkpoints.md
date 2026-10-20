# FD_TC_160 · CHAI-31552 — checkpoints

**Goal:** Israel-bound flight (YYZ?TLV, AC-operated) cancelled due to not extraordinary circumstance (cancellation code CREW � crew unavailability, controllable). Re-routing delay was only 2 hours � below the 3-hour ASL No Travel threshold (Gate 8). Despite controllable cause and cancellation, insufficient delay = NOT ELIGIBLE.

Methods: seed 10, chat 39, api 20, email 3, dashboard 44, implied 16, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Israel-bound flight (YYZ?TLV, AC-operated) cancelled due to not extraordinary circumstance (cancellation code CREW � crew unavailability, co |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Hadas Mor (Adult) | PNR: single passenger Hadas Mor (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 085, YYZ?TLV | Journey: 1 leg AC operated, Flight AC 085, YYZ?TLV |
| CP004 | PREREQUISITES | prerequisite | seed | Flight status: CANCELLED | Flight status: CANCELLED |
| CP005 | PREREQUISITES | prerequisite | seed | Cancellation code: CREW (Crew unavailability � Not Extraordinary Circumstance / Controllable) | Cancellation code: CREW (Crew unavailability � Not Extraordinary Circumstance / Controllable) |
| CP006 | PREREQUISITES | prerequisite | seed | Re-routing delay: 2hrs (below 3hr threshold) | Re-routing delay: 2hrs (below 3hr threshold) |
| CP007 | PREREQUISITES | prerequisite | seed | Customer action: Stayed at YYZ, did NOT accept rebooking, did NOT travel | Customer action: Stayed at YYZ, did NOT accept rebooking, did NOT travel |
| CP008 | PREREQUISITES | prerequisite | seed | No Travel status: Origin | No Travel status: Origin |
| CP009 | PREREQUISITES | prerequisite | seed | Fallback: FALSE | Fallback: FALSE |
| CP010 | PREREQUISITES | prerequisite | seed | Regime: ASL (Israel destination � TLV) + APPR (Canadian origin � YYZ) | Regime: ASL (Israel destination � TLV) + APPR (Canadian origin � YYZ) |
| CP011 | PREREQUISITES | prerequisite | seed | Result: NOT ELIGIBLE (delay below 3hr threshold despite controllable cause) | Result: NOT ELIGIBLE (delay below 3hr threshold despite controllable cause) |
| CP012 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP013 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP014 | START | customer | chat | Then user selects English |  |
| CP015 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP016 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP017 | START | customer | chat | And the user says "My flight from Toronto to Tel Aviv was disrupted and I decided not to take any replacement flight. Can I get compensation | My flight from Toronto to Tel Aviv was disrupted and I decided not to take any replacement flight. Can I get compensation? |
| CP018 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP019 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP020 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP021 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Hadas Mor" | Hadas Mor |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Hadas! And, what is your booking reference number? |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC128" | PNR: TC128 |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC128 |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: h***@gmail.com � Phone: +1***345 |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: h***@gmail.com" | Email: h***@gmail.com |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP035 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP037 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Hadas Mor (Adult) Is this who you'd like to include? |
| CP042 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP044 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 085 � Route: Toronto (YYZ) ? Tel Aviv Ben Gurion (TLV) � Date: May 31, 2026 � Status: Disrupted (MSL delay: 2 hours) |
| CP045 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure ? >72 hours ? PROCEED |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for ASL (Israel) = 7 years ? within limitation ? PROCEED |  |
| CP051 | REGIME DETERMINATION | verdict | api | Then the system determines applicable regime: |  |
| CP052 | REGIME DETERMINATION | system | implied | And the system checks: Origin airport = YYZ (Toronto, Canada) ? NOT Israel origin |  |
| CP053 | REGIME DETERMINATION | system | implied | And the system checks: Destination airport = TLV (Tel Aviv, Israel) ? Israel destination |  |
| CP054 | REGIME DETERMINATION | system | implied | And the system determines: ASL (Israel Aviation Services Law) applies |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 085, Route: YYZ ? TLV, Scheduled Arrival: 16:00 (local TLV) | Promised Itinerary - Flight: AC 085, Route: YYZ ? TLV, Scheduled Arrival: 16:00 (local TLV) |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 085, Route: YYZ ? TLV, Status: DISRUPTED | Current Itinerary - Flight: AC 085, Route: YYZ ? TLV, Status: DISRUPTED |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | MSL Delay: 2H 00M ? BELOW 3-HOUR ASL THRESHOLD | MSL Delay: 2H 00M ? BELOW 3-HOUR ASL THRESHOLD |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Customer Status: NO TRAVEL - ORIGIN (customer remained at YYZ, declined rebooking) | Customer Status: NO TRAVEL - ORIGIN (customer remained at YYZ, declined rebooking) |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | History - No rebooking accepted | History - No rebooking accepted |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Regime: ASL (Israel) (Israel destination � TLV) | Regime: ASL (Israel) (Israel destination � TLV) |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Destination: TLV (Israel) | Destination: TLV (Israel) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | ASL Threshold: Delay must be ? 3 hours ? 2h < 3h ? NOT ELIGIBLE | ASL Threshold: Delay must be ? 3 hours ? 2h < 3h ? NOT ELIGIBLE |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE | Fallback: FALSE |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | MS HADAS MOR / NOT ELIGIBLE / DELAY_BELOW_3_HOURS / 0.00 | MS HADAS MOR / NOT ELIGIBLE / DELAY_BELOW_3_HOURS / 0.00 |
| CP067 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP068 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your arrival in Tel Aviv was on time. That means there's no recorded delay for this part of your trip. Based |
| CP069 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP070 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP071 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP072 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP073 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to h***@gmail.com |  |
| CP074 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (MSL delay below 3-hour threshold), travel status (No Travel - O |  |
| CP075 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP076 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP077 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Hadas Mor" with PNR "TC128" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Hadas Mor" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC128" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL (Israel destination � TLV) + APPR" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Hadas Mor" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "h***@gmail.com" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***345" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YYZ ? TLV" with claim filed as cancelled |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "MSL re-routing delay 2h � below ASL mini |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to delay 2h being less than 3h ASL No Travel threshold |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Hadas Mor + TC128 + YYZ?TLV + FD" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe to "h***@gmail.com" containing Case Reference and YYZ to TLV CANCELLED |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP131 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to MSL delay below 3-hour ASL threshold |  |
| CP132 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP133 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP134 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP135 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP136 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP137 | EXPECTED RESULTS | verdict | api | DDS returns FD-ASL-NE-14. | DDS returns FD-ASL-NE-14. |
| CP138 | EXPECTED RESULTS | verdict | api | Trip Tracer: CANCELLED; MSL = AC 085 YYZ?TLV; Cancellation Code = CREW (4-char Netline � Not Extraordinary Circumstance / Controllable); Re- | Trip Tracer: CANCELLED; MSL = AC 085 YYZ?TLV; Cancellation Code = CREW (4-char Netline � Not Extraordinary Circumstance / Controllable); Re-routing delay = 2hrs |
| CP139 | EXPECTED RESULTS | verdict | chat | CRITICAL: Despite controllable cancellation code CREW on Israel-bound route, re-routing delay is below 3hr threshold ? NE. | CRITICAL: Despite controllable cancellation code CREW on Israel-bound route, re-routing delay is below 3hr threshold ? NE. |
| CP140 | EXPECTED RESULTS | verdict | chat | Threshold overrides controllability. | Threshold overrides controllability. |
| CP141 | EXPECTED RESULTS | verdict | chat | Both regimes NE (below threshold). | Both regimes NE (below threshold). |
| CP142 | EXPECTED RESULTS | verdict | chat | Result: NOT ELIGIBLE, ILS 0. | Result: NOT ELIGIBLE, ILS 0. |
| CP143 | EXPECTED RESULTS | verdict | api | DDS = FD-ASL-NE-14. | DDS = FD-ASL-NE-14. |
