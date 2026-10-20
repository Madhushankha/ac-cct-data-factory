Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
When the user selects English
Then an alert information is displayed:
"Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then the chatbot asks: "How can I help you today?"
And the user says: "My flight from Toronto to Vancouver was delayed for 7 hours due to a crew issue. I was traveling with 2 family members and had to book an emergency hotel overnight. Can I get reimbursed?"
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
And Trip Tracer returns: PNR FOUND (3 Passengers on booking)

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
Then the chatbot checks if there are multiple PAX on PNR? ? YES (3 PAX found)
And the chatbot displays passenger list:
"I found the following passengers on this booking:
1. [Pax 1 Name] (Claimant / Booker - Elderly, Aeroplan Basic)
2. [Pax 2 Name] (Adult)
3. [Pax 3 Name] (Adult)

Are you claiming expenses on behalf of all passengers on this booking?"
When the user confirms: "Yes, claiming for all 3 passengers"
Then the chatbot retrieves booking details and displays:
"I found the following journey:
* Flight: AC 301
* Route: Toronto (YYZ) ? Vancouver (YVR)
* Date: June 15, 2026
* Departure Delay: 7 hours (420 minutes)
* Passengers: 3

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
* Delay Code: 66 (Flight Crew Shortage / Scheduling) ? Controllable
* Passenger Mix: 1 Elderly (Pax 1) + 2 Regular (Pax 2, Pax 3) ? Mixed Exception handling
* Booker Status: Aeroplan Basic (Pax 1 only)
* Delay Band: DELAY_6_HOURS_OR_MORE (Overnight eligible)
* Operating Airline: Air Canada (AC)
And DDS assigns Response Code: SoC-APPR-EL-08

# --- FRAUD SCREENING (GLOB-05) ---
Then the system sends case data to CyberSource for fraud screening
And CyberSource returns: GREEN (no fraud indicators detected)

# --- ELIGIBLE RESULT (SoC-03b) & ENTITLEMENT DISPLAY ---
Then the chatbot displays:
"Great news! Based on the details of your flight, you and the passengers on your booking are eligible for expense reimbursement. Your flight AC 301 from Toronto to Vancouver was delayed by approximately 7 hours due to crew scheduling. Under the applicable regulations (APPR), you may be reimbursed for reasonable expenses incurred during this disruption."
And the chatbot displays the combined entitlements for 3 passengers:
"Based on the length of your disruption (7 hours) and 3 traveling passengers, you may be eligible for reimbursement in the following categories:
* Hotel accommodation: Rate of the day (up to 3 nights, $500.00 maximum per room)
* Meals: up to $90.00 CAD ($30.00 per person)
* Ground transportation: up to $200.00 CAD
* Communication: up to $90.00 CAD ($30.00 per person)
* Parking: up to $50.00 CAD (1 day maximum)
* Essential items: up to $90.00 CAD ($30.00 per person)

Please note that all expenses must have been incurred during the disruption period and supported by valid receipts."

# --- RECEIPT UPLOAD & OCR VALIDATION (RR-01) ---
Then the chatbot responds:
"To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption."
When the user uploads only the hotel receipt:
* Receipt 1: Hotel receipt � $620.00 CAD (1 night accommodation)

Then OCR engine extracts and validates line items:
* Receipt 1 � Hotel Accommodation:
  - Line item: Hotel stay, 1 night � $620.00 CAD
  - Date: June 15, 2026
  - Category: Hotel
  - Within disruption window: YES ?
  - Nights: 1 (within 3-night max) ?
  - Rate / Cap check: $620.00 vs $500.00 max cap ? ABOVE THRESHOLD (Capped at $500.00 CAD)
  - OCR Result: CAPPED / APPROVED AT CAP ($500.00 CAD) ?

