# SOC_UAT_027 · CHAI-31942 — checkpoints

**Goal:** Verify NOT ELIGIBLE when customer informed ?14 days before departure under EU.

Methods: seed 15, chat 38, api 17, email 1, dashboard 34, implied 15, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify NOT ELIGIBLE when customer informed ?14 days before departure under EU. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: EU | � Regime: EU |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 871 CDG?YUL | � Itinerary: Single segment � AC 871 CDG?YUL |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 871 CDG?YUL | � SOC Segment (per SoC Flight Identifier): AC 871 CDG?YUL |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 871 CDG?YUL, Dep: 20-Jun 11:00 | � Promised Itinerary: AC 871 CDG?YUL, Dep: 20-Jun 11:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 871 CDG?YUL, Dep: 21-Jun 08:00 | � Actual Itinerary: AC 871 CDG?YUL, Dep: 21-Jun 08:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure delay code: 64 (Flight Crew Shortage) � Classification: Controllable (irrelevant � notification check takes precedence; EU doesn | � Departure delay code: 64 (Flight Crew Shortage) � Classification: Controllable (irrelevant � notification check takes precedence; EU doesn't check controllabi |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay: 1080 min (18 hours) | � Departure delay: 1080 min (18 hours) |
| CP009 | PREREQUISITES | prerequisite | seed | � EU Notification Threshold: ?14 days (NOT 14 days) | � EU Notification Threshold: ?14 days (NOT 14 days) |
| CP010 | PREREQUISITES | prerequisite | seed | � 18 days ? 14 days ? NOT ELIGIBLE | � 18 days ? 14 days ? NOT ELIGIBLE |
| CP011 | PREREQUISITES | prerequisite | seed | � Regime: EU (CDG departure) | � Regime: EU (CDG departure) |
| CP012 | PREREQUISITES | prerequisite | seed | � Filing deadline: France ? 1,825 days (5 years) | � Filing deadline: France ? 1,825 days (5 years) |
| CP013 | PREREQUISITES | prerequisite | seed | � CRITICAL REGIME DIFFERENCE: | � CRITICAL REGIME DIFFERENCE: |
| CP014 | PREREQUISITES | prerequisite | seed | APPR: 12 HOURS notification threshold | APPR: 12 HOURS notification threshold |
| CP015 | PREREQUISITES | prerequisite | seed | EU: 14 DAYS notification threshold | EU: 14 DAYS notification threshold |
| CP016 | PREREQUISITES | prerequisite | seed | ASL: 14 DAYS notification threshold | ASL: 14 DAYS notification threshold |
| CP017 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP018 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP019 | START | customer | chat | Then user selects English |  |
| CP020 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP021 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP022 | START | customer | chat | And the user says "My flight from Paris to Montreal was delayed by about 18 hours. I was notified weeks in advance about the schedule change | My flight from Paris to Montreal was delayed by about 18 hours. I was notified weeks in advance about the schedule change. I still had to buy food and stay at a |
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
| CP042 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 871 � Route: Paris (CDG) ? Montreal (YUL) � Date: June 3, 2026 � Departure Delay: 18 hours Is this the journey you'd |
| CP043 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP047 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP049 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU SOC per departing country |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Departing country: France ? Limitation = 1,825 days (5 years) � Days elapsed: Within limitation period ? PROCEED |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip CDG?YUL on AC871 was delayed +18H 00M � passenger notified 18 days before departure | Single-segment trip CDG?YUL on AC871 was delayed +18H 00M � passenger notified 18 days before departure |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: EU (CDG departure) | Regime: EU (CDG departure) |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 871, Route: CDG ? YUL, Scheduled Dep: 20-Jun 11:00 | Promised Itinerary � Flight: AC 871, Route: CDG ? YUL, Scheduled Dep: 20-Jun 11:00 |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 871, Route: CDG ? YUL, Status: ARRIVED LATE, Scheduled Dep: 11:00 ? Actual Dep: 21-Jun 08:00, Delay: +18H 00M | Current Itinerary � Flight: AC 871, Route: CDG ? YUL, Status: ARRIVED LATE, Scheduled Dep: 11:00 ? Actual Dep: 21-Jun 08:00, Delay: +18H 00M (note: actual is +2 |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Notification: 18 days before departure ? ?14 days threshold ? NOT ELIGIBLE | Notification: 18 days before departure ? ?14 days threshold ? NOT ELIGIBLE |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | NOT_ELIGIBLE reason: Notified ?14 days before departure (EU threshold) | NOT_ELIGIBLE reason: Notified ?14 days before departure (EU threshold) |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE |
| CP067 | NOTIFICATION CHECK � THIS IS THE KEY TEST | email | email | � Passenger type check: | - Passenger type: Regular (not employee, not exception) - Regular ? proceed to notification check � Notification check: - Notification timestamp: 18 days before |
| CP068 | CRITICAL REGIME DIFFERENCE | system | implied | - APPR threshold: 12 HOURS (NE-03 uses 12-hour threshold) | - EU threshold: 14 days (this test uses 15-day threshold) - ASL threshold: 14 days (same as EU) - Under APPR, 18 days advance notice ? would still be NE (exceed |
| CP069 | CRITICAL REGIME DIFFERENCE | system | implied | Then the chatbot checks which airline company is it ? AC |  |
| CP070 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. Our records show that you were notified about the schedule change for  | I've reviewed the details of your flight. Our records show that you were notified about the schedule change for flight AC 871 from Paris to Montreal approximate |
| CP071 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP072 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP073 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP074 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP075 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-EU-NE-03 � Notification ?14 Days EU Not Eligible |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "EU" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Regular" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 871 CDG ? YUL as the claimed flight |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (18 hours)" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 871 CDG ? YUL |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 871 |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "N/A (not evaluated � notification threshold exceeded)" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 1080 min (18 hours) |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Notification Check is "NOTIFIED 18 days before departure ? ?14 days (EU threshold) ? NOT ELIGIBLE" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT EVALUATED (EU doesn't check; also notification already disqualifies)" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-EU-NE-03" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the APPR threshold is 12 HOURS (SoC-APPR-NE-03) |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the EU threshold is 14 days (this test) |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the ASL threshold is 14 days (same as EU) |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP112 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-EU-NE-03 � Notification ?14 Days EU Not Eligible |  |
| CP113 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-NE-03 is determined as NOT ELIGIBLE |  |
| CP114 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP115 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP116 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP117 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP118 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP119 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP120 | EXPECTED RESULTS | verdict | chat | SoC-EU-NE-03. | SoC-EU-NE-03. |
| CP121 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP122 | EXPECTED RESULTS | verdict | chat | Passenger notified ?14 days before departure (EU threshold). | Passenger notified ?14 days before departure (EU threshold). |
| CP123 | EXPECTED RESULTS | verdict | chat | No receipt upload. | No receipt upload. |
| CP124 | EXPECTED RESULTS | verdict | chat | No case creation. | No case creation. |
