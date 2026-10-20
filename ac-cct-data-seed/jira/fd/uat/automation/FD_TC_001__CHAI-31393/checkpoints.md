# FD_TC_001 · CHAI-31393 — checkpoints

**Goal:** Validates the simplest end-to-end eligible scenario with a Basic Aeroplan member who selects Cash (Interac) over AC Wallet. Single passenger on a single domestic AC leg, delayed 4 hours due to controllable reason (Code 64). Aeroplan Basic profile (9876543210) is linked to the booking � system offers BOTH Cash ($400 CAD) and AC Wallet ($480 CAD with 20% top-up). Customer selects Cash/Interac payout at $400 CAD. Confirms DDS correctly identifies APPR regime, controllable classification, Tier 1 delay band, and generates EL-01 response code. Also validates CyberSource GREEN passes through to auto-approved payment. Validates that AC Wallet is correctly offered but not forced � customer free choice of Cash is respected.

Methods: seed 13, chat 64, api 16, email 3, dashboard 46, implied 21, manual 17, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates the simplest end-to-end eligible scenario with a Basic Aeroplan member who selects Cash (Interac) over AC Wallet. Single passenger |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC001 � single passenger Catherine Bouchard (Adult - Basic Aeroplan Member) | PNR: TC001 � single passenger Catherine Bouchard (Adult - Basic Aeroplan Member) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC domestic YUL?YYZ | Journey: 1 leg AC domestic YUL?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 14:00 | Scheduled arrival: 14:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival: 18:00 (4hr delay) | Actual arrival: 18:00 (4hr delay) |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival delay code: 64 (Flight Crew Shortage � Controllable) | Arrival delay code: 64 (Flight Crew Shortage � Controllable) |
| CP007 | PREREQUISITES | prerequisite | seed | Flight status: Arrived (operated) | Flight status: Arrived (operated) |
| CP008 | PREREQUISITES | prerequisite | seed | Booking changes: None � no VOL or INVOL | Booking changes: None � no VOL or INVOL |
| CP009 | PREREQUISITES | prerequisite | seed | Carrier: AC only | Carrier: AC only |
| CP010 | PREREQUISITES | prerequisite | seed | 72hrs: Elapsed (filed D+13) | 72hrs: Elapsed (filed D+13) |
| CP011 | PREREQUISITES | prerequisite | seed | Time limit: Within 366 days | Time limit: Within 366 days |
| CP012 | PREREQUISITES | prerequisite | seed | No duplicate case | No duplicate case |
| CP013 | PREREQUISITES | prerequisite | seed | Not employee, not infant | Not employee, not infant |
| CP014 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked (9876543210), Basic Member in good standing | Aeroplan: Linked (9876543210), Basic Member in good standing |
| CP015 | PREREQUISITES | prerequisite | implied | CyberSource: Configured to return GREEN | CyberSource: Configured to return GREEN |
| CP016 | PREREQUISITES | prerequisite | implied | RDS: No flags | RDS: No flags |
| CP017 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP018 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP019 | START | customer | chat | Then user selects English |  |
| CP020 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP021 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP022 | START | customer | chat | And the user says "My flight was delayed about 4 hours, I'd like to check if I'm eligible for compensation" | My flight was delayed about 4 hours, I'd like to check if I'm eligible for compensation |
| CP023 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP024 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP025 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP026 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Catherine Bouchard" | Catherine Bouchard |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Catherine! And, what is your booking reference number? |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC001" | PNR: TC001 |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC001 |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: c***@gmail.com � Phone: +1***567 |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: c***@gmail.com" | Email: c***@gmail.com |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "591837" | 591837 |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP043 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Catherine Bouchard (Adult - Aeroplan Member) Is this who you'd like to include? |
| CP044 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP046 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 301 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: January 15, 2026 � Arrival Delay: 4 hours Is this the journey yo |
| CP047 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP050 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP051 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP052 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was January 15, 2026; current date is January 28, 2026 ? 312 hours ? >72 hours ? PROCEED | (If <72 hrs: case would enter System Processing Queue; customer asked for preferred email; system polls DDS/Trip Tracer for up to 14 days; if hit ? Welcome Back |
| CP053 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP054 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption January 15, 2026; filing January 28, 2026 ? 13 days ? within 366 days ? PROCEED |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 301, Route: YUL ? YYZ, Scheduled Arrival: 14:00 | Promised Itinerary - Flight: AC 301, Route: YUL ? YYZ, Scheduled Arrival: 14:00 |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 301, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 14:00 ? Actual: 18:00, Delay: +4H 00M | Current Itinerary - Flight: AC 301, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 14:00 ? Actual: 18:00, Delay: +4H 00M |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 301 � YUL ? YYZ � 64 | MSL FLIGHT: AC 301 � YUL ? YYZ � 64 |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to flight crew shortage" | "Delayed due to flight crew shortage" |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +4H 00M � CONTROLLABLE | Delay: +4H 00M � CONTROLLABLE |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: 9876543210 (Basic Member � linked) | Aeroplan: 9876543210 (Basic Member � linked) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | MS CATHERINE BOUCHARD / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 Cash / CAD 480.00 AC Wallet (+20%) / [expiry date] | MS CATHERINE BOUCHARD / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 Cash / CAD 480.00 AC Wallet (+20%) / [expiry date] |
| CP065 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP066 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP067 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP068 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 301 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours. Based on the Air Passenger  |
| CP069 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP070 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP071 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP072 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (Aeroplan #: 9876543210, Status: Basic Member) |  |
| CP073 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Aeroplan account in good standing? ? YES |  |
| CP074 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot offers BOTH options: | Since you are an Aeroplan member, you can choose to receive: � Cash: $400 CAD will be sent via Interac e-Transfer and takes 5 to 10 business days to process. �  |
| CP075 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And the user selects "Cash" | Cash |
| CP076 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the system determines: Customer selected Cash ? Payment method = Interac e-Transfer (Canada) |  |
| CP077 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP078 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP079 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
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
| CP090 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: Interac e-Transfer (c***@gmail.com) After submission, you will receive a confirmation email summarizing your eligibilit |
| CP091 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP092 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP093 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP094 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP095 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP096 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP097 | NOTIFICATION | email | email | And an eligible notification email is sent to c***@gmail.com |  |
| CP098 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD Cash � Interac e-Transfer), regulation (APPR), flight details (YUL?YYZ |  |
| CP099 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP100 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP101 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Catherine Bouchard" with PNR "TC001" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" mapped from chatbot intent |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Catherine Bouchard" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC001" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Catherine Bouchard" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "c***@gmail.com" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***567" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "9876543210" linked and in good standing (Basic Member) |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be "Basic / Member" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated for this automated FD case |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the compensation should show "$400 CAD (Cash � Interac e-Transfer)" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the AC Wallet option ($480 CAD) should be visible as the offered alternative but NOT selected |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" (APPR, Code 64 Controllable, 4h delay, Tier 1) |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Catherine Bouchard + TC001 + YUL?YYZ + FD" |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record to the case automatically for identified and authenticated user |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case function from My Activities to get this case |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent to the customer |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing $400 CAD Cash and Interac e-Transfer payment method |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP157 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP158 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP159 | PAYMENT VALIDATION | payment | chat | And the customer has Aeroplan "9876543210" linked with Basic Member status in good standing |  |
| CP160 | PAYMENT VALIDATION | payment | chat | And both options should have been offered: Cash ($400 CAD Interac) AND AC Wallet ($480 CAD with 20% top-up) |  |
| CP161 | PAYMENT VALIDATION | payment | chat | And the customer selected "Cash" ? Payment method = Interac e-Transfer |  |
| CP162 | PAYMENT VALIDATION | payment | manual | And AC Wallet was offered but NOT selected � AC Wallet payout NOT dispatched |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And the Interac email should be collected from the customer (c***@gmail.com) |  |
| CP164 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created with $400 CAD |  |
| CP165 | PAYMENT VALIDATION | payment | manual | And the record should be picked up by the daily evening batch file |  |
| CP166 | PAYMENT VALIDATION | payment | manual | And the record should be dispatched to Unifier |  |
| CP167 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP168 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received from Interac |  |
| CP169 | PAYMENT VALIDATION | payment | manual | And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP170 | PAYMENT VALIDATION | payment | manual | And if the customer does not claim the Interac payment within 35 days the status should be set to "Expired" |  |
| CP171 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details: amount ($400 CAD), payment method (Cash � Interac e-Transfer), status  |  |
| CP172 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-01. | DDS returns FD-APPR-EL-01. |
| CP173 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 14:00 (14-day mark, no changes); Actual = 18:00; Delay = 4hrs; MSL = Leg 1 (AC 301 YUL?YYZ); Code 64 (Flight Crew Sho | Trip Tracer: Promise = 14:00 (14-day mark, no changes); Actual = 18:00; Delay = 4hrs; MSL = Leg 1 (AC 301 YUL?YYZ); Code 64 (Flight Crew Shortage � Controllable |
| CP174 | EXPECTED RESULTS | verdict | chat | Aeroplan: Basic Member (9876543210) linked � BOTH Cash ($400 CAD) and AC Wallet ($480 CAD +20%) offered. | Aeroplan: Basic Member (9876543210) linked � BOTH Cash ($400 CAD) and AC Wallet ($480 CAD +20%) offered. |
| CP175 | EXPECTED RESULTS | verdict | chat | Customer selects Cash. | Customer selects Cash. |
| CP176 | EXPECTED RESULTS | verdict | chat | Compensation: $400 CAD (Tier 1: 3�<6hrs) via Interac e-Transfer. | Compensation: $400 CAD (Tier 1: 3�<6hrs) via Interac e-Transfer. |
| CP177 | EXPECTED RESULTS | verdict | chat | AC Wallet offered but NOT selected � NOT dispatched. | AC Wallet offered but NOT selected � NOT dispatched. |
| CP178 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN ? auto-approved. | CyberSource: GREEN ? auto-approved. |
| CP179 | EXPECTED RESULTS | verdict | chat | IDV: Persona PASS. | IDV: Persona PASS. |
| CP180 | EXPECTED RESULTS | verdict | chat | Payment: Interac e-Transfer (c***@gmail.com). | Payment: Interac e-Transfer (c***@gmail.com). |
| CP181 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Case created; Status = submitted; Regulation = APPR; Code 64; Delay 4hrs; $400 Cash/Interac selected; AC Wallet offered/$4 | Claims Dashboard: Case created; Status = submitted; Regulation = APPR; Code 64; Delay 4hrs; $400 Cash/Interac selected; AC Wallet offered/$480 not selected; Fra |
