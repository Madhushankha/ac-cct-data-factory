# FD_TC_007 · CHAI-31399 — checkpoints

**Goal:** After the airline made an INVOL change that consolidated a 2-leg connecting itinerary into a single direct flight (MANY_TO_ONE: YUL?YOW?YYZ connecting ? YUL?YYZ direct), the customer voluntarily chose an even LATER direct flight (positive VOL). The extra time the customer added (+2hrs) is DEDUCTED from the total gross delay (9hrs), resulting in a net delay of 7 hours (6�<9h Tier 2 band). Customer has an active Basic Aeroplan account linked and opts for AC Wallet payout ($700 base + 20% = $840 CAD). Validates: (1) DDS applies positive VOL deduction correctly to compute net delay at destination YYZ, (2) MANY_TO_ONE rebooking pattern correctly handled � 2 legs consolidated into 1, (3) Promise stays at 14-day mark (10:00) because there was no VOL before INVOL, (4) Arrival delay code 32 (Ramp loading) evaluated as Controllable, (5) APPR Tier 2 compensation ($700 CAD cash / $840 CAD AC Wallet) offered, (6) AC Wallet EIP/iFly payment rail executed successfully.

Methods: seed 17, chat 67, api 24, email 3, dashboard 45, implied 22, manual 11, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | After the airline made an INVOL change that consolidated a 2-leg connecting itinerary into a single direct flight (MANY_TO_ONE: YUL?YOW?YYZ  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC004 � Camille Brosseau (Adult) | PNR: TC004 � Camille Brosseau (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Original (14-day): 2 legs connecting: Leg 1 AC 8102 YUL?YOW dep 08:00 arr 09:00; Leg 2 AC 8202 YOW?YYZ dep 09:30 arr 10:00 | Original (14-day): 2 legs connecting: Leg 1 AC 8102 YUL?YOW dep 08:00 arr 09:00; Leg 2 AC 8202 YOW?YYZ dep 09:30 arr 10:00 |
| CP004 | PREREQUISITES | prerequisite | seed | Promise = 10:00 (14-day mark final arrival at YYZ � no VOL before INVOL) | Promise = 10:00 (14-day mark final arrival at YYZ � no VOL before INVOL) |
| CP005 | PREREQUISITES | prerequisite | seed | Change 1 (D-3): INVOL � AC consolidated connecting into direct (MANY_TO_ONE: 2?1 leg): Direct AC 425 YUL?YYZ, arrival 17:00 | Change 1 (D-3): INVOL � AC consolidated connecting into direct (MANY_TO_ONE: 2?1 leg): Direct AC 425 YUL?YYZ, arrival 17:00 |
| CP006 | PREREQUISITES | prerequisite | seed | Change 2 (D-1): VOL � customer changes to even later direct flight AC 427 YUL?YYZ, arrival 19:00 (+2hrs added by customer) | Change 2 (D-1): VOL � customer changes to even later direct flight AC 427 YUL?YYZ, arrival 19:00 (+2hrs added by customer) |
| CP007 | PREREQUISITES | prerequisite | seed | Actual arrival: 19:00 | Actual arrival: 19:00 |
| CP008 | PREREQUISITES | prerequisite | seed | Total gross delay = 19:00 - 10:00 = 9hrs | Total gross delay = 19:00 - 10:00 = 9hrs |
| CP009 | PREREQUISITES | prerequisite | seed | Post-INVOL VOL deduction = +2hrs | Post-INVOL VOL deduction = +2hrs |
| CP010 | PREREQUISITES | prerequisite | seed | Net delay = 7hrs (9hrs - 2hrs) | Net delay = 7hrs (9hrs - 2hrs) |
| CP011 | PREREQUISITES | prerequisite | seed | Arrival delay code on MSL (AC 427): 32 (Ramp Loading � Controllable) | Arrival delay code on MSL (AC 427): 32 (Ramp Loading � Controllable) |
| CP012 | PREREQUISITES | prerequisite | seed | Flight status: Arrived (operated) | Flight status: Arrived (operated) |
| CP013 | PREREQUISITES | prerequisite | seed | Carrier: AC only | Carrier: AC only |
| CP014 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked (9876543210), Profile = Basic Member, account active and in good standing | Aeroplan: Linked (9876543210), Profile = Basic Member, account active and in good standing |
| CP015 | PREREQUISITES | prerequisite | seed | 72hrs: Elapsed (filed D+13) | 72hrs: Elapsed (filed D+13) |
| CP016 | PREREQUISITES | prerequisite | seed | Time limit: Within 366 days | Time limit: Within 366 days |
| CP017 | PREREQUISITES | prerequisite | seed | No duplicate case | No duplicate case |
| CP018 | PREREQUISITES | prerequisite | seed | Not employee, not infant | Not employee, not infant |
| CP019 | PREREQUISITES | prerequisite | implied | CyberSource: Configured to return GREEN | CyberSource: Configured to return GREEN |
| CP020 | PREREQUISITES | prerequisite | implied | RDS: No flags | RDS: No flags |
| CP021 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP022 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP023 | START | customer | chat | Then user selects English |  |
| CP024 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP025 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP026 | START | customer | chat | And the user says "Air Canada rebooked me after a disruption, then I changed to an even later flight myself. I'd like to claim compensation  | Air Canada rebooked me after a disruption, then I changed to an even later flight myself. I'd like to claim compensation for my delay and get it in my AC Wallet |
| CP027 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP028 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP029 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP030 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP031 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP032 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP033 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Camille Brosseau" | Camille Brosseau |
| CP034 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Camille! And, what is your booking reference number? |
| CP035 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC004" | PNR: TC004 |
| CP036 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC004 |  |
| CP037 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP038 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: c***@gmail.com � Phone: +1***234 |
| CP041 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: c***@gmail.com" | Email: c***@gmail.com |
| CP042 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP043 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482916" | 482916 |
| CP044 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP045 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP046 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP047 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP048 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP049 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP050 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Camille Brosseau (Adult - Aeroplan Member) Is this who you'd like to include? |
| CP051 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP052 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP053 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 427 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: May 10, 2026 � Arrival Delay: 7 hours (net, after adjustment for |
| CP054 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP055 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg � MANY_TO_ONE consolidated 2 legs into 1) ? skip GenUC-18 |  |
| CP056 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP057 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP058 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP059 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 10, 2026; current date is June 4, 2026 ? >72 hours ? PROCEED |  |
| CP060 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP061 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 10, 2026; filing June 4, 2026 ? within 366 days ? PROCEED |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP063 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Rebooking Pattern: MANY_TO_ONE (2?1 leg) � Original 2-leg connecting YUL?YOW?YYZ consolidated into direct YUL?YYZ | Rebooking Pattern: MANY_TO_ONE (2?1 leg) � Original 2-leg connecting YUL?YOW?YYZ consolidated into direct YUL?YYZ |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - 2-leg connecting: Leg 1 AC 8102 YUL?YOW arr 09:00; Leg 2 AC 8202 YOW?YYZ arr 10:00 (14-day mark final arrival, no VOL b | Promised Itinerary - 2-leg connecting: Leg 1 AC 8102 YUL?YOW arr 09:00; Leg 2 AC 8202 YOW?YYZ arr 10:00 (14-day mark final arrival, no VOL before INVOL) |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Flight AC 427, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual Arrival: 19:00 | Flight AC 427, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual Arrival: 19:00 |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Final Destination Arrival: YYZ at 19:00 | Final Destination Arrival: YYZ at 19:00 |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Total Gross Delay: +9H 00M (19:00 - 10:00 promise) | Total Gross Delay: +9H 00M (19:00 - 10:00 promise) |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | Post-INVOL VOL Deduction: +2H 00M (customer voluntarily chose later flight: 17:00?19:00 = +2hrs POSITIVE, DEDUCTED) | Post-INVOL VOL Deduction: +2H 00M (customer voluntarily chose later flight: 17:00?19:00 = +2hrs POSITIVE, DEDUCTED) |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Net Delay: +7H 00M (9hrs - 2hrs deduction) | Net Delay: +7H 00M (9hrs - 2hrs deduction) |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | Original (14-day): 2-leg connecting YUL?YOW?YYZ arr 10:00 | Original (14-day): 2-leg connecting YUL?YOW?YYZ arr 10:00 |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | Change 1 (Day -3): INVOL � AC consolidated connecting into direct YUL?YYZ (MANY_TO_ONE) ? arr 17:00 | Change 1 (Day -3): INVOL � AC consolidated connecting into direct YUL?YYZ (MANY_TO_ONE) ? arr 17:00 |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | Change 2 (Day -1): VOL � Customer changes to later direct flight ? arr 19:00 (+2hrs POSITIVE, DEDUCTED) | Change 2 (Day -1): VOL � Customer changes to later direct flight ? arr 19:00 (+2hrs POSITIVE, DEDUCTED) |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 427 � YUL ? YYZ � 32 | MSL FLIGHT: AC 427 � YUL ? YYZ � 32 |
| CP076 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to ramp loading operations" | "Delayed due to ramp loading operations" |
| CP077 | TRIP TRACER UI VALIDATION | verdict | api | Total Delay: +9H 00M � Post-INVOL VOL Deduction: +2H 00M � Net Delay: +7H 00M � CONTROLLABLE | Total Delay: +9H 00M � Post-INVOL VOL Deduction: +2H 00M � Net Delay: +7H 00M � CONTROLLABLE |
| CP078 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE � Sister City: FALSE | Fallback: FALSE � Sister City: FALSE |
| CP079 | TRIP TRACER UI VALIDATION | verdict | api | MS CAMILLE BROSSEAU / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 840.00 (Wallet) / CAD 700.00 (Cash) / [expiry date] | MS CAMILLE BROSSEAU / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 840.00 (Wallet) / CAD 700.00 (Cash) / [expiry date] |
| CP080 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP081 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP082 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP083 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 427 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7 hours (after accounting for your r |
| CP084 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP085 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP086 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP087 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (Aeroplan #: 9876543210, Status: Basic Member) |  |
| CP088 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Aeroplan account in good standing? ? YES |  |
| CP089 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot offers BOTH options: | Since you are an Aeroplan member, you can choose to either receive: � Cash: CAD $700 will be compensated and takes 5 to 10 business days to process the payment. |
| CP090 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And the user selects "AC Wallet" | AC Wallet |
| CP091 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP092 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP093 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP094 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP095 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP096 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP097 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP098 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP099 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP100 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP101 | CLAIM AMOUNT CONFIRMATION | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $840 CAD Payment Method: AC Wallet (Aeroplan #: 9876543210) Would you like me to submit your claim?" |
| CP102 | CLAIM AMOUNT CONFIRMATION | alert | chat | And an alert information is displayed: "Please note that payment details cannot be changed after submission." | Please note that payment details cannot be changed after submission. |
| CP103 | CLAIM AMOUNT CONFIRMATION | customer | chat | When the user provides: "Yes" | Yes |
| CP104 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 10 business days. A confirmat | Thank you. Your claim has been submitted and will now be processed within the next 10 business days. A confirmation email will be sent to you with details on ho |
| CP105 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP106 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP107 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP108 | NOTIFICATION | email | email | And an eligible notification email is sent to c***@gmail.com |  |
| CP109 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($840 CAD AC Wallet), Aeroplan confirmation, regulation (APPR), flight details ( |  |
| CP110 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP111 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP112 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Camille Brosseau" with PNR "TC004" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" mapped from chatbot intent |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Camille Brosseau" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC004" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Camille Brosseau" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "c***@gmail.com" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***234" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "9876543210" linked and in good standing |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be "Basic / Member" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Rebooking Pattern should be "MANY_TO_ONE" where original connecting YUL to YOW to YYZ was consolidated into direct YUL to YYZ |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated for this automated FD case |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record to the case automatically for identified and authenticated user |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case function from My Activities to get this case |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent to the customer |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP166 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP167 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP168 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP169 | PAYMENT VALIDATION | payment | chat | And the customer has Aeroplan "9876543210" linked with Basic status in good standing |  |
| CP170 | PAYMENT VALIDATION | payment | chat | And both options should be offered: Cash at $700 CAD and AC Wallet at $840 CAD with 20% top-up |  |
| CP171 | PAYMENT VALIDATION | payment | chat | And the customer selects "AC Wallet" |  |
| CP172 | PAYMENT VALIDATION | payment | chat | And the 20% top-up should be applied converting $700 base to $840 CAD |  |
| CP173 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created |  |
| CP174 | PAYMENT VALIDATION | payment | manual | And the record should be picked up by the daily evening batch file |  |
| CP175 | PAYMENT VALIDATION | payment | manual | And the record should be dispatched to EIP |  |
| CP176 | PAYMENT VALIDATION | payment | chat | And EIP should convert from CAD to customer's Aeroplan profile currency if applicable |  |
| CP177 | PAYMENT VALIDATION | payment | chat | And EIP should check Aeroplan account validity confirming it is active and not frozen |  |
| CP178 | PAYMENT VALIDATION | payment | chat | And EIP should send to iGiga |  |
| CP179 | PAYMENT VALIDATION | payment | chat | And iGiga should send to iFly for deposit |  |
| CP180 | PAYMENT VALIDATION | payment | chat | And iFly should talk back to EIP |  |
| CP181 | PAYMENT VALIDATION | payment | chat | And EIP should talk back to Claims Dashboard with deposited amount ($840 CAD), exchange rate used, and status "Completed" or "Issued" |  |
| CP182 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show the correct amount ($840 CAD) |  |
| CP183 | PAYMENT VALIDATION | payment | chat | And the currency should be displayed as "CAD" |  |
| CP184 | PAYMENT VALIDATION | payment | chat | And the payment method should show "AC Wallet" |  |
| CP185 | PAYMENT VALIDATION | payment | chat | And the status should be updated |  |
| CP186 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-01. | DDS returns FD-APPR-EL-01. |
| CP187 | EXPECTED RESULTS | verdict | chat | Rebooking: MANY_TO_ONE (2?1 leg) � original 2-leg connecting YUL?YOW?YYZ consolidated into direct YUL?YYZ. | Rebooking: MANY_TO_ONE (2?1 leg) � original 2-leg connecting YUL?YOW?YYZ consolidated into direct YUL?YYZ. |
| CP188 | EXPECTED RESULTS | verdict | api | Promise = 10:00 (14-day mark final arrival at YYZ, no VOL before INVOL); Actual = 19:00; Total gross delay = 9hrs; Post-INVOL VOL = +2hrs (P | Promise = 10:00 (14-day mark final arrival at YYZ, no VOL before INVOL); Actual = 19:00; Total gross delay = 9hrs; Post-INVOL VOL = +2hrs (POSITIVE ? DEDUCTED); |
| CP189 | EXPECTED RESULTS | verdict | chat | Compensation: $840 CAD via AC Wallet ($700 base Tier 2 + 20% top-up) or $700 CAD Cash. | Compensation: $840 CAD via AC Wallet ($700 base Tier 2 + 20% top-up) or $700 CAD Cash. |
| CP190 | EXPECTED RESULTS | verdict | chat | Basic Aeroplan profile recognized and active. | Basic Aeroplan profile recognized and active. |
