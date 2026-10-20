# FD_ED_TC_07 · CHAI-31818 — checkpoints

**Goal:** Customer's OTP fails 5 times, IDV is offered, but IDV also fails (document unreadable, face mismatch). Case is created with all flight disruption data (Code 64 Flight Crew Shortage � Controllable, 4h delay, 3�<6h band, APPR domestic YUL?YYZ) and sent for manual eligibility determination. Tests the IDV Link-Non Biometric Flow ? Manual Handling Request Flow from Miro. DDS evaluation deferred until authentication is resolved by manual team.

Methods: seed 2, chat 42, api 3, email 3, dashboard 3, implied 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer's OTP fails 5 times, IDV is offered, but IDV also fails (document unreadable, face mismatch). Case is created with all flight disru |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TCED06; Journey: 1 leg AC domestic YUL?YYZ; Scheduled arrival: 14:00; Actual arrival: 18:00 (4hr delay, 3�<6h band); Arrival delay code | PNR: TCED06; Journey: 1 leg AC domestic YUL?YYZ; Scheduled arrival: 14:00; Actual arrival: 18:00 (4hr delay, 3�<6h band); Arrival delay code: 64 (Flight Crew Sh |
| CP003 | PREREQUISITES | prerequisite | seed | Baseline APPR Tier 1 compensation if eligible: $400 CAD (pending auth resolution) | Baseline APPR Tier 1 compensation if eligible: $400 CAD (pending auth resolution) |
| CP004 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP005 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP006 | START | customer | chat | Then user selects English |  |
| CP007 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP008 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP009 | START | customer | chat | And the user says "My flight from Montreal to Toronto was delayed 4 hours due to crew issues. I'd like to file a compensation claim" | My flight from Montreal to Toronto was delayed 4 hours due to crew issues. I'd like to file a compensation claim |
| CP010 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP011 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP012 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP013 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP014 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP015 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP016 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Laurent Pelletier" | Laurent Pelletier |
| CP017 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Laurent! And, what is your booking reference number? |
| CP018 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC225" | PNR: TC225 |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC225 |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP021 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP022 | AUTHENTICATION � OTP ATTEMPTS (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP023 | AUTHENTICATION � OTP ATTEMPTS (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: l***@gmail.com � Phone: +1***456 |
| CP024 | AUTHENTICATION � OTP ATTEMPTS (GenUC-05) | customer | chat | And the user selects "Email: l***@gmail.com" | Email: l***@gmail.com |
| CP025 | AUTHENTICATION � OTP ATTEMPTS (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP026 | OTP ATTEMPT 1 OF 5 | customer | chat | And the user provides the OTP code "111111" | 111111 |
| CP027 | OTP ATTEMPT 1 OF 5 | system | implied | Then the chatbot validates the OTP code ? INCORRECT (attempt 1 of 5) |  |
| CP028 | OTP ATTEMPT 1 OF 5 | bot | chat | Then the chatbot responds: | The code you entered is incorrect. Please try again. You have 4 attempts remaining. |
| CP029 | OTP ATTEMPT 2 OF 5 | customer | chat | And the user provides the OTP code "222222" | 222222 |
| CP030 | OTP ATTEMPT 2 OF 5 | system | implied | Then the chatbot validates the OTP code ? INCORRECT (attempt 2 of 5) |  |
| CP031 | OTP ATTEMPT 2 OF 5 | bot | chat | Then the chatbot responds: | The code you entered is incorrect. Please try again. You have 3 attempts remaining. |
| CP032 | OTP ATTEMPT 3 OF 5 | customer | chat | And the user provides the OTP code "333333" | 333333 |
| CP033 | OTP ATTEMPT 3 OF 5 | system | implied | Then the chatbot validates the OTP code ? INCORRECT (attempt 3 of 5) |  |
| CP034 | OTP ATTEMPT 3 OF 5 | bot | chat | Then the chatbot responds: | The code you entered is incorrect. Please try again. You have 2 attempts remaining. |
| CP035 | OTP ATTEMPT 4 OF 5 | customer | chat | And the user provides the OTP code "444444" | 444444 |
| CP036 | OTP ATTEMPT 4 OF 5 | system | implied | Then the chatbot validates the OTP code ? INCORRECT (attempt 4 of 5) |  |
| CP037 | OTP ATTEMPT 4 OF 5 | bot | chat | Then the chatbot responds: | The code you entered is incorrect. Please try again. You have 1 attempt remaining. |
| CP038 | OTP ATTEMPT 5 OF 5 | customer | chat | And the user provides the OTP code "555555" | 555555 |
| CP039 | OTP ATTEMPT 5 OF 5 | system | implied | Then the chatbot validates the OTP code ? INCORRECT (attempt 5 of 5) |  |
| CP040 | OTP ATTEMPT 5 OF 5 | system | implied | Then the system determines: OTP MAXIMUM ATTEMPTS REACHED (5/5) |  |
| CP041 | OTP FAILURE ? IDV OFFERED IMMEDIATELY | bot | chat | Then the chatbot responds: | You've reached the maximum number of verification attempts. Don't worry � I can verify your identity another way. I'll send you a secure link to verify your ide |
| CP042 | IDV LINK � NON-BIOMETRIC FLOW | bot | chat | Then the chatbot responds: | Please click the link below to verify your identity. You'll need a valid government-issued photo ID (passport, driver's license, or national ID card). |
| CP043 | IDV LINK � NON-BIOMETRIC FLOW | bot | chat | And chatbot displays a button "Verify my identity" | Verify my identity |
| CP044 | IDV LINK � NON-BIOMETRIC FLOW | customer | chat | When user clicks on the button |  |
| CP045 | IDV LINK � NON-BIOMETRIC FLOW | idv | chat | Then the chatbot sends Persona IDV link to the customer |  |
| CP046 | IDV LINK � NON-BIOMETRIC FLOW | customer | chat | And the customer opens the Persona link |  |
| CP047 | PERSONA IDV PROCESS � FAILURE | system | implied | And the customer attempts all steps: | ? ID Type: Canadian Driver's License ? Front of ID: Uploaded � BLURRY / UNREADABLE (document quality insufficient) ? Back of ID: Uploaded � PARTIALLY OBSCURED ? |
| CP048 | PERSONA IDV PROCESS � FAILURE | idv | chat | And Persona evaluates: | ? Document Quality: FAIL (below minimum threshold � text unreadable) ? Face Match: FAIL (confidence score below threshold) ? Overall Result: IDV FAIL |
| CP049 | PERSONA IDV PROCESS � FAILURE | idv | chat | And Persona returns: IDV FAIL (reason: document quality insufficient + face mismatch) |  |
| CP050 | IDV FAILURE � BOTH AUTH METHODS EXHAUSTED | bot | chat | Then the chatbot responds: | I'm sorry, but we were unable to verify your identity at this time. The document provided could not be read clearly, and the face verification was unsuccessful. |
| CP051 | CASE CREATION � MANUAL HANDLING | system | implied | Then the system creates a case with status: PENDING MANUAL HANDLING (Authentication Failure) |  |
| CP052 | CASE CREATION � MANUAL HANDLING | idv | chat | And the case contains: | � PNR: TC225 � Passenger: Laurent Pelletier � Journey: YUL ? YYZ (AC domestic), delayed 4h (3�<6h band) � Scheduled Arrival: 14:00 ? Actual Arrival: 18:00 � Arr |
| CP053 | CASE CREATION � MANUAL HANDLING | bot | chat | Then the chatbot responds: | Your case has been created and forwarded to our Customer Relations team. Your case reference number is [CASE-REF]. A team member will contact you within 15 busi |
| CP054 | CASE CREATION � MANUAL HANDLING | alert | chat | And an alert information is displayed: "Case created for manual review." | Case created for manual review. |
| CP055 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP056 | NOTIFICATION | email | email | And a Manual Handling notification email is sent to l***@gmail.com |  |
| CP057 | NOTIFICATION | email | email | And the email contains: | Your Air Canada claim requires additional verification � [CASE-REF] We were unable to verify your identity automatically. Our Customer Relations team will conta |
| CP058 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP059 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP060 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP061 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP062 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the case by PNR |  |
| CP063 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Case Title: "Travel Disruptions � Authentication Failure" � Status: Pending Manual Handling � Created: [date populated] � Last updated at: [date populated] �  |
| CP064 | CASE OVERVIEW | idv | chat | � Claimant Name: Laurent Pelletier | � Authentication Status: FAILED � OTP: 5/5 INCORRECT � IDV: FAIL (document quality + face mismatch) � PNR: TC225 � Journey: YUL ? YYZ (AC domestic, DELAYED +4h, |
