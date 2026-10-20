# FD_TC_015 · CHAI-31407 — checkpoints

**Goal:** PNR has 10+ passengers (group booking). System detects group booking identifier and restricts to individual claim only � other passengers are NOT displayed for privacy and compliance. Validates group booking detection and restriction logic.

Methods: seed 5, chat 58, api 15, email 3, dashboard 49, implied 19, manual 17, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | PNR has 10+ passengers (group booking). System detects group booking identifier and restricts to individual claim only � other passengers ar |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: 12 passengers (group booking with group identifier present), 1 leg AC domestic YUL?YYZ | PNR: 12 passengers (group booking with group identifier present), 1 leg AC domestic YUL?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: Scheduled arrival 14:00, Actual arrival 18:00 (4hr delay) | Itinerary: Scheduled arrival 14:00, Actual arrival 18:00 (4hr delay) |
| CP004 | PREREQUISITES | prerequisite | seed | Arrival delay code: 19 (Late Check-in) | Arrival delay code: 19 (Late Check-in) |
| CP005 | PREREQUISITES | prerequisite | seed | Claimant: Jean-Pierre Martin (1 of 12) | Claimant: Jean-Pierre Martin (1 of 12) |
| CP006 | PREREQUISITES | prerequisite | seed | Group booking flag: TRUE in PNR | Group booking flag: TRUE in PNR |
| CP007 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP008 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP009 | START | customer | chat | Then user selects English |  |
| CP010 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP011 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP012 | START | customer | chat | And the user says "Our group flight was delayed 4 hours, there are 12 of us, we want compensation" | Our group flight was delayed 4 hours, there are 12 of us, we want compensation |
| CP013 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP014 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP015 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP016 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP017 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP018 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP019 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Jean-Pierre Martin" | Jean-Pierre Martin |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Jean-Pierre! And, what is your booking reference number? |
| CP021 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC013" | PNR: TC013 |
| CP022 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC013 |  |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP025 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: j***@gmail.com � Phone: +1***234 |
| CP027 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: j***@gmail.com" | Email: j***@gmail.com |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP029 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "847291" | 847291 |
| CP030 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP032 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP033 | GROUP BOOKING CHECK | system | implied | And group booking identifier = PRESENT |  |
| CP034 | GROUP BOOKING CHECK | bot | chat | Then the chatbot responds: | I can see this is a group booking with 12 passengers. You will only be able to claim for yourself |
| CP035 | GROUP BOOKING CHECK | system | implied | Then user "confirms" |  |
| CP036 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 301 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: January 15, 2026 � Arrival Delay: 4 hours Is this the journey yo |
| CP037 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP038 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP039 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP040 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP041 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP042 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was January 15, 2026; current date is January 28, 2026 ? 312 hours ? >72 hours ? PROCEED | (If <72 hrs: case would enter System Processing Queue; customer asked for preferred email; system polls DDS/Trip Tracer for up to 14 days; if hit ? Welcome Back |
| CP043 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP044 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption January 15, 2026; filing January 28, 2026 ? 13 days ? within 366 days ? PROCEED |  |
| CP045 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP046 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP047 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 301, Route: YUL ? YYZ, Scheduled Arrival: 14:00 | Promised Itinerary - Flight: AC 301, Route: YUL ? YYZ, Scheduled Arrival: 14:00 |
| CP048 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary -  Flight: AC 301, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: ~~14:00~~ ? Actual: 18:00, Delay: +4H 00M | Current Itinerary -  Flight: AC 301, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: ~~14:00~~ ? Actual: 18:00, Delay: +4H 00M |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 301 � YUL ? YYZ � 19 | MSL FLIGHT: AC 301 � YUL ? YYZ � 19 |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to late check-in" | "Delayed due to late check-in" |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +4H 00M � CONTROLLABLE | Delay: +4H 00M � CONTROLLABLE |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | MS CATHERINE BOUCHARD / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 / [expiry date] | MS CATHERINE BOUCHARD / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 / [expiry date] |
| CP054 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP055 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP056 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP057 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 301 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours . Based on the Air Passenger |
| CP058 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP059 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP060 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP061 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP062 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP063 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP064 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP065 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence  ? Interac (CANADA) |  |
| CP066 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-transfer. Before we move forward, please confirmthe email address where you'd like to receive your payment related i |
| CP067 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP068 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP069 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP070 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP071 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP072 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP073 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP074 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP075 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP076 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP077 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP078 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP079 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then then chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: c***@gmail.com After submission, you will receive a confirmation email summarizing your eligibility, claim details and  |
| CP080 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP081 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP082 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP083 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP084 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP085 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP086 | NOTIFICATION | email | email | And an eligible notification email is sent to c***@gmail.com |  |
| CP087 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details, disruption reason, next steps, tr |  |
| CP088 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP089 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP090 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the group booking identifier was detected in Trip Tracer for PNR "TC013" (12 passengers) |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the claimant "Jean-Pierre Martin" claimed for self only |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then exactly one case should have been created for claimant "Jean-Pierre Martin" with PNR "TC013" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no cases should have been created for the other 11 passengers on the PNR |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Header Topic/Sub-topic should be "Travel Disruptions � Delays" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date should be populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Jean-Pierre Martin" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC013" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Group Booking flag should be "TRUE" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case note should read "Group booking � claimant claimed for self only. Other passengers must claim separately." |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Information section should list only 1 passenger: "Jean-Pierre Martin" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the names and details of the other 11 passengers should NOT be displayed on the case |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "j***@gmail.com" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***234" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address and Profile ID should be populated |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" (AC 301, 14:00 ? 18:00, +4H 00M) with claim filed for this flight |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Code should show "Code 19 (late check-in) � Controllable" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present with no expected ancillary fees |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should show "ELIGIBLE � CAD 400 (APPR Tier 1, 3 to <6 hrs) � 1 passenger" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS outcome should be "FD-APPR-EL-01" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" (APPR, Code 19 Controllable, 4h delay) for the claimant only |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Jean-Pierre Martin + TC013 + YUL?YYZ + FD" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Persona IDV result should be "PASS" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe to "j***@gmail.com" containing CAD 400 for 1 passenger |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record the group booking detection and the self-only restriction with timestamps |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should show that passenger selection was skipped and no other passenger names were shown |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP149 | PAYMENT VALIDATION | payment | chat | Given the group booking allows the customer to claim for self only and passenger selection is skipped |  |
| CP150 | PAYMENT VALIDATION | payment | chat | Then the payment flow should proceed for 1 passenger only |  |
| CP151 | PAYMENT VALIDATION | payment | chat | And the customer's country of residence is "Canada" |  |
| CP152 | PAYMENT VALIDATION | payment | chat | And the currency should be set to "CAD" |  |
| CP153 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP154 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created |  |
| CP155 | PAYMENT VALIDATION | payment | manual | And the record should be picked up by the daily evening batch file |  |
| CP156 | PAYMENT VALIDATION | payment | manual | And the record should be dispatched to Unifier |  |
| CP157 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually |  |
| CP158 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP159 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received from Interac |  |
| CP160 | PAYMENT VALIDATION | payment | manual | And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP161 | PAYMENT VALIDATION | payment | manual | And if the payment is unclaimed after 35 days the status should be set to "Expired" |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show payout details for the single claimant only |  |
| CP163 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-01. | DDS returns FD-APPR-EL-01. |
| CP164 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise 14:00, Actual 18:00, 4hrs, Code 19, Controllable, APPR. | Trip Tracer: Promise 14:00, Actual 18:00, 4hrs, Code 19, Controllable, APPR. |
| CP165 | EXPECTED RESULTS | verdict | chat | Compensation: $400 CAD (single passenger only). | Compensation: $400 CAD (single passenger only). |
| CP166 | EXPECTED RESULTS | verdict | chat | CRITICAL: System must detect group booking ? only show claimant's name ? NOT display other 11 passengers. | CRITICAL: System must detect group booking ? only show claimant's name ? NOT display other 11 passengers. |
| CP167 | EXPECTED RESULTS | verdict | dashboard | Claims Dashboard: 1 passenger (Jean-Pierre Martin); Group booking flag = TRUE; Note: "Other passengers must claim separately." | Claims Dashboard: 1 passenger (Jean-Pierre Martin); Group booking flag = TRUE; Note: "Other passengers must claim separately." |
