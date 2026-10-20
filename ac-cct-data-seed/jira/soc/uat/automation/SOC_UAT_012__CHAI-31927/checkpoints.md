# SOC_UAT_012 · CHAI-31927 — checkpoints

**Goal:** Verify that when segment has no departure code and RE was retriggered for 14 days, system returns NO DETERMINATION and routes to manual handling.

Methods: seed 16, chat 38, api 18, dashboard 39, implied 17, manual 6, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify that when segment has no departure code and RE was retriggered for 14 days, system returns NO DETERMINATION and routes to manual hand |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 301 YYZ?YVR | � Itinerary: Single segment � AC 301 YYZ?YVR |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 301 YYZ?YVR | � SOC Segment (per SoC Flight Identifier): AC 301 YYZ?YVR |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 301 YYZ?YVR, Dep: 15-May 08:00 | � Promised Itinerary: AC 301 YYZ?YVR, Dep: 15-May 08:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 301 YYZ?YVR, Dep: 15-May 14:00 | � Actual Itinerary: AC 301 YYZ?YVR, Dep: 15-May 14:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 360 min (6 hours) | � Departure Delay: 360 min (6 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: NONE (not populated after 14-day retrigger) | � Departure delay code: NONE (not populated after 14-day retrigger) |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Unknown � no departure delay code available | � Controllability: Unknown � no departure delay code available |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP011 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Departure delay code check ? NONE ? No Determination | � Check Order: 1. Departure delay code check ? NONE ? No Determination |
| CP012 | PREREQUISITES | prerequisite | seed | � 14-Day RE Retrigger: Triggered and completed, still no code | � 14-Day RE Retrigger: Triggered and completed, still no code |
| CP013 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult | � PAX Count: 1 adult |
| CP014 | PREREQUISITES | prerequisite | seed | � Class of Booking: PY | � Class of Booking: PY |
| CP015 | PREREQUISITES | prerequisite | seed | � Revenue Booking: YES | � Revenue Booking: YES |
| CP016 | PREREQUISITES | prerequisite | seed | � ACR Issued: N/A | � ACR Issued: N/A |
| CP017 | PREREQUISITES | prerequisite | seed | � Journey Completed: > 72h (well beyond 14 days) | � Journey Completed: > 72h (well beyond 14 days) |
| CP018 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP019 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP020 | START | customer | chat | Then user selects English |  |
| CP021 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP022 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP023 | START | customer | chat | And the user says "My Air Canada flight from Toronto to Vancouver was delayed by about 6 hours a couple of weeks ago. I had to buy meals and | My Air Canada flight from Toronto to Vancouver was delayed by about 6 hours a couple of weeks ago. I had to buy meals and pay for a hotel. Can I get reimbursed  |
| CP024 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP025 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP026 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP039 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP041 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP042 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP043 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 301 � Route: Toronto (YYZ) ? Vancouver (YVR) � Date: May 15, 2026 � Departure Delay: 6 hours Is this the journey you |
| CP044 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes (well beyond � disruption was May 15) |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR SOC per province |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Origin: YYZ (Ontario) ? Limitation = 730 days � Destination: YVR (British Columbia) ? Limitation = 1,095 days � Days elapsed: 24 days (disruption May 15, fili |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Partial � Departure delay code MISSING |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment domestic trip YYZ?YVR on AC301 was delayed +6H 00M � departure delay code missing after 14-day retrigger | Single-segment domestic trip YYZ?YVR on AC301 was delayed +6H 00M � departure delay code missing after 14-day retrigger |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 301, Route: YYZ ? YVR, Scheduled Dep: 15-May 08:00 | Promised Itinerary � Flight: AC 301, Route: YYZ ? YVR, Scheduled Dep: 15-May 08:00 |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 301, Route: YYZ ? YVR, Status: ARRIVED LATE, Scheduled Dep: 08:00 ? Actual: 14:00, Delay: +6H 00M | Current Itinerary � Flight: AC 301, Route: YYZ ? YVR, Status: ARRIVED LATE, Scheduled Dep: 08:00 ? Actual: 14:00, Delay: +6H 00M |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: NONE (not populated after 14-day RE retrigger) | Departure Delay Code: NONE (not populated after 14-day RE retrigger) |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | 14-Day RE Retrigger: COMPLETED � code still not populated | 14-Day RE Retrigger: COMPLETED � code still not populated |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NO_DETERMINATION / BAND: DELAY_6_HOURS_OR_MORE / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NO_DETERMINATION / BAND: DELAY_6_HOURS_OR_MORE / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NO DETERMINATION � case created for manual review | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NO DETERMINATION � case created for manual review |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-APPR-ND-03 | DDS RESPONSE CODE = SoC-APPR-ND-03 |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP069 | NO DETERMINATION RESULT | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight AC 301 from Toronto to Vancouver. Unfortunately, we are unable to deter | I've reviewed the details of your flight AC 301 from Toronto to Vancouver. Unfortunately, we are unable to determine your eligibility for expense reimbursement  |
| CP070 | CASE CREATION | system | implied | Then the system creates a case for manual agent review |  |
| CP071 | CASE CREATION | system | implied | And the case is assigned to the manual review queue |  |
| CP072 | CASE CREATION | system | implied | And the case note indicates: "No Departure delay code available after 14-day RE retrigger � agent investigation required" |  |
| CP073 | CASE CREATION | system | implied | And the case reference number is provided to the passenger |  |
| CP074 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP075 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP076 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-ND-03 � Missing Delay Code No Determination |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Assigned (Manual Review Queue)" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is "Manual Review Queue" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (Auth Flow 1) |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is greyed out / not applicable |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 301 YYZ ? YVR as the claimed flight |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (6 hours)" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 301 YYZ ? YVR |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 301 |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "UNKNOWN � no Departure delay code populated" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 360 min (6 hours) |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "UNKNOWN � no Departure delay code available" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the 14-Day RE Retrigger is "COMPLETED � code still not populated" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-ND-03" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Check Order is: 1. Departure delay code check ? NONE ? No Determination |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Agent Action Required is "Manually investigate disruption cause � contact operations for Departure delay code" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And all other data is available (operating times, carrier, delay calculation) � ONLY the Departure delay code is missing so controllability  |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Limitation Period Check shows Origin YYZ (Ontario) = 730 days and Destination YVR (British Columbia) = 1,095 days |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the disruption was May 15 with filing Jun 8 = 24 days which is within limitation |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (pending manual determination)" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "N/A" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Current Status is "Assigned (Manual Review Queue)" and the case is NOT in read-only mode |  |
| CP119 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-ND-03 � Missing Delay Code No Determination |  |
| CP120 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-ND-03 has No Determination |  |
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
| CP132 | EXPECTED RESULTS | verdict | chat | SoC-APPR-ND-03. | SoC-APPR-ND-03. |
| CP133 | EXPECTED RESULTS | verdict | chat | NO DETERMINATION. | NO DETERMINATION. |
| CP134 | EXPECTED RESULTS | verdict | chat | No Departure delay code available after 14-day RE retrigger. | No Departure delay code available after 14-day RE retrigger. |
| CP135 | EXPECTED RESULTS | verdict | chat | Case created for manual review. | Case created for manual review. |
