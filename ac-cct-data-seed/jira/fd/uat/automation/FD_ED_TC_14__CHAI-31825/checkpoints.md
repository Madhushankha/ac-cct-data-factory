# FD_ED_TC_14 · CHAI-31825 — checkpoints

**Goal:** PNR has 1 adult + 1 infant without seat (lap infant). Adult is eligible for compensation. Infant is NOT eligible under APPR. System must display clear messaging about infant ineligibility and create compensation record for adult only. Per call transcript: "Infants are not eligible for compensation in flight disruption scenarios."

Methods: seed 1, chat 51, api 18, email 3, dashboard 4, implied 23, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | PNR has 1 adult + 1 infant without seat (lap infant). Adult is eligible for compensation. Infant is NOT eligible under APPR. System must dis |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TCED14; 2 passengers: Sarah Miller (Adult) + Baby Miller (Infant, DOB: Jan 2025, no seat assigned); 1 leg AC (YUL?YYZ); Delay 4 hrs; Co | PNR: TCED14; 2 passengers: Sarah Miller (Adult) + Baby Miller (Infant, DOB: Jan 2025, no seat assigned); 1 leg AC (YUL?YYZ); Delay 4 hrs; Code 42; APPR |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "My flight from Montreal to Toronto was delayed 4 hours due to a crew issue. I was travelling with my baby. Can I get comp | My flight from Montreal to Toronto was delayed 4 hours due to a crew issue. I was travelling with my baby. Can I get compensation for both of us? |
| CP009 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP011 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP012 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP013 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP014 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP015 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Sarah Miller" | Sarah Miller |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Sarah! And, what is your booking reference number? |
| CP017 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC234" | PNR: TC234 |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC234 |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP022 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: s***@gmail.com � Phone: +1***678 |
| CP023 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: s***@gmail.com" | Email: s***@gmail.com |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP025 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP026 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP028 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP029 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP030 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP031 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP032 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 2 passengers on this booking: � Sarah Miller (Adult) � Baby Miller (Infant � No Seat, DOB: January 2025) Who would you like to include? |
| CP033 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user selects both passengers |  |
| CP034 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 2 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP035 | INFANT CHECK | system | implied | Then the system checks passenger types: | ? Sarah Miller: Adult ? ELIGIBLE for assessment ? Baby Miller: INFANT WITHOUT SEAT (DOB: January 2025, age ~17 months, lap infant, no seat assigned) ? NOT ELIGI |
| CP036 | INFANT CHECK | system | implied | Then the system notes: Only Sarah Miller (Adult) is eligible for compensation assessment; Baby Miller (Infant No Seat) is excluded per APPR  |  |
| CP037 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 422 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 2, 2026 � Arrival Delay: 4 hours Is this the journey you'd  |
| CP038 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP039 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP040 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP041 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP042 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP043 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline ? within limitation ? PROCEED |  |
| CP044 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YUL (Canada) ? APPR |  |
| CP045 | REGIME DETERMINATION | system | implied | And the system checks: Distance YUL?YYZ = ~505 km ? Short-haul |  |
| CP046 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP047 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP048 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 422, Route: YUL ? YYZ, Scheduled Arrival: 10:00 | Promised Itinerary - Flight: AC 422, Route: YUL ? YYZ, Scheduled Arrival: 10:00 |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 422, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 14:00, Delay: +4H 00M | Current Itinerary - Flight: AC 422, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 14:00, Delay: +4H 00M |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (Canadian origin � YUL) | Regime: APPR (Canadian origin � YUL) |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | Distance: ~505 km ? Short-haul | Distance: ~505 km ? Short-haul |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 422 � YUL ? YYZ � 42 | MSL FLIGHT: AC 422 � YUL ? YYZ � 42 |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42) | CONTROLLABLE (Code 42) |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | Passenger 1: MS SARAH MILLER (Adult) ? ELIGIBLE | Passenger 1: MS SARAH MILLER (Adult) ? ELIGIBLE |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Passenger 2: BABY MILLER (Infant � No Seat, DOB: Jan 2025) ? NOT ELIGIBLE (Infant No Seat) | Passenger 2: BABY MILLER (Infant � No Seat, DOB: Jan 2025) ? NOT ELIGIBLE (Infant No Seat) |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | APPR: Delay 3�6h, Controllable, Short-haul ? ELIGIBLE (adult only) | APPR: Delay 3�6h, Controllable, Short-haul ? ELIGIBLE (adult only) |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Compensation: CAD $400 (Sarah Miller only) | Compensation: CAD $400 (Sarah Miller only) |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | MS SARAH MILLER / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 | MS SARAH MILLER / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | BABY MILLER / NOT ELIGIBLE / INFANT_NO_SEAT / CAD $0 | BABY MILLER / NOT ELIGIBLE / INFANT_NO_SEAT / CAD $0 |
| CP060 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening (for eligible adult only) |  |
| CP061 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP062 | ELIGIBLE/NOT ELIGIBLE MIXED RESULT | bot | chat | Then the chatbot displays: | I've checked your flight details. Flight AC 422 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours. For Sarah Miller: Based on the Canadian Air P |
| CP063 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP064 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP065 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP066 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP067 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No (only 1 eligible pax � Sarah Miller) |  |
| CP068 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "Sarah Miller is entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days | Sarah Miller is entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP069 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP070 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP071 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada) |  |
| CP072 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer. |
| CP073 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | customer | chat | And the user provides "sarah.miller@gmail.com" | sarah.miller@gmail.com |
| CP074 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | system | implied | Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded." |  |
| CP075 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP076 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP077 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP078 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP085 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP086 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Sarah Miller: $400 CAD Baby Miller: Not eligible (infant without seat) Total Deposit Amount: $400 CAD Payment Method: Interac e-Transfer After submission, you w |
| CP087 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP088 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP089 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP090 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP091 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP092 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP093 | NOTIFICATION | email | email | And notification email is sent to s***@gmail.com |  |
| CP094 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation details (Sarah: $400 CAD eligible; Baby: not eligible � infant no seat), regulation (AP |  |
| CP095 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP096 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP097 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the case by PNR |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Case Title: "Travel Disruptions � Delay" � Status: in review/done � Regime: APPR PASSENGER INFORMATION � Sarah Miller: Tags: Claimant, Adult � ELIGIBLE ($400  |
| CP101 | EXPECTED RESULTS | verdict | dashboard | Infant without seat identified; Clear messaging about infant ineligibility under APPR; Adult claim proceeds normally; Compensation for adult | Infant without seat identified; Clear messaging about infant ineligibility under APPR; Adult claim proceeds normally; Compensation for adult only ($400); Infant |
