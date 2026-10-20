# FD_TC_175 · CHAI-31567 — checkpoints

**Goal:** Mixed Regime � APPR + ASL (ASL Not Eligible at 4hr Delay � APPR Only Eligible). Flight from Toronto (YYZ) to Tel Aviv (TLV) � Canada departure, Israel arrival. APPR applies (Canada departure) AND ASL applies (Israel arrival). At 4hr delay: APPR = $400 CAD (Tier 1, 3�<6h). However, per the Confluence compensation table, ASL compensation only starts at 8+ hours (3670 ILS). At 4hr delay, ASL has NO applicable compensation amount and is NOT ELIGIBLE. Only APPR produces an eligible result ? APPR selected as the only eligible regime. Validates that ASL's 8-hour threshold is correctly applied and that the system does not award ASL compensation below 8 hours.

Methods: seed 8, chat 66, api 21, email 3, dashboard 45, implied 24, manual 14, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Mixed Regime � APPR + ASL (ASL Not Eligible at 4hr Delay � APPR Only Eligible). Flight from Toronto (YYZ) to Tel Aviv (TLV) � Canada departu |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Noam Golan), 1 leg AC operated YYZ?TLV | PNR: Single passenger (Noam Golan), 1 leg AC operated YYZ?TLV |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: Scheduled arrival 06:00 (TLV local), Actual arrival 10:00 (4hr delay) | Itinerary: Scheduled arrival 06:00 (TLV local), Actual arrival 10:00 (4hr delay) |
| CP004 | PREREQUISITES | prerequisite | seed | Disruption code: 42 (Controllable) | Disruption code: 42 (Controllable) |
| CP005 | PREREQUISITES | prerequisite | seed | Flight status: Arrived (operated) | Flight status: Arrived (operated) |
| CP006 | PREREQUISITES | prerequisite | seed | Booking changes: None | Booking changes: None |
| CP007 | PREREQUISITES | prerequisite | seed | Carrier: AC only | Carrier: AC only |
| CP008 | PREREQUISITES | prerequisite | seed | Route context: Canada departure (YYZ) ? APPR applies; Israel arrival (TLV) ? ASL applies; Not EU origin ? EU N/A | Route context: Canada departure (YYZ) ? APPR applies; Israel arrival (TLV) ? ASL applies; Not EU origin ? EU N/A |
| CP009 | PREREQUISITES | prerequisite | seed | ASL note: Per compensation table, ASL starts at 8+ hours � at 4hr delay, ASL has no applicable compensation | ASL note: Per compensation table, ASL starts at 8+ hours � at 4hr delay, ASL has no applicable compensation |
| CP010 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP011 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP012 | START | customer | chat | Then user selects English |  |
| CP013 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP014 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP015 | START | customer | chat | And the user says "My flight from Toronto to Tel Aviv was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compens | My flight from Toronto to Tel Aviv was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation |
| CP016 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP017 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP018 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP019 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP022 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Noam Golan" | Noam Golan |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Noam! And, what is your booking reference number? |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC149" | PNR: TC149 |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC149 |  |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: n***@gmail.com Phone: +972***456 |
| CP030 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: n***@gmail.com" | Email: n***@gmail.com |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP033 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP035 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP036 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP037 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP038 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Noam Golan (Adult) Is this who you'd like to include? |
| CP039 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP040 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP041 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 085 Route: Toronto (YYZ) ? Tel Aviv Ben Gurion (TLV) Date: June 3, 2026 Arrival Delay: 4 hours Is this the journey you |
| CP042 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP046 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP047 | REGIME DETERMINATION � DUAL REGIME | system | implied | Then the system determines applicable regimes: |  |
| CP048 | REGIME DETERMINATION � DUAL REGIME | system | implied | And the system checks: Origin airport = YYZ (Toronto, Canada) ? APPR applies (Canada departure) |  |
| CP049 | REGIME DETERMINATION � DUAL REGIME | system | implied | And the system checks: Destination airport = TLV (Tel Aviv, Israel) ? ASL applies (Israel arrival) |  |
| CP050 | REGIME DETERMINATION � DUAL REGIME | system | implied | And the system checks: Origin = YYZ (not EU) ? EU 261 does NOT apply |  |
| CP051 | REGIME DETERMINATION � DUAL REGIME | verdict | api | And the system determines: DUAL REGIME � APPR + ASL (both assessed independently) |  |
| CP052 | TRIAGE & DDS EVALUATION � DUAL REGIME | verdict | api | Then the DDS evaluation is done in backend |  |
| CP053 | TRIAGE & DDS EVALUATION � DUAL REGIME | verdict | api | And DDS assesses BOTH regimes independently: |  |
| CP054 | APPR ASSESSMENT | system | implied | ? Origin: YYZ (Canada) ? APPR applies | ? Delay: 4 hours ? 3�<6h tier (Tier 1) ? Code: 42 ? Controllable under APPR ? APPR Result: ELIGIBLE � $400 CAD |
| CP055 | ASL ASSESSMENT | system | implied | ? Destination: TLV (Israel) ? ASL applies | ? Delay: 4 hours ? Per compensation table: ASL compensation starts at 8+ hours (3670 ILS). At 4hr delay, ASL has NO applicable compensation amount. ? Code: 42 ? |
| CP056 | REGIME SELECTION | system | implied | ? Applicable regimes: APPR & ASL | ? APPR: ELIGIBLE � $400 CAD ? ASL: NOT ELIGIBLE (4hr delay < 8hr ASL threshold) ? Only one regime eligible ? APPR selected as the only eligible regime ? SELECTE |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 085, Route: YYZ ? TLV, Scheduled Arrival: 06:00 | Promised Itinerary - Flight: AC 085, Route: YYZ ? TLV, Scheduled Arrival: 06:00 |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 085, Route: YYZ ? TLV, Status: ARRIVED LATE, Actual: 10:00, Delay: +4H 00M | Current Itinerary - Flight: AC 085, Route: YYZ ? TLV, Status: ARRIVED LATE, Actual: 10:00, Delay: +4H 00M |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Dual Regime: APPR + ASL | Dual Regime: APPR + ASL |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | EU 261: NOT APPLICABLE (origin not EU) | EU 261: NOT APPLICABLE (origin not EU) |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | APPR: ELIGIBLE � $400 CAD | APPR: ELIGIBLE � $400 CAD |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | ASL: NOT ELIGIBLE (4hr delay < 8hr ASL threshold � ASL compensation starts at 8+ hours) | ASL: NOT ELIGIBLE (4hr delay < 8hr ASL threshold � ASL compensation starts at 8+ hours) |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Selected: APPR � $400 CAD (only eligible regime) | Selected: APPR � $400 CAD (only eligible regime) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 085 � YYZ ? TLV � 42 | MSL FLIGHT: AC 085 � YYZ ? TLV � 42 |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42) | CONTROLLABLE (Code 42) |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | MR NOAM GOLAN / ELIGIBLE / APPR_3_TO_6_HOURS (ONLY ELIGIBLE REGIME) / $400 CAD | MR NOAM GOLAN / ELIGIBLE / APPR_3_TO_6_HOURS (ONLY ELIGIBLE REGIME) / $400 CAD |
| CP067 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP068 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP069 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP070 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 085 from Toronto (YYZ) to Tel Aviv Ben Gurion (TLV) was delayed by about 4 hours. Based on the app |
| CP071 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP072 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Israel" | Israel |
| CP073 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Israel ? Currency = ILS ? Payment Method = BSM Email Payment |  |
| CP074 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP075 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive $400 CAD compensation (equivalent in ILS at current exchange rate). Please note that | You are entitled to receive $400 CAD compensation (equivalent in ILS at current exchange rate). Please note that it will take 5 to 10 business days to process p |
| CP076 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency (ILS)." | Please note that payments will be deposited in your local currency (ILS). |
| CP077 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP078 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? BSM Email Payment | Replace the entire PAYMENT METHOD section with: |
| CP079 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment re |
| CP080 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | customer | chat | And user provides "Yes" | Yes |
| CP081 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP085 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP086 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP087 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP088 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP089 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP090 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP091 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP092 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD (equivalent in ILS) Payment Method: Email After submission, you will receive a confirmation email summarizing your eligibility, claim d |
| CP093 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP094 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP095 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP096 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP097 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP098 | CURRENCY CONVERSION LOGGING | verdict | api | ? Compensation Amount (Selected Regime � APPR): $400 CAD | ? ASL Amount (Not Selected � NE): $0 (ASL not eligible at 4hr delay) ? Exchange Rate Used: CAD ? ILS (Bank of Canada rate) ? Payment Currency: ILS (customer in  |
| CP099 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP100 | NOTIFICATION | email | email | And an eligible notification email is sent to n***@gmail.com |  |
| CP101 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR � only eligible regime), flight details (YYZ?TLV, 4 |  |
| CP102 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP103 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP104 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Noam Golan" with PNR "TC149" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Noam Golan" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC149" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR + ASL (Dual Regime � APPR SELECTED; ASL Not Eligible at this delay)" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And EU 261 should be N/A as not EU origin |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Noam Golan" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YYZ ? TLV" with claim filed for this flight |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Assessment 1 ELIGIBLE SELECTED should be APPR with eligibility ELIGIBLE and compensation "$400 CAD" Tier 1 3 to less than 6hrs controlla |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Assessment 2 NOT ELIGIBLE should be ASL with eligibility NOT ELIGIBLE due to 4hr delay being less than 8hr ASL threshold and compensatio |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And only one regime should be eligible so APPR should be selected by default |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if delay were 8 hours or more ASL would be eligible at 3670 ILS and would be selected over APPR per fixed priority as ASL is greater tha |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And BOTH regimes should be assessed and logged |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be "ELIGIBLE" under APPR as only eligible regime |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the ASL assessment should be visible showing NOT ELIGIBLE below 8hr threshold |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Noam Golan + TC149 + YYZ?TLV + FD" |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent containing compensation "$400 CAD" and regulation "APPR" and flight details YYZ to  |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record dual-regime assessment with APPR $400 selected and ASL NE below 8hr threshold |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the exchange rate should be logged CAD to ILS |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP159 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Israel" |  |
| CP160 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "ILS" |  |
| CP161 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM Email Payment" |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered and AC Wallet should NOT be offered |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And the dual regime should be assessed with APPR ELIGIBLE at $400 CAD vs ASL NOT ELIGIBLE at 4hr delay less than 8hr ASL threshold |  |
| CP164 | PAYMENT VALIDATION | payment | chat | And only APPR should be eligible so APPR should be selected as only eligible regime at $400 CAD |  |
| CP165 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "$400 CAD" converted to ILS for payment |  |
| CP166 | PAYMENT VALIDATION | payment | chat | And email should be confirmed for BSM Email Payment |  |
| CP167 | PAYMENT VALIDATION | payment | chat | And IDV should be completed via Persona and IDV should PASS |  |
| CP168 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP169 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP170 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier and Unifier should process BSM Email Payment in ILS |  |
| CP171 | PAYMENT VALIDATION | payment | manual | And HSBC should send an acknowledgement back and the end-of-day report should be received |  |
| CP172 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Completed" or "Rejected" or "Expired" |  |
| CP173 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details "$400 CAD" as APPR selected with payment currency ILS and exchange rate |  |
| CP174 | PAYMENT VALIDATION | payment | chat | And the exchange rate source and date and value should be logged |  |
| CP175 | PAYMENT VALIDATION | payment | chat | And ASL was assessed but NOT ELIGIBLE at 4hr delay as ASL compensation starts at 8 plus hours per compensation table and if delay were 8hrs  |  |
| CP176 | EXPECTED RESULTS | verdict | api | DDS returns FD-MIXED-EL-04. | DDS returns FD-MIXED-EL-04. |
| CP177 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 06:00; Actual = 10:00; Delay = 4hrs; MSL = Leg 1; Code 42; Controllable; Regime = APPR + ASL (both assessed). | Trip Tracer: Promise = 06:00; Actual = 10:00; Delay = 4hrs; MSL = Leg 1; Code 42; Controllable; Regime = APPR + ASL (both assessed). |
| CP178 | EXPECTED RESULTS | verdict | chat | APPR = ELIGIBLE ($400 CAD, Tier 1, 3�<6hrs). | APPR = ELIGIBLE ($400 CAD, Tier 1, 3�<6hrs). |
| CP179 | EXPECTED RESULTS | verdict | chat | ASL = NOT ELIGIBLE (4hr delay < 8hr ASL threshold � per compensation table, ASL starts at 8+ hours with 3670 ILS). | ASL = NOT ELIGIBLE (4hr delay < 8hr ASL threshold � per compensation table, ASL starts at 8+ hours with 3670 ILS). |
| CP180 | EXPECTED RESULTS | verdict | chat | Only APPR eligible ? APPR selected. | Only APPR eligible ? APPR selected. |
| CP181 | EXPECTED RESULTS | verdict | chat | NOTE: If delay were ?8hrs, ASL (3670 ILS) would be eligible and would be selected over APPR per fixed priority (ASL > APPR). | NOTE: If delay were ?8hrs, ASL (3670 ILS) would be eligible and would be selected over APPR per fixed priority (ASL > APPR). |
| CP182 | EXPECTED RESULTS | verdict | api | Claims Dashboard: APPR = Eligible ($400, selected); ASL = Not Eligible (below 8hr threshold); DDS = FD-MIXED-EL-04. | Claims Dashboard: APPR = Eligible ($400, selected); ASL = Not Eligible (below 8hr threshold); DDS = FD-MIXED-EL-04. |
