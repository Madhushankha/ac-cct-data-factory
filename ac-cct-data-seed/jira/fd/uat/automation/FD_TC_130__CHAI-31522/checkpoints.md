# FD_TC_130 · CHAI-31522 — checkpoints

**Goal:** A UK-originating, AC-operated flight (LHR ? YYZ) was cancelled with code POSI (SOM). The aircraft couldn't be positioned at LHR because of an AC upline issue, which is controllable. The customer declined rebooking and stayed in London. No Travel Origin + UK origin + Controllable = GBP 520. APPR also applies (Canada destination), but EU-UK is more generous. Checks four things: (1) UK No Travel Origin is identified, (2) the flat UK cancellation amount is applied, (3) POSI (SOM) is classed as controllable, and (4) the dual-regime check (EU-UK and APPR) picks EU-UK.

Methods: seed 14, chat 65, api 32, email 3, dashboard 44, implied 25, manual 15, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | A UK-originating, AC-operated flight (LHR ? YYZ) was cancelled with code POSI (SOM). The aircraft couldn't be positioned at LHR because of a |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR TC087: one passenger, Henry Whitfield (Adult) | PNR TC087: one passenger, Henry Whitfield (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | One AC-operated leg: AC 849 LHR ? YYZ, May 28, 2026, scheduled departure 10:00, scheduled arrival 14:00 (local YYZ) | One AC-operated leg: AC 849 LHR ? YYZ, May 28, 2026, scheduled departure 10:00, scheduled arrival 14:00 (local YYZ) |
| CP004 | PREREQUISITES | prerequisite | seed | Status: CANCELLED | Status: CANCELLED |
| CP005 | PREREQUISITES | prerequisite | seed | Cancellation code: POSI (SOM), aircraft availability, upline, controllable | Cancellation code: POSI (SOM), aircraft availability, upline, controllable |
| CP006 | PREREQUISITES | prerequisite | seed | Upline cause: inbound AC 848 YYZ ? LHR couldn't position the aircraft at LHR because of an AC operational issue (not on the customer's PNR) | Upline cause: inbound AC 848 YYZ ? LHR couldn't position the aircraft at LHR because of an AC operational issue (not on the customer's PNR) |
| CP007 | PREREQUISITES | prerequisite | seed | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP008 | PREREQUISITES | prerequisite | seed | The customer declined rebooking and stayed at LHR | The customer declined rebooking and stayed at LHR |
| CP009 | PREREQUISITES | prerequisite | seed | No Travel status: Origin | No Travel status: Origin |
| CP010 | PREREQUISITES | prerequisite | seed | Regimes: EU 261 (UK) + APPR | Regimes: EU 261 (UK) + APPR |
| CP011 | PREREQUISITES | prerequisite | seed | Filed June 24, 2026 (more than 72 hours after scheduled departure, within the UK 6-year limit) | Filed June 24, 2026 (more than 72 hours after scheduled departure, within the UK 6-year limit) |
| CP012 | PREREQUISITES | prerequisite | seed | No duplicate | No duplicate |
| CP013 | PREREQUISITES | prerequisite | seed | Aeroplan: not linked, so Cash only | Aeroplan: not linked, so Cash only |
| CP014 | PREREQUISITES | prerequisite | seed | Residence: United Kingdom, so GBP and BSM email payment | Residence: United Kingdom, so GBP and BSM email payment |
| CP015 | PREREQUISITES | prerequisite | implied | CyberSource set to GREEN | CyberSource set to GREEN |
| CP016 | PREREQUISITES | prerequisite | seed | Persona set to IDV PASS | Persona set to IDV PASS |
| CP017 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP018 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP019 | START | customer | chat | Then user selects English |  |
| CP020 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP021 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP022 | START | customer | chat | And the user says "My flight from London Heathrow to Toronto was cancelled because the aircraft wasn't available, and I didn't take any repl | My flight from London Heathrow to Toronto was cancelled because the aircraft wasn't available, and I didn't take any replacement flight. Can I get compensation? |
| CP023 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP024 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP025 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your cancelled flight and see if you are eligible for compensation | No problem, I can help you create a claim for your cancelled flight and see if you are eligible for compensation. |
| CP026 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable." | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Henry Whitfield" | Henry Whitfield |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, Henry! And, what is your booking reference number?" | Thanks, Henry! And, what is your booking reference number? |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC087" | PNR: TC087 |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC087 |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: Email: h***@gmail.com / Phone: +44***890 |  |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: h***@gmail.com" | Email: h***@gmail.com |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP042 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP043 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP044 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP045 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP046 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays: "I found 1 passenger on this booking: Henry Whitfield (Adult). Is this who you'd like to include?" | I found 1 passenger on this booking: Henry Whitfield (Adult). Is this who you'd like to include? |
| CP047 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP049 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 849 Route: London Heathrow (LHR) ? Toronto (YYZ) Date: May 28, 2026 Status: CANCELLED Is this the journey you'd like t |
| CP050 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP051 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP052 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP053 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP054 | 72-HOUR CHECK | system | implied | Then the system calculates: Scheduled departure May 28, 2026; current date June 24, 2026 ? >72 hours ? PROCEED |  |
| CP055 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (UK) = 6 years ? within limitation ? PROCEED |  |
| CP056 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = LHR (UK) ? EU 261 (UK) applies |  |
| CP057 | REGIME DETERMINATION | system | implied | And the system checks: Destination = YYZ (Canada) ? APPR also applies |  |
| CP058 | REGIME DETERMINATION | system | implied | And the system checks: Customer did NOT travel ? No Travel Origin (remained at LHR) |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | And DDS identifies MSL = AC 849 LHR?YYZ (only segment, cancelled) |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the cancellation code on MSL ? POSI (SOM) ? used for controllability (no fallback needed) |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | And DDS classifies POSI (SOM) as CONTROLLABLE (aircraft availability / positioning � upline, within carrier control) |  |
| CP063 | TRIAGE & DDS EVALUATION | verdict | api | And DDS detects travel outcome: No Travel � Origin (customer never departed LHR, no rebooking accepted) |  |
| CP064 | TRIAGE & DDS EVALUATION | verdict | api | And DDS evaluates EU 261 (UK): No Travel Origin, Controllable ? GBP 520 ? ELIGIBLE |  |
| CP065 | TRIAGE & DDS EVALUATION | verdict | api | And DDS evaluates APPR: No Travel Origin, Controllable ? CAD 400 ? ELIGIBLE |  |
| CP066 | TRIAGE & DDS EVALUATION | verdict | api | And DDS compares both regimes and selects EU 261 (UK) as most generous |  |
| CP067 | TRIAGE & DDS EVALUATION | verdict | api | And DDS returns FD-EU-EL-21 and sends results to Trip Tracer UI |  |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 849, Route: LHR ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 14:00 (local YYZ) | Promised Itinerary - Flight: AC 849, Route: LHR ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 14:00 (local YYZ) |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 849, Route: LHR ? YYZ, Status: CANCELLED | Current Itinerary - Flight: AC 849, Route: LHR ? YYZ, Status: CANCELLED |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Customer Status: NO TRAVEL - ORIGIN (customer remained at LHR, declined rebooking) | Customer Status: NO TRAVEL - ORIGIN (customer remained at LHR, declined rebooking) |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | History - No rebooking accepted | History - No rebooking accepted |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | Regimes: EU 261 (UK) (UK origin � LHR) + APPR (Canada destination � YYZ) | Regimes: EU 261 (UK) (UK origin � LHR) + APPR (Canada destination � YYZ) |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 849 � LHR ? YYZ | MSL FLIGHT: AC 849 � LHR ? YYZ |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | Cancellation Code: POSI (SOM) � 4-character Netline code, NOT a numeric delay code | Cancellation Code: POSI (SOM) � 4-character Netline code, NOT a numeric delay code |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | "Cancellation � aircraft availability (upline positioning)" | "Cancellation � aircraft availability (upline positioning)" |
| CP076 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (POSI is in the Controllable cancellation code list: COMM, CREW, EQUI, FUEL, HDLG, HOLI, OPER, POSI, REPO, ROTA, RTNS, TECH) | CONTROLLABLE (POSI is in the Controllable cancellation code list: COMM, CREW, EQUI, FUEL, HDLG, HOLI, OPER, POSI, REPO, ROTA, RTNS, TECH) |
| CP077 | TRIP TRACER UI VALIDATION | verdict | api | Disruption Type: CANCELLATION | Disruption Type: CANCELLATION |
| CP078 | TRIP TRACER UI VALIDATION | verdict | api | EU 261 UK: No Travel Origin, Controllable = GBP 520 ? SELECTED | EU 261 UK: No Travel Origin, Controllable = GBP 520 ? SELECTED |
| CP079 | TRIP TRACER UI VALIDATION | verdict | api | APPR: No Travel Origin, Controllable = CAD 400 (not selected) | APPR: No Travel Origin, Controllable = CAD 400 (not selected) |
| CP080 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE (cancellation code POSI available � cancellation code used first in priority order) | Fallback: FALSE (cancellation code POSI available � cancellation code used first in priority order) |
| CP081 | TRIP TRACER UI VALIDATION | verdict | api | Sister City: FALSE | Sister City: FALSE |
| CP082 | TRIP TRACER UI VALIDATION | verdict | api | DDS outcome code: FD-EU-EL-21 | DDS outcome code: FD-EU-EL-21 |
| CP083 | TRIP TRACER UI VALIDATION | verdict | api | MR HENRY WHITFIELD / ELIGIBLE / EU261_UK_NO_TRAVEL_ORIGIN / GBP 520.00 / [expiry date] | MR HENRY WHITFIELD / ELIGIBLE / EU261_UK_NO_TRAVEL_ORIGIN / GBP 520.00 / [expiry date] |
| CP084 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP085 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN LIGHT (no fraud detected) |  |
| CP086 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP087 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 849 from London Heathrow (LHR) to Toronto (YYZ) on May 28, 2026 was cancelled because the aircraft |
| CP088 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: "Thank you for confirming. In which country will your reimbursement be deposited?" | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP089 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "United Kingdom" | United Kingdom |
| CP090 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = UK ? Currency = GBP |  |
| CP091 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No ? Cash only |  |
| CP092 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP093 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a GBP 520 compensation. Please note that it will take 5 to 10 business days to proce | You are entitled to receive a GBP 520 compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP094 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP095 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And the user provides "Yes" | Yes |
| CP096 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the system checks which payment method is mapped based on country of residence ? BSM � Email Payment (UK) |  |
| CP097 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | bot | chat | Then the chatbot responds: "Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email add | Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment re |
| CP098 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | system | implied | And the user responds: "Yes, confirm this email." |  |
| CP099 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | system | implied | Then the chatbot does NOT ask for bank account, sort code, IBAN or card details in the chat |  |
| CP100 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | idv | chat | Then the system checks that IDV is not completed |  |
| CP101 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: "I must verify your identity for payment security. Please click here to get started" | I must verify your identity for payment security. Please click here to get started |
| CP102 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And the chatbot displays a button "Get verified" | Get verified |
| CP103 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When the user clicks on the button |  |
| CP104 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then the system checks if IDV at Payment |  |
| CP105 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the system checks if the user has consented to IDV |  |
| CP106 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP107 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP108 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP109 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: "Your identity has been verified successfully. Let's proceed to finalize your claim." | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP110 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: GBP 520 Payment Method: BSM � Email Payment (h***@gmail.com) After submission, you will receive a confirmation email summarizing your eligibilit |
| CP111 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP112 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP113 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP114 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP115 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP116 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP117 | NOTIFICATION | email | email | And an eligible notification email is sent to h***@gmail.com |  |
| CP118 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (GBP 520), regulation (EU 261 UK), flight details (AC 849 LHR?YYZ CANCELLED), tr |  |
| CP119 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No] | Is there anything I can help you with? |
| CP120 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP121 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Henry Whitfield" with PNR "TC087" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date should be populated |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Henry Whitfield" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC087" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (UK) + APPR" |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Henry Whitfield" |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "h***@gmail.com" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+44***890" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address, Profile ID and Tier Status should be populated |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: LHR ? YYZ" with claim filed for this flight as cancelled |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present with no expected ancillary fees |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should show compensation "GBP 520" |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Cancellation Code should be "POSI (SOM)" as a 4-character Netline code indicating Controllable (aircraft availability, upline) |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the travel status should show "No Travel � Origin" |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dual Regime should show EU 261 UK at GBP 520 as SELECTED and APPR at CAD 400 as not selected |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS outcome should be "FD-EU-EL-21" |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 UK with No Travel Origin and controllable cancellation code  |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Henry Whitfield + TC087 + LHR?YYZ + FD" |  |
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
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing "GBP 520", "EU 261 UK", "No Travel - Origin", AC 849 LHR?YYZ c |  |
| CP166 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And a PS agent task for the refund should be visible on the case |  |
| CP167 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP168 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP169 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP170 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP171 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP172 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP173 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP174 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP175 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "United Kingdom" |  |
| CP176 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "GBP" |  |
| CP177 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM � Email Payment" |  |
| CP178 | PAYMENT VALIDATION | payment | chat | And the customer's email address should be confirmed and locked, with phone number on file |  |
| CP179 | PAYMENT VALIDATION | payment | chat | And no bank account, sort code, IBAN or card details should be collected in the chat |  |
| CP180 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP181 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "GBP 520" for EU UK No Travel Origin with controllable cancellation code POSI (SOM) |  |
| CP182 | PAYMENT VALIDATION | payment | chat | And this is a No Travel case so both compensation and refund should be processed |  |
| CP183 | PAYMENT VALIDATION | payment | chat | And a PS agent task should be created in Claims Dashboard for the refund |  |
| CP184 | PAYMENT VALIDATION | payment | chat | And the agent should action the refund in ARD Web and mark it as refunded |  |
| CP185 | PAYMENT VALIDATION | payment | chat | And exactly one compensation record should be created in the backend with GL account and cost center |  |
| CP186 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP187 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier via HSBC channel for BSM |  |
| CP188 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP189 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cashed" or "Rejected" or "Expired" |  |
| CP190 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should record GBP amount, CAD equivalent, exchange rate, source and date |  |
| CP191 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show GBP 520, payment method "Cash" via "BSM � Email Payment", and status updated via talkb |  |
| CP192 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show a refund record with PS agent task status tracked separately |  |
| CP193 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-EL-21. | DDS returns FD-EU-EL-21. |
| CP194 | EXPECTED RESULTS | verdict | api | Trip Tracer: Flight = CANCELLED, MSL = Leg 1, cancellation code = POSI (SOM), aircraft availability upline, controllable. | Trip Tracer: Flight = CANCELLED, MSL = Leg 1, cancellation code = POSI (SOM), aircraft availability upline, controllable. |
| CP195 | EXPECTED RESULTS | verdict | api | No Travel = Origin, Fallback = FALSE, Sister City = FALSE, Regimes = EU 261 (UK) + APPR. | No Travel = Origin, Fallback = FALSE, Sister City = FALSE, Regimes = EU 261 (UK) + APPR. |
| CP196 | EXPECTED RESULTS | verdict | chat | Dual regime: EU-UK GBP 520 (No Travel Origin) is SELECTED over APPR CAD 400. | Dual regime: EU-UK GBP 520 (No Travel Origin) is SELECTED over APPR CAD 400. |
| CP197 | EXPECTED RESULTS | verdict | chat | CyberSource GREEN, Persona PASS. | CyberSource GREEN, Persona PASS. |
| CP198 | EXPECTED RESULTS | verdict | chat | Payment: BSM email payment, GBP, plus a refund through a PS agent task. | Payment: BSM email payment, GBP, plus a refund through a PS agent task. |
| CP199 | EXPECTED RESULTS | verdict | dashboard | Claims Dashboard: EU-UK EL-21 selected, No Travel = Origin, POSI (SOM), Resolved. | Claims Dashboard: EU-UK EL-21 selected, No Travel = Origin, POSI (SOM), Resolved. |
