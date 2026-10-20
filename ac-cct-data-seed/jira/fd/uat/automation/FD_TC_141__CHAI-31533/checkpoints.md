# FD_TC_141 · CHAI-31533 — checkpoints

**Goal:** EU Mainland multi-leg journey (CDG?YYZ?YVR). Leg 1 completed on time. Leg 2 (YYZ?YVR) cancelled due to uncontrollable reason (cancellation code WEAT). Customer stranded at YYZ � did not return to CDG, did not reach YVR. Under EU 261, extraordinary circumstances exempt the airline. APPR also assessed but also NE (uncontrollable). Result: NOT ELIGIBLE under all regimes.

Methods: seed 10, chat 41, api 10, email 3, dashboard 45, implied 19, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | EU Mainland multi-leg journey (CDG?YYZ?YVR). Leg 1 completed on time. Leg 2 (YYZ?YVR) cancelled due to uncontrollable reason (cancellation c |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Rapha�l Dufresne (Adult) | PNR: single passenger Rapha�l Dufresne (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 2 legs AC operated: Leg 1 AC 871 CDG?YYZ (on time); Leg 2 AC 121 YYZ?YVR (CANCELLED) | Journey: 2 legs AC operated: Leg 1 AC 871 CDG?YYZ (on time); Leg 2 AC 121 YYZ?YVR (CANCELLED) |
| CP004 | PREREQUISITES | prerequisite | seed | Cancellation code on Leg 2: WEAT (Severe weather � Uncontrollable / Extraordinary) | Cancellation code on Leg 2: WEAT (Severe weather � Uncontrollable / Extraordinary) |
| CP005 | PREREQUISITES | prerequisite | seed | Customer action: Stranded at YYZ | Customer action: Stranded at YYZ |
| CP006 | PREREQUISITES | prerequisite | seed | Did NOT return to CDG | Did NOT return to CDG |
| CP007 | PREREQUISITES | prerequisite | seed | Did NOT reach YVR | Did NOT reach YVR |
| CP008 | PREREQUISITES | prerequisite | seed | No Travel status: Incomplete | No Travel status: Incomplete |
| CP009 | PREREQUISITES | prerequisite | seed | Fallback: FALSE | Fallback: FALSE |
| CP010 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (EU Mainland) + APPR | Regime: EU 261 (EU Mainland) + APPR |
| CP011 | PREREQUISITES | prerequisite | seed | Result: NOT ELIGIBLE under both regimes | Result: NOT ELIGIBLE under both regimes |
| CP012 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP013 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP014 | START | customer | chat | Then user selects English |  |
| CP015 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP016 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP017 | START | customer | chat | And the user says "I flew from Paris to Toronto but my connecting flight from Toronto to Vancouver was cancelled due to severe weather. I'm  | I flew from Paris to Toronto but my connecting flight from Toronto to Vancouver was cancelled due to severe weather. I'm stuck in Toronto � I didn't go back to  |
| CP018 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP019 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP020 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP021 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Rapha�l Dufresne" | Rapha�l Dufresne |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Rapha�l! And, what is your booking reference number? |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC101" | PNR: TC101 |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC101 |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: r***@outlook.com Phone: +33***345 |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: r***@outlook.com" | Email: r***@outlook.com |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP035 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP037 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Rapha�l Dufresne (Adult) Is this who you'd like to include? |
| CP042 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP044 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Segment 1: Flight AC 871, Paris Charles de Gaulle (CDG) ? Toronto (YYZ), May 27, 2026 � COMPLETED Segment 2: Flight AC 121, Toron |
| CP045 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP047 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 CANCELLED |  |
| CP048 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot determines: Claim applies to Segment 2 (AC 121 YYZ?YVR � CANCELLED) |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP050 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP051 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure of Leg 2 |  |
| CP052 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure was May 27, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED |  |
| CP053 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction � CDG origin) = 5 years ? within limitation ? PROCEED |  |
| CP054 | REGIME DETERMINATION | system | implied | Then the system determines: Journey origin = CDG (Paris, EU Mainland) ? EU 261 (EU Mainland) |  |
| CP055 | REGIME DETERMINATION | system | implied | And the system checks: Destination = YVR (Vancouver, Canada) ? APPR also applies |  |
| CP056 | REGIME DETERMINATION | system | implied | And the system checks: Customer stuck at midpoint (YYZ), never reached YVR, did not return to CDG ? No Travel Incomplete |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC101 | Cancellation � severe weather |
| CP060 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP061 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your connecting flight AC 121 from Toronto (YYZ) to Vancouver (YVR) on May 27, 2026 was cancelled. Howeve |
| CP062 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP063 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP064 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP065 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP066 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to r***@outlook.com |  |
| CP067 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (Leg 2: YYZ?YVR CANCELLED), not eligible reason (extraordinary circumstances � severe |  |
| CP068 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP069 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP070 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Rapha�l Dufresne" with PNR "TC101" |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Rapha�l Dufresne" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC101" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (EU Mainland) + APPR" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Rapha�l Dufresne" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "r***@outlook.com" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+33***345" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: CDG ? YYZ" as completed and "Segment 2: YYZ ? YVR" with claim filed for this flight as cancelled |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Extraordinary circumstances � severe wea |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And both regimes should be assessed with EU 261 as NE due to extraordinary and APPR as NE due to uncontrollable |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to extraordinary circumstances with cancellation code WEAT as Unc |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Rapha�l Dufresne + TC101 + CDG?YYZ?YVR + FD" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe to "r***@outlook.com" containing extraordinary circumstances severe we |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP125 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to extraordinary circumstances severe weather |  |
| CP126 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP128 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP129 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP131 | EXPECTED RESULTS | verdict | chat | DS returns FD-EU-NE-11. | DS returns FD-EU-NE-11. |
| CP132 | EXPECTED RESULTS | verdict | api | Trip Tracer: Leg 1 = Completed; Leg 2 = CANCELLED; MSL = Leg 2 (AC 121 YYZ?YVR); Cancellation Code = WEAT (4-char Netline code � Uncontrolla | Trip Tracer: Leg 1 = Completed; Leg 2 = CANCELLED; MSL = Leg 2 (AC 121 YYZ?YVR); Cancellation Code = WEAT (4-char Netline code � Uncontrollable: ; No Travel = I |
| CP133 | EXPECTED RESULTS | verdict | chat | Extraordinary Circumstances: Article 5(3) � airline exempt. | Extraordinary Circumstances: Article 5(3) � airline exempt. |
| CP134 | EXPECTED RESULTS | verdict | api | Regime comparison: EU 261 = NE (extraordinary); APPR = NE (uncontrollable); Both Not Eligible. | Regime comparison: EU 261 = NE (extraordinary); APPR = NE (uncontrollable); Both Not Eligible. |
| CP135 | EXPECTED RESULTS | verdict | chat | Result: NOT ELIGIBLE, �0. | Result: NOT ELIGIBLE, �0. |
| CP136 | EXPECTED RESULTS | verdict | chat | CyberSource: NOT triggered. | CyberSource: NOT triggered. |
| CP137 | EXPECTED RESULTS | verdict | chat | IDV: NOT required. | IDV: NOT required. |
| CP138 | EXPECTED RESULTS | verdict | chat | Payment: NONE. | Payment: NONE. |
| CP139 | EXPECTED RESULTS | verdict | api | Claims Dashboard: EU Mainland NE-11; NOT ELIGIBLE; Extraordinary Circumstances (WEAT); No Travel = Incomplete; Stranded = YYZ; Multi-leg (CD | Claims Dashboard: EU Mainland NE-11; NOT ELIGIBLE; Extraordinary Circumstances (WEAT); No Travel = Incomplete; Stranded = YYZ; Multi-leg (CDG?YYZ?YVR); Both reg |
