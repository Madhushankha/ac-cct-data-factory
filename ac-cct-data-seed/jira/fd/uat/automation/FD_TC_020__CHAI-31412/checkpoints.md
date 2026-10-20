# FD_TC_020 · CHAI-31412 — checkpoints

**Goal:** CyberSource returns GREEN but internal RDS business rules detect flags � Customer's device location does not match claimed country of residence.. RDS flags override the GREEN CyberSource result and force manual review. Validates that RDS can override CyberSource regardless of CyberSource outcome.

Methods: seed 2, chat 63, api 15, email 3, dashboard 50, implied 26, manual 8, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | CyberSource returns GREEN but internal RDS business rules detect flags � Customer's device location does not match claimed country of reside |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Diane Lefebvre), 1 leg AC domestic YUL?YYZ | PNR: Single passenger (Diane Lefebvre), 1 leg AC domestic YUL?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: 4hr delay, Arrival delay code:14 (Boarding Discrepancy), Controllable | Itinerary: 4hr delay, Arrival delay code:14 (Boarding Discrepancy), Controllable |
| CP004 | PREREQUISITES | prerequisite | implied | CyberSource: Returns GREEN | CyberSource: Returns GREEN |
| CP005 | PREREQUISITES | prerequisite | implied | RDS: Customer's device location does not match claimed country of residence ? OVERRIDE triggered | RDS: Customer's device location does not match claimed country of residence ? OVERRIDE triggered |
| CP006 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP007 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP008 | START | customer | chat | Then user selects English |  |
| CP009 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP010 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP011 | START | customer | chat | And the user says "My flight was delayed 4 hours, I want compensation" | My flight was delayed 4 hours, I want compensation |
| CP012 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP013 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP014 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP015 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP017 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP018 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Diane Lefebvre" | Diane Lefebvre |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Diane! And, what is your booking reference number? |
| CP020 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC016" | PNR: TC016 |
| CP021 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC016 |  |
| CP022 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP025 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: d***@gmail.com � Phone: +1***678 |
| CP026 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: d***@gmail.com" | Email: d***@gmail.com |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP028 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP029 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP031 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP032 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP033 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP034 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP035 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Diane Lefebvre (Adult) Is this who you'd like to include? |
| CP036 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP037 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP038 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 428 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: May 16, 2026 � Arrival Delay: 4 hours Is this the journey you'd  |
| CP039 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP040 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP041 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP042 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP043 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP044 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 16, 2026; current date is June 4, 2026 ? >72 hours ? PROCEED |  |
| CP045 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP046 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 16, 2026; filing June 4, 2026 ? within 366 days ? PROCEED |  |
| CP047 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP048 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 428, Route: YUL ? YYZ, Scheduled Arrival: 14:00 (14-day mark) | Promised Itinerary - Flight: AC 428, Route: YUL ? YYZ, Scheduled Arrival: 14:00 (14-day mark) |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 428, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: ~~14:00~~ ? Actual: 18:00, Delay: +4H 00M | Current Itinerary - Flight: AC 428, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: ~~14:00~~ ? Actual: 18:00, Delay: +4H 00M |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | History - No changes recorded | History - No changes recorded |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 428 � YUL ? YYZ � 14 | MSL FLIGHT: AC 428 � YUL ? YYZ � 14 |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to Boarding Discrepancy" | "Delayed due to Boarding Discrepancy" |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +4H 00M � CONTROLLABLE | Delay: +4H 00M � CONTROLLABLE |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | MS DIANE LEFEBVRE / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 / [expiry date] | MS DIANE LEFEBVRE / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 / [expiry date] |
| CP057 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP058 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP059 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system logs: CyberSource Decision = GREEN; Risk Score = LOW |  |
| CP060 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system checks RDS (Risk Detection System) for claim frequency |  |
| CP061 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And RDS returns: ANNOTATION � Geolocation mismatch (RDS Code 1). Customer's device IP resolves to a different country than claimed residence |  |
| CP062 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer flow CONTINUES (RDS flag does not block the customer) |  |
| CP063 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 428 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours. Based on the Air Passenger  |
| CP064 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP065 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP066 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP067 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP068 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP069 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP070 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP071 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP072 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac (CANADA) |  |
| CP073 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP074 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP075 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP076 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP077 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP078 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP085 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP086 | CLAIM AMOUNT CONFIRMATION | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: d***@gmail.com After submission, you will receive a confirmation email summarizing your eligibility, claim details and  |
| CP087 | CLAIM AMOUNT CONFIRMATION | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP088 | CLAIM AMOUNT CONFIRMATION | customer | chat | When the user provides: "Yes" | Yes |
| CP089 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP090 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP091 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP092 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP093 | NOTIFICATION | email | email | And an eligible notification email is sent to d***@gmail.com |  |
| CP094 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details, disruption reason, next steps, tr |  |
| CP095 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP096 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP097 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Diane Lefebvre" with PNR "TC016" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Diane Lefebvre" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC016" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Diane Lefebvre" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "d***@gmail.com" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***678" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated for this automated FD case |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Diane Lefebvre + TC016 + YUL?YYZ + FD" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" indicating no fraud detected |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the RDS Annotation should be "GEOLOCATION_MISMATCH" |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should be flagged for manual review due to RDS business rule override |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the customer flow should have continued as the RDS flag does not block the customer |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And compensation may be HELD pending manual review regardless of CyberSource GREEN |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps including the RDS flag for high frequency claimant |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" or "Parked" if compensation is held pending manual review |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case may require manual review before payment is released |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP155 | PAYMENT VALIDATION | payment | chat | Given the CyberSource fraud screening result is "GREEN" |  |
| CP156 | PAYMENT VALIDATION | payment | chat | And the RDS business rule flags the case |  |
| CP157 | PAYMENT VALIDATION | payment | chat | Then RDS should override CyberSource GREEN |  |
| CP158 | PAYMENT VALIDATION | payment | chat | And the case should be sent for manual review |  |
| CP159 | PAYMENT VALIDATION | payment | chat | And the compensation should be HELD and NOT released until the review is complete |  |
| CP160 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show CyberSource result as "GREEN" with an RDS flag |  |
| CP161 | PAYMENT VALIDATION | payment | chat | And manual review should be required |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And payment should be on hold |  |
| CP163 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-01. | DDS returns FD-APPR-EL-01. |
| CP164 | EXPECTED RESULTS | verdict | chat | Compensation: $400 CAD (calculated but HELD). | Compensation: $400 CAD (calculated but HELD). |
| CP165 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP166 | EXPECTED RESULTS | verdict | chat | RDS: OVERRIDE . | RDS: OVERRIDE . |
| CP167 | EXPECTED RESULTS | verdict | chat | CRITICAL: Despite GREEN CyberSource, case goes to manual review because RDS flags override. | CRITICAL: Despite GREEN CyberSource, case goes to manual review because RDS flags override. |
| CP168 | EXPECTED RESULTS | verdict | dashboard | Claims Dashboard: Fraud = GREEN; RDS = FLAGGED (customer's IP/device location doesn't match claimed residence); Status = Manual Review; Cybe | Claims Dashboard: Fraud = GREEN; RDS = FLAGGED (customer's IP/device location doesn't match claimed residence); Status = Manual Review; CyberSource overridden b |
