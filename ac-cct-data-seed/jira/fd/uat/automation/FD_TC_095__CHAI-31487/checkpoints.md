# FD_TC_095 · CHAI-31487 — checkpoints

**Goal:** Disrupted leg operated by a non-Star Alliance carrier (e.g., WestJet). AC systems have the flight timing data (scheduled vs. actual arrival times, delay duration) and can identify the MSL. DDS determines MSL = WestJet-operated leg. Since WestJet is not a Star Alliance partner, AC is not responsible for the disruption. The system redirects the customer to contact WestJet directly. No case is created, no DDS eligibility assessment is performed, and no compensation is issued. Validates the OAL redirect path when MSL falls on a non-Star Alliance carrier.

Methods: seed 10, chat 35, api 9, dashboard 6, implied 9, manual 2, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Disrupted leg operated by a non-Star Alliance carrier (e.g., WestJet). AC systems have the flight timing data (scheduled vs. actual arrival  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger, 2 legs YUL?YYZ?YVR | PNR: Single passenger, 2 legs YUL?YYZ?YVR |
| CP003 | PREREQUISITES | prerequisite | seed | Leg 1 (YUL?YYZ): AC operated, on time | Leg 1 (YUL?YYZ): AC operated, on time |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 10:30 | Scheduled arrival: 10:30 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival: 10:28 | Actual arrival: 10:28 |
| CP006 | PREREQUISITES | prerequisite | seed | Leg 2 (YYZ?YVR): Operated by WestJet (WS 3456) | Leg 2 (YYZ?YVR): Operated by WestJet (WS 3456) |
| CP007 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 16:00 | Scheduled arrival: 16:00 |
| CP008 | PREREQUISITES | prerequisite | seed | Actual arrival: 21:00 (5hr delay) | Actual arrival: 21:00 (5hr delay) |
| CP009 | PREREQUISITES | prerequisite | seed | MSL: Leg 2 (WS 3456) � 5hr delay is the most significant disruption | MSL: Leg 2 (WS 3456) � 5hr delay is the most significant disruption |
| CP010 | PREREQUISITES | prerequisite | seed | MSL Carrier: WestJet (WS) � non-Star Alliance | MSL Carrier: WestJet (WS) � non-Star Alliance |
| CP011 | PREREQUISITES | prerequisite | seed | DDS Action: MSL identified on non-Star Alliance OAL ? AC not responsible ? redirect to OAL | DDS Action: MSL identified on non-Star Alliance OAL ? AC not responsible ? redirect to OAL |
| CP012 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP013 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP014 | START | customer | chat | Then user selects English |  |
| CP015 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP016 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP017 | START | customer | chat | And the user says "I flew from Montreal to Toronto on Air Canada and then from Toronto to Vancouver on WestJet. The WestJet flight was delay | I flew from Montreal to Toronto on Air Canada and then from Toronto to Vancouver on WestJet. The WestJet flight was delayed 5 hours. Can I get compensation? |
| CP018 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP019 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP020 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP021 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Thierry Rousseau" | Thierry Rousseau |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Thierry! And, what is your booking reference number? |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC057" | PNR: TC057 |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC057 |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: t***@gmail.com Phone: +1***123 |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP035 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP037 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Thierry Rousseau (Adult) Is this who you'd like to include? |
| CP042 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP044 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Segment 1: Flight AC 497, Montreal (YUL) ? Toronto (YYZ), June 7, 2026 � COMPLETED (AC operated) Segment 2: Flight WS 3456, Toron |
| CP045 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP047 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED on time (AC), Segment 2 DELAYED +5h (WestJet � OAL) |  |
| CP048 | MSL DETERMINATION | verdict | api | Then the system calculates MSL using available timing data: | Segment 1 (AC 497): Scheduled arrival 10:30, Actual arrival 10:28 ? No delay Segment 2 (WS 3456): Scheduled arrival 16:00, Actual arrival 21:00 ? 5hr delay MSL  |
| CP049 | MSL CHECK � OAL | verdict | api | Then the system checks MSL for operating carrier on the disrupted leg |  |
| CP050 | MSL CHECK � OAL | verdict | api | And MSL returns: Segment 2 operated by WestJet (WS) ? OAL |  |
| CP051 | MSL CHECK � OAL | system | implied | And the system checks: Is WestJet a Star Alliance partner? ? NO |  |
| CP052 | MSL CHECK � OAL | verdict | api | And the system determines: MSL on non-Star Alliance OAL ? AC NOT RESPONSIBLE ? REDIRECT TO OAL |  |
| CP053 | OAL REDIRECT RESULT | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight, and we confirm that this flight was operated by a different airline. Please reach out to WestJet directly for any clai |
| CP054 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP055 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP056 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP057 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given MSL determined the disrupted leg is operated by a non-Star Alliance OAL for PNR "TC057" |  |
| CP058 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the chatbot should have redirected the customer to contact the operating airline directly |  |
| CP059 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no DDS evaluation should have occurred |  |
| CP060 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no case should have been created in the automated system |  |
| CP061 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Claims Dashboard entry should exist for PNR "TC057" |  |
| CP062 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And when searching Claims Dashboard by PNR "TC057" no case should be found |  |
| CP063 | PAYMENT VALIDATION | payment | chat | Given no case was created due to OAL non-Star Alliance operated flight |  |
| CP064 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP065 | PAYMENT VALIDATION | payment | chat | And the case was created and sent to agent for manual handling |  |
| CP066 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP067 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP068 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP069 | PAYMENT VALIDATION | payment | manual | And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e- |  |
| CP070 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved |  |
| CP071 | EXPECTED RESULTS | verdict | api | DDS identifies MSL using available flight timing data: Segment 1 (AC 497): Scheduled arrival 10:30, Actual arrival 10:28 ? 0 delay Segment 2 | DDS identifies MSL using available flight timing data: Segment 1 (AC 497): Scheduled arrival 10:30, Actual arrival 10:28 ? 0 delay Segment 2 (WS 3456): Schedule |
| CP072 | EXPECTED RESULTS | verdict | chat | Validation = confirm NO entry exists for PNR TC057. | Validation = confirm NO entry exists for PNR TC057. |
