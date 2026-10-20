# SOC_UAT_077 · CHAI-31992 — checkpoints

**Goal:** Verify that when an emergency override results in Pay, the system returns ELIGIBLE per override amounts and proceeds to full receipt upload and case creation.

Methods: seed 14, chat 56, api 34, email 5, dashboard 36, implied 38, manual 5, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify that when an emergency override results in Pay, the system returns ELIGIBLE per override amounts and proceeds to full receipt upload  |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: ANY (Override applies across all regimes) | � Regime: ANY (Override applies across all regimes) |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 201 YYZ?YYC | � Itinerary: Single segment � AC 201 YYZ?YYC |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 201 YYZ?YYC | � SOC Segment (per SoC Flight Identifier): AC 201 YYZ?YYC |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 201 YYZ?YYC, Dep: 27-Jun 07:00 | � Promised Itinerary: AC 201 YYZ?YYC, Dep: 27-Jun 07:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 201 YYZ?YYC, Dep: 27-Jun 15:00 | � Actual Itinerary: AC 201 YYZ?YYC, Dep: 27-Jun 15:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 480 min (8 hours) | � Departure Delay: 480 min (8 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Original Departure delay code: 77 (Weather) � originally coded as weather | � Original Departure delay code: 77 (Weather) � originally coded as weather |
| CP009 | PREREQUISITES | prerequisite | seed | � Corrected Departure delay code (post-override): 64 (Flight Crew Shortage) � Controllable � investigation reveals weather code was incorrec | � Corrected Departure delay code (post-override): 64 (Flight Crew Shortage) � Controllable � investigation reveals weather code was incorrectly assigned; actual |
| CP010 | PREREQUISITES | prerequisite | seed | � Override Status: RESOLVED � Pay | � Override Status: RESOLVED � Pay |
| CP011 | PREREQUISITES | prerequisite | seed | � Override Reason: Departure delay code was MISCLASSIFIED. Weather (77) was incorrectly assigned; actual cause was Flight Crew Shortage (64  | � Override Reason: Departure delay code was MISCLASSIFIED. Weather (77) was incorrectly assigned; actual cause was Flight Crew Shortage (64 � Controllable). Age |
| CP012 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP013 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Normal DDS ? NE-07 (weather, regular pax) ? 2. Dispute ? 3. Agent investigation ? 4. Override APPROVED ? PAY ? ELIGIBLE | � Check Order: 1. Normal DDS ? NE-07 (weather, regular pax) ? 2. Dispute ? 3. Agent investigation ? 4. Override APPROVED ? PAY ? ELIGIBLE |
| CP014 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / ACR: No / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: YES / ACR: No / Journey: > 72h |
| CP015 | PREREQUISITES | prerequisite | seed | � ENTITLEMENTS (, standard APPR � post-override): Meals $30 / Hotel: Rate of day, $500 cap / Transport $200 / Communication $30 / Parking $5 | � ENTITLEMENTS (, standard APPR � post-override): Meals $30 / Hotel: Rate of day, $500 cap / Transport $200 / Communication $30 / Parking $50 / Essentials $30 |
| CP016 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP017 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP018 | START | customer | chat | Then user selects English |  |
| CP019 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP020 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP021 | START | customer | chat | And the user says "My Air Canada flight from Toronto to Calgary was delayed by about 6 hours. The airline says it was weather but I was at t | My Air Canada flight from Toronto to Calgary was delayed by about 6 hours. The airline says it was weather but I was at the airport and the weather was perfectl |
| CP022 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP023 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP024 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP037 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP039 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP041 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 201 � Route: Toronto (YYZ) ? Calgary (YYC) � Date: June 3, 2026 � Departure Delay: 6 hours Is this the journey you'd |
| CP042 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP046 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP047 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP048 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR SOC per province |  |
| CP049 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Origin: YYZ (Ontario) ? Limitation = 730 days � Destination: YYC (Alberta) ? Limitation = 730 days � Days elapsed: 6 days ? Within limitation period ? PROCEED |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP051 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP053 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected � DISPUTED ? OVERRIDE APPROVED (PAY) | Trip Completed, Disruption Detected � DISPUTED ? OVERRIDE APPROVED (PAY) |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment domestic trip YYZ?YYC on AC201 was delayed +8H 00M (note: prereqs say 8h/480 min, chatbot says 6h � use prereqs: 8h for Trip  | Single-segment domestic trip YYZ?YYC on AC201 was delayed +8H 00M (note: prereqs say 8h/480 min, chatbot says 6h � use prereqs: 8h for Trip Tracer, chatbot disp |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: APPR | Regime: APPR |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 201, Route: YYZ ? YYC, Scheduled Dep: 27-Jun 07:00 | Promised Itinerary � Flight: AC 201, Route: YYZ ? YYC, Scheduled Dep: 27-Jun 07:00 |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 201, Route: YYZ ? YYC, Status: ARRIVED LATE, Scheduled Dep: 07:00 ? Actual: 15:00, Delay: +8H 00M | Current Itinerary � Flight: AC 201, Route: YYZ ? YYC, Status: ARRIVED LATE, Scheduled Dep: 07:00 ? Actual: 15:00, Delay: +8H 00M |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Original Departure Delay Code: 77 (Weather) � Uncontrollable | Original Departure Delay Code: 77 (Weather) � Uncontrollable |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Original DDS: SoC-APPR-NE-07 (NOT ELIGIBLE � weather, regular pax) | Original DDS: SoC-APPR-NE-07 (NOT ELIGIBLE � weather, regular pax) |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE (original) | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE (original) |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Dispute Flag: YES | Dispute Flag: YES |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Dispute Reason: Passenger disputes weather classification � claims weather was clear, other airlines operating normally | Dispute Reason: Passenger disputes weather classification � claims weather was clear, other airlines operating normally |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | Override Status: APPROVED ? | Override Status: APPROVED ? |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | Override Decision: PAY | Override Decision: PAY |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | Override Reason: "Departure delay code 77 (Weather) was incorrectly assigned. Investigation confirms clear weather at YYZ on Jun 27, 2026. O | Override Reason: "Departure delay code 77 (Weather) was incorrectly assigned. Investigation confirms clear weather at YYZ on Jun 27, 2026. Other carriers operat |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | Corrected Departure Delay Code: 64 (Flight Crew Shortage) � Controllable | Corrected Departure Delay Code: 64 (Flight Crew Shortage) � Controllable |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | Original DDS Code: SoC-APPR-NE-07 (NOT ELIGIBLE) | Original DDS Code: SoC-APPR-NE-07 (NOT ELIGIBLE) |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | Overridden DDS Code: SoC-APPR-EL-08 (ELIGIBLE � controllable, transit delay ?2h) | Overridden DDS Code: SoC-APPR-EL-08 (ELIGIBLE � controllable, transit delay ?2h) |
| CP073 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: ELIGIBLE (overridden) / BAND: DELAY_6_HOURS_OR_MORE / MEAL: $30.00 / ACCOMMODATION: Rate of day (max $500) / GEN | PASSENGER: [Name] / STATUS: ELIGIBLE (overridden) / BAND: DELAY_6_HOURS_OR_MORE / MEAL: $30.00 / ACCOMMODATION: Rate of day (max $500) / GENERAL EXPENSES: Trans |
| CP074 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: GREEN (post-override) | CyberSource: GREEN (post-override) |
| CP075 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE (Override Approved � Pay) | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE (Override Approved � Pay) |
| CP076 | TRIP TRACER UI VALIDATIONS | verdict | api | Total Approved: $243.00 CAD (Hotel $170 + Meals $28 + Transport $45) | Total Approved: $243.00 CAD (Hotel $170 + Meals $28 + Transport $45) |
| CP077 | TRIP TRACER UI VALIDATIONS | verdict | api | Receipt Validation: 3 receipts processed, 4 line items, all PASSED, 0 flagged, 0 failed | Receipt Validation: 3 receipts processed, 4 line items, all PASSED, 0 flagged, 0 failed |
| CP078 | TRIP TRACER UI VALIDATIONS | verdict | api | Payment: Canada ? EFT ? $243.00 CAD | Payment: Canada ? EFT ? $243.00 CAD |
| CP079 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-APPR-NE-07 | DDS RESPONSE CODE = SoC-APPR-NE-07 |
| CP080 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP081 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. Unfortunately, your flight AC 201 from Toronto to Calgary was delayed  | I've reviewed the details of your flight. Unfortunately, your flight AC 201 from Toronto to Calgary was delayed due to weather conditions, which is classified a |
| CP082 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP083 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Dispute" | Dispute |
| CP084 | DISPUTE FLOW | bot | chat | Then the chatbot responds: "We understand. Your dispute has been recorded and a case has been created for our team to review manually. You w | We understand. Your dispute has been recorded and a case has been created for our team to review manually. You will receive an update once our team has complete |
| CP085 | CASE CREATION WITH DISPUTE FLAG | system | implied | Then the system creates a case in Case Services |  |
| CP086 | CASE CREATION WITH DISPUTE FLAG | system | implied | And the case includes: | � DDS response code: SoC-APPR-NE-07 � Original eligibility: NOT ELIGIBLE � Dispute flag: YES � Dispute reason: Passenger disputes weather classification � claim |
| CP087 | CASE CREATION WITH DISPUTE FLAG | system | implied | And the case is assigned to the manual handling queue |  |
| CP088 | CASE CREATION WITH DISPUTE FLAG | system | implied | And the case reference number is provided to the passenger |  |
| CP089 | CASE CREATION WITH DISPUTE FLAG | system | implied | Then the chatbot provides: | "Your dispute reference number is: [Case Number]. You will receive an email confirmation shortly." |
| CP090 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP091 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP092 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP093 | AGENT OVERRIDE FLOW � OVERRIDE APPROVED | system | implied | When the agent opens the case in Claims Dashboard |  |
| CP094 | AGENT OVERRIDE FLOW � OVERRIDE APPROVED | system | implied | Then the agent reviews: | � Original DDS determination: SoC-APPR-NE-07 (NOT ELIGIBLE � weather) � Passenger dispute: Claims weather was fine at airport, other airlines operating normally |
| CP095 | OVERRIDE DECISION � PAY | system | implied | Then the agent determines: Override APPROVED � original determination overridden | � Departure delay code 77 (Weather) was INCORRECTLY assigned � Actual cause: Crew scheduling (Code 41) � CONTROLLABLE � Weather reports confirm clear conditions |
| CP096 | OVERRIDE DECISION � PAY | system | implied | Then the agent updates the case: | � Override Status: APPROVED � Override Decision: PAY � Override Reason: "Departure delay code 77 (Weather) was incorrectly assigned. Investigation confirms clea |
| CP097 | FRAUD SCREENING � POST-OVERRIDE (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening (behind the scenes) |  |
| CP098 | FRAUD SCREENING � POST-OVERRIDE (GLOB-05) | system | implied | And CyberSource evaluates the claim |  |
| CP099 | FRAUD SCREENING � POST-OVERRIDE (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) | ? PROCEED to Welcome Back flow |
| CP100 | WELCOME BACK NOTIFICATION | email | email | Then the system sends a Welcome Back email to the passenger: | Good news! After reviewing your dispute for flight AC 201 from Toronto to Calgary on June 3, 2026, we have determined that you are eligible for expense reimburs |
| CP101 | WELCOME BACK NOTIFICATION | email | email | And the email includes: | � Deep link to chatbot with pre-populated claim data � Case reference number � Expiry date for completing the claim |
| CP102 | WELCOME BACK FLOW � RECEIPT UPLOAD | system | implied | Then the passenger clicks the deep link |  |
| CP103 | WELCOME BACK FLOW � RECEIPT UPLOAD | system | implied | And the chatbot opens with pre-populated data: | "Welcome back, [First Name]! We've reviewed your dispute and determined that you are eligible for expense reimbursement for your flight AC 201 from Toronto to C |
| CP104 | ENTITLEMENT DISPLAY | bot | chat | Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, APPR regime: | Based on the length of your disruption (6 hours), you may be eligible for reimbursement in the following categories: � Meals: up to $30.00 � Hotel accommodation |
| CP105 | RECEIPT UPLOAD | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP106 | RECEIPT UPLOAD | bot | chat | And the chatbot displays the receipt upload interface |  |
| CP107 | RECEIPT UPLOAD | system | implied | And the user uploads receipt images: | � Receipt 1: Hotel receipt � $170.00 CAD (1 night) � Receipt 2: Meal receipt � $28.00 CAD (dinner) � Receipt 3: Taxi receipt � $45.00 CAD (airport to hotel + ho |
| CP108 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | Then the system processes uploaded receipts through OCR (Agentic Receipt Reader) |  |
| CP109 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | And the OCR engine extracts line items from each receipt: | Receipt 1 � Hotel: � Line item: Hotel stay, 1 night � $170.00 CAD � Date: June 3, 2026 � Category: Hotel � Within disruption window: YES ? � Rate of day compari |
| CP110 | RECEIPT VALIDATION SUMMARY | system | implied | Then the system displays the OCR validation summary: | � Total receipts processed: 3 � Total line items extracted: 4 � Items PASSED: 4 � Items FLAGGED for agent review: 0 � Items FAILED: 0 |
| CP111 | EXPENSE BREAKDOWN | system | implied | � Hotel: $170.00 ? | � Meals: $28.00 ? � Transport: $45.00 ? � Communication: $0.00 (no receipt submitted) � Parking: $0.00 (no receipt submitted) � Essentials: $0.00 (no receipt su |
| CP112 | CASE UPDATE (GLOB-09) | system | implied | Then the system updates the existing case in Case Services |  |
| CP113 | CASE UPDATE (GLOB-09) | system | implied | And the case now includes: | � Override: APPROVED � Overridden eligibility: ELIGIBLE � Overridden DDS code: SoC-APPR-EL-08 � All approved line items with amounts � Receipt images attached � |
| CP114 | CASE UPDATE (GLOB-09) | system | implied | And the case reference number is confirmed to the passenger |  |
| CP115 | CASE UPDATE (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully. Here's a summary: � Case Reference: [Case Number] � Total claim amount: $243.00 CAD � Categories: Hotel ($170.00), M |
| CP116 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP117 | NOTIFICATION | email | email | And an eligible confirmation email is sent to the passenger at t***@gmail.com |  |
| CP118 | NOTIFICATION | email | email | And the email includes: | � Case reference number � Claim summary with approved amounts � Note about dispute resolution � Next steps for payment processing |
| CP119 | CLAIMS PAYMENT FLOW | system | implied | Then the system initiates payment processing |  |
| CP120 | CLAIMS PAYMENT FLOW | system | implied | And Case Services calculates: | � Approved amount: $243.00 CAD � Payment method: Canada ? EFT |
| CP121 | CLAIMS PAYMENT FLOW | bot | chat | Then the chatbot responds: | To complete your reimbursement, we'll need your payment details. |
| CP122 | CLAIMS PAYMENT FLOW | system | implied | And the chatbot collects: | � Country of residence: Canada � Payment method: EFT � Bank details: [collected securely] |
| CP123 | CLAIMS PAYMENT FLOW | bot | chat | Then the chatbot responds: | Your payment of $243.00 CAD will be processed via Electronic Funds Transfer. You should receive the funds within [X] business days. |
| CP124 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP125 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP126 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-OVERRIDE-APPROVED � Override Approved Eligible |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved (Override Approved)" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment transitioned from "Manual Handling" to "Resolved" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant", "Adult", "Disputed", and "Override Approved" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 201 YYZ ? YYC as the claimed flight |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (6 hours)" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Disruption Reason (Original) "Weather (Code 77 � INCORRECT)" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason (Corrected) is "Crew Scheduling (Code 41 � CONTROLLABLE)" |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 360 min (6 hours) |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed Departure)" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability (Original) is "UNCONTROLLABLE (Weather � Code 77)" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability (Corrected) is "CONTROLLABLE (Crew Scheduling � Code 41)" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Original DDS Response Code is "SoC-APPR-NE-07 (NOT ELIGIBLE)" |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Overridden DDS Response Code is "SoC-APPR-EL-08 (ELIGIBLE)" |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute is "YES" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Override Status is "APPROVED (PAY)" |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Agent Decision is "Override approved � Departure delay code was misclassified" |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Investigation shows "Weather reports confirm clear conditions at YYZ. Other carriers operated normally on same route." |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Evidence includes "NavCanada data, weather reports, competitor flight logs" |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Corrected Code is "41 (Crew Scheduling � controllable)" |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Outcome is "ELIGIBLE (overridden from NOT ELIGIBLE)" |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN (post-override)" |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE (via override)" |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Hotel $170.00 APPROVED |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Meals $28.00 APPROVED (?$30) |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Transport $45.00 APPROVED (?$200) |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Communication $0.00 No receipt |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Parking $0.00 No receipt |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Essentials $0.00 No receipt |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is $243.00 CAD |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 0 |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Welcome Back email was sent post-override |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligible confirmation email was sent with approved amounts |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the note about dispute resolution is included |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved (Override Approved)" |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP165 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-OVERRIDE-APPROVED � Override Approved Eligible |  |
| CP166 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-OVERRIDE-APPROVED has override APPROVED and is ELIGIBLE |  |
| CP167 | PAYMENT VALIDATION | payment | chat | Then SOC payment is CASH ONLY (even for override, SOC does not offer AC Wallet) |  |
| CP168 | PAYMENT VALIDATION | payment | chat | And the route is AC 201 YYZ ? YYC with delay 360 min (6 hrs) originally coded Weather (77) corrected to Crew (41) |  |
| CP169 | PAYMENT VALIDATION | payment | chat | And the original DDS is SoC-APPR-NE-07 overridden to SoC-APPR-EL-08 |  |
| CP170 | PAYMENT VALIDATION | payment | chat | And CyberSource fraud screening is GREEN (post-override) |  |
| CP171 | PAYMENT VALIDATION | payment | chat | And the Welcome Back email was sent and customer uploaded receipts |  |
| CP172 | PAYMENT VALIDATION | payment | chat | And the entitlements for 1 adult PY no ACR are Meals $30, Hotel rate of day/$500 cap, Transport $200, Communication $30, Parking $50, Essent |  |
| CP173 | PAYMENT VALIDATION | payment | chat | And the approved receipts are Hotel $170 (vs $500 PASS), Meals $28 (vs $30 PASS), Taxi $45 (vs $200 PASS) totalling $243.00 CAD |  |
| CP174 | PAYMENT VALIDATION | payment | manual | And the country of residence is Canada with currency CAD and payment method Interac via Unifier |  |
| CP175 | PAYMENT VALIDATION | payment | chat | And $243.00 is less than $500 so no approval is needed |  |
| CP176 | PAYMENT VALIDATION | payment | manual | And the batch file is sent to Unifier and end-of-day report is generated |  |
| CP177 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab shows Amount $243.00 CAD, Type Cash, Method Interac |  |
| CP178 | PAYMENT VALIDATION | payment | chat | And the Override tag is "APPROVED" |  |
| CP179 | PAYMENT VALIDATION | payment | chat | And the Original DDS is SoC-APPR-NE-07 and Overridden is SoC-APPR-EL-08 |  |
| CP180 | PAYMENT VALIDATION | payment | manual | And the status is updated via talkback |  |
| CP181 | EXPECTED RESULTS | verdict | chat | SoC-Override-Pay. | SoC-Override-Pay. |
| CP182 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP183 | EXPECTED RESULTS | verdict | chat | Emergency override resolved to Pay. | Emergency override resolved to Pay. |
| CP184 | EXPECTED RESULTS | verdict | api | Normal DDS evaluation skipped � override takes precedence. | Normal DDS evaluation skipped � override takes precedence. |
| CP185 | EXPECTED RESULTS | verdict | chat | Override amounts applied (may differ from standard entitlements). | Override amounts applied (may differ from standard entitlements). |
| CP186 | EXPECTED RESULTS | verdict | chat | Fraud screening GREEN. | Fraud screening GREEN. |
| CP187 | EXPECTED RESULTS | verdict | chat | Full receipt upload + OCR + case creation + notification. | Full receipt upload + OCR + case creation + notification. |
| CP188 | EXPECTED RESULTS | verdict | chat | Case flagged with override metadata. | Case flagged with override metadata. |
| CP189 | EXPECTED RESULTS | verdict | api | Even if normal DDS would have returned NOT ELIGIBLE, override Pay = ELIGIBLE. | Even if normal DDS would have returned NOT ELIGIBLE, override Pay = ELIGIBLE. |
