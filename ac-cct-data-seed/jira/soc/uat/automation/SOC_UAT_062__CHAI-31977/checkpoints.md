# SOC_UAT_062 · CHAI-31977 — checkpoints

**Goal:** No travel incomplete,  not cancelled, ASL.

Methods: seed 13, chat 38, api 19, dashboard 33, implied 14, manual 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | No travel incomplete,  not cancelled, ASL. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: ASL | � Regime: ASL |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Multi-segment | � Itinerary: Multi-segment |
| CP004 | PREREQUISITES | prerequisite | seed | - Segment 1: AC 090 TLV?HFA (operated normally) | - Segment 1: AC 090 TLV?HFA (operated normally) |
| CP005 | PREREQUISITES | prerequisite | seed | - Segment 2: AC 091 HFA?VDA (operated � passenger did not board) | - Segment 2: AC 091 HFA?VDA (operated � passenger did not board) |
| CP006 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 091 HFA?VDA (Segment 2 � operated, passenger missed/couldn't board) | � SOC Segment (per SoC Flight Identifier): AC 091 HFA?VDA (Segment 2 � operated, passenger missed/couldn't board) |
| CP007 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: Incomplete journey. Stranded at mid-point (HFA). SOC segment flight operated (not cancelled) | � Actual Itinerary: Incomplete journey. Stranded at mid-point (HFA). SOC segment flight operated (not cancelled) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure Delay: N/A � no travel on SOC segment, flight not cancelled | � Departure Delay: N/A � no travel on SOC segment, flight not cancelled |
| CP009 | PREREQUISITES | prerequisite | seed | No travel | No travel |
| CP010 | PREREQUISITES | prerequisite | seed | � Departure delay code: N/A � flight operated normally | � Departure delay code: N/A � flight operated normally |
| CP011 | PREREQUISITES | prerequisite | seed | � Controllability: N/A � SOC segment not cancelled; ASL does not evaluate controllability for SOC anyway | � Controllability: N/A � SOC segment not cancelled; ASL does not evaluate controllability for SOC anyway |
| CP012 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP013 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Regular ? ? 2. No-travel check ? SOC segment not cancelled ? NOT ELIGIBLE | � Check Order: 1. Pax Type ? Regular ? ? 2. No-travel check ? SOC segment not cancelled ? NOT ELIGIBLE |
| CP014 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h |
| CP015 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP016 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP017 | START | customer | chat | Then user selects English |  |
| CP018 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP019 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP020 | START | customer | chat | And the user says "I was on a connecting flight within Israel from Tel Aviv through Haifa to Eilat. My first leg was fine, but I got stuck i | I was on a connecting flight within Israel from Tel Aviv through Haifa to Eilat. My first leg was fine, but I got stuck in Haifa. The airline says my connecting |
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
| CP040 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 090 ? AC 091 � Route: Tel Aviv (TLV) ? Haifa (HFA) ? Eilat (VDA) � Date: June 6, 2026 � Segment 1: AC 090 TLV?HFA �  |
| CP041 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? Yes (2 segments) |  |
| CP043 | SEGMENT SELECTION (GenUC-18a) | bot | chat | Then the chatbot displays the segment(s) associated with the selected journey: | Which segment was affected by the disruption? � Segment 1: AC 090 TLV?HFA (Operated normally) � Segment 2: AC 091 HFA?VDA (Operated � passenger did not board) |
| CP044 | SEGMENT SELECTION (GenUC-18a) | customer | chat | And the user selects "Segment 2: AC 091 HFA?VDA" | Segment 2: AC 091 HFA?VDA |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + segment combination |  |
| CP047 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP049 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for ASL SOC |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � ASL limitation: 1,460 days (4 years) � FIXED � Days elapsed: 3 days ? Within limitation period ? PROCEED |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Not Completed � Passenger stranded at connection | Trip Not Completed � Passenger stranded at connection |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Multi-segment trip TLV?HFA?VDA � Segment 2 AC091 HFA?VDA operated (passenger did not board � missed connection). Passenger stranded at HFA. | Multi-segment trip TLV?HFA?VDA � Segment 2 AC091 HFA?VDA operated (passenger did not board � missed connection). Passenger stranded at HFA. |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: ASL (TLV?HFA?VDA = all Israel) | Regime: ASL (TLV?HFA?VDA = all Israel) |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 2 | PASSENGERS: 1 � SEGMENTS: 2 |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Seg 1: AC 090, TLV ? HFA / Seg 2: AC 091, HFA ? VDA | Promised Itinerary � Seg 1: AC 090, TLV ? HFA / Seg 2: AC 091, HFA ? VDA |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Seg 1: AC 090, TLV ? HFA, Status: ON TIME / Seg 2: AC 091, HFA ? VDA, Status: OPERATED (passenger did not board) | Current Itinerary � Seg 1: AC 090, TLV ? HFA, Status: ON TIME / Seg 2: AC 091, HFA ? VDA, Status: OPERATED (passenger did not board) |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present � SOC Segment: AC 091 HFA?VDA | SOC section present � SOC Segment: AC 091 HFA?VDA |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Flight Status: OPERATED (not cancelled � departed without passenger) | Flight Status: OPERATED (not cancelled � departed without passenger) |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Geographic Check: TLV?HFA?VDA = all Israel ? PASSED ? | Geographic Check: TLV?HFA?VDA = all Israel ? PASSED ? |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: � / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: � / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | NOT_ELIGIBLE reason: Connecting flight operated � not cancelled. Dispute relevant if missed connection was caused by airline delay on first  | NOT_ELIGIBLE reason: Connecting flight operated � not cancelled. Dispute relevant if missed connection was caused by airline delay on first leg. |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLEDDS RESPONSE CODE = SoC-ASL-NE-14 | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLEDDS RESPONSE CODE = SoC-ASL-NE-14 |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP069 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. Our records show that your connecting flight AC 091 from Haifa to Eila | I've reviewed the details of your flight. Our records show that your connecting flight AC 091 from Haifa to Eilat operated and was not cancelled. Since the conn |
| CP070 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP071 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP072 | NOTE ON DISPUTE PATH | system | implied | If the user had selected "Dispute": | ? Case created with dispute flag ? Case sent to manual handling queue ? Agent investigates: * Was first leg delayed, causing missed connection? * Was minimum co |
| CP073 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP074 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP075 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-ASL-NE-14 � Flight Operated Incomplete Journey ASL Not Eligible |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "ASL" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 090 ? AC 091 TLV ? HFA ? VDA with claim filed for segment AC 091 HFA ? VDA |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 1 AC 090 TLV ? HFA is "Operated normally" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 2 AC 091 HFA ? VDA is "OPERATED (not cancelled � passenger did not board)" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 090 ? AC 091 TLV ? HFA ? VDA |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is "N/A (flight operated � not cancelled in system)" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "N/A (flight not recorded as cancelled)" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is "N/A" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Cancellation Check is "NOT CANCELLED � flight operated (AC 091 departed without passenger)" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "No Travel � Incomplete Journey (stranded at HFA, not cancelled)" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (TLV ? HFA ? VDA = all Israel)" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED (ASL regime does not evaluate for SOC)" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-ASL-NE-14" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Dispute Note is "Passenger may dispute if missed connection was caused by airline delay on first leg � agent should investigate MCT  |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the connecting flight operated normally so the passenger missed it or could not board which is different from NE-11 where the connecting |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP112 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-ASL-NE-14 � Flight Operated Incomplete Journey ASL Not Eligible |  |
| CP113 | PAYMENT VALIDATION | payment | chat | Given the case SoC-ASL-NE-14 is determined as NOT ELIGIBLE |  |
| CP114 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP115 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP116 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP117 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP118 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP119 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP120 | EXPECTED RESULTS | verdict | chat | SoC-ASL-NE-14. | SoC-ASL-NE-14. |
| CP121 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP122 | EXPECTED RESULTS | verdict | chat | No travel (incomplete),  not cancelled under ASL. | No travel (incomplete),  not cancelled under ASL. |
