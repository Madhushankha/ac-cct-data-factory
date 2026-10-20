# FD_TC_128 · CHAI-31520 — checkpoints

**Goal:** EU Rest of Europe flight (CDG?YYZ, AC-operated) rebooked to sister city YTZ. Customer arrived at YTZ with 4h50m delay vs original YYZ scheduled arrival. No arrival delay code available � Rules Engine used departure delay code 37 (Controllable) as fallback. Travel Completed + Rest of Europe + 4+ hr delay + Controllable (fallback) + Sister City = �600. APPR also applies at $400 CAD (3�<6 hr) � EU wins (�600 ? ~$880 CAD > $400). Difference from EL-19: exceeds 4-hour threshold.

Methods: seed 16, chat 65, api 13, email 3, dashboard 50, implied 27, manual 14, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | EU Rest of Europe flight (CDG?YYZ, AC-operated) rebooked to sister city YTZ. Customer arrived at YTZ with 4h50m delay vs original YYZ schedu |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Julien Marchand (Adult) | PNR: single passenger Julien Marchand (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 870, CDG?YYZ (original booking) | Journey: 1 leg AC operated, Flight AC 870, CDG?YYZ (original booking) |
| CP004 | PREREQUISITES | prerequisite | seed | Customer rebooked to sister city: actual arrival at YTZ (Billy Bishop Toronto City Airport) | Customer rebooked to sister city: actual arrival at YTZ (Billy Bishop Toronto City Airport) |
| CP005 | PREREQUISITES | prerequisite | seed | Scheduled departure: 10:00 (CDG local) | Scheduled departure: 10:00 (CDG local) |
| CP006 | PREREQUISITES | prerequisite | seed | Scheduled arrival at YYZ: 13:00 (YYZ local) | Scheduled arrival at YYZ: 13:00 (YYZ local) |
| CP007 | PREREQUISITES | prerequisite | seed | Actual arrival at YTZ: 17:50 (YTZ local) | Actual arrival at YTZ: 17:50 (YTZ local) |
| CP008 | PREREQUISITES | prerequisite | seed | Delay at arrival (calculated at sister city YTZ vs original YYZ scheduled arrival): 4 hours 50 minutes (290 minutes) | Delay at arrival (calculated at sister city YTZ vs original YYZ scheduled arrival): 4 hours 50 minutes (290 minutes) |
| CP009 | PREREQUISITES | prerequisite | seed | Arrival delay code: UNAVAILABLE | Arrival delay code: UNAVAILABLE |
| CP010 | PREREQUISITES | prerequisite | seed | Departure delay code: 37 (Controllable) � used as fallback | Departure delay code: 37 (Controllable) � used as fallback |
| CP011 | PREREQUISITES | prerequisite | seed | Fallback: TRUE | Fallback: TRUE |
| CP012 | PREREQUISITES | prerequisite | seed | Sister city: TRUE (YTZ = sister city of YYZ). bound_destination_type: SISTER_PROMISED | Sister city: TRUE (YTZ = sister city of YYZ). bound_destination_type: SISTER_PROMISED |
| CP013 | PREREQUISITES | prerequisite | seed | Travel status: Travel Completed | Travel status: Travel Completed |
| CP014 | PREREQUISITES | prerequisite | seed | Origin region: CDG = Rest of Europe | Origin region: CDG = Rest of Europe |
| CP015 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (Rest of Europe) + APPR (Canada arrival) | Regime: EU 261 (Rest of Europe) + APPR (Canada arrival) |
| CP016 | PREREQUISITES | prerequisite | seed | Residence: France ? EUR ? BSM � Email Payment | Residence: France ? EUR ? BSM � Email Payment |
| CP017 | PREREQUISITES | prerequisite | seed | Aeroplan: NOT linked ? Cash only | Aeroplan: NOT linked ? Cash only |
| CP018 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP019 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP020 | START | customer | chat | Then user selects English |  |
| CP021 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP022 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP023 | START | customer | chat | And the user says "My flight from Paris was supposed to arrive at Toronto Pearson but I was rerouted to Billy Bishop and arrived nearly 5 ho | My flight from Paris was supposed to arrive at Toronto Pearson but I was rerouted to Billy Bishop and arrived nearly 5 hours late. I'd like to claim compensatio |
| CP024 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP025 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP026 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP027 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Julien Marchand" | Julien Marchand |
| CP031 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Julien! And, what is your booking reference number? |
| CP032 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC086" | PNR: TC086 |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC086 |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP035 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: j***@gmail.com Phone: +33***567 |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: j***@gmail.com" | Email: j***@gmail.com |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP040 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "619482" | 619482 |
| CP041 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP042 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP043 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP044 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP045 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP046 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP047 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Julien Marchand (Adult) Is this who you'd like to include? |
| CP048 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP049 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP050 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 870 Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ) � Arrived at Billy Bishop (YTZ) Date: June 7, 2026 Status: AR |
| CP051 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP052 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP053 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP054 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP055 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled arrival |  |
| CP056 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled arrival was June 7, 2026 13:00 YYZ; current date is June 24, 2026 ? >72 hours ? PROCEED |  |
| CP057 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction) = 5 years ? within limitation ? PROCEED |  |
| CP058 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = CDG (Paris, EU) ? EU 261 (Rest of Europe) |  |
| CP059 | REGIME DETERMINATION | system | implied | And the system checks: Destination = YYZ/YTZ (Toronto, Canada) ? APPR also applies |  |
| CP060 | REGIME DETERMINATION | system | implied | And the system checks: Sister city match: YTZ = sister city of YYZ ? bound_destination_type = SISTER_PROMISED ? same destination |  |
| CP061 | REGIME DETERMINATION | system | implied | And the system checks: Origin region = CDG = Rest of Europe ? Rest of Europe tier structure applies |  |
| CP062 | REGIME DETERMINATION | system | implied | And the system checks: Customer completed travel ? Travel Completed (arrived at sister city = same destination) |  |
| CP063 | REGIME DETERMINATION | system | implied | And the system checks: Delay at arrival = 4 hrs 50 min (290 min) calculated at YTZ vs original YYZ scheduled arrival ? ?240 min ? 4+ hr band |  |
| CP064 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP065 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP066 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC086 | ? Promised Itinerary - Flight: AC 870, Route: CDG ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 13:00 (local YYZ) ? Current Itinerary - Flight: AC 870,  |
| CP067 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP068 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP069 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP070 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 870 from Paris Charles de Gaulle (CDG) to Toronto on June 7, 2026 was delayed by about 4 hours 50  |
| CP071 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP072 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "France" | France |
| CP073 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = France ? Currency = EUR |  |
| CP074 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP075 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP076 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a �600 EUR compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a �600 EUR compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP077 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP078 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP079 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? BSM � Email Payment (France) |  |
| CP080 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | bot | chat | Then the chatbot responds: "Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email add | Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment re |
| CP081 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | system | implied | And user responds: "Yes, confirm this email." |  |
| CP082 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
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
| CP093 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �600 EUR Payment Method: BSM � Email Payment After submission, you will receive a confirmation email summarizing your eligibility, claim details |
| CP094 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP095 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP096 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP097 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP098 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP099 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP100 | NOTIFICATION | email | email | And an eligible notification email is sent to j***@gmail.com |  |
| CP101 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�600 EUR), regulation (EU 261/2004), flight details (AC 870 CDG?YTZ DELAYED 4h5 |  |
| CP102 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP103 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP104 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Julien Marchand" with PNR "TC086" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Julien Marchand" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC086" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (Rest of Europe) + APPR" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Julien Marchand" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "j***@gmail.com" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+33***567" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: CDG ? YYZ" arrived at sister city YTZ with claim filed for this flight as delayed |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Sister City flag should be TRUE with YTZ as sister city of YYZ |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fallback Code flag should be TRUE with departure code 37 used as arrival code was unavailable |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the bound_destination_type should be "SISTER_PROMISED" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "�600 EUR" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dual Regime should show EU 261 Rest of Europe at �600 as selected and APPR at $400 CAD as not selected |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the most generous regime should be EU 261 Rest of Europe at �600 because at typical exchange rates �600 is approximately $880 CAD which  |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 with Travel Completed and Rest of Europe origin and controll |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Julien Marchand + TC086 + CDG?YTZ + FD" |  |
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
| CP169 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "�600" for EU Rest of Europe Travel Completed with 4 hours or more delay and sister city and fallback  |  |
| CP170 | PAYMENT VALIDATION | payment | chat | And this is a Travel Completed case so compensation only with no refund as the customer used the ticket |  |
| CP171 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP172 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP173 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier via HSBC channel for BSM |  |
| CP174 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP175 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP176 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should record EUR amount and CAD equivalent and exchange rate and source and date |  |
| CP177 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details with amount in EUR and payment method "Cash" via "BSM � Email Payment"  |  |
| CP178 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-EL-20. | DDS returns FD-EU-EL-20. |
| CP179 | EXPECTED RESULTS | verdict | api | Trip Tracer: Flight = ARRIVED (DELAYED � SISTER CITY); Delay at arrival = 4h50m (290 min) at sister city YTZ vs original YYZ; MSL = Leg 1; A | Trip Tracer: Flight = ARRIVED (DELAYED � SISTER CITY); Delay at arrival = 4h50m (290 min) at sister city YTZ vs original YYZ; MSL = Leg 1; Arrival Delay Code =  |
| CP180 | EXPECTED RESULTS | verdict | chat | EU 261 (Rest of Europe) + APPR. | EU 261 (Rest of Europe) + APPR. |
| CP181 | EXPECTED RESULTS | verdict | chat | Origin Region = Rest of Europe. | Origin Region = Rest of Europe. |
| CP182 | EXPECTED RESULTS | verdict | api | Delay Band = DELAY_GTE_4_HOURS (?240 min). | Delay Band = DELAY_GTE_4_HOURS (?240 min). |
| CP183 | EXPECTED RESULTS | verdict | api | Compensation: �600 (EU Rest of Europe, Travel Completed, 4+ hr, Sister City + Fallback Departure Code). | Compensation: �600 (EU Rest of Europe, Travel Completed, 4+ hr, Sister City + Fallback Departure Code). |
| CP184 | EXPECTED RESULTS | verdict | api | Dual Regime: EU 261 = EL-20 (�600) ? SELECTED; APPR = $400 CAD (not selected). | Dual Regime: EU 261 = EL-20 (�600) ? SELECTED; APPR = $400 CAD (not selected). |
| CP185 | EXPECTED RESULTS | verdict | chat | Most Generous: EU 261 Rest of Europe (�600 ? ~$880 CAD > $400). | Most Generous: EU 261 Rest of Europe (�600 ? ~$880 CAD > $400). |
| CP186 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP187 | EXPECTED RESULTS | verdict | chat | IDV: PASS. | IDV: PASS. |
| CP188 | EXPECTED RESULTS | verdict | chat | Payment: BSM � Email Payment France EUR. | Payment: BSM � Email Payment France EUR. |
| CP189 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Travel Completed; EU Rest of Europe; 4+ hr delay; Sister City = TRUE (YTZ); Fallback = TRUE; Departure Code 37; �600; DDS  | Claims Dashboard: Travel Completed; EU Rest of Europe; 4+ hr delay; Sister City = TRUE (YTZ); Fallback = TRUE; Departure Code 37; �600; DDS = FD-EU-EL-20. |
