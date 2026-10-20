# FD_TC_174 · CHAI-31566 — checkpoints

**Goal:** Mixed Regime � APPR + EU Eligible (AC Wallet on EU-Selected Amount). Dual-regime route (CDG?YYZ, EU + APPR) at 4hr delay. Per fixed priority, EU is always selected over APPR (�600). Customer selects AC Wallet payout. Validates that the 20% AC Wallet top-up is applied to the EU-selected amount (�600) converted to CAD, NOT the APPR amount ($400). �600 � Bank of Canada rate = ~$880 CAD base ? +20% = ~$1,056 CAD via AC Wallet. Tests that the top-up calculation uses the fixed-priority-selected regime's converted CAD value.

Methods: seed 7, chat 67, api 17, email 3, dashboard 29, implied 24, manual 7, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Mixed Regime � APPR + EU Eligible (AC Wallet on EU-Selected Amount). Dual-regime route (CDG?YYZ, EU + APPR) at 4hr delay. Per fixed priority |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Claudette Beauregard), 1 leg AC operated CDG?YYZ | PNR: Single passenger (Claudette Beauregard), 1 leg AC operated CDG?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: Scheduled arrival 16:00, Actual arrival 20:00 (4hr delay) | Itinerary: Scheduled arrival 16:00, Actual arrival 20:00 (4hr delay) |
| CP004 | PREREQUISITES | prerequisite | seed | Disruption code: 42 (Controllable) | Disruption code: 42 (Controllable) |
| CP005 | PREREQUISITES | prerequisite | seed | Flight distance: CDG?YYZ = ~5,500km (>3500km) | Flight distance: CDG?YYZ = ~5,500km (>3500km) |
| CP006 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked, account active (NOT frozen) | Aeroplan: Linked, account active (NOT frozen) |
| CP007 | PREREQUISITES | prerequisite | seed | Payment: AC Wallet selected | Payment: AC Wallet selected |
| CP008 | PREREQUISITES | prerequisite | seed | Route context: EU origin (CDG) ? EU 261; Canada arrival ? APPR | Route context: EU origin (CDG) ? EU 261; Canada arrival ? APPR |
| CP009 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP010 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP011 | START | customer | chat | Then user selects English |  |
| CP012 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP013 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP014 | START | customer | chat | And the user says "My flight from Paris to Toronto was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensati | My flight from Paris to Toronto was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation |
| CP015 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP016 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP017 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP018 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP021 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Claudette Beauregard" | Claudette Beauregard |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Claudette! And, what is your booking reference number? |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC148" | PNR: TC148 |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC148 |  |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: c***@gmail.com Phone: +33***345 |
| CP029 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: c***@gmail.com" | Email: c***@gmail.com |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP032 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP034 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP035 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP036 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP037 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Claudette Beauregard (Adult) Is this who you'd like to include? |
| CP038 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP039 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP040 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 871 Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ) Date: June 2, 2026 Arrival Delay: 4 hours Is this the journey |
| CP041 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP045 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP046 | REGIME DETERMINATION � DUAL REGIME | system | implied | Then the system determines: Origin = CDG (EU) ? EU 261 applies; Destination = YYZ (Canada) ? APPR applies |  |
| CP047 | REGIME DETERMINATION � DUAL REGIME | verdict | api | And the system determines: DUAL REGIME � EU 261 + APPR |  |
| CP048 | TRIAGE & DDS EVALUATION � DUAL REGIME FIXED PRIORITY | verdict | api | Then the DDS evaluation is done in backend |  |
| CP049 | EU 261 ASSESSMENT | system | implied | ? Distance: ~5,500 km ? Long-haul (>3500km) | ? Delay: 4 hours ? 4+ threshold ? Code: 42 ? Controllable ? EU 261 Result: ELIGIBLE � �600 |
| CP050 | APPR ASSESSMENT | system | implied | ? Delay: 4 hours ? 3�<6h tier (Tier 1) | ? Code: 42 ? Controllable ? APPR Result: ELIGIBLE � $400 CAD |
| CP051 | MOST GENEROUS SELECTION | system | implied | ? Per Most Generous Logic: APPR & EU ? EU always first | ? SELECTED: EU 261 � �600 |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Dual Regime: EU 261 + APPR | Dual Regime: EU 261 + APPR |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | EU 261: ELIGIBLE � �600 | EU 261: ELIGIBLE � �600 |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | APPR: ELIGIBLE � $400 CAD | APPR: ELIGIBLE � $400 CAD |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Most Generous: EU 261 � �600 (fixed priority) | Most Generous: EU 261 � �600 (fixed priority) |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 871 � CDG ? YYZ � 42 | MSL FLIGHT: AC 871 � CDG ? YYZ � 42 |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42) | CONTROLLABLE (Code 42) |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: Linked, ACTIVE | Aeroplan: Linked, ACTIVE |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | MS CLAUDETTE BEAUREGARD / ELIGIBLE / EU261_4_PLUS_HOURS_LONG_HAUL (FIXED PRIORITY) / �600 | MS CLAUDETTE BEAUREGARD / ELIGIBLE / EU261_4_PLUS_HOURS_LONG_HAUL (FIXED PRIORITY) / �600 |
| CP060 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP061 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP062 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 871 from Paris Charles de Gaulle (CDG) to Toronto (YYZ) was delayed by about 4 hours. Based on the |
| CP063 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP064 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP065 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP066 | CASH vs AC WALLET CHECK � AEROPLAN ACTIVE (FD-06a) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (Aeroplan linked) |  |
| CP067 | CASH vs AC WALLET CHECK � AEROPLAN ACTIVE (FD-06a) | system | implied | Then the chatbot checks: Is Aeroplan account active (not frozen)? ? YES |  |
| CP068 | CASH vs AC WALLET CHECK � AEROPLAN ACTIVE (FD-06a) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP069 | AC WALLET CALCULATION � APPLIED TO EU-SELECTED AMOUNT | system | implied | Then the system calculates AC Wallet amount: | ? Selected Regime: EU 261 (per fixed priority) ? EU 261 Compensation: �600 ? Convert to CAD: �600 � 1.4667 = $880.02 CAD (base amount) ? AC Wallet Top-Up: 20% ? |
| CP070 | AC WALLET CALCULATION � APPLIED TO EU-SELECTED AMOUNT | bot | chat | Then the chatbot responds: | You are entitled to receive �600 compensation (approximately $880 CAD). You can choose to receive this as: Cash � �600 (approximately $880 CAD) via Interac e-Tr |
| CP071 | AC WALLET CALCULATION � APPLIED TO EU-SELECTED AMOUNT | customer | chat | And the user selects "AC Wallet" | AC Wallet |
| CP072 | AC WALLET PAYOUT (FD-06a) | system | implied | Then the chatbot confirms: | "Great choice! You'll receive approximately $1,056 CAD in AC Wallet credits, which will be available in your Aeroplan account immediately after processing." |
| CP073 | AC WALLET PAYOUT (FD-06a) | system | implied | And the system records: Payment method = AC Wallet; Amount = ~$1,056 CAD (120% of ~$880 CAD EU-selected base); Aeroplan linked |  |
| CP074 | AC WALLET PAYOUT (FD-06a) | idv | chat | Then system checks that IDV is not completed |  |
| CP075 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP076 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP077 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP078 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP085 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: ~$1,056 CAD (AC Wallet credits � 120% of �600 base) Payment Method: AC Wallet (Aeroplan linked) After submission, you will receive a confirmatio |
| CP086 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP087 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP088 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP089 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP090 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP091 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP092 | NOTIFICATION | email | email | And an eligible notification email is sent to c***@gmail.com |  |
| CP093 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (~$1,056 CAD AC Wallet), base amount (�600 EU 261), payment method (AC Wallet),  |  |
| CP094 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP095 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP096 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Claudette Beauregard" with PNR "TC148" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Claudette Beauregard" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC148" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 + APPR (Dual Regime � EU 261 SELECTED per fixed priority)" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Claudette Beauregard" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Linked, account active (NOT frozen)" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: CDG ? YYZ" with claim filed for this flight |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Primary Selected regime should be EU 261 with eligibility ELIGIBLE and base compensation "�600 EUR" for greater than 3500km controll |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Secondary Not Selected regime should be APPR with eligibility ELIGIBLE and compensation "$400 CAD" Tier 1 and NOT SELECTED |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the AC Wallet calculation should show payment method AC Wallet with EAP check account active NOT frozen and base amount EU-selected per  |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the top-up should be applied AFTER fixed-priority regime selection AND currency conversion as 20% of the winning regime's CAD-converted  |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the total AC Wallet deposit should be approximately $1,056 CAD |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And BOTH regimes should be assessed and logged |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be "ELIGIBLE" under EU 261 selected per fixed priority |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the AC Wallet top-up calculation should be shown |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically and the result should be "No duplicate found" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent containing EU 261 selected per fixed priority and base �600 approximately $880 CAD  |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP130 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP131 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And the Aeroplan should be linked and account active NOT frozen so BOTH options should be offered with Cash approximately $880 CAD AND AC Wa |  |
| CP133 | PAYMENT VALIDATION | payment | chat | And the dual regime should be assessed with EU 261 �600 vs APPR $400 CAD and EU 261 should be SELECTED per fixed priority hierarchy |  |
| CP134 | PAYMENT VALIDATION | payment | chat | And EU 261 should be selected per fixed priority NOT by amount comparison |  |
| CP135 | PAYMENT VALIDATION | payment | chat | And AC Wallet should be offered because this is flight disruption EU 261 and AC Wallet is available for FD APPR or EU |  |
| CP136 | PAYMENT VALIDATION | payment | chat | And the AC Wallet calculation should be applied to the EU-SELECTED amount with EU 261 base �600 converted to CAD at �600 multiplied by Bank  |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And the 20% top-up must be applied to the EU-selected amount converted to CAD approximately $880 NOT to the APPR amount $400 and if the syst |  |
| CP138 | PAYMENT VALIDATION | payment | chat | And the customer should select AC Wallet and approximately $1,056 CAD should be deposited |  |
| CP139 | PAYMENT VALIDATION | payment | manual | And a compensation record should be created and picked up by the daily evening batch file and dispatched to EIP NOT Unifier |  |
| CP140 | PAYMENT VALIDATION | payment | chat | And EIP should check Aeroplan account validity as active not frozen and PASS |  |
| CP141 | PAYMENT VALIDATION | payment | chat | And EIP should send to iGiga and then iFly for deposit |  |
| CP142 | PAYMENT VALIDATION | payment | chat | And iFly should talk back to EIP and EIP should talk back to Claims Dashboard with deposited amount approximately $1,056 CAD and status Comp |  |
| CP143 | PAYMENT VALIDATION | payment | chat | And if the Aeroplan account is frozen or closed there should be a rejection with error message and failure notification to case and agent fl |  |
| CP144 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the EIP team |  |
| CP145 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details approximately $1,056 CAD with payment method "AC Wallet" and EU 261 sel |  |
| CP146 | PAYMENT VALIDATION | payment | chat | And the exchange rate should be logged with source Bank of Canada and date and value for AC Wallet CAD conversion NOT for regime selection |  |
| CP147 | EXPECTED RESULTS | verdict | api | DDS returns FD-MIXED-EL-03. | DDS returns FD-MIXED-EL-03. |
| CP148 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 16:00; Actual = 20:00; Delay = 4hrs; Code 42; Controllable; Regime = EU 261 + APPR. | Trip Tracer: Promise = 16:00; Actual = 20:00; Delay = 4hrs; Code 42; Controllable; Regime = EU 261 + APPR. |
| CP149 | EXPECTED RESULTS | verdict | chat | Dual Assessment: EU 261 = �600 (>3500km); APPR = $400 CAD. | Dual Assessment: EU 261 = �600 (>3500km); APPR = $400 CAD. |
| CP150 | EXPECTED RESULTS | verdict | chat | Most Generous: Fixed priority � EU always over APPR ? EU selected. | Most Generous: Fixed priority � EU always over APPR ? EU selected. |
| CP151 | EXPECTED RESULTS | verdict | chat | Currency conversion for AC Wallet: �600 � Bank of Canada rate = ~$880 CAD. | Currency conversion for AC Wallet: �600 � Bank of Canada rate = ~$880 CAD. |
| CP152 | EXPECTED RESULTS | verdict | chat | AC Wallet top-up: $880 CAD base + 20% = ~$1,056 CAD. | AC Wallet top-up: $880 CAD base + 20% = ~$1,056 CAD. |
| CP153 | EXPECTED RESULTS | verdict | chat | CRITICAL: Top-up is applied to the fixed-priority-selected regime's CAD-converted amount, NOT to APPR's $400. | CRITICAL: Top-up is applied to the fixed-priority-selected regime's CAD-converted amount, NOT to APPR's $400. |
| CP154 | EXPECTED RESULTS | verdict | chat | EAP check: Account active, deposit of ~$1,056 CAD. | EAP check: Account active, deposit of ~$1,056 CAD. |
| CP155 | EXPECTED RESULTS | verdict | api | Claims Dashboard: EU 261 selected per fixed priority; Base = �600 (~$880 CAD); AC Wallet = ~$1,056 CAD; Exchange rate logged for AC Wallet c | Claims Dashboard: EU 261 selected per fixed priority; Base = �600 (~$880 CAD); AC Wallet = ~$1,056 CAD; Exchange rate logged for AC Wallet conversion; DDS = FD- |
