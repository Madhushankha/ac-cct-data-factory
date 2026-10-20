# SOC_UAT_017 · CHAI-31932 — checkpoints

**Goal:** Verify APPR SOC eligibility, scaled multi-pax entitlements ($120 meal cap), below-threshold OCR auto-approval ($88 meal / $453 total), and automated payout for a 4-PAX booking with mixed exception types (2 Accessibility + 2 Regular) following a 7-hour controllable crew delay (Code 65).

Methods: seed 26, chat 46, api 5, email 2, dashboard 39, implied 20, manual 5, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify APPR SOC eligibility, scaled multi-pax entitlements ($120 meal cap), below-threshold OCR auto-approval ($88 meal / $453 total), and a |  |
| CP002 | PREREQUISITES | prerequisite | seed | Regime: APPR | Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: Single segment � AC 301 YYZ ? YVR | Itinerary: Single segment � AC 301 YYZ ? YVR |
| CP004 | PREREQUISITES | prerequisite | seed | SOC Segment (per SoC Flight Identifier): AC 301 YYZ ? YVR | SOC Segment (per SoC Flight Identifier): AC 301 YYZ ? YVR |
| CP005 | PREREQUISITES | prerequisite | seed | Promised Itinerary: AC 301 YYZ ? YVR, Dep: 15-Jun 08:00 | Promised Itinerary: AC 301 YYZ ? YVR, Dep: 15-Jun 08:00 |
| CP006 | PREREQUISITES | prerequisite | seed | Actual Itinerary: AC 301 YYZ ? YVR, Dep: 15-Jun 15:00 | Actual Itinerary: AC 301 YYZ ? YVR, Dep: 15-Jun 15:00 |
| CP007 | PREREQUISITES | prerequisite | seed | Departure Delay: 420 min (7 hours) | Departure Delay: 420 min (7 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | Departure Delay Code: 65 (Flight Crew Shortage / Scheduling) � Controllable | Departure Delay Code: 65 (Flight Crew Shortage / Scheduling) � Controllable |
| CP009 | PREREQUISITES | prerequisite | seed | Controllability: Controllable (Code 65) | Controllability: Controllable (Code 65) |
| CP010 | PREREQUISITES | prerequisite | seed | Passenger Count & Types (4 Pax on PNR): | Passenger Count & Types (4 Pax on PNR): |
| CP011 | PREREQUISITES | prerequisite | seed | Pax 1 (Claimant): Adult / Accessibility (SSR: WCHR) / Aeroplan Basic Member | Pax 1 (Claimant): Adult / Accessibility (SSR: WCHR) / Aeroplan Basic Member |
| CP012 | PREREQUISITES | prerequisite | seed | Pax 2: Adult / Accessibility (SSR: DPNA) / Aeroplan Basic Member | Pax 2: Adult / Accessibility (SSR: DPNA) / Aeroplan Basic Member |
| CP013 | PREREQUISITES | prerequisite | seed | Pax 3: Adult / Regular (Non-exception) / Aeroplan Basic Member | Pax 3: Adult / Regular (Non-exception) / Aeroplan Basic Member |
| CP014 | PREREQUISITES | prerequisite | seed | Pax 4: Adult / Regular (Non-exception) / Aeroplan Basic Member | Pax 4: Adult / Regular (Non-exception) / Aeroplan Basic Member |
| CP015 | PREREQUISITES | prerequisite | seed | Check Order: | Check Order: |
| CP016 | PREREQUISITES | prerequisite | seed | Exception Check ? Mixed Exception (2 Accessibility + 2 Regular) ? | Exception Check ? Mixed Exception (2 Accessibility + 2 Regular) ? |
| CP017 | PREREQUISITES | prerequisite | seed | Controllability ? Controllable (Code 65) ? ? ELIGIBLE | Controllability ? Controllable (Code 65) ? ? ELIGIBLE |
| CP018 | PREREQUISITES | prerequisite | seed | PAX Count: 4 adults / Class: PY / Revenue: YES / ACR: No / Journey: > 72h | PAX Count: 4 adults / Class: PY / Revenue: YES / ACR: No / Journey: > 72h |
| CP019 | PREREQUISITES | prerequisite | seed | Overnight Eligible: YES (delay > 360 min) | Overnight Eligible: YES (delay > 360 min) |
| CP020 | PREREQUISITES | prerequisite | seed | ENTITLEMENTS (4 adults, PY, 2 Accessibility + 2 Regular, no ACR): | ENTITLEMENTS (4 adults, PY, 2 Accessibility + 2 Regular, no ACR): |
| CP021 | PREREQUISITES | prerequisite | seed | Meals: $30.00 / pax * 4 = $120.00 CAD | Meals: $30.00 / pax * 4 = $120.00 CAD |
| CP022 | PREREQUISITES | prerequisite | seed | Hotel: Rate of day, 3 nights max, $500 cap per room | Hotel: Rate of day, 3 nights max, $500 cap per room |
| CP023 | PREREQUISITES | prerequisite | seed | Transport: $200.00 CAD | Transport: $200.00 CAD |
| CP024 | PREREQUISITES | prerequisite | seed | Communication: $120.00 CAD ($30.00 / pax * 4) | Communication: $120.00 CAD ($30.00 / pax * 4) |
| CP025 | PREREQUISITES | prerequisite | seed | Parking: $50.00 CAD | Parking: $50.00 CAD |
| CP026 | PREREQUISITES | prerequisite | seed | Essentials: $120.00 CAD ($30.00 / pax * 4) | Essentials: $120.00 CAD ($30.00 / pax * 4) |
| CP027 | PREREQUISITES | prerequisite | seed | Submitted Expense: Meal only � 1 receipt of $88.00 CAD (Family Dinner) | Submitted Expense: Meal only � 1 receipt of $88.00 CAD (Family Dinner) |
| CP028 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP029 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP030 | START | customer | chat | When the user selects English |  |
| CP031 | START | alert | chat | Then an alert information is displayed: | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP032 | START | bot | chat | Then the chatbot asks: "How can I help you today?" | How can I help you today? |
| CP033 | START | customer | chat | And the user says: "My family flight from Toronto to Vancouver was delayed for 7 hours because of crew scheduling. There were 4 of us travel | My family flight from Toronto to Vancouver was delayed for 7 hours because of crew scheduling. There were 4 of us traveling, including two family members needin |
| CP034 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP035 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP036 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP037 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP038 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP039 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP040 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP041 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP042 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP043 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (4 Passengers on booking) |  |
| CP044 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP045 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | * Email: t***@gmail.com * Phone: +1***789 |
| CP046 | AUTHENTICATION (GenUC-05) | customer | chat | When the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP047 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP048 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP049 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP050 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP051 | PASSENGER & JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if this PNR is a group booking ? No |  |
| CP052 | PASSENGER & JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? YES (4 PAX found) |  |
| CP053 | PASSENGER & JOURNEY SELECTION (GenUC-08) | bot | chat | And the chatbot displays passenger list: | I found the following passengers on this booking: 1. [Pax 1 Name] (Claimant - Accessibility WCHR) 2. [Pax 2 Name] (Accessibility DPNA) 3. [Pax 3 Name] (Adult) 4 |
| CP054 | PASSENGER & JOURNEY SELECTION (GenUC-08) | customer | chat | When the user confirms: "Yes, claiming for all 4 passengers" | Yes, claiming for all 4 passengers |
| CP055 | PASSENGER & JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: * Flight: AC 301 * Route: Toronto (YYZ) ? Vancouver (YVR) * Date: June 15, 2026 * Departure Delay: 7 hours (420 minutes) * Passen |
| CP056 | PASSENGER & JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP057 | PASSENGER & JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there is more than 1 segment ? No |  |
| CP058 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot sends request to Case Services for duplicate check (GenUC-10) |  |
| CP059 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP060 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot checks 72-hour window passed ? YES |  |
| CP061 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot verifies Filing deadline limitation: | * Origin: YYZ (Ontario) ? Limitation = 730 days * Destination: YVR (British Columbia) ? Limitation = 1,095 days * Elapsed: Within limitation period ? PROCEED |
| CP062 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot checks if triage data is available ? YES |  |
| CP063 | TRIAGE AND DDS EVALUATION | verdict | api | Then DDS evaluates backend rules: | * Delay Code: 65 (Flight Crew Shortage / Duty Scheduling) ? Controllable * Passenger Mix: 2 Accessibility + 2 Regular ? Mixed Exception handling * Delay Band: D |
| CP064 | TRIAGE AND DDS EVALUATION | verdict | api | And DDS assigns Response Code: SoC-APPR-EL-08 |  |
| CP065 | FRAUD SCREENING (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening |  |
| CP066 | FRAUD SCREENING (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) |  |
| CP067 | ELIGIBLE RESULT & ENTITLEMENT DISPLAY (SoC-03b) | bot | chat | Then the chatbot displays: | Great news! Based on the details of your flight, you and the passengers on your booking are eligible for expense reimbursement. Your flight AC 301 from Toronto  |
| CP068 | ELIGIBLE RESULT & ENTITLEMENT DISPLAY (SoC-03b) | bot | chat | And the chatbot displays the combined entitlements for 4 passengers: | Based on the length of your disruption (7 hours) and 4 traveling passengers, you may be eligible for reimbursement in the following categories: * Meals: up to $ |
| CP069 | RECEIPT UPLOAD & OCR VALIDATION (RR-01) | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP070 | RECEIPT UPLOAD & OCR VALIDATION (RR-01) | system | implied | When the user uploads only the meal receipt: | * Receipt 1: Meal receipt � $88.00 CAD (Family Dinner for 4) |
| CP071 | RECEIPT UPLOAD & OCR VALIDATION (RR-01) | system | implied | Then OCR engine extracts and validates line items: | * Receipt 1 � Meals: - Line item: Family Dinner � $88.00 CAD - Date: June 15, 2026 - Category: Meals - Within disruption window: YES ? - Threshold check: $88.00 |
| CP072 | RECEIPT VALIDATION SUMMARY | system | implied | Then the system displays the OCR validation summary: | * Total receipts processed: 1 * Total line items extracted: 1 * Items PASSED: 1 * Items FLAGGED for agent review: 0 * Items FAILED: 0 * Expense Breakdown: - Hot |
| CP073 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case in Case Services: | * DDS response code: SoC-APPR-EL-08 * Eligibility: ELIGIBLE * Regime: APPR * Approved Total: $88.00 CAD (Meals only) * Receipt images attached: 1 * Fraud screen |
| CP074 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP075 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully. Here's a summary: * Case Reference: [Case Number] * Total claim amount: $88.00 CAD * Categories: Meals ($88.00) * Cl |
| CP076 | NOTIFICATION & CLAIMS PAYMENT | email | email | Then Adobe sends an eligibility confirmation email to t***@gmail.com |  |
| CP077 | NOTIFICATION & CLAIMS PAYMENT | system | implied | And Case Services triggers automated payment processing: | * Approved amount: $88.00 CAD (< $500 threshold ? No manual sign-off required) * Payment method: Canada ? Interac |
| CP078 | NOTIFICATION & CLAIMS PAYMENT | email | email | When the chatbot collects payment details: | * Country of residence: Canada * Payment method: Interac * Email: [collected securely] |
| CP079 | NOTIFICATION & CLAIMS PAYMENT | bot | chat | Then the chatbot responds: | Your payment of $88.00 CAD will be processed via Electronic Funds Transfer. You should receive the funds within 3�5 business days. |
| CP080 | NOTIFICATION & CLAIMS PAYMENT | bot | chat | When the chatbot asks: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP081 | NOTIFICATION & CLAIMS PAYMENT | customer | chat | And the user selects "No" | No |
| CP082 | NOTIFICATION & CLAIMS PAYMENT | system | implied | Then the chatbot concludes: "Thank you for choosing Air Canada." |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated (Pax 1) |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Accessibility (SSR: WCHR)" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated with 4 associated passengers |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant", "Adult", "Accessibility", "Multi-PAX (4)" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Basic Member" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 301 YYZ ? YVR as the claimed flight |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (7 hours)" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 301 YYZ ? YVR |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 301 |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Flight Crew Shortage / Scheduling (Departure delay code 65 � CONTROLLABLE)" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 420 min (7 hours) |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Evaluation Order shows: | / Order / Check Step               / Result                                              / / 1     / Passenger Exception Type / Mixed Exception (2 Accessibility |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Overnight Eligible is "YES (delay >360 min)" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the ACR Issued shows Hotel No, Transport No, Meal No |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-EL-08" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Entitlements for 4 adults PY show: | / Category      / Entitlement Limit                       / / Meals         / $120.00 CAD ($30.00/pax x 4)            / / Hotel         / Rate of day, max 3 nig |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows: | / Category      / Amount     / Status                                               / / Meals         / $88.00 CAD / APPROVED (Family dinner, <= $120.00 group t |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is $88.00 CAD |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 0 |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "$88.00 CAD (APPR � Suggested Highlighted)" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource result is "GREEN" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP125 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-EL-08 is determined as ELIGIBLE for 4 passengers |  |
| CP126 | PAYMENT VALIDATION | payment | chat | Then SOC payment mode is validated as CASH ONLY |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And the route is AC 301 YYZ ? YVR with a departure delay of 420 min (7 hours) for 4 adults in PY |  |
| CP128 | PAYMENT VALIDATION | payment | chat | And the meal entitlement for 4 adults is calculated as $120.00 CAD ($30.00/pax x 4) |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And the approved receipt is Meals $88.00 CAD totalling $88.00 CAD |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And the system verifies $88.00 CAD is less than the $500.00 SOC sign-off threshold |  |
| CP131 | PAYMENT VALIDATION | payment | chat | And no secondary manual approval or agent review is triggered |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And the country of residence is Canada with currency CAD and payment method EFT |  |
| CP133 | PAYMENT VALIDATION | payment | chat | And the Comp Status is "Sent for issuance" |  |
| CP134 | PAYMENT VALIDATION | payment | manual | And the compensation record is created and batch file sent to Unifier |  |
| CP135 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard displays "$88.00 CAD", "Cash", "EFT", and status confirmed via talkback |  |
| CP136 | EXPECTED RESULTS | verdict | chat | SoC-APPR-EL-08. | SoC-APPR-EL-08. |
| CP137 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP138 | EXPECTED RESULTS | verdict | api | Controllable delay >= 2h (7 hours, Code 65 Crew Shortage / Scheduling). | Controllable delay >= 2h (7 hours, Code 65 Crew Shortage / Scheduling). |
| CP139 | EXPECTED RESULTS | verdict | chat | Passenger type checked FIRST (Mixed: 2 Accessibility + 2 Regular), then controllability SECOND (Controllable). | Passenger type checked FIRST (Mixed: 2 Accessibility + 2 Regular), then controllability SECOND (Controllable). |
| CP140 | EXPECTED RESULTS | verdict | chat | Operating carrier correctly identified as AC. | Operating carrier correctly identified as AC. |
| CP141 | EXPECTED RESULTS | verdict | chat | Fraud screening GREEN. | Fraud screening GREEN. |
| CP142 | EXPECTED RESULTS | verdict | chat | Entitlements applied for 4 passengers with Meals cap at $120.00 CAD ($30 * 4). | Entitlements applied for 4 passengers with Meals cap at $120.00 CAD ($30 * 4). |
| CP143 | EXPECTED RESULTS | verdict | chat | Submitted meal receipt of $88.00 CAD validated as below-threshold. | Submitted meal receipt of $88.00 CAD validated as below-threshold. |
| CP144 | EXPECTED RESULTS | verdict | chat | Full receipt OCR extraction, automatic case resolution ($88.00 CAD), EFT payout initiation, and Adobe confirmation email complete without fl | Full receipt OCR extraction, automatic case resolution ($88.00 CAD), EFT payout initiation, and Adobe confirmation email complete without flagging for manual re |
