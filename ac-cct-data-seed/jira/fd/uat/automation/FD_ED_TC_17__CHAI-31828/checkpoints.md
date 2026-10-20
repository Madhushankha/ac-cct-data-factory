# FD_ED_TC_17 · CHAI-31828 — checkpoints

**Goal:** Customer's PNR was split from a group booking. The originator office ID still identifies it as a group-origin booking. Per call transcript: "When a group PNR is split, the originator office ID remains the same, and the booking is still considered a group booking for eligibility and reporting purposes."

Methods: seed 1, chat 51, api 19, email 3, dashboard 3, implied 21, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer's PNR was split from a group booking. The originator office ID still identifies it as a group-origin booking. Per call transcript:  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TCED17 (split from group GRP-2026-0520); Originator office ID: YYZAC1234 (same as original group); 1 passenger on split PNR: "Priya Sha | PNR: TCED17 (split from group GRP-2026-0520); Originator office ID: YYZAC1234 (same as original group); 1 passenger on split PNR: "Priya Sharma"; 1 leg AC (YYZ? |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "My flight from Toronto to Vancouver was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compen | My flight from Toronto to Vancouver was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation |
| CP009 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP011 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP012 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP013 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP014 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP015 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Priya Sharma" | Priya Sharma |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Priya! And, what is your booking reference number? |
| CP017 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC237" | PNR: TC237 |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC237 |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP022 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: p***@gmail.com � Phone: +1***456 |
| CP023 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: p***@gmail.com" | Email: p***@gmail.com |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP025 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP026 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP028 | GROUP BOOKING CHECK � SPLIT PNR DETECTION | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP029 | GROUP BOOKING CHECK � SPLIT PNR DETECTION | verdict | api | And Trip Tracer returns: | When a group PNR is split, the originator office ID remains the same, and the booking is still considered a group booking |
| CP030 | SPLIT PNR � GROUP TREATMENT APPLIED | system | implied | Then the system determines: SPLIT PNR ? GROUP BOOKING TREATMENT |  |
| CP031 | SPLIT PNR � GROUP TREATMENT APPLIED | system | implied | And the system applies group booking rules: | ? Rule 1: Treat as group booking for eligibility and reporting ? ENFORCED ? Rule 2: Individual claim only (1 passenger on split PNR) ? ENFORCED ? Rule 3: Origin |
| CP032 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot displays: | I found 1 passenger on this booking: � Priya Sharma (Adult) Is this who you'd like to include? |
| CP033 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP034 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 103 � Route: Toronto (YYZ) ? Vancouver (YVR) � Date: June 2, 2026 � Arrival Delay: 4 hours Is this the journey you'd |
| CP035 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP036 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP037 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP038 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP039 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP040 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline ? within limitation ? PROCEED |  |
| CP041 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YYZ (Canada) ? APPR |  |
| CP042 | REGIME DETERMINATION | system | implied | And the system checks: Distance YYZ?YVR = ~3,350 km ? Long-haul (domestic) |  |
| CP043 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP044 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP045 | TRIP TRACER UI VALIDATION | verdict | api | PNR Type: SPLIT PNR (split from group GRP-2026-0520) | PNR Type: SPLIT PNR (split from group GRP-2026-0520) |
| CP046 | TRIP TRACER UI VALIDATION | verdict | api | Originator Office ID: YYZAC1234 (same as original group) | Originator Office ID: YYZAC1234 (same as original group) |
| CP047 | TRIP TRACER UI VALIDATION | verdict | api | Group Treatment: APPLIED (despite split) | Group Treatment: APPLIED (despite split) |
| CP048 | TRIP TRACER UI VALIDATION | verdict | api | Passengers on Split PNR: 1 (Priya Sharma) | Passengers on Split PNR: 1 (Priya Sharma) |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 103, Route: YYZ ? YVR, Scheduled Arrival: 14:00 | Promised Itinerary - Flight: AC 103, Route: YYZ ? YVR, Scheduled Arrival: 14:00 |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 103, Route: YYZ ? YVR, Status: ARRIVED LATE, Actual: 18:00, Delay: +4H 00M | Current Itinerary - Flight: AC 103, Route: YYZ ? YVR, Status: ARRIVED LATE, Actual: 18:00, Delay: +4H 00M |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (Canadian origin � YYZ) | Regime: APPR (Canadian origin � YYZ) |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 103 � YYZ ? YVR � 42 | MSL FLIGHT: AC 103 � YYZ ? YVR � 42 |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42) | CONTROLLABLE (Code 42) |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | APPR: Delay 3�6h, Controllable ? ELIGIBLE | APPR: Delay 3�6h, Controllable ? ELIGIBLE |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Compensation: CAD $400 | Compensation: CAD $400 |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | MS PRIYA SHARMA / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 | MS PRIYA SHARMA / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 |
| CP057 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP058 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP059 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP060 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 103 from Toronto (YYZ) to Vancouver (YVR) was delayed by about 4 hours. Based on the Canadian Air  |
| CP061 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP062 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP063 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP064 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP065 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP066 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP067 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP068 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada) |  |
| CP069 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer. |
| CP070 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | customer | chat | And the user provides "priya.sharma@gmail.com" | priya.sharma@gmail.com |
| CP071 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | system | implied | Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded." |  |
| CP072 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP073 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP074 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP075 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP076 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP077 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP078 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP083 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: Interac e-Transfer After submission, you will receive a confirmation email summarizing your eligibility, claim details  |
| CP084 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP085 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP086 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP087 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP088 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP089 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP090 | NOTIFICATION | email | email | And an eligible notification email is sent to p***@gmail.com |  |
| CP091 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details, next steps, tracking link |  |
| CP092 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP093 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP094 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the case by PNR |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Case Title: "Travel Disruptions � Delay" � Status: in review/done � PNR Type: SPLIT PNR (from group GRP-2026-0520) � Originator Office ID: YYZAC1234 (group or |
| CP098 | SPLIT PNR VALIDATION | system | implied | ? Split PNR detected via originator office ID: YES ? | ? Originator office ID matches original group: YES (YYZAC1234) ? ? Group treatment applied: YES ? ? Individual claim processed: YES ? ? Customer experience seam |
| CP099 | EXPECTED RESULTS | verdict | chat | Split PNR detected via originator office ID matching group office; Treated as group booking (individual claim only); Full eligible flow comp | Split PNR detected via originator office ID matching group office; Treated as group booking (individual claim only); Full eligible flow completed; Group origin  |