# --- RECEIPT VALIDATION SUMMARY ---
Then the system displays the OCR validation summary:
* Total receipts processed: 1
* Total line items extracted: 1
* Items PASSED (Capped): 1
* Items FLAGGED for agent review: 0
* Items FAILED: 0
* Expense Breakdown:
  - Hotel: $500.00 CAD (Claimed $620.00 CAD, Capped at policy max $500.00) ?
  - Meals: $0.00 (no receipt submitted)
  - Transport: $0.00 (no receipt submitted)
  - Communication: $0.00 (no receipt submitted)
  - Parking: $0.00 (no receipt submitted)
  - Essentials: $0.00 (no receipt submitted)
* TOTAL APPROVED: $500.00 CAD

# --- CASE CREATION (GLOB-09) ---
Then the system creates a case in Case Services:
* DDS response code: SoC-APPR-EL-08
* Eligibility: ELIGIBLE
* Regime: APPR
* Approved Total: $500.00 CAD (Hotel capped)
* Receipt images attached: 1
* Fraud screening result: GREEN
And the case reference number is provided to the passenger

Then the chatbot responds:
"Your claim has been submitted successfully. Here's a summary:
* Case Reference: [Case Number]
* Total claim amount: $500.00 CAD (Accommodation capped at allowable maximum)
* Categories: Hotel ($500.00)
* Claimed for: 3 Passengers
You will receive a confirmation email shortly with your case details and next steps."

# --- NOTIFICATION (Adobe) ---
Then the system triggers notification via Adobe
And an eligible confirmation email is sent to the passenger at t***@gmail.com

# --- CLAIMS PAYMENT FLOW ---
Then the system initiates payment processing
And Case Services calculates:
* Approved amount: $500.00 CAD
* Currency conversion: CAD ? country of residence currency (if different)
* Payment method determination based on country of residence:
  * Canada ? EFT (Electronic Funds Transfer / Interac)
  * US + 70 BSM countries ? VSF
  * Others ? BSM or manual
Then the chatbot responds:
"To complete your reimbursement, we'll need your payment details."
And the chatbot collects:
* Country of residence: Canada
* Payment method: EFT
* Bank details: [collected securely]
Then the chatbot responds:
"Your payment of $500.00 CAD will be processed via Electronic Funds Transfer. You should receive the funds within [X] business days."

