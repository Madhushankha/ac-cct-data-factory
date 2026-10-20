# FD_TC_118 · CHAI-31510 — checkpoints

**Goal:** Guadeloupe-origin flight (PTP?YUL) diverted to sister-city airport YOW (Ottawa) instead of YUL (Montr�al Trudeau). 3.5hr delay, controllable. Sister City flag = TRUE. Flat �400 Guadeloupe rate with sister city. Validates: (1) Sister city pairing YUL?YOW (Ottawa) works under EU-Guadeloupe regime, (3) Flat �400 unchanged by sister city (no additional deduction or premium).

Methods: seed 11, chat 61, api 22, email 3, dashboard 45, implied 24, manual 14, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Guadeloupe-origin flight (PTP?YUL) diverted to sister-city airport YOW (Ottawa) instead of YUL (Montr�al Trudeau). 3.5hr delay, controllable |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger (Adult) | PNR: single passenger (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 1840, PTP?YUL, diverted to YOW (sister city of YUL) | Journey: 1 leg AC operated, Flight AC 1840, PTP?YUL, diverted to YOW (sister city of YUL) |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival at YUL: 18:00 | Scheduled arrival at YUL: 18:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival at YOW: 21:30 (3.5hr delay) | Actual arrival at YOW: 21:30 (3.5hr delay) |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival Delay code: 42 (Controllable) | Arrival Delay code: 42 (Controllable) |
| CP007 | PREREQUISITES | prerequisite | seed | Arrival code: 42 (available) | Arrival code: 42 (available) |
| CP008 | PREREQUISITES | prerequisite | seed | Sister city mapping: YUL?YOW = VALID PAIR | Sister city mapping: YUL?YOW = VALID PAIR |
| CP009 | PREREQUISITES | prerequisite | seed | Fallback: FALSE | Fallback: FALSE |
| CP010 | PREREQUISITES | prerequisite | seed | Origin: PTP � Guadeloupe (EU outermost region) | Origin: PTP � Guadeloupe (EU outermost region) |
| CP011 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (Guadeloupe) + APPR | Regime: EU 261 (Guadeloupe) + APPR |
| CP012 | PREREQUISITES | prerequisite | seed | Residence: France (Guadeloupe) ? EUR ? Email | Residence: France (Guadeloupe) ? EUR ? Email |
| CP013 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP014 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP015 | START | customer | chat | Then user selects English |  |
| CP016 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP017 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP018 | START | customer | chat | And the user says "My flight from Pointe-�-Pitre was supposed to land at Montreal Trudeau but landed at Ottawa instead and arrived 3 and a h | My flight from Pointe-�-Pitre was supposed to land at Montreal Trudeau but landed at Ottawa instead and arrived 3 and a half hours late due to a crew issue, I'd |
| CP019 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP020 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP021 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP022 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Marie-Jos�e Laroche" | Marie-Jos�e Laroche |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Marie-Jos�e! And, what is your booking reference number? |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC075" | PNR: TC075 |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC075 |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: m***@gmail.com � Phone: +590***234 |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: m***@gmail.com" | Email: m***@gmail.com |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP036 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP038 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Marie-Jos�e Laroche (Adult) Is this who you'd like to include? |
| CP043 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP045 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 1802 � Route: Pointe-�-Pitre (PTP) ? Montreal (YUL) [Landed at Ottawa(YOW)] � Date: May 26, 2026 � Arrival Delay: 3  |
| CP046 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP047 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP051 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 26, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction) = 5 years ? within limitation ? PROCEED |  |
| CP053 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = PTP (Guadeloupe � EU outermost region) ? EU 261 (Guadeloupe) |  |
| CP054 | REGIME DETERMINATION | system | implied | And the system checks: Guadeloupe compensation rule ? Flat �400 |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 1802, Route: PTP ? YUL, Scheduled Arrival: 18:00 at YUL | Promised Itinerary - Flight: AC 1802, Route: PTP ? YUL, Scheduled Arrival: 18:00 at YUL |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 1802, Route: PTP ? YOW (sister city), Status: ARRIVED LATE, Scheduled Arrival: 18:00 ? Actual: 21:30 at YOW,  | Current Itinerary - Flight: AC 1802, Route: PTP ? YOW (sister city), Status: ARRIVED LATE, Scheduled Arrival: 18:00 ? Actual: 21:30 at YOW, Delay: +3H 30M |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Sister City Check: YOW ? YUL = VALID PAIR (confirmed in DDS sister city config) | Sister City Check: YOW ? YUL = VALID PAIR (confirmed in DDS sister city config) |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Sister city accepted as equivalent destination | Sister city accepted as equivalent destination |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Regime: EU 261 (Guadeloupe / DOM-TOM) | Regime: EU 261 (Guadeloupe / DOM-TOM) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Compensation Rule: Flat �400 | Compensation Rule: Flat �400 |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 1802 � PTP ? YOW � 42 | MSL FLIGHT: AC 1802 � PTP ? YOW � 42 |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to scheduled maintenance" | "Delayed due to scheduled maintenance" |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +3H 30M � CONTROLLABLE | Delay: +3H 30M � CONTROLLABLE |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Sister City: TRUE (YOW?YUL) | Sister City: TRUE (YOW?YUL) |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE | Fallback: FALSE |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | MS MARIE-JOS�E LAROCHE / ELIGIBLE / EU261_GUADELOUPE_DELAY_GTE_3_HOURS_SISTER_CITY / EUR 400.00 / [expiry date] | MS MARIE-JOS�E LAROCHE / ELIGIBLE / EU261_GUADELOUPE_DELAY_GTE_3_HOURS_SISTER_CITY / EUR 400.00 / [expiry date] |
| CP069 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP070 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP071 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP072 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 1802 from Pointe-�-Pitre (PTP) to Montreal (YUL) was delayed by about 3 hours and 30 minutes. Base |
| CP073 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP074 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "France" | France |
| CP075 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = France ? Currency = EUR |  |
| CP076 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP077 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP078 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a �400 EUR compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a �400 EUR compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP079 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP080 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP081 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? BSM � Email Payment (France/Guadeloupe) |  |
| CP082 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through SEPA bank transfer. Before we move forward, please provide your bank details for the transfer. |
| CP083 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | system | implied | And the chatbot collects: Account holder name, IBAN, BIC/SWIFT |  |
| CP084 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | customer | chat | And the user provides bank details |  |
| CP085 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | system | implied | Then the chatbot confirms: "Thank you. Your bank details have been recorded." |  |
| CP086 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP087 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP088 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP089 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP090 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP091 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP092 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP093 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP094 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �400 EUR Payment Method: BSM � Email Payment After submission, you will receive a confirmation email summarizing your eligibility, claim details |
| CP095 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP096 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP097 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP098 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP099 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP100 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP101 | NOTIFICATION | email | email | And an eligible notification email is sent to m***@gmail.com |  |
| CP102 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�400 EUR), regulation (EU 261/2004), flight details (including sister city note |  |
| CP103 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP104 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP105 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Marie-Jos�e Laroche" with PNR "TC075" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Marie-Jos�e Laroche" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC075" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (Guadeloupe / DOM-TOM)" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Marie-Jos�e Laroche" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "m***@gmail.com" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+590***234" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: PTP ? YUL" with landing at YOW as sister city and claim filed for this flight |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "�400 EUR" as Guadeloupe flat rate |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 Guadeloupe with delay 3h 30m and controllable Code 42 and si |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Marie-Jos�e Laroche + TC075 + PTP?YUL + FD" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing compensation "�400 EUR" and regulation "EU 261/2004" and siste |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP160 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "France/EU" |  |
| CP161 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "EUR" |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM � Email Payment" |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And the bank details should be collected including IBAN and BIC/SWIFT |  |
| CP164 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP165 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "�400" as Guadeloupe flat rate |  |
| CP166 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP167 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP168 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP169 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP170 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP171 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should record EUR amount and CAD equivalent and exchange rate and source and date |  |
| CP172 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details "�400 EUR" with payment method "Cash" via "SEPA" and status updated via |  |
| CP173 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-EL-10. | DDS returns FD-EU-EL-10. |
| CP174 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 18:00 YUL; Actual = 21:30 YOW; Delay = 3.5hrs; MSL = Leg 1; Code 42; Controllable; Sister City = TRUE (YUL?YOW); Fall | Trip Tracer: Promise = 18:00 YUL; Actual = 21:30 YOW; Delay = 3.5hrs; MSL = Leg 1; Code 42; Controllable; Sister City = TRUE (YUL?YOW); Fallback = FALSE. |
| CP175 | EXPECTED RESULTS | verdict | chat | Guadeloupe Rate: Flat �400 (sister city does not change amount). | Guadeloupe Rate: Flat �400 (sister city does not change amount). |
| CP176 | EXPECTED RESULTS | verdict | api | Dual Regime: EU-Guadeloupe = EL-10 (�400, Sister City); APPR = EL-04 ($400, Sister City). | Dual Regime: EU-Guadeloupe = EL-10 (�400, Sister City); APPR = EL-04 ($400, Sister City). |
| CP177 | EXPECTED RESULTS | verdict | chat | Most Generous: EU-Guadeloupe selected (�400 ? ~$590 CAD > $400). | Most Generous: EU-Guadeloupe selected (�400 ? ~$590 CAD > $400). |
| CP178 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP179 | EXPECTED RESULTS | verdict | chat | IDV: PASS. | IDV: PASS. |
| CP180 | EXPECTED RESULTS | verdict | chat | Payment: SEPA Bank Transfer to FR76***342 (EUR). | Payment: SEPA Bank Transfer to FR76***342 (EUR). |
| CP181 | EXPECTED RESULTS | verdict | api | Claims Dashboard: EU 261 (Guadeloupe) EL-10 ? SELECTED; �400 flat; Sister City = TRUE (YUL?YOW); Fallback = FALSE; DDS = FD-EU-EL-10. | Claims Dashboard: EU 261 (Guadeloupe) EL-10 ? SELECTED; �400 flat; Sister City = TRUE (YUL?YOW); Fallback = FALSE; DDS = FD-EU-EL-10. |
