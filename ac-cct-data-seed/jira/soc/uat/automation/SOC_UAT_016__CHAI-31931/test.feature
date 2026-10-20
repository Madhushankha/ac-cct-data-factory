Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My Air Canada flight from Toronto to Vancouver was delayed by about 7 hours because of a crew scheduling issue. I had to buy meals, pay for a hotel overnight, and take a taxi. Can I get reimbursed?"
When the chatbot identifies Standards of Care (SoC) intent
Then the chatbot checks: Is this a third-party submission? ? NO

SOC ENTRY (SoC-01):
Then the chatbot displays the case opening legal disclaimer (GenUC-24):
"Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds:
"I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "[First Name] [Last Name]"
Then the chatbot responds:
"Thanks, [First Name]! And, what is your booking reference number?"
And the user provides "PNR: [PNR Code]"
Then the chatbot searches Trip Tracer for PNR: [PNR Code]
And Trip Tracer returns: PNR FOUND

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: t***@gmail.com
� Phone: +1***789
And the user selects "Email: t***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "546879"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds:
"Your verification was successful. Let's proceed to the next step."

Then the chatbot checks if this PNR a group booking ? No
Then the chatbot checks if there are multiple PAX on PNR? ? No

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 301
� Route: Toronto (YYZ) ? Vancouver (YVR)
� Date: June 14, 2026
� Departure Delay: 7 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"

Then the chatbot checks if there are more than 1 segment ? No

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes
Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR SOC per province
And the system calculates:
� Origin: YYZ (Ontario) ? Limitation = 730 days
� Destination: YVR (British Columbia) ? Limitation = 1,095 days
� Days elapsed: Within limitation period ? PROCEED

Then the chatbot checks if there is triage data available? ? Yes

TRIAGE AND DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

TRIP TRACER UI VALIDATIONS:
Then the tester opens Trip Tracer UI for PNR
Trip Overview:
? PNR: [PNR Code]
? TYPE: REVENUE
? ?? Trip Completed, Disruption Detected
? Single-segment domestic trip YYZ?YVR on AC301 was delayed +7H 00M due to crew shortage (controllable)
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 301, Route: YYZ ? YVR, Scheduled Dep: 15-Jun 08:00
? Current Itinerary � Flight: AC 301, Route: YYZ ? YVR, Status: ARRIVED LATE, Scheduled Dep: 08:00 ? Actual: 15:00, Delay: +7H 00M

Standards of Care (1):
? SOC section present
? Departure Delay Code: 64 (Flight Crew Shortage) � Controllable
? PASSENGER: [Name] | STATUS: ELIGIBLE | BAND: DELAY_6_HOURS_OR_MORE | MEAL: $30.00 | ACCOMMODATION: Rate of day (max $500) | GENERAL EXPENSES: Transport $200 + Comm $30 + Parking $50 + Essentials $30 | EXPIRES: [date]
? CyberSource: GREEN

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: ELIGIBLE
? Total Approved: $255.00 CAD (Hotel $165 + Meals $25 + Transport $50 + Comm $15)

DDS RESPONSE CODE = SoC-APPR-EL-08

Then the chatbot checks which airline company is it ? AC

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger)
And CyberSource evaluates the claim
And CyberSource returns: GREEN (no fraud indicators detected)
? PROCEED to eligible flow

ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 301 from Toronto to Vancouver was delayed by approximately 7 hours due to a crew scheduling issue. Under the applicable regulations (APPR), you may be reimbursed for reasonable expenses incurred during this disruption."

ENTITLEMENT DISPLAY:
Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, no ACR:
"Based on the length of your disruption (7 hours), you may be eligible for reimbursement in the following categories:
� Meals: up to $30.00
� Hotel accommodation: Rate of day (up to 3 nights, $500 maximum)
� Ground transportation: up to $200.00
� Communication: up to $30.00
� Parking: up to $50.00 (1 day maximum)
� Essential items: up to $30.00

Please note that all expenses must have been incurred during the disruption period and supported by valid receipts."

RECEIPT UPLOAD � WELCOME BACK FLOW:
Then the chatbot responds:
"To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption."
And the chatbot displays the receipt upload interface
And the user uploads receipt images:
� Receipt 1: Hotel receipt � $165.00 CAD (1 night)
� Receipt 2: Meal receipt � $25.00 CAD (dinner)
� Receipt 3: Taxi receipt � $50.00 CAD (airport to hotel + hotel to airport)
� Receipt 4: Communication � $15.00 CAD (Wi-Fi)

