# SOC_UAT_033 · CHAI-31948 — checkpoints

**Goal:** No travel origin,  delay < 2h, EU.

Methods: seed 12, chat 36, api 19, dashboard 32, implied 13, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | No travel origin,  delay < 2h, EU. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: EU | � Regime: EU |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 849 LHR?YYZ | � Itinerary: Single segment � AC 849 LHR?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 849 LHR?YYZ | � SOC Segment (per SoC Flight Identifier): AC 849 LHR?YYZ |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 849 LHR?YYZ, Dep: 07-Jun 09:00 | � Promised Itinerary: AC 849 LHR?YYZ, Dep: 07-Jun 09:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: Flight cancelled. SOC segment departure delay = 90 min (1.5 hours). Passenger stayed at origin (LHR) | � Actual Itinerary: Flight cancelled. SOC segment departure delay = 90 min (1.5 hours). Passenger stayed at origin (LHR) |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure delay code: 64 (Flight Crew Shortage) � Classification: Controllable (irrelevant � EU doesn't check controllability; delay thres | � Departure delay code: 64 (Flight Crew Shortage) � Classification: Controllable (irrelevant � EU doesn't check controllability; delay threshold fails first) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay on SOC segment: 90 min (1.5 hours) | � Departure delay on SOC segment: 90 min (1.5 hours) |
| CP009 | PREREQUISITES | prerequisite | seed | � No-travel threshold: ?2h (120 min) ? 90 min < 120 min ? NOT MET | � No-travel threshold: ?2h (120 min) ? 90 min < 120 min ? NOT MET |
| CP010 | PREREQUISITES | prerequisite | seed | � Travel status: No Travel � Stayed at Origin (LHR) | � Travel status: No Travel � Stayed at Origin (LHR) |
| CP011 | PREREQUISITES | prerequisite | seed | � Regime: EU (LHR departure) | � Regime: EU (LHR departure) |
| CP012 | PREREQUISITES | prerequisite | seed | � Filing deadline: UK ? 2,190 days (6 years) | � Filing deadline: UK ? 2,190 days (6 years) |
| CP013 | PREREQUISITES | prerequisite | seed | � Geographic check: LHR = UK ? PASSED ? | � Geographic check: LHR = UK ? PASSED ? |
| CP014 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP015 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP016 | START | customer | chat | Then user selects English |  |
| CP017 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP018 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP019 | START | customer | chat | And the user says "My flight from London to Toronto was cancelled and I was rebooked on a flight about 2 and a half hours later. I had to bu | My flight from London to Toronto was cancelled and I was rebooked on a flight about 2 and a half hours later. I had to buy food while waiting at Heathrow. Can I |
| CP020 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP021 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP022 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP035 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP037 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP038 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP039 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 849 � Route: London Heathrow (LHR) ? Toronto (YYZ) � Date: June 5, 2026 � Status: CANCELLED � Rebooked on later flig |
| CP040 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP041 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP042 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP044 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP045 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP046 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU SOC per departing country |  |
| CP047 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Departing country: United Kingdom ? Limitation = 2,190 days (6 years) � Days elapsed: 3 days ? Within limitation period ? PROCEED |
| CP048 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP049 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP050 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP051 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP052 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP053 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Not Completed, Disruption Detected | Trip Not Completed, Disruption Detected |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip LHR?YYZ on AC849 was cancelled � rebooked with SOC segment departure delay +1H 30M. Passenger stayed at origin (LHR). | Single-segment trip LHR?YYZ on AC849 was cancelled � rebooked with SOC segment departure delay +1H 30M. Passenger stayed at origin (LHR). |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: EU (LHR departure) | Regime: EU (LHR departure) |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 849, Route: LHR ? YYZ, Scheduled Dep: 07-Jun 09:00 | Promised Itinerary � Flight: AC 849, Route: LHR ? YYZ, Scheduled Dep: 07-Jun 09:00 |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 849, Route: LHR ? YYZ, Status: CANCELLED � Rebooked, SOC Segment Departure Delay: +1H 30M | Current Itinerary � Flight: AC 849, Route: LHR ? YYZ, Status: CANCELLED � Rebooked, SOC Segment Departure Delay: +1H 30M |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC Segment Departure Delay: 90 min (1.5 hours) � below 2h threshold | SOC Segment Departure Delay: 90 min (1.5 hours) � below 2h threshold |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 64 (Flight Crew Shortage) � Controllable (NOT CHECKED � EU doesn't evaluate; threshold fails first) | Departure Delay Code: 64 (Flight Crew Shortage) � Controllable (NOT CHECKED � EU doesn't evaluate; threshold fails first) |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_LESS_THAN_2_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_LESS_THAN_2_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-EU-NE-09 | DDS RESPONSE CODE = SoC-EU-NE-09 |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP066 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. Your flight AC 849 from London to Toronto was cancelled and you were r | I've reviewed the details of your flight. Your flight AC 849 from London to Toronto was cancelled and you were rebooked on a later flight. However, the total de |
| CP067 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP068 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP069 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP070 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP071 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-EU-NE-09 � No Travel Stayed at Origin Below 2h Not Eligible |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "EU" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 849 LHR ? YYZ as the claimed flight |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "CANCELLED � Rebooked" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 849 LHR ? YYZ |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 849 |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "N/A (not evaluated � delay below threshold)" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Departure Delay is 150 min (2.5 hours) |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the No-Travel Threshold is "120 min (2 hours) � NOT MET" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "No Travel � Stayed at Origin (LHR, rebooked)" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (LHR = UK origin)" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED (EU regime does not evaluate controllability for SOC)" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-EU-NE-09" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And there are two different thresholds: Transit (?2h) vs No-Travel (?2h) and this passenger did NOT travel so the 2-hour threshold applies |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And 2.5h exceeds transit threshold but NOT no-travel threshold |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP106 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-EU-NE-09 � No Travel Stayed at Origin Below 2h Not Eligible |  |
| CP107 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-NE-09 is determined as NOT ELIGIBLE |  |
| CP108 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP109 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP110 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP111 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP112 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP113 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP114 | EXPECTED RESULTS | verdict | chat | SoC-EU-NE-09. | SoC-EU-NE-09. |
| CP115 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP116 | EXPECTED RESULTS | verdict | chat | No travel (origin),  delay 150 min (<2h threshold for no-travel under EU). | No travel (origin),  delay 150 min (<2h threshold for no-travel under EU). |
