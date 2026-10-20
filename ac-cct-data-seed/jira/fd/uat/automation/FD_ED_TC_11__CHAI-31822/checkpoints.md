# FD_ED_TC_11 · CHAI-31822 — checkpoints

**Goal:** Customer first asks an FAQ question about a disruption notification ("what does this notification mean?"), then switches to wanting compensation ("I want to claim"). System must handle the intent transition correctly, provide the FAQ answer, then seamlessly transition to case creation without losing context or re-greeting.

Methods: seed 1, chat 54, api 12, email 3, implied 22, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer first asks an FAQ question about a disruption notification ("what does this notification mean?"), then switches to wanting compensa |  |
| CP002 | PREREQUISITES | prerequisite | seed | Customer received a flight disruption notification email; PNR: TCED11; 1 leg AC (YUL?YYZ); Delay 4 hrs; Code 42; APPR | Customer received a flight disruption notification email; PNR: TCED11; 1 leg AC (YUL?YYZ); Delay 4 hrs; Code 42; APPR |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | INTENT 1 � FAQ QUESTION | customer | chat | And the user says "I got an email saying my flight was disrupted and I might be eligible for compensation. What does that mean?" | I got an email saying my flight was disrupted and I might be eligible for compensation. What does that mean? |
| CP009 | INTENT DETECTION � FAQ | system | implied | Then the chatbot's intent detection engine analyzes the input: | ? Detected Intent: FAQ / Information Request (customer asking about disruption notification meaning) ? Confidence: HIGH ? Routing: FAQ Response |
| CP010 | FAQ RESPONSE | bot | chat | Then the chatbot responds: | When your flight is delayed, cancelled, or disrupted, you may be entitled to compensation under applicable air passenger protection regulations. The amount depe |
| CP011 | INTENT SWITCH � FAQ TO FD COMPENSATION | customer | chat | And the user says "Yes, I want to claim compensation for my delayed flight" | Yes, I want to claim compensation for my delayed flight |
| CP012 | INTENT DETECTION � INTENT SWITCH | system | implied | Then the chatbot's intent detection engine analyzes the input: | ? Previous Intent: FAQ / Information Request (completed) ? New Intent: Flight Disruption Compensation (customer wants to file a claim) ? Intent Transition: FAQ  |
| CP013 | SEAMLESS TRANSITION TO FD COMPENSATION FLOW | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP014 | SEAMLESS TRANSITION TO FD COMPENSATION FLOW | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP015 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP017 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP018 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Chantal B�langer" | Chantal B�langer |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Chantal! And, what is your booking reference number? |
| CP020 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC229" | PNR: TC229 |
| CP021 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC229 |  |
| CP022 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP025 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: c***@gmail.com � Phone: +1***678 |
| CP026 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: c***@gmail.com" | Email: c***@gmail.com |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP028 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP029 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP031 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP032 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP033 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP034 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP035 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Chantal B�langer (Adult) Is this who you'd like to include? |
| CP036 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP037 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP038 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 422 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 1, 2026 � Arrival Delay: 4 hours Is this the journey you'd  |
| CP039 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP040 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP041 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP042 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP043 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP044 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline ? within limitation ? PROCEED |  |
| CP045 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YUL (Canada) ? APPR |  |
| CP046 | REGIME DETERMINATION | system | implied | And the system checks: Distance YUL?YYZ = ~505 km ? Short-haul |  |
| CP047 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP048 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates: | ? APPR: Delay 3�6h, Controllable ? ELIGIBLE ? Compensation: CAD $400 |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Intent Flow: FAQ ? FD Compensation (intent switch) | Intent Flow: FAQ ? FD Compensation (intent switch) |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | Context Loss: NONE ? | Context Loss: NONE ? |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | Re-greeting: NONE ? | Re-greeting: NONE ? |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR | Regime: APPR |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | Compensation: CAD $400 | Compensation: CAD $400 |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | MS CHANTAL B�LANGER / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 | MS CHANTAL B�LANGER / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 |
| CP055 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP056 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP057 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 422 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours. Based on the Canadian Air P |
| CP058 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP059 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP060 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP061 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP062 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP063 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP064 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP065 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada) |  |
| CP066 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer. |
| CP067 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | customer | chat | And the user provides "chantal.belanger@gmail.com" | chantal.belanger@gmail.com |
| CP068 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | system | implied | Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded." |  |
| CP069 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP070 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP071 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP072 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP073 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP074 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP075 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP076 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP077 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP078 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP080 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: Interac e-Transfer After submission, you will receive a confirmation email summarizing your eligibility, claim details  |
| CP081 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP082 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP083 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP084 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP085 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP086 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP087 | NOTIFICATION | email | email | And an eligible notification email is sent to c***@gmail.com |  |
| CP088 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details, next steps, tracking link |  |
| CP089 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP090 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP091 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP092 | INTENT TRANSITION VALIDATION | system | implied | ? Intent 1: FAQ ("what does this notification mean?") ? FAQ response provided ? | ? Intent Switch: Customer says "I want to claim compensation" ? detected ? ? Intent 2: FD Compensation ? routed correctly ? ? Context Loss: NONE ? (no re-greeti |
| CP093 | EXPECTED RESULTS | verdict | chat | FAQ intent handled first with correct answer; Intent switch to case creation detected seamlessly; No re-greeting or duplicate privacy notice | FAQ intent handled first with correct answer; Intent switch to case creation detected seamlessly; No re-greeting or duplicate privacy notice; Smooth transition  |
