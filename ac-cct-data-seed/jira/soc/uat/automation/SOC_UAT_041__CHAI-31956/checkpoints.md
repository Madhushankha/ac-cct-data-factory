# SOC_UAT_041 · CHAI-31956 — checkpoints

**Goal:** Verify ELIGIBLE when customer stayed at origin,  delay ?2h, EU regime. Full eligible flow through receipt upload and case creation.

Methods: seed 20, chat 72, api 22, email 4, dashboard 56, implied 28, manual 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify ELIGIBLE when customer stayed at origin,  delay ?2h, EU regime. Full eligible flow through receipt upload and case creation. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: EU | � Regime: EU |
| CP003 | PREREQUISITES | prerequisite | seed | �  Carrier: AC (AC 848 LHR?YYZ) | �  Carrier: AC (AC 848 LHR?YYZ) |
| CP004 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 848 LHR?YYZ, Dep: 18-Jun 11:00, Arr: 18-Jun 15:00 | � Promised Itinerary: AC 848 LHR?YYZ, Dep: 18-Jun 11:00, Arr: 18-Jun 15:00 |
| CP005 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: Flight cancelled. Rebooked next day. Passenger stayed at origin (LHR) | � Actual Itinerary: Flight cancelled. Rebooked next day. Passenger stayed at origin (LHR) |
| CP006 | PREREQUISITES | prerequisite | seed | � Delay Length: 420 min (7 hours) | � Delay Length: 420 min (7 hours) |
| CP007 | PREREQUISITES | prerequisite | seed | � Controllability: NOT CHECKED � EU does not evaluate controllability for SOC | � Controllability: NOT CHECKED � EU does not evaluate controllability for SOC |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 77 (Weather � IRRELEVANT under EU SOC) | � Departure delay code: 77 (Weather � IRRELEVANT under EU SOC) |
| CP009 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP010 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Regular ? ? 2. No-travel delay check ? ?2h ? ELIGIBLE (no controllability check) | � Check Order: 1. Pax Type ? Regular ? ? 2. No-travel delay check ? ?2h ? ELIGIBLE (no controllability check) |
| CP011 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult | � PAX Count: 1 adult |
| CP012 | PREREQUISITES | prerequisite | seed | � Class of Booking: PY | � Class of Booking: PY |
| CP013 | PREREQUISITES | prerequisite | seed | � Revenue Booking: YES | � Revenue Booking: YES |
| CP014 | PREREQUISITES | prerequisite | seed | � ACR Issued: Hotel: No, Transport: No, Meal: No | � ACR Issued: Hotel: No, Transport: No, Meal: No |
| CP015 | PREREQUISITES | prerequisite | seed | � Journey Completed: > 72h ENTITLEMENTS (, 1 adult, PY, no ACR): | � Journey Completed: > 72h ENTITLEMENTS (, 1 adult, PY, no ACR): |
| CP016 | PREREQUISITES | prerequisite | seed | � Meals: $30/pax (converted to EUR for EU regime) | � Meals: $30/pax (converted to EUR for EU regime) |
| CP017 | PREREQUISITES | prerequisite | seed | � Hotel: Rate of day, max 3 nights, $500 cap | � Hotel: Rate of day, max 3 nights, $500 cap |
| CP018 | PREREQUISITES | prerequisite | seed | � Transport: $200 (1-5 pax) | � Transport: $200 (1-5 pax) |
| CP019 | PREREQUISITES | prerequisite | seed | � Communication: $30/pax | � Communication: $30/pax |
| CP020 | PREREQUISITES | prerequisite | seed | � Parking: $50, 1 day max | � Parking: $50, 1 day max |
| CP021 | PREREQUISITES | prerequisite | seed | � Essentials: $30/pax | � Essentials: $30/pax |
| CP022 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP023 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP024 | START | customer | chat | Then user selects English |  |
| CP025 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP026 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP027 | START | customer | chat | And the user says "My Air Canada flight from London to Toronto was delayed by about 7 hours. I had to buy food, pay for a hotel overnight, a | My Air Canada flight from London to Toronto was delayed by about 7 hours. I had to buy food, pay for a hotel overnight, and take a taxi. Can I get reimbursed fo |
| CP028 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP029 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP030 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP031 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP032 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP033 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP034 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP035 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP036 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP037 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP040 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP042 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP043 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP044 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP045 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP046 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP047 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 848 � Route: London Heathrow (LHR) ? Toronto (YYZ) � Date: June 10, 2026 � Departure Delay: 7 hours Is this the jour |
| CP048 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP049 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP050 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP052 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP053 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP054 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU SOC per departing country |  |
| CP055 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Departing country: United Kingdom ? Limitation = 2,190 days (6 years) � Days elapsed: Within limitation period ? PROCEED |
| CP056 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip LHR?YYZ on AC848 was delayed +7H 00M due to weather (uncontrollable � NOT CHECKED under EU) | Single-segment trip LHR?YYZ on AC848 was delayed +7H 00M due to weather (uncontrollable � NOT CHECKED under EU) |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: EU (LHR departure) | Regime: EU (LHR departure) |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 848, Route: LHR ? YYZ, Scheduled Dep: 18-Jun 11:00 | Promised Itinerary � Flight: AC 848, Route: LHR ? YYZ, Scheduled Dep: 18-Jun 11:00 |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 848, Route: LHR ? YYZ, Status: ARRIVED LATE, Scheduled Dep: 11:00 ? Actual: 18:00, Delay: +7H 00M | Current Itinerary � Flight: AC 848, Route: LHR ? YYZ, Status: ARRIVED LATE, Scheduled Dep: 11:00 ? Actual: 18:00, Delay: +7H 00M |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 77 (Weather) � NOT CHECKED (EU does not evaluate controllability) | Departure Delay Code: 77 (Weather) � NOT CHECKED (EU does not evaluate controllability) |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: �30.00 / ACCOMMODATION: Rate of day (max �500) / GENERAL EXPENSES | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: �30.00 / ACCOMMODATION: Rate of day (max �500) / GENERAL EXPENSES: Transport �200 + C |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: GREEN | CyberSource: GREEN |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | CRITICAL: Weather = NOT ELIGIBLE under APPR (NE-07) but ELIGIBLE under EU (EL-01) | CRITICAL: Weather = NOT ELIGIBLE under APPR (NE-07) but ELIGIBLE under EU (EL-01) |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE |
| CP073 | TRIP TRACER UI VALIDATIONS | verdict | api | Total Approved: �263.00 EUR (Hotel �170 + Meals �30 [capped] + Transport �49 + Comm �14) | Total Approved: �263.00 EUR (Hotel �170 + Meals �30 [capped] + Transport �49 + Comm �14) |
| CP074 | TRIP TRACER UI VALIDATIONS | verdict | api | Flagged Items: 1 (meals exceeded �30 threshold � agent review required) | Flagged Items: 1 (meals exceeded �30 threshold � agent review required) |
| CP075 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-EU-EL-01 | DDS RESPONSE CODE = SoC-EU-EL-01 |
| CP076 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP077 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger) |  |
| CP078 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates the claim |  |
| CP079 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) | ? PROCEED to eligible flow |
| CP080 | ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 848  | Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 848 from London to Toronto was delayed by approximat |
| CP081 | ENTITLEMENT DISPLAY | bot | chat | Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, EU regime: | "Based on the length of your disruption (7 hours), you may be eligible for reimbursement in the following categories: � Meals: up to �30.00 � Hotel accommodatio |
| CP082 | EU CURRENCY NOTE | system | implied | EU entitlements are calculated in EUR (or GBP for UK departures). | Receipts may be in any currency � Case Services handles conversion: 1. Receipt currency ? regime currency (EUR/GBP) for threshold comparison 2. Regime currency  |
| CP083 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP084 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | And the chatbot displays the receipt upload interface |  |
| CP085 | RECEIPT UPLOAD � WELCOME BACK FLOW | system | implied | And the user uploads receipt images: | � Receipt 1: Hotel receipt � �145.00 GBP (1 night near Heathrow) � Receipt 2: Meal receipt � �38.00 GBP (dinner + breakfast) � Receipt 3: Taxi receipt � �42.00  |
| CP086 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | Then the system processes uploaded receipts through OCR (Agentic Receipt Reader) |  |
| CP087 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | And the OCR engine extracts line items from each receipt: | Receipt 1 � Hotel: � Line item: Hotel stay, 1 night � �145.00 GBP � Date: June 10, 2026 � Category: Hotel � Within disruption window: YES ? � Currency conversio |
| CP088 | RECEIPT VALIDATION SUMMARY | system | implied | Then the system displays the OCR validation summary: | � Total receipts processed: 4 � Total line items extracted: 6 � Items PASSED: 5 � Items FLAGGED for agent review: 1 (meals exceed �30 threshold) � Items FAILED: |
| CP089 | AGENT REVIEW REQUIRED | system | implied | Meal total (�45) exceeds �30 threshold by �15. | Agent must decide: � Option A: Approve up to �30, reject �15 overage ? Approved meals = �30 � Option B: Approve full amount with justification (e.g., airport pr |
| CP090 | EXPENSE BREAKDOWN | system | implied | � Hotel: �145.00 / �170.00 ? | � Meals: �25.50 / �30.00 ? (capped at �30 threshold) � Transport: �42.00 / �49.00 ? � Communication: �12.00 / �14.00 ? � Parking: �0.00 / �0.00 (no receipt subm |
| CP091 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system initiates payment processing |  |
| CP092 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP093 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Germany" | Germany |
| CP094 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot responds: "Thank you for confirming. Based on the information provided, here is the total reimbursement you are eligible fo | � Hotel: �170.00 � Meals: �30.00 (capped at threshold) � Transport: �49.00 � Communication: �14.00 � Total: �263.00 EUR" |
| CP095 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot responds: "I am able to proceed to payment now. Please note that once you confirm, your reimbursement amount will be finali | I am able to proceed to payment now. Please note that once you confirm, your reimbursement amount will be finalized. Would you like to proceed? |
| CP096 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | And user responds: "Yes" |  |
| CP097 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: | � Country = Germany � Currency = EUR � Payment Method = BSM � Email Payment (EUR) � Processing Channel = HSBC � Payout currency conversion = Not required (EUR ? |
| CP098 | BSM OFFER | bot | chat | Then the chatbot responds: | Before we move forward, please confirm the email address where you'd like to receive your payment and all updates about this case. Would you like to use t***@gm |
| CP099 | BSM OFFER | bot | chat | And the chatbot displays options: | � Yes, confirm this email � Use a different email |
| CP100 | BSM OFFER | customer | chat | And the user selects "Yes, confirm this email" | Yes, confirm this email |
| CP101 | BSM OFFER | bot | chat | Then the chatbot asks: "Great, can you please confirm that we have the right phone number on the file +1***789?" | Great, can you please confirm that we have the right phone number on the file +1***789? |
| CP102 | BSM OFFER | bot | chat | And the chatbot displays options: | � Yes, confirm this phone number � Use a different phone number |
| CP103 | BSM OFFER | customer | chat | And the user selects "Yes, confirm this phone number" | Yes, confirm this phone number |
| CP104 | BSM OFFER | idv | chat | Then system checks if IDV has been done already ? No |  |
| CP105 | IDENTITY VERIFICATION � PERSONA | bot | chat | Then the chatbot responds: | Before we process your payment, we need to verify your identity. You will receive a separate link to complete identity verification through our secure partner. |
| CP106 | IDENTITY VERIFICATION � PERSONA | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP107 | IDENTITY VERIFICATION � PERSONA | customer | chat | And the customer opens the Persona link |  |
| CP108 | IDENTITY VERIFICATION � PERSONA | idv | chat | And the customer completes identity verification via Persona |  |
| CP109 | IDENTITY VERIFICATION � PERSONA | idv | chat | And Persona returns: IDV PASS |  |
| CP110 | IDENTITY VERIFICATION � PERSONA | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP111 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �263.00 EUR Payment Method: t***@gmail.com After submission, you will receive a confirmation email summarizing your eligibility, claim details a |
| CP112 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP113 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP114 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case in Case Services |  |
| CP115 | CASE CREATION (GLOB-09) | idv | chat | And the case includes: | � DDS response code: SoC-EU-EL-01 � Eligibility: ELIGIBLE � Regime: EU (EC 261/2004) � Departure country: United Kingdom � Currency: GBP (receipts) ? EUR (thres |
| CP116 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP117 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully. Here's a summary: � Case Reference: [Case Number] � Total claim amount: �263.00 EUR � Categories: Hotel (�170.00), M |
| CP118 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP119 | NOTIFICATION | email | email | And an eligible confirmation email is sent to the passenger at t***@gmail.com |  |
| CP120 | NOTIFICATION | email | email | And the email includes: | � Case reference number � Claim summary with approved amounts (EUR) � Note about meal threshold cap � Next steps for payment � Password required to access the s |
| CP121 | NOTIFICATION | email | email | And a separate email containing the secure BSM payment link is sent to t***@gmail.com |  |
| CP122 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP123 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP124 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-EU-EL-01 � EU Eligible Travel Completed Flagged Meal |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "In Progress (flagged item requires agent review)" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (Auth Flow 1) |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is NOT greyed out |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "EU (EC 261/2004)" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Regular" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 849 LHR ? YYZ as the claimed flight |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (7 hours)" |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 849 LHR ? YYZ |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 849 |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Weather (Code 77)" |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 420 min (7 hours) |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed Departure)" |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (LHR = UK origin)" |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED (EU regime � controllability irrelevant)" |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Overnight Eligible is "YES (delay >330 min)" |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the ACR Issued shows Hotel No, Transport No, Meal No |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-EU-EL-01" |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the same passenger, same flight, same disruption under APPR would be SoC-APPR-NE-07 (NOT ELIGIBLE � weather is uncontrollable) but under |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Hotel �145.00 / �170.00 APPROVED (1 night, within rate of day, <�500 cap) |  |
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Meals �38.00 / �45.00 FLAGGED (exceeds �30 threshold by �15 � agent decision required: approve up to �30, ap |  |
| CP166 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Transport �42.00 / �49.00 APPROVED (?�200) |  |
| CP167 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Communication �12.00 / �14.00 APPROVED (?�30) |  |
| CP168 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Parking �0.00 No receipt |  |
| CP169 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Essentials �0.00 No receipt |  |
| CP170 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is �263.00 EUR (after meal cap at �30) |  |
| CP171 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 1 (meals � agent decision required) |  |
| CP172 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "�263.00 EUR (EU � Suggested Highlighted)" |  |
| CP173 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And receipts are in GBP converted to EUR for threshold comparison with payout in country of residence currency |  |
| CP174 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP175 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource result is "GREEN" |  |
| CP176 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Country of Residence is "Germany" with Currency "EUR" |  |
| CP177 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Method is "BSM � Email Payment (EUR)" with Processing Channel "HSBC" |  |
| CP178 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Email is "t***@gmail.com" (confirmed, locked) |  |
| CP179 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is confirmed as "+1***789" |  |
| CP180 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no bank details / IBAN are stored on the case |  |
| CP181 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the IDV result is "Persona PASS (at Payment)" |  |
| CP182 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the secure payment link email and password email were sent to "t***@gmail.com" |  |
| CP183 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case Status is "In Progress (flagged item � NOT read-only until agent resolves meal flag)" |  |
| CP184 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-EU-EL-01 � EU Eligible Flagged Meal � BSM HSBC EUR |  |
| CP185 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-EL-01 is determined as ELIGIBLE |  |
| CP186 | PAYMENT VALIDATION | payment | chat | Then SOC payment is CASH ONLY |  |
| CP187 | PAYMENT VALIDATION | payment | chat | And AC Wallet / e-credit is NOT offered |  |
| CP188 | PAYMENT VALIDATION | payment | chat | And the route is AC 848 LHR ? YYZ with delay 420 min (7 hrs) for 1 adult PY |  |
| CP189 | PAYMENT VALIDATION | payment | chat | And receipts are in GBP with threshold comparison in EUR |  |
| CP190 | PAYMENT VALIDATION | payment | chat | And the entitlements are Meals �30, Hotel rate of day/�500 cap, Transport �200, Comm �30, Parking �50, Essentials �30 |  |
| CP191 | PAYMENT VALIDATION | payment | chat | And the approved receipts are Hotel �170, Meals �30 (capped from �45), Taxi �49, Comm �14 totalling �263.00 EUR |  |
| CP192 | PAYMENT VALIDATION | payment | chat | And the country of residence is Germany with currency EUR |  |
| CP193 | PAYMENT VALIDATION | payment | chat | And the payment method is BSM � Email Payment (EUR) processed via HSBC |  |
| CP194 | PAYMENT VALIDATION | payment | chat | And only the customer's email t***@gmail.com and phone confirmation are collected (no bank details) |  |
| CP195 | PAYMENT VALIDATION | payment | chat | And the payment email cannot be changed after confirmation |  |
| CP196 | PAYMENT VALIDATION | payment | chat | And Persona IDV returned PASS before claim submission |  |
| CP197 | PAYMENT VALIDATION | payment | chat | And no payout currency conversion is applied (EUR ? EUR) |  |
| CP198 | PAYMENT VALIDATION | payment | chat | And the Comp Status is "Pending agent review" until the meal flag is resolved |  |
| CP199 | PAYMENT VALIDATION | payment | chat | And after the agent approves the �30 cap, the Comp Status is "Sent for issuance" |  |
| CP200 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard shows �263.00 EUR, Cash, BSM (HSBC), t***@gmail.com, status via talkback |  |
| CP201 | EXPECTED RESULTS | verdict | chat | SoC-EU-EL-01. | SoC-EU-EL-01. |
| CP202 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP203 | EXPECTED RESULTS | verdict | chat | No travel (origin), delay ?2h. | No travel (origin), delay ?2h. |
| CP204 | EXPECTED RESULTS | verdict | chat | Controllability NOT checked (EU regime difference from APPR). | Controllability NOT checked (EU regime difference from APPR). |
| CP205 | EXPECTED RESULTS | verdict | chat | Eligible regardless of disruption type. | Eligible regardless of disruption type. |
| CP206 | EXPECTED RESULTS | verdict | chat | Entitlements in EUR. | Entitlements in EUR. |
| CP207 | EXPECTED RESULTS | verdict | chat | Full receipt + case flow. | Full receipt + case flow. |
