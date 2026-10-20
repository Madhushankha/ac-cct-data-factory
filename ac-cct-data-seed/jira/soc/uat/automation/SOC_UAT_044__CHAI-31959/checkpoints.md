# SOC_UAT_044 · CHAI-31959 — checkpoints

**Goal:** Verify ELIGIBLE when customer stayed at origin,  cancelled, EU.

Methods: seed 16, chat 68, api 22, email 4, dashboard 69, implied 26, manual 7, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify ELIGIBLE when customer stayed at origin,  cancelled, EU. |  |
| CP002 | PREREQUISITES | prerequisite | seed | Regime: EU | Regime: EU |
| CP003 | PREREQUISITES | prerequisite | seed | Carrier: AC (AC 854 LHR?YYZ) | Carrier: AC (AC 854 LHR?YYZ) |
| CP004 | PREREQUISITES | prerequisite | seed | Promised Itinerary: AC 854 LHR?YYZ, Dep: 20-Jun 10:00, Arr: 20-Jun 14:00 | Promised Itinerary: AC 854 LHR?YYZ, Dep: 20-Jun 10:00, Arr: 20-Jun 14:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual Itinerary: Flight cancelled. No alternative offered within 24h. Passenger stayed at LHR | Actual Itinerary: Flight cancelled. No alternative offered within 24h. Passenger stayed at LHR |
| CP006 | PREREQUISITES | prerequisite | seed | Delay Length: 1440 min (24 hours) | Delay Length: 1440 min (24 hours) |
| CP007 | PREREQUISITES | prerequisite | seed | Controllability: NOT CHECKED | Controllability: NOT CHECKED |
| CP008 | PREREQUISITES | prerequisite | seed | EU regime | EU regime |
| CP009 | PREREQUISITES | prerequisite | seed | Departure delay code: Flight cancelled (code irrelevant for EU SOC) | Departure delay code: Flight cancelled (code irrelevant for EU SOC) |
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
| CP023 | START | customer | chat | And the user says ""My flight from London to Toronto was cancelled and I never made it to my destination. I was stuck at the airport for ove | My flight from London to Toronto was cancelled and I never made it to my destination. I was stuck at the airport for over 24 hours. I had to buy meals, pay for  |
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
| CP043 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 854 Route: London Heathrow (LHR) ? Toronto (YYZ) Date: June 20, 2026 Status: CANCELLED � No alternative offered within |
| CP044 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms ""Yes"" | Yes |
| CP045 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No (single leg) |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU SOC per departing country |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | Departing country: United Kingdom ? Limitation = 2,190 days (6 years) Days elapsed: Within limitation period ? PROCEED |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP053 | CLAIM TIME LIMIT CHECK | verdict | api | Then the DDS evaluation is done in backend |  |
| CP054 | CLAIM TIME LIMIT CHECK | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Not Completed, Disruption Detected | Trip Not Completed, Disruption Detected |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip LHR?YYZ on AC854 was cancelled � no alternative within 24h. Passenger stayed at origin (LHR). | Single-segment trip LHR?YYZ on AC854 was cancelled � no alternative within 24h. Passenger stayed at origin (LHR). |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: EU (LHR departure) | Regime: EU (LHR departure) |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 854, Route: LHR ? YYZ, Scheduled Dep: 20-Jun 10:00 | Promised Itinerary � Flight: AC 854, Route: LHR ? YYZ, Scheduled Dep: 20-Jun 10:00 |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 854, Route: LHR ? YYZ, Status: CANCELLED � No alternative within 24h | Current Itinerary � Flight: AC 854, Route: LHR ? YYZ, Status: CANCELLED � No alternative within 24h |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Cancellation: YES ? / SOC Segment Delay: 1440 min (24h) ? ?2h ? | Cancellation: YES ? / SOC Segment Delay: 1440 min (24h) ? ?2h ? |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Controllability: NOT CHECKED (EU regime) | Controllability: NOT CHECKED (EU regime) |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: �60.00 / ACCOMMODATION: Rate of day (max �500) / GENERAL EXPENSES | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: �60.00 / ACCOMMODATION: Rate of day (max �500) / GENERAL EXPENSES: Transport �200 + C |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: GREEN | CyberSource: GREEN |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | Total Approved: �285.00 EUR (Hotel �155/�182 + Meals �48/�56 + Transport �40/�47) | Total Approved: �285.00 EUR (Hotel �155/�182 + Meals �48/�56 + Transport �40/�47) |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | Currency: GBP receipts ? EUR threshold comparison ? country of residence payout | Currency: GBP receipts ? EUR threshold comparison ? country of residence payout |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-EU-EL-04 | DDS RESPONSE CODE = SoC-EU-EL-04 |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP073 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger) |  |
| CP074 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates the claim |  |
| CP075 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) | ? PROCEED to eligible flow |
| CP076 | ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: ""Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 854 | Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 854 from London Heathrow to Toronto was cancelled an |
| CP077 | ENTITLEMENT DISPLAY | bot | chat | Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, no ACR: | Based on the length of your disruption (24 hours), you may be eligible for reimbursement in the following categories: Meals: up to $60.00 Hotel accommodation: R |
| CP078 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP079 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | And the chatbot displays the receipt upload interface |  |
| CP080 | RECEIPT UPLOAD � WELCOME BACK FLOW | system | implied | And the user uploads receipt images: | Receipt 1: Hotel receipt � �155.00 GBP (1 night near Heathrow) Receipt 2: Meal receipt � �48.00 GBP (dinner + breakfast + lunch) Receipt 3: Taxi receipt � �40.0 |
| CP081 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | Then the system processes uploaded receipts through OCR (Agentic Receipt Reader) |  |
| CP082 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | And the OCR engine extracts line items from each receipt: | Receipt 1 � Hotel: Line item: Hotel stay, 1 night � �155.00 GBP Date: June 20, 2026 Category: Hotel Within disruption window: YES ? Currency conversion: �155 GB |
| CP083 | RECEIPT VALIDATION SUMMARY | system | implied | Total receipts processed: 3 | Total line items extracted: 6 Items PASSED: 6 Items FLAGGED for agent review: 0 Items FAILED: 0 |
| CP084 | EXPENSE BREAKDOWN | system | implied | Hotel: �155.00 / �182.00 ? | Meals: �48.00 / �56.00 ? Transport: �40.00 / �47.00 ? Communication: �0.00 (no receipt submitted) Parking: �0.00 (no receipt submitted) Essentials: �0.00 (no re |
| CP085 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system initiates payment processing |  |
| CP086 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP087 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Germany" | Germany |
| CP088 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot responds: "Thank you for confirming. Based on the information provided, here is the total reimbursement you are eligible fo | � Hotel: �182.00 � Meals: �56.00 � Transport: �47.00 � Total: �285.00 EUR" |
| CP089 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot responds: "I am able to proceed to payment now. Please note that once you confirm, your reimbursement amount will be finali | I am able to proceed to payment now. Please note that once you confirm, your reimbursement amount will be finalized. Would you like to proceed? |
| CP090 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | And user responds: "Yes" |  |
| CP091 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: | � Country = Germany / Currency = EUR � Payment Method = BSM � Email Payment (EUR) / Processing Channel = HSBC � Payout currency conversion = Not required (EUR ? |
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
| CP104 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �285.00 EUR Payment Method: t***@gmail.com After submission, you will receive a confirmation email summarizing your eligibility, claim details a |
| CP105 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP106 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP107 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case in Case Services |  |
| CP108 | CASE CREATION (GLOB-09) | idv | chat | And the case includes: | � DDS response code: SoC-EU-EL-04 � Eligibility: ELIGIBLE / Regime: EU (EC 261/2004) � Departure country: United Kingdom � Currency: GBP (receipts) ? EUR (thres |
| CP109 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP110 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully. Here's a summary: � Case Reference: [Case Number] � Total claim amount: �285.00 EUR � Categories: Hotel (�182.00), M |
| CP111 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP112 | NOTIFICATION | email | email | And an eligible confirmation email is sent to t***@gmail.com |  |
| CP113 | NOTIFICATION | email | email | And the email includes: Case reference number, claim summary (EUR), EU 261/2004 reference, flight details (AC 854 LHR?YYZ CANCELLED), next s |  |
| CP114 | NOTIFICATION | email | email | And a separate email containing the secure BSM payment link is sent to t***@gmail.com |  |
| CP115 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP116 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP117 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-EU-EL-04 � EU Eligible No Travel Stayed at Origin LHR Cancelled |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent can edit Topic/Sub-topic but cannot switch between automated and non-automated |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date is populated |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date is populated |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (identified + authenticated, Auth Flow 1) |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is NOT greyed out |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date is populated |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID is populated |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source is populated |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID is populated |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "EU (EC 261/2004)" |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address is populated |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Regular" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 854 LHR ? YYZ as the claimed flight (single leg, 1 segment) |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "CANCELLED � No alternative offered within 24h" |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section is present with no entries |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 854 LHR ? YYZ |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 854 |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Flight cancelled (code irrelevant for EU SOC)" |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 1440 min (24 hours) |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "No Travel � Stayed at Origin (LHR)" |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (LHR = UK origin)" |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED (EU regime � controllability irrelevant for SOC)" |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Cancellation Check is "CANCELLED ? (flight cancelled, no alternative within 24h)" |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Departure Delay is "?2h (24 hours) ? (well above no-travel 2h threshold)" |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Overnight Eligible is "YES (delay >360 min)" |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the ACR Issued shows Hotel No, Transport No, Meal No |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-EU-EL-04" |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP166 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Check Order is: 1. Pax Type ? Regular ? ? 2. No-travel check ? Flight cancelled ? ? Departure delay ?2h ? ? ELIGIBLE (no controllabi |  |
| CP167 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And under APPR this scenario's outcome depends on the Departure delay code's controllability classification but under EU eligible regardless |  |
| CP168 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Entitlements for 1 adult PY no ACR show Meals $60 (EUR equivalent), Hotel rate of day max 3 nights $500 cap, Transport $200, Communi |  |
| CP169 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Hotel �155/~�182 APPROVED |  |
| CP170 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Meals �48/~�56 APPROVED |  |
| CP171 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Transport �40/~�47 APPROVED |  |
| CP172 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is �285.00 EUR |  |
| CP173 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP174 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource result is "GREEN" |  |
| CP175 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Auto-Append shows the system appended the booking record automatically |  |
| CP176 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligible confirmation email was sent via Adobe |  |
| CP177 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email contains Case Reference, approved amounts, EU 261/2004 reference, flight details (AC 854 LHR ? YYZ CANCELLED), and next steps |  |
| CP178 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Agent Notes section is accessible |  |
| CP179 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log records all actions with timestamps |  |
| CP180 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Customer Communications shows eligible notification email |  |
| CP181 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Chatbot transcript is accessible and linked to the case |  |
| CP182 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab shows receipt images attached |  |
| CP183 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Country of Residence is "Germany" with Currency "EUR" |  |
| CP184 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Method is "BSM � Email Payment (EUR)" with Processing Channel "HSBC" |  |
| CP185 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Email is "t***@gmail.com" (confirmed, locked) |  |
| CP186 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is confirmed as "+1***789" |  |
| CP187 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no bank details / IBAN are stored on the case |  |
| CP188 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the IDV result is "Persona PASS (at Payment)" |  |
| CP189 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligible confirmation email (with password) and secure payment link email were sent to "t***@gmail.com" |  |
| CP190 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved" |  |
| CP191 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP192 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent cannot access Case Search (leads/management only) |  |
| CP193 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-EU-EL-04 � EU Eligible No Travel Stayed at Origin LHR Cancelled � BSM HSBC EUR |  |
| CP194 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-EL-04 is determined as ELIGIBLE |  |
| CP195 | PAYMENT VALIDATION | payment | chat | Then SOC payment is CASH ONLY |  |
| CP196 | PAYMENT VALIDATION | payment | chat | And AC Wallet / e-credit is NOT offered |  |
| CP197 | PAYMENT VALIDATION | payment | chat | And the route is AC 854 LHR ? YYZ CANCELLED for 1 adult PY |  |
| CP198 | PAYMENT VALIDATION | payment | chat | And the approved receipts are Hotel �155/~�182, Meals �48/~�56, Taxi �40/~�47 totalling �285.00 EUR |  |
| CP199 | PAYMENT VALIDATION | payment | chat | And the country of residence is Germany with currency EUR |  |
| CP200 | PAYMENT VALIDATION | payment | chat | And the payment method is BSM � Email Payment (EUR) processed via HSBC |  |
| CP201 | PAYMENT VALIDATION | payment | chat | And only the customer's email t***@gmail.com and phone confirmation are collected (no bank details / IBAN) |  |
| CP202 | PAYMENT VALIDATION | payment | chat | And the payment email cannot be changed after confirmation |  |
| CP203 | PAYMENT VALIDATION | payment | chat | And Persona IDV returned PASS before claim submission |  |
| CP204 | PAYMENT VALIDATION | payment | chat | And no payout currency conversion is applied (EUR ? EUR) |  |
| CP205 | PAYMENT VALIDATION | payment | chat | And the GBP ? EUR threshold conversion is logged (source, date, value) |  |
| CP206 | PAYMENT VALIDATION | payment | chat | And the Comp Status is "Sent for issuance" |  |
| CP207 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard shows �285.00 EUR, Cash, BSM (HSBC), t***@gmail.com, status via talkback |  |
| CP208 | EXPECTED RESULTS | verdict | chat | SoC-EU-EL-04. | SoC-EU-EL-04. |
| CP209 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP210 | EXPECTED RESULTS | verdict | chat | No travel (origin), flight cancelled. | No travel (origin), flight cancelled. |
| CP211 | EXPECTED RESULTS | verdict | chat | Controllability NOT checked. | Controllability NOT checked. |
| CP212 | EXPECTED RESULTS | verdict | chat | Full receipt + case flow. | Full receipt + case flow. |
| CP213 | EXPECTED RESULTS | verdict | chat | Entitlements per  category. | Entitlements per  category. |
