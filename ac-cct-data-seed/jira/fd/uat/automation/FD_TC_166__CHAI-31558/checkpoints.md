# FD_TC_166 · CHAI-31558 — checkpoints

**Goal:** Israel-route multi-leg journey where the MSL is operated by a STAR ALLIANCE partner. Unlike non-Star OALs (TC_182), Star Alliance partners have the StarQuest process � a formal inter-airline data request mechanism. AC initiates StarQuest to obtain disruption data from the Star partner. Case is held pending StarQuest response. Different from ND-01 (non-Star, simple redirect) � here AC actively pursues the data through the alliance framework.

Methods: seed 6, chat 42, api 13, dashboard 40, implied 11, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Israel-route multi-leg journey where the MSL is operated by a STAR ALLIANCE partner. Unlike non-Star OALs (TC_182), Star Alliance partners h |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger | PNR: Single passenger |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: Multi-leg, Israel origin | Journey: Multi-leg, Israel origin |
| CP004 | PREREQUISITES | prerequisite | seed | MSL: On Star Alliance partner leg | MSL: On Star Alliance partner leg |
| CP005 | PREREQUISITES | prerequisite | seed | AC leg: Completed on time | AC leg: Completed on time |
| CP006 | PREREQUISITES | prerequisite | seed | Star partner leg: Disrupted � data requested via StarQuest | Star partner leg: Disrupted � data requested via StarQuest |
| CP007 | PREREQUISITES | prerequisite | seed | Regime: ASL applicable (Israel route) | Regime: ASL applicable (Israel route) |
| CP008 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP009 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP010 | START | customer | chat | Then user selects English |  |
| CP011 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP012 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP013 | START | customer | chat | And the user says "I flew from Tel Aviv to Frankfurt on Air Canada and then from Frankfurt to Toronto on Lufthansa. The Lufthansa flight was | I flew from Tel Aviv to Frankfurt on Air Canada and then from Frankfurt to Toronto on Lufthansa. The Lufthansa flight was delayed 5 hours. Can I get compensatio |
| CP014 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP015 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP016 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP017 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP018 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP020 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Ziv Harari" | Ziv Harari |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Ziv! And, what is your booking reference number? |
| CP022 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC140" | PNR: TC140 |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC140 |  |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: z***@outlook.com � Phone: +972***567 |
| CP028 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: z***@outlook.com" | Email: z***@outlook.com |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP030 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP031 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP033 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP034 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP035 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP036 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP037 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Ziv Harari (Adult) Is this who you'd like to include? |
| CP038 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP039 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP040 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Segment 1: Flight AC 084, Tel Aviv Ben Gurion (TLV) ? Frankfurt (FRA), June 12, 2026 � COMPLETED (AC operated) � Segment 2: Fli |
| CP041 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP043 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED (AC), Segment 2 DELAYED (Lufthansa � Star Alliance) |  |
| CP044 | SEGMENT CHECK (GenUC-18) | verdict | api | Then the chatbot determines: MSL = Segment 2 (LH 471 � the disrupted leg) |  |
| CP045 | MSL CHECK � STAR ALLIANCE PARTNER | verdict | api | Then the system checks MSL for operating carrier on the disrupted leg |  |
| CP046 | MSL CHECK � STAR ALLIANCE PARTNER | verdict | api | And MSL returns: Segment 2 operated by Lufthansa (LH) ? Star Alliance partner |  |
| CP047 | MSL CHECK � STAR ALLIANCE PARTNER | system | implied | And the system checks: Is Lufthansa a Star Alliance partner? ? YES |  |
| CP048 | MSL CHECK � STAR ALLIANCE PARTNER | verdict | api | And the system determines: MSL on Star Alliance partner ? STARQUEST CASE ? IMMEDIATE MANUAL HANDLING |  |
| CP049 | STAR ALLIANCE PARTNER RESULT | bot | chat | Then the chatbot displays: | I've reviewed your flight details and noticed that this trip was operated by our Star Alliance partner. To complete this claim, I can forward your details to an |
| CP050 | STAR ALLIANCE PARTNER RESULT | customer | chat | And the user selects "Yes" | Yes |
| CP051 | STARQUEST CASE CREATION | system | implied | Then the system creates a StarQuest case for immediate manual agent handling |  |
| CP052 | STARQUEST CASE CREATION | system | implied | And the case is routed to the StarQuest team |  |
| CP053 | STARQUEST CASE CREATION | verdict | api | And the case contains: PNR TC140, passenger details, journey details, MSL on Lufthansa LH 471, delay 5h, Star Alliance partner flag, ASL reg |  |
| CP054 | STARQUEST CASE CREATION | bot | chat | Then the chatbot responds: | Thank you. Your claim has been forwarded to our team for review. You will receive an update via email once the review is complete. Please allow additional proce |
| CP055 | STARQUEST CASE CREATION | alert | chat | And an alert information is displayed: "Claim forwarded for review!" | Claim forwarded for review! |
| CP056 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP057 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP058 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP059 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Ziv Harari" with PNR "TC140" |  |
| CP060 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP061 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP062 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Pending Agent Review (StarQuest)" |  |
| CP063 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP064 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP065 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "StarQuest Team" |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should be greyed out or not applicable as manual handling is required |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Ziv Harari" |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC140" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL (Israel origin � TLV)" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Ziv Harari" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "z***@outlook.com" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+972***567" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: TLV ? FRA" as completed and AC operated and "Segment 2: FRA ? YYZ" delayed plus 5h and Lufthansa LH  |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the MSL should be Segment 2 Lufthansa as Star Alliance partner |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Star Alliance partner should result in immediate StarQuest routing with no 14-day polling delay |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "StarQuest � MSL on Star Alliance par |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should NOT have been auto-evaluated as it was skipped due to Star Alliance partner requiring immediate manual  |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should NOT have run automatically |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the status should be "Pending StarQuest Review" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Ziv Harari + TC140 + TLV?YYZ + FD" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it is No Determination pending manual review |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should be routed to StarQuest team queue immediately with no 14-day polling |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the StarQuest agent should pull the case for manual review |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case forwarded notification should have been sent |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an email should have been sent to "z***@outlook.com" containing Case Reference and flight details Leg 2 LH 471 FRA to YYZ delayed 5h and |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record case creation and StarQuest routing |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the forwarded notification |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Current Status should be "Pending Agent Review (StarQuest)" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should NOT be in read-only mode as the agent can update after manual review |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP107 | PAYMENT VALIDATION | payment | chat | Given no determination was made due to Star Alliance partner operated segment |  |
| CP108 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP109 | PAYMENT VALIDATION | payment | chat | And the case was created and sent to agent for manual handling |  |
| CP110 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP111 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP112 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP113 | PAYMENT VALIDATION | payment | manual | And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e- |  |
| CP114 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved |  |
| CP115 | EXPECTED RESULTS | verdict | api | DDS returns FD-ASL-ND-02. | DDS returns FD-ASL-ND-02. |
| CP116 | EXPECTED RESULTS | verdict | api | Trip Tracer: AC leg = Completed; Star partner leg = Disrupted; MSL = Star Alliance partner leg; Disruption data = NOT YET AVAILABLE (StarQue | Trip Tracer: AC leg = Completed; Star partner leg = Disrupted; MSL = Star Alliance partner leg; Disruption data = NOT YET AVAILABLE (StarQuest initiated). |
| CP117 | EXPECTED RESULTS | verdict | chat | No Determination: Cannot assess eligibility until StarQuest response received. | No Determination: Cannot assess eligibility until StarQuest response received. |
| CP118 | EXPECTED RESULTS | verdict | chat | StarQuest Process: AC initiates formal data request to Star Alliance partner for disruption codes and operating times. | StarQuest Process: AC initiates formal data request to Star Alliance partner for disruption codes and operating times. |
| CP119 | EXPECTED RESULTS | verdict | chat | Case held pending response. | Case held pending response. |
| CP120 | EXPECTED RESULTS | verdict | chat | Compensation: NOT CALCULATED (pending StarQuest). | Compensation: NOT CALCULATED (pending StarQuest). |
| CP121 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP122 | EXPECTED RESULTS | verdict | api | Regime Assessment: ASL = ND-02 (Star Alliance, StarQuest pending). | Regime Assessment: ASL = ND-02 (Star Alliance, StarQuest pending). |
| CP123 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Status = No Determination; Reason = MSL on Star partner (StarQuest initiated); Agent Action = "Monitor StarQuest response; | Claims Dashboard: Status = No Determination; Reason = MSL on Star partner (StarQuest initiated); Agent Action = "Monitor StarQuest response; re-run DDS when dat |
