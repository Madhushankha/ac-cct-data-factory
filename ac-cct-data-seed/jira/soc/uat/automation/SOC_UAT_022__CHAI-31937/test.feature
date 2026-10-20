Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
When the user selects English
Then an alert information is displayed:
"Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then the chatbot asks: "How can I help you today?"
And the user says: "My flight from Toronto to Vancouver was delayed by 7 hours due to flight plan issues. I had to stay overnight at a hotel and paid out of pocket. Can I get reimbursed?"
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
And Trip Tracer returns: PNR FOUND (1 Passenger on booking)

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
Then the chatbot checks if there are multiple PAX on PNR? -> No (1 PAX)
Then the chatbot retrieves booking details and displays:
"I found the following journey:
* Flight: AC 301
* Route: Toronto (YYZ) -> Vancouver (YVR)
* Date: June 15, 2026
* Departure Delay: 7 hours (420 minutes)
* Passengers: 1 Adult

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
* Delay Code: 61 (Flight Operations / Flight Plan Preparation) -> Controllable
* Passenger Type: 1 Regular Adult -> Standard handling
* Booker Status: Aeroplan Basic Member
* Delay Band: DELAY_6_HOURS_OR_MORE (Overnight eligible)
* Operating Airline: Air Canada (AC)
And DDS assigns Response Code: SoC-APPR-EL-08

# --- FRAUD SCREENING (GLOB-05) ---
Then the system sends case data to CyberSource for fraud screening
And CyberSource returns: GREEN (no fraud indicators detected)

# --- ELIGIBLE RESULT (SoC-03b) & ENTITLEMENT DISPLAY ---
Then the chatbot displays:
"Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 301 from Toronto to Vancouver was delayed by approximately 7 hours due to flight planning operations. Under the applicable regulations (APPR), you may be reimbursed for reasonable expenses incurred during this disruption."
And the chatbot displays the entitlements for 1 passenger:
"Based on the length of your disruption (7 hours), you may be eligible for reimbursement in the following categories:
* Hotel accommodation: Rate of the day (up to 3 nights, $500.00 maximum per room)
* Meals: up to $30.00 CAD
* Ground transportation: up to $200.00 CAD
* Essential items: up to $30.00 CAD
* Communication: up to $30.00 CAD
* Parking: up to $50.00 CAD (1 day maximum)

Please note that all expenses must have been incurred during the disruption period and supported by valid receipts."

# --- RECEIPT UPLOAD & OCR VALIDATION (RR-01) ---
Then the chatbot responds:
"To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption."
When the user uploads the hotel receipt ($580.00 CAD):
* Receipt 1: Hotel receipt � $580.00 CAD (1 night accommodation, exceeds $500 cap)

Then OCR engine extracts and validates line items:
* Receipt 1 � Hotel Accommodation:
  - Line item: Hotel stay, 1 night � $580.00 CAD
  - Date: June 15, 2026 | Category: Hotel | Within disruption window: YES
  - Cap check: $580.00 > $500.00 max cap -> Exceeds $500.00 hotel cap limit
  - OCR Result: REVIEW NEEDED (Exceeds $500.00 hotel cap)

# --- RECEIPT VALIDATION & HOTEL CAP CHECK ---
Then the system evaluates hotel claim value:
* Total Claimed Hotel Amount: $580.00 CAD
* Policy Maximum Hotel Cap: $500.00 CAD
* System Rule Check: Submitted hotel amount ($580.00 CAD) EXCEEDS the $500.00 CAD auto-approval hotel cap
* Outcome: Case flagged for Manual Review (exceeds $500 hotel cap)

# --- CASE CREATION & MANUAL ROUTING (GLOB-09) ---
Then the system creates a case in Case Services:
* DDS response code: SoC-APPR-EL-08
* Eligibility: ELIGIBLE (Pending Review)
* Status: Pending Agent Review
* Queue: Manual Handling Queue
* Reason: Hotel expense exceeds $500.00 cap limit
* Receipt images attached: 1
* Fraud screening result: GREEN
And the case reference number is provided to the passenger

