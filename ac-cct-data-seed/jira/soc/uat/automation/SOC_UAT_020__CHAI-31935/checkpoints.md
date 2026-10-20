# SOC_UAT_020 · CHAI-31935 — checkpoints

**Goal:** Verify APPR SOC eligibility, below-threshold OCR auto-approval across four categories (Meals, Transport, Accommodation, Essentials), and automated Interac payout for a 5-adult passenger booking with 1 Basic Aeroplan booker and 4 non-members experiencing a 7-hour controllable crew delay (Code 63), where all submitted receipts ($450.00 CAD total) are within category entitlement caps and processed via Interac by collecting only the recipient's email address.

Methods: seed 19, chat 52, api 6, email 2, dashboard 41, implied 21, manual 5, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify APPR SOC eligibility, below-threshold OCR auto-approval across four categories (Meals, Transport, Accommodation, Essentials), and aut |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 301 YYZ -> YVR | � Itinerary: Single segment � AC 301 YYZ -> YVR |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 301 YYZ -> YVR | � SOC Segment (per SoC Flight Identifier): AC 301 YYZ -> YVR |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 301 YYZ -> YVR, Dep: 15-Jun 08:00 | � Promised Itinerary: AC 301 YYZ -> YVR, Dep: 15-Jun 08:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 301 YYZ -> YVR, Dep: 15-Jun 15:00 | � Actual Itinerary: AC 301 YYZ -> YVR, Dep: 15-Jun 15:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 420 min (7 hours) | � Departure Delay: 420 min (7 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure Delay Code: 63 (Flight Crew Shortage / Scheduling) � Controllable | � Departure Delay Code: 63 (Flight Crew Shortage / Scheduling) � Controllable |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Controllable (Code 63) | � Controllability: Controllable (Code 63) |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Count & Types (5 Adult Pax on PNR): | � Passenger Count & Types (5 Adult Pax on PNR): |
| CP011 | PREREQUISITES | prerequisite | seed | - Pax 1 (Claimant / Booker): Regular Adult / Aeroplan Basic Member | - Pax 1 (Claimant / Booker): Regular Adult / Aeroplan Basic Member |
| CP012 | PREREQUISITES | prerequisite | seed | - Pax 2: Regular Adult / Non-member | - Pax 2: Regular Adult / Non-member |
| CP013 | PREREQUISITES | prerequisite | seed | - Pax 3: Regular Adult / Non-member | - Pax 3: Regular Adult / Non-member |
| CP014 | PREREQUISITES | prerequisite | seed | - Pax 4: Regular Adult / Non-member | - Pax 4: Regular Adult / Non-member |
| CP015 | PREREQUISITES | prerequisite | seed | - Pax 5: Regular Adult / Non-member | - Pax 5: Regular Adult / Non-member |
| CP016 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type -> Regular Adult (All 5) PASS -> 2. Controllability -> Controllable (Code 63) PASS -> ELIGIBLE | � Check Order: 1. Pax Type -> Regular Adult (All 5) PASS -> 2. Controllability -> Controllable (Code 63) PASS -> ELIGIBLE |
| CP017 | PREREQUISITES | prerequisite | seed | � PAX Count: 5 adults / Class: PY / Revenue: YES / ACR: No / Journey: > 72h | � PAX Count: 5 adults / Class: PY / Revenue: YES / ACR: No / Journey: > 72h |
| CP018 | PREREQUISITES | prerequisite | seed | � Overnight Eligible: YES (delay > 360 min) | � Overnight Eligible: YES (delay > 360 min) |
| CP019 | PREREQUISITES | prerequisite | seed | � Entitlements: Hotel: Rate of day, 3 nights max, $500.00 CAD cap per room / Meals: $30.00 x 5 = $150.00 CAD / Transport: $200.00 CAD (1-5 p | � Entitlements: Hotel: Rate of day, 3 nights max, $500.00 CAD cap per room / Meals: $30.00 x 5 = $150.00 CAD / Transport: $200.00 CAD (1-5 pax group) / Comm: $3 |
| CP020 | PREREQUISITES | prerequisite | seed | � Submitted Expenses (All Below Threshold): Hotel ($260.00 CAD) + Meals ($85.00 CAD) + Transport ($60.00 CAD) + Essentials ($45.00 CAD) = To | � Submitted Expenses (All Below Threshold): Hotel ($260.00 CAD) + Meals ($85.00 CAD) + Transport ($60.00 CAD) + Essentials ($45.00 CAD) = Total $450.00 CAD |
| CP021 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP022 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP023 | START | customer | chat | When the user selects English |  |
| CP024 | START | alert | chat | Then an alert information is displayed: | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP025 | START | bot | chat | Then the chatbot asks: "How can I help you today?" | How can I help you today? |
| CP026 | START | customer | chat | And the user says: "My flight from Toronto to Vancouver was delayed for 7 hours because of crew shortages. There were 5 adults traveling tog | My flight from Toronto to Vancouver was delayed for 7 hours because of crew shortages. There were 5 adults traveling together and we incurred expenses for food, |
| CP027 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP028 | START | system | implied | Then the chatbot checks: Is this a third-party submission? -> NO |  |
| CP029 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP031 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP032 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP033 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP034 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP035 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP036 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (5 Passengers on booking) |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | * Email: t***@gmail.com * Phone: +1***789 |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | When the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP041 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP042 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code -> CORRECT (attempt 1 of 5) |  |
| CP043 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP044 | PASSENGER & JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if this PNR is a group booking -> No |  |
| CP045 | PASSENGER & JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? -> YES (5 PAX found) |  |
| CP046 | PASSENGER & JOURNEY SELECTION (GenUC-08) | bot | chat | And the chatbot displays passenger list: | I found the following passengers on this booking: 1. [Pax 1 Name] (Claimant / Booker - Adult, Aeroplan Basic) 2. [Pax 2 Name] (Adult) 3. [Pax 3 Name] (Adult) 4. |
| CP047 | PASSENGER & JOURNEY SELECTION (GenUC-08) | customer | chat | When the user confirms: "Yes, claiming for all 5 passengers" | Yes, claiming for all 5 passengers |
| CP048 | PASSENGER & JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: * Flight: AC 301 * Route: Toronto (YYZ) -> Vancouver (YVR) * Date: June 15, 2026 * Departure Delay: 7 hours (420 minutes) * Passe |
| CP049 | PASSENGER & JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP050 | PASSENGER & JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there is more than 1 segment -> No |  |
| CP051 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot sends request to Case Services for duplicate check (GenUC-10) |  |
| CP052 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP053 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot checks 72-hour window passed -> YES |  |
| CP054 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot verifies Filing deadline limitation: | * Origin: YYZ (Ontario) -> Limitation = 730 days * Destination: YVR (British Columbia) -> Limitation = 1,095 days * Elapsed: Within limitation period -> PROCEED |
| CP055 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot checks if triage data is available -> YES |  |
| CP056 | TRIAGE AND DDS EVALUATION | verdict | api | Then DDS evaluates backend rules: | * Delay Code: 63 (Flight Crew Shortage / Scheduling) -> Controllable * Passenger Type: 5 Regular Adults -> Standard handling * Booker Status: Aeroplan Basic (Pa |
| CP057 | TRIAGE AND DDS EVALUATION | verdict | api | And DDS assigns Response Code: SoC-APPR-EL-08 |  |
| CP058 | FRAUD SCREENING (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening |  |
| CP059 | FRAUD SCREENING (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) |  |
| CP060 | ELIGIBLE RESULT & ENTITLEMENT DISPLAY (SoC-03b) | bot | chat | Then the chatbot displays: | Great news! Based on the details of your flight, you and the passengers on your booking are eligible for expense reimbursement. Your flight AC 301 from Toronto  |
| CP061 | ELIGIBLE RESULT & ENTITLEMENT DISPLAY (SoC-03b) | bot | chat | And the chatbot displays the combined entitlements for 5 passengers: | Based on the length of your disruption (7 hours) and 5 traveling passengers, you may be eligible for reimbursement in the following categories: * Hotel accommod |
| CP062 | RECEIPT UPLOAD & OCR VALIDATION (RR-01) | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP063 | RECEIPT UPLOAD & OCR VALIDATION (RR-01) | system | implied | When the user uploads the four receipts (all below threshold): | * Receipt 1: Hotel receipt � $260.00 CAD (1 night accommodation) * Receipt 2: Meal receipt � $85.00 CAD (Dinner for 5) * Receipt 3: Taxi receipt � $60.00 CAD (V |
| CP064 | RECEIPT UPLOAD & OCR VALIDATION (RR-01) | system | implied | Then OCR engine extracts and validates line items: | * Receipt 1 � Hotel Accommodation: - Line item: Hotel stay, 1 night � $260.00 CAD - Date: June 15, 2026 - Category: Hotel - Within disruption window: YES - Nigh |
| CP065 | RECEIPT VALIDATION SUMMARY | system | implied | Then the system displays the OCR validation summary: | * Total receipts processed: 4 * Total line items extracted: 4 * Items PASSED: 4 * Items FLAGGED for agent review: 0 * Items FAILED: 0 * Expense Breakdown: - Hot |
| CP066 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case in Case Services: | * DDS response code: SoC-APPR-EL-08 * Eligibility: ELIGIBLE * Regime: APPR * Approved Total: $450.00 CAD (Hotel $260.00 + Meals $85.00 + Transport $60.00 + Esse |
| CP067 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP068 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully. Here's a summary: * Case Reference: [Case Number] * Total claim amount: $450.00 CAD * Categories: Hotel ($260.00), M |
| CP069 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP070 | NOTIFICATION | email | email | And an eligible confirmation email is sent to the passenger at t***@gmail.com |  |
| CP071 | CLAIMS PAYMENT FLOW | system | implied | Then the system initiates payment processing |  |
| CP072 | CLAIMS PAYMENT FLOW | system | implied | And Case Services calculates: | Approved amount: $450.00 CAD Currency conversion: CAD -> country of residence currency (if different) Payment method determination based on country of residence |
| CP073 | CLAIMS PAYMENT FLOW | bot | chat | Then the chatbot responds: | To complete your reimbursement, we'll need your payment details. |
| CP074 | CLAIMS PAYMENT FLOW | system | implied | And the chatbot collects: | Country of residence: Canada Payment method: Interac Email address for Interac transfer: [t***@gmail.com] |
| CP075 | CLAIMS PAYMENT FLOW | bot | chat | Then the chatbot responds: | Your payment of $450.00 CAD will be processed via Interac e-Transfer to your email. You should receive the transfer notification within [X] business days. |
| CP076 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP077 | END FLOW (GLOB-11) | customer | chat | When the user selects "No" | No |
| CP078 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-EL-08 � 5 Adult Pax Delay Code 63 All 4 Categories Below Threshold |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated (Pax 1) |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated with 5 associated passengers |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant", "Adult", "Multi-PAX (5)" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Basic Member (Booker Only)" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Associated Passengers evaluation shows: | / Passenger / Type  / Aeroplan Tier / Exception Type / / Pax 1     / Adult / Basic Member  / None (Regular) / / Pax 2     / Adult / Non-Member    / None (Regula |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 301 YYZ -> YVR as the claimed flight |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (7 hours)" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 301 YYZ -> YVR |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 301 |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Flight Crew Shortage / Scheduling (Departure delay code 63 � CONTROLLABLE)" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 420 min (7 hours) |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Evaluation Order shows: | / Order / Check Step               / Result                                / / 1     / Passenger Exception Type / Regular Adult (All 5) PASS            / / 2    |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Overnight Eligible is "YES (delay > 360 min)" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the ACR Issued shows Hotel No, Transport No, Meal No |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-EL-08" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Entitlements for 5 adults PY show: | / Category      / Entitlement Limit                   / / Hotel         / Rate of day, max 3 nights, $500 cap / / Meals         / $150.00 CAD ($30.00/pax x 5)   |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows: | / Category      / Claimed Amount / Approved Amount / Status                                              / / Hotel         / $260.00 CAD    / $260.00 CAD     /  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is $450.00 CAD |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 0 |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "$450.00 CAD (APPR � Suggested Highlighted)" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource result is "GREEN" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP123 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-EL-08 � 5 Adult Pax Code 63 All Categories Below Threshold (Interac) |  |
| CP124 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-EL-08 is determined as ELIGIBLE for 5 adult passengers |  |
| CP125 | PAYMENT VALIDATION | payment | chat | Then SOC payment mode is validated as CASH ONLY |  |
| CP126 | PAYMENT VALIDATION | payment | chat | And the route is AC 301 YYZ -> YVR with a departure delay of 420 min (7 hours) for 5 adults in PY |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And the group entitlements for 5 adults are Hotel $500.00 CAD cap, Meals $150.00 CAD, Transport $200.00 CAD, Essentials $150.00 CAD |  |
| CP128 | PAYMENT VALIDATION | payment | chat | And the approved receipts are Hotel $260.00 CAD, Meals $85.00 CAD, Transport $60.00 CAD, and Essentials $45.00 CAD totalling $450.00 CAD |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And the system verifies $450.00 CAD is less than the $500.00 SOC sign-off threshold |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And no secondary manual approval or agent review is triggered |  |
| CP131 | PAYMENT VALIDATION | payment | chat | And Case Services determines payment method based on country of residence: | / Country of Residence / Payment Method Determination / Selected Method / / Canada               / Interac (E-Transfer)         / Interac         / / US + 70 BS |
| CP132 | PAYMENT VALIDATION | payment | chat | And the bot collects only the email address for Interac transfer without requesting bank account details |  |
| CP133 | PAYMENT VALIDATION | payment | chat | And the country of residence is confirmed as Canada with currency CAD |  |
| CP134 | PAYMENT VALIDATION | payment | chat | And the total approved compensation is $450.00 CAD |  |
| CP135 | PAYMENT VALIDATION | payment | chat | And the Comp Status is "Sent for issuance" |  |
| CP136 | PAYMENT VALIDATION | payment | manual | And the compensation record is created and batch file dispatched to Unifier |  |
| CP137 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard displays "$450.00 CAD", "Cash", "Interac", and status confirmed via talkback |  |
| CP138 | EXPECTED RESULTS | verdict | chat | SoC-APPR-EL-08. | SoC-APPR-EL-08. |
| CP139 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP140 | EXPECTED RESULTS | verdict | api | Controllable delay >= 2h (7 hours, Code 63 Crew Shortage / Scheduling). | Controllable delay >= 2h (7 hours, Code 63 Crew Shortage / Scheduling). |
| CP141 | EXPECTED RESULTS | verdict | api | Passenger type checked FIRST (5 Regular Adults), then controllability checked SECOND (Code 63 Controllable). | Passenger type checked FIRST (5 Regular Adults), then controllability checked SECOND (Code 63 Controllable). |
| CP142 | EXPECTED RESULTS | verdict | chat | Booker holds Aeroplan Basic membership while the other 4 passengers are non-members. | Booker holds Aeroplan Basic membership while the other 4 passengers are non-members. |
| CP143 | EXPECTED RESULTS | verdict | chat | Operating carrier correctly identified as AC. | Operating carrier correctly identified as AC. |
| CP144 | EXPECTED RESULTS | verdict | chat | Fraud screening GREEN. | Fraud screening GREEN. |
| CP145 | EXPECTED RESULTS | verdict | chat | Entitlements applied for 5 passengers with Meals cap at $150.00 CAD, Hotel cap at $500.00 CAD, Transport cap at $200.00 CAD, and Essentials  | Entitlements applied for 5 passengers with Meals cap at $150.00 CAD, Hotel cap at $500.00 CAD, Transport cap at $200.00 CAD, and Essentials cap at $150.00 CAD. |
| CP146 | EXPECTED RESULTS | verdict | chat | Submitted receipts across all four categories (Hotel $260.00 CAD, Meals $85.00 CAD, Transport $60.00 CAD, Essentials $45.00 CAD) are validat | Submitted receipts across all four categories (Hotel $260.00 CAD, Meals $85.00 CAD, Transport $60.00 CAD, Essentials $45.00 CAD) are validated as below-threshol |
| CP147 | EXPECTED RESULTS | verdict | chat | Full receipt upload + OCR + case creation + notification + automated Interac payout flow (email only collected) completes with total $450.00 | Full receipt upload + OCR + case creation + notification + automated Interac payout flow (email only collected) completes with total $450.00 CAD without manual  |
