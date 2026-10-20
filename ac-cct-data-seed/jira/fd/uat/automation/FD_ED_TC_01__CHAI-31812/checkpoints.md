# FD_ED_TC_01 · CHAI-31812 — checkpoints

**Goal:** Validates that the chatbot can successfully identify a customer using their full name and e-ticket number when PNR is not available. Customer has 3 ticket numbers from rebookings � system must handle exchanged tickets gracefully and accept the active one. Tests Auth Flow 2 (e-ticket identification path).

Methods: seed 1, chat 55, api 26, email 3, dashboard 3, implied 23, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates that the chatbot can successfully identify a customer using their full name and e-ticket number when PNR is not available. Custome |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TCED01 exists in Trip Tracer; Customer has 3 e-ticket numbers from rebookings (014-1234567890 exchanged, 014-2345678901 exchanged, 014- | PNR: TCED01 exists in Trip Tracer; Customer has 3 e-ticket numbers from rebookings (014-1234567890 exchanged, 014-2345678901 exchanged, 014-3456789012 active);  |
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
| CP013 | IDENTIFICATION � AUTH FLOW 2 (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP014 | IDENTIFICATION � AUTH FLOW 2 (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP015 | IDENTIFICATION � AUTH FLOW 2 (GenUC-01) | customer | chat | And the user provides "Marc-Andr� Bouchard" | Marc-Andr� Bouchard |
| CP016 | IDENTIFICATION � AUTH FLOW 2 (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Marc-Andr�! And, what is your booking reference number? |
| CP017 | IDENTIFICATION � AUTH FLOW 2 (GenUC-01) | customer | chat | And the user provides "I don't have my booking reference" | I don't have my booking reference |
| CP018 | E-TICKET FALLBACK | bot | chat | Then the chatbot responds: | No problem! Can you provide your e-ticket number instead? It's a 13-digit number starting with 014 that you can find on your booking confirmation email or recei |
| CP019 | E-TICKET FALLBACK | customer | chat | And the user provides "014-1234567890" | 014-1234567890 |
| CP020 | E-TICKET LOOKUP � EXCHANGED TICKET HANDLING | verdict | api | Then the chatbot searches Trip Tracer for e-ticket: 014-1234567890 |  |
| CP021 | E-TICKET LOOKUP � EXCHANGED TICKET HANDLING | verdict | api | And Trip Tracer returns: E-TICKET FOUND but status = EXCHANGED (this ticket was exchanged during rebooking) |  |
| CP022 | E-TICKET LOOKUP � EXCHANGED TICKET HANDLING | verdict | api | And Trip Tracer identifies: This ticket was exchanged to 014-2345678901 |  |
| CP023 | E-TICKET LOOKUP � EXCHANGED TICKET HANDLING | bot | chat | Then the chatbot responds: | I found a record for that ticket number, but it appears this ticket was exchanged during a rebooking. Do you have a more recent ticket number, or would you like |
| CP024 | E-TICKET LOOKUP � EXCHANGED TICKET HANDLING | customer | chat | And the user provides "I think I have another one � 014-3456789012" | I think I have another one � 014-3456789012 |
| CP025 | E-TICKET LOOKUP � ACTIVE TICKET | verdict | api | Then the chatbot searches Trip Tracer for e-ticket: 014-3456789012 |  |
| CP026 | E-TICKET LOOKUP � ACTIVE TICKET | verdict | api | And Trip Tracer returns: E-TICKET FOUND, status = ACTIVE |  |
| CP027 | E-TICKET LOOKUP � ACTIVE TICKET | verdict | api | And Trip Tracer resolves: E-ticket 014-3456789012 ? PNR: TC219 |  |
| CP028 | E-TICKET LOOKUP � ACTIVE TICKET | verdict | api | And Trip Tracer validates: Passenger name "Marc-Andr� Bouchard" matches PNR TC219 ? NAME MATCH CONFIRMED | Marc-Andr� Bouchard |
| CP029 | E-TICKET LOOKUP � ACTIVE TICKET | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP030 | TICKET HISTORY VALIDATION | system | implied | ? E-ticket 014-1234567890: EXCHANGED ? replaced by 014-2345678901 | ? E-ticket 014-2345678901: EXCHANGED ? replaced by 014-3456789012 ? E-ticket 014-3456789012: ACTIVE ? linked to PNR TC219 ? System correctly followed the exchan |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: m***@gmail.com � Phone: +1***234 |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: m***@gmail.com" | Email: m***@gmail.com |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP036 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP038 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Marc-Andr� Bouchard (Adult) Is this who you'd like to include? |
| CP043 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP045 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 422 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 1, 2026 � Arrival Delay: 4 hours Is this the journey you'd  |
| CP046 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP047 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline ? within limitation ? PROCEED |  |
| CP052 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YUL (Canada) ? APPR |  |
| CP053 | REGIME DETERMINATION | system | implied | And the system checks: Distance YUL?YYZ = ~505 km ? Short-haul |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Identification Method: E-TICKET (Auth Flow 2) | Identification Method: E-TICKET (Auth Flow 2) |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | E-ticket Used: 014-3456789012 (ACTIVE) | E-ticket Used: 014-3456789012 (ACTIVE) |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | E-ticket History: 014-1234567890 ? EXCHANGED ? 014-2345678901 ? EXCHANGED ? 014-3456789012 (ACTIVE) | E-ticket History: 014-1234567890 ? EXCHANGED ? 014-2345678901 ? EXCHANGED ? 014-3456789012 (ACTIVE) |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | PNR Resolved: TC219 (via e-ticket cross-reference) | PNR Resolved: TC219 (via e-ticket cross-reference) |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Name Match: Marc-Andr� Bouchard ? CONFIRMED | Name Match: Marc-Andr� Bouchard ? CONFIRMED |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 422, Route: YUL ? YYZ, Scheduled Arrival: 10:00 | Promised Itinerary - Flight: AC 422, Route: YUL ? YYZ, Scheduled Arrival: 10:00 |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 422, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 14:00, Delay: +4H 00M | Current Itinerary - Flight: AC 422, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 14:00, Delay: +4H 00M |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (Canadian origin � YUL) | Regime: APPR (Canadian origin � YUL) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Distance: ~505 km ? Short-haul | Distance: ~505 km ? Short-haul |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 422 � YUL ? YYZ � 42 | MSL FLIGHT: AC 422 � YUL ? YYZ � 42 |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42) | CONTROLLABLE (Code 42) |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | APPR: Delay 3�6h, Controllable, Short-haul ? ELIGIBLE | APPR: Delay 3�6h, Controllable, Short-haul ? ELIGIBLE |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Compensation: CAD $400 | Compensation: CAD $400 |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | MR MARC-ANDR� BOUCHARD / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 | MR MARC-ANDR� BOUCHARD / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 |
| CP070 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP071 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP072 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP073 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 422 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours. Based on the Canadian Air P |
| CP074 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP075 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP076 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP077 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP078 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP079 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP080 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP081 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP082 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada) |  |
| CP083 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer. |
| CP084 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | customer | chat | And the user provides "marcandre.bouchard@gmail.com" | marcandre.bouchard@gmail.com |
| CP085 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | system | implied | Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded." |  |
| CP086 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP087 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP088 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP089 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP090 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP091 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP092 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP093 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP094 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP095 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP096 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP097 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: Interac e-Transfer After submission, you will receive a confirmation email summarizing your eligibility, claim details  |
| CP098 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP099 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP100 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP101 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP102 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP103 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP104 | NOTIFICATION | email | email | And an eligible notification email is sent to m***@gmail.com |  |
| CP105 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details (YUL?YYZ), identification method ( |  |
| CP106 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP107 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP108 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the case by PNR |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Case Title: "Travel Disruptions � Delay" � Status: in review/done � Identification Method: E-Ticket (Auth Flow 2) � E-ticket: 014-3456789012 (ACTIVE) � E-tick |
| CP112 | EXPECTED RESULTS | verdict | api | Customer identified via full name + e-ticket number; Exchanged ticket handled gracefully with prompt for newer ticket; Active ticket accepte | Customer identified via full name + e-ticket number; Exchanged ticket handled gracefully with prompt for newer ticket; Active ticket accepted; PNR resolved from |
