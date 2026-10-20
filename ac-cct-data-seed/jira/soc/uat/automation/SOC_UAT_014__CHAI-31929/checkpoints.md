# SOC_UAT_014 · CHAI-31929 — checkpoints

**Goal:** Verify eligible when customer at mid-point, did not reach destination, disruption Safety.

Methods: seed 27, chat 68, api 20, email 4, dashboard 49, implied 27, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify eligible when customer at mid-point, did not reach destination, disruption Safety. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Multi-segment | � Itinerary: Multi-segment |
| CP004 | PREREQUISITES | prerequisite | seed | - Segment 1: AC 701 YYZ?YYC, Dep: 12-Jun 07:00 (operated normally) | - Segment 1: AC 701 YYZ?YYC, Dep: 12-Jun 07:00 (operated normally) |
| CP005 | PREREQUISITES | prerequisite | seed | - Segment 2: AC 702 YYC?YVR, Dep: 12-Jun 12:00 (cancelled � mechanical) | - Segment 2: AC 702 YYC?YVR, Dep: 12-Jun 12:00 (cancelled � mechanical) |
| CP006 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 702 YYC?YVR (Segment 2 � the cancelled segment) | � SOC Segment (per SoC Flight Identifier): AC 702 YYC?YVR (Segment 2 � the cancelled segment) |
| CP007 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: | � Promised Itinerary: |
| CP008 | PREREQUISITES | prerequisite | seed | - Seg 1: AC 701 YYZ?YYC, Dep: 12-Jun 07:00 | - Seg 1: AC 701 YYZ?YYC, Dep: 12-Jun 07:00 |
| CP009 | PREREQUISITES | prerequisite | seed | - Seg 2: AC 702 YYC?YVR, Dep: 12-Jun 12:00 | - Seg 2: AC 702 YYC?YVR, Dep: 12-Jun 12:00 |
| CP010 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 701 completed. AC 702 cancelled (mechanical). Stranded at YYC. Rebooked next day | � Actual Itinerary: AC 701 completed. AC 702 cancelled (mechanical). Stranded at YYC. Rebooked next day |
| CP011 | PREREQUISITES | prerequisite | seed | � Departure Delay on SOC Segment: 840 min (14 hours) | � Departure Delay on SOC Segment: 840 min (14 hours) |
| CP012 | PREREQUISITES | prerequisite | seed | � Departure delay code on SOC Segment: 44 (Spares and Maintenance Equipment � Safety)� Safety | � Departure delay code on SOC Segment: 44 (Spares and Maintenance Equipment � Safety)� Safety |
| CP013 | PREREQUISITES | prerequisite | seed | � Controllability: Safety (Code 44) | � Controllability: Safety (Code 44) |
| CP014 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular (Note: J cabin exception pax would skip controllability, but outcome is same � ELIGIBLE either way for Safety) | � Passenger Type: Regular (Note: J cabin exception pax would skip controllability, but outcome is same � ELIGIBLE either way for Safety) |
| CP015 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Regular ? ? 2. Controllability ? Safety ? ELIGIBLE | � Check Order: 1. Pax Type ? Regular ? ? 2. Controllability ? Safety ? ELIGIBLE |
| CP016 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult | � PAX Count: 1 adult |
| CP017 | PREREQUISITES | prerequisite | seed | � Class of Booking: J (Business) | � Class of Booking: J (Business) |
| CP018 | PREREQUISITES | prerequisite | seed | � Revenue Booking: YES | � Revenue Booking: YES |
| CP019 | PREREQUISITES | prerequisite | seed | � ACR Issued: Hotel: No, Transport: No, Meal: No | � ACR Issued: Hotel: No, Transport: No, Meal: No |
| CP020 | PREREQUISITES | prerequisite | seed | � Journey Completed: > 72h | � Journey Completed: > 72h |
| CP021 | PREREQUISITES | prerequisite | seed | � J CABIN MEAL NOTE: J cabin passengers receive meal entitlement at standard CCT rate ($60 for ). Business and economy currently have the sa | � J CABIN MEAL NOTE: J cabin passengers receive meal entitlement at standard CCT rate ($60 for ). Business and economy currently have the same CCT meal allowanc |
| CP022 | PREREQUISITES | prerequisite | seed | � ENTITLEMENTS (, 1 adult, J class, no ACR): | � ENTITLEMENTS (, 1 adult, J class, no ACR): |
| CP023 | PREREQUISITES | prerequisite | seed | - Meals: $60/pax (J cabin � same CCT rate as economy currently) | - Meals: $60/pax (J cabin � same CCT rate as economy currently) |
| CP024 | PREREQUISITES | prerequisite | seed | - Hotel: Rate of day, 3 nights max, $500 cap | - Hotel: Rate of day, 3 nights max, $500 cap |
| CP025 | PREREQUISITES | prerequisite | seed | - Transport: $200 (1 pax) | - Transport: $200 (1 pax) |
| CP026 | PREREQUISITES | prerequisite | seed | - Communication: $30/pax | - Communication: $30/pax |
| CP027 | PREREQUISITES | prerequisite | seed | - Parking: $50, 1 day max | - Parking: $50, 1 day max |
| CP028 | PREREQUISITES | prerequisite | seed | - Essentials: $30/pax | - Essentials: $30/pax |
| CP029 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP030 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP031 | START | customer | chat | Then user selects English |  |
| CP032 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP033 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP034 | START | customer | chat | And the user says "I was on a connecting flight. My first leg from Toronto to Calgary was fine, but my second leg from Calgary to Vancouver  | I was on a connecting flight. My first leg from Toronto to Calgary was fine, but my second leg from Calgary to Vancouver was cancelled because of a mechanical i |
| CP035 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP036 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP037 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP038 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP039 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP040 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP041 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP042 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP043 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP044 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP045 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP046 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP047 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP048 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP049 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP050 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP051 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP052 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP053 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP054 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 701 ? AC 702 � Route: Toronto (YYZ) ? Calgary (YYC) ? Vancouver (YVR) � Date: June 12, 2026 � Segment 1: AC 701 YYZ? |
| CP055 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP056 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? Yes (2 segments) |  |
| CP057 | SEGMENT SELECTION (GenUC-18a) | bot | chat | Then the chatbot displays the segment(s) associated with the selected journey: | Which segment was affected by the disruption? � Segment 1: AC 701 YYZ?YYC (Operated normally) � Segment 2: AC 702 YYC?YVR (Cancelled � Mechanical) |
| CP058 | SEGMENT SELECTION (GenUC-18a) | customer | chat | And the user selects "Segment 2: AC 702 YYC?YVR" | Segment 2: AC 702 YYC?YVR |
| CP059 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP060 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + segment combination |  |
| CP061 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP062 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP063 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR SOC per province |  |
| CP064 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Origin: YYZ (Ontario) ? Limitation = 730 days � Destination: YVR (British Columbia) ? Limitation = 1,095 days � Days elapsed: Within limitation period ? PROCE |
| CP065 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP066 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP067 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Not Completed, Disruption Detected | Trip Not Completed, Disruption Detected |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | Multi-segment domestic trip YYZ?YYC?YVR � Segment 2 AC702 YYC?YVR was cancelled due to mechanical/safety issue (Code 44). Passenger stranded | Multi-segment domestic trip YYZ?YYC?YVR � Segment 2 AC702 YYC?YVR was cancelled due to mechanical/safety issue (Code 44). Passenger stranded at YYC. |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 2 | PASSENGERS: 1 � SEGMENTS: 2 |
| CP073 | TRIP TRACER UI VALIDATIONS | verdict | api | Class of Booking: J (Business) | Class of Booking: J (Business) |
| CP074 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Seg 1: AC 701, YYZ ? YYC, Dep: 12-Jun 07:00 / Seg 2: AC 702, YYC ? YVR, Dep: 12-Jun 12:00 | Promised Itinerary � Seg 1: AC 701, YYZ ? YYC, Dep: 12-Jun 07:00 / Seg 2: AC 702, YYC ? YVR, Dep: 12-Jun 12:00 |
| CP075 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Seg 1: AC 701, YYZ ? YYC, Status: ON TIME / Seg 2: AC 702, YYC ? YVR, Status: CANCELLED | Current Itinerary � Seg 1: AC 701, YYZ ? YYC, Status: ON TIME / Seg 2: AC 702, YYC ? YVR, Status: CANCELLED |
| CP076 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present � SOC Segment: AC 702 YYC?YVR | SOC section present � SOC Segment: AC 702 YYC?YVR |
| CP077 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 44 (Spares and Maintenance Equipment) � Safety | Departure Delay Code: 44 (Spares and Maintenance Equipment) � Safety |
| CP078 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: $60.00 (J cabin � same CCT rate) / ACCOMMODATION: Rate of day (ma | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: $60.00 (J cabin � same CCT rate) / ACCOMMODATION: Rate of day (max $500) / GENERAL EX |
| CP079 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: GREEN | CyberSource: GREEN |
| CP080 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE |
| CP081 | TRIP TRACER UI VALIDATIONS | verdict | api | Total Approved: $353.00 CAD (Hotel $210 + Meals $55 + Transport $60 + Essentials $28) | Total Approved: $353.00 CAD (Hotel $210 + Meals $55 + Transport $60 + Essentials $28) |
| CP082 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-APPR-EL-05 | DDS RESPONSE CODE = SoC-APPR-EL-05 |
| CP083 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP084 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger) |  |
| CP085 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates the claim |  |
| CP086 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) | ? PROCEED to eligible flow |
| CP087 | ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your connecting fli | Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your connecting flight AC 702 from Calgary to Vancouver was cancell |
| CP088 | ENTITLEMENT DISPLAY | bot | chat | Then the chatbot displays the eligible expense categories based on  delay, 1 adult, J class, no ACR: | Based on the length of your disruption (14 hours), you may be eligible for reimbursement in the following categories: � Meals: up to $60.00 � Hotel accommodatio |
| CP089 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP090 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | And the chatbot displays the receipt upload interface |  |
| CP091 | RECEIPT UPLOAD � WELCOME BACK FLOW | system | implied | And the user uploads receipt images: | � Receipt 1: Hotel receipt � $210.00 CAD (1 night at Calgary) � Receipt 2: Meal receipt � $55.00 CAD (dinner + breakfast) � Receipt 3: Taxi receipt � $60.00 CAD |
| CP092 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | Then the system processes uploaded receipts through OCR (Agentic Receipt Reader) |  |
| CP093 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | And the OCR engine extracts line items from each receipt: | Receipt 1 � Hotel: � Line item: Hotel stay, 1 night � $210.00 CAD � Date: June 12, 2026 � Category: Hotel � Within disruption window: YES ? � Rate of day compar |
| CP094 | RECEIPT VALIDATION SUMMARY | system | implied | Then the system displays the OCR validation summary: | � Total receipts processed: 4 � Total line items extracted: 6 � Items PASSED: 6 � Items FLAGGED for agent review: 0 � Items FAILED: 0 |
| CP095 | EXPENSE BREAKDOWN | system | implied | � Hotel: $210.00 ? | � Meals: $55.00 ? � Transport: $60.00 ? � Communication: $0.00 (no receipt submitted) � Parking: $0.00 (no receipt submitted) � Essentials: $28.00 ? � TOTAL APP |
| CP096 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP097 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP098 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP099 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP100 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP101 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $353.00 CAD compensation. Please note that it will take 5 to 10 business days to p | You are entitled to receive a $353.00 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP102 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP103 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP104 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac (CANADA) |  |
| CP105 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP106 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP107 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP108 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP109 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP110 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP111 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP112 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP113 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP114 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP115 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP116 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP117 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP118 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $353.00 CAD Payment Method: t***@gmail.com After submission, you will receive a confirmation email summarizing your eligibility, claim details a |
| CP119 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP120 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP121 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case in Case Services |  |
| CP122 | CASE CREATION (GLOB-09) | idv | chat | And the case includes: | � DDS response code: SoC-APPR-EL-05 � Eligibility: ELIGIBLE � Regime: APPR � Class of Booking: J (Business) � All approved line items with amounts � Receipt ima |
| CP123 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP124 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully. Here's a summary: � Case Reference: [Case Number] � Total claim amount: $353.00 CAD � Categories: Hotel ($210.00), M |
| CP125 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP126 | NOTIFICATION | email | email | And an eligible confirmation email is sent to the passenger at t***@gmail.com |  |
| CP127 | NOTIFICATION | email | email | And the email includes: | � Case reference number � Claim summary with approved amounts � Next steps for payment � Password required to access the secure payment link |
| CP128 | NOTIFICATION | email | email | And a separate email containing the secure Interac payment link is sent to t***@gmail.com |  |
| CP129 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP130 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP131 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-EL-05 � Safety Incomplete Journey J Class Eligible |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 701 ? AC 702 YYZ ? YYC ? YVR with claim filed for segment AC 702 YYC ? YVR |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 1 AC 701 YYZ ? YYC is "Operated normally" |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Segment 2 AC 702 YYC ? YVR is "CANCELLED (Mechanical) � Disrupted segment" |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 701 ? AC 702 YYZ ? YYC ? YVR |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 702 YYC ? YVR |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Spares and Maintenance Equipment (Code 44 � Safety)" |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 840 min (14 hours) |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "No Travel � Incomplete Journey (stranded at YYC)" |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "Safety" |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" (checked FIRST) |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "J (Business)" |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-EL-05" |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Entitlements for 1 adult J class no ACR show Meals $60/pax, Hotel rate of day 3 nights max $500 cap, Transport $200, Communication $ |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Hotel $210.00 APPROVED (1 night Calgary, within rate of day, <$500 cap) |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Meals $55.00 APPROVED (dinner $32 + breakfast $23, ?$60 J class) |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Transport $60.00 APPROVED (taxi airport?hotel, ?$200) |  |
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Communication $0.00 No receipt |  |
| CP166 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Parking $0.00 No receipt |  |
| CP167 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Essentials $28.00 APPROVED (toiletries, ?$30) |  |
| CP168 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is $353.00 CAD |  |
| CP169 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 0 |  |
| CP170 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "$353.00 CAD (APPR � Suggested Highlighted)" |  |
| CP171 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP172 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource result is "GREEN" |  |
| CP173 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligible confirmation email was sent |  |
| CP174 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email contains $353.00 CAD, category breakdown, and J class noted |  |
| CP175 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Country of Residence is "Canada" with Currency "CAD" |  |
| CP176 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Method is "Interac e-Transfer" |  |
| CP177 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Email is "t***@gmail.com" (confirmed, locked) |  |
| CP178 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no bank details are stored on the case |  |
| CP179 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the IDV result is "Persona PASS (at Payment)" |  |
| CP180 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the secure payment link email and password were sent to "t***@gmail.com" |  |
| CP181 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved" |  |
| CP182 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP183 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-EL-05 � Safety Incomplete Journey J Class Eligible |  |
| CP184 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-EL-05 is determined as ELIGIBLE |  |
| CP185 | PAYMENT VALIDATION | payment | chat | Then SOC payment is CASH ONLY |  |
| CP186 | PAYMENT VALIDATION | payment | chat | And AC Wallet / e-credit is NOT offered |  |
| CP187 | PAYMENT VALIDATION | payment | chat | And the route is AC 701 ? AC 702 YYZ ? YYC ? YVR (stranded at YYC) for 1 adult J class |  |
| CP188 | PAYMENT VALIDATION | payment | chat | And the approved receipts are Hotel $210, Meals $55, Taxi $60, Essentials $28 totalling $353.00 CAD |  |
| CP189 | PAYMENT VALIDATION | payment | chat | And the country of residence is Canada with currency CAD |  |
| CP190 | PAYMENT VALIDATION | payment | chat | And the payment method is Interac e-Transfer |  |
| CP191 | PAYMENT VALIDATION | payment | chat | And only the customer's email t***@gmail.com is collected (no bank details) |  |
| CP192 | PAYMENT VALIDATION | payment | chat | And Persona IDV returned PASS before claim submission |  |
| CP193 | PAYMENT VALIDATION | payment | chat | And the Comp Status is "Sent for issuance" |  |
| CP194 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard shows $353.00 CAD, Cash, Interac, t***@gmail.com, status via talkback |  |
| CP195 | EXPECTED RESULTS | verdict | chat | SoC-APPR-EL-05. | SoC-APPR-EL-05. |
| CP196 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP197 | EXPECTED RESULTS | verdict | chat | No travel (incomplete), Safety. | No travel (incomplete), Safety. |
| CP198 | EXPECTED RESULTS | verdict | chat | J class entitlements applied. | J class entitlements applied. |
| CP199 | EXPECTED RESULTS | verdict | chat | Full receipt + case flow. | Full receipt + case flow. |
