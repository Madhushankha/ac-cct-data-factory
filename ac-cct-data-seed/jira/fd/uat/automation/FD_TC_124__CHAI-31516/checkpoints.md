# FD_TC_124 · CHAI-31516 — checkpoints

**Goal:** EU Rest of Europe flight (CDG?YTZ, AC-operated) where the customer was rebooked to sister-city airport YTZ (Toronto Island) instead of original destination YYZ (Toronto Pearson). Flight arrived with a delay of 4 hours 50 minutes at the sister-city destination. Travel Completed + Rest of Europe + 4+ hr delay + sister city = �600. APPR also applies (Canada destination) at $400 CAD (3�<6 hr band) � EU wins (�600 ? ~$880 CAD > $400).

Methods: seed 16, chat 66, api 12, email 3, dashboard 48, implied 29, manual 14, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | EU Rest of Europe flight (CDG?YTZ, AC-operated) where the customer was rebooked to sister-city airport YTZ (Toronto Island) instead of origi |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Jean-Luc Moreau (Adult) | PNR: single passenger Jean-Luc Moreau (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 870, CDG?YYZ (original destination) | Journey: 1 leg AC operated, Flight AC 870, CDG?YYZ (original destination) |
| CP004 | PREREQUISITES | prerequisite | seed | Customer accepted rebooking to sister-city airport YTZ (Toronto Island) | Customer accepted rebooking to sister-city airport YTZ (Toronto Island) |
| CP005 | PREREQUISITES | prerequisite | seed | Scheduled departure: 10:00 (CDG local) | Scheduled departure: 10:00 (CDG local) |
| CP006 | PREREQUISITES | prerequisite | seed | Scheduled arrival at YYZ: 13:00 (YYZ local) | Scheduled arrival at YYZ: 13:00 (YYZ local) |
| CP007 | PREREQUISITES | prerequisite | seed | Actual arrival at YTZ: 17:50 (YTZ local) | Actual arrival at YTZ: 17:50 (YTZ local) |
| CP008 | PREREQUISITES | prerequisite | seed | Delay at arrival (measured against original YYZ scheduled arrival): 4 hours 50 minutes (290 minutes) | Delay at arrival (measured against original YYZ scheduled arrival): 4 hours 50 minutes (290 minutes) |
| CP009 | PREREQUISITES | prerequisite | seed | Delay code (arrival): 42 (Scheduled Maintenance � Controllable) | Delay code (arrival): 42 (Scheduled Maintenance � Controllable) |
| CP010 | PREREQUISITES | prerequisite | seed | Fallback: FALSE (arrival code available) | Fallback: FALSE (arrival code available) |
| CP011 | PREREQUISITES | prerequisite | seed | Customer action: Completed travel � arrived at sister-city YTZ | Customer action: Completed travel � arrived at sister-city YTZ |
| CP012 | PREREQUISITES | prerequisite | seed | Travel status: Travel Completed | Travel status: Travel Completed |
| CP013 | PREREQUISITES | prerequisite | seed | Sister city: YTZ is sister city of YYZ (Toronto metropolitan area) | Sister city: YTZ is sister city of YYZ (Toronto metropolitan area) |
| CP014 | PREREQUISITES | prerequisite | seed | Origin region: CDG = Rest of Europe | Origin region: CDG = Rest of Europe |
| CP015 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (Rest of Europe) + APPR (Canada arrival) | Regime: EU 261 (Rest of Europe) + APPR (Canada arrival) |
| CP016 | PREREQUISITES | prerequisite | seed | Residence: France ? EUR ? BSM � Email Payment | Residence: France ? EUR ? BSM � Email Payment |
| CP017 | PREREQUISITES | prerequisite | seed | Aeroplan: NOT linked ? Cash only | Aeroplan: NOT linked ? Cash only |
| CP018 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP019 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP020 | START | customer | chat | Then user selects English |  |
| CP021 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP022 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP023 | START | customer | chat | And the user says "My flight from Paris was supposed to land at Toronto Pearson but I ended up at Toronto Island airport almost 5 hours late | My flight from Paris was supposed to land at Toronto Pearson but I ended up at Toronto Island airport almost 5 hours late. Can I get compensation? |
| CP024 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP025 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP026 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP027 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Jean-Luc Moreau" | Jean-Luc Moreau |
| CP031 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Jean-Luc! And, what is your booking reference number? |
| CP032 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC081" | PNR: TC081 |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC081 |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP035 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: j***@gmail.com Phone: +33***567 |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: j***@gmail.com" | Email: j***@gmail.com |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP040 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "842572" | 842572 |
| CP041 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP042 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP043 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP044 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP045 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP046 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP047 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Jean-Luc Moreau (Adult) Is this who you'd like to include? |
| CP048 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP049 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP050 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 870 Route: Paris Charles de Gaulle (CDG) ? Toronto Island (YTZ) [rebooked from Toronto Pearson (YYZ)] Date: June 2, 20 |
| CP051 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP052 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP053 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP054 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP055 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled arrival |  |
| CP056 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled arrival was June 2, 2026 13:00 YYZ; current date is June 24, 2026 ? >72 hours ? PROCEED |  |
| CP057 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction) = 5 years ? within limitation ? PROCEED |  |
| CP058 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = CDG (Paris, EU) ? EU 261 (Rest of Europe) |  |
| CP059 | REGIME DETERMINATION | system | implied | And the system checks: Destination = YTZ (Toronto Island, Canada) ? sister city of YYZ ? APPR also applies |  |
| CP060 | REGIME DETERMINATION | system | implied | And the system checks: Origin region = CDG = Rest of Europe ? Rest of Europe tier structure applies |  |
| CP061 | REGIME DETERMINATION | system | implied | And the system checks: Customer completed travel (arrived at sister-city YTZ) ? Travel Completed |  |
| CP062 | REGIME DETERMINATION | system | implied | And the system checks: Delay at arrival = 4 hrs 50 min (290 min) ? ?240 min ? 4+ hr band |  |
| CP063 | SISTER CITY VALIDATION | system | implied | Then the system checks: Is YTZ a sister city of original destination YYZ? |  |
| CP064 | SISTER CITY VALIDATION | system | implied | And the system queries EDS Reference Data Service ? YYZ and YTZ are sister cities (Toronto metropolitan area) |  |
| CP065 | SISTER CITY VALIDATION | system | implied | And the system confirms: Sister city = TRUE ? delay measured against original YYZ scheduled arrival |  |
| CP066 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP067 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP068 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC081 | Delay � scheduled maintenance |
| CP069 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP070 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP071 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP072 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 870 from Paris Charles de Gaulle (CDG) to Toronto (YTZ � sister city of YYZ) on June 2, 2026 was d |
| CP073 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP074 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "France" | France |
| CP075 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = France ? Currency = EUR |  |
| CP076 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP077 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP078 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a �600 EUR compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a �600 EUR compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
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
| CP095 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �600 EUR Payment Method: BSM � Email Payment After submission, you will receive a confirmation email summarizing your eligibility, claim details |
| CP096 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP097 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP098 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP099 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP100 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP101 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP102 | NOTIFICATION | email | email | And an eligible notification email is sent to j***@gmail.com |  |
| CP103 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�600 EUR), regulation (EU 261/2004), flight details (AC 870 CDG?YTZ DELAYED 4h5 |  |
| CP104 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP105 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP106 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Jean-Luc Moreau" with PNR "TC081" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Jean-Luc Moreau" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC081" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (Rest of Europe) + APPR" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Jean-Luc Moreau" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "j***@gmail.com" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+33***567" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: CDG ? YTZ" as sister city of YYZ with claim filed for this flight as delayed |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Sister City flag should be TRUE with YTZ as sister of YYZ |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "�600 EUR" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dual Regime should show EU 261 Rest of Europe at �600 as selected and APPR at $400 CAD as not selected |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the most generous regime should be EU 261 Rest of Europe at �600 because at typical exchange rates �600 is approximately $880 CAD which  |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 with Travel Completed and Rest of Europe origin and controll |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Jean-Luc Moreau + TC081 + CDG?YTZ + FD" |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing compensation "�600 EUR" and regulation "EU 261/2004" and trave |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP164 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "France" |  |
| CP165 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "EUR" |  |
| CP166 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM � Email Payment" |  |
| CP167 | PAYMENT VALIDATION | payment | chat | And the customer details should be collected including email address and phone number |  |
| CP168 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP169 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "�600" for EU Rest of Europe Travel Completed with 4 hours or more delay and sister city |  |
| CP170 | PAYMENT VALIDATION | payment | chat | And this is a Travel Completed case so compensation only with no refund as the customer used the ticket |  |
| CP171 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP172 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP173 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier via HSBC channel for BSM |  |
| CP174 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP175 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP176 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should record EUR amount and CAD equivalent and exchange rate and source and date |  |
| CP177 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details with amount in EUR and payment method "Cash" via "BSM � Email Payment"  |  |
| CP178 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-EL-16. | DDS returns FD-EU-EL-16. |
| CP179 | EXPECTED RESULTS | verdict | api | Trip Tracer: Flight = ARRIVED (DELAYED); Delay at arrival = 4h50m (290 min); MSL = Leg 1; Delay Code (arrival) = 42 (Scheduled Maintenance � | Trip Tracer: Flight = ARRIVED (DELAYED); Delay at arrival = 4h50m (290 min); MSL = Leg 1; Delay Code (arrival) = 42 (Scheduled Maintenance � CONTROLLABLE per Ga |
| CP180 | EXPECTED RESULTS | verdict | chat | EU 261 (Rest of Europe) + APPR. | EU 261 (Rest of Europe) + APPR. |
| CP181 | EXPECTED RESULTS | verdict | chat | Origin Region = Rest of Europe. | Origin Region = Rest of Europe. |
| CP182 | EXPECTED RESULTS | verdict | api | Delay Band = DELAY_GTE_4_HOURS (?240 min). | Delay Band = DELAY_GTE_4_HOURS (?240 min). |
| CP183 | EXPECTED RESULTS | verdict | chat | Compensation: �600 (EU Rest of Europe, Travel Completed, 4+ hr, Sister City). | Compensation: �600 (EU Rest of Europe, Travel Completed, 4+ hr, Sister City). |
| CP184 | EXPECTED RESULTS | verdict | api | Dual Regime: EU 261 = EL-16 (�600, Travel Completed, Rest of Europe, 4+ hr, Sister City) ? SELECTED; APPR = $400 CAD (3�<6 hr, not selected) | Dual Regime: EU 261 = EL-16 (�600, Travel Completed, Rest of Europe, 4+ hr, Sister City) ? SELECTED; APPR = $400 CAD (3�<6 hr, not selected). |
| CP185 | EXPECTED RESULTS | verdict | chat | Most Generous: EU 261 Rest of Europe (�600 ? ~$880 CAD > $400). | Most Generous: EU 261 Rest of Europe (�600 ? ~$880 CAD > $400). |
| CP186 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP187 | EXPECTED RESULTS | verdict | chat | IDV: PASS. | IDV: PASS. |
| CP188 | EXPECTED RESULTS | verdict | chat | Payment: BSM � Email Payment France EUR. | Payment: BSM � Email Payment France EUR. |
| CP189 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Travel Completed; EU Rest of Europe; 4+ hr delay; Sister City = TRUE; Code 42; �600; DDS = FD-EU-EL-16. | Claims Dashboard: Travel Completed; EU Rest of Europe; 4+ hr delay; Sister City = TRUE; Code 42; �600; DDS = FD-EU-EL-16. |
