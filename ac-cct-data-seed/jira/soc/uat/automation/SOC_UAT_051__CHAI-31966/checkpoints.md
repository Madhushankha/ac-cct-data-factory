# SOC_UAT_051 · CHAI-31966 — checkpoints

**Goal:** Verify NOT ELIGIBLE when customer informed ?14 days before departure under ASL.

Methods: seed 17, chat 38, api 19, dashboard 32, implied 13, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify NOT ELIGIBLE when customer informed ?14 days before departure under ASL. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: ASL | � Regime: ASL |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 084 TLV?YYZ | � Itinerary: Single segment � AC 084 TLV?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 084 TLV?YYZ | � SOC Segment (per SoC Flight Identifier): AC 084 TLV?YYZ |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 084  TLV?YYZ, Dep: 20-Jun 16:00 | � Promised Itinerary: AC 084  TLV?YYZ, Dep: 20-Jun 16:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 084  TLV?YYZ, Dep: 21-Jun 10:00 | � Actual Itinerary: AC 084  TLV?YYZ, Dep: 21-Jun 10:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 1080 min (18 hours) | � Departure Delay: 1080 min (18 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 64 (Flight Crew Shortage) � Controllable (present in flight data but never evaluated � notification check disqualifi | � Departure delay code: 64 (Flight Crew Shortage) � Controllable (present in flight data but never evaluated � notification check disqualifies first; ASL doesn' |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Controllable (Code 64) � NOT EVALUATED (notification already disqualifies) | � Controllability: Controllable (Code 64) � NOT EVALUATED (notification already disqualifies) |
| CP010 | PREREQUISITES | prerequisite | seed | � Notification Time: 20 days before scheduled departure | � Notification Time: 20 days before scheduled departure |
| CP011 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP012 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Regular ? ? 2. Notification check ? ?14 days ? NOT ELIGIBLE | � Check Order: 1. Pax Type ? Regular ? ? 2. Notification check ? ?14 days ? NOT ELIGIBLE |
| CP013 | PREREQUISITES | prerequisite | seed | � Note: ASL uses 14-day advance notification threshold (same as EU, different from APPR 12-hour) | � Note: ASL uses 14-day advance notification threshold (same as EU, different from APPR 12-hour) |
| CP014 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult | � PAX Count: 1 adult |
| CP015 | PREREQUISITES | prerequisite | seed | � Class of Booking: PY | � Class of Booking: PY |
| CP016 | PREREQUISITES | prerequisite | seed | � Revenue Booking: YES | � Revenue Booking: YES |
| CP017 | PREREQUISITES | prerequisite | seed | � ACR Issued: N/A | � ACR Issued: N/A |
| CP018 | PREREQUISITES | prerequisite | seed | � Journey Completed: > 72h | � Journey Completed: > 72h |
| CP019 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP020 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP021 | START | customer | chat | Then user selects English |  |
| CP022 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP023 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP024 | START | customer | chat | And the user says "My flight from Tel Aviv to Toronto was delayed by about 18 hours. I was notified weeks in advance about the schedule chan | My flight from Tel Aviv to Toronto was delayed by about 18 hours. I was notified weeks in advance about the schedule change. I still had to buy food and stay at |
| CP025 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP026 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP027 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP031 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP032 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP042 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP043 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP044 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 084 � Route: Tel Aviv (TLV) ? Toronto (YYZ) � Date: June 3, 2026 � Departure Delay: 18 hours Is this the journey you |
| CP045 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for ASL SOC |  |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � ASL limitation: 1,460 days (4 years) � FIXED for all origins � Days elapsed: 6 days ? Within limitation period ? PROCEED |
| CP053 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip TLV?YYZ on AC084 was delayed +18H 00M � passenger notified 20 days before departure | Single-segment trip TLV?YYZ on AC084 was delayed +18H 00M � passenger notified 20 days before departure |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: ASL (TLV departure � Israel) | Regime: ASL (TLV departure � Israel) |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 084, Route: TLV ? YYZ, Scheduled Dep: 20-Jun 16:00 | Promised Itinerary � Flight: AC 084, Route: TLV ? YYZ, Scheduled Dep: 20-Jun 16:00 |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 084, Route: TLV ? YYZ, Status: ARRIVED LATE, Scheduled Dep: 16:00 ? Actual Dep: 21-Jun 10:00, Delay: +18H 00M | Current Itinerary � Flight: AC 084, Route: TLV ? YYZ, Status: ARRIVED LATE, Scheduled Dep: 16:00 ? Actual Dep: 21-Jun 10:00, Delay: +18H 00M |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Notification: 20 days before departure ? ?14 days threshold (ASL, same as EU) ? NOT ELIGIBLE | Notification: 20 days before departure ? ?14 days threshold (ASL, same as EU) ? NOT ELIGIBLE |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | NOT_ELIGIBLE reason: Notified ?14 days before departure (ASL threshold) | NOT_ELIGIBLE reason: Notified ?14 days before departure (ASL threshold) |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-ASL-NE-03 | DDS RESPONSE CODE = SoC-ASL-NE-03 |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP071 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. Our records show that you were notified about the schedule change for  | I've reviewed the details of your flight. Our records show that you were notified about the schedule change for flight AC 084 from Tel Aviv to Toronto approxima |
| CP072 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP073 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP074 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP075 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP076 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-ASL-NE-03 � Notification ?14 Days ASL Not Eligible |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "ASL" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 084 TLV ? YYZ as the claimed flight |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (18 hours)" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 084 TLV ? YYZ |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 084 |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "N/A (not evaluated � notification threshold exceeded)" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 1080 min (18 hours) |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Notification Check is "NOTIFIED 20 days before departure ? ?14 days (ASL threshold) ? NOT ELIGIBLE" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT EVALUATED (notification already disqualifies; ASL doesn't check controllability anyway)" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "NOT EVALUATED (notification already disqualifies)" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-ASL-NE-03" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the APPR threshold is 12 HOURS, EU threshold is 14 days, and ASL threshold is 14 days (same as EU) |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP111 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-ASL-NE-03 � Notification ?14 Days ASL Not Eligible |  |
| CP112 | PAYMENT VALIDATION | payment | chat | Given the case SoC-ASL-NE-03 is determined as NOT ELIGIBLE |  |
| CP113 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP114 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP115 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP116 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP117 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP118 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP119 | EXPECTED RESULTS | verdict | chat | SoC-ASL-NE-03. | SoC-ASL-NE-03. |
| CP120 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP121 | EXPECTED RESULTS | verdict | chat | Passenger notified ?14 days before departure (ASL threshold). | Passenger notified ?14 days before departure (ASL threshold). |
| CP122 | EXPECTED RESULTS | verdict | chat | No receipt upload. | No receipt upload. |
| CP123 | EXPECTED RESULTS | verdict | chat | No case creation. | No case creation. |