# --- END FLOW (GLOB-11) ---
Then the chatbot offers: "Is there anything else I can help you with?"
* I would like you to � new flow
* No
When the user selects "No"
Then the chatbot responds: "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION:
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Resolved"
  And the Created date and Last Updated date are populated
  And the SLA countdown is tracking correctly
  And the Team assignment is correct
  And the Claimant Name is populated (Pax 1)
  And the Claimant Type is "Elderly (Age >= 65)"
  And the Authentication is "Pass"
  And the PNR is populated with 3 associated passengers
  And the Regime is "APPR"
  And the Full Name is populated
  And the Tags include "Claimant", "Adult", "Elderly", "Multi-PAX (3)"
  And the Email is "t***@gmail.com"
  And the Phone is "+1***789"
  And the Tier Status is "Basic Member (Booker Only)"
  And the Associated Passengers evaluation shows:
      | Passenger | Type    | Aeroplan Tier | Exception Type |
      | Pax 1     | Adult   | Basic Member  | Elderly (>=65) |
      | Pax 2     | Adult   | Non-Member    | None (Regular) |
      | Pax 3     | Adult   | Non-Member    | None (Regular) |
  And the Itinerary shows Journey AC 301 YYZ ? YVR as the claimed flight
  And the Flight Status is "DELAYED (7 hours)"
  And the Eligibility section shows Journey = AC 301 YYZ ? YVR
  And the Flight Leg at Fault is AC 301
  And the Operating Carrier is AC
  And the Disruption Reason is "Flight Crew Shortage / Scheduling (Departure delay code 66 � CONTROLLABLE)"
  And the Delay Minutes is 420 min (7 hours)
  And the Travel Status is "Travelled (delayed)"
  And the Passenger Evaluation Order shows:
      | Order | Check Step               | Result                                              |
      | 1     | Passenger Exception Type | Mixed Exception (1 Elderly + 2 None) PASS           |
      | 2     | Controllability          | WITHIN CARRIER CONTROL (Code 66) PASS               |
  And the Overnight Eligible is "YES (delay >360 min)"
  And the Class of Booking is "PY"
  And the Revenue Booking is "YES"
  And the ACR Issued shows Hotel No, Transport No, Meal No
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-APPR-EL-08"
  And the Fraud Screening is "CyberSource GREEN"
  And the Eligibility is "ELIGIBLE"
  And the Entitlements for 3 adults PY show:
      | Category      | Entitlement Limit                       |
      | Hotel         | Rate of day, max 3 nights, $500 cap     |
      | Meals         | $90.00 CAD ($30.00/pax x 3)             |
      | Transport     | $200.00 CAD                             |
      | Communication | $90.00 CAD ($30.00/pax x 3)             |
      | Parking       | $50.00 CAD                              |
      | Essentials    | $90.00 CAD ($30.00/pax x 3)             |
  And the Receipt Validator shows:
      | Category      | Claimed Amount | Approved Amount | Status                                          |
      | Hotel         | $620.00 CAD    | $500.00 CAD     | APPROVED (Capped at policy max $500.00 per room)|
      | Meals         | $0.00          | $0.00           | No receipt                                      |
      | Transport     | $0.00          | $0.00           | No receipt                                      |
      | Communication | $0.00          | $0.00           | No receipt                                      |
      | Parking       | $0.00          | $0.00           | No receipt                                      |
      | Essentials    | $0.00          | $0.00           | No receipt                                      |
  And the Total Approved is $500.00 CAD
  And the Items Flagged for Review is 0
  And the Applicable Regimes SOC Amount is "$500.00 CAD (APPR � Suggested Highlighted)"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource result is "GREEN"
  And the Final Status is "Resolved"
  And the case is in read-only mode

PAYMENT VALIDATION:
  Given the case SoC-APPR-EL-08 is determined as ELIGIBLE for 3 passengers
  Then SOC payment mode is validated as CASH ONLY
  And the route is AC 301 YYZ ? YVR with a departure delay of 420 min (7 hours) for 3 adults in PY
  And the hotel entitlement is validated as Rate of day with a maximum cap of $500.00 CAD
  And the submitted hotel receipt of $620.00 CAD is approved at the capped amount of $500.00 CAD
  And Case Services determines payment method based on country of residence:
      | Country of Residence | Payment Method Determination | Selected Method |
      | Canada               | Interac | Interac?           |
      | US + 70 BSM          | VSF                              | N/A             |
      | Others               | BSM or manual                    | N/A             |
  And the country of residence is confirmed as Canada with currency CAD
  And the total approved compensation is $500.00 CAD
  And the Comp Status is "Sent for issuance"
  And the compensation record is created and batch file dispatched to Unifier
  And the Claims Dashboard displays "$500.00 CAD", "Cash", "Interac", and status confirmed via talkback

EXPECTED RESULTS:
SoC-APPR-EL-08. ELIGIBLE. Controllable delay >= 2h (7 hours, Code 66 Crew Shortage / Scheduling). Passenger exception checked FIRST (Mixed: 1 Elderly + 2 None), then controllability checked SECOND (Code 66 Controllable). Booker holds Aeroplan Basic membership while other 2 passengers are non-members. Operating carrier correctly identified as AC. Fraud screening GREEN. Entitlement applied for overnight hotel accommodation up to $500.00 CAD cap. Submitted hotel receipt ($620.00 CAD) validated and automatically capped at $500.00 CAD. Full receipt OCR extraction, automatic case resolution ($500.00 CAD), automated EFT/Interac payout processing for Canada, and Adobe confirmation email complete successfully.