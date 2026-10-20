# SOC_UAT_009 · CHAI-31924 — checkpoints

**Goal:** Verify not eligible when customer at mid-point, didn't reach destination,  delay < 2h.

Methods: seed 19, chat 38, api 18, dashboard 42, implied 13, manual 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify not eligible when customer at mid-point, didn't reach destination,  delay < 2h. |  |
| CP002 | PREREQUISITES | prerequisite | seed | Regime: APPR | Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: Multi-segment | Itinerary: Multi-segment |
| CP004 | PREREQUISITES | prerequisite | seed | Segment 1: AC 131 YYZ?YYC, Dep: 07-Jun 07:00 (operated normally) | Segment 1: AC 131 YYZ?YYC, Dep: 07-Jun 07:00 (operated normally) |
| CP005 | PREREQUISITES | prerequisite | seed | Segment 2: AC 132 YYC?YVR, Dep: 07-Jun 12:00 (cancelled, rebooked) | Segment 2: AC 132 YYC?YVR, Dep: 07-Jun 12:00 (cancelled, rebooked) |
| CP006 | PREREQUISITES | prerequisite | seed | SOC Segment (per SoC Flight Identifier): AC 132 YYC?YVR (Segment 2 � the cancelled segment) | SOC Segment (per SoC Flight Identifier): AC 132 YYC?YVR (Segment 2 � the cancelled segment) |
| CP007 | PREREQUISITES | prerequisite | seed | Promised Itinerary: | Promised Itinerary: |
| CP008 | PREREQUISITES | prerequisite | seed | Seg 1: AC 131 YYZ?YYC, Dep: 07-Jun 07:00 | Seg 1: AC 131 YYZ?YYC, Dep: 07-Jun 07:00 |
| CP009 | PREREQUISITES | prerequisite | seed | Seg 2: AC 132 YYC?YVR, Dep: 07-Jun 12:00 | Seg 2: AC 132 YYC?YVR, Dep: 07-Jun 12:00 |
| CP010 | PREREQUISITES | prerequisite | seed | Actual Itinerary: Incomplete journey. Stranded at mid-point (YYC). SOC segment departure delay = 90 min (1.5h) | Actual Itinerary: Incomplete journey. Stranded at mid-point (YYC). SOC segment departure delay = 90 min (1.5h) |
| CP011 | PREREQUISITES | prerequisite | seed | Departure Delay on SOC Segment: 90 min (1 hour 30 min) | Departure Delay on SOC Segment: 90 min (1 hour 30 min) |
| CP012 | PREREQUISITES | prerequisite | seed | Departure delay code: 42 (Scheduled Maintenance) � Controllable | Departure delay code: 42 (Scheduled Maintenance) � Controllable |
| CP013 | PREREQUISITES | prerequisite | seed | Controllability: Controllable (Code 42) � but IRRELEVANT because delay threshold not met | Controllability: Controllable (Code 42) � but IRRELEVANT because delay threshold not met |
| CP014 | PREREQUISITES | prerequisite | seed | Passenger Type: Regular | Passenger Type: Regular |
| CP015 | PREREQUISITES | prerequisite | seed | Check Order: 1. Pax Type ? Regular ? ? 2. No-travel SOC segment departure delay check ? <2h ? NOT ELIGIBLE | Check Order: 1. Pax Type ? Regular ? ? 2. No-travel SOC segment departure delay check ? <2h ? NOT ELIGIBLE |
| CP016 | PREREQUISITES | prerequisite | seed | PAX Count: 1 adult | PAX Count: 1 adult |
| CP017 | PREREQUISITES | prerequisite | seed | Class of Booking: PY | Class of Booking: PY |
| CP018 | PREREQUISITES | prerequisite | seed | Revenue Booking: YES | Revenue Booking: YES |
| CP019 | PREREQUISITES | prerequisite | seed | ACR Issued: N/A | ACR Issued: N/A |
| CP020 | PREREQUISITES | prerequisite | seed | Journey Completed: > 72h | Journey Completed: > 72h |
| CP021 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP022 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP023 | START | customer | chat | Then user selects English |  |
| CP024 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP025 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP026 | START | customer | chat | And the user says "I was on a connecting flight. My first leg went fine but my second leg got cancelled. I was stuck at Calgary for about an | I was on a connecting flight. My first leg went fine but my second leg got cancelled. I was stuck at Calgary for about an hour and a half before they rebooked m |
| CP027 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP028 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP029 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP031 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP032 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP033 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP034 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP035 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP036 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: t***@gmail.com Phone: +1***789 |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP041 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP042 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP043 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP044 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP045 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP046 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 131 ? AC 132 Route: Toronto (YYZ) ? Calgary (YYC) ? Vancouver (YVR) Date: June 7, 2026 Segment 1: AC 131 YYZ?YYC � Ope |
| CP047 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? Yes (2 segments) |  |
| CP049 | SEGMENT SELECTION (GenUC-18a) | bot | chat | Then the chatbot displays the segment(s) associated with the selected journey: | Which segment was affected by the disruption? Segment 1: AC 131 YYZ?YYC (Operated) Segment 2: AC 132 YYC?YVR (Cancelled) |
| CP050 | SEGMENT SELECTION (GenUC-18a) | customer | chat | And the user selects "Segment 2: AC 132 YYC?YVR" | Segment 2: AC 132 YYC?YVR |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP052 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + segment combination |  |
| CP053 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP054 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP055 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR SOC per province |  |
| CP056 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | SOC Segment Departure Airport: YYC (Alberta) ? Limitation = 730 days Days elapsed: Within limitation period ? PROCEED |
| CP057 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Not Completed, Disruption Detected | Trip Not Completed, Disruption Detected |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Multi-segment domestic trip YYZ?YYC?YVR � Segment 2 AC132 YYC?YVR was cancelled, rebooked with SOC segment departure delay +1H 30M. Passenge | Multi-segment domestic trip YYZ?YYC?YVR � Segment 2 AC132 YYC?YVR was cancelled, rebooked with SOC segment departure delay +1H 30M. Passenger stranded at YYC. |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 2 | PASSENGERS: 1 � SEGMENTS: 2 |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Seg 1: AC 131, YYZ ? YYC, Dep: 07-Jun 07:00 / Seg 2: AC 132, YYC ? YVR, Dep: 07-Jun 12:00 | Promised Itinerary � Seg 1: AC 131, YYZ ? YYC, Dep: 07-Jun 07:00 / Seg 2: AC 132, YYC ? YVR, Dep: 07-Jun 12:00 |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Seg 1: AC 131, YYZ ? YYC, Status: ON TIME / Seg 2: AC 132, YYC ? YVR, Status: CANCELLED � Rebooked, SOC Segment Departur | Current Itinerary � Seg 1: AC 131, YYZ ? YYC, Status: ON TIME / Seg 2: AC 132, YYC ? YVR, Status: CANCELLED � Rebooked, SOC Segment Departure Delay: +1H 30M |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present � SOC Segment: AC 132 YYC?YVR | SOC section present � SOC Segment: AC 132 YYC?YVR |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC Segment Departure Delay: 90 min (1.5 hours) � below 2h threshold | SOC Segment Departure Delay: 90 min (1.5 hours) � below 2h threshold |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 42 (Scheduled Maintenance) � Controllable (irrelevant � threshold not met) | Departure Delay Code: 42 (Scheduled Maintenance) � Controllable (irrelevant � threshold not met) |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_LESS_THAN_2_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_LESS_THAN_2_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-APPR-NE-16 | DDS RESPONSE CODE = SoC-APPR-NE-16 |
| CP073 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP074 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. Your connecting flight AC 132 from Calgary to Vancouver was cancelled  | I've reviewed the details of your flight. Your connecting flight AC 132 from Calgary to Vancouver was cancelled and you were rebooked on a later flight. However |
| CP075 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP076 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP077 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP078 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP079 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-NE-16 � Incomplete Journey Below 2h Not Eligible |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (Auth Flow 1) |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is NOT greyed out |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 131 YYZ ? YYC ? YVR with claim filed for segment AC 132 YYC ? YVR |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 1 AC 131 YYZ ? YYC is "Operated" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 2 AC 132 YYC ? YVR is "CANCELLED, rebooked (Disrupted segment)" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 131 ? AC 132 YYZ ? YYC ? YVR |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 132 YYC ? YVR |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Scheduled Maintenance (Code 42)" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Departure Delay is 90 min (1.5 hours) |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the No-Travel Threshold is 120 min (2 hours) and is NOT MET |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "No Travel � Incomplete (stranded at YYC, rebooked)" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "Controllable (Code 42)" but IRRELEVANT because delay threshold not met |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-NE-16" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Check Order is: 1. Pax Type ? Regular ? ? 2. No-travel departure delay check ? <2h ? NOT ELIGIBLE |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Limitation Period Check shows SOC Segment Departure YYC (Alberta) = 730 days |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the limitation check passed (within limitation) |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "N/A" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility on Claims Dashboard is "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP125 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-NE-16 � Incomplete Journey Below 2h Not Eligible |  |
| CP126 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-NE-16 is determined as NOT ELIGIBLE |  |
| CP127 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP128 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP130 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP131 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP133 | EXPECTED RESULTS | verdict | chat | SoC-APPR-NE-16. | SoC-APPR-NE-16. |
| CP134 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP135 | EXPECTED RESULTS | verdict | chat | No travel (incomplete),  delay 90 min (<2h threshold). | No travel (incomplete),  delay 90 min (<2h threshold). |
