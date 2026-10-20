# FD_TC_023 · CHAI-31415 — checkpoints

**Goal:** Checks Tier 2 compensation for an Aeroplan Elite 25K member on a single domestic leg. The delay is 7 hours, with arrival delay code 99: the inbound aircraft was late because of an AC controllable issue upline. DDS should find the 6 to under 9 hour band (EL-02) and the APPR regime. The linked Elite 25K profile means both Cash (CAD 700) and AC Wallet (CAD 840 with the 20% top-up) are offered. The customer picks Cash, paid by Interac in Canada. Also checks CyberSource GREEN, Persona PASS, that only the email is collected, and that the Claims Dashboard shows the Elite 25K tier in a read-only resolved state with Unifier payout routing.

Methods: seed 14, chat 56, api 26, email 2, dashboard 43, implied 15, manual 17, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Checks Tier 2 compensation for an Aeroplan Elite 25K member on a single domestic leg. The delay is 7 hours, with arrival delay code 99: the  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR TC081: one passenger, Philippe Tremblay (Adult, Aeroplan Elite 25K 9876543210, active and in good standing) | PNR TC081: one passenger, Philippe Tremblay (Adult, Aeroplan Elite 25K 9876543210, active and in good standing) |
| CP003 | PREREQUISITES | prerequisite | seed | One AC domestic leg: AC 430 YUL ? YYZ, May 10, 2026 | One AC domestic leg: AC 430 YUL ? YYZ, May 10, 2026 |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival 10:00, actual 17:00 (7h, 6 to under 9 hour band) | Scheduled arrival 10:00, actual 17:00 (7h, 6 to under 9 hour band) |
| CP005 | PREREQUISITES | prerequisite | seed | Cancellation code: NONE | Cancellation code: NONE |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival delay code: 99 (upline, controllable), so Fallback = FALSE | Arrival delay code: 99 (upline, controllable), so Fallback = FALSE |
| CP007 | PREREQUISITES | prerequisite | seed | Upline cause: inbound AC 429 YYZ ? YUL arrived late for an AC controllable reason (not on the customer's PNR) | Upline cause: inbound AC 429 YYZ ? YUL arrived late for an AC controllable reason (not on the customer's PNR) |
| CP008 | PREREQUISITES | prerequisite | seed | No VOL or INVOL changes | No VOL or INVOL changes |
| CP009 | PREREQUISITES | prerequisite | seed | AC only | AC only |
| CP010 | PREREQUISITES | prerequisite | seed | Filed June 13, 2026 (D+34, more than 72 hours after arrival, within 366 days) | Filed June 13, 2026 (D+34, more than 72 hours after arrival, within 366 days) |
| CP011 | PREREQUISITES | prerequisite | seed | No duplicate | No duplicate |
| CP012 | PREREQUISITES | prerequisite | seed | Not an employee, not an infant | Not an employee, not an infant |
| CP013 | PREREQUISITES | prerequisite | implied | CyberSource set to GREEN | CyberSource set to GREEN |
| CP014 | PREREQUISITES | prerequisite | seed | Persona set to IDV PASS | Persona set to IDV PASS |
| CP015 | PREREQUISITES | prerequisite | seed | Country of residence: Canada (CAD) | Country of residence: Canada (CAD) |
| CP016 | PREREQUISITES | prerequisite | seed | Payment: Cash by Interac, email only | Payment: Cash by Interac, email only |
| CP017 | GREETING & INTENT IDENTIFICATION | customer | chat | Given the user opens the agentic chatbot |  |
| CP018 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP019 | GREETING & INTENT IDENTIFICATION | customer | chat | Then user selects "English" | English |
| CP020 | GREETING & INTENT IDENTIFICATION | alert | chat | Then an alert information is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI t | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP021 | GREETING & INTENT IDENTIFICATION | bot | chat | Then chatbot asks: "How can I help you today?" | How can I help you today? |
| CP022 | GREETING & INTENT IDENTIFICATION | customer | chat | And the user says: "My flight from Montreal to Toronto was delayed about 7 hours because the plane arrived late from its previous flight, I' | My flight from Montreal to Toronto was delayed about 7 hours because the plane arrived late from its previous flight, I'd like to check if I'm eligible for comp |
| CP023 | GREETING & INTENT IDENTIFICATION | system | implied | When the chatbot identifies flight disruption intent |  |
| CP024 | GREETING & INTENT IDENTIFICATION | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP025 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP026 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. Please provide your f |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Philippe Tremblay" | Philippe Tremblay |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, Philippe! And, what is your booking reference number?" | Thanks, Philippe! And, what is your booking reference number? |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "TC081" | TC081 |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC081 |  |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details, Aeroplan Elite 25K profile) is revealed to the customer |  |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: Email: p***@gmail.com / Phone: +1***234 |  |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: p***@gmail.com" | Email: p***@gmail.com |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP039 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP041 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | verdict | api | Then the system checks Trip Tracer for group booking identifier ? NOT PRESENT |  |
| CP042 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP043 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays: "I found 1 passenger on this booking: Philippe Tremblay (Adult - Aeroplan Elite 25K). Is this who you'd like to in | I found 1 passenger on this booking: Philippe Tremblay (Adult - Aeroplan Elite 25K). Is this who you'd like to include? |
| CP044 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP046 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 430 Route: Montreal (YUL) ? Toronto (YYZ) Date: May 10, 2026 Arrival Delay: 7 hours Is this the journey you'd like to  |
| CP047 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP049 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot sends request to Case Services for duplicate check ? NO existing case found |  |
| CP050 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks 72-hour rule: Arrival May 10, 2026; filing June 13, 2026 ? 34 days (>72 hours) ? PROCEED |  |
| CP051 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks APPR filing deadline: 34 days elapsed (within 366 days) ? PROCEED |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend for PNR TC081 |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | And DDS identifies MSL = AC 430 YUL?YYZ (only segment) |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the cancellation code on MSL ? NONE |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the first arrival delay code on MSL ? 99 (upline) ? no fallback needed |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS classifies 99 as CONTROLLABLE (upline � within carrier control) |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | And DDS calculates delay = 17:00 ? 10:00 = 7 hours ? band 6 to <9 hours ? Tier 2 |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS validates Aeroplan Elite 25K status as active and in good standing |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sets eligibility = CAD 700 Cash / CAD 840 AC Wallet |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | And DDS returns FD-APPR-EL-02 and sends results to Trip Tracer UI |  |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary: Flight AC 430, Route: YUL ? YYZ, Scheduled Arrival: 10:00 | Promised Itinerary: Flight AC 430, Route: YUL ? YYZ, Scheduled Arrival: 10:00 |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary: Flight AC 430, Route: YUL ? YYZ, Status: ARRIVED LATE, 10:00 ? 17:00, Delay: +7H 00M | Current Itinerary: Flight AC 430, Route: YUL ? YYZ, Status: ARRIVED LATE, 10:00 ? 17:00, Delay: +7H 00M |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | History: No booking changes (no VOL or INVOL) | History: No booking changes (no VOL or INVOL) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | MSL Flight: AC 430 � YUL ? YYZ � Code 99 � "Delayed due to upline controllable carrier issue" | MSL Flight: AC 430 � YUL ? YYZ � Code 99 � "Delayed due to upline controllable carrier issue" |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Cancellation code: NONE ; Fallback: FALSE | Cancellation code: NONE ; Fallback: FALSE |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Delay Classification: +7H 00M � CONTROLLABLE � DELAY_6_TO_LT_9_HOURS | Delay Classification: +7H 00M � CONTROLLABLE � DELAY_6_TO_LT_9_HOURS |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: 9876543210 (Elite 25K � linked) | Aeroplan: 9876543210 (Elite 25K � linked) |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | DDS outcome code: FD-APPR-EL-02 | DDS outcome code: FD-APPR-EL-02 |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | MR PHILIPPE TREMBLAY / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet (+20%) / [expiry date] | MR PHILIPPE TREMBLAY / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet (+20%) / [expiry date] |
| CP071 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource |  |
| CP072 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN LIGHT (Pass) |  |
| CP073 | ELIGIBLE RESULT DISPLAY (FD-05a) | bot | chat | Then the chatbot displays: "I've checked your flight details, and flight AC 430 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7  | I've checked your flight details, and flight AC 430 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7 hours. Based on the Air Passenger Protection Reg |
| CP074 | CLAIM PAYMENT & AEROPLAN OFFER | bot | chat | Then the chatbot asks: "Thank you for confirming. In which country will your reimbursement be deposited?" | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP075 | CLAIM PAYMENT & AEROPLAN OFFER | customer | chat | And the user selects "Canada" ? Currency = CAD | Canada |
| CP076 | CLAIM PAYMENT & AEROPLAN OFFER | system | implied | Then the chatbot checks Aeroplan status: Philippe Tremblay has linked Aeroplan 9876543210, Elite 25K in good standing |  |
| CP077 | CLAIM PAYMENT & AEROPLAN OFFER | bot | chat | And the chatbot offers BOTH options: | As an Aeroplan Elite 25K member, you can choose to receive: Cash: CAD 700 sent via Interac e-Transfer, which takes 5 to 10 business days to process. AC Wallet:  |
| CP078 | CLAIM PAYMENT & AEROPLAN OFFER | customer | chat | And the user selects "Cash" | Cash |
| CP079 | CLAIM PAYMENT & AEROPLAN OFFER | system | implied | Then the system checks which payment method is mapped based on country of residence ? Interac (CANADA) |  |
| CP080 | CLAIM PAYMENT & AEROPLAN OFFER | bot | chat | Then the chatbot responds: "Your payment will be made through Interac e-Transfer. Before we move forward, please confirm the email address w | Your payment will be made through Interac e-Transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP081 | CLAIM PAYMENT & AEROPLAN OFFER | customer | chat | And the user confirms: "Yes, use this email" | Yes, use this email |
| CP082 | CLAIM PAYMENT & AEROPLAN OFFER | system | implied | Then the chatbot does NOT ask for bank account, card, transit or institution numbers |  |
| CP083 | CLAIM PAYMENT & AEROPLAN OFFER | idv | chat | Then the system checks that IDV is not completed |  |
| CP084 | IDENTITY VERIFICATION | bot | chat | Then the chatbot responds: "I must verify your identity for payment security. Please click here to get started" | I must verify your identity for payment security. Please click here to get started |
| CP085 | IDENTITY VERIFICATION | bot | chat | And the chatbot displays a "Get verified" button | Get verified |
| CP086 | IDENTITY VERIFICATION | customer | chat | When the user clicks on the button |  |
| CP087 | IDENTITY VERIFICATION | idv | chat | Then the system checks IDV at Payment and consent |  |
| CP088 | IDENTITY VERIFICATION | idv | chat | And the customer completes Persona verification |  |
| CP089 | IDENTITY VERIFICATION | idv | chat | And Persona returns: IDV PASS |  |
| CP090 | IDENTITY VERIFICATION | bot | chat | Then the chatbot responds: "Your identity has been verified successfully. Let's proceed to finalize your claim." | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP091 | CLAIM CONFIRMATION & CASE CREATION (GLOB-09) | bot | chat | Then the chatbot displays: | Please review your compensation details: Deposit Amount: CAD 700 Payment Method: Interac e-Transfer (p***@gmail.com) After submission, you will receive a confir |
| CP092 | CLAIM CONFIRMATION & CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP093 | CLAIM CONFIRMATION & CASE CREATION (GLOB-09) | customer | chat | When the user confirms "Yes" | Yes |
| CP094 | CLAIM CONFIRMATION & CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP095 | CLAIM CONFIRMATION & CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP096 | CLAIM CONFIRMATION & CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP097 | NOTIFICATION & WRAP-UP (GLOB-11) | email | email | Then Adobe sends a notification email to p***@gmail.com |  |
| CP098 | NOTIFICATION & WRAP-UP (GLOB-11) | email | email | And the email contains: Case Reference, CAD 700 Cash (Interac e-Transfer), Aeroplan Elite 25K confirmation, regulation (APPR), flight detail |  |
| CP099 | NOTIFICATION & WRAP-UP (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No] | Is there anything I can help you with? |
| CP100 | NOTIFICATION & WRAP-UP (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP101 | NOTIFICATION & WRAP-UP (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP102 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Given the case has been created for claimant "Philippe Tremblay" with PNR "TC081" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Created date and Last Updated date should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP108 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the Team assignment should be correct |  |
| CP109 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP110 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP111 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Claimant Name should be "Philippe Tremblay" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the PNR should be "TC081" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated |  |
| CP116 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Full Name should be "Philippe Tremblay" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Tags should include "Claimant", "Adult", and "Elite 25K" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Email should be "p***@gmail.com" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Phone should be "+1***234" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Address and Profile ID should be populated |  |
| CP122 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Aeroplan should be "9876543210" linked and active |  |
| CP123 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Tier Status should be "Elite 25K / Member" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP125 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Disruption Code should show "Code 99 (upline) � Controllable" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Ancillary Fee section should be present and empty |  |
| CP127 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Eligibility and Compensation section should show "CAD 700 (Cash � Interac e-Transfer)" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the AC Wallet option (CAD 840 with 20% bonus) should be visible as the offered alternative but NOT selected |  |
| CP129 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP130 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP131 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the DDS outcome should be "FD-APPR-EL-02" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" (APPR, Code 99 Controllable, 7h delay, Tier 2) |  |
| CP133 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Philippe Tremblay + TC081 + YUL?YYZ + FD" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP136 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP137 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP138 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP139 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Persona IDV result should be "PASS" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP141 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP142 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP143 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP145 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP146 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP147 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP148 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP149 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP150 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP151 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP152 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP153 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP154 | PAYMENT VALIDATION (GLOB-11) | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP155 | PAYMENT VALIDATION (GLOB-11) | payment | chat | Then the currency should be set to "CAD" |  |
| CP156 | PAYMENT VALIDATION (GLOB-11) | payment | chat | And the customer has Aeroplan "9876543210" linked with Elite 25K status in good standing |  |
| CP157 | PAYMENT VALIDATION (GLOB-11) | payment | chat | And both options should have been offered: Cash (CAD 700 Interac) AND AC Wallet (CAD 840 with 20% top-up) |  |
| CP158 | PAYMENT VALIDATION (GLOB-11) | payment | chat | And the customer selected "Cash" ? Payment method = Interac e-Transfer |  |
| CP159 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And AC Wallet was offered but NOT selected ? AC Wallet payout NOT dispatched |  |
| CP160 | PAYMENT VALIDATION (GLOB-11) | payment | chat | And only the Interac email "p***@gmail.com" should be collected (no bank, card, transit or institution numbers) |  |
| CP161 | PAYMENT VALIDATION (GLOB-11) | payment | chat | And exactly one compensation record of CAD 700 should be created with GL account and cost center |  |
| CP162 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP163 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And Cash should be dispatched to Unifier |  |
| CP164 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And Unifier should send an acknowledgement back |  |
| CP165 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And the end-of-day report should be received from Interac |  |
| CP166 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And the status should be "Pending" transitioning to "Cashed" or "Rejected" or "Expired" |  |
| CP167 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And if the payment is unclaimed after 35 days the status should be set to "Expired" |  |
| CP168 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And the Claims Dashboard Compensation tab should show "CAD 700", payment method "Cash" via "Interac", and status updated via talkback |  |
| CP169 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-02. | DDS returns FD-APPR-EL-02. |
| CP170 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 10:00, Actual = 17:00, Delay = 7 hours, MSL = Leg 1, no cancellation code, arrival code 99 (upline, controllable), Fa | Trip Tracer: Promise = 10:00, Actual = 17:00, Delay = 7 hours, MSL = Leg 1, no cancellation code, arrival code 99 (upline, controllable), Fallback = FALSE, Regi |
| CP171 | EXPECTED RESULTS | verdict | chat | The linked Elite 25K profile gets both Cash (CAD 700) and AC Wallet (CAD 840). | The linked Elite 25K profile gets both Cash (CAD 700) and AC Wallet (CAD 840). |
| CP172 | EXPECTED RESULTS | verdict | chat | The customer picks Cash, and CAD 700 is paid by Interac to p***@gmail.com. | The customer picks Cash, and CAD 700 is paid by Interac to p***@gmail.com. |
| CP173 | EXPECTED RESULTS | verdict | chat | CyberSource GREEN, Persona PASS. | CyberSource GREEN, Persona PASS. |
| CP174 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Resolved/Done, Elite 25K, Code 99, CAD 700 Interac payout. | Claims Dashboard: Resolved/Done, Elite 25K, Code 99, CAD 700 Interac payout. |
