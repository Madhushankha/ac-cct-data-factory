# SOC_UAT_013 · CHAI-31928 — checkpoints

**Goal:** Verify that when customer did not travel (remained at origin) following a safety disruption, system returns ELIGIBLE under APPR and proceeds to receipt upload and case creation.

Methods: seed 22, chat 68, api 20, email 4, dashboard 69, implied 27, manual 8, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify that when customer did not travel (remained at origin) following a safety disruption, system returns ELIGIBLE under APPR and proceeds |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 501 YYZ?YVR | � Itinerary: Single segment � AC 501 YYZ?YVR |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 501 YYZ?YVR | � SOC Segment (per SoC Flight Identifier): AC 501 YYZ?YVR |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 501 YYZ?YVR, Dep: 10-Jun 07:00 | � Promised Itinerary: AC 501 YYZ?YVR, Dep: 10-Jun 07:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: Flight cancelled. Passenger stayed at origin (YYZ). No rebooking within 24h | � Actual Itinerary: Flight cancelled. Passenger stayed at origin (YYZ). No rebooking within 24h |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 1440 min (24 hours) | � Departure Delay: 1440 min (24 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 41(TD � Aircraft Defects or Maintenance Finding) � Safety | � Departure delay code: 41(TD � Aircraft Defects or Maintenance Finding) � Safety |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Safety (Code 41) | � Controllability: Safety (Code 41) |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP011 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Regular ? ? 2. Controllability ? Safety ? ELIGIBLE | � Check Order: 1. Pax Type ? Regular ? ? 2. Controllability ? Safety ? ELIGIBLE |
| CP012 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult | � PAX Count: 1 adult |
| CP013 | PREREQUISITES | prerequisite | seed | � Class of Booking: PY | � Class of Booking: PY |
| CP014 | PREREQUISITES | prerequisite | seed | � Revenue Booking: YES | � Revenue Booking: YES |
| CP015 | PREREQUISITES | prerequisite | seed | � ACR Issued: Hotel: No, Transport: No, Meal: No | � ACR Issued: Hotel: No, Transport: No, Meal: No |
| CP016 | PREREQUISITES | prerequisite | seed | � Journey Completed: > 72h | � Journey Completed: > 72h |
| CP017 | PREREQUISITES | prerequisite | seed | � ENTITLEMENTS (, 1 adult, PY, no ACR): | � ENTITLEMENTS (, 1 adult, PY, no ACR): |
| CP018 | PREREQUISITES | prerequisite | seed | - Meals: $60/pax | - Meals: $60/pax |
| CP019 | PREREQUISITES | prerequisite | seed | - Hotel: Rate of day, max 3 nights, $500 cap (overnight eligible � delay >360 min) | - Hotel: Rate of day, max 3 nights, $500 cap (overnight eligible � delay >360 min) |
| CP020 | PREREQUISITES | prerequisite | seed | - Transport: $200 (1�5 pax) | - Transport: $200 (1�5 pax) |
| CP021 | PREREQUISITES | prerequisite | seed | - Communication: $30/pax | - Communication: $30/pax |
| CP022 | PREREQUISITES | prerequisite | seed | - Parking: $50, 1 day max | - Parking: $50, 1 day max |
| CP023 | PREREQUISITES | prerequisite | seed | - Essentials: $30/pax | - Essentials: $30/pax |
| CP024 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP025 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP026 | START | customer | chat | Then user selects English |  |
| CP027 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP028 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP029 | START | customer | chat | And the user says "My flight was cancelled because of an aircraft defect and I never made it to my destination. I was stuck at the airport f | My flight was cancelled because of an aircraft defect and I never made it to my destination. I was stuck at the airport for over 24 hours. I had to buy meals, p |
| CP030 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP031 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP032 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP033 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP034 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP035 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP036 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP037 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP038 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP039 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP042 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP043 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP044 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP045 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP046 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP047 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP048 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP049 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 501 � Route: Toronto (YYZ) ? Vancouver (YVR) � Date: June 10, 2026 � Status: CANCELLED � Aircraft defect Is this the |
| CP050 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP051 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP052 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP053 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP054 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP055 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP056 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR SOC per province |  |
| CP057 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Origin: YYZ (Ontario) ? Limitation = 730 days � Destination: YVR (British Columbia) ? Limitation = 1,095 days � Days elapsed: Within limitation period ? PROCE |
| CP058 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Not Completed, Disruption Detected | Trip Not Completed, Disruption Detected |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment domestic trip YYZ?YVR on AC501 was cancelled due to aircraft defect (safety) | Single-segment domestic trip YYZ?YVR on AC501 was cancelled due to aircraft defect (safety) |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Passenger stayed at origin (YYZ) | Passenger stayed at origin (YYZ) |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 501, Route: YYZ ? YVR, Scheduled Dep: 10-Jun 07:00 | Promised Itinerary � Flight: AC 501, Route: YYZ ? YVR, Scheduled Dep: 10-Jun 07:00 |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 501, Route: YYZ ? YVR, Status: CANCELLED | Current Itinerary � Flight: AC 501, Route: YYZ ? YVR, Status: CANCELLED |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 41 (Aircraft Defects / Maintenance Finding) � Safety | Departure Delay Code: 41 (Aircraft Defects / Maintenance Finding) � Safety |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: $60.00 / ACCOMMODATION: Rate of day (max $500) / GENERAL EXPENSES | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: $60.00 / ACCOMMODATION: Rate of day (max $500) / GENERAL EXPENSES: Transport $200 + C |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: GREEN | CyberSource: GREEN |
| CP073 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE |
| CP074 | TRIP TRACER UI VALIDATIONS | verdict | api | Total Approved: $305.00 CAD (Hotel $180 + Meals $45 + Transport $55 + Essentials $25) | Total Approved: $305.00 CAD (Hotel $180 + Meals $45 + Transport $55 + Essentials $25) |
| CP075 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-APPR-EL-01 | DDS RESPONSE CODE = SoC-APPR-EL-01 |
| CP076 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP077 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger) |  |
| CP078 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates the claim |  |
| CP079 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) | ? PROCEED to eligible flow |
| CP080 | ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 501  | Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 501 from Toronto to Vancouver was cancelled due to a |
| CP081 | ENTITLEMENT DISPLAY | bot | chat | Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, no ACR: | Based on the length of your disruption (24 hours), you may be eligible for reimbursement in the following categories: � Meals: up to $60.00 � Hotel accommodatio |
| CP082 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP083 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | And the chatbot displays the receipt upload interface |  |
| CP084 | RECEIPT UPLOAD � WELCOME BACK FLOW | system | implied | And the user uploads receipt images: | � Receipt 1: Hotel receipt � $180.00 CAD (1 night) � Receipt 2: Meal receipt � $45.00 CAD (dinner + breakfast) � Receipt 3: Taxi receipt � $55.00 CAD (airport t |
| CP085 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | Then the system processes uploaded receipts through OCR (Agentic Receipt Reader) |  |
| CP086 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | And the OCR engine extracts line items from each receipt: | Receipt 1 � Hotel: � Line item: Hotel stay, 1 night � $180.00 CAD � Date: June 10, 2026 � Category: Hotel � Within disruption window: YES ? � Rate of day compar |
| CP087 | RECEIPT VALIDATION SUMMARY | system | implied | Then the system displays the OCR validation summary: | � Total receipts processed: 4 � Total line items extracted: 5 � Items PASSED: 5 � Items FLAGGED for agent review: 0 � Items FAILED: 0 |
| CP088 | EXPENSE BREAKDOWN | system | implied | � Hotel: $180.00 ? | � Meals: $45.00 ? � Transport: $55.00 ? � Communication: $0.00 (no receipt submitted) � Parking: $0.00 (no receipt submitted) � Essentials: $25.00 ? � TOTAL APP |
| CP089 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP090 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP091 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP092 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP093 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP094 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $305.00 CAD compensation. Please note that it will take 5 to 10 business days to p | You are entitled to receive a $305.00 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP095 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP096 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP097 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac (CANADA) |  |
| CP098 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP099 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP100 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP101 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP102 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP103 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP104 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP105 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP106 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP107 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP108 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP109 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP110 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP111 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $305.00 CAD Payment Method: t***@gmail.com After submission, you will receive a confirmation email summarizing your eligibility, claim details a |
| CP112 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP113 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP114 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case in Case Services |  |
| CP115 | CASE CREATION (GLOB-09) | idv | chat | And the case includes: | � DDS response code: SoC-APPR-EL-01 � Eligibility: ELIGIBLE � Regime: APPR � All approved line items with amounts � Receipt images attached � Fraud screening re |
| CP116 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP117 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully. Here's a summary: � Case Reference: [Case Number] � Total claim amount: $305.00 CAD � Categories: Hotel ($180.00), M |
| CP118 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP119 | NOTIFICATION | email | email | And an eligible confirmation email is sent to the passenger at t***@gmail.com |  |
| CP120 | NOTIFICATION | email | email | And the email includes: | � Case reference number � Claim summary with approved amounts � Next steps for payment � Password required to access the secure payment link |
| CP121 | NOTIFICATION | email | email | And a separate email containing the secure Interac payment link is sent to t***@gmail.com |  |
| CP122 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP123 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP124 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada. |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-EL-01 � Safety Aircraft Defect Eligible |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent can edit Topic/Sub-topic but cannot switch between automated and non-automated |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date is populated |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date is populated |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (identified + authenticated, Auth Flow 1) |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is NOT greyed out |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date is populated |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID is populated |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source is populated |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID is populated |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address is populated |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Regular" |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 501 YYZ ? YVR as the claimed flight |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "CANCELLED � Aircraft defect" |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section is present with no entries |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 501 YYZ ? YVR |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 501 |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Aircraft Defect (Code 41 � Safety)" |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 1440 min (24 hours) |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "No Travel � Stayed at Origin (YYZ)" |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" (checked FIRST) |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "Safety" (checked SECOND) |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Overnight Eligible is "Yes (delay >360 min)" |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP166 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the ACR Issued shows Hotel No, Transport No, Meal No |  |
| CP167 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-EL-01" |  |
| CP168 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP169 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP170 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Check Order is: 1. Pax Type ? Regular ? ? 2. Controllability ? Safety ? ELIGIBLE |  |
| CP171 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Entitlements for 1 adult PY no ACR show Meals $60/pax, Hotel rate of day max 3 nights $500 cap, Transport $200, Communication $30/pa |  |
| CP172 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Hotel $180.00 APPROVED |  |
| CP173 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Meals $45.00 APPROVED (dinner $28 + breakfast $17, ?$60) |  |
| CP174 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Transport $55.00 APPROVED (taxi airport?hotel, ?$200) |  |
| CP175 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Communication $0.00 No receipt submitted |  |
| CP176 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Parking $0.00 No receipt submitted |  |
| CP177 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Essentials $25.00 APPROVED (phone charging cable, ?$30) |  |
| CP178 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is $305.00 CAD |  |
| CP179 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 0 |  |
| CP180 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "$305.00 CAD (APPR � Suggested Highlighted)" |  |
| CP181 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP182 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource result is "GREEN" |  |
| CP183 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Auto-Append shows the system appended the booking record automatically |  |
| CP184 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Country of Residence is "Canada" with Currency "CAD" |  |
| CP185 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Method is "Interac e-Transfer" |  |
| CP186 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Email is "t***@gmail.com" (confirmed, locked) |  |
| CP187 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no bank details are stored on the case |  |
| CP188 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the IDV result is "Persona PASS (at Payment)" |  |
| CP189 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the secure payment link email and password were sent to "t***@gmail.com" |  |
| CP190 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligible confirmation email was sent via Adobe to "t***@gmail.com" |  |
| CP191 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email contains Case Reference, claim summary $305.00 CAD, approved categories, and next steps |  |
| CP192 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Agent Notes section is accessible |  |
| CP193 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log records all actions with timestamps |  |
| CP194 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Customer Communications shows eligible notification email |  |
| CP195 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Chatbot transcript is accessible and linked to the case |  |
| CP196 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab shows 4 receipt images attached |  |
| CP197 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved" |  |
| CP198 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP199 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent cannot access Case Search (leads/management only) |  |
| CP200 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-EL-01 � Safety Aircraft Defect Eligible |  |
| CP201 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-EL-01 is determined as ELIGIBLE |  |
| CP202 | PAYMENT VALIDATION | payment | chat | Then SOC payment is CASH ONLY |  |
| CP203 | PAYMENT VALIDATION | payment | chat | And AC Wallet / e-credit is NOT offered |  |
| CP204 | PAYMENT VALIDATION | payment | chat | And the route is AC 501 YYZ ? YVR with delay 1440 min (24 hrs) for 1 adult PY |  |
| CP205 | PAYMENT VALIDATION | payment | chat | And the approved receipts are Hotel $180, Meals $45, Taxi $55, Essentials $25 totalling $305.00 CAD |  |
| CP206 | PAYMENT VALIDATION | payment | chat | And the country of residence is Canada with currency CAD |  |
| CP207 | PAYMENT VALIDATION | payment | chat | And the payment method is Interac e-Transfer |  |
| CP208 | PAYMENT VALIDATION | payment | chat | And only the customer's email t***@gmail.com is collected (no bank details) |  |
| CP209 | PAYMENT VALIDATION | payment | chat | And the payment email cannot be changed after confirmation |  |
| CP210 | PAYMENT VALIDATION | payment | chat | And Persona IDV returned PASS before claim submission |  |
| CP211 | PAYMENT VALIDATION | payment | chat | And the Comp Status is "Sent for issuance" |  |
| CP212 | PAYMENT VALIDATION | payment | manual | And the batch file is sent to Unifier and EOD report updates only when event occurs |  |
| CP213 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard shows $305.00 CAD, Cash, Interac, t***@gmail.com, status via talkback |  |
| CP214 | EXPECTED RESULTS | verdict | chat | SoC-APPR-EL-01. | SoC-APPR-EL-01. |
| CP215 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP216 | EXPECTED RESULTS | verdict | chat | No travel (origin), Safety. | No travel (origin), Safety. |
| CP217 | EXPECTED RESULTS | verdict | chat | Pax type checked FIRST (Regular), then controllability (Safety). | Pax type checked FIRST (Regular), then controllability (Safety). |
| CP218 | EXPECTED RESULTS | verdict | chat | Full receipt upload + OCR + case creation + notification. | Full receipt upload + OCR + case creation + notification. |
| CP219 | EXPECTED RESULTS | verdict | chat | Entitlements applied per  delay category. | Entitlements applied per  delay category. |
