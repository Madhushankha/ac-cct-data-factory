# SOC_UAT_004 · CHAI-31919 — checkpoints

**Goal:** Verify that when the transit delay is below 2 hours, the system returns NOT ELIGIBLE under APPR.

Methods: seed 15, chat 35, api 17, dashboard 36, implied 13, manual 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify that when the transit delay is below 2 hours, the system returns NOT ELIGIBLE under APPR. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 301 YYZ?YOW | � Itinerary: Single segment � AC 301 YYZ?YOW |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 301 YYZ?YOW | � SOC Segment (per SoC Flight Identifier): AC 301 YYZ?YOW |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 301 YYZ?YOW, Dep: 03-Jun 09:00 | � Promised Itinerary: AC 301 YYZ?YOW, Dep: 03-Jun 09:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 301 YYZ?YOW, Dep: 03-Jun 10:30 | � Actual Itinerary: AC 301 YYZ?YOW, Dep: 03-Jun 10:30 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 90 min (1.5 hours) | � Departure Delay: 90 min (1.5 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 64 (Flight Crew Shortage) � Controllable | � Departure delay code: 64 (Flight Crew Shortage) � Controllable |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Controllable (Code 64) | � Controllability: Controllable (Code 64) |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP011 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Regular ? ? 2. Departure delay check ? <2h ? NOT ELIGIBLE | � Check Order: 1. Pax Type ? Regular ? ? 2. Departure delay check ? <2h ? NOT ELIGIBLE |
| CP012 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult | � PAX Count: 1 adult |
| CP013 | PREREQUISITES | prerequisite | seed | � Class of Booking: PY | � Class of Booking: PY |
| CP014 | PREREQUISITES | prerequisite | seed | � Revenue Booking: YES | � Revenue Booking: YES |
| CP015 | PREREQUISITES | prerequisite | seed | � ACR Issued: N/A | � ACR Issued: N/A |
| CP016 | PREREQUISITES | prerequisite | seed | � Journey Completed: > 72h | � Journey Completed: > 72h |
| CP017 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP018 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP019 | START | customer | chat | Then user selects English |  |
| CP020 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP021 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP022 | START | customer | chat | And the user says "My flight was delayed for several hours and I had to buy food at the airport and book a hotel for the night. Can I get re | My flight was delayed for several hours and I had to buy food at the airport and book a hotel for the night. Can I get reimbursed for what I spent? |
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
| CP042 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 301 � Route: Toronto (YYZ) ? Ottawa (YOW) � Date: June 3, 2026 � Departure Delay: 1.5 hours Is this the journey you' |
| CP043 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP045 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR SOC by province of SOC segment departure airport |  |
| CP046 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | SOC Segment Departure Airport: YYZ (Ontario) ? Limitation = 730 days Days elapsed: Within limitation period ? PROCEED |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP051 | 72-HOUR CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment domestic trip YYZ?YOW on AC301 was delayed +1H 30M due to crew (controllable) | Single-segment domestic trip YYZ?YOW on AC301 was delayed +1H 30M due to crew (controllable) |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 301, Route: YYZ ? YOW, Scheduled Dep: 03-Jun 09:00 | Promised Itinerary � Flight: AC 301, Route: YYZ ? YOW, Scheduled Dep: 03-Jun 09:00 |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 301, Route: YYZ ? YOW, Status: ARRIVED LATE, Scheduled Dep: 09:00 ? Actual: 10:30, Delay: +1H 30M | Current Itinerary � Flight: AC 301, Route: YYZ ? YOW, Status: ARRIVED LATE, Scheduled Dep: 09:00 ? Actual: 10:30, Delay: +1H 30M |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [First Name] [Last Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_LESS_THAN_2_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES:  | PASSENGER: [First Name] [Last Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_LESS_THAN_2_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | NOT_ELIGIBLE reason: Delay below 2-hour threshold | NOT_ELIGIBLE reason: Delay below 2-hour threshold |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-APPR-NE-04 | DDS RESPONSE CODE = SoC-APPR-NE-04 |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP067 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I checked your flight details, and it looks like your departure fom Toronto was less than 2h delayed. Based on A | I checked your flight details, and it looks like your departure fom Toronto was less than 2h delayed. Based on APPR, you are not entitled to expense reimburseme |
| CP068 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP069 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-NE-04 � Delay Below 2h Not Eligible |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (Auth Flow 1) |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is NOT greyed out |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 301 YYZ ? YOW as the claimed flight |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 301 YYZ ? YOW |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 301 |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Flight Crew Shortage (Code 64)" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 90 min (1.5 hours) |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travel Completed" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "Controllable (Code 64)" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-NE-04" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Check Order is: 1. Pax Type ? Regular ? ? 2. Delay check ? <2h ? NOT ELIGIBLE |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "N/A" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is not offered (not shown in transcript for NE-04) |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility on Claims Dashboard is "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP109 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-NE-04 � Delay Below 2h Not Eligible |  |
| CP110 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-NE-04 is determined as NOT ELIGIBLE |  |
| CP111 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP112 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP113 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP114 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP115 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP116 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP117 | EXPECTED RESULTS | verdict | chat | SoC-APPR-NE-04. | SoC-APPR-NE-04. |
| CP118 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP119 | EXPECTED RESULTS | verdict | chat | Transit delay 90 min, below 2-hour threshold. | Transit delay 90 min, below 2-hour threshold. |
| CP120 | EXPECTED RESULTS | verdict | chat | No receipt upload. | No receipt upload. |
| CP121 | EXPECTED RESULTS | verdict | chat | No case creation. | No case creation. |
