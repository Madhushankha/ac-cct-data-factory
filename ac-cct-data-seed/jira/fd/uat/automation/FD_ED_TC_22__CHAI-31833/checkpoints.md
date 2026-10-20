# FD_ED_TC_22 · CHAI-31833 — checkpoints

**Goal:** Customer completes identification, authentication, passenger/journey selection, but DDS service goes down during eligibility assessment. System must handle gracefully, create a case for retry, and notify customer.

Methods: seed 1, chat 29, api 18, email 3, dashboard 3, implied 17, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer completes identification, authentication, passenger/journey selection, but DDS service goes down during eligibility assessment. Sys |  |
| CP002 | PREREQUISITES | prerequisite | seed | DDS service: will go DOWN during eligibility assessment; All other services operational; Customer has completed identification and authentic | DDS service: will go DOWN during eligibility assessment; All other services operational; Customer has completed identification and authentication |
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
| CP015 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Fran�ois Leblanc" | Fran�ois Leblanc |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Fran�ois! And, what is your booking reference number? |
| CP017 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC242" | PNR: TC242 |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC242 |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP022 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: f***@gmail.com � Phone: +1***890 |
| CP023 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: f***@gmail.com" | Email: f***@gmail.com |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP025 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP026 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP028 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP029 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP030 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP031 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP032 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Fran�ois Leblanc (Adult) Is this who you'd like to include? |
| CP033 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP034 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP035 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 422 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 2, 2026 � Arrival Delay: 4 hours Is this the journey you'd  |
| CP036 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP037 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP038 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP039 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP040 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP041 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline ? within limitation ? PROCEED |  |
| CP042 | TRIAGE & DDS EVALUATION � SERVICE FAILURE | verdict | api | Then the system attempts to send the case to DDS for eligibility assessment |  |
| CP043 | TRIAGE & DDS EVALUATION � SERVICE FAILURE | verdict | api | And the system calls DDS service |  |
| CP044 | TRIAGE & DDS EVALUATION � SERVICE FAILURE | verdict | api | And DDS service returns: SERVICE UNAVAILABLE (HTTP 503 � service down) |  |
| CP045 | DDS RETRY LOGIC | verdict | api | ? Attempt 1: DDS call ? 503 SERVICE UNAVAILABLE ? retry after 5 seconds | ? Attempt 2: DDS call ? 503 SERVICE UNAVAILABLE ? retry after 10 seconds ? Attempt 3: DDS call ? 503 SERVICE UNAVAILABLE ? MAX RETRIES EXHAUSTED |
| CP046 | DDS SERVICE DOWN � GRACEFUL ERROR HANDLING | verdict | api | Then the system determines: DDS SERVICE DOWN � CANNOT ASSESS ELIGIBILITY |  |
| CP047 | DDS SERVICE DOWN � GRACEFUL ERROR HANDLING | system | implied | And the system takes the following actions: | ? DDS Status: DOWN (3 retries failed) ? Eligibility Assessment: DEFERRED (cannot be completed) ? Case Creation: YES (create case for automatic retry when DDS re |
| CP048 | GRACEFUL ERROR MESSAGE TO CUSTOMER | bot | chat | Then the chatbot responds: | Thank you for providing all the information. I've received your claim details, but our eligibility assessment system is currently experiencing a temporary issue |
| CP049 | GRACEFUL ERROR MESSAGE TO CUSTOMER | alert | chat | And an alert information is displayed: "Claim received � processing will resume shortly." | Claim received � processing will resume shortly. |
| CP050 | CASE CREATION � DDS RETRY QUEUE | verdict | api | Then the system creates a case with status: PENDING (DDS Retry Queue) |  |
| CP051 | CASE CREATION � DDS RETRY QUEUE | system | implied | And the case contains: | � PNR: TC242 � Passenger: Fran�ois Leblanc � Journey: YUL?YYZ, June 2, 2026, delayed 4h � Identification: COMPLETED � Authentication: COMPLETED (OTP PASS) � Pas |
| CP052 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP053 | NOTIFICATION | email | email | And a Claim Received notification email is sent to f***@gmail.com |  |
| CP054 | NOTIFICATION | email | email | And the email contains: | Your Air Canada claim has been received � [CASE-REF] Your claim has been received and is being processed. We will notify you of the outcome within 15 days. Ther |
| CP055 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP056 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP057 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP058 | POST-RECOVERY � DDS AUTO-RETRY | verdict | api | When the DDS service recovers (e.g., 2 hours later) |  |
| CP059 | POST-RECOVERY � DDS AUTO-RETRY | verdict | api | Then the system automatically detects DDS recovery |  |
| CP060 | POST-RECOVERY � DDS AUTO-RETRY | verdict | api | And the system queries the DDS Retry Queue |  |
| CP061 | POST-RECOVERY � DDS AUTO-RETRY | verdict | api | And the system finds: Case [CASE-REF] for PNR TC242 � pending DDS assessment |  |
| CP062 | POST-RECOVERY � DDS AUTO-RETRY | verdict | api | And the system automatically sends the case to DDS for eligibility assessment |  |
| CP063 | POST-RECOVERY � DDS AUTO-RETRY | verdict | api | And DDS evaluates: | ? Regime: APPR ? MSL: AC 422 � YUL ? YYZ � Code 42 � Controllable ? Delay: 4h (3�6h tier) ? Result: ELIGIBLE � $400 CAD |
| CP064 | POST-RECOVERY � DDS AUTO-RETRY | verdict | api | And the case status is updated from "Pending (DDS Retry Queue)" to "Eligible" | Pending (DDS Retry Queue) Eligible |
| CP065 | POST-RECOVERY � DDS AUTO-RETRY | system | implied | And the system proceeds with CyberSource fraud screening |  |
| CP066 | POST-RECOVERY � DDS AUTO-RETRY | system | implied | And CyberSource returns: GREEN |  |
| CP067 | POST-RECOVERY � DDS AUTO-RETRY | system | implied | And the system sends eligible notification to customer |  |
| CP068 | POST-RECOVERY � DDS AUTO-RETRY | system | implied | And the customer is prompted to complete payment flow |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the case by PNR |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | TBD |
| CP072 | EXPECTED RESULTS | verdict | api | DDS failure detected after 3 retries; Graceful error message (no technical jargon); Case created with all data preserved; Auto-retry schedul | DDS failure detected after 3 retries; Graceful error message (no technical jargon); Case created with all data preserved; Auto-retry scheduled; Customer notifie |
