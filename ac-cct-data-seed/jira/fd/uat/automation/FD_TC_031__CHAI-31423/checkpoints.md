# FD_TC_031 · CHAI-31423 — checkpoints

**Goal:** Customer's original flight AC 435 YUL?YYZ was cancelled due to aircraft damage during ground handling (arrival delay code 31). Customer accepts rebooking to AC 436 YUL?YHM (Hamilton � sister city of YYZ). Actual arrival at YHM is 4 hours after original promised arrival at YYZ. Validates: (1) Sister city flag set when customer is rebooked to sister city airport, (2) Delay calculated as actual arrival at sister city (YHM) minus original promised arrival at original destination (YYZ), (3) DDS recognizes YHM?YYZ sister city mapping and does NOT reject claim because destination doesn't match, (4) Tier 1 ($400) applies for 4hr delay. Tests EL-04 response code.

Methods: seed 9, chat 62, api 21, email 3, dashboard 45, implied 21, manual 16, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer's original flight AC 435 YUL?YYZ was cancelled due to aircraft damage during ground handling (arrival delay code 31). Customer acce |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger, 1 leg AC domestic YUL?YYZ | PNR: Single passenger, 1 leg AC domestic YUL?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Original itinerary: AC 435 YUL?YYZ, Scheduled arrival: 14:00 at YYZ | Original itinerary: AC 435 YUL?YYZ, Scheduled arrival: 14:00 at YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Original flight AC 435 CANCELLED (arrival delay code: 31 � Aircraft Damage During Ground Handling) | Original flight AC 435 CANCELLED (arrival delay code: 31 � Aircraft Damage During Ground Handling) |
| CP005 | PREREQUISITES | prerequisite | seed | Customer offered rebooking options | Customer offered rebooking options |
| CP006 | PREREQUISITES | prerequisite | seed | Customer ACCEPTS rebooking to AC 436 YUL?YHM (Hamilton � sister city of YYZ) | Customer ACCEPTS rebooking to AC 436 YUL?YHM (Hamilton � sister city of YYZ) |
| CP007 | PREREQUISITES | prerequisite | seed | Rebooked flight AC 436 departs YUL and arrives YHM at 18:00 | Rebooked flight AC 436 departs YUL and arrives YHM at 18:00 |
| CP008 | PREREQUISITES | prerequisite | seed | Delay: 18:00 (YHM actual) ? 14:00 (YYZ original promise) = 4hrs | Delay: 18:00 (YHM actual) ? 14:00 (YYZ original promise) = 4hrs |
| CP009 | PREREQUISITES | prerequisite | seed | Sister city mapping: YHM ? YYZ configured in system | Sister city mapping: YHM ? YYZ configured in system |
| CP010 | PREREQUISITES | prerequisite | seed | Carrier: AC only | Carrier: AC only |
| CP011 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP012 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP013 | START | customer | chat | Then user selects English |  |
| CP014 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP015 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP016 | START | customer | chat | And the user says "My flight from Montreal to Toronto was cancelled and I was rebooked to a flight landing at Hamilton instead. I arrived 4  | My flight from Montreal to Toronto was cancelled and I was rebooked to a flight landing at Hamilton instead. I arrived 4 hours later than my original flight was |
| CP017 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP018 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP019 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP020 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "V�ronique Gagnon" | V�ronique Gagnon |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, V�ronique! And, what is your booking reference number? |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC023" | PNR: TC023 |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC023 |  |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: v***@gmail.com � Phone: +1***789 |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: v***@gmail.com" | Email: v***@gmail.com |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP034 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP036 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP037 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP039 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � V�ronique Gagnon (Adult) Is this who you'd like to include? |
| CP041 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP043 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 435 �Route: Montreal (YUL) ? Hamilton (YHM) [Rebooked � original destination: Toronto YYZ] � Date: May 9, 2026 � Arr |
| CP044 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP049 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 9, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 9, 2026; filing June 15, 2026 ? 37 days ? within 366 days ? PROCEED |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 435, Route: YUL ? YYZ, Scheduled Arrival: 14:00 at YYZ (original flight � CANCELLED) | Promised Itinerary - Flight: AC 435, Route: YUL ? YYZ, Scheduled Arrival: 14:00 at YYZ (original flight � CANCELLED) |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 436, Route: YUL ? YHM (rebooked to sister city), Status: ARRIVED, Actual Arrival: 18:00 at YHM | Current Itinerary - Flight: AC 436, Route: YUL ? YHM (rebooked to sister city), Status: ARRIVED, Actual Arrival: 18:00 at YHM |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | History - Change 1: INVOL � Original flight AC 435 YUL?YYZ cancelled (arrival delay code: 31 � Aircraft Damage During Ground Handling). Cust | History - Change 1: INVOL � Original flight AC 435 YUL?YYZ cancelled (arrival delay code: 31 � Aircraft Damage During Ground Handling). Customer accepted rebook |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Delay Calculation: Original promise = 14:00 at YYZ (AC 435); Actual arrival = 18:00 at YHM (AC 436, sister city); Delay = 4hrs | Delay Calculation: Original promise = 14:00 at YYZ (AC 435); Actual arrival = 18:00 at YHM (AC 436, sister city); Delay = 4hrs |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Sister City Check: YHM ? YYZ = VALID PAIR (confirmed in DDS sister city config) | Sister City Check: YHM ? YYZ = VALID PAIR (confirmed in DDS sister city config) |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Sister city accepted as equivalent destination | Sister city accepted as equivalent destination |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 435 � YUL ? YYZ � Arrival delay code: 31 | MSL FLIGHT: AC 435 � YUL ? YYZ � Arrival delay code: 31 |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | "Cancelled due to aircraft damage during ground handling" | "Cancelled due to aircraft damage during ground handling" |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Rebooked Flight: AC 436 � YUL ? YHM (sister city of YYZ) | Rebooked Flight: AC 436 � YUL ? YHM (sister city of YYZ) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +4H 00M � CONTROLLABLE | Delay: +4H 00M � CONTROLLABLE |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | MS V�RONIQUE GAGNON / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 / [expiry date] | MS V�RONIQUE GAGNON / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 / [expiry date] |
| CP066 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP067 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP068 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP069 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your original flight from Montreal (YUL) to Toronto (YYZ) was cancelled and you were rebooked to Hamilton (Y |
| CP070 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP071 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP072 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP073 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP074 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP075 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP076 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP077 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP078 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac (CANADA) |  |
| CP079 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP080 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP081 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP085 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP086 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP087 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP088 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP089 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP090 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP091 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP092 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: v***@gmail.com After submission, you will receive a confirmation email summarizing your eligibility, claim details and  |
| CP093 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP094 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP095 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP096 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP097 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP098 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP099 | NOTIFICATION | email | email | And an eligible notification email is sent to v***@gmail.com |  |
| CP100 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details (including sister city note: YHM f |  |
| CP101 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP102 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP103 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "V�ronique Gagnon" with PNR "TC023" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "V�ronique Gagnon" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC023" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "V�ronique Gagnon" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "v***@gmail.com" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***789" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated for this automated FD case |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "V�ronique Gagnon + TC023 + YUL?YYZ + FD" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP158 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP159 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP160 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP161 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "$400" for Tier 1 delay of 3 to less than 6 hours |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP164 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP165 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP166 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP167 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received from Interac |  |
| CP168 | PAYMENT VALIDATION | payment | manual | And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP169 | PAYMENT VALIDATION | payment | manual | And if the payment is unclaimed after 35 days the status should be set to "Expired" |  |
| CP170 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show "$400" CAD |  |
| CP171 | PAYMENT VALIDATION | payment | chat | And the payment method should show "Cash" via "Interac" |  |
| CP172 | PAYMENT VALIDATION | payment | manual | And the status should be updated via talkback |  |
| CP173 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-04. | DDS returns FD-APPR-EL-04. |
| CP174 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 14:00 at YYZ (original flight AC 435, CANCELLED); Actual = 18:00 at YHM (rebooked flight AC 436, sister city); Sister | Trip Tracer: Promise = 14:00 at YYZ (original flight AC 435, CANCELLED); Actual = 18:00 at YHM (rebooked flight AC 436, sister city); Sister City = TRUE (YHM?YY |
| CP175 | EXPECTED RESULTS | verdict | chat | Change History: INVOL � AC 435 cancelled ? customer accepted rebooking to AC 436 YUL?YHM. | Change History: INVOL � AC 435 cancelled ? customer accepted rebooking to AC 436 YUL?YHM. |
| CP176 | EXPECTED RESULTS | verdict | chat | CRITICAL: System must recognize YHM as sister city of YYZ and NOT reject claim because destination doesn't match. | CRITICAL: System must recognize YHM as sister city of YYZ and NOT reject claim because destination doesn't match. |
| CP177 | EXPECTED RESULTS | verdict | chat | Compensation: $400 CAD (Tier 1). | Compensation: $400 CAD (Tier 1). |
| CP178 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Sister City flag = TRUE; Original destination = YYZ; Actual arrival = YHM; DDS = FD-APPR-EL-04. | Claims Dashboard: Sister City flag = TRUE; Original destination = YYZ; Actual arrival = YHM; DDS = FD-APPR-EL-04. |
