# SOC_UAT_047 · CHAI-31962 — checkpoints

**Goal:** Verify ELIGIBLE when customer traveled to destination with transit delay ?2h under EU. Any disruption type qualifies (EU does not require controllability for SOC).

Methods: seed 13, chat 43, api 27, email 1, dashboard 40, implied 14, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify ELIGIBLE when customer traveled to destination with transit delay ?2h under EU. Any disruption type qualifies (EU does not require co |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: EU | � Regime: EU |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 837 FRA?YYZ | � Itinerary: Single segment � AC 837 FRA?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 837 FRA?YYZ | � SOC Segment (per SoC Flight Identifier): AC 837 FRA?YYZ |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 837 FRA?YYZ, Dep: 22-Jun 10:00 | � Promised Itinerary: AC 837 FRA?YYZ, Dep: 22-Jun 10:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 837 FRA?YYZ, Dep: 22-Jun 17:00 | � Actual Itinerary: AC 837 FRA?YYZ, Dep: 22-Jun 17:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 420 min (7 hours) | � Departure Delay: 420 min (7 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 77 (Weather) � Uncontrollable � NOT CHECKED under EU SOC (EU does not evaluate controllability; code present but irr | � Departure delay code: 77 (Weather) � Uncontrollable � NOT CHECKED under EU SOC (EU does not evaluate controllability; code present but irrelevant) |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: NOT CHECKED � EU does not evaluate controllability for SOC | � Controllability: NOT CHECKED � EU does not evaluate controllability for SOC |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP011 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Regular ? ? 2. Transit departure delay check ? ?2h ? ELIGIBLE (no controllability check) | � Check Order: 1. Pax Type ? Regular ? ? 2. Transit departure delay check ? ?2h ? ELIGIBLE (no controllability check) |
| CP012 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / ACR: No / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: YES / ACR: No / Journey: > 72h |
| CP013 | PREREQUISITES | prerequisite | seed | � Overnight Eligible: YES (delay >360 min) | � Overnight Eligible: YES (delay >360 min) |
| CP014 | PREREQUISITES | prerequisite | seed | � ENTITLEMENTS (, 1 adult, PY, no ACR): Meals: $30/pax (EUR equivalent) / Hotel: Rate of day, 3 nights max, $500 cap / Transport: $200 / Com | � ENTITLEMENTS (, 1 adult, PY, no ACR): Meals: $30/pax (EUR equivalent) / Hotel: Rate of day, 3 nights max, $500 cap / Transport: $200 / Communication: $30 / Pa |
| CP015 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP016 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP017 | START | customer | chat | Then user selects English |  |
| CP018 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP019 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP020 | START | customer | chat | And the user says "My Air Canada flight from Frankfurt to Toronto was delayed by about 8 hours because of a crew scheduling issue. I had to  | My Air Canada flight from Frankfurt to Toronto was delayed by about 8 hours because of a crew scheduling issue. I had to buy food, pay for a hotel, and take a t |
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
| CP040 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 837 � Route: Frankfurt (FRA) ? Toronto (YYZ) � Date: June 14, 2026 � Departure Delay: 8 hours Is this the journey yo |
| CP041 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP045 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP046 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP047 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU SOC per departing country |  |
| CP048 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Departing country: Germany ? Limitation = 1,460 days (4 years) � Days elapsed: Within limitation period ? PROCEED |
| CP049 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP050 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP051 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP052 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP053 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip FRA?YYZ on AC837 was delayed +8H 00M due to weather (uncontrollable � NOT CHECKED under EU) | Single-segment trip FRA?YYZ on AC837 was delayed +8H 00M due to weather (uncontrollable � NOT CHECKED under EU) |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: EU (FRA departure) | Regime: EU (FRA departure) |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 837, Route: FRA ? YYZ, Scheduled Dep: 22-Jun 10:00 | Promised Itinerary � Flight: AC 837, Route: FRA ? YYZ, Scheduled Dep: 22-Jun 10:00 |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 837, Route: FRA ? YYZ, Status: ARRIVED LATE, Scheduled Dep: 10:00 ? Actual: 17:00, Delay: +7H 00M (note: prer | Current Itinerary � Flight: AC 837, Route: FRA ? YYZ, Status: ARRIVED LATE, Scheduled Dep: 10:00 ? Actual: 17:00, Delay: +7H 00M (note: prereqs say 420 min/7h,  |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 77 (Weather) � NOT CHECKED (EU does not evaluate controllability) | Departure Delay Code: 77 (Weather) � NOT CHECKED (EU does not evaluate controllability) |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: �30.00 / ACCOMMODATION: Rate of day (max �500) / GENERAL EXPENSES | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: �30.00 / ACCOMMODATION: Rate of day (max �500) / GENERAL EXPENSES: Transport �200 + C |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: YELLOW ?? � Case PARKED in fraud queue | CyberSource: YELLOW ?? � Case PARKED in fraud queue |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Fraud queue: Case visible to fraud team only. Agent cannot see CyberSource result. | Fraud queue: Case visible to fraud team only. Agent cannot see CyberSource result. |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Passenger NOT informed of fraud flag � receives generic "being processed" message. | Passenger NOT informed of fraud flag � receives generic "being processed" message. |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Welcome Back email: NOT SENT (held until fraud team clears) | Welcome Back email: NOT SENT (held until fraud team clears) |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE (parked � pending fraud review) | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE (parked � pending fraud review) |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | Post-fraud-clear: If cleared ? Welcome Back email ? receipt upload ? normal flow | Post-fraud-clear: If cleared ? Welcome Back email ? receipt upload ? normal flow |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | Post-fraud-confirm: If confirmed fraud ? rejection email ? case closed | Post-fraud-confirm: If confirmed fraud ? rejection email ? case closed |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-EU-EL-07 | DDS RESPONSE CODE = SoC-EU-EL-07 |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | FRAUD SCREENING � CYBERSOURCE (GLOB-05):  YELLOW RESULT | FRAUD SCREENING � CYBERSOURCE (GLOB-05):  YELLOW RESULT |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger) |  |
| CP073 | TRIP TRACER UI VALIDATIONS | verdict | api | And CyberSource evaluates the claim |  |
| CP074 | TRIP TRACER UI VALIDATIONS | verdict | api | And CyberSource returns: YELLOW  (potential fraud indicators detected) |  |
| CP075 | CYBERSOURCE YELLOW � CASE PARKED IN FRAUD QUEUE | system | implied | � YELLOW means: suspicious but not confirmed fraud | � Case is PARKED in the CyberSource/Fraud queue � Agent CANNOT see the CyberSource result � it's invisible to them � The case appears in the fraud team's queue  |
| CP076 | WHAT THE PASSENGER SEES | bot | chat | The chatbot does NOT mention fraud. Instead, it displays a generic processing message. |  |
| CP077 | WHAT THE PASSENGER SEES | bot | chat | Then the chatbot displays: "Thank you for your patience. We've reviewed the details of your flight AC 837 from Frankfurt to Toronto and conf | Thank you for your patience. We've reviewed the details of your flight AC 837 from Frankfurt to Toronto and confirmed your eligibility for expense reimbursement |
| CP078 | WHAT HAPPENS BEHIND THE SCENES | email | email | � Case is created with ELIGIBLE status but PARKED in fraud queue | � Fraud team reviews the CyberSource indicators � If fraud team CLEARS the case: ? Welcome Back email sent to passenger ? Passenger uploads receipts ? normal fl |
| CP079 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP080 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP081 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-EU-EL-07 � EU Eligible CyberSource Yellow Fraud Queue |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "In Fraud Queue" (visible to fraud team + management ONLY; regular agents see "In Progress") |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is "Fraud Review Team" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are visible to regular agents (fraud flag is invisible to them) |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is NOT greyed out |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "EU (EC 261/2004)" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 837 FRA ? YYZ as the claimed flight |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (8 hours)" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 837 FRA ? YYZ |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 837 |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Crew Scheduling (Code 41)" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 480 min (8 hours) |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed Departure)" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (FRA = Germany, EU origin)" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED (EU regime)" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Overnight Eligible is "YES (delay >360 min)" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-EU-EL-07" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource YELLOW" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the status is "PARKED in fraud queue" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Team Action Required is: if CLEARED then send Welcome Back email then receipt upload then payment; if CONFIRMED fraud then rej |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent CANNOT see CyberSource result � invisible to regular agents |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the passenger is NOT told about fraud flag � sees generic "being processed" message |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE (pending fraud clearance)" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (pending fraud clearance � Welcome Back not yet sent)" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "N/A (pending)" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource result is "YELLOW" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case Status is "In Fraud Queue (PARKED) � visible to fraud team + management only; regular agents see In Progress" |  |
| CP125 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-EU-EL-07 � EU Eligible CyberSource Yellow Fraud Queue |  |
| CP126 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-EL-07 is PARKED in fraud queue |  |
| CP127 | PAYMENT VALIDATION | payment | chat | Then the case is awaiting fraud review |  |
| CP128 | PAYMENT VALIDATION | payment | chat | And no receipts are uploaded (Welcome Back not sent � pending fraud clearance) |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And no compensation record is created yet |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And the route is AC 837 FRA ? YYZ with delay 480 min (8 hrs) for 1 adult PY |  |
| CP131 | PAYMENT VALIDATION | payment | chat | And the entitlements if cleared are Meals �30, Hotel rate of day/�500, Transport �200, Comm �30, Parking �50, Essentials �30 |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And if the fraud team CLEARS then Welcome Back email is sent and receipt upload and normal payment flow resume with SOC as CASH ONLY |  |
| CP133 | PAYMENT VALIDATION | payment | chat | And if fraud is CONFIRMED then rejection email is sent and case is closed with no payment |  |
| CP134 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows case status as "In Fraud Queue" for fraud team and "In Progress" for regular agents |  |
| CP135 | EXPECTED RESULTS | verdict | chat | SoC-EU-EL-07. | SoC-EU-EL-07. |
| CP136 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP137 | EXPECTED RESULTS | verdict | chat | Transit delay ?2h (7 hours,  category). | Transit delay ?2h (7 hours,  category). |
| CP138 | EXPECTED RESULTS | verdict | chat | Controllability NOT checked � this is the key EU regime difference. | Controllability NOT checked � this is the key EU regime difference. |
| CP139 | EXPECTED RESULTS | verdict | chat | Same scenario under APPR with weather + regular pax = NOT ELIGIBLE (NE-07). | Same scenario under APPR with weather + regular pax = NOT ELIGIBLE (NE-07). |
| CP140 | EXPECTED RESULTS | verdict | chat | Under EU = ELIGIBLE regardless of disruption type. | Under EU = ELIGIBLE regardless of disruption type. |
| CP141 | EXPECTED RESULTS | verdict | chat | Entitlements in EUR. | Entitlements in EUR. |
| CP142 | EXPECTED RESULTS | verdict | chat | Full receipt + case flow. | Full receipt + case flow. |
