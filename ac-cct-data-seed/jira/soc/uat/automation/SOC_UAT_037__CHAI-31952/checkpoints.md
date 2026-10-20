# SOC_UAT_037 · CHAI-31952 — checkpoints

**Goal:** No travel return,  not cancelled, EU.

Methods: seed 12, chat 36, api 19, dashboard 32, implied 15, manual 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | No travel return,  not cancelled, EU. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: EU | � Regime: EU |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 871 CDG?YYZ | � Itinerary: Single segment � AC 871 CDG?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 871 CDG?YYZ | � SOC Segment (per SoC Flight Identifier): AC 871 CDG?YYZ |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 871 CDG?YYZ, Dep: 10-Jun 14:00 | � Promised Itinerary: AC 871 CDG?YYZ, Dep: 10-Jun 14:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: Passenger returned to origin. SOC segment flight operated (not cancelled in system � departed and returned) | � Actual Itinerary: Passenger returned to origin. SOC segment flight operated (not cancelled in system � departed and returned) |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: N/A � no travel, SOC segment not cancelled | � Departure Delay: N/A � no travel, SOC segment not cancelled |
| CP008 | PREREQUISITES | prerequisite | seed | No travel | No travel |
| CP009 | PREREQUISITES | prerequisite | seed | � Departure delay code: N/A � flight operated (not recorded as cancelled) | � Departure delay code: N/A � flight operated (not recorded as cancelled) |
| CP010 | PREREQUISITES | prerequisite | seed | � Controllability: N/A � SOC segment not cancelled; EU does not evaluate controllability for SOC anyway | � Controllability: N/A � SOC segment not cancelled; EU does not evaluate controllability for SOC anyway |
| CP011 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP012 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Regular ? ? 2. No-travel check ? SOC segment not cancelled ? NOT ELIGIBLE | � Check Order: 1. Pax Type ? Regular ? ? 2. No-travel check ? SOC segment not cancelled ? NOT ELIGIBLE |
| CP013 | PREREQUISITES | prerequisite | implied | � Note: Although passenger returned to origin, the system records the flight as "operated" (not cancelled). The flight technically departed  | � Note: Although passenger returned to origin, the system records the flight as "operated" (not cancelled). The flight technically departed � it was not a cance |
| CP014 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h |
| CP015 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP016 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP017 | START | customer | chat | Then user selects English |  |
| CP018 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP019 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP020 | START | customer | chat | And the user says "I boarded my flight from Paris to Toronto, but we ended up back at Paris. The airline says the flight wasn't officially c | I boarded my flight from Paris to Toronto, but we ended up back at Paris. The airline says the flight wasn't officially cancelled though � it technically operat |
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
| CP040 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 871 � Route: Paris (CDG) ? Toronto (YYZ) � Date: June 6, 2026 � Status: OPERATED � Flight departed and arrived (pass |
| CP041 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP045 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP046 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP047 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU SOC per departing country |  |
| CP048 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Departing country: France ? Limitation = 1,825 days (5 years) � Days elapsed: 2 days ? Within limitation period ? PROCEED |
| CP049 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP050 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP051 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP052 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP053 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Not Completed � Passenger returned to origin | Trip Not Completed � Passenger returned to origin |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip CDG?YYZ on AC871 � flight operated (departed and returned to CDG). System records as "operated" not "cancelled." | Single-segment trip CDG?YYZ on AC871 � flight operated (departed and returned to CDG). System records as "operated" not "cancelled." |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: EU (CDG departure) | Regime: EU (CDG departure) |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 871, Route: CDG ? YYZ, Scheduled Dep: 10-Jun 14:00 | Promised Itinerary � Flight: AC 871, Route: CDG ? YYZ, Scheduled Dep: 10-Jun 14:00 |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 871, Route: CDG ? YYZ, Status: OPERATED (departed and returned to origin � not recorded as cancelled) | Current Itinerary � Flight: AC 871, Route: CDG ? YYZ, Status: OPERATED (departed and returned to origin � not recorded as cancelled) |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Flight Status: OPERATED (not cancelled in system � departed + returned) | Flight Status: OPERATED (not cancelled in system � departed + returned) |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: � / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: � / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | NOT_ELIGIBLE reason: Flight not recorded as cancelled. Dispute particularly relevant � agent may reclassify as de facto cancellation. | NOT_ELIGIBLE reason: Flight not recorded as cancelled. Dispute particularly relevant � agent may reclassify as de facto cancellation. |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-EU-NE-13 | DDS RESPONSE CODE = SoC-EU-NE-13 |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP067 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. Our records show that flight AC 871 from Paris to Toronto operated and | I've reviewed the details of your flight. Our records show that flight AC 871 from Paris to Toronto operated and was not recorded as cancelled. Since the flight |
| CP068 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP069 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP070 | NOTE ON DISPUTE PATH | system | implied | If the user had selected "Dispute": | ? Case created with dispute flag ? Case sent to manual handling queue ? Agent investigates: * Was the flight diverted back to origin? * Should this be reclassif |
| CP071 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP072 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP073 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-EU-NE-13 � Flight Operated Returned to Origin Not Eligible |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "EU" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 871 CDG ? YYZ as the claimed flight |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "OPERATED (not cancelled � departed and returned to origin)" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 871 CDG ? YYZ |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is "N/A (flight operated � not cancelled in system)" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "N/A (flight not recorded as cancelled)" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is "N/A" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Cancellation Check is "NOT CANCELLED � flight operated (departed + returned)" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "No Travel � Returned to Origin (CDG, not cancelled in system)" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (CDG = France, EU origin)" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED (EU regime does not evaluate for SOC)" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-EU-NE-13" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Dispute Note is "Passenger may dispute � agent should investigate whether diversion back to origin should be reclassified as de fact |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And although passenger returned to origin (same outcome as cancellation from passenger's perspective) the system records flight as "operated |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP109 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-EU-NE-13 � Flight Operated Returned to Origin Not Eligible |  |
| CP110 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-NE-13 is determined as NOT ELIGIBLE |  |
| CP111 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP112 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP113 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP114 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP115 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP116 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP117 | EXPECTED RESULTS | verdict | chat | SoC-EU-NE-13. | SoC-EU-NE-13. |
| CP118 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP119 | EXPECTED RESULTS | verdict | chat | No travel (return),  not cancelled under EU. | No travel (return),  not cancelled under EU. |
