# FD_TC_113 · CHAI-31505 — checkpoints

**Goal:** UK-origin flight (LHR?YYZ) delayed 3.5 hours. Arrival code is MISSING � fallback to departure code. Validates: (1) Fallback logic works under EU 261 UK regime, (2) Fallback flag = TRUE correctly logged, (3) UK Tier 1 applies even when code is obtained via fallback, (4) EU-UK EL-05 is the specific code for UK + Fallback at Tier 1.

Methods: seed 9, chat 62, api 22, email 3, dashboard 46, implied 22, manual 14, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | UK-origin flight (LHR?YYZ) delayed 3.5 hours. Arrival code is MISSING � fallback to departure code. Validates: (1) Fallback logic works unde |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger (Adult) | PNR: single passenger (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 858, LHR?YYZ | Journey: 1 leg AC operated, Flight AC 858, LHR?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 16:00 | Scheduled arrival: 16:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival: 19:30 (3.5hr delay) | Actual arrival: 19:30 (3.5hr delay) |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival code: NULL (MISSING) | Arrival code: NULL (MISSING) |
| CP007 | PREREQUISITES | prerequisite | seed | Departure Delay code: 42(Scheduled Maintenance � Controllable) | Departure Delay code: 42(Scheduled Maintenance � Controllable) |
| CP008 | PREREQUISITES | prerequisite | seed | Fallback: TRUE | Fallback: TRUE |
| CP009 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (UK) + APPR | Regime: EU 261 (UK) + APPR |
| CP010 | PREREQUISITES | prerequisite | seed | Residence: UK ? Email | Residence: UK ? Email |
| CP011 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP012 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP013 | START | customer | chat | Then user selects English |  |
| CP014 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP015 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP016 | START | customer | chat | And the user says "My flight from London Heathrow to Toronto was delayed about 3 and a half hours, I'd like to check if I'm eligible for com | My flight from London Heathrow to Toronto was delayed about 3 and a half hours, I'd like to check if I'm eligible for compensation |
| CP017 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP018 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP019 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP020 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Edward Mitchell" | Edward Mitchell |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Edward! And, what is your booking reference number? |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC070" | PNR: TC070 |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC070 |  |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: e***@gmail.com � Phone: +44***456 |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: e***@gmail.com" | Email: e***@gmail.com |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP034 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP036 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP037 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP039 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Edward Mitchell (Adult) Is this who you'd like to include? |
| CP041 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP043 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 858 � Route: London Heathrow (LHR) ? Toronto (YYZ) � Date: May 24, 2026 � Arrival Delay: 3 hours 30 minutes Is this  |
| CP044 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP049 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 24, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (UK) = 6 years ? within limitation ? PROCEED |  |
| CP051 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = LHR (UK) ? EU 261 (UK) |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 858, Route: LHR ? YYZ, Scheduled Arrival: 16:00 | Promised Itinerary - Flight: AC 858, Route: LHR ? YYZ, Scheduled Arrival: 16:00 |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 858, Route: LHR ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 16:00 ? Actual: 19:30, Delay: +3H 30M | Current Itinerary - Flight: AC 858, Route: LHR ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 16:00 ? Actual: 19:30, Delay: +3H 30M |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Regime: EU 261 (UK) | Regime: EU 261 (UK) |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Origin Region: LHR = UK | Origin Region: LHR = UK |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 858� LHR ? YYZ � ARRIVAL CODE: NULL (MISSING) | MSL FLIGHT: AC 858� LHR ? YYZ � ARRIVAL CODE: NULL (MISSING) |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | FALLBACK TRIGGERED: Arrival code NULL ? using departure code | FALLBACK TRIGGERED: Arrival code NULL ? using departure code |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Departure Code: 42 (Scheduled Maintenance � Controllable) | Departure Code: 42 (Scheduled Maintenance � Controllable) |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Fallback Flag: TRUE | Fallback Flag: TRUE |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42 via fallback departure code) | CONTROLLABLE (Code 42 via fallback departure code) |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +3H 30M � CONTROLLABLE | Delay: +3H 30M � CONTROLLABLE |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | EU 261 UK Tier: 3�<4 hrs ? UK Tier 1 | EU 261 UK Tier: 3�<4 hrs ? UK Tier 1 |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Sister City: FALSE | Sister City: FALSE |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | MR EDWARD MITCHELL / ELIGIBLE / EU261_UK_DELAY_3_TO_LT_4_HOURS_LONG_HAUL (FALLBACK) / GBP 260.00 / [expiry date] | MR EDWARD MITCHELL / ELIGIBLE / EU261_UK_DELAY_3_TO_LT_4_HOURS_LONG_HAUL (FALLBACK) / GBP 260.00 / [expiry date] |
| CP067 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP068 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP069 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP070 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 858 from London Heathrow (LHR) to Toronto (YYZ) was delayed by about 3 hours and 30 minutes. Based |
| CP071 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP072 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "United Kingdom" | United Kingdom |
| CP073 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = UK ? Currency = GBP |  |
| CP074 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP075 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP076 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a �260 GBP compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a �260 GBP compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP077 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP078 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP079 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? BSM � Email Payment (UK) |  |
| CP080 | PAYMENT METHOD � BANK TRANSFER (FD-07) | system | implied | "Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to re |  |
| CP081 | PAYMENT METHOD � BANK TRANSFER (FD-07) | customer | chat | And the user provides "Yes" | Yes |
| CP082 | PAYMENT METHOD � BANK TRANSFER (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP085 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP086 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP087 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP088 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP089 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP090 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP091 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP092 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP093 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �260 GBP Payment Method: Bank Transfer After submission, you will receive a confirmation email summarizing your eligibility, claim details and n |
| CP094 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP095 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP096 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP097 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP098 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP099 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP100 | NOTIFICATION | email | email | And an eligible notification email is sent to e***@gmail.com |  |
| CP101 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�260 GBP), regulation (EU 261 UK), flight details, fallback code note, disrupti |  |
| CP102 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP103 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP104 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Edward Mitchell" with PNR "TC070" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Edward Mitchell" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC070" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (UK)" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Edward Mitchell" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "e***@gmail.com" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+44***456" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: LHR ? YYZ" with claim filed for this flight |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "�260 GBP" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 UK with delay 3h 30m and UK origin and controllable Code 42  |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Edward Mitchell + TC070 + LHR?YYZ + FD" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing compensation "�260 GBP" and regulation "EU 261 UK" and fallbac |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP159 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "United Kingdom" |  |
| CP160 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "GBP" |  |
| CP161 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM � Email Payment" |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And the customer details should be collected including email address |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP164 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "�260" GBP |  |
| CP165 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP166 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP167 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP168 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP169 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP170 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should record GBP amount and CAD equivalent and exchange rate and source and date |  |
| CP171 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details with amount in GBP and payment method "Cash" via "Bank Transfer" and st |  |
| CP172 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-EL-05. | DDS returns FD-EU-EL-05. |
| CP173 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 16:00; Actual = 19:30; Delay = 3.5hrs; MSL = Leg 1; Arrival Code = NULL; Departure Delay Code = 42; Fallback = TRUE;  | Trip Tracer: Promise = 16:00; Actual = 19:30; Delay = 3.5hrs; MSL = Leg 1; Arrival Code = NULL; Departure Delay Code = 42; Fallback = TRUE; Controllable; APPR + |
| CP174 | EXPECTED RESULTS | verdict | api | Dual Regime: EU-UK = EL-05 (Tier 1, Fallback); APPR = EL-07 ($400, Fallback). | Dual Regime: EU-UK = EL-05 (Tier 1, Fallback); APPR = EL-07 ($400, Fallback). |
| CP175 | EXPECTED RESULTS | verdict | chat | Most Generous: EU-UK selected. | Most Generous: EU-UK selected. |
| CP176 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP177 | EXPECTED RESULTS | verdict | chat | IDV: PASS. | IDV: PASS. |
| CP178 | EXPECTED RESULTS | verdict | chat | Payment: Email. | Payment: Email. |
| CP179 | EXPECTED RESULTS | verdict | dashboard | Claims Dashboard: EU-UK EL-05 (260 GBP)? SELECTED; | Claims Dashboard: EU-UK EL-05 (260 GBP)? SELECTED; |
