# FD_TC_019 · CHAI-31411 — checkpoints

**Goal:** CyberSource returns RED (high fraud risk). Case is auto-rejected. Customer is offered a dispute path where they can explain. Validates that RED triggers rejection message + dispute option, not just a dead end.

Methods: seed 2, chat 39, api 15, email 4, dashboard 57, implied 27, manual 7, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | CyberSource returns RED (high fraud risk). Case is auto-rejected. Customer is offered a dispute path where they can explain. Validates that  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Alain Moreau), 1 leg AC domestic YUL?YYZ | PNR: Single passenger (Alain Moreau), 1 leg AC domestic YUL?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: 4hr delay, Arrival delay code: 13 (Oversales), Controllable | Itinerary: 4hr delay, Arrival delay code: 13 (Oversales), Controllable |
| CP004 | PREREQUISITES | prerequisite | implied | CyberSource: Configured to return RED (high risk) | CyberSource: Configured to return RED (high risk) |
| CP005 | PREREQUISITES | prerequisite | implied | RDS: No internal flags | RDS: No internal flags |
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
| CP018 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Alain Moreau" | Alain Moreau |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Alain! And, what is your booking reference number? |
| CP020 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC015" | PNR: TC015 |
| CP021 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC015 |  |
| CP022 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP025 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: a***@outlook.com � Phone: +1***567 |
| CP026 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: a***@outlook.com" | Email: a***@outlook.com |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP028 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "294718" | 294718 |
| CP029 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP031 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP032 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP033 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP034 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP035 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Alain Moreau (Adult) Is this who you'd like to include? |
| CP036 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP037 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP038 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 427 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: May 15, 2026 � Arrival Delay: 4 hours Is this the journey you'd  |
| CP039 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP040 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP041 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP042 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP043 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP044 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 15, 2026; current date is June 4, 2026 ? >72 hours ? PROCEED |  |
| CP045 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP046 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 15, 2026; filing June 4, 2026 ? within 366 days ? PROCEED |  |
| CP047 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP048 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 427, Route: YUL ? YYZ, Scheduled Arrival: 14:00 (14-day mark) | Promised Itinerary - Flight: AC 427, Route: YUL ? YYZ, Scheduled Arrival: 14:00 (14-day mark) |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 427, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: ~~14:00~~ ? Actual: 18:00, Delay: +4H 00M | Current Itinerary - Flight: AC 427, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: ~~14:00~~ ? Actual: 18:00, Delay: +4H 00M |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | History - No changes recorded | History - No changes recorded |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 427 � YUL ? YYZ � 13 | MSL FLIGHT: AC 427 � YUL ? YYZ � 13 |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to oversales" | "Delayed due to oversales" |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +4H 00M � CONTROLLABLE | Delay: +4H 00M � CONTROLLABLE |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | MR ALAIN MOREAU / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 / [expiry date] | MR ALAIN MOREAU / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 / [expiry date] |
| CP057 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP058 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: RED (fraud detected, high risk) |  |
| CP059 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system logs: CyberSource Decision = RED; Risk Score = HIGH; Action = BLOCK AND REDIRECT |  |
| CP060 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the automated payment flow is BLOCKED |  |
| CP061 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the case is flagged as FRAUD DETECTED |  |
| CP062 | FRAUD REDIRECT | bot | chat | Then the chatbot displays: | We were unable to verify the information provided using our automated verification system due to discrepancies in the submitted details. Please note that no pay |
| CP063 | FRAUD REDIRECT | customer | chat | When the user says: "There is something wrong." | There is something wrong. |
| CP064 | FRAUD REDIRECT | bot | chat | Then the chatbot responds: "I understand your concern. I can create a case for our team to investigate your case further. Would you like to  | I understand your concern. I can create a case for our team to investigate your case further. Would you like to continue? |
| CP065 | NO PAYMENT FLOW | system | implied | Then the chatbot does NOT proceed to country of residence |  |
| CP066 | NO PAYMENT FLOW | system | implied | And the chatbot does NOT proceed to payment method |  |
| CP067 | NO PAYMENT FLOW | idv | chat | And the chatbot does NOT proceed to IDV |  |
| CP068 | NO PAYMENT FLOW | system | implied | And NO payment is initiated |  |
| CP069 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case with FRAUD flag: |  |
| CP070 | CASE CREATION (GLOB-09) | system | implied | And the case status = "Blocked � Fraud Review" |  |
| CP071 | CASE CREATION (GLOB-09) | system | implied | And the case is routed to the fraud investigation team |  |
| CP072 | CASE CREATION (GLOB-09) | system | implied | And the booking record is appended automatically |  |
| CP073 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP074 | NOTIFICATION | email | email | And a generic notification email is sent to a***@outlook.com |  |
| CP075 | NOTIFICATION | email | email | And the email contains: Case Reference, generic message about contacting Customer Relations |  |
| CP076 | NOTIFICATION | email | email | And the email does NOT mention fraud detection (security measure) |  |
| CP077 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP078 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP079 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Alain Moreau" with PNR "TC015" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Pending Fraud Manual Review" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "Fraud Investigation Team" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel may be restricted due to fraud flag |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Alain Moreau" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC015" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Alain Moreau" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "a***@outlook.com" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***567" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and DDS should have determined eligible but payment should be blocked by Cybe |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as eligible per DDS but blocked by fraud |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Alain Moreau + TC015 + YUL?YYZ + FD" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "RED" indicating fraud detected and high risk |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the customer should have been told the case cannot be processed through the automated system and redirected to Customer Relations |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the automated payment flow should have been BLOCKED |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no payment should have been initiated with no country of residence, no payment method, and no IDV |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should be flagged as "FRAUD DETECTED" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should be routed to the fraud investigation team |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a dispute option should be offered as required by privacy law |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if disputed the case should go to the CyberSource queue for review |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if CyberSource rejects the case after review a rejection notification should be sent and the case should be closed with a specific closu |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should be routed directly to the fraud investigation team and not the regular agent queue |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a generic notification email should have been sent to "a***@outlook.com" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email should contain the Case Reference and a generic message about contacting Customer Relations |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email should NOT mention fraud detection as a security measure |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps including the CyberSource RED flag and BLOCK action |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the generic notification email |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Blocked � Fraud Review" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should NOT be resolved as it is pending fraud investigation outcome |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Queue should only be visible to fraud team and management roles |  |
| CP142 | PAYMENT VALIDATION | payment | chat | Given the CyberSource fraud screening result is "RED" |  |
| CP143 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP144 | PAYMENT VALIDATION | payment | chat | And the customer should be offered a dispute option as required by privacy law |  |
| CP145 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show CyberSource result as "RED" |  |
| CP146 | PAYMENT VALIDATION | payment | manual | And the case should be auto-rejected |  |
| CP147 | PAYMENT VALIDATION | payment | chat | And a dispute record should exist if the customer disputed |  |
| CP148 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-01. | DDS returns FD-APPR-EL-01. |
| CP149 | EXPECTED RESULTS | verdict | chat | Compensation: $400 CAD (calculated but REJECTED). | Compensation: $400 CAD (calculated but REJECTED). |
| CP150 | EXPECTED RESULTS | verdict | chat | CyberSource: RED ? auto-rejected. | CyberSource: RED ? auto-rejected. |
| CP151 | EXPECTED RESULTS | verdict | chat | Customer offered: Dispute path with document upload option. | Customer offered: Dispute path with document upload option. |
| CP152 | EXPECTED RESULTS | verdict | dashboard | Claims Dashboard: Fraud = RED; Status = Rejected; Dispute option = Available; Compensation = $400 (not released). | Claims Dashboard: Fraud = RED; Status = Rejected; Dispute option = Available; Compensation = $400 (not released). |
