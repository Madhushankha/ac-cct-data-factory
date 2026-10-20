# FD_ED_TC_05 · CHAI-31816 — checkpoints

**Goal:** Customer enters wrong OTP 5 times triggering a 24-hour OTP cooldown. IDV (Persona) is offered immediately. Customer completes IDV successfully (Persona PASS) and is authenticated. The underlying flight was delayed 7 hours (6�<9h band) due to Code 67 (Crew Transport / Hotel / Logistics Delay � Controllable) on a domestic APPR route (YUL?YYZ). Passenger holds a Basic Aeroplan profile (9876543210). System evaluates claim as ELIGIBLE under APPR Tier 2 ($700 CAD Cash / $840 CAD AC Wallet). Since Aeroplan is linked, chatbot offers both Cash and AC Wallet (+20% bonus). Customer selects Cash (Interac e-Transfer). At payout stage, IDV is SKIPPED because it was already completed during authentication. Validates: (1) 5x OTP failure triggers immediate IDV offer with 24-hour OTP lockout, (2) Persona IDV PASS authenticates user, (3) DDS evaluates Code 67 with 7h delay under APPR Tier 2, (4) Linked Basic Aeroplan profile triggers dual payout offer, (5) IDV at payout is skipped since auth IDV passed, (6) Successful case creation and payment dispatch.

