# SOC_UAT_046 · CHAI-31961 — checkpoints

**Goal:** Verify ELIGIBLE when customer at mid-point,  cancelled, EU.

Methods: seed 16, chat 69, api 22, email 4, dashboard 67, implied 24, manual 6, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify ELIGIBLE when customer at mid-point,  cancelled, EU. |  |
| CP002 | PREREQUISITES | prerequisite | seed | Regime: EU | Regime: EU |
| CP003 | PREREQUISITES | prerequisite | seed | Carrier: AC (AC 858 LHR?YVR via YYZ) | Carrier: AC (AC 858 LHR?YVR via YYZ) |
| CP004 | PREREQUISITES | prerequisite | seed | Promised Itinerary: AC 858 LHR?YYZ, then AC 859 YYZ?YVR | Promised Itinerary: AC 858 LHR?YYZ, then AC 859 YYZ?YVR |
| CP005 | PREREQUISITES | prerequisite | seed | Actual Itinerary: AC 858 completed. AC 859 cancelled. Stranded at YYZ. Rebooked next day | Actual Itinerary: AC 858 completed. AC 859 cancelled. Stranded at YYZ. Rebooked next day |
| CP006 | PREREQUISITES | prerequisite | seed | Delay Length: 840 min (14 hours) | Delay Length: 840 min (14 hours) |
| CP007 | PREREQUISITES | prerequisite | seed | Controllability: NOT CHECKED | Controllability: NOT CHECKED |
| CP008 | PREREQUISITES | prerequisite | seed | EU regime | EU regime |
| CP009 | PREREQUISITES | prerequisite | seed | Departure delay code: Flight cancelled (IRRELEVANT under EU SOC) | Departure delay code: Flight cancelled (IRRELEVANT under EU SOC) |
| CP010 | PREREQUISITES | prerequisite | seed | Passenger Type: Regular | Passenger Type: Regular |
| CP011 | PREREQUISITES | prerequisite | seed | Check Order: 1. Pax Type ? Regular ? ? 2. No-travel check ? Flight cancelled ? ELIGIBLE | Check Order: 1. Pax Type ? Regular ? ? 2. No-travel check ? Flight cancelled ? ELIGIBLE |
| CP012 | PREREQUISITES | prerequisite | seed | PAX Count: 1 adult | PAX Count: 1 adult |
| CP013 | PREREQUISITES | prerequisite | seed | Class of Booking: PY | Class of Booking: PY |
| CP014 | PREREQUISITES | prerequisite | seed | Revenue Booking: YES | Revenue Booking: YES |
| CP015 | PREREQUISITES | prerequisite | seed | ACR Issued: Hotel: No, Transport: No, Meal: No | ACR Issued: Hotel: No, Transport: No, Meal: No |
| CP016 | PREREQUISITES | prerequisite | seed | Journey Completed: > 72h ENTITLEMENTS (, 1 adult, PY, no ACR): | Journey Completed: > 72h ENTITLEMENTS (, 1 adult, PY, no ACR): |
| CP017 | PREREQUISITES | prerequisite | seed | Meals: $60 / Hotel: Rate of day, 3 nights max, $500 cap / Transport: $200 / Communication: $30 / Parking: $50 / Essentials: $30 | Meals: $60 / Hotel: Rate of day, 3 nights max, $500 cap / Transport: $200 / Communication: $30 / Parking: $50 / Essentials: $30 |
| CP018 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP019 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP020 | START | customer | chat | Then user selects English |  |
| CP021 | START | alert | chat | Then an alert information is displayed ""Please note that by using this service, you will interact with an automated chatbot which uses AI t | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP022 | START | bot | chat | Then chatbot asks ""How can I help you today?"" | How can I help you today? |
| CP023 | START | customer | chat | And the user says ""I was on a connecting flight from London to Vancouver through Toronto. My first leg from London to Toronto was fine, but | I was on a connecting flight from London to Vancouver through Toronto. My first leg from London to Toronto was fine, but my second leg from Toronto to Vancouver |
| CP024 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP025 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP026 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides ""[First Name] [Last Name]"" | [First Name] [Last Name] |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides ""PNR: [PNR Code]"" | PNR: [PNR Code] |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: t***@gmail.com Phone: +1***789 |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects ""Email: t***@gmail.com"" | Email: t***@gmail.com |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code ""546879"" | 546879 |
| CP039 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP041 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP042 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP043 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 858 ? AC 859 Route: London Heathrow (LHR) ? Toronto (YYZ) ? Vancouver (YVR) Date: June 22, 2026 Segment 1: AC 858 LHR? |
| CP044 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms ""Yes"" | Yes |
| CP045 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? Yes (2 segments) |  |
| CP046 | SEGMENT SELECTION (GenUC-18a) | bot | chat | Then the chatbot displays the segment(s) associated with the selected journey: | Which segment was affected by the disruption? Segment 1: AC 858 LHR?YYZ (Operated normally) Segment 2: AC 859 YYZ?YVR (Cancelled) |
| CP047 | SEGMENT SELECTION (GenUC-18a) | customer | chat | And the user selects ""Segment 2: AC 859 YYZ?YVR"" | Segment 2: AC 859 YYZ?YVR |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + segment combination |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP051 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU SOC per departing country |  |
| CP053 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | Departing country (of journey origin): United Kingdom ? Limitation = 2,190 days (6 years) Days elapsed: Within limitation period ? PROCEED |
| CP054 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Not Completed, Disruption Detected | Trip Not Completed, Disruption Detected |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Multi-segment trip LHR?YYZ?YVR � Segment 1 AC858 on time, Segment 2 AC859 YYZ?YVR cancelled. Passenger stranded at YYZ for 14 hours. | Multi-segment trip LHR?YYZ?YVR � Segment 1 AC858 on time, Segment 2 AC859 YYZ?YVR cancelled. Passenger stranded at YYZ for 14 hours. |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: EU (LHR departure � journey origin) | Regime: EU (LHR departure � journey origin) |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 2 | PASSENGERS: 1 � SEGMENTS: 2 |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Seg 1: AC 858, LHR ? YYZ, Dep: 22-Jun / Seg 2: AC 859, YYZ ? YVR | Promised Itinerary � Seg 1: AC 858, LHR ? YYZ, Dep: 22-Jun / Seg 2: AC 859, YYZ ? YVR |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Seg 1: AC 858, LHR ? YYZ, Status: ON TIME / Seg 2: AC 859, YYZ ? YVR, Status: CANCELLED � Rebooked next day | Current Itinerary � Seg 1: AC 858, LHR ? YYZ, Status: ON TIME / Seg 2: AC 859, YYZ ? YVR, Status: CANCELLED � Rebooked next day |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present � SOC Segment: AC 859 YYZ?YVR | SOC section present � SOC Segment: AC 859 YYZ?YVR |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Cancellation: YES ? / SOC Segment Delay: 840 min (14h) ? ?2h ? | Cancellation: YES ? / SOC Segment Delay: 840 min (14h) ? ?2h ? |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Controllability: NOT CHECKED (EU regime) | Controllability: NOT CHECKED (EU regime) |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: �60.00 / ACCOMMODATION: Rate of day (max �500) / GENERAL EXPENSES | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: �60.00 / ACCOMMODATION: Rate of day (max �500) / GENERAL EXPENSES: Transport �200 + C |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: GREEN | CyberSource: GREEN |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | Currency note: Receipts in CAD (stranded at YYZ) ? EUR threshold comparison ? country of residence payout | Currency note: Receipts in CAD (stranded at YYZ) ? EUR threshold comparison ? country of residence payout |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | Total Approved: ~�211.00 EUR (Hotel $185 CAD/~�120 + Meals $52 CAD/~�34 + Transport $60 CAD/~�39 + Essentials $28 CAD/~�18) | Total Approved: ~�211.00 EUR (Hotel $185 CAD/~�120 + Meals $52 CAD/~�34 + Transport $60 CAD/~�39 + Essentials $28 CAD/~�18) |
| CP073 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-EU-EL-06 | DDS RESPONSE CODE = SoC-EU-EL-06 |
| CP074 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP075 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening (behind the scenes) |  |
| CP076 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) | ? PROCEED to eligible flow |
| CP077 | ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: ""Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your connecting fl | Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your connecting flight AC 859 from Toronto to Vancouver was cancell |
| CP078 | ENTITLEMENT DISPLAY | bot | chat | Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, no ACR: | Based on the length of your disruption (14 hours), you may be eligible for reimbursement in the following categories: Meals: up to $60.00 Hotel accommodation: R |
| CP079 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP080 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | And the chatbot displays the receipt upload interface |  |
| CP081 | RECEIPT UPLOAD � WELCOME BACK FLOW | system | implied | And the user uploads receipt images: | Receipt 1: Hotel receipt � $185.00 CAD (1 night near YYZ) Receipt 2: Meal receipt � $52.00 CAD (dinner + breakfast) Receipt 3: Taxi receipt � $60.00 CAD (airpor |
| CP082 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | Then the system processes uploaded receipts through OCR (Agentic Receipt Reader) | Receipt 1 � Hotel: Line item: Hotel stay, 1 night � $185.00 CAD Date: June 22, 2026 Category: Hotel Within disruption window: YES ? Currency conversion: $185 CA |
| CP083 | RECEIPT VALIDATION SUMMARY | system | implied | Total receipts processed: 4 | Total line items extracted: 6 Items PASSED: 6 / Items FLAGGED: 0 / Items FAILED: 0 |
| CP084 | EXPENSE BREAKDOWN | system | implied | Hotel: $185.00 CAD / ~�120.00 EUR ? | Meals: $52.00 CAD / ~�34.00 EUR ? Transport: $60.00 CAD / ~�39.00 EUR ? Communication: $0.00 (no receipt) Parking: $0.00 (no receipt) Essentials: $28.00 CAD / ~ |
| CP085 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system initiates payment processing |  |
| CP086 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP087 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Germany" | Germany |
| CP088 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot responds: "Thank you for confirming. Based on the information provided, here is the total reimbursement you are eligible fo | � Hotel: �120.00 � Meals: �34.00 � Transport: �39.00 � Essentials: �18.00 � Total: �211.00 EUR" |
| CP089 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot responds: "I am able to proceed to payment now. Please note that once you confirm, your reimbursement amount will be finali | I am able to proceed to payment now. Please note that once you confirm, your reimbursement amount will be finalized. Would you like to proceed? |
| CP090 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | And user responds: "Yes" |  |
| CP091 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: | � Country = Germany / Currency = EUR � Payment Method = BSM � Email Payment (EUR) / Processing Channel = HSBC � Currency chain = CAD (receipts) ? EUR (threshold |
| CP092 | BSM OFFER | bot | chat | Then the chatbot responds: | Before we move forward, please confirm the email address where you'd like to receive your payment and all updates about this case. Would you like to use t***@gm |
| CP093 | BSM OFFER | bot | chat | And the chatbot displays options: | � Yes, confirm this email � Use a different email |
| CP094 | BSM OFFER | customer | chat | And the user selects "Yes, confirm this email" | Yes, confirm this email |
| CP095 | BSM OFFER | bot | chat | Then the chatbot asks: "Great, can you please confirm that we have the right phone number on the file +1***789?" | Great, can you please confirm that we have the right phone number on the file +1***789? |
| CP096 | BSM OFFER | bot | chat | And the chatbot displays options: | � Yes, confirm this phone number � Use a different phone number |
| CP097 | BSM OFFER | customer | chat | And the user selects "Yes, confirm this phone number" | Yes, confirm this phone number |
| CP098 | BSM OFFER | idv | chat | Then system checks if IDV has been done already ? No |  |
| CP099 | IDENTITY VERIFICATION � PERSONA | bot | chat | Then the chatbot responds: | Before we process your payment, we need to verify your identity. You will receive a separate link to complete identity verification through our secure partner. |
| CP100 | IDENTITY VERIFICATION � PERSONA | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP101 | IDENTITY VERIFICATION � PERSONA | idv | chat | And the customer completes identity verification via Persona |  |
| CP102 | IDENTITY VERIFICATION � PERSONA | idv | chat | And Persona returns: IDV PASS |  |
| CP103 | IDENTITY VERIFICATION � PERSONA | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP104 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �211.00 EUR Payment Method: t***@gmail.com After submission, you will receive a confirmation email summarizing your eligibility, claim details a |
| CP105 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP106 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP107 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case in Case Services |  |
| CP108 | CASE CREATION (GLOB-09) | idv | chat | And the case includes: | � DDS response code: SoC-EU-EL-06 � Eligibility: ELIGIBLE / Regime: EU (EC 261/2004) � Departure country: United Kingdom (journey origin) � Currency chain: CAD  |
| CP109 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP110 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully. Here's a summary: � Case Reference: [Case Number] � Total claim amount: �211.00 EUR � Categories: Hotel (�120.00), M |
| CP111 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP112 | NOTIFICATION | email | email | And an eligible confirmation email is sent to t***@gmail.com |  |
| CP113 | NOTIFICATION | email | email | And the email includes: Case reference number, claim summary (EUR), EU 261/2004, flight details (Seg 1: LHR?YYZ completed, Seg 2: YYZ?YVR CA |  |
| CP114 | NOTIFICATION | email | email | And a separate email containing the secure BSM payment link is sent to t***@gmail.com |  |
| CP115 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP116 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP117 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-EU-EL-06 � EU Eligible No Travel Incomplete Journey Stranded at YYZ |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (Auth Flow 1) |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is NOT greyed out |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "EU (EC 261/2004)" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Regular" |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 858 ? AC 859 LHR ? YYZ ? YVR with claim filed for segment AC 859 YYZ ? YVR (multi-leg, 2 segments) |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 1 AC 858 LHR ? YYZ is "Operated normally (completed)" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 2 AC 859 YYZ ? YVR is "CANCELLED � Disrupted segment" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 858 ? AC 859 LHR ? YYZ ? YVR |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 859 YYZ ? YVR |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Flight cancelled (IRRELEVANT under EU SOC)" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 840 min (14 hours) |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "No Travel � Incomplete Journey (stranded at YYZ)" |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (LHR = UK origin � journey originated from EU/UK)" |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED (EU regime � controllability irrelevant)" |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Cancellation Check is "CANCELLED ? (AC 859 cancelled)" |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Departure Delay is "?2h (14 hours) ?" |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Overnight Eligible is "YES (delay >360 min)" |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the ACR Issued shows Hotel No, Transport No, Meal No |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-EU-EL-06" |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Check Order is: 1. Pax Type ? Regular ? ? 2. No-travel check ? Flight cancelled ? ? Departure delay ?2h ? ? ELIGIBLE |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And under APPR outcome depends on controllability of the cancellation code � if uncontrollable ? NE-12, if Safety ? EL-05/06 � but under EU  |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Entitlements for 1 adult PY no ACR show Meals $60 (EUR equivalent � but receipts likely in CAD since stranded at YYZ), Hotel rate of |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Currency Note is passenger stranded at YYZ (Canada) so receipts likely in CAD with threshold comparison converting CAD ? EUR and pay |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Hotel $185 CAD / ~�120 APPROVED |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Meals $52 CAD / ~�34 APPROVED |  |
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Transport $60 CAD / ~�39 APPROVED |  |
| CP166 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Essentials $28 CAD / ~�18 APPROVED |  |
| CP167 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is ~�211.00 EUR (converted from CAD receipts) |  |
| CP168 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP169 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource result is "GREEN" |  |
| CP170 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Auto-Append shows the system appended the booking record automatically |  |
| CP171 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligible confirmation email was sent |  |
| CP172 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email contains Case Reference, approved amounts (in country of residence currency), EU 261/2004, flight details (Seg 1: LHR ? YYZ co |  |
| CP173 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Agent Notes section is accessible |  |
| CP174 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log records all actions with timestamps |  |
| CP175 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the currency conversion is logged in audit trail (CAD ? EUR ? local) |  |
| CP176 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Customer Communications shows eligible notification email |  |
| CP177 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Chatbot transcript is accessible and linked to the case |  |
| CP178 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab shows receipt images attached |  |
| CP179 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Country of Residence is "Germany" with Currency "EUR" |  |
| CP180 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Method is "BSM � Email Payment (EUR)" with Processing Channel "HSBC" |  |
| CP181 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Email is "t***@gmail.com" (confirmed, locked) |  |
| CP182 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is confirmed as "+1***789" |  |
| CP183 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no bank details / IBAN are stored on the case |  |
| CP184 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the IDV result is "Persona PASS (at Payment)" |  |
| CP185 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CAD ? EUR exchange rate (source, date, value) is logged in the audit trail |  |
| CP186 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligible confirmation email (with password) and secure payment link email were sent to "t***@gmail.com" |  |
| CP187 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved" |  |
| CP188 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP189 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent cannot access Case Search (leads/management only) |  |
| CP190 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-EU-EL-06 � EU Eligible Incomplete Journey Stranded at YYZ � BSM HSBC EUR |  |
| CP191 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-EL-06 is determined as ELIGIBLE |  |
| CP192 | PAYMENT VALIDATION | payment | chat | Then SOC payment is CASH ONLY |  |
| CP193 | PAYMENT VALIDATION | payment | chat | And AC Wallet / e-credit is NOT offered |  |
| CP194 | PAYMENT VALIDATION | payment | chat | And the route is AC 858 ? AC 859 LHR ? YYZ ? YVR (stranded at YYZ) for 1 adult PY |  |
| CP195 | PAYMENT VALIDATION | payment | chat | And receipts are in CAD: Hotel $185/~�120, Meals $52/~�34, Taxi $60/~�39, Essentials $28/~�18 totalling �211.00 EUR |  |
| CP196 | PAYMENT VALIDATION | payment | chat | And the currency chain is CAD (receipts) ? EUR (threshold) ? EUR (payout) |  |
| CP197 | PAYMENT VALIDATION | payment | chat | And the CAD ? EUR exchange rate is logged (source, date, value) |  |
| CP198 | PAYMENT VALIDATION | payment | chat | And the country of residence is Germany with currency EUR |  |
| CP199 | PAYMENT VALIDATION | payment | chat | And the payment method is BSM � Email Payment (EUR) processed via HSBC |  |
| CP200 | PAYMENT VALIDATION | payment | chat | And only the customer's email t***@gmail.com and phone confirmation are collected (no bank details / IBAN) |  |
| CP201 | PAYMENT VALIDATION | payment | chat | And Persona IDV returned PASS before claim submission |  |
| CP202 | PAYMENT VALIDATION | payment | chat | And the compensation record is created with GL accounts per category and cost center |  |
| CP203 | PAYMENT VALIDATION | payment | chat | And the Comp Status is "Sent for issuance" |  |
| CP204 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard shows �211.00 EUR, Cash, BSM (HSBC), t***@gmail.com, status via talkback |  |
| CP205 | EXPECTED RESULTS | verdict | chat | SoC-EU-EL-06. | SoC-EU-EL-06. |
| CP206 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP207 | EXPECTED RESULTS | verdict | chat | No travel (incomplete), flight cancelled. | No travel (incomplete), flight cancelled. |
| CP208 | EXPECTED RESULTS | verdict | chat | Controllability NOT checked. | Controllability NOT checked. |
| CP209 | EXPECTED RESULTS | verdict | chat | Full receipt + case flow. | Full receipt + case flow. |
