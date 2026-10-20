# FD_TC_165 · CHAI-31557 — checkpoints

**Goal:** Israel-route multi-leg journey where the MSL (most significant leg with the disruption) is operated by a NON-Star Alliance OAL. AC does not have data-sharing agreements with non-Star carriers, so disruption codes and operating times are unavailable. DDS cannot determine eligibility because the disrupted leg's data is inaccessible. Customer is redirected to the OAL. Different from ND-02 (Star Alliance partner, where StarQuest process applies) � non-Star OALs have no AC data pathway at all.

Methods: seed 6, chat 40, api 14, dashboard 41, implied 12, manual 9, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Israel-route multi-leg journey where the MSL (most significant leg with the disruption) is operated by a NON-Star Alliance OAL. AC does not  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger | PNR: Single passenger |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: Multi-leg, Israel origin | Journey: Multi-leg, Israel origin |
| CP004 | PREREQUISITES | prerequisite | seed | MSL: On OAL leg (non-Star Alliance carrier) | MSL: On OAL leg (non-Star Alliance carrier) |
| CP005 | PREREQUISITES | prerequisite | seed | AC leg: Completed on time | AC leg: Completed on time |
| CP006 | PREREQUISITES | prerequisite | seed | OAL leg: Disrupted � data NOT available to AC (no data-sharing agreement with non-Star carrier) | OAL leg: Disrupted � data NOT available to AC (no data-sharing agreement with non-Star carrier) |
| CP007 | PREREQUISITES | prerequisite | seed | Regime: ASL applicable (Israel route) | Regime: ASL applicable (Israel route) |
| CP008 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP009 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP010 | START | customer | chat | Then user selects English |  |
| CP011 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP012 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP013 | START | customer | chat | And the user says "I flew from Tel Aviv to Toronto on Air Canada and then from Toronto to Vancouver on WestJet. The WestJet flight was delay | I flew from Tel Aviv to Toronto on Air Canada and then from Toronto to Vancouver on WestJet. The WestJet flight was delayed 5 hours. Can I get compensation? |
| CP014 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP015 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP016 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP017 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP018 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP020 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Boaz Kimchi" | Boaz Kimchi |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Boaz! And, what is your booking reference number? |
| CP022 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC139" | PNR: TC139 |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC139 |  |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: b***@gmail.com � Phone: +972***456 |
| CP028 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: b***@gmail.com" | Email: b***@gmail.com |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP030 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP031 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP033 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP034 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP035 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP036 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP037 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Boaz Kimchi (Adult) Is this who you'd like to include? |
| CP038 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP039 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP040 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Segment 1: Flight AC 084, Tel Aviv Ben Gurion (TLV) ? Toronto (YYZ), June 11, 2026 � COMPLETED (AC operated) � Segment 2: Fligh |
| CP041 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP043 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED (AC), Segment 2 DELAYED (WestJet � non-Star Alliance OAL) |  |
| CP044 | SEGMENT CHECK (GenUC-18) | verdict | api | Then the chatbot determines: MSL = Segment 2 (WS 3421 � the disrupted leg) |  |
| CP045 | MSL CHECK � NON-STAR ALLIANCE OAL | verdict | api | Then the system checks MSL for operating carrier on the disrupted leg |  |
| CP046 | MSL CHECK � NON-STAR ALLIANCE OAL | verdict | api | And MSL returns: Segment 2 operated by WestJet (WS) ? Non-Star Alliance OAL |  |
| CP047 | MSL CHECK � NON-STAR ALLIANCE OAL | system | implied | And the system checks: Is WestJet a Star Alliance partner? ? NO |  |
| CP048 | MSL CHECK � NON-STAR ALLIANCE OAL | verdict | api | And the system determines: MSL on non-Star Alliance OAL ? SYSTEM POLLS FOR OAL DATA ? IF UNAVAILABLE AFTER 14 DAYS ? MANUAL HANDLING |  |
| CP049 | NON-STAR ALLIANCE OAL RESULT | bot | chat | Then the chatbot displays: | I've reviewed your flight details and noticed that the disrupted flight was operated by another airline. To complete this claim, I can forward your details to a |
| CP050 | NON-STAR ALLIANCE OAL RESULT | customer | chat | And the user selects "Yes" | Yes |
| CP051 | CASE CREATION | system | implied | Then the system creates a case for manual agent handling |  |
| CP052 | CASE CREATION | system | implied | And the case is placed in the System Processing Queue |  |
| CP053 | CASE CREATION | system | implied | And the system begins polling for WestJet disruption data (daily for up to 14 days) |  |
| CP054 | CASE CREATION | verdict | api | And the case contains: PNR TC139, passenger details, journey details, MSL on WestJet WS 3421, delay 5h, non-Star Alliance OAL flag, ASL regi |  |
| CP055 | CASE CREATION | bot | chat | Then the chatbot responds: | Thank you. Your claim has been forwarded to our team for review. You will receive an update via email once the review is complete. Please allow additional proce |
| CP056 | CASE CREATION | alert | chat | And an alert information is displayed: "Claim forwarded for review!" | Claim forwarded for review! |
| CP057 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP058 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP059 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP060 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Boaz Kimchi" with PNR "TC139" |  |
| CP061 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP062 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP063 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Pending Agent Review" placed in System Processing Queue with polls for OAL data up to 14 days and escalation  |  |
| CP064 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP065 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "System Processing Queue" initially transitioning to "Manual Review Agent Queue" after 14-day exhaustion i |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should be greyed out or not applicable as it is pending OAL data polling or manual handling |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Boaz Kimchi" |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC139" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL (Israel origin � TLV)" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Boaz Kimchi" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "b***@gmail.com" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+972***456" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: TLV ? YYZ" as completed and AC operated and "Segment 2: YYZ ? YVR" delayed plus 5h and WestJet WS 34 |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the MSL should be Segment 2 WestJet as non-Star Alliance |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And this should differ from TC140 where Star Alliance results in immediate StarQuest routing whereas here non-Star OAL means system polls fo |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "MSL on non-Star Alliance OAL; system |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should NOT have been auto-evaluated as it was skipped due to non-Star Alliance OAL requiring polling before as |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should NOT have run automatically |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the status should be "Pending � OAL Data Polling" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Boaz Kimchi + TC139 + TLV?YVR + FD" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it is No Determination pending data or review |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should be placed in System Processing Queue polling for OAL data |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if data is unavailable after 14 days the case should be escalated to Manual Review Agent Queue |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case forwarded notification should have been sent |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an email should have been sent to "b***@gmail.com" containing Case Reference and flight details Leg 2 WS 3421 YYZ to YVR delayed 5h and  |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record case creation and System Processing Queue placement and OAL polling status |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the forwarded notification |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Current Status should be "Pending Agent Review" in System Processing Queue polling |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should NOT be in read-only mode as the agent can update after manual review |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP108 | PAYMENT VALIDATION | payment | chat | Given no determination was made due to OAL data polling for non-Star Alliance partner |  |
| CP109 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP110 | PAYMENT VALIDATION | payment | chat | And the case was created and sent to agent for manual handling |  |
| CP111 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP112 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP113 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP114 | PAYMENT VALIDATION | payment | manual | And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e- |  |
| CP115 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved |  |
| CP116 | EXPECTED RESULTS | verdict | api | DDS returns FD-ASL-ND-01. | DDS returns FD-ASL-ND-01. |
| CP117 | EXPECTED RESULTS | verdict | api | Trip Tracer: AC leg = Completed; OAL leg = Disrupted; MSL = OAL leg (non-Star Alliance); OAL disruption data = NOT AVAILABLE (no data-sharin | Trip Tracer: AC leg = Completed; OAL leg = Disrupted; MSL = OAL leg (non-Star Alliance); OAL disruption data = NOT AVAILABLE (no data-sharing agreement). |
| CP118 | EXPECTED RESULTS | verdict | api | No Determination: Cannot assess eligibility � MSL is on a carrier AC has no data access to. | No Determination: Cannot assess eligibility � MSL is on a carrier AC has no data access to. |
| CP119 | EXPECTED RESULTS | verdict | chat | Customer Redirect: Directed to contact the operating OAL directly for their disruption claim. | Customer Redirect: Directed to contact the operating OAL directly for their disruption claim. |
| CP120 | EXPECTED RESULTS | verdict | chat | Compensation: NOT CALCULATED. | Compensation: NOT CALCULATED. |
| CP121 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP122 | EXPECTED RESULTS | verdict | api | Regime Assessment: ASL = ND-01 (OAL, non-Star, redirect); APPR = ND (same gap). | Regime Assessment: ASL = ND-01 (OAL, non-Star, redirect); APPR = ND (same gap). |
| CP123 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Status = No Determination; Reason = MSL on non-Star OAL (data unavailable); Redirect = OAL; DDS = FD-ASL-ND-01. | Claims Dashboard: Status = No Determination; Reason = MSL on non-Star OAL (data unavailable); Redirect = OAL; DDS = FD-ASL-ND-01. |
