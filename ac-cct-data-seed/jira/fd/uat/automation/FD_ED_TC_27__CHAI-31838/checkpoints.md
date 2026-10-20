# FD_ED_TC_27 · CHAI-31838 — checkpoints

**Goal:** Per call transcript: "The Canadian equivalent of compensation amounts should be logged for reporting, and conversion rates should be standardized for exposure analysis." This TC validates that when compensation is in EUR (EU regime), the system logs both the EUR amount AND the CAD equivalent with the conversion rate used.

Methods: seed 1, chat 52, api 15, email 3, dashboard 3, implied 28, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Per call transcript: "The Canadian equivalent of compensation amounts should be logged for reporting, and conversion rates should be standar |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TCED26; 1 leg AC (CDG?YYZ); Delay 4 hrs; Code 42; EU EL-01 (�600); Customer resides in France; Payment in EUR; CAD/EUR exchange rate av | PNR: TCED26; 1 leg AC (CDG?YYZ); Delay 4 hrs; Code 42; EU EL-01 (�600); Customer resides in France; Payment in EUR; CAD/EUR exchange rate available |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "My flight from Paris to Toronto was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensati | My flight from Paris to Toronto was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation |
| CP009 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP011 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP012 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP013 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP014 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP015 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Pierre Moreau" | Pierre Moreau |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Pierre! And, what is your booking reference number? |
| CP017 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC247" | PNR: TC247 |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC247 |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP022 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: p***@gmail.com � Phone: +33789 |
| CP023 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: p@gmail.com" | Email: p@gmail.com |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP025 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP026 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP028 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP029 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP030 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP031 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP032 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Pierre Moreau (Adult) Is this who you'd like to include? |
| CP033 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP034 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP035 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 871 � Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ) � Date: June 1, 2026 � Arrival Delay: 4 hours Is this the |
| CP036 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP037 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP038 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP039 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP040 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP041 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (France = 5 years) ? within limitation ? PROCEED |  |
| CP042 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = CDG (Paris, France, EU) ? EU 261 |  |
| CP043 | REGIME DETERMINATION | system | implied | And the system checks: Distance CDG?YYZ = ~5,900 km ? Long-haul (>3500km) |  |
| CP044 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP045 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP046 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 871, Route: CDG ? YYZ, Scheduled Arrival: 13:00 | Promised Itinerary - Flight: AC 871, Route: CDG ? YYZ, Scheduled Arrival: 13:00 |
| CP047 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 871, Route: CDG ? YYZ, Status: ARRIVED LATE, Actual: 17:00, Delay: +4H 00M | Current Itinerary - Flight: AC 871, Route: CDG ? YYZ, Status: ARRIVED LATE, Actual: 17:00, Delay: +4H 00M |
| CP048 | TRIP TRACER UI VALIDATION | verdict | api | Regime: EU 261 (EU origin � CDG) | Regime: EU 261 (EU origin � CDG) |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Distance: ~5,900 km ? Long-haul (>3500km) | Distance: ~5,900 km ? Long-haul (>3500km) |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 871 � CDG ? YYZ � 42 | MSL FLIGHT: AC 871 � CDG ? YYZ � 42 |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42) | CONTROLLABLE (Code 42) |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | EU 261: Delay 4h, Controllable, Long-haul ? ELIGIBLE | EU 261: Delay 4h, Controllable, Long-haul ? ELIGIBLE |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | Compensation: �600 (EU 261 long-haul rate) | Compensation: �600 (EU 261 long-haul rate) |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | MR PIERRE MOREAU / ELIGIBLE / EU261_DELAY_GTE_4_HOURS_LONG_HAUL / �600 | MR PIERRE MOREAU / ELIGIBLE / EU261_DELAY_GTE_4_HOURS_LONG_HAUL / �600 |
| CP055 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP056 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP057 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP058 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 871 from Paris Charles de Gaulle (CDG) to Toronto (YYZ) was delayed by about 4 hours. Based on EU  |
| CP059 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP060 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "France" | France |
| CP061 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = France ? Currency = EUR ? Payment Method = Bank Transfer (SEPA) |  |
| CP062 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP063 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP064 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive �600 compensation. Please note that it will take 5 to 10 business days to process pa | You are entitled to receive �600 compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP065 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency (EUR)." | Please note that payments will be deposited in your local currency (EUR). |
| CP066 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP067 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Bank Transfer (SEPA) |  |
| CP068 | PAYMENT METHOD � BANK TRANSFER SEPA (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through SEPA bank transfer. Before we move forward, please provide your bank details for the transfer. |
| CP069 | PAYMENT METHOD � BANK TRANSFER SEPA (FD-07) | system | implied | And the chatbot collects: | � Account holder name � IBAN � BIC/SWIFT |
| CP070 | PAYMENT METHOD � BANK TRANSFER SEPA (FD-07) | customer | chat | And the user provides: | � Account holder name: Pierre Moreau � IBAN: FR76 3000 6000 0112 3456 7890 189 � BIC: AGRIFRPP |
| CP071 | PAYMENT METHOD � BANK TRANSFER SEPA (FD-07) | system | implied | Then the chatbot confirms: "Thank you. Your SEPA bank transfer details have been recorded." |  |
| CP072 | PAYMENT METHOD � BANK TRANSFER SEPA (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP073 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP074 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP075 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP076 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP077 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP078 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP083 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �600 Payment Method: SEPA Bank Transfer After submission, you will receive a confirmation email summarizing your eligibility, claim details and  |
| CP084 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP085 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP086 | CASE CREATION � WITH CURRENCY CONVERSION LOGGING (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP087 | CASE CREATION � WITH CURRENCY CONVERSION LOGGING (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP088 | CASE CREATION � WITH CURRENCY CONVERSION LOGGING (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP089 | CURRENCY CONVERSION LOGGING | system | implied | Then the system logs the following for reporting purposes: | ? Compensation Amount (Original): �600 EUR ? Exchange Rate Used: 1 EUR = 1.4850 CAD (standardized rate as of June 15, 2026) ? CAD Equivalent: $891.00 CAD (�600  |
| CP090 | REPORTING DATA STRUCTURE | system | implied | ? Case Reference: [CASE-REF] | ? Regime: EU 261 ? Compensation Currency: EUR ? Compensation Amount (EUR): �600.00 ? CAD Equivalent Amount: $891.00 CAD ? Exchange Rate: 1.4850 EUR/CAD ? Exchan |
| CP091 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP092 | NOTIFICATION | email | email | And an eligible notification email is sent to p***@gmail.com |  |
| CP093 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�600 � EUR only, NOT CAD equivalent), regulation (EU 261), flight details, paym | NOTE: Customer notification shows EUR amount ONLY. CAD equivalent is internal reporting data only. |
| CP094 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP095 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP096 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the case by PNR |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Case Title: "Travel Disruptions � Delay" � Status: in review/done � Regime: EU 261 � Compensation (EUR): �600.00 � CAD Equivalent: $891.00 CAD � Exchange Rate |
| CP100 | REPORTING VALIDATION | system | implied | When the reporting team runs the exposure analysis report |  |
| CP101 | REPORTING VALIDATION | system | implied | Then the report includes: | ? Case [CASE-REF]: �600 EUR / $891.00 CAD at 1.4850 EUR/CAD ? ? Exchange rate standardized: YES (Bank of Canada daily rate) ? ? CAD equivalent logged: YES ? ? E |
| CP102 | CURRENCY CONVERSION VALIDATION | system | implied | ? Compensation in original currency (EUR): �600.00 ? | ? CAD equivalent calculated: $891.00 CAD ? ? Exchange rate used: 1.4850 EUR/CAD ? ? Exchange rate source: Bank of Canada ? ? Exchange rate date: June 15, 2026 ? |
| CP103 | EXPECTED RESULTS | verdict | chat | EU compensation (�600) correctly determined as most generous; CAD equivalent ($880.02) logged for reporting; Exchange rate, source, and date | EU compensation (�600) correctly determined as most generous; CAD equivalent ($880.02) logged for reporting; Exchange rate, source, and date documented; APPR al |
