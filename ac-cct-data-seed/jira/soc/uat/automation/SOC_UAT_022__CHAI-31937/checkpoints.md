# SOC_UAT_022 · CHAI-31937 — checkpoints

**Goal:** Verify APPR SOC eligibility, hotel cap evaluation, OCR extraction, and manual review escalation for a single adult passenger with Basic Aeroplan membership experiencing a 7-hour controllable flight plan delay (Code 61), where a submitted hotel receipt of $580.00 CAD exceeds the $500.00 CAD policy hotel cap, triggering routing to the Manual Handling Queue for agent review before any Interac payout issuance.

Methods: seed 15, chat 45, api 6, email 2, dashboard 40, implied 20, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify APPR SOC eligibility, hotel cap evaluation, OCR extraction, and manual review escalation for a single adult passenger with Basic Aero |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 301 YYZ -> YVR | � Itinerary: Single segment � AC 301 YYZ -> YVR |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 301 YYZ -> YVR | � SOC Segment (per SoC Flight Identifier): AC 301 YYZ -> YVR |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 301 YYZ -> YVR, Dep: 15-Jun 08:00 | � Promised Itinerary: AC 301 YYZ -> YVR, Dep: 15-Jun 08:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 301 YYZ -> YVR, Dep: 15-Jun 15:00 | � Actual Itinerary: AC 301 YYZ -> YVR, Dep: 15-Jun 15:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 420 min (7 hours) | � Departure Delay: 420 min (7 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure Delay Code: 61 (Flight Operations / Flight Plan Preparation) � Controllable | � Departure Delay Code: 61 (Flight Operations / Flight Plan Preparation) � Controllable |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Controllable (Code 61) | � Controllability: Controllable (Code 61) |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Count & Types (1 Adult Pax on PNR): | � Passenger Count & Types (1 Adult Pax on PNR): |
| CP011 | PREREQUISITES | prerequisite | seed | - Pax 1 (Claimant / Booker): Regular Adult / Aeroplan Basic Member | - Pax 1 (Claimant / Booker): Regular Adult / Aeroplan Basic Member |
| CP012 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type -> Regular Adult PASS -> 2. Controllability -> Controllable (Code 61) PASS -> ELIGIBLE | � Check Order: 1. Pax Type -> Regular Adult PASS -> 2. Controllability -> Controllable (Code 61) PASS -> ELIGIBLE |
| CP013 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / ACR: No / Journey: > 72h | � PAX Count: 1 adult / Class: PY / Revenue: YES / ACR: No / Journey: > 72h |
| CP014 | PREREQUISITES | prerequisite | seed | � Overnight Eligible: YES (delay > 360 min) | � Overnight Eligible: YES (delay > 360 min) |
| CP015 | PREREQUISITES | prerequisite | seed | � Entitlements: Hotel: Rate of day, 3 nights max, $500.00 CAD cap / Meals: $30.00 CAD / Transport: $200.00 CAD / Comm: $30.00 CAD / Parking: | � Entitlements: Hotel: Rate of day, 3 nights max, $500.00 CAD cap / Meals: $30.00 CAD / Transport: $200.00 CAD / Comm: $30.00 CAD / Parking: $50.00 CAD / Essent |
| CP016 | PREREQUISITES | prerequisite | seed | � Submitted Expense: Accommodation only � 1 receipt of $580.00 CAD (Exceeds $500.00 hotel cap -> Routes to Manual Handling Queue) | � Submitted Expense: Accommodation only � 1 receipt of $580.00 CAD (Exceeds $500.00 hotel cap -> Routes to Manual Handling Queue) |
| CP017 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP018 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP019 | START | customer | chat | When the user selects English |  |
| CP020 | START | alert | chat | Then an alert information is displayed: | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP021 | START | bot | chat | Then the chatbot asks: "How can I help you today?" | How can I help you today? |
| CP022 | START | customer | chat | And the user says: "My flight from Toronto to Vancouver was delayed by 7 hours due to flight plan issues. I had to stay overnight at a hotel | My flight from Toronto to Vancouver was delayed by 7 hours due to flight plan issues. I had to stay overnight at a hotel and paid out of pocket. Can I get reimb |
| CP023 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP024 | START | system | implied | Then the chatbot checks: Is this a third-party submission? -> NO |  |
| CP025 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (1 Passenger on booking) |  |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | * Email: t***@gmail.com * Phone: +1***789 |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | When the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP038 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code -> CORRECT (attempt 1 of 5) |  |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP040 | PASSENGER & JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if this PNR is a group booking -> No |  |
| CP041 | PASSENGER & JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? -> No (1 PAX) |  |
| CP042 | PASSENGER & JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: * Flight: AC 301 * Route: Toronto (YYZ) -> Vancouver (YVR) * Date: June 15, 2026 * Departure Delay: 7 hours (420 minutes) * Passe |
| CP043 | PASSENGER & JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | PASSENGER & JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there is more than 1 segment -> No |  |
| CP045 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot sends request to Case Services for duplicate check (GenUC-10) |  |
| CP046 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP047 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot checks 72-hour window passed -> YES |  |
| CP048 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot verifies Filing deadline limitation: | * Origin: YYZ (Ontario) -> Limitation = 730 days * Destination: YVR (British Columbia) -> Limitation = 1,095 days * Elapsed: Within limitation period -> PROCEED |
| CP049 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot checks if triage data is available -> YES |  |
| CP050 | TRIAGE AND DDS EVALUATION | verdict | api | Then DDS evaluates backend rules: | * Delay Code: 61 (Flight Operations / Flight Plan Preparation) -> Controllable * Passenger Type: 1 Regular Adult -> Standard handling * Booker Status: Aeroplan  |
| CP051 | TRIAGE AND DDS EVALUATION | verdict | api | And DDS assigns Response Code: SoC-APPR-EL-08 |  |
| CP052 | FRAUD SCREENING (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening |  |
| CP053 | FRAUD SCREENING (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) |  |
| CP054 | ELIGIBLE RESULT & ENTITLEMENT DISPLAY (SoC-03b) | bot | chat | Then the chatbot displays: | Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 301 from Toronto to Vancouver was delayed by approxi |
| CP055 | ELIGIBLE RESULT & ENTITLEMENT DISPLAY (SoC-03b) | bot | chat | And the chatbot displays the entitlements for 1 passenger: | Based on the length of your disruption (7 hours), you may be eligible for reimbursement in the following categories: * Hotel accommodation: Rate of the day (up  |
| CP056 | RECEIPT UPLOAD & OCR VALIDATION (RR-01) | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP057 | RECEIPT UPLOAD & OCR VALIDATION (RR-01) | system | implied | When the user uploads the hotel receipt ($580.00 CAD): | * Receipt 1: Hotel receipt � $580.00 CAD (1 night accommodation, exceeds $500 cap) |
| CP058 | RECEIPT UPLOAD & OCR VALIDATION (RR-01) | system | implied | Then OCR engine extracts and validates line items: | * Receipt 1 � Hotel Accommodation: - Line item: Hotel stay, 1 night � $580.00 CAD - Date: June 15, 2026 / Category: Hotel / Within disruption window: YES - Cap  |
| CP059 | RECEIPT VALIDATION & HOTEL CAP CHECK | system | implied | Then the system evaluates hotel claim value: | * Total Claimed Hotel Amount: $580.00 CAD * Policy Maximum Hotel Cap: $500.00 CAD * System Rule Check: Submitted hotel amount ($580.00 CAD) EXCEEDS the $500.00  |
| CP060 | CASE CREATION & MANUAL ROUTING (GLOB-09) | system | implied | Then the system creates a case in Case Services: | * DDS response code: SoC-APPR-EL-08 * Eligibility: ELIGIBLE (Pending Review) * Status: Pending Agent Review * Queue: Manual Handling Queue * Reason: Hotel expen |
| CP061 | CASE CREATION & MANUAL ROUTING (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP062 | CASE CREATION & MANUAL ROUTING (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been received and submitted for agent review. Here's a summary: * Case Reference: [Case Number] * Total submitted claim amount: $580.00 CAD * Cat |
| CP063 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP064 | NOTIFICATION | email | email | And a manual review confirmation email is sent to the passenger at t***@gmail.com |  |
| CP065 | CLAIMS PAYMENT PRE-COLLECTION FLOW | system | implied | Then the chatbot prompts to collect payment information in advance: | "To ensure prompt payment once your claim is reviewed and approved, please confirm your payment details." |
| CP066 | CLAIMS PAYMENT PRE-COLLECTION FLOW | system | implied | And the chatbot collects: | Country of residence: Canada Payment method: Interac Email address for Interac transfer: [t***@gmail.com] |
| CP067 | CLAIMS PAYMENT PRE-COLLECTION FLOW | bot | chat | Then the chatbot responds: | Thank you. Your payment details have been saved. If approved by our review team, funds will be sent via Interac e-Transfer to your email. |
| CP068 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP069 | END FLOW (GLOB-11) | customer | chat | When the user selects "No" | No |
| CP070 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-EL-08 � 1 Adult Pax Delay Code 61 Hotel Exceeds $500 Cap Manual Review |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Pending Agent Review" |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly (30-day target) |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is "Manual Handling Queue" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated (Pax 1) |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated with 1 passenger |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant", "Adult", "High Value (> $500 Hotel)" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Basic Member" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 301 YYZ -> YVR as the claimed flight |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (7 hours)" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 301 YYZ -> YVR |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 301 |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Flight Operations / Flight Plan Preparation (Departure delay code 61 � CONTROLLABLE)" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 420 min (7 hours) |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Evaluation Order shows: | / Order / Check Step               / Result                                / / 1     / Passenger Exception Type / Regular Adult PASS                    / / 2    |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Overnight Eligible is "YES (delay > 360 min)" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the ACR Issued shows Hotel No, Transport No, Meal No |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-EL-08" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Entitlements for 1 adult PY show: | / Category      / Entitlement Limit                   / / Hotel         / Rate of day, max 3 nights, $500 cap / / Meals         / $30.00 CAD                     |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows: | / Category      / Claimed Amount / Policy Cap   / Flag / Status                                         / / Hotel         / $580.00 CAD    / $500.00 CAD  / REVI |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Claimed Amount is "$580.00 CAD" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the System Threshold Banner displays: "Hotel expense exceeds $500.00 cap - Manual review required" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 1 |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource result is "GREEN" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is unlocked for agent review |  |
| CP113 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-EL-08 � 1 Adult Pax Code 61 Hotel Exceeds $500 Cap Manual Routing (Interac) |  |
| CP114 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-EL-08 is evaluated for 1 adult passenger |  |
| CP115 | PAYMENT VALIDATION | payment | chat | Then SOC payment mode is validated as CASH ONLY |  |
| CP116 | PAYMENT VALIDATION | payment | chat | And the total submitted hotel receipt amounts to $580.00 CAD |  |
| CP117 | PAYMENT VALIDATION | payment | chat | And the system verifies the hotel amount exceeds the $500.00 CAD policy hotel cap threshold |  |
| CP118 | PAYMENT VALIDATION | payment | manual | Then automated payment dispatch to Unifier is blocked pending agent review |  |
| CP119 | PAYMENT VALIDATION | payment | chat | And the payment status is set to "Pending Agent Review" |  |
| CP120 | PAYMENT VALIDATION | payment | chat | And Case Services verifies payment method determination for Canada: | / Country of Residence / Payment Method Determination / Pre-collected Detail    / / Canada               / Interac (E-Transfer)         / Recipient Email ID onl |
| CP121 | PAYMENT VALIDATION | payment | chat | And the bot confirms email "t***@gmail.com" is recorded without collecting bank account details |  |
| CP122 | PAYMENT VALIDATION | payment | chat | And upon manual agent adjudication and approval up to allowable policy caps, Interac issuance will be triggered |  |
| CP123 | EXPECTED RESULTS | verdict | chat | SoC-APPR-EL-08. | SoC-APPR-EL-08. |
| CP124 | EXPECTED RESULTS | verdict | chat | ELIGIBLE (Routed to Manual Review). | ELIGIBLE (Routed to Manual Review). |
| CP125 | EXPECTED RESULTS | verdict | api | Controllable delay >= 2h (7 hours, Code 61 Flight Operations / Flight Plan Preparation). | Controllable delay >= 2h (7 hours, Code 61 Flight Operations / Flight Plan Preparation). |
| CP126 | EXPECTED RESULTS | verdict | api | Passenger type checked FIRST (1 Regular Adult), then controllability checked SECOND (Code 61 Controllable). | Passenger type checked FIRST (1 Regular Adult), then controllability checked SECOND (Code 61 Controllable). |
| CP127 | EXPECTED RESULTS | verdict | chat | Booker holds Aeroplan Basic membership. | Booker holds Aeroplan Basic membership. |
| CP128 | EXPECTED RESULTS | verdict | chat | Operating carrier correctly identified as AC. | Operating carrier correctly identified as AC. |
| CP129 | EXPECTED RESULTS | verdict | chat | Fraud screening GREEN. | Fraud screening GREEN. |
| CP130 | EXPECTED RESULTS | verdict | chat | Entitlement applied for 1 passenger with hotel cap at $500.00 CAD. | Entitlement applied for 1 passenger with hotel cap at $500.00 CAD. |
| CP131 | EXPECTED RESULTS | verdict | chat | Submitted hotel receipt of $580.00 CAD exceeds the $500.00 CAD hotel policy cap. | Submitted hotel receipt of $580.00 CAD exceeds the $500.00 CAD hotel policy cap. |
| CP132 | EXPECTED RESULTS | verdict | chat | System blocks auto-payout, transitions case status to "Pending Agent Review", assigns to Manual Handling Queue, pre-collects recipient email | System blocks auto-payout, transitions case status to "Pending Agent Review", assigns to Manual Handling Queue, pre-collects recipient email for Interac transfe |
