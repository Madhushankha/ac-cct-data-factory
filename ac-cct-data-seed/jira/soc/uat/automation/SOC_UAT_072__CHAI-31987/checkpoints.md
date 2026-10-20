# SOC_UAT_072 · CHAI-31987 — checkpoints

**Goal:** Verify ELIGIBLE when customer returned to origin,  cancelled, ASL.

Methods: seed 17, chat 42, api 22, email 1, dashboard 25, implied 25, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify ELIGIBLE when customer returned to origin,  cancelled, ASL. |  |
| CP002 | PREREQUISITES | prerequisite | seed | Regime: ASL | Regime: ASL |
| CP003 | PREREQUISITES | prerequisite | seed | Carrier: AC (AC 084 TLV?YYZ) | Carrier: AC (AC 084 TLV?YYZ) |
| CP004 | PREREQUISITES | prerequisite | seed | Promised Itinerary: AC 084 TLV?YYZ, Dep: 21-Jun 21:00, Arr: 22-Jun 03:00 | Promised Itinerary: AC 084 TLV?YYZ, Dep: 21-Jun 21:00, Arr: 22-Jun 03:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual Itinerary: Flight diverted back to TLV. Flight cancelled. Rebooked next day | Actual Itinerary: Flight diverted back to TLV. Flight cancelled. Rebooked next day |
| CP006 | PREREQUISITES | prerequisite | seed | Delay Length: 960 min (16 hours) | Delay Length: 960 min (16 hours) |
| CP007 | PREREQUISITES | prerequisite | seed | Controllability: NOT CHECKED | Controllability: NOT CHECKED |
| CP008 | PREREQUISITES | prerequisite | seed | ASL regime | ASL regime |
| CP009 | PREREQUISITES | prerequisite | seed | Departure delay code: Flight cancelled (IRRELEVANT under ASL SOC) | Departure delay code: Flight cancelled (IRRELEVANT under ASL SOC) |
| CP010 | PREREQUISITES | prerequisite | seed | Passenger Type: Regular | Passenger Type: Regular |
| CP011 | PREREQUISITES | prerequisite | seed | Check Order: 1. Pax Type ? Regular ? ? 2. No-travel check ? Flight cancelled ? ELIGIBLE | Check Order: 1. Pax Type ? Regular ? ? 2. No-travel check ? Flight cancelled ? ELIGIBLE |
| CP012 | PREREQUISITES | prerequisite | seed | Geographic Check: Origin = TLV (Israel) ? | Geographic Check: Origin = TLV (Israel) ? |
| CP013 | PREREQUISITES | prerequisite | seed | PAX Count: 1 adult | PAX Count: 1 adult |
| CP014 | PREREQUISITES | prerequisite | seed | Class of Booking: PY | Class of Booking: PY |
| CP015 | PREREQUISITES | prerequisite | seed | Revenue Booking: YES | Revenue Booking: YES |
| CP016 | PREREQUISITES | prerequisite | seed | ACR Issued: Hotel: No, Transport: No, Meal: No | ACR Issued: Hotel: No, Transport: No, Meal: No |
| CP017 | PREREQUISITES | prerequisite | seed | Journey Completed: > 72h ENTITLEMENTS (, 1 adult, PY, no ACR): | Journey Completed: > 72h ENTITLEMENTS (, 1 adult, PY, no ACR): |
| CP018 | PREREQUISITES | prerequisite | seed | Meals: $60 / Hotel: Rate of day, 3 nights max, $500 cap / Transport: $200 / Communication: $30 / Parking: $50 / Essentials: $30 | Meals: $60 / Hotel: Rate of day, 3 nights max, $500 cap / Transport: $200 / Communication: $30 / Parking: $50 / Essentials: $30 |
| CP019 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP020 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP021 | START | customer | chat | Then user selects English |  |
| CP022 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP023 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP024 | START | customer | chat | And the user says "My flight from Tel Aviv to Eilat took off but had to turn around and come back to Ben Gurion airport because of a mechani | My flight from Tel Aviv to Eilat took off but had to turn around and come back to Ben Gurion airport because of a mechanical problem. I was stuck at the airport |
| CP025 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP026 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP027 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP031 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP032 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP042 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP043 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP044 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 084 � Route: Tel Aviv (TLV) ? Eilat (VDA) � Date: June 12, 2026 � Status: DIVERTED � Returned to origin (TLV) Is thi |
| CP045 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for ASL SOC |  |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � ASL limitation: 1,460 days (4 years) � FIXED � Days elapsed: Within limitation period ? PROCEED |
| CP053 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Not Completed, Disruption Detected | Trip Not Completed, Disruption Detected |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip TLV?VDA on AC084 was diverted � returned to origin (TLV), then cancelled. Passenger returned to TLV, rebooked 16 hours l | Single-segment trip TLV?VDA on AC084 was diverted � returned to origin (TLV), then cancelled. Passenger returned to TLV, rebooked 16 hours later. |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: ASL (TLV?VDA = Israel?Israel) | Regime: ASL (TLV?VDA = Israel?Israel) |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 084, Route: TLV ? VDA, Scheduled Dep: 21-Jun 21:00 | Promised Itinerary � Flight: AC 084, Route: TLV ? VDA, Scheduled Dep: 21-Jun 21:00 |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 084, Route: TLV ? VDA, Status: DIVERTED � Returned to origin (TLV), CANCELLED, rebooked | Current Itinerary � Flight: AC 084, Route: TLV ? VDA, Status: DIVERTED � Returned to origin (TLV), CANCELLED, rebooked |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 06 (Mechanical) � NOT CHECKED (ASL does not evaluate controllability) | Departure Delay Code: 06 (Mechanical) � NOT CHECKED (ASL does not evaluate controllability) |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Geographic Check: TLV?VDA = Israel?Israel ? PASSED ? | Geographic Check: TLV?VDA = Israel?Israel ? PASSED ? |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Diversion + cancellation ? / SOC Segment Delay: 960 min (16h) ? ?2h ? | Diversion + cancellation ? / SOC Segment Delay: 960 min (16h) ? ?2h ? |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: ?220.00 / ACCOMMODATION: Rate of day (max ?1,800) / GENERAL EXPEN | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: ?220.00 / ACCOMMODATION: Rate of day (max ?1,800) / GENERAL EXPENSES: Transport ?720  |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: GREEN | CyberSource: GREEN |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | Total Approved: ?1,120.00 ILS (Hotel ?620 + Meals ?200 + Transport ?210 + Essentials ?90) | Total Approved: ?1,120.00 ILS (Hotel ?620 + Meals ?200 + Transport ?210 + Essentials ?90) |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-ASL-EL-05 | DDS RESPONSE CODE = SoC-ASL-EL-05 |
| CP073 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP074 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening (behind the scenes) |  |
| CP075 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) | ? PROCEED to eligible flow |
| CP076 | ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 084  | Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 084 from Tel Aviv to Eilat was diverted back to Tel  |
| CP077 | ENTITLEMENT DISPLAY | bot | chat | Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, ASL regime: | Based on the length of your disruption (16 hours), you may be eligible for reimbursement in the following categories: � Meals: up to ?220.00 � Hotel accommodati |
| CP078 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. |
| CP079 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | And the chatbot displays the receipt upload interface |  |
| CP080 | RECEIPT UPLOAD � WELCOME BACK FLOW | system | implied | And the user uploads receipt images: | � Receipt 1: Hotel receipt � ?620.00 ILS (1 night near Ben Gurion) � Receipt 2: Meal receipt � ?200.00 ILS (dinner + breakfast + snack) � Receipt 3: Taxi receip |
| CP081 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | Then the system processes uploaded receipts through OCR (Agentic Receipt Reader) |  |
| CP082 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | And the OCR engine extracts line items from each receipt: | Receipt 1 � Hotel: � Line item: Hotel stay, 1 night � ?620.00 ILS � Date: June 12, 2026 � Category: Hotel � Within disruption window: YES ? � Rate of day compar |
| CP083 | RECEIPT VALIDATION SUMMARY | system | implied | � Total receipts processed: 4 | � Total line items extracted: 7 � Items PASSED: 7 / Items FLAGGED: 0 / Items FAILED: 0 |
| CP084 | EXPENSE BREAKDOWN | system | implied | � Hotel: ?620.00 ? | � Meals: ?200.00 ? � Transport: ?210.00 ? � Communication: ?0.00 (no receipt) � Parking: ?0.00 (no receipt) � Essentials: ?90.00 ? � TOTAL APPROVED: ?1,120.00 I |
| CP085 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case in Case Services |  |
| CP086 | CASE CREATION (GLOB-09) | system | implied | And the case includes all approved line items, receipt images, fraud screening GREEN |  |
| CP087 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP088 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully. Here's a summary: � Case Reference: [Case Number] � Total claim amount: ?1,120.00 ILS � Categories: Hotel (?620.00), |
| CP089 | NOTIFICATION | email | email | Then the system triggers eligible confirmation email |  |
| CP090 | CLAIMS PAYMENT FLOW | system | implied | Then the system initiates payment processing | � Approved amount: ?1,120.00 ILS ? converted to country of residence currency � Payment method per country of residence |
| CP091 | CLAIMS PAYMENT FLOW | system | implied | Then the chatbot collects payment details and payment is initiated |  |
| CP092 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP093 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP094 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-ASL-EL-05 � ASL Eligible Returned to Origin Diverted Mechanical |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 084 TLV ? VDA as the claimed flight |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DIVERTED � Returned to origin (TLV)" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 084 TLV ? VDA |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Mechanical (Code 06 � IRRELEVANT under ASL)" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 960 min (16 hours) |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "No Travel � Returned to Origin (TLV)" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (TLV ? VDA = Israel ? Israel)" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Cancellation Check is "CANCELLED (diversion = cancellation) ?" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Departure Delay is "?2h (16 hours) ?" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-ASL-EL-05" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And under APPR this would be SoC-APPR-EL-03 (also ELIGIBLE � mechanical = Safety) and both regimes agree but for different reasons |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Hotel ?620.00 APPROVED |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Meals ?200.00 APPROVED (??220) |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Transport ?210.00 APPROVED |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Essentials ?90.00 APPROVED (??110) |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is ?1,120.00 ILS |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 0 |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP121 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-ASL-EL-05 � ASL Eligible Returned to Origin Diverted Mechanical |  |
| CP122 | PAYMENT VALIDATION | payment | chat | Given the case SoC-ASL-EL-05 is determined as ELIGIBLE |  |
| CP123 | PAYMENT VALIDATION | payment | chat | Then SOC payment is CASH ONLY |  |
| CP124 | PAYMENT VALIDATION | payment | chat | And the route is AC 084 TLV ? VDA (diverted back) for 1 adult PY |  |
| CP125 | PAYMENT VALIDATION | payment | chat | And ASL controllability is NOT checked |  |
| CP126 | PAYMENT VALIDATION | payment | chat | And the approved receipts are Hotel ?620, Meals ?200, Taxi ?210, Essentials ?90 totalling ?1,120.00 ILS |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And the country of residence determines currency and payment method |  |
| CP128 | PAYMENT VALIDATION | payment | chat | And currency conversion logging applies |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And no approval is needed |  |
| CP130 | PAYMENT VALIDATION | payment | manual | And the batch file is sent to Unifier and end-of-day report is generated |  |
| CP131 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard shows ?1,120.00 ILS, Cash, payment method, status via talkback |  |
| CP132 | EXPECTED RESULTS | verdict | chat | SoC-ASL-EL-05. | SoC-ASL-EL-05. |
| CP133 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP134 | EXPECTED RESULTS | verdict | chat | No travel (return), flight cancelled. | No travel (return), flight cancelled. |
| CP135 | EXPECTED RESULTS | verdict | chat | Controllability NOT checked. | Controllability NOT checked. |
| CP136 | EXPECTED RESULTS | verdict | chat | Full receipt + case flow. | Full receipt + case flow. |
