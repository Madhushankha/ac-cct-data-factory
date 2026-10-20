# FD_TC_030 · CHAI-31422 — checkpoints

**Goal:** Validates an end-to-end eligible flight disruption claim scenario for a multi-passenger family/group booking of 6 passengers where the primary claimant is an active Aeroplan member. Flight AC 434 (YUL?YYZ) is delayed 10 hours (APPR Tier 3: 9+ hrs band) due to a controllable reason (Code 15 / Code 42 - Scheduled Maintenance / Technical Delay). The primary claimant selects AC Wallet payout for all 6 passengers. Validates the 20% top-up calculation at the highest compensation band: base $1,000 CAD + 20% = $1,200 CAD per passenger, totaling $7,200 CAD AC Wallet ($6,000 CAD base equivalent). Confirms that DDS returns EL-03, CyberSource passes GREEN, Persona IDV passes, the payment record routes to EIP/iFly rather than Unifier, and Claims Dashboard reflects 6 passengers in read-only resolved state with AC Wallet payout.

Methods: seed 16, chat 49, api 20, email 1, dashboard 46, implied 11, manual 13, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates an end-to-end eligible flight disruption claim scenario for a multi-passenger family/group booking of 6 passengers where the prima |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC022 � 6 passengers: Nathalie Fortin (Adult - Primary Claimant, Aeroplan Member 1234567890), Marc Fortin (Adult), Eric Fortin (Adult), | PNR: TC022 � 6 passengers: Nathalie Fortin (Adult - Primary Claimant, Aeroplan Member 1234567890), Marc Fortin (Adult), Eric Fortin (Adult), Julie Fortin (Adult |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC domestic YUL?YYZ (Flight AC 434) | Journey: 1 leg AC domestic YUL?YYZ (Flight AC 434) |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 08:00 | Scheduled arrival: 08:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival: 18:00 (10hr delay � Delay band: 9+ hours) | Actual arrival: 18:00 (10hr delay � Delay band: 9+ hours) |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival delay code: 15 / 42 (Scheduled Maintenance / Controllable) | Arrival delay code: 15 / 42 (Scheduled Maintenance / Controllable) |
| CP007 | PREREQUISITES | prerequisite | seed | Flight status: Arrived (operated) | Flight status: Arrived (operated) |
| CP008 | PREREQUISITES | prerequisite | seed | Booking changes: None � no VOL or INVOL | Booking changes: None � no VOL or INVOL |
| CP009 | PREREQUISITES | prerequisite | seed | Carrier: AC only | Carrier: AC only |
| CP010 | PREREQUISITES | prerequisite | seed | 72hrs: Elapsed (filed D+38) | 72hrs: Elapsed (filed D+38) |
| CP011 | PREREQUISITES | prerequisite | seed | Time limit: Within 366 days | Time limit: Within 366 days |
| CP012 | PREREQUISITES | prerequisite | seed | No duplicate case | No duplicate case |
| CP013 | PREREQUISITES | prerequisite | seed | Not employee, not infant | Not employee, not infant |
| CP014 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked (1234567890), account active and in good standing (NOT frozen) | Aeroplan: Linked (1234567890), account active and in good standing (NOT frozen) |
| CP015 | PREREQUISITES | prerequisite | implied | CyberSource: Configured to return GREEN | CyberSource: Configured to return GREEN |
| CP016 | PREREQUISITES | prerequisite | seed | Persona: Configured to return IDV PASS | Persona: Configured to return IDV PASS |
| CP017 | PREREQUISITES | prerequisite | seed | Country of residence: Canada (CAD) | Country of residence: Canada (CAD) |
| CP018 | PREREQUISITES | prerequisite | seed | Payment: AC Wallet selected for all 6 passengers | Payment: AC Wallet selected for all 6 passengers |
| CP019 | GREETING & INTENT IDENTIFICATION | customer | chat | Given the user opens the agentic chatbot |  |
| CP020 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP021 | GREETING & INTENT IDENTIFICATION | customer | chat | Then user selects "English" | English |
| CP022 | GREETING & INTENT IDENTIFICATION | alert | chat | Then an alert information is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI t | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP023 | GREETING & INTENT IDENTIFICATION | bot | chat | Then chatbot asks: "How can I help you today?" | How can I help you today? |
| CP024 | GREETING & INTENT IDENTIFICATION | customer | chat | And the user says: "My flight was delayed about 10 hours, I'd like to check if our booking of 6 is eligible for compensation and I'd prefer  | My flight was delayed about 10 hours, I'd like to check if our booking of 6 is eligible for compensation and I'd prefer to get it on my Aeroplan account |
| CP025 | GREETING & INTENT IDENTIFICATION | system | implied | When the chatbot identifies flight disruption intent |  |
| CP026 | GREETING & INTENT IDENTIFICATION | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP027 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP028 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. Please provide your f |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Nathalie Fortin" | Nathalie Fortin |
| CP031 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, Nathalie! And, what is your booking reference number?" | Thanks, Nathalie! And, what is your booking reference number? |
| CP032 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "TC022" | TC022 |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC022 |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP035 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is retrieved |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | * Email: n***@outlook.com * Phone: +1678 |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: n@outlook.com" | Email: n@outlook.com |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP040 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides OTP code "739281" | 739281 |
| CP041 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP042 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP043 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP044 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | system | implied | And group booking identifier = NOT PRESENT |  |
| CP045 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP046 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR TC022: | I found 6 passengers on this booking: 1. Nathalie Fortin (Adult - Aeroplan Member) 2. Marc Fortin (Adult) 3. Eric Fortin (Adult) 4. Julie Fortin (Adult) 5. Luca |
| CP047 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes, include all 6 passengers" | Yes, include all 6 passengers |
| CP048 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 6 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP049 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: * Flight: AC 434 * Route: Montreal (YUL) ? Toronto (YYZ) * Date: May 8, 2026 * Arrival Delay: 10 hours Is this the journey you'd  |
| CP050 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP051 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP052 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot sends request to Case Services for duplicate check ? NO existing case found for any of the 6 passengers on this journey |  |
| CP053 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks 72-hour rule: Arrival May 8, 2026; filing June 15, 2026 ? 38 days (>72 hours) ? PROCEED |  |
| CP054 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks APPR filing deadline: 38 days elapsed (within 366 days) ? PROCEED |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | Backend DDS executes evaluation for PNR TC022 covering all 6 passengers: | � Regime: APPR Applicable � Delay reason: Code 15 / 42 (Maintenance / Technical � Controllable) � Delay duration: 10 hours (Band: 9+ hours ? Tier 3) � Base Elig |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | [x] Promised Itinerary: Flight AC 434, YUL ? YYZ, Scheduled Arrival: 08:00 | [x] Promised Itinerary: Flight AC 434, YUL ? YYZ, Scheduled Arrival: 08:00 |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | [x] Current Itinerary: Flight AC 434, YUL ? YYZ, Status: ARRIVED LATE, Scheduled: 08:00 ? Actual: 18:00, Delay: +10H 00M | [x] Current Itinerary: Flight AC 434, YUL ? YYZ, Status: ARRIVED LATE, Scheduled: 08:00 ? Actual: 18:00, Delay: +10H 00M |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | [x] Regime: APPR (1 regime) | [x] Regime: APPR (1 regime) |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | [x] MSL Flight: AC 434 � YUL ? YYZ � Code 15 / 42 ("Delayed due to scheduled maintenance / technical") | [x] MSL Flight: AC 434 � YUL ? YYZ � Code 15 / 42 ("Delayed due to scheduled maintenance / technical") |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | [x] Delay Classification: +10H 00M � CONTROLLABLE | [x] Delay Classification: +10H 00M � CONTROLLABLE |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | [x] Aeroplan: 1234567890 (Nathalie Fortin � linked, active, good standing) | [x] Aeroplan: 1234567890 (Nathalie Fortin � linked, active, good standing) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | MS NATHALIE FORTIN / ELIGIBLE / DELAY_GTE_9_HOURS / CAD 1,000.00 Cash / CAD 1,200.00 AC Wallet | MS NATHALIE FORTIN / ELIGIBLE / DELAY_GTE_9_HOURS / CAD 1,000.00 Cash / CAD 1,200.00 AC Wallet |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | MR MARC FORTIN / ELIGIBLE / DELAY_GTE_9_HOURS / CAD 1,000.00 Cash / CAD 1,200.00 AC Wallet | MR MARC FORTIN / ELIGIBLE / DELAY_GTE_9_HOURS / CAD 1,000.00 Cash / CAD 1,200.00 AC Wallet |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | MR ERIC FORTIN / ELIGIBLE / DELAY_GTE_9_HOURS / CAD 1,000.00 Cash / CAD 1,200.00 AC Wallet | MR ERIC FORTIN / ELIGIBLE / DELAY_GTE_9_HOURS / CAD 1,000.00 Cash / CAD 1,200.00 AC Wallet |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | MS JULIE FORTIN / ELIGIBLE / DELAY_GTE_9_HOURS / CAD 1,000.00 Cash / CAD 1,200.00 AC Wallet | MS JULIE FORTIN / ELIGIBLE / DELAY_GTE_9_HOURS / CAD 1,000.00 Cash / CAD 1,200.00 AC Wallet |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | MSTR LUCAS FORTIN / ELIGIBLE / DELAY_GTE_9_HOURS / CAD 1,000.00 Cash / CAD 1,200.00 AC Wallet | MSTR LUCAS FORTIN / ELIGIBLE / DELAY_GTE_9_HOURS / CAD 1,000.00 Cash / CAD 1,200.00 AC Wallet |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | MISS EMMA FORTIN / ELIGIBLE / DELAY_GTE_9_HOURS / CAD 1,000.00 Cash / CAD 1,200.00 AC Wallet | MISS EMMA FORTIN / ELIGIBLE / DELAY_GTE_9_HOURS / CAD 1,000.00 Cash / CAD 1,200.00 AC Wallet |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Total Compensation: CAD 6,000.00 Cash / CAD 7,200.00 AC Wallet | Total Compensation: CAD 6,000.00 Cash / CAD 7,200.00 AC Wallet |
| CP069 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Chatbot sends case details to CyberSource ? Returns GREEN LIGHT (Pass) |  |
| CP070 | ELIGIBLE RESULT DISPLAY (FD-05a) | bot | chat | Chatbot displays: "I've checked your flight details, and flight AC 434 from Montreal (YUL) to Toronto (YYZ) was delayed by about 10 hours du | I've checked your flight details, and flight AC 434 from Montreal (YUL) to Toronto (YYZ) was delayed by about 10 hours due to maintenance constraints (Controlla |
| CP071 | CLAIM PAYMENT & AEROPLAN AC WALLET SELECTION | bot | chat | Chatbot asks: "In which country will your reimbursement be deposited?" | In which country will your reimbursement be deposited? |
| CP072 | IDENTITY VERIFICATION | bot | chat | Chatbot displays "Get verified" button ? User completes Persona IDV ? Persona returns IDV PASS | Get verified |
| CP073 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Chatbot responds: "Please review your compensation details: | Total Base Amount: $6,000 CAD Top-Up Bonus (20%): $1,200 CAD Total Deposit Amount: $7,200 CAD Payment Method: AC Wallet (Aeroplan #: 1234567890) Would you like  |
| CP074 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that payment details cannot be changed after submission." | Please note that payment details cannot be changed after submission. |
| CP075 | CASE CREATION & NOTIFICATION | email | email | Chatbot responds: "Thank you. Your claim has been submitted and will be processed within 10 business days. A confirmation email will be sent | Thank you. Your claim has been submitted and will be processed within 10 business days. A confirmation email will be sent to you with details on how to monitor  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Nathalie Fortin" with PNR "TC022" covering 6 passengers |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Nathalie Fortin" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC022" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Nathalie Fortin" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "n***@outlook.com" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***678" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "1234567890" linked and active |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And all 6 passengers should be listed on the case (Nathalie, Marc, Eric, Julie, Lucas, Emma Fortin) |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present and empty |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should show "$7,200 CAD (AC Wallet � 20% Top-up Applied)" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" (APPR, Tier 3: 9+ hrs, 6 Pax, AC Wallet) |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically across all 6 passengers |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Payment Validation Gherkin: |
| CP130 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP131 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And the customer has Aeroplan "1234567890" linked and in good standing |  |
| CP133 | PAYMENT VALIDATION | payment | chat | And both options should be offered: Cash at $6,000 CAD and AC Wallet at $7,200 CAD with 20% top-up for 6 passengers |  |
| CP134 | PAYMENT VALIDATION | payment | chat | And the customer selects "AC Wallet" |  |
| CP135 | PAYMENT VALIDATION | payment | chat | And the 20% top-up should be applied converting $1,000 to $1,200 per passenger ($7,200 CAD total) |  |
| CP136 | PAYMENT VALIDATION | payment | chat | And AC Wallet should be offered because this is flight disruption APPR |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created for $7,200 CAD |  |
| CP138 | PAYMENT VALIDATION | payment | manual | And the record should be picked up by the daily evening batch file |  |
| CP139 | PAYMENT VALIDATION | payment | manual | And the record should be dispatched to EIP and NOT Unifier |  |
| CP140 | PAYMENT VALIDATION | payment | chat | And EIP should convert from CAD to the customer's Aeroplan profile country currency if applicable |  |
| CP141 | PAYMENT VALIDATION | payment | chat | And EIP should check Aeroplan account validity confirming it is active and not frozen |  |
| CP142 | PAYMENT VALIDATION | payment | chat | And EIP should send to iGiga |  |
| CP143 | PAYMENT VALIDATION | payment | chat | And iGiga should send to iFly for deposit |  |
| CP144 | PAYMENT VALIDATION | payment | chat | And iFly should talk back to EIP |  |
| CP145 | PAYMENT VALIDATION | payment | chat | And EIP should talk back to Claims Dashboard with deposited amount, exchange rate, and status |  |
| CP146 | PAYMENT VALIDATION | payment | chat | And if the Aeroplan account is frozen or closed a rejection with error message should be returned and a failure notification should be sent  |  |
| CP147 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the EIP team |  |
| CP148 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show "$7,200 CAD" |  |
| CP149 | PAYMENT VALIDATION | payment | chat | And the payment method should show "AC Wallet" |  |
| CP150 | PAYMENT VALIDATION | payment | manual | And the status should be updated via talkback |  |
| CP151 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-03 for 6 passengers. | DDS returns FD-APPR-EL-03 for 6 passengers. |
| CP152 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 08:00; Actual = 18:00; Delay = 10hrs; MSL = Leg 1; Code 15 / 42; Controllable; APPR. | Trip Tracer: Promise = 08:00; Actual = 18:00; Delay = 10hrs; MSL = Leg 1; Code 15 / 42; Controllable; APPR. |
| CP153 | EXPECTED RESULTS | verdict | chat | Compensation: $7,200 CAD via AC Wallet ($6,000 base for 6 pax + 20% top-up of $1,200). | Compensation: $7,200 CAD via AC Wallet ($6,000 base for 6 pax + 20% top-up of $1,200). |
| CP154 | EXPECTED RESULTS | verdict | chat | Aeroplan check: Account active, deposit dispatched to EIP/iFly. | Aeroplan check: Account active, deposit dispatched to EIP/iFly. |
| CP155 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP156 | EXPECTED RESULTS | verdict | chat | Persona: PASS. | Persona: PASS. |
| CP157 | EXPECTED RESULTS | verdict | dashboard | Claims Dashboard: Case created in Resolved/Done status with read-only summary, 6 passengers listed, $7,200 CAD AC Wallet credited to Aeropla | Claims Dashboard: Case created in Resolved/Done status with read-only summary, 6 passengers listed, $7,200 CAD AC Wallet credited to Aeroplan 1234567890. |
