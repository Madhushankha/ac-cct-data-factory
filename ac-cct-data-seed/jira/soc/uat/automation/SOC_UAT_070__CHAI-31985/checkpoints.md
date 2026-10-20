# SOC_UAT_070 · CHAI-31985 — checkpoints

**Goal:** Verify ELIGIBLE when customer at mid-point, didn't reach destination,  delay ?2h, ASL.

Methods: seed 26, chat 48, api 24, email 2, dashboard 34, implied 27, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify ELIGIBLE when customer at mid-point, didn't reach destination,  delay ?2h, ASL. |  |
| CP002 | PREREQUISITES | prerequisite | seed | Regime: ASL | Regime: ASL |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: Multi-segmen | Itinerary: Multi-segmen |
| CP004 | PREREQUISITES | prerequisite | seed | Segment 1: AC 090 TLV?HFA, Dep: 13-Jun 08:00 (operated normally) | Segment 1: AC 090 TLV?HFA, Dep: 13-Jun 08:00 (operated normally) |
| CP005 | PREREQUISITES | prerequisite | seed | Segment 2: AC 091 HFA?VDA, Dep: 13-Jun 14:00 (cancelled, rebooked) | Segment 2: AC 091 HFA?VDA, Dep: 13-Jun 14:00 (cancelled, rebooked) |
| CP006 | PREREQUISITES | prerequisite | seed | SOC Segment (per SoC Flight Identifier): AC 091 HFA?VDA (Segment 2 � cancelled) | SOC Segment (per SoC Flight Identifier): AC 091 HFA?VDA (Segment 2 � cancelled) |
| CP007 | PREREQUISITES | prerequisite | seed | Promised Itinerary: AC 090 TLV?HFA, then AC 091 HFA?VDA | Promised Itinerary: AC 090 TLV?HFA, then AC 091 HFA?VDA |
| CP008 | PREREQUISITES | prerequisite | seed | Actual Itinerary: AC 090 completed. AC 091 cancelled. Stranded at HFA. Rebooked 3 hours later | Actual Itinerary: AC 090 completed. AC 091 cancelled. Stranded at HFA. Rebooked 3 hours later |
| CP009 | PREREQUISITES | prerequisite | seed | Departure Delay on SOC Segment: 180 min (3 hours) | Departure Delay on SOC Segment: 180 min (3 hours) |
| CP010 | PREREQUISITES | prerequisite | seed | Departure delay code: 05 (Aircraft Defect) � present in flight data but NOT CHECKED under ASL SOC | Departure delay code: 05 (Aircraft Defect) � present in flight data but NOT CHECKED under ASL SOC |
| CP011 | PREREQUISITES | prerequisite | seed | Controllability: NOT CHECKED � ASL regime does not evaluate controllability for SOC | Controllability: NOT CHECKED � ASL regime does not evaluate controllability for SOC |
| CP012 | PREREQUISITES | prerequisite | seed | Passenger Type: Regular | Passenger Type: Regular |
| CP013 | PREREQUISITES | prerequisite | seed | Check Order: 1. Pax Type ? Regular ? ? 2. No-travel check ? SOC segment cancelled ? ? SOC segment departure delay ?2h ? ? ELIGIBLE (no contr | Check Order: 1. Pax Type ? Regular ? ? 2. No-travel check ? SOC segment cancelled ? ? SOC segment departure delay ?2h ? ? ELIGIBLE (no controllability check) |
| CP014 | PREREQUISITES | prerequisite | seed | Geographic Check: TLV (Israel) ? HFA (Israel) ? VDA (Israel) ? ALL Israel ? PASSED ? | Geographic Check: TLV (Israel) ? HFA (Israel) ? VDA (Israel) ? ALL Israel ? PASSED ? |
| CP015 | PREREQUISITES | prerequisite | seed | PAX Count: 1 adult | PAX Count: 1 adult |
| CP016 | PREREQUISITES | prerequisite | seed | Class of Booking: J (Business) | Class of Booking: J (Business) |
| CP017 | PREREQUISITES | prerequisite | seed | Revenue Booking: YES | Revenue Booking: YES |
| CP018 | PREREQUISITES | prerequisite | seed | ACR Issued: Hotel: No, Transport: No, Meal: No | ACR Issued: Hotel: No, Transport: No, Meal: No |
| CP019 | PREREQUISITES | prerequisite | seed | Journey Completed: > 72h | Journey Completed: > 72h |
| CP020 | PREREQUISITES | prerequisite | seed | J CABIN MEAL NOTE: J cabin passengers receive meal entitlement at standard CCT rate | J CABIN MEAL NOTE: J cabin passengers receive meal entitlement at standard CCT rate |
| CP021 | PREREQUISITES | prerequisite | seed | ENTITLEMENTS (1 adult, J class, no ACR � LIMITED) | ENTITLEMENTS (1 adult, J class, no ACR � LIMITED) |
| CP022 | PREREQUISITES | prerequisite | seed | Meals: ?55 (lower tier) | Meals: ?55 (lower tier) |
| CP023 | PREREQUISITES | prerequisite | seed | Communication: ?110 | Communication: ?110 |
| CP024 | PREREQUISITES | prerequisite | seed | Hotel: NOT ENTITLED (delay <360 min) | Hotel: NOT ENTITLED (delay <360 min) |
| CP025 | PREREQUISITES | prerequisite | seed | Transport: NOT ENTITLED (delay <360 min) | Transport: NOT ENTITLED (delay <360 min) |
| CP026 | PREREQUISITES | prerequisite | seed | Parking: NOT ENTITLED (delay <300 min) | Parking: NOT ENTITLED (delay <300 min) |
| CP027 | PREREQUISITES | prerequisite | seed | Essentials: NOT ENTITLED (delay <300 min) | Essentials: NOT ENTITLED (delay <300 min) |
| CP028 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP029 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP030 | START | customer | chat | Then user selects English |  |
| CP031 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP032 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP033 | START | customer | chat | And the user says "I was on a connecting flight within Israel from Tel Aviv through Haifa to Eilat. My first leg was fine, but my second leg | I was on a connecting flight within Israel from Tel Aviv through Haifa to Eilat. My first leg was fine, but my second leg from Haifa to Eilat was cancelled beca |
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
| CP053 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 090 ? AC 091 � Route: Tel Aviv (TLV) ? Haifa (HFA) ? Eilat (VDA) � Date: June 13, 2026 � Departure Delay: 180 min (3 |
| CP054 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP055 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? Yes (2 segments) |  |
| CP056 | SEGMENT SELECTION (GenUC-18a) | bot | chat | Then the chatbot displays: "Which segment was affected by the disruption? | * Segment 1: AC 090 TLV?HFA (Operated normally) * Segment 2: AC 091 HFA?VDA (Cancelled)" |
| CP057 | SEGMENT SELECTION (GenUC-18a) | customer | chat | And the user selects "Segment 2: AC 091 HFA?VDA" | Segment 2: AC 091 HFA?VDA |
| CP058 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP059 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP060 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP061 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 73 hours for all segments in the selected journey ? Yes |  |
| CP062 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for ASL SOC |  |
| CP063 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � ASL limitation: 1,460 days (4 years) � FIXED � Days elapsed: Within limitation period ? PROCEED |
| CP064 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP065 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP066 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Not Completed, Disruption Detected | Trip Not Completed, Disruption Detected |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | Multi-segment trip TLV?HFA?VDA � Segment 2 AC091 HFA?VDA was cancelled due to aircraft defect. Passenger stranded at HFA for 3 hours. | Multi-segment trip TLV?HFA?VDA � Segment 2 AC091 HFA?VDA was cancelled due to aircraft defect. Passenger stranded at HFA for 3 hours. |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: ASL (TLV?HFA?VDA = all Israel) | Regime: ASL (TLV?HFA?VDA = all Israel) |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 2 | PASSENGERS: 1 � SEGMENTS: 2 |
| CP073 | TRIP TRACER UI VALIDATIONS | verdict | api | Class of Booking: J (Business) | Class of Booking: J (Business) |
| CP074 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Seg 1: AC 090, TLV ? HFA / Seg 2: AC 091, HFA ? VDA | Promised Itinerary � Seg 1: AC 090, TLV ? HFA / Seg 2: AC 091, HFA ? VDA |
| CP075 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Seg 1: AC 090, TLV ? HFA, Status: ON TIME / Seg 2: AC 091, HFA ? VDA, Status: CANCELLED | Current Itinerary � Seg 1: AC 090, TLV ? HFA, Status: ON TIME / Seg 2: AC 091, HFA ? VDA, Status: CANCELLED |
| CP076 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present � SOC Segment: AC 091 HFA?VDA | SOC section present � SOC Segment: AC 091 HFA?VDA |
| CP077 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 05 (Aircraft Defect) � NOT CHECKED (ASL does not evaluate controllability) | Departure Delay Code: 05 (Aircraft Defect) � NOT CHECKED (ASL does not evaluate controllability) |
| CP078 | TRIP TRACER UI VALIDATIONS | verdict | api | Geographic Check: TLV?HFA?VDA = all Israel ? PASSED ? | Geographic Check: TLV?HFA?VDA = all Israel ? PASSED ? |
| CP079 | TRIP TRACER UI VALIDATIONS | verdict | api | Cancellation: YES ? / SOC Segment Delay: 180 min (3h) ? ?2h ? | Cancellation: YES ? / SOC Segment Delay: 180 min (3h) ? ?2h ? |
| CP080 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_2_TO_6_HOURS / MEAL: ?55.00 (LIMITED � short delay tier) / ACCOMMODATION: � (NOT ENTITLED | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_2_TO_6_HOURS / MEAL: ?55.00 (LIMITED � short delay tier) / ACCOMMODATION: � (NOT ENTITLED, delay <6h) / GENER |
| CP081 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: GREEN | CyberSource: GREEN |
| CP082 | TRIP TRACER UI VALIDATIONS | verdict | api | LIMITED entitlements: Meals ?55 + Comm ?110 only. No hotel/transport/parking/essentials. | LIMITED entitlements: Meals ?55 + Comm ?110 only. No hotel/transport/parking/essentials. |
| CP083 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE |
| CP084 | TRIP TRACER UI VALIDATIONS | verdict | api | Total Approved: ?83.00 ILS (Meals ?48 + Comm ?35) | Total Approved: ?83.00 ILS (Meals ?48 + Comm ?35) |
| CP085 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-ASL-EL-03 | DDS RESPONSE CODE = SoC-ASL-EL-03 |
| CP086 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP087 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger) |  |
| CP088 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates the claim |  |
| CP089 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) | ? PROCEED to eligible flow |
| CP090 | ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "Your connecting flight AC 091 from Haifa to Eilat was cancelled due to an aircraft defect, and you were stranded | Your connecting flight AC 091 from Haifa to Eilat was cancelled due to an aircraft defect, and you were stranded in Haifa for approximately 3 hours. |
| CP091 | ENTITLEMENT DISPLAY | bot | chat | Then the chatbot displays the eligible expense categories based on  delay, 1 adult, J class, ASL regime: | Based on the length of your disruption (3 hours), you may be eligible for reimbursement in the following categories: � Meals: up to ?55.00 � Communication: up t |
| CP092 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP093 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | And the chatbot displays the receipt upload interface |  |
| CP094 | RECEIPT UPLOAD � WELCOME BACK FLOW | system | implied | And the user uploads receipt images: | � Receipt 1: Meal receipt � ?48.00 ILS (sandwich + coffee + water at Ben Gurion) � Receipt 2: Communication � ?35.00 ILS (Wi-Fi access + phone calls) |
| CP095 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | Then the system processes uploaded receipts through OCR (Agentic Receipt Reader) |  |
| CP096 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | And the OCR engine extracts line items from each receipt: | Receipt 1 � Meals: � Line item 1: Sandwich � ?28.00 ILS � Line item 2: Coffee � ?14.00 ILS � Line item 3: Water � ?6.00 ILS � Total meals: ?48.00 ILS � Date: Ju |
| CP097 | RECEIPT VALIDATION SUMMARY | system | implied | Then the system displays the OCR validation summary: | � Total receipts processed: 2 � Total line items extracted: 5 � Items PASSED: 5 � Items FLAGGED for agent review: 0 � Items FAILED: 0 |
| CP098 | EXPENSE BREAKDOWN | system | implied | � Hotel: NOT ENTITLED (delay <360 min) | � Meals: ?48.00 ? � Transport: NOT ENTITLED (delay <360 min) � Communication: ?35.00 ? � Parking: NOT ENTITLED (delay <300 min) � Essentials: NOT ENTITLED (dela |
| CP099 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case in Case Services |  |
| CP100 | CASE CREATION (GLOB-09) | system | implied | And the case includes: | � DDS response code: SoC-ASL-EL-03 � Eligibility: ELIGIBLE � Regime: ASL (limited entitlements) � Currency: ILS (receipts in ILS � no conversion needed) � All a |
| CP101 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP102 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully. Here's a summary: � Case Reference: [Case Number] � Total claim amount: ?83.00 ILS � Categories: Meals (?48.00), Com |
| CP103 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP104 | NOTIFICATION | email | email | And an eligible confirmation email is sent to the passenger at t***@gmail.com |  |
| CP105 | CLAIMS PAYMENT FLOW | system | implied | Then the system initiates payment processing |  |
| CP106 | CLAIMS PAYMENT FLOW | system | implied | And Case Services calculates: | � Approved amount: ?83.00 ILS � Currency conversion to country of residence currency (if different from ILS) � Payment method per country of residence |
| CP107 | CLAIMS PAYMENT FLOW | bot | chat | Then the chatbot responds: | To complete your reimbursement, we'll need your payment details. |
| CP108 | CLAIMS PAYMENT FLOW | system | implied | And the chatbot collects: | � Country of residence: [Country] � Payment method: [determined by country] � Payment details: [collected securely] |
| CP109 | CLAIMS PAYMENT FLOW | bot | chat | Then the chatbot responds: | Your payment of [amount in local currency] will be processed via [payment method]. You should receive the funds within [X] business days. |
| CP110 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP111 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP112 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-ASL-EL-03 � ASL Eligible Incomplete Journey Limited Entitlements |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 090 ? AC 091 TLV ? HFA ? VDA with claim filed for segment AC 091 HFA ? VDA |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 1 AC 090 TLV ? HFA is "Operated normally" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 2 AC 091 HFA ? VDA is "CANCELLED (Aircraft defect) � Disrupted segment" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 090 ? AC 091 TLV ? HFA ? VDA |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 091 HFA ? VDA |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Departure Delay Code is "05 (Aircraft Defect) � NOT CHECKED under ASL" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 180 min (3 hours) |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "No Travel � Incomplete Journey (stranded at HFA)" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (TLV ? HFA ? VDA = all Israel)" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED (ASL regime)" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the SOC Segment Cancellation Check is "CANCELLED ?" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the SOC Segment Departure Delay is "?2h (3 hours) ?" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Overnight Eligible is "NO (delay <360 min)" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "J (Business)" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-ASL-EL-03" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Entitlement Limits Applied are LIMITED |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Meals entitlement is ?55 max (lower tier, J cabin � same CCT rate) |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Communication entitlement is ?110 max |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Hotel is NOT ENTITLED (delay <360 min) |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Transport is NOT ENTITLED |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Parking is NOT ENTITLED |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Essentials is NOT ENTITLED |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Meals ?48.00 APPROVED (??55) |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Communication ?35.00 APPROVED (??110) |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is ?83.00 ILS |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 0 |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved" |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP148 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-ASL-EL-03 � ASL Eligible Incomplete Journey Limited Entitlements |  |
| CP149 | PAYMENT VALIDATION | payment | chat | Given the case SoC-ASL-EL-03 is determined as ELIGIBLE |  |
| CP150 | PAYMENT VALIDATION | payment | chat | Then SOC payment is CASH ONLY |  |
| CP151 | PAYMENT VALIDATION | payment | chat | And the route is AC 090 ? AC 091 TLV ? HFA ? VDA (stranded at HFA) with delay 180 min (3 hrs) for 1 adult J class |  |
| CP152 | PAYMENT VALIDATION | payment | chat | And ASL controllability is NOT checked |  |
| CP153 | PAYMENT VALIDATION | payment | chat | And the entitlements are LIMITED for 2�6h delay: Meals ?55 and Comm ?110 only |  |
| CP154 | PAYMENT VALIDATION | payment | chat | And Hotel, Transport, Parking, and Essentials are NOT entitled |  |
| CP155 | PAYMENT VALIDATION | payment | chat | And the approved receipts are Meals ?48 and Comm ?35 totalling ?83.00 ILS |  |
| CP156 | PAYMENT VALIDATION | payment | chat | And the country of residence determines currency and payment method |  |
| CP157 | PAYMENT VALIDATION | payment | chat | And the Comp Status is "Sent for issuance" |  |
| CP158 | PAYMENT VALIDATION | payment | manual | And the batch file is sent to Unifier and EOD report updates only when event occurs |  |
| CP159 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard shows ?83.00 ILS, Cash, payment method, status via talkback |  |
| CP160 | EXPECTED RESULTS | verdict | chat | SoC-ASL-EL-03. | SoC-ASL-EL-03. |
| CP161 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP162 | EXPECTED RESULTS | verdict | chat | No travel (incomplete � stranded at HFA mid-point), SOC segment (AC 091) cancelled, departure delay 180 min (?2h). | No travel (incomplete � stranded at HFA mid-point), SOC segment (AC 091) cancelled, departure delay 180 min (?2h). |
| CP163 | EXPECTED RESULTS | verdict | chat | Controllability NOT checked (ASL). | Controllability NOT checked (ASL). |
| CP164 | EXPECTED RESULTS | verdict | chat | J class, limited entitlements (meals ?55 + comm ?110 only). | J class, limited entitlements (meals ?55 + comm ?110 only). |
| CP165 | EXPECTED RESULTS | verdict | chat | Full receipt + case flow. | Full receipt + case flow. |
