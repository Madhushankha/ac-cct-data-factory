# FD_ED_TC_12 · CHAI-31823 — checkpoints

**Goal:** Customer mentions multiple needs in one message. System must detect all intents, prioritize them (FD compensation > expense claim > accessibility FAQ), and handle sequentially. Tests the intent prioritization logic discussed in the call transcript.

Methods: seed 1, chat 59, api 12, email 3, dashboard 3, implied 25, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer mentions multiple needs in one message. System must detect all intents, prioritize them (FD compensation > expense claim > accessib |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TCED12; Customer has disrupted flight AND hotel expense AND accessibility question; 1 leg AC (YYZ?YVR); Delay 5 hrs; Code 42; APPR | PNR: TCED12; Customer has disrupted flight AND hotel expense AND accessibility question; 1 leg AC (YYZ?YVR); Delay 5 hrs; Code 42; APPR |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | MULTIPLE INTENTS IN ONE MESSAGE | customer | chat | And the user says "My flight from Toronto to Vancouver was delayed 5 hours and I had to pay for a hotel. I also need to know about wheelchai | My flight from Toronto to Vancouver was delayed 5 hours and I had to pay for a hotel. I also need to know about wheelchair assistance for my next flight. Can yo |
| CP009 | INTENT DETECTION � MULTIPLE INTENTS DETECTED | system | implied | Then the chatbot's intent detection engine analyzes the input: | ? Intent 1: Flight Disruption Compensation (flight delayed 5 hours ? FD claim) � PRIORITY: HIGH ? Intent 2: Expense Reimbursement (hotel expense due to disrupti |
| CP010 | INTENT ACKNOWLEDGMENT + PRIORITIZATION | bot | chat | Then the chatbot responds: | I can see you have a few things you need help with. Let me address them one at a time: 1 2 3 Let's start with your flight compensation claim. |
| CP011 | INTENT 1 � FD COMPENSATION | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP012 | INTENT 1 � FD COMPENSATION | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP013 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP014 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP015 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP016 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "James Chen" | James Chen |
| CP017 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, James! And, what is your booking reference number? |
| CP018 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC230" | PNR: TC230 |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC230 |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP021 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP022 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP023 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: j***@gmail.com � Phone: +1***789 |
| CP024 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: j***@gmail.com" | Email: j***@gmail.com |
| CP025 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP026 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP027 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP029 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP030 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP031 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP032 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP033 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � James Chen (Adult) Is this who you'd like to include? |
| CP034 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP035 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP036 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 103 � Route: Toronto (YYZ) ? Vancouver (YVR) � Date: June 1, 2026 � Arrival Delay: 5 hours Is this the journey you'd |
| CP037 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP038 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP039 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP040 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP041 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP042 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline ? within limitation ? PROCEED |  |
| CP043 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YYZ (Canada) ? APPR |  |
| CP044 | REGIME DETERMINATION | system | implied | And the system checks: Distance YYZ?YVR = ~3,350 km ? Long-haul (domestic) |  |
| CP045 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP046 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP047 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR | Regime: APPR |
| CP048 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 103 � YYZ ? YVR � 42 | MSL FLIGHT: AC 103 � YYZ ? YVR � 42 |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42) | CONTROLLABLE (Code 42) |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | APPR: Delay 3�6h, Controllable ? ELIGIBLE | APPR: Delay 3�6h, Controllable ? ELIGIBLE |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | Compensation: CAD $400 | Compensation: CAD $400 |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | MR JAMES CHEN / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 | MR JAMES CHEN / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 |
| CP053 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP054 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP055 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 103 from Toronto (YYZ) to Vancouver (YVR) was delayed by about 5 hours. Based on the Canadian Air  |
| CP056 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP057 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP058 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP059 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP060 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP061 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP062 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP063 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada) |  |
| CP064 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer. |
| CP065 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | customer | chat | And the user provides "james.chen@gmail.com" | james.chen@gmail.com |
| CP066 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | system | implied | Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded." |  |
| CP067 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP068 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP069 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP070 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP071 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP072 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP073 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP074 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP075 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP076 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP077 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP078 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: Interac e-Transfer After submission, you will receive a confirmation email summarizing your eligibility, claim details  |
| CP079 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP080 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP081 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP082 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP083 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP084 | FD COMPENSATION COMPLETE � TRANSITION TO INTENT 2 | bot | chat | Then the chatbot responds: | Great, your flight compensation claim has been submitted! Now let's take care of your hotel expense. ? 1/3 complete |
| CP085 | INTENT 2 � EXPENSE REIMBURSEMENT | bot | chat | Then the chatbot responds: | You mentioned you had to pay for a hotel due to the delay. I can help you submit that expense for reimbursement. Please upload your hotel receipt (PDF, JPG, or  |
| CP086 | INTENT 2 � EXPENSE REIMBURSEMENT | system | implied | And the user uploads: Hotel_Receipt_TC230.pdf |  |
| CP087 | INTENT 2 � EXPENSE REIMBURSEMENT | system | implied | Then the chatbot confirms: | "Thank you. I've attached your hotel receipt to your case [CASE-REF]. Our team will review the expense as part of your claim. Hotel expenses related to flight d |
| CP088 | INTENT 2 � EXPENSE REIMBURSEMENT | bot | chat | And the chatbot responds: | Could you confirm the hotel expense amount? |
| CP089 | INTENT 2 � EXPENSE REIMBURSEMENT | customer | chat | And the user provides "$189.50 CAD" | $189.50 CAD |
| CP090 | INTENT 2 � EXPENSE REIMBURSEMENT | system | implied | Then the chatbot confirms: | "Thank you. Hotel expense of $189.50 CAD has been added to your case for review. ? 2/3 complete" |
| CP091 | INTENT 2 COMPLETE � TRANSITION TO INTENT 3 | bot | chat | Then the chatbot responds: | Now let me help you with your question about wheelchair assistance. |
| CP092 | INTENT 3 � ACCESSIBILITY FAQ | bot | chat | Then the chatbot responds: | Air Canada offers wheelchair assistance and other accessibility services for passengers who need them. Here's what you need to know: � Requesting wheelchair ass |
| CP093 | INTENT 3 � ACCESSIBILITY FAQ | system | implied | And the user responds "No, that covers it. Thank you!" |  |
| CP094 | ALL INTENTS COMPLETE | bot | chat | Then the chatbot responds: | Great! Here's a summary of everything we covered today: ? Flight compensation claim � Submitted (Case [CASE-REF], $400 CAD via Interac e-Transfer) ? Hotel expen |
| CP095 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP096 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP097 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP098 | NOTIFICATION | email | email | And an eligible notification email is sent to j***@gmail.com |  |
| CP099 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), hotel expense ($189.50 CAD attached), regulation (APPR), flight deta |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the case by PNR |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Case Title: "Travel Disruptions � Delay" � Status: in review/done � Regime: APPR � Intents Handled: 3 (FD Compensation, Expense Reimbursement, Accessibility F |
| CP103 | INTENT PRIORITIZATION VALIDATION | system | implied | ? Intent 1 (HIGH): FD Compensation ? processed FIRST ? | ? Intent 2 (MEDIUM): Expense Reimbursement ? processed SECOND ? ? Intent 3 (LOW): Accessibility FAQ ? processed THIRD ? ? All 3 intents detected from single mes |
| CP104 | EXPECTED RESULTS | verdict | chat | All 3 intents detected from single message; Priority order applied (FD > Expense > Accessibility); FD compensation processed first with full | All 3 intents detected from single message; Priority order applied (FD > Expense > Accessibility); FD compensation processed first with full flow; Expense claim |
