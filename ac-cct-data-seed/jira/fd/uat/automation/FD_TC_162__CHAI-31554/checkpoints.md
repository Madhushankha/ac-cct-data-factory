# FD_TC_162 · CHAI-31554 — checkpoints

**Goal:** Flight TLV?YYZ (Tel Aviv to Toronto) � delayed 4 hours, controllable (arrival delay code 66). This TC validates the ASL "end in Israel" component check � which FAILS because destination is YYZ (Canada), not Israel. IMPORTANT NOTE: ASL applies to flights to AND from Israel. Since this itinerary STARTS in Israel (TLV), ASL still applies via the "start in Israel" path. NE-21 fires specifically for the "end in Israel" check failure as a component code. Additionally, even if ASL applies via the origin path, the 4hr delay is below the 8-hour ASL Travel Completed threshold (Gate 8), so the result would still be NE under ASL.

Methods: seed 10, chat 42, api 12, email 3, dashboard 43, implied 18, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Flight TLV?YYZ (Tel Aviv to Toronto) � delayed 4 hours, controllable (arrival delay code 66). This TC validates the ASL "end in Israel" comp |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Maya Stein (Adult) | PNR: single passenger Maya Stein (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 084, TLV?YYZ | Journey: 1 leg AC operated, Flight AC 084, TLV?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Flight status: ARRIVED LATE | Flight status: ARRIVED LATE |
| CP005 | PREREQUISITES | prerequisite | seed | Arrival delay code: 66 (Not Extraordinary Circumstance � controllable) | Arrival delay code: 66 (Not Extraordinary Circumstance � controllable) |
| CP006 | PREREQUISITES | prerequisite | seed | Delay: 4 hours | Delay: 4 hours |
| CP007 | PREREQUISITES | prerequisite | seed | Origin: TLV (Tel Aviv, Israel) ? "start in Israel" check PASSES ? ASL applies via origin | Origin: TLV (Tel Aviv, Israel) ? "start in Israel" check PASSES ? ASL applies via origin |
| CP008 | PREREQUISITES | prerequisite | seed | Destination: YYZ (Toronto, Canada) ? NOT Israel destination ? "end in Israel" check FAILS | Destination: YYZ (Toronto, Canada) ? NOT Israel destination ? "end in Israel" check FAILS |
| CP009 | PREREQUISITES | prerequisite | seed | ASL Travel Completed threshold: 8 hours ? 4hrs < 8hrs ? below threshold | ASL Travel Completed threshold: 8 hours ? 4hrs < 8hrs ? below threshold |
| CP010 | PREREQUISITES | prerequisite | seed | Regime: ASL (via origin) + APPR (Canadian destination) | Regime: ASL (via origin) + APPR (Canadian destination) |
| CP011 | PREREQUISITES | prerequisite | seed | Result: NOT ELIGIBLE under ASL "end in Israel" check (NE-21 component); also NE under ASL overall (4hrs < 8hr Travel Completed threshold) | Result: NOT ELIGIBLE under ASL "end in Israel" check (NE-21 component); also NE under ASL overall (4hrs < 8hr Travel Completed threshold) |
| CP012 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP013 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP014 | START | customer | chat | Then user selects English |  |
| CP015 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP016 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP017 | START | customer | chat | And the user says "My flight from Tel Aviv to Toronto was delayed about 4 hours due to a crew issue. I'd like to check if I'm eligible for c | My flight from Tel Aviv to Toronto was delayed about 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation under Israeli regulations |
| CP018 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP019 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP020 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP021 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Maya Stein" | Maya Stein |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Maya! And, what is your booking reference number? |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC135" | PNR: TC135 |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC135 |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: m***@gmail.com Phone: +972***012 |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: m***@gmail.com" | Email: m***@gmail.com |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP035 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP037 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Maya Stein (Adult) Is this who you'd like to include? |
| CP042 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP044 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 084 Route: Tel Aviv Ben Gurion (TLV) ? Toronto (YYZ) Date: June 7, 2026 Arrival Delay: 4 hours Is this the journey you |
| CP045 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP050 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was June 7, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED |  |
| CP051 | CLAIM TIME LIMIT CHECK | verdict | api | Then the chatbot checks: Filing deadline for ASL = 1,460 days (4 years) from MSL scheduled departure date ? within limitation ? PROCEED |  |
| CP052 | REGIME DETERMINATION � ASL ROUTE CHECK | verdict | api | Then the system determines applicable regime: |  |
| CP053 | REGIME DETERMINATION � ASL ROUTE CHECK | system | implied | And the system checks: Origin airport = TLV (Tel Aviv, Israel) ? Israel origin ? "start in Israel" check PASSES |  |
| CP054 | REGIME DETERMINATION � ASL ROUTE CHECK | system | implied | And the system checks: Destination airport = YYZ (Toronto, Canada) ? NOT Israel destination |  |
| CP055 | REGIME DETERMINATION � ASL ROUTE CHECK | system | implied | And the system checks: Did itinerary END in Israel? ? NO (ended in Canada) ? NE-21 fires for this component check |  |
| CP056 | REGIME DETERMINATION � ASL ROUTE CHECK | system | implied | And the system notes: ASL "start in Israel" check passes (origin = TLV) � ASL applies via origin path |  |
| CP057 | REGIME DETERMINATION � ASL ROUTE CHECK | system | implied | And the system checks: ASL Travel Completed threshold = 8 hours ? 4hrs < 8hrs ? below threshold ? NOT ELIGIBLE regardless |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC135 | start in Israel end in Israel Start in Israel End in Israel end in Israel start in Israel |
| CP061 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP062 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your flight AC 084 from Tel Aviv Ben Gurion (TLV) to Toronto (YYZ) was delayed by 4 hours. However, the I |
| CP063 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP064 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP065 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP066 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP067 | NOTIFICATION | email | email | And a notification email is sent to m***@gmail.com |  |
| CP068 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (TLV?YYZ, delayed 4h), not eligible reason under ASL "end in Israel" check (itinerary | end in Israel |
| CP069 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP070 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP071 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Maya Stein" with PNR "TC135" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Maya Stein" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC135" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL (Israel)" with start in Israel passing via origin TLV and end in Israel failing with destination YYZ and below |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Maya Stein" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "m***@gmail.com" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+972***012" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: TLV ? YYZ" with claim filed for this flight as arrived late plus 4h |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "ASL end in Israel check fails � NE-21 co |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to ASL end in Israel criterion not met NE-21 and also below 8hr T |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Maya Stein + TC135 + TLV?YYZ + FD" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a notification email should have been sent to "m***@gmail.com" containing Case Reference and flight details TLV to YYZ delayed 4h and no |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP124 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to ASL end in Israel check failing |  |
| CP125 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP126 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP128 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP130 | EXPECTED RESULTS | verdict | api | DDS returns FD-ASL-NE-21. | DDS returns FD-ASL-NE-21. |
| CP131 | EXPECTED RESULTS | verdict | api | Trip Tracer: Flight operated; Arrival delay = 4hrs; Arrival Delay Code 66 (numeric � Not Extraordinary Circumstance / Controllable); Origin  | Trip Tracer: Flight operated; Arrival delay = 4hrs; Arrival Delay Code 66 (numeric � Not Extraordinary Circumstance / Controllable); Origin TLV (Israel) ? "Star |
| CP132 | EXPECTED RESULTS | verdict | chat | ASL applies via origin path ("start in Israel" PASSES), BUT: ASL Travel Completed threshold = 8 hours (NOT 3 hours � 3hr is for No Travel on | ASL applies via origin path ("start in Israel" PASSES), BUT: ASL Travel Completed threshold = 8 hours (NOT 3 hours � 3hr is for No Travel only) ? 4hrs < 8hrs ?  |
| CP133 | EXPECTED RESULTS | verdict | chat | NE-21 is a COMPONENT check for the "end in Israel" path. | NE-21 is a COMPONENT check for the "end in Israel" path. |
| CP134 | EXPECTED RESULTS | verdict | chat | APPR may still apply (arriving in Canada, controllable, 4hr delay) � assessed separately and may yield eligible result under APPR. | APPR may still apply (arriving in Canada, controllable, 4hr delay) � assessed separately and may yield eligible result under APPR. |
| CP135 | EXPECTED RESULTS | verdict | chat | Result: NOT ELIGIBLE under ASL, ILS 0. | Result: NOT ELIGIBLE under ASL, ILS 0. |
| CP136 | EXPECTED RESULTS | verdict | chat | CyberSource: NOT triggered. | CyberSource: NOT triggered. |
| CP137 | EXPECTED RESULTS | verdict | chat | IDV: NOT required. | IDV: NOT required. |
| CP138 | EXPECTED RESULTS | verdict | chat | Payment: NONE. | Payment: NONE. |
| CP139 | EXPECTED RESULTS | verdict | api | DDS = FD-ASL-NE-21. | DDS = FD-ASL-NE-21. |
