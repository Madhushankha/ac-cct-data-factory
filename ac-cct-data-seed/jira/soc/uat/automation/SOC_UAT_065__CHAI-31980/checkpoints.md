# SOC_UAT_065 · CHAI-31980 — checkpoints

**Goal:** Verify NO DETERMINATION when no Departure delay code after 14-day retrigger under ASL.

Methods: seed 12, chat 38, api 21, dashboard 30, implied 16, manual 6, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify NO DETERMINATION when no Departure delay code after 14-day retrigger under ASL. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: ASL | � Regime: ASL |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 084 TLV?VDA | � Itinerary: Single segment � AC 084 TLV?VDA |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 084 TLV?VDA | � SOC Segment (per SoC Flight Identifier): AC 084 TLV?VDA |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 084 TLV?VDA, Dep: 15-May 16:00 | � Promised Itinerary: AC 084 TLV?VDA, Dep: 15-May 16:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 084 TLV?VDA, Dep: 15-May 22:00 | � Actual Itinerary: AC 084 TLV?VDA, Dep: 15-May 22:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 360 min (6 hours) | � Departure Delay: 360 min (6 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: NONE (not populated after 14-day retrigger) | � Departure delay code: NONE (not populated after 14-day retrigger) |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Unknown � no departure delay code available; ASL doesn't check controllability for SOC anyway, but code still needed for  | � Controllability: Unknown � no departure delay code available; ASL doesn't check controllability for SOC anyway, but code still needed for audit trail |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP011 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Departure delay code check ? NONE ? No Determination | � Check Order: 1. Departure delay code check ? NONE ? No Determination |
| CP012 | PREREQUISITES | prerequisite | seed | � 14-Day RE Retrigger: Triggered and completed, still no code | � 14-Day RE Retrigger: Triggered and completed, still no code |
| CP013 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h (well beyond 14 days) | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h (well beyond 14 days) |
| CP014 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP015 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP016 | START | customer | chat | Then user selects English |  |
| CP017 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP018 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP019 | START | customer | chat | And the user says "My Air Canada flight from Tel Aviv to Eilat was significantly delayed a couple of weeks ago. I had to pay for meals and a | My Air Canada flight from Tel Aviv to Eilat was significantly delayed a couple of weeks ago. I had to pay for meals and accommodation. Can I get reimbursed? |
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
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP035 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP037 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP038 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP039 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 084 � Route: Tel Aviv (TLV) ? Eilat (VDA) � Date: May 16, 2026 � Status: Flight data incomplete � actual departure/D |
| CP040 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP041 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP042 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP044 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP045 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes (well beyond � disruption was May 16) |  |
| CP046 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for ASL SOC |  |
| CP047 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � ASL limitation: 1,460 days (4 years) � FIXED � Days elapsed: 24 days (disruption May 16, filing Jun 9) ? Within limitation period ? PROCEED |
| CP048 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Partial � operating data MISSING |  |
| CP049 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP050 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP051 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP052 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP053 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip TLV?VDA on AC084 was delayed +6H 00M � departure delay code missing after 14-day retrigger | Single-segment trip TLV?VDA on AC084 was delayed +6H 00M � departure delay code missing after 14-day retrigger |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: ASL (TLV?VDA = Israel?Israel) | Regime: ASL (TLV?VDA = Israel?Israel) |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 084, Route: TLV ? VDA, Scheduled Dep: 15-May 16:00 | Promised Itinerary � Flight: AC 084, Route: TLV ? VDA, Scheduled Dep: 15-May 16:00 |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 084, Route: TLV ? VDA, Status: ARRIVED LATE, Scheduled Dep: 16:00 ? Actual: 22:00, Delay: +6H 00M | Current Itinerary � Flight: AC 084, Route: TLV ? VDA, Status: ARRIVED LATE, Scheduled Dep: 16:00 ? Actual: 22:00, Delay: +6H 00M |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: NONE (not populated after 14-day RE retrigger) | Departure Delay Code: NONE (not populated after 14-day RE retrigger) |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | 14-Day RE Retrigger: COMPLETED � code still not populated | 14-Day RE Retrigger: COMPLETED � code still not populated |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Geographic Check: TLV?VDA = Israel?Israel ? PASSED ? | Geographic Check: TLV?VDA = Israel?Israel ? PASSED ? |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NO_DETERMINATION / BAND: DELAY_6_HOURS_OR_MORE / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � | PASSENGER: [Name] / STATUS: NO_DETERMINATION / BAND: DELAY_6_HOURS_OR_MORE / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NO DETERMINATION � case created for manual review | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NO DETERMINATION � case created for manual review |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-ASL-ND-03 | DDS RESPONSE CODE = SoC-ASL-ND-03 |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP067 | NO DETERMINATION RESULT | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight AC 084 from Tel Aviv to Eilat. Unfortunately, we are unable to determin | I've reviewed the details of your flight AC 084 from Tel Aviv to Eilat. Unfortunately, we are unable to determine your eligibility for expense reimbursement aut |
| CP068 | CASE CREATION | system | implied | Then the system creates a case for manual agent review |  |
| CP069 | CASE CREATION | system | implied | And the case is assigned to the manual review queue |  |
| CP070 | CASE CREATION | verdict | api | And the case note indicates: "ASL regime � Operating data missing (actual dep/arr times) after 14-day RE retrigger. Cannot calculate delay.  | ASL regime � Operating data missing (actual dep/arr times) after 14-day RE retrigger. Cannot calculate delay. Geographic check passed (TLV?VDA = Israel?Israel). |
| CP071 | CASE CREATION | system | implied | And the case reference number is provided to the passenger |  |
| CP072 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP073 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP074 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-ASL-ND-03 � Missing Delay Code ASL No Determination |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Assigned (Manual Review Queue)" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is "Manual Review Queue" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "ASL" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 084 TLV ? VDA as the claimed flight |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (6 hours)" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 084 TLV ? VDA |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 084 |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "UNKNOWN � no Departure delay code populated" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 360 min (6 hours) |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (TLV ? VDA = Israel ? Israel)" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT APPLICABLE (ASL doesn't check � but code still needed for validation)" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the 14-Day RE Retrigger is "COMPLETED � code still not populated" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-ASL-ND-03" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Agent Action Required is "Manually investigate disruption cause � contact operations for Departure delay code. Code needed for audit |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And all other data is available (operating times, carrier, delay calculation, geographic check) � ONLY the Departure delay code is missing |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (pending manual determination)" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Current Status is "Assigned (Manual Review Queue)" and the case is NOT in read-only mode |  |
| CP108 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-ASL-ND-03 � Missing Delay Code ASL No Determination |  |
| CP109 | PAYMENT VALIDATION | payment | chat | Given the case SoC-ASL-ND-03 has No Determination |  |
| CP110 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow is triggered |  |
| CP111 | PAYMENT VALIDATION | payment | chat | And the case is created and sent to agent for manual handling |  |
| CP112 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked at chatbot stage |  |
| CP113 | PAYMENT VALIDATION | payment | chat | And no automated compensation record is created |  |
| CP114 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP115 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered at chatbot stage |  |
| CP116 | PAYMENT VALIDATION | payment | chat | And if the agent later determines eligible then the agent manually creates compensation with SOC as cash only |  |
| CP117 | PAYMENT VALIDATION | payment | chat | And a compensation record is created with GL account and cost center |  |
| CP118 | PAYMENT VALIDATION | payment | manual | And a batch file is dispatched to Unifier |  |
| CP119 | PAYMENT VALIDATION | payment | manual | And end-of-day report status tracking is initiated |  |
| CP120 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Case status = "No Determination" with no payout section until manually resolved |  |
| CP121 | EXPECTED RESULTS | verdict | chat | SoC-ASL-ND-03. | SoC-ASL-ND-03. |
| CP122 | EXPECTED RESULTS | verdict | chat | NO DETERMINATION. | NO DETERMINATION. |
| CP123 | EXPECTED RESULTS | verdict | chat | No Departure delay code available after 14-day RE retrigger. | No Departure delay code available after 14-day RE retrigger. |
| CP124 | EXPECTED RESULTS | verdict | chat | Case created for manual review. | Case created for manual review. |
