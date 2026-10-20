# FD_TC_120 · CHAI-31512 — checkpoints

**Goal:** Guadeloupe-origin flight diverted to sister city YOW (Ottawa) AND arrival code missing (fallback to departure code 42). BOTH flags TRUE simultaneously. Flat �400 Guadeloupe rate.

Methods: seed 11, chat 63, api 22, email 3, dashboard 45, implied 22, manual 14, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Guadeloupe-origin flight diverted to sister city YOW (Ottawa) AND arrival code missing (fallback to departure code 42). BOTH flags TRUE simu |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Laurent Mercier (Adult) | PNR: single passenger Laurent Mercier (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 1840, PTP?YUL, diverted to YOW (sister city of YUL) | Journey: 1 leg AC operated, Flight AC 1840, PTP?YUL, diverted to YOW (sister city of YUL) |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival at YUL: 18:00 | Scheduled arrival at YUL: 18:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival at YOW: 21:30 (3.5hr delay) | Actual arrival at YOW: 21:30 (3.5hr delay) |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival code: NULL (MISSING) | Arrival code: NULL (MISSING) |
| CP007 | PREREQUISITES | prerequisite | seed | Departure code: 42 (Scheduled Maintenance � Controllable) | Departure code: 42 (Scheduled Maintenance � Controllable) |
| CP008 | PREREQUISITES | prerequisite | seed | Sister City: YUL?YOW = VALID PAIR | Sister City: YUL?YOW = VALID PAIR |
| CP009 | PREREQUISITES | prerequisite | seed | Fallback: TRUE | Fallback: TRUE |
| CP010 | PREREQUISITES | prerequisite | seed | Origin: PTP � Guadeloupe | Origin: PTP � Guadeloupe |
| CP011 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (Guadeloupe) + APPR | Regime: EU 261 (Guadeloupe) + APPR |
| CP012 | PREREQUISITES | prerequisite | seed | Residence: France (Guadeloupe) ? EUR ? BSM � Email Payment | Residence: France (Guadeloupe) ? EUR ? BSM � Email Payment |
| CP013 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP014 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP015 | START | customer | chat | Then user selects English |  |
| CP016 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP017 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP018 | START | customer | chat | And the user says "My flight from Pointe-�-Pitre was supposed to land at Montreal Trudeau but landed at Ottawa instead and arrived 3 and a h | My flight from Pointe-�-Pitre was supposed to land at Montreal Trudeau but landed at Ottawa instead and arrived 3 and a half hours late, I'd like to check if I' |
| CP019 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP020 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP021 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP022 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Laurent Mercier" | Laurent Mercier |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Laurent! And, what is your booking reference number? |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC077" | PNR: TC077 |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC077 |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: l***@gmail.com � Phone: +590426 |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: l@gmail.com" | Email: l@gmail.com |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP036 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP038 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Laurent Mercier (Adult) Is this who you'd like to include? |
| CP043 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP045 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 1840 � Route: Pointe-�-Pitre (PTP) ? Montreal (YUL) [Landed at Ottawa (YOW)] � Date: May 28, 2026 � Arrival Delay: 3 |
| CP046 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP047 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP051 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 28, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction) = 5 years ? within limitation ? PROCEED |  |
| CP053 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = PTP (Guadeloupe � EU outermost region) ? EU 261 (Guadeloupe) |  |
| CP054 | REGIME DETERMINATION | system | implied | And the system checks: Guadeloupe compensation rule ? Flat �400 |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 1840, Route: PTP ? YUL, Scheduled Arrival: 18:00 at YUL | Promised Itinerary - Flight: AC 1840, Route: PTP ? YUL, Scheduled Arrival: 18:00 at YUL |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 1840, Route: PTP ? YOW (sister city), Status: ARRIVED LATE, Scheduled Arrival: 18:00 ? Actual: 21:30 at YOW,  | Current Itinerary - Flight: AC 1840, Route: PTP ? YOW (sister city), Status: ARRIVED LATE, Scheduled Arrival: 18:00 ? Actual: 21:30 at YOW, Delay: +3H 30M |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Sister City Check: YOW ? YUL = VALID PAIR (confirmed in DDS sister city config) | Sister City Check: YOW ? YUL = VALID PAIR (confirmed in DDS sister city config) |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Sister city accepted as equivalent destination | Sister city accepted as equivalent destination |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Regime: EU 261 (Guadeloupe / DOM-TOM) | Regime: EU 261 (Guadeloupe / DOM-TOM) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Compensation Rule: Flat �400 | Compensation Rule: Flat �400 |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 1840 � PTP ? YOW � ARRIVAL CODE: NULL (MISSING) | MSL FLIGHT: AC 1840 � PTP ? YOW � ARRIVAL CODE: NULL (MISSING) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | FALLBACK TRIGGERED: Arrival code NULL ? using departure code | FALLBACK TRIGGERED: Arrival code NULL ? using departure code |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Departure Code: 42 (Scheduled Maintenance) | Departure Code: 42 (Scheduled Maintenance) |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Fallback Flag: TRUE | Fallback Flag: TRUE |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42 via fallback departure code) | CONTROLLABLE (Code 42 via fallback departure code) |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +3H 30M � CONTROLLABLE | Delay: +3H 30M � CONTROLLABLE |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | MR LAURENT MERCIER / ELIGIBLE / EU261_GUADELOUPE_DELAY_GTE_3_HOURS (SISTER CITY + FALLBACK) / EUR 400.00 / [expiry date] | MR LAURENT MERCIER / ELIGIBLE / EU261_GUADELOUPE_DELAY_GTE_3_HOURS (SISTER CITY + FALLBACK) / EUR 400.00 / [expiry date] |
| CP070 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP071 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP072 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP073 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 1840 from Pointe-�-Pitre (PTP) to Montreal (YUL) was delayed by about 3 hours and 30 minutes. Base |
| CP074 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP075 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "France" | France |
| CP076 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = France ? Currency = EUR |  |
| CP077 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP078 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a �400 EUR compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a �400 EUR compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP079 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP080 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP081 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? BSM � Email Payment (France) |  |
| CP082 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | bot | chat | Then the chatbot responds: "Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email add | Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment re |
| CP083 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | system | implied | And user responds: "Yes, confirm this email." |  |
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
| CP095 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �400 EUR Payment Method: BSM � Email Payment After submission, you will receive a confirmation email summarizing your eligibility, claim details |
| CP096 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP097 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP098 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP099 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP100 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP101 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP102 | NOTIFICATION | email | email | And an eligible notification email is sent to l***@gmail.com |  |
| CP103 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�400 EUR), regulation (EU 261/2004), flight details (including sister city note |  |
| CP104 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP105 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP106 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Laurent Mercier" with PNR "TC077" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Laurent Mercier" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC077" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (Guadeloupe / DOM-TOM)" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Laurent Mercier" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "l***@gmail.com" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+590***426" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: PTP ? YUL" with landing at YOW as sister city and claim filed for this flight |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "�400 EUR" as Guadeloupe flat rate |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 Guadeloupe with delay 3h 30m and controllable Code 42 via fa |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Laurent Mercier + TC077 + PTP?YUL + FD" |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing compensation "�400 EUR" and regulation "EU 261/2004" and siste |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP161 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "France (Guadeloupe)" |  |
| CP162 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "EUR" |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM � Email Payment" |  |
| CP164 | PAYMENT VALIDATION | payment | chat | And the customer details should be collected including email address |  |
| CP165 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP166 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "�400" as Guadeloupe flat rate |  |
| CP167 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP168 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP169 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP170 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP171 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP172 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should record EUR amount and CAD equivalent and exchange rate and source and date for PRISM/Exposure reporti |  |
| CP173 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details with amount in EUR and payment method "Cash" via "BSM � Email Payment"  |  |
| CP174 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-EL-12. | DDS returns FD-EU-EL-12. |
| CP175 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 18:00 YUL; Actual = 21:30 YOW; Delay = 3.5hrs; MSL = Leg 1; Departure Code = 42; Sister City = TRUE (YUL?YOW); Fallba | Trip Tracer: Promise = 18:00 YUL; Actual = 21:30 YOW; Delay = 3.5hrs; MSL = Leg 1; Departure Code = 42; Sister City = TRUE (YUL?YOW); Fallback = TRUE; Controlla |
| CP176 | EXPECTED RESULTS | verdict | chat | Guadeloupe Rate: Flat �400 (unchanged by sister city or fallback). | Guadeloupe Rate: Flat �400 (unchanged by sister city or fallback). |
| CP177 | EXPECTED RESULTS | verdict | api | Dual Regime: EU-Guadeloupe = EL-12 (�400, Sister City + Fallback); APPR = EL-10 ($400, Sister City + Fallback). | Dual Regime: EU-Guadeloupe = EL-12 (�400, Sister City + Fallback); APPR = EL-10 ($400, Sister City + Fallback). |
| CP178 | EXPECTED RESULTS | verdict | chat | Most Generous: EU-Guadeloupe selected. | Most Generous: EU-Guadeloupe selected. |
| CP179 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP180 | EXPECTED RESULTS | verdict | chat | IDV: PASS. | IDV: PASS. |
| CP181 | EXPECTED RESULTS | verdict | chat | Payment: BSM � Email Payment. | Payment: BSM � Email Payment. |
