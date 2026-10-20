# FD_TC_134 · CHAI-31526 — checkpoints

**Goal:** Guadeloupe-origin multi-leg journey (PTP?YUL?YYZ). Leg 1 completed on time. Leg 2 (YUL?YYZ) cancelled due to controllable reason (cancellation code CREW). Customer stranded at midpoint YUL � did not return to PTP or reach YYZ. No Travel Incomplete + Guadeloupe = flat �400. APPR also applies but EU-Guadeloupe wins. Validates: (1) Guadeloupe flat rate applies consistently across all three No Travel statuses (Origin EL-23, Return EL-29, Incomplete EL-35), (2) No Travel Incomplete correctly identified when customer stuck at midpoint, (3) Cancellation code CREW correctly classified as Controllable.

Methods: seed 12, chat 67, api 11, email 3, dashboard 49, implied 27, manual 14, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Guadeloupe-origin multi-leg journey (PTP?YUL?YYZ). Leg 1 completed on time. Leg 2 (YUL?YYZ) cancelled due to controllable reason (cancellati |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Maxime Th�odore (Adult) | PNR: single passenger Maxime Th�odore (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 2 legs AC operated: Leg 1 AC 1802 PTP?YUL (on time); Leg 2 AC 422 YUL?YYZ (CANCELLED) | Journey: 2 legs AC operated: Leg 1 AC 1802 PTP?YUL (on time); Leg 2 AC 422 YUL?YYZ (CANCELLED) |
| CP004 | PREREQUISITES | prerequisite | seed | Cancellation code on Leg 2: CREW (Crew unavailability � Controllable) | Cancellation code on Leg 2: CREW (Crew unavailability � Controllable) |
| CP005 | PREREQUISITES | prerequisite | seed | Customer action: Stranded at YUL (midpoint) | Customer action: Stranded at YUL (midpoint) |
| CP006 | PREREQUISITES | prerequisite | seed | Did NOT reach YYZ | Did NOT reach YYZ |
| CP007 | PREREQUISITES | prerequisite | seed | Did NOT return to PTP | Did NOT return to PTP |
| CP008 | PREREQUISITES | prerequisite | seed | No Travel status: Incomplete | No Travel status: Incomplete |
| CP009 | PREREQUISITES | prerequisite | seed | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP010 | PREREQUISITES | prerequisite | seed | MSL: Leg 2 (YUL?YYZ) | MSL: Leg 2 (YUL?YYZ) |
| CP011 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (Guadeloupe) + APPR | Regime: EU 261 (Guadeloupe) + APPR |
| CP012 | PREREQUISITES | prerequisite | seed | Residence: Guadeloupe (France) ? EUR ? BSM � Email Payment | Residence: Guadeloupe (France) ? EUR ? BSM � Email Payment |
| CP013 | PREREQUISITES | prerequisite | seed | Aeroplan: NOT linked ? Cash only | Aeroplan: NOT linked ? Cash only |
| CP014 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP015 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP016 | START | customer | chat | Then user selects English |  |
| CP017 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP018 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP019 | START | customer | chat | And the user says "I flew from Pointe-�-Pitre to Montreal but my connecting flight from Montreal to Toronto was cancelled due to a crew issu | I flew from Pointe-�-Pitre to Montreal but my connecting flight from Montreal to Toronto was cancelled due to a crew issue. I'm stuck in Montreal � I didn't go  |
| CP020 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP021 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP022 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP023 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Maxime Th�odore" | Maxime Th�odore |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Maxime! And, what is your booking reference number? |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC093" | PNR: TC093 |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC093 |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: m***@gmail.com Phone: +590***901 |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: m***@gmail.com" | Email: m***@gmail.com |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP037 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP039 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP041 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP043 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Maxime Th�odore (Adult) Is this who you'd like to include? |
| CP044 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP046 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Segment 1: Flight AC 1802, Pointe-�-Pitre (PTP) ? Montreal (YUL), June 7, 2026 � COMPLETED Segment 2: Flight AC 422, Montreal (YU |
| CP047 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP049 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 CANCELLED |  |
| CP050 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot determines: Claim applies to Segment 2 (AC 422 YUL?YYZ � CANCELLED) |  |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP052 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP053 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure of Leg 2 |  |
| CP054 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure was June 7, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED |  |
| CP055 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction � Guadeloupe is French overseas territory) = 5 years ? within limit |  |
| CP056 | REGIME DETERMINATION | system | implied | Then the system determines: Journey origin = PTP (Guadeloupe � EU outermost region) ? EU 261 (Guadeloupe) |  |
| CP057 | REGIME DETERMINATION | system | implied | And the system checks: Destination = YYZ (Toronto, Canada) ? APPR also applies |  |
| CP058 | REGIME DETERMINATION | system | implied | And the system checks: Customer stuck at midpoint (YUL), never reached YYZ, did not return to PTP ? No Travel Incomplete |  |
| CP059 | REGIME DETERMINATION | system | implied | And the system checks: Guadeloupe compensation rule ? Flat �400 |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC093 | Cancellation � crew unavailability |
| CP063 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP064 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP065 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP066 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your connecting flight AC 422 from Montreal (YUL) to Toronto (YYZ) on June 7, 2026 was cancelled. Based on t |
| CP067 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP068 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "France" | France |
| CP069 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = France (Guadeloupe) ? Currency = EUR |  |
| CP070 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP071 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP072 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a �400 EUR compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a �400 EUR compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP073 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP074 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP075 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? BSM � Email Payment (France/Guadeloupe) |  |
| CP076 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | bot | chat | Then the chatbot responds: "Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email add | Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment re |
| CP077 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | system | implied | And user responds: "Yes, confirm this email." |  |
| CP078 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP085 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP086 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP087 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP088 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP089 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �400 EUR Payment Method: BSM � Email Payment After submission, you will receive a confirmation email summarizing your eligibility, claim details |
| CP090 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP091 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP092 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP093 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP094 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP095 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP096 | NOTIFICATION | email | email | And an eligible notification email is sent to m***@gmail.com |  |
| CP097 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�400 EUR), regulation (EU 261/2004), flight details (Leg 2: YUL?YYZ CANCELLED), |  |
| CP098 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP099 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP100 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Maxime Th�odore" with PNR "TC093" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Maxime Th�odore" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC093" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (Guadeloupe / DOM-TOM) + APPR" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Maxime Th�odore" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "m***@gmail.com" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+590***901" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: PTP ? YUL" as completed and "Segment 2: YUL ? YYZ" with claim filed as cancelled |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "�400 EUR" as Guadeloupe flat rate for No Tra |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Cancellation Code should be "CREW" as a 4-character Netline code indicating Controllable |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dual Regime should show EU 261 Guadeloupe at �400 as selected and APPR at $400 CAD as not selected |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the most generous regime should be EU 261 Guadeloupe at �400 because at typical exchange rates �400 is approximately $590 CAD which is g |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 Guadeloupe with No Travel Incomplete and controllable cancel |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the No Travel status should be "INCOMPLETE" as stranded at YUL midpoint and not Origin and not Return |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Maxime Th�odore + TC093 + PTP?YUL?YYZ + FD" |  |
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
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing compensation "�400 EUR" and regulation "EU 261/2004" and trave |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP159 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "France (Guadeloupe)" |  |
| CP160 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "EUR" |  |
| CP161 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM � Email Payment" |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And the customer details should be collected including email address and phone number |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP164 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "�400" as Guadeloupe flat rate for No Travel Incomplete with controllable cancellation code CREW |  |
| CP165 | PAYMENT VALIDATION | payment | chat | And this is a No Travel case so both compensation and refund should be processed |  |
| CP166 | PAYMENT VALIDATION | payment | chat | And a PS agent task should be created in Claims Dashboard for the refund |  |
| CP167 | PAYMENT VALIDATION | payment | chat | And the agent should action the refund in ARD Web and mark it as refunded |  |
| CP168 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP169 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP170 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier via HSBC channel for BSM |  |
| CP171 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP172 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP173 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should record EUR amount and CAD equivalent and exchange rate and source and date |  |
| CP174 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details with amount in EUR and payment method "Cash" via "BSM � Email Payment"  |  |
| CP175 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show a refund record with PS agent task status tracked separately |  |
| CP176 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-EL-35. | DDS returns FD-EU-EL-35. |
| CP177 | EXPECTED RESULTS | verdict | api | Trip Tracer: Leg 1 = Completed; Leg 2 = CANCELLED; MSL = Leg 2 (AC 422 YUL?YYZ); Cancellation Code = CREW ; No Travel = Incomplete; Fallback | Trip Tracer: Leg 1 = Completed; Leg 2 = CANCELLED; MSL = Leg 2 (AC 422 YUL?YYZ); Cancellation Code = CREW ; No Travel = Incomplete; Fallback = FALSE (cancellati |
| CP178 | EXPECTED RESULTS | verdict | chat | Guadeloupe Rate: Flat �400 . | Guadeloupe Rate: Flat �400 . |
| CP179 | EXPECTED RESULTS | verdict | api | Dual Regime: EU-Guadeloupe = EL-35 (�400, No Travel Incomplete); APPR = $400 CAD (not selected). | Dual Regime: EU-Guadeloupe = EL-35 (�400, No Travel Incomplete); APPR = $400 CAD (not selected). |
| CP180 | EXPECTED RESULTS | verdict | chat | Most Generous: EU-Guadeloupe selected (�400 ? ~$590 CAD > $400). | Most Generous: EU-Guadeloupe selected (�400 ? ~$590 CAD > $400). |
| CP181 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP182 | EXPECTED RESULTS | verdict | chat | IDV: PASS. | IDV: PASS. |
| CP183 | EXPECTED RESULTS | verdict | chat | Payment: BSM � Email Payment Guadeloupe EUR. | Payment: BSM � Email Payment Guadeloupe EUR. |
| CP184 | EXPECTED RESULTS | verdict | api | Claims Dashboard: EU-Guadeloupe EL-35 ? SELECTED; �400; No Travel = Incomplete; Stranded = YUL; MSL = Leg 2; Cancellation Code = CREW; Fallb | Claims Dashboard: EU-Guadeloupe EL-35 ? SELECTED; �400; No Travel = Incomplete; Stranded = YUL; MSL = Leg 2; Cancellation Code = CREW; Fallback = FALSE; Multi-l |
