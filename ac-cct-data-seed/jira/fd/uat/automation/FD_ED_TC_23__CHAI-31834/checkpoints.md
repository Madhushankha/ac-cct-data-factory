# FD_ED_TC_23 · CHAI-31834 — checkpoints

**Goal:** Customer accesses chatbot via WhatsApp. Rich UI components (flight cards, interactive buttons, seat maps) may not render on WhatsApp. System must fall back to text-based alternatives. Per call transcript: "Cards, buttons, dropdowns may not display on WhatsApp."

Methods: seed 1, chat 37, api 6, email 3, dashboard 3, implied 34, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer accesses chatbot via WhatsApp. Rich UI components (flight cards, interactive buttons, seat maps) may not render on WhatsApp. System |  |
| CP002 | PREREQUISITES | prerequisite | seed | Channel: WhatsApp; PNR: TCED23; 1 leg AC (YUL?YYZ); Delay 4 hrs; APPR EL-01 | Channel: WhatsApp; PNR: TCED23; 1 leg AC (YUL?YYZ); Delay 4 hrs; APPR EL-01 |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot via WhatsApp (not web, not mobile app) |  |
| CP004 | START | system | implied | Then the system detects: Channel = WhatsApp |  |
| CP005 | START | system | implied | And the system applies: WhatsApp rendering rules (text-based fallbacks for rich UI components) |  |
| CP006 | START | bot | chat | Then the chatbot displays greeting (GLOB-01) � WhatsApp text format: | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? Reply with: 1 - English 2 -  |
| CP007 | START | system | implied | Then user replies "1" |  |
| CP008 | START | idv | chat | Then the chatbot sends a text message: "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP009 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP010 | START | customer | chat | And the user says "My flight from Montreal to Toronto was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compens | My flight from Montreal to Toronto was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation |
| CP011 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP012 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP013 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP014 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Reply with: 1 - Yes 2 - No" |
| CP015 | LEGAL DISCLAIMER | system | implied | And the user replies "1" | IDENTIFICATION (GenUC-01) � WhatsApp: |
| CP016 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP017 | LEGAL DISCLAIMER | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP018 | LEGAL DISCLAIMER | customer | chat | And the user provides "Olivier Bergeron" | Olivier Bergeron |
| CP019 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: | Thanks, Olivier! And, what is your booking reference number? |
| CP020 | LEGAL DISCLAIMER | customer | chat | And the user provides "TC243" | TC243 |
| CP021 | LEGAL DISCLAIMER | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC243 |  |
| CP022 | LEGAL DISCLAIMER | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP023 | LEGAL DISCLAIMER | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer | AUTHENTICATION (GenUC-05) � WhatsApp: |
| CP024 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP025 | LEGAL DISCLAIMER | system | implied | And the user replies "1" |  |
| CP026 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP027 | LEGAL DISCLAIMER | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP028 | LEGAL DISCLAIMER | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP029 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP030 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP031 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP032 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP033 | PASSENGER SELECTION � WhatsApp (GenUC-06) | bot | chat | Then the chatbot responds: | How many people are on your claim? I found 1 passenger on this booking: Olivier Bergeron (Adult) Is this who you'd like to include? Reply with: 1 - Yes 2 - No |
| CP034 | PASSENGER SELECTION � WhatsApp (GenUC-06) | system | implied | And the user replies "1" |  |
| CP035 | PASSENGER SELECTION � WhatsApp (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP036 | JOURNEY SELECTION � WhatsApp (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays in text format (no flight card rendering on WhatsApp): | I found the following journey: Flight: AC 422 Route: Montreal (YUL) ? Toronto (YYZ) Date: June 1, 2026 Arrival Delay: 4 hours Is this the journey you'd like to  |
| CP037 | JOURNEY SELECTION � WhatsApp (GenUC-08) | system | implied | And the user replies "1" |  |
| CP038 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP039 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP040 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP041 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP042 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline ? within limitation ? PROCEED |  |
| CP043 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YUL (Canada) ? APPR |  |
| CP044 | REGIME DETERMINATION | system | implied | And the system checks: Distance YUL?YYZ = ~505 km ? Short-haul |  |
| CP045 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP046 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates: | APPR: Delay 3�6h, Controllable ? ELIGIBLE Compensation: CAD $400 |
| CP047 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP048 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP049 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment | ELIGIBLE RESULT (FD-05a) � WhatsApp: |
| CP050 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | bot | chat | Then the chatbot displays (text format): | I've checked your flight details, and it looks like flight AC 422 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours. Based on the Canadian Air P |
| CP051 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW � WhatsApp | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? Reply with: 1 - Canada 2 - United States 3 - Other (please type your country) |
| CP052 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW � WhatsApp | system | implied | And the user replies "1" |  |
| CP053 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW � WhatsApp | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP054 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP055 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP056 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to proc | Reply with: 1 - Yes 2 - No" |
| CP057 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed (text): "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP058 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | And user replies "1" |  |
| CP059 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada) |  |
| CP060 | PAYMENT METHOD � INTERAC E-TRANSFER � WhatsApp (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer. |
| CP061 | PAYMENT METHOD � INTERAC E-TRANSFER � WhatsApp (FD-07) | customer | chat | And the user provides "olivier.bergeron@gmail.com" | olivier.bergeron@gmail.com |
| CP062 | PAYMENT METHOD � INTERAC E-TRANSFER � WhatsApp (FD-07) | system | implied | Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded." |  |
| CP063 | PAYMENT METHOD � INTERAC E-TRANSFER � WhatsApp (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP064 | IDENTITY VERIFICATION � PERSONA � WhatsApp (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click the link below to get started: [Persona Verification Link] Open this link in your mobile browser  |
| CP065 | IDENTITY VERIFICATION � PERSONA � WhatsApp (FD-07b) | customer | chat | When user clicks on the link |  |
| CP066 | IDENTITY VERIFICATION � PERSONA � WhatsApp (FD-07b) | idv | chat | Then the user is redirected to Persona IDV in their mobile browser |  |
| CP067 | IDENTITY VERIFICATION � PERSONA � WhatsApp (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP068 | IDENTITY VERIFICATION � PERSONA � WhatsApp (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP069 | IDENTITY VERIFICATION � PERSONA � WhatsApp (FD-07b) | bot | chat | Then the chatbot responds (back in WhatsApp): | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP070 | CLAIM AMOUNT CONFIRMATION FLOW � WhatsApp | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: Interac e-Transfer After submission, you will receive a confirmation email summarizing your eligibility, claim details  |
| CP071 | CLAIM AMOUNT CONFIRMATION FLOW � WhatsApp | system | implied | When the user replies "1" |  |
| CP072 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP073 | CASE CREATION (GLOB-09) | system | implied | And the chatbot sends: "Claim submission successful!" |  |
| CP074 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP075 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP076 | NOTIFICATION | email | email | And an eligible notification email is sent to o***@gmail.com |  |
| CP077 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details, channel (WhatsApp), next steps, t | END FLOW (GLOB-11) � WhatsApp: |
| CP078 | NOTIFICATION | bot | chat | Then the chatbot offers: | Is there anything I can help you with? Reply with: 1 - Yes, I have another request 2 - No, I'm done |
| CP079 | NOTIFICATION | system | implied | And the user replies "2" |  |
| CP080 | NOTIFICATION | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP081 | WHATSAPP COMPONENT RENDERING VALIDATION | idv | chat | ? Language selection: Numbered text options (not buttons) ? | ? Legal disclaimer confirmation: Numbered text options ? ? OTP delivery selection: Numbered text options ? ? Passenger selection: Text list with numbered confir |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the case by PNR |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Case Title: "Travel Disruptions � Delay" � Status: in review/done � Channel: WhatsApp � Rendering Mode: Text Fallback � Regime: APPR |
| CP085 | EXPECTED RESULTS | verdict | chat | WhatsApp channel detected; All rich UI components (cards, buttons, dropdowns) replaced with text-based alternatives; Numbered options used i | WhatsApp channel detected; All rich UI components (cards, buttons, dropdowns) replaced with text-based alternatives; Numbered options used instead of buttons; F |
