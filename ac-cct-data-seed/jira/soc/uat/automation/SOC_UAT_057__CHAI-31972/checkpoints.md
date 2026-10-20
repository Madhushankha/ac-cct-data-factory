# SOC_UAT_057 · CHAI-31972 — checkpoints

**Goal:** No travel origin,  delay < 2h, ASL.

Methods: seed 17, chat 36, api 20, dashboard 34, implied 13, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | No travel origin,  delay < 2h, ASL. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: ASL | � Regime: ASL |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 084 TLV?VDA | � Itinerary: Single segment � AC 084 TLV?VDA |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 084 TLV?VDA | � SOC Segment (per SoC Flight Identifier): AC 084 TLV?VDA |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 085 TLV?YYZ, Dep: 07-Jun 16:00 | � Promised Itinerary: AC 085 TLV?YYZ, Dep: 07-Jun 16:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: Flight cancelled. SOC segment departure delay = 90 min (1.5 hours). Passenger stayed at origin (TLV) | � Actual Itinerary: Flight cancelled. SOC segment departure delay = 90 min (1.5 hours). Passenger stayed at origin (TLV) |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay on SOC Segment: 90 min (1.5 hours) | � Departure Delay on SOC Segment: 90 min (1.5 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | (but <2h for no-travel) | (but <2h for no-travel) |
| CP009 | PREREQUISITES | prerequisite | seed | � Departure delay code: 64 (Flight Crew Shortage) � Controllable (present in flight data but never evaluated � delay threshold fails first;  | � Departure delay code: 64 (Flight Crew Shortage) � Controllable (present in flight data but never evaluated � delay threshold fails first; ASL doesn't check co |
| CP010 | PREREQUISITES | prerequisite | seed | � Controllability: Controllable (Code 64) � NOT CHECKED (ASL does not evaluate controllability for SOC � same as EU) | � Controllability: Controllable (Code 64) � NOT CHECKED (ASL does not evaluate controllability for SOC � same as EU) |
| CP011 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP012 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Regular ? ? 2. No-travel SOC segment departure delay check ? <2h ? NOT ELIGIBLE | � Check Order: 1. Pax Type ? Regular ? ? 2. No-travel SOC segment departure delay check ? <2h ? NOT ELIGIBLE |
| CP013 | PREREQUISITES | prerequisite | seed | � Note: For no-travel scenarios under ASL, SOC segment departure delay must be ?2h | � Note: For no-travel scenarios under ASL, SOC segment departure delay must be ?2h |
| CP014 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult | � PAX Count: 1 adult |
| CP015 | PREREQUISITES | prerequisite | seed | � Class of Booking: PY | � Class of Booking: PY |
| CP016 | PREREQUISITES | prerequisite | seed | � Revenue Booking: YES | � Revenue Booking: YES |
| CP017 | PREREQUISITES | prerequisite | seed | � ACR Issued: N/A | � ACR Issued: N/A |
| CP018 | PREREQUISITES | prerequisite | seed | � Journey Completed: > 72h | � Journey Completed: > 72h |
| CP019 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP020 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP021 | START | customer | chat | Then user selects English |  |
| CP022 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP023 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP024 | START | customer | chat | And the user says "My flight from Tel Aviv was cancelled and I was rebooked on a flight about 2 and a half hours later. I had to buy food wh | My flight from Tel Aviv was cancelled and I was rebooked on a flight about 2 and a half hours later. I had to buy food while waiting at Ben Gurion airport. Can  |
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
| CP044 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 084 � Route: Tel Aviv (TLV) ? Eilat (VDA) � Date: June 5, 2026 � Status: CANCELLED � Rebooked on later flight �  Del |
| CP045 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for ASL SOC |  |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � ASL limitation: 1,460 days (4 years) � FIXED � Days elapsed: 4 days ? Within limitation period ? PROCEED |
| CP053 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Not Completed, Disruption Detected | Trip Not Completed, Disruption Detected |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip TLV?VDA on AC084 was cancelled � rebooked with SOC segment departure delay +1H 30M (note: prereqs say 90 min but journey | Single-segment trip TLV?VDA on AC084 was cancelled � rebooked with SOC segment departure delay +1H 30M (note: prereqs say 90 min but journey selection says 150  |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: ASL (TLV?VDA = Israel?Israel) | Regime: ASL (TLV?VDA = Israel?Israel) |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 084, Route: TLV ? VDA, Scheduled Dep: 07-Jun 16:00 | Promised Itinerary � Flight: AC 084, Route: TLV ? VDA, Scheduled Dep: 07-Jun 16:00 |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 084, Route: TLV ? VDA, Status: CANCELLED � Rebooked, SOC Segment Departure Delay: +1H 30M | Current Itinerary � Flight: AC 084, Route: TLV ? VDA, Status: CANCELLED � Rebooked, SOC Segment Departure Delay: +1H 30M |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC Segment Departure Delay: 90 min (1.5 hours) � below 2h threshold | SOC Segment Departure Delay: 90 min (1.5 hours) � below 2h threshold |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Geographic Check: TLV?VDA = Israel?Israel ? PASSED ? | Geographic Check: TLV?VDA = Israel?Israel ? PASSED ? |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 64 (Flight Crew Shortage) � NOT CHECKED (ASL does not evaluate controllability; threshold fails first) | Departure Delay Code: 64 (Flight Crew Shortage) � NOT CHECKED (ASL does not evaluate controllability; threshold fails first) |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_LESS_THAN_2_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_LESS_THAN_2_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-ASL-NE-09 | DDS RESPONSE CODE = SoC-ASL-NE-09 |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP072 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. Your flight AC 084 from Tel Aviv to Eilat was cancelled and you were r | I've reviewed the details of your flight. Your flight AC 084 from Tel Aviv to Eilat was cancelled and you were rebooked on a later flight. However, the total de |
| CP073 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP074 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP075 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP076 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP077 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-ASL-NE-09 � No Travel Below 2h ASL Not Eligible |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "ASL" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 084 TLV ? VDA as the claimed flight |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "CANCELLED � Rebooked" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 084 TLV ? VDA |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 084 |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "N/A (not evaluated � delay below threshold)" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Departure Delay is 150 min (2.5 hours) |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the No-Travel Threshold is "120 min (2 hours) � NOT MET" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "No Travel � Stayed at Origin (TLV, rebooked)" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (TLV ? VDA = Israel ? Israel � BOTH Israel)" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED (ASL regime does not evaluate controllability for SOC � same as EU)" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-ASL-NE-09" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the same 2-hour no-travel threshold applies as APPR (NE-14) and EU (NE-09) � universal across all three regimes |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And like EU, ASL does NOT check controllability for SOC meaning ASL has the same simplified NE structure as EU (6 no-travel NE cases vs APPR |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP114 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-ASL-NE-09 � No Travel Below 2h ASL Not Eligible |  |
| CP115 | PAYMENT VALIDATION | payment | chat | Given the case SoC-ASL-NE-09 is determined as NOT ELIGIBLE |  |
| CP116 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP117 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP118 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP119 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP120 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP121 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP122 | EXPECTED RESULTS | verdict | chat | SoC-ASL-NE-09. | SoC-ASL-NE-09. |
| CP123 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP124 | EXPECTED RESULTS | verdict | chat | No travel (origin),  delay 150 min (<2h threshold for no-travel under ASL). | No travel (origin),  delay 150 min (<2h threshold for no-travel under ASL). |
