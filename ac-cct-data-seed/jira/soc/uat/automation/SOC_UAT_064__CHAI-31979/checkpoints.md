# SOC_UAT_064 · CHAI-31979 — checkpoints

**Goal:** Verify NO DETERMINATION when  operated by STAR under ASL.

Methods: seed 12, chat 41, api 21, dashboard 56, implied 18, manual 9, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify NO DETERMINATION when  operated by STAR under ASL. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: ASL | � Regime: ASL |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Multi-segment | � Itinerary: Multi-segment |
| CP004 | PREREQUISITES | prerequisite | seed | - Segment 1: AC 084 YYZ?TLV (operated normally � AC segment) | - Segment 1: AC 084 YYZ?TLV (operated normally � AC segment) |
| CP005 | PREREQUISITES | prerequisite | seed | - Segment 2: TK 789 TLV?IST (delayed 4 hours � STAR segment) | - Segment 2: TK 789 TLV?IST (delayed 4 hours � STAR segment) |
| CP006 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): TK 789 TLV?IST (Segment 2 � the STAR segment with the qualifying departure delay) | � SOC Segment (per SoC Flight Identifier): TK 789 TLV?IST (Segment 2 � the STAR segment with the qualifying departure delay) |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay on SOC Segment (Seg 2): 240 min (4 hours) | � Departure Delay on SOC Segment (Seg 2): 240 min (4 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: Unknown � STAR disruption, AC has limited data | � Departure delay code: Unknown � STAR disruption, AC has limited data |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Unknown � STAR disruption data not fully available; ASL doesn't check controllability for SOC anyway | � Controllability: Unknown � STAR disruption data not fully available; ASL doesn't check controllability for SOC anyway |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP011 | PREREQUISITES | prerequisite | seed | � Check Order: 1. SOC segment carrier check ? STAR ? No Determination | � Check Order: 1. SOC segment carrier check ? STAR ? No Determination |
| CP012 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h |
| CP013 | PREREQUISITES | prerequisite | seed | � Geographic Note: Journey destination IST (Istanbul) is NOT Israel � ASL geographic gate may also disqualify, but STAR SOC segment check tr | � Geographic Note: Journey destination IST (Istanbul) is NOT Israel � ASL geographic gate may also disqualify, but STAR SOC segment check triggered ND first |
| CP014 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP015 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP016 | START | customer | chat | Then user selects English |  |
| CP017 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP018 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP019 | START | customer | chat | And the user says "I had a connecting flight booked through Air Canada from Toronto to Istanbul through Tel Aviv. The Air Canada leg from To | I had a connecting flight booked through Air Canada from Toronto to Istanbul through Tel Aviv. The Air Canada leg from Toronto to Tel Aviv was fine, but the Tur |
| CP020 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP021 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP022 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: t***@gmail.com Phone: +1***789 |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP035 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP037 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP038 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP039 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 084 ? TK 789 Route: Toronto (YYZ) ? Tel Aviv (TLV) ? Istanbul (IST) Date: June 15, 2026 Segment 1: AC 084 YYZ?TLV � Op |
| CP040 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP041 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? Yes (2 segments) |  |
| CP042 | SEGMENT SELECTION (GenUC-18a) | bot | chat | Then the chatbot displays the segment(s) associated with the selected journey: | Which segment was affected by the disruption? Segment 1: AC 084 YYZ?TLV (Operated normally) Segment 2: TK 789 TLV?IST (Delayed � 4 hours) |
| CP043 | SEGMENT SELECTION (GenUC-18a) | customer | chat | And the user selects "Segment 2: TK 789 TLV?IST" | Segment 2: TK 789 TLV?IST |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + segment combination |  |
| CP046 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP047 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP048 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for ASL SOC |  |
| CP049 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | ASL limitation: 1,460 days (4 years) � FIXED for all origins Days elapsed: Within limitation period ? PROCEED |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP051 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP053 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | Multi-segment trip YYZ?TLV?IST � Segment 1 AC084 on time, Segment 2 TK789 (STAR) delayed +4H 00M | Multi-segment trip YYZ?TLV?IST � Segment 1 AC084 on time, Segment 2 TK789 (STAR) delayed +4H 00M |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: ASL (journey involves Israel � TLV transit) | Regime: ASL (journey involves Israel � TLV transit) |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 2 | PASSENGERS: 1 � SEGMENTS: 2 |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Seg 1: AC 084, YYZ ? TLV, Dep: 15-Jun / Seg 2: TK 789, TLV ? IST, Dep: 15-Jun | Promised Itinerary � Seg 1: AC 084, YYZ ? TLV, Dep: 15-Jun / Seg 2: TK 789, TLV ? IST, Dep: 15-Jun |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Seg 1: AC 084, YYZ ? TLV, Status: ON TIME / Seg 2: TK 789, TLV ? IST, Status: ARRIVED LATE, Delay: +4H 00M | Current Itinerary � Seg 1: AC 084, YYZ ? TLV, Status: ON TIME / Seg 2: TK 789, TLV ? IST, Status: ARRIVED LATE, Delay: +4H 00M |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present � SOC Segment: TK 789 TLV?IST (STAR) | SOC section present � SOC Segment: TK 789 TLV?IST (STAR) |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Operating Carrier: TK (Turkish Airlines � STAR Alliance) | Operating Carrier: TK (Turkish Airlines � STAR Alliance) |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: Unknown (STAR � AC has limited data) | Departure Delay Code: Unknown (STAR � AC has limited data) |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Geographic Note: YYZ?TLV?IST � ASL dual geographic gate would also fail (origin YYZ ? Israel, destination IST ? Israel), but STAR carrier ch | Geographic Note: YYZ?TLV?IST � ASL dual geographic gate would also fail (origin YYZ ? Israel, destination IST ? Israel), but STAR carrier check triggered ND fir |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NO_DETERMINATION / BAND: DELAY_2_TO_6_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NO_DETERMINATION / BAND: DELAY_2_TO_6_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Receipt collection: INITIATED (STAR partners � more cooperative data-sharing) | Receipt collection: INITIATED (STAR partners � more cooperative data-sharing) |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NO DETERMINATION � case created for manual review, receipt collection initiated | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NO DETERMINATION � case created for manual review, receipt collection initiated |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-ASL-ND-02 | DDS RESPONSE CODE = SoC-ASL-ND-02 |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC & STAR |  |
| CP070 | NO DETERMINATION RESULT | bot | chat | Then the chatbot displays: "I've reviewed the details of your journey. The disruption on your trip was caused by a delay on your Turkish Air | I've reviewed the details of your journey. The disruption on your trip was caused by a delay on your Turkish Airlines flight TK 789 from Tel Aviv to Istanbul, w |
| CP071 | RECEIPT COLLECTION INITIATED | system | implied | Then the system flags the case for potential receipt collection |  |
| CP072 | RECEIPT COLLECTION INITIATED | system | implied | And the case note indicates: "STAR partner disruption � receipt collection initiated pending manual review" |  |
| CP073 | CASE CREATION | system | implied | Then the system creates a case for agent review |  |
| CP074 | CASE CREATION | system | implied | And the case is assigned to the manual review queue |  |
| CP075 | CASE CREATION | system | implied | And the case reference number is provided to the passenger |  |
| CP076 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP077 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP078 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-ASL-ND-02 � STAR Alliance ASL No Determination |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent can edit Topic/Sub-topic but cannot switch between automated and non-automated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Assigned (Manual Review Queue)" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date is populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date is populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is "Manual Review Queue" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (identified + authenticated, Auth Flow 1) |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is greyed out / not applicable (No Determination � agent must manually assess) |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date is populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID is populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source is populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID is populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "ASL" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address is populated |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Regular" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 084 ? TK 789 YYZ ? TLV ? IST with claim filed for segment TK 789 TLV ? IST |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 1 AC 084 YYZ ? TLV is "Operated normally" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 2 TK 789 TLV ? IST is "DELAYED 4 hours (STAR Alliance partner � disrupted segment)" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section is present with no entries |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 084 ? TK 789 YYZ ? TLV ? IST |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is "TK 789 TLV ? IST (STAR Alliance partner)" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is "TK (Turkish Airlines � STAR Alliance)" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the SOC Segment is "TK 789 (STAR operated)" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "UNKNOWN (limited STAR data available � AC cannot determine)" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 240 min (4 hours) |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check shows disrupted segment origin TLV (Tel Aviv, Israel) IS Israel ? but journey destination IST (Istanbul, Turkey) is |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And ASL requires BOTH origin AND destination to be Israel |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the geographic gate may also disqualify but STAR SOC check triggered ND first |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT APPLICABLE (ASL doesn't check for SOC � but STAR data still limited)" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-ASL-ND-02" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Collection is "INITIATED (pending manual review � STAR partners may share more data than generic OALs)" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Agent Action Required is "Manual investigation � review with STAR partner data, verify delay, determine eligibility. Also verify ASL |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And this differs from ND-01 (OAL) because STAR partners have more cooperative data-sharing so receipt collection is initiated proactively an |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (pending manual determination)" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "N/A (pending manual determination)" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check ran automatically and result is "No duplicate found" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered (No Determination � pending manual review) |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Auto-Append shows the system appended the booking record automatically |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Agent Notes section is accessible |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log records case creation, No Determination, STAR flag, receipt collection initiated, manual handling routing, and geographic  |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Customer Communications shows No Determination notification sent |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Chatbot transcript is accessible and linked to the case |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab is empty (no receipts uploaded at chatbot stage) |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Current Status is "Assigned (Manual Review Queue � No Determination)" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is NOT in read-only mode (agent can determine outcome after manual review) |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent cannot access Case Search (leads/management only) |  |
| CP141 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-ASL-ND-02 � STAR Alliance ASL No Determination |  |
| CP142 | PAYMENT VALIDATION | payment | chat | Given the case SoC-ASL-ND-02 has No Determination |  |
| CP143 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow is triggered |  |
| CP144 | PAYMENT VALIDATION | payment | chat | And the case is created and sent to agent for manual handling |  |
| CP145 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked at chatbot stage |  |
| CP146 | PAYMENT VALIDATION | payment | chat | And no automated compensation record is created |  |
| CP147 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP148 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered at chatbot stage |  |
| CP149 | PAYMENT VALIDATION | payment | chat | And if the agent later determines eligible then the agent manually creates compensation with SOC as cash only |  |
| CP150 | PAYMENT VALIDATION | payment | chat | And a compensation record is created with GL account and cost center |  |
| CP151 | PAYMENT VALIDATION | payment | manual | And a batch file is dispatched to Unifier |  |
| CP152 | PAYMENT VALIDATION | payment | manual | And end-of-day report status tracking is initiated |  |
| CP153 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Case status = "No Determination" with no payout section until manually resolved |  |
| CP154 | EXPECTED RESULTS | verdict | chat | SoC-ASL-ND-02. | SoC-ASL-ND-02. |
| CP155 | EXPECTED RESULTS | verdict | chat | NO DETERMINATION.  on STAR Alliance partner. | NO DETERMINATION.  on STAR Alliance partner. |
| CP156 | EXPECTED RESULTS | verdict | chat | Case created for agent review. | Case created for agent review. |
| CP157 | EXPECTED RESULTS | verdict | chat | Receipt collection initiated. | Receipt collection initiated. |
| CP158 | EXPECTED RESULTS | verdict | chat | Dark mode review may be needed. | Dark mode review may be needed. |
