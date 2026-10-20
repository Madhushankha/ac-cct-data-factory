# FD_ED_TC_20 · CHAI-31831 — checkpoints

**Goal:** Per call transcript: "Any claim with an RDS flag alert should be sent to manual review or rejected, regardless of CyberSource's outcome." This TC validates that even when CyberSource returns GREEN, if RDS flags are present (geolocation mismatch + multiple email usage), the case is STILL routed to manual review.

Methods: chat 29, api 6, email 3, dashboard 4, implied 26, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Per call transcript: "Any claim with an RDS flag alert should be sent to manual review or rejected, regardless of CyberSource's outcome." Th |  |
| CP002 | PREREQUISITES | prerequisite | implied | PNR: TCED20; 1 leg AC (YUL?YYZ); Delay 4 hrs; Code 42; APPR EL-01; CyberSource: GREEN; RDS flags: Geolocation mismatch (claim from Nigeria,  | PNR: TCED20; 1 leg AC (YUL?YYZ); Delay 4 hrs; Code 42; APPR EL-01; CyberSource: GREEN; RDS flags: Geolocation mismatch (claim from Nigeria, flight in Canada) +  |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "My flight from Montreal to Toronto was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compens | My flight from Montreal to Toronto was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation |
| CP009 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP011 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP012 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP013 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP014 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP015 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Jean-Pierre Martin" | Jean-Pierre Martin |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Jean-Pierre! And, what is your booking reference number? |
| CP017 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC240" | PNR: TC240 |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC240 |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP022 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: j***@gmail.com � Phone: +1***678 |
| CP023 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: j***@gmail.com" | Email: j***@gmail.com |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP025 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP026 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP028 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP029 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP030 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP031 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP032 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Jean-Pierre Martin (Adult) Is this who you'd like to include? |
| CP033 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP034 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP035 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 422 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 1, 2026 � Arrival Delay: 4 hours Is this the journey you'd  |
| CP036 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP037 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP038 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP039 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP040 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP041 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline ? within limitation ? PROCEED |  |
| CP042 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YUL (Canada) ? APPR |  |
| CP043 | REGIME DETERMINATION | system | implied | And the system checks: Distance YUL?YYZ = ~505 km ? Short-haul |  |
| CP044 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP045 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates: | ? APPR: Delay 3�6h, Controllable ? ELIGIBLE ? Compensation: CAD $400 |
| CP046 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP047 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected by CyberSource) |  |
| CP048 | RDS CHECK � PARALLEL TO CYBERSOURCE | system | implied | Then the system simultaneously runs RDS (Risk Detection System) checks |  |
| CP049 | RDS CHECK � PARALLEL TO CYBERSOURCE | system | implied | And RDS evaluates: |  |
| CP050 | RDS FLAG 1 � GEOLOCATION MISMATCH | system | implied | ? Customer's IP geolocation: Lagos, Nigeria | ? Flight route: Montreal (YUL) ? Toronto (YYZ), Canada ? Mismatch: Customer claiming from Nigeria for a Canadian domestic flight ? RDS Flag: GEOLOCATION_MISMATC |
| CP051 | RDS FLAG 2 � MULTIPLE EMAIL USAGE | system | implied | ? Email on claim: j***@gmail.com | ? Same email found on: 3 other claims in past 30 days CASE-FD-20260510-001 (YYZ?YVR, May 10, 2026) CASE-FD-20260515-002 (YUL?YYZ, May 15, 2026) CASE-FD-20260518 |
| CP052 | RDS OVERALL RESULT | system | implied | ? RDS Flags: 2 HIGH RISK FLAGS | ? RDS Decision: MANUAL REVIEW REQUIRED |
| CP053 | RDS OVERRIDE � CYBERSOURCE GREEN OVERRIDDEN | system | implied | Then the system evaluates: CyberSource = GREEN, RDS = 2 HIGH RISK FLAGS |  |
| CP054 | RDS OVERRIDE � CYBERSOURCE GREEN OVERRIDDEN | system | implied | And the system applies the override rule: | ? Per call transcript: "Any claim with an RDS flag alert should be sent to manual review or rejected, regardless of CyberSource's outcome." ? RDS FLAGS OVERRIDE |
| CP055 | CUSTOMER-FACING RESULT � NO ALARM | bot | chat | Then the chatbot displays: | Thank you for submitting your claim. Your claim has been received and is currently being processed. Please note that it may take up to 15 days to fully assess y |
| CP056 | CUSTOMER-FACING RESULT � NO ALARM | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP057 | CASE CREATION (GLOB-09) | system | implied | Then the system creates the case with status: ELIGIBLE � COMPENSATION HELD (RDS Manual Review) |  |
| CP058 | CASE CREATION (GLOB-09) | system | implied | And the case contains: | � PNR: TC240 � Passenger: Jean-Pierre Martin � Journey: YUL?YYZ, delayed 4h � Regime: APPR � DDS Decision: ELIGIBLE ($400 CAD) � CyberSource: GREEN � RDS Flags: |
| CP059 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP060 | NOTIFICATION | email | email | And a standard processing notification email is sent to j***@gmail.com |  |
| CP061 | NOTIFICATION | email | email | And the email contains: | Your Air Canada claim has been received � [CASE-REF] Your claim is being processed. We will notify you of the outcome within 15 days. |
| CP062 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP063 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP064 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP065 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the case by PNR |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Case Title: "Travel Disruptions � Delay" � Status: Eligible � Compensation Held (RDS Review) � Created: � Last updated at � SLA � Team: Fraud Review Team CASE |
| CP068 | RDS OVERRIDE VALIDATION | system | implied | ? CyberSource result: GREEN ? | ? RDS flags present: YES (2 high risk) ? ? Override rule applied: YES ? ? Compensation held: YES ? ? Payment blocked: YES ? ? Routed to Fraud Review Team: YES ? |
| CP069 | EXPECTED RESULTS | verdict | dashboard | CyberSource returns GREEN; RDS detects 3 flags (geolocation, multiple email, late booking); RDS flags OVERRIDE CyberSource GREEN; Case route | CyberSource returns GREEN; RDS detects 3 flags (geolocation, multiple email, late booking); RDS flags OVERRIDE CyberSource GREEN; Case routed to manual review d |
