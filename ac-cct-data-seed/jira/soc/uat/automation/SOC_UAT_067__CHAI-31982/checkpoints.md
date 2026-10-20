# SOC_UAT_067 · CHAI-31982 — checkpoints

**Goal:** Verify NO DETERMINATION when OAL data unavailable after 14-day retrigger under ASL.

Methods: seed 13, chat 41, api 23, dashboard 35, implied 16, manual 6, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify NO DETERMINATION when OAL data unavailable after 14-day retrigger under ASL. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: ASL | � Regime: ASL |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Multi-segment | � Itinerary: Multi-segment |
| CP004 | PREREQUISITES | prerequisite | seed | - Segment 1: AC 090 TLV?HFA (operated normally � AC segment) | - Segment 1: AC 090 TLV?HFA (operated normally � AC segment) |
| CP005 | PREREQUISITES | prerequisite | seed | - Segment 2: LY 301 HFA?VDA (OAL data unavailable � El Al segment) | - Segment 2: LY 301 HFA?VDA (OAL data unavailable � El Al segment) |
| CP006 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): LY 301 HFA?VDA (Segment 2 � the OAL segment with suspected disruption) | � SOC Segment (per SoC Flight Identifier): LY 301 HFA?VDA (Segment 2 � the OAL segment with suspected disruption) |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay on SOC Segment: Unknown � OAL data unavailable | � Departure Delay on SOC Segment: Unknown � OAL data unavailable |
| CP008 | PREREQUISITES | prerequisite | seed | Unknown | Unknown |
| CP009 | PREREQUISITES | prerequisite | seed | � Departure delay code: Unknown � OAL data unavailable | � Departure delay code: Unknown � OAL data unavailable |
| CP010 | PREREQUISITES | prerequisite | seed | � Controllability: Unknown � OAL data unavailable; ASL doesn't check controllability for SOC anyway | � Controllability: Unknown � OAL data unavailable; ASL doesn't check controllability for SOC anyway |
| CP011 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP012 | PREREQUISITES | prerequisite | seed | � Check Order: 1. OAL data check ? UNAVAILABLE ? No Determination | � Check Order: 1. OAL data check ? UNAVAILABLE ? No Determination |
| CP013 | PREREQUISITES | prerequisite | seed | � 14-Day RE Retrigger: Triggered and completed, OAL data still unavailable | � 14-Day RE Retrigger: Triggered and completed, OAL data still unavailable |
| CP014 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h |
| CP015 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP016 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP017 | START | customer | chat | Then user selects English |  |
| CP018 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP019 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP020 | START | customer | chat | And the user says "I had a connecting flight booked through Air Canada from Tel Aviv through Haifa to Eilat. The Air Canada leg was fine, bu | I had a connecting flight booked through Air Canada from Tel Aviv through Haifa to Eilat. The Air Canada leg was fine, but the El Al leg from Haifa to Eilat was |
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
| CP040 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 090 ? LY 301 � Route: Tel Aviv (TLV) ? Haifa (HFA) ? Eilat (VDA) � Date: May 16, 2026 � Segment 1: AC 090 TLV?HFA �  |
| CP041 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? Yes (2 segments) |  |
| CP043 | SEGMENT SELECTION (GenUC-18a) | bot | chat | Then the chatbot displays the segment(s) associated with the selected journey: | Which segment was affected by the disruption? � Segment 1: AC 090 TLV?HFA (Operated normally) � Segment 2: LY 301 HFA?VDA (Flight data unavailable) |
| CP044 | SEGMENT SELECTION (GenUC-18a) | customer | chat | And the user selects "Segment 2: LY 301 HFA?VDA" | Segment 2: LY 301 HFA?VDA |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + segment combination |  |
| CP047 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes (well beyond � disruption was May 16) |  |
| CP049 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for ASL SOC |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � ASL limitation: 1,460 days (4 years) � FIXED � Days elapsed: 24 days (disruption May 16, filing Jun 9) ? Within limitation period ? PROCEED |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Partial � OAL operating data MISSING |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | Disruption Suspected � OAL operating data unavailable | Disruption Suspected � OAL operating data unavailable |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Multi-segment trip TLV?HFA?VDA � Segment 1 AC090 on time, Segment 2 LY301 (OAL) � flight data unavailable after 14-day retrigger | Multi-segment trip TLV?HFA?VDA � Segment 1 AC090 on time, Segment 2 LY301 (OAL) � flight data unavailable after 14-day retrigger |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: ASL (TLV?HFA?VDA = all Israel) | Regime: ASL (TLV?HFA?VDA = all Israel) |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 2 | PASSENGERS: 1 � SEGMENTS: 2 |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Seg 1: AC 090, TLV ? HFA / Seg 2: LY 301, HFA ? VDA | Promised Itinerary � Seg 1: AC 090, TLV ? HFA / Seg 2: LY 301, HFA ? VDA |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Seg 1: AC 090, TLV ? HFA, Status: ON TIME / Seg 2: LY 301, HFA ? VDA, Status: DATA UNAVAILABLE � OAL operating data not  | Current Itinerary � Seg 1: AC 090, TLV ? HFA, Status: ON TIME / Seg 2: LY 301, HFA ? VDA, Status: DATA UNAVAILABLE � OAL operating data not populated |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present � SOC Segment: LY 301 HFA?VDA (OAL) | SOC section present � SOC Segment: LY 301 HFA?VDA (OAL) |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Operating Carrier: LY (El Al � OAL) | Operating Carrier: LY (El Al � OAL) |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | OAL Operating Data: UNAVAILABLE after 14-day RE retrigger | OAL Operating Data: UNAVAILABLE after 14-day RE retrigger |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Delay Calculation: IMPOSSIBLE (no OAL actual times) | Delay Calculation: IMPOSSIBLE (no OAL actual times) |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Geographic Check: TLV?HFA?VDA = all Israel ? PASSED ? | Geographic Check: TLV?HFA?VDA = all Israel ? PASSED ? |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NO_DETERMINATION / BAND: � (cannot calculate) / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NO_DETERMINATION / BAND: � (cannot calculate) / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | Difference from ND-01: ND-01 = immediate OAL detection ? instant ND. ND-05 = system waited 14 days, retriggered RE, OAL data still unavailab | Difference from ND-01: ND-01 = immediate OAL detection ? instant ND. ND-05 = system waited 14 days, retriggered RE, OAL data still unavailable ? ND after exhaus |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NO DETERMINATION � case created for manual review (agent must coordinate with OA | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NO DETERMINATION � case created for manual review (agent must coordinate with OAL for operating data |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-ASL-ND-05 | DDS RESPONSE CODE = SoC-ASL-ND-05 |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC & OAL |  |
| CP072 | NO DETERMINATION RESULT | bot | chat | Then the chatbot displays: "I've reviewed the details of your journey. The disruption appears to have occurred on your El Al flight LY 301 f | I've reviewed the details of your journey. The disruption appears to have occurred on your El Al flight LY 301 from Haifa to Eilat. Unfortunately, the operating |
| CP073 | CASE CREATION | system | implied | Then the system creates a case for manual agent review |  |
| CP074 | CASE CREATION | system | implied | And the case is assigned to the manual review queue |  |
| CP075 | CASE CREATION | verdict | api | And the case note indicates: "ASL regime � OAL (El Al LY 301) operating data unavailable after 14-day RE retrigger. Geographic check passed  | ASL regime � OAL (El Al LY 301) operating data unavailable after 14-day RE retrigger. Geographic check passed (TLV?HFA?VDA = all Israel). Agent must investigate |
| CP076 | CASE CREATION | system | implied | And the case reference number is provided to the passenger |  |
| CP077 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP078 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP079 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-ASL-ND-05 � OAL Data Missing After Retrigger ASL No Determination |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Assigned (Manual Review Queue)" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is "Manual Review Queue" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "ASL" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 090 ? LY 301 TLV ? HFA ? VDA with claim filed for segment LY 301 HFA ? VDA |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 1 AC 090 TLV ? HFA is "Operated normally" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 2 LY 301 HFA ? VDA is "OAL operating data UNAVAILABLE (Disrupted segment)" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 090 ? LY 301 TLV ? HFA ? VDA |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is "LY 301 HFA ? VDA (OAL)" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is "LY (El Al � OAL)" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the SOC Segment is "LY 301 (OAL operated � data unavailable)" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "UNKNOWN � OAL operating data unavailable" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Actual Departure Time (OAL) is "NOT AVAILABLE" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Actual Arrival Time (OAL) is "NOT AVAILABLE" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is "UNKNOWN � cannot calculate without OAL operating data" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "UNKNOWN � OAL data missing" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (TLV ? HFA ? VDA = all Israel)" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT APPLICABLE (ASL doesn't check)" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the 14-Day RE Retrigger is "COMPLETED � OAL data still not available" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-ASL-ND-05" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Agent Action Required is "Investigate OAL disruption data � coordinate with El Al for operating data. Geographic origin already conf |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the difference from ND-01 is ND-01 detects OAL SOC immediately and triggers instant ND while ND-05 means the system WAITED 14 days, retr |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the difference from ND-04 is ND-04 is AC's OWN operating data missing (AC flight) while ND-05 is OAL operating data missing (El Al fligh |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (pending manual determination)" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Current Status is "Assigned (Manual Review Queue)" and the case is NOT in read-only mode |  |
| CP118 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-ASL-ND-05 � OAL Data Missing After Retrigger ASL No Determination |  |
| CP119 | PAYMENT VALIDATION | payment | chat | Given the case SoC-ASL-ND-05 has No Determination |  |
| CP120 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow is triggered |  |
| CP121 | PAYMENT VALIDATION | payment | chat | And the case is created and sent to agent for manual handling |  |
| CP122 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked at chatbot stage |  |
| CP123 | PAYMENT VALIDATION | payment | chat | And no automated compensation record is created |  |
| CP124 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP125 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered at chatbot stage |  |
| CP126 | PAYMENT VALIDATION | payment | chat | And if the agent later determines eligible then the agent manually creates compensation with SOC as cash only |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And a compensation record is created with GL account and cost center |  |
| CP128 | PAYMENT VALIDATION | payment | manual | And a batch file is dispatched to Unifier |  |
| CP129 | PAYMENT VALIDATION | payment | manual | And end-of-day report status tracking is initiated |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Case status = "No Determination" with no payout section until manually resolved |  |
| CP131 | EXPECTED RESULTS | verdict | chat | SoC-ASL-ND-05. | SoC-ASL-ND-05. |
| CP132 | EXPECTED RESULTS | verdict | chat | NO DETERMINATION. | NO DETERMINATION. |
| CP133 | EXPECTED RESULTS | verdict | chat | OAL data unavailable after 14-day retrigger. | OAL data unavailable after 14-day retrigger. |
| CP134 | EXPECTED RESULTS | verdict | chat | Case created for manual review. | Case created for manual review. |
| CP135 | EXPECTED RESULTS | verdict | chat | Dark mode review may be needed. | Dark mode review may be needed. |
