# SOC_UAT_019 · CHAI-31934 — checkpoints

**Goal:** Verify APPR SOC eligibility, below-threshold OCR auto-approval for meals and accommodation, and automated Interac payout for a 3-PAX booking with mixed exception profiles (1 Elderly booker with Basic Aeroplan + 2 Regular non-members) experiencing a 7-hour controllable crew delay (Code 68), where submitted meal ($65.00 CAD) and accommodation ($320.00 CAD) receipts are both below entitlement caps and processed via Interac by collecting only the recipient's email address.

Methods: seed 17, chat 52, api 6, email 2, dashboard 41, implied 21, manual 5, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify APPR SOC eligibility, below-threshold OCR auto-approval for meals and accommodation, and automated Interac payout for a 3-PAX booking |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 301 YYZ -> YVR | � Itinerary: Single segment � AC 301 YYZ -> YVR |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 301 YYZ -> YVR | � SOC Segment (per SoC Flight Identifier): AC 301 YYZ -> YVR |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 301 YYZ -> YVR, Dep: 15-Jun 08:00 | � Promised Itinerary: AC 301 YYZ -> YVR, Dep: 15-Jun 08:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 301 YYZ -> YVR, Dep: 15-Jun 15:00 | � Actual Itinerary: AC 301 YYZ -> YVR, Dep: 15-Jun 15:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 420 min (7 hours) | � Departure Delay: 420 min (7 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure Delay Code: 68 (Flight Crew Shortage / Scheduling) � Controllable | � Departure Delay Code: 68 (Flight Crew Shortage / Scheduling) � Controllable |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Controllable (Code 68) | � Controllability: Controllable (Code 68) |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Count & Types (3 Pax on PNR): | � Passenger Count & Types (3 Pax on PNR): |
| CP011 | PREREQUISITES | prerequisite | seed | - Pax 1 (Claimant / Booker): Elderly Adult (Age >= 65) / Aeroplan Basic Member | - Pax 1 (Claimant / Booker): Elderly Adult (Age >= 65) / Aeroplan Basic Member |
| CP012 | PREREQUISITES | prerequisite | seed | - Pax 2: Regular Adult (Non-exception) / Non-member | - Pax 2: Regular Adult (Non-exception) / Non-member |
| CP013 | PREREQUISITES | prerequisite | seed | - Pax 3: Regular Adult (Non-exception) / Non-member | - Pax 3: Regular Adult (Non-exception) / Non-member |
| CP014 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Exception Check -> Mixed Exception (1 Elderly + 2 None) PASS -> 2. Controllability -> Controllable (Code 68) PASS -> ELIGI | � Check Order: 1. Exception Check -> Mixed Exception (1 Elderly + 2 None) PASS -> 2. Controllability -> Controllable (Code 68) PASS -> ELIGIBLE |
| CP015 | PREREQUISITES | prerequisite | seed | � PAX Count: 3 adults / Class: PY / Revenue: YES / ACR: No / Journey: > 72h | � PAX Count: 3 adults / Class: PY / Revenue: YES / ACR: No / Journey: > 72h |
| CP016 | PREREQUISITES | prerequisite | seed | � Overnight Eligible: YES (delay > 360 min) | � Overnight Eligible: YES (delay > 360 min) |
| CP017 | PREREQUISITES | prerequisite | seed | � Entitlements: Hotel: Rate of day, 3 nights max, $500.00 CAD cap per room / Meals: $30.00 x 3 = $90.00 CAD / Transport: $200.00 CAD / Comm: | � Entitlements: Hotel: Rate of day, 3 nights max, $500.00 CAD cap per room / Meals: $30.00 x 3 = $90.00 CAD / Transport: $200.00 CAD / Comm: $30.00 x 3 = $90.00 |
| CP018 | PREREQUISITES | prerequisite | seed | � Submitted Expenses: Meal ($65.00 CAD, below $90.00 cap) and Accommodation ($320.00 CAD, below $500.00 cap) � Total: $385.00 CAD | � Submitted Expenses: Meal ($65.00 CAD, below $90.00 cap) and Accommodation ($320.00 CAD, below $500.00 cap) � Total: $385.00 CAD |
| CP019 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP020 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP021 | START | customer | chat | When the user selects English |  |
| CP022 | START | alert | chat | Then an alert information is displayed: | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP023 | START | bot | chat | Then the chatbot asks: "How can I help you today?" | How can I help you today? |
| CP024 | START | customer | chat | And the user says: "My flight from Toronto to Vancouver was delayed for 7 hours because of crew scheduling. I had 2 family members with me a | My flight from Toronto to Vancouver was delayed for 7 hours because of crew scheduling. I had 2 family members with me and we had to buy meals and pay for an ov |
| CP025 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP026 | START | system | implied | Then the chatbot checks: Is this a third-party submission? -> NO |  |
| CP027 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP031 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP032 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (3 Passengers on booking) |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | * Email: t***@gmail.com * Phone: +1***789 |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | When the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code -> CORRECT (attempt 1 of 5) |  |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP042 | PASSENGER & JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if this PNR is a group booking -> No |  |
| CP043 | PASSENGER & JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? -> YES (3 PAX found) |  |
| CP044 | PASSENGER & JOURNEY SELECTION (GenUC-08) | bot | chat | And the chatbot displays passenger list: | I found the following passengers on this booking: 1. [Pax 1 Name] (Claimant / Booker - Elderly, Aeroplan Basic) 2. [Pax 2 Name] (Adult) 3. [Pax 3 Name] (Adult)  |
| CP045 | PASSENGER & JOURNEY SELECTION (GenUC-08) | customer | chat | When the user confirms: "Yes, claiming for all 3 passengers" | Yes, claiming for all 3 passengers |
| CP046 | PASSENGER & JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: * Flight: AC 301 * Route: Toronto (YYZ) -> Vancouver (YVR) * Date: June 15, 2026 * Departure Delay: 7 hours (420 minutes) * Passe |
| CP047 | PASSENGER & JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | PASSENGER & JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there is more than 1 segment -> No |  |
| CP049 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot sends request to Case Services for duplicate check (GenUC-10) |  |
| CP050 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP051 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot checks 72-hour window passed -> YES |  |
| CP052 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot verifies Filing deadline limitation: | * Origin: YYZ (Ontario) -> Limitation = 730 days * Destination: YVR (British Columbia) -> Limitation = 1,095 days * Elapsed: Within limitation period -> PROCEED |
| CP053 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot checks if triage data is available -> YES |  |
| CP054 | TRIAGE AND DDS EVALUATION | verdict | api | Then DDS evaluates backend rules: | * Delay Code: 68 (Flight Crew Shortage / Scheduling) -> Controllable * Passenger Mix: 1 Elderly (Pax 1) + 2 Regular (Pax 2, Pax 3) -> Mixed Exception handling * |
| CP055 | TRIAGE AND DDS EVALUATION | verdict | api | And DDS assigns Response Code: SoC-APPR-EL-08 |  |
| CP056 | FRAUD SCREENING (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening |  |
| CP057 | FRAUD SCREENING (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) |  |
| CP058 | ELIGIBLE RESULT & ENTITLEMENT DISPLAY (SoC-03b) | bot | chat | Then the chatbot displays: | Great news! Based on the details of your flight, you and the passengers on your booking are eligible for expense reimbursement. Your flight AC 301 from Toronto  |
| CP059 | ELIGIBLE RESULT & ENTITLEMENT DISPLAY (SoC-03b) | bot | chat | And the chatbot displays the combined entitlements for 3 passengers: | Based on the length of your disruption (7 hours) and 3 traveling passengers, you may be eligible for reimbursement in the following categories: * Hotel accommod |
| CP060 | RECEIPT UPLOAD & OCR VALIDATION (RR-01) | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP061 | RECEIPT UPLOAD & OCR VALIDATION (RR-01) | system | implied | When the user uploads the meal and accommodation receipts: | * Receipt 1: Hotel receipt � $320.00 CAD (1 night accommodation) * Receipt 2: Meal receipt � $65.00 CAD (Dinner for 3) |
| CP062 | RECEIPT UPLOAD & OCR VALIDATION (RR-01) | system | implied | Then OCR engine extracts and validates line items: | * Receipt 1 � Hotel Accommodation: - Line item: Hotel stay, 1 night � $320.00 CAD - Date: June 15, 2026 - Category: Hotel - Within disruption window: YES - Nigh |
| CP063 | RECEIPT VALIDATION SUMMARY | system | implied | Then the system displays the OCR validation summary: | * Total receipts processed: 2 * Total line items extracted: 2 * Items PASSED: 2 * Items FLAGGED for agent review: 0 * Items FAILED: 0 * Expense Breakdown: - Hot |
| CP064 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case in Case Services: | * DDS response code: SoC-APPR-EL-08 * Eligibility: ELIGIBLE * Regime: APPR * Approved Total: $385.00 CAD (Hotel $320.00 + Meals $65.00) * Receipt images attache |
| CP065 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP066 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully. Here's a summary: * Case Reference: [Case Number] * Total claim amount: $385.00 CAD * Categories: Hotel ($320.00), M |
| CP067 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP068 | NOTIFICATION | email | email | And an eligible confirmation email is sent to the passenger at t***@gmail.com |  |
| CP069 | CLAIMS PAYMENT FLOW | system | implied | Then the system initiates payment processing |  |
| CP070 | CLAIMS PAYMENT FLOW | system | implied | And Case Services calculates: | Approved amount: $385.00 CAD Currency conversion: CAD -> country of residence currency (if different) Payment method determination based on country of residence |
| CP071 | CLAIMS PAYMENT FLOW | bot | chat | Then the chatbot responds: | To complete your reimbursement, we'll need your payment details. |
| CP072 | CLAIMS PAYMENT FLOW | system | implied | And the chatbot collects: | Country of residence: Canada Payment method: Interac Email address for Interac transfer: [t***@gmail.com] |
| CP073 | CLAIMS PAYMENT FLOW | bot | chat | Then the chatbot responds: | Your payment of $385.00 CAD will be processed via Interac e-Transfer to your email. You should receive the transfer notification within [X] business days. |
| CP074 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP075 | END FLOW (GLOB-11) | customer | chat | When the user selects "No" | No |
| CP076 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-EL-08 � 3 Pax Mixed Exception Delay Code 68 Meal & Hotel Below Threshold |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated (Pax 1) |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Elderly (Age >= 65)" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated with 3 associated passengers |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant", "Adult", "Elderly", "Multi-PAX (3)" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Basic Member (Booker Only)" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Associated Passengers evaluation shows: | / Passenger / Type  / Aeroplan Tier / Exception Type / / Pax 1     / Adult / Basic Member  / Elderly (>=65) / / Pax 2     / Adult / Non-Member    / None (Regula |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 301 YYZ -> YVR as the claimed flight |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (7 hours)" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 301 YYZ -> YVR |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 301 |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Flight Crew Shortage / Scheduling (Departure delay code 68 � CONTROLLABLE)" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 420 min (7 hours) |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Evaluation Order shows: | / Order / Check Step               / Result                                    / / 1     / Passenger Exception Type / Mixed Exception (1 Elderly + 2 None) PASS  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Overnight Eligible is "YES (delay > 360 min)" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the ACR Issued shows Hotel No, Transport No, Meal No |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-EL-08" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Entitlements for 3 adults PY show: | / Category      / Entitlement Limit                   / / Hotel         / Rate of day, max 3 nights, $500 cap / / Meals         / $90.00 CAD ($30.00/pax x 3)    |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows: | / Category      / Claimed Amount / Approved Amount / Status                                             / / Hotel         / $320.00 CAD    / $320.00 CAD     / A |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is $385.00 CAD |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 0 |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "$385.00 CAD (APPR � Suggested Highlighted)" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource result is "GREEN" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP121 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-EL-08 � 3 Pax Mixed Exception Code 68 Meal & Hotel Below Threshold (Interac) |  |
| CP122 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-EL-08 is determined as ELIGIBLE for 3 passengers |  |
| CP123 | PAYMENT VALIDATION | payment | chat | Then SOC payment mode is validated as CASH ONLY |  |
| CP124 | PAYMENT VALIDATION | payment | chat | And the route is AC 301 YYZ -> YVR with a departure delay of 420 min (7 hours) for 3 adults in PY |  |
| CP125 | PAYMENT VALIDATION | payment | chat | And the group entitlements for 3 adults are Hotel $500.00 CAD cap and Meals $90.00 CAD ($30.00/pax x 3) |  |
| CP126 | PAYMENT VALIDATION | payment | chat | And the approved receipts are Hotel $320.00 CAD and Meals $65.00 CAD totalling $385.00 CAD |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And the system verifies $385.00 CAD is less than the $500.00 SOC sign-off threshold |  |
| CP128 | PAYMENT VALIDATION | payment | chat | And no secondary manual approval or agent review is triggered |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And Case Services determines payment method based on country of residence: | / Country of Residence / Payment Method Determination / Selected Method / / Canada               / Interac (E-Transfer)         / Interac         / / US + 70 BS |
| CP130 | PAYMENT VALIDATION | payment | chat | And the bot collects only the email address for Interac transfer without requesting bank account details |  |
| CP131 | PAYMENT VALIDATION | payment | chat | And the country of residence is confirmed as Canada with currency CAD |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And the total approved compensation is $385.00 CAD |  |
| CP133 | PAYMENT VALIDATION | payment | chat | And the Comp Status is "Sent for issuance" |  |
| CP134 | PAYMENT VALIDATION | payment | manual | And the compensation record is created and batch file dispatched to Unifier |  |
| CP135 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard displays "$385.00 CAD", "Cash", "Interac", and status confirmed via talkback |  |
| CP136 | EXPECTED RESULTS | verdict | chat | SoC-APPR-EL-08. | SoC-APPR-EL-08. |
| CP137 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP138 | EXPECTED RESULTS | verdict | api | Controllable delay >= 2h (7 hours, Code 68 Crew Shortage / Scheduling). | Controllable delay >= 2h (7 hours, Code 68 Crew Shortage / Scheduling). |
| CP139 | EXPECTED RESULTS | verdict | api | Passenger exception checked FIRST (Mixed: 1 Elderly + 2 None), then controllability checked SECOND (Code 68 Controllable). | Passenger exception checked FIRST (Mixed: 1 Elderly + 2 None), then controllability checked SECOND (Code 68 Controllable). |
| CP140 | EXPECTED RESULTS | verdict | chat | Booker holds Aeroplan Basic membership while the other 2 passengers are non-members. | Booker holds Aeroplan Basic membership while the other 2 passengers are non-members. |
| CP141 | EXPECTED RESULTS | verdict | chat | Operating carrier correctly identified as AC. | Operating carrier correctly identified as AC. |
| CP142 | EXPECTED RESULTS | verdict | chat | Fraud screening GREEN. | Fraud screening GREEN. |
| CP143 | EXPECTED RESULTS | verdict | chat | Entitlements applied for 3 passengers with Meals cap at $90.00 CAD and Hotel cap at $500.00 CAD. | Entitlements applied for 3 passengers with Meals cap at $90.00 CAD and Hotel cap at $500.00 CAD. |
| CP144 | EXPECTED RESULTS | verdict | chat | Submitted hotel receipt ($320.00 CAD) and meal receipt ($65.00 CAD) both validated as below-threshold. | Submitted hotel receipt ($320.00 CAD) and meal receipt ($65.00 CAD) both validated as below-threshold. |
| CP145 | EXPECTED RESULTS | verdict | chat | Full receipt upload + OCR + case creation + notification + automated Interac payout flow (email only collected) completes with total $385.00 | Full receipt upload + OCR + case creation + notification + automated Interac payout flow (email only collected) completes with total $385.00 CAD without manual  |
