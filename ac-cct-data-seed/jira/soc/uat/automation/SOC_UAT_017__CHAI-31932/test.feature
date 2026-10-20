Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
When the user selects English
Then an alert information is displayed:
"Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then the chatbot asks: "How can I help you today?"
And the user says: "My family flight from Toronto to Vancouver was delayed for 7 hours because of crew scheduling. There were 4 of us traveling, including two family members needing accessibility assistance. We had to purchase meals during the delay. Can I get reimbursed?"
When the chatbot identifies Standards of Care (SoC) intent
Then the chatbot checks: Is this a third-party submission? ? NO

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
And Trip Tracer returns: PNR FOUND (4 Passengers on booking)

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
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds:
"Your verification was successful. Let's proceed to the next step."

# --- PASSENGER & JOURNEY SELECTION (GenUC-08) ---
Then the chatbot checks if this PNR is a group booking ? No
Then the chatbot checks if there are multiple PAX on PNR? ? YES (4 PAX found)
And the chatbot displays passenger list:
"I found the following passengers on this booking:
1. [Pax 1 Name] (Claimant - Accessibility WCHR)
2. [Pax 2 Name] (Accessibility DPNA)
3. [Pax 3 Name] (Adult)
4. [Pax 4 Name] (Adult)

Are you claiming expenses on behalf of all passengers on this booking?"
When the user confirms: "Yes, claiming for all 4 passengers"
Then the chatbot retrieves booking details and displays:
"I found the following journey:
* Flight: AC 301
* Route: Toronto (YYZ) ? Vancouver (YVR)
* Date: June 15, 2026
* Departure Delay: 7 hours (420 minutes)
* Passengers: 4

Is this the journey you'd like to check?"
And the user confirms "Yes"
Then the chatbot checks if there is more than 1 segment ? No

# --- ELIGIBILITY & TIME LIMIT CHECKS ---
Then the chatbot sends request to Case Services for duplicate check (GenUC-10)
And Case Services returns: NO existing case found for this passenger + journey combination
Then the chatbot checks 72-hour window passed ? YES
Then the chatbot verifies Filing deadline limitation:
* Origin: YYZ (Ontario) ? Limitation = 730 days
* Destination: YVR (British Columbia) ? Limitation = 1,095 days
* Elapsed: Within limitation period ? PROCEED
Then the chatbot checks if triage data is available ? YES

# --- TRIAGE AND DDS EVALUATION ---
Then DDS evaluates backend rules:
* Delay Code: 65 (Flight Crew Shortage / Duty Scheduling) ? Controllable
* Passenger Mix: 2 Accessibility + 2 Regular ? Mixed Exception handling
* Delay Band: DELAY_6_HOURS_OR_MORE
* Operating Airline: Air Canada (AC)
And DDS assigns Response Code: SoC-APPR-EL-08

# --- FRAUD SCREENING (GLOB-05) ---
Then the system sends case data to CyberSource for fraud screening
And CyberSource returns: GREEN (no fraud indicators detected)

# --- ELIGIBLE RESULT (SoC-03b) & ENTITLEMENT DISPLAY ---
Then the chatbot displays:
"Great news! Based on the details of your flight, you and the passengers on your booking are eligible for expense reimbursement. Your flight AC 301 from Toronto to Vancouver was delayed by approximately 7 hours due to crew scheduling. Under the applicable regulations (APPR), you may be reimbursed for reasonable expenses incurred during this disruption."
And the chatbot displays the combined entitlements for 4 passengers:
"Based on the length of your disruption (7 hours) and 4 traveling passengers, you may be eligible for reimbursement in the following categories:
* Meals: up to $120.00 CAD ($30.00 per person)
* Hotel accommodation: Rate of the day (up to 3 nights, $500.00 maximum per room)
* Ground transportation: up to $200.00 CAD
* Communication: up to $120.00 CAD ($30.00 per person)
* Parking: up to $50.00 CAD (1 day maximum)
* Essential items: up to $120.00 CAD ($30.00 per person)

Please note that all expenses must have been incurred during the disruption period and supported by valid receipts."

# --- RECEIPT UPLOAD & OCR VALIDATION (RR-01) ---
Then the chatbot responds:
"To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption."
When the user uploads only the meal receipt:
* Receipt 1: Meal receipt � $88.00 CAD (Family Dinner for 4)

Then OCR engine extracts and validates line items:
* Receipt 1 � Meals:
  - Line item: Family Dinner � $88.00 CAD
  - Date: June 15, 2026
  - Category: Meals
  - Within disruption window: YES ?
  - Threshold check: $88.00 ? $120.00 ($30.00 � 4 pax aggregate entitlement) ?
  - OCR Result: PASS ?

# --- RECEIPT VALIDATION SUMMARY ---
Then the system displays the OCR validation summary:
* Total receipts processed: 1
* Total line items extracted: 1
* Items PASSED: 1
* Items FLAGGED for agent review: 0
* Items FAILED: 0
* Expense Breakdown:
  - Hotel: $0.00 (no receipt submitted)
  - Meals: $88.00 CAD ?
  - Transport: $0.00 (no receipt submitted)
  - Communication: $0.00 (no receipt submitted)
  - Parking: $0.00 (no receipt submitted)
  - Essentials: $0.00 (no receipt submitted)
* TOTAL APPROVED: $88.00 CAD

# --- CASE CREATION (GLOB-09) ---
Then the system creates a case in Case Services:
* DDS response code: SoC-APPR-EL-08
* Eligibility: ELIGIBLE
* Regime: APPR
* Approved Total: $88.00 CAD (Meals only)
* Receipt images attached: 1
* Fraud screening result: GREEN
And the case reference number is provided to the passenger

