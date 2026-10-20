# FD_TC_115 · CHAI-31507 — checkpoints

**Goal:** UK-origin flight diverted to sister city YTZ AND arrival code missing (fallback to departure code 42). BOTH flags TRUE simultaneously � Sister City + Fallback. 3.5hr delay = UK Tier 1. Validates the COMBINED Sister City + Fallback mechanism under EU 261 UK.

Methods: seed 8, chat 58, api 23, email 3, dashboard 46, implied 21, manual 14, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | UK-origin flight diverted to sister city YTZ AND arrival code missing (fallback to departure code 42). BOTH flags TRUE simultaneously � Sist |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger | PNR: single passenger |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, LHR?YYZ, diverted to YTZ | Journey: 1 leg AC operated, LHR?YYZ, diverted to YTZ |
| CP004 | PREREQUISITES | prerequisite | seed | Delay: 3.5hrs | Delay: 3.5hrs |
| CP005 | PREREQUISITES | prerequisite | seed | Arrival code: NULL (MISSING) | Arrival code: NULL (MISSING) |
| CP006 | PREREQUISITES | prerequisite | seed | Departure code: 42 (Scheduled Maintenance � Controllable) | Departure code: 42 (Scheduled Maintenance � Controllable) |
| CP007 | PREREQUISITES | prerequisite | seed | Sister City: YYZ?YTZ | Sister City: YYZ?YTZ |
| CP008 | PREREQUISITES | prerequisite | seed | Fallback: TRUE | Fallback: TRUE |
| CP009 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (UK) + APPR | Regime: EU 261 (UK) + APPR |
| CP010 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP011 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP012 | START | customer | chat | Then user selects English |  |
| CP013 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP014 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP015 | START | customer | chat | And the user says "My flight from London Heathrow was supposed to land at Toronto Pearson but landed at Billy Bishop Toronto City Airport in | My flight from London Heathrow was supposed to land at Toronto Pearson but landed at Billy Bishop Toronto City Airport instead and arrived 3 and a half hours la |
| CP016 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP017 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP018 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP019 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP022 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Oliver Bennett" | Oliver Bennett |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Oliver! And, what is your booking reference number? |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC072" | PNR: TC072 |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC072 |  |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: o***@gmail.com � Phone: +44***678 |
| CP030 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: o***@gmail.com" | Email: o***@gmail.com |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP033 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP035 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP036 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP037 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP038 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP039 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Oliver Bennett (Adult) Is this who you'd like to include? |
| CP040 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP041 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP042 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 849 � Route: London Heathrow (LHR) ? Toronto (YYZ) [Landed at Billy Bishop (YTZ)] � Date: May 26, 2026 � Arrival Del |
| CP043 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP047 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP048 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 26, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP049 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (UK) = 6 years ? within limitation ? PROCEED |  |
| CP050 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = LHR (UK) ? EU 261 (UK) |  |
| CP051 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 849, Route: LHR ? YYZ, Scheduled Arrival: 16:00 at YYZ | Promised Itinerary - Flight: AC 849, Route: LHR ? YYZ, Scheduled Arrival: 16:00 at YYZ |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 849, Route: LHR ? YTZ (sister city), Status: ARRIVED LATE, Scheduled Arrival: 16:00 ? Actual: 19:30 at YTZ, D | Current Itinerary - Flight: AC 849, Route: LHR ? YTZ (sister city), Status: ARRIVED LATE, Scheduled Arrival: 16:00 ? Actual: 19:30 at YTZ, Delay: +3H 30M |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Sister City Check: YTZ ? YYZ = VALID PAIR (confirmed in DDS sister city config) | Sister City Check: YTZ ? YYZ = VALID PAIR (confirmed in DDS sister city config) |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Sister city accepted as equivalent destination | Sister city accepted as equivalent destination |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Regime: EU 261 (UK) | Regime: EU 261 (UK) |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Origin Region: LHR = UK | Origin Region: LHR = UK |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 849 � LHR ? YTZ � ARRIVAL CODE: NULL (MISSING) | MSL FLIGHT: AC 849 � LHR ? YTZ � ARRIVAL CODE: NULL (MISSING) |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | FALLBACK TRIGGERED: Arrival code NULL ? using departure code | FALLBACK TRIGGERED: Arrival code NULL ? using departure code |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Departure Code: 42 (Scheduled Maintenance) | Departure Code: 42 (Scheduled Maintenance) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Fallback Flag: TRUE | Fallback Flag: TRUE |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42 via fallback departure code) | CONTROLLABLE (Code 42 via fallback departure code) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +3H 30M � CONTROLLABLE | Delay: +3H 30M � CONTROLLABLE |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | EU 261 UK Tier: 3�<4 hrs ? UK Tier 1 | EU 261 UK Tier: 3�<4 hrs ? UK Tier 1 |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | MR OLIVER BENNETT / ELIGIBLE / EU261_UK_DELAY_3_TO_LT_4_HOURS (SISTER CITY + FALLBACK) / GBP 260.00 / [expiry date] | MR OLIVER BENNETT / ELIGIBLE / EU261_UK_DELAY_3_TO_LT_4_HOURS (SISTER CITY + FALLBACK) / GBP 260.00 / [expiry date] |
| CP067 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP068 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP069 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP070 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 849 from London Heathrow (LHR) to Toronto (YYZ) was delayed by about 3 hours and 30 minutes. Based |
| CP071 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP072 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "United Kingdom" | United Kingdom |
| CP073 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = UK ? Currency = GBP |  |
| CP074 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP075 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP076 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a �260 GBP compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a �260 GBP compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP077 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP078 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP079 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? BSM � Email Payment (UK) |  |
| CP080 | PAYMENT METHOD � BSM EMAIL TRANSFER (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment re |
| CP081 | PAYMENT METHOD � BSM EMAIL TRANSFER (FD-07) | customer | chat | And user provides "Yes" | Yes |
| CP082 | PAYMENT METHOD � BSM EMAIL TRANSFER (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP085 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP086 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP087 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP088 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP089 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP090 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �260 GBP Payment Method: Email Transfer After submission, you will receive a confirmation email summarizing your eligibility, claim details and  |
| CP091 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP092 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP093 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP094 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP095 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP096 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP097 | NOTIFICATION | email | email | And an eligible notification email is sent to o***@gmail.com |  |
| CP098 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�260 GBP), regulation (EU 261 UK), flight details (including sister city note:  |  |
| CP099 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP100 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP101 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Oliver Bennett" with PNR "TC072" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Oliver Bennett" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC072" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (UK)" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Oliver Bennett" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "o***@gmail.com" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+44***678" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: LHR ? YYZ" with landing at YTZ as sister city and claim filed for this flight |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "�260 GBP" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 UK with delay 3h 30m and long-haul and controllable Code 42  |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Oliver Bennett + TC072 + LHR?YYZ + FD" |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing compensation "�260 GBP" and regulation "EU 261 UK" and sister  |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP156 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "United Kingdom" |  |
| CP157 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "GBP" |  |
| CP158 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM � Email Payment" |  |
| CP159 | PAYMENT VALIDATION | payment | chat | And the customer details should be collected including email address |  |
| CP160 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP161 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "�260" GBP |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP163 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP164 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP165 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP166 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP167 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should record GBP amount and CAD equivalent and exchange rate and source and date |  |
| CP168 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details with amount in GBP and payment method "Cash" via "Bank Transfer" and st |  |
| CP169 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-EL-07. | DDS returns FD-EU-EL-07. |
| CP170 | EXPECTED RESULTS | verdict | api | Trip Tracer: Delay = 3.5hrs; MSL = Leg 1; Code 42 (Departure, Fallback); Controllable; Sister City = TRUE; Fallback = TRUE; UK Tier 1. | Trip Tracer: Delay = 3.5hrs; MSL = Leg 1; Code 42 (Departure, Fallback); Controllable; Sister City = TRUE; Fallback = TRUE; UK Tier 1. |
| CP171 | EXPECTED RESULTS | verdict | api | Dual Regime: EU-UK = EL-07 (Tier 1, Sister City + Fallback); APPR = EL-10 ($400, Sister City + Fallback). | Dual Regime: EU-UK = EL-07 (Tier 1, Sister City + Fallback); APPR = EL-10 ($400, Sister City + Fallback). |
| CP172 | EXPECTED RESULTS | verdict | chat | Most Generous: EU-UK selected. | Most Generous: EU-UK selected. |
| CP173 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP174 | EXPECTED RESULTS | verdict | dashboard | Claims Dashboard: EU-UK EL-07(260 GBP) ? SELECTED; | Claims Dashboard: EU-UK EL-07(260 GBP) ? SELECTED; |
