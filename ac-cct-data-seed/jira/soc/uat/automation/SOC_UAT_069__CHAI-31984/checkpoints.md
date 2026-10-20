# SOC_UAT_069 · CHAI-31984 — checkpoints

**Goal:** Verify ELIGIBLE when customer returned to origin,  delay ?2h, ASL.

Methods: seed 26, chat 45, api 26, email 3, dashboard 25, implied 27, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify ELIGIBLE when customer returned to origin,  delay ?2h, ASL. |  |
| CP002 | PREREQUISITES | prerequisite | seed | Regime: ASL | Regime: ASL |
| CP003 | PREREQUISITES | prerequisite | seed | Carrier: AC (AC 084 TLV?YYZ) | Carrier: AC (AC 084 TLV?YYZ) |
| CP004 | PREREQUISITES | prerequisite | seed | Promised Itinerary: AC 084 TLV?YYZ, Dep: 19-Jun 21:00, Arr: 20-Jun 03:00 | Promised Itinerary: AC 084 TLV?YYZ, Dep: 19-Jun 21:00, Arr: 20-Jun 03:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual Itinerary: Flight diverted back to TLV. Rebooked 8 hours later | Actual Itinerary: Flight diverted back to TLV. Rebooked 8 hours later |
| CP006 | PREREQUISITES | prerequisite | seed | Delay Length: 480 min (8 hours) | Delay Length: 480 min (8 hours) |
| CP007 | PREREQUISITES | prerequisite | seed | Controllability: NOT CHECKED | Controllability: NOT CHECKED |
| CP008 | PREREQUISITES | prerequisite | seed | ASL regime | ASL regime |
| CP009 | PREREQUISITES | prerequisite | seed | Departure delay code: 72 (ATC | Departure delay code: 72 (ATC |
| CP010 | PREREQUISITES | prerequisite | seed | IRRELEVANT under ASL SOC) | IRRELEVANT under ASL SOC) |
| CP011 | PREREQUISITES | prerequisite | seed | Passenger Type: Regular | Passenger Type: Regular |
| CP012 | PREREQUISITES | prerequisite | seed | Check Order: 1. Pax Type ? Regular ? ? 2. No-travel delay check ? ?2h ? ELIGIBLE | Check Order: 1. Pax Type ? Regular ? ? 2. No-travel delay check ? ?2h ? ELIGIBLE |
| CP013 | PREREQUISITES | prerequisite | seed | Geographic Check: Origin = TLV (Israel) ? | Geographic Check: Origin = TLV (Israel) ? |
| CP014 | PREREQUISITES | prerequisite | seed | PAX Count: 2 adults, 1 child | PAX Count: 2 adults, 1 child |
| CP015 | PREREQUISITES | prerequisite | seed | Class of Booking: PY | Class of Booking: PY |
| CP016 | PREREQUISITES | prerequisite | seed | Revenue Booking: YES | Revenue Booking: YES |
| CP017 | PREREQUISITES | prerequisite | seed | ACR Issued: Hotel: No, Transport: No, Meal: No | ACR Issued: Hotel: No, Transport: No, Meal: No |
| CP018 | PREREQUISITES | prerequisite | seed | Journey Completed: > 72h ENTITLEMENTS (, 2 adults + 1 child, PY, no ACR): | Journey Completed: > 72h ENTITLEMENTS (, 2 adults + 1 child, PY, no ACR): |
| CP019 | PREREQUISITES | prerequisite | seed | Meals: $30/pax | Meals: $30/pax |
| CP020 | PREREQUISITES | prerequisite | seed | 3 = $90 | 3 = $90 |
| CP021 | PREREQUISITES | prerequisite | seed | Hotel: Rate of day, 2 rooms (per adult), 3 nights max, $500 cap (if overnight) | Hotel: Rate of day, 2 rooms (per adult), 3 nights max, $500 cap (if overnight) |
| CP022 | PREREQUISITES | prerequisite | seed | Transport: $200 (1-5 pax) | Transport: $200 (1-5 pax) |
| CP023 | PREREQUISITES | prerequisite | seed | Communication: $30/pax | Communication: $30/pax |
| CP024 | PREREQUISITES | prerequisite | seed | 3 = $90 | 3 = $90 |
| CP025 | PREREQUISITES | prerequisite | seed | Parking: $50, 1 day max | Parking: $50, 1 day max |
| CP026 | PREREQUISITES | prerequisite | seed | Essentials: $30/pax | Essentials: $30/pax |
| CP027 | PREREQUISITES | prerequisite | seed | 3 = $90 | 3 = $90 |
| CP028 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP029 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP030 | START | customer | chat | Then user selects English |  |
| CP031 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP032 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP033 | START | customer | chat | And the user says "My flight from Tel Aviv to Eilat was cancelled because of bad weather and I never made it to my destination. I was stuck  | My flight from Tel Aviv to Eilat was cancelled because of bad weather and I never made it to my destination. I was stuck at Ben Gurion airport for about 18 hour |
| CP034 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP035 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP036 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP037 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP038 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP039 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP040 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP041 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP042 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP043 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP044 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP045 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP046 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP047 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP048 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP049 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP050 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP051 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP052 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP053 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 084 � Route: Tel Aviv (TLV) ? Eilat (VDA) � Date: June 11, 2026 � Status: CANCELLED Is this the journey you'd like t |
| CP054 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP055 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP056 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP057 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP058 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP059 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP060 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for ASL SOC |  |
| CP061 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � ASL limitation: 1,460 days (4 years) � FIXED � Days elapsed: Within limitation period ? PROCEED |
| CP062 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP063 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP064 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Not Completed, Disruption Detected | Trip Not Completed, Disruption Detected |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip TLV?VDA on AC084 was cancelled � passenger stayed at origin (TLV) for 18 hours | Single-segment trip TLV?VDA on AC084 was cancelled � passenger stayed at origin (TLV) for 18 hours |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: ASL (TLV?VDA = Israel?Israel) | Regime: ASL (TLV?VDA = Israel?Israel) |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 3 (2 adults + 1 child) � SEGMENTS: 1 | PASSENGERS: 3 (2 adults + 1 child) � SEGMENTS: 1 |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 084, Route: TLV ? VDA, Scheduled Dep: 19-Jun 21:00 | Promised Itinerary � Flight: AC 084, Route: TLV ? VDA, Scheduled Dep: 19-Jun 21:00 |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 084, Route: TLV ? VDA, Status: CANCELLED | Current Itinerary � Flight: AC 084, Route: TLV ? VDA, Status: CANCELLED |
| CP073 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present � 3 passenger rows | SOC section present � 3 passenger rows |
| CP074 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 77 (Weather) � NOT CHECKED (ASL does not evaluate controllability) | Departure Delay Code: 77 (Weather) � NOT CHECKED (ASL does not evaluate controllability) |
| CP075 | TRIP TRACER UI VALIDATIONS | verdict | api | Geographic Check: TLV?VDA = Israel?Israel ? PASSED ? | Geographic Check: TLV?VDA = Israel?Israel ? PASSED ? |
| CP076 | TRIP TRACER UI VALIDATIONS | verdict | api | Cancellation: YES ? / SOC Segment Delay to rebooking: 1080 min (18h) ? ?2h ? | Cancellation: YES ? / SOC Segment Delay to rebooking: 1080 min (18h) ? ?2h ? |
| CP077 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER 1 (Adult � Claimant): [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: ?220.00 (3 pax) / ACCOMMODATION: Rate of day | PASSENGER 1 (Adult � Claimant): [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: ?220.00 (3 pax) / ACCOMMODATION: Rate of day (max ?1,800) / GENE |
| CP078 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER 2 (Adult): [Name] / STATUS: ELIGIBLE / same entitlements | PASSENGER 2 (Adult): [Name] / STATUS: ELIGIBLE / same entitlements |
| CP079 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER 3 (Child): [Name] / STATUS: ELIGIBLE / same entitlements | PASSENGER 3 (Child): [Name] / STATUS: ELIGIBLE / same entitlements |
| CP080 | TRIP TRACER UI VALIDATIONS | verdict | api | Transportation (PNR-level): ?720.00 (1�5 pax shared) | Transportation (PNR-level): ?720.00 (1�5 pax shared) |
| CP081 | TRIP TRACER UI VALIDATIONS | verdict | api | Hotel: 2 rooms (1 per adult) | Hotel: 2 rooms (1 per adult) |
| CP082 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: GREEN | CyberSource: GREEN |
| CP083 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE |
| CP084 | TRIP TRACER UI VALIDATIONS | verdict | api | Total Approved: ?1,085.00 ILS (Hotel ?600 + Meals ?190 + Transport ?200 + Essentials ?95) | Total Approved: ?1,085.00 ILS (Hotel ?600 + Meals ?190 + Transport ?200 + Essentials ?95) |
| CP085 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-ASL-EL-02 | DDS RESPONSE CODE = SoC-ASL-EL-02 |
| CP086 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP087 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger) |  |
| CP088 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates the claim |  |
| CP089 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) | ? PROCEED to eligible flow |
| CP090 | ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 084  | Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 084 from Tel Aviv to Eilat was cancelled and you wer |
| CP091 | ENTITLEMENT DISPLAY | bot | chat | Then the chatbot displays the eligible expense categories based on  delay, 2 adults + 1 child, PY class, ASL regime: | Based on the length of your disruption (18 hours), you may be eligible for reimbursement in the following categories: � Meals: up to ?220.00 � Hotel accommodati |
| CP092 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP093 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | And the chatbot displays the receipt upload interface |  |
| CP094 | RECEIPT UPLOAD � WELCOME BACK FLOW | system | implied | And the user uploads receipt images: | � Receipt 1: Hotel receipt � ?600.00 ILS (1 night near Ben Gurion) � Receipt 2: Meal receipt � ?190.00 ILS (dinner + breakfast + lunch) � Receipt 3: Taxi receip |
| CP095 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | Then the system processes uploaded receipts through OCR (Agentic Receipt Reader) |  |
| CP096 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | And the OCR engine extracts line items from each receipt: | Receipt 1 � Hotel: � Line item: Hotel stay, 1 night � ?600.00 ILS � Date: June 11, 2026 � Category: Hotel � Within disruption window: YES ? � Rate of day compar |
| CP097 | RECEIPT VALIDATION SUMMARY | system | implied | Then the system displays the OCR validation summary: | � Total receipts processed: 4 � Total line items extracted: 6 � Items PASSED: 6 � Items FLAGGED for agent review: 0 � Items FAILED: 0 |
| CP098 | EXPENSE BREAKDOWN | system | implied | � Hotel: ?600.00 ? | � Meals: ?190.00 ? � Transport: ?200.00 ? � Communication: ?0.00 (no receipt submitted) � Parking: ?0.00 (no receipt submitted) � Essentials: ?95.00 ? � TOTAL A |
| CP099 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case in Case Services |  |
| CP100 | CASE CREATION (GLOB-09) | system | implied | And the case includes: | � DDS response code: SoC-ASL-EL-02 � Eligibility: ELIGIBLE � Regime: ASL � Currency: ILS (receipts in ILS � no conversion needed for threshold comparison) � All |
| CP101 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP102 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully. Here's a summary: � Case Reference: [Case Number] � Total claim amount: ?1,085.00 ILS � Categories: Hotel (?600.00), |
| CP103 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP104 | NOTIFICATION | email | email | And an eligible confirmation email is sent to the passenger at t***@gmail.com |  |
| CP105 | NOTIFICATION | email | email | And the email includes: | � Case reference number � Claim summary with approved amounts (in country of residence currency) � Next steps for payment processing |
| CP106 | CLAIMS PAYMENT FLOW | system | implied | Then the system initiates payment processing |  |
| CP107 | CLAIMS PAYMENT FLOW | system | implied | And Case Services calculates: | � Approved amount: ?1,085.00 ILS � Currency conversion to country of residence currency (if different from ILS) � Payment method determination based on country  |
| CP108 | CLAIMS PAYMENT FLOW | bot | chat | Then the chatbot responds: | To complete your reimbursement, we'll need your payment details. |
| CP109 | CLAIMS PAYMENT FLOW | system | implied | And the chatbot collects: | � Country of residence: [Country] � Payment method: [determined by country] � Payment details: [collected securely] |
| CP110 | CLAIMS PAYMENT FLOW | bot | chat | Then the chatbot responds: | Your payment of [amount in local currency] will be processed via [payment method]. You should receive the funds within [X] business days. |
| CP111 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP112 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP113 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-ASL-EL-02 � ASL Eligible No Travel Stayed at Origin Cancelled |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 084 TLV ? VDA as the claimed flight |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "CANCELLED" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 084 TLV ? VDA |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Weather (Code 77 � IRRELEVANT under ASL)" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 1080 min (18 hours) |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "No Travel � Stayed at Origin (TLV)" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (TLV ? VDA = Israel ? Israel)" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Cancellation Check is "CANCELLED ?" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Departure Delay is "?2h (18 hours) ?" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-ASL-EL-02" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And under APPR this would be SoC-APPR-NE-08 (NOT ELIGIBLE) and under EU SoC-EU-EL-02 (ELIGIBLE) |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Hotel ?600.00 APPROVED |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Meals ?190.00 APPROVED (??220) |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Transport ?200.00 APPROVED |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Essentials ?95.00 APPROVED (??110) |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is ?1,085.00 ILS |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 0 |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP140 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-ASL-EL-02 � ASL Eligible No Travel Stayed at Origin Cancelled |  |
| CP141 | PAYMENT VALIDATION | payment | chat | Given the case SoC-ASL-EL-02 is determined as ELIGIBLE |  |
| CP142 | PAYMENT VALIDATION | payment | chat | Then SOC payment is CASH ONLY |  |
| CP143 | PAYMENT VALIDATION | payment | chat | And the route is AC 084 TLV ? VDA CANCELLED with 18h delay for 1 adult PY |  |
| CP144 | PAYMENT VALIDATION | payment | chat | And ASL controllability is NOT checked |  |
| CP145 | PAYMENT VALIDATION | payment | chat | And the approved receipts are Hotel ?600, Meals ?190, Taxi ?200, Essentials ?95 totalling ?1,085.00 ILS |  |
| CP146 | PAYMENT VALIDATION | payment | chat | And the country of residence determines currency and payment method |  |
| CP147 | PAYMENT VALIDATION | payment | chat | And currency conversion logging applies |  |
| CP148 | PAYMENT VALIDATION | payment | manual | And the batch file is sent to Unifier and end-of-day report is generated |  |
| CP149 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard shows ?1,085.00 ILS, Cash, payment method, status via talkback |  |
| CP150 | EXPECTED RESULTS | verdict | chat | SoC-ASL-EL-02. | SoC-ASL-EL-02. |
| CP151 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP152 | EXPECTED RESULTS | verdict | chat | No travel (return), delay ?2h. | No travel (return), delay ?2h. |
| CP153 | EXPECTED RESULTS | verdict | chat | Controllability NOT checked. | Controllability NOT checked. |
| CP154 | EXPECTED RESULTS | verdict | chat | Hotel: 2 rooms (per adult). | Hotel: 2 rooms (per adult). |
| CP155 | EXPECTED RESULTS | verdict | chat | Entitlements per  for 3 passengers. | Entitlements per  for 3 passengers. |
| CP156 | EXPECTED RESULTS | verdict | chat | Full receipt + case flow. | Full receipt + case flow. |
