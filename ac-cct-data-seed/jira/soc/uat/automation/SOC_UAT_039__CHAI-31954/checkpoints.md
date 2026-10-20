# SOC_UAT_039 · CHAI-31954 — checkpoints

**Goal:** Verify NO DETERMINATION when  operated by OAL under EU regime.

Methods: seed 14, chat 41, api 19, dashboard 4, implied 13, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify NO DETERMINATION when  operated by OAL under EU regime. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: EU | � Regime: EU |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Multi-segment | � Itinerary: Multi-segment |
| CP004 | PREREQUISITES | prerequisite | seed | - Segment 1: AC 849 LHR?FRA, Dep: 01-Jun 08:00 (operated normally � AC segment) | - Segment 1: AC 849 LHR?FRA, Dep: 01-Jun 08:00 (operated normally � AC segment) |
| CP005 | PREREQUISITES | prerequisite | seed | - Segment 2: LH 470 FRA?MUC, Dep: 01-Jun 14:00 (delayed 5 hours � OAL segment) | - Segment 2: LH 470 FRA?MUC, Dep: 01-Jun 14:00 (delayed 5 hours � OAL segment) |
| CP006 | PREREQUISITES | prerequisite | seed | � "SOC Segment: LH 470 FRA?MUC (customer-selected segment)" | � "SOC Segment: LH 470 FRA?MUC (customer-selected segment)" |
| CP007 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: | � Actual Itinerary: |
| CP008 | PREREQUISITES | prerequisite | seed | - Seg 1: AC 849 LHR?FRA, Dep: 01-Jun 08:00 (on time) | - Seg 1: AC 849 LHR?FRA, Dep: 01-Jun 08:00 (on time) |
| CP009 | PREREQUISITES | prerequisite | seed | - Seg 2: LH 470 FRA?MUC, Dep: 01-Jun 19:00 (5h departure delay) | - Seg 2: LH 470 FRA?MUC, Dep: 01-Jun 19:00 (5h departure delay) |
| CP010 | PREREQUISITES | prerequisite | seed | � Departure Delay on SOC Segment (Seg 2): 300 min (5 hours) | � Departure Delay on SOC Segment (Seg 2): 300 min (5 hours) |
| CP011 | PREREQUISITES | prerequisite | seed | � Departure delay code: Unknown � OAL disruption, AC cannot determine | � Departure delay code: Unknown � OAL disruption, AC cannot determine |
| CP012 | PREREQUISITES | prerequisite | seed | � Controllability: Unknown � OAL disruption data not available to AC; EU doesn't check controllability for SOC anyway | � Controllability: Unknown � OAL disruption data not available to AC; EU doesn't check controllability for SOC anyway |
| CP013 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP014 | PREREQUISITES | prerequisite | seed | � Check Order: 1. SOC segment carrier check ? OAL ? No Determination | � Check Order: 1. SOC segment carrier check ? OAL ? No Determination |
| CP015 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h |
| CP016 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP017 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP018 | START | customer | chat | Then user selects English |  |
| CP019 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP020 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP021 | START | customer | chat | And the user says "I had a connecting flight from London to Munich through Frankfurt. The Air Canada leg from London to Frankfurt was fine,  | I had a connecting flight from London to Munich through Frankfurt. The Air Canada leg from London to Frankfurt was fine, but the Lufthansa leg from Frankfurt to |
| CP022 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP023 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP024 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP037 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP039 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP041 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 849 ? LH 470 � Route: London Heathrow (LHR) ? Frankfurt (FRA) ? Munich (MUC) � Date: June 1, 2026 � Segment 1: AC 84 |
| CP042 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? Yes (2 segments) |  |
| CP044 | SEGMENT SELECTION (GenUC-18a) | bot | chat | Then the chatbot displays the segment(s) associated with the selected journey: | Which segment was affected by the disruption? � Segment 1: AC 849 LHR?FRA (Operated normally) � Segment 2: LH 470 FRA?MUC (Delayed � 5 hours) |
| CP045 | SEGMENT SELECTION (GenUC-18a) | customer | chat | And the user selects "Segment 2: LH 470 FRA?MUC" | Segment 2: LH 470 FRA?MUC |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + segment combination |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU SOC per departing country |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Departing country (of journey origin): United Kingdom ? Limitation = 2,190 days (6 years) � Days elapsed: 7 days ? Within limitation period ? PROCEED |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Multi-segment trip LHR?FRA?MUC � Segment 1 AC849 on time, Segment 2 LH470 (OAL) delayed +5H 00M | Multi-segment trip LHR?FRA?MUC � Segment 1 AC849 on time, Segment 2 LH470 (OAL) delayed +5H 00M |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: EU (LHR departure) | Regime: EU (LHR departure) |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 2 | PASSENGERS: 1 � SEGMENTS: 2 |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Seg 1: AC 849, LHR ? FRA, Dep: 01-Jun 08:00 / Seg 2: LH 470, FRA ? MUC, Dep: 01-Jun 14:00 | Promised Itinerary � Seg 1: AC 849, LHR ? FRA, Dep: 01-Jun 08:00 / Seg 2: LH 470, FRA ? MUC, Dep: 01-Jun 14:00 |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Seg 1: AC 849, LHR ? FRA, Status: ON TIME / Seg 2: LH 470, FRA ? MUC, Status: ARRIVED LATE, Scheduled Dep: 14:00 ? Actua | Current Itinerary � Seg 1: AC 849, LHR ? FRA, Status: ON TIME / Seg 2: LH 470, FRA ? MUC, Status: ARRIVED LATE, Scheduled Dep: 14:00 ? Actual: 19:00, Delay: +5H |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present � SOC Segment: LH 470 FRA?MUC (OAL) | SOC section present � SOC Segment: LH 470 FRA?MUC (OAL) |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Operating Carrier: LH (Lufthansa � OAL) | Operating Carrier: LH (Lufthansa � OAL) |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: Unknown (OAL � AC has no data) | Departure Delay Code: Unknown (OAL � AC has no data) |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NO_DETERMINATION / BAND: DELAY_2_TO_6_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NO_DETERMINATION / BAND: DELAY_2_TO_6_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NO DETERMINATION (or redirected to OAL) | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NO DETERMINATION (or redirected to OAL) |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-EU-ND-01 | DDS RESPONSE CODE = SoC-EU-ND-01 |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC & OAL |  |
| CP070 | NO DETERMINATION RESULT | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight, and we confirm that this flight was operated by Lufthansa. Please reac | I've reviewed the details of your flight, and we confirm that this flight was operated by Lufthansa. Please reach out to United Airlines directly for any claim- |
| CP071 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP072 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP073 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-EU-ND-01 � OAL Segment EU No Determination |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then no case is created in the Claims Dashboard for this scenario |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case is routed directly to manual handling without case creation at chatbot stage |  |
| CP078 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-EU-ND-01 � OAL Segment EU No Determination |  |
| CP079 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-ND-01 has No Determination |  |
| CP080 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow is triggered |  |
| CP081 | PAYMENT VALIDATION | payment | chat | And the case is created and sent to agent for manual handling |  |
| CP082 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked at chatbot stage |  |
| CP083 | PAYMENT VALIDATION | payment | chat | And no automated compensation record is created |  |
| CP084 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP085 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered at chatbot stage |  |
| CP086 | PAYMENT VALIDATION | payment | chat | And if the agent later determines eligible then the agent manually creates compensation with SOC as cash only |  |
| CP087 | PAYMENT VALIDATION | payment | chat | And a compensation record is created with GL account and cost center |  |
| CP088 | PAYMENT VALIDATION | payment | manual | And a batch file is dispatched to Unifier |  |
| CP089 | PAYMENT VALIDATION | payment | manual | And end-of-day report status tracking is initiated |  |
| CP090 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Case status = "No Determination" with no payout section until manually resolved |  |
| CP091 | EXPECTED RESULTS | verdict | chat | SoC-EU-ND-01. | SoC-EU-ND-01. |
| CP092 | EXPECTED RESULTS | verdict | chat | NO DETERMINATION.  on OAL � AC cannot determine eligibility. | NO DETERMINATION.  on OAL � AC cannot determine eligibility. |
| CP093 | EXPECTED RESULTS | verdict | chat | Passenger redirected to OAL. | Passenger redirected to OAL. |
| CP094 | EXPECTED RESULTS | verdict | chat | Case created for manual agent handling. | Case created for manual agent handling. |
| CP095 | EXPECTED RESULTS | verdict | chat | Dark mode review may be needed for QA validation. | Dark mode review may be needed for QA validation. |
