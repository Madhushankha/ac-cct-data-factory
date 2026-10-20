# FD_TC_159 · CHAI-31551 — checkpoints

**Goal:** Two-leg journey to Israel (YYZ?FRA?TLV). Leg 1 completed on time. Leg 2 (FRA?TLV) cancelled due to extraordinary circumstance (cancellation code WEAT). Customer stranded at FRA (midpoint) � did not return to YYZ, did not reach TLV. Under ASL, extraordinary circumstance = airline exempt.

Methods: seed 11, chat 37, api 23, email 3, dashboard 21, implied 19, manual 5, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Two-leg journey to Israel (YYZ?FRA?TLV). Leg 1 completed on time. Leg 2 (FRA?TLV) cancelled due to extraordinary circumstance (cancellation  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Talia Friedman (Adult) | PNR: single passenger Talia Friedman (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 2 legs: Leg 1 AC 873 YYZ?FRA (on time); Leg 2 AC 9042 FRA?TLV (CANCELLED) | Journey: 2 legs: Leg 1 AC 873 YYZ?FRA (on time); Leg 2 AC 9042 FRA?TLV (CANCELLED) |
| CP004 | PREREQUISITES | prerequisite | seed | Cancellation code on Leg 2: WEAT (Severe weather � Extraordinary Circumstance) | Cancellation code on Leg 2: WEAT (Severe weather � Extraordinary Circumstance) |
| CP005 | PREREQUISITES | prerequisite | seed | Customer action: Stranded at FRA (midpoint) | Customer action: Stranded at FRA (midpoint) |
| CP006 | PREREQUISITES | prerequisite | seed | Did NOT return to YYZ | Did NOT return to YYZ |
| CP007 | PREREQUISITES | prerequisite | seed | Did NOT reach TLV | Did NOT reach TLV |
| CP008 | PREREQUISITES | prerequisite | seed | No Travel status: Incomplete | No Travel status: Incomplete |
| CP009 | PREREQUISITES | prerequisite | seed | Fallback: FALSE | Fallback: FALSE |
| CP010 | PREREQUISITES | prerequisite | seed | MSL: Leg 2 (FRA?TLV) | MSL: Leg 2 (FRA?TLV) |
| CP011 | PREREQUISITES | prerequisite | seed | Regime: ASL (Israel destination) + APPR (Canadian origin) + potentially EU 261 (FRA = EU) | Regime: ASL (Israel destination) + APPR (Canadian origin) + potentially EU 261 (FRA = EU) |
| CP012 | PREREQUISITES | prerequisite | seed | Result: NOT ELIGIBLE under all regimes | Result: NOT ELIGIBLE under all regimes |
| CP013 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP014 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP015 | START | customer | chat | Then user selects English |  |
| CP016 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP017 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP018 | START | customer | chat | And the user says "I flew from Toronto to Frankfurt but my connecting flight from Frankfurt to Tel Aviv was cancelled due to severe weather. | I flew from Toronto to Frankfurt but my connecting flight from Frankfurt to Tel Aviv was cancelled due to severe weather. I'm stuck in Frankfurt � I didn't go b |
| CP019 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP020 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP021 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP022 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Talia Friedman" | Talia Friedman |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Talia! And, what is your booking reference number? |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC127" | PNR: TC127 |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC127 |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@outlook.com � Phone: +1***123 |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@outlook.com" | Email: t***@outlook.com |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP036 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP038 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Talia Friedman (Adult) Is this who you'd like to include? |
| CP043 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP045 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Segment 1: Flight AC 873, Toronto (YYZ) ? Frankfurt (FRA), May 29, 2026 � COMPLETED � Segment 2: Flight AC 9042, Frankfurt (FRA |
| CP046 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP047 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP048 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 CANCELLED |  |
| CP049 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot determines: Claim applies to Segment 2 (AC 9042 FRA?TLV � CANCELLED) |  |
| CP050 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP052 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure of Leg 2 |  |
| CP053 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure was May 29, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP054 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for ASL (Israel) = 7 years ? within limitation ? PROCEED |  |
| CP055 | REGIME DETERMINATION | verdict | api | Then the system determines applicable regime: |  |
| CP056 | REGIME DETERMINATION | system | implied | And the system checks: Origin airport = YYZ (Toronto, Canada) ? NOT Israel origin |  |
| CP057 | REGIME DETERMINATION | system | implied | And the system checks: Destination airport = TLV (Tel Aviv, Israel) ? Israel destination |  |
| CP058 | REGIME DETERMINATION | system | implied | And the system determines: ASL (Israel Aviation Services Law) applies |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Segment 1: Flight: AC 873, Route: YYZ ? FRA, Status: COMPLETED (on time) | Segment 1: Flight: AC 873, Route: YYZ ? FRA, Status: COMPLETED (on time) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Segment 2: Flight: AC 9042, Route: FRA ? TLV, Status: CANCELLED (claim filed) | Segment 2: Flight: AC 9042, Route: FRA ? TLV, Status: CANCELLED (claim filed) |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Customer Status: NO TRAVEL - INCOMPLETE (stranded at FRA � did not return to YYZ, did not reach TLV) | Customer Status: NO TRAVEL - INCOMPLETE (stranded at FRA � did not return to YYZ, did not reach TLV) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | History - Customer stranded at mid-point FRA; no rebooking accepted; no return to origin | History - Customer stranded at mid-point FRA; no rebooking accepted; no return to origin |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Regime: ASL (Israel) (Israel destination � TLV) | Regime: ASL (Israel) (Israel destination � TLV) |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Destination: TLV (Israel) | Destination: TLV (Israel) |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 9042 � FRA ? TLV � WEAT | MSL FLIGHT: AC 9042 � FRA ? TLV � WEAT |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | "Cancellation � severe weather" | "Cancellation � severe weather" |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | EXTRAORDINARY CIRCUMSTANCES (WEAT) | EXTRAORDINARY CIRCUMSTANCES (WEAT) |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Disruption Type: CANCELLATION (Leg 2, mid-journey) | Disruption Type: CANCELLATION (Leg 2, mid-journey) |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | ASL: Extraordinary circumstances ? NOT ELIGIBLE | ASL: Extraordinary circumstances ? NOT ELIGIBLE |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | MS TALIA FRIEDMAN / NOT ELIGIBLE / EXTRAORDINARY_CIRCUMSTANCES / 0.00 | MS TALIA FRIEDMAN / NOT ELIGIBLE / EXTRAORDINARY_CIRCUMSTANCES / 0.00 |
| CP074 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP075 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your connecting flight AC 9042 from Frankfurt (FRA) to Tel Aviv Ben Gurion (TLV) on May 29, 2026 was canc |
| CP076 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP077 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP078 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP079 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP080 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to t***@outlook.com |  |
| CP081 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (Leg 2: FRA?TLV CANCELLED), not eligible reason (extraordinary circumstances � severe |  |
| CP082 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP083 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP084 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Talia Friedman" with PNR "TC127" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Talia Friedman" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC127" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL (Israel destination � TLV) + APPR" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Talia Friedman" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "t***@outlook.com" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***123" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: YYZ ? FRA" as completed and "Segment 2: FRA ? TLV" as cancelled with claim filed |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Extraordinary Circumstance � WEAT � Leg  |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to Extraordinary Circumstance with WEAT and Leg 2 FRA to TLV and  |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically and the result should be "No duplicate found" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent to "t***@outlook.com" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP110 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to Extraordinary Circumstance severe weather on Leg 2 |  |
| CP111 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP112 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP113 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP114 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP115 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP116 | EXPECTED RESULTS | verdict | api | DDS returns FD-ASL-NE-12. | DDS returns FD-ASL-NE-12. |
| CP117 | EXPECTED RESULTS | verdict | api | Trip Tracer: Leg 1 = Completed; Leg 2 = CANCELLED; MSL = Leg 2 (AC 9042 FRA?TLV); Cancellation Code = WEAT (Extraordinary Circumstance); No  | Trip Tracer: Leg 1 = Completed; Leg 2 = CANCELLED; MSL = Leg 2 (AC 9042 FRA?TLV); Cancellation Code = WEAT (Extraordinary Circumstance); No Travel = Incomplete  |
| CP118 | EXPECTED RESULTS | verdict | chat | CRITICAL: Potentially all three regimes (ASL + APPR + EU 261) � ALL NE (Extraordinary/Uncontrollable). | CRITICAL: Potentially all three regimes (ASL + APPR + EU 261) � ALL NE (Extraordinary/Uncontrollable). |
| CP119 | EXPECTED RESULTS | verdict | chat | Result: NOT ELIGIBLE, ILS 0. | Result: NOT ELIGIBLE, ILS 0. |
| CP120 | EXPECTED RESULTS | verdict | api | DDS = FD-ASL-NE-12. | DDS = FD-ASL-NE-12. |
