# FD_TC_013 · CHAI-31405 — checkpoints

**Goal:** System automatically rebooked the passenger after a disruption (React auto-rebook). React is classified as INVOL � promise stays at 14-day mark. Validates that automated system rebookings are treated identically to airline-initiated INVOL, not as customer VOL.

Methods: seed 6, chat 60, api 16, email 3, dashboard 45, implied 21, manual 16, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | System automatically rebooked the passenger after a disruption (React auto-rebook). React is classified as INVOL � promise stays at 14-day m |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Isabelle Tremblay), 1 leg AC domestic YUL?YYZ | PNR: Single passenger (Isabelle Tremblay), 1 leg AC domestic YUL?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Original (14-day) arrival: 10:00 | Original (14-day) arrival: 10:00 |
| CP004 | PREREQUISITES | prerequisite | seed | Change: React auto-rebook � system automatically rebooked after disruption, arrival 14:30 | Change: React auto-rebook � system automatically rebooked after disruption, arrival 14:30 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival: 14:30 | Actual arrival: 14:30 |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival delay code:61 (Cabin Appearance/Amenities) | Arrival delay code:61 (Cabin Appearance/Amenities) |
| CP007 | PREREQUISITES | prerequisite | seed | Carrier: AC only | Carrier: AC only |
| CP008 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP009 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP010 | START | customer | chat | Then user selects English |  |
| CP011 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP012 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP013 | START | customer | chat | And the user says "My flight was automatically rebooked by the system after a cancellation and I arrived 4 and a half hours late, I want com | My flight was automatically rebooked by the system after a cancellation and I arrived 4 and a half hours late, I want compensation |
| CP014 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP015 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP016 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP017 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP018 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP020 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Isabelle Tremblay" | Isabelle Tremblay |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Isabelle! And, what is your booking reference number? |
| CP022 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC010" | PNR: TC010 |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC010 |  |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: i***@outlook.com � Phone: +1***890 |
| CP028 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: i***@outlook.com" | Email: i***@outlook.com |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP030 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP031 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP033 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP034 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP035 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP036 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP037 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Isabelle Tremblay (Adult) Is this who you'd like to include? |
| CP038 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP039 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP040 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 423 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: May 14, 2026 � Arrival Delay: 4 hours 30 minutes Is this the jou |
| CP041 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP045 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP046 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 14, 2026; current date is June 4, 2026 ? >72 hours ? PROCEED |  |
| CP047 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP048 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 14, 2026; filing June 4, 2026 ? within 366 days ? PROCEED |  |
| CP049 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP050 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 423, Route: YUL ? YYZ, Scheduled Arrival: 10:00 (14-day mark, REACC = INVOL, doesn't update) | Promised Itinerary - Flight: AC 423, Route: YUL ? YYZ, Scheduled Arrival: 10:00 (14-day mark, REACC = INVOL, doesn't update) |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 423, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: ~~10:00~~ ? Actual: 14:30, Delay: +4H 30M | Current Itinerary - Flight: AC 423, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: ~~10:00~~ ? Actual: 14:30, Delay: +4H 30M |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | History - Change 1: REACC (React auto-rebook by system) ? arr 14:30 ? classified as INVOL | History - Change 1: REACC (React auto-rebook by system) ? arr 14:30 ? classified as INVOL |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 423 � YUL ? YYZ � 61 | MSL FLIGHT: AC 423 � YUL ? YYZ � 61 |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to cabin appearance/amenities" | "Delayed due to cabin appearance/amenities" |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +4H 30M � CONTROLLABLE | Delay: +4H 30M � CONTROLLABLE |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | MS ISABELLE TREMBLAY / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 / [expiry date] | MS ISABELLE TREMBLAY / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 / [expiry date] |
| CP059 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP060 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP061 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP062 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 423 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours and 30 minutes. Based on the |
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
| CP085 | CLAIM AMOUNT CONFIRMATION | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: i***@outlook.com After submission, you will receive a confirmation email summarizing your eligibility, claim details an |
| CP086 | CLAIM AMOUNT CONFIRMATION | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP087 | CLAIM AMOUNT CONFIRMATION | customer | chat | When the user provides: "Yes" | Yes |
| CP088 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP089 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP090 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP091 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP092 | NOTIFICATION | email | email | And an eligible notification email is sent to i***@outlook.com |  |
| CP093 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details, disruption reason, next steps, tr |  |
| CP094 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP095 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP096 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Isabelle Tremblay" with PNR "TC010" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Isabelle Tremblay" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC010" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Isabelle Tremblay" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "i***@outlook.com" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***890" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated for this automated FD case |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Isabelle Tremblay + TC010 + YUL?YYZ + FD" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP151 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP152 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP153 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP154 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP155 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP156 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP157 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP158 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP159 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received from Interac |  |
| CP160 | PAYMENT VALIDATION | payment | manual | And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP161 | PAYMENT VALIDATION | payment | manual | And if the payment is unclaimed after 35 days the status should be set to "Expired" |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should verify the correct amount |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And the currency should be displayed |  |
| CP164 | PAYMENT VALIDATION | payment | chat | And the payment method should be displayed |  |
| CP165 | PAYMENT VALIDATION | payment | manual | And the status should be updated via talkback |  |
| CP166 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-01. | DDS returns FD-APPR-EL-01. |
| CP167 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 10:00 (14-day mark, React = INVOL); Actual = 14:30; Delay = 4.5hrs; History shows React auto-rebook (classified as IN | Trip Tracer: Promise = 10:00 (14-day mark, React = INVOL); Actual = 14:30; Delay = 4.5hrs; History shows React auto-rebook (classified as INVOL); MSL = Leg 1; C |
| CP168 | EXPECTED RESULTS | verdict | chat | Compensation: $400 CAD (Tier 1). | Compensation: $400 CAD (Tier 1). |
