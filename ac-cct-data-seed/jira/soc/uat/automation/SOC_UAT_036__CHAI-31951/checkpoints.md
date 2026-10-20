# SOC_UAT_036 · CHAI-31951 — checkpoints

**Goal:** No travel origin,  not cancelled, EU.

Methods: seed 12, chat 37, api 20, dashboard 32, implied 13, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | No travel origin,  not cancelled, EU. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: EU | � Regime: EU |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 849 LHR?YYZ | � Itinerary: Single segment � AC 849 LHR?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 849 LHR?YYZ | � SOC Segment (per SoC Flight Identifier): AC 849 LHR?YYZ |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 849 LHR?YYZ, Dep: 09-Jun 10:00 | � Promised Itinerary: AC 849 LHR?YYZ, Dep: 09-Jun 10:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: Passenger did not travel. SOC segment flight operated (not cancelled). Passenger chose not to board | � Actual Itinerary: Passenger did not travel. SOC segment flight operated (not cancelled). Passenger chose not to board |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: N/A � no travel, SOC segment not cancelled | � Departure Delay: N/A � no travel, SOC segment not cancelled |
| CP008 | PREREQUISITES | prerequisite | seed | No travel | No travel |
| CP009 | PREREQUISITES | prerequisite | seed | � Departure delay code: N/A � flight operated normally | � Departure delay code: N/A � flight operated normally |
| CP010 | PREREQUISITES | prerequisite | seed | � Controllability: N/A � SOC segment not cancelled; EU does not evaluate controllability for SOC anyway | � Controllability: N/A � SOC segment not cancelled; EU does not evaluate controllability for SOC anyway |
| CP011 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP012 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Regular ? ? 2. No-travel check ? SOC segment not cancelled ? NOT ELIGIBLE | � Check Order: 1. Pax Type ? Regular ? ? 2. No-travel check ? SOC segment not cancelled ? NOT ELIGIBLE |
| CP013 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h |
| CP014 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP015 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP016 | START | customer | chat | Then user selects English |  |
| CP017 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP018 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP019 | START | customer | chat | And the user says "I didn't end up taking my flight from London to Toronto because I heard there were issues. The flight apparently still op | I didn't end up taking my flight from London to Toronto because I heard there were issues. The flight apparently still operated though. I had already arranged a |
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
| CP039 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 849 � Route: London Heathrow (LHR) ? Toronto (YYZ) � Date: June 6, 2026 � Status: OPERATED � Flight departed and arr |
| CP040 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP041 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP042 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP044 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP045 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP046 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU SOC per departing country |  |
| CP047 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Departing country: United Kingdom ? Limitation = 2,190 days (6 years) � Days elapsed: 2 days ? Within limitation period ? PROCEED |
| CP048 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP049 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP050 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP051 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP052 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP053 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Not Completed � Passenger did not board | Trip Not Completed � Passenger did not board |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip LHR?YYZ on AC849 � flight operated as scheduled. Passenger chose not to board. | Single-segment trip LHR?YYZ on AC849 � flight operated as scheduled. Passenger chose not to board. |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: EU (LHR departure) | Regime: EU (LHR departure) |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 849, Route: LHR ? YYZ, Scheduled Dep: 09-Jun 10:00 | Promised Itinerary � Flight: AC 849, Route: LHR ? YYZ, Scheduled Dep: 09-Jun 10:00 |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 849, Route: LHR ? YYZ, Status: OPERATED � On time (passenger did not board) | Current Itinerary � Flight: AC 849, Route: LHR ? YYZ, Status: OPERATED � On time (passenger did not board) |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Flight Status: OPERATED (not cancelled) | Flight Status: OPERATED (not cancelled) |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | No departure delay code (flight operated normally) | No departure delay code (flight operated normally) |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: � / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: � / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | NOT_ELIGIBLE reason: Flight not cancelled � no disruption | NOT_ELIGIBLE reason: Flight not cancelled � no disruption |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-EU-NE-12 | DDS RESPONSE CODE = SoC-EU-NE-12 |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP067 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. Our records show that flight AC 849 from London to Toronto operated as | I've reviewed the details of your flight. Our records show that flight AC 849 from London to Toronto operated as scheduled and was not cancelled. Since the flig |
| CP068 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP069 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP070 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP071 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP072 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-EU-NE-12 � Flight Operated Stayed at Origin Not Eligible |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "EU" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 849 LHR ? YYZ as the claimed flight |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "OPERATED (not cancelled � flight departed and arrived as scheduled)" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 849 LHR ? YYZ |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is "N/A (flight operated normally)" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "N/A (flight operated � no disruption)" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is "N/A (flight operated on schedule)" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Cancellation Check is "NOT CANCELLED � flight operated" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "No Travel � Passenger did not board (voluntary)" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (LHR = UK origin)" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED (EU regime does not evaluate for SOC)" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-EU-NE-12" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And this is the "Stayed at origin" variant of the not-cancelled check with NE-12 (origin), NE-13 (return), NE-14 (incomplete) |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP107 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-EU-NE-12 � Flight Operated Stayed at Origin Not Eligible |  |
| CP108 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-NE-12 is determined as NOT ELIGIBLE |  |
| CP109 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP110 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP111 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP112 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP113 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP114 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP115 | EXPECTED RESULTS | verdict | chat | SoC-EU-NE-12. | SoC-EU-NE-12. |
| CP116 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP117 | EXPECTED RESULTS | verdict | chat | No travel (origin),  flight not cancelled under EU. | No travel (origin),  flight not cancelled under EU. |
| CP118 | EXPECTED RESULTS | verdict | chat | Passenger chose not to travel but flight operated. | Passenger chose not to travel but flight operated. |
