# SOC_UAT_010 · CHAI-31925 — checkpoints

**Goal:** Verify that when the segment was operated by an OAL carrier, the system returns NO DETERMINATION

Methods: seed 22, chat 44, api 21, dashboard 52, implied 14, manual 9, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify that when the segment was operated by an OAL carrier, the system returns NO DETERMINATION |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Multi-segment | � Itinerary: Multi-segment |
| CP004 | PREREQUISITES | prerequisite | seed | - Segment 1: AC 845 YYZ?FRA, Dep: 10-Jun 08:00 (operated normally � AC segment) | - Segment 1: AC 845 YYZ?FRA, Dep: 10-Jun 08:00 (operated normally � AC segment) |
| CP005 | PREREQUISITES | prerequisite | seed | - Segment 2: LH 470 FRA?MUC, Dep: 10-Jun 14:00 (delayed 5 hours � OAL segment) | - Segment 2: LH 470 FRA?MUC, Dep: 10-Jun 14:00 (delayed 5 hours � OAL segment) |
| CP006 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): LH 470 FRA?MUC (Segment 2 � the OAL segment with the qualifying departure delay) | � SOC Segment (per SoC Flight Identifier): LH 470 FRA?MUC (Segment 2 � the OAL segment with the qualifying departure delay) |
| CP007 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: | � Promised Itinerary: |
| CP008 | PREREQUISITES | prerequisite | seed | - Seg 1: AC 845 YYZ?FRA, Dep: 10-Jun 08:00 | - Seg 1: AC 845 YYZ?FRA, Dep: 10-Jun 08:00 |
| CP009 | PREREQUISITES | prerequisite | seed | - Seg 2: LH 470 FRA?MUC, Dep: 10-Jun 14:00 | - Seg 2: LH 470 FRA?MUC, Dep: 10-Jun 14:00 |
| CP010 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: | � Actual Itinerary: |
| CP011 | PREREQUISITES | prerequisite | seed | - Seg 1: AC 845 YYZ?FRA, Dep: 10-Jun 08:00 (on time) | - Seg 1: AC 845 YYZ?FRA, Dep: 10-Jun 08:00 (on time) |
| CP012 | PREREQUISITES | prerequisite | seed | - Seg 2: LH 470 FRA?MUC, Dep: 10-Jun 19:00 (5h departure delay) | - Seg 2: LH 470 FRA?MUC, Dep: 10-Jun 19:00 (5h departure delay) |
| CP013 | PREREQUISITES | prerequisite | seed | � Departure Delay on SOC Segment (Seg 2): 300 min (5 hours) | � Departure Delay on SOC Segment (Seg 2): 300 min (5 hours) |
| CP014 | PREREQUISITES | prerequisite | seed | � Departure delay code: Unknown � OAL disruption, AC cannot determine | � Departure delay code: Unknown � OAL disruption, AC cannot determine |
| CP015 | PREREQUISITES | prerequisite | seed | � Controllability: Unknown � OAL disruption data not available to AC | � Controllability: Unknown � OAL disruption data not available to AC |
| CP016 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP017 | PREREQUISITES | prerequisite | seed | � Check Order: 1. SOC segment carrier check ? OAL ? No Determination | � Check Order: 1. SOC segment carrier check ? OAL ? No Determination |
| CP018 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult | � PAX Count: 1 adult |
| CP019 | PREREQUISITES | prerequisite | seed | � Class of Booking: PY | � Class of Booking: PY |
| CP020 | PREREQUISITES | prerequisite | seed | � Revenue Booking: YES | � Revenue Booking: YES |
| CP021 | PREREQUISITES | prerequisite | seed | � ACR Issued: N/A | � ACR Issued: N/A |
| CP022 | PREREQUISITES | prerequisite | seed | � Journey Completed: > 72h | � Journey Completed: > 72h |
| CP023 | PREREQUISITES | prerequisite | seed | � OAL Testing Note: Cannot simulate OAL delays in test environment | � OAL Testing Note: Cannot simulate OAL delays in test environment |
| CP024 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP025 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP026 | START | customer | chat | Then user selects English |  |
| CP027 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP028 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP029 | START | customer | chat | And the user says "I had a connecting flight booked through Air Canada. The first leg on Air Canada was fine, but the second leg operated by | I had a connecting flight booked through Air Canada. The first leg on Air Canada was fine, but the second leg operated by Lufthansa was delayed by 5 hours. I ha |
| CP030 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP031 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP032 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP033 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP034 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable." | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP035 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP036 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, [First Name]! And, what is your booking reference number?" | Thanks, [First Name]! And, what is your booking reference number? |
| CP037 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP038 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP039 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP040 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP042 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP043 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP044 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP045 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP046 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP047 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP048 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP049 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP050 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP051 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP052 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � [First Name] [Last Name] (Adult) Is this who you'd like to include? |
| CP053 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP054 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP055 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 845 ? LH 470 � Route: Toronto (YYZ) ? Frankfurt (FRA) ? Munich (MUC) � Date: June 10, 2026 � Segment 1: AC 845 YYZ?F |
| CP056 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP057 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? Yes (2 segments) |  |
| CP058 | SEGMENT SELECTION (GenUC-18a) | bot | chat | Then the chatbot displays the segment(s) associated with the selected journey: | Which segment was affected by the disruption? � Segment 1: AC 845 YYZ?FRA (Operated normally) � Segment 2: LH 470 FRA?MUC (Delayed � 5 hours) |
| CP059 | SEGMENT SELECTION (GenUC-18a) | customer | chat | And the user selects "Segment 2: LH 470 FRA?MUC" | Segment 2: LH 470 FRA?MUC |
| CP060 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP061 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + segment combination |  |
| CP062 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected departure time of the last segment ? Yes |  |
| CP063 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP064 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR SOC per province |  |
| CP065 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Origin: YYZ (Ontario) ? Limitation = 730 days � Days elapsed: Within limitation period ? PROCEED |
| CP066 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP067 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP068 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | Multi-segment trip YYZ?FRA?MUC � Segment 1 AC845 on time, Segment 2 LH470 (OAL) delayed +5H 00M | Multi-segment trip YYZ?FRA?MUC � Segment 1 AC845 on time, Segment 2 LH470 (OAL) delayed +5H 00M |
| CP073 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 2 | PASSENGERS: 1 � SEGMENTS: 2 |
| CP074 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Seg 1: AC 845, YYZ ? FRA, Dep: 10-Jun 08:00 / Seg 2: LH 470, FRA ? MUC, Dep: 10-Jun 14:00 | Promised Itinerary � Seg 1: AC 845, YYZ ? FRA, Dep: 10-Jun 08:00 / Seg 2: LH 470, FRA ? MUC, Dep: 10-Jun 14:00 |
| CP075 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Seg 1: AC 845, YYZ ? FRA, Status: ON TIME / Seg 2: LH 470, FRA ? MUC, Status: ARRIVED LATE, Scheduled Dep: 14:00 ? Actua | Current Itinerary � Seg 1: AC 845, YYZ ? FRA, Status: ON TIME / Seg 2: LH 470, FRA ? MUC, Status: ARRIVED LATE, Scheduled Dep: 14:00 ? Actual: 19:00, Delay: +5H |
| CP076 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present � SOC Segment: LH 470 FRA?MUC (OAL) | SOC section present � SOC Segment: LH 470 FRA?MUC (OAL) |
| CP077 | TRIP TRACER UI VALIDATIONS | verdict | api | Operating Carrier: LH (Lufthansa � OAL) | Operating Carrier: LH (Lufthansa � OAL) |
| CP078 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: Unknown (OAL � AC has no data) | Departure Delay Code: Unknown (OAL � AC has no data) |
| CP079 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NO_DETERMINATION / BAND: DELAY_2_TO_6_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NO_DETERMINATION / BAND: DELAY_2_TO_6_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP080 | TRIP TRACER UI VALIDATIONS | verdict | api | NO_DETERMINATION reason: OAL-operated SOC segment � AC cannot determine controllability | NO_DETERMINATION reason: OAL-operated SOC segment � AC cannot determine controllability |
| CP081 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NO DETERMINATION (or redirected to OAL) | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NO DETERMINATION (or redirected to OAL) |
| CP082 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-APPR-ND-01 | DDS RESPONSE CODE = SoC-APPR-ND-01 |
| CP083 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC & OAL |  |
| CP084 | NO DETERMINATION RESULT | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight and we confirm that this flight was operated by lufthansa. Please reach | I've reviewed the details of your flight and we confirm that this flight was operated by lufthansa. Please reach out to Lufthansa for any claim related request. |
| CP085 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP086 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP087 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-ND-01 � OAL Segment No Determination |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent can edit Topic/Sub-topic but cannot switch between automated and non-automated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Pending Agent Review (No Determination � sent to OAL)" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date is populated |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date is populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is "Manual Handling Queue" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (identified + authenticated, Auth Flow 1) |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is greyed out / not applicable (No Determination � agent must manually assess) |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Adult" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date is populated |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID is populated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source is populated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID is populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address is populated |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is populated |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 845 YYZ ? FRA ? MUC with claim filed for segment LH 470 FRA ? MUC |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 1 AC 845 YYZ ? FRA is "Operated normally (NOT the disrupted segment)" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 2 LH 470 FRA ? MUC is "DELAYED 5 hours (OAL � Lufthansa � disrupted segment)" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section is present with no entries |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 845 ? LH 470 YYZ ? FRA ? MUC |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is "LH 470 FRA ? MUC (OAL segment)" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is "OAL (Lufthansa � LH)" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Unknown � OAL disruption, AC cannot determine" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 300 min (5 hours) on OAL segment |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travel Completed" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "Unknown � OAL disruption data not available to AC" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-ND-01" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Check Order is: 1. SOC carrier check ? OAL ? No Determination |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And AC cannot determine eligibility because the disruption occurred on an OAL segment and AC does not have access to Lufthansa's departure d |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached � No Determination)" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "N/A" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check ran automatically and result is "No duplicate found" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered (No Determination � pending manual review) |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Auto-Append shows the system appended the booking record automatically |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is not applicable (No Determination � case already routed to manual handling) |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Agent Notes section is accessible |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log records case creation, No Determination, OAL flag, and manual handling routing |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Customer Communications shows forwarded notification |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Chatbot transcript is accessible and linked to the case |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab is empty |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Current Status is "Pending Agent Review (No Determination)" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is NOT in read-only mode (agent can determine outcome after manual review) |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent cannot access Case Search (leads/management only) |  |
| CP146 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-ND-01 � OAL Segment No Determination |  |
| CP147 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-ND-01 has No Determination |  |
| CP148 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow is triggered |  |
| CP149 | PAYMENT VALIDATION | payment | chat | And the case is created and sent to agent for manual handling |  |
| CP150 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked at chatbot stage |  |
| CP151 | PAYMENT VALIDATION | payment | chat | And no automated compensation record is created |  |
| CP152 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP153 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered at chatbot stage |  |
| CP154 | PAYMENT VALIDATION | payment | chat | And if the agent later determines eligible then the agent manually creates compensation with SOC as cash only |  |
| CP155 | PAYMENT VALIDATION | payment | chat | And a compensation record is created with GL account and cost center |  |
| CP156 | PAYMENT VALIDATION | payment | manual | And a batch file is dispatched to Unifier |  |
| CP157 | PAYMENT VALIDATION | payment | manual | And end-of-day report status tracking is initiated |  |
| CP158 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Case status = "No Determination" with no payout section until manually resolved |  |
| CP159 | EXPECTED RESULTS | verdict | chat | SoC-APPR-ND-01. | SoC-APPR-ND-01. |
| CP160 | EXPECTED RESULTS | verdict | chat | NO DETERMINATION.  on OAL � AC cannot determine eligibility. | NO DETERMINATION.  on OAL � AC cannot determine eligibility. |
| CP161 | EXPECTED RESULTS | verdict | chat | Passenger redirected to OAL. | Passenger redirected to OAL. |
| CP162 | EXPECTED RESULTS | verdict | chat | Case created for manual agent handling. | Case created for manual agent handling. |
| CP163 | EXPECTED RESULTS | verdict | chat | Dark mode review may be needed for QA validation. | Dark mode review may be needed for QA validation. |
