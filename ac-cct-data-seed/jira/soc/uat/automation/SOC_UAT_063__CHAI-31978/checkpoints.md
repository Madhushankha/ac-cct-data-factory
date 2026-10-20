# SOC_UAT_063 · CHAI-31978 — checkpoints

**Goal:** Verify NO DETERMINATION when  operated by OAL under ASL.

Methods: seed 11, chat 41, api 21, dashboard 33, implied 16, manual 6, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify NO DETERMINATION when  operated by OAL under ASL. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: ASL | � Regime: ASL |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Multi-segment | � Itinerary: Multi-segment |
| CP004 | PREREQUISITES | prerequisite | seed | - Segment 1: AC 090 TLV?HFA (operated normally � AC segment) | - Segment 1: AC 090 TLV?HFA (operated normally � AC segment) |
| CP005 | PREREQUISITES | prerequisite | seed | - Segment 2: LY 301 HFA?VDA (delayed 5 hours � OAL segment) | - Segment 2: LY 301 HFA?VDA (delayed 5 hours � OAL segment) |
| CP006 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): LY 301 HFA?VDA (Segment 2 � the OAL segment with the qualifying departure delay) | � SOC Segment (per SoC Flight Identifier): LY 301 HFA?VDA (Segment 2 � the OAL segment with the qualifying departure delay) |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay on SOC Segment (Seg 2): 300 min (5 hours) | � Departure Delay on SOC Segment (Seg 2): 300 min (5 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: Unknown � OAL disruption, AC cannot determine | � Departure delay code: Unknown � OAL disruption, AC cannot determine |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Unknown � OAL disruption data not available to AC; ASL doesn't check controllability for SOC anyway | � Controllability: Unknown � OAL disruption data not available to AC; ASL doesn't check controllability for SOC anyway |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP011 | PREREQUISITES | prerequisite | seed | � Check Order: 1. SOC segment carrier check ? OAL ? No Determination | � Check Order: 1. SOC segment carrier check ? OAL ? No Determination |
| CP012 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h |
| CP013 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP014 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP015 | START | customer | chat | Then user selects English |  |
| CP016 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP017 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP018 | START | customer | chat | And the user says "I had a connecting flight from Tel Aviv to Eilat through Haifa. The Air Canada leg from Tel Aviv to Haifa was fine, but t | I had a connecting flight from Tel Aviv to Eilat through Haifa. The Air Canada leg from Tel Aviv to Haifa was fine, but the El Al leg from Haifa to Eilat was de |
| CP019 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP020 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP021 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP034 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP036 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP037 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP038 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 090 ? LY 301 � Route: Tel Aviv (TLV) ? Haifa (HFA) ? Eilat (VDA) � Date: June 1, 2026 � Segment 1: AC 090 TLV?HFA �  |
| CP039 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP040 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? Yes (2 segments) |  |
| CP041 | SEGMENT SELECTION (GenUC-18a) | bot | chat | Then the chatbot displays the segment(s) associated with the selected journey: | Which segment was affected by the disruption? � Segment 1: AC 090 TLV?HFA (Operated normally) � Segment 2: LY 301 HFA?VDA (Delayed � 5 hours) |
| CP042 | SEGMENT SELECTION (GenUC-18a) | customer | chat | And the user selects "Segment 2: LY 301 HFA?VDA" | Segment 2: LY 301 HFA?VDA |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + segment combination |  |
| CP045 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP046 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP047 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for ASL SOC |  |
| CP048 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � ASL limitation: 1,460 days (4 years) � FIXED � Days elapsed: 8 days ? Within limitation period ? PROCEED |
| CP049 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP050 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP051 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP052 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP053 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | Multi-segment trip TLV?HFA?VDA � Segment 1 AC090 on time, Segment 2 LY301 (OAL) delayed +5H 00M | Multi-segment trip TLV?HFA?VDA � Segment 1 AC090 on time, Segment 2 LY301 (OAL) delayed +5H 00M |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: ASL (TLV?HFA?VDA = all Israel) | Regime: ASL (TLV?HFA?VDA = all Israel) |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 2 | PASSENGERS: 1 � SEGMENTS: 2 |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Seg 1: AC 090, TLV ? HFA / Seg 2: LY 301, HFA ? VDA | Promised Itinerary � Seg 1: AC 090, TLV ? HFA / Seg 2: LY 301, HFA ? VDA |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Seg 1: AC 090, TLV ? HFA, Status: ON TIME / Seg 2: LY 301, HFA ? VDA, Status: ARRIVED LATE, Delay: +5H 00M | Current Itinerary � Seg 1: AC 090, TLV ? HFA, Status: ON TIME / Seg 2: LY 301, HFA ? VDA, Status: ARRIVED LATE, Delay: +5H 00M |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present � SOC Segment: LY 301 HFA?VDA (OAL) | SOC section present � SOC Segment: LY 301 HFA?VDA (OAL) |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Operating Carrier: LY (El Al � OAL) | Operating Carrier: LY (El Al � OAL) |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: Unknown (OAL � AC has no data) | Departure Delay Code: Unknown (OAL � AC has no data) |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Geographic Check: TLV?HFA?VDA = all Israel ? PASSED ? | Geographic Check: TLV?HFA?VDA = all Israel ? PASSED ? |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NO_DETERMINATION / BAND: DELAY_2_TO_6_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NO_DETERMINATION / BAND: DELAY_2_TO_6_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NO DETERMINATION � case created for manual review (or redirected to OAL) | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NO DETERMINATION � case created for manual review (or redirected to OAL) |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-ASL-ND-01 | DDS RESPONSE CODE = SoC-ASL-ND-01 |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC & OAL |  |
| CP068 | NO DETERMINATION RESULT | bot | chat | Then the chatbot displays: "I've reviewed the details of your journey. The disruption on your trip was caused by a delay on your El Al fligh | I've reviewed the details of your journey. The disruption on your trip was caused by a delay on your El Al flight LY 301 from Haifa to Eilat, which was not oper |
| CP069 | CASE CREATION | system | implied | Then the system creates a case for manual agent handling |  |
| CP070 | CASE CREATION | system | implied | And the case is assigned to the manual review queue |  |
| CP071 | CASE CREATION | verdict | api | And the case note indicates: "ASL regime �  on OAL (El Al LY 301). AC cannot verify OAL disruption data. Geographic check passed (all Israel | ASL regime �  on OAL (El Al LY 301). AC cannot verify OAL disruption data. Geographic check passed (all Israel). Manual investigation required. Passenger may al |
| CP072 | CASE CREATION | system | implied | And the case reference number is provided to the passenger |  |
| CP073 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP074 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP075 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-ASL-ND-01 � OAL Segment ASL No Determination |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Assigned (Manual Review Queue)" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is "Manual Review Queue" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (Auth Flow 1) |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is greyed out / not applicable |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "ASL" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 090 ? LY 301 TLV ? HFA ? VDA with claim filed for segment LY 301 HFA ? VDA |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 1 AC 090 TLV ? HFA is "Operated normally" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 2 LY 301 HFA ? VDA is "DELAYED 5 hours (OAL operated � disrupted segment)" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 090 ? LY 301 TLV ? HFA ? VDA |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is "LY 301 HFA ? VDA (OAL)" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is "LY (El Al � OAL)" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the SOC Segment is "LY 301 (OAL operated)" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "UNKNOWN (AC has no OAL disruption data)" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 300 min (5 hours) |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (TLV ? HFA ? VDA = all Israel)" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT APPLICABLE (ASL doesn't check � but OAL data still unavailable)" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-ASL-ND-01" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Agent Action Required is "Manual investigation � contact OAL for disruption data, verify delay, determine eligibility manually" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (pending manual determination)" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Current Status is "Assigned (Manual Review Queue)" and the case is NOT in read-only mode |  |
| CP112 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-ASL-ND-01 � OAL Segment ASL No Determination |  |
| CP113 | PAYMENT VALIDATION | payment | chat | Given the case SoC-ASL-ND-01 has No Determination |  |
| CP114 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow is triggered |  |
| CP115 | PAYMENT VALIDATION | payment | chat | And the case is created and sent to agent for manual handling |  |
| CP116 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked at chatbot stage |  |
| CP117 | PAYMENT VALIDATION | payment | chat | And no automated compensation record is created |  |
| CP118 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP119 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered at chatbot stage |  |
| CP120 | PAYMENT VALIDATION | payment | chat | And if the agent later determines eligible then the agent manually creates compensation with SOC as cash only |  |
| CP121 | PAYMENT VALIDATION | payment | chat | And a compensation record is created with GL account and cost center |  |
| CP122 | PAYMENT VALIDATION | payment | manual | And a batch file is dispatched to Unifier |  |
| CP123 | PAYMENT VALIDATION | payment | manual | And end-of-day report status tracking is initiated |  |
| CP124 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Case status = "No Determination" with no payout section until manually resolved |  |
| CP125 | EXPECTED RESULTS | verdict | chat | SoC-ASL-ND-01. | SoC-ASL-ND-01. |
| CP126 | EXPECTED RESULTS | verdict | chat | NO DETERMINATION.  on OAL � AC cannot determine eligibility. | NO DETERMINATION.  on OAL � AC cannot determine eligibility. |
| CP127 | EXPECTED RESULTS | verdict | chat | Passenger redirected to OAL. | Passenger redirected to OAL. |
| CP128 | EXPECTED RESULTS | verdict | chat | Case created for manual agent handling. | Case created for manual agent handling. |
| CP129 | EXPECTED RESULTS | verdict | chat | Dark mode review may be needed for QA validation. | Dark mode review may be needed for QA validation. |
