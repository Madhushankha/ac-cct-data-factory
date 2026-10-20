# SOC_UAT_023 · CHAI-31938 — checkpoints

**Goal:** Verify eligible when transit delay ?2h is within carrier control but Safety.

Methods: seed 18, chat 71, api 22, email 4, dashboard 56, implied 28, manual 5, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify eligible when transit delay ?2h is within carrier control but Safety. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 401 YYZ?YHZ | � Itinerary: Single segment � AC 401 YYZ?YHZ |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 401 YYZ?YHZ | � SOC Segment (per SoC Flight Identifier): AC 401 YYZ?YHZ |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 401 YYZ?YHZ, Dep: 16-Jun 09:00 | � Promised Itinerary: AC 401 YYZ?YHZ, Dep: 16-Jun 09:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 401 YYZ?YHZ, Dep: 16-Jun 13:00 | � Actual Itinerary: AC 401 YYZ?YHZ, Dep: 16-Jun 13:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 240 min (4 hours) | � Departure Delay: 240 min (4 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 41 | � Departure delay code: 41 |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Safety (Code 41) | � Controllability: Safety (Code 41) |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Type: Exception | � Passenger Type: Exception |
| CP011 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Accessibility SSR (EXCEPTION) ? Controllability SKIPPED ? ELIGIBLE | � Check Order: 1. Pax Type ? Accessibility SSR (EXCEPTION) ? Controllability SKIPPED ? ELIGIBLE |
| CP012 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: J / Revenue: YES / ACR: No / Journey: > 72h | � PAX Count: 1 adult / Class: J / Revenue: YES / ACR: No / Journey: > 72h |
| CP013 | PREREQUISITES | prerequisite | seed | � ENTITLEMENTS (1 adult, J Class, no ACR � LIMITED): | � ENTITLEMENTS (1 adult, J Class, no ACR � LIMITED): |
| CP014 | PREREQUISITES | prerequisite | seed | - Meals: $15/pax | - Meals: $15/pax |
| CP015 | PREREQUISITES | prerequisite | seed | - Communication: $30/pax (>120 min) | - Communication: $30/pax (>120 min) |
| CP016 | PREREQUISITES | prerequisite | seed | - Hotel: NOT entitled (delay <360 min) | - Hotel: NOT entitled (delay <360 min) |
| CP017 | PREREQUISITES | prerequisite | seed | - Transport: NOT entitled (delay <360 min) | - Transport: NOT entitled (delay <360 min) |
| CP018 | PREREQUISITES | prerequisite | seed | - Parking: NOT entitled (delay <300 min) | - Parking: NOT entitled (delay <300 min) |
| CP019 | PREREQUISITES | prerequisite | seed | - Essentials: NOT entitled (delay <300 min) | - Essentials: NOT entitled (delay <300 min) |
| CP020 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP021 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP022 | START | customer | chat | Then user selects English |  |
| CP023 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP024 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP025 | START | customer | chat | And the user says "My Air Canada flight from Toronto to Halifax was delayed by about 4 hours because of an aircraft defect they found before | My Air Canada flight from Toronto to Halifax was delayed by about 4 hours because of an aircraft defect they found before takeoff. I had to buy food while waiti |
| CP026 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP027 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP028 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP032 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP033 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP035 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP040 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP041 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP042 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP043 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP044 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP045 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 401 � Route: Toronto (YYZ) ? Halifax (YHZ) � Date: June 15, 2026 � Departure Delay: 4 hours Is this the journey you' |
| CP046 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP047 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP051 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR SOC per province |  |
| CP053 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Origin: YYZ (Ontario) ? Limitation = 730 days � Destination: YHZ (Nova Scotia) ? Limitation = 730 days � Days elapsed: Within limitation period ? PROCEED |
| CP054 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment domestic trip YYZ?YHZ on AC401 was delayed +4H 00M due to aircraft defect (safety) | Single-segment domestic trip YYZ?YHZ on AC401 was delayed +4H 00M due to aircraft defect (safety) |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Class of Booking: J (Business) | Class of Booking: J (Business) |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Passenger Type: Exception (Accessibility SSR) | Passenger Type: Exception (Accessibility SSR) |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 401, Route: YYZ ? YHZ, Scheduled Dep: 16-Jun 09:00 | Promised Itinerary � Flight: AC 401, Route: YYZ ? YHZ, Scheduled Dep: 16-Jun 09:00 |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 401, Route: YYZ ? YHZ, Status: ARRIVED LATE, Scheduled Dep: 09:00 ? Actual: 13:00, Delay: +4H 00M | Current Itinerary � Flight: AC 401, Route: YYZ ? YHZ, Status: ARRIVED LATE, Scheduled Dep: 09:00 ? Actual: 13:00, Delay: +4H 00M |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 41 (Aircraft Defects / Maintenance Finding) � Safety | Departure Delay Code: 41 (Aircraft Defects / Maintenance Finding) � Safety |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_2_TO_6_HOURS / MEAL: $15.00 (LIMITED � short delay tier) / ACCOMMODATION: � (NOT ENTITLED | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_2_TO_6_HOURS / MEAL: $15.00 (LIMITED � short delay tier) / ACCOMMODATION: � (NOT ENTITLED, delay <6h) / GENER |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: GREEN | CyberSource: GREEN |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | LIMITED entitlements: Meals $15 + Comm $30 only. No hotel/transport/parking/essentials. | LIMITED entitlements: Meals $15 + Comm $30 only. No hotel/transport/parking/essentials. |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | Total Approved: $26.00 CAD (Meals $14 + Comm $12) | Total Approved: $26.00 CAD (Meals $14 + Comm $12) |
| CP073 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-APPR-EL-09 | DDS RESPONSE CODE = SoC-APPR-EL-09 |
| CP074 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP075 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger) |  |
| CP076 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates the claim |  |
| CP077 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) | ? PROCEED to eligible flow |
| CP078 | ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 401  | Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 401 from Toronto to Halifax was delayed by approxima |
| CP079 | ENTITLEMENT DISPLAY | bot | chat | Then the chatbot displays the eligible expense categories based on  delay, 1 adult, J class, no ACR: | Based on the length of your disruption (4 hours), you may be eligible for reimbursement in the following categories: � Meals: up to $15.00 � Communication: up t |
| CP080 | KEY DIFFERENCE FROM OTHER EL CASES | system | implied | This is a  delay, so entitlements are LIMITED: | � Meals: $15 (NOT $30 or $60 � lower  tier) � Communication: $30 (>120 min ?) � Hotel: NOT ENTITLED ? (delay <360 min, no overnight) � Transport: NOT ENTITLED ? |
| CP081 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP082 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | And the chatbot displays the receipt upload interface |  |
| CP083 | RECEIPT UPLOAD � WELCOME BACK FLOW | system | implied | And the user uploads receipt images: | � Receipt 1: Meal receipt � $14.00 CAD (sandwich + coffee at airport) � Receipt 2: Communication � $12.00 CAD (Wi-Fi access) |
| CP084 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | Then the system processes uploaded receipts through OCR (Agentic Receipt Reader) |  |
| CP085 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | And the OCR engine extracts line items from each receipt: | Receipt 1 � Meals: � Line item 1: Sandwich � $9.00 CAD � Line item 2: Coffee � $5.00 CAD � Total meals: $14.00 CAD � Date: June 15, 2026 � Category: Meals � Wit |
| CP086 | RECEIPT VALIDATION SUMMARY | system | implied | Then the system displays the OCR validation summary: | � Total receipts processed: 2 � Total line items extracted: 3 � Items PASSED: 3 � Items FLAGGED for agent review: 0 � Items FAILED: 0 |
| CP087 | EXPENSE BREAKDOWN | system | implied | � Hotel: NOT ENTITLED (delay <360 min) | � Meals: $14.00 ? � Transport: NOT ENTITLED (delay <360 min) � Communication: $12.00 ? � Parking: NOT ENTITLED (delay <300 min) � Essentials: NOT ENTITLED (dela |
| CP088 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP089 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP090 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP091 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP092 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP093 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $26.00 CAD compensation. Please note that it will take 5 to 10 business days to pr | You are entitled to receive a $26.00 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP094 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP095 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP096 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac (CANADA) |  |
| CP097 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP098 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP099 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP100 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP101 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP102 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP103 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP104 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP105 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP106 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP107 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP108 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP109 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP110 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $26.00 CAD Payment Method: t***@gmail.com After submission, you will receive a confirmation email summarizing your eligibility, claim details an |
| CP111 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP112 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP113 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case in Case Services |  |
| CP114 | CASE CREATION (GLOB-09) | idv | chat | And the case includes: | � DDS response code: SoC-APPR-EL-09 � Eligibility: ELIGIBLE (limited entitlements, 2�6h tier) � Regime: APPR � Passenger Type: Exception (Accessibility SSR) � c |
| CP115 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP116 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully. Here's a summary: � Case Reference: [Case Number] � Total claim amount: $26.00 CAD � Categories: Meals ($14.00), Com |
| CP117 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP118 | NOTIFICATION | email | email | And an eligible confirmation email is sent to the passenger at t***@gmail.com |  |
| CP119 | NOTIFICATION | email | email | And the email includes: | � Case reference number � Claim summary with approved amounts � Next steps for payment � Password required to access the secure payment link |
| CP120 | NOTIFICATION | email | email | And a separate email containing the secure Interac payment link is sent to t***@gmail.com |  |
| CP121 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP122 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP123 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-EL-09 � Exception Limited Entitlements Eligible |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Exception" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Exception" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 401 YYZ ? YHZ as the claimed flight |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (4 hours)" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 401 YYZ ? YHZ |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 401 |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Safety (Departure delay code 41 � Safety)" |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 240 min (4 hours) |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Exception" (checked FIRST) |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "SKIPPED" |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Overnight Eligible is "NO (delay <360 min)" |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "J" |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the ACR Issued shows Hotel No, Transport No, Meal No |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-EL-09" |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Entitlement Limits Applied are LIMITED for 2�6h delay tier |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Meals entitlement is $15 max (lower tier) |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Communication entitlement is $30 max (>120 min) |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Hotel is NOT ENTITLED (delay <360 min, no overnight) |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Transport is NOT ENTITLED (delay <360 min) |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Parking is NOT ENTITLED (delay <300 min) |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Essentials is NOT ENTITLED (delay <300 min) |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Hotel NOT ENTITLED (delay <360 min) |  |
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Meals $14.00 APPROVED (sandwich $9 + coffee $5, ?$15) |  |
| CP166 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Transport NOT ENTITLED (delay <360 min) |  |
| CP167 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Communication $12.00 APPROVED (Wi-Fi, ?$30) |  |
| CP168 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Parking NOT ENTITLED (delay <300 min) |  |
| CP169 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Essentials NOT ENTITLED (delay <300 min) |  |
| CP170 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is $26.00 CAD |  |
| CP171 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 0 |  |
| CP172 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "$26.00 CAD (APPR � Suggested Highlighted)" |  |
| CP173 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP174 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource result is "GREEN" |  |
| CP175 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Country of Residence is "Canada" with Currency "CAD" |  |
| CP176 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Method is "Interac e-Transfer" |  |
| CP177 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Email is "t***@gmail.com" (confirmed, locked) |  |
| CP178 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no bank details are stored on the case |  |
| CP179 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the IDV result is "Persona PASS (at Payment)" |  |
| CP180 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the payout amount includes Communication ($12.00) for a total of $26.00 CAD |  |
| CP181 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved" |  |
| CP182 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP183 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-EL-09 � Exception Limited Entitlements Eligible |  |
| CP184 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-EL-09 is determined as ELIGIBLE |  |
| CP185 | PAYMENT VALIDATION | payment | chat | Then SOC payment is CASH ONLY |  |
| CP186 | PAYMENT VALIDATION | payment | chat | And AC Wallet / e-credit is NOT offered |  |
| CP187 | PAYMENT VALIDATION | payment | chat | And the route is AC 401 YYZ ? YHZ with delay 240 min (4 hrs) for 1 adult J class Exception |  |
| CP188 | PAYMENT VALIDATION | payment | chat | And exception pax controllability is SKIPPED so ELIGIBLE regardless of code 41 (Safety) |  |
| CP189 | PAYMENT VALIDATION | payment | chat | And the entitlements for 2�6h 1 adult J class are Meals $15 and Comm $30 only |  |
| CP190 | PAYMENT VALIDATION | payment | chat | And Hotel, Transport, Parking, and Essentials are NOT entitled |  |
| CP191 | PAYMENT VALIDATION | payment | chat | And the approved receipts are Meals $14 and Comm $12 totalling $26.00 CAD |  |
| CP192 | PAYMENT VALIDATION | payment | chat | And $26.00 is less than SOC threshold so no approval is needed |  |
| CP193 | PAYMENT VALIDATION | payment | chat | And the country of residence is Canada with currency CAD |  |
| CP194 | PAYMENT VALIDATION | payment | chat | And the payment method is Interac e-Transfer |  |
| CP195 | PAYMENT VALIDATION | payment | chat | And only the customer's email t***@gmail.com is collected (no bank details) |  |
| CP196 | PAYMENT VALIDATION | payment | chat | And Persona IDV returned PASS before claim submission |  |
| CP197 | PAYMENT VALIDATION | payment | chat | And the Comp Status is "Sent for issuance" |  |
| CP198 | PAYMENT VALIDATION | payment | manual | And the batch file is sent to Unifier and EOD report updates only when event occurs |  |
| CP199 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard shows $26.00 CAD, Cash, Interac, t***@gmail.com, status via talkback |  |
| CP200 | EXPECTED RESULTS | verdict | chat | SoC-APPR-EL-09. | SoC-APPR-EL-09. |
| CP201 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP202 | EXPECTED RESULTS | verdict | chat | Exception pax (Accessibility SSR) with Safety code 41. | Exception pax (Accessibility SSR) with Safety code 41. |
| CP203 | EXPECTED RESULTS | verdict | chat | Controllability SKIPPED. | Controllability SKIPPED. |
| CP204 | EXPECTED RESULTS | verdict | chat | Transit delay 4h, limited entitlements (2�6h): meals $15 + communication $30 only. | Transit delay 4h, limited entitlements (2�6h): meals $15 + communication $30 only. |
| CP205 | EXPECTED RESULTS | verdict | chat | J class. | J class. |
