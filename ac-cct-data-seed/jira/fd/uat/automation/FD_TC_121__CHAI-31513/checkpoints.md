# FD_TC_121 · CHAI-31513 — checkpoints

**Goal:** EU Rest of Europe flight (CDG?YYZ, AC-operated) delayed at arrival by 3 hours 30 minutes due to controllable reason (delay code 42 � Scheduled Maintenance). Customer completed travel. Travel Completed + Rest of Europe + 3�<4 hr delay = �300. APPR also applies (Canada destination) at $400 CAD � compare and select most generous

Methods: seed 14, chat 65, api 12, email 3, dashboard 47, implied 26, manual 14, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | EU Rest of Europe flight (CDG?YYZ, AC-operated) delayed at arrival by 3 hours 30 minutes due to controllable reason (delay code 42 � Schedul |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Antoine Dupont (Adult) | PNR: single passenger Antoine Dupont (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 870, CDG?YYZ | Journey: 1 leg AC operated, Flight AC 870, CDG?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled departure: 10:00 (CDG local) | Scheduled departure: 10:00 (CDG local) |
| CP005 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 13:00 (YYZ local) | Scheduled arrival: 13:00 (YYZ local) |
| CP006 | PREREQUISITES | prerequisite | seed | Actual arrival: 16:30 (YYZ local) | Actual arrival: 16:30 (YYZ local) |
| CP007 | PREREQUISITES | prerequisite | seed | Delay at arrival: 3 hours 30 minutes | Delay at arrival: 3 hours 30 minutes |
| CP008 | PREREQUISITES | prerequisite | seed | Arrival Delay code (arrival): 42 (Scheduled Maintenance � Controllable) | Arrival Delay code (arrival): 42 (Scheduled Maintenance � Controllable) |
| CP009 | PREREQUISITES | prerequisite | seed | Fallback: FALSE (arrival code available) | Fallback: FALSE (arrival code available) |
| CP010 | PREREQUISITES | prerequisite | seed | Customer action: Completed travel � arrived at YYZ | Customer action: Completed travel � arrived at YYZ |
| CP011 | PREREQUISITES | prerequisite | seed | Travel status: Travel Completed | Travel status: Travel Completed |
| CP012 | PREREQUISITES | prerequisite | seed | Origin region: CDG = Rest of Europe | Origin region: CDG = Rest of Europe |
| CP013 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (Rest of Europe) + APPR (Canada arrival) | Regime: EU 261 (Rest of Europe) + APPR (Canada arrival) |
| CP014 | PREREQUISITES | prerequisite | seed | Residence: France ? EUR ? BSM � Email Payment | Residence: France ? EUR ? BSM � Email Payment |
| CP015 | PREREQUISITES | prerequisite | seed | Aeroplan: NOT linked ? Cash only | Aeroplan: NOT linked ? Cash only |
| CP016 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP017 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP018 | START | customer | chat | Then user selects English |  |
| CP019 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP020 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP021 | START | customer | chat | And the user says "My flight from Paris to Toronto arrived over 3 hours late. Can I get compensation?" | My flight from Paris to Toronto arrived over 3 hours late. Can I get compensation? |
| CP022 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP023 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP024 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP025 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Antoine Dupont" | Antoine Dupont |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Antoine! And, what is your booking reference number? |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC078" | PNR: TC078 |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC078 |  |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: a***@gmail.com Phone: +33***123 |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: a***@gmail.com" | Email: a***@gmail.com |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP039 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP041 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP042 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP043 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP044 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP045 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Antoine Dupont (Adult) Is this who you'd like to include? |
| CP046 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP047 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP048 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 870 Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ) Date: May 29, 2026 Status: ARRIVED (Delayed) Is this the jour |
| CP049 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP050 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP052 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP053 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled arrival |  |
| CP054 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled arrival was May 29, 2026 13:00 YYZ; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP055 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction) = 5 years ? within limitation ? PROCEED |  |
| CP056 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = CDG (Paris, EU) ? EU 261 (Rest of Europe) |  |
| CP057 | REGIME DETERMINATION | system | implied | And the system checks: Destination = YYZ (Toronto, Canada) ? APPR also applies |  |
| CP058 | REGIME DETERMINATION | system | implied | And the system checks: Origin region = CDG = Rest of Europe ? Rest of Europe tier structure applies |  |
| CP059 | REGIME DETERMINATION | system | implied | And the system checks: Customer completed travel ? Travel Completed |  |
| CP060 | REGIME DETERMINATION | system | implied | And the system checks: Delay at arrival = 3 hrs 30 min ? 3�<4 hr band |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP063 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC078 | Delay � scheduled maintenance |
| CP064 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP065 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP066 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP067 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 870 from Paris Charles de Gaulle (CDG) to Toronto (YYZ) on May 29, 2026 was delayed by about 3 hou |
| CP068 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP069 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "France" | France |
| CP070 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = France ? Currency = EUR |  |
| CP071 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP072 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP073 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a �300 EUR compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a �300 EUR compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP074 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP075 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP076 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? BSM � Email Payment (France) |  |
| CP077 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | bot | chat | Then the chatbot responds: "Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email add | Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment re |
| CP078 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | system | implied | And user responds: "Yes, confirm this email." |  |
| CP079 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP085 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP086 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP087 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP088 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP089 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP090 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �300 EUR Payment Method: BSM � Email Payment After submission, you will receive a confirmation email summarizing your eligibility, claim details |
| CP091 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP092 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP093 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP094 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP095 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP096 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP097 | NOTIFICATION | email | email | And an eligible notification email is sent to a***@gmail.com |  |
| CP098 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�300 EUR), regulation (EU 261/2004), flight details (AC 870 CDG?YYZ DELAYED 3h3 |  |
| CP099 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP100 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP101 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Antoine Dupont" with PNR "TC078" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Antoine Dupont" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC078" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (Rest of Europe) + APPR" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Antoine Dupont" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "a***@gmail.com" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+33***123" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: CDG ? YYZ" with claim filed for this flight as delayed |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "�300 EUR" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dual Regime should show EU 261 Rest of Europe at �300 as selected and APPR at $400 CAD as not selected |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the most generous regime should be EU 261 Rest of Europe at �300 because at typical exchange rates �300 is approximately $440 CAD which  |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 with Travel Completed and Rest of Europe origin and controll |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Antoine Dupont + TC078 + CDG?YYZ + FD" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing compensation "�300 EUR" and regulation "EU 261/2004" and trave |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP158 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "France" |  |
| CP159 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "EUR" |  |
| CP160 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM � Email Payment" |  |
| CP161 | PAYMENT VALIDATION | payment | chat | And the customer details should be collected including email address confirmed |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "�300" for EU Rest of Europe Travel Completed with 3 to less than 4 hour delay |  |
| CP164 | PAYMENT VALIDATION | payment | chat | And this is a Travel Completed case so compensation only with no refund as the customer used the ticket |  |
| CP165 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP166 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP167 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP168 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP169 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP170 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should record EUR amount and CAD equivalent and exchange rate and source and date |  |
| CP171 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details with amount in EUR and payment method "Cash" via "BSM � Email Payment"  |  |
| CP172 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-EL-13. | DDS returns FD-EU-EL-13. |
| CP173 | EXPECTED RESULTS | verdict | api | Trip Tracer: Flight = ARRIVED (DELAYED); Delay at arrival = 3h30m; MSL = Leg 1; Delay Code (arrival) = 42 (Scheduled Maintenance); Controlla | Trip Tracer: Flight = ARRIVED (DELAYED); Delay at arrival = 3h30m; MSL = Leg 1; Delay Code (arrival) = 42 (Scheduled Maintenance); Controllable; Travel Complete |
| CP174 | EXPECTED RESULTS | verdict | chat | Origin Region = Rest of Europe. | Origin Region = Rest of Europe. |
| CP175 | EXPECTED RESULTS | verdict | api | Delay Band = 3�<4 hrs. | Delay Band = 3�<4 hrs. |
| CP176 | EXPECTED RESULTS | verdict | chat | Compensation: �300 (EU Rest of Europe, Travel Completed, 3�<4 hr). | Compensation: �300 (EU Rest of Europe, Travel Completed, 3�<4 hr). |
| CP177 | EXPECTED RESULTS | verdict | api | Dual Regime: EU 261 = EL-13 (�300, Travel Completed, Rest of Europe, 3�<4 hr) ? SELECTED; APPR = $400 CAD (not selected). | Dual Regime: EU 261 = EL-13 (�300, Travel Completed, Rest of Europe, 3�<4 hr) ? SELECTED; APPR = $400 CAD (not selected). |
| CP178 | EXPECTED RESULTS | verdict | chat | Most Generous: EU 261 Rest of Europe (�300 ? ~$440 CAD > $400). | Most Generous: EU 261 Rest of Europe (�300 ? ~$440 CAD > $400). |
| CP179 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP180 | EXPECTED RESULTS | verdict | chat | IDV: PASS. | IDV: PASS. |
| CP181 | EXPECTED RESULTS | verdict | chat | Payment: BSM � Email Payment France EUR. | Payment: BSM � Email Payment France EUR. |
| CP182 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Travel Completed; EU Rest of Europe; 3�<4 hr delay; Code 42; �300; DDS = FD-EU-EL-13. | Claims Dashboard: Travel Completed; EU Rest of Europe; 3�<4 hr delay; Code 42; �300; DDS = FD-EU-EL-13. |
