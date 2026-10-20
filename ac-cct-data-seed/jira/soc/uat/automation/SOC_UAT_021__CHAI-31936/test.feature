Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
When the user selects English
Then an alert information is displayed:
"Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then the chatbot asks: "How can I help you today?"
And the user says: "My flight from Toronto to Vancouver was delayed by 7 hours due to airport ground handling operations. There were 2 of us traveling and we incurred high expenses for hotel, meals, transport, and essential items. Can we get reimbursed?"
When the chatbot identifies Standards of Care (SoC) intent
Then the chatbot checks: Is this a third-party submission? -> NO

# --- SOC ENTRY (SoC-01) ---
Then the chatbot displays the case opening legal disclaimer (GenUC-24):
"Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

# --- IDENTIFICATION (GenUC-01) ---
Then the chatbot responds:
"I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "[First Name] [Last Name]"
Then the chatbot responds:
"Thanks, [First Name]! And, what is your booking reference number?"
And the user provides "PNR: [PNR Code]"
Then the chatbot searches Trip Tracer for PNR: [PNR Code]
And Trip Tracer returns: PNR FOUND (2 Passengers on booking)

# --- AUTHENTICATION (GenUC-05) ---
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
* Email: t***@gmail.com
* Phone: +1***789
When the user selects "Email: t***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "546879"
Then the chatbot validates the OTP code -> CORRECT (attempt 1 of 5)
Then the chatbot responds:
"Your verification was successful. Let's proceed to the next step."

# --- PASSENGER & JOURNEY SELECTION (GenUC-08) ---
Then the chatbot checks if this PNR is a group booking -> No
Then the chatbot checks if there are multiple PAX on PNR? -> YES (2 PAX found)
And the chatbot displays passenger list:
"I found the following passengers on this booking:
1. [Pax 1 Name] (Claimant / Booker - Adult, Aeroplan Basic)
2. [Pax 2 Name] (Adult)

Are you claiming expenses on behalf of all passengers on this booking?"
When the user confirms: "Yes, claiming for both passengers"
Then the chatbot retrieves booking details and displays:
"I found the following journey:
* Flight: AC 301
* Route: Toronto (YYZ) -> Vancouver (YVR)
* Date: June 15, 2026
* Departure Delay: 7 hours (420 minutes)
* Passengers: 2 Adults

Is this the journey you'd like to check?"
And the user confirms "Yes"
Then the chatbot checks if there is more than 1 segment -> No

# --- ELIGIBILITY & TIME LIMIT CHECKS ---
Then the chatbot sends request to Case Services for duplicate check (GenUC-10)
And Case Services returns: NO existing case found for this passenger + journey combination
Then the chatbot checks 72-hour window passed -> YES
Then the chatbot verifies Filing deadline limitation:
* Origin: YYZ (Ontario) -> Limitation = 730 days
* Destination: YVR (British Columbia) -> Limitation = 1,095 days
* Elapsed: Within limitation period -> PROCEED
Then the chatbot checks if triage data is available -> YES

# --- TRIAGE AND DDS EVALUATION ---
Then DDS evaluates backend rules:
* Delay Code: 06 (Airport Operations / Ground Handling) -> Controllable
* Passenger Type: 2 Regular Adults -> Standard handling
* Booker Status: Aeroplan Basic (Pax 1 only)
* Delay Band: DELAY_6_HOURS_OR_MORE (Overnight eligible)
* Operating Airline: Air Canada (AC)
And DDS assigns Response Code: SoC-APPR-EL-08

# --- FRAUD SCREENING (GLOB-05) ---
Then the system sends case data to CyberSource for fraud screening
And CyberSource returns: GREEN (no fraud indicators detected)

# --- ELIGIBLE RESULT (SoC-03b) & ENTITLEMENT DISPLAY ---
Then the chatbot displays:
"Great news! Based on the details of your flight, you and the passenger on your booking are eligible for expense reimbursement. Your flight AC 301 from Toronto to Vancouver was delayed by approximately 7 hours due to airport ground operations. Under the applicable regulations (APPR), you may be reimbursed for reasonable expenses incurred during this disruption."
And the chatbot displays the combined entitlements for 2 passengers:
"Based on the length of your disruption (7 hours) and 2 traveling passengers, you may be eligible for reimbursement in the following categories:
* Hotel accommodation: Rate of the day (up to 3 nights, $500.00 maximum per room)
* Meals: up to $60.00 CAD ($30.00 per person)
* Ground transportation: up to $200.00 CAD
* Essential items: up to $60.00 CAD ($30.00 per person)
* Communication: up to $60.00 CAD ($30.00 per person)
* Parking: up to $50.00 CAD (1 day maximum)

Please note that all expenses must have been incurred during the disruption period and supported by valid receipts."

