# SOC_UAT_028 · CHAI-31943 — checkpoints

**Goal:** Verify NOT ELIGIBLE when transit delay < 2h under EU.

Methods: seed 10, chat 38, api 16, dashboard 32, implied 15, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify NOT ELIGIBLE when transit delay < 2h under EU. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: EU | � Regime: EU |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 849 LHR?YYZ | � Itinerary: Single segment � AC 849 LHR?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 849 LHR?YYZ | � SOC Segment (per SoC Flight Identifier): AC 849 LHR?YYZ |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 849 LHR?YYZ, Dep: 03-Jun 13:00 | � Promised Itinerary: AC 849 LHR?YYZ, Dep: 03-Jun 13:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 849 LHR?YYZ, Dep: 03-Jun 14:30 | � Actual Itinerary: AC 849 LHR?YYZ, Dep: 03-Jun 14:30 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 90 min (1.5 hours) / Delay Category: <2h | � Departure Delay: 90 min (1.5 hours) / Delay Category: <2h |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 64 (Crew Shortage) � Controllable | � Departure delay code: 64 (Crew Shortage) � Controllable |
| CP009 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP010 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Regular ? ? 2. Departure delay check ? <2h ? NOT ELIGIBLE | � Check Order: 1. Pax Type ? Regular ? ? 2. Departure delay check ? <2h ? NOT ELIGIBLE |
| CP011 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h |
| CP012 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP013 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP014 | START | customer | chat | Then user selects English |  |
| CP015 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP016 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP017 | START | customer | chat | And the user says "My flight from London to Toronto was delayed by about an hour and a half. I had to buy food while waiting. Can I get reim | My flight from London to Toronto was delayed by about an hour and a half. I had to buy food while waiting. Can I get reimbursed? |
| CP018 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP019 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP020 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP030 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP033 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP035 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP036 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP037 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 849 � Route: London Heathrow (LHR) ? Toronto (YYZ) � Date: June 3, 2026 � Departure Delay: 1 hour 30 minutes Is this |
| CP038 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP039 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP040 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP041 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP042 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP043 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP044 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU SOC per departing country |  |
| CP045 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Departing country: United Kingdom ? Limitation = 2,190 days (6 years) � Days elapsed: Within limitation period ? PROCEED |
| CP046 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP047 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP048 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP049 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP050 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP051 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP052 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip LHR?YYZ on AC849 was delayed +1H 30M | Single-segment trip LHR?YYZ on AC849 was delayed +1H 30M |
| CP053 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: EU (LHR departure) | Regime: EU (LHR departure) |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 849, Route: LHR ? YYZ, Scheduled Dep: 03-Jun 13:00 | Promised Itinerary � Flight: AC 849, Route: LHR ? YYZ, Scheduled Dep: 03-Jun 13:00 |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 849, Route: LHR ? YYZ, Status: ARRIVED LATE, Scheduled Dep: 13:00 ? Actual: 14:30, Delay: +1H 30M | Current Itinerary � Flight: AC 849, Route: LHR ? YYZ, Status: ARRIVED LATE, Scheduled Dep: 13:00 ? Actual: 14:30, Delay: +1H 30M |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_LESS_THAN_2_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_LESS_THAN_2_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | NOT_ELIGIBLE reason: Delay below 2-hour threshold | NOT_ELIGIBLE reason: Delay below 2-hour threshold |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE |
| CP061 | TRANSIT DELAY CHECK � THIS IS THE KEY TEST | system | implied | � Transit delay: 90 min (1.5 hours) | � Minimum threshold: 120 min (2 hours) � 90 min < 120 min ? BELOW 2-hour threshold ? NOT ELIGIBLE � This threshold is UNIVERSAL across all three regimes: - APPR |
| CP062 | TRANSIT DELAY CHECK � THIS IS THE KEY TEST | system | implied | Then the chatbot checks which airline company is it ? AC |  |
| CP063 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. Your flight AC 849 from London to Toronto was delayed by 1 hour and 30 | I've reviewed the details of your flight. Your flight AC 849 from London to Toronto was delayed by 1 hour and 30 minutes. Unfortunately, under the applicable EU |
| CP064 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP065 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP066 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP067 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP068 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-EU-NE-04 � Delay Below 2h EU Not Eligible |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "EU" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 849 LHR ? YYZ as the claimed flight |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (1 hour 30 min)" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 849 LHR ? YYZ |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 849 |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "N/A (not evaluated � delay below threshold)" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 90 min (1 hour 30 min) |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Category is "<2h � BELOW minimum threshold" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Transit Delay Threshold is "120 min (2 hours) � NOT MET" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT EVALUATED (delay below threshold)" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-EU-NE-04" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the 2-hour threshold is universal across APPR, EU, and ASL |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP103 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-EU-NE-04 � Delay Below 2h EU Not Eligible |  |
| CP104 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-NE-04 is determined as NOT ELIGIBLE |  |
| CP105 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP106 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP107 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP108 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP109 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP110 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP111 | EXPECTED RESULTS | verdict | chat | SoC-EU-NE-04. | SoC-EU-NE-04. |
| CP112 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP113 | EXPECTED RESULTS | verdict | chat | Transit delay 90 min, below 2-hour threshold. | Transit delay 90 min, below 2-hour threshold. |
| CP114 | EXPECTED RESULTS | verdict | chat | No receipt upload. | No receipt upload. |
| CP115 | EXPECTED RESULTS | verdict | chat | No case creation. | No case creation. |
