# FD_TC_109 · CHAI-31501 — checkpoints

**Goal:** UK-originating flight (London Heathrow LHR ? Toronto YYZ) delayed 3 hours 30 minutes due to Code 67 (Crew Transport / Hotel / Logistics Delay � Controllable). EU 261 (UK retained law) applies based on UK departure origin. Passenger is a Portuguese national (Diogo Silva) holding an active Aeroplan Elite 25K membership linked to the booking. Validates: (1) UK origin correctly triggers EU 261 (UK) regime, (2) Code 67 evaluated as Controllable, (3) UK long-haul Tier 1 compensation rate (�260 GBP cash) calculated, (4) Linked Aeroplan Elite 25K status triggers BOTH Cash (�260 GBP) and AC Wallet (�312 GBP with 20% bonus) payment options, (5) AC Wallet payment rail executes successfully via EIP / iGiga / iFly.

Methods: seed 12, chat 63, api 22, email 3, dashboard 46, implied 26, manual 11, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | UK-originating flight (London Heathrow LHR ? Toronto YYZ) delayed 3 hours 30 minutes due to Code 67 (Crew Transport / Hotel / Logistics Dela |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC066 � single passenger Diogo Silva (Adult - Aeroplan Elite 25K Member) | PNR: TC066 � single passenger Diogo Silva (Adult - Aeroplan Elite 25K Member) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 858, LHR?YYZ | Journey: 1 leg AC operated, Flight AC 858, LHR?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 16:00 | Scheduled arrival: 16:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival: 19:30 (3hr 30min delay, 210 min) | Actual arrival: 19:30 (3hr 30min delay, 210 min) |
| CP006 | PREREQUISITES | prerequisite | seed | Disruption code: 67 (Crew Transport / Hotel / Logistics Delay � Controllable) | Disruption code: 67 (Crew Transport / Hotel / Logistics Delay � Controllable) |
| CP007 | PREREQUISITES | prerequisite | seed | Arrival code: 67 (available, no fallback) | Arrival code: 67 (available, no fallback) |
| CP008 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (UK) � UK origin (LHR) | Regime: EU 261 (UK) � UK origin (LHR) |
| CP009 | PREREQUISITES | prerequisite | seed | Booking changes: None | Booking changes: None |
| CP010 | PREREQUISITES | prerequisite | seed | Timing: >72hrs elapsed | Timing: >72hrs elapsed |
| CP011 | PREREQUISITES | prerequisite | seed | Filing: Within limitation | Filing: Within limitation |
| CP012 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked (9876543210), Elite 25K in good standing | Aeroplan: Linked (9876543210), Elite 25K in good standing |
| CP013 | PREREQUISITES | prerequisite | seed | Residence: UK / Portugal ? Currency = GBP | Residence: UK / Portugal ? Currency = GBP |
| CP014 | PREREQUISITES | prerequisite | implied | CyberSource: GREEN | CyberSource: GREEN |
| CP015 | PREREQUISITES | prerequisite | implied | RDS: No flags | RDS: No flags |
| CP016 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP017 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP018 | START | customer | chat | Then user selects English |  |
| CP019 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP020 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP021 | START | customer | chat | And the user says "My flight from London Heathrow to Toronto was delayed about 3 and a half hours due to crew transport delays, I'd like to  | My flight from London Heathrow to Toronto was delayed about 3 and a half hours due to crew transport delays, I'd like to check if I'm eligible for compensation |
| CP022 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP023 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP024 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP025 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Diogo Silva" | Diogo Silva |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Diogo! And, what is your booking reference number? |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC066" | PNR: TC066 |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC066 |  |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: d***@gmail.com � Phone: +351***123 |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: d***@gmail.com" | Email: d***@gmail.com |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP039 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP041 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP042 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP043 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP044 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP045 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Diogo Silva (Adult - Aeroplan Elite 25K) Is this who you'd like to include? |
| CP046 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP047 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP048 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 858 � Route: London Heathrow (LHR) ? Toronto (YYZ) � Date: May 20, 2026 � Arrival Delay: 3 hours 30 minutes Is this  |
| CP049 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP050 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP052 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP053 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP054 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 20, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP055 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 = varies by jurisdiction (UK: 6 years) |  |
| CP056 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 20, 2026; filing June 15, 2026 ? 26 days ? within limitation ? PROCEED |  |
| CP057 | REGIME DETERMINATION | verdict | api | Then the system determines applicable regime: |  |
| CP058 | REGIME DETERMINATION | system | implied | And the system checks: Origin airport = LHR (London Heathrow, UK) |  |
| CP059 | REGIME DETERMINATION | system | implied | And the system checks: Operating carrier = AC (Air Canada) |  |
| CP060 | REGIME DETERMINATION | system | implied | And the system determines: EU 261 (UK) applies � UK-originating flight |  |
| CP061 | REGIME DETERMINATION | system | implied | And the system checks: Origin region = UK ? UK tier structure applies |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP063 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 858, Route: LHR ? YYZ, Scheduled Arrival: 16:00 (local YYZ time) | Promised Itinerary - Flight: AC 858, Route: LHR ? YYZ, Scheduled Arrival: 16:00 (local YYZ time) |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 858, Route: LHR ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 16:00 ? Actual: 19:30, Delay: +3H 30M | Current Itinerary - Flight: AC 858, Route: LHR ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 16:00 ? Actual: 19:30, Delay: +3H 30M |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Regime: EU 261 (UK) (UK origin � LHR) | Regime: EU 261 (UK) (UK origin � LHR) |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Origin Region: LHR = UK | Origin Region: LHR = UK |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 858 � LHR ? YYZ � 67 | MSL FLIGHT: AC 858 � LHR ? YYZ � 67 |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to crew transport / hotel logistics" | "Delayed due to crew transport / hotel logistics" |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +3H 30M � CONTROLLABLE | Delay: +3H 30M � CONTROLLABLE |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | EU 261 UK Tier: Long-haul 3�<4 hrs ? UK Tier 1 (�260 GBP) | EU 261 UK Tier: Long-haul 3�<4 hrs ? UK Tier 1 (�260 GBP) |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | Sister City: FALSE | Sister City: FALSE |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE | Fallback: FALSE |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | MR DIOGO SILVA / ELIGIBLE / EU261_UK_DELAY_3_TO_LT_4_HOURS_LONG_HAUL / GBP �312.00 (Wallet) / GBP �260.00 (Cash) / [expiry date] | MR DIOGO SILVA / ELIGIBLE / EU261_UK_DELAY_3_TO_LT_4_HOURS_LONG_HAUL / GBP �312.00 (Wallet) / GBP �260.00 (Cash) / [expiry date] |
| CP075 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP076 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP077 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP078 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 858 from London Heathrow (LHR) to Toronto (YYZ) was delayed by about 3 hours and 30 minutes due to |
| CP079 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP080 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "United Kingdom" | United Kingdom |
| CP081 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = UK ? Currency = GBP |  |
| CP082 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (Aeroplan #: 9876543210, Status: Elite 25K) |  |
| CP083 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Aeroplan account in good standing? ? YES |  |
| CP084 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot offers BOTH options: | Since you are an Aeroplan Elite 25K member, you can choose to receive: � Cash: �260 GBP will be compensated and takes 5 to 10 business days to process. � AC Wal |
| CP085 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And the user selects "AC Wallet" | AC Wallet |
| CP086 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP087 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP088 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP089 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP090 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP091 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP092 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP093 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP094 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP095 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP096 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �312 GBP Payment Method: AC Wallet (Aeroplan #: 9876543210) After submission, you will receive a confirmation email summarizing your eligibility |
| CP097 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that payment details cannot be changed after submission." | Please note that payment details cannot be changed after submission. |
| CP098 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP099 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 10 business days. Please chec | Thank you. Your claim has been submitted and will now be processed within the next 10 business days. Please check your email for a confirmation email summarizin |
| CP100 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP101 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP102 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP103 | NOTIFICATION | email | email | And an eligible notification email is sent to d***@gmail.com |  |
| CP104 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�312 GBP AC Wallet), Aeroplan confirmation, regulation (EU 261 UK), flight deta |  |
| CP105 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP106 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP107 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Diogo Silva" with PNR "TC066" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Diogo Silva" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC066" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (UK)" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Diogo Silva" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "d***@gmail.com" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+351***123" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "9876543210" linked and in good standing (Elite 25K) |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be "Elite 25K" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: LHR ? YYZ" with claim filed for this flight |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "�312 GBP (AC Wallet) / �260 GBP (Cash)" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 UK with delay 3h 30m, UK origin, and controllable Code 67 |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Diogo Silva + TC066 + LHR?YYZ + FD" |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing compensation amount "�312 GBP" and regulation "EU 261 UK" and  |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP162 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "United Kingdom" |  |
| CP163 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "GBP" |  |
| CP164 | PAYMENT VALIDATION | payment | chat | And the customer has Aeroplan "9876543210" linked with Elite 25K status in good standing |  |
| CP165 | PAYMENT VALIDATION | payment | chat | And both options should be offered: Cash at �260 GBP and AC Wallet at �312 GBP with 20% top-up |  |
| CP166 | PAYMENT VALIDATION | payment | chat | And the customer selects "AC Wallet" |  |
| CP167 | PAYMENT VALIDATION | payment | chat | And the 20% top-up should be applied converting �260 base to �312 GBP |  |
| CP168 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend |  |
| CP169 | PAYMENT VALIDATION | payment | manual | And the record should be picked up by the daily evening batch file |  |
| CP170 | PAYMENT VALIDATION | payment | manual | And the record should be dispatched to EIP |  |
| CP171 | PAYMENT VALIDATION | payment | chat | And EIP should verify Aeroplan account validity (active, not frozen) |  |
| CP172 | PAYMENT VALIDATION | payment | chat | And EIP should send to iGiga ? iFly for deposit |  |
| CP173 | PAYMENT VALIDATION | payment | chat | And iFly should talk back to EIP |  |
| CP174 | PAYMENT VALIDATION | payment | chat | And EIP should talk back to Claims Dashboard with deposited amount (�312 GBP), exchange rate used, and status "Completed" or "Issued" |  |
| CP175 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show payout details: amount (�312 GBP), currency (GBP), payment method "AC Wallet", status  |  |
| CP176 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-EL-01. | DDS returns FD-EU-EL-01. |
| CP177 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 16:00; Actual = 19:30; Delay = 3.5hrs (210 min); MSL = Leg 1 (AC 858); Code 67 (Crew Transport Delay); Controllable;  | Trip Tracer: Promise = 16:00; Actual = 19:30; Delay = 3.5hrs (210 min); MSL = Leg 1 (AC 858); Code 67 (Crew Transport Delay); Controllable; Fallback = FALSE. |
| CP178 | EXPECTED RESULTS | verdict | api | Dual Regime Assessment: EU 261 (UK) = ELIGIBLE ? EL-01, UK Tier 1 (3�<4hrs); �260 GBP Cash base / �312 GBP AC Wallet (+20%). | Dual Regime Assessment: EU 261 (UK) = ELIGIBLE ? EL-01, UK Tier 1 (3�<4hrs); �260 GBP Cash base / �312 GBP AC Wallet (+20%). |
| CP179 | EXPECTED RESULTS | verdict | chat | Passenger: Diogo Silva (Portuguese, Elite 25K Member #: 9876543210). | Passenger: Diogo Silva (Portuguese, Elite 25K Member #: 9876543210). |
| CP180 | EXPECTED RESULTS | verdict | api | Regime: EU 261 (UK) Compensation: �312 GBP (AC Wallet). | Regime: EU 261 (UK) Compensation: �312 GBP (AC Wallet). |
| CP181 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP182 | EXPECTED RESULTS | verdict | chat | IDV: Persona PASS. | IDV: Persona PASS. |
| CP183 | EXPECTED RESULTS | verdict | chat | Payment: AC Wallet (EIP/iFly). | Payment: AC Wallet (EIP/iFly). |
| CP184 | EXPECTED RESULTS | verdict | dashboard | Claims Dashboard: EU 261 (UK) EL-01 selected, �312 GBP AC Wallet issued. | Claims Dashboard: EU 261 (UK) EL-01 selected, �312 GBP AC Wallet issued. |
