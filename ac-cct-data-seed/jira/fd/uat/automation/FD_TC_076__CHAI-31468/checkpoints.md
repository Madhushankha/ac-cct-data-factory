# FD_TC_076 · CHAI-31468 — checkpoints

**Goal:** Flight cancelled due to safety regulation (PERF). Customer declined rebooking and stayed at origin. Under APPR, safety is a SEPARATE category from controllable and uncontrollable � disruptions required for safety purposes are never eligible for compensation because passenger safety is a non-negotiable obligation. Validates that DDS correctly classifies PERF as Safety and returns NE regardless of other factors. The No Travel Origin status combined with Safety creates a clear-cut NE scenario.

Methods: seed 11, chat 44, api 21, email 3, dashboard 44, implied 17, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Flight cancelled due to safety regulation (PERF). Customer declined rebooking and stayed at origin. Under APPR, safety is a SEPARATE categor |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC043 � single passenger �mile Gagnon (Adult) | PNR: TC043 � single passenger �mile Gagnon (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | 1 leg AC operated | 1 leg AC operated |
| CP004 | PREREQUISITES | prerequisite | seed | Flight AC 470, YUL ? YYZ (domestic) | Flight AC 470, YUL ? YYZ (domestic) |
| CP005 | PREREQUISITES | prerequisite | seed | Sched Dep: 10:00, Sched Arr: 12:00 | Sched Dep: 10:00, Sched Arr: 12:00 |
| CP006 | PREREQUISITES | prerequisite | seed | Flight status: CANCELLED | Flight status: CANCELLED |
| CP007 | PREREQUISITES | prerequisite | implied | Cancellation code: PERF (Safety � aircraft does not meet required safety/performance standards) | Cancellation code: PERF (Safety � aircraft does not meet required safety/performance standards) |
| CP008 | PREREQUISITES | prerequisite | seed | Customer action: Declined rebooking, stayed at YUL (origin) | Customer action: Declined rebooking, stayed at YUL (origin) |
| CP009 | PREREQUISITES | prerequisite | seed | No Travel status: Origin | No Travel status: Origin |
| CP010 | PREREQUISITES | prerequisite | seed | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP011 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic) | Regime: APPR (domestic) |
| CP012 | PREREQUISITES | prerequisite | seed | Timing: >72hrs elapsed | Timing: >72hrs elapsed |
| CP013 | PREREQUISITES | prerequisite | seed | Filing: Within 366 days | Filing: Within 366 days |
| CP014 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP015 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP016 | START | customer | chat | Then user selects English |  |
| CP017 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP018 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP019 | START | customer | chat | And the user says "My flight from Montreal to Toronto was cancelled due to a safety regulation issue and I didn't take any replacement fligh | My flight from Montreal to Toronto was cancelled due to a safety regulation issue and I didn't take any replacement flight. Can I get compensation? |
| CP020 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP021 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP022 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP023 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "�mile Gagnon" | �mile Gagnon |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, �mile! And, what is your booking reference number? |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC043" | PNR: TC043 |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC043 |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: e***@gmail.com � Phone: +1***567 |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: e***@gmail.com" | Email: e***@gmail.com |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP037 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP039 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP041 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP043 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � �mile Gagnon (Adult) Is this who you'd like to include? |
| CP044 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP046 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 470 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: May 31, 2026 � Status: CANCELLED Is this the journey you'd like  |
| CP047 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP050 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP051 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure |  |
| CP052 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure was May 31, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP053 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP054 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 31, 2026; filing June 15, 2026 ? 15 days ? within 366 days ? PROCEED |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 470, Route: YUL ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 12:00 | Promised Itinerary - Flight: AC 470, Route: YUL ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 12:00 |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 470, Route: YUL ? YYZ, Status: CANCELLED | Current Itinerary - Flight: AC 470, Route: YUL ? YYZ, Status: CANCELLED |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Customer Status: NO TRAVEL - ORIGIN (customer never departed, declined rebooking) | Customer Status: NO TRAVEL - ORIGIN (customer never departed, declined rebooking) |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | History - No rebooking accepted | History - No rebooking accepted |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 470 � YUL ? YYZ � PERF | MSL FLIGHT: AC 470 � YUL ? YYZ � PERF |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | "Cancellation � safety regulation" | "Cancellation � safety regulation" |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | SAFETY (PERF) | SAFETY (PERF) |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Disruption Type: CANCELLATION | Disruption Type: CANCELLATION |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | DDS Gate 9: Safety ? NOT ELIGIBLE under APPR | DDS Gate 9: Safety ? NOT ELIGIBLE under APPR |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | MR �MILE GAGNON / NOT ELIGIBLE / SAFETY / CAD 0.00 | MR �MILE GAGNON / NOT ELIGIBLE / SAFETY / CAD 0.00 |
| CP069 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP070 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP071 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your flight AC 470 from Montreal (YUL) to Toronto (YYZ) on May 31, 2026 was cancelled. However, you are n |
| CP072 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP073 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP074 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP075 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP076 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to e***@gmail.com |  |
| CP077 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (safety � safety regulation), travel status (No Travel - Origin) |  |
| CP078 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP079 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP080 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "�mile Gagnon" with PNR "TC043" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "�mile Gagnon" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC043" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "�mile Gagnon" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "e***@gmail.com" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***567" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Safety � Code 81" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to Safety Code 81 safety regulation |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "�mile Gagnon + TC043 + YUL?YYZ + FD" |  |
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
| CP134 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to Safety Code 81 |  |
| CP135 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP136 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP138 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP139 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP140 | EXPECTED RESULTS | verdict | api | DDS: FD-APPR-NE-14. | DDS: FD-APPR-NE-14. |
| CP141 | EXPECTED RESULTS | verdict | chat | AC 470 YUL?YYZ CANCELLED. | AC 470 YUL?YYZ CANCELLED. |
| CP142 | EXPECTED RESULTS | verdict | chat | Cancellation code = PERF (Safety). | Cancellation code = PERF (Safety). |
| CP143 | EXPECTED RESULTS | verdict | api | MSL = Leg 1. | MSL = Leg 1. |
| CP144 | EXPECTED RESULTS | verdict | chat | No Travel = TRUE, Status = Origin. | No Travel = TRUE, Status = Origin. |
| CP145 | EXPECTED RESULTS | verdict | api | No Travel Gate: MSL cancelled ? YES ? Check controllability. | No Travel Gate: MSL cancelled ? YES ? Check controllability. |
| CP146 | EXPECTED RESULTS | verdict | chat | Controllability: PERF = Safety (within carrier's control but required for safety) ? No cash compensation. | Controllability: PERF = Safety (within carrier's control but required for safety) ? No cash compensation. |
| CP147 | EXPECTED RESULTS | verdict | chat | Outcome: Expenses + full ticket refund, $0 cash compensation. | Outcome: Expenses + full ticket refund, $0 cash compensation. |
| CP148 | EXPECTED RESULTS | verdict | chat | Fraud: NOT INVOKED. | Fraud: NOT INVOKED. |
| CP149 | EXPECTED RESULTS | verdict | chat | IDV: NOT REQUIRED. | IDV: NOT REQUIRED. |
| CP150 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP151 | EXPECTED RESULTS | verdict | chat | APPR = NE-14 (No Travel Origin + Safety); EU = N/A; ASL = N/A. | APPR = NE-14 (No Travel Origin + Safety); EU = N/A; ASL = N/A. |
