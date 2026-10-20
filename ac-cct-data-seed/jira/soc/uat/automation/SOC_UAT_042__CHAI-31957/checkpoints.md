# SOC_UAT_042 · CHAI-31957 — checkpoints

**Goal:** Verify ELIGIBLE when customer returned to origin,  delay ?2h, EU.

Methods: seed 25, chat 70, api 21, email 4, dashboard 47, implied 25, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify ELIGIBLE when customer returned to origin,  delay ?2h, EU. |  |
| CP002 | PREREQUISITES | prerequisite | seed | Regime: EU | Regime: EU |
| CP003 | PREREQUISITES | prerequisite | seed | Carrier: AC (AC 850 CDG?YUL) | Carrier: AC (AC 850 CDG?YUL) |
| CP004 | PREREQUISITES | prerequisite | seed | Promised Itinerary: AC 850 CDG?YUL, Dep: 19-Jun 09:00, Arr: 19-Jun 13:00 | Promised Itinerary: AC 850 CDG?YUL, Dep: 19-Jun 09:00, Arr: 19-Jun 13:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual Itinerary: Flight diverted back to CDG. Rebooked 8 hours later | Actual Itinerary: Flight diverted back to CDG. Rebooked 8 hours later |
| CP006 | PREREQUISITES | prerequisite | seed | Delay Length: 480 min (8 hours) | Delay Length: 480 min (8 hours) |
| CP007 | PREREQUISITES | prerequisite | seed | Controllability: NOT CHECKED | Controllability: NOT CHECKED |
| CP008 | PREREQUISITES | prerequisite | seed | EU does not evaluate controllability for SOC | EU does not evaluate controllability for SOC |
| CP009 | PREREQUISITES | prerequisite | seed | Departure delay code: 72 (ATC | Departure delay code: 72 (ATC |
| CP010 | PREREQUISITES | prerequisite | seed | IRRELEVANT under EU SOC) | IRRELEVANT under EU SOC) |
| CP011 | PREREQUISITES | prerequisite | seed | Passenger Type: Regular | Passenger Type: Regular |
| CP012 | PREREQUISITES | prerequisite | seed | Check Order: 1. Pax Type ? Regular ? ? 2. No-travel delay check ? ?2h ? ELIGIBLE | Check Order: 1. Pax Type ? Regular ? ? 2. No-travel delay check ? ?2h ? ELIGIBLE |
| CP013 | PREREQUISITES | prerequisite | seed | PAX Count: 2 adults, 2 children | PAX Count: 2 adults, 2 children |
| CP014 | PREREQUISITES | prerequisite | seed | Class of Booking: PY | Class of Booking: PY |
| CP015 | PREREQUISITES | prerequisite | seed | Revenue Booking: YES | Revenue Booking: YES |
| CP016 | PREREQUISITES | prerequisite | seed | ACR Issued: Hotel: No, Transport: No, Meal: No | ACR Issued: Hotel: No, Transport: No, Meal: No |
| CP017 | PREREQUISITES | prerequisite | seed | Journey Completed: > 72h ENTITLEMENTS (, 2 adults + 2 children, PY, no ACR): | Journey Completed: > 72h ENTITLEMENTS (, 2 adults + 2 children, PY, no ACR): |
| CP018 | PREREQUISITES | prerequisite | seed | Meals: $30/pax | Meals: $30/pax |
| CP019 | PREREQUISITES | prerequisite | seed | 4 = $120 | 4 = $120 |
| CP020 | PREREQUISITES | prerequisite | seed | Hotel: Rate of day, 2 rooms (per adult), 3 nights max, $500 cap (if overnight) | Hotel: Rate of day, 2 rooms (per adult), 3 nights max, $500 cap (if overnight) |
| CP021 | PREREQUISITES | prerequisite | seed | Transport: $200 (1-5 pax) | Transport: $200 (1-5 pax) |
| CP022 | PREREQUISITES | prerequisite | seed | Communication: $30/pax | Communication: $30/pax |
| CP023 | PREREQUISITES | prerequisite | seed | 4 = $120 | 4 = $120 |
| CP024 | PREREQUISITES | prerequisite | seed | Parking: $50, 1 day max | Parking: $50, 1 day max |
| CP025 | PREREQUISITES | prerequisite | seed | Essentials: $30/pax | Essentials: $30/pax |
| CP026 | PREREQUISITES | prerequisite | seed | 4 = $120 | 4 = $120 |
| CP027 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP028 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP029 | START | customer | chat | Then user selects English |  |
| CP030 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP031 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP032 | START | customer | chat | And the user says "My flight from Paris to Toronto was cancelled and I never made it to my destination. I was stuck at the airport for about | My flight from Paris to Toronto was cancelled and I never made it to my destination. I was stuck at the airport for about 18 hours. I had to buy meals, pay for  |
| CP033 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP034 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP035 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP036 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP037 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP038 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP039 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP040 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP041 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP042 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP043 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP044 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP045 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP046 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP047 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP048 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP049 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP050 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP051 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP052 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 871 � Route: Paris (CDG) ? Toronto (YYZ) � Date: June 11, 2026 � Status: CANCELLED Is this the journey you'd like to |
| CP053 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP054 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP055 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP056 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP057 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP058 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP059 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU SOC per departing country |  |
| CP060 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Departing country: France ? Limitation = 1,825 days (5 years) � Days elapsed: Within limitation period ? PROCEED |
| CP061 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP063 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Not Completed, Disruption Detected | Trip Not Completed, Disruption Detected |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip CDG?YYZ on AC871 was cancelled � passenger stayed at origin (CDG) for 18 hours | Single-segment trip CDG?YYZ on AC871 was cancelled � passenger stayed at origin (CDG) for 18 hours |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: EU (CDG departure) | Regime: EU (CDG departure) |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 871, Route: CDG ? YYZ, Scheduled Dep: 19-Jun 09:00 | Promised Itinerary � Flight: AC 871, Route: CDG ? YYZ, Scheduled Dep: 19-Jun 09:00 |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 871, Route: CDG ? YYZ, Status: CANCELLED | Current Itinerary � Flight: AC 871, Route: CDG ? YYZ, Status: CANCELLED |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP073 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 77 (Weather) � NOT CHECKED (EU does not evaluate controllability) | Departure Delay Code: 77 (Weather) � NOT CHECKED (EU does not evaluate controllability) |
| CP074 | TRIP TRACER UI VALIDATIONS | verdict | api | Cancellation: YES ? / SOC Segment Delay to rebooking: 1080 min (18h) ? ?2h ? | Cancellation: YES ? / SOC Segment Delay to rebooking: 1080 min (18h) ? ?2h ? |
| CP075 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: �60.00 / ACCOMMODATION: Rate of day (max �500) / GENERAL EXPENSES | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: �60.00 / ACCOMMODATION: Rate of day (max �500) / GENERAL EXPENSES: Transport �200 + C |
| CP076 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: GREEN | CyberSource: GREEN |
| CP077 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE |
| CP078 | TRIP TRACER UI VALIDATIONS | verdict | api | Total Approved: �320.00 EUR (Hotel �175 + Meals �52 + Transport �65 + Essentials �28) | Total Approved: �320.00 EUR (Hotel �175 + Meals �52 + Transport �65 + Essentials �28) |
| CP079 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-EU-EL-02 | DDS RESPONSE CODE = SoC-EU-EL-02 |
| CP080 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP081 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening (behind the scenes) |  |
| CP082 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) | ? PROCEED to eligible flow |
| CP083 | ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 871  | Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 871 from Paris to Toronto was cancelled and you were |
| CP084 | ENTITLEMENT DISPLAY | bot | chat | Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, EU regime: | Based on the length of your disruption (18 hours), you may be eligible for reimbursement in the following categories: � Meals: up to �60.00 � Hotel accommodatio |
| CP085 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP086 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | And the chatbot displays the receipt upload interface |  |
| CP087 | RECEIPT UPLOAD � WELCOME BACK FLOW | system | implied | And the user uploads receipt images: | � Receipt 1: Hotel receipt � �175.00 EUR (1 night near CDG) � Receipt 2: Meal receipt � �52.00 EUR (dinner + breakfast + lunch) � Receipt 3: Taxi receipt � �65. |
| CP088 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | Then the system processes uploaded receipts through OCR (Agentic Receipt Reader) |  |
| CP089 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | And the OCR engine extracts line items from each receipt: | Receipt 1 � Hotel: � Line item: Hotel stay, 1 night � �175.00 EUR � Date: June 11, 2026 � Category: Hotel � Within disruption window: YES ? � Rate of day compar |
| CP090 | RECEIPT VALIDATION SUMMARY | system | implied | Then the system displays the OCR validation summary: | � Total receipts processed: 4 � Total line items extracted: 6 � Items PASSED: 6 � Items FLAGGED for agent review: 0 � Items FAILED: 0 |
| CP091 | EXPENSE BREAKDOWN | system | implied | � Hotel: �175.00 ? | � Meals: �52.00 ? � Transport: �65.00 ? � Communication: �0.00 (no receipt submitted) � Parking: �0.00 (no receipt submitted) � Essentials: �28.00 ? � TOTAL APP |
| CP092 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system initiates payment processing |  |
| CP093 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP094 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Germany" | Germany |
| CP095 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot responds: "Thank you for confirming. Based on the information provided, here is the total reimbursement you are eligible fo | � Hotel: �160.00 � Meals: �48.00 � Transport: �55.00 � Total: �263.00 EUR" |
| CP096 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot responds: "I am able to proceed to payment now. Please note that once you confirm, your reimbursement amount will be finali | I am able to proceed to payment now. Please note that once you confirm, your reimbursement amount will be finalized. Would you like to proceed? |
| CP097 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | And user responds: "Yes" |  |
| CP098 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: | � Country = Germany � Currency = EUR � Payment Method = BSM � Email Payment (EUR) � Processing Channel = HSBC � Payout currency conversion = Not required (EUR ? |
| CP099 | BSM OFFER | bot | chat | Then the chatbot responds: | Before we move forward, please confirm the email address where you'd like to receive your payment and all updates about this case. Would you like to use t***@gm |
| CP100 | BSM OFFER | bot | chat | And the chatbot displays options: | � Yes, confirm this email � Use a different email |
| CP101 | BSM OFFER | customer | chat | And the user selects "Yes, confirm this email" | Yes, confirm this email |
| CP102 | BSM OFFER | bot | chat | Then the chatbot asks: "Great, can you please confirm that we have the right phone number on the file +1***789?" | Great, can you please confirm that we have the right phone number on the file +1***789? |
| CP103 | BSM OFFER | bot | chat | And the chatbot displays options: | � Yes, confirm this phone number � Use a different phone number |
| CP104 | BSM OFFER | customer | chat | And the user selects "Yes, confirm this phone number" | Yes, confirm this phone number |
| CP105 | BSM OFFER | idv | chat | Then system checks if IDV has been done already ? No |  |
| CP106 | IDENTITY VERIFICATION � PERSONA | bot | chat | Then the chatbot responds: | Before we process your payment, we need to verify your identity. You will receive a separate link to complete identity verification through our secure partner. |
| CP107 | IDENTITY VERIFICATION � PERSONA | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP108 | IDENTITY VERIFICATION � PERSONA | customer | chat | And the customer opens the Persona link |  |
| CP109 | IDENTITY VERIFICATION � PERSONA | idv | chat | And the customer completes identity verification via Persona |  |
| CP110 | IDENTITY VERIFICATION � PERSONA | idv | chat | And Persona returns: IDV PASS |  |
| CP111 | IDENTITY VERIFICATION � PERSONA | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP112 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �263.00 EUR Payment Method: t***@gmail.com After submission, you will receive a confirmation email summarizing your eligibility, claim details a |
| CP113 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP114 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP115 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case in Case Services |  |
| CP116 | CASE CREATION (GLOB-09) | idv | chat | And the case includes: | � DDS response code: SoC-EU-EL-03 � Eligibility: ELIGIBLE � Regime: EU (EC 261/2004) � Departure country: Germany � All approved line items with amounts � Recei |
| CP117 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP118 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully. Here's a summary: � Case Reference: [Case Number] � Total claim amount: �263.00 EUR � Categories: Hotel (�160.00), M |
| CP119 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP120 | NOTIFICATION | email | email | And an eligible confirmation email is sent to the passenger at t***@gmail.com |  |
| CP121 | NOTIFICATION | email | email | And the email includes: | � Case reference number � Claim summary with approved amounts (EUR) � Next steps for payment � Password required to access the secure payment link |
| CP122 | NOTIFICATION | email | email | And a separate email containing the secure BSM payment link is sent to t***@gmail.com |  |
| CP123 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP124 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP125 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-EU-EL-02 � EU Eligible No Travel Stayed at Origin Cancelled |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "EU (EC 261/2004)" |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 871 CDG ? YYZ as the claimed flight |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "CANCELLED" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 871 CDG ? YYZ |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 871 |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Weather (Code 77 � IRRELEVANT under EU)" |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 1080 min (18 hours) |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "No Travel � Stayed at Origin (CDG)" |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (CDG = France, EU origin)" |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED (EU regime)" |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Cancellation Check is "CANCELLED ?" |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Departure Delay is "?2h (18 hours) ?" |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-EU-EL-02" |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the same scenario under APPR would be SoC-APPR-NE-08 (NOT ELIGIBLE � weather is uncontrollable) |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Hotel �175.00 APPROVED |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Meals �52.00 APPROVED (dinner �25 + breakfast �15 + lunch �12, ?�60) |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Transport �65.00 APPROVED (?�200) |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Communication �0.00 No receipt |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Parking �0.00 No receipt |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Essentials �28.00 APPROVED (?�30) |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is �320.00 EUR |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 0 |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource result is "GREEN" |  |
| CP166 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Country of Residence is "Germany" with Currency "EUR" |  |
| CP167 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Method is "BSM � Email Payment (EUR)" with Processing Channel "HSBC" |  |
| CP168 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Email is "t***@gmail.com" (confirmed, locked) |  |
| CP169 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is confirmed as "+1***789" |  |
| CP170 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no bank details / IBAN are stored on the case |  |
| CP171 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the IDV result is "Persona PASS (at Payment)" |  |
| CP172 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligible confirmation email (with password) and secure payment link email were sent to "t***@gmail.com" |  |
| CP173 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved" |  |
| CP174 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP175 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-EU-EL-03 � EU Eligible Diverted Return to Origin � BSM HSBC EUR |  |
| CP176 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-EL-03 is determined as ELIGIBLE |  |
| CP177 | PAYMENT VALIDATION | payment | chat | Then SOC payment is CASH ONLY |  |
| CP178 | PAYMENT VALIDATION | payment | chat | And AC Wallet / e-credit is NOT offered |  |
| CP179 | PAYMENT VALIDATION | payment | chat | And the route is AC 837 FRA ? YYZ (diverted back to FRA) with delay 840 min (14 hrs) for 1 adult |  |
| CP180 | PAYMENT VALIDATION | payment | chat | And the approved receipts are Hotel �160, Meals �48, Taxi �55 totalling �263.00 EUR |  |
| CP181 | PAYMENT VALIDATION | payment | chat | And the country of residence is Germany with currency EUR |  |
| CP182 | PAYMENT VALIDATION | payment | chat | And the payment method is BSM � Email Payment (EUR) processed via HSBC |  |
| CP183 | PAYMENT VALIDATION | payment | chat | And only the customer's email t***@gmail.com and phone confirmation are collected (no bank details) |  |
| CP184 | PAYMENT VALIDATION | payment | chat | And the payment email cannot be changed after confirmation |  |
| CP185 | PAYMENT VALIDATION | payment | chat | And Persona IDV returned PASS before claim submission |  |
| CP186 | PAYMENT VALIDATION | payment | chat | And no payout currency conversion is applied (EUR ? EUR) |  |
| CP187 | PAYMENT VALIDATION | payment | chat | And no approval is needed |  |
| CP188 | PAYMENT VALIDATION | payment | chat | And the Comp Status is "Sent for issuance" |  |
| CP189 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard shows �263.00 EUR, Cash, BSM (HSBC), t***@gmail.com, status via talkback |  |
| CP190 | EXPECTED RESULTS | verdict | chat | SoC-EU-EL-02. | SoC-EU-EL-02. |
| CP191 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP192 | EXPECTED RESULTS | verdict | chat | No travel (return), delay ?2h. | No travel (return), delay ?2h. |
| CP193 | EXPECTED RESULTS | verdict | chat | Controllability NOT checked. | Controllability NOT checked. |
| CP194 | EXPECTED RESULTS | verdict | chat | Hotel: 2 rooms (per adult). | Hotel: 2 rooms (per adult). |
| CP195 | EXPECTED RESULTS | verdict | chat | Entitlements per  for 4 passengers. | Entitlements per  for 4 passengers. |
| CP196 | EXPECTED RESULTS | verdict | chat | Full receipt + case flow. | Full receipt + case flow. |
