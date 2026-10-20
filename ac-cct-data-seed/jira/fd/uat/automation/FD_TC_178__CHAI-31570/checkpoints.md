# FD_TC_178 · CHAI-31570 — checkpoints

**Goal:** Mixed Regime � EU Eligible but ASL No Determination. Triple-regime route (CDG?YYZ?TLV) where EU 261 is Eligible, APPR is Eligible, but ASL is No Determination (missing Israeli-specific data). Per fixed priority hierarchy, EU is always selected over APPR (not by CAD comparison). ASL's ND does NOT block the eligible EU/APPR assessment. System selects from regimes with definitive results using fixed priority hierarchy. Validates that ND on one regime does not prevent compensation under other eligible regimes.

Methods: seed 7, chat 68, api 22, email 3, dashboard 42, implied 29, manual 12, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Mixed Regime � EU Eligible but ASL No Determination. Triple-regime route (CDG?YYZ?TLV) where EU 261 is Eligible, APPR is Eligible, but ASL i |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Sylvain Moreau), 2 legs CDG?YYZ?TLV | PNR: Single passenger (Sylvain Moreau), 2 legs CDG?YYZ?TLV |
| CP003 | PREREQUISITES | prerequisite | seed | Leg 1 (CDG?YYZ): AC operated, on time | Leg 1 (CDG?YYZ): AC operated, on time |
| CP004 | PREREQUISITES | prerequisite | seed | Leg 2 (YYZ?TLV): Delayed 4hrs | Leg 2 (YYZ?TLV): Delayed 4hrs |
| CP005 | PREREQUISITES | prerequisite | seed | Disruption code: 42 (Controllable) | Disruption code: 42 (Controllable) |
| CP006 | PREREQUISITES | prerequisite | seed | EU data: Complete ? Eligible | EU data: Complete ? Eligible |
| CP007 | PREREQUISITES | prerequisite | seed | APPR data: Complete ? Eligible | APPR data: Complete ? Eligible |
| CP008 | PREREQUISITES | prerequisite | seed | ASL data: Incomplete � Israeli regulatory data missing ? No Determination | ASL data: Incomplete � Israeli regulatory data missing ? No Determination |
| CP009 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP010 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP011 | START | customer | chat | Then user selects English |  |
| CP012 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP013 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP014 | START | customer | chat | And the user says "I flew from Paris to Toronto and then Toronto to Tel Aviv. My second flight was delayed 4 hours due to a crew issue. I'd  | I flew from Paris to Toronto and then Toronto to Tel Aviv. My second flight was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compe |
| CP015 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP016 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP017 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP018 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP021 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Sylvain Moreau" | Sylvain Moreau |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Sylvain! And, what is your booking reference number? |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC152" | PNR: TC152 |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC152 |  |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: s***@gmail.com Phone: +33***890 |
| CP029 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: s***@gmail.com" | Email: s***@gmail.com |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP032 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP034 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP035 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP036 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP037 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Sylvain Moreau (Adult) Is this who you'd like to include? |
| CP038 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP039 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP040 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Segment 1: Flight AC 871, Paris Charles de Gaulle (CDG) ? Toronto (YYZ), June 6, 2026 � COMPLETED Segment 2: Flight AC 085, Toron |
| CP041 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP043 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 DELAYED |  |
| CP044 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot determines: Claim applies to Segment 2 (AC 085 YYZ?TLV � DELAYED); Final destination = TLV; Final arrival delay = 4h |  |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found |  |
| CP047 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP048 | REGIME DETERMINATION � TRIPLE REGIME | system | implied | Then the system determines applicable regimes: |  |
| CP049 | REGIME DETERMINATION � TRIPLE REGIME | system | implied | And the system checks: Journey origin = CDG (EU) ? EU 261 applies |  |
| CP050 | REGIME DETERMINATION � TRIPLE REGIME | system | implied | And the system checks: Connection through YYZ (Canada) ? APPR applies |  |
| CP051 | REGIME DETERMINATION � TRIPLE REGIME | system | implied | And the system checks: Final destination = TLV (Israel) ? ASL applies |  |
| CP052 | REGIME DETERMINATION � TRIPLE REGIME | verdict | api | And the system determines: TRIPLE REGIME � EU 261 + APPR + ASL |  |
| CP053 | TRIAGE & DDS EVALUATION � TRIPLE REGIME WITH ASL ND | verdict | api | Then the DDS evaluation is done in backend |  |
| CP054 | TRIAGE & DDS EVALUATION � TRIPLE REGIME WITH ASL ND | verdict | api | And DDS assesses ALL THREE regimes independently: |  |
| CP055 | EU 261 ASSESSMENT | system | implied | ? Origin: CDG (EU) ? EU 261 applies | ? Distance: CDG?TLV = ~3,400 km ? Medium-haul (1500�3500km) ? Delay at final destination: 4 hours ? ?3h threshold ? Code: 42 ? Controllable under EU 261 ? EU 26 |
| CP056 | APPR ASSESSMENT | system | implied | ? Connection: YYZ (Canada) ? APPR applies | ? Delay at final destination: 4 hours ? 3�<6h tier ? Code: 42 ? Controllable under APPR ? APPR Data: COMPLETE ? APPR Result: ELIGIBLE � $400 CAD |
| CP057 | ASL ASSESSMENT | system | implied | ? Destination: TLV (Israel) ? ASL applies | ? Delay at final destination: 4 hours ? Code: 42 ? Controllable under ASL ? ASL Data: INCOMPLETE � Israeli regulatory data missing (specific ASL compensation ta |
| CP058 | MIXED RESULT � EU ELIGIBLE, APPR ELIGIBLE, ASL NO DETERMINATION | system | implied | ? EU 261: ELIGIBLE � �400 | ? APPR: ELIGIBLE � $400 CAD ? ASL: NO DETERMINATION (data incomplete) ? ASL ND blocks eligible assessment? ? NO � ASL's ND does NOT block EU/APPR ? System selec |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Segment 1: Flight: AC 871, Route: CDG ? YYZ, Status: COMPLETED (on time) | Segment 1: Flight: AC 871, Route: CDG ? YYZ, Status: COMPLETED (on time) |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Segment 2: Flight: AC 085, Route: YYZ ? TLV, Status: ARRIVED LATE, Delay: +4H 00M | Segment 2: Flight: AC 085, Route: YYZ ? TLV, Status: ARRIVED LATE, Delay: +4H 00M |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Triple Regime: EU 261 + APPR + ASL | Triple Regime: EU 261 + APPR + ASL |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | EU 261: ELIGIBLE � �400 � DATA COMPLETE | EU 261: ELIGIBLE � �400 � DATA COMPLETE |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | APPR: ELIGIBLE � $400 CAD � DATA COMPLETE | APPR: ELIGIBLE � $400 CAD � DATA COMPLETE |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | ASL: NO DETERMINATION � DATA INCOMPLETE (Israeli regulatory data missing) | ASL: NO DETERMINATION � DATA INCOMPLETE (Israeli regulatory data missing) |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | ASL ND Blocking: NO � does not block EU/APPR eligible assessment | ASL ND Blocking: NO � does not block EU/APPR eligible assessment |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Eligible regimes: EU 261 + APPR ? Fixed priority: EU first | Eligible regimes: EU 261 + APPR ? Fixed priority: EU first |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Most Generous (from determined regimes): EU 261 � �400 (fixed priority) | Most Generous (from determined regimes): EU 261 � �400 (fixed priority) |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 085 � YYZ ? TLV � 42 | MSL FLIGHT: AC 085 � YYZ ? TLV � 42 |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42) | CONTROLLABLE (Code 42) |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | MR SYLVAIN MOREAU / ELIGIBLE / EU261_3_PLUS_HOURS_MEDIUM_HAUL (FIXED PRIORITY from determined regimes) / �400 | MR SYLVAIN MOREAU / ELIGIBLE / EU261_3_PLUS_HOURS_MEDIUM_HAUL (FIXED PRIORITY from determined regimes) / �400 |
| CP071 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP072 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP073 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP074 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your connecting flight AC 085 from Toronto (YYZ) to Tel Aviv Ben Gurion (TLV) was delayed by about 4 hours.  |
| CP075 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP076 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "France" | France |
| CP077 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = France ? Currency = EUR ? Payment Method = BSM Email Payment |  |
| CP078 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP079 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive �400 compensation. Please note that it will take 5 to 10 business days to process pa | You are entitled to receive �400 compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP080 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency (EUR)." | Please note that payments will be deposited in your local currency (EUR). |
| CP081 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP082 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment re |
| CP083 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | customer | chat | And user provides "Yes" | Yes |
| CP084 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP085 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP086 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP087 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP088 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP089 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP090 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP091 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP092 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP093 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP094 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP095 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �400 Payment Method: Email After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps. W |
| CP096 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP097 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP098 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP099 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP100 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP101 | ASL NO DETERMINATION � BACKGROUND PROCESSING | system | implied | Then the system notes: ASL assessment returned No Determination |  |
| CP102 | ASL NO DETERMINATION � BACKGROUND PROCESSING | system | implied | And the system schedules: ASL data retry (daily polling for up to 14 days for Israeli regulatory data) |  |
| CP103 | ASL NO DETERMINATION � BACKGROUND PROCESSING | system | implied | And the system records: If ASL data becomes available and ASL is eligible, ASL would take priority over EU per fixed hierarchy (ASL > EU > A |  |
| CP104 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP105 | NOTIFICATION | email | email | And an eligible notification email is sent to s***@gmail.com |  |
| CP106 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�400), regulation (EU 261 � selected per fixed priority from determined regimes |  |
| CP107 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP108 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP109 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Sylvain Moreau" with PNR "TC152" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Sylvain Moreau" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC152" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 + APPR + ASL (Triple Regime � EU 261 SELECTED per fixed priority; ASL = No Determination)" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Sylvain Moreau" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: CDG ? YYZ" completed on time and "Segment 2: YYZ ? TLV" delayed plus 4h with claim filed |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Assessment 1 ELIGIBLE SELECTED should be EU 261 with eligibility ELIGIBLE and compensation "�400 EUR" for 1500 to 3500km band and 3h or  |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Assessment 2 ELIGIBLE Not Selected should be APPR with eligibility ELIGIBLE and compensation "$400 CAD" Tier 1 and NOT SELECTED as EU ta |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Assessment 3 NO DETERMINATION should be ASL with eligibility NO DETERMINATION due to Israeli regulatory data missing and compensation PE |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And ASL's ND should NOT block the other regimes from being assessed and selected |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligible regimes should be EU 261 and APPR and per fixed priority EU always over APPR so EU 261 should be SELECTED |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the selection should be by fixed priority hierarchy NOT by CAD conversion comparison |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And ASL should be excluded from selection as No Determination and may be resolved later |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if ASL data becomes available and ASL is eligible ASL would take priority as ASL is greater than EU is greater than APPR |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And ALL THREE regimes should be assessed |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And EU 261 should be Eligible at �400 selected per fixed priority |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And APPR should be Eligible at $400 not selected |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And ASL should be No Determination logged with manual handling if needed |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And ASL ND should NOT prevent eligible outcome as the system selects from regimes with definitive results using fixed priority |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Sylvain Moreau + TC152 + CDG?TLV + FD" |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" as it ran for the eligible EU 261 assessment |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent containing compensation "�400 EUR" and regulation "EU 261" and flight details CDG t |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record triple-regime assessment with EU 261 Eligible �400 selected per fixed priority and APPR Eligible $400 not se |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the exchange rate should be logged for internal reporting |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the ASL ND flag should be visible for potential manual follow-up |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" based on EU 261 eligible assessment as ASL ND does not block resolution |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP159 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "France" |  |
| CP160 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "EUR" |  |
| CP161 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM Email Payment" |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered and AC Wallet should NOT be offered |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And the triple regime should be assessed with EU 261 ELIGIBLE at �400 vs APPR ELIGIBLE at $400 CAD vs ASL NO DETERMINATION data missing |  |
| CP164 | PAYMENT VALIDATION | payment | chat | And ASL should be excluded as ND and EU vs APPR should result in EU selected per fixed priority hierarchy NOT by CAD comparison |  |
| CP165 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "�400" EUR as EU 261 selected per fixed priority from regimes with definitive results |  |
| CP166 | PAYMENT VALIDATION | payment | chat | And the payment currency should be EUR as the customer is in France and EU 261 is already in EUR so no conversion is needed |  |
| CP167 | PAYMENT VALIDATION | payment | chat | And email should be confirmed for BSM Email Payment |  |
| CP168 | PAYMENT VALIDATION | payment | chat | And IDV at Payment should be triggered via Persona and IDV PASS should be required before claim submission |  |
| CP169 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP170 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP171 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier and Unifier should process BSM Email Payment |  |
| CP172 | PAYMENT VALIDATION | payment | manual | And HSBC should send an acknowledgement back and the end-of-day report should be received |  |
| CP173 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP174 | PAYMENT VALIDATION | payment | chat | And BSM Email Payment processing should take 5 to 10 business days |  |
| CP175 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details "�400 EUR" with payment method "Cash" via "BSM Email Payment" and statu |  |
| CP176 | EXPECTED RESULTS | verdict | api | DDS returns FD-MIXED-ND-01. | DDS returns FD-MIXED-ND-01. |
| CP177 | EXPECTED RESULTS | verdict | api | Trip Tracer: Delay = 4hrs; MSL = Leg 2; Code 42; Controllable; Regime = EU + APPR + ASL. | Trip Tracer: Delay = 4hrs; MSL = Leg 2; Code 42; Controllable; Regime = EU + APPR + ASL. |
| CP178 | EXPECTED RESULTS | verdict | chat | Triple Assessment: EU 261 = ELIGIBLE (�400, 1500�3500km); APPR = ELIGIBLE ($400 CAD); ASL = NO DETERMINATION (missing data). | Triple Assessment: EU 261 = ELIGIBLE (�400, 1500�3500km); APPR = ELIGIBLE ($400 CAD); ASL = NO DETERMINATION (missing data). |
| CP179 | EXPECTED RESULTS | verdict | chat | CRITICAL: ASL's ND does NOT block the other regimes. | CRITICAL: ASL's ND does NOT block the other regimes. |
| CP180 | EXPECTED RESULTS | verdict | chat | System selects from regimes with definitive results using fixed priority: EU over APPR ? EU selected. | System selects from regimes with definitive results using fixed priority: EU over APPR ? EU selected. |
| CP181 | EXPECTED RESULTS | verdict | chat | Selection is by fixed priority hierarchy, NOT by CAD conversion comparison. | Selection is by fixed priority hierarchy, NOT by CAD conversion comparison. |
| CP182 | EXPECTED RESULTS | verdict | chat | ASL ND is logged and may be resolved later via manual handling � if ASL data becomes available and ASL is eligible, ASL would take priority  | ASL ND is logged and may be resolved later via manual handling � if ASL data becomes available and ASL is eligible, ASL would take priority over EU per fixed hi |
| CP183 | EXPECTED RESULTS | verdict | chat | Compensation: �400 (EU 261). | Compensation: �400 (EU 261). |
| CP184 | EXPECTED RESULTS | verdict | api | Claims Dashboard: EU = Eligible (�400, selected per fixed priority); APPR = Eligible ($400, not selected); ASL = No Determination (logged);  | Claims Dashboard: EU = Eligible (�400, selected per fixed priority); APPR = Eligible ($400, not selected); ASL = No Determination (logged); DDS = FD-MIXED-ND-01 |