RECEIPT READER � OCR VALIDATION (RR-01):
Then the system processes uploaded receipts through OCR (Agentic Receipt Reader)
And the OCR engine extracts line items from each receipt:

Receipt 1 � Hotel:
� Line item: Hotel stay, 1 night � $165.00 CAD
� Date: June 14, 2026
� Category: Hotel
� Within disruption window: YES ?
� Rate of day comparison: $165 vs rate of day ? WITHIN range ?
� Nights: 1 (within 3-night max) ?
� Amount: $165 < $500 cap ?
� OCR Result: PASS ?

Receipt 2 � Meals:
� Line item: Dinner � $25.00 CAD
� Date: June 14, 2026
� Category: Meals
� Within disruption window: YES ?
� Threshold check: $25 ? $30 ( meal entitlement) ?
� OCR Result: PASS ?

Receipt 3 � Transport:
� Line item 1: Taxi airport?hotel � $28.00 CAD
� Line item 2: Taxi hotel?airport � $22.00 CAD
� Total transport: $50.00 CAD
� Date: June 14-15, 2026
� Category: Transport
� Within disruption window: YES ?
� Threshold check: $50 ? $200 (1-5 pax) ?
� OCR Result: PASS ?

Receipt 4 � Communication:
� Line item: Wi-Fi access � $15.00 CAD
� Date: June 14, 2026
� Category: Communication
� Within disruption window: YES ?
� Threshold check: $15 ? $30 ?
� OCR Result: PASS ?

RECEIPT VALIDATION SUMMARY:
Then the system displays the OCR validation summary:
� Total receipts processed: 4
� Total line items extracted: 5
� Items PASSED: 5
� Items FLAGGED for agent review: 0
� Items FAILED: 0

EXPENSE BREAKDOWN:
� Hotel: $165.00 ?
� Meals: $25.00 ?
� Transport: $50.00 ?
� Communication: $15.00 ?
� Parking: $0.00 (no receipt submitted)
� Essentials: $0.00 (no receipt submitted)
� TOTAL APPROVED: $255.00 CAD

CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada"
Then the system determines: Country = Canada ? Currency = CAD
CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? Yes (Super Elite 50K)
And the system confirms SOC = CASH ONLY ? AC Wallet / e-credit NOT offered
Then the chatbot checks if the claim is for multiple pax ? Yes (2 pax)
Then the chatbot responds: "You are entitled to receive a $127.00 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency."
And user provides "Yes"
Then system checks which payment method is mapped based on country of residence ? Interac (CANADA)
PAYMENT METHOD � INTERAC (FD-07):
Then the chatbot responds:
"Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information. Would you like to use t***@gmail.com? Please note that only one email address can be used for this compensation/reimbursement and it can't be changed once confirmed."
And the user confirms "Yes, use this email"
Then system checks that IDV is not completed
IDENTITY VERIFICATION � PERSONA (FD-07b):
Then the chatbot responds:
"I must verify your identity for payment security. Please click here to get started"
And chatbot displays a button "Get verified"
When user clicks on the button
Then system checks if IDV at Payment
Then system checks if user have consented to IDV
And the chatbot sends Persona IDV link to the customer
And the customer opens the Persona link
And the customer completes identity verification via Persona
And Persona returns: IDV PASS
Then the chatbot responds:
"Your identity has been verified successfully. Let's proceed to finalize your claim."
CLAIM AMOUNT CONFIRMATION FLOW:
Then the chatbot responds: "Please review your compensation details:
Deposit Amount: $127.00 CAD
Payment Method: t***@gmail.com
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps that will also include the password required to access the secure payment link, which will be sent in a separate email
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user provides: "Yes"
CASE CREATION (GLOB-09):
Then the system creates a case in Case Services
And the case includes:
� DDS response code: SoC-APPR-EL-07
� Eligibility: ELIGIBLE
� Regime: APPR
� Passengers: 2 adults (1 Super Elite 50K + 1 companion)
� Exception privilege: Extended to companion from Super Elite claimant
� Class of Booking: J (Business)
� All approved line items with amounts
� Receipt images attached
� Fraud screening result: GREEN
� Country of residence: Canada | Currency: CAD
� Payment method: Interac e-Transfer | Payment email: t***@gmail.com (single payee � claimant)
� IDV: Persona PASS
And the case reference number is provided to the passenger
Then the chatbot responds:
"Your claim has been submitted successfully for both passengers. Here's a summary:
� Case Reference: [Case Number]
� Total claim amount: $127.00 CAD
� Categories: Meals ($52.00), Communication ($40.00), Essentials ($35.00)
� Passengers covered: [First Name] (Super Elite 50K), [Companion First Name]
You will receive a confirmation email shortly with your case details and next steps."
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe
And an eligible confirmation email is sent to the passenger at t***@gmail.com
And the email includes:
� Case reference number
� Claim summary with approved amounts
� Next steps for payment
� Password required to access the secure payment link
And a separate email containing the secure Interac payment link is sent to t***@gmail.com
END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-APPR-EL-08 � Controllable Overnight Eligible
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Resolved"
  And the Created date and Last Updated date are populated
  And the SLA countdown is tracking correctly
  And the Team assignment is correct
  And the Claimant Name is populated
  And the Claimant Type is "Regular"
  And the Authentication is "Pass"
  And the PNR is populated
  And the Regime is "APPR"
  And the Full Name is populated
  And the Tags include "Claimant" and "Adult"
  And the Email is "t***@gmail.com"
  And the Phone is "+1***789"
  And the Tier Status is "Regular"
  And the Itinerary shows Journey AC 301 YYZ ? YVR as the claimed flight
  And the Flight Status is "DELAYED (7 hours)"
  And the Eligibility section shows Journey = AC 301 YYZ ? YVR
  And the Flight Leg at Fault is AC 301
  And the Operating Carrier is AC
  And the Disruption Reason is "Flight Crew Shortage (Departure delay code 64 � CONTROLLABLE)"
  And the Delay Minutes is 420 min (7 hours)
  And the Travel Status is "Travelled (delayed)"
  And the Passenger Type is "Regular" (checked FIRST)
  And the Controllability is "WITHIN CARRIER CONTROL (Controllable)" (checked SECOND)
  And the Overnight Eligible is "YES (delay >360 min)"
  And the Class of Booking is "PY"
  And the Revenue Booking is "YES"
  And the ACR Issued shows Hotel No, Transport No, Meal No
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-APPR-EL-08"
  And the Fraud Screening is "CyberSource GREEN"
  And the Eligibility is "ELIGIBLE"
  And the Entitlements for 1 adult PY no ACR show Meals $30/pax, Hotel rate of day max 3 nights $500 cap, Transport $200, Communication $30/pax, Parking $50 1 day max, Essentials $30/pax
  And the Receipt Validator shows Hotel $165.00 APPROVED (1 night, within rate of day, <$500 cap)
  And the Receipt Validator shows Meals $25.00 APPROVED (dinner, ?$30)
  And the Receipt Validator shows Transport $50.00 APPROVED (taxi airport?hotel, ?$200)
  And the Receipt Validator shows Communication $15.00 APPROVED (Wi-Fi, ?$30)
  And the Receipt Validator shows Parking $0.00 No receipt
  And the Receipt Validator shows Essentials $0.00 No receipt
  And the Total Approved is $255.00 CAD
  And the Items Flagged for Review is 0
  And the Applicable Regimes SOC Amount is "$255.00 CAD (APPR � Suggested Highlighted)"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource result is "GREEN"
  And the Country of Residence is "Canada" with Currency "CAD"
  And the Payment Method is "Interac e-Transfer"
  And the Payment Email is "t***@gmail.com" (confirmed, locked)
  And no bank details are stored on the case
  And the IDV result is "Persona PASS (at Payment)"
  And the secure payment link email and password were sent to "t***@gmail.com"
  And the Final Status is "Resolved"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-APPR-EL-08 � Controllable Overnight Eligible
  Given the case SoC-APPR-EL-08 is determined as ELIGIBLE
  Then SOC payment is CASH ONLY
  And AC Wallet / e-credit is NOT offered
  And the route is AC 301 YYZ ? YVR with delay 420 min (7 hrs) for 1 adult PY
  And the approved receipts are Hotel $165, Meals $25, Taxi $50, Comm $15 totalling $255.00 CAD
  And $255.00 is less than SOC threshold so no approval is needed
  And the country of residence is Canada with currency CAD
  And the payment method is Interac e-Transfer
  And only the customer's email t***@gmail.com is collected (no bank details)
  And Persona IDV returned PASS before claim submission
  And the Comp Status is "Sent for issuance"
  And the compensation record is created and batch file sent to Unifier
  And the Claims Dashboard shows $255.00 CAD, Cash, Interac, t***@gmail.com, status via talkback
EXPECTED RESULTS:
SoC-APPR-EL-08. ELIGIBLE. Controllable delay ?2h (7 hours,  category). Pax type checked FIRST (Regular), then controllability (Controllable).  correctly identified as AC. Fraud screening GREEN. Entitlements applied per  delay category. Full receipt upload + OCR + case creation + notification flow completes.