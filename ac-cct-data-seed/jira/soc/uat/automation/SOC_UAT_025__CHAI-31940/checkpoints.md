# SOC_UAT_025 · CHAI-31940 — checkpoints

**Goal:** Verify NOT ELIGIBLE for AC employee booking under EU regime.

Methods: seed 12, chat 38, api 16, dashboard 36, implied 16, manual 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify NOT ELIGIBLE for AC employee booking under EU regime. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: EU | � Regime: EU |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 849 LHR?YYZ | � Itinerary: Single segment � AC 849 LHR?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 849 LHR?YYZ | � SOC Segment (per SoC Flight Identifier): AC 849 LHR?YYZ |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 849 LHR?YYZ, Dep: 01-Jun 19:00 | � Promised Itinerary: AC 849 LHR?YYZ, Dep: 01-Jun 19:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 849 LHR?YYZ, Dep: 02-Jun 01:00 | � Actual Itinerary: AC 849 LHR?YYZ, Dep: 02-Jun 01:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 360 min (6 hours) | � Departure Delay: 360 min (6 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 41 (Aircraft Defects / Maintenance Finding) � N/A (employee not eligible regardless) | � Departure delay code: 41 (Aircraft Defects / Maintenance Finding) � N/A (employee not eligible regardless) |
| CP009 | PREREQUISITES | prerequisite | seed | � Passenger Type: Employee (AC) � office suffix ES/OT/EP/EE/EC | � Passenger Type: Employee (AC) � office suffix ES/OT/EP/EE/EC |
| CP010 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Employee ? NOT ELIGIBLE (no further checks) | � Check Order: 1. Pax Type ? Employee ? NOT ELIGIBLE (no further checks) |
| CP011 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: NO � Employee / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: NO � Employee / Journey: > 72h |
| CP012 | PREREQUISITES | prerequisite | seed | � Employee Flow: NOT blocked upfront. Goes through OTP first, then receives "Not Eligible." | � Employee Flow: NOT blocked upfront. Goes through OTP first, then receives "Not Eligible." |
| CP013 | PREREQUISITES | prerequisite | seed | � Policy: Not eligible under CCT (decided by Mohammed). Eligible for baggage claims only | � Policy: Not eligible under CCT (decided by Mohammed). Eligible for baggage claims only |
| CP014 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP015 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP016 | START | customer | chat | Then user selects English |  |
| CP017 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP018 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP019 | START | customer | chat | And the user says "My flight from London to Toronto was delayed by about 6 hours and I had to buy food and pay for a hotel overnight. Can I  | My flight from London to Toronto was delayed by about 6 hours and I had to buy food and pay for a hotel overnight. Can I get reimbursed for what I spent? |
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
| CP039 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 849 � Route: London Heathrow (LHR) ? Toronto (YYZ) � Date: June 1, 2026 � Departure Delay: 6 hours Is this the journ |
| CP040 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP041 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP042 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP044 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP045 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP046 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU SOC per departing country |  |
| CP047 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Departing country: United Kingdom ? Limitation = 2,190 days (6 years) � Days elapsed: Within limitation period ? PROCEED |
| CP048 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP049 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP050 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP051 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP052 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: EMPLOYEE (non-revenue) | TYPE: EMPLOYEE (non-revenue) |
| CP053 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip LHR?YYZ on AC849 was delayed +6H 00M | Single-segment trip LHR?YYZ on AC849 was delayed +6H 00M |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: EU (LHR departure) | Regime: EU (LHR departure) |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 849, Route: LHR ? YYZ, Scheduled Dep: 01-Jun 19:00 | Promised Itinerary � Flight: AC 849, Route: LHR ? YYZ, Scheduled Dep: 01-Jun 19:00 |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 849, Route: LHR ? YYZ, Status: ARRIVED LATE, Scheduled Dep: 19:00 ? Actual: 02-Jun 01:00, Delay: +6H 00M | Current Itinerary � Flight: AC 849, Route: LHR ? YYZ, Status: ARRIVED LATE, Scheduled Dep: 19:00 ? Actual: 02-Jun 01:00, Delay: +6H 00M |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | NOT_ELIGIBLE reason: Employee booking (AC) | NOT_ELIGIBLE reason: Employee booking (AC) |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE |
| CP063 | EMPLOYEE CHECK � THIS IS THE KEY TEST | system | implied | � Passenger type check: | - PNR booking type detected: EMPLOYEE (AC) - Office suffix: ES (employee standby) / OT / EP / EE / EC - Employee detected AFTER OTP authentication (not blocked  |
| CP064 | EMPLOYEE CHECK � THIS IS THE KEY TEST | system | implied | Then the chatbot checks which airline company is it ? AC |  |
| CP065 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your booking. Unfortunately, your booking is classified as an employee booking, whi | I've reviewed the details of your booking. Unfortunately, your booking is classified as an employee booking, which does not qualify for Standards of Care expens |
| CP066 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP067 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP068 | NOTE ON DISPUTE PATH | system | implied | If the user had selected "Dispute": | ? Case created with dispute flag ? Case sent to manual handling queue ? Agent reviews employee status and circumstances ? Employee remains not eligible for CCT  |
| CP069 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP070 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP071 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-EU-NE-01 � AC Employee EU Not Eligible |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Employee (AC)" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID is "Employee office suffix (ES/OT/EP/EE/EC)" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "EU" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant", "Adult", and "Employee" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Employee" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 849 LHR ? YYZ as the claimed flight |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (6 hours)" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 849 LHR ? YYZ |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 849 |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "N/A (not evaluated � employee not eligible)" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 360 min (6 hours) |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "EMPLOYEE (AC) � detected after OTP authentication" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "NO � employee booking" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT EVALUATED (employee not eligible regardless; EU doesn't check controllability anyway)" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Employee Flow is "OTP completed ? Employee detected ? Not Eligible" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-EU-NE-01" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Policy is "Not eligible under CCT (Mohammed decision). Eligible for baggage only." |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "N/A" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility on Claims Dashboard is "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP111 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-EU-NE-01 � AC Employee EU Not Eligible |  |
| CP112 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-NE-01 is determined as NOT ELIGIBLE |  |
| CP113 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP114 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP115 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP116 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP117 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP118 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP119 | EXPECTED RESULTS | verdict | chat | System correctly identifies AC employee booking AFTER OTP authentication (not blocked at entry). | System correctly identifies AC employee booking AFTER OTP authentication (not blocked at entry). |
| CP120 | EXPECTED RESULTS | verdict | chat | Returns SoC-EU-NE-01. | Returns SoC-EU-NE-01. |
| CP121 | EXPECTED RESULTS | verdict | chat | Displays NOT ELIGIBLE. | Displays NOT ELIGIBLE. |
| CP122 | EXPECTED RESULTS | verdict | chat | Offers dispute option � if disputed, case created and sent to manual handling. | Offers dispute option � if disputed, case created and sent to manual handling. |
| CP123 | EXPECTED RESULTS | verdict | chat | No receipt upload triggered. | No receipt upload triggered. |
