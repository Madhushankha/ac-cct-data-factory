# FD_TC_035 · CHAI-31427 — checkpoints

**Goal:** Customer's original flight AC 435 YUL?YYZ was CANCELLED due to FOC (Flight Ops Control / Crew � Controllable). Customer is reprotected / rebooked onto renumbered flight AC 445 YUL?YYZ. The renumbered flight departs at the exact SAME scheduled departure time (08:00) AND arrives at YYZ at the exact SAME scheduled arrival time (10:00) as the original promised itinerary (0 hours arrival delay). Passenger holds a Basic Aeroplan profile (9876543210) linked to the booking. Validates: (1) Involuntary reprotection / flight renumbering handling (AC 435 ? AC 445), (2) APPR Controllable Cancellation Entitlement logic � under APPR, a controllable cancellation is a standalone entitlement that yields $400 CAD Cash / $480 CAD AC Wallet floor even when the passenger arrives on time on the reprotected flight, (3) FOC (Flight Ops Control / Crew) classified as Controllable, (4) Linked Basic Aeroplan profile triggers dual payout offer (Cash vs AC Wallet with 20% top-up), (5) Customer selects Cash ($400 CAD via Interac e-Transfer).

Prereuisites:
PNR: TC024 � single passenger Dominique Arsenault (Adult - Basic Aeroplan Member #: 9876543210). Original itinerary: AC 435 YUL?YYZ, Scheduled departure: 08:00, Scheduled arrival: 10:00. Original flight CANCELLED (Cancellation Code: FOC � Flight Ops Control / Crew � Controllable). Customer reprotected on renumbered flight AC 445 YUL?YYZ. Scheduled departure time: 08:00 (SAME as original scheduled departure). Actual arrival time: 10:00 (SAME as original promised arrival � 0h delay). Entitlement: Controllable Cancellation Entitlement Floor ($400 CAD Cash / $480 CAD AC Wallet). Aeroplan: Linked (9876543210), Basic Member in good standing. CyberSource: GREEN. RDS: No flags.

Methods: chat 61, api 18, email 3, dashboard 47, implied 21, manual 17, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer's original flight AC 435 YUL?YYZ was CANCELLED due to FOC (Flight Ops Control / Crew � Controllable). Customer is reprotected / reb |  |
| CP002 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP003 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP004 | START | customer | chat | Then user selects English |  |
| CP005 | START | alert | chat | Then an alert information is displayed ""Please note that by using this service, you will interact with an automated chatbot which uses AI t | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP006 | START | bot | chat | Then chatbot asks ""How can I help you today?"" | How can I help you today? |
| CP007 | START | customer | chat | And the user says ""My flight from Montreal to Toronto was cancelled due to flight ops crew control and I was moved to a renumbered flight.  | My flight from Montreal to Toronto was cancelled due to flight ops crew control and I was moved to a renumbered flight. It departed and arrived at the same time |
| CP008 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP009 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP010 | START | bot | chat | Then the chatbot responds: ""No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP011 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: ""Please note that the assessment and decision regarding your request will be made through an automated decision- | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP012 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP013 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP014 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides ""Dominique Arsenault"" | Dominique Arsenault |
| CP015 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Dominique! And, what is your booking reference number? |
| CP016 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides ""PNR: TC024"" | PNR: TC024 |
| CP017 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC024 |  |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP020 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: d***@gmail.com � Phone: +1***890 |
| CP022 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects ""Email: d***@gmail.com"" | Email: d***@gmail.com |
| CP023 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP024 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code ""629184"" | 629184 |
| CP025 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP027 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP028 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP029 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP030 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP031 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Dominique Arsenault (Adult - Aeroplan Member) Is this who you'd like to include? |
| CP032 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms ""Yes"" | Yes |
| CP033 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP034 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Original Flight: AC 435 � CANCELLED (FOC � Flight Ops Control / Crew) � Reprotected Flight: AC 445 (Renumbered) � Route: Montre |
| CP035 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms ""Yes"" | Yes |
| CP036 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP037 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP038 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP039 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP040 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 10, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP041 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP042 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 10, 2026; filing June 15, 2026 ? 36 days ? within 366 days ? PROCEED |  |
| CP043 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP044 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP045 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 435, Route: YUL ? YYZ, Scheduled Departure: 08:00, Scheduled Arrival: 10:00 (original flight � CANCELLED) | Promised Itinerary - Flight: AC 435, Route: YUL ? YYZ, Scheduled Departure: 08:00, Scheduled Arrival: 10:00 (original flight � CANCELLED) |
| CP046 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 445 (Renumbered), Route: YUL ? YYZ, Status: ARRIVED, Scheduled Departure: 08:00 (SAME), Actual Arrival: 10:00 | Current Itinerary - Flight: AC 445 (Renumbered), Route: YUL ? YYZ, Status: ARRIVED, Scheduled Departure: 08:00 (SAME), Actual Arrival: 10:00 (SAME) |
| CP047 | TRIP TRACER UI VALIDATION | verdict | api | History - Change 1: INVOL � Original flight AC 435 YUL?YYZ cancelled (FOC Crew / Flight Ops Control). Customer reprotected onto renumbered f | History - Change 1: INVOL � Original flight AC 435 YUL?YYZ cancelled (FOC Crew / Flight Ops Control). Customer reprotected onto renumbered flight AC 445 YUL?YYZ |
| CP048 | TRIP TRACER UI VALIDATION | verdict | api | Departure Check: Scheduled departure matches original (08:00) | Departure Check: Scheduled departure matches original (08:00) |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Arrival Check: Actual arrival matches original promise (10:00) � 0h arrival delay | Arrival Check: Actual arrival matches original promise (10:00) � 0h arrival delay |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 435 � YUL ? YYZ � Cancellation Code: FOC (Flight Ops Control / Crew � Controllable) | MSL FLIGHT: AC 435 � YUL ? YYZ � Cancellation Code: FOC (Flight Ops Control / Crew � Controllable) |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Rebooked Flight: AC 445 � YUL ? YYZ (Renumbered) | Rebooked Flight: AC 445 � YUL ? YYZ (Renumbered) |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | DDS Entitlement Gate: Controllable Cancellation Entitlement Floor applies ($400 CAD Cash / $480 CAD AC Wallet) | DDS Entitlement Gate: Controllable Cancellation Entitlement Floor applies ($400 CAD Cash / $480 CAD AC Wallet) |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: 9876543210 (Basic Member � linked) | Aeroplan: 9876543210 (Basic Member � linked) |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | MS DOMINIQUE ARSENAULT / ELIGIBLE / CONTROLLABLE_CANCELLATION_ENTITLEMENT / CAD $400.00 Cash / CAD $480.00 AC Wallet (+20%) / [expiry date] | MS DOMINIQUE ARSENAULT / ELIGIBLE / CONTROLLABLE_CANCELLATION_ENTITLEMENT / CAD $400.00 Cash / CAD $480.00 AC Wallet (+20%) / [expiry date] |
| CP056 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP057 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP058 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP059 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your original flight AC 435 from Montreal (YUL) to Toronto (YYZ) was cancelled due to flight operations crew |
| CP060 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP061 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects ""Canada"" | Canada |
| CP062 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP063 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (Aeroplan #: 9876543210, Status: Basic Member) |  |
| CP064 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Aeroplan account in good standing? ? YES |  |
| CP065 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot offers BOTH options: | Since you are an Aeroplan member, you can choose to receive: � Cash: $400 CAD will be sent via Interac e-Transfer and takes 5 to 10 business days to process. �  |
| CP066 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And the user selects ""Cash"" | Cash |
| CP067 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the system determines: Customer selected Cash ? Payment method = Interac e-Transfer (Canada) |  |
| CP068 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP069 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms ""Yes, use this email"" | Yes, use this email |
| CP070 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP071 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP072 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button ""Get verified"" | Get verified |
| CP073 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP074 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP075 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP076 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP077 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP078 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP081 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: ""Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: Interac e-Transfer (d***@gmail.com) After submission, you will receive a confirmation email summarizing your eligibilit |
| CP082 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: ""Please note that the payment details cannot be changed after submission."" | Please note that the payment details cannot be changed after submission. |
| CP083 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: ""Yes"" | Yes |
| CP084 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: ""Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your e | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP085 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: ""Claim submission successful!"" | Claim submission successful! |
| CP086 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP087 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP088 | NOTIFICATION | email | email | And an eligible notification email is sent to d***@gmail.com |  |
| CP089 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD Cash � Interac e-Transfer), regulation (APPR), flight details (AC 435  |  |
| CP090 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP091 | END FLOW (GLOB-11) | customer | chat | And the user selects ""No"" | No |
| CP092 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds ""Thank you for choosing Air Canada."" | Thank you for choosing Air Canada. |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant ""Dominique Arsenault"" with PNR ""TC024"" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be ""Travel Disruptions � Delay"" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be ""In Review"" or ""Done"" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be ""Dominique Arsenault"" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be ""Adult"" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be ""Pass"" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be ""TC024"" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be ""APPR"" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be ""Dominique Arsenault"" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include ""Claimant"" and ""Adult"" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be ""d***@gmail.com"" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be ""+1***890"" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be ""9876543210"" linked and in good standing (Basic Member) |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be ""Basic / Member"" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show ""Bound 1: YUL ? YYZ"" (original AC 435 cancelled; reprotected on renumbered AC 445) with claim filed for this f |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated for this automated FD case |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the compensation should show ""$400 CAD (Cash � Interac e-Transfer)"" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the AC Wallet option ($480 CAD) should be visible as offered but NOT selected |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as ""ELIGIBLE"" under APPR Controllable Cancellation Entitlement (renumbered flight AC  |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data ""Dominique Arsenault + TC024 + YUL?YYZ + FD"" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be ""No duplicate found"" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be ""GREEN"" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from ""Assigned"" to ""In Progress"" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be ""Resolved"" |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP149 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is ""Canada"" |  |
| CP150 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to ""CAD"" |  |
| CP151 | PAYMENT VALIDATION | payment | chat | And the customer has Aeroplan ""9876543210"" linked with Basic Member status in good standing |  |
| CP152 | PAYMENT VALIDATION | payment | chat | And both options should have been offered: Cash ($400 CAD Interac) AND AC Wallet ($480 CAD with 20% top-up) |  |
| CP153 | PAYMENT VALIDATION | payment | chat | And the customer selected ""Cash"" ? Payment method = Interac e-Transfer |  |
| CP154 | PAYMENT VALIDATION | payment | manual | And AC Wallet was offered but NOT selected ? AC Wallet payout NOT dispatched |  |
| CP155 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be ""$400 CAD"" for Controllable Cancellation Entitlement Floor (<3h arrival delay) |  |
| CP156 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP157 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP158 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP159 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP160 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received from Interac |  |
| CP161 | PAYMENT VALIDATION | payment | manual | And the status should be ""Pending"" transitioning to ""Cached"" or ""Rejected"" or ""Expired"" |  |
| CP162 | PAYMENT VALIDATION | payment | manual | And if the payment is unclaimed after 35 days the status should be set to ""Expired"" |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show ""$400 CAD"" Cash via Interac |  |
| CP164 | PAYMENT VALIDATION | payment | manual | And the status should be updated via talkback |  |
| CP165 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 10:00 at YYZ (original flight AC 435, CANCELLED); Actual = 10:00 at YYZ (reprotected on renumbered flight AC 445); De | Trip Tracer: Promise = 10:00 at YYZ (original flight AC 435, CANCELLED); Actual = 10:00 at YYZ (reprotected on renumbered flight AC 445); Departure = 08:00 (SAM |
| CP166 | EXPECTED RESULTS | verdict | chat | Aeroplan: Basic Member (9876543210) linked � BOTH Cash ($400 CAD) and AC Wallet ($480 CAD +20%) offered. | Aeroplan: Basic Member (9876543210) linked � BOTH Cash ($400 CAD) and AC Wallet ($480 CAD +20%) offered. |
| CP167 | EXPECTED RESULTS | verdict | chat | Customer selects Cash. | Customer selects Cash. |
| CP168 | EXPECTED RESULTS | verdict | chat | Change History: INVOL � AC 435 cancelled (FOC) ? customer reprotected onto renumbered flight AC 445 YUL?YYZ. | Change History: INVOL � AC 435 cancelled (FOC) ? customer reprotected onto renumbered flight AC 445 YUL?YYZ. |
