# SOC_UAT_007 · CHAI-31922 — checkpoints

**Goal:** Verify not eligible when customer at mid-point, did not land at destination, disruption outside carrier control.

Methods: seed 19, chat 38, api 17, dashboard 38, implied 12, manual 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify not eligible when customer at mid-point, did not land at destination, disruption outside carrier control. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Multi-segment | � Itinerary: Multi-segment |
| CP004 | PREREQUISITES | prerequisite | seed | - Segment 1: AC 901 YYZ?YYC, Dep: 06-Jun 07:00 (operated normally) | - Segment 1: AC 901 YYZ?YYC, Dep: 06-Jun 07:00 (operated normally) |
| CP005 | PREREQUISITES | prerequisite | seed | - Segment 2: AC 902 YYC?YVR, Dep: 06-Jun 12:00 (cancelled) | - Segment 2: AC 902 YYC?YVR, Dep: 06-Jun 12:00 (cancelled) |
| CP006 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 902 YYC?YVR (Segment 2 � the cancelled segment evaluated for SOC) | � SOC Segment (per SoC Flight Identifier): AC 902 YYC?YVR (Segment 2 � the cancelled segment evaluated for SOC) |
| CP007 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: | � Promised Itinerary: |
| CP008 | PREREQUISITES | prerequisite | seed | - Seg 1: AC 901 YYZ?YYC, Dep: 06-Jun 07:00 | - Seg 1: AC 901 YYZ?YYC, Dep: 06-Jun 07:00 |
| CP009 | PREREQUISITES | prerequisite | seed | - Seg 2: AC 902 YYC?YVR, Dep: 06-Jun 12:00 | - Seg 2: AC 902 YYC?YVR, Dep: 06-Jun 12:00 |
| CP010 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 901 YYZ?YYC completed. AC 902 YYC?YVR cancelled. Passenger stranded at YYC | � Actual Itinerary: AC 901 YYZ?YYC completed. AC 902 YYC?YVR cancelled. Passenger stranded at YYC |
| CP011 | PREREQUISITES | prerequisite | seed | � Departure Delay: N/A � no travel on SOC segment (cancelled) | � Departure Delay: N/A � no travel on SOC segment (cancelled) |
| CP012 | PREREQUISITES | prerequisite | seed | � Departure delay code on SOC Segment: 77 (Weather) � Uncontrollable | � Departure delay code on SOC Segment: 77 (Weather) � Uncontrollable |
| CP013 | PREREQUISITES | prerequisite | seed | � Controllability: Uncontrollable (Code 77) | � Controllability: Uncontrollable (Code 77) |
| CP014 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP015 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Regular ? ? 2. Controllability ? Uncontrollable ? NOT ELIGIBLE | � Check Order: 1. Pax Type ? Regular ? ? 2. Controllability ? Uncontrollable ? NOT ELIGIBLE |
| CP016 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult | � PAX Count: 1 adult |
| CP017 | PREREQUISITES | prerequisite | seed | � Class of Booking: PY | � Class of Booking: PY |
| CP018 | PREREQUISITES | prerequisite | seed | � Revenue Booking: YES | � Revenue Booking: YES |
| CP019 | PREREQUISITES | prerequisite | seed | � ACR Issued: N/A | � ACR Issued: N/A |
| CP020 | PREREQUISITES | prerequisite | seed | � Journey Completed: > 72h | � Journey Completed: > 72h |
| CP021 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP022 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP023 | START | customer | chat | Then user selects English |  |
| CP024 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP025 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP026 | START | customer | chat | And the user says "I was on a connecting flight and my second leg got cancelled because of weather. I got stuck at Calgary and never made it | I was on a connecting flight and my second leg got cancelled because of weather. I got stuck at Calgary and never made it to Vancouver. I had to pay for food an |
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
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP041 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP042 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP043 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP044 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP045 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP046 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 901 ? AC 902 � Route: Toronto (YYZ) ? Calgary (YYC) ? Vancouver (YVR) � Date: June 6, 2026 � Segment 1: AC 901 YYZ?Y |
| CP047 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? Yes (2 segments) |  |
| CP049 | SEGMENT SELECTION (GenUC-18a) | bot | chat | Then the chatbot displays the segment(s) associated with the selected journey: | Which segment was affected by the disruption? � Segment 1: AC 901 YYZ?YYC (Operated) � Segment 2: AC 902 YYC?YVR (Cancelled) |
| CP050 | SEGMENT SELECTION (GenUC-18a) | customer | chat | And the user selects "Segment 2: AC 902 YYC?YVR" | Segment 2: AC 902 YYC?YVR |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP052 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + segment combination |  |
| CP053 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP054 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP055 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR SOC per province ? Within limitation period ? PROCEED |  |
| CP056 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Not Completed, Disruption Detected | Trip Not Completed, Disruption Detected |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Multi-segment domestic trip YYZ?YYC?YVR � Segment 2 AC902 YYC?YVR was cancelled due to weather (uncontrollable). Passenger stranded at YYC. | Multi-segment domestic trip YYZ?YYC?YVR � Segment 2 AC902 YYC?YVR was cancelled due to weather (uncontrollable). Passenger stranded at YYC. |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 2 | PASSENGERS: 1 � SEGMENTS: 2 |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Seg 1: AC 901, YYZ ? YYC, Dep: 06-Jun 07:00 / Seg 2: AC 902, YYC ? YVR, Dep: 06-Jun 12:00 | Promised Itinerary � Seg 1: AC 901, YYZ ? YYC, Dep: 06-Jun 07:00 / Seg 2: AC 902, YYC ? YVR, Dep: 06-Jun 12:00 |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Seg 1: AC 901, YYZ ? YYC, Status: ON TIME / Seg 2: AC 902, YYC ? YVR, Status: CANCELLED | Current Itinerary � Seg 1: AC 901, YYZ ? YYC, Status: ON TIME / Seg 2: AC 902, YYC ? YVR, Status: CANCELLED |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present � SOC Segment: AC 902 YYC?YVR | SOC section present � SOC Segment: AC 902 YYC?YVR |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 77 (Weather) � Uncontrollable | Departure Delay Code: 77 (Weather) � Uncontrollable |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: � / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE / BAND: � / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-APPR-NE-12 | DDS RESPONSE CODE = SoC-APPR-NE-12 |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP072 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. Unfortunately, your connecting flight AC 902 from Calgary to Vancouver | I've reviewed the details of your flight. Unfortunately, your connecting flight AC 902 from Calgary to Vancouver was cancelled due to severe weather conditions. |
| CP073 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP074 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP075 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP076 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP077 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-NE-12 � Weather Incomplete Journey Not Eligible |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (Auth Flow 1) |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is NOT greyed out |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 901 YYZ ? YYC ? YVR with claim filed for segment AC 902 YYC ? YVR |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 1 AC 901 YYZ ? YYC is "Operated" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 2 AC 902 YYC ? YVR is "CANCELLED (Disrupted segment)" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 901 ? AC 902 YYZ ? YYC ? YVR |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 902 YYC ? YVR |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Weather (Code 77)" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is "N/A (no travel � incomplete journey)" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "No Travel � Incomplete (stranded at YYC)" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "Uncontrollable (Code 77 � Weather)" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-NE-12" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Check Order is: 1. Pax Type ? Regular ? ? 2. Controllability ? Uncontrollable ? NOT ELIGIBLE |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if Pax Type were Exception, controllability would be skipped and passenger would be ELIGIBLE |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "N/A" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility on Claims Dashboard is "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP119 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-NE-12 � Weather Incomplete Journey Not Eligible |  |
| CP120 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-NE-12 is determined as NOT ELIGIBLE |  |
| CP121 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP122 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP123 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP124 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP125 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP126 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP127 | EXPECTED RESULTS | verdict | chat | SoC-APPR-NE-12. | SoC-APPR-NE-12. |
| CP128 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP129 | EXPECTED RESULTS | verdict | chat | No travel (incomplete, mid-point), outside carrier control, regular passenger. | No travel (incomplete, mid-point), outside carrier control, regular passenger. |
