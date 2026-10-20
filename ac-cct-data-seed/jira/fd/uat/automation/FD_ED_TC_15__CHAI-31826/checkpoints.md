# FD_ED_TC_15 · CHAI-31826 — checkpoints

**Goal:** PNR is a group booking with 15 passengers. Per call transcript: "For group bookings, each passenger must submit their claim individually, and Agentic should not present other passengers in the group booking during the claim process." System must detect group booking identifier, NOT display other passengers, and allow only individual claim.

Methods: seed 1, chat 51, api 19, email 3, dashboard 4, implied 22, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | PNR is a group booking with 15 passengers. Per call transcript: "For group bookings, each passenger must submit their claim individually, an |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TCED15; Group booking (15 pax); Group booking identifier PRESENT in Trip Tracer (Group ID: GRP-2026-0525); Customer: "Ahmed Hassan" (1  | PNR: TCED15; Group booking (15 pax); Group booking identifier PRESENT in Trip Tracer (Group ID: GRP-2026-0525); Customer: "Ahmed Hassan" (1 of 15 passengers) |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "My flight from Toronto to Vancouver was delayed 4 hours due to a crew issue. I was part of a group trip. Can I get compen | My flight from Toronto to Vancouver was delayed 4 hours due to a crew issue. I was part of a group trip. Can I get compensation? |
| CP009 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO (customer is the traveller) |  |
| CP011 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP012 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP013 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP014 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP015 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Ahmed Hassan" | Ahmed Hassan |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Ahmed! And, what is your booking reference number? |
| CP017 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC235" | PNR: TC235 |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC235 |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP022 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: a***@gmail.com � Phone: +1***345 |
| CP023 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: a***@gmail.com" | Email: a***@gmail.com |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP025 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP026 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP028 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP029 | GROUP BOOKING CHECK | verdict | api | And Trip Tracer returns: GROUP BOOKING IDENTIFIER PRESENT | Ahmed Hassan |
| CP030 | GROUP BOOKING DETECTED � INDIVIDUAL CLAIM ONLY | system | implied | Then the system determines: GROUP BOOKING ? INDIVIDUAL CLAIM PROCESSING ONLY |  |
| CP031 | GROUP BOOKING DETECTED � INDIVIDUAL CLAIM ONLY | system | implied | And the system applies group booking rules: | ? Rule 1: Do NOT display other passengers in the group ? ENFORCED ? Rule 2: Each passenger must submit their claim individually ? ENFORCED ? Rule 3: Only the au |
| CP032 | PASSENGER SELECTION � GROUP BOOKING OVERRIDE (GenUC-06) | bot | chat | Then the chatbot responds: | I can see this is a group booking. For group bookings, each passenger needs to submit their claim individually. I'll process your claim for Ahmed Hassan. who wo |
| CP033 | PASSENGER SELECTION � GROUP BOOKING OVERRIDE (GenUC-06) | bot | chat | Then the chatbot displays: | I'll be processing the claim for: � Ahmed Hassan (Adult) Is this correct? |
| CP034 | PASSENGER SELECTION � GROUP BOOKING OVERRIDE (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP035 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 103 � Route: Toronto (YYZ) ? Vancouver (YVR) � Date: June 1, 2026 � Arrival Delay: 4 hours Is this the journey you'd |
| CP036 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP037 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP038 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP039 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for Ahmed Hassan + this journey combination |  |
| CP040 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP041 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline ? within limitation ? PROCEED |  |
| CP042 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YYZ (Canada) ? APPR |  |
| CP043 | REGIME DETERMINATION | system | implied | And the system checks: Distance YYZ?YVR = ~3,350 km ? Long-haul (domestic) |  |
| CP044 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP045 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP046 | TRIP TRACER UI VALIDATION | verdict | api | Booking Type: GROUP BOOKING (Group ID: GRP-2026-0525) | Booking Type: GROUP BOOKING (Group ID: GRP-2026-0525) |
| CP047 | TRIP TRACER UI VALIDATION | verdict | api | Total Passengers: 15 | Total Passengers: 15 |
| CP048 | TRIP TRACER UI VALIDATION | verdict | api | Claim Filed For: Ahmed Hassan ONLY (1 of 15) | Claim Filed For: Ahmed Hassan ONLY (1 of 15) |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Other Passengers Displayed: NO ? | Other Passengers Displayed: NO ? |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 103, Route: YYZ ? YVR, Scheduled Arrival: 14:00 | Promised Itinerary - Flight: AC 103, Route: YYZ ? YVR, Scheduled Arrival: 14:00 |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 103, Route: YYZ ? YVR, Status: ARRIVED LATE, Actual: 18:00, Delay: +4H 00M | Current Itinerary - Flight: AC 103, Route: YYZ ? YVR, Status: ARRIVED LATE, Actual: 18:00, Delay: +4H 00M |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (Canadian origin � YYZ) | Regime: APPR (Canadian origin � YYZ) |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 103 � YYZ ? YVR � 42 | MSL FLIGHT: AC 103 � YYZ ? YVR � 42 |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42) | CONTROLLABLE (Code 42) |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | APPR: Delay 3�6h, Controllable ? ELIGIBLE | APPR: Delay 3�6h, Controllable ? ELIGIBLE |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Compensation: CAD $400 | Compensation: CAD $400 |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | MR AHMED HASSAN / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 | MR AHMED HASSAN / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 |
| CP058 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP059 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP060 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP061 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 103 from Toronto (YYZ) to Vancouver (YVR) was delayed by about 4 hours. Based on the Canadian Air  |
| CP062 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP063 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP064 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP065 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP066 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No (individual claim � group booking) |  |
| CP067 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP068 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP069 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP070 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada) |  |
| CP071 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer. |
| CP072 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | customer | chat | And the user provides "ahmed.hassan@gmail.com" | ahmed.hassan@gmail.com |
| CP073 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | system | implied | Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded." |  |
| CP074 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP075 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP076 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP077 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP078 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP085 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: Interac e-Transfer After submission, you will receive a confirmation email summarizing your eligibility, claim details  |
| CP086 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP087 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP088 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP089 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP090 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP091 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP092 | NOTIFICATION | email | email | And an eligible notification email is sent to a***@gmail.com |  |
| CP093 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details, note about group booking (individ |  |
| CP094 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP095 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP096 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the case by PNR |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Case Title: "Travel Disruptions � Delay" � Status: in review/done � Booking Type: GROUP BOOKING (Group ID: GRP-2026-0525) � Total Group Passengers: 15 � Claim |
| CP100 | GROUP BOOKING VALIDATION | system | implied | ? Group booking identifier detected: YES ? | ? Group ID: GRP-2026-0525 ? ? Total passengers: 15 ? ? PAX count > 9 ? GROUP BOOKING ? ? Other passengers displayed: NO ? ? Individual claim only: YES ? ? Multi |
| CP101 | EXPECTED RESULTS | verdict | dashboard | Group booking detected via identifier; Other 14 passengers NOT displayed; Individual claim only; Group booking ID logged; Note about separat | Group booking detected via identifier; Other 14 passengers NOT displayed; Individual claim only; Group booking ID logged; Note about separate claims for other p |
