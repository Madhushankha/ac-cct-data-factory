# FD_TC_006 · CHAI-31398 — checkpoints

**Goal:** Customer made a voluntary change (VOL) to a later flight BEFORE the airline made an involuntary change (INVOL). The INVOL rebook splits the original single direct flight into a 2-leg connecting itinerary (ONE_TO_MANY: YUL?YYZ direct ? YUL?YOW?YYZ connecting). Customer has an active Aeroplan 75K status linked to booking. Arrival at destination YYZ is delayed by 9h 30m (9h+ tier). Validates: (1) DDS sets promise to last VOL arrival time (13:00) before first INVOL � NOT the 14-day mark (10:00), (2) ONE_TO_MANY rebooking pattern correctly handled � delay measured at final destination YYZ, (3) MSL determined across the 2-leg rebooked itinerary, (4) Segment check (GenUC-18) triggers for multi-leg journey, (5) APPR Tier 3 compensation ($1,000 CAD base / $1,200 CAD AC Wallet with 20% top-up) correctly evaluated for 9h+ delay, (6) Aeroplan 75K tier status recognized in profile.

Methods: seed 13, chat 67, api 26, email 3, dashboard 45, implied 23, manual 11, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer made a voluntary change (VOL) to a later flight BEFORE the airline made an involuntary change (INVOL). The INVOL rebook splits the  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC003 � Hugo Villeneuve (Adult) | PNR: TC003 � Hugo Villeneuve (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Original (14-day): 1 leg direct AC 423 YUL?YYZ, arrival 10:00 | Original (14-day): 1 leg direct AC 423 YUL?YYZ, arrival 10:00 |
| CP004 | PREREQUISITES | prerequisite | seed | Change 1 (D-10): VOL � customer changed to later direct flight AC 425 YUL?YYZ, new arrival 13:00 | Change 1 (D-10): VOL � customer changed to later direct flight AC 425 YUL?YYZ, new arrival 13:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Change 2 (D-3): INVOL � AC cancelled direct flight and rebooked onto connecting itinerary (ONE_TO_MANY: 1?2 legs): Leg 1 AC 8101 YUL?YOW dep | Change 2 (D-3): INVOL � AC cancelled direct flight and rebooked onto connecting itinerary (ONE_TO_MANY: 1?2 legs): Leg 1 AC 8101 YUL?YOW dep 14:00 arr 15:00; Le |
| CP006 | PREREQUISITES | prerequisite | seed | Actual arrival at YYZ: 22:30 | Actual arrival at YYZ: 22:30 |
| CP007 | PREREQUISITES | prerequisite | seed | Promise = 13:00 (last VOL before first INVOL) | Promise = 13:00 (last VOL before first INVOL) |
| CP008 | PREREQUISITES | prerequisite | seed | Delay = 22:30 - 13:00 = 9 hours 30 minutes (9h+ delay band) | Delay = 22:30 - 13:00 = 9 hours 30 minutes (9h+ delay band) |
| CP009 | PREREQUISITES | prerequisite | seed | Arrival delay code on MSL (Leg 2): 96 (Ops Control � Controllable) | Arrival delay code on MSL (Leg 2): 96 (Ops Control � Controllable) |
| CP010 | PREREQUISITES | prerequisite | seed | Carrier: AC only (both legs) | Carrier: AC only (both legs) |
| CP011 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked (9876543210), Tier Status = 75K, in good standing | Aeroplan: Linked (9876543210), Tier Status = 75K, in good standing |
| CP012 | PREREQUISITES | prerequisite | seed | 72hrs: Elapsed (filed D+13) | 72hrs: Elapsed (filed D+13) |
| CP013 | PREREQUISITES | prerequisite | seed | Time limit: Within 366 days | Time limit: Within 366 days |
| CP014 | PREREQUISITES | prerequisite | seed | No duplicate case | No duplicate case |
| CP015 | PREREQUISITES | prerequisite | implied | CyberSource: GREEN | CyberSource: GREEN |
| CP016 | PREREQUISITES | prerequisite | implied | RDS: No flags | RDS: No flags |
| CP017 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP018 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP019 | START | customer | chat | Then user selects English |  |
| CP020 | START | alert | chat | Then an alert information is displayed ""Please note that by using this service, you will interact with an automated chatbot which uses AI t | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP021 | START | bot | chat | Then chatbot asks ""How can I help you today?"" | How can I help you today? |
| CP022 | START | customer | chat | And the user says ""My flight was changed by Air Canada after I had already changed it myself. I arrived over 9 hours late and want to check | My flight was changed by Air Canada after I had already changed it myself. I arrived over 9 hours late and want to check compensation. |
| CP023 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP024 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP025 | START | bot | chat | Then the chatbot responds: ""No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP026 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: ""Please note that the assessment and decision regarding your request will be made through an automated decision- | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides ""Hugo Villeneuve"" | Hugo Villeneuve |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Hugo! And, what is your booking reference number? |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides ""PNR: TC003"" | PNR: TC003 |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC003 |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: h***@gmail.com � Phone: +1***234 |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects ""Email: h***@gmail.com"" | Email: h***@gmail.com |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code ""482916"" | 482916 |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP042 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP043 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP044 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP045 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP046 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Hugo Villeneuve (Adult - Aeroplan 75K) Is this who you'd like to include? |
| CP047 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms ""Yes"" | Yes |
| CP048 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP049 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Segment 1: Flight AC 8101, Montreal (YUL) ? Ottawa (YOW), May 10, 2026 � COMPLETED Segment 2: Flight AC 8201, Ottawa (YOW) ? Toro |
| CP050 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms ""Yes"" | Yes |
| CP051 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments � ONE_TO_MANY rebooking) |  |
| CP052 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED (YUL?YOW), Segment 2 ARRIVED LATE (YOW?YYZ) |  |
| CP053 | SEGMENT CHECK (GenUC-18) | verdict | api | Then the chatbot determines: Final destination = YYZ; Final arrival delay = 9h 30m; Claim applies to full journey; MSL = Leg 2 (YOW?YYZ) |  |
| CP054 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP055 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP056 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP057 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 10, 2026; current date is June 4, 2026 ? >72 hours ? PROCEED |  |
| CP058 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP059 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 10, 2026; filing June 4, 2026 ? within 366 days ? PROCEED |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Rebooking Pattern: ONE_TO_MANY (1?2 legs) � Original direct YUL?YYZ split into connecting YUL?YOW?YYZ | Rebooking Pattern: ONE_TO_MANY (1?2 legs) � Original direct YUL?YYZ split into connecting YUL?YOW?YYZ |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Direct Flight: AC 425, Route: YUL ? YYZ, Scheduled Arrival: 13:00 (Last VOL before first INVOL, NOT 14-day mark of 10:0 | Promised Itinerary - Direct Flight: AC 425, Route: YUL ? YYZ, Scheduled Arrival: 13:00 (Last VOL before first INVOL, NOT 14-day mark of 10:00) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Segment 1: Flight AC 8101, Route: YUL ? YOW, Status: COMPLETED, Dep: 14:00, Arr: 15:00 | Segment 1: Flight AC 8101, Route: YUL ? YOW, Status: COMPLETED, Dep: 14:00, Arr: 15:00 |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Segment 2: Flight AC 8201, Route: YOW ? YYZ, Status: ARRIVED LATE, Dep: 21:00, Actual Arr: 22:30 | Segment 2: Flight AC 8201, Route: YOW ? YYZ, Status: ARRIVED LATE, Dep: 21:00, Actual Arr: 22:30 |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Final Destination Arrival: YYZ at 22:30 ? Delay: +9H 30M (22:30 - 13:00 promise) | Final Destination Arrival: YYZ at 22:30 ? Delay: +9H 30M (22:30 - 13:00 promise) |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Original (14-day): Direct AC 423 YUL?YYZ arr 10:00 | Original (14-day): Direct AC 423 YUL?YYZ arr 10:00 |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Change 1 (Day -10): VOL � customer changed to direct AC 425 YUL?YYZ ? arr 13:00 | Change 1 (Day -10): VOL � customer changed to direct AC 425 YUL?YYZ ? arr 13:00 |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | Change 2 (Day -3): INVOL � AC cancelled direct and rebooked onto connecting YUL?YOW?YYZ (ONE_TO_MANY) ? arr 22:30 | Change 2 (Day -3): INVOL � AC cancelled direct and rebooked onto connecting YUL?YOW?YYZ (ONE_TO_MANY) ? arr 22:30 |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 8201 � YOW ? YYZ � 96 | MSL FLIGHT: AC 8201 � YOW ? YYZ � 96 |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | ""Delayed due to Ops Control"" | ""Delayed due to Ops Control"" |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +9H 30M � CONTROLLABLE | Delay: +9H 30M � CONTROLLABLE |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | CRITICAL: Promise = 13:00 (last VOL), NOT 10:00 (14-day mark) | CRITICAL: Promise = 13:00 (last VOL), NOT 10:00 (14-day mark) |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | CRITICAL: ONE_TO_MANY rebooking � delay measured at final destination YYZ, not at intermediate YOW | CRITICAL: ONE_TO_MANY rebooking � delay measured at final destination YYZ, not at intermediate YOW |
| CP076 | TRIP TRACER UI VALIDATION | verdict | api | MR HUGO VILLENEUVE / ELIGIBLE / DELAY_GE_9_HOURS / CAD 1,200.00 (Wallet) / CAD 1,000.00 (Cash) / [expiry date] | MR HUGO VILLENEUVE / ELIGIBLE / DELAY_GE_9_HOURS / CAD 1,200.00 (Wallet) / CAD 1,000.00 (Cash) / [expiry date] |
| CP077 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP078 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP079 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP080 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your journey from Montreal (YUL) to Toronto (YYZ) via Ottawa (YOW) was delayed by about 9 and a half hours.  |
| CP081 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP082 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects ""Canada"" | Canada |
| CP083 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP084 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (Aeroplan #: 9876543210, Status: 75K) |  |
| CP085 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Aeroplan account in good standing? ? YES |  |
| CP086 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot offers BOTH options: | Since you are an Aeroplan member, you can choose to either receive: � Cash: CAD $1,000 will be compensated and takes 5 to 10 business days to process the paymen |
| CP087 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And the user selects ""AC Wallet"" | AC Wallet |
| CP088 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP089 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button ""Get verified"" | Get verified |
| CP090 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP091 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP092 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP093 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP094 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP095 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP096 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP097 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP098 | CLAIM AMOUNT CONFIRMATION | bot | chat | Then the chatbot responds: ""Please review your compensation details: | Deposit Amount: $1,200 CAD Payment Method: AC Wallet (Aeroplan #: 9876543210) Would you like me to submit your claim?"" |
| CP099 | CLAIM AMOUNT CONFIRMATION | alert | chat | And an alert information is displayed: ""Please note that payment details cannot be changed after submission."" | Please note that payment details cannot be changed after submission. |
| CP100 | CLAIM AMOUNT CONFIRMATION | customer | chat | When the user provides: ""Yes"" | Yes |
| CP101 | CASE CREATION (GLOB-09) | bot | chat | Then chatbot responds: ""Thank you. Your claim has been submitted and will be processed within 10 business days. | A confirmation email will be sent to you with details on how to monitor your claim status and payment updates. Please refer to that email for any follow-up info |
| CP102 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: ""Claim submission successful!"" | Claim submission successful! |
| CP103 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP104 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP105 | NOTIFICATION | email | email | And an eligible notification email is sent to h***@gmail.com |  |
| CP106 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($1,200 CAD AC Wallet), Aeroplan confirmation, regulation (APPR), flight details |  |
| CP107 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP108 | END FLOW (GLOB-11) | customer | chat | And the user selects ""No"" | No |
| CP109 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds ""Thank you for choosing Air Canada."" | Thank you for choosing Air Canada. |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant ""Hugo Villeneuve"" with PNR ""TC003"" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be ""Travel Disruptions � Delay"" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be ""In Review"" or ""Done"" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be ""Hugo Villeneuve"" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be ""Adult"" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be ""Pass"" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be ""TC003"" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be ""APPR"" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be ""Hugo Villeneuve"" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be ""h***@gmail.com"" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be ""+1***234"" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be ""9876543210"" linked and in good standing |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be ""75K"" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show ""Bound 1: YUL ? YOW ? YYZ"" as a 2-leg connecting flight with claim filed |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Rebooking Pattern should be ""ONE_TO_MANY"" where original direct YUL to YYZ was split into connecting YUL to YOW to YYZ |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated for this automated FD case |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be ""No duplicate found"" |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be ""GREEN"" |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record to the case automatically for identified and authenticated user |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case function from My Activities to get this case |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from ""Assigned"" to ""In Progress"" |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent to the customer |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be ""Resolved"" |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP164 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is ""Canada"" |  |
| CP165 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to ""CAD"" |  |
| CP166 | PAYMENT VALIDATION | payment | chat | And the customer has Aeroplan ""9876543210"" linked with ""75K"" status in good standing |  |
| CP167 | PAYMENT VALIDATION | payment | chat | And both options should be offered: Cash at $1,000 CAD and AC Wallet at $1,200 CAD with 20% top-up |  |
| CP168 | PAYMENT VALIDATION | payment | chat | And the customer selects ""AC Wallet"" |  |
| CP169 | PAYMENT VALIDATION | payment | chat | And the 20% top-up should be applied converting $1,000 base to $1,200 CAD |  |
| CP170 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created |  |
| CP171 | PAYMENT VALIDATION | payment | manual | And the record should be picked up by the daily evening batch file |  |
| CP172 | PAYMENT VALIDATION | payment | manual | And the record should be dispatched to EIP |  |
| CP173 | PAYMENT VALIDATION | payment | chat | And EIP should convert from CAD to the customer's Aeroplan profile currency if applicable |  |
| CP174 | PAYMENT VALIDATION | payment | chat | And EIP should check Aeroplan account validity confirming it is active and not frozen |  |
| CP175 | PAYMENT VALIDATION | payment | chat | And EIP should send to iGiga |  |
| CP176 | PAYMENT VALIDATION | payment | chat | And iGiga should send to iFly for deposit |  |
| CP177 | PAYMENT VALIDATION | payment | chat | And iFly should talk back to EIP |  |
| CP178 | PAYMENT VALIDATION | payment | chat | And EIP should talk back to Claims Dashboard with deposited amount ($1,200 CAD), exchange rate used, and status ""Completed"" or ""Issued"" |  |
| CP179 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show the correct amount ($1,200 CAD) |  |
| CP180 | PAYMENT VALIDATION | payment | chat | And the currency should be displayed as ""CAD"" |  |
| CP181 | PAYMENT VALIDATION | payment | chat | And the payment method should show ""AC Wallet"" |  |
| CP182 | PAYMENT VALIDATION | payment | chat | And the status should be updated |  |
| CP183 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-01. | DDS returns FD-APPR-EL-01. |
| CP184 | EXPECTED RESULTS | verdict | chat | Rebooking: ONE_TO_MANY (1?2 legs) � original direct YUL?YYZ split into connecting YUL?YOW?YYZ. | Rebooking: ONE_TO_MANY (1?2 legs) � original direct YUL?YYZ split into connecting YUL?YOW?YYZ. |
| CP185 | EXPECTED RESULTS | verdict | api | Promise = 13:00 (last VOL before first INVOL, NOT 10:00 14-day mark); Actual final arrival at YYZ = 22:30; Delay = 9h 30m (22:30 - 13:00); C | Promise = 13:00 (last VOL before first INVOL, NOT 10:00 14-day mark); Actual final arrival at YYZ = 22:30; Delay = 9h 30m (22:30 - 13:00); Change History: VOL a |
| CP186 | EXPECTED RESULTS | verdict | api | CRITICAL: Promise must be 13:00, not 10:00. | CRITICAL: Promise must be 13:00, not 10:00. |
| CP187 | EXPECTED RESULTS | verdict | api | Delay measured at final destination YYZ, not intermediate YOW. | Delay measured at final destination YYZ, not intermediate YOW. |
| CP188 | EXPECTED RESULTS | verdict | chat | Compensation: $1,200 CAD via AC Wallet ($1,000 base Tier 3 + 20% top-up) or $1,000 CAD Cash. | Compensation: $1,200 CAD via AC Wallet ($1,000 base Tier 3 + 20% top-up) or $1,000 CAD Cash. |
| CP189 | EXPECTED RESULTS | verdict | chat | Tier Status = 75K recognized. | Tier Status = 75K recognized. |
