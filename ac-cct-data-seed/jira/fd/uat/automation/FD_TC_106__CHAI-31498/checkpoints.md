# FD_TC_106 · CHAI-31498 — checkpoints

**Goal:** Customer attempts to file a compensation claim BEFORE their flight has occurred. The flight date is in the future � the flight has not departed, not arrived, and no disruption has actually happened yet. System must reject the claim at the FLIGHT DATE CHECK stage, before DDS is ever invoked. Per business rules, DDS can only run 72 hours POST-ARRIVAL to allow flight data finalization. Validates: (1) System checks flight date against current date, (2) Future flights are rejected with a clear explanation, (3) NO case is created (not even a shell case � there's nothing to track for a flight that hasn't happened), (4) DDS is NOT invoked at all, (5) Customer is told to return 72hrs after arrival. This is the earliest possible rejection point in the entire flow.

Methods: seed 7, chat 43, api 6, dashboard 6, implied 9, manual 2, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer attempts to file a compensation claim BEFORE their flight has occurred. The flight date is in the future � the flight has not depar |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC058 � single passenger (Adult) | PNR: TC058 � single passenger (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 427, YUL?YYZ | Journey: 1 leg AC operated, Flight AC 427, YUL?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Flight date: May 22, 2026 (FUTURE � flight has not occurred) | Flight date: May 22, 2026 (FUTURE � flight has not occurred) |
| CP005 | PREREQUISITES | prerequisite | seed | Current date: May 20, 2026 (2 days before flight) | Current date: May 20, 2026 (2 days before flight) |
| CP006 | PREREQUISITES | prerequisite | seed | Flight status: NOT DEPARTED � future flight | Flight status: NOT DEPARTED � future flight |
| CP007 | PREREQUISITES | prerequisite | seed | 72-hour rule: Cannot process until 72hrs post-arrival of final leg | 72-hour rule: Cannot process until 72hrs post-arrival of final leg |
| CP008 | PREREQUISITES | prerequisite | seed | No disruption has occurred (flight is in the future) | No disruption has occurred (flight is in the future) |
| CP009 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP010 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP011 | START | customer | chat | Then user selects English |  |
| CP012 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP013 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP014 | START | customer | chat | And the user says "My flight is on May 21st and I heard there might be delays. I'd like to file a compensation claim in advance" | My flight is on May 21st and I heard there might be delays. I'd like to file a compensation claim in advance |
| CP015 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP016 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP017 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP018 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP021 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Philippe Tremblay" | Philippe Tremblay |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Philippe! And, what is your booking reference number? |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC063" | PNR: TC063 |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC063 |  |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: p***@gmail.com � Phone: +1***012 |
| CP029 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: p***@gmail.com" | Email: p***@gmail.com |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP032 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP034 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP035 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP036 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP037 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP038 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Philippe Tremblay (Adult) Is this who you'd like to include? |
| CP039 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP040 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP041 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 507 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: May 21, 2026 � Status: SCHEDULED (not yet departed) Is this the  |
| CP042 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | PRE-TRAVEL CHECK | system | implied | Then the system checks: Has the flight departed? |  |
| CP044 | PRE-TRAVEL CHECK | system | implied | And the system calculates: Flight date = May 21, 2026; Current date = May 18, 2026 ? FLIGHT HAS NOT YET DEPARTED |  |
| CP045 | PRE-TRAVEL CHECK | system | implied | Then the system determines: PRE-TRAVEL ? REJECTED (cannot file claim for a flight that hasn't occurred) |  |
| CP046 | PRE-TRAVEL REJECTION RESULT | bot | chat | Then the chatbot displays: | I understand you'd like to file a claim, but it looks like your flight AC 507 from Montreal (YUL) to Toronto (YYZ) on May 21, 2026 has not yet departed. Claims  |
| CP047 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP048 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP049 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP050 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the system detected the flight has not yet departed for PNR "TC063" with flight date May 21 and current date May 18 |  |
| CP051 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the chatbot should have informed the customer that claims can only be filed after travel is complete |  |
| CP052 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no DDS evaluation should have occurred |  |
| CP053 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no case should have been created in the system |  |
| CP054 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Claims Dashboard entry should exist for PNR "TC063" |  |
| CP055 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And when searching Claims Dashboard by PNR "TC063" no case should be found |  |
| CP056 | PAYMENT VALIDATION | payment | manual | Given the claim was rejected because the flight has not yet departed |  |
| CP057 | PAYMENT VALIDATION | payment | chat | Then no case was created so no payment flow should be triggered |  |
| CP058 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP059 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP060 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP061 | PAYMENT VALIDATION | payment | chat | And no Claims Dashboard entry should exist as no case exists |  |
| CP062 | EXPECTED RESULTS | verdict | chat | Flight Date Check: Flight date = May 22, 2026; Current date = May 20, 2026; Flight is FUTURE (has not occurred) ? PRE-TRAVEL REJECTION. | Flight Date Check: Flight date = May 22, 2026; Current date = May 20, 2026; Flight is FUTURE (has not occurred) ? PRE-TRAVEL REJECTION. |
| CP063 | EXPECTED RESULTS | verdict | api | DDS: NOT INVOKED � cannot assess a flight that hasn't happened. | DDS: NOT INVOKED � cannot assess a flight that hasn't happened. |
| CP064 | EXPECTED RESULTS | verdict | chat | No disruption data exists. | No disruption data exists. |
| CP065 | EXPECTED RESULTS | verdict | chat | Case: NOT CREATED � no shell case, no reference number generated. | Case: NOT CREATED � no shell case, no reference number generated. |
| CP066 | EXPECTED RESULTS | verdict | chat | There is nothing to track for a future flight. | There is nothing to track for a future flight. |
| CP067 | EXPECTED RESULTS | verdict | chat | Customer Messaging: "We appreciate you reaching out. | Customer Messaging: "We appreciate you reaching out. |
| CP068 | EXPECTED RESULTS | verdict | chat | However, we are unable to process a flight disruption claim before your travel date. | However, we are unable to process a flight disruption claim before your travel date. |
| CP069 | EXPECTED RESULTS | verdict | chat | Please come back 72 hours after the expected arrival of the final leg of your journey on May 22, 2026. | Please come back 72 hours after the expected arrival of the final leg of your journey on May 22, 2026. |
| CP070 | EXPECTED RESULTS | verdict | chat | This allows us to properly assess your claim." Fraud Screening: NOT INVOKED. | This allows us to properly assess your claim." Fraud Screening: NOT INVOKED. |
| CP071 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP072 | EXPECTED RESULTS | verdict | api | Claims Dashboard: NO ENTRY � no case created, no DDS invoked, pre-travel rejection only. | Claims Dashboard: NO ENTRY � no case created, no DDS invoked, pre-travel rejection only. |
| CP073 | EXPECTED RESULTS | verdict | chat | Key Distinction from 72-hour check (TC_068): TC_068 = flight has occurred but <72hrs have passed (case created, pending). | Key Distinction from 72-hour check (TC_068): TC_068 = flight has occurred but <72hrs have passed (case created, pending). |
| CP074 | EXPECTED RESULTS | verdict | chat | TC_077 = flight hasn't occurred at all (no case created, rejected outright). | TC_077 = flight hasn't occurred at all (no case created, rejected outright). |
