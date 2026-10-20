# FD_TC_110 · CHAI-31502 — checkpoints

**Goal:** UK-origin route (LHR?YYZ); delay tier � 5 hours. UK Tier 2 = 4+ hrs (higher compensation than UK Tier 1). Also validates that at 5hr delay, EU-UK Tier 2 is still more generous than APPR Tier 1 ($400, 3�<6hrs), confirming EU-UK remains the selected regime at this delay band.

Methods: seed 10, chat 62, api 21, email 3, dashboard 45, implied 23, manual 14, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | UK-origin route (LHR?YYZ); delay tier � 5 hours. UK Tier 2 = 4+ hrs (higher compensation than UK Tier 1). Also validates that at 5hr delay,  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR:  single passenger(Adult) | PNR:  single passenger(Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 858, LHR?YYZ | Journey: 1 leg AC operated, Flight AC 858, LHR?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 16:00 | Scheduled arrival: 16:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival: 21:00 (5hr delay, 300 min) | Actual arrival: 21:00 (5hr delay, 300 min) |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival Delay code: 42 (Scheduled Maintenance � Controllable) | Arrival Delay code: 42 (Scheduled Maintenance � Controllable) |
| CP007 | PREREQUISITES | prerequisite | seed | Arrival code: 42 (available) | Arrival code: 42 (available) |
| CP008 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (UK) + APPR | Regime: EU 261 (UK) + APPR |
| CP009 | PREREQUISITES | prerequisite | seed | Booking changes: None | Booking changes: None |
| CP010 | PREREQUISITES | prerequisite | seed | Aeroplan: NOT linked ? Cash only | Aeroplan: NOT linked ? Cash only |
| CP011 | PREREQUISITES | prerequisite | seed | Residence: UK ? Email | Residence: UK ? Email |
| CP012 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP013 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP014 | START | customer | chat | Then user selects English |  |
| CP015 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP016 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP017 | START | customer | chat | And the user says "My flight from London Heathrow to Toronto was delayed about 5 hours, I'd like to check if I'm eligible for compensation" | My flight from London Heathrow to Toronto was delayed about 5 hours, I'd like to check if I'm eligible for compensation |
| CP018 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP019 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP020 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP021 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Sarah Thompson" | Sarah Thompson |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Sarah! And, what is your booking reference number? |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC121" | PNR: TC121 |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC121 |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: s***@gmail.com � Phone: +44***234 |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: s***@gmail.com" | Email: s***@gmail.com |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP035 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP037 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Sarah Thompson (Adult) Is this who you'd like to include? |
| CP042 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP044 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 858 � Route: London Heathrow (LHR) ? Toronto (YYZ) � Date: May 21, 2026 � Arrival Delay: 5 hours Is this the journey |
| CP045 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP050 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 21, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (UK) = 6 years |  |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 21, 2026; filing June 15, 2026 ? 25 days ? within limitation ? PROCEED |  |
| CP053 | REGIME DETERMINATION | system | implied | And the system checks: Origin region = UK ? UK tier structure applies |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 858, Route: LHR ? YYZ, Scheduled Arrival: 16:00 | Promised Itinerary - Flight: AC 858, Route: LHR ? YYZ, Scheduled Arrival: 16:00 |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 858, Route: LHR ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 16:00 ? Actual: 21:00, Delay: +5H 00M | Current Itinerary - Flight: AC 858, Route: LHR ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 16:00 ? Actual: 21:00, Delay: +5H 00M |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Regime: EU 261 (UK) | Regime: EU 261 (UK) |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Origin Region: LHR = UK | Origin Region: LHR = UK |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 858� LHR ? YYZ � 42 | MSL FLIGHT: AC 858� LHR ? YYZ � 42 |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to Scheduled maintenance" | "Delayed due to Scheduled maintenance" |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +5H 00M � CONTROLLABLE | Delay: +5H 00M � CONTROLLABLE |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | EU 261 UK Tier: 4+ hrs ? UK Tier 2 | EU 261 UK Tier: 4+ hrs ? UK Tier 2 |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Sister City: FALSE | Sister City: FALSE |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE | Fallback: FALSE |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | MS SARAH THOMPSON / ELIGIBLE / EU261_UK_DELAY_GTE_4_HOURS_LONG_HAUL / GBP 520.00 / [expiry date] | MS SARAH THOMPSON / ELIGIBLE / EU261_UK_DELAY_GTE_4_HOURS_LONG_HAUL / GBP 520.00 / [expiry date] |
| CP067 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP068 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP069 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP070 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 858 from London Heathrow (LHR) to Toronto (YYZ) was delayed by about 5 hours. Based on the UK Air  |
| CP071 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP072 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "United Kingdom" | United Kingdom |
| CP073 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = UK ? Currency = GBP |  |
| CP074 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP075 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP076 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a �520 GBP compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a �520 GBP compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP077 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP078 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP079 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Bank Transfer (UK) |  |
| CP080 | PAYMENT METHOD � BANK TRANSFER (FD-07) | bot | chat | Then the chatbot responds: "Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email add | Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment re |
| CP081 | PAYMENT METHOD � BANK TRANSFER (FD-07) | system | implied | And user responds: "Yes, confirm this email." |  |
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
| CP093 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �520 GBP Payment Method: Bank Transfer After submission, you will receive a confirmation email summarizing your eligibility, claim details and n |
| CP094 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP095 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP096 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP097 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP098 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP099 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP100 | NOTIFICATION | email | email | And an eligible notification email is sent to s***@gmail.com |  |
| CP101 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�520 GBP), regulation (EU 261 UK), flight details (LHR?YYZ), disruption reason, |  |
| CP102 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP103 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP104 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Sarah Thompson" with PNR "TC183" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Sarah Thompson" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC183" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (UK)" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Sarah Thompson" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "s***@gmail.com" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+44***234" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: LHR ? YYZ" with claim filed for this flight |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "�520 GBP" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 UK with delay 5h and UK origin and controllable Code 42 |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Sarah Thompson + TC183 + LHR?YYZ + FD" |  |
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
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing compensation amount "�520 GBP" and regulation "EU 261 UK" and  |  |
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
| CP161 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Email Payment" |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "�520" GBP |  |
| CP164 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP165 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP166 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP167 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP168 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP169 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should record GBP amount and CAD equivalent and exchange rate and source and date for PRISM/Exposure reporti |  |
| CP170 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details with amount in GBP and payment method "Cash" via "Email Transfer" and s |  |
| CP171 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-EL-02. | DDS returns FD-EU-EL-02. |
| CP172 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 16:00; Actual = 21:00; Delay = 5hrs (300 min); MSL = Leg 1; Code 42; Controllable; Fallback = FALSE. | Trip Tracer: Promise = 16:00; Actual = 21:00; Delay = 5hrs (300 min); MSL = Leg 1; Code 42; Controllable; Fallback = FALSE. |
| CP173 | EXPECTED RESULTS | verdict | api | Dual Regime: EU 261 (UK) = EL-02, UK Tier 2 (4+hrs); APPR = EL-01, $400 (Tier 1, 3�<6hrs). | Dual Regime: EU 261 (UK) = EL-02, UK Tier 2 (4+hrs); APPR = EL-01, $400 (Tier 1, 3�<6hrs). |
| CP174 | EXPECTED RESULTS | verdict | chat | Most Generous: EU-UK EL-02 (520 GBP) selected. | Most Generous: EU-UK EL-02 (520 GBP) selected. |
| CP175 | EXPECTED RESULTS | verdict | chat | Compensation: UK Tier 2 amount (Cash). | Compensation: UK Tier 2 amount (Cash). |
| CP176 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP177 | EXPECTED RESULTS | verdict | chat | IDV: PASS. | IDV: PASS. |
| CP178 | EXPECTED RESULTS | verdict | chat | Payment:Email. | Payment:Email. |
| CP179 | EXPECTED RESULTS | verdict | api | Claims Dashboard: EU-UK EL-02(520 GBP) ? SELECTED; APPR $400; ASL N/A; DDS = FD-EU-EL-02. | Claims Dashboard: EU-UK EL-02(520 GBP) ? SELECTED; APPR $400; ASL N/A; DDS = FD-EU-EL-02. |
