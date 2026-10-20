# SOC_UAT_074 · CHAI-31989 — checkpoints

**Goal:** Verify ELIGIBLE when customer traveled to destination with transit delay ?2h under ASL. Any disruption type qualifies.

Methods: seed 15, chat 46, api 21, email 1, dashboard 26, implied 23, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify ELIGIBLE when customer traveled to destination with transit delay ?2h under ASL. Any disruption type qualifies. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: ASL | � Regime: ASL |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 084 TLV?VDA | � Itinerary: Single segment � AC 084 TLV?VDA |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 084 TLV?VDA | � SOC Segment (per SoC Flight Identifier): AC 084 TLV?VDA |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 084 TLV?VDA, Dep: 22-Jun 16:00 | � Promised Itinerary: AC 084 TLV?VDA, Dep: 22-Jun 16:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 084 TLV?VDA, Dep: 22-Jun 23:00 | � Actual Itinerary: AC 084 TLV?VDA, Dep: 22-Jun 23:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 420 min (7 hours) | � Departure Delay: 420 min (7 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 77 (Weather) � Uncontrollable � NOT CHECKED under ASL SOC (ASL does not evaluate controllability; code present but i | � Departure delay code: 77 (Weather) � Uncontrollable � NOT CHECKED under ASL SOC (ASL does not evaluate controllability; code present but irrelevant) |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: NOT CHECKED � ASL does not evaluate controllability for SOC | � Controllability: NOT CHECKED � ASL does not evaluate controllability for SOC |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP011 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Regular ? ? 2. Transit departure delay check ? ?2h ? ELIGIBLE (no controllability check) | � Check Order: 1. Pax Type ? Regular ? ? 2. Transit departure delay check ? ?2h ? ELIGIBLE (no controllability check) |
| CP012 | PREREQUISITES | prerequisite | seed | � Note: SAME AS EU � controllability not checked. Under APPR, weather + regular pax = NOT ELIGIBLE (NE-07). Under ASL = ELIGIBLE | � Note: SAME AS EU � controllability not checked. Under APPR, weather + regular pax = NOT ELIGIBLE (NE-07). Under ASL = ELIGIBLE |
| CP013 | PREREQUISITES | prerequisite | seed | � Geographic Check: Origin = TLV (Israel) ? / Destination = VDA (Israel) ? ? BOTH Israel ? PASSED ? | � Geographic Check: Origin = TLV (Israel) ? / Destination = VDA (Israel) ? ? BOTH Israel ? PASSED ? |
| CP014 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / ACR: No / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: YES / ACR: No / Journey: > 72h |
| CP015 | PREREQUISITES | prerequisite | seed | � Overnight Eligible: YES (delay >360 min) | � Overnight Eligible: YES (delay >360 min) |
| CP016 | PREREQUISITES | prerequisite | seed | � ENTITLEMENTS (, 1 adult, PY, no ACR): Meals ?110 / Hotel: Rate of day, ?1,800 cap / Transport ?720 / Communication ?110 / Parking ?180 / E | � ENTITLEMENTS (, 1 adult, PY, no ACR): Meals ?110 / Hotel: Rate of day, ?1,800 cap / Transport ?720 / Communication ?110 / Parking ?180 / Essentials ?110 |
| CP017 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP018 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP019 | START | customer | chat | Then user selects English |  |
| CP020 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP021 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP022 | START | customer | chat | And the user says "My Air Canada flight from Tel Aviv to Eilat was delayed by about 8 hours because of a crew scheduling issue. I had to buy | My Air Canada flight from Tel Aviv to Eilat was delayed by about 8 hours because of a crew scheduling issue. I had to buy food, pay for a hotel overnight, and t |
| CP023 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP024 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP025 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP038 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP041 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP042 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 084 � Route: Tel Aviv (TLV) ? Eilat (VDA) � Date: June 14, 2026 � Departure Delay: 8 hours Is this the journey you'd |
| CP043 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP047 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP049 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for ASL SOC |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � ASL limitation: 1,460 days (4 years) � FIXED � Days elapsed: Within limitation period ? PROCEED |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip TLV?VDA on AC084 was delayed +7H 00M (note: prereqs say 7h/420 min, chatbot says 8h � use prereqs: 7h) due to weather (u | Single-segment trip TLV?VDA on AC084 was delayed +7H 00M (note: prereqs say 7h/420 min, chatbot says 8h � use prereqs: 7h) due to weather (uncontrollable � NOT  |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: ASL (TLV?VDA = Israel?Israel) | Regime: ASL (TLV?VDA = Israel?Israel) |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 084, Route: TLV ? VDA, Scheduled Dep: 22-Jun 16:00 | Promised Itinerary � Flight: AC 084, Route: TLV ? VDA, Scheduled Dep: 22-Jun 16:00 |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 084, Route: TLV ? VDA, Status: ARRIVED LATE, Scheduled Dep: 16:00 ? Actual: 23:00, Delay: +7H 00M | Current Itinerary � Flight: AC 084, Route: TLV ? VDA, Status: ARRIVED LATE, Scheduled Dep: 16:00 ? Actual: 23:00, Delay: +7H 00M |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 77 (Weather) � NOT CHECKED (ASL does not evaluate controllability) | Departure Delay Code: 77 (Weather) � NOT CHECKED (ASL does not evaluate controllability) |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Geographic Check: TLV?VDA = Israel?Israel ? PASSED ? | Geographic Check: TLV?VDA = Israel?Israel ? PASSED ? |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: ?110.00 / ACCOMMODATION: Rate of day (max ?1,800) / GENERAL EXPEN | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: ?110.00 / ACCOMMODATION: Rate of day (max ?1,800) / GENERAL EXPENSES: Transport ?720  |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: GREEN | CyberSource: GREEN |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | Total Approved: ?830.00 ILS (Hotel ?520 + Meals ?95 + Transport ?175 + Comm ?40) | Total Approved: ?830.00 ILS (Hotel ?520 + Meals ?95 + Transport ?175 + Comm ?40) |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-ASL-EL-07 | DDS RESPONSE CODE = SoC-ASL-EL-07 |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP071 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening (behind the scenes) |  |
| CP072 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) | ? PROCEED to eligible flow |
| CP073 | ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 084  | Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 084 from Tel Aviv to Eilat was delayed by approximat |
| CP074 | ENTITLEMENT DISPLAY | bot | chat | Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, ASL regime: | Based on the length of your disruption (8 hours), you may be eligible for reimbursement in the following categories: � Meals: up to ?110.00 � Hotel accommodatio |
| CP075 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. |
| CP076 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | And the chatbot displays the receipt upload interface |  |
| CP077 | RECEIPT UPLOAD � WELCOME BACK FLOW | system | implied | And the user uploads receipt images: | � Receipt 1: Hotel receipt � ?520.00 ILS (1 night) � Receipt 2: Meal receipt � ?95.00 ILS (dinner + breakfast) � Receipt 3: Taxi receipt � ?175.00 ILS (airport  |
| CP078 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | Then the system processes uploaded receipts through OCR (Agentic Receipt Reader) | Receipt 1 � Hotel: � Line item: Hotel stay, 1 night � ?520.00 ILS � Within disruption window: YES ? / Rate of day: WITHIN range ? � Nights: 1 ? / Amount: ?520 < |
| CP079 | RECEIPT VALIDATION SUMMARY | system | implied | � Total receipts: 4 / Line items: 7 / PASSED: 7 / FLAGGED: 0 / FAILED: 0 |  |
| CP080 | EXPENSE BREAKDOWN | system | implied | � Hotel: ?520.00 ? / Meals: ?95.00 ? / Transport: ?175.00 ? / Communication: ?40.00 ? | � Parking: ?0.00 / Essentials: ?0.00 � TOTAL APPROVED: ?830.00 ILS |
| CP081 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case with all approved line items, receipt images, fraud screening GREEN |  |
| CP082 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP083 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully. Here's a summary: � Case Reference: [Case Number] � Total claim amount: ?830.00 ILS � Categories: Hotel (?520.00), M |
| CP084 | NOTIFICATION + CLAIMS PAYMENT FLOW | email | email | Then the system triggers eligible confirmation email |  |
| CP085 | NOTIFICATION + CLAIMS PAYMENT FLOW | system | implied | Then the system initiates payment processing ? ?830.00 ILS ? country of residence currency |  |
| CP086 | NOTIFICATION + CLAIMS PAYMENT FLOW | system | implied | Then the chatbot collects payment details and payment is initiated |  |
| CP087 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP088 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP089 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-ASL-EL-07 � ASL Eligible Travel Completed Crew Scheduling |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 084 TLV ? VDA as the claimed flight |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (8 hours)" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 084 TLV ? VDA |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 084 |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Crew Scheduling (Code 41 � IRRELEVANT under ASL)" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 480 min (8 hours) |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed Departure)" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (TLV ? VDA = Israel ? Israel)" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Overnight Eligible is "YES" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-ASL-EL-07" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And under APPR this would be SoC-APPR-EL-08 (also ELIGIBLE � crew is controllable) and both regimes agree for controllable disruptions |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Hotel ?520.00 APPROVED |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Meals ?95.00 APPROVED (??110) |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Transport ?175.00 APPROVED |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Communication ?40.00 APPROVED (??110) |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is ?830.00 ILS |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 0 |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP117 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-ASL-EL-07 � ASL Eligible Travel Completed Crew Scheduling |  |
| CP118 | PAYMENT VALIDATION | payment | chat | Given the case SoC-ASL-EL-07 is determined as ELIGIBLE |  |
| CP119 | PAYMENT VALIDATION | payment | chat | Then SOC payment is CASH ONLY |  |
| CP120 | PAYMENT VALIDATION | payment | chat | And the route is AC 084 TLV ? VDA with delay 480 min (8 hrs) for 1 adult PY |  |
| CP121 | PAYMENT VALIDATION | payment | chat | And ASL controllability is NOT checked |  |
| CP122 | PAYMENT VALIDATION | payment | chat | And the entitlements for 1 adult PY no ACR are Meals ?110, Hotel rate of day 3 nights max ?1,800 cap, Transport ?720, Communication ?110, Pa |  |
| CP123 | PAYMENT VALIDATION | payment | chat | And the approved receipts are Hotel ?520 (vs ?1,800 PASS), Meals ?95 (vs ?110 PASS), Taxi ?175 (vs ?720 PASS), Comm ?40 (vs ?110 PASS) total |  |
| CP124 | PAYMENT VALIDATION | payment | chat | And the country of residence determines currency and payment method |  |
| CP125 | PAYMENT VALIDATION | payment | chat | And currency conversion logging includes ILS amount, CAD equivalent, exchange rate, source, and date |  |
| CP126 | PAYMENT VALIDATION | payment | chat | And ?830 (~$300 CAD) is less than $500 so no approval is needed |  |
| CP127 | PAYMENT VALIDATION | payment | manual | And the batch file is sent to Unifier and end-of-day report is generated |  |
| CP128 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard shows ?830.00 ILS, Cash, payment method, status via talkback |  |
| CP129 | EXPECTED RESULTS | verdict | chat | SoC-ASL-EL-07. | SoC-ASL-EL-07. |
| CP130 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP131 | EXPECTED RESULTS | verdict | chat | Transit delay ?2h (7 hours,  category). | Transit delay ?2h (7 hours,  category). |
| CP132 | EXPECTED RESULTS | verdict | chat | Controllability NOT checked � same behavior as EU regime. | Controllability NOT checked � same behavior as EU regime. |
| CP133 | EXPECTED RESULTS | verdict | chat | Same weather scenario under APPR with regular pax = NOT ELIGIBLE (NE-07). | Same weather scenario under APPR with regular pax = NOT ELIGIBLE (NE-07). |
| CP134 | EXPECTED RESULTS | verdict | chat | Under ASL = ELIGIBLE regardless of disruption type. | Under ASL = ELIGIBLE regardless of disruption type. |
| CP135 | EXPECTED RESULTS | verdict | chat | Entitlements in ILS. | Entitlements in ILS. |
| CP136 | EXPECTED RESULTS | verdict | chat | Full receipt + case flow. | Full receipt + case flow. |
