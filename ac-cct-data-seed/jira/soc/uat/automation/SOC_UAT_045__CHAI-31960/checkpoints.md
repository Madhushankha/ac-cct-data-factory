# SOC_UAT_045 · CHAI-31960 — checkpoints

**Goal:** Verify ELIGIBLE when customer returned to origin,  cancelled, EU.

Methods: seed 16, chat 66, api 21, email 4, dashboard 60, implied 24, manual 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify ELIGIBLE when customer returned to origin,  cancelled, EU. |  |
| CP002 | PREREQUISITES | prerequisite | seed | Regime: EU | Regime: EU |
| CP003 | PREREQUISITES | prerequisite | seed | Carrier: AC (AC 856 CDG?YUL) | Carrier: AC (AC 856 CDG?YUL) |
| CP004 | PREREQUISITES | prerequisite | seed | Promised Itinerary: AC 856 CDG?YUL, Dep: 21-Jun 14:00, Arr: 21-Jun 18:00 | Promised Itinerary: AC 856 CDG?YUL, Dep: 21-Jun 14:00, Arr: 21-Jun 18:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual Itinerary: Flight diverted back to CDG. Flight cancelled. Rebooked next day | Actual Itinerary: Flight diverted back to CDG. Flight cancelled. Rebooked next day |
| CP006 | PREREQUISITES | prerequisite | seed | Delay Length: 960 min (16 hours) | Delay Length: 960 min (16 hours) |
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
| CP023 | START | customer | chat | And the user says ""My flight from Paris to Montreal took off but had to turn around and come back to Paris. The flight was cancelled after  | My flight from Paris to Montreal took off but had to turn around and come back to Paris. The flight was cancelled after we returned. I was stuck at the airport  |
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
| CP043 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 856 Route: Paris Charles de Gaulle (CDG) ? Montreal (YUL) Date: June 21, 2026 Status: DIVERTED � Returned to origin (C |
| CP044 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms ""Yes"" | Yes |
| CP045 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No (single leg) |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU SOC per departing country |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | Departing country: France ? Limitation = 1,825 days (5 years) Days elapsed: Within limitation period ? PROCEED |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Not Completed, Disruption Detected | Trip Not Completed, Disruption Detected |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip CDG?YUL on AC856 was diverted � returned to origin (CDG), then cancelled. Passenger returned to CDG, rebooked 16 hours l | Single-segment trip CDG?YUL on AC856 was diverted � returned to origin (CDG), then cancelled. Passenger returned to CDG, rebooked 16 hours later. |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: EU (CDG departure) | Regime: EU (CDG departure) |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 856, Route: CDG ? YUL, Scheduled Dep: 21-Jun 14:00 | Promised Itinerary � Flight: AC 856, Route: CDG ? YUL, Scheduled Dep: 21-Jun 14:00 |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 856, Route: CDG ? YUL, Status: DIVERTED � Returned to origin (CDG), CANCELLED, rebooked | Current Itinerary � Flight: AC 856, Route: CDG ? YUL, Status: DIVERTED � Returned to origin (CDG), CANCELLED, rebooked |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Diversion + cancellation ? / SOC Segment Delay: 960 min (16h) ? ?2h ? | Diversion + cancellation ? / SOC Segment Delay: 960 min (16h) ? ?2h ? |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Controllability: NOT CHECKED (EU regime) | Controllability: NOT CHECKED (EU regime) |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: �60.00 / ACCOMMODATION: Rate of day (max �500) / GENERAL EXPENSES | PASSENGER: [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: �60.00 / ACCOMMODATION: Rate of day (max �500) / GENERAL EXPENSES: Transport �200 + C |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: GREEN | CyberSource: GREEN |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | Total Approved: �303.00 EUR (Hotel �165 + Meals �55 + Transport �58 + Essentials �25) | Total Approved: �303.00 EUR (Hotel �165 + Meals �55 + Transport �58 + Essentials �25) |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-EU-EL-05 | DDS RESPONSE CODE = SoC-EU-EL-05 |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP072 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening (behind the scenes) |  |
| CP073 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) | ? PROCEED to eligible flow |
| CP074 | ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: ""Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 856 | Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 856 from Paris to Montreal was diverted back to Pari |
| CP075 | ENTITLEMENT DISPLAY | bot | chat | Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, no ACR: | Based on the length of your disruption (16 hours), you may be eligible for reimbursement in the following categories: Meals: up to �60.00 Hotel accommodation: R |
| CP076 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP077 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | And the chatbot displays the receipt upload interface |  |
| CP078 | RECEIPT UPLOAD � WELCOME BACK FLOW | system | implied | And the user uploads receipt images: | Receipt 1: Hotel receipt � �165.00 EUR (1 night near CDG) Receipt 2: Meal receipt � �55.00 EUR (dinner + breakfast + snack) Receipt 3: Taxi receipt � �58.00 EUR |
| CP079 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | Then the system processes uploaded receipts through OCR (Agentic Receipt Reader) | Receipt 1 � Hotel: Line item: Hotel stay, 1 night � �165.00 EUR Date: June 21, 2026 Category: Hotel Within disruption window: YES ? Rate of day comparison: �165 |
| CP080 | RECEIPT VALIDATION SUMMARY | system | implied | Total receipts processed: 4 | Total line items extracted: 7 Items PASSED: 7 / Items FLAGGED: 0 / Items FAILED: 0 |
| CP081 | EXPENSE BREAKDOWN | system | implied | Hotel: �165.00 ? | Meals: �55.00 ? Transport: �58.00 ? Communication: �0.00 (no receipt) Parking: �0.00 (no receipt) Essentials: �25.00 ? TOTAL APPROVED: �303.00 EUR |
| CP082 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system initiates payment processing |  |
| CP083 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP084 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Germany" | Germany |
| CP085 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot responds: "Thank you for confirming. Based on the information provided, here is the total reimbursement you are eligible fo | � Hotel: �165.00 � Meals: �55.00 � Transport: �58.00 � Essentials: �25.00 � Total: �303.00 EUR" |
| CP086 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot responds: "I am able to proceed to payment now. Please note that once you confirm, your reimbursement amount will be finali | I am able to proceed to payment now. Please note that once you confirm, your reimbursement amount will be finalized. Would you like to proceed? |
| CP087 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | And user responds: "Yes" |  |
| CP088 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: | � Country = Germany / Currency = EUR � Payment Method = BSM � Email Payment (EUR) / Processing Channel = HSBC � Payout currency conversion = Not required (EUR ? |
| CP089 | BSM OFFER | bot | chat | Then the chatbot responds: | Before we move forward, please confirm the email address where you'd like to receive your payment and all updates about this case. Would you like to use t***@gm |
| CP090 | BSM OFFER | bot | chat | And the chatbot displays options: | � Yes, confirm this email � Use a different email |
| CP091 | BSM OFFER | customer | chat | And the user selects "Yes, confirm this email" | Yes, confirm this email |
| CP092 | BSM OFFER | bot | chat | Then the chatbot asks: "Great, can you please confirm that we have the right phone number on the file +1***789?" | Great, can you please confirm that we have the right phone number on the file +1***789? |
| CP093 | BSM OFFER | bot | chat | And the chatbot displays options: | � Yes, confirm this phone number � Use a different phone number |
| CP094 | BSM OFFER | customer | chat | And the user selects "Yes, confirm this phone number" | Yes, confirm this phone number |
| CP095 | BSM OFFER | idv | chat | Then system checks if IDV has been done already ? No |  |
| CP096 | IDENTITY VERIFICATION � PERSONA | bot | chat | Then the chatbot responds: | Before we process your payment, we need to verify your identity. You will receive a separate link to complete identity verification through our secure partner. |
| CP097 | IDENTITY VERIFICATION � PERSONA | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP098 | IDENTITY VERIFICATION � PERSONA | idv | chat | And the customer completes identity verification via Persona |  |
| CP099 | IDENTITY VERIFICATION � PERSONA | idv | chat | And Persona returns: IDV PASS |  |
| CP100 | IDENTITY VERIFICATION � PERSONA | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP101 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �303.00 EUR Payment Method: t***@gmail.com After submission, you will receive a confirmation email summarizing your eligibility, claim details a |
| CP102 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP103 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP104 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case in Case Services |  |
| CP105 | CASE CREATION (GLOB-09) | idv | chat | And the case includes: | � DDS response code: SoC-EU-EL-05 � Eligibility: ELIGIBLE / Regime: EU (EC 261/2004) � Departure country: France � Currency: EUR (receipts) ? EUR (threshold) ?  |
| CP106 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP107 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully. Here's a summary: � Case Reference: [Case Number] � Total claim amount: �303.00 EUR � Categories: Hotel (�165.00), M |
| CP108 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP109 | NOTIFICATION | email | email | And an eligible confirmation email is sent to t***@gmail.com |  |
| CP110 | NOTIFICATION | email | email | And the email includes: Case reference number, claim summary (EUR), EU 261/2004 reference, flight details (AC 856 CDG?YUL DIVERTED/CANCELLED |  |
| CP111 | NOTIFICATION | email | email | And a separate email containing the secure BSM payment link is sent to t***@gmail.com |  |
| CP112 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP113 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP114 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-EU-EL-05 � EU Eligible No Travel Returned to Origin CDG Diverted Cancelled |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (Auth Flow 1) |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is NOT greyed out |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "EU (EC 261/2004)" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Regular" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 856 CDG ? YUL as the claimed flight (single leg, 1 segment) |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DIVERTED � Returned to origin (CDG). Flight cancelled. Rebooked next day." |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 856 CDG ? YUL |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 856 |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Flight cancelled (IRRELEVANT under EU SOC)" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 960 min (16 hours) |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "No Travel � Returned to Origin (CDG)" |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PASSED ? (CDG = France, EU origin)" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED (EU regime � controllability irrelevant)" |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Cancellation Check is "CANCELLED ? (flight diverted back + cancelled)" |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Departure Delay is "?2h (16 hours) ?" |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Overnight Eligible is "YES (delay >360 min)" |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the ACR Issued shows Hotel No, Transport No, Meal No |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-EU-EL-05" |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Check Order is: 1. Pax Type ? Regular ? ? 2. No-travel check ? Flight cancelled ? ? Departure delay ?2h ? ? ELIGIBLE |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the key difference from EL-04 is EL-04 stayed at origin (never departed) while EL-05 departed, diverted back, returned to origin � both  |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And under APPR outcome depends on controllability � if uncontrollable (e.g., weather) ? NE-10, if Safety ? EL-03/04 � but under EU eligible  |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Entitlements for 1 adult PY no ACR show Meals $60 (EUR equivalent), Hotel rate of day max 3 nights $500 cap, Transport $200, Communi |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Hotel �165 APPROVED |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Meals �55 APPROVED |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Transport �58 APPROVED |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Essentials �25 APPROVED |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is �303.00 EUR |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource result is "GREEN" |  |
| CP166 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Auto-Append shows the system appended the booking record automatically |  |
| CP167 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligible confirmation email was sent |  |
| CP168 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email contains Case Reference, approved amounts, EU 261/2004, flight details (AC 856 CDG ? YUL DIVERTED/CANCELLED) |  |
| CP169 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Country of Residence is "Germany" with Currency "EUR" |  |
| CP170 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Method is "BSM � Email Payment (EUR)" with Processing Channel "HSBC" |  |
| CP171 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Email is "t***@gmail.com" (confirmed, locked) |  |
| CP172 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is confirmed as "+1***789" |  |
| CP173 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no bank details / IBAN are stored on the case |  |
| CP174 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the IDV result is "Persona PASS (at Payment)" |  |
| CP175 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligible confirmation email (with password) and secure payment link email were sent to "t***@gmail.com" |  |
| CP176 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved" |  |
| CP177 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP178 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-EU-EL-05 � EU Eligible No Travel Returned to Origin CDG � BSM HSBC EUR |  |
| CP179 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-EL-05 is determined as ELIGIBLE |  |
| CP180 | PAYMENT VALIDATION | payment | chat | Then SOC payment is CASH ONLY |  |
| CP181 | PAYMENT VALIDATION | payment | chat | And AC Wallet / e-credit is NOT offered |  |
| CP182 | PAYMENT VALIDATION | payment | chat | And the route is AC 856 CDG ? YUL DIVERTED + CANCELLED for 1 adult PY |  |
| CP183 | PAYMENT VALIDATION | payment | chat | And the approved receipts are Hotel �165, Meals �55, Taxi �58, Essentials �25 totalling �303.00 EUR |  |
| CP184 | PAYMENT VALIDATION | payment | chat | And the country of residence is Germany with currency EUR |  |
| CP185 | PAYMENT VALIDATION | payment | chat | And the payment method is BSM � Email Payment (EUR) processed via HSBC |  |
| CP186 | PAYMENT VALIDATION | payment | chat | And only the customer's email t***@gmail.com and phone confirmation are collected (no bank details / IBAN) |  |
| CP187 | PAYMENT VALIDATION | payment | chat | And the payment email cannot be changed after confirmation |  |
| CP188 | PAYMENT VALIDATION | payment | chat | And Persona IDV returned PASS before claim submission |  |
| CP189 | PAYMENT VALIDATION | payment | chat | And no currency conversion is applied (EUR receipts ? EUR payout) |  |
| CP190 | PAYMENT VALIDATION | payment | chat | And the Comp Status is "Sent for issuance" |  |
| CP191 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard shows �303.00 EUR, Cash, BSM (HSBC), t***@gmail.com, status via talkback |  |
| CP192 | EXPECTED RESULTS | verdict | chat | SoC-EU-EL-05. | SoC-EU-EL-05. |
| CP193 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP194 | EXPECTED RESULTS | verdict | chat | No travel (return), flight cancelled. | No travel (return), flight cancelled. |
| CP195 | EXPECTED RESULTS | verdict | chat | Controllability NOT checked. | Controllability NOT checked. |
| CP196 | EXPECTED RESULTS | verdict | chat | Full receipt + case flow. | Full receipt + case flow. |
