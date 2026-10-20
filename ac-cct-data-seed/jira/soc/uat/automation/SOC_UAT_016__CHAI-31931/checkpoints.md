# SOC_UAT_016 · CHAI-31931 — checkpoints

**Goal:** Verify eligible when transit delay ?2h is within carrier control under APPR.

Methods: seed 13, chat 69, api 19, email 4, dashboard 52, implied 28, manual 5, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify eligible when transit delay ?2h is within carrier control under APPR. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 301 YYZ?YVR | � Itinerary: Single segment � AC 301 YYZ?YVR |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 301 YYZ?YVR | � SOC Segment (per SoC Flight Identifier): AC 301 YYZ?YVR |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 301 YYZ?YVR, Dep: 15-Jun 08:00 | � Promised Itinerary: AC 301 YYZ?YVR, Dep: 15-Jun 08:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 301 YYZ?YVR, Dep: 15-Jun 15:00 | � Actual Itinerary: AC 301 YYZ?YVR, Dep: 15-Jun 15:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 420 min (7 hours) | � Departure Delay: 420 min (7 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 64 (Flight Crew Shortage) � Controllable | � Departure delay code: 64 (Flight Crew Shortage) � Controllable |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Controllable (Code 64) | � Controllability: Controllable (Code 64) |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular (non-exception) | � Passenger Type: Regular (non-exception) |
| CP011 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Regular ? ? 2. Controllability ? Controllable ? ? ELIGIBLE | � Check Order: 1. Pax Type ? Regular ? ? 2. Controllability ? Controllable ? ? ELIGIBLE |
| CP012 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / ACR: No / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: YES / ACR: No / Journey: > 72h |
| CP013 | PREREQUISITES | prerequisite | seed | � Overnight Eligible: YES (delay >360 min) | � Overnight Eligible: YES (delay >360 min) |
| CP014 | PREREQUISITES | prerequisite | seed | � ENTITLEMENTS (, 1 adult, PY, no ACR): Meals: $30 / Hotel: Rate of day, 3 nights max, $500 cap / Transport: $200 / Communication: $30 / Par | � ENTITLEMENTS (, 1 adult, PY, no ACR): Meals: $30 / Hotel: Rate of day, 3 nights max, $500 cap / Transport: $200 / Communication: $30 / Parking: $50 / Essentia |
| CP015 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP016 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP017 | START | customer | chat | Then user selects English |  |
| CP018 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP019 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP020 | START | customer | chat | And the user says "My Air Canada flight from Toronto to Vancouver was delayed by about 7 hours because of a crew scheduling issue. I had to  | My Air Canada flight from Toronto to Vancouver was delayed by about 7 hours because of a crew scheduling issue. I had to buy meals, pay for a hotel overnight, a |
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
| CP040 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 301 � Route: Toronto (YYZ) ? Vancouver (YVR) � Date: June 14, 2026 � Departure Delay: 7 hours Is this the journey yo |
| CP041 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP045 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP046 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP047 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR SOC per province |  |
| CP048 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Origin: YYZ (Ontario) ? Limitation = 730 days � Destination: YVR (British Columbia) ? Limitation = 1,095 days � Days elapsed: Within limitation period ? PROCE |
| CP049 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP050 | TRIAGE AND DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP051 | TRIAGE AND DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP052 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP053 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment domestic trip YYZ?YVR on AC301 was delayed +7H 00M due to crew shortage (controllable) | Single-segment domestic trip YYZ?YVR on AC301 was delayed +7H 00M due to crew shortage (controllable) |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 301, Route: YYZ ? YVR, Scheduled Dep: 15-Jun 08:00 | Promised Itinerary � Flight: AC 301, Route: YYZ ? YVR, Scheduled Dep: 15-Jun 08:00 |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 301, Route: YYZ ? YVR, Status: ARRIVED LATE, Scheduled Dep: 08:00 ? Actual: 15:00, Delay: +7H 00M | Current Itinerary � Flight: AC 301, Route: YYZ ? YVR, Status: ARRIVED LATE, Scheduled Dep: 08:00 ? Actual: 15:00, Delay: +7H 00M |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 64 (Flight Crew Shortage) � Controllable | Departure Delay Code: 64 (Flight Crew Shortage) � Controllable |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: $30.00 / ACCOMMODATION: Rate of day (max $500) / GENERAL EXPENSES | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: $30.00 / ACCOMMODATION: Rate of day (max $500) / GENERAL EXPENSES: Transport $200 + C |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: GREEN | CyberSource: GREEN |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Total Approved: $255.00 CAD (Hotel $165 + Meals $25 + Transport $50 + Comm $15) | Total Approved: $255.00 CAD (Hotel $165 + Meals $25 + Transport $50 + Comm $15) |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-APPR-EL-08 | DDS RESPONSE CODE = SoC-APPR-EL-08 |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP067 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger) |  |
| CP068 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates the claim |  |
| CP069 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) | ? PROCEED to eligible flow |
| CP070 | ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 301  | Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 301 from Toronto to Vancouver was delayed by approxi |
| CP071 | ENTITLEMENT DISPLAY | bot | chat | Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, no ACR: | Based on the length of your disruption (7 hours), you may be eligible for reimbursement in the following categories: � Meals: up to $30.00 � Hotel accommodation |
| CP072 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP073 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | And the chatbot displays the receipt upload interface |  |
| CP074 | RECEIPT UPLOAD � WELCOME BACK FLOW | system | implied | And the user uploads receipt images: | � Receipt 1: Hotel receipt � $165.00 CAD (1 night) � Receipt 2: Meal receipt � $25.00 CAD (dinner) � Receipt 3: Taxi receipt � $50.00 CAD (airport to hotel + ho |
| CP075 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | Then the system processes uploaded receipts through OCR (Agentic Receipt Reader) |  |
| CP076 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | And the OCR engine extracts line items from each receipt: | Receipt 1 � Hotel: � Line item: Hotel stay, 1 night � $165.00 CAD � Date: June 14, 2026 � Category: Hotel � Within disruption window: YES ? � Rate of day compar |
| CP077 | RECEIPT VALIDATION SUMMARY | system | implied | Then the system displays the OCR validation summary: | � Total receipts processed: 4 � Total line items extracted: 5 � Items PASSED: 5 � Items FLAGGED for agent review: 0 � Items FAILED: 0 |
| CP078 | EXPENSE BREAKDOWN | system | implied | � Hotel: $165.00 ? | � Meals: $25.00 ? � Transport: $50.00 ? � Communication: $15.00 ? � Parking: $0.00 (no receipt submitted) � Essentials: $0.00 (no receipt submitted) � TOTAL APP |
| CP079 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP080 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP081 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP082 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? Yes (Super Elite 50K) |  |
| CP083 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | And the system confirms SOC = CASH ONLY ? AC Wallet / e-credit NOT offered |  |
| CP084 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? Yes (2 pax) |  |
| CP085 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $127.00 CAD compensation. Please note that it will take 5 to 10 business days to p | You are entitled to receive a $127.00 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP086 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP087 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP088 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac (CANADA) |  |
| CP089 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP090 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP091 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP092 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP093 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP094 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP095 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP096 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP097 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP098 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP099 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP100 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP101 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP102 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $127.00 CAD Payment Method: t***@gmail.com After submission, you will receive a confirmation email summarizing your eligibility, claim details a |
| CP103 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP104 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP105 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case in Case Services |  |
| CP106 | CASE CREATION (GLOB-09) | idv | chat | And the case includes: | � DDS response code: SoC-APPR-EL-07 � Eligibility: ELIGIBLE � Regime: APPR � Passengers: 2 adults (1 Super Elite 50K + 1 companion) � Exception privilege: Exten |
| CP107 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP108 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully for both passengers. Here's a summary: � Case Reference: [Case Number] � Total claim amount: $127.00 CAD � Categories |
| CP109 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP110 | NOTIFICATION | email | email | And an eligible confirmation email is sent to the passenger at t***@gmail.com |  |
| CP111 | NOTIFICATION | email | email | And the email includes: | � Case reference number � Claim summary with approved amounts � Next steps for payment � Password required to access the secure payment link |
| CP112 | NOTIFICATION | email | email | And a separate email containing the secure Interac payment link is sent to t***@gmail.com |  |
| CP113 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP114 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP115 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-EL-08 � Controllable Overnight Eligible |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Regular" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 301 YYZ ? YVR as the claimed flight |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (7 hours)" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 301 YYZ ? YVR |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 301 |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Flight Crew Shortage (Departure delay code 64 � CONTROLLABLE)" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 420 min (7 hours) |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" (checked FIRST) |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "WITHIN CARRIER CONTROL (Controllable)" (checked SECOND) |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Overnight Eligible is "YES (delay >360 min)" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the ACR Issued shows Hotel No, Transport No, Meal No |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-EL-08" |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Entitlements for 1 adult PY no ACR show Meals $30/pax, Hotel rate of day max 3 nights $500 cap, Transport $200, Communication $30/pa |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Hotel $165.00 APPROVED (1 night, within rate of day, <$500 cap) |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Meals $25.00 APPROVED (dinner, ?$30) |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Transport $50.00 APPROVED (taxi airport?hotel, ?$200) |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Communication $15.00 APPROVED (Wi-Fi, ?$30) |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Parking $0.00 No receipt |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Essentials $0.00 No receipt |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is $255.00 CAD |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 0 |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "$255.00 CAD (APPR � Suggested Highlighted)" |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource result is "GREEN" |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Country of Residence is "Canada" with Currency "CAD" |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Method is "Interac e-Transfer" |  |
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Email is "t***@gmail.com" (confirmed, locked) |  |
| CP166 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no bank details are stored on the case |  |
| CP167 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the IDV result is "Persona PASS (at Payment)" |  |
| CP168 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the secure payment link email and password were sent to "t***@gmail.com" |  |
| CP169 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved" |  |
| CP170 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP171 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-EL-08 � Controllable Overnight Eligible |  |
| CP172 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-EL-08 is determined as ELIGIBLE |  |
| CP173 | PAYMENT VALIDATION | payment | chat | Then SOC payment is CASH ONLY |  |
| CP174 | PAYMENT VALIDATION | payment | chat | And AC Wallet / e-credit is NOT offered |  |
| CP175 | PAYMENT VALIDATION | payment | chat | And the route is AC 301 YYZ ? YVR with delay 420 min (7 hrs) for 1 adult PY |  |
| CP176 | PAYMENT VALIDATION | payment | chat | And the approved receipts are Hotel $165, Meals $25, Taxi $50, Comm $15 totalling $255.00 CAD |  |
| CP177 | PAYMENT VALIDATION | payment | chat | And $255.00 is less than SOC threshold so no approval is needed |  |
| CP178 | PAYMENT VALIDATION | payment | chat | And the country of residence is Canada with currency CAD |  |
| CP179 | PAYMENT VALIDATION | payment | chat | And the payment method is Interac e-Transfer |  |
| CP180 | PAYMENT VALIDATION | payment | chat | And only the customer's email t***@gmail.com is collected (no bank details) |  |
| CP181 | PAYMENT VALIDATION | payment | chat | And Persona IDV returned PASS before claim submission |  |
| CP182 | PAYMENT VALIDATION | payment | chat | And the Comp Status is "Sent for issuance" |  |
| CP183 | PAYMENT VALIDATION | payment | manual | And the compensation record is created and batch file sent to Unifier |  |
| CP184 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard shows $255.00 CAD, Cash, Interac, t***@gmail.com, status via talkback |  |
| CP185 | EXPECTED RESULTS | verdict | chat | SoC-APPR-EL-08. | SoC-APPR-EL-08. |
| CP186 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP187 | EXPECTED RESULTS | verdict | chat | Controllable delay ?2h (7 hours,  category). | Controllable delay ?2h (7 hours,  category). |
| CP188 | EXPECTED RESULTS | verdict | chat | Pax type checked FIRST (Regular), then controllability (Controllable).  correctly identified as AC. | Pax type checked FIRST (Regular), then controllability (Controllable).  correctly identified as AC. |
| CP189 | EXPECTED RESULTS | verdict | chat | Fraud screening GREEN. | Fraud screening GREEN. |
| CP190 | EXPECTED RESULTS | verdict | chat | Entitlements applied per  delay category. | Entitlements applied per  delay category. |
| CP191 | EXPECTED RESULTS | verdict | chat | Full receipt upload + OCR + case creation + notification flow completes. | Full receipt upload + OCR + case creation + notification flow completes. |
