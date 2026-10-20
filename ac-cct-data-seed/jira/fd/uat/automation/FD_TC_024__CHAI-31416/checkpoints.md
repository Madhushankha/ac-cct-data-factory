# FD_TC_024 · CHAI-31416 — checkpoints

**Goal:** A 7-hour controllable delay on a single domestic leg (AC 431, YUL?YYZ) is in the APPR 6 to under 9 hour band. The cause is arrival delay code 17 (PC): AC sent a late or incorrect catering order to the supplier. The customer has an active Aeroplan Elite 25K profile, so the bot offers both payout options, and the customer picks AC Wallet. Checks that DDS classes code 17 as controllable and returns EL-02. Also checks the 20% top-up (CAD 700 base + CAD 140 = CAD 840 AC Wallet), Persona IDV PASS, CyberSource GREEN, routing to EIP ? iGiga ? iFly (not Unifier), and that the Claims Dashboard shows the Elite 25K tier with a read-only resolution.

Methods: seed 17, chat 61, api 25, email 3, dashboard 42, implied 13, manual 13, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | A 7-hour controllable delay on a single domestic leg (AC 431, YUL?YYZ) is in the APPR 6 to under 9 hour band. The cause is arrival delay cod |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR TC074: one passenger, Isabelle C�t� (Adult, claimant), Aeroplan Elite 25K, number 9876543210 | PNR TC074: one passenger, Isabelle C�t� (Adult, claimant), Aeroplan Elite 25K, number 9876543210 |
| CP003 | PREREQUISITES | prerequisite | seed | One AC domestic leg: AC 431 YUL?YYZ, May 10, 2026 | One AC domestic leg: AC 431 YUL?YYZ, May 10, 2026 |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival 10:00 | Scheduled arrival 10:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival 17:00 (7-hour delay, 6 to under 9 hour band) | Actual arrival 17:00 (7-hour delay, 6 to under 9 hour band) |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival delay code: 17 (PC, catering order, within carrier control) | Arrival delay code: 17 (PC, catering order, within carrier control) |
| CP007 | PREREQUISITES | prerequisite | seed | No cancellation code | No cancellation code |
| CP008 | PREREQUISITES | prerequisite | seed | Flight status: Arrived (operated) | Flight status: Arrived (operated) |
| CP009 | PREREQUISITES | prerequisite | seed | Booking changes: none (no VOL or INVOL) | Booking changes: none (no VOL or INVOL) |
| CP010 | PREREQUISITES | prerequisite | seed | Carrier: AC only | Carrier: AC only |
| CP011 | PREREQUISITES | prerequisite | seed | More than 72 hours have passed (filed D+34) | More than 72 hours have passed (filed D+34) |
| CP012 | PREREQUISITES | prerequisite | seed | Within 366 days | Within 366 days |
| CP013 | PREREQUISITES | prerequisite | seed | No duplicate case | No duplicate case |
| CP014 | PREREQUISITES | prerequisite | seed | Not an employee, not an infant | Not an employee, not an infant |
| CP015 | PREREQUISITES | prerequisite | seed | Aeroplan linked, Elite 25K active and in good standing (not frozen, Star Alliance Silver) | Aeroplan linked, Elite 25K active and in good standing (not frozen, Star Alliance Silver) |
| CP016 | PREREQUISITES | prerequisite | implied | CyberSource set to GREEN | CyberSource set to GREEN |
| CP017 | PREREQUISITES | prerequisite | seed | Persona set to IDV PASS | Persona set to IDV PASS |
| CP018 | PREREQUISITES | prerequisite | seed | Country of residence: Canada (CAD) | Country of residence: Canada (CAD) |
| CP019 | PREREQUISITES | prerequisite | seed | Payout selected: AC Wallet, CAD 840 | Payout selected: AC Wallet, CAD 840 |
| CP020 | GREETING & INTENT IDENTIFICATION | customer | chat | Given the user opens the agentic chatbot |  |
| CP021 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP022 | GREETING & INTENT IDENTIFICATION | customer | chat | Then user selects "English" | English |
| CP023 | GREETING & INTENT IDENTIFICATION | alert | chat | Then an alert information is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI t | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP024 | GREETING & INTENT IDENTIFICATION | bot | chat | Then chatbot asks: "How can I help you today?" | How can I help you today? |
| CP025 | GREETING & INTENT IDENTIFICATION | customer | chat | And the user says: "My flight was delayed about 7 hours because of a catering problem, I'd like to check if I'm eligible for compensation an | My flight was delayed about 7 hours because of a catering problem, I'd like to check if I'm eligible for compensation and I'd prefer to get it on my Aeroplan ac |
| CP026 | GREETING & INTENT IDENTIFICATION | system | implied | When the chatbot identifies flight disruption intent |  |
| CP027 | GREETING & INTENT IDENTIFICATION | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP028 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP029 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. Please provide your f |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Isabelle C�t�" | Isabelle C�t� |
| CP032 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, Isabelle! And, what is your booking reference number?" | Thanks, Isabelle! And, what is your booking reference number? |
| CP033 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "TC074" | TC074 |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC074 |  |
| CP035 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP036 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details, Aeroplan Elite 25K profile) is revealed to the customer |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: Email: i***@gmail.com / Phone: +1***345 |  |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: i***@gmail.com" | Email: i***@gmail.com |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP041 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP042 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP043 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Welcome back, Isabelle (Aeroplan Elite 25K). Let's proceed to the next step." | Your verification was successful. Welcome back, Isabelle (Aeroplan Elite 25K). Let's proceed to the next step. |
| CP044 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | verdict | api | Then the system checks Trip Tracer for group booking identifier ? NOT PRESENT |  |
| CP045 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP046 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays: "I found 1 passenger on this booking: Isabelle C�t� (Adult - Aeroplan Elite 25K). Is this who you'd like to includ | I found 1 passenger on this booking: Isabelle C�t� (Adult - Aeroplan Elite 25K). Is this who you'd like to include? |
| CP047 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP049 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 431 Route: Montreal (YUL) ? Toronto (YYZ) Date: May 10, 2026 Arrival Delay: 7 hours Is this the journey you'd like to  |
| CP050 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP051 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP052 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot sends request to Case Services for duplicate check ? NO existing case found |  |
| CP053 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks 72-hour rule: Arrival May 10, 2026; filing June 13, 2026 ? 34 days (>72 hours) ? PROCEED |  |
| CP054 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks APPR filing deadline: 34 days elapsed (within 366 days) ? PROCEED |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend for PNR TC074 / Claimant Isabelle C�t� |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the cancellation code on MSL ? NONE |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the first arrival delay code on MSL ? 17 (PC) |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS classifies 17 (PC) as WITHIN CARRIER CONTROL ? CONTROLLABLE |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS calculates delay = 7 hours ? band 6 to <9 hours ? Tier 2 |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | And DDS validates Aeroplan Elite 25K status as active |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sets base eligibility = CAD 700 cash; AC Wallet eligibility (+20%) = CAD 840 |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | And DDS returns FD-APPR-EL-02 and sends results to Trip Tracer UI |  |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary: Flight AC 431, Route: YUL ? YYZ, Scheduled Arrival: 10:00 | Promised Itinerary: Flight AC 431, Route: YUL ? YYZ, Scheduled Arrival: 10:00 |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary: Flight AC 431, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 10:00 ? Actual: 17:00, Delay: +7H 00M | Current Itinerary: Flight AC 431, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 10:00 ? Actual: 17:00, Delay: +7H 00M |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | MSL Flight: AC 431 � YUL ? YYZ � Code 17 (PC) � "Catering order � late or incorrect order given to supplier" | MSL Flight: AC 431 � YUL ? YYZ � Code 17 (PC) � "Catering order � late or incorrect order given to supplier" |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Cancellation code: NONE ; Fallback: FALSE (arrival delay code available) | Cancellation code: NONE ; Fallback: FALSE (arrival delay code available) |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | APPR causal category: Within carrier control ? CONTROLLABLE | APPR causal category: Within carrier control ? CONTROLLABLE |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | Delay Classification: +7H 00M � CONTROLLABLE � DELAY_6_TO_LT_9_HOURS | Delay Classification: +7H 00M � CONTROLLABLE � DELAY_6_TO_LT_9_HOURS |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: 9876543210 (Elite 25K � linked, active, Star Alliance Silver) | Aeroplan: 9876543210 (Elite 25K � linked, active, Star Alliance Silver) |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | DDS outcome code: FD-APPR-EL-02 | DDS outcome code: FD-APPR-EL-02 |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | MS ISABELLE C�T� / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 840.00 (Wallet) / [expiry date] | MS ISABELLE C�T� / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 840.00 (Wallet) / [expiry date] |
| CP073 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource |  |
| CP074 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN LIGHT (Pass) |  |
| CP075 | ELIGIBLE RESULT DISPLAY (FD-05a) | bot | chat | Then the chatbot displays: "I've checked your flight details, and flight AC 431 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7  | I've checked your flight details, and flight AC 431 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7 hours. Based on the Air Passenger Protection Reg |
| CP076 | CLAIM PAYMENT & AC WALLET SELECTION | bot | chat | Then the chatbot asks: "In which country will your reimbursement be deposited?" | In which country will your reimbursement be deposited? |
| CP077 | CLAIM PAYMENT & AC WALLET SELECTION | customer | chat | And the user selects "Canada" ? Currency = CAD | Canada |
| CP078 | CLAIM PAYMENT & AC WALLET SELECTION | system | implied | Then the chatbot checks Aeroplan status: Isabelle C�t� has linked Aeroplan 9876543210, Elite 25K in good standing |  |
| CP079 | CLAIM PAYMENT & AC WALLET SELECTION | bot | chat | And the chatbot offers BOTH options: | As an Aeroplan Elite 25K member, you can choose to either receive: Cash: CAD 700 will be compensated by Interac e-Transfer and takes 5 to 10 business days to pr |
| CP080 | CLAIM PAYMENT & AC WALLET SELECTION | customer | chat | And the user selects "AC Wallet" | AC Wallet |
| CP081 | CLAIM PAYMENT & AC WALLET SELECTION | system | implied | Then the chatbot does NOT ask for an Interac email, bank account, card or any other payment details |  |
| CP082 | IDENTITY VERIFICATION | bot | chat | Then the chatbot displays "Get verified" button | Get verified |
| CP083 | IDENTITY VERIFICATION | idv | chat | And the user completes Persona IDV |  |
| CP084 | IDENTITY VERIFICATION | idv | chat | And Persona returns: IDV PASS |  |
| CP085 | CLAIM AMOUNT CONFIRMATION | bot | chat | Then the chatbot responds: "Thank you. Here is a summary of your compensation: | Deposit Amount: CAD 840 Payment Method: AC Wallet (Aeroplan #: 9876543210) Would you like me to submit your claim?" |
| CP086 | CLAIM AMOUNT CONFIRMATION | alert | chat | And an alert information is displayed: "Please note that payment details cannot be changed after submission." | Please note that payment details cannot be changed after submission. |
| CP087 | CLAIM AMOUNT CONFIRMATION | customer | chat | When the user clicks on "Yes" | Yes |
| CP088 | CASE CREATION & NOTIFICATION | email | email | Then the chatbot responds: "Thank you. Your claim has been submitted and will be processed within 10 business days. A confirmation email wil | Thank you. Your claim has been submitted and will be processed within 10 business days. A confirmation email will be sent to you with details on how to monitor  |
| CP089 | CASE CREATION & NOTIFICATION | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP090 | CASE CREATION & NOTIFICATION | email | email | And the system triggers notification via Adobe to i***@gmail.com |  |
| CP091 | CASE CREATION & NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (CAD 840 AC Wallet), Aeroplan Elite 25K confirmation (9876543210), regulation (A |  |
| CP092 | CASE CREATION & NOTIFICATION | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No] | Is there anything I can help you with? |
| CP093 | CASE CREATION & NOTIFICATION | customer | chat | And the user selects "No" | No |
| CP094 | CASE CREATION & NOTIFICATION | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Isabelle C�t�" with PNR "TC074" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date should be populated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Isabelle C�t�" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC074" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Isabelle C�t�" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant", "Adult", and "Elite 25K" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "i***@gmail.com" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***345" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address and Profile ID should be populated |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "9876543210" linked and active |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be "Elite 25K / Member" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Code should show "Code 17 (PC � Catering order) � Controllable" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present and empty |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should show "CAD 840 (AC Wallet � 20% Top-up Applied)" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS outcome should be "FD-APPR-EL-02" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" (APPR, Tier 2: 6 to <9 hrs, Code 17 Controllable, AC Wallet) |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Isabelle C�t� + TC074 + YUL?YYZ + FD" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Persona IDV result should be "PASS" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP146 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP147 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP148 | PAYMENT VALIDATION | payment | chat | And the customer has Aeroplan "9876543210" linked with Elite 25K status in good standing |  |
| CP149 | PAYMENT VALIDATION | payment | chat | And both options should be offered: Cash at CAD 700 by Interac and AC Wallet at CAD 840 with 20% top-up |  |
| CP150 | PAYMENT VALIDATION | payment | chat | And the customer selects "AC Wallet" |  |
| CP151 | PAYMENT VALIDATION | payment | chat | And no Interac email or other payment details should have been collected |  |
| CP152 | PAYMENT VALIDATION | payment | chat | And the 20% top-up should be applied converting CAD 700 to CAD 840 |  |
| CP153 | PAYMENT VALIDATION | payment | chat | And AC Wallet should be offered because this is a flight disruption under APPR |  |
| CP154 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created for CAD 840 |  |
| CP155 | PAYMENT VALIDATION | payment | manual | And the record should be picked up by the daily evening batch file |  |
| CP156 | PAYMENT VALIDATION | payment | manual | And the record should be dispatched to EIP and NOT Unifier |  |
| CP157 | PAYMENT VALIDATION | payment | chat | And EIP should convert from CAD to the customer's Aeroplan profile country currency if applicable |  |
| CP158 | PAYMENT VALIDATION | payment | chat | And EIP should check Aeroplan account validity confirming it is active and not frozen |  |
| CP159 | PAYMENT VALIDATION | payment | chat | And EIP should send to iGiga |  |
| CP160 | PAYMENT VALIDATION | payment | chat | And iGiga should send to iFly for deposit |  |
| CP161 | PAYMENT VALIDATION | payment | chat | And iFly should talk back to EIP |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And EIP should talk back to Claims Dashboard with deposited amount (CAD 840), exchange rate, and status |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And if the Aeroplan account is frozen or closed a rejection with error message should be returned, a failure notification should be sent to  |  |
| CP164 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the EIP team |  |
| CP165 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show "CAD 840" |  |
| CP166 | PAYMENT VALIDATION | payment | chat | And the payment method should show "AC Wallet" |  |
| CP167 | PAYMENT VALIDATION | payment | manual | And the status should be updated via talkback |  |
| CP168 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-02. | DDS returns FD-APPR-EL-02. |
| CP169 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promised = 10:00, Actual = 17:00, Delay = 7 hours, MSL = Leg 1, arrival delay code 17 (PC, catering order, within carrier contr | Trip Tracer: Promised = 10:00, Actual = 17:00, Delay = 7 hours, MSL = Leg 1, arrival delay code 17 (PC, catering order, within carrier control), Fallback = FALS |
| CP170 | EXPECTED RESULTS | verdict | chat | Aeroplan: Elite 25K linked and active. | Aeroplan: Elite 25K linked and active. |
| CP171 | EXPECTED RESULTS | verdict | chat | Compensation: CAD 840 by AC Wallet (CAD 700 base + 20% top-up of CAD 140). | Compensation: CAD 840 by AC Wallet (CAD 700 base + 20% top-up of CAD 140). |
| CP172 | EXPECTED RESULTS | verdict | chat | EIP check: account active, deposit successful through iGiga/iFly. | EIP check: account active, deposit successful through iGiga/iFly. |
| CP173 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP174 | EXPECTED RESULTS | verdict | chat | Persona: PASS. | Persona: PASS. |
| CP175 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Resolved/Done, read-only, Elite 25K tier populated, Code 17, CAD 840 AC Wallet credited to Aeroplan 9876543210. | Claims Dashboard: Resolved/Done, read-only, Elite 25K tier populated, Code 17, CAD 840 AC Wallet credited to Aeroplan 9876543210. |
