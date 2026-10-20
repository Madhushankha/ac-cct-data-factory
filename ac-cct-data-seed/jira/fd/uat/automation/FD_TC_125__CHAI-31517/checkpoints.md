# FD_TC_125 · CHAI-31517 — checkpoints

**Goal:** EU Rest of Europe flight (CDG?YYZ, AC-operated) delayed at arrival by 3 hours 40 minutes. No arrival delay code is available � the Rules Engine falls back to the first departure delay code (code 19 � Controllable) per Gate 9 priority order: cancellation code ? first arrival delay code ? first departure delay code. Travel Completed + Rest of Europe + 3�<4 hr delay + Controllable (via fallback departure code) = �300. APPR also applies (Canada destination) at $400 CAD � EU wins (�300 ? ~$440 CAD > $400). Validates: (1) Fallback code logic correctly triggers when arrival delay code is unavailable, (2) Departure delay code 19 correctly classified as Controllable, (3) Rest of Europe origin tier + 3�<4 hr delay band = �300, (4) Dual-regime comparison EU vs APPR.

Methods: seed 15, chat 65, api 13, email 3, dashboard 48, implied 26, manual 14, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | EU Rest of Europe flight (CDG?YYZ, AC-operated) delayed at arrival by 3 hours 40 minutes. No arrival delay code is available � the Rules Eng |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Camille Lef�vre (Adult) | PNR: single passenger Camille Lef�vre (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 870, CDG?YYZ | Journey: 1 leg AC operated, Flight AC 870, CDG?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled departure: 10:00 (CDG local) | Scheduled departure: 10:00 (CDG local) |
| CP005 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 13:00 (YYZ local) | Scheduled arrival: 13:00 (YYZ local) |
| CP006 | PREREQUISITES | prerequisite | seed | Actual arrival: 16:40 (YYZ local) | Actual arrival: 16:40 (YYZ local) |
| CP007 | PREREQUISITES | prerequisite | seed | Delay at arrival: 3 hours 40 minutes (220 minutes) | Delay at arrival: 3 hours 40 minutes (220 minutes) |
| CP008 | PREREQUISITES | prerequisite | seed | Arrival delay code: UNAVAILABLE (no arrival code assigned) | Arrival delay code: UNAVAILABLE (no arrival code assigned) |
| CP009 | PREREQUISITES | prerequisite | seed | Departure delay code: 19 (Controllable) � used as fallback per Gate 9 priority order | Departure delay code: 19 (Controllable) � used as fallback per Gate 9 priority order |
| CP010 | PREREQUISITES | prerequisite | seed | Fallback: TRUE (departure code used because arrival code is unavailable) | Fallback: TRUE (departure code used because arrival code is unavailable) |
| CP011 | PREREQUISITES | prerequisite | seed | Customer action: Completed travel � arrived at YYZ | Customer action: Completed travel � arrived at YYZ |
| CP012 | PREREQUISITES | prerequisite | seed | Travel status: Travel Completed | Travel status: Travel Completed |
| CP013 | PREREQUISITES | prerequisite | seed | Origin region: CDG = Rest of Europe | Origin region: CDG = Rest of Europe |
| CP014 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (Rest of Europe) + APPR (Canada arrival) | Regime: EU 261 (Rest of Europe) + APPR (Canada arrival) |
| CP015 | PREREQUISITES | prerequisite | seed | Residence: France ? EUR ? BSM � Email Payment | Residence: France ? EUR ? BSM � Email Payment |
| CP016 | PREREQUISITES | prerequisite | seed | Aeroplan: NOT linked ? Cash only | Aeroplan: NOT linked ? Cash only |
| CP017 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP018 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP019 | START | customer | chat | Then user selects English |  |
| CP020 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP021 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP022 | START | customer | chat | And the user says "My flight from Paris to Toronto arrived almost 4 hours late. Can I get compensation?" | My flight from Paris to Toronto arrived almost 4 hours late. Can I get compensation? |
| CP023 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP024 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP025 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP026 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Camille Lef�vre" | Camille Lef�vre |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Camille! And, what is your booking reference number? |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC082" | PNR: TC082 |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC082 |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: c***@gmail.com Phone: +33***789 |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: c***@gmail.com" | Email: c***@gmail.com |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "614829" | 614829 |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP042 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP043 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP044 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP045 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP046 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Camille Lef�vre (Adult) Is this who you'd like to include? |
| CP047 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP049 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 870 Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ) Date: June 4, 2026 Status: ARRIVED (Delayed) Is this the jour |
| CP050 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP051 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP052 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP053 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP054 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled arrival |  |
| CP055 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled arrival was June 4, 2026 13:00 YYZ; current date is June 24, 2026 ? >72 hours ? PROCEED |  |
| CP056 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction) = 5 years ? within limitation ? PROCEED |  |
| CP057 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = CDG (Paris, EU) ? EU 261 (Rest of Europe) |  |
| CP058 | REGIME DETERMINATION | system | implied | And the system checks: Destination = YYZ (Toronto, Canada) ? APPR also applies |  |
| CP059 | REGIME DETERMINATION | system | implied | And the system checks: Origin region = CDG = Rest of Europe ? Rest of Europe tier structure applies |  |
| CP060 | REGIME DETERMINATION | system | implied | And the system checks: Customer completed travel ? Travel Completed |  |
| CP061 | REGIME DETERMINATION | system | implied | And the system checks: Delay at arrival = 3 hrs 40 min (220 min) ? 3�<4 hr band (180�239 min) |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP063 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP064 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC082 | ? Promised Itinerary - Flight: AC 870, Route: CDG ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 13:00 (local YYZ) ? Current Itinerary - Flight: AC 870,  |
| CP065 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP066 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP067 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP068 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 870 from Paris Charles de Gaulle (CDG) to Toronto (YYZ) on June 4, 2026 was delayed by about 3 hou |
| CP069 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP070 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "France" | France |
| CP071 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = France ? Currency = EUR |  |
| CP072 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP073 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP074 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a �300 EUR compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a �300 EUR compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP075 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP076 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP077 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? BSM � Email Payment (France) |  |
| CP078 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | bot | chat | Then the chatbot responds: "Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email add | Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment re |
| CP079 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | system | implied | And user responds: "Yes, confirm this email." |  |
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
| CP091 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �300 EUR Payment Method: BSM � Email Payment After submission, you will receive a confirmation email summarizing your eligibility, claim details |
| CP092 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP093 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP094 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP095 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP096 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP097 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP098 | NOTIFICATION | email | email | And an eligible notification email is sent to c***@gmail.com |  |
| CP099 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�300 EUR), regulation (EU 261/2004), flight details (AC 870 CDG?YYZ DELAYED 3h4 |  |
| CP100 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP101 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP102 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Camille Lef�vre" with PNR "TC082" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Camille Lef�vre" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC082" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (Rest of Europe) + APPR" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Camille Lef�vre" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "c***@gmail.com" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+33***789" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: CDG ? YYZ" with claim filed for this flight as delayed |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "�300 EUR" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fallback Code flag should be TRUE with departure code 19 used as arrival code was unavailable |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dual Regime should show EU 261 Rest of Europe at �300 as selected and APPR at $400 CAD as not selected |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the most generous regime should be EU 261 Rest of Europe at �300 because at typical exchange rates �300 is approximately $440 CAD which  |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 with Travel Completed and Rest of Europe origin and controll |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Camille Lef�vre + TC082 + CDG?YYZ + FD" |  |
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
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing compensation "�300 EUR" and regulation "EU 261/2004" and trave |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP160 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "France" |  |
| CP161 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "EUR" |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM � Email Payment" |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And the customer details should be collected including email address and phone number |  |
| CP164 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP165 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "�300" for EU Rest of Europe Travel Completed with 3 to less than 4 hour delay and fallback departure  |  |
| CP166 | PAYMENT VALIDATION | payment | chat | And this is a Travel Completed case so compensation only with no refund as the customer used the ticket |  |
| CP167 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP168 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP169 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier via HSBC channel for BSM |  |
| CP170 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP171 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP172 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should record EUR amount and CAD equivalent and exchange rate and source and date |  |
| CP173 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details with amount in EUR and payment method "Cash" via "BSM � Email Payment"  |  |
| CP174 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-EL-17. | DDS returns FD-EU-EL-17. |
| CP175 | EXPECTED RESULTS | verdict | api | Trip Tracer: Flight = ARRIVED (DELAYED); Delay at arrival = 3h40m (220 min); MSL = Leg 1; Arrival Delay Code = UNAVAILABLE; Departure Delay  | Trip Tracer: Flight = ARRIVED (DELAYED); Delay at arrival = 3h40m (220 min); MSL = Leg 1; Arrival Delay Code = UNAVAILABLE; Departure Delay Code = 19; Fallback  |
| CP176 | EXPECTED RESULTS | verdict | chat | EU 261 (Rest of Europe) + APPR. | EU 261 (Rest of Europe) + APPR. |
| CP177 | EXPECTED RESULTS | verdict | chat | Origin Region = Rest of Europe. | Origin Region = Rest of Europe. |
| CP178 | EXPECTED RESULTS | verdict | api | Delay Band = DELAY_3_TO_LT_4_HOURS (180�239 min). | Delay Band = DELAY_3_TO_LT_4_HOURS (180�239 min). |
| CP179 | EXPECTED RESULTS | verdict | api | Compensation: �300 (EU Rest of Europe, Travel Completed, 3�<4 hr, Fallback Departure Code). | Compensation: �300 (EU Rest of Europe, Travel Completed, 3�<4 hr, Fallback Departure Code). |
| CP180 | EXPECTED RESULTS | verdict | api | Dual Regime: EU 261 = EL-17 (�300, Travel Completed, Rest of Europe, 3�<4 hr, Fallback Code) ? SELECTED; APPR = $400 CAD (not selected). | Dual Regime: EU 261 = EL-17 (�300, Travel Completed, Rest of Europe, 3�<4 hr, Fallback Code) ? SELECTED; APPR = $400 CAD (not selected). |
| CP181 | EXPECTED RESULTS | verdict | chat | Most Generous: EU 261 Rest of Europe (�300 ? ~$440 CAD > $400). | Most Generous: EU 261 Rest of Europe (�300 ? ~$440 CAD > $400). |
| CP182 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP183 | EXPECTED RESULTS | verdict | chat | IDV: PASS. | IDV: PASS. |
| CP184 | EXPECTED RESULTS | verdict | chat | Payment: BSM � Email Payment France EUR. | Payment: BSM � Email Payment France EUR. |
| CP185 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Travel Completed; EU Rest of Europe; 3�<4 hr delay; Fallback = TRUE; Departure Code 19; �300; DDS = FD-EU-EL-17. | Claims Dashboard: Travel Completed; EU Rest of Europe; 3�<4 hr delay; Fallback = TRUE; Departure Code 19; �300; DDS = FD-EU-EL-17. |
