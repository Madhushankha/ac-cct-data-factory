# FD_TC_164 · CHAI-31556 — checkpoints

**Goal:** Israel-destination flight (YYZ?TLV) delayed 4 hours due to severe weather (Code 72). Under ASL, weather is classified as "extraordinary circumstances" � outside airline control. Despite a 4hr delay that would qualify if controllable, the extraordinary classification blocks eligibility. ASL counterpart to APPR TC_066 (NE-28, uncontrollable weather) and EU TC_140 (NE-23, extraordinary weather). Validates that extraordinary classification is consistent across all three regimes.

Methods: seed 10, chat 38, api 14, email 3, dashboard 48, implied 16, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Israel-destination flight (YYZ?TLV) delayed 4 hours due to severe weather (Code 72). Under ASL, weather is classified as "extraordinary circ |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger (Adult) | PNR: single passenger (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 084, YYZ?TLV | Journey: 1 leg AC operated, Flight AC 084, YYZ?TLV |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 16:00 | Scheduled arrival: 16:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival: 20:00 (4hr delay) | Actual arrival: 20:00 (4hr delay) |
| CP006 | PREREQUISITES | prerequisite | seed | Disruption code: 72 (Weather � Severe Thunderstorm) | Disruption code: 72 (Weather � Severe Thunderstorm) |
| CP007 | PREREQUISITES | prerequisite | seed | Arrival code: 72 (available, no fallback) | Arrival code: 72 (available, no fallback) |
| CP008 | PREREQUISITES | prerequisite | seed | ASL classification: Extraordinary Circumstances | ASL classification: Extraordinary Circumstances |
| CP009 | PREREQUISITES | prerequisite | seed | APPR classification: Uncontrollable | APPR classification: Uncontrollable |
| CP010 | PREREQUISITES | prerequisite | seed | Delay: 4hrs (would be eligible if controllable) | Delay: 4hrs (would be eligible if controllable) |
| CP011 | PREREQUISITES | prerequisite | seed | Regime: ASL (TLV destination) + APPR (YYZ origin) | Regime: ASL (TLV destination) + APPR (YYZ origin) |
| CP012 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP013 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP014 | START | customer | chat | Then user selects English |  |
| CP015 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP016 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP017 | START | customer | chat | And the user says "My flight from Toronto to Tel Aviv was delayed about 4 hours due to severe weather. I'd like to check if I'm eligible for | My flight from Toronto to Tel Aviv was delayed about 4 hours due to severe weather. I'd like to check if I'm eligible for compensation |
| CP018 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP019 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP020 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP021 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Adi Carmel" | Adi Carmel |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Adi! And, what is your booking reference number? |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC138" | PNR: TC138 |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC138 |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: a***@gmail.com Phone: +1***345 |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: a***@gmail.com" | Email: a***@gmail.com |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP035 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP037 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Adi Carmel (Adult) Is this who you'd like to include? |
| CP042 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP044 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 085 Route: Toronto (YYZ) ? Tel Aviv Ben Gurion (TLV) Date: June 10, 2026 Arrival Delay: 4 hours Is this the journey yo |
| CP045 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP050 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was June 10, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED |  |
| CP051 | CLAIM TIME LIMIT CHECK | verdict | api | Then the chatbot checks: Filing deadline for ASL = 1,460 days (4 years) from MSL scheduled departure date ? within limitation ? PROCEED |  |
| CP052 | REGIME DETERMINATION | verdict | api | Then the system determines applicable regime: |  |
| CP053 | REGIME DETERMINATION | system | implied | And the system checks: Destination airport = TLV (Tel Aviv, Israel) ? Israel destination |  |
| CP054 | REGIME DETERMINATION | system | implied | And the system determines: ASL (Israel Aviation Services Law) applies (ASL covers flights to/from Israel) |  |
| CP055 | REGIME DETERMINATION | system | implied | And the system checks: Origin = YYZ (Canada) ? APPR also applies |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC138 | Delayed due to severe weather (thunderstorm) |
| CP059 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP060 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your flight AC 085 from Toronto (YYZ) to Tel Aviv Ben Gurion (TLV) on June 10, 2026 was delayed by 4 hour |
| CP061 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP062 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP063 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP064 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP065 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to a***@gmail.com |  |
| CP066 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (AC 085 YYZ?TLV, delayed 4h), not eligible reason (Extraordinary Circumstance � sever |  |
| CP067 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP068 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP069 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Adi Carmel" with PNR "TC138" |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Adi Carmel" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC138" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL (Israel destination � TLV) + APPR" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Adi Carmel" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "a***@gmail.com" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***345" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YYZ ? TLV" with claim filed for this flight as arrived late plus 4h |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Extraordinary Circumstance � severe weat |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Double NE reason should show first Extraordinary Circumstance airline exempt and second 4hrs less than 8hr ASL Travel Completed thre |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And even if controllable 4hrs would still be NE under ASL as below 8hr threshold |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to Extraordinary Circumstance with arrival delay code 72 and weat |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fallback flag should be FALSE as arrival code is available Code 72 |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Sister City flag should be FALSE |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Adi Carmel + TC138 + YYZ?TLV + FD" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe to "a***@gmail.com" containing Case Reference and flight details AC 08 |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP127 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to Extraordinary Circumstance and below 8hr threshold |  |
| CP128 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP131 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP133 | EXPECTED RESULTS | verdict | api | DDS returns FD-ASL-NE-24. | DDS returns FD-ASL-NE-24. |
| CP134 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 16:00; Actual = 20:00; Delay = 4hrs; MSL = Leg 1 (AC 084); Code 72 (Weather); Extraordinary; Fallback = FALSE. | Trip Tracer: Promise = 16:00; Actual = 20:00; Delay = 4hrs; MSL = Leg 1 (AC 084); Code 72 (Weather); Extraordinary; Fallback = FALSE. |
| CP135 | EXPECTED RESULTS | verdict | api | CRITICAL: 4hr delay meets threshold but Code 72 = Extraordinary ? $0. | CRITICAL: 4hr delay meets threshold but Code 72 = Extraordinary ? $0. |
| CP136 | EXPECTED RESULTS | verdict | chat | Weather is outside airline control regardless of delay duration. | Weather is outside airline control regardless of delay duration. |
| CP137 | EXPECTED RESULTS | verdict | chat | Compensation: $0. | Compensation: $0. |
| CP138 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP139 | EXPECTED RESULTS | verdict | api | Regime Assessment: ASL = NE-24 (Extraordinary, Weather, Delay at Arrival); APPR = NE (Uncontrollable); EU = N/A. | Regime Assessment: ASL = NE-24 (Extraordinary, Weather, Delay at Arrival); APPR = NE (Uncontrollable); EU = N/A. |
| CP140 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Travel Completed; Code 72 (Weather, Extraordinary); Delay = 4hrs (would be eligible if controllable); $0; DDS = FD-ASL-NE- | Claims Dashboard: Travel Completed; Code 72 (Weather, Extraordinary); Delay = 4hrs (would be eligible if controllable); $0; DDS = FD-ASL-NE-24. |
