# FD_TC_156 · CHAI-31548 — checkpoints

**Goal:** Entire itinerary on an Israel route is operated by OTHER AIRLINES � no AC operated segments. AC ticket stock (014-) but operating carrier is OAL. Under ASL, the operating carrier bears compensation responsibility. Since AC did not operate any segment, AC cannot assess. Customer redirected to operating airline. ASL counterpart to APPR TC_043 (NE-05) and EU TC equivalent.

Methods: seed 5, chat 39, api 7, dashboard 6, implied 11, manual 1, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Entire itinerary on an Israel route is operated by OTHER AIRLINES � no AC operated segments. AC ticket stock (014-) but operating carrier is |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger | PNR: Single passenger |
| CP003 | PREREQUISITES | prerequisite | seed | Ticket stock: 014- (AC issued) | Ticket stock: 014- (AC issued) |
| CP004 | PREREQUISITES | prerequisite | seed | Journey: Israel origin route | Journey: Israel origin route |
| CP005 | PREREQUISITES | prerequisite | seed | Operating carrier: ALL legs OAL operated (zero AC segments) | Operating carrier: ALL legs OAL operated (zero AC segments) |
| CP006 | PREREQUISITES | prerequisite | seed | Regime: ASL applicable (Israel route) | Regime: ASL applicable (Israel route) |
| CP007 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP008 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP009 | START | customer | chat | Then user selects English |  |
| CP010 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP011 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP012 | START | customer | chat | And the user says "My flight from Tel Aviv to Toronto was delayed 4 hours. I booked through Air Canada but the flight was operated by El Al. | My flight from Tel Aviv to Toronto was delayed 4 hours. I booked through Air Canada but the flight was operated by El Al. Can I get compensation? |
| CP013 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP014 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP015 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP016 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP017 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP018 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP019 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Noa Peretz" | Noa Peretz |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Noa! And, what is your booking reference number? |
| CP021 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC123" | PNR: TC123 |
| CP022 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC123 |  |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data is revealed � ALL LEGS OAL OPERATED (014 ticket stock, AC-issued but OAL-operated) |  |
| CP025 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: n***@gmail.com � Phone: +972***567 |
| CP027 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: n***@gmail.com" | Email: n***@gmail.com |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP029 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP030 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP032 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP033 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP034 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP035 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP036 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Noa Peretz (Adult) Is this who you'd like to include? |
| CP037 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP038 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP039 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: LY 315 (Operated by El Al) � Route: Tel Aviv Ben Gurion (TLV) ? Toronto (YYZ) � Date: June 4, 2026 � Arrival Delay: 4 h |
| CP040 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP041 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP042 | ALL OAL ITINERARY CHECK | system | implied | Then the system checks: Are ALL segments on this itinerary operated by OAL (non-AC)? |  |
| CP043 | ALL OAL ITINERARY CHECK | system | implied | And the system identifies: Flight LY 315 operated by El Al ? OAL |  |
| CP044 | ALL OAL ITINERARY CHECK | system | implied | And the system checks: Any AC-operated segments? ? NO (all OAL) |  |
| CP045 | ALL OAL ITINERARY CHECK | system | implied | And the system determines: ALL OAL ITINERARY ? NOT ELIGIBLE (AC cannot assess; customer should contact operating airline) |  |
| CP046 | ALL OAL RESULT | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight, and we confirm that all flights on this itinerary were operated by a different airline. Please reach out to El Al dire |
| CP047 | ALL OAL RESULT | idv | chat | And the chatbot provides: | � El Al contact information � Link to El Al claim form � Reference to ASL rights NO DDS EVALUATION (skipped � all OAL itinerary) NO PAYMENT FLOW (skipped) NO ID |
| CP048 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP049 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP050 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP051 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the system determined all segments are operated by OAL El Al LY 315 for PNR "TC123" |  |
| CP052 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the chatbot should have redirected the customer to contact El Al directly |  |
| CP053 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no DDS evaluation should have occurred |  |
| CP054 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no case should have been created in the automated system |  |
| CP055 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Claims Dashboard entry should exist for PNR "TC123" |  |
| CP056 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And when searching Claims Dashboard by PNR "TC123" no case should be found |  |
| CP057 | PAYMENT VALIDATION | payment | chat | Given no case was created due to OAL operated flight |  |
| CP058 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP059 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP060 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP061 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP062 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP063 | EXPECTED RESULTS | verdict | api | DDS returns FD-ASL-NE-05. | DDS returns FD-ASL-NE-05. |
| CP064 | EXPECTED RESULTS | verdict | chat | Operating Carrier Check: AC operated legs = 0 ? NOT ELIGIBLE (all OAL itinerary). | Operating Carrier Check: AC operated legs = 0 ? NOT ELIGIBLE (all OAL itinerary). |
| CP065 | EXPECTED RESULTS | verdict | chat | AC ticket stock does NOT make AC responsible � operating carrier bears liability. | AC ticket stock does NOT make AC responsible � operating carrier bears liability. |
| CP066 | EXPECTED RESULTS | verdict | chat | Customer Redirect: Directed to contact operating airline. | Customer Redirect: Directed to contact operating airline. |
| CP067 | EXPECTED RESULTS | verdict | chat | Compensation: $0 (from AC). | Compensation: $0 (from AC). |
| CP068 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP069 | EXPECTED RESULTS | verdict | api | Regime Assessment: ASL = NE-05 (All OAL); APPR = NE (if applicable); EU = NE (if applicable). | Regime Assessment: ASL = NE-05 (All OAL); APPR = NE (if applicable); EU = NE (if applicable). |
| CP070 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Status = Closed � Not Eligible; Reason = All OAL itinerary; Redirect = operating airline; DDS = FD-ASL-NE-05. | Claims Dashboard: Status = Closed � Not Eligible; Reason = All OAL itinerary; Redirect = operating airline; DDS = FD-ASL-NE-05. |
