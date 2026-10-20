# FD_TC_033 · CHAI-31425 — checkpoints

**Goal:** Customer's original flight YUL?YYZ was CANCELLED due to SOP Ops Control (Controllable). Customer accepts rebooking to AC 436 YUL?YHM (Hamilton � sister city of YYZ). Actual arrival at YHM is 7 hours after original promised arrival at YYZ (10:00 promise vs 17:00 actual). Passenger holds a Basic Aeroplan profile (9876543210) linked to the booking. Validates: (1) Sister city flag set when customer is rebooked to sister city airport, (2) Delay calculated as actual arrival at sister city (YHM) minus original promised arrival at original destination (YYZ) = 7 hours, (3) SOP Ops Control classified as Controllable, (4) APPR Tier 2 ($700 CAD Cash / $840 CAD AC Wallet) applies for 7hr delay, (5) Linked Basic Aeroplan profile triggers dual payout offer (Cash vs AC Wallet with 20% top-up), (6) Customer selects Cash ($700 CAD via Interac e-Transfer).

Methods: seed 7, chat 61, api 19, email 3, dashboard 47, implied 23, manual 17, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer's original flight YUL?YYZ was CANCELLED due to SOP Ops Control (Controllable). Customer accepts rebooking to AC 436 YUL?YHM (Hamilt |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC024 � single passenger Dominique Arsenault (Adult - Basic Aeroplan Member #: 9876543210) | PNR: TC024 � single passenger Dominique Arsenault (Adult - Basic Aeroplan Member #: 9876543210) |
| CP003 | PREREQUISITES | prerequisite | seed | Original itinerary: AC 435 YUL?YYZ, Scheduled arrival: 10:00 | Original itinerary: AC 435 YUL?YYZ, Scheduled arrival: 10:00 |
| CP004 | PREREQUISITES | prerequisite | seed | Original flight CANCELLED (Cancellation Code: SOP Ops Control � Controllable) | Original flight CANCELLED (Cancellation Code: SOP Ops Control � Controllable) |
| CP005 | PREREQUISITES | prerequisite | seed | Customer offered rebooking options and ACCEPTS rebooking to AC 436 YUL?YHM (Hamilton � sister city of YYZ) | Customer offered rebooking options and ACCEPTS rebooking to AC 436 YUL?YHM (Hamilton � sister city of YYZ) |
| CP006 | PREREQUISITES | prerequisite | seed | Rebooked flight AC 436 departs YUL and arrives YHM at 17:00 | Rebooked flight AC 436 departs YUL and arrives YHM at 17:00 |
| CP007 | PREREQUISITES | prerequisite | seed | Delay calculation: 17:00 (YHM actual) ? 10:00 (YYZ original promise) = 7hrs (6�<9h band, APPR Tier 2) | Delay calculation: 17:00 (YHM actual) ? 10:00 (YYZ original promise) = 7hrs (6�<9h band, APPR Tier 2) |
| CP008 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked (9876543210), Basic Member in good standing | Aeroplan: Linked (9876543210), Basic Member in good standing |
| CP009 | PREREQUISITES | prerequisite | implied | CyberSource: GREEN | CyberSource: GREEN |
| CP010 | PREREQUISITES | prerequisite | implied | RDS: No flags | RDS: No flags |
| CP011 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP012 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP013 | START | customer | chat | Then user selects English |  |
| CP014 | START | alert | chat | Then an alert information is displayed ""Please note that by using this service, you will interact with an automated chatbot which uses AI t | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP015 | START | bot | chat | Then chatbot asks ""How can I help you today?"" | How can I help you today? |
| CP016 | START | customer | chat | And the user says ""My flight from Montreal to Toronto was cancelled due to SOP ops control and I was rebooked to a flight landing at Hamilt | My flight from Montreal to Toronto was cancelled due to SOP ops control and I was rebooked to a flight landing at Hamilton instead. I arrived 7 hours later than |
| CP017 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP018 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP019 | START | bot | chat | Then the chatbot responds: ""No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP020 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: ""Please note that the assessment and decision regarding your request will be made through an automated decision- | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides ""Dominique Arsenault"" | Dominique Arsenault |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Dominique! And, what is your booking reference number? |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides ""PNR: TC024"" | PNR: TC024 |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC024 |  |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: d***@gmail.com � Phone: +1***890 |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects ""Email: d***@gmail.com"" | Email: d***@gmail.com |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code ""629184"" | 629184 |
| CP034 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP036 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP037 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP039 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Dominique Arsenault (Adult - Aeroplan Member) Is this who you'd like to include? |
| CP041 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms ""Yes"" | Yes |
| CP042 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP043 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 436 � Route: Montreal (YUL) ? Hamilton (YHM) [Rebooked � original destination: Toronto YYZ] � Date: May 10, 2026 � A |
| CP044 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms ""Yes"" | Yes |
| CP045 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP049 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 10, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 10, 2026; filing June 15, 2026 ? 36 days ? within 366 days ? PROCEED |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 435, Route: YUL ? YYZ, Scheduled Arrival: 10:00 at YYZ (original flight � CANCELLED) | Promised Itinerary - Flight: AC 435, Route: YUL ? YYZ, Scheduled Arrival: 10:00 at YYZ (original flight � CANCELLED) |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 436, Route: YUL ? YHM (rebooked to sister city), Status: ARRIVED, Actual Arrival: 17:00 at YHM | Current Itinerary - Flight: AC 436, Route: YUL ? YHM (rebooked to sister city), Status: ARRIVED, Actual Arrival: 17:00 at YHM |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | History - Change 1: INVOL � Original flight AC 435 YUL?YYZ cancelled (SOP Ops Control). Customer accepted rebooking to AC 436 YUL?YHM (siste | History - Change 1: INVOL � Original flight AC 435 YUL?YYZ cancelled (SOP Ops Control). Customer accepted rebooking to AC 436 YUL?YHM (sister city of YYZ). |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Sister City Check: YHM ? YYZ = VALID PAIR (confirmed in DDS sister city config) | Sister City Check: YHM ? YYZ = VALID PAIR (confirmed in DDS sister city config) |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Sister city accepted as equivalent destination | Sister city accepted as equivalent destination |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 435 � YUL ? YYZ � Cancellation Code: SOP Ops Control | MSL FLIGHT: AC 435 � YUL ? YYZ � Cancellation Code: SOP Ops Control |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Rebooked Flight: AC 436 � YUL ? YHM (sister city) | Rebooked Flight: AC 436 � YUL ? YHM (sister city) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Delay Calculation: Original promise = 10:00 at YYZ; Actual arrival = 17:00 at YHM (sister city); Delay = 7hrs | Delay Calculation: Original promise = 10:00 at YYZ; Actual arrival = 17:00 at YHM (sister city); Delay = 7hrs |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +7H 00M � CONTROLLABLE (SOP Ops Control) | Delay: +7H 00M � CONTROLLABLE (SOP Ops Control) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: 9876543210 (Basic Member � linked) | Aeroplan: 9876543210 (Basic Member � linked) |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | MS DOMINIQUE ARSENAULT / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD $700.00 Cash / CAD $840.00 AC Wallet (+20%) / [expiry date] | MS DOMINIQUE ARSENAULT / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD $700.00 Cash / CAD $840.00 AC Wallet (+20%) / [expiry date] |
| CP066 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP067 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP068 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP069 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your original flight AC 435 from Montreal (YUL) to Toronto (YYZ) was cancelled due to SOP operational contro |
| CP070 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP071 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects ""Canada"" | Canada |
| CP072 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP073 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (Aeroplan #: 9876543210, Status: Basic Member) |  |
| CP074 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Aeroplan account in good standing? ? YES |  |
| CP075 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot offers BOTH options: | Since you are an Aeroplan member, you can choose to receive: � Cash: $700 CAD will be sent via Interac e-Transfer and takes 5 to 10 business days to process. �  |
| CP076 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And the user selects ""Cash"" | Cash |
| CP077 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the system determines: Customer selected Cash ? Payment method = Interac e-Transfer (Canada) |  |
| CP078 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP079 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms ""Yes, use this email"" | Yes, use this email |
| CP080 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button ""Get verified"" | Get verified |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP085 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP086 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP087 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP088 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP089 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP090 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP091 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: ""Please review your compensation details: | Deposit Amount: $700 CAD Payment Method: Interac e-Transfer (d***@gmail.com) After submission, you will receive a confirmation email summarizing your eligibilit |
| CP092 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: ""Please note that the payment details cannot be changed after submission."" | Please note that the payment details cannot be changed after submission. |
| CP093 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: ""Yes"" | Yes |
| CP094 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: ""Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your e | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP095 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: ""Claim submission successful!"" | Claim submission successful! |
| CP096 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP097 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP098 | NOTIFICATION | email | email | And an eligible notification email is sent to d***@gmail.com |  |
| CP099 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($700 CAD Cash � Interac e-Transfer), regulation (APPR), flight details (includi |  |
| CP100 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP101 | END FLOW (GLOB-11) | customer | chat | And the user selects ""No"" | No |
| CP102 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds ""Thank you for choosing Air Canada."" | Thank you for choosing Air Canada. |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant ""Dominique Arsenault"" with PNR ""TC024"" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be ""Travel Disruptions � Delay"" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be ""In Review"" or ""Done"" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be ""Dominique Arsenault"" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be ""Adult"" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be ""Pass"" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be ""TC024"" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be ""APPR"" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be ""Dominique Arsenault"" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include ""Claimant"" and ""Adult"" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be ""d***@gmail.com"" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be ""+1***890"" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be ""9876543210"" linked and in good standing (Basic Member) |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be ""Basic / Member"" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show ""Bound 1: YUL ? YYZ"" (rebooked YUL ? YHM sister city) with claim filed for this flight |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated for this automated FD case |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the compensation should show ""$700 CAD (Cash � Interac e-Transfer)"" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the AC Wallet option ($840 CAD) should be visible as offered but NOT selected |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as ""ELIGIBLE"" under APPR Tier 2 (sister city YHM, 7h delay, SOP Ops Control) |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data ""Dominique Arsenault + TC024 + YUL?YYZ + FD"" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be ""No duplicate found"" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be ""GREEN"" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from ""Assigned"" to ""In Progress"" |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be ""Resolved"" |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP159 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is ""Canada"" |  |
| CP160 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to ""CAD"" |  |
| CP161 | PAYMENT VALIDATION | payment | chat | And the customer has Aeroplan ""9876543210"" linked with Basic Member status in good standing |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And both options should have been offered: Cash ($700 CAD Interac) AND AC Wallet ($840 CAD with 20% top-up) |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And the customer selected ""Cash"" ? Payment method = Interac e-Transfer |  |
| CP164 | PAYMENT VALIDATION | payment | manual | And AC Wallet was offered but NOT selected ? AC Wallet payout NOT dispatched |  |
| CP165 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be ""$700 CAD"" for Tier 2 delay of 6 to less than 9 hours |  |
| CP166 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP167 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP168 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP169 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP170 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received from Interac |  |
| CP171 | PAYMENT VALIDATION | payment | manual | And the status should be ""Pending"" transitioning to ""Cached"" or ""Rejected"" or ""Expired"" |  |
| CP172 | PAYMENT VALIDATION | payment | manual | And if the payment is unclaimed after 35 days the status should be set to ""Expired"" |  |
| CP173 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show ""$700 CAD"" Cash via Interac |  |
| CP174 | PAYMENT VALIDATION | payment | manual | And the status should be updated via talkback |  |
| CP175 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 10:00 at YYZ (original flight AC 435, CANCELLED); Actual = 17:00 at YHM (rebooked flight AC 436, sister city); Sister | Trip Tracer: Promise = 10:00 at YYZ (original flight AC 435, CANCELLED); Actual = 17:00 at YHM (rebooked flight AC 436, sister city); Sister City = TRUE (YHM?YY |
| CP176 | EXPECTED RESULTS | verdict | chat | Aeroplan: Basic Member (9876543210) linked � BOTH Cash ($700 CAD) and AC Wallet ($840 CAD +20%) offered. | Aeroplan: Basic Member (9876543210) linked � BOTH Cash ($700 CAD) and AC Wallet ($840 CAD +20%) offered. |
| CP177 | EXPECTED RESULTS | verdict | chat | Customer selects Cash. | Customer selects Cash. |
| CP178 | EXPECTED RESULTS | verdict | chat | Change History: INVOL � AC 435 cancelled (SOP Ops Control) ? customer accepted rebooking to AC 436 YUL?YHM. | Change History: INVOL � AC 435 cancelled (SOP Ops Control) ? customer accepted rebooking to AC 436 YUL?YHM. |
