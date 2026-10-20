# FD_TC_008 · CHAI-31400 — checkpoints

**Goal:** After airline made an INVOL change that rerouted a 2-leg connecting itinerary through a different connection point (MANY_TO_MANY: YUL?YOW?YYZ ? YUL?YKF?YYZ), customer voluntarily chose an EARLIER connecting itinerary (negative VOL � trying to arrive sooner). The customer's time is NOT deducted because they were mitigating the delay. Validates: (1) DDS does NOT apply deduction for negative VOL, (2) MANY_TO_MANY rebooking pattern correctly handled � same number of legs but different connection, (3) Delay measured at final destination YYZ, (4) Segment check triggers for multi-leg journey.

Methods: seed 11, chat 63, api 10, email 3, dashboard 44, implied 22, manual 15, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | After airline made an INVOL change that rerouted a 2-leg connecting itinerary through a different connection point (MANY_TO_MANY: YUL?YOW?YY |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC005 � Val�rie Dupont (Adult) | PNR: TC005 � Val�rie Dupont (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Original (14-day): 2 legs connecting: Leg 1 AC 8103 YUL?YOW dep 08:00 arr 09:00; Leg 2 AC 8203 YOW?YYZ dep 09:30 arr 10:00 | Original (14-day): 2 legs connecting: Leg 1 AC 8103 YUL?YOW dep 08:00 arr 09:00; Leg 2 AC 8203 YOW?YYZ dep 09:30 arr 10:00 |
| CP004 | PREREQUISITES | prerequisite | seed | Promise = 10:00 (14-day mark) | Promise = 10:00 (14-day mark) |
| CP005 | PREREQUISITES | prerequisite | seed | Change 1 (D-3): INVOL � AC rerouted through different connection (MANY_TO_MANY: 2?2 legs, connection change): Leg 1 AC 8301 YUL?YKF dep 12:0 | Change 1 (D-3): INVOL � AC rerouted through different connection (MANY_TO_MANY: 2?2 legs, connection change): Leg 1 AC 8301 YUL?YKF dep 12:00 arr 13:30; Leg 2 A |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival at YYZ = 17:00 | Arrival at YYZ = 17:00 |
| CP007 | PREREQUISITES | prerequisite | seed | Change 2 (D-1): VOL � customer moves to EARLIER connecting itinerary: Leg 1 AC 8302 YUL?YKF dep 10:00 arr 11:30; Leg 2 AC 8402 YKF?YYZ dep 1 | Change 2 (D-1): VOL � customer moves to EARLIER connecting itinerary: Leg 1 AC 8302 YUL?YKF dep 10:00 arr 11:30; Leg 2 AC 8402 YKF?YYZ dep 12:30 arr 15:00 (-2hr |
| CP008 | PREREQUISITES | prerequisite | seed | Actual arrival at YYZ: 15:00 | Actual arrival at YYZ: 15:00 |
| CP009 | PREREQUISITES | prerequisite | seed | Total delay = 15:00 - 10:00 = 5hrs | Total delay = 15:00 - 10:00 = 5hrs |
| CP010 | PREREQUISITES | prerequisite | seed | Post-INVOL VOL = -2hrs (NEGATIVE ? NOT DEDUCTED) | Post-INVOL VOL = -2hrs (NEGATIVE ? NOT DEDUCTED) |
| CP011 | PREREQUISITES | prerequisite | seed | Net delay = 5hrs (full delay, no deduction) | Net delay = 5hrs (full delay, no deduction) |
| CP012 | PREREQUISITES | prerequisite | seed | Arrival delay code on MSL (Leg 2): 62 (Operational Requirements � Controllable) | Arrival delay code on MSL (Leg 2): 62 (Operational Requirements � Controllable) |
| CP013 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP014 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP015 | START | customer | chat | Then user selects English |  |
| CP016 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP017 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP018 | START | customer | chat | And the user says "Air Canada rebooked me to a late flight but then I found an earlier one and changed myself. Can I get compensation?" | Air Canada rebooked me to a late flight but then I found an earlier one and changed myself. Can I get compensation? |
| CP019 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP020 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP021 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP022 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Val�rie Dupont" | Val�rie Dupont |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Val�rie! And, what is your booking reference number? |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC005" | PNR: TC005 |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC005 |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: v***@gmail.com Phone: +1***234 |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: v***@gmail.com" | Email: v***@gmail.com |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482916" | 482916 |
| CP036 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP038 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Val�rie Dupont (Adult) Is this who you'd like to include? |
| CP043 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP045 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Segment 1: Flight AC 8302, Montreal (YUL) ? Kitchener-Waterloo (YKF), May 10, 2026 � COMPLETED Segment 2: Flight AC 8402, Kitchen |
| CP046 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP047 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments � MANY_TO_MANY rebooking, connection change) |  |
| CP048 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED (YUL?YKF), Segment 2 ARRIVED LATE (YKF?YYZ) |  |
| CP049 | SEGMENT CHECK (GenUC-18) | verdict | api | Then the chatbot determines: Final destination = YYZ; Final arrival delay = 5h; MSL = Leg 2 (YKF?YYZ) |  |
| CP050 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP052 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP053 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 10, 2026; current date is June 4, 2026 ? >72 hours ? PROCEED |  |
| CP054 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP055 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 10, 2026; filing June 4, 2026 ? within 366 days ? PROCEED |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC005 | Delayed due to operational requirements |
| CP059 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP060 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP061 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP062 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your journey from Montreal (YUL) to Toronto (YYZ) via Kitchener-Waterloo (YKF) was delayed by about 5 hours. |
| CP063 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP064 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP065 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP066 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP067 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP068 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP069 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP070 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP071 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac (CANADA) |  |
| CP072 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP073 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP074 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP075 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP076 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP077 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP078 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP085 | CLAIM AMOUNT CONFIRMATION | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: v***@gmail.com Would you like me to submit your claim?" |
| CP086 | CLAIM AMOUNT CONFIRMATION | alert | chat | And an alert information is displayed: "Please note that payment details cannot be changed after submission" | Please note that payment details cannot be changed after submission |
| CP087 | CLAIM AMOUNT CONFIRMATION | customer | chat | When the user clicks on "Yes" | Yes |
| CP088 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP089 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP090 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP091 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP092 | NOTIFICATION | email | email | And an eligible notification email is sent to v***@gmail.com |  |
| CP093 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details (MANY_TO_MANY rebooking: original  |  |
| CP094 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP095 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP096 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Val�rie Dupont" with PNR "TC005" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" mapped from chatbot intent |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Val�rie Dupont" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC005" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Val�rie Dupont" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "v***@gmail.com" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***234" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated for this automated FD case |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record to the case automatically for identified and authenticated user |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case function from My Activities to get this case |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent to the customer |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP150 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP151 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP152 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP153 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP154 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created |  |
| CP155 | PAYMENT VALIDATION | payment | manual | And the record should be picked up by the daily evening batch file |  |
| CP156 | PAYMENT VALIDATION | payment | manual | And the record should be dispatched to Unifier |  |
| CP157 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP158 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received from Interac |  |
| CP159 | PAYMENT VALIDATION | payment | manual | And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP160 | PAYMENT VALIDATION | payment | manual | And if the customer does not claim the Interac payment within 35 days the status should be set to "Expired" |  |
| CP161 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show the correct amount |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And the currency should be displayed |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And the payment method should show "Cash" |  |
| CP164 | PAYMENT VALIDATION | payment | chat | And the status should be updated |  |
| CP165 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-01. | DDS returns FD-APPR-EL-01. |
| CP166 | EXPECTED RESULTS | verdict | chat | Rebooking: MANY_TO_MANY (2?2 legs, connection change) � original 2-leg YUL?YOW?YYZ rerouted to 2-leg YUL?YKF?YYZ (different connection point | Rebooking: MANY_TO_MANY (2?2 legs, connection change) � original 2-leg YUL?YOW?YYZ rerouted to 2-leg YUL?YKF?YYZ (different connection point). |
| CP167 | EXPECTED RESULTS | verdict | api | Promise = 10:00 (14-day mark); Actual final arrival at YYZ = 15:00; Total delay = 5hrs; Post-INVOL VOL = -2hrs (NEGATIVE ? NOT DEDUCTED � cu | Promise = 10:00 (14-day mark); Actual final arrival at YYZ = 15:00; Total delay = 5hrs; Post-INVOL VOL = -2hrs (NEGATIVE ? NOT DEDUCTED � customer was mitigatin |
| CP168 | EXPECTED RESULTS | verdict | chat | CRITICAL: Negative VOL must NOT reduce the delay. | CRITICAL: Negative VOL must NOT reduce the delay. |
| CP169 | EXPECTED RESULTS | verdict | chat | Compensation: $400 CAD (Tier 1, 3�<6hrs). | Compensation: $400 CAD (Tier 1, 3�<6hrs). |
