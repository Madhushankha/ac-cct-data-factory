# FD_ED_TC_13 · CHAI-31824 — checkpoints

**Goal:** Customer has Aeroplan and selects AC Wallet, but EAP (E-credit Application Platform) check reveals the Aeroplan account is FROZEN (fraud hold / compliance issue). System must gracefully fall back to cash payment without alarming the customer.

Methods: seed 1, chat 51, api 6, email 3, dashboard 4, implied 24, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer has Aeroplan and selects AC Wallet, but EAP (E-credit Application Platform) check reveals the Aeroplan account is FROZEN (fraud hol |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TCED13; Aeroplan #: 1111222233 on booking; Aeroplan account status: FROZEN; 1 leg AC (YUL?YYZ); Delay 4 hrs; Code 42; APPR EL-01; Custo | PNR: TCED13; Aeroplan #: 1111222233 on booking; Aeroplan account status: FROZEN; 1 leg AC (YUL?YYZ); Delay 4 hrs; Code 42; APPR EL-01; Customer resides in Canad |
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
| CP015 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Alexandre Dupont" | Alexandre Dupont |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Alexandre! And, what is your booking reference number? |
| CP017 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC233" | PNR: TC233 |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC233 |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP022 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: a***@gmail.com � Phone: +1***567 |
| CP023 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: a***@gmail.com" | Email: a***@gmail.com |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP025 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP026 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP028 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP029 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP030 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP031 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP032 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Alexandre Dupont (Adult) Is this who you'd like to include? |
| CP033 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP034 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP035 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 422 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 2, 2026 � Arrival Delay: 4 hours Is this the journey you'd  |
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
| CP047 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP048 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 422 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours. Based on the Canadian Air P |
| CP049 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP050 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP051 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP052 | CASH vs AC WALLET CHECK � AEROPLAN DETECTED (FD-06a) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (Aeroplan #: 1111222233) |  |
| CP053 | EAP CHECK | system | implied | Then the system queries EAP for Aeroplan account status |  |
| CP054 | EAP CHECK | system | implied | And EAP returns: Aeroplan #1111222233 ? Account Status: FROZEN (fraud hold / compliance issue) | ? Aeroplan Account: 1111222233 ? Account Status: FROZEN ? Reason: Fraud hold / compliance issue ? AC Wallet Eligible: NO (frozen accounts cannot receive AC Wall |
| CP055 | AC WALLET OPTION � SUPPRESSED | system | implied | Then the system determines: Aeroplan account FROZEN ? AC Wallet option NOT offered |  |
| CP056 | AC WALLET OPTION � SUPPRESSED | bot | chat | Then the chatbot responds: | You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP057 | AC WALLET OPTION � SUPPRESSED | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP058 | AC WALLET OPTION � SUPPRESSED | customer | chat | And user provides "Yes" | Yes |
| CP059 | AC WALLET OPTION � SUPPRESSED | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada) |  |
| CP060 | PAYMENT METHOD � INTERAC E-TRANSFER � FALLBACK FROM AC WALLET (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer. |
| CP061 | PAYMENT METHOD � INTERAC E-TRANSFER � FALLBACK FROM AC WALLET (FD-07) | customer | chat | And the user provides "alexandre.dupont@gmail.com" | alexandre.dupont@gmail.com |
| CP062 | PAYMENT METHOD � INTERAC E-TRANSFER � FALLBACK FROM AC WALLET (FD-07) | system | implied | Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded." |  |
| CP063 | PAYMENT METHOD � INTERAC E-TRANSFER � FALLBACK FROM AC WALLET (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP064 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP065 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP066 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP067 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP068 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP069 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP070 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP071 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP072 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP073 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP074 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: Interac e-Transfer After submission, you will receive a confirmation email summarizing your eligibility, claim details  |
| CP075 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP076 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP077 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP078 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP079 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP080 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP081 | NOTIFICATION | email | email | And an eligible notification email is sent to a***@gmail.com |  |
| CP082 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), payment method (Interac e-Transfer), regulation (APPR), flight detai |  |
| CP083 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP084 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP085 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the case by PNR |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Case Title: "Travel Disruptions � Delay" � Status: in review/done � Aeroplan: 1111222233 � FROZEN � AC Wallet: NOT OFFERED (EAP check fail � frozen account) � |
| CP089 | EAP CHECK VALIDATION | system | implied | ? Aeroplan on booking: YES (1111222233) ? | ? EAP query: Account status = FROZEN ? ? AC Wallet offered: NO (silently suppressed) ? ? Customer alarmed: NO (no mention of frozen account) ? ? Fallback to cas |
| CP090 | EXPECTED RESULTS | verdict | dashboard | AC Wallet selected by customer; EAP check detects frozen account; Graceful fallback to cash (Interac) without alarming customer; Customer in | AC Wallet selected by customer; EAP check detects frozen account; Graceful fallback to cash (Interac) without alarming customer; Customer informed payment metho |