Then the chatbot responds:
"Your claim has been received and submitted for agent review. Here's a summary:
* Case Reference: [Case Number]
* Total submitted claim amount: $580.00 CAD
* Categories: Hotel ($580.00)
* Claimed for: 1 Passenger
Because your hotel accommodation claim exceeds our automated cap of $500.00 CAD, a customer service agent will review your receipt manually within 30 days."

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
Scenario: Claims Dashboard validation for SoC-APPR-EL-08 � 1 Adult Pax Delay Code 61 Hotel Exceeds $500 Cap Manual Review
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Pending Agent Review"
  And the Created date and Last Updated date are populated
  And the SLA countdown is tracking correctly (30-day target)
  And the Team assignment is "Manual Handling Queue"
  And the Claimant Name is populated (Pax 1)
  And the Claimant Type is "Regular"
  And the Authentication is "Pass"
  And the PNR is populated with 1 passenger
  And the Regime is "APPR"
  And the Full Name is populated
  And the Tags include "Claimant", "Adult", "High Value (> $500 Hotel)"
  And the Email is "t***@gmail.com"
  And the Phone is "+1***789"
  And the Tier Status is "Basic Member"
  And the Itinerary shows Journey AC 301 YYZ -> YVR as the claimed flight
  And the Flight Status is "DELAYED (7 hours)"
  And the Eligibility section shows Journey = AC 301 YYZ -> YVR
  And the Flight Leg at Fault is AC 301
  And the Operating Carrier is AC
  And the Disruption Reason is "Flight Operations / Flight Plan Preparation (Departure delay code 61 � CONTROLLABLE)"
  And the Delay Minutes is 420 min (7 hours)
  And the Travel Status is "Travelled (delayed)"
  And the Passenger Evaluation Order shows:
      | Order | Check Step               | Result                                |
      | 1     | Passenger Exception Type | Regular Adult PASS                    |
      | 2     | Controllability          | WITHIN CARRIER CONTROL (Code 61) PASS |
  And the Overnight Eligible is "YES (delay > 360 min)"
  And the Class of Booking is "PY"
  And the Revenue Booking is "YES"
  And the ACR Issued shows Hotel No, Transport No, Meal No
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-APPR-EL-08"
  And the Fraud Screening is "CyberSource GREEN"
  And the Eligibility is "ELIGIBLE"
  And the Entitlements for 1 adult PY show:
      | Category      | Entitlement Limit                   |
      | Hotel         | Rate of day, max 3 nights, $500 cap |
      | Meals         | $30.00 CAD                          |
      | Transport     | $200.00 CAD                         |
      | Essentials    | $30.00 CAD                          |
      | Communication | $30.00 CAD                          |
      | Parking       | $50.00 CAD                          |
  And the Receipt Validator shows:
      | Category      | Claimed Amount | Policy Cap   | Flag / Status                                         |
      | Hotel         | $580.00 CAD    | $500.00 CAD  | REVIEW NEEDED (Claimed $580.00 > $500.00 hotel cap)   |
      | Meals         | $0.00          | $0.00        | No receipt                                            |
      | Transport     | $0.00          | $0.00        | No receipt                                            |
      | Essentials    | $0.00          | $0.00        | No receipt                                            |
      | Communication | $0.00          | $0.00        | No receipt                                            |
      | Parking       | $0.00          | $0.00        | No receipt                                            |
  And the Total Claimed Amount is "$580.00 CAD"
  And the System Threshold Banner displays: "Hotel expense exceeds $500.00 cap - Manual review required"
  And the Items Flagged for Review is 1
  And the Duplicate Check result is "No duplicate found"
  And CyberSource result is "GREEN"
  And the Decision Assist panel is unlocked for agent review

# --- PAYMENT VALIDATION (Gherkin) ---
Scenario: Payment validation for SoC-APPR-EL-08 � 1 Adult Pax Code 61 Hotel Exceeds $500 Cap Manual Routing (Interac)
  Given the case SoC-APPR-EL-08 is evaluated for 1 adult passenger
  Then SOC payment mode is validated as CASH ONLY
  And the total submitted hotel receipt amounts to $580.00 CAD
  And the system verifies the hotel amount exceeds the $500.00 CAD policy hotel cap threshold
  Then automated payment dispatch to Unifier is blocked pending agent review
  And the payment status is set to "Pending Agent Review"
  And Case Services verifies payment method determination for Canada:
      | Country of Residence | Payment Method Determination | Pre-collected Detail    |
      | Canada               | Interac (E-Transfer)         | Recipient Email ID only |
  And the bot confirms email "t***@gmail.com" is recorded without collecting bank account details
  And upon manual agent adjudication and approval up to allowable policy caps, Interac issuance will be triggered

# --- EXPECTED RESULTS ---
SoC-APPR-EL-08. ELIGIBLE (Routed to Manual Review). Controllable delay >= 2h (7 hours, Code 61 Flight Operations / Flight Plan Preparation). Passenger type checked FIRST (1 Regular Adult), then controllability checked SECOND (Code 61 Controllable). Booker holds Aeroplan Basic membership. Operating carrier correctly identified as AC. Fraud screening GREEN. Entitlement applied for 1 passenger with hotel cap at $500.00 CAD. Submitted hotel receipt of $580.00 CAD exceeds the $500.00 CAD hotel policy cap. System blocks auto-payout, transitions case status to "Pending Agent Review", assigns to Manual Handling Queue, pre-collects recipient email for Interac transfer, and sends manual review confirmation email via Adobe.