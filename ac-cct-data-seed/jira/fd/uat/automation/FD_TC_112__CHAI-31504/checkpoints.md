# FD_TC_112 · CHAI-31504 — checkpoints

**Goal:** EU Rest of Europe flight from Paris CDG to Toronto YYZ, diverted to Billy Bishop YTZ (sister city of YYZ). CDG = Rest of Europe origin, 4hr delay (?240 min) ? �600 EUR. DDS uses origin-region tiers, not distance bands. Validates: (1) Rest of Europe origin-region compensation, (2) 4+ hr delay = �600, (3) Sister city pairing YYZ?YTZ, (4) Dual regime EU 261 + APPR with EU selected as most generous.

Methods: seed 9, chat 57, api 24, email 3, dashboard 45, implied 23, manual 13, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | EU Rest of Europe flight from Paris CDG to Toronto YYZ, diverted to Billy Bishop YTZ (sister city of YYZ). CDG = Rest of Europe origin, 4hr  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Marie Dupuis (Adult) | PNR: single passenger Marie Dupuis (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 870, CDG?YYZ, diverted to YTZ (sister city of YYZ) | Journey: 1 leg AC operated, Flight AC 870, CDG?YYZ, diverted to YTZ (sister city of YYZ) |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival at YYZ: 14:00 | Scheduled arrival at YYZ: 14:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival at YTZ: 18:00 (4hr delay) | Actual arrival at YTZ: 18:00 (4hr delay) |
| CP006 | PREREQUISITES | prerequisite | seed | Disruption code: 42 (Scheduled Maintenance � Controllable) | Disruption code: 42 (Scheduled Maintenance � Controllable) |
| CP007 | PREREQUISITES | prerequisite | seed | Origin region: CDG = Rest of Europe | Origin region: CDG = Rest of Europe |
| CP008 | PREREQUISITES | prerequisite | seed | Sister city mapping: YYZ?YTZ = VALID PAIR | Sister city mapping: YYZ?YTZ = VALID PAIR |
| CP009 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (Rest of Europe � CDG is EU origin) + APPR (Canada arrival) | Regime: EU 261 (Rest of Europe � CDG is EU origin) + APPR (Canada arrival) |
| CP010 | PREREQUISITES | prerequisite | seed | Residence: France ? EUR ? BSM � Email Payment | Residence: France ? EUR ? BSM � Email Payment |
| CP011 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP012 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP013 | START | customer | chat | Then user selects English |  |
| CP014 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP015 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP016 | START | customer | chat | And the user says "My flight from Paris was supposed to land at Toronto Pearson but was diverted to Billy Bishop and arrived 4 hours late" | My flight from Paris was supposed to land at Toronto Pearson but was diverted to Billy Bishop and arrived 4 hours late |
| CP017 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP018 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP019 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP020 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Marie Dupuis" | Marie Dupuis |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Marie! And, what is your booking reference number? |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC069" | PNR: TC069 |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC069 |  |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: m***@gmail.com � Phone: +33***567 |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: m***@gmail.com" | Email: m***@gmail.com |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP034 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP036 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP037 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP039 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Marie Dupuis (Adult) Is this who you'd like to include? |
| CP041 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP043 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 870 � Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ) [Landed at Billy Bishop (YTZ)] � Date: May 8, 2026 � Arri |
| CP044 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP049 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 8, 2026; current date is June 10, 2026 ? >72 hours ? PROCEED |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (France departure) = 5 years from disruption |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 8, 2026; filing June 10, 2026 ? 33 days ? within 5 years ? PROCEED |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 870, Route: CDG ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 14:00 | Promised Itinerary - Flight: AC 870, Route: CDG ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 14:00 |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 870, Route: CDG ? YTZ (sister city), Status: ARRIVED, Actual Departure: 14:00, Actual Arrival: 18:00 | Current Itinerary - Flight: AC 870, Route: CDG ? YTZ (sister city), Status: ARRIVED, Actual Departure: 14:00, Actual Arrival: 18:00 |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Sister City Check: YTZ ? YYZ = VALID PAIR (confirmed in DDS sister city config) | Sister City Check: YTZ ? YYZ = VALID PAIR (confirmed in DDS sister city config) |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Sister city accepted as equivalent destination | Sister city accepted as equivalent destination |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Arrival Delay: 4 hours (? 3-hour threshold MET) | Arrival Delay: 4 hours (? 3-hour threshold MET) |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Customer Status: TRAVELLED (completed journey) | Customer Status: TRAVELLED (completed journey) |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | History - No changes recorded | History - No changes recorded |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Regime: EU 261 (Rest of Europe � CDG origin) + APPR (Canada arrival) | Regime: EU 261 (Rest of Europe � CDG origin) + APPR (Canada arrival) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 6712 � CDG ? LGW � 42 | MSL FLIGHT: AC 6712 � CDG ? LGW � 42 |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | "Delay � scheduled maintenance" | "Delay � scheduled maintenance" |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE ( Code 42) | CONTROLLABLE ( Code 42) |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Origin Region: CDG = Rest of Europe | Origin Region: CDG = Rest of Europe |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | EU 261 Compensation: Rest of Europe + delay ? 4 hrs + sister city = �600 | EU 261 Compensation: Rest of Europe + delay ? 4 hrs + sister city = �600 |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE | Fallback: FALSE |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | MS MARIE DUPUIS / ELIGIBLE / EU261_REST_OF_EUROPE_DELAY_GTE_4_HOURS_SISTER_CITY / EUR �600.00 | MS MARIE DUPUIS / ELIGIBLE / EU261_REST_OF_EUROPE_DELAY_GTE_4_HOURS_SISTER_CITY / EUR �600.00 |
| CP069 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP070 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP071 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP072 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 870 from Paris Charles de Gaulle (CDG) to Toronto (YYZ) was delayed by about 4 hours. Based on the |
| CP073 | COUNTRY OF RESIDENCE (FD-06) | bot | chat | Then the chatbot asks: | Which country would you like to receive your reimbursement in? This determines the currency and payment method. |
| CP074 | COUNTRY OF RESIDENCE (FD-06) | customer | chat | And the user selects "France" | France |
| CP075 | COUNTRY OF RESIDENCE (FD-06) | system | implied | Then the system determines: Country = France ? Currency = EUR ? Payment Method = BSM � Email Payment |  |
| CP076 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? NO |  |
| CP077 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot determines: AC Wallet NOT available |  |
| CP078 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot offers CASH ONLY: | You are entitled to receive a �600 EUR compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP079 | PAYMENT METHOD (FD-07) | bot | chat | Then the chatbot responds: "Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email add | Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment re |
| CP080 | PAYMENT METHOD (FD-07) | system | implied | And user responds: "Yes, confirm this email." |  |
| CP081 | PAYMENT METHOD (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Before we process your payment, we need to verify your identity. You will receive a separate link to complete identity verification through our secure partner. |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP085 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP086 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP087 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: |  |
| CP088 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �600 EUR Payment Method: Email After submission, you will receive a confirmation email summarizing your eligibility, claim details and next step |
| CP089 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP090 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP091 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP092 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP093 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP094 | CASE CREATION (GLOB-09) | system | implied | Then the chatbot creates the case and responds: | "Your claim has been submitted. Case Reference: CASE-FD-20260610-083." "You will also receive an email with your case number and a link to track your case statu |
| CP095 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP096 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP097 | NOTIFICATION | email | email | And an eligible notification email is sent to m***@gmail.com |  |
| CP098 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�600), regulation (EU 261/2004), flight details (including sister city note: YT |  |
| CP099 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP100 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP101 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Marie Dupuis" with PNR "TC069" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Marie Dupuis" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC069" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (Rest of Europe)" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Marie Dupuis" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "m***@gmail.com" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+33***567" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: CDG ? YYZ" with landing at YTZ as sister city and claim filed for this flight |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "�600 EUR" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 with delay 4h and Rest of Europe origin and controllable Cod |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Marie Dupuis + TC069 + CDG?YYZ" |  |
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
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing compensation "�600 EUR" and regulation "EU 261/2004" and siste |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP156 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is an EU country |  |
| CP157 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "EUR" |  |
| CP158 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM � Email Payment" |  |
| CP159 | PAYMENT VALIDATION | payment | chat | And the customer details should be collected including email address |  |
| CP160 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP161 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "�600" for EU Rest of Europe with delay of 4 hours or more |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP163 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP164 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP165 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP166 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP167 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should record EUR amount and CAD equivalent and exchange rate and source and date for PRISM/Exposure reporti |  |
| CP168 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show payout details "�600 EUR" with payment method "Cash" via "BSM � Email Payment" |  |
| CP169 | EXPECTED RESULTS | verdict | api | Code 42; Controllable; Sister City = TRUE (YYZ?YTZ); Origin Region = Rest of Europe. | Code 42; Controllable; Sister City = TRUE (YYZ?YTZ); Origin Region = Rest of Europe. |
| CP170 | EXPECTED RESULTS | verdict | chat | Compensation: �600 (EU 261 Rest of Europe, delay ?4hrs). | Compensation: �600 (EU 261 Rest of Europe, delay ?4hrs). |
| CP171 | EXPECTED RESULTS | verdict | api | Regime Assessment: APPR = EL-01 ($400 CAD); EU 261 = EL-04 (�600, Sister City) ? SELECTED (most generous). | Regime Assessment: APPR = EL-01 ($400 CAD); EU 261 = EL-04 (�600, Sister City) ? SELECTED (most generous). |
| CP172 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP173 | EXPECTED RESULTS | verdict | chat | IDV: PASS. | IDV: PASS. |
| CP174 | EXPECTED RESULTS | verdict | chat | Payment: BSM � Email Payment France EUR. | Payment: BSM � Email Payment France EUR. |
| CP175 | EXPECTED RESULTS | verdict | api | Claims Dashboard: EU 261 EL-04; �600; Rest of Europe; Sister City = TRUE; DDS = FD-EU-EL-04. | Claims Dashboard: EU 261 EL-04; �600; Rest of Europe; Sister City = TRUE; DDS = FD-EU-EL-04. |
