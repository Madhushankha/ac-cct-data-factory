# FD_TC_138 · CHAI-31530 — checkpoints

**Goal:** All legs of the journey are operated by a non-EU carrier (e.g., Air Canada is Canadian, not EU-based). Flight ARRIVES in EU but does NOT depart from EU. Under EU 261, flights arriving in EU are only covered if operated by an EU-based carrier. Since AC is not EU-based, EU 261 does NOT apply for inbound flights. Validates that DDS correctly applies the EU carrier check for arriving flights.

Methods: seed 5, chat 38, api 8, dashboard 6, implied 11, manual 1, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | All legs of the journey are operated by a non-EU carrier (e.g., Air Canada is Canadian, not EU-based). Flight ARRIVES in EU but does NOT dep |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger, 1 leg AC operated YYZ?LHR (Canada to UK) | PNR: Single passenger, 1 leg AC operated YYZ?LHR (Canada to UK) |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: Scheduled arrival 08:00 (LHR local), Actual arrival 12:00 (4hr delay) | Itinerary: Scheduled arrival 08:00 (LHR local), Actual arrival 12:00 (4hr delay) |
| CP004 | PREREQUISITES | prerequisite | seed | Disruption code: 42 (Controllable) | Disruption code: 42 (Controllable) |
| CP005 | PREREQUISITES | prerequisite | seed | Carrier: AC (Canadian carrier � NOT an EU-based carrier) | Carrier: AC (Canadian carrier � NOT an EU-based carrier) |
| CP006 | PREREQUISITES | prerequisite | seed | Route direction: Arriving in EU/UK, NOT departing from EU/UK | Route direction: Arriving in EU/UK, NOT departing from EU/UK |
| CP007 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP008 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP009 | START | customer | chat | Then user selects English |  |
| CP010 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP011 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP012 | START | customer | chat | And the user says "My flight from Paris to London was delayed 4 hours. I booked through Air Canada but the flight was operated by another ai | My flight from Paris to London was delayed 4 hours. I booked through Air Canada but the flight was operated by another airline. Can I get compensation? |
| CP013 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP014 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP015 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP016 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP017 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP018 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP019 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Isabelle Roux" | Isabelle Roux |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Isabelle! And, what is your booking reference number? |
| CP021 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC097" | PNR: TC097 |
| CP022 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC097 |  |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data is revealed � ALL LEGS OAL OPERATED (014 ticket stock, AC-issued but OAL-operated) |  |
| CP025 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: i***@gmail.com � Phone: +33***789 |
| CP027 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: i***@gmail.com" | Email: i***@gmail.com |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP029 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP030 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP032 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP033 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP034 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP035 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP036 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Isabelle Roux (Adult) Is this who you'd like to include? |
| CP037 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP038 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP039 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AF 1234 (Operated by Air France) � Route: Paris Charles de Gaulle (CDG) ? London Heathrow (LHR) � Date: June 7, 2026 �  |
| CP040 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP041 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP042 | ALL OAL ITINERARY CHECK | system | implied | Then the system checks: Are ALL segments on this itinerary operated by OAL (non-AC)? |  |
| CP043 | ALL OAL ITINERARY CHECK | system | implied | And the system identifies: Flight AF 1234 operated by Air France ? OAL |  |
| CP044 | ALL OAL ITINERARY CHECK | system | implied | And the system checks: Any AC-operated segments? ? NO (all OAL) |  |
| CP045 | ALL OAL ITINERARY CHECK | system | implied | And the system determines: ALL OAL ITINERARY ? NOT ELIGIBLE (AC cannot assess; customer should contact operating airline) |  |
| CP046 | ALL OAL RESULT | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight, and we confirm that all flights on this itinerary were operated by a different airline. Please reach out to Air France |
| CP047 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP048 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP049 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP050 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the system determined all segments are operated by OAL Air France AF 1234 for PNR "TC097" |  |
| CP051 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the chatbot should have redirected the customer to contact Air France directly |  |
| CP052 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no DDS evaluation should have occurred |  |
| CP053 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no case should have been created in the automated system |  |
| CP054 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Claims Dashboard entry should exist for PNR "TC097" |  |
| CP055 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And when searching Claims Dashboard by PNR "TC097" no case should be found |  |
| CP056 | PAYMENT VALIDATION | payment | chat | Given no case was created due to OAL operated flight |  |
| CP057 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP058 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP059 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP060 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP061 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP062 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-NE-04. | DDS returns FD-EU-NE-04. |
| CP063 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 08:00 LHR; Actual = 12:00; Delay = 4hrs; MSL = Leg 1; Code 42; Controllable. | Trip Tracer: Promise = 08:00 LHR; Actual = 12:00; Delay = 4hrs; MSL = Leg 1; Code 42; Controllable. |
| CP064 | EXPECTED RESULTS | verdict | api | Regime check: Origin YYZ (Canada) � NOT EU origin ? EU 261 departure rule does NOT apply. | Regime check: Origin YYZ (Canada) � NOT EU origin ? EU 261 departure rule does NOT apply. |
| CP065 | EXPECTED RESULTS | verdict | chat | Destination LHR (UK) � EU arrival, BUT carrier AC is NOT EU-based ? EU 261 arrival rule does NOT apply. | Destination LHR (UK) � EU arrival, BUT carrier AC is NOT EU-based ? EU 261 arrival rule does NOT apply. |
| CP066 | EXPECTED RESULTS | verdict | chat | CRITICAL: EU 261 only covers arriving flights when operated by an EU-based carrier (e.g., British Airways, Lufthansa). | CRITICAL: EU 261 only covers arriving flights when operated by an EU-based carrier (e.g., British Airways, Lufthansa). |
| CP067 | EXPECTED RESULTS | verdict | chat | AC is Canadian ? excluded. | AC is Canadian ? excluded. |
| CP068 | EXPECTED RESULTS | verdict | chat | APPR applies (departing Canada). | APPR applies (departing Canada). |
| CP069 | EXPECTED RESULTS | verdict | chat | Compensation under EU 261: $0 � Not Eligible. | Compensation under EU 261: $0 � Not Eligible. |
| CP070 | EXPECTED RESULTS | verdict | api | Claims Dashboard: EU 261 = Not Applicable (non-EU carrier arriving in EU); APPR = assessed separately (Canada departure); DDS = FD-EU-NE-04. | Claims Dashboard: EU 261 = Not Applicable (non-EU carrier arriving in EU); APPR = assessed separately (Canada departure); DDS = FD-EU-NE-04. |
