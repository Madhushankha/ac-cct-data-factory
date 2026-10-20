# FD_ED_TC_08 · CHAI-31819 — checkpoints

**Goal:** Customer passes OTP authentication and is found eligible under APPR for a 7-hour arrival delay (6�<9h band, Tier 2: $700 CAD Cash / $840 CAD AC Wallet) caused by Code 64 (Flight Crew Shortage � Controllable) on a domestic flight. Passenger holds a Basic Aeroplan profile (9876543210). At the payout stage, IDV (Persona) is required before payment release. Customer selects Cash ($700 CAD Interac e-Transfer), but IDV fails at payout (face mismatch, document glare) ? compensation is HELD (not released), payment is BLOCKED, and the case is flagged for fraud review. Tests the Claim Payment with IDV Failure flow from Miro.

Methods: seed 10, chat 51, api 14, email 3, dashboard 3, implied 27, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer passes OTP authentication and is found eligible under APPR for a 7-hour arrival delay (6�<9h band, Tier 2: $700 CAD Cash / $840 CAD |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC226 � single passenger Vincent Larose (Adult - Basic Aeroplan Member #: 9876543210) | PNR: TC226 � single passenger Vincent Larose (Adult - Basic Aeroplan Member #: 9876543210) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC domestic YUL?YYZ | Journey: 1 leg AC domestic YUL?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Flight AC 422, June 2, 2026 | Flight AC 422, June 2, 2026 |
| CP005 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 10:00 ? Actual arrival: 17:00 (7hr delay, 6�<9h band) | Scheduled arrival: 10:00 ? Actual arrival: 17:00 (7hr delay, 6�<9h band) |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival delay code: 64 (Flight Crew Shortage � Controllable) | Arrival delay code: 64 (Flight Crew Shortage � Controllable) |
| CP007 | PREREQUISITES | prerequisite | seed | Regime: APPR (Canadian origin YUL) | Regime: APPR (Canadian origin YUL) |
| CP008 | PREREQUISITES | prerequisite | seed | OTP: will PASS on 1st attempt | OTP: will PASS on 1st attempt |
| CP009 | PREREQUISITES | prerequisite | seed | DDS: FD-APPR-EL-01 (Eligible, APPR Tier 2: $700 CAD Cash / $840 CAD AC Wallet) | DDS: FD-APPR-EL-01 (Eligible, APPR Tier 2: $700 CAD Cash / $840 CAD AC Wallet) |
| CP010 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked (9876543210), Basic Member in good standing | Aeroplan: Linked (9876543210), Basic Member in good standing |
| CP011 | PREREQUISITES | prerequisite | implied | CyberSource: GREEN | CyberSource: GREEN |
| CP012 | PREREQUISITES | prerequisite | seed | IDV at payout: will FAIL (Persona returns FAIL � face mismatch + document quality marginal) | IDV at payout: will FAIL (Persona returns FAIL � face mismatch + document quality marginal) |
| CP013 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP014 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP015 | START | customer | chat | Then user selects English |  |
| CP016 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP017 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP018 | START | customer | chat | And the user says "My flight from Montreal to Toronto was delayed 7 hours due to a crew issue. I'd like to check if I'm eligible for compens | My flight from Montreal to Toronto was delayed 7 hours due to a crew issue. I'd like to check if I'm eligible for compensation |
| CP019 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP020 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP021 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP022 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Vincent Larose" | Vincent Larose |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Vincent! And, what is your booking reference number? |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC226" | PNR: TC226 |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC226 |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP031 | AUTHENTICATION � OTP SUCCESS (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP032 | AUTHENTICATION � OTP SUCCESS (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: v***@gmail.com � Phone: +1***567 |
| CP033 | AUTHENTICATION � OTP SUCCESS (GenUC-05) | customer | chat | And the user selects "Email: v***@gmail.com" | Email: v***@gmail.com |
| CP034 | AUTHENTICATION � OTP SUCCESS (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP035 | AUTHENTICATION � OTP SUCCESS (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP036 | AUTHENTICATION � OTP SUCCESS (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP037 | AUTHENTICATION � OTP SUCCESS (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP038 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Vincent Larose (Adult - Aeroplan Member) Is this who you'd like to include? |
| CP043 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP045 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 422 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 2, 2026 � Arrival Delay: 7 hours Is this the journey you'd  |
| CP046 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP047 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline ? within limitation ? PROCEED |  |
| CP052 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YUL (Canada) ? APPR |  |
| CP053 | REGIME DETERMINATION | system | implied | And the system checks: Distance YUL?YYZ = ~505 km ? Short-haul |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 422, Route: YUL ? YYZ, Scheduled Arrival: 10:00 | Promised Itinerary - Flight: AC 422, Route: YUL ? YYZ, Scheduled Arrival: 10:00 |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 422, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 17:00, Delay: +7H 00M (6�<9h band) | Current Itinerary - Flight: AC 422, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 17:00, Delay: +7H 00M (6�<9h band) |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (Canadian origin � YUL) | Regime: APPR (Canadian origin � YUL) |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 422 � YUL ? YYZ � 64 | MSL FLIGHT: AC 422 � YUL ? YYZ � 64 |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 64 � Flight Crew Shortage) | CONTROLLABLE (Code 64 � Flight Crew Shortage) |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | APPR: Delay 6�9h, Controllable ? ELIGIBLE (Tier 2) | APPR: Delay 6�9h, Controllable ? ELIGIBLE (Tier 2) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: 9876543210 (Basic Member � linked) | Aeroplan: 9876543210 (Basic Member � linked) |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | MR VINCENT LAROSE / ELIGIBLE / APPR_6_TO_LT_9_HOURS / CAD $700 Cash / CAD $840 AC Wallet (+20%) / [expiry date] | MR VINCENT LAROSE / ELIGIBLE / APPR_6_TO_LT_9_HOURS / CAD $700 Cash / CAD $840 AC Wallet (+20%) / [expiry date] |
| CP064 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP065 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected at this stage) |  |
| CP066 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP067 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 422 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7 hours due to a crew shortage. Base |
| CP068 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP069 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP070 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP071 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (Aeroplan #: 9876543210, Status: Basic Member) |  |
| CP072 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Aeroplan account in good standing? ? YES |  |
| CP073 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot offers BOTH options: | Since you are an Aeroplan member, you can choose to receive: � Cash: $700 CAD will be sent via Interac e-Transfer and takes 5 to 10 business days to process. �  |
| CP074 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And the user selects "Cash" | Cash |
| CP075 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the system determines: Customer selected Cash ? Payment method = Interac e-Transfer (Canada) |  |
| CP076 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please confirm the email address where you'd like to receive the transfer. |
| CP077 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | customer | chat | And the user provides "vincent.larose@gmail.com" | vincent.larose@gmail.com |
| CP078 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | system | implied | Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded." |  |
| CP079 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP080 | IDENTITY VERIFICATION AT PAYOUT � PERSONA � IDV FAILURE (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP081 | IDENTITY VERIFICATION AT PAYOUT � PERSONA � IDV FAILURE (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP082 | IDENTITY VERIFICATION AT PAYOUT � PERSONA � IDV FAILURE (FD-07b) | customer | chat | When user clicks on the button |  |
| CP083 | IDENTITY VERIFICATION AT PAYOUT � PERSONA � IDV FAILURE (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP084 | IDENTITY VERIFICATION AT PAYOUT � PERSONA � IDV FAILURE (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP085 | IDENTITY VERIFICATION AT PAYOUT � PERSONA � IDV FAILURE (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP086 | IDENTITY VERIFICATION AT PAYOUT � PERSONA � IDV FAILURE (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP087 | PERSONA IDV PROCESS � FAILURE AT PAYOUT | system | implied | And the customer attempts all steps: | ? ID Type: Canadian Passport ? Front of ID: Uploaded � GLARE / PARTIALLY UNREADABLE ? Selfie: Captured � FACE MISMATCH (selfie does not match passport photo) |
| CP088 | PERSONA IDV PROCESS � FAILURE AT PAYOUT | idv | chat | And Persona evaluates: | ? Document Quality: MARGINAL (glare on key fields) ? Face Match: FAIL (confidence score 42% � below 80% threshold) ? Overall Result: IDV FAIL |
| CP089 | PERSONA IDV PROCESS � FAILURE AT PAYOUT | idv | chat | And Persona returns: IDV FAIL (reason: face mismatch + document quality marginal) |  |
| CP090 | IDV FAILURE AT PAYOUT ? COMPENSATION HELD + FRAUD FLAG | idv | chat | Then the system determines: IDV FAILED AT PAYOUT STAGE |  |
| CP091 | IDV FAILURE AT PAYOUT ? COMPENSATION HELD + FRAUD FLAG | idv | chat | And the system takes the following actions: | ? Compensation: HELD ($700 CAD payment NOT released) ? Case Status: FLAGGED FOR FRAUD REVIEW ? Fraud Flag Reason: IDV failure at payout (face mismatch � potenti |
| CP092 | IDV FAILURE AT PAYOUT ? COMPENSATION HELD + FRAUD FLAG | bot | chat | Then the chatbot responds: | I'm sorry, but we were unable to verify your identity for payment processing. Your claim has been approved, but the payment cannot be released until your identi |
| CP093 | IDV FAILURE AT PAYOUT ? COMPENSATION HELD + FRAUD FLAG | system | implied | And the chatbot provides: | � Case Reference number � Status: "Claim approved � payment held pending identity verification" � Next steps: "Our team will contact you within 15 business days |
| CP094 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted. Please check your email for a confirmation email summarizing your clai | Thank you. Your claim has been submitted. Please check your email for a confirmation email summarizing your claim details. |
| CP095 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submitted � payment pending verification." | Claim submitted � payment pending verification. |
| CP096 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP097 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP098 | NOTIFICATION | email | email | And a Compensation Held notification email is sent to v***@gmail.com |  |
| CP099 | NOTIFICATION | email | email | And the email contains: | Your Air Canada claim � Payment pending verification � [CASE-REF] We were unable to verify your identity during the payment process. Our team will contact you w |
| CP100 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP101 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP102 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the case by PNR |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Case Title: "Travel Disruptions � Delay" � Status: Eligible � Payment Held (Fraud Review) � Created: [date populated] � Last updated at: [date populated] � SL |
| CP106 | CASE OVERVIEW | idv | chat | � Claimant Name: Vincent Larose | � Authentication (OTP): PASS (1st attempt) � IDV at Auth: NOT REQUIRED (OTP passed) � IDV at Payout: FAIL (face mismatch + document quality marginal) � Persona  |
| CP107 | PASSENGER INFORMATION | system | implied | � Full Name: Vincent Larose | � Aeroplan: 9876543210 (linked, Basic Member in good standing) � Tier Status: Basic / Member � Tags: Claimant, Adult, Fraud Flag � Email: v***@gmail.com � Phone |
| CP108 | ITINERARY | system | implied | � Journey: Bound 1: YUL ? YYZ (AC 422, DELAYED +7h, 6�<9h band) |  |
| CP109 | ELIGIBILITY AND COMPENSATION | idv | chat | � Eligibility: ELIGIBLE ($700 CAD Cash / $840 CAD AC Wallet) | � Payment: HELD ($700 CAD Interac payment blocked due to IDV fail at payout) � Fraud Review: PENDING |
