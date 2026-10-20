# FD_ED_TC_02 · CHAI-31813 — checkpoints

**Goal:** Validates that when a customer is logged into their Aeroplan profile, the system bypasses OTP authentication entirely and proceeds directly to passenger selection. Also tests AC Wallet payout since customer has active Aeroplan.

Methods: seed 1, chat 41, api 20, email 3, dashboard 3, implied 27, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates that when a customer is logged into their Aeroplan profile, the system bypasses OTP authentication entirely and proceeds directly  |  |
| CP002 | PREREQUISITES | prerequisite | seed | Customer logged into Aeroplan profile (session active); Aeroplan #: 1234567890; PNR: TCED02; 1 leg AC (YYZ?YVR); Delay 4 hrs; Code 42; APPR; | Customer logged into Aeroplan profile (session active); Aeroplan #: 1234567890; PNR: TCED02; 1 leg AC (YYZ?YVR); Delay 4 hrs; Code 42; APPR; Aeroplan account ac |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | system | implied | And the user is LOGGED INTO THEIR AEROPLAN PROFILE (active session detected) |  |
| CP005 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP006 | START | customer | chat | Then user selects English |  |
| CP007 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP008 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP009 | START | customer | chat | And the user says "My flight from Toronto to Vancouver was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compen | My flight from Toronto to Vancouver was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation |
| CP010 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP011 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP012 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP013 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP014 | IDENTIFICATION � AEROPLAN LOGIN DETECTED (GenUC-01) | system | implied | Then the chatbot detects: AEROPLAN SESSION ACTIVE (Aeroplan #: 1234567890) |  |
| CP015 | IDENTIFICATION � AEROPLAN LOGIN DETECTED (GenUC-01) | bot | chat | And the chatbot responds: | I can see you're logged into your Aeroplan account. Let me pull up your information. |
| CP016 | IDENTIFICATION � AEROPLAN LOGIN DETECTED (GenUC-01) | system | implied | And the system automatically retrieves: Customer name, Aeroplan number, associated PNRs |  |
| CP017 | IDENTIFICATION � AEROPLAN LOGIN DETECTED (GenUC-01) | system | implied | And the system identifies: Aeroplan #1234567890 ? Customer: "Sophie Tremblay" |  |
| CP018 | IDENTIFICATION � AEROPLAN LOGIN DETECTED (GenUC-01) | bot | chat | And the chatbot responds: | Hi Sophie! I can see your Aeroplan profile. What is your booking reference number? |
| CP019 | IDENTIFICATION � AEROPLAN LOGIN DETECTED (GenUC-01) | customer | chat | And the user provides "PNR: TC220" | PNR: TC220 |
| CP020 | IDENTIFICATION � AEROPLAN LOGIN DETECTED (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC220 |  |
| CP021 | IDENTIFICATION � AEROPLAN LOGIN DETECTED (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP022 | IDENTIFICATION � AEROPLAN LOGIN DETECTED (GenUC-01) | verdict | api | And Trip Tracer validates: Aeroplan #1234567890 matches PNR TC220 ? AEROPLAN MATCH CONFIRMED |  |
| CP023 | IDENTIFICATION � AEROPLAN LOGIN DETECTED (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP024 | AUTHENTICATION � OTP BYPASSED | system | implied | Then the system checks: Is customer authenticated via Aeroplan login? ? YES (active session) |  |
| CP025 | AUTHENTICATION � OTP BYPASSED | system | implied | Then the system determines: OTP AUTHENTICATION BYPASSED � Aeroplan login provides sufficient identity verification |  |
| CP026 | AUTHENTICATION � OTP BYPASSED | bot | chat | Then the chatbot responds: | Since you're already logged into your Aeroplan account, we've verified your identity. Let's proceed to the next step. |
| CP027 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP028 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP029 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP030 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP031 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Sophie Tremblay (Adult) Is this who you'd like to include? |
| CP032 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP033 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP034 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 103 � Route: Toronto (YYZ) ? Vancouver (YVR) � Date: June 1, 2026 � Arrival Delay: 4 hours Is this the journey you'd |
| CP035 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP036 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP037 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP038 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP039 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP040 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline ? within limitation ? PROCEED |  |
| CP041 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YYZ (Canada) ? APPR |  |
| CP042 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP043 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP044 | TRIP TRACER UI VALIDATION | verdict | api | Identification Method: AEROPLAN LOGIN (Session Active) | Identification Method: AEROPLAN LOGIN (Session Active) |
| CP045 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan #: 1234567890 | Aeroplan #: 1234567890 |
| CP046 | TRIP TRACER UI VALIDATION | verdict | api | OTP: BYPASSED (Aeroplan login authentication) | OTP: BYPASSED (Aeroplan login authentication) |
| CP047 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 103, Route: YYZ ? YVR, Scheduled Arrival: 14:00 | Promised Itinerary - Flight: AC 103, Route: YYZ ? YVR, Scheduled Arrival: 14:00 |
| CP048 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 103, Route: YYZ ? YVR, Status: ARRIVED LATE, Actual: 18:00, Delay: +4H 00M | Current Itinerary - Flight: AC 103, Route: YYZ ? YVR, Status: ARRIVED LATE, Actual: 18:00, Delay: +4H 00M |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (Canadian origin � YYZ) | Regime: APPR (Canadian origin � YYZ) |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 103 � YYZ ? YVR � 42 | MSL FLIGHT: AC 103 � YYZ ? YVR � 42 |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42) | CONTROLLABLE (Code 42) |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | APPR: Delay 3�6h, Controllable ? ELIGIBLE | APPR: Delay 3�6h, Controllable ? ELIGIBLE |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | Compensation: CAD $400 | Compensation: CAD $400 |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan Account: ACTIVE (not frozen) ? AC Wallet eligible | Aeroplan Account: ACTIVE (not frozen) ? AC Wallet eligible |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | MS SOPHIE TREMBLAY / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 | MS SOPHIE TREMBLAY / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 |
| CP056 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP057 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP058 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP059 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 103 from Toronto (YYZ) to Vancouver (YVR) was delayed by about 4 hours. Based on the Canadian Air  |
| CP060 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP061 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP062 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP063 | CASH vs AC WALLET CHECK � AEROPLAN ACTIVE (FD-06a) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (Aeroplan #: 1234567890) |  |
| CP064 | CASH vs AC WALLET CHECK � AEROPLAN ACTIVE (FD-06a) | system | implied | Then the chatbot checks: Is Aeroplan account active (not frozen)? ? YES |  |
| CP065 | CASH vs AC WALLET CHECK � AEROPLAN ACTIVE (FD-06a) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP066 | CASH vs AC WALLET CHECK � AEROPLAN ACTIVE (FD-06a) | bot | chat | Then the chatbot responds: | You are entitled to receive a $400 CAD compensation. You can choose to receive this as: � Cash � $400 CAD via Interac e-Transfer (5�10 business days) � AC Walle |
| CP067 | CASH vs AC WALLET CHECK � AEROPLAN ACTIVE (FD-06a) | customer | chat | And the user selects "AC Wallet" | AC Wallet |
| CP068 | AC WALLET PAYOUT (FD-06a) | system | implied | Then the chatbot confirms: | "Great choice! You'll receive $480 CAD in AC Wallet credits, which will be available in your Aeroplan account immediately after processing." |
| CP069 | AC WALLET PAYOUT (FD-06a) | system | implied | And the system records: Payment method = AC Wallet; Amount = $480 CAD; Aeroplan #: 1234567890 |  |
| CP070 | AC WALLET PAYOUT (FD-06a) | idv | chat | Then system checks that IDV is not completed |  |
| CP071 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP072 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP073 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP074 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP075 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP076 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP077 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP078 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP081 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $480 CAD Payment Method: AC Wallet (Aeroplan #: 1234567890) After submission, you will receive a confirmation email summarizing your eligibility |
| CP082 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP083 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP084 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP085 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP086 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP087 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP088 | NOTIFICATION | email | email | And an eligible notification email is sent to the customer's email on file |  |
| CP089 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($480 CAD AC Wallet credits), payment method (AC Wallet), Aeroplan number, regul |  |
| CP090 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP091 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP092 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the case by PNR |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Case Title: "Travel Disruptions � Delay" � Status: in review/done � Identification Method: Aeroplan Login (OTP Bypassed) � Aeroplan #: 1234567890 � Payment Me |
| CP096 | EXPECTED RESULTS | verdict | api | Customer identified via Aeroplan login session; OTP/IDV completely bypassed; AC Wallet offered and selected; EAP check confirms account acti | Customer identified via Aeroplan login session; OTP/IDV completely bypassed; AC Wallet offered and selected; EAP check confirms account active; Payment deposite |
