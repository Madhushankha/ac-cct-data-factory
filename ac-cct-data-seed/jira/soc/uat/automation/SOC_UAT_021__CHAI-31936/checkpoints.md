# SOC_UAT_021 · CHAI-31936 — checkpoints

**Goal:** Verify APPR SOC eligibility, group entitlement evaluation, OCR line-item processing across four categories (Meals, Transport, Accommodation, Essentials), and manual review escalation for a 2-adult booking (1 Basic Aeroplan booker + 1 non-member) experiencing a 7-hour controllable airport-related delay (Code 06), where submitted expenses total $980.00 CAD (exceeding the $800.00 CAD total case threshold) and trigger routing to the Manual Handling Queue for agent review before any Interac payout issuance.

Methods: seed 16, chat 47, api 6, email 2, dashboard 41, implied 20, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify APPR SOC eligibility, group entitlement evaluation, OCR line-item processing across four categories (Meals, Transport, Accommodation, |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 301 YYZ -> YVR | � Itinerary: Single segment � AC 301 YYZ -> YVR |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 301 YYZ -> YVR | � SOC Segment (per SoC Flight Identifier): AC 301 YYZ -> YVR |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 301 YYZ -> YVR, Dep: 15-Jun 08:00 | � Promised Itinerary: AC 301 YYZ -> YVR, Dep: 15-Jun 08:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 301 YYZ -> YVR, Dep: 15-Jun 15:00 | � Actual Itinerary: AC 301 YYZ -> YVR, Dep: 15-Jun 15:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 420 min (7 hours) | � Departure Delay: 420 min (7 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure Delay Code: 06 (Airport Operations / Ground Handling within AC control) � Controllable | � Departure Delay Code: 06 (Airport Operations / Ground Handling within AC control) � Controllable |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Controllable (Code 06) | � Controllability: Controllable (Code 06) |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Count & Types (2 Adult Pax on PNR): | � Passenger Count & Types (2 Adult Pax on PNR): |
| CP011 | PREREQUISITES | prerequisite | seed | - Pax 1 (Claimant / Booker): Regular Adult / Aeroplan Basic Member | - Pax 1 (Claimant / Booker): Regular Adult / Aeroplan Basic Member |
| CP012 | PREREQUISITES | prerequisite | seed | - Pax 2: Regular Adult / Non-member | - Pax 2: Regular Adult / Non-member |
| CP013 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type -> Regular Adult (Both) PASS -> 2. Controllability -> Controllable (Code 06) PASS -> ELIGIBLE | � Check Order: 1. Pax Type -> Regular Adult (Both) PASS -> 2. Controllability -> Controllable (Code 06) PASS -> ELIGIBLE |
| CP014 | PREREQUISITES | prerequisite | seed | � PAX Count: 2 adults / Class: PY / Revenue: YES / ACR: No / Journey: > 72h | � PAX Count: 2 adults / Class: PY / Revenue: YES / ACR: No / Journey: > 72h |
| CP015 | PREREQUISITES | prerequisite | seed | � Overnight Eligible: YES (delay > 360 min) | � Overnight Eligible: YES (delay > 360 min) |
| CP016 | PREREQUISITES | prerequisite | seed | � Entitlements: Hotel: Rate of day, 3 nights max, $500.00 CAD cap per room / Meals: $30.00 x 2 = $60.00 CAD / Transport: $200.00 CAD / Comm: | � Entitlements: Hotel: Rate of day, 3 nights max, $500.00 CAD cap per room / Meals: $30.00 x 2 = $60.00 CAD / Transport: $200.00 CAD / Comm: $30.00 x 2 = $60.00 |
| CP017 | PREREQUISITES | prerequisite | seed | � Submitted Expenses (Total $980.00 CAD > $800.00 Cap): Hotel ($550.00 CAD) + Meals ($130.00 CAD) + Transport ($220.00 CAD) + Essentials ($8 | � Submitted Expenses (Total $980.00 CAD > $800.00 Cap): Hotel ($550.00 CAD) + Meals ($130.00 CAD) + Transport ($220.00 CAD) + Essentials ($80.00 CAD) -> Exceeds |
| CP018 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP019 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP020 | START | customer | chat | When the user selects English |  |
| CP021 | START | alert | chat | Then an alert information is displayed: | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP022 | START | bot | chat | Then the chatbot asks: "How can I help you today?" | How can I help you today? |
| CP023 | START | customer | chat | And the user says: "My flight from Toronto to Vancouver was delayed by 7 hours due to airport ground handling operations. There were 2 of us | My flight from Toronto to Vancouver was delayed by 7 hours due to airport ground handling operations. There were 2 of us traveling and we incurred high expenses |
| CP024 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP025 | START | system | implied | Then the chatbot checks: Is this a third-party submission? -> NO |  |
| CP026 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (2 Passengers on booking) |  |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | * Email: t***@gmail.com * Phone: +1***789 |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | When the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP039 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code -> CORRECT (attempt 1 of 5) |  |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP041 | PASSENGER & JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if this PNR is a group booking -> No |  |
| CP042 | PASSENGER & JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? -> YES (2 PAX found) |  |
| CP043 | PASSENGER & JOURNEY SELECTION (GenUC-08) | bot | chat | And the chatbot displays passenger list: | I found the following passengers on this booking: 1. [Pax 1 Name] (Claimant / Booker - Adult, Aeroplan Basic) 2. [Pax 2 Name] (Adult) Are you claiming expenses  |
| CP044 | PASSENGER & JOURNEY SELECTION (GenUC-08) | customer | chat | When the user confirms: "Yes, claiming for both passengers" | Yes, claiming for both passengers |
| CP045 | PASSENGER & JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: * Flight: AC 301 * Route: Toronto (YYZ) -> Vancouver (YVR) * Date: June 15, 2026 * Departure Delay: 7 hours (420 minutes) * Passe |
| CP046 | PASSENGER & JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP047 | PASSENGER & JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there is more than 1 segment -> No |  |
| CP048 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot sends request to Case Services for duplicate check (GenUC-10) |  |
| CP049 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP050 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot checks 72-hour window passed -> YES |  |
| CP051 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot verifies Filing deadline limitation: | * Origin: YYZ (Ontario) -> Limitation = 730 days * Destination: YVR (British Columbia) -> Limitation = 1,095 days * Elapsed: Within limitation period -> PROCEED |
| CP052 | ELIGIBILITY & TIME LIMIT CHECKS | system | implied | Then the chatbot checks if triage data is available -> YES |  |
| CP053 | TRIAGE AND DDS EVALUATION | verdict | api | Then DDS evaluates backend rules: | * Delay Code: 06 (Airport Operations / Ground Handling) -> Controllable * Passenger Type: 2 Regular Adults -> Standard handling * Booker Status: Aeroplan Basic  |
| CP054 | TRIAGE AND DDS EVALUATION | verdict | api | And DDS assigns Response Code: SoC-APPR-EL-08 |  |
| CP055 | FRAUD SCREENING (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening |  |
| CP056 | FRAUD SCREENING (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) |  |
| CP057 | ELIGIBLE RESULT & ENTITLEMENT DISPLAY (SoC-03b) | bot | chat | Then the chatbot displays: | Great news! Based on the details of your flight, you and the passenger on your booking are eligible for expense reimbursement. Your flight AC 301 from Toronto t |
| CP058 | ELIGIBLE RESULT & ENTITLEMENT DISPLAY (SoC-03b) | bot | chat | And the chatbot displays the combined entitlements for 2 passengers: | Based on the length of your disruption (7 hours) and 2 traveling passengers, you may be eligible for reimbursement in the following categories: * Hotel accommod |
| CP059 | RECEIPT UPLOAD & OCR VALIDATION (RR-01) | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP060 | RECEIPT UPLOAD & OCR VALIDATION (RR-01) | system | implied | When the user uploads the four receipts (Totaling $980.00 CAD): | * Receipt 1: Hotel receipt � $550.00 CAD (1 night accommodation, exceeds $500 cap) * Receipt 2: Meal receipt � $130.00 CAD (Dinner for 2, exceeds $60 cap) * Rec |
| CP061 | RECEIPT UPLOAD & OCR VALIDATION (RR-01) | system | implied | Then OCR engine extracts and validates line items: | * Receipt 1 � Hotel Accommodation: - Line item: Hotel stay, 1 night � $550.00 CAD - Date: June 15, 2026 / Category: Hotel / Within disruption window: YES - Cap  |
| CP062 | RECEIPT VALIDATION & TOTAL CAP CHECK | system | implied | Then the system evaluates total claim value: | * Total Claimed Amount: $980.00 CAD * Total Calculated Capped Entitlement: $820.00 CAD ($500 + $60 + $200 + $60) * System Rule Check: Total submitted ($980.00 C |
| CP063 | CASE CREATION & MANUAL ROUTING (GLOB-09) | system | implied | Then the system creates a case in Case Services: | * DDS response code: SoC-APPR-EL-08 * Eligibility: ELIGIBLE (Pending Review) * Status: Pending Agent Review * Queue: Manual Handling Queue * Reason: Total expen |
| CP064 | CASE CREATION & MANUAL ROUTING (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP065 | CASE CREATION & MANUAL ROUTING (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been received and submitted for agent review. Here's a summary: * Case Reference: [Case Number] * Total submitted claim amount: $980.00 CAD * Cat |
| CP066 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP067 | NOTIFICATION | email | email | And a manual review confirmation email is sent to the passenger at t***@gmail.com |  |
| CP068 | CLAIMS PAYMENT PRE-COLLECTION FLOW | system | implied | Then the chatbot prompts to collect payment information in advance: | "To ensure prompt payment once your claim is reviewed and approved, please confirm your payment details." |
| CP069 | CLAIMS PAYMENT PRE-COLLECTION FLOW | system | implied | And the chatbot collects: | Country of residence: Canada Payment method: Interac Email address for Interac transfer: [t***@gmail.com] |
| CP070 | CLAIMS PAYMENT PRE-COLLECTION FLOW | bot | chat | Then the chatbot responds: | Thank you. Your payment details have been saved. If approved by our review team, funds will be sent via Interac e-Transfer to your email. |
| CP071 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP072 | END FLOW (GLOB-11) | customer | chat | When the user selects "No" | No |
| CP073 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-EL-08 � 2 Adult Pax Delay Code 06 Total Exceeds $800 Manual Review |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Pending Agent Review" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly (30-day target) |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is "Manual Handling Queue" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated (Pax 1) |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated with 2 associated passengers |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant", "Adult", "Multi-PAX (2)", "High Value (> $800)" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Basic Member (Booker Only)" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Associated Passengers evaluation shows: | / Passenger / Type  / Aeroplan Tier / Exception Type / / Pax 1     / Adult / Basic Member  / None (Regular) / / Pax 2     / Adult / Non-Member    / None (Regula |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 301 YYZ -> YVR as the claimed flight |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (7 hours)" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 301 YYZ -> YVR |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 301 |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Airport Operations / Ramp Ground Handling (Departure delay code 06 � CONTROLLABLE)" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 420 min (7 hours) |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Evaluation Order shows: | / Order / Check Step               / Result                                / / 1     / Passenger Exception Type / Regular Adult (Both) PASS             / / 2    |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Overnight Eligible is "YES (delay > 360 min)" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the ACR Issued shows Hotel No, Transport No, Meal No |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-EL-08" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Entitlements for 2 adults PY show: | / Category      / Entitlement Limit                   / / Hotel         / Rate of day, max 3 nights, $500 cap / / Meals         / $60.00 CAD ($30.00/pax x 2)    |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows: | / Category      / Claimed Amount / Capped Value / Flag / Status                                         / / Hotel         / $550.00 CAD    / $500.00 CAD  / REVI |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Claimed Amount is "$980.00 CAD" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the System Threshold Banner displays: "Total claim exceeds $800.00 threshold - Manual review required" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 4 |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource result is "GREEN" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is unlocked for agent review |  |
| CP117 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-EL-08 � 2 Adult Pax Code 06 Total Exceeds $800 Manual Routing (Interac) |  |
| CP118 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-EL-08 is evaluated for 2 adult passengers |  |
| CP119 | PAYMENT VALIDATION | payment | chat | Then SOC payment mode is validated as CASH ONLY |  |
| CP120 | PAYMENT VALIDATION | payment | chat | And the total submitted receipts amount to $980.00 CAD (Hotel $550 + Meals $130 + Transport $220 + Essentials $80) |  |
| CP121 | PAYMENT VALIDATION | payment | chat | And the system verifies total amount exceeds the $800.00 CAD automated issuance threshold |  |
| CP122 | PAYMENT VALIDATION | payment | manual | Then automated payment dispatch to Unifier is blocked pending agent review |  |
| CP123 | PAYMENT VALIDATION | payment | chat | And the payment status is set to "Pending Agent Review" |  |
| CP124 | PAYMENT VALIDATION | payment | chat | And Case Services verifies payment method determination for Canada: | / Country of Residence / Payment Method Determination / Pre-collected Detail    / / Canada               / Interac (E-Transfer)         / Recipient Email ID onl |
| CP125 | PAYMENT VALIDATION | payment | chat | And the bot confirms email "t***@gmail.com" is recorded without collecting bank account details |  |
| CP126 | PAYMENT VALIDATION | payment | chat | And upon manual agent adjudication and approval up to allowable policy caps, Interac issuance will be triggered |  |
| CP127 | EXPECTED RESULTS | verdict | chat | SoC-APPR-EL-08. | SoC-APPR-EL-08. |
| CP128 | EXPECTED RESULTS | verdict | chat | ELIGIBLE (Routed to Manual Review). | ELIGIBLE (Routed to Manual Review). |
| CP129 | EXPECTED RESULTS | verdict | api | Controllable delay >= 2h (7 hours, Code 06 Airport Operations / Ramp Ground Handling). | Controllable delay >= 2h (7 hours, Code 06 Airport Operations / Ramp Ground Handling). |
| CP130 | EXPECTED RESULTS | verdict | api | Passenger type checked FIRST (2 Regular Adults), then controllability checked SECOND (Code 06 Controllable). | Passenger type checked FIRST (2 Regular Adults), then controllability checked SECOND (Code 06 Controllable). |
| CP131 | EXPECTED RESULTS | verdict | chat | Booker holds Aeroplan Basic membership while the other passenger is a non-member. | Booker holds Aeroplan Basic membership while the other passenger is a non-member. |
| CP132 | EXPECTED RESULTS | verdict | chat | Operating carrier correctly identified as AC. | Operating carrier correctly identified as AC. |
| CP133 | EXPECTED RESULTS | verdict | chat | Fraud screening GREEN. | Fraud screening GREEN. |
| CP134 | EXPECTED RESULTS | verdict | chat | Entitlements applied for 2 passengers (Meals cap $60, Hotel cap $500, Transport cap $200, Essentials cap $60). | Entitlements applied for 2 passengers (Meals cap $60, Hotel cap $500, Transport cap $200, Essentials cap $60). |
| CP135 | EXPECTED RESULTS | verdict | chat | Submitted receipts across all four categories total $980.00 CAD, exceeding the $800.00 CAD automated compensation threshold. | Submitted receipts across all four categories total $980.00 CAD, exceeding the $800.00 CAD automated compensation threshold. |
| CP136 | EXPECTED RESULTS | verdict | chat | System blocks auto-payout, transitions case status to "Pending Agent Review", assigns to Manual Handling Queue, pre-collects recipient email | System blocks auto-payout, transitions case status to "Pending Agent Review", assigns to Manual Handling Queue, pre-collects recipient email for Interac transfe |
