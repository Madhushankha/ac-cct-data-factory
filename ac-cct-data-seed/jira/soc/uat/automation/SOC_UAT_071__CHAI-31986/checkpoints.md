# SOC_UAT_071 · CHAI-31986 — checkpoints

**Goal:** Verify ELIGIBLE when customer stayed at origin,  cancelled, ASL.

Methods: seed 17, chat 43, api 22, email 2, dashboard 25, implied 27, manual 2, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify ELIGIBLE when customer stayed at origin,  cancelled, ASL. |  |
| CP002 | PREREQUISITES | prerequisite | seed | Regime: ASL | Regime: ASL |
| CP003 | PREREQUISITES | prerequisite | seed | Carrier: AC (AC 085 TLV?YYZ) | Carrier: AC (AC 085 TLV?YYZ) |
| CP004 | PREREQUISITES | prerequisite | seed | Promised Itinerary: AC 085 TLV?YYZ, Dep: 20-Jun 16:00, Arr: 20-Jun 22:00 | Promised Itinerary: AC 085 TLV?YYZ, Dep: 20-Jun 16:00, Arr: 20-Jun 22:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual Itinerary: Flight cancelled. No alternative offered within 24h. Passenger stayed at TLV | Actual Itinerary: Flight cancelled. No alternative offered within 24h. Passenger stayed at TLV |
| CP006 | PREREQUISITES | prerequisite | seed | Delay Length: 1440 min (24 hours) | Delay Length: 1440 min (24 hours) |
| CP007 | PREREQUISITES | prerequisite | seed | Controllability: NOT CHECKED | Controllability: NOT CHECKED |
| CP008 | PREREQUISITES | prerequisite | seed | ASL regime | ASL regime |
| CP009 | PREREQUISITES | prerequisite | seed | Departure delay code: Flight cancelled (code irrelevant for ASL SOC) | Departure delay code: Flight cancelled (code irrelevant for ASL SOC) |
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
| CP024 | START | customer | chat | And the user says "My flight from Tel Aviv to Eilat was cancelled due to an air traffic control restriction and I never made it to my destin | My flight from Tel Aviv to Eilat was cancelled due to an air traffic control restriction and I never made it to my destination. I was stuck at Ben Gurion airpor |
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
| CP044 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 084 � Route: Tel Aviv (TLV) ? Eilat (VDA) � Date: June 11, 2026 � Status: CANCELLED Is this the journey you'd like t |
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
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip TLV?VDA on AC084 was cancelled due to ATC restriction � passenger stayed at origin (TLV) for 14 hours | Single-segment trip TLV?VDA on AC084 was cancelled due to ATC restriction � passenger stayed at origin (TLV) for 14 hours |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: ASL (TLV?VDA = Israel?Israel) | Regime: ASL (TLV?VDA = Israel?Israel) |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 084, Route: TLV ? VDA, Scheduled Dep: 20-Jun 16:00 | Promised Itinerary � Flight: AC 084, Route: TLV ? VDA, Scheduled Dep: 20-Jun 16:00 |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 084, Route: TLV ? VDA, Status: CANCELLED | Current Itinerary � Flight: AC 084, Route: TLV ? VDA, Status: CANCELLED |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 72 (ATC Restriction) � NOT CHECKED (ASL does not evaluate controllability) | Departure Delay Code: 72 (ATC Restriction) � NOT CHECKED (ASL does not evaluate controllability) |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Geographic Check: TLV?VDA = Israel?Israel ? PASSED ? | Geographic Check: TLV?VDA = Israel?Israel ? PASSED ? |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Cancellation: YES ? / SOC Segment Delay: 840 min (14h) ? ?2h ? | Cancellation: YES ? / SOC Segment Delay: 840 min (14h) ? ?2h ? |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: ?220.00 / ACCOMMODATION: Rate of day (max ?1,800) / GENERAL EXPEN | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: ?220.00 / ACCOMMODATION: Rate of day (max ?1,800) / GENERAL EXPENSES: Transport ?720  |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: GREEN | CyberSource: GREEN |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | Total Approved: ?960.00 ILS (Hotel ?580 + Meals ?185 + Transport ?195) | Total Approved: ?960.00 ILS (Hotel ?580 + Meals ?185 + Transport ?195) |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-ASL-EL-04 | DDS RESPONSE CODE = SoC-ASL-EL-04 |
| CP073 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP074 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger) |  |
| CP075 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates the claim |  |
| CP076 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) | ? PROCEED to eligible flow |
| CP077 | ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 084  | Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 084 from Tel Aviv to Eilat was cancelled and you wer |
| CP078 | ENTITLEMENT DISPLAY | bot | chat | Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, ASL regime: | Based on the length of your disruption (14 hours), you may be eligible for reimbursement in the following categories: � Meals: up to ?220.00 � Hotel accommodati |
| CP079 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP080 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | And the chatbot displays the receipt upload interface |  |
| CP081 | RECEIPT UPLOAD � WELCOME BACK FLOW | system | implied | And the user uploads receipt images: | � Receipt 1: Hotel receipt � ?580.00 ILS (1 night near Ben Gurion) � Receipt 2: Meal receipt � ?185.00 ILS (dinner + breakfast + lunch) � Receipt 3: Taxi receip |
| CP082 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | Then the system processes uploaded receipts through OCR (Agentic Receipt Reader) |  |
| CP083 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | And the OCR engine extracts line items from each receipt: | Receipt 1 � Hotel: � Line item: Hotel stay, 1 night � ?580.00 ILS � Date: June 11, 2026 � Category: Hotel � Within disruption window: YES ? � Rate of day compar |
| CP084 | RECEIPT VALIDATION SUMMARY | system | implied | Then the system displays the OCR validation summary: | � Total receipts processed: 3 � Total line items extracted: 5 � Items PASSED: 5 � Items FLAGGED for agent review: 0 � Items FAILED: 0 |
| CP085 | EXPENSE BREAKDOWN | system | implied | � Hotel: ?580.00 ? | � Meals: ?185.00 ? � Transport: ?195.00 ? � Communication: ?0.00 (no receipt submitted) � Parking: ?0.00 (no receipt submitted) � Essentials: ?0.00 (no receipt  |
| CP086 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case in Case Services |  |
| CP087 | CASE CREATION (GLOB-09) | system | implied | And the case includes: | � DDS response code: SoC-ASL-EL-04 � Eligibility: ELIGIBLE � Regime: ASL � Currency: ILS � All approved line items with amounts � Receipt images attached � Frau |
| CP088 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP089 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully. Here's a summary: � Case Reference: [Case Number] � Total claim amount: ?960.00 ILS � Categories: Hotel (?580.00), M |
| CP090 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP091 | NOTIFICATION | email | email | And an eligible confirmation email is sent to the passenger at t***@gmail.com |  |
| CP092 | CLAIMS PAYMENT FLOW | system | implied | Then the system initiates payment processing |  |
| CP093 | CLAIMS PAYMENT FLOW | system | implied | And Case Services calculates: | � Approved amount: ?960.00 ILS � Currency conversion to country of residence currency (if different from ILS) � Payment method per country of residence |
| CP094 | CLAIMS PAYMENT FLOW | bot | chat | Then the chatbot responds: | To complete your reimbursement, we'll need your payment details. |
| CP095 | CLAIMS PAYMENT FLOW | system | implied | And the chatbot collects: | � Country of residence: [Country] � Payment method: [determined by country] � Payment details: [collected securely] |
| CP096 | CLAIMS PAYMENT FLOW | bot | chat | Then the chatbot responds: | Your payment of [amount in local currency] will be processed via [payment method]. You should receive the funds within [X] business days. |
| CP097 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP098 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP099 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-ASL-EL-04 � ASL Eligible ATC Restriction Cancelled |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 084 TLV ? VDA as the claimed flight |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "CANCELLED" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 084 TLV ? VDA |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "ATC Restriction (Code 72 � IRRELEVANT under ASL)" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 840 min (14 hours) |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "No Travel � Stayed at Origin (TLV)" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (TLV ? VDA = Israel ? Israel)" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Cancellation Check is "CANCELLED ?" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Departure Delay is "?2h (14 hours) ?" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-ASL-EL-04" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And under APPR this would be SoC-APPR-NE-08 (NOT ELIGIBLE � ATC is uncontrollable) |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And this tests a DIFFERENT uncontrollable code (72 vs 77 in EL-02) to ensure ASL doesn't accidentally check controllability |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Hotel ?580.00 APPROVED |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Meals ?185.00 APPROVED (??220) |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Transport ?195.00 APPROVED |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is ?960.00 ILS |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 0 |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP126 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-ASL-EL-04 � ASL Eligible ATC Restriction Cancelled |  |
| CP127 | PAYMENT VALIDATION | payment | chat | Given the case SoC-ASL-EL-04 is determined as ELIGIBLE |  |
| CP128 | PAYMENT VALIDATION | payment | chat | Then SOC payment is CASH ONLY |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And the route is AC 084 TLV ? VDA CANCELLED with 14h delay for 1 adult PY |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And the approved receipts are Hotel ?580, Meals ?185, Taxi ?195 totalling ?960.00 ILS |  |
| CP131 | PAYMENT VALIDATION | payment | chat | And the country of residence determines currency and payment method |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And the Comp Status is "Sent for issuance" |  |
| CP133 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard shows ?960.00 ILS, Cash, payment method, status via talkback |  |
| CP134 | EXPECTED RESULTS | verdict | chat | SoC-ASL-EL-04. | SoC-ASL-EL-04. |
| CP135 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP136 | EXPECTED RESULTS | verdict | chat | No travel (origin), flight cancelled. | No travel (origin), flight cancelled. |
| CP137 | EXPECTED RESULTS | verdict | chat | Controllability NOT checked. | Controllability NOT checked. |
| CP138 | EXPECTED RESULTS | verdict | chat | Full receipt + case flow. | Full receipt + case flow. |
| CP139 | EXPECTED RESULTS | verdict | chat | Entitlements per  category. | Entitlements per  category. |
