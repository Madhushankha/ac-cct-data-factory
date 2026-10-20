# FD_TC_037 · CHAI-31429 — checkpoints

**Goal:** Arrival disruption code is MISSING from the system � ground team at arrival station didn't log it. DDS falls back to the departure code (42) for eligibility assessment and sets Fallback = TRUE flag. Validates that a missing arrival code does NOT block the claim and the fallback mechanism works correctly at Tier 1.

Methods: seed 6, chat 60, api 19, email 3, dashboard 46, implied 21, manual 16, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Arrival disruption code is MISSING from the system � ground team at arrival station didn't log it. DDS falls back to the departure code (42) |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger, 1 leg AC domestic YUL?YYZ | PNR: Single passenger, 1 leg AC domestic YUL?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: Scheduled arrival 14:00, Actual arrival 18:00 (4hr delay) | Itinerary: Scheduled arrival 14:00, Actual arrival 18:00 (4hr delay) |
| CP004 | PREREQUISITES | prerequisite | seed | Arrival code: NULL (MISSING � not logged) | Arrival code: NULL (MISSING � not logged) |
| CP005 | PREREQUISITES | prerequisite | seed | Departure delay code: 64 (Flight Crew Shortage � Controllable) | Departure delay code: 64 (Flight Crew Shortage � Controllable) |
| CP006 | PREREQUISITES | prerequisite | seed | Cancellation code: NULL (flight operated, not cancelled) | Cancellation code: NULL (flight operated, not cancelled) |
| CP007 | PREREQUISITES | prerequisite | seed | Booking changes: None | Booking changes: None |
| CP008 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP009 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP010 | START | customer | chat | Then user selects English |  |
| CP011 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP012 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP013 | START | customer | chat | And the user says "My flight was delayed about 4 hours due to a maintenance issue, I'd like to check if I'm eligible for compensation" | My flight was delayed about 4 hours due to a maintenance issue, I'd like to check if I'm eligible for compensation |
| CP014 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP015 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP016 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP017 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP018 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP020 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Nathalie Fortin" | Nathalie Fortin |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Nathalie! And, what is your booking reference number? |
| CP022 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC026" | PNR: TC026 |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC026 |  |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: n***@outlook.com � Phone: +1***012 |
| CP028 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: n***@outlook.com" | Email: n***@outlook.com |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP030 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP031 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP033 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP034 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP035 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP036 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP037 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Nathalie Fortin (Adult) Is this who you'd like to include? |
| CP038 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP039 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP040 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 438 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: May 12, 2026 � Arrival Delay: 4 hours Is this the journey you'd  |
| CP041 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP045 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP046 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 12, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP047 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP048 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 12, 2026; filing June 15, 2026 ? 34 days ? within 366 days ? PROCEED |  |
| CP049 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP050 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 438, Route: YUL ? YYZ, Scheduled Arrival: 14:00 | Promised Itinerary - Flight: AC 438, Route: YUL ? YYZ, Scheduled Arrival: 14:00 |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 438, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 14:00 ? Actual: 18:00, Delay: +4H 00M | Current Itinerary - Flight: AC 438, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 14:00 ? Actual: 18:00, Delay: +4H 00M |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 438 � YUL ? YYZ � ARRIVAL CODE: NULL (MISSING) | MSL FLIGHT: AC 438 � YUL ? YYZ � ARRIVAL CODE: NULL (MISSING) |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | FALLBACK TRIGGERED: Arrival code NULL ? using departure code | FALLBACK TRIGGERED: Arrival code NULL ? using departure code |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Departure delay code: 64 (Flight Crew Shortage) | Departure delay code: 64 (Flight Crew Shortage) |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Fallback Flag: TRUE | Fallback Flag: TRUE |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE | CONTROLLABLE |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +4H 00M � CONTROLLABLE | Delay: +4H 00M � CONTROLLABLE |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | MS NATHALIE FORTIN / ELIGIBLE / DELAY_3_TO_LT_6_HOURS (FALLBACK) / CAD 400.00 / [expiry date] | MS NATHALIE FORTIN / ELIGIBLE / DELAY_3_TO_LT_6_HOURS (FALLBACK) / CAD 400.00 / [expiry date] |
| CP061 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP062 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP063 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP064 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 438 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours. Based on the Air Passenger  |
| CP065 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP066 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP067 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP068 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP069 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP070 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP071 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP072 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP073 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac (CANADA) |  |
| CP074 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP075 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP076 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP077 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP078 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP085 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP086 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP087 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: n***@outlook.com After submission, you will receive a confirmation email summarizing your eligibility, claim details an |
| CP088 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP089 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP090 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP091 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP092 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP093 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP094 | NOTIFICATION | email | email | And an eligible notification email is sent to n***@outlook.com |  |
| CP095 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details, fallback code note, disruption re |  |
| CP096 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP097 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP098 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Nathalie Fortin" with PNR "TC026" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Nathalie Fortin" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC026" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Nathalie Fortin" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "n***@outlook.com" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***012" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated for this automated FD case |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Nathalie Fortin + TC026 + YUL?YYZ + FD" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP153 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP154 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP155 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP156 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP157 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "$400" for Tier 1 delay of 3 to less than 6 hours |  |
| CP158 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP159 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP160 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP161 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP162 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received from Interac |  |
| CP163 | PAYMENT VALIDATION | payment | manual | And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP164 | PAYMENT VALIDATION | payment | manual | And if the payment is unclaimed after 35 days the status should be set to "Expired" |  |
| CP165 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show "$400" CAD |  |
| CP166 | PAYMENT VALIDATION | payment | chat | And the payment method should show "Cash" via "Interac" |  |
| CP167 | PAYMENT VALIDATION | payment | manual | And the status should be updated via talkback |  |
| CP168 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-02. | DDS returns FD-APPR-EL-02. |
| CP169 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 14:00; Actual = 18:00; Delay = 4hrs; MSL = Leg 1; Arrival Code = NULL; Departure Code = 64; Fallback = TRUE (departur | Trip Tracer: Promise = 14:00; Actual = 18:00; Delay = 4hrs; MSL = Leg 1; Arrival Code = NULL; Departure Code = 64; Fallback = TRUE (departure code used because  |
| CP170 | EXPECTED RESULTS | verdict | api | CRITICAL: DDS must use departure code 64 when arrival code is NULL and set Fallback flag. | CRITICAL: DDS must use departure code 64 when arrival code is NULL and set Fallback flag. |
| CP171 | EXPECTED RESULTS | verdict | chat | Compensation: $400 CAD (Tier 1). | Compensation: $400 CAD (Tier 1). |
| CP172 | EXPECTED RESULTS | verdict | dashboard | Claims Dashboard: Fallback = TRUE; | Claims Dashboard: Fallback = TRUE; |
