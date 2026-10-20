# SOC_UAT_008 · CHAI-31923 — checkpoints

**Goal:** Verify not eligible when customer stayed at origin and  delay < 2 hours.

Methods: seed 15, chat 36, api 18, dashboard 35, implied 13, manual 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify not eligible when customer stayed at origin and  delay < 2 hours. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 111 YYZ?YUL | � Itinerary: Single segment � AC 111 YYZ?YUL |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 111 YYZ?YUL | � SOC Segment (per SoC Flight Identifier): AC 111 YYZ?YUL |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 111 YYZ?YUL, Dep: 07-Jun 09:00 | � Promised Itinerary: AC 111 YYZ?YUL, Dep: 07-Jun 09:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: Flight cancelled. SOC segment departure delay = 90 min (1.5h). Passenger stayed at origin | � Actual Itinerary: Flight cancelled. SOC segment departure delay = 90 min (1.5h). Passenger stayed at origin |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay on SOC Segment: 90 min (1.5 hours) | � Departure Delay on SOC Segment: 90 min (1.5 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 42 (Scheduled Maintenance) � Controllable | � Departure delay code: 42 (Scheduled Maintenance) � Controllable |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Controllable (Code 42) � but IRRELEVANT because delay threshold not met | � Controllability: Controllable (Code 42) � but IRRELEVANT because delay threshold not met |
| CP010 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Regular ? ? 2. No-travel SOC segment departure delay check ? <2h ? NOT ELIGIBLE | � Check Order: 1. Pax Type ? Regular ? ? 2. No-travel SOC segment departure delay check ? <2h ? NOT ELIGIBLE |
| CP011 | PREREQUISITES | prerequisite | seed | � Note: For no-travel scenarios, SOC segment departure delay must be ?2h (120 min) | � Note: For no-travel scenarios, SOC segment departure delay must be ?2h (120 min) |
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
| CP022 | START | customer | chat | And the user says "My flight was cancelled and I was rebooked on a later flight, but the rebooking was only about 2 and a half hours later.  | My flight was cancelled and I was rebooked on a later flight, but the rebooking was only about 2 and a half hours later. I still had to buy food while waiting.  |
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
| CP042 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 111 � Route: Toronto (YYZ) ? Montreal (YUL) � Date: June 7, 2026 � Status: CANCELLED � Rebooked on later flight Dela |
| CP043 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP047 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP049 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR SOC per province |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Origin: YYZ (Ontario) ? Limitation = 730 days � Destination: YUL (Quebec) ? Limitation = 1,095 days � Days elapsed: Within limitation period ? PROCEED |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Not Completed, Disruption Detected | Trip Not Completed, Disruption Detected |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment domestic trip YYZ?YUL on AC111 was cancelled � rebooked with SOC segment departure delay +1H 30M. Passenger stayed at origin  | Single-segment domestic trip YYZ?YUL on AC111 was cancelled � rebooked with SOC segment departure delay +1H 30M. Passenger stayed at origin (YYZ). |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 111, Route: YYZ ? YUL, Scheduled Dep: 07-Jun 09:00 | Promised Itinerary � Flight: AC 111, Route: YYZ ? YUL, Scheduled Dep: 07-Jun 09:00 |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 111, Route: YYZ ? YUL, Status: CANCELLED � Rebooked, SOC Segment Departure Delay: +1H 30M | Current Itinerary � Flight: AC 111, Route: YYZ ? YUL, Status: CANCELLED � Rebooked, SOC Segment Departure Delay: +1H 30M |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC Segment Departure Delay: 90 min (1.5 hours) � below 2h threshold | SOC Segment Departure Delay: 90 min (1.5 hours) � below 2h threshold |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 42 (Scheduled Maintenance) � Controllable (irrelevant � threshold not met) | Departure Delay Code: 42 (Scheduled Maintenance) � Controllable (irrelevant � threshold not met) |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_LESS_THAN_2_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_LESS_THAN_2_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-APPR-NE-14 | DDS RESPONSE CODE = SoC-APPR-NE-14 |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP068 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. Your flight AC 111 from Toronto to Montreal was cancelled and you were | I've reviewed the details of your flight. Your flight AC 111 from Toronto to Montreal was cancelled and you were rebooked on a later flight. However, the total  |
| CP069 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP070 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP071 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP072 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP073 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-NE-14 � No-Travel Below 2h Threshold Not Eligible |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (Auth Flow 1) |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is NOT greyed out |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 111 YYZ ? YUL as the claimed flight |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "CANCELLED � Rebooked on later flight" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 111 YYZ ? YUL |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 111 |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Scheduled Maintenance (Code 42)" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Departure Delay is 90 min (1.5 hours) |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the No-Travel Threshold is 120 min (2 hours) and is NOT MET |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-NE-14" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Check Order is: 1. Pax Type ? Regular ? ? 2. No-travel departure delay check ? <2h ? NOT ELIGIBLE |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Limitation Period Check shows Origin YYZ (Ontario) = 730 days and Destination YUL (Quebec) = 1,095 days |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the limitation check passed (within limitation) |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "N/A" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility on Claims Dashboard is "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP112 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-NE-14 � No-Travel Below 2h Threshold Not Eligible |  |
| CP113 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-NE-14 is determined as NOT ELIGIBLE |  |
| CP114 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP115 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP116 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP117 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP118 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP119 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP120 | EXPECTED RESULTS | verdict | chat | SoC-APPR-NE-14. | SoC-APPR-NE-14. |
| CP121 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP122 | EXPECTED RESULTS | verdict | chat | No travel (origin),  delay 150 min (<2h threshold for no-travel scenarios). | No travel (origin),  delay 150 min (<2h threshold for no-travel scenarios). |
