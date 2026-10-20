Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My Air Canada flight from Toronto to Halifax was delayed by about 4 hours because of an aircraft defect they found before takeoff. I had to buy food while waiting at the airport. Can I get reimbursed?"
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
� Flight: AC 401
� Route: Toronto (YYZ) ? Halifax (YHZ)
� Date: June 15, 2026
� Departure Delay: 4 hours
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
� Destination: YHZ (Nova Scotia) ? Limitation = 730 days
� Days elapsed: Within limitation period ? PROCEED

Then the chatbot checks if there is triage data available? ? Yes

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

TRIP TRACER UI VALIDATIONS:
Then the tester opens Trip Tracer UI for PNR
Trip Overview:
? PNR: [PNR Code]
? TYPE: REVENUE
? ?? Trip Completed, Disruption Detected
? Single-segment domestic trip YYZ?YHZ on AC401 was delayed +4H 00M due to aircraft defect (safety)
? PASSENGERS: 1 � SEGMENTS: 1
? Class of Booking: J (Business)
? Passenger Type: Exception (Accessibility SSR)

Itinerary:
? Promised Itinerary � Flight: AC 401, Route: YYZ ? YHZ, Scheduled Dep: 16-Jun 09:00
? Current Itinerary � Flight: AC 401, Route: YYZ ? YHZ, Status: ARRIVED LATE, Scheduled Dep: 09:00 ? Actual: 13:00, Delay: +4H 00M

Standards of Care (1):
? SOC section present
? Departure Delay Code: 41 (Aircraft Defects / Maintenance Finding) � Safety
? PASSENGER: [Name] | STATUS: ELIGIBLE | BAND: DELAY_2_TO_6_HOURS | MEAL: $15.00 (LIMITED � short delay tier) | ACCOMMODATION: � (NOT ENTITLED, delay <6h) | GENERAL EXPENSES: Comm $30 only (Transport/Parking/Essentials NOT ENTITLED) | EXPIRES: [date]
? CyberSource: GREEN
? LIMITED entitlements: Meals $15 + Comm $30 only. No hotel/transport/parking/essentials.

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: ELIGIBLE
? Total Approved: $26.00 CAD (Meals $14 + Comm $12)

DDS RESPONSE CODE = SoC-APPR-EL-09

Then the chatbot checks which airline company is it ? AC

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger)
And CyberSource evaluates the claim
And CyberSource returns: GREEN (no fraud indicators detected)
? PROCEED to eligible flow

ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 401 from Toronto to Halifax was delayed by approximately 4 hours due to an aircraft safety issue. Under the applicable regulations (APPR), you may be reimbursed for reasonable expenses incurred during this disruption."

ENTITLEMENT DISPLAY:
Then the chatbot displays the eligible expense categories based on  delay, 1 adult, J class, no ACR:
"Based on the length of your disruption (4 hours), you may be eligible for reimbursement in the following categories:
� Meals: up to $15.00
� Communication: up to $30.00

Please note that due to the length of the disruption (under 6 hours), hotel accommodation, ground transportation, parking, and essential items are not eligible for reimbursement at this time.

All expenses must have been incurred during the disruption period and supported by valid receipts."

 KEY DIFFERENCE FROM OTHER EL CASES:
This is a  delay, so entitlements are LIMITED:
� Meals: $15 (NOT $30 or $60 � lower  tier)
� Communication: $30 (>120 min ?)
� Hotel: NOT ENTITLED ? (delay <360 min, no overnight)
� Transport: NOT ENTITLED ? (delay <360 min)
� Parking: NOT ENTITLED ? (delay <300 min)
� Essentials: NOT ENTITLED ? (delay <300 min)

RECEIPT UPLOAD � WELCOME BACK FLOW:
Then the chatbot responds:
"To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption."
And the chatbot displays the receipt upload interface
And the user uploads receipt images:
� Receipt 1: Meal receipt � $14.00 CAD (sandwich + coffee at airport)
� Receipt 2: Communication � $12.00 CAD (Wi-Fi access)

RECEIPT READER � OCR VALIDATION (RR-01):
Then the system processes uploaded receipts through OCR (Agentic Receipt Reader)
And the OCR engine extracts line items from each receipt:

Receipt 1 � Meals:
� Line item 1: Sandwich � $9.00 CAD
� Line item 2: Coffee � $5.00 CAD
� Total meals: $14.00 CAD
� Date: June 15, 2026
� Category: Meals
� Within disruption window: YES ?
� Threshold check: $14 ? $15 ( meal entitlement) ?
� OCR Result: PASS ?

Receipt 2 � Communication:
� Line item: Airport Wi-Fi access � $12.00 CAD
� Date: June 15, 2026
� Category: Communication
� Within disruption window: YES ?
� Threshold check: $12 ? $30 (communication entitlement) ?
� OCR Result: PASS ?

RECEIPT VALIDATION SUMMARY:
Then the system displays the OCR validation summary:
� Total receipts processed: 2
� Total line items extracted: 3
� Items PASSED: 3
� Items FLAGGED for agent review: 0
� Items FAILED: 0

EXPENSE BREAKDOWN:
� Hotel: NOT ENTITLED (delay <360 min)
� Meals: $14.00 ?
� Transport: NOT ENTITLED (delay <360 min)
� Communication: $12.00 ?
� Parking: NOT ENTITLED (delay <300 min)
� Essentials: NOT ENTITLED (delay <300 min)
� TOTAL APPROVED: $26.00 CAD

CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada"
Then the system determines: Country = Canada ? Currency = CAD
CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot checks if the claim is for multiple pax ? No
Then the chatbot responds: "You are entitled to receive a $26.00 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
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
Deposit Amount: $26.00 CAD
Payment Method: t***@gmail.com
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps that will also include the password required to access the secure payment link, which will be sent in a separate email
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user provides: "Yes"
CASE CREATION (GLOB-09):
Then the system creates a case in Case Services
And the case includes:
� DDS response code: SoC-APPR-EL-09
� Eligibility: ELIGIBLE (limited entitlements, 2�6h tier)
� Regime: APPR
� Passenger Type: Exception (Accessibility SSR) � controllability SKIPPED
� All approved line items with amounts (Meals $14 + Communication $12)
� Receipt images attached
� Fraud screening result: GREEN
� Country of residence: Canada | Currency: CAD
� Payment method: Interac e-Transfer | Payment email: t***@gmail.com
� IDV: Persona PASS
And the case reference number is provided to the passenger
Then the chatbot responds:
"Your claim has been submitted successfully. Here's a summary:
� Case Reference: [Case Number]
� Total claim amount: $26.00 CAD
� Categories: Meals ($14.00), Communication ($12.00)
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
Scenario: Claims Dashboard validation for SoC-APPR-EL-09 � Exception Limited Entitlements Eligible
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Resolved"
  And the Created date and Last Updated date are populated
  And the SLA countdown is tracking correctly
  And the Team assignment is correct
  And the Claimant Name is populated
  And the Claimant Type is "Exception"
  And the Authentication is "Pass"
  And the PNR is populated
  And the Regime is "APPR"
  And the Full Name is populated
  And the Tags include "Claimant" and "Adult"
  And the Tier Status is "Exception"
  And the Itinerary shows Journey AC 401 YYZ ? YHZ as the claimed flight
  And the Flight Status is "DELAYED (4 hours)"
  And the Eligibility section shows Journey = AC 401 YYZ ? YHZ
  And the Flight Leg at Fault is AC 401
  And the Operating Carrier is AC
  And the Disruption Reason is "Safety (Departure delay code 41 � Safety)"
  And the Delay Minutes is 240 min (4 hours)
  And the Travel Status is "Travelled (delayed)"
  And the Passenger Type is "Exception" (checked FIRST)
  And the Controllability is "SKIPPED"
  And the Overnight Eligible is "NO (delay <360 min)"
  And the Class of Booking is "J"
  And the Revenue Booking is "YES"
  And the ACR Issued shows Hotel No, Transport No, Meal No
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-APPR-EL-09"
  And the Fraud Screening is "CyberSource GREEN"
  And the Eligibility is "ELIGIBLE"
  And the Entitlement Limits Applied are LIMITED for 2�6h delay tier
  And Meals entitlement is $15 max (lower tier)
  And Communication entitlement is $30 max (>120 min)
  And Hotel is NOT ENTITLED (delay <360 min, no overnight)
  And Transport is NOT ENTITLED (delay <360 min)
  And Parking is NOT ENTITLED (delay <300 min)
  And Essentials is NOT ENTITLED (delay <300 min)
  And the Receipt Validator shows Hotel NOT ENTITLED (delay <360 min)
  And the Receipt Validator shows Meals $14.00 APPROVED (sandwich $9 + coffee $5, ?$15)
  And the Receipt Validator shows Transport NOT ENTITLED (delay <360 min)
  And the Receipt Validator shows Communication $12.00 APPROVED (Wi-Fi, ?$30)
  And the Receipt Validator shows Parking NOT ENTITLED (delay <300 min)
  And the Receipt Validator shows Essentials NOT ENTITLED (delay <300 min)
  And the Total Approved is $26.00 CAD
  And the Items Flagged for Review is 0
  And the Applicable Regimes SOC Amount is "$26.00 CAD (APPR � Suggested Highlighted)"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource result is "GREEN"
  And the Country of Residence is "Canada" with Currency "CAD"
  And the Payment Method is "Interac e-Transfer"
  And the Payment Email is "t***@gmail.com" (confirmed, locked)
  And no bank details are stored on the case
  And the IDV result is "Persona PASS (at Payment)"
  And the payout amount includes Communication ($12.00) for a total of $26.00 CAD
  And the Final Status is "Resolved"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-APPR-EL-09 � Exception Limited Entitlements Eligible
  Given the case SoC-APPR-EL-09 is determined as ELIGIBLE
  Then SOC payment is CASH ONLY
  And AC Wallet / e-credit is NOT offered
  And the route is AC 401 YYZ ? YHZ with delay 240 min (4 hrs) for 1 adult J class Exception
  And exception pax controllability is SKIPPED so ELIGIBLE regardless of code 41 (Safety)
  And the entitlements for 2�6h 1 adult J class are Meals $15 and Comm $30 only
  And Hotel, Transport, Parking, and Essentials are NOT entitled
  And the approved receipts are Meals $14 and Comm $12 totalling $26.00 CAD
  And $26.00 is less than SOC threshold so no approval is needed
  And the country of residence is Canada with currency CAD
  And the payment method is Interac e-Transfer
  And only the customer's email t***@gmail.com is collected (no bank details)
  And Persona IDV returned PASS before claim submission
  And the Comp Status is "Sent for issuance"
  And the batch file is sent to Unifier and EOD report updates only when event occurs
  And the Claims Dashboard shows $26.00 CAD, Cash, Interac, t***@gmail.com, status via talkback

EXPECTED RESULTS:
SoC-APPR-EL-09. ELIGIBLE. Exception pax (Accessibility SSR) with Safety code 41. Controllability SKIPPED. Transit delay 4h, limited entitlements (2�6h): meals $15 + communication $30 only. J class.