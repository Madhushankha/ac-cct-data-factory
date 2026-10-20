# SOC_UAT_031 · CHAI-31946 — checkpoints

**Goal:** Verify NOT ELIGIBLE when itinerary origin is outside UK.

Methods: seed 12, chat 39, api 19, dashboard 52, implied 15, manual 6, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify NOT ELIGIBLE when itinerary origin is outside UK. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: EU (UK application) | � Regime: EU (UK application) |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 855 YUL?LHR | � Itinerary: Single segment � AC 855 YUL?LHR |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 855 YUL?LHR | � SOC Segment (per SoC Flight Identifier): AC 855 YUL?LHR |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 855 YUL?LHR, Dep: 06-Jun 20:00 | � Promised Itinerary: AC 855 YUL?LHR, Dep: 06-Jun 20:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 855 YUL?LHR, Dep: 07-Jun 02:00 | � Actual Itinerary: AC 855 YUL?LHR, Dep: 07-Jun 02:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 360 min (6 hours) | � Departure Delay: 360 min (6 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 64 (Flight Crew Shortage) � Controllable | � Departure delay code: 64 (Flight Crew Shortage) � Controllable |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Controllable (Code 64) � NOT EVALUATED (geographic check fails first; EU doesn't check controllability for SOC anyway) | � Controllability: Controllable (Code 64) � NOT EVALUATED (geographic check fails first; EU doesn't check controllability for SOC anyway) |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP011 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Geographic origin check ? YUL (Canada) ? NOT in UK ? NOT ELIGIBLE under UK regime | � Check Order: 1. Geographic origin check ? YUL (Canada) ? NOT in UK ? NOT ELIGIBLE under UK regime |
| CP012 | PREREQUISITES | prerequisite | seed | � Note: UK regime requires itinerary to originate from UK. YUL?LHR starts in Canada | � Note: UK regime requires itinerary to originate from UK. YUL?LHR starts in Canada |
| CP013 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h |
| CP014 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP015 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP016 | START | customer | chat | Then user selects English |  |
| CP017 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP018 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP019 | START | customer | chat | And the user says "My flight from Montreal to London was delayed by about 7 hours. I had to buy food and stay overnight at a hotel. Can I ge | My flight from Montreal to London was delayed by about 7 hours. I had to buy food and stay overnight at a hotel. Can I get reimbursed? |
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
| CP039 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 855 � Route: Montreal (YUL) ? London Heathrow (LHR) � Date: June 5, 2026 � Departure Delay: 7 hours Is this the jour |
| CP040 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP041 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP042 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP044 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP045 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP046 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU SOC per departing country |  |
| CP047 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Departing country: Canada ? Limitation = 730 days (2 years) � Days elapsed: Within limitation period ? PROCEED |
| CP048 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP049 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP050 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP051 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP052 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP053 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip YUL?LHR on AC855 was delayed +6H 00M � origin NOT in UK (YUL = Canada) | Single-segment trip YUL?LHR on AC855 was delayed +6H 00M � origin NOT in UK (YUL = Canada) |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: APPR (system determines � UK/EU does not apply to non-UK/EU departures) | Regime: APPR (system determines � UK/EU does not apply to non-UK/EU departures) |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 855, Route: YUL ? LHR, Scheduled Dep: 06-Jun 20:00 | Promised Itinerary � Flight: AC 855, Route: YUL ? LHR, Scheduled Dep: 06-Jun 20:00 |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 855, Route: YUL ? LHR, Status: ARRIVED LATE, Scheduled Dep: 20:00 ? Actual: 07-Jun 02:00, Delay: +6H 00M | Current Itinerary � Flight: AC 855, Route: YUL ? LHR, Status: ARRIVED LATE, Scheduled Dep: 20:00 ? Actual: 07-Jun 02:00, Delay: +6H 00M |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Geographic Check: Origin = YUL (Canada) � NOT UK ? UK regime does NOT apply | Geographic Check: Origin = YUL (Canada) � NOT UK ? UK regime does NOT apply |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime applied: APPR (system routes to applicable regime) | Regime applied: APPR (system routes to applicable regime) |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 64 (Flight Crew Shortage) � Controllable | Departure Delay Code: 64 (Flight Crew Shortage) � Controllable |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: depends on regime routing (ELIGIBLE under APPR � controllable ?2h / NOT_ELIGIBLE if evaluated under EU/UK only � | PASSENGER: [Name] / STATUS: depends on regime routing (ELIGIBLE under APPR � controllable ?2h / NOT_ELIGIBLE if evaluated under EU/UK only � geographic fail) |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: depends on regime routing | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: depends on regime routing |
| CP065 | GEOGRAPHIC ORIGIN CHECK � UK-SPECIFIC TEST | verdict | api | � EU regime geographic check: | - Origin airport: YUL (Montreal, Canada) - Origin country: CANADA - Is Canada an EU/EEA member state? ? NO - Is Canada the United Kingdom? ? NO - Result: ITINER |
| CP066 | WHY SEPARATE FROM NE-06 | system | implied | After Brexit, the UK has its own version of EU261 (UK261 / "Retained EU Law"). | The system needs to check BOTH: - NE-06: Did the flight start in the EU/EEA? ? NO - NE-07: Did the flight start in the UK? ? NO These are separate checks becaus |
| CP067 | WHY SEPARATE FROM NE-06 | system | implied | Then the chatbot checks which airline company is it ? AC |  |
| CP068 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. Your flight AC 855 departed from Montreal (Canada), which is outside t | I've reviewed the details of your flight. Your flight AC 855 departed from Montreal (Canada), which is outside the United Kingdom. Under UK aviation regulations |
| CP069 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP070 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP071 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP072 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP073 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-EU-NE-07 � UK Geographic Gate Failed Not Eligible |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent can edit Topic/Sub-topic but cannot switch between automated and non-automated |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date is populated |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date is populated |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (identified + authenticated, Auth Flow 1) |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is NOT greyed out |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date is populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID is populated |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source is populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID is populated |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "EU (UK-specific check)" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address is populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Regular" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 855 YUL ? LHR as the claimed flight |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (7 hours)" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section is present with no entries |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 855 YUL ? LHR |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 855 |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "N/A (not evaluated � geographic check failed)" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 420 min (7 hours) |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Origin Check (UK) is "FAILED" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Origin is "YUL (Montreal, Canada) � NOT UK" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Destination is "LHR (London, UK) � UK ? (but origin matters for non-UK carriers)" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Origin Check (EU) is "Also FAILED (Canada is NOT EU/EEA)" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT EVALUATED (geographic gate failed)" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Departure delay code is "64 (Flight Crew Shortage) � Controllable (present in flight data but never evaluated)" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-EU-NE-07" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime Note is "May be eligible under APPR instead (Canadian departure)" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And this is separate from NE-06 because after Brexit UK has its own version of EU261 (UK261 / Retained EU Law) so NE-06 tests the EU gate an |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And YUL ? LHR fails BOTH gates because Canada is neither EU nor UK |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "N/A" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility on Claims Dashboard is "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent cannot access Case Search (leads/management only) |  |
| CP131 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-EU-NE-07 � UK Geographic Gate Failed Not Eligible |  |
| CP132 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-NE-07 is determined as NOT ELIGIBLE |  |
| CP133 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP134 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP135 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP136 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP138 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP139 | EXPECTED RESULTS | verdict | chat | SoC-EU-NE-07. | SoC-EU-NE-07. |
| CP140 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP141 | EXPECTED RESULTS | verdict | chat | Itinerary originated from YUL (Canada), not from UK. | Itinerary originated from YUL (Canada), not from UK. |
| CP142 | EXPECTED RESULTS | verdict | chat | UK regime requires UK origin. | UK regime requires UK origin. |
| CP143 | EXPECTED RESULTS | verdict | chat | No receipt upload. | No receipt upload. |
| CP144 | EXPECTED RESULTS | verdict | chat | No case creation. | No case creation. |
