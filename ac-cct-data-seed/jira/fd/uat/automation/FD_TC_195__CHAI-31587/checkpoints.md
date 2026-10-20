# FD_TC_195 · CHAI-31587 — checkpoints

**Goal:** Customer's ticket was voluntarily changed via ATC (VOL), then an agent with ACNP changed the flight (INVOL). Validates that the promise updates to the last VOL arrival (11:30) and that the subsequent Agent+ACNP does NOT further update the promise.

Methods: seed 1, chat 58, api 19, email 3, dashboard 33, implied 20, manual 9, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer's ticket was voluntarily changed via ATC (VOL), then an agent with ACNP changed the flight (INVOL). Validates that the promise upda |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (V�ronique Lambert); 1 leg AC YUL?YYZ; Original (14-day) arrival: 10:00; Change 1 (D-5): ATC VOL ? new arrival 11:30;  | PNR: Single passenger (V�ronique Lambert); 1 leg AC YUL?YYZ; Original (14-day) arrival: 10:00; Change 1 (D-5): ATC VOL ? new arrival 11:30; Change 2 (D-1): Agen |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "I changed my ticket last week, then an agent changed my flight again because of a disruption. I arrived 4 and a half hour | I changed my ticket last week, then an agent changed my flight again because of a disruption. I arrived 4 and a half hours late. Can I get compensation? |
| CP009 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP011 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP012 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP013 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP014 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP015 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "V�ronique Lambert" | V�ronique Lambert |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, V�ronique! And, what is your booking reference number? |
| CP017 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TCCOMBO05" | PNR: TCCOMBO05 |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TCCOMBO05 |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP022 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: v***@gmail.com � Phone: +1***678 |
| CP023 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: v***@gmail.com" | Email: v***@gmail.com |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP025 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP026 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP028 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP029 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP030 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP031 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP032 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � V�ronique Lambert (Adult) Is this who you'd like to include? |
| CP033 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP034 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP035 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 429 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 12, 2026 � Arrival Delay: 4.5 hours Is this the journey you |
| CP036 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP037 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP038 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP039 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP040 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP041 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YUL (Canada) ? APPR |  |
| CP042 | TRIAGE & DDS EVALUATION � VOL THEN INVOL DETECTED | verdict | api | Then the DDS evaluation is done in backend |  |
| CP043 | TRIAGE & DDS EVALUATION � VOL THEN INVOL DETECTED | verdict | api | And DDS checks booking change history: | ? Change 1 (D-5): ATC (Amadeus Ticket Changes) transaction ? Classification: VOL (ATC = voluntary ticket reissue/change) ? ATC changed arrival from 10:00 ? 11:3 |
| CP044 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 429, Route: YUL ? YYZ, Scheduled Arrival: 11:30 (updated by ATC VOL, NOT further updated by Agent+ACNP) | Promised Itinerary - Flight: AC 429, Route: YUL ? YYZ, Scheduled Arrival: 11:30 (updated by ATC VOL, NOT further updated by Agent+ACNP) |
| CP045 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 429, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 16:00, Delay: +4H 30M | Current Itinerary - Flight: AC 429, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 16:00, Delay: +4H 30M |
| CP046 | TRIP TRACER UI VALIDATION | verdict | api | Change 1: ATC (Amadeus Ticket Changes) at D-5 � VOL � arrival 10:00 ? 11:30 � PROMISE UPDATED | Change 1: ATC (Amadeus Ticket Changes) at D-5 � VOL � arrival 10:00 ? 11:30 � PROMISE UPDATED |
| CP047 | TRIP TRACER UI VALIDATION | verdict | api | Change 2: Agent with ACNP (SK ACNP) at D-1 � INVOL � arrival 11:30 ? 16:00 � PROMISE NOT UPDATED | Change 2: Agent with ACNP (SK ACNP) at D-1 � INVOL � arrival 11:30 ? 16:00 � PROMISE NOT UPDATED |
| CP048 | TRIP TRACER UI VALIDATION | verdict | api | Promise = 11:30 (last VOL before first INVOL) | Promise = 11:30 (last VOL before first INVOL) |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Delay from promise = 4.5 hours (16:00 - 11:30) | Delay from promise = 4.5 hours (16:00 - 11:30) |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR | Regime: APPR |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | APPR: Delay 3�6h, Controllable ? ELIGIBLE | APPR: Delay 3�6h, Controllable ? ELIGIBLE |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 429 � YUL ? YYZ � 42 | MSL FLIGHT: AC 429 � YUL ? YYZ � 42 |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42) | CONTROLLABLE (Code 42) |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | CRITICAL: ACNP presence on Change 2 confirms INVOL classification � same agent action WITHOUT ACNP would be VOL and would update promise | CRITICAL: ACNP presence on Change 2 confirms INVOL classification � same agent action WITHOUT ACNP would be VOL and would update promise |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | MS V�RONIQUE LAMBERT / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 | MS V�RONIQUE LAMBERT / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 |
| CP056 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP057 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP058 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP059 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 429 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours and 30 minutes. Based on the |
| CP060 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP061 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP062 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP063 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP064 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP065 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP066 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP067 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP068 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada) |  |
| CP069 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer. |
| CP070 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | customer | chat | And the user provides "veronique.lambert@gmail.com" | veronique.lambert@gmail.com |
| CP071 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | system | implied | Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded." |  |
| CP072 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
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
| CP083 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: Interac e-Transfer After submission, you will receive a confirmation email summarizing your eligibility, claim details  |
| CP084 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP085 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP086 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP087 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP088 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP089 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP090 | NOTIFICATION | email | email | And an eligible notification email is sent to v***@gmail.com |  |
| CP091 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details (AC 429, YUL?YYZ, 4.5hr delay from |  |
| CP092 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP093 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP094 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "V�ronique Lambert" with PNR "TCCOMBO05" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "V�ronique Lambert" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TCCOMBO05" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "V�ronique Lambert" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility should be "ELIGIBLE" under APPR with compensation "$400 CAD" Tier 1 3 to less than 6hrs controllable |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Change History should show Change 1 ATC Amadeus Ticket Changes at D-5 as VOL with arrival 10:00 to 11:30 and PROMISE UPDATED and Cha |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Promise should be 11:30 as last VOL before first INVOL NOT 14-day mark 10:00 |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Actual should be 16:00 |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay should be 4.5hrs from VOL-updated promise |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And Agent plus ACNP should NOT have overridden the VOL-updated promise and ACNP should confirm INVOL classification |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And VOL should have been detected via ATC with promise updated to 11:30 |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And INVOL should have been detected via Agent plus ACNP SK ACNP with promise NOT further updated |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be ELIGIBLE at $400 CAD |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "V�ronique Lambert + TCCOMBO05 + YUL?YYZ + FD" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing Case Reference and compensation $400 CAD and regulation APPR a |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record ATC VOL at D-5 promise 10:00 to 11:30 then Agent plus ACNP INVOL at D-1 SK ACNP promise unchanged at 11:30 a |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should note ACNP presence on Change 2 confirms INVOL and same agent action without ACNP would be VOL |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP135 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP136 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP138 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP139 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "$400 CAD" APPR Tier 1 3 to less than 6hrs controllable |  |
| CP140 | PAYMENT VALIDATION | payment | chat | And IDV at Payment should be triggered via Persona and Persona should return IDV PASS |  |
| CP141 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP142 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier and Unifier should process Interac e-Transfer for $400 CAD |  |
| CP143 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details "$400 CAD" with payment method "Cash" via "Interac e-Transfer" and stat |  |
| CP144 | EXPECTED RESULTS | verdict | api | Sequence: VOL (ATC) ? INVOL (Agent+ACNP); Promise: 11:30 (last VOL before INVOL); Agent+ACNP did NOT override VOL promise; ACNP confirms INV | Sequence: VOL (ATC) ? INVOL (Agent+ACNP); Promise: 11:30 (last VOL before INVOL); Agent+ACNP did NOT override VOL promise; ACNP confirms INVOL; Actual: 16:00; D |
