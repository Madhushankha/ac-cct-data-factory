# SOC_UAT_026 · CHAI-31941 — checkpoints

**Goal:** Verify NOT ELIGIBLE for OAL employee booking under EU.

Methods: seed 10, chat 38, api 16, dashboard 33, implied 16, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify NOT ELIGIBLE for OAL employee booking under EU. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: EU | � Regime: EU |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � LH 470 FRA?YYZ | � Itinerary: Single segment � LH 470 FRA?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): LH 470 FRA?YYZ | � SOC Segment (per SoC Flight Identifier): LH 470 FRA?YYZ |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: LH 470 FRA?YYZ, Dep: 02-Jun 10:00 | � Promised Itinerary: LH 470 FRA?YYZ, Dep: 02-Jun 10:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: LH 470 FRA?YYZ, Dep: 02-Jun 16:00 | � Actual Itinerary: LH 470 FRA?YYZ, Dep: 02-Jun 16:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 420 min (7 hours) | � Departure Delay: 420 min (7 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 64 � N/A (employee not eligible) | � Departure delay code: 64 � N/A (employee not eligible) |
| CP009 | PREREQUISITES | prerequisite | seed | � Passenger Type: Employee (OAL) | � Passenger Type: Employee (OAL) |
| CP010 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Employee ? NOT ELIGIBLE | � Check Order: 1. Pax Type ? Employee ? NOT ELIGIBLE |
| CP011 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: NO / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: NO / Journey: > 72h |
| CP012 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP013 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP014 | START | customer | chat | Then user selects English |  |
| CP015 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP016 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP017 | START | customer | chat | And the user says "My Lufthansa flight from Frankfurt to Toronto was delayed by about 7 hours. I had to buy food and stay overnight at a hot | My Lufthansa flight from Frankfurt to Toronto was delayed by about 7 hours. I had to buy food and stay overnight at a hotel. Can I get reimbursed? |
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
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. Not Eligible |
| CP035 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP036 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP037 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: LH 470 � Route: Frankfurt (FRA) ? Toronto (YYZ) � Date: June 2, 2026 � Departure Delay: 7 hours Is this the journey you |
| CP038 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP039 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP040 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP041 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP042 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP043 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP044 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU SOC per departing country |  |
| CP045 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Departing country: Germany ? Limitation = 1,460 days (4 years) � Days elapsed: Within limitation period ? PROCEED |
| CP046 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP047 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP048 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP049 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP050 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: EMPLOYEE (non-revenue) | TYPE: EMPLOYEE (non-revenue) |
| CP051 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP052 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip FRA?YYZ on LH470 was delayed +7H 00M | Single-segment trip FRA?YYZ on LH470 was delayed +7H 00M |
| CP053 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: EU (FRA departure) | Regime: EU (FRA departure) |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: LH 470, Route: FRA ? YYZ, Scheduled Dep: 02-Jun 10:00 | Promised Itinerary � Flight: LH 470, Route: FRA ? YYZ, Scheduled Dep: 02-Jun 10:00 |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: LH 470, Route: FRA ? YYZ, Status: ARRIVED LATE, Scheduled Dep: 10:00 ? Actual: 16:00, Delay: +7H 00M (note: 6h = | Current Itinerary � Flight: LH 470, Route: FRA ? YYZ, Status: ARRIVED LATE, Scheduled Dep: 10:00 ? Actual: 16:00, Delay: +7H 00M (note: 6h = 360 min per actual  |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | NOT_ELIGIBLE reason: Employee booking (OAL) | NOT_ELIGIBLE reason: Employee booking (OAL) |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE |
| CP061 | EMPLOYEE CHECK | system | implied | � Passenger type check: | - PNR booking type detected: EMPLOYEE (OAL booking) - Employee detected AFTER OTP authentication (not blocked upfront) - Revenue booking check: FAIL � employee  |
| CP062 | EMPLOYEE CHECK | system | implied | Then the chatbot checks which airline company is it ? OAL |  |
| CP063 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your booking. Unfortunately, your booking is classified as an employee booking, whi | I've reviewed the details of your booking. Unfortunately, your booking is classified as an employee booking, which does not qualify for Standards of Care expens |
| CP064 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP065 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP066 | NOTE ON DISPUTE PATH | system | implied | If the user had selected "Dispute": | ? Case created with dispute flag ? Case sent to manual handling queue |
| CP067 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP068 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP069 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-EU-NE-02 � OAL Employee EU Not Eligible |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Employee (OAL)" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID is "Employee (OAL booking)" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "EU" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant", "Adult", and "Employee" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Employee" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey LH 470 FRA ? YYZ as the claimed flight |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (7 hours)" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = LH 470 FRA ? YYZ |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is LH 470 |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is "LH (Lufthansa � OAL)" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "N/A (not evaluated � employee not eligible)" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 420 min (7 hours) |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "EMPLOYEE (OAL booking) � detected after OTP" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "NO � employee booking" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT EVALUATED (employee not eligible regardless)" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-EU-NE-02" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Policy is "Not eligible under CCT. Same policy as NE-01 � universal across AC and OAL." |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP105 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-EU-NE-02 � OAL Employee EU Not Eligible |  |
| CP106 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-NE-02 is determined as NOT ELIGIBLE |  |
| CP107 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP108 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP109 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP110 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP111 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP112 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP113 | EXPECTED RESULTS | verdict | chat | System correctly identifies OAL employee booking AFTER OTP authentication. | System correctly identifies OAL employee booking AFTER OTP authentication. |
| CP114 | EXPECTED RESULTS | verdict | chat | Returns SoC-EU-NE-02. | Returns SoC-EU-NE-02. |
| CP115 | EXPECTED RESULTS | verdict | chat | Displays NOT ELIGIBLE. | Displays NOT ELIGIBLE. |
| CP116 | EXPECTED RESULTS | verdict | chat | Offers dispute option � if disputed, case created and sent to manual handling. | Offers dispute option � if disputed, case created and sent to manual handling. |
| CP117 | EXPECTED RESULTS | verdict | chat | No receipt upload triggered. | No receipt upload triggered. |
