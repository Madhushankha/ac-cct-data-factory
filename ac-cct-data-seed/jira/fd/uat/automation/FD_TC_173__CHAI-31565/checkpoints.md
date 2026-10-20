# FD_TC_173 · CHAI-31565 — checkpoints

**Goal:** Mixed Regime � APPR + EU Eligible (EU Still Selected at 10hr Delay per Fixed Priority). Same dual-regime route (CDG?YYZ, EU + APPR) but at 10-hour delay. Under the fixed priority hierarchy, EU is ALWAYS selected over APPR regardless of delay duration. At 10hr delay: APPR Tier 3 = $1,000 CAD, EU (EU261) = �600 (fixed by distance band, does NOT increase with longer delays). Despite APPR's higher CAD amount, EU is still selected per the fixed priority. Validates that the fixed priority does NOT flip at higher delay tiers � EU always wins over APPR. Tests that DDS does NOT perform a CAD conversion comparison to override the fixed hierarchy.

Methods: seed 6, chat 69, api 20, email 3, dashboard 30, implied 25, manual 9, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Mixed Regime � APPR + EU Eligible (EU Still Selected at 10hr Delay per Fixed Priority). Same dual-regime route (CDG?YYZ, EU + APPR) but at 1 |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Jean-Marc Rousseau), 1 leg AC operated CDG?YYZ | PNR: Single passenger (Jean-Marc Rousseau), 1 leg AC operated CDG?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: Scheduled arrival 10:00 (YYZ local), Actual arrival 20:00 (10hr delay) | Itinerary: Scheduled arrival 10:00 (YYZ local), Actual arrival 20:00 (10hr delay) |
| CP004 | PREREQUISITES | prerequisite | seed | Disruption code: 42(Controllable) | Disruption code: 42(Controllable) |
| CP005 | PREREQUISITES | prerequisite | seed | Booking changes: None | Booking changes: None |
| CP006 | PREREQUISITES | prerequisite | seed | Carrier: AC only | Carrier: AC only |
| CP007 | PREREQUISITES | prerequisite | seed | Route context: EU origin (CDG) ? EU 261; Canada arrival ? APPR | Route context: EU origin (CDG) ? EU 261; Canada arrival ? APPR |
| CP008 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP009 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP010 | START | customer | chat | Then user selects English |  |
| CP011 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP012 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP013 | START | customer | chat | And the user says "My flight from Paris to Toronto was delayed 10 hours due to a crew issue. I'd like to check if I'm eligible for compensat | My flight from Paris to Toronto was delayed 10 hours due to a crew issue. I'd like to check if I'm eligible for compensation |
| CP014 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP015 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP016 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP017 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP018 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP020 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Jean-Marc Rousseau" | Jean-Marc Rousseau |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Jean-Marc! And, what is your booking reference number? |
| CP022 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC147" | PNR: TC147 |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC147 |  |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: j***@gmail.com Phone: +33***234 |
| CP028 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: j***@gmail.com" | Email: j***@gmail.com |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP030 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP031 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP033 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP034 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP035 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP036 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP037 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Jean-Marc Rousseau (Adult) Is this who you'd like to include? |
| CP038 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP039 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP040 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 871 Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ) Date: June 1, 2026 Arrival Delay: 10 hours Is this the journe |
| CP041 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP045 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP046 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (France = 5 years) and APPR ? within limitation ? PROCEED |  |
| CP047 | REGIME DETERMINATION � DUAL REGIME | system | implied | Then the system determines applicable regimes: |  |
| CP048 | REGIME DETERMINATION � DUAL REGIME | system | implied | And the system checks: Origin airport = CDG (Paris, France, EU) ? EU 261 applies |  |
| CP049 | REGIME DETERMINATION � DUAL REGIME | system | implied | And the system checks: Destination airport = YYZ (Toronto, Canada) ? APPR applies |  |
| CP050 | REGIME DETERMINATION � DUAL REGIME | verdict | api | And the system determines: DUAL REGIME � EU 261 + APPR (both assessed independently) |  |
| CP051 | TRIAGE & DDS EVALUATION � DUAL REGIME FIXED PRIORITY | verdict | api | Then the DDS evaluation is done in backend |  |
| CP052 | TRIAGE & DDS EVALUATION � DUAL REGIME FIXED PRIORITY | verdict | api | And DDS assesses BOTH regimes independently: |  |
| CP053 | EU 261 ASSESSMENT | system | implied | ? Origin: CDG (EU) ? EU 261 applies | ? Distance: CDG?YYZ = ~5,500 km ? Long-haul (>3500km) ? Delay: 10 hours ? 4+ threshold (EU261 amount is fixed at �600 for >3500km regardless of delay duration b |
| CP054 | APPR ASSESSMENT | system | implied | ? Destination: YYZ (Canada) ? APPR applies | ? Delay: 10 hours ? 9+ hours tier (Tier 3) ? Code: 42 ? Controllable under APPR ? APPR Result: ELIGIBLE � $1,000 CAD (Tier 3: 9+ hours) |
| CP055 | MOST GENEROUS SELECTION | system | implied | ? Applicable regimes: APPR & EU | ? Per Most Generous Logic: APPR & EU ? EU is always selected first (fixed priority hierarchy) ? EU 261: �600 ? APPR: $1,000 CAD (not selected despite higher CAD |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 871, Route: CDG ? YYZ, Scheduled Arrival: 10:00 | Promised Itinerary - Flight: AC 871, Route: CDG ? YYZ, Scheduled Arrival: 10:00 |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 871, Route: CDG ? YYZ, Status: ARRIVED LATE, Actual: 20:00, Delay: +10H 00M | Current Itinerary - Flight: AC 871, Route: CDG ? YYZ, Status: ARRIVED LATE, Actual: 20:00, Delay: +10H 00M |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Dual Regime: EU 261 + APPR | Dual Regime: EU 261 + APPR |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | EU 261: ELIGIBLE � �600 | EU 261: ELIGIBLE � �600 |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | APPR: ELIGIBLE � $1,000 CAD | APPR: ELIGIBLE � $1,000 CAD |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Most Generous: EU 261 � �600 (fixed priority: EU always selected over APPR, NO regime flip) | Most Generous: EU 261 � �600 (fixed priority: EU always selected over APPR, NO regime flip) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 871 � CDG ? YYZ � 42 | MSL FLIGHT: AC 871 � CDG ? YYZ � 42 |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42) | CONTROLLABLE (Code 42) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | MR JEAN-MARC ROUSSEAU / ELIGIBLE / EU261_4_PLUS_HOURS_LONG_HAUL (FIXED PRIORITY) / �600 | MR JEAN-MARC ROUSSEAU / ELIGIBLE / EU261_4_PLUS_HOURS_LONG_HAUL (FIXED PRIORITY) / �600 |
| CP065 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP066 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP067 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP068 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 871 from Paris Charles de Gaulle (CDG) to Toronto (YYZ) was delayed by about 10 hours. Based on th |
| CP069 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP070 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "France" | France |
| CP071 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = France ? Currency = EUR ? Payment Method = BSM Email Payment |  |
| CP072 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP073 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP074 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive �600 compensation. Please note that it will take 5 to 10 business days to process pa | You are entitled to receive �600 compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP075 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency (EUR)." | Please note that payments will be deposited in your local currency (EUR). |
| CP076 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP077 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? BSM Email Payment |  |
| CP078 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment re |
| CP079 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | customer | chat | And user provides "Yes" | Yes |
| CP080 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP085 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP086 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP087 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP088 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP089 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP090 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP091 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �600 Payment Method: Email After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps. W |
| CP092 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP093 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP094 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP095 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP096 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP097 | CURRENCY CONVERSION LOGGING | verdict | api | ? Compensation Amount (Selected Regime � EU 261): �600 EUR | ? APPR Amount (Not Selected): $1,000 CAD ? Exchange Rate Used: 1 EUR = 1.4667 CAD (for internal reporting only) ? CAD Equivalent of EU 261 Amount: ~$880 CAD (lo |
| CP098 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP099 | NOTIFICATION | email | email | And an eligible notification email is sent to j***@gmail.com |  |
| CP100 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�600 EUR), regulation (EU 261 � selected per fixed priority), flight details (C |  |
| CP101 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP102 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP103 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Jean-Marc Rousseau" with PNR "TC147" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Jean-Marc Rousseau" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC147" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 + APPR (Dual Regime � EU 261 SELECTED per fixed priority)" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Jean-Marc Rousseau" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: CDG ? YYZ" with claim filed for this flight |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Primary Selected regime should be EU 261 with eligibility ELIGIBLE and compensation "�600 EUR" for greater than 3500km and EU compen |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Secondary Not Selected regime should be APPR with eligibility ELIGIBLE and compensation "$1,000 CAD" Tier 3 9hrs or more controllabl |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Selection Method should be fixed priority hierarchy NOT CAD conversion comparison |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And there should be NO regime flip as EU is always selected over APPR regardless of delay tier |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And at 4hr delay TC189 EU �600 was selected and APPR $400 was not selected |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And at 10hr delay TC147 EU �600 is STILL selected and APPR $1,000 is STILL not selected |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the fixed priority does NOT change based on delay duration or amount |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And BOTH regimes should be assessed and logged |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be "ELIGIBLE" under EU 261 fixed priority |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And EU 261 should be flagged as SELECTED |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically and the result should be "No duplicate found" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent containing compensation "�600 EUR" and regulation "EU 261" and flight details CDG t |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP138 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "France" |  |
| CP139 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "EUR" |  |
| CP140 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM Email Payment" |  |
| CP141 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered and AC Wallet should NOT be offered |  |
| CP142 | PAYMENT VALIDATION | payment | chat | And EU should be selected despite APPR having higher CAD amount with $1,000 being greater than approximately $880 CAD equivalent of �600 as  |  |
| CP143 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "�600" EUR as EU 261 selected per fixed priority |  |
| CP144 | PAYMENT VALIDATION | payment | chat | And the payment currency should be EUR as the customer is in France and EU 261 is already in EUR so no conversion is needed |  |
| CP145 | PAYMENT VALIDATION | payment | chat | And IDV should be completed via Persona and IDV should PASS |  |
| CP146 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP147 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP148 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier and Unifier should process Email Payment |  |
| CP149 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP150 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received with status "Pending" transitioning to "Completed" or "Rejected" |  |
| CP151 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details "�600 EUR" as EU 261 selected per fixed priority with payment currency  |  |
| CP152 | PAYMENT VALIDATION | payment | chat | And both regime assessments should be logged with EU 261 Eligible �600 SELECTED and APPR Eligible $1,000 not selected |  |
| CP153 | PAYMENT VALIDATION | payment | chat | And NO regime flip exists as EU is always selected over APPR regardless of delay tier per legal team approval |  |
| CP154 | EXPECTED RESULTS | verdict | api | DDS returns FD-MIXED-EL-02. | DDS returns FD-MIXED-EL-02. |
| CP155 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 10:00; Actual = 20:00; Delay = 10hrs; MSL = Leg 1; Code 42; Controllable; Regime = EU 261 + APPR. | Trip Tracer: Promise = 10:00; Actual = 20:00; Delay = 10hrs; MSL = Leg 1; Code 42; Controllable; Regime = EU 261 + APPR. |
| CP156 | EXPECTED RESULTS | verdict | chat | Dual Assessment: EU 261 = �600 (>3500km � EU compensation is FIXED by distance band, does NOT increase with longer delays); APPR = $1,000 CA | Dual Assessment: EU 261 = �600 (>3500km � EU compensation is FIXED by distance band, does NOT increase with longer delays); APPR = $1,000 CAD (Tier 3, ?9hrs). |
| CP157 | EXPECTED RESULTS | verdict | chat | Most Generous Selection: Fixed priority � APPR & EU ? EU always first. | Most Generous Selection: Fixed priority � APPR & EU ? EU always first. |
| CP158 | EXPECTED RESULTS | verdict | chat | EU 261 SELECTED � �600. | EU 261 SELECTED � �600. |
| CP159 | EXPECTED RESULTS | verdict | chat | CRITICAL: There is NO regime flip. | CRITICAL: There is NO regime flip. |
| CP160 | EXPECTED RESULTS | verdict | chat | EU is always selected over APPR regardless of delay duration or amount. | EU is always selected over APPR regardless of delay duration or amount. |
| CP161 | EXPECTED RESULTS | verdict | chat | At 10hr delay, APPR's $1,000 CAD exceeds EU's ~$880 CAD equivalent, but the fixed priority hierarchy (approved by legal) overrides any amoun | At 10hr delay, APPR's $1,000 CAD exceeds EU's ~$880 CAD equivalent, but the fixed priority hierarchy (approved by legal) overrides any amount comparison. |
| CP162 | EXPECTED RESULTS | verdict | chat | Compensation: �600 (EU 261). | Compensation: �600 (EU 261). |
| CP163 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Primary = EU 261 (�600, selected per fixed priority); Secondary = APPR ($1,000, not selected despite higher CAD value); DD | Claims Dashboard: Primary = EU 261 (�600, selected per fixed priority); Secondary = APPR ($1,000, not selected despite higher CAD value); DDS = FD-MIXED-EL-02. |
