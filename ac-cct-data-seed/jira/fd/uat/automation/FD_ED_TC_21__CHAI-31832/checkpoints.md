# FD_ED_TC_21 · CHAI-31832 — checkpoints

**Goal:** Customer starts FD flow, gets distracted, returns 2 hours later. Tests session timeout handling and whether customer can resume or must restart. Per call transcript: session expiration and inactivity conditions need testing.

Methods: seed 1, chat 34, api 5, implied 13, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer starts FD flow, gets distracted, returns 2 hours later. Tests session timeout handling and whether customer can resume or must rest |  |
| CP002 | PREREQUISITES | prerequisite | seed | Session timeout configured (e.g., 30 minutes of inactivity); Customer starts flow, completes identification, then goes inactive | Session timeout configured (e.g., 30 minutes of inactivity); Customer starts flow, completes identification, then goes inactive |
| CP003 | PHASE 1 � INITIAL SESSION | customer | chat | Given the user opens the agentic chatbot at 14:00 |  |
| CP004 | PHASE 1 � INITIAL SESSION | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | PHASE 1 � INITIAL SESSION | customer | chat | Then user selects English |  |
| CP006 | PHASE 1 � INITIAL SESSION | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | PHASE 1 � INITIAL SESSION | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | PHASE 1 � INITIAL SESSION | customer | chat | And the user says "My flight from Montreal to Toronto was delayed 4 hours. I'd like to file a compensation claim" | My flight from Montreal to Toronto was delayed 4 hours. I'd like to file a compensation claim |
| CP009 | PHASE 1 � INITIAL SESSION | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | PHASE 1 � INITIAL SESSION | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP011 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process... |
| CP012 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP013 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Nathalie C�t�" | Nathalie C�t� |
| CP014 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Nathalie! And, what is your booking reference number? |
| CP015 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC242" | PNR: TC242 |
| CP016 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC242 |  |
| CP017 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data is revealed |  |
| CP019 | SESSION STATE AT 14:05 | system | implied | ? Session ID: SES-20260615-1400-001 | ? Session Status: ACTIVE ? Last Activity: 14:05 ? Progress: Identification COMPLETED (name + PNR found) ? Next Step: Authentication (OTP) ? Session Timeout: 30  |
| CP020 | PHASE 2 � INACTIVITY | system | implied | At 14:05, the customer gets distracted and stops interacting with the chatbot. |  |
| CP021 | INACTIVITY MONITORING | system | implied | ? 14:05 � Last customer interaction | ? 14:15 � 10 minutes inactive (no action) ? 14:25 � 20 minutes inactive (no action) ? 14:30 � 25 minutes inactive � WARNING THRESHOLD APPROACHING |
| CP022 | INACTIVITY WARNING | bot | chat | Then the chatbot displays an inactivity warning: | Are you still there? Your session will expire in 5 minutes due to inactivity. Please respond to continue. |
| CP023 | SESSION EXPIRATION | system | implied | Then the system determines: SESSION EXPIRED (30 minutes of inactivity) |  |
| CP024 | SESSION EXPIRATION | system | implied | And the system takes the following actions: | ? Session ID: SES-20260615-1400-001 ? EXPIRED ? Session data: CLEARED (for security � PNR data, passenger info purged from active session) ? Authentication stat |
| CP025 | SESSION EXPIRATION | bot | chat | Then the chatbot displays: | Your session has expired due to inactivity. For your security, you'll need to start a new session. Don't worry � you can return anytime to file your claim. |
| CP026 | PHASE 3 � CUSTOMER RETURNS | system | implied | At 16:05, the customer returns to the chatbot (2 hours after session expired). |  |
| CP027 | PHASE 3 � CUSTOMER RETURNS | customer | chat | Given the user opens the agentic chatbot at 16:05 |  |
| CP028 | PHASE 3 � CUSTOMER RETURNS | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? resume |
| CP029 | PHASE 3 � CUSTOMER RETURNS | customer | chat | Then user selects English |  |
| CP030 | PHASE 3 � CUSTOMER RETURNS | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP031 | PHASE 3 � CUSTOMER RETURNS | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP032 | PHASE 3 � CUSTOMER RETURNS | customer | chat | And the user says "I was trying to file a compensation claim earlier but got distracted. Can I continue?" | I was trying to file a compensation claim earlier but got distracted. Can I continue? |
| CP033 | SESSION RESUME CHECK | system | implied | Then the system checks: Is there an active session for this user? ? NO (session expired) |  |
| CP034 | SESSION RESUME CHECK | system | implied | Then the system checks: Is there a saved progress state? ? PARTIAL (PNR TC242 looked up, but authentication not completed) |  |
| CP035 | SESSION RESUME CHECK | system | implied | Then the system determines: CANNOT RESUME � AUTHENTICATION NOT COMPLETED ? MUST RESTART |  |
| CP036 | RESTART FLOW | bot | chat | Then the chatbot responds: | I see you started a claim earlier but your session expired due to inactivity. For security reasons, since your identity wasn't fully verified, you'll need to st |
| CP037 | RESTART FLOW | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP038 | RESTART FLOW | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP039 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process... |
| CP040 | IDENTIFICATION � RESTART (GenUC-01) | bot | chat | Then the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP041 | IDENTIFICATION � RESTART (GenUC-01) | customer | chat | And the user provides "Nathalie C�t�" | Nathalie C�t� |
| CP042 | IDENTIFICATION � RESTART (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Nathalie! And, what is your booking reference number? |
| CP043 | IDENTIFICATION � RESTART (GenUC-01) | customer | chat | And the user provides "PNR: TC242" | PNR: TC242 |
| CP044 | IDENTIFICATION � RESTART (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC242 |  |
| CP045 | IDENTIFICATION � RESTART (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND | NOTE: From this point, the standard FD flow continues from the beginning (authentication ? passenger selection ? journey selection ? DDS ? result). The customer |
| CP046 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP047 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: n***@gmail.com � Phone: +1***789 |
| CP048 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: n***@gmail.com" | Email: n***@gmail.com |
| CP049 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP050 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP051 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP052 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP053 | SESSION EXPIRATION VALIDATION | system | implied | ? Session timeout: 30 minutes ? | ? Inactivity warning at 25 minutes: YES ? ? Session expired at 30 minutes: YES ? ? Session data cleared (security): YES ? ? Authentication state reset: YES ? ?  |
| CP054 | EXPECTED RESULTS | verdict | chat | Session timeout detected after 30 min inactivity; 5-minute warning sent; Session expired; Data preserved; Customer returns and offered resum | Session timeout detected after 30 min inactivity; 5-minute warning sent; Session expired; Data preserved; Customer returns and offered resume option; Re-authent |