# --- RECEIPT UPLOAD & OCR VALIDATION (RR-01) ---
Then the chatbot responds:
"To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption."
When the user uploads the four receipts (Totaling $980.00 CAD):
* Receipt 1: Hotel receipt � $550.00 CAD (1 night accommodation, exceeds $500 cap)
* Receipt 2: Meal receipt � $130.00 CAD (Dinner for 2, exceeds $60 cap)
* Receipt 3: Taxi receipt � $220.00 CAD (Airport transfer, exceeds $200 cap)
* Receipt 4: Essentials receipt � $80.00 CAD (Emergency items, exceeds $60 cap)

Then OCR engine extracts and validates line items:
* Receipt 1 � Hotel Accommodation:
  - Line item: Hotel stay, 1 night � $550.00 CAD
  - Date: June 15, 2026 | Category: Hotel | Within disruption window: YES
  - Cap check: $550.00 > $500.00 max cap -> Capped at $500.00 CAD
* Receipt 2 � Meals:
  - Line item: Dinner � $130.00 CAD
  - Date: June 15, 2026 | Category: Meals | Within disruption window: YES
  - Threshold check: $130.00 > $60.00 ($30.00 x 2 pax cap) -> Capped at $60.00 CAD
* Receipt 3 � Transport:
  - Line item: Airport Taxi � $220.00 CAD
  - Date: June 15, 2026 | Category: Transport | Within disruption window: YES
  - Threshold check: $220.00 > $200.00 cap -> Capped at $200.00 CAD
* Receipt 4 � Essentials:
  - Line item: Pharmacy/Toiletries � $80.00 CAD
  - Date: June 15, 2026 | Category: Essentials | Within disruption window: YES
  - Threshold check: $80.00 > $60.00 ($30.00 x 2 pax cap) -> Capped at $60.00 CAD

# --- RECEIPT VALIDATION & TOTAL CAP CHECK ---
Then the system evaluates total claim value:
* Total Claimed Amount: $980.00 CAD
* Total Calculated Capped Entitlement: $820.00 CAD ($500 + $60 + $200 + $60)
* System Rule Check: Total submitted ($980.00 CAD) and capped value ($820.00 CAD) EXCEED the $800.00 CAD auto-approval threshold
* Outcome: Case flagged for Manual Review (exceeds $800 total threshold)

# --- CASE CREATION & MANUAL ROUTING (GLOB-09) ---
Then the system creates a case in Case Services:
* DDS response code: SoC-APPR-EL-08
* Eligibility: ELIGIBLE (Pending Review)
* Status: Pending Agent Review
* Queue: Manual Handling Queue
* Reason: Total expense exceeds $800.00 threshold limit
* Receipt images attached: 4
* Fraud screening result: GREEN
And the case reference number is provided to the passenger

Then the chatbot responds:
"Your claim has been received and submitted for agent review. Here's a summary:
* Case Reference: [Case Number]
* Total submitted claim amount: $980.00 CAD
* Categories: Hotel ($550.00), Meals ($130.00), Transport ($220.00), Essentials ($80.00)
* Claimed for: 2 Passengers
Because your total claim exceeds our automated processing limit of $800.00 CAD, a customer service agent will review your receipts manually within 30 days."

# --- NOTIFICATION (Adobe) ---
Then the system triggers notification via Adobe
And a manual review confirmation email is sent to the passenger at t***@gmail.com

# --- CLAIMS PAYMENT PRE-COLLECTION FLOW ---
Then the chatbot prompts to collect payment information in advance:
"To ensure prompt payment once your claim is reviewed and approved, please confirm your payment details."
And the chatbot collects:
Country of residence: Canada
Payment method: Interac
Email address for Interac transfer: [t***@gmail.com]
Then the chatbot responds:
"Thank you. Your payment details have been saved. If approved by our review team, funds will be sent via Interac e-Transfer to your email."

# --- END FLOW (GLOB-11) ---
Then the chatbot offers: "Is there anything else I can help you with?"
I would like you to � new flow
No
When the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

