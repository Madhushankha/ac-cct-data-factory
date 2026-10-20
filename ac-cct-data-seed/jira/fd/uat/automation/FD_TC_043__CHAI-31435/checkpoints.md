# FD_TC_043 · CHAI-31435 — checkpoints

**Goal:** A single-leg domestic flight was cancelled for a controllable reason: cancellation code FUEL (ANF), fuel shortage. The customer stayed at the origin airport and didn't travel. Checks that DDS finds No Travel Origin when the only flight is cancelled, uses the cancellation code (FUEL) for eligibility, classes it as controllable, and applies the APPR No Travel Origin rules: CAD 400 flat compensation plus a refund.

Methods: seed 12, chat 67, api 28, email 3, dashboard 42, implied 22, manual 17, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | A single-leg domestic flight was cancelled for a controllable reason: cancellation code FUEL (ANF), fuel shortage. The customer stayed at th |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR TC083: one passenger, H�l�ne Bouchard (Adult) | PNR TC083: one passenger, H�l�ne Bouchard (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | One AC domestic leg: AC 444 YUL?YYZ, May 18, 2026, scheduled departure 09:00, scheduled arrival 12:00 | One AC domestic leg: AC 444 YUL?YYZ, May 18, 2026, scheduled departure 09:00, scheduled arrival 12:00 |
| CP004 | PREREQUISITES | prerequisite | seed | Status: CANCELLED | Status: CANCELLED |
| CP005 | PREREQUISITES | prerequisite | seed | Cancellation code: FUEL (ANF), fuel shortage, controllable | Cancellation code: FUEL (ANF), fuel shortage, controllable |
| CP006 | PREREQUISITES | prerequisite | seed | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP007 | PREREQUISITES | prerequisite | seed | The customer stayed at YUL, didn't travel and didn't accept rebooking | The customer stayed at YUL, didn't travel and didn't accept rebooking |
| CP008 | PREREQUISITES | prerequisite | seed | No Travel status: Origin | No Travel status: Origin |
| CP009 | PREREQUISITES | prerequisite | seed | Aeroplan: not linked, so Cash only | Aeroplan: not linked, so Cash only |
| CP010 | PREREQUISITES | prerequisite | seed | Filed June 15, 2026 (more than 72 hours after scheduled departure, 28 days, within 366 days) | Filed June 15, 2026 (more than 72 hours after scheduled departure, 28 days, within 366 days) |
| CP011 | PREREQUISITES | prerequisite | seed | No duplicate | No duplicate |
| CP012 | PREREQUISITES | prerequisite | implied | CyberSource set to GREEN | CyberSource set to GREEN |
| CP013 | PREREQUISITES | prerequisite | seed | Persona set to IDV PASS | Persona set to IDV PASS |
| CP014 | PREREQUISITES | prerequisite | seed | Country of residence: Canada (CAD, Interac, email only) | Country of residence: Canada (CAD, Interac, email only) |
| CP015 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP016 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP017 | START | customer | chat | Then user selects English |  |
| CP018 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP019 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP020 | START | customer | chat | And the user says "My flight from Montreal to Toronto was cancelled because of a fuel shortage and I didn't take any replacement flight. Can | My flight from Montreal to Toronto was cancelled because of a fuel shortage and I didn't take any replacement flight. Can I get compensation? |
| CP021 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP022 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP023 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your cancelled flight and see if you are eligible for compensation | No problem, I can help you create a claim for your cancelled flight and see if you are eligible for compensation. |
| CP024 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable." | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "H�l�ne Bouchard" | H�l�ne Bouchard |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, H�l�ne! And, what is your booking reference number?" | Thanks, H�l�ne! And, what is your booking reference number? |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC083" | PNR: TC083 |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC083 |  |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: Email: h***@gmail.com / Phone: +1***678 |  |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: h***@gmail.com" | Email: h***@gmail.com |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP038 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP040 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP041 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP042 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP043 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP044 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays: "I found 1 passenger on this booking: H�l�ne Bouchard (Adult). Is this who you'd like to include?" | I found 1 passenger on this booking: H�l�ne Bouchard (Adult). Is this who you'd like to include? |
| CP045 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP047 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 444 Route: Montreal (YUL) ? Toronto (YYZ) Date: May 18, 2026 Status: CANCELLED Is this the journey you'd like to check |
| CP048 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP049 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP050 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP052 | 72-HOUR CHECK | system | implied | Then the system calculates: Scheduled departure May 18, 2026; current date June 15, 2026 ? >72 hours ? PROCEED |  |
| CP053 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP054 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 18, 2026; filing June 15, 2026 ? 28 days ? within 366 days ? PROCEED |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS identifies MSL = AC 444 YUL?YYZ (only segment, cancelled) |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the cancellation code on MSL ? FUEL (ANF) ? used for controllability (no fallback needed) |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS classifies FUEL (ANF) as WITHIN CARRIER CONTROL ? CONTROLLABLE (fuel shortage) |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS detects travel outcome: No Travel � Origin (customer never departed YUL, no rebooking accepted) |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | And DDS applies APPR No Travel Origin rule: controllable cancellation ? flat CAD 400 + refund |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS returns FD-APPR-EL-13 and sends results to Trip Tracer UI |  |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 444, Route: YUL ? YYZ, Scheduled Departure: 09:00, Scheduled Arrival: 12:00 | Promised Itinerary - Flight: AC 444, Route: YUL ? YYZ, Scheduled Departure: 09:00, Scheduled Arrival: 12:00 |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 444, Route: YUL ? YYZ, Status: CANCELLED | Current Itinerary - Flight: AC 444, Route: YUL ? YYZ, Status: CANCELLED |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Customer Status: NO TRAVEL - ORIGIN (customer never departed, declined rebooking) | Customer Status: NO TRAVEL - ORIGIN (customer never departed, declined rebooking) |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | History - No rebooking accepted | History - No rebooking accepted |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 444 � YUL ? YYZ � Cancellation Code: FUEL (ANF) | MSL FLIGHT: AC 444 � YUL ? YYZ � Cancellation Code: FUEL (ANF) |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | "Cancellation � Fuel shortage" | "Cancellation � Fuel shortage" |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (FUEL � ANF) | CONTROLLABLE (FUEL � ANF) |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Disruption Type: CANCELLATION | Disruption Type: CANCELLATION |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | APPR No Travel Origin: Controllable cancellation = flat CAD 400 | APPR No Travel Origin: Controllable cancellation = flat CAD 400 |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | DDS outcome code: FD-APPR-EL-13 | DDS outcome code: FD-APPR-EL-13 |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | MS H�L�NE BOUCHARD / ELIGIBLE / NO_TRAVEL_ORIGIN / CAD 400.00 / [expiry date] | MS H�L�NE BOUCHARD / ELIGIBLE / NO_TRAVEL_ORIGIN / CAD 400.00 / [expiry date] |
| CP075 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP076 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN LIGHT (no fraud detected) |  |
| CP077 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP078 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 444 from Montreal (YUL) to Toronto (YYZ) on May 18, 2026 was cancelled due to a fuel shortage. Bas |
| CP079 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: "Thank you for confirming. In which country will your reimbursement be deposited?" | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP080 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP081 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP082 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No ? Cash only |  |
| CP083 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP084 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a CAD 400 compensation. Please note that it will take 5 to 10 business days to proce | You are entitled to receive a CAD 400 compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP085 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP086 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And the user provides "Yes" | Yes |
| CP087 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the system checks which payment method is mapped based on country of residence ? Interac (CANADA) |  |
| CP088 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP089 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP090 | PAYMENT METHOD � INTERAC (FD-07) | system | implied | Then the chatbot does NOT ask for bank account, card, transit or institution numbers |  |
| CP091 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then the system checks that IDV is not completed |  |
| CP092 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: "I must verify your identity for payment security. Please click here to get started" | I must verify your identity for payment security. Please click here to get started |
| CP093 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And the chatbot displays a button "Get verified" | Get verified |
| CP094 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When the user clicks on the button |  |
| CP095 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then the system checks if IDV at Payment |  |
| CP096 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the system checks if the user has consented to IDV |  |
| CP097 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP098 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP099 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP100 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: "Your identity has been verified successfully. Let's proceed to finalize your claim." | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP101 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: CAD 400 Payment Method: Interac e-Transfer (h***@gmail.com) After submission, you will receive a confirmation email summarizing your eligibility |
| CP102 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP103 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP104 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP105 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP106 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP107 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP108 | NOTIFICATION | email | email | And an eligible notification email is sent to h***@gmail.com |  |
| CP109 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (CAD 400), regulation (APPR), flight details (AC 444 YUL?YYZ CANCELLED), travel  |  |
| CP110 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No] | Is there anything I can help you with? |
| CP111 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP112 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "H�l�ne Bouchard" with PNR "TC083" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date should be populated |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "H�l�ne Bouchard" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC083" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "H�l�ne Bouchard" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "h***@gmail.com" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***678" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address, Profile ID and Tier Status should be populated |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" (CANCELLED) with claim filed for this flight |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Code should show "Cancellation Code FUEL (ANF) � fuel shortage � Controllable" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the travel status should show "No Travel � Origin" |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present with no expected ancillary fees |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should show "ELIGIBLE � CAD 400 (No Travel Origin, flat)" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS outcome should be "FD-APPR-EL-13" |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" (APPR, No Travel Origin, FUEL (ANF) controllable) |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "H�l�ne Bouchard + TC083 + YUL?YYZ + FD" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Persona IDV result should be "PASS" |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And a PS agent task for the refund should be visible on the case |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP165 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP166 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP167 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP168 | PAYMENT VALIDATION | payment | chat | And only the customer's email "h***@gmail.com" should be collected (no bank, card, transit or institution numbers) |  |
| CP169 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP170 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "CAD 400" as a flat No Travel Origin amount |  |
| CP171 | PAYMENT VALIDATION | payment | chat | And this is a No Travel case so both compensation and refund should be processed |  |
| CP172 | PAYMENT VALIDATION | payment | chat | And a PS agent task should be created in Claims Dashboard for the refund |  |
| CP173 | PAYMENT VALIDATION | payment | chat | And the agent should action the refund in ARD Web and mark it as refunded |  |
| CP174 | PAYMENT VALIDATION | payment | chat | And exactly one compensation record should be created in the backend with GL account and cost center |  |
| CP175 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP176 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP177 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP178 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received from Interac |  |
| CP179 | PAYMENT VALIDATION | payment | manual | And the status should be "Pending" transitioning to "Cashed" or "Rejected" or "Expired" |  |
| CP180 | PAYMENT VALIDATION | payment | manual | And if the payment is unclaimed after 35 days the status should be set to "Expired" |  |
| CP181 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show "CAD 400" with payment method "Cash" via "Interac" and status updated via talkback |  |
| CP182 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show a refund record with PS agent task status tracked separately |  |
| CP183 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-13. | DDS returns FD-APPR-EL-13. |
| CP184 | EXPECTED RESULTS | verdict | api | In Trip Tracer:  Flight = CANCELLED and MSL = Leg 1 (the cancelled leg). | In Trip Tracer:  Flight = CANCELLED and MSL = Leg 1 (the cancelled leg). |
| CP185 | EXPECTED RESULTS | verdict | chat | Cancellation code = FUEL (ANF), fuel shortage, controllable. | Cancellation code = FUEL (ANF), fuel shortage, controllable. |
| CP186 | EXPECTED RESULTS | verdict | chat | Fallback = FALSE. | Fallback = FALSE. |
| CP187 | EXPECTED RESULTS | verdict | chat | No Travel = TRUE, with No Travel status = Origin. | No Travel = TRUE, with No Travel status = Origin. |
| CP188 | EXPECTED RESULTS | verdict | api | Regime = APPR. | Regime = APPR. |
| CP189 | EXPECTED RESULTS | verdict | chat | The system must identify No Travel Origin when the single leg is cancelled and the customer didn't travel. | The system must identify No Travel Origin when the single leg is cancelled and the customer didn't travel. |
| CP190 | EXPECTED RESULTS | verdict | chat | Compensation is CAD 400 flat by Interac (email only), plus a refund through a PS agent task in ARD Web. | Compensation is CAD 400 flat by Interac (email only), plus a refund through a PS agent task in ARD Web. |
| CP191 | EXPECTED RESULTS | verdict | chat | CyberSource is GREEN and Persona is PASS. | CyberSource is GREEN and Persona is PASS. |
| CP192 | EXPECTED RESULTS | verdict | api | Claims Dashboard: No Travel = TRUE, Status = Origin, Flight = Cancelled, Code = FUEL (ANF), DDS = FD-APPR-EL-13. | Claims Dashboard: No Travel = TRUE, Status = Origin, Flight = Cancelled, Code = FUEL (ANF), DDS = FD-APPR-EL-13. |
