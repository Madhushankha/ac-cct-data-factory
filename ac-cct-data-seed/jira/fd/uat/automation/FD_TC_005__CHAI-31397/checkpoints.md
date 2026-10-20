# FD_TC_005 · CHAI-31397 — checkpoints

**Goal:** Validates an eligible flight disruption scenario for a single passenger on a single domestic AC leg delayed 4 hours due to a controllable reason (Code 67), where the customer selects AC Wallet instead of Cash. Validates that when the customer has an active Aeroplan account (Elite 50K) linked and in good standing, the AC Wallet option is offered with a 20% top-up ($480 total). Confirms DDS correctly identifies the APPR regime, controllable classification, and Tier 1 delay band. Confirms EAP (E-credit Application Platform) check passes, CyberSource returns GREEN for auto-approval, and $480 CAD is deposited to the Aeroplan profile.

Methods: seed 11, chat 69, api 16, email 3, dashboard 44, implied 22, manual 11, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates an eligible flight disruption scenario for a single passenger on a single domestic AC leg delayed 4 hours due to a controllable re |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Marie-Claire Dubois), 1 leg AC domestic YUL?YYZ | PNR: Single passenger (Marie-Claire Dubois), 1 leg AC domestic YUL?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: Scheduled arrival 14:00, Actual arrival 18:00 (4hr delay) | Itinerary: Scheduled arrival 14:00, Actual arrival 18:00 (4hr delay) |
| CP004 | PREREQUISITES | prerequisite | seed | Arrival delay code: 67(Crew) on arrival | Arrival delay code: 67(Crew) on arrival |
| CP005 | PREREQUISITES | prerequisite | seed | Flight status: Arrived (operated) | Flight status: Arrived (operated) |
| CP006 | PREREQUISITES | prerequisite | seed | Booking changes: None � no VOL or INVOL | Booking changes: None � no VOL or INVOL |
| CP007 | PREREQUISITES | prerequisite | seed | Carrier: AC only | Carrier: AC only |
| CP008 | PREREQUISITES | prerequisite | seed | 72hrs: Elapsed (filed D+13) | 72hrs: Elapsed (filed D+13) |
| CP009 | PREREQUISITES | prerequisite | seed | Time limit: Within 366 days | Time limit: Within 366 days |
| CP010 | PREREQUISITES | prerequisite | seed | No duplicate case | No duplicate case |
| CP011 | PREREQUISITES | prerequisite | seed | Not employee, not infant | Not employee, not infant |
| CP012 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked to booking (Elite 50K), account in good standing (NOT frozen) | Aeroplan: Linked to booking (Elite 50K), account in good standing (NOT frozen) |
| CP013 | PREREQUISITES | prerequisite | implied | CyberSource: Configured to return GREEN | CyberSource: Configured to return GREEN |
| CP014 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP015 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | "Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP016 | START | customer | chat | Then user selects English |  |
| CP017 | START | alert | chat | Then an alert information is displayed " Please note  that by using this service, you will interact with an automated chatbot which uses AI  |  Please note  that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informa |
| CP018 | START | system | implied | Then chatbot ask "How can I help you today?" |  |
| CP019 | START | customer | chat | And the user says "My flight was delayed about 4 hours, I'd like to check if I'm eligible for compensation and I'd prefer to get it on my Ae | My flight was delayed about 4 hours, I'd like to check if I'm eligible for compensation and I'd prefer to get it on my Aeroplan account |
| CP020 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP021 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP022 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP023 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Marie-Claire Dubois" | Marie-Claire Dubois |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Marie-Claire! And, what is your booking reference number? |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC002" | PNR: TC002 |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC002 |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: m***@gmail.com � Phone: +1***234 |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: m***@gmail.com" | Email: m***@gmail.com |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482916" | 482916 |
| CP037 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP039 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP041 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP043 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Marie-Claire Dubois (Adult) Is this who you'd like to include? |
| CP044 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP046 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 302 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: January 15, 2026 � Arrival Delay: 4 hours Is this the journey yo |
| CP047 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP050 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP051 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP052 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was January 15, 2026; current date is January 28, 2026 ? 312 hours ? >72 hours ? PROCEED |  |
| CP053 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP054 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption January 15, 2026; filing January 28, 2026 ? 13 days ? within 366 days ? PROCEED |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 302, Route: YUL ? YYZ, Scheduled Arrival: 14:00 | Promised Itinerary - Flight: AC 302, Route: YUL ? YYZ, Scheduled Arrival: 14:00 |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 302, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: ~~14:00~~ ? Actual: 18:00, Delay: +4H 00M | Current Itinerary - Flight: AC 302, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: ~~14:00~~ ? Actual: 18:00, Delay: +4H 00M |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 302 � YUL ? YYZ � 67 | MSL FLIGHT: AC 302 � YUL ? YYZ � 67 |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to Crew " | "Delayed due to Crew " |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +4H 00M � CONTROLLABLE | Delay: +4H 00M � CONTROLLABLE |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | MS MARIE-CLAIRE DUBOIS / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 480.00 (Wallet) / [expiry date] | MS MARIE-CLAIRE DUBOIS / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 480.00 (Wallet) / [expiry date] |
| CP064 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP065 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP066 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP067 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 302 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours . Based on the Air Passenger |
| CP068 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP069 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP070 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP071 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (Aeroplan #: 9876546710) |  |
| CP072 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Aeroplan account in good standing? ? YES |  |
| CP073 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot offers BOTH options: | Since you have an AC wallet, you can choose to either recieve: � Cash: CAD $400 will be compensated and takes 5 to 10 business days to process the payment. � AC |
| CP074 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And the user selects "AC Wallet" | AC Wallet |
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
| CP085 | CLAIM AMOUNT CONFIRMATION | bot | chat | Then the chatbot responds: "Thank you. You will be receiving $400 CAD converted into the currency associatedto your profile. | Deposit Amount: $480 CAD Payment Method: AC Wallet Would you like me to submit your claim?" |
| CP086 | CLAIM AMOUNT CONFIRMATION | alert | chat | And an alert information is displayed: "Please note that payment details cannot be changed after submission" | Please note that payment details cannot be changed after submission |
| CP087 | CLAIM AMOUNT CONFIRMATION | customer | chat | When the user clicks on "Yes" | Yes |
| CP088 | CASE CREATION (GLOB-09) | bot | chat | Then chatbot responds: "Thank you. Your claim has been submitted and will be processed within 10 business days. | A confirmation email will be sent to you with details on how to monitor your claim status and payment updates. Please refer to that email for any follow-up info |
| CP089 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP090 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP091 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP092 | NOTIFICATION | email | email | And an eligible notification email is sent to m***@gmail.com |  |
| CP093 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($480 AC Wallet), Aeroplan confirmation, regulation (APPR), flight details, trac |  |
| CP094 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP095 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP096 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Marie-Claire Dubois" with PNR "TC002" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" mapped from chatbot intent |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Marie-Claire Dubois" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC002" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Marie-Claire Dubois" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "m***@gmail.com" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***234" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "9876546710" linked and in good standing |  |
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
| CP152 | PAYMENT VALIDATION | payment | chat | And the customer has Aeroplan "9876546710" linked and in good standing |  |
| CP153 | PAYMENT VALIDATION | payment | chat | And both options should be offered: Cash at $400 and AC Wallet at $480 with 20% top-up |  |
| CP154 | PAYMENT VALIDATION | payment | chat | And the customer selects "AC Wallet" |  |
| CP155 | PAYMENT VALIDATION | payment | chat | And the 20% top-up should be applied converting $400 to $480 |  |
| CP156 | PAYMENT VALIDATION | payment | chat | And AC Wallet should only be offered because this is flight disruption APPR |  |
| CP157 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created |  |
| CP158 | PAYMENT VALIDATION | payment | manual | And the record should be picked up by the daily evening batch file |  |
| CP159 | PAYMENT VALIDATION | payment | manual | And the record should be dispatched to EIP and NOT Unifier |  |
| CP160 | PAYMENT VALIDATION | payment | chat | And EIP should convert from CAD to the customer's Aeroplan profile country currency |  |
| CP161 | PAYMENT VALIDATION | payment | chat | And EIP should check Aeroplan account validity confirming it is active and not frozen |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And EIP should send to iGiga |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And iGiga should send to iFly for deposit |  |
| CP164 | PAYMENT VALIDATION | payment | chat | And iFly should talk back to EIP |  |
| CP165 | PAYMENT VALIDATION | payment | chat | And EIP should talk back to Claims Dashboard with deposited amount, exchange rate used, and status "Completed" or "Issued" |  |
| CP166 | PAYMENT VALIDATION | payment | chat | And if the Aeroplan account is frozen or closed a rejection with error message should be returned |  |
| CP167 | PAYMENT VALIDATION | payment | chat | And a failure notification should be sent to the case |  |
| CP168 | PAYMENT VALIDATION | payment | chat | And the agent should be flagged |  |
| CP169 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show the correct amount |  |
| CP170 | PAYMENT VALIDATION | payment | chat | And the currency should be displayed |  |
| CP171 | PAYMENT VALIDATION | payment | chat | And the payment method should show "AC Wallet" |  |
| CP172 | PAYMENT VALIDATION | payment | chat | And the status should be updated |  |
| CP173 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-01. | DDS returns FD-APPR-EL-01. |
| CP174 | EXPECTED RESULTS | verdict | api | Trip Tracer: Same as TC_001 � Promise 14:00, Actual 18:00, 4hrs, MSL Leg 1, Code 67, Controllable, APPR. | Trip Tracer: Same as TC_001 � Promise 14:00, Actual 18:00, 4hrs, MSL Leg 1, Code 67, Controllable, APPR. |
| CP175 | EXPECTED RESULTS | verdict | chat | Compensation: $480 CAD via AC Wallet ($400 base + 20% top-up). | Compensation: $480 CAD via AC Wallet ($400 base + 20% top-up). |
| CP176 | EXPECTED RESULTS | verdict | chat | EAP check: Account active, deposit successful. | EAP check: Account active, deposit successful. |
| CP177 | EXPECTED RESULTS | verdict | api | Claims Dashboard: $480 AC Wallet; Aeroplan confirmed; All other DDS values same as TC_001. | Claims Dashboard: $480 AC Wallet; Aeroplan confirmed; All other DDS values same as TC_001. |
