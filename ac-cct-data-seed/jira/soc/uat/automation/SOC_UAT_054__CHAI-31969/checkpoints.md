# SOC_UAT_054 · CHAI-31969 — checkpoints

**Goal:** Verify NOT ELIGIBLE when itinerary origin is not Israel under ASL.

Methods: seed 16, chat 39, api 20, dashboard 35, implied 13, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify NOT ELIGIBLE when itinerary origin is not Israel under ASL. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: EU | � Regime: EU |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 080 LHR?TLV | � Itinerary: Single segment � AC 080 LHR?TLV |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 080 LHR?TLV | � SOC Segment (per SoC Flight Identifier): AC 080 LHR?TLV |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 080 LHR?TLV, Dep: 05-Jun 21:00 | � Promised Itinerary: AC 080 LHR?TLV, Dep: 05-Jun 21:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 080 LHR?TLV, Dep: 06-Jun 03:00 | � Actual Itinerary: AC 080 LHR?TLV, Dep: 06-Jun 03:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 360 min (6 hours) | � Departure Delay: 360 min (6 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 64 (Flight Crew Shortage) � Controllable (present in flight data but never evaluated � geographic check fails first; | � Departure delay code: 64 (Flight Crew Shortage) � Controllable (present in flight data but never evaluated � geographic check fails first; ASL doesn't check c |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Controllable (Code 64) � NOT EVALUATED (geographic gate failed) | � Controllability: Controllable (Code 64) � NOT EVALUATED (geographic gate failed) |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP011 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Geographic origin check ? LHR (UK) ? NOT Israel ? NOT ELIGIBLE under ASL | � Check Order: 1. Geographic origin check ? LHR (UK) ? NOT Israel ? NOT ELIGIBLE under ASL |
| CP012 | PREREQUISITES | prerequisite | seed | � Note: ASL requires itinerary to START in Israel. LHR?TLV starts in UK | � Note: ASL requires itinerary to START in Israel. LHR?TLV starts in UK |
| CP013 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult | � PAX Count: 1 adult |
| CP014 | PREREQUISITES | prerequisite | seed | � Class of Booking: PY | � Class of Booking: PY |
| CP015 | PREREQUISITES | prerequisite | seed | � Revenue Booking: YES | � Revenue Booking: YES |
| CP016 | PREREQUISITES | prerequisite | seed | � ACR Issued: N/A | � ACR Issued: N/A |
| CP017 | PREREQUISITES | prerequisite | seed | � Journey Completed: > 72h | � Journey Completed: > 72h |
| CP018 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP019 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP020 | START | customer | chat | Then user selects English |  |
| CP021 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP022 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP023 | START | customer | chat | And the user says "My Air Canada flight from London to Tel Aviv was delayed by about 8 hours. I had to buy food and pay for a hotel overnigh | My Air Canada flight from London to Tel Aviv was delayed by about 8 hours. I had to buy food and pay for a hotel overnight. Can I get reimbursed? |
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
| CP043 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 080 � Route: London Heathrow (LHR) ? Tel Aviv (TLV) � Date: June 4, 2026 � Departure Delay: 8 hours Is this the jour |
| CP044 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for ASL SOC |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � ASL limitation: 1,460 days (4 years) � FIXED for all origins � Days elapsed: 5 days ? Within limitation period ? PROCEED |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip LHR?TLV on AC080 was delayed +6H 00M � origin NOT in Israel (LHR = UK) | Single-segment trip LHR?TLV on AC080 was delayed +6H 00M � origin NOT in Israel (LHR = UK) |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: EU (system determines � ASL does not apply, LHR departure ? EU applies) | Regime: EU (system determines � ASL does not apply, LHR departure ? EU applies) |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 080, Route: LHR ? TLV, Scheduled Dep: 05-Jun 21:00 | Promised Itinerary � Flight: AC 080, Route: LHR ? TLV, Scheduled Dep: 05-Jun 21:00 |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 080, Route: LHR ? TLV, Status: ARRIVED LATE, Scheduled Dep: 21:00 ? Actual: 06-Jun 03:00, Delay: +6H 00M | Current Itinerary � Flight: AC 080, Route: LHR ? TLV, Status: ARRIVED LATE, Scheduled Dep: 21:00 ? Actual: 06-Jun 03:00, Delay: +6H 00M |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Geographic Check (ASL): Origin = LHR (UK) � NOT Israel ? ASL does NOT apply | Geographic Check (ASL): Origin = LHR (UK) � NOT Israel ? ASL does NOT apply |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Destination = TLV (Israel) � PASS ? but origin fails ? ASL FAIL | Destination = TLV (Israel) � PASS ? but origin fails ? ASL FAIL |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime applied: EU (LHR = UK departure ? EU/UK261 applies) | Regime applied: EU (LHR = UK departure ? EU/UK261 applies) |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: depends on regime routing (ELIGIBLE under EU � controllability not checked / NOT_ELIGIBLE if evaluated under ASL | PASSENGER: [Name] / STATUS: depends on regime routing (ELIGIBLE under EU � controllability not checked / NOT_ELIGIBLE if evaluated under ASL only � geographic f |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: depends on regime routing | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: depends on regime routing |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-ASL-NE-06 | DDS RESPONSE CODE = SoC-ASL-NE-06 |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP071 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. Your flight AC 080 departed from London (United Kingdom), which is out | I've reviewed the details of your flight. Your flight AC 080 departed from London (United Kingdom), which is outside Israel. Under the applicable Israeli aviati |
| CP072 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP073 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP074 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP075 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP076 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-ASL-NE-06 � Origin Not Israel ASL Not Eligible |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "EU" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 080 LHR ? TLV as the claimed flight |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (8 hours)" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 080 LHR ? TLV |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 080 |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "N/A (not evaluated � geographic check failed)" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 480 min (8 hours) |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "FAILED" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Origin is "LHR (London, UK) � NOT Israel" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Destination is "TLV (Tel Aviv, Israel) � IS Israel ?" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And ASL requires BOTH origin AND destination to be Israel so the check FAILS |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT EVALUATED (geographic gate failed)" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-ASL-NE-06" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime Note is "May be eligible under EU instead (LHR = UK departure)" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And APPR has NO geographic check, EU has Origin check ONLY (must depart from EU/EEA/UK), and ASL requires BOTH origin AND destination to be  |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP114 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-ASL-NE-06 � Origin Not Israel ASL Not Eligible |  |
| CP115 | PAYMENT VALIDATION | payment | chat | Given the case SoC-ASL-NE-06 is determined as NOT ELIGIBLE |  |
| CP116 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP117 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP118 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP119 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP120 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP121 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP122 | EXPECTED RESULTS | verdict | chat | SoC-ASL-NE-06. | SoC-ASL-NE-06. |
| CP123 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP124 | EXPECTED RESULTS | verdict | chat | Itinerary originated from YYZ (Canada), not from Israel. | Itinerary originated from YYZ (Canada), not from Israel. |
| CP125 | EXPECTED RESULTS | verdict | chat | ASL regime requires Israel origin. | ASL regime requires Israel origin. |
| CP126 | EXPECTED RESULTS | verdict | chat | No receipt upload. | No receipt upload. |
| CP127 | EXPECTED RESULTS | verdict | chat | No case creation. | No case creation. |
