# SOC_UAT_068 · CHAI-31983 — checkpoints

**Goal:** Verify ELIGIBLE when customer stayed at origin,  delay ?2h, ASL regime. Full eligible flow.

Methods: seed 24, chat 47, api 23, email 3, dashboard 39, implied 28, manual 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify ELIGIBLE when customer stayed at origin,  delay ?2h, ASL regime. Full eligible flow. |  |
| CP002 | PREREQUISITES | prerequisite | seed | Regime: ASL | Regime: ASL |
| CP003 | PREREQUISITES | prerequisite | seed | Carrier: AC (AC 085 TLV?YYZ) | Carrier: AC (AC 085 TLV?YYZ) |
| CP004 | PREREQUISITES | prerequisite | seed | Promised Itinerary: AC 085 TLV?YYZ, Dep: 18-Jun 16:00, Arr: 18-Jun 22:00 | Promised Itinerary: AC 085 TLV?YYZ, Dep: 18-Jun 16:00, Arr: 18-Jun 22:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual Itinerary: Flight cancelled. Rebooked next day. Passenger stayed at origin (TLV) | Actual Itinerary: Flight cancelled. Rebooked next day. Passenger stayed at origin (TLV) |
| CP006 | PREREQUISITES | prerequisite | seed | Delay Length: 1440 min (24 hours) | Delay Length: 1440 min (24 hours) |
| CP007 | PREREQUISITES | prerequisite | seed | Controllability: NOT CHECKED | Controllability: NOT CHECKED |
| CP008 | PREREQUISITES | prerequisite | seed | ASL does not evaluate controllability for SOC | ASL does not evaluate controllability for SOC |
| CP009 | PREREQUISITES | prerequisite | seed | Departure delay code: 77 (Weather | Departure delay code: 77 (Weather |
| CP010 | PREREQUISITES | prerequisite | seed | IRRELEVANT under ASL SOC) | IRRELEVANT under ASL SOC) |
| CP011 | PREREQUISITES | prerequisite | seed | Passenger Type: Regular | Passenger Type: Regular |
| CP012 | PREREQUISITES | prerequisite | seed | Check Order: 1. Pax Type ? Regular ? ? 2. No-travel delay check ? ?2h ? ELIGIBLE (no controllability check) | Check Order: 1. Pax Type ? Regular ? ? 2. No-travel delay check ? ?2h ? ELIGIBLE (no controllability check) |
| CP013 | PREREQUISITES | prerequisite | seed | Note: ASL regime = eligible regardless of controllability (same as EU) | Note: ASL regime = eligible regardless of controllability (same as EU) |
| CP014 | PREREQUISITES | prerequisite | seed | Geographic Check: Origin = TLV (Israel) ? / Destination = YYZ ? itinerary starts in Israel ? | Geographic Check: Origin = TLV (Israel) ? / Destination = YYZ ? itinerary starts in Israel ? |
| CP015 | PREREQUISITES | prerequisite | seed | PAX Count: 1 adult | PAX Count: 1 adult |
| CP016 | PREREQUISITES | prerequisite | seed | Class of Booking: PY | Class of Booking: PY |
| CP017 | PREREQUISITES | prerequisite | seed | Revenue Booking: YES | Revenue Booking: YES |
| CP018 | PREREQUISITES | prerequisite | seed | ACR Issued: Hotel: No, Transport: No, Meal: No | ACR Issued: Hotel: No, Transport: No, Meal: No |
| CP019 | PREREQUISITES | prerequisite | seed | Journey Completed: > 72h ENTITLEMENTS (, 1 adult, PY, no ACR): | Journey Completed: > 72h ENTITLEMENTS (, 1 adult, PY, no ACR): |
| CP020 | PREREQUISITES | prerequisite | seed | Meals: $60/pax (converted to ILS for ASL regime) | Meals: $60/pax (converted to ILS for ASL regime) |
| CP021 | PREREQUISITES | prerequisite | seed | Hotel: Rate of day, max 3 nights, $500 cap | Hotel: Rate of day, max 3 nights, $500 cap |
| CP022 | PREREQUISITES | prerequisite | seed | Transport: $200 (1-5 pax) | Transport: $200 (1-5 pax) |
| CP023 | PREREQUISITES | prerequisite | seed | Communication: $30/pax | Communication: $30/pax |
| CP024 | PREREQUISITES | prerequisite | seed | Parking: $50, 1 day max | Parking: $50, 1 day max |
| CP025 | PREREQUISITES | prerequisite | seed | Essentials: $30/pax | Essentials: $30/pax |
| CP026 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP027 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP028 | START | customer | chat | Then user selects English |  |
| CP029 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP030 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP031 | START | customer | chat | And the user says "My Air Canada flight from Tel Aviv to Toronto was delayed by about 7 hours because of bad weather. I had to buy food, pay | My Air Canada flight from Tel Aviv to Toronto was delayed by about 7 hours because of bad weather. I had to buy food, pay for a hotel overnight, and take a taxi |
| CP032 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP033 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP034 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP035 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP036 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP037 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP038 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP039 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP040 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP041 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP042 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP043 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP044 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP045 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP046 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP047 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP048 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP049 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP050 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP051 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 084 � Route: Tel Aviv (TLV) ? Toronto (YYZ) � Date: June 10, 2026 � Departure Delay: 7 hours Is this the journey you |
| CP052 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP053 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP054 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP055 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP056 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP057 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP058 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for ASL SOC |  |
| CP059 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � ASL limitation: 1,460 days (4 years) � FIXED � Days elapsed: Within limitation period ? PROCEED |
| CP060 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip TLV?YYZ on AC085 was delayed +7H 00M (note: prereqs say 24h/1440 min but chatbot says 7h � use chatbot flow: 7h) due to  | Single-segment trip TLV?YYZ on AC085 was delayed +7H 00M (note: prereqs say 24h/1440 min but chatbot says 7h � use chatbot flow: 7h) due to weather (uncontrolla |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: ASL (TLV departure � Israel) | Regime: ASL (TLV departure � Israel) |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 085, Route: TLV ? YYZ, Scheduled Dep: 18-Jun 16:00 | Promised Itinerary � Flight: AC 085, Route: TLV ? YYZ, Scheduled Dep: 18-Jun 16:00 |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 085, Route: TLV ? YYZ, Status: ARRIVED LATE, Delay: +7H 00M | Current Itinerary � Flight: AC 085, Route: TLV ? YYZ, Status: ARRIVED LATE, Delay: +7H 00M |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 77 (Weather) � NOT CHECKED (ASL does not evaluate controllability) | Departure Delay Code: 77 (Weather) � NOT CHECKED (ASL does not evaluate controllability) |
| CP073 | TRIP TRACER UI VALIDATIONS | verdict | api | Geographic Check: Origin = TLV (Israel) ? | Geographic Check: Origin = TLV (Israel) ? |
| CP074 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: ?110.00 / ACCOMMODATION: Rate of day (max ?1,800) / GENERAL EXPEN | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: ?110.00 / ACCOMMODATION: Rate of day (max ?1,800) / GENERAL EXPENSES: Transport ?720  |
| CP075 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: GREEN | CyberSource: GREEN |
| CP076 | TRIP TRACER UI VALIDATIONS | verdict | api | CRITICAL: Weather = NOT ELIGIBLE under APPR (NE-07) but ELIGIBLE under ASL (EL-01) | CRITICAL: Weather = NOT ELIGIBLE under APPR (NE-07) but ELIGIBLE under ASL (EL-01) |
| CP077 | TRIP TRACER UI VALIDATIONS | verdict | api | Currency: ILS (Israeli New Shekel � ?) | Currency: ILS (Israeli New Shekel � ?) |
| CP078 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE |
| CP079 | TRIP TRACER UI VALIDATIONS | verdict | api | Total Approved: ?870.00 ILS (Hotel ?550 + Meals ?95 + Transport ?180 + Comm ?45) | Total Approved: ?870.00 ILS (Hotel ?550 + Meals ?95 + Transport ?180 + Comm ?45) |
| CP080 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-ASL-EL-01 | DDS RESPONSE CODE = SoC-ASL-EL-01 |
| CP081 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP082 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger) |  |
| CP083 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates the claim |  |
| CP084 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) | ? PROCEED to eligible flow |
| CP085 | ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 084  | Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 084 from Tel Aviv to Eilat was delayed by approximat |
| CP086 | ENTITLEMENT DISPLAY | bot | chat | Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, ASL regime: | "Based on the length of your disruption (7 hours), you may be eligible for reimbursement in the following categories: � Meals: up to ?110.00 � Hotel accommodati |
| CP087 | ASL CURRENCY NOTE | system | implied | ASL entitlements are calculated in ILS (Israeli New Shekel � ?). | Receipts may be in any currency � Case Services handles conversion: 1. Receipt currency ? regime currency (ILS) for threshold comparison 2. Regime currency ? co |
| CP088 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP089 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | And the chatbot displays the receipt upload interface |  |
| CP090 | RECEIPT UPLOAD � WELCOME BACK FLOW | system | implied | And the user uploads receipt images: | � Receipt 1: Hotel receipt � ?550.00 ILS (1 night near Ben Gurion) � Receipt 2: Meal receipt � ?95.00 ILS (dinner + breakfast) � Receipt 3: Taxi receipt � ?180. |
| CP091 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | Then the system processes uploaded receipts through OCR (Agentic Receipt Reader) |  |
| CP092 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | And the OCR engine extracts line items from each receipt: | Receipt 1 � Hotel: � Line item: Hotel stay, 1 night � ?550.00 ILS � Date: June 10, 2026 � Category: Hotel � Within disruption window: YES ? � Rate of day compar |
| CP093 | RECEIPT VALIDATION SUMMARY | system | implied | Then the system displays the OCR validation summary: | � Total receipts processed: 4 � Total line items extracted: 6 � Items PASSED: 6 � Items FLAGGED for agent review: 0 � Items FAILED: 0 |
| CP094 | EXPENSE BREAKDOWN | system | implied | � Hotel: ?550.00 ? | � Meals: ?95.00 ? � Transport: ?180.00 ? � Communication: ?45.00 ? � Parking: ?0.00 (no receipt submitted) � Essentials: ?0.00 (no receipt submitted) � TOTAL AP |
| CP095 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case in Case Services |  |
| CP096 | CASE CREATION (GLOB-09) | system | implied | And the case includes: | � DDS response code: SoC-ASL-EL-01 � Eligibility: ELIGIBLE � Regime: ASL � Currency: ILS (receipts in ILS � no conversion needed for threshold comparison) � All |
| CP097 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP098 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully. Here's a summary: � Case Reference: [Case Number] � Total claim amount: ?870.00 ILS � Categories: Hotel (?550.00), M |
| CP099 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP100 | NOTIFICATION | email | email | And an eligible confirmation email is sent to the passenger at t***@gmail.com |  |
| CP101 | NOTIFICATION | email | email | And the email includes: | � Case reference number � Claim summary with approved amounts (in country of residence currency) � Next steps for payment processing |
| CP102 | CLAIMS PAYMENT FLOW | system | implied | Then the system initiates payment processing |  |
| CP103 | CLAIMS PAYMENT FLOW | system | implied | And Case Services calculates: | � Approved amount: ?870.00 ILS � Currency conversion to country of residence currency (if different from ILS) � Payment method determination based on country of |
| CP104 | CLAIMS PAYMENT FLOW | bot | chat | Then the chatbot responds: | To complete your reimbursement, we'll need your payment details. |
| CP105 | CLAIMS PAYMENT FLOW | system | implied | And the chatbot collects: | � Country of residence: [Country] � Payment method: [determined by country] � Payment details: [collected securely] |
| CP106 | CLAIMS PAYMENT FLOW | bot | chat | Then the chatbot responds: | Your payment of [amount in local currency] will be processed via [payment method]. You should receive the funds within [X] business days. |
| CP107 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP108 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP109 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-ASL-EL-01 � ASL Eligible Travel Completed Weather |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "ASL" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Regular" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 084 TLV ? VDA as the claimed flight |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (7 hours)" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 084 TLV ? VDA |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 084 |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Weather (Code 77 � IRRELEVANT under ASL)" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 420 min (7 hours) |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed Departure)" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (TLV ? VDA = Israel ? Israel)" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED (ASL regime � controllability irrelevant, same as EU)" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Overnight Eligible is "YES (delay >360 min)" |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-ASL-EL-01" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And under APPR this would be SoC-APPR-NE-07 (NOT ELIGIBLE � weather is uncontrollable), under EU SoC-EU-EL-01 (ELIGIBLE), and under ASL SoC- |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Hotel ?550.00 APPROVED |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Meals ?95.00 APPROVED (??110) |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Transport ?180.00 APPROVED (??720) |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Communication ?45.00 APPROVED (??110) |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Parking ?0.00 No receipt |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Essentials ?0.00 No receipt |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is ?870.00 ILS |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 0 |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved" |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP152 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-ASL-EL-01 � ASL Eligible Travel Completed Weather |  |
| CP153 | PAYMENT VALIDATION | payment | chat | Given the case SoC-ASL-EL-01 is determined as ELIGIBLE |  |
| CP154 | PAYMENT VALIDATION | payment | chat | Then SOC payment is CASH ONLY |  |
| CP155 | PAYMENT VALIDATION | payment | chat | And the route is AC 084 TLV ? VDA with delay 420 min (7 hrs) for 1 adult PY |  |
| CP156 | PAYMENT VALIDATION | payment | chat | And ASL controllability is NOT checked |  |
| CP157 | PAYMENT VALIDATION | payment | chat | And the approved receipts are Hotel ?550, Meals ?95, Taxi ?180, Comm ?45 totalling ?870.00 ILS |  |
| CP158 | PAYMENT VALIDATION | payment | chat | And the receipts are in ILS so no conversion is needed for threshold comparison |  |
| CP159 | PAYMENT VALIDATION | payment | chat | And the country of residence determines payout currency and method |  |
| CP160 | PAYMENT VALIDATION | payment | chat | And currency conversion logging includes ILS amount, CAD equivalent, and exchange rate |  |
| CP161 | PAYMENT VALIDATION | payment | chat | And the Comp Status is "Sent for issuance" |  |
| CP162 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard shows ?870.00 ILS, Cash, payment method, status via talkback |  |
| CP163 | EXPECTED RESULTS | verdict | chat | SoC-ASL-EL-01. | SoC-ASL-EL-01. |
| CP164 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP165 | EXPECTED RESULTS | verdict | chat | No travel (origin), delay ?2h. | No travel (origin), delay ?2h. |
| CP166 | EXPECTED RESULTS | verdict | chat | Controllability NOT checked (ASL regime). | Controllability NOT checked (ASL regime). |
| CP167 | EXPECTED RESULTS | verdict | chat | Geographic check passed: origin = TLV (Israel). | Geographic check passed: origin = TLV (Israel). |
| CP168 | EXPECTED RESULTS | verdict | chat | Entitlements in ILS. | Entitlements in ILS. |
| CP169 | EXPECTED RESULTS | verdict | chat | Full receipt + case flow. | Full receipt + case flow. |
