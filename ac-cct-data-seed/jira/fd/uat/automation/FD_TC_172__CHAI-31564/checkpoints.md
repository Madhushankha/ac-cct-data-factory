# FD_TC_172 · CHAI-31564 — checkpoints

**Goal:** Mixed Regime � APPR + EU Eligible (EU Selected per Fixed Priority). Flight from Paris CDG to Toronto YYZ � EU origin, arriving in Canada. EU 261 applies (CDG = EU origin) AND APPR applies (YYZ = Canada destination). Both regimes find eligible with controllable cause. Per the Most Generous Logic, when APPR & EU both apply, EU is always selected first (fixed priority hierarchy approved by legal team, not amount comparison). At 4hr delay for >3500km: APPR = $400 CAD, EU (EU261) = �600. EU selected per fixed priority. Validates dual-regime assessment and fixed-priority selection logic.

Methods: seed 8, chat 73, api 22, email 3, dashboard 49, implied 26, manual 15, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Mixed Regime � APPR + EU Eligible (EU Selected per Fixed Priority). Flight from Paris CDG to Toronto YYZ � EU origin, arriving in Canada. EU |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Marie Lef�vre), 1 leg AC operated CDG?YYZ | PNR: Single passenger (Marie Lef�vre), 1 leg AC operated CDG?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: Scheduled arrival 16:00 (YYZ local), Actual arrival 20:00 (4hr delay) | Itinerary: Scheduled arrival 16:00 (YYZ local), Actual arrival 20:00 (4hr delay) |
| CP004 | PREREQUISITES | prerequisite | seed | Disruption code: 42 (Controllable) | Disruption code: 42 (Controllable) |
| CP005 | PREREQUISITES | prerequisite | seed | Flight distance: CDG?YYZ = ~5,500km (>3500km band) | Flight distance: CDG?YYZ = ~5,500km (>3500km band) |
| CP006 | PREREQUISITES | prerequisite | seed | Flight status: Arrived (operated) | Flight status: Arrived (operated) |
| CP007 | PREREQUISITES | prerequisite | seed | Booking changes: None | Booking changes: None |
| CP008 | PREREQUISITES | prerequisite | seed | Carrier: AC only | Carrier: AC only |
| CP009 | PREREQUISITES | prerequisite | seed | Route context: EU origin (CDG) ? EU 261 applies; Canada arrival (YYZ) ? APPR applies; Not Israel ? ASL N/A | Route context: EU origin (CDG) ? EU 261 applies; Canada arrival (YYZ) ? APPR applies; Not Israel ? ASL N/A |
| CP010 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP011 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP012 | START | customer | chat | Then user selects English |  |
| CP013 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP014 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP015 | START | customer | chat | And the user says "My flight from Paris to Toronto was delayed 4 hours. I'd like to check if I'm eligible for compensation" | My flight from Paris to Toronto was delayed 4 hours. I'd like to check if I'm eligible for compensation |
| CP016 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP017 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP018 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP019 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP022 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Marie Lef�vre" | Marie Lef�vre |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Marie! And, what is your booking reference number? |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC146" | PNR: TC146 |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC146 |  |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: m***@gmail.com Phone: +33***234 |
| CP030 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: m***@gmail.com" | Email: m***@gmail.com |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP033 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP035 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP036 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP037 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP038 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP039 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Marie Lef�vre (Adult) Is this who you'd like to include? |
| CP040 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP041 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP042 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 871 Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ) Date: June 10, 2026 Arrival Delay: 4 hours Is this the journe |
| CP043 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP047 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP048 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (France = 5 years) and APPR ? within limitation ? PROCEED |  |
| CP049 | REGIME DETERMINATION � DUAL REGIME | system | implied | Then the system determines applicable regimes: |  |
| CP050 | REGIME DETERMINATION � DUAL REGIME | system | implied | And the system checks: Origin airport = CDG (Paris, France, EU) ? EU 261 applies |  |
| CP051 | REGIME DETERMINATION � DUAL REGIME | system | implied | And the system checks: Destination airport = YYZ (Toronto, Canada) ? APPR applies |  |
| CP052 | REGIME DETERMINATION � DUAL REGIME | system | implied | And the system checks: Destination = YYZ (not Israel) ? ASL does NOT apply |  |
| CP053 | REGIME DETERMINATION � DUAL REGIME | verdict | api | And the system determines: DUAL REGIME � EU 261 + APPR (both assessed independently) |  |
| CP054 | TRIAGE & DDS EVALUATION � DUAL REGIME FIXED PRIORITY | verdict | api | Then the DDS evaluation is done in backend |  |
| CP055 | TRIAGE & DDS EVALUATION � DUAL REGIME FIXED PRIORITY | verdict | api | And DDS assesses BOTH regimes independently: |  |
| CP056 | EU 261 ASSESSMENT | system | implied | ? Origin: CDG (EU) ? EU 261 applies | ? Distance: CDG?YYZ = ~5,500 km ? Long-haul (>3500km) ? Delay: 4 hours ? 4+ threshold ? Code: 42 ? Controllable under EU 261 ? EU 261 Result: ELIGIBLE � �600 (E |
| CP057 | APPR ASSESSMENT | system | implied | ? Destination: YYZ (Canada) ? APPR applies | ? Delay: 4 hours ? 3�<6h tier (Tier 1) ? Code: 42 ? Controllable under APPR ? APPR Result: ELIGIBLE � $400 CAD (Tier 1: 3�<6 hours) |
| CP058 | MOST GENEROUS SELECTION | system | implied | ? Applicable regimes: APPR & EU | ? Per Most Generous Logic: APPR & EU ? EU is always selected first (fixed priority hierarchy per legal team approval) ? EU 261: �600 ? APPR: $400 CAD (not selec |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 871, Route: CDG ? YYZ, Scheduled Arrival: 16:00 | Promised Itinerary - Flight: AC 871, Route: CDG ? YYZ, Scheduled Arrival: 16:00 |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 871, Route: CDG ? YYZ, Status: ARRIVED LATE, Actual: 20:00, Delay: +4H 00M | Current Itinerary - Flight: AC 871, Route: CDG ? YYZ, Status: ARRIVED LATE, Actual: 20:00, Delay: +4H 00M |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Dual Regime: EU 261 + APPR | Dual Regime: EU 261 + APPR |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | EU 261: ELIGIBLE � �600 | EU 261: ELIGIBLE � �600 |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | APPR: ELIGIBLE � $400 CAD | APPR: ELIGIBLE � $400 CAD |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Most Generous: EU 261 � �600 (fixed priority: EU always selected over APPR) | Most Generous: EU 261 � �600 (fixed priority: EU always selected over APPR) |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 871 � CDG ? YYZ � 42 | MSL FLIGHT: AC 871 � CDG ? YYZ � 42 |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42) | CONTROLLABLE (Code 42) |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE | Fallback: FALSE |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Sister City: FALSE | Sister City: FALSE |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | MS MARIE LEF�VRE / ELIGIBLE / EU261_4_PLUS_HOURS_LONG_HAUL (FIXED PRIORITY) / �600 | MS MARIE LEF�VRE / ELIGIBLE / EU261_4_PLUS_HOURS_LONG_HAUL (FIXED PRIORITY) / �600 |
| CP070 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP071 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP072 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP073 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 871 from Paris Charles de Gaulle (CDG) to Toronto (YYZ) was delayed by about 4 hours. Based on the |
| CP074 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP075 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "France" | France |
| CP076 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = France ? Currency = EUR ? Payment Method = BSM Email Payment |  |
| CP077 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP078 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP079 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive �600 compensation. Please note that it will take 5 to 10 business days to process pa | You are entitled to receive �600 compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP080 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency (EUR)." | Please note that payments will be deposited in your local currency (EUR). |
| CP081 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP082 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Bank Transfer (SEPA) |  |
| CP083 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment re |
| CP084 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | customer | chat | And user provides "Yes" | Yes |
| CP085 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP086 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP087 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP088 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP089 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP090 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP091 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP092 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP093 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP094 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP095 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP096 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �600 Payment Method: Email After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps. W |
| CP097 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP098 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP099 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP100 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP101 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP102 | CURRENCY CONVERSION LOGGING | verdict | api | ? Compensation Amount (Selected Regime � EU 261): �600 EUR | ? APPR Amount (Not Selected): $400 CAD ? Exchange Rate Used: 1 EUR = 1.4667 CAD (for internal reporting only, NOT used for regime selection) ? CAD Equivalent of |
| CP103 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP104 | NOTIFICATION | email | email | And an eligible notification email is sent to m***@gmail.com |  |
| CP105 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�600 EUR), regulation (EU 261 � selected per fixed priority), flight details (C |  |
| CP106 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP107 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP108 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Marie Lef�vre" with PNR "TC146" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Marie Lef�vre" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC146" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 + APPR (Dual Regime � EU 261 SELECTED per fixed priority)" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Marie Lef�vre" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: CDG ? YYZ" with claim filed for this flight |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Primary Selected regime should be EU 261 with eligibility ELIGIBLE and compensation "�600 EUR" for greater than 3500km controllable  |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Secondary Not Selected regime should be APPR with eligibility ELIGIBLE and compensation "$400 CAD" Tier 1 3 to less than 6hrs contro |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Selection Method should be fixed priority hierarchy NOT CAD conversion comparison |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And per Confluence "APPR & EU ? 1. EU, 2. APPR" and legal note "Although certain EU amounts are slightly below the CAD, they were fine with  |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And BOTH regimes should be assessed and logged |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 selected per fixed priority |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the APPR assessment should be visible alongside the EU 261 assessment |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And EU 261 should be flagged as SELECTED |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Marie Lef�vre + TC146 + CDG?YYZ + FD" |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing compensation "�600 EUR" and regulation "EU 261" and flight det |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record dual-regime assessment with EU 261 at �600 selected per fixed priority and APPR at $400 not selected |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the exchange rate should be logged in audit trail for internal reporting with source and date and value |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP166 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP167 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "France" |  |
| CP168 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "EUR" |  |
| CP169 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM Email Payment" |  |
| CP170 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP171 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "�600" EUR |  |
| CP172 | PAYMENT VALIDATION | payment | chat | And the selection should be by fixed priority order with EU always over APPR per legal team approval NOT by CAD conversion comparison |  |
| CP173 | PAYMENT VALIDATION | payment | chat | And IDV at Payment should be triggered via Persona and the customer should complete IDV and Persona should return IDV PASS |  |
| CP174 | PAYMENT VALIDATION | payment | chat | And the claim amount confirmation should show �600 EUR via Email and the customer should confirm and the claim should be submitted |  |
| CP175 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP176 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP177 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier and Unifier should process BSM Email Payment |  |
| CP178 | PAYMENT VALIDATION | payment | manual | And HSBC should send an acknowledgement back and the end-of-day report should be received |  |
| CP179 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP180 | PAYMENT VALIDATION | payment | chat | And if payment fails a failure notification should be sent to the case and the agent should be flagged |  |
| CP181 | PAYMENT VALIDATION | payment | chat | And SEPA transfer processing should take 5 to 10 business days |  |
| CP182 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details "�600 EUR" with payment method "Cash" via "SEPA Bank Transfer" and stat |  |
| CP183 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should be for internal reporting only with �600 EUR multiplied by Bank of Canada rate equaling approximately |  |
| CP184 | PAYMENT VALIDATION | payment | chat | And exchange rate source should be Bank of Canada with exchange rate date and value logged for reporting only |  |
| CP185 | PAYMENT VALIDATION | payment | chat | And both regime assessments should be logged in audit trail with EU 261 Eligible �600 SELECTED per fixed priority and APPR Eligible $400 not |  |
| CP186 | PAYMENT VALIDATION | payment | chat | And the compensation amount must be the EU 261 amount �600 NOT the APPR amount $400 |  |
| CP187 | PAYMENT VALIDATION | payment | chat | And the payment currency should follow the customer's country of residence France resulting in EUR and EU 261 compensation is already in EUR |  |
| CP188 | PAYMENT VALIDATION | payment | chat | And no CAD conversion comparison should be performed for regime selection as selection is by fixed priority hierarchy per legal team approva |  |
| CP189 | EXPECTED RESULTS | verdict | api | DDS returns FD-MIXED-EL-01. | DDS returns FD-MIXED-EL-01. |
| CP190 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 16:00; Actual = 20:00; Delay = 4hrs; MSL = Leg 1 (AC CDG?YYZ); Code 42; Controllable; Regime = EU 261 + APPR (both ap | Trip Tracer: Promise = 16:00; Actual = 20:00; Delay = 4hrs; MSL = Leg 1 (AC CDG?YYZ); Code 42; Controllable; Regime = EU 261 + APPR (both apply). |
| CP191 | EXPECTED RESULTS | verdict | chat | Dual Assessment: EU 261 = �600 (EU261 column, 4+ hours, >3500km, controllable); APPR = $400 CAD (Tier 1, 3�<6hrs). | Dual Assessment: EU 261 = �600 (EU261 column, 4+ hours, >3500km, controllable); APPR = $400 CAD (Tier 1, 3�<6hrs). |
| CP192 | EXPECTED RESULTS | verdict | chat | Most Generous Selection: Fixed priority hierarchy � APPR & EU ? EU always first (per legal team approval). | Most Generous Selection: Fixed priority hierarchy � APPR & EU ? EU always first (per legal team approval). |
| CP193 | EXPECTED RESULTS | verdict | chat | EU 261 SELECTED � �600. | EU 261 SELECTED � �600. |
| CP194 | EXPECTED RESULTS | verdict | chat | CRITICAL: Both regimes MUST be assessed and logged. | CRITICAL: Both regimes MUST be assessed and logged. |
| CP195 | EXPECTED RESULTS | verdict | chat | Selection is by fixed priority order, NOT by CAD conversion comparison. | Selection is by fixed priority order, NOT by CAD conversion comparison. |
| CP196 | EXPECTED RESULTS | verdict | dashboard | Dashboard must show APPR result alongside EU result, with EU flagged as selected. | Dashboard must show APPR result alongside EU result, with EU flagged as selected. |
| CP197 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Primary = EU 261 (�600, selected per fixed priority); Secondary = APPR ($400, not selected); DDS = FD-MIXED-EL-01. | Claims Dashboard: Primary = EU 261 (�600, selected per fixed priority); Secondary = APPR ($400, not selected); DDS = FD-MIXED-EL-01. |
