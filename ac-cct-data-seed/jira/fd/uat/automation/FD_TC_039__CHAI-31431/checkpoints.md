# FD_TC_039 · CHAI-31431 — checkpoints

**Goal:** The arrival delay code is missing at the highest delay tier (10 hours), so DDS falls back to departure delay code 06 (OA, controllable). This completes the fallback � delay tier matrix with a different controllable code. It checks that fallback works the same whatever the delay length or controllable code, and that Tier 3 pays CAD 1,000 by Interac.

Methods: seed 16, chat 62, api 34, email 3, dashboard 41, implied 22, manual 16, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | The arrival delay code is missing at the highest delay tier (10 hours), so DDS falls back to departure delay code 06 (OA, controllable). Thi |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR TC078: one passenger, Fran�ois Beaumont (Adult) | PNR TC078: one passenger, Fran�ois Beaumont (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | One AC domestic leg: AC 440 YUL?YYZ, May 14, 2026 | One AC domestic leg: AC 440 YUL?YYZ, May 14, 2026 |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival 08:00 | Scheduled arrival 08:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival 18:00 (10-hour delay, 9+ hour band) | Actual arrival 18:00 (10-hour delay, 9+ hour band) |
| CP006 | PREREQUISITES | prerequisite | seed | Status: ARRIVED (operated) | Status: ARRIVED (operated) |
| CP007 | PREREQUISITES | prerequisite | seed | Cancellation code: NONE | Cancellation code: NONE |
| CP008 | PREREQUISITES | prerequisite | seed | Arrival delay code: NULL (missing) | Arrival delay code: NULL (missing) |
| CP009 | PREREQUISITES | prerequisite | seed | First departure delay code: 06 (OA, no gate/stand availability due to own airline activity, controllable), used as fallback | First departure delay code: 06 (OA, no gate/stand availability due to own airline activity, controllable), used as fallback |
| CP010 | PREREQUISITES | prerequisite | seed | No other delay codes on the MSL | No other delay codes on the MSL |
| CP011 | PREREQUISITES | prerequisite | seed | Booking changes: none (no VOL or INVOL) | Booking changes: none (no VOL or INVOL) |
| CP012 | PREREQUISITES | prerequisite | seed | Aeroplan: not linked | Aeroplan: not linked |
| CP013 | PREREQUISITES | prerequisite | implied | CyberSource set to GREEN | CyberSource set to GREEN |
| CP014 | PREREQUISITES | prerequisite | seed | Persona set to IDV PASS | Persona set to IDV PASS |
| CP015 | PREREQUISITES | prerequisite | seed | Country of residence: Canada (CAD, Interac) | Country of residence: Canada (CAD, Interac) |
| CP016 | PREREQUISITES | prerequisite | seed | Regime: APPR | Regime: APPR |
| CP017 | PREREQUISITES | prerequisite | seed | More than 72 hours have passed | More than 72 hours have passed |
| CP018 | PREREQUISITES | prerequisite | seed | Filed after 32 days, within 366 days | Filed after 32 days, within 366 days |
| CP019 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP020 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP021 | START | customer | chat | Then user selects English |  |
| CP022 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP023 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP024 | START | customer | chat | And the user says "My flight from Montreal to Toronto was delayed about 10 hours because there was no gate available for our plane, I'd like | My flight from Montreal to Toronto was delayed about 10 hours because there was no gate available for our plane, I'd like to check if I'm eligible for compensat |
| CP025 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP026 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP027 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP028 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable." | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Fran�ois Beaumont" | Fran�ois Beaumont |
| CP032 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, Fran�ois! And, what is your booking reference number?" | Thanks, Fran�ois! And, what is your booking reference number? |
| CP033 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC078" | PNR: TC078 |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC078 |  |
| CP035 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP036 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: Email: f***@outlook.com / Phone: +1***234 |  |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: f***@outlook.com" | Email: f***@outlook.com |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP041 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP042 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP043 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP044 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP045 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP046 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP047 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP048 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays: "I found 1 passenger on this booking: Fran�ois Beaumont (Adult). Is this who you'd like to include?" | I found 1 passenger on this booking: Fran�ois Beaumont (Adult). Is this who you'd like to include? |
| CP049 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP050 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP051 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 440 Route: Montreal (YUL) ? Toronto (YYZ) Date: May 14, 2026 Arrival Delay: 10 hours Is this the journey you'd like to |
| CP052 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP053 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP054 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP055 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP056 | 72-HOUR CHECK | system | implied | Then the system calculates: Arrival May 14, 2026; current date June 15, 2026 ? >72 hours ? PROCEED |  |
| CP057 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP058 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 14, 2026; filing June 15, 2026 ? 32 days ? within 366 days ? PROCEED |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | And DDS identifies MSL = AC 440 YUL?YYZ (only segment) |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the cancellation code on MSL ? NONE |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the first arrival delay code on MSL ? NULL (MISSING) |  |
| CP063 | TRIAGE & DDS EVALUATION | verdict | api | And DDS falls back to the first departure delay code on MSL ? 06 (OA) |  |
| CP064 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sets Fallback = TRUE |  |
| CP065 | TRIAGE & DDS EVALUATION | verdict | api | And DDS finds a single delay code on MSL ? Multiple Root Cause Analysis NOT required |  |
| CP066 | TRIAGE & DDS EVALUATION | verdict | api | And DDS calculates delay = 18:00 ? 08:00 = 10 hours ? band 9+ hours ? Tier 3 |  |
| CP067 | TRIAGE & DDS EVALUATION | verdict | api | And DDS classifies 06 (OA) as WITHIN CARRIER CONTROL ? CONTROLLABLE |  |
| CP068 | TRIAGE & DDS EVALUATION | verdict | api | And DDS applies APPR Tier 3 = CAD 1,000 |  |
| CP069 | TRIAGE & DDS EVALUATION | verdict | api | And DDS returns FD-APPR-EL-09 and sends results to Trip Tracer UI |  |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 440, Route: YUL ? YYZ, Scheduled Arrival: 08:00 | Promised Itinerary - Flight: AC 440, Route: YUL ? YYZ, Scheduled Arrival: 08:00 |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 440, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 08:00 ? Actual: 18:00, Delay: +10H 00M | Current Itinerary - Flight: AC 440, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 08:00 ? Actual: 18:00, Delay: +10H 00M |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | History - No booking changes (no VOL or INVOL) | History - No booking changes (no VOL or INVOL) |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 440 � YUL ? YYZ | MSL FLIGHT: AC 440 � YUL ? YYZ |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | Cancellation code: NONE | Cancellation code: NONE |
| CP076 | TRIP TRACER UI VALIDATION | verdict | api | First arrival delay code: NULL (MISSING) | First arrival delay code: NULL (MISSING) |
| CP077 | TRIP TRACER UI VALIDATION | verdict | api | FALLBACK TRIGGERED: Arrival code NULL ? using departure code | FALLBACK TRIGGERED: Arrival code NULL ? using departure code |
| CP078 | TRIP TRACER UI VALIDATION | verdict | api | First departure delay code: 06 (OA) � "No gate/stand availability due to own airline activity" | First departure delay code: 06 (OA) � "No gate/stand availability due to own airline activity" |
| CP079 | TRIP TRACER UI VALIDATION | verdict | api | No additional delay codes on MSL | No additional delay codes on MSL |
| CP080 | TRIP TRACER UI VALIDATION | verdict | api | Controllability source = first departure delay code (fallback) | Controllability source = first departure delay code (fallback) |
| CP081 | TRIP TRACER UI VALIDATION | verdict | api | Fallback Flag: TRUE | Fallback Flag: TRUE |
| CP082 | TRIP TRACER UI VALIDATION | verdict | api | APPR causal category: Within carrier control ? CONTROLLABLE | APPR causal category: Within carrier control ? CONTROLLABLE |
| CP083 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +10H 00M � CONTROLLABLE | Delay: +10H 00M � CONTROLLABLE |
| CP084 | TRIP TRACER UI VALIDATION | verdict | api | DDS outcome code: FD-APPR-EL-09 | DDS outcome code: FD-APPR-EL-09 |
| CP085 | TRIP TRACER UI VALIDATION | verdict | api | MR FRAN�OIS BEAUMONT / ELIGIBLE / DELAY_GTE_9_HOURS (FALLBACK) / CAD 1000.00 / [expiry date] | MR FRAN�OIS BEAUMONT / ELIGIBLE / DELAY_GTE_9_HOURS (FALLBACK) / CAD 1000.00 / [expiry date] |
| CP086 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP087 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN LIGHT (no fraud detected) |  |
| CP088 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP089 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 440 from Montreal (YUL) to Toronto (YYZ) was delayed by about 10 hours. Based on the Air Passenger |
| CP090 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: "Thank you for confirming. In which country will your reimbursement be deposited?" | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP091 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP092 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP093 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP094 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP095 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a CAD 1,000 compensation. Please note that it will take 5 to 10 business days to pro | You are entitled to receive a CAD 1,000 compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP096 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP097 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And the user provides "Yes" | Yes |
| CP098 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the system checks which payment method is mapped based on country of residence ? Interac (CANADA) |  |
| CP099 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP100 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP101 | PAYMENT METHOD � INTERAC (FD-07) | system | implied | Then the chatbot does NOT ask for bank account, card or any other payment details |  |
| CP102 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then the system checks that IDV is not completed |  |
| CP103 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: "I must verify your identity for payment security. Please click here to get started" | I must verify your identity for payment security. Please click here to get started |
| CP104 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And the chatbot displays a button "Get verified" | Get verified |
| CP105 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When the user clicks on the button |  |
| CP106 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then the system checks if IDV at Payment |  |
| CP107 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the system checks if the user has consented to IDV |  |
| CP108 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP109 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP110 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP111 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: "Your identity has been verified successfully. Let's proceed to finalize your claim." | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP112 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: CAD 1,000 Payment Method: Interac e-Transfer (f***@outlook.com) After submission, you will receive a confirmation email summarizing your eligibi |
| CP113 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP114 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP115 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP116 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP117 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP118 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP119 | NOTIFICATION | email | email | And an eligible notification email is sent to f***@outlook.com |  |
| CP120 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (CAD 1,000), regulation (APPR), flight details, fallback code note, disruption r |  |
| CP121 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No] | Is there anything I can help you with? |
| CP122 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP123 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Fran�ois Beaumont" with PNR "TC078" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date should be populated |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Fran�ois Beaumont" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC078" |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Fran�ois Beaumont" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "f***@outlook.com" |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***234" |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address, Profile ID and Tier Status should be populated |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fallback flag should be "TRUE" (arrival code NULL, departure code 06) |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present with no expected ancillary fees |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should show "ELIGIBLE � CAD 1,000 (Tier 3, 9+ hrs, Controllable, Departure Code 06 fallback)" |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS outcome should be "FD-APPR-EL-09" |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" due to controllable departure delay Code 06 (OA) used as fallback because |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Fran�ois Beaumont + TC078 + YUL?YYZ + FD" |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Persona IDV result should be "PASS" |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP166 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP167 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP168 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP169 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP170 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP171 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP172 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP173 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP174 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP175 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP176 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP177 | PAYMENT VALIDATION | payment | chat | And only the customer's email address should have been collected (no bank, card or other payment details) |  |
| CP178 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP179 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "CAD 1,000" for Tier 3 delay of 9 or more hours |  |
| CP180 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP181 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP182 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP183 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP184 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received from Interac |  |
| CP185 | PAYMENT VALIDATION | payment | manual | And the status should be "Pending" transitioning to "Cashed" or "Rejected" or "Expired" |  |
| CP186 | PAYMENT VALIDATION | payment | manual | And if the payment is unclaimed after 35 days the status should be set to "Expired" |  |
| CP187 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show "CAD 1,000" |  |
| CP188 | PAYMENT VALIDATION | payment | chat | And the payment method should show "Cash" via "Interac" |  |
| CP189 | PAYMENT VALIDATION | payment | manual | And the status should be updated via talkback |  |
| CP190 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-09. | DDS returns FD-APPR-EL-09. |
| CP191 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 08:00, Actual = 18:00, Delay = 10 hours, MSL = Leg 1, cancellation code = NONE, arrival code = NULL, departure code = | Trip Tracer: Promise = 08:00, Actual = 18:00, Delay = 10 hours, MSL = Leg 1, cancellation code = NONE, arrival code = NULL, departure code = 06 (OA) used as fal |
| CP192 | EXPECTED RESULTS | verdict | chat | Compensation: CAD 1,000 (Tier 3) by Interac. | Compensation: CAD 1,000 (Tier 3) by Interac. |
| CP193 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP194 | EXPECTED RESULTS | verdict | chat | Persona: PASS. | Persona: PASS. |
| CP195 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Fallback = TRUE, code used = 06 (departure), DDS = FD-APPR-EL-09, Resolved. | Claims Dashboard: Fallback = TRUE, code used = 06 (departure), DDS = FD-APPR-EL-09, Resolved. |
