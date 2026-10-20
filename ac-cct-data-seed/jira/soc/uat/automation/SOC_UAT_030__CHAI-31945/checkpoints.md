# SOC_UAT_030 · CHAI-31945 — checkpoints

**Goal:** Verify NOT ELIGIBLE when itinerary origin is outside EU.

Methods: seed 15, chat 39, api 20, dashboard 33, implied 15, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify NOT ELIGIBLE when itinerary origin is outside EU. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 848 YYZ?LHR | � Itinerary: Single segment � AC 848 YYZ?LHR |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 848 YYZ?LHR | � SOC Segment (per SoC Flight Identifier): AC 848 YYZ?LHR |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 848 YYZ?LHR, Dep: 05-Jun 19:00 | � Promised Itinerary: AC 848 YYZ?LHR, Dep: 05-Jun 19:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 848 YYZ?LHR, Dep: 06-Jun 01:00 | � Actual Itinerary: AC 848 YYZ?LHR, Dep: 06-Jun 01:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 360 min (6 hours) / Delay Category: | � Departure Delay: 360 min (6 hours) / Delay Category: |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 64 (Crew Shortage) � Controllable | � Departure delay code: 64 (Crew Shortage) � Controllable |
| CP009 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP010 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Geographic origin check ? YYZ (Canada) ? NOT in EU ? NOT ELIGIBLE under EU | � Check Order: 1. Geographic origin check ? YYZ (Canada) ? NOT in EU ? NOT ELIGIBLE under EU |
| CP011 | PREREQUISITES | prerequisite | seed | � CRITICAL REGIME DIFFERENCES � GEOGRAPHIC CHECKS: | � CRITICAL REGIME DIFFERENCES � GEOGRAPHIC CHECKS: |
| CP012 | PREREQUISITES | prerequisite | seed | - APPR: NO geographic origin check � applies to all Canadian airline flights | - APPR: NO geographic origin check � applies to all Canadian airline flights |
| CP013 | PREREQUISITES | prerequisite | seed | - EU: Flight must DEPART FROM EU/EEA/UK airport (origin check ONLY) | - EU: Flight must DEPART FROM EU/EEA/UK airport (origin check ONLY) |
| CP014 | PREREQUISITES | prerequisite | seed | - ASL: Flight must involve Israel (to/from TLV, SDV, ETH, EIY) | - ASL: Flight must involve Israel (to/from TLV, SDV, ETH, EIY) |
| CP015 | PREREQUISITES | prerequisite | seed | � NOTE: This itinerary WOULD be eligible under APPR (Canadian departure, AC flight, controllable delay ?2h). System should route to APPR ins | � NOTE: This itinerary WOULD be eligible under APPR (Canadian departure, AC flight, controllable delay ?2h). System should route to APPR instead |
| CP016 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h |
| CP017 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP018 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP019 | START | customer | chat | Then user selects English |  |
| CP020 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP021 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP022 | START | customer | chat | And the user says "My flight from Toronto to London was delayed by about 8 hours. I had to buy food and pay for a hotel overnight at the air | My flight from Toronto to London was delayed by about 8 hours. I had to buy food and pay for a hotel overnight at the airport. Can I get reimbursed? |
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
| CP042 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 848 � Route: Toronto (YYZ) ? London Heathrow (LHR) � Date: June 4, 2026 � Departure Delay: 8 hours Is this the journ |
| CP043 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP047 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP049 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU SOC per departing country |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Departing country: Canada ? Limitation = 730 days (2 years) NOTE: Canada is listed in the EU limitation table under "2 years" category � Days elapsed: Within  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip YYZ?LHR on AC848 was delayed +6H 00M � origin NOT in EU (YYZ = Canada) | Single-segment trip YYZ?LHR on AC848 was delayed +6H 00M � origin NOT in EU (YYZ = Canada) |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: APPR (system determines � EU does not apply to non-EU departures) | Regime: APPR (system determines � EU does not apply to non-EU departures) |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 848, Route: YYZ ? LHR, Scheduled Dep: 05-Jun 19:00 | Promised Itinerary � Flight: AC 848, Route: YYZ ? LHR, Scheduled Dep: 05-Jun 19:00 |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 848, Route: YYZ ? LHR, Status: ARRIVED LATE, Scheduled Dep: 19:00 ? Actual: 06-Jun 01:00, Delay: +6H 00M | Current Itinerary � Flight: AC 848, Route: YYZ ? LHR, Status: ARRIVED LATE, Scheduled Dep: 19:00 ? Actual: 06-Jun 01:00, Delay: +6H 00M |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Geographic Check: Origin = YYZ (Canada) � NOT EU/EEA/UK ? EU regime does NOT apply | Geographic Check: Origin = YYZ (Canada) � NOT EU/EEA/UK ? EU regime does NOT apply |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime applied: APPR (system routes to applicable regime) | Regime applied: APPR (system routes to applicable regime) |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 64 (Crew Shortage) � Controllable | Departure Delay Code: 64 (Crew Shortage) � Controllable |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: ELIGIBLE (under APPR � controllable, ?2h) or NOT_ELIGIBLE (if evaluated under EU only � geographic fail) � depen | PASSENGER: [Name] / STATUS: ELIGIBLE (under APPR � controllable, ?2h) or NOT_ELIGIBLE (if evaluated under EU only � geographic fail) � depends on system routing |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | NOTE: Test validates EU geographic gate specifically. If system correctly routes to APPR, passenger would be ELIGIBLE under APPR. | NOTE: Test validates EU geographic gate specifically. If system correctly routes to APPR, passenger would be ELIGIBLE under APPR. |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: depends on regime routing (ELIGIBLE under APPR / NOT ELIGIBLE under EU) | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: depends on regime routing (ELIGIBLE under APPR / NOT ELIGIBLE under EU) |
| CP069 | GEOGRAPHIC ORIGIN CHECK � THIS IS THE KEY TEST | verdict | api | � EU regime geographic check: | - Origin airport: YYZ (Toronto, Canada) - Origin country: CANADA - Is Canada an EU/EEA member state? ? NO - Is Canada the United Kingdom? ? NO - EU regulation 2 |
| CP070 | CRITICAL REGIME DIFFERENCES � GEOGRAPHIC CHECKS | system | implied | - APPR: NO geographic origin check � applies to all Canadian airline flights | - EU: Flight must DEPART FROM EU/EEA/UK airport (origin check ONLY) - ASL: Flight must DEPART FROM AND ARRIVE IN Israel (BOTH origin + destination) NOTE: Even t |
| CP071 | CRITICAL REGIME DIFFERENCES � GEOGRAPHIC CHECKS | system | implied | Then the chatbot checks which airline company is it ? AC |  |
| CP072 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. Your flight AC 848 departed from Toronto (Canada), which is outside th | I've reviewed the details of your flight. Your flight AC 848 departed from Toronto (Canada), which is outside the European Union. Under EU Regulation 261/2004,  |
| CP073 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP074 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP075 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP076 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP077 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-EU-NE-06 � Geographic Gate Failed Not Eligible |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 848 YYZ ? LHR as the claimed flight |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (8 hours)" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 848 YYZ ? LHR |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 848 |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "N/A (not evaluated � geographic check failed)" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 480 min (8 hours) |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Origin Check is "FAILED" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Origin is "YYZ (Toronto, Canada) � NOT EU/EEA/UK" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Destination is "LHR (London, UK) � EU/UK ? (but origin is what matters for non-EU carriers)" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT EVALUATED (geographic gate failed first)" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-EU-NE-06" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime Note is "May be eligible under APPR instead" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP113 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-EU-NE-06 � Geographic Gate Failed Not Eligible |  |
| CP114 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-NE-06 is determined as NOT ELIGIBLE |  |
| CP115 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP116 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP117 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP118 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP119 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP120 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP121 | EXPECTED RESULTS | verdict | chat | SoC-EU-NE-06. | SoC-EU-NE-06. |
| CP122 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP123 | EXPECTED RESULTS | verdict | chat | Itinerary originated from YYZ (Canada), not from EU. | Itinerary originated from YYZ (Canada), not from EU. |
| CP124 | EXPECTED RESULTS | verdict | chat | EU regime requires EU origin. | EU regime requires EU origin. |
| CP125 | EXPECTED RESULTS | verdict | chat | No receipt upload. | No receipt upload. |
| CP126 | EXPECTED RESULTS | verdict | chat | No case creation. | No case creation. |
