# FD_TC_117 · CHAI-31509 — checkpoints

**Goal:** Flight from Pointe-�-Pitre (PTP) to Montreal (YUL). Guadeloupe is an EU outermost region (DOM-TOM French territory) covered under EU 261 with a SPECIAL compensation rate � flat �400 regardless of distance band. Validates: (1) PTP correctly identified as Guadeloupe/EU outermost region, (2) Flat �400 applied (no distance band calculation), (3) EU-Guadeloupe (�400 ? ~$590 CAD) is more generous than APPR ($400 CAD) ? EU selected, (4)Email payment for French territory.

Methods: seed 11, chat 64, api 21, email 3, dashboard 45, implied 26, manual 14, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Flight from Pointe-�-Pitre (PTP) to Montreal (YUL). Guadeloupe is an EU outermost region (DOM-TOM French territory) covered under EU 261 wit |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger (Adult) | PNR: single passenger (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 1840, PTP?YUL | Journey: 1 leg AC operated, Flight AC 1840, PTP?YUL |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 18:00 | Scheduled arrival: 18:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival: 21:30 (3.5hr delay) | Actual arrival: 21:30 (3.5hr delay) |
| CP006 | PREREQUISITES | prerequisite | seed | Disruption code: 42 (Controllable) | Disruption code: 42 (Controllable) |
| CP007 | PREREQUISITES | prerequisite | seed | Arrival code: 42 (available) | Arrival code: 42 (available) |
| CP008 | PREREQUISITES | prerequisite | seed | Fallback: FALSE | Fallback: FALSE |
| CP009 | PREREQUISITES | prerequisite | seed | Origin: PTP � Pointe-�-Pitre, Guadeloupe (EU outermost region / DOM-TOM) | Origin: PTP � Pointe-�-Pitre, Guadeloupe (EU outermost region / DOM-TOM) |
| CP010 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (Guadeloupe rate) + APPR (Canada arrival) | Regime: EU 261 (Guadeloupe rate) + APPR (Canada arrival) |
| CP011 | PREREQUISITES | prerequisite | seed | Residence: France (Guadeloupe) ? EUR ? Email  Transfer | Residence: France (Guadeloupe) ? EUR ? Email  Transfer |
| CP012 | PREREQUISITES | prerequisite | seed | Aeroplan: NOT linked | Aeroplan: NOT linked |
| CP013 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP014 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP015 | START | customer | chat | Then user selects English |  |
| CP016 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP017 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP018 | START | customer | chat | And the user says "My flight from Pointe-�-Pitre in Guadeloupe to Montreal was delayed about 3 and a half hours due to a crew issue, I'd lik | My flight from Pointe-�-Pitre in Guadeloupe to Montreal was delayed about 3 and a half hours due to a crew issue, I'd like to check if I'm eligible for compensa |
| CP019 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP020 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP021 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP022 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Jean-Pierre Duval" | Jean-Pierre Duval |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Jean-Pierre! And, what is your booking reference number? |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC074" | PNR: TC074 |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC074 |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: j***@gmail.com � Phone: +590***123 |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: j***@gmail.com" | Email: j***@gmail.com |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP036 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP038 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Jean-Pierre Duval (Adult) Is this who you'd like to include? |
| CP043 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP045 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 1840 � Route: Pointe-�-Pitre (PTP) ? Montreal (YUL) � Date: May 25, 2026 � Arrival Delay: 3 hours 30 minutes Is this |
| CP046 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP047 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP051 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 25, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction) = 5 years |  |
| CP053 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 25, 2026; filing June 15, 2026 ? 21 days ? within limitation ? PROCEED |  |
| CP054 | REGIME DETERMINATION | verdict | api | Then the system determines applicable regime: |  |
| CP055 | REGIME DETERMINATION | system | implied | And the system checks: Origin airport = PTP (Pointe-�-Pitre, Guadeloupe) |  |
| CP056 | REGIME DETERMINATION | system | implied | And the system checks: Is Guadeloupe an EU territory? ? YES (DOM-TOM � French overseas department, EU outermost region) |  |
| CP057 | REGIME DETERMINATION | system | implied | And the system checks: Operating carrier = AC (Air Canada) |  |
| CP058 | REGIME DETERMINATION | system | implied | And the system determines: EU 261 (Guadeloupe) applies � EU outermost region originating flight on any carrier |  |
| CP059 | REGIME DETERMINATION | system | implied | And the system checks: Guadeloupe compensation rule ? Flat �400 regardless of distance band |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 1840, Route: PTP ? YUL, Scheduled Arrival: 18:00 (local YUL time) | Promised Itinerary - Flight: AC 1840, Route: PTP ? YUL, Scheduled Arrival: 18:00 (local YUL time) |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 1840, Route: PTP ? YUL, Status: ARRIVED LATE, Scheduled Arrival: 18:00 ? Actual: 21:30, Delay: +3H 30M | Current Itinerary - Flight: AC 1840, Route: PTP ? YUL, Status: ARRIVED LATE, Scheduled Arrival: 18:00 ? Actual: 21:30, Delay: +3H 30M |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Regime: EU 261 (Guadeloupe / DOM-TOM) | Regime: EU 261 (Guadeloupe / DOM-TOM) |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Origin: PTP (Guadeloupe � EU outermost region) | Origin: PTP (Guadeloupe � EU outermost region) |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Compensation Rule: Flat �400 (Guadeloupe-specific, no distance band tiers) | Compensation Rule: Flat �400 (Guadeloupe-specific, no distance band tiers) |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 1840 � PTP ? YUL � 42 | MSL FLIGHT: AC 1840 � PTP ? YUL � 42 |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to scheduled maintenance" | "Delayed due to scheduled maintenance" |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +3H 30M � CONTROLLABLE | Delay: +3H 30M � CONTROLLABLE |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Sister City: FALSE | Sister City: FALSE |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE | Fallback: FALSE |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | MR JEAN-PIERRE DUVAL / ELIGIBLE / EU261_GUADELOUPE_DELAY_GTE_3_HOURS / EUR 400.00 / [expiry date] | MR JEAN-PIERRE DUVAL / ELIGIBLE / EU261_GUADELOUPE_DELAY_GTE_3_HOURS / EUR 400.00 / [expiry date] |
| CP073 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP074 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP075 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP076 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 1840 from Pointe-�-Pitre (PTP) to Montreal (YUL) was delayed by about 3 hours and 30 minutes. Base |
| CP077 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP078 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "France" | France |
| CP079 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = France ? Currency = EUR |  |
| CP080 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP081 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP082 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a �400 EUR compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a �400 EUR compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP083 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP084 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP085 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? BSM � Email Payment (France/Guadeloupe) |  |
| CP086 | PAYMENT METHOD  � BSM EMAIL PAYMENT (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment re |
| CP087 | PAYMENT METHOD  � BSM EMAIL PAYMENT (FD-07) | customer | chat | And user provides "Yes" | Yes |
| CP088 | PAYMENT METHOD  � BSM EMAIL PAYMENT (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP089 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP090 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP091 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP092 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP093 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP094 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP095 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP096 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP097 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP098 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP099 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �400 EUR Payment Method: BSM � Email Payment After submission, you will receive a confirmation email summarizing your eligibility, claim details |
| CP100 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP101 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP102 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP103 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP104 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP105 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP106 | NOTIFICATION | email | email | And an eligible notification email is sent to j***@gmail.com |  |
| CP107 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�400 EUR), regulation (EU 261/2004), flight details (PTP?YUL), disruption reaso |  |
| CP108 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP109 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP110 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Jean-Pierre Duval" with PNR "TC074" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Jean-Pierre Duval" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC074" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (Guadeloupe / DOM-TOM)" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Jean-Pierre Duval" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "j***@gmail.com" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+590***123" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: PTP ? YUL" with claim filed for this flight |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "�400 EUR" as Guadeloupe flat rate |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 Guadeloupe with delay 3h 30m and controllable Code 42 and fl |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Jean-Pierre Duval + TC074 + PTP?YUL + FD" |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing compensation "�400 EUR" and regulation "EU 261/2004" and fligh |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP165 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "France/EU" |  |
| CP166 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "EUR" |  |
| CP167 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM � Email Payment" |  |
| CP168 | PAYMENT VALIDATION | payment | chat | And the customer details should be collected including email address |  |
| CP169 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP170 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "�400" as Guadeloupe flat rate |  |
| CP171 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP172 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP173 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP174 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP175 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP176 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should record EUR amount and CAD equivalent and exchange rate and source and date for PRISM/Exposure reporti |  |
| CP177 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details "�400 EUR" with payment method "Cash" via "SEPA" and status updated via |  |
| CP178 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-EL-09. | DDS returns FD-EU-EL-09. |
| CP179 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 18:00; Actual = 21:30; Delay = 3.5hrs; MSL = Leg 1 (AC 1840); Code 42; Controllable; Fallback = FALSE; Sister City =  | Trip Tracer: Promise = 18:00; Actual = 21:30; Delay = 3.5hrs; MSL = Leg 1 (AC 1840); Code 42; Controllable; Fallback = FALSE; Sister City = FALSE. |
| CP180 | EXPECTED RESULTS | verdict | chat | Guadeloupe Rate: 3+hrs ? flat �400. | Guadeloupe Rate: 3+hrs ? flat �400. |
| CP181 | EXPECTED RESULTS | verdict | api | Dual Regime: EU-Guadeloupe = EL-09 (�400 flat); APPR = EL-01 ($400 CAD). | Dual Regime: EU-Guadeloupe = EL-09 (�400 flat); APPR = EL-01 ($400 CAD). |
| CP182 | EXPECTED RESULTS | verdict | chat | Currency Comparison: �400 ? ~$590 CAD > $400 CAD ? EU-Guadeloupe selected (most generous). | Currency Comparison: �400 ? ~$590 CAD > $400 CAD ? EU-Guadeloupe selected (most generous). |
| CP183 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP184 | EXPECTED RESULTS | verdict | chat | IDV: PASS. | IDV: PASS. |
| CP185 | EXPECTED RESULTS | verdict | chat | Payment: Email. | Payment: Email. |
