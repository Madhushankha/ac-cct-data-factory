# SOC_UAT_011 · CHAI-31926 — checkpoints

**Goal:** Verify that when the  segment was operated by a STAR carrier, the system returns NO DETERMINATION and forwards to agent review.

Methods: seed 21, chat 40, api 18, dashboard 54, implied 18, manual 9, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify that when the  segment was operated by a STAR carrier, the system returns NO DETERMINATION and forwards to agent review. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Multi-segment | � Itinerary: Multi-segment |
| CP004 | PREREQUISITES | prerequisite | seed | - Segment 1: AC 789 YYZ?ORD, Dep: 02-Jun 08:00 | - Segment 1: AC 789 YYZ?ORD, Dep: 02-Jun 08:00 |
| CP005 | PREREQUISITES | prerequisite | seed | - Segment 2: UA 8765 ORD?SFO, Dep: 02-Jun 14:00 | - Segment 2: UA 8765 ORD?SFO, Dep: 02-Jun 14:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): UA 8765 ORD?SFO | � SOC Segment (per SoC Flight Identifier): UA 8765 ORD?SFO |
| CP007 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: | � Promised Itinerary: |
| CP008 | PREREQUISITES | prerequisite | seed | - Seg 1: AC 789 YYZ?ORD, Dep: 02-Jun 08:00 | - Seg 1: AC 789 YYZ?ORD, Dep: 02-Jun 08:00 |
| CP009 | PREREQUISITES | prerequisite | seed | - Seg 2: UA 8765 ORD?SFO, Dep: 02-Jun 14:00 | - Seg 2: UA 8765 ORD?SFO, Dep: 02-Jun 14:00 |
| CP010 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: | � Actual Itinerary: |
| CP011 | PREREQUISITES | prerequisite | seed | - Seg 1: AC 789 YYZ?ORD, Dep: 02-Jun 08:00 (on time) | - Seg 1: AC 789 YYZ?ORD, Dep: 02-Jun 08:00 (on time) |
| CP012 | PREREQUISITES | prerequisite | seed | - Seg 2: UA 8765 ORD?SFO, Dep: 02-Jun 18:00 (4h departure delay) | - Seg 2: UA 8765 ORD?SFO, Dep: 02-Jun 18:00 (4h departure delay) |
| CP013 | PREREQUISITES | prerequisite | seed | � Departure Delay on SOC Segment (Seg 2): 240 min (4 hours) | � Departure Delay on SOC Segment (Seg 2): 240 min (4 hours) |
| CP014 | PREREQUISITES | prerequisite | seed | � Departure delay code: Unknown � STAR disruption, AC cannot determine | � Departure delay code: Unknown � STAR disruption, AC cannot determine |
| CP015 | PREREQUISITES | prerequisite | seed | � Controllability: Unknown � STAR disruption data not available to AC | � Controllability: Unknown � STAR disruption data not available to AC |
| CP016 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP017 | PREREQUISITES | prerequisite | seed | � Check Order: 1. SOC segment carrier check ? STAR ? No Determination (Step 3 of APPR SOC flow) | � Check Order: 1. SOC segment carrier check ? STAR ? No Determination (Step 3 of APPR SOC flow) |
| CP018 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult | � PAX Count: 1 adult |
| CP019 | PREREQUISITES | prerequisite | seed | � Class of Booking: PY | � Class of Booking: PY |
| CP020 | PREREQUISITES | prerequisite | seed | � Revenue Booking: YES | � Revenue Booking: YES |
| CP021 | PREREQUISITES | prerequisite | seed | � ACR Issued: N/A | � ACR Issued: N/A |
| CP022 | PREREQUISITES | prerequisite | seed | � Journey Completed: > 72h | � Journey Completed: > 72h |
| CP023 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP024 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP025 | START | customer | chat | Then user selects English |  |
| CP026 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP027 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP028 | START | customer | chat | And the user says "I had a connecting flight booked through Air Canada. The first leg on Air Canada was fine, but the second leg operated by | I had a connecting flight booked through Air Canada. The first leg on Air Canada was fine, but the second leg operated by United Airlines was delayed by 4 hours |
| CP029 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP030 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP031 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP032 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP033 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP034 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP035 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP036 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP037 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP038 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP041 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP042 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP043 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP044 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP045 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP046 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP047 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP048 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 789 ? UA 8765 � Route: Toronto (YYZ) ? Chicago (ORD) ? San Francisco (SFO) � Date: June 2, 2026 � Segment 1: AC 789  |
| CP049 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP050 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? Yes (2 segments) |  |
| CP051 | SEGMENT SELECTION (GenUC-18a) | bot | chat | Then the chatbot displays the segment(s) associated with the selected journey: | Which segment was affected by the disruption? � Segment 1: AC 789 YYZ?ORD (Operated normally) � Segment 2: UA 8765 ORD?SFO (Delayed � 4 hours) |
| CP052 | SEGMENT SELECTION (GenUC-18a) | customer | chat | And the user selects "Segment 2: UA 8765 ORD?SFO" | Segment 2: UA 8765 ORD?SFO |
| CP053 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP054 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + segment combination |  |
| CP055 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP056 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP057 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR SOC per province |  |
| CP058 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Origin: YYZ (Ontario) ? Limitation = 730 days � Days elapsed: Within limitation period ? PROCEED |
| CP059 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Multi-segment trip YYZ?ORD?SFO � Segment 1 AC789 on time, Segment 2 UA8765 (STAR) delayed +4H 00M | Multi-segment trip YYZ?ORD?SFO � Segment 1 AC789 on time, Segment 2 UA8765 (STAR) delayed +4H 00M |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 2 | PASSENGERS: 1 � SEGMENTS: 2 |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Seg 1: AC 789, YYZ ? ORD, Dep: 02-Jun 08:00 / Seg 2: UA 8765, ORD ? SFO, Dep: 02-Jun 14:00 | Promised Itinerary � Seg 1: AC 789, YYZ ? ORD, Dep: 02-Jun 08:00 / Seg 2: UA 8765, ORD ? SFO, Dep: 02-Jun 14:00 |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Seg 1: AC 789, YYZ ? ORD, Status: ON TIME / Seg 2: UA 8765, ORD ? SFO, Status: ARRIVED LATE, Scheduled Dep: 14:00 ? Actu | Current Itinerary � Seg 1: AC 789, YYZ ? ORD, Status: ON TIME / Seg 2: UA 8765, ORD ? SFO, Status: ARRIVED LATE, Scheduled Dep: 14:00 ? Actual: 18:00, Delay: +4 |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present � SOC Segment: UA 8765 ORD?SFO (STAR) | SOC section present � SOC Segment: UA 8765 ORD?SFO (STAR) |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | Operating Carrier: UA (United Airlines � STAR Alliance) | Operating Carrier: UA (United Airlines � STAR Alliance) |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: Unknown (STAR � AC has limited data) | Departure Delay Code: Unknown (STAR � AC has limited data) |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NO_DETERMINATION / BAND: DELAY_2_TO_6_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NO_DETERMINATION / BAND: DELAY_2_TO_6_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP073 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NO DETERMINATION � case created for manual review | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NO DETERMINATION � case created for manual review |
| CP074 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-APPR-ND-02 | DDS RESPONSE CODE = SoC-APPR-ND-02 |
| CP075 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC & STAR |  |
| CP076 | NO DETERMINATION RESULT | bot | chat | Then the chatbot displays: "I've reviewed the details of your journey. The disruption on your trip was caused by a delay on your United Airl | I've reviewed the details of your journey. The disruption on your trip was caused by a delay on your United Airlines flight UA 8765 from Chicago to San Francisc |
| CP077 | RECEIPT COLLECTION INITIATED | system | implied | Then the system flags the case for potential receipt collection |  |
| CP078 | RECEIPT COLLECTION INITIATED | system | implied | And the case note indicates: "STAR partner disruption � receipt collection initiated pending manual review" |  |
| CP079 | CASE CREATION | system | implied | Then the system creates a case for agent review |  |
| CP080 | CASE CREATION | system | implied | And the case is assigned to the manual review queue |  |
| CP081 | CASE CREATION | system | implied | And the case reference number is provided to the passenger |  |
| CP082 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP083 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP084 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-ND-02 � STAR Alliance No Determination |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent can edit Topic/Sub-topic but cannot switch between automated and non-automated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Assigned (Manual Review Queue)" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date is populated |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date is populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is "Manual Review Queue" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (identified + authenticated, Auth Flow 1) |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is greyed out / not applicable (No Determination � agent must manually assess) |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Adult" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date is populated |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID is populated |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source is populated |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID is populated |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address is populated |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is populated |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 789 ? UA 8765 YYZ ? ORD ? SFO with claim filed for segment UA 8765 ORD ? SFO |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 1 AC 789 YYZ ? ORD is "Operated normally" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 2 UA 8765 ORD ? SFO is "DELAYED 4 hours (STAR Alliance partner � disrupted segment)" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section is present with no entries |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 789 ? UA 8765 YYZ ? ORD ? SFO |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the SOC Segment is UA 8765 ORD ? SFO |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is "UA (United Airlines � STAR Alliance)" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is "UA 8765 (STAR operated � largest delay)" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "UNKNOWN (limited STAR data available � AC cannot determine)" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 240 min (4 hours) |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "UNKNOWN � cannot determine for STAR partner" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-ND-02" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Check Order is: 1. SOC carrier check ? STAR ? No Determination |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Collection is "INITIATED (pending manual review � STAR partners may share more data than non-partner OALs)" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Agent Action Required is "Manual investigation � review with STAR partner data" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And this differs from ND-01 (non-Star OAL) because STAR partners may share more data so receipt collection is initiated proactively |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (pending manual determination)" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "N/A (pending manual determination)" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check ran automatically and result is "No duplicate found" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered (No Determination � pending manual review) |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Auto-Append shows the system appended the booking record automatically |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Agent Notes section is accessible |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log records case creation, No Determination, STAR flag, receipt collection initiated, and manual handling routing |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Customer Communications shows forwarded notification |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Chatbot transcript is accessible and linked to the case |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab is empty |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Current Status is "Assigned (Manual Review Queue � No Determination)" |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is NOT in read-only mode (agent can determine outcome after manual review) |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent cannot access Case Search (leads/management only) |  |
| CP145 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-ND-02 � STAR Alliance No Determination |  |
| CP146 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-ND-02 has No Determination |  |
| CP147 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow is triggered |  |
| CP148 | PAYMENT VALIDATION | payment | chat | And the case is created and sent to agent for manual handling |  |
| CP149 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked at chatbot stage |  |
| CP150 | PAYMENT VALIDATION | payment | chat | And no automated compensation record is created |  |
| CP151 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP152 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered at chatbot stage |  |
| CP153 | PAYMENT VALIDATION | payment | chat | And if the agent later determines eligible then the agent manually creates compensation with SOC as cash only |  |
| CP154 | PAYMENT VALIDATION | payment | chat | And a compensation record is created with GL account and cost center |  |
| CP155 | PAYMENT VALIDATION | payment | manual | And a batch file is dispatched to Unifier |  |
| CP156 | PAYMENT VALIDATION | payment | manual | And end-of-day report status tracking is initiated |  |
| CP157 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Case status = "No Determination" with no payout section until manually resolved |  |
| CP158 | EXPECTED RESULTS | verdict | chat | SoC-APPR-ND-02. | SoC-APPR-ND-02. |
| CP159 | EXPECTED RESULTS | verdict | chat | NO DETERMINATION.  on STAR Alliance partner. | NO DETERMINATION.  on STAR Alliance partner. |
| CP160 | EXPECTED RESULTS | verdict | chat | Case created for agent review. | Case created for agent review. |
| CP161 | EXPECTED RESULTS | verdict | chat | Receipt collection initiated. | Receipt collection initiated. |