Methods: chat 57, api 18, email 3, dashboard 3, implied 28, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer enters wrong OTP 5 times triggering a 24-hour OTP cooldown. IDV (Persona) is offered immediately. Customer completes IDV successful |  |
| CP002 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP003 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP004 | START | customer | chat | Then user selects English |  |
| CP005 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP006 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP007 | START | customer | chat | And the user says "My flight from Montreal to Toronto was delayed 7 hours due to a crew transport issue. I'd like to check if I'm eligible f | My flight from Montreal to Toronto was delayed 7 hours due to a crew transport issue. I'd like to check if I'm eligible for compensation |
| CP008 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP009 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP010 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP011 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP012 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP013 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP014 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Isabelle Fournier" | Isabelle Fournier |
| CP015 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Isabelle! And, what is your booking reference number? |
| CP016 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC223" | PNR: TC223 |
| CP017 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC223 |  |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP020 | AUTHENTICATION � OTP ATTEMPTS (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP021 | AUTHENTICATION � OTP ATTEMPTS (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: i***@gmail.com � Phone: +1***345 |
| CP022 | AUTHENTICATION � OTP ATTEMPTS (GenUC-05) | customer | chat | And the user selects "Email: i***@gmail.com" | Email: i***@gmail.com |
| CP023 | AUTHENTICATION � OTP ATTEMPTS (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP024 | OTP ATTEMPT 1 OF 5 | customer | chat | And the user provides the OTP code "111111" | 111111 |
| CP025 | OTP ATTEMPT 1 OF 5 | system | implied | Then the chatbot validates the OTP code ? INCORRECT (attempt 1 of 5) |  |
| CP026 | OTP ATTEMPT 1 OF 5 | bot | chat | Then the chatbot responds: | The code you entered is incorrect. Please try again. You have 4 attempts remaining. |
| CP027 | OTP ATTEMPT 2 OF 5 | customer | chat | And the user provides the OTP code "222222" | 222222 |
| CP028 | OTP ATTEMPT 2 OF 5 | system | implied | Then the chatbot validates the OTP code ? INCORRECT (attempt 2 of 5) |  |
| CP029 | OTP ATTEMPT 2 OF 5 | bot | chat | Then the chatbot responds: | The code you entered is incorrect. Please try again. You have 3 attempts remaining. |
| CP030 | OTP ATTEMPT 3 OF 5 | customer | chat | And the user provides the OTP code "333333" | 333333 |
| CP031 | OTP ATTEMPT 3 OF 5 | system | implied | Then the chatbot validates the OTP code ? INCORRECT (attempt 3 of 5) |  |
| CP032 | OTP ATTEMPT 3 OF 5 | bot | chat | Then the chatbot responds: | The code you entered is incorrect. Please try again. You have 2 attempts remaining. |
| CP033 | OTP ATTEMPT 4 OF 5 | customer | chat | And the user provides the OTP code "444444" | 444444 |
| CP034 | OTP ATTEMPT 4 OF 5 | system | implied | Then the chatbot validates the OTP code ? INCORRECT (attempt 4 of 5) |  |
| CP035 | OTP ATTEMPT 4 OF 5 | bot | chat | Then the chatbot responds: | The code you entered is incorrect. Please try again. You have 1 attempt remaining. |
| CP036 | OTP ATTEMPT 5 OF 5 | customer | chat | And the user provides the OTP code "555555" | 555555 |
| CP037 | OTP ATTEMPT 5 OF 5 | system | implied | Then the chatbot validates the OTP code ? INCORRECT (attempt 5 of 5) |  |
| CP038 | OTP ATTEMPT 5 OF 5 | system | implied | Then the system determines: OTP MAXIMUM ATTEMPTS REACHED (5/5) � 24-HOUR OTP LOCKOUT ENFORCED |  |
| CP039 | OTP FAILURE ? IDV OFFERED IMMEDIATELY | bot | chat | Then the chatbot responds: | You've reached the maximum number of verification attempts. Don't worry � I can verify your identity another way. I'll send you a secure link to verify your ide |
| CP040 | IDV LINK � NON-BIOMETRIC FLOW | bot | chat | Then the chatbot responds: | Please click the link below to verify your identity. You'll need a valid government-issued photo ID (passport, driver's license, or national ID card). |
| CP041 | IDV LINK � NON-BIOMETRIC FLOW | bot | chat | And chatbot displays a button "Verify my identity" | Verify my identity |
| CP042 | IDV LINK � NON-BIOMETRIC FLOW | customer | chat | When user clicks on the button |  |
| CP043 | IDV LINK � NON-BIOMETRIC FLOW | idv | chat | Then the chatbot sends Persona IDV link to the customer |  |
| CP044 | IDV LINK � NON-BIOMETRIC FLOW | customer | chat | And the customer opens the Persona link |  |
| CP045 | PERSONA IDV PROCESS | system | implied | And the customer completes all steps: | ? ID Type: Canadian Driver's License ? Front of ID: Uploaded successfully ? Back of ID: Uploaded successfully ? Selfie: Captured successfully ? Document quality |
| CP046 | PERSONA IDV PROCESS | idv | chat | And Persona returns: IDV PASS |  |
| CP047 | PERSONA IDV PROCESS | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to the next step. |
| CP048 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP049 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP050 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP051 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP052 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Isabelle Fournier (Adult - Aeroplan Member) Is this who you'd like to include? |
| CP053 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP054 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP055 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 422 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 1, 2026 � Arrival Delay: 7 hours Is this the journey you'd  |
| CP056 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP057 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP058 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP059 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP060 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP061 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline ? within limitation ? PROCEED |  |
| CP062 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YUL (Canada) ? APPR |  |
| CP063 | REGIME DETERMINATION | system | implied | And the system checks: Distance YUL?YYZ = ~505 km ? Short-haul |  |
| CP064 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP065 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Authentication Method: IDV (Persona PASS) � after OTP 5x failure | Authentication Method: IDV (Persona PASS) � after OTP 5x failure |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | OTP Attempts: 5/5 FAILED (24-hour lockout enforced) | OTP Attempts: 5/5 FAILED (24-hour lockout enforced) |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | IDV at Auth: PASS (Canadian Driver's License) | IDV at Auth: PASS (Canadian Driver's License) |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 422, Route: YUL ? YYZ, Scheduled Arrival: 10:00 | Promised Itinerary - Flight: AC 422, Route: YUL ? YYZ, Scheduled Arrival: 10:00 |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 422, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 17:00, Delay: +7H 00M (6�<9h band) | Current Itinerary - Flight: AC 422, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 17:00, Delay: +7H 00M (6�<9h band) |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (Canadian origin � YUL) | Regime: APPR (Canadian origin � YUL) |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | Distance: ~505 km ? Short-haul | Distance: ~505 km ? Short-haul |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 422 � YUL ? YYZ � 67 | MSL FLIGHT: AC 422 � YUL ? YYZ � 67 |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 67 � Crew Transport / Hotel / Logistics Delay) | CONTROLLABLE (Code 67 � Crew Transport / Hotel / Logistics Delay) |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | APPR: Delay 6�9h, Controllable ? ELIGIBLE (Tier 2) | APPR: Delay 6�9h, Controllable ? ELIGIBLE (Tier 2) |
| CP076 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: 9876543210 (Basic Member � linked) | Aeroplan: 9876543210 (Basic Member � linked) |
| CP077 | TRIP TRACER UI VALIDATION | verdict | api | MS ISABELLE FOURNIER / ELIGIBLE / APPR_6_TO_LT_9_HOURS / CAD $700 Cash / CAD $840 AC Wallet (+20%) / [expiry date] | MS ISABELLE FOURNIER / ELIGIBLE / APPR_6_TO_LT_9_HOURS / CAD $700 Cash / CAD $840 AC Wallet (+20%) / [expiry date] |
| CP078 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP079 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP080 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP081 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 422 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7 hours due to crew transport logist |
| CP082 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP083 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP084 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP085 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (Aeroplan #: 9876543210, Status: Basic Member) |  |
| CP086 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Aeroplan account in good standing? ? YES |  |
| CP087 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot offers BOTH options: | Since you are an Aeroplan member, you can choose to receive: � Cash: $700 CAD will be sent via Interac e-Transfer and takes 5 to 10 business days to process. �  |
| CP088 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And the user selects "Cash" | Cash |
| CP089 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the system determines: Customer selected Cash ? Payment method = Interac e-Transfer (Canada) |  |
| CP090 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please confirm the email address where you'd like to receive the transfer. |
| CP091 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | customer | chat | And the user provides "isabelle.fournier@gmail.com" | isabelle.fournier@gmail.com |
| CP092 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | system | implied | Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded." |  |
| CP093 | IDV AT PAYOUT � ALREADY COMPLETED | idv | chat | Then system checks: Has IDV been completed? ? YES (completed during authentication phase after OTP failure) |  |
| CP094 | IDV AT PAYOUT � ALREADY COMPLETED | idv | chat | Then system determines: IDV ALREADY PASSED � NO NEED TO REPEAT |  |
| CP095 | IDV AT PAYOUT � ALREADY COMPLETED | bot | chat | Then the chatbot responds: | Your identity was already verified earlier. No additional verification is needed. |
| CP096 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $700 CAD Payment Method: Interac e-Transfer (isabelle.fournier@gmail.com) After submission, you will receive a confirmation email summarizing yo |
| CP097 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP098 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP099 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP100 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP101 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP102 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP103 | NOTIFICATION | email | email | And an eligible notification email is sent to i***@gmail.com |  |
| CP104 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($700 CAD Cash), regulation (APPR), flight details (YUL?YYZ AC 422, delayed 7h,  |  |
| CP105 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP106 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP107 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the case by PNR |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Case Title: "Travel Disruptions � Delay" � Status: In Review / Done � Authentication: IDV (Persona PASS) � after OTP 5x failure � OTP History: 5/5 INCORRECT ( |
