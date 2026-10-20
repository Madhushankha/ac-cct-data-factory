# SOC_UAT_059 · CHAI-31974 — checkpoints

**Goal:** No travel incomplete,  delay < 2h, ASL.

Methods: seed 13, chat 38, api 20, dashboard 33, implied 13, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | No travel incomplete,  delay < 2h, ASL. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: ASL | � Regime: ASL |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Multi-segment | � Itinerary: Multi-segment |
| CP004 | PREREQUISITES | prerequisite | seed | - Segment 1: AC 090 TLV?HFA (operated normally) | - Segment 1: AC 090 TLV?HFA (operated normally) |
| CP005 | PREREQUISITES | prerequisite | seed | - Segment 2: AC 091 HFA?VDA (cancelled, rebooked) | - Segment 2: AC 091 HFA?VDA (cancelled, rebooked) |
| CP006 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 091 HFA?VDA (Segment 2 � cancelled) | � SOC Segment (per SoC Flight Identifier): AC 091 HFA?VDA (Segment 2 � cancelled) |
| CP007 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: Incomplete journey. Stranded at mid-point (HFA). SOC segment departure delay = 170 min (2.82h) | � Actual Itinerary: Incomplete journey. Stranded at mid-point (HFA). SOC segment departure delay = 170 min (2.82h) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure Delay on SOC Segment: 170 min (2 hours 50 min) | � Departure Delay on SOC Segment: 170 min (2 hours 50 min) |
| CP009 | PREREQUISITES | prerequisite | seed | (but <2h for no-travel) | (but <2h for no-travel) |
| CP010 | PREREQUISITES | prerequisite | seed | � Departure delay code: 64 (Flight Crew Shortage) � Controllable (present in flight data but never evaluated � delay threshold fails first;  | � Departure delay code: 64 (Flight Crew Shortage) � Controllable (present in flight data but never evaluated � delay threshold fails first; ASL doesn't check co |
| CP011 | PREREQUISITES | prerequisite | seed | � Controllability: Controllable (Code 64) � NOT CHECKED (ASL does not evaluate controllability for SOC) | � Controllability: Controllable (Code 64) � NOT CHECKED (ASL does not evaluate controllability for SOC) |
| CP012 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP013 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Regular ? ? 2. No-travel SOC segment departure delay check ? <2h ? NOT ELIGIBLE | � Check Order: 1. Pax Type ? Regular ? ? 2. No-travel SOC segment departure delay check ? <2h ? NOT ELIGIBLE |
| CP014 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h |
| CP015 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP016 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP017 | START | customer | chat | Then user selects English |  |
| CP018 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP019 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP020 | START | customer | chat | And the user says "I was on a connecting flight within Israel. My first leg from Tel Aviv to Haifa was fine, but my second leg from Haifa to | I was on a connecting flight within Israel. My first leg from Tel Aviv to Haifa was fine, but my second leg from Haifa to Eilat was cancelled. I was stuck in Ha |
| CP021 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP022 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP023 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP036 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP038 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP039 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP040 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 090 ? AC 091 � Route: Tel Aviv (TLV) ? Haifa (HFA) ? Eilat (VDA) � Date: June 5, 2026 � Segment 1: AC 090 TLV?HFA �  |
| CP041 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? Yes (2 segments) |  |
| CP043 | SEGMENT SELECTION (GenUC-18a) | bot | chat | Then the chatbot displays the segment(s) associated with the selected journey: | Which segment was affected by the disruption? � Segment 1: AC 090 TLV?HFA (Operated normally) � Segment 2: AC 091 HFA?VDA (Cancelled) |
| CP044 | SEGMENT SELECTION (GenUC-18a) | customer | chat | And the user selects "Segment 2: AC 091 HFA?VDA" | Segment 2: AC 091 HFA?VDA |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + segment combination |  |
| CP047 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP049 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for ASL SOC |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � ASL limitation: 1,460 days (4 years) � FIXED � Days elapsed: 4 days ? Within limitation period ? PROCEED |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Not Completed, Disruption Detected | Trip Not Completed, Disruption Detected |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Multi-segment trip TLV?HFA?VDA � Segment 2 AC091 HFA?VDA was cancelled, rebooked with SOC segment departure delay +2H 50M (170 min). Passeng | Multi-segment trip TLV?HFA?VDA � Segment 2 AC091 HFA?VDA was cancelled, rebooked with SOC segment departure delay +2H 50M (170 min). Passenger stranded at HFA. |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: ASL (TLV?HFA?VDA = all Israel) | Regime: ASL (TLV?HFA?VDA = all Israel) |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 2 | PASSENGERS: 1 � SEGMENTS: 2 |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Seg 1: AC 090, TLV ? HFA / Seg 2: AC 091, HFA ? VDA | Promised Itinerary � Seg 1: AC 090, TLV ? HFA / Seg 2: AC 091, HFA ? VDA |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Seg 1: AC 090, TLV ? HFA, Status: ON TIME / Seg 2: AC 091, HFA ? VDA, Status: CANCELLED � Rebooked, SOC Segment Departur | Current Itinerary � Seg 1: AC 090, TLV ? HFA, Status: ON TIME / Seg 2: AC 091, HFA ? VDA, Status: CANCELLED � Rebooked, SOC Segment Departure Delay: +2H 50M |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present � SOC Segment: AC 091 HFA?VDA | SOC section present � SOC Segment: AC 091 HFA?VDA |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC Segment Departure Delay: 170 min (2h 50m) � below 2h threshold (note: prereqs state delay is below threshold despite 170 min > 120 min � | SOC Segment Departure Delay: 170 min (2h 50m) � below 2h threshold (note: prereqs state delay is below threshold despite 170 min > 120 min � validate against ac |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Geographic Check: TLV?HFA?VDA = all Israel ? PASSED ? | Geographic Check: TLV?HFA?VDA = all Israel ? PASSED ? |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 64 (Flight Crew Shortage) � NOT CHECKED (ASL does not evaluate controllability) | Departure Delay Code: 64 (Flight Crew Shortage) � NOT CHECKED (ASL does not evaluate controllability) |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_LESS_THAN_2_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_LESS_THAN_2_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-ASL-NE-11 | DDS RESPONSE CODE = SoC-ASL-NE-11 |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP070 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. Your connecting flight AC 091 from Haifa to Eilat was cancelled and yo | I've reviewed the details of your flight. Your connecting flight AC 091 from Haifa to Eilat was cancelled and you were rebooked on a later flight. However, the  |
| CP071 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP072 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP073 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP074 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP075 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-ASL-NE-11 � Incomplete Journey Below 2h ASL Not Eligible |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "ASL" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 090 ? AC 091 TLV ? HFA ? VDA with claim filed for segment AC 091 HFA ? VDA |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 1 AC 090 TLV ? HFA is "Operated normally" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 2 AC 091 HFA ? VDA is "CANCELLED, rebooked (Disrupted segment)" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 090 ? AC 091 TLV ? HFA ? VDA |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 091 HFA ? VDA |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "N/A (not evaluated � delay below threshold)" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Departure Delay is 170 min (2 hours 50 min) |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the No-Travel Threshold is "120 min (2 hours) � NOT MET" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "No Travel � Incomplete Journey (stranded at HFA, rebooked)" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (TLV ? HFA ? VDA = all Israel)" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED (ASL regime does not evaluate for SOC)" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-ASL-NE-11" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And this is the third variant of no-travel <2h for ASL: NE-09 (origin, 150min), NE-10 (return, 160min), NE-11 (incomplete, 170min) all below |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP111 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-ASL-NE-11 � Incomplete Journey Below 2h ASL Not Eligible |  |
| CP112 | PAYMENT VALIDATION | payment | chat | Given the case SoC-ASL-NE-11 is determined as NOT ELIGIBLE |  |
| CP113 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP114 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP115 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP116 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP117 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP118 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP119 | EXPECTED RESULTS | verdict | chat | SoC-ASL-NE-11. | SoC-ASL-NE-11. |
| CP120 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP121 | EXPECTED RESULTS | verdict | chat | No travel (incomplete),  delay 170 min (<2h threshold under ASL). | No travel (incomplete),  delay 170 min (<2h threshold under ASL). |