Then the chatbot responds:
"Your claim has been submitted successfully. Here's a summary:
* Case Reference: [Case Number]
* Total claim amount: $88.00 CAD
* Categories: Meals ($88.00)
* Claimed for: 4 Passengers
You will receive a confirmation email shortly with your case details and next steps."

# --- NOTIFICATION & CLAIMS PAYMENT ---
Then Adobe sends an eligibility confirmation email to t***@gmail.com
And Case Services triggers automated payment processing:
* Approved amount: $88.00 CAD (< $500 threshold ? No manual sign-off required)
* Payment method: Canada ? Interac
When the chatbot collects payment details:
* Country of residence: Canada
* Payment method: Interac
* Email: [collected securely]
Then the chatbot responds:
"Your payment of $88.00 CAD will be processed via Electronic Funds Transfer. You should receive the funds within 3�5 business days."
When the chatbot asks: "Is there anything else I can help you with?"
And the user selects "No"
Then the chatbot concludes: "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION:
 Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Resolved"
  And the Created date and Last Updated date are populated
  And the SLA countdown is tracking correctly
  And the Team assignment is correct
  And the Claimant Name is populated (Pax 1)
  And the Claimant Type is "Accessibility (SSR: WCHR)"
  And the Authentication is "Pass"
  And the PNR is populated with 4 associated passengers
  And the Regime is "APPR"
  And the Full Name is populated
  And the Tags include "Claimant", "Adult", "Accessibility", "Multi-PAX (4)"
  And the Email is "t***@gmail.com"
  And the Phone is "+1***789"
  And the Tier Status is "Basic Member"
  And the Itinerary shows Journey AC 301 YYZ ? YVR as the claimed flight
  And the Flight Status is "DELAYED (7 hours)"
  And the Eligibility section shows Journey = AC 301 YYZ ? YVR
  And the Flight Leg at Fault is AC 301
  And the Operating Carrier is AC
  And the Disruption Reason is "Flight Crew Shortage / Scheduling (Departure delay code 65 � CONTROLLABLE)"
  And the Delay Minutes is 420 min (7 hours)
  And the Travel Status is "Travelled (delayed)"
  And the Passenger Evaluation Order shows:
      | Order | Check Step               | Result                                              |
      | 1     | Passenger Exception Type | Mixed Exception (2 Accessibility + 2 Regular) PASS |
      | 2     | Controllability          | WITHIN CARRIER CONTROL (Code 65) PASS               |
  And the Overnight Eligible is "YES (delay >360 min)"
  And the Class of Booking is "PY"
  And the Revenue Booking is "YES"
  And the ACR Issued shows Hotel No, Transport No, Meal No
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-APPR-EL-08"
  And the Fraud Screening is "CyberSource GREEN"
  And the Eligibility is "ELIGIBLE"
  And the Entitlements for 4 adults PY show:
      | Category      | Entitlement Limit                       |
      | Meals         | $120.00 CAD ($30.00/pax x 4)            |
      | Hotel         | Rate of day, max 3 nights, $500 cap     |
      | Transport     | $200.00 CAD                             |
      | Communication | $120.00 CAD ($30.00/pax x 4)            |
      | Parking       | $50.00 CAD                              |
      | Essentials    | $120.00 CAD ($30.00/pax x 4)            |
  And the Receipt Validator shows:
      | Category      | Amount     | Status                                               |
      | Meals         | $88.00 CAD | APPROVED (Family dinner, <= $120.00 group threshold) |
      | Hotel         | $0.00      | No receipt                                           |
      | Transport     | $0.00      | No receipt                                           |
      | Communication | $0.00      | No receipt                                           |
      | Parking       | $0.00      | No receipt                                           |
      | Essentials    | $0.00      | No receipt                                           |
  And the Total Approved is $88.00 CAD
  And the Items Flagged for Review is 0
  And the Applicable Regimes SOC Amount is "$88.00 CAD (APPR � Suggested Highlighted)"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource result is "GREEN"
  And the Final Status is "Resolved"
  And the case is in read-only mode

PAYMENT VALIDATION:
  Given the case SoC-APPR-EL-08 is determined as ELIGIBLE for 4 passengers
  Then SOC payment mode is validated as CASH ONLY
  And the route is AC 301 YYZ ? YVR with a departure delay of 420 min (7 hours) for 4 adults in PY
  And the meal entitlement for 4 adults is calculated as $120.00 CAD ($30.00/pax x 4)
  And the approved receipt is Meals $88.00 CAD totalling $88.00 CAD
  And the system verifies $88.00 CAD is less than the $500.00 SOC sign-off threshold
  And no secondary manual approval or agent review is triggered
  And the country of residence is Canada with currency CAD and payment method EFT
  And the Comp Status is "Sent for issuance"
  And the compensation record is created and batch file sent to Unifier
  And the Claims Dashboard displays "$88.00 CAD", "Cash", "EFT", and status confirmed via talkback

EXPECTED RESULTS:
SoC-APPR-EL-08. ELIGIBLE. Controllable delay >= 2h (7 hours, Code 65 Crew Shortage / Scheduling). Passenger type checked FIRST (Mixed: 2 Accessibility + 2 Regular), then controllability SECOND (Controllable). Operating carrier correctly identified as AC. Fraud screening GREEN. Entitlements applied for 4 passengers with Meals cap at $120.00 CAD ($30 * 4). Submitted meal receipt of $88.00 CAD validated as below-threshold. Full receipt OCR extraction, automatic case resolution ($88.00 CAD), EFT payout initiation, and Adobe confirmation email complete without flagging for manual review.