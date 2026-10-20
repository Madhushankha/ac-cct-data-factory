# FD_TC_044 · CHAI-31436 — checkpoints

**Goal:** Two-leg domestic journey where Leg 2 is cancelled. Customer is stranded at midpoint (YYZ) � they neither reached their destination (YVR) nor returned to origin (YUL). Validates DDS correctly identifies No Travel Incomplete status, which is the most complex No Travel scenario since customer is at neither endpoint.

Methods: seed 8, chat 73, api 21, email 3, dashboard 45, implied 23, manual 23, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Two-leg domestic journey where Leg 2 is cancelled. Customer is stranded at midpoint (YYZ) � they neither reached their destination (YVR) nor |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (�mile Gagnon), 2 segments AC domestic YUL?YYZ?YVR within one bound | PNR: Single passenger (�mile Gagnon), 2 segments AC domestic YUL?YYZ?YVR within one bound |
| CP003 | PREREQUISITES | prerequisite | seed | Seg 1 (AC 450, YUL?YYZ): Operated, on time | Seg 1 (AC 450, YUL?YYZ): Operated, on time |
| CP004 | PREREQUISITES | prerequisite | seed | Seg 2 (AC 451, YYZ?YVR): CANCELLED | Seg 2 (AC 451, YYZ?YVR): CANCELLED |
| CP005 | PREREQUISITES | prerequisite | seed | Cancellation code: EQUI(Equipment issue) | Cancellation code: EQUI(Equipment issue) |
| CP006 | PREREQUISITES | prerequisite | seed | Customer action: Stayed at YYZ (midpoint) | Customer action: Stayed at YYZ (midpoint) |
| CP007 | PREREQUISITES | prerequisite | seed | Did NOT return to YUL | Did NOT return to YUL |
| CP008 | PREREQUISITES | prerequisite | seed | Did NOT reach YVR | Did NOT reach YVR |
| CP009 | PREREQUISITES | prerequisite | seed | No Travel status: Incomplete | No Travel status: Incomplete |
| CP010 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP011 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP012 | START | customer | chat | Then user selects English |  |
| CP013 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP014 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP015 | START | customer | chat | And the user says "I flew from Montreal to Toronto but my connecting flight from Toronto to Vancouver was cancelled and I didn't take any re | I flew from Montreal to Toronto but my connecting flight from Toronto to Vancouver was cancelled and I didn't take any replacement. Can I get compensation? |
| CP016 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP017 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP018 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP019 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP022 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "�mile Gagnon" | �mile Gagnon |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, �mile! And, what is your booking reference number? |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC034" | PNR: TC034 |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC034 |  |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: e***@gmail.com � Phone: +1***012 |
| CP030 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: e***@gmail.com" | Email: e***@gmail.com |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP033 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP035 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP036 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP037 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP038 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP039 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � �mile Gagnon (Adult) Is this who you'd like to include? |
| CP040 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP041 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP042 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Segment 1: Flight AC 450, Montreal (YUL) ? Toronto (YYZ), May 20, 2026 � COMPLETED � Segment 2: Flight AC 451, Toronto (YYZ) ?  |
| CP043 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP045 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 CANCELLED |  |
| CP046 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot determines: Claim applies to Segment 2 (AC 451 YYZ?YVR � CANCELLED) |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure of cancelled segment |  |
| CP050 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure was May 20, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 20, 2026; filing June 15, 2026 ? 26 days ? within 366 days ? PROCEED |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Segment 1: Flight: AC 450, Route: YUL ? YYZ, Status: COMPLETED | Segment 1: Flight: AC 450, Route: YUL ? YYZ, Status: COMPLETED |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Segment 2: Flight: AC 451, Route: YYZ ? YVR, Status: CANCELLED (claim filed) | Segment 2: Flight: AC 451, Route: YYZ ? YVR, Status: CANCELLED (claim filed) |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Customer Status: NO TRAVEL - INCOMPLETE (started journey, stranded at connection YYZ) | Customer Status: NO TRAVEL - INCOMPLETE (started journey, stranded at connection YYZ) |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | History - No rebooking accepted for connecting segment | History - No rebooking accepted for connecting segment |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 451 � YYZ ? YVR � EQUI | MSL FLIGHT: AC 451 � YYZ ? YVR � EQUI |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | "Cancellation � Equipment issue" | "Cancellation � Equipment issue" |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (EQUI) | CONTROLLABLE (EQUI) |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Disruption Type: CANCELLATION (mid-journey) | Disruption Type: CANCELLATION (mid-journey) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | APPR No Travel Incomplete: Controllable cancellation = flat $400 | APPR No Travel Incomplete: Controllable cancellation = flat $400 |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | MR �MILE GAGNON / ELIGIBLE / NO_TRAVEL_INCOMPLETE / CAD 400.00 / [expiry date] | MR �MILE GAGNON / ELIGIBLE / NO_TRAVEL_INCOMPLETE / CAD 400.00 / [expiry date] |
| CP067 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP068 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP069 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP070 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 451 from Toronto (YYZ) to Vancouver (YVR) on May 20, 2026 was cancelled. Based on the Air Passenge |
| CP071 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP072 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP073 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP074 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP075 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP076 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP077 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP078 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP079 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac (CANADA) |  |
| CP080 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP081 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP082 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP085 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP086 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP087 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP088 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP089 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP090 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP091 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP092 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP093 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: e***@gmail.com After submission, you will receive a confirmation email summarizing your eligibility, claim details and  |
| CP094 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP095 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP096 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP097 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP098 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP099 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP100 | NOTIFICATION | email | email | And an eligible notification email is sent to e***@gmail.com |  |
| CP101 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details (YYZ?YVR CANCELLED, connecting seg |  |
| CP102 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP103 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP104 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "�mile Gagnon" with PNR "TC034" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "�mile Gagnon" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC034" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "�mile Gagnon" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "e***@gmail.com" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***012" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: YUL ? YYZ" as completed and "Segment 2: YYZ ? YVR" with claim filed for this flight |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated for this automated FD case |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "�mile Gagnon + TC034 + YYZ?YVR + FD" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP159 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP160 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP161 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "$400" as a flat No Travel amount |  |
| CP164 | PAYMENT VALIDATION | payment | chat | And this is a No Travel case so both compensation and refund should be processed |  |
| CP165 | PAYMENT VALIDATION | payment | chat | And a PS agent task should be created in Claims Dashboard for the refund |  |
| CP166 | PAYMENT VALIDATION | payment | chat | And the agent should action the refund in ARD Web and mark it as refunded |  |
| CP167 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created |  |
| CP168 | PAYMENT VALIDATION | payment | manual | And the record should be picked up by the daily evening batch file |  |
| CP169 | PAYMENT VALIDATION | payment | manual | And the record should be dispatched to Unifier |  |
| CP170 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually |  |
| CP171 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP172 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received from Interac |  |
| CP173 | PAYMENT VALIDATION | payment | manual | And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP174 | PAYMENT VALIDATION | payment | manual | And if the payment is unclaimed after 35 days the status should be set to "Expired" |  |
| CP175 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show "$400" CAD with payment method "Cash" via "Interac" and status updated |  |
| CP176 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show a refund record with PS agent task status tracked separately    Given the customer's country of residen |  |
| CP177 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP178 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP179 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP180 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "$400" as a flat No Travel amount |  |
| CP181 | PAYMENT VALIDATION | payment | chat | And this is a No Travel case so both compensation and refund should be processed |  |
| CP182 | PAYMENT VALIDATION | payment | chat | And a PS agent task should be created in Claims Dashboard for the refund |  |
| CP183 | PAYMENT VALIDATION | payment | chat | And the agent should action the refund in ARD Web and mark it as refunded |  |
| CP184 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created |  |
| CP185 | PAYMENT VALIDATION | payment | manual | And the record should be picked up by the daily evening batch file |  |
| CP186 | PAYMENT VALIDATION | payment | manual | And the record should be dispatched to Unifier |  |
| CP187 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually |  |
| CP188 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP189 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received from Interac |  |
| CP190 | PAYMENT VALIDATION | payment | manual | And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP191 | PAYMENT VALIDATION | payment | manual | And if the payment is unclaimed after 35 days the status should be set to "Expired" |  |
| CP192 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show "$400" CAD with payment method "Cash" via "Interac" and status updated |  |
| CP193 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show a refund record with PS agent task status tracked separately |  |
| CP194 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-17. | DDS returns FD-APPR-EL-17. |
| CP195 | EXPECTED RESULTS | verdict | api | Trip Tracer: Leg 1 = Operated; Leg 2 = CANCELLED; MSL = Leg 2; Cancellation Code = EQUI; Controllable; No Travel = TRUE; Status = Incomplete | Trip Tracer: Leg 1 = Operated; Leg 2 = CANCELLED; MSL = Leg 2; Cancellation Code = EQUI; Controllable; No Travel = TRUE; Status = Incomplete (stranded at midpoi |
| CP196 | EXPECTED RESULTS | verdict | chat | Compensation: Per APPR No Travel Incomplete rules. | Compensation: Per APPR No Travel Incomplete rules. |
| CP197 | EXPECTED RESULTS | verdict | api | Claims Dashboard: No Travel = TRUE; Status = Incomplete; Stranded location = YYZ; DDS = FD-APPR-EL-17. | Claims Dashboard: No Travel = TRUE; Status = Incomplete; Stranded location = YYZ; DDS = FD-APPR-EL-17. |
