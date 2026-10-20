# SOC_UAT_040 · CHAI-31955 — checkpoints

**Goal:** Verify NO DETERMINATION when  operated by STAR under EU.

Methods: seed 14, chat 41, api 20, dashboard 36, implied 18, manual 6, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify NO DETERMINATION when  operated by STAR under EU. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: EU | � Regime: EU |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Multi-segment | � Itinerary: Multi-segment |
| CP004 | PREREQUISITES | prerequisite | seed | - Segment 1: AC 871 CDG?ORD, Dep: 02-Jun 08:00 (operated normally � AC segment) | - Segment 1: AC 871 CDG?ORD, Dep: 02-Jun 08:00 (operated normally � AC segment) |
| CP005 | PREREQUISITES | prerequisite | seed | - Segment 2: UA 8765 ORD?SFO, Dep: 02-Jun 14:00 (delayed 4 hours � STAR segment) | - Segment 2: UA 8765 ORD?SFO, Dep: 02-Jun 14:00 (delayed 4 hours � STAR segment) |
| CP006 | PREREQUISITES | prerequisite | seed | � SOC Segment: UA 8765 ORD?SFO (customer-selected segment) | � SOC Segment: UA 8765 ORD?SFO (customer-selected segment) |
| CP007 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: | � Actual Itinerary: |
| CP008 | PREREQUISITES | prerequisite | seed | - Seg 1: AC 871 CDG?ORD, Dep: 02-Jun 08:00 (on time) | - Seg 1: AC 871 CDG?ORD, Dep: 02-Jun 08:00 (on time) |
| CP009 | PREREQUISITES | prerequisite | seed | - Seg 2: UA 8765 ORD?SFO, Dep: 02-Jun 18:00 (4h departure delay) | - Seg 2: UA 8765 ORD?SFO, Dep: 02-Jun 18:00 (4h departure delay) |
| CP010 | PREREQUISITES | prerequisite | seed | � Departure Delay on SOC Segment (Seg 2): 240 min (4 hours) | � Departure Delay on SOC Segment (Seg 2): 240 min (4 hours) |
| CP011 | PREREQUISITES | prerequisite | seed | � Departure delay code: Unknown � STAR disruption, AC has limited data | � Departure delay code: Unknown � STAR disruption, AC has limited data |
| CP012 | PREREQUISITES | prerequisite | seed | � Controllability: Unknown � STAR disruption data not fully available to AC; EU doesn't check controllability for SOC anyway | � Controllability: Unknown � STAR disruption data not fully available to AC; EU doesn't check controllability for SOC anyway |
| CP013 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP014 | PREREQUISITES | prerequisite | seed | � Check Order: 1. SOC segment carrier check ? STAR ? No Determination | � Check Order: 1. SOC segment carrier check ? STAR ? No Determination |
| CP015 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h |
| CP016 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP017 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP018 | START | customer | chat | Then user selects English |  |
| CP019 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP020 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP021 | START | customer | chat | And the user says "I had a connecting flight booked through Air Canada from Paris to San Francisco through Chicago. The Air Canada leg from  | I had a connecting flight booked through Air Canada from Paris to San Francisco through Chicago. The Air Canada leg from Paris to Chicago was fine, but the Unit |
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
| CP041 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 871 ? UA 8765 � Route: Paris (CDG) ? Chicago (ORD) ? San Francisco (SFO) � Date: June 2, 2026 � Segment 1: AC 871 CD |
| CP042 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? Yes (2 segments) |  |
| CP044 | SEGMENT SELECTION (GenUC-18a) | bot | chat | Then the chatbot displays the segment(s) associated with the selected journey: | Which segment was affected by the disruption? � Segment 1: AC 871 CDG?ORD (Operated normally) � Segment 2: UA 8765 ORD?SFO (Delayed � 4 hours) |
| CP045 | SEGMENT SELECTION (GenUC-18a) | customer | chat | And the user selects "Segment 2: UA 8765 ORD?SFO" | Segment 2: UA 8765 ORD?SFO |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + segment combination |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU SOC per departing country |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Departing country (of journey origin): France ? Limitation = 1,825 days (5 years) � Days elapsed: 6 days ? Within limitation period ? PROCEED |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Multi-segment trip CDG?ORD?SFO � Segment 1 AC871 on time, Segment 2 UA8765 (STAR) delayed +4H 00M | Multi-segment trip CDG?ORD?SFO � Segment 1 AC871 on time, Segment 2 UA8765 (STAR) delayed +4H 00M |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: EU (CDG departure) | Regime: EU (CDG departure) |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 2 | PASSENGERS: 1 � SEGMENTS: 2 |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Seg 1: AC 871, CDG ? ORD, Dep: 02-Jun 08:00 / Seg 2: UA 8765, ORD ? SFO, Dep: 02-Jun 14:00 | Promised Itinerary � Seg 1: AC 871, CDG ? ORD, Dep: 02-Jun 08:00 / Seg 2: UA 8765, ORD ? SFO, Dep: 02-Jun 14:00 |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Seg 1: AC 871, CDG ? ORD, Status: ON TIME / Seg 2: UA 8765, ORD ? SFO, Status: ARRIVED LATE, Scheduled Dep: 14:00 ? Actu | Current Itinerary � Seg 1: AC 871, CDG ? ORD, Status: ON TIME / Seg 2: UA 8765, ORD ? SFO, Status: ARRIVED LATE, Scheduled Dep: 14:00 ? Actual: 18:00, Delay: +4 |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present � SOC Segment: UA 8765 ORD?SFO (STAR) | SOC section present � SOC Segment: UA 8765 ORD?SFO (STAR) |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Operating Carrier: UA (United Airlines � STAR Alliance) | Operating Carrier: UA (United Airlines � STAR Alliance) |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: Unknown (STAR � AC has limited data) | Departure Delay Code: Unknown (STAR � AC has limited data) |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NO_DETERMINATION / BAND: DELAY_2_TO_6_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NO_DETERMINATION / BAND: DELAY_2_TO_6_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Receipt collection: INITIATED (STAR partners � more cooperative data-sharing) | Receipt collection: INITIATED (STAR partners � more cooperative data-sharing) |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NO DETERMINATION � case created for manual review, receipt collection initiated | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NO DETERMINATION � case created for manual review, receipt collection initiated |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-EU-ND-02 | DDS RESPONSE CODE = SoC-EU-ND-02 |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC & STAR |  |
| CP071 | NO DETERMINATION RESULT | bot | chat | Then the chatbot displays: "I've reviewed the details of your journey. The disruption on your trip was caused by a delay on your United Airl | I've reviewed the details of your journey. The disruption on your trip was caused by a delay on your United Airlines flight UA 8765 from Chicago to San Francisc |
| CP072 | RECEIPT COLLECTION INITIATED | system | implied | Then the system flags the case for potential receipt collection |  |
| CP073 | RECEIPT COLLECTION INITIATED | system | implied | And the case note indicates: "STAR partner disruption � receipt collection initiated pending manual review" |  |
| CP074 | CASE CREATION | system | implied | Then the system creates a case for agent review |  |
| CP075 | CASE CREATION | system | implied | And the case is assigned to the manual review queue |  |
| CP076 | CASE CREATION | system | implied | And the case reference number is provided to the passenger |  |
| CP077 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP078 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP079 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-EU-ND-02 � STAR Alliance EU No Determination |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Assigned (Manual Review Queue)" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is "Manual Review Queue" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (Auth Flow 1) |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is greyed out / not applicable |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "EU" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 871 ? UA 8765 CDG ? ORD ? SFO with claim filed for segment UA 8765 ORD ? SFO |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 1 AC 871 CDG ? ORD is "Operated normally" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 2 UA 8765 ORD ? SFO is "DELAYED 4 hours (STAR Alliance partner � disrupted segment)" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 871 ? UA 8765 CDG ? ORD ? SFO |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is "UA 8765 ORD ? SFO (STAR partner)" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is "UA (United Airlines � STAR Alliance)" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "UNKNOWN (limited STAR data available)" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 240 min (4 hours) |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (CDG = France, EU origin)" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT APPLICABLE (EU doesn't check � but STAR data still limited)" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-EU-ND-02" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Collection is "INITIATED (pending manual review � STAR partners may share more data)" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Agent Action Required is "Manual investigation � review with STAR partner data, verify delay, determine eligibility" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And this differs from ND-01 (OAL) because STAR partners have more cooperative data-sharing so receipt collection is initiated proactively an |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (pending manual determination)" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Current Status is "Assigned (Manual Review Queue)" and the case is NOT in read-only mode |  |
| CP119 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-EU-ND-02 � STAR Alliance EU No Determination |  |
| CP120 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-ND-02 has No Determination |  |
| CP121 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow is triggered |  |
| CP122 | PAYMENT VALIDATION | payment | chat | And the case is created and sent to agent for manual handling |  |
| CP123 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked at chatbot stage |  |
| CP124 | PAYMENT VALIDATION | payment | chat | And no automated compensation record is created |  |
| CP125 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP126 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered at chatbot stage |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And if the agent later determines eligible then the agent manually creates compensation with SOC as cash only |  |
| CP128 | PAYMENT VALIDATION | payment | chat | And a compensation record is created with GL account and cost center |  |
| CP129 | PAYMENT VALIDATION | payment | manual | And a batch file is dispatched to Unifier |  |
| CP130 | PAYMENT VALIDATION | payment | manual | And end-of-day report status tracking is initiated |  |
| CP131 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Case status = "No Determination" with no payout section until manually resolved |  |
| CP132 | EXPECTED RESULTS | verdict | chat | SoC-EU-ND-02. | SoC-EU-ND-02. |
| CP133 | EXPECTED RESULTS | verdict | chat | NO DETERMINATION.  on STAR Alliance partner. | NO DETERMINATION.  on STAR Alliance partner. |
| CP134 | EXPECTED RESULTS | verdict | chat | Case created for agent review. | Case created for agent review. |
| CP135 | EXPECTED RESULTS | verdict | chat | Receipt collection initiated. | Receipt collection initiated. |
| CP136 | EXPECTED RESULTS | verdict | chat | Dark mode review may be needed. | Dark mode review may be needed. |