# --- CLAIMS DASHBOARD VALIDATION (Gherkin) ---
Scenario: Claims Dashboard validation for SoC-APPR-EL-08 � 2 Adult Pax Delay Code 06 Total Exceeds $800 Manual Review
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Pending Agent Review"
  And the Created date and Last Updated date are populated
  And the SLA countdown is tracking correctly (30-day target)
  And the Team assignment is "Manual Handling Queue"
  And the Claimant Name is populated (Pax 1)
  And the Claimant Type is "Regular"
  And the Authentication is "Pass"
  And the PNR is populated with 2 associated passengers
  And the Regime is "APPR"
  And the Full Name is populated
  And the Tags include "Claimant", "Adult", "Multi-PAX (2)", "High Value (> $800)"
  And the Email is "t***@gmail.com"
  And the Phone is "+1***789"
  And the Tier Status is "Basic Member (Booker Only)"
  And the Associated Passengers evaluation shows:
      | Passenger | Type  | Aeroplan Tier | Exception Type |
      | Pax 1     | Adult | Basic Member  | None (Regular) |
      | Pax 2     | Adult | Non-Member    | None (Regular) |
  And the Itinerary shows Journey AC 301 YYZ -> YVR as the claimed flight
  And the Flight Status is "DELAYED (7 hours)"
  And the Eligibility section shows Journey = AC 301 YYZ -> YVR
  And the Flight Leg at Fault is AC 301
  And the Operating Carrier is AC
  And the Disruption Reason is "Airport Operations / Ramp Ground Handling (Departure delay code 06 � CONTROLLABLE)"
  And the Delay Minutes is 420 min (7 hours)
  And the Travel Status is "Travelled (delayed)"
  And the Passenger Evaluation Order shows:
      | Order | Check Step               | Result                                |
      | 1     | Passenger Exception Type | Regular Adult (Both) PASS             |
      | 2     | Controllability          | WITHIN CARRIER CONTROL (Code 06) PASS |
  And the Overnight Eligible is "YES (delay > 360 min)"
  And the Class of Booking is "PY"
  And the Revenue Booking is "YES"
  And the ACR Issued shows Hotel No, Transport No, Meal No
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-APPR-EL-08"
  And the Fraud Screening is "CyberSource GREEN"
  And the Eligibility is "ELIGIBLE"
  And the Entitlements for 2 adults PY show:
      | Category      | Entitlement Limit                   |
      | Hotel         | Rate of day, max 3 nights, $500 cap |
      | Meals         | $60.00 CAD ($30.00/pax x 2)         |
      | Transport     | $200.00 CAD                         |
      | Essentials    | $60.00 CAD ($30.00/pax x 2)         |
      | Communication | $60.00 CAD ($30.00/pax x 2)         |
      | Parking       | $50.00 CAD                          |
  And the Receipt Validator shows:
      | Category      | Claimed Amount | Capped Value | Flag / Status                                         |
      | Hotel         | $550.00 CAD    | $500.00 CAD  | REVIEW NEEDED (Claimed $550.00 > $500.00 cap)         |
      | Meals         | $130.00 CAD    | $60.00 CAD   | REVIEW NEEDED (Claimed $130.00 > $60.00 cap)          |
      | Transport     | $220.00 CAD    | $200.00 CAD  | REVIEW NEEDED (Claimed $220.00 > $200.00 cap)         |
      | Essentials    | $80.00 CAD     | $60.00 CAD   | REVIEW NEEDED (Claimed $80.00 > $60.00 cap)           |
  And the Total Claimed Amount is "$980.00 CAD"
  And the System Threshold Banner displays: "Total claim exceeds $800.00 threshold - Manual review required"
  And the Items Flagged for Review is 4
  And the Duplicate Check result is "No duplicate found"
  And CyberSource result is "GREEN"
  And the Decision Assist panel is unlocked for agent review

# --- PAYMENT VALIDATION (Gherkin) ---
Scenario: Payment validation for SoC-APPR-EL-08 � 2 Adult Pax Code 06 Total Exceeds $800 Manual Routing (Interac)
  Given the case SoC-APPR-EL-08 is evaluated for 2 adult passengers
  Then SOC payment mode is validated as CASH ONLY
  And the total submitted receipts amount to $980.00 CAD (Hotel $550 + Meals $130 + Transport $220 + Essentials $80)
  And the system verifies total amount exceeds the $800.00 CAD automated issuance threshold
  Then automated payment dispatch to Unifier is blocked pending agent review
  And the payment status is set to "Pending Agent Review"
  And Case Services verifies payment method determination for Canada:
      | Country of Residence | Payment Method Determination | Pre-collected Detail    |
      | Canada               | Interac (E-Transfer)         | Recipient Email ID only |
  And the bot confirms email "t***@gmail.com" is recorded without collecting bank account details
  And upon manual agent adjudication and approval up to allowable policy caps, Interac issuance will be triggered

# --- EXPECTED RESULTS ---
SoC-APPR-EL-08. ELIGIBLE (Routed to Manual Review). Controllable delay >= 2h (7 hours, Code 06 Airport Operations / Ramp Ground Handling). Passenger type checked FIRST (2 Regular Adults), then controllability checked SECOND (Code 06 Controllable). Booker holds Aeroplan Basic membership while the other passenger is a non-member. Operating carrier correctly identified as AC. Fraud screening GREEN. Entitlements applied for 2 passengers (Meals cap $60, Hotel cap $500, Transport cap $200, Essentials cap $60). Submitted receipts across all four categories total $980.00 CAD, exceeding the $800.00 CAD automated compensation threshold. System blocks auto-payout, transitions case status to "Pending Agent Review", assigns to Manual Handling Queue, pre-collects recipient email for Interac transfer, and sends manual review confirmation email via Adobe.