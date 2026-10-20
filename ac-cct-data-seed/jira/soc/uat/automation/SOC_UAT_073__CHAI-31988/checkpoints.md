# SOC_UAT_073 · CHAI-31988 — checkpoints

**Goal:** Verify ELIGIBLE when customer at mid-point,  cancelled, ASL.

Methods: seed 14, chat 45, api 22, email 1, dashboard 25, implied 23, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify ELIGIBLE when customer at mid-point,  cancelled, ASL. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: ASL | � Regime: ASL |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Multi-segment | � Itinerary: Multi-segment |
| CP004 | PREREQUISITES | prerequisite | seed | - Segment 1: AC 090 TLV?HFA (operated normally) | - Segment 1: AC 090 TLV?HFA (operated normally) |
| CP005 | PREREQUISITES | prerequisite | seed | - Segment 2: AC 091 HFA?VDA (cancelled � crew shortage) | - Segment 2: AC 091 HFA?VDA (cancelled � crew shortage) |
| CP006 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 091 HFA?VDA (Segment 2 � cancelled) | � SOC Segment (per SoC Flight Identifier): AC 091 HFA?VDA (Segment 2 � cancelled) |
| CP007 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 090 completed. AC 091 cancelled. Stranded at HFA. Rebooked 12 hours later | � Actual Itinerary: AC 090 completed. AC 091 cancelled. Stranded at HFA. Rebooked 12 hours later |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure Delay on SOC Segment: 720 min (12 hours) | � Departure Delay on SOC Segment: 720 min (12 hours) |
| CP009 | PREREQUISITES | prerequisite | seed | � Departure delay code: 64 (Flight Crew Shortage) � Controllable � NOT CHECKED under ASL SOC (ASL does not evaluate controllability; code pr | � Departure delay code: 64 (Flight Crew Shortage) � Controllable � NOT CHECKED under ASL SOC (ASL does not evaluate controllability; code present but irrelevant |
| CP010 | PREREQUISITES | prerequisite | seed | � Controllability: NOT CHECKED � ASL regime | � Controllability: NOT CHECKED � ASL regime |
| CP011 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP012 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Regular ? ? 2. No-travel check ? Flight cancelled ? ? SOC segment departure delay ?2h ? ? ELIGIBLE | � Check Order: 1. Pax Type ? Regular ? ? 2. No-travel check ? Flight cancelled ? ? SOC segment departure delay ?2h ? ? ELIGIBLE |
| CP013 | PREREQUISITES | prerequisite | seed | � Geographic Check: TLV?HFA?VDA = ALL within Israel ? PASSED ? | � Geographic Check: TLV?HFA?VDA = ALL within Israel ? PASSED ? |
| CP014 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / ACR: No / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: YES / ACR: No / Journey: > 72h |
| CP015 | PREREQUISITES | prerequisite | seed | � ENTITLEMENTS (, 1 adult, PY, no ACR): Meals ?220 / Hotel: Rate of day, 3 nights, ?1,800 cap / Transport ?720 / Communication ?110 / Parkin | � ENTITLEMENTS (, 1 adult, PY, no ACR): Meals ?220 / Hotel: Rate of day, 3 nights, ?1,800 cap / Transport ?720 / Communication ?110 / Parking ?180 / Essentials  |
| CP016 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP017 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP018 | START | customer | chat | Then user selects English |  |
| CP019 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP020 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP021 | START | customer | chat | And the user says "I was on a connecting flight within Israel from Tel Aviv through Haifa to Eilat. My first leg was fine, but my second leg | I was on a connecting flight within Israel from Tel Aviv through Haifa to Eilat. My first leg was fine, but my second leg from Haifa to Eilat was cancelled beca |
| CP022 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP023 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP024 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP037 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP039 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP041 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 090 ? AC 091 � Route: Tel Aviv (TLV) ? Haifa (HFA) ? Eilat (VDA) � Date: June 12, 2026 � Segment 1: AC 090 TLV?HFA � |
| CP042 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? Yes (2 segments) |  |
| CP044 | SEGMENT SELECTION (GenUC-18a) | bot | chat | Then the chatbot displays the segment(s) associated with the selected journey: | Which segment was affected by the disruption? � Segment 1: AC 090 TLV?HFA (Operated normally) � Segment 2: AC 091 HFA?VDA (Cancelled) |
| CP045 | SEGMENT SELECTION (GenUC-18a) | customer | chat | And the user selects "Segment 2: AC 091 HFA?VDA" | Segment 2: AC 091 HFA?VDA |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + segment combination |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for ASL SOC |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � ASL limitation: 1,460 days (4 years) � FIXED � Days elapsed: Within limitation period ? PROCEED |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Not Completed, Disruption Detected | Trip Not Completed, Disruption Detected |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Multi-segment trip TLV?HFA?VDA � Segment 2 AC091 HFA?VDA cancelled due to crew shortage. Passenger stranded at HFA for 12 hours. | Multi-segment trip TLV?HFA?VDA � Segment 2 AC091 HFA?VDA cancelled due to crew shortage. Passenger stranded at HFA for 12 hours. |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: ASL (TLV?HFA?VDA = all Israel) | Regime: ASL (TLV?HFA?VDA = all Israel) |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 2 | PASSENGERS: 1 � SEGMENTS: 2 |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Seg 1: AC 090, TLV ? HFA / Seg 2: AC 091, HFA ? VDA | Promised Itinerary � Seg 1: AC 090, TLV ? HFA / Seg 2: AC 091, HFA ? VDA |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Seg 1: AC 090, TLV ? HFA, Status: ON TIME / Seg 2: AC 091, HFA ? VDA, Status: CANCELLED | Current Itinerary � Seg 1: AC 090, TLV ? HFA, Status: ON TIME / Seg 2: AC 091, HFA ? VDA, Status: CANCELLED |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present � SOC Segment: AC 091 HFA?VDA | SOC section present � SOC Segment: AC 091 HFA?VDA |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 64 (Flight Crew Shortage) � NOT CHECKED (ASL does not evaluate controllability) | Departure Delay Code: 64 (Flight Crew Shortage) � NOT CHECKED (ASL does not evaluate controllability) |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Geographic Check: TLV?HFA?VDA = all Israel ? PASSED ? | Geographic Check: TLV?HFA?VDA = all Israel ? PASSED ? |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Cancellation: YES ? / SOC Segment Delay: 720 min (12h) ? ?2h ? | Cancellation: YES ? / SOC Segment Delay: 720 min (12h) ? ?2h ? |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: ?220.00 / ACCOMMODATION: Rate of day (max ?1,800) / GENERAL EXPEN | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: ?220.00 / ACCOMMODATION: Rate of day (max ?1,800) / GENERAL EXPENSES: Transport ?720  |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: GREEN | CyberSource: GREEN |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | Total Approved: ?775.00 ILS (Hotel ?450 + Meals ?175 + Transport ?150) | Total Approved: ?775.00 ILS (Hotel ?450 + Meals ?175 + Transport ?150) |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-ASL-EL-06 | DDS RESPONSE CODE = SoC-ASL-EL-06 |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP073 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening (behind the scenes) |  |
| CP074 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) | ? PROCEED to eligible flow |
| CP075 | ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your connecting fli | Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your connecting flight AC 091 from Haifa to Eilat was cancelled due |
| CP076 | ENTITLEMENT DISPLAY | bot | chat | Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, ASL regime: | Based on the length of your disruption (12 hours), you may be eligible for reimbursement in the following categories: � Meals: up to ?220.00 � Hotel accommodati |
| CP077 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. |
| CP078 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | And the chatbot displays the receipt upload interface |  |
| CP079 | RECEIPT UPLOAD � WELCOME BACK FLOW | system | implied | And the user uploads receipt images: | � Receipt 1: Hotel receipt � ?450.00 ILS (1 night in Haifa) � Receipt 2: Meal receipt � ?175.00 ILS (dinner + breakfast) � Receipt 3: Taxi receipt � ?150.00 ILS |
| CP080 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | Then the system processes uploaded receipts through OCR (Agentic Receipt Reader) | Receipt 1 � Hotel: � Line item: Hotel stay, 1 night � ?450.00 ILS � Within disruption window: YES ? / Rate of day: WITHIN range ? � Nights: 1 ? / Amount: ?450 < |
| CP081 | RECEIPT VALIDATION SUMMARY | system | implied | � Total receipts: 3 / Line items: 5 / PASSED: 5 / FLAGGED: 0 / FAILED: 0 |  |
| CP082 | EXPENSE BREAKDOWN | system | implied | � Hotel: ?450.00 ? / Meals: ?175.00 ? / Transport: ?150.00 ? | � Communication: ?0.00 / Parking: ?0.00 / Essentials: ?0.00 � TOTAL APPROVED: ?775.00 ILS |
| CP083 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case with all approved line items, receipt images, fraud screening GREEN |  |
| CP084 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP085 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully. Here's a summary: � Case Reference: [Case Number] � Total claim amount: ?775.00 ILS � Categories: Hotel (?450.00), M |
| CP086 | NOTIFICATION + CLAIMS PAYMENT FLOW | email | email | Then the system triggers eligible confirmation email |  |
| CP087 | NOTIFICATION + CLAIMS PAYMENT FLOW | system | implied | Then the system initiates payment processing ? ?775.00 ILS ? country of residence currency |  |
| CP088 | NOTIFICATION + CLAIMS PAYMENT FLOW | system | implied | Then the chatbot collects payment details and payment is initiated |  |
| CP089 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP090 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP091 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-ASL-EL-06 � ASL Eligible Incomplete Journey Crew Shortage |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 090 ? AC 091 TLV ? HFA ? VDA with claim filed for segment AC 091 HFA ? VDA |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 1 AC 090 TLV ? HFA is "Operated normally" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 2 AC 091 HFA ? VDA is "CANCELLED (Crew Scheduling) � Disrupted segment" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 090 ? AC 091 TLV ? HFA ? VDA |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 091 HFA ? VDA |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "64 (Flight Crew Shortage) � IRRELEVANT under ASL" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 720 min (12 hours) |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "No Travel � Incomplete Journey (stranded at HFA)" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (TLV ? HFA ? VDA = all Israel)" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Cancellation Check is "CANCELLED ?" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Departure Delay is "?2h (12 hours) ?" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-ASL-EL-06" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Hotel ?450.00 APPROVED |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Meals ?175.00 APPROVED (??220) |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Transport ?150.00 APPROVED |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is ?775.00 ILS |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 0 |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP118 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-ASL-EL-06 � ASL Eligible Incomplete Journey Crew Shortage |  |
| CP119 | PAYMENT VALIDATION | payment | chat | Given the case SoC-ASL-EL-06 is determined as ELIGIBLE |  |
| CP120 | PAYMENT VALIDATION | payment | chat | Then SOC payment is CASH ONLY |  |
| CP121 | PAYMENT VALIDATION | payment | chat | And the route is AC 090 ? AC 091 TLV ? HFA ? VDA (stranded at HFA) with delay 720 min (12 hrs) for 1 adult PY |  |
| CP122 | PAYMENT VALIDATION | payment | chat | And ASL controllability is NOT checked |  |
| CP123 | PAYMENT VALIDATION | payment | chat | And the entitlements for 1 adult PY no ACR are Meals ?220, Hotel rate of day 3 nights max ?1,800 cap, Transport ?720, Communication ?110, Pa |  |
| CP124 | PAYMENT VALIDATION | payment | chat | And the approved receipts are Hotel ?450 (1 night in Haifa vs ?1,800 PASS), Meals ?175 (vs ?220 PASS), Taxi ?150 (vs ?720 PASS) totalling ?7 |  |
| CP125 | PAYMENT VALIDATION | payment | chat | And the country of residence determines currency and payment method |  |
| CP126 | PAYMENT VALIDATION | payment | chat | And currency conversion logging includes ILS amount, CAD equivalent, exchange rate, source, and date |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And ?775 (~$280 CAD) is less than $500 so no approval is needed |  |
| CP128 | PAYMENT VALIDATION | payment | manual | And the batch file is sent to Unifier and end-of-day report is generated |  |
| CP129 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard shows ?775.00 ILS, Cash, payment method, status via talkback |  |
| CP130 | EXPECTED RESULTS | verdict | chat | SoC-ASL-EL-06. | SoC-ASL-EL-06. |
| CP131 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP132 | EXPECTED RESULTS | verdict | chat | No travel (incomplete), flight cancelled. | No travel (incomplete), flight cancelled. |
| CP133 | EXPECTED RESULTS | verdict | chat | Controllability NOT checked. | Controllability NOT checked. |
| CP134 | EXPECTED RESULTS | verdict | chat | Full receipt + case flow. | Full receipt + case flow. |
