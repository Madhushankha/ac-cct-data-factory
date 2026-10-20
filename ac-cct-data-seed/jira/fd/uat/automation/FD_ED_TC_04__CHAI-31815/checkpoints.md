# FD_ED_TC_04 · CHAI-31815 — checkpoints

**Goal:** Customer doesn't know their PNR but provides both Aeroplan number and e-ticket number. System cross-references both to locate the booking and resolve the PNR automatically.

Methods: seed 1, chat 59, api 19, email 3, dashboard 3, implied 29, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer doesn't know their PNR but provides both Aeroplan number and e-ticket number. System cross-references both to locate the booking an |  |
| CP002 | PREREQUISITES | prerequisite | seed | Customer NOT logged in; Aeroplan #: 5678901234; E-ticket: 014-5678901234; PNR: TCED04 (customer doesn't know this); 1 leg AC (YYZ?YUL); Dela | Customer NOT logged in; Aeroplan #: 5678901234; E-ticket: 014-5678901234; PNR: TCED04 (customer doesn't know this); 1 leg AC (YYZ?YUL); Delay 4 hrs; Code 42; AP |
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
| CP015 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Isabelle Fournier" | Isabelle Fournier |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Isabelle! And, what is your booking reference number? |
| CP017 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC223" | PNR: TC223 |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC223 |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP021 | AUTHENTICATION � OTP ATTEMPTS (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP022 | AUTHENTICATION � OTP ATTEMPTS (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: i***@gmail.com � Phone: +1***345 |
| CP023 | AUTHENTICATION � OTP ATTEMPTS (GenUC-05) | customer | chat | And the user selects "Email: i***@gmail.com" | Email: i***@gmail.com |
| CP024 | AUTHENTICATION � OTP ATTEMPTS (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP025 | OTP ATTEMPT 1 OF 5 | customer | chat | And the user provides the OTP code "111111" | 111111 |
| CP026 | OTP ATTEMPT 1 OF 5 | system | implied | Then the chatbot validates the OTP code ? INCORRECT (attempt 1 of 5) |  |
| CP027 | OTP ATTEMPT 1 OF 5 | bot | chat | Then the chatbot responds: | The code you entered is incorrect. Please try again. You have 4 attempts remaining. |
| CP028 | OTP ATTEMPT 2 OF 5 | customer | chat | And the user provides the OTP code "222222" | 222222 |
| CP029 | OTP ATTEMPT 2 OF 5 | system | implied | Then the chatbot validates the OTP code ? INCORRECT (attempt 2 of 5) |  |
| CP030 | OTP ATTEMPT 2 OF 5 | bot | chat | Then the chatbot responds: | The code you entered is incorrect. Please try again. You have 3 attempts remaining. |
| CP031 | OTP ATTEMPT 3 OF 5 | customer | chat | And the user provides the OTP code "333333" | 333333 |
| CP032 | OTP ATTEMPT 3 OF 5 | system | implied | Then the chatbot validates the OTP code ? INCORRECT (attempt 3 of 5) |  |
| CP033 | OTP ATTEMPT 3 OF 5 | bot | chat | Then the chatbot responds: | The code you entered is incorrect. Please try again. You have 2 attempts remaining. |
| CP034 | OTP ATTEMPT 4 OF 5 | customer | chat | And the user provides the OTP code "444444" | 444444 |
| CP035 | OTP ATTEMPT 4 OF 5 | system | implied | Then the chatbot validates the OTP code ? INCORRECT (attempt 4 of 5) |  |
| CP036 | OTP ATTEMPT 4 OF 5 | bot | chat | Then the chatbot responds: | The code you entered is incorrect. Please try again. You have 1 attempt remaining. |
| CP037 | OTP ATTEMPT 5 OF 5 | customer | chat | And the user provides the OTP code "555555" | 555555 |
| CP038 | OTP ATTEMPT 5 OF 5 | system | implied | Then the chatbot validates the OTP code ? INCORRECT (attempt 5 of 5) |  |
| CP039 | OTP ATTEMPT 5 OF 5 | system | implied | Then the system determines: OTP MAXIMUM ATTEMPTS REACHED (5/5) |  |
| CP040 | OTP FAILURE ? IDV OFFERED IMMEDIATELY | bot | chat | Then the chatbot responds: | You've reached the maximum number of verification attempts. Don't worry � I can verify your identity another way. I'll send you a secure link to verify your ide |
| CP041 | IDV LINK � NON-BIOMETRIC FLOW | bot | chat | Then the chatbot responds: | Please click the link below to verify your identity. You'll need a valid government-issued photo ID (passport, driver's license, or national ID card). |
| CP042 | IDV LINK � NON-BIOMETRIC FLOW | bot | chat | And chatbot displays a button "Verify my identity" | Verify my identity |
| CP043 | IDV LINK � NON-BIOMETRIC FLOW | customer | chat | When user clicks on the button |  |
| CP044 | IDV LINK � NON-BIOMETRIC FLOW | idv | chat | Then the chatbot sends Persona IDV link to the customer |  |
| CP045 | IDV LINK � NON-BIOMETRIC FLOW | customer | chat | And the customer opens the Persona link |  |
| CP046 | PERSONA IDV PROCESS | system | implied | And the customer is prompted to: | 1 2 3 4 |
| CP047 | PERSONA IDV PROCESS | system | implied | And the customer completes all steps: | ? ID Type: Canadian Driver's License ? Front of ID: Uploaded successfully ? Back of ID: Uploaded successfully ? Selfie: Captured successfully ? Document quality |
| CP048 | PERSONA IDV PROCESS | idv | chat | And Persona returns: IDV PASS |  |
| CP049 | PERSONA IDV PROCESS | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to the next step. |
| CP050 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP051 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP052 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP053 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP054 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Isabelle Fournier (Adult) Is this who you'd like to include? |
| CP055 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP056 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP057 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 422 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 1, 2026 � Arrival Delay: 4 hours Is this the journey you'd  |
| CP058 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP059 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP060 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP061 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP062 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP063 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline ? within limitation ? PROCEED |  |
| CP064 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YUL (Canada) ? APPR |  |
| CP065 | REGIME DETERMINATION | system | implied | And the system checks: Distance YUL?YYZ = ~505 km ? Short-haul |  |
| CP066 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP067 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Authentication Method: IDV (Persona) � after OTP 5x failure | Authentication Method: IDV (Persona) � after OTP 5x failure |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | OTP Attempts: 5/5 FAILED | OTP Attempts: 5/5 FAILED |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | IDV: PASS (Canadian Driver's License) | IDV: PASS (Canadian Driver's License) |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | Cooldown: NONE (IDV offered immediately) | Cooldown: NONE (IDV offered immediately) |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 422, Route: YUL ? YYZ, Scheduled Arrival: 10:00 | Promised Itinerary - Flight: AC 422, Route: YUL ? YYZ, Scheduled Arrival: 10:00 |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 422, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 14:00, Delay: +4H 00M | Current Itinerary - Flight: AC 422, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 14:00, Delay: +4H 00M |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (Canadian origin � YUL) | Regime: APPR (Canadian origin � YUL) |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | Distance: ~505 km ? Short-haul | Distance: ~505 km ? Short-haul |
| CP076 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 422 � YUL ? YYZ � 42 | MSL FLIGHT: AC 422 � YUL ? YYZ � 42 |
| CP077 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42) | CONTROLLABLE (Code 42) |
| CP078 | TRIP TRACER UI VALIDATION | verdict | api | APPR: Delay 3�6h, Controllable, Short-haul ? ELIGIBLE | APPR: Delay 3�6h, Controllable, Short-haul ? ELIGIBLE |
| CP079 | TRIP TRACER UI VALIDATION | verdict | api | Compensation: CAD $400 | Compensation: CAD $400 |
| CP080 | TRIP TRACER UI VALIDATION | verdict | api | MS ISABELLE FOURNIER / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 | MS ISABELLE FOURNIER / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 |
| CP081 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP082 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP083 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP084 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 422 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours. Based on the Canadian Air P |
| CP085 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP086 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP087 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP088 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP089 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP090 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP091 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP092 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP093 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada) |  |
| CP094 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer. |
| CP095 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | customer | chat | And the user provides "isabelle.fournier@gmail.com" | isabelle.fournier@gmail.com |
| CP096 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | system | implied | Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded." |  |
| CP097 | IDV AT PAYOUT � ALREADY COMPLETED | idv | chat | Then system checks: Has IDV been completed? ? YES (completed during authentication phase after OTP failure) |  |
| CP098 | IDV AT PAYOUT � ALREADY COMPLETED | idv | chat | Then system determines: IDV ALREADY PASSED � NO NEED TO REPEAT |  |
| CP099 | IDV AT PAYOUT � ALREADY COMPLETED | bot | chat | Then the chatbot responds: | Your identity was already verified earlier. No additional verification is needed. |
| CP100 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: Interac e-Transfer After submission, you will receive a confirmation email summarizing your eligibility, claim details  |
| CP101 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP102 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP103 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP104 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP105 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP106 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP107 | NOTIFICATION | email | email | And an eligible notification email is sent to i***@gmail.com |  |
| CP108 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details, authentication method (IDV after  |  |
| CP109 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP110 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP111 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the case by PNR |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Case Title: "Travel Disruptions � Delay" � Status: in review/done � Authentication: IDV (Persona PASS) � after OTP 5x failure � OTP History: 5/5 INCORRECT � I |
| CP115 | EXPECTED RESULTS | verdict | chat | Customer identified via Aeroplan + e-ticket cross-reference; PNR resolved automatically without customer providing it; Full eligible flow co | Customer identified via Aeroplan + e-ticket cross-reference; PNR resolved automatically without customer providing it; Full eligible flow completed; Identificat |
