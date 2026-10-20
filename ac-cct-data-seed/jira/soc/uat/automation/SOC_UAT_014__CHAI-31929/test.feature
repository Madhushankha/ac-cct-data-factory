Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I was on a connecting flight. My first leg from Toronto to Calgary was fine, but my second leg from Calgary to Vancouver was cancelled because of a mechanical issue. I was stuck in Calgary for about 14 hours. I had to buy food, pay for a hotel, and take a taxi. Can I get reimbursed?"
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
� Flight: AC 701 ? AC 702
� Route: Toronto (YYZ) ? Calgary (YYC) ? Vancouver (YVR)
� Date: June 12, 2026
� Segment 1: AC 701 YYZ?YYC � Operated normally
� Segment 2: AC 702 YYC?YVR � CANCELLED (Mechanical)
Is this the journey you'd like to check?"
And the user confirms "Yes"

Then the chatbot checks if there are more than 1 segment ? Yes (2 segments)

SEGMENT SELECTION (GenUC-18a):
Then the chatbot displays the segment(s) associated with the selected journey:
"Which segment was affected by the disruption?
� Segment 1: AC 701 YYZ?YYC (Operated normally)
� Segment 2: AC 702 YYC?YVR (Cancelled � Mechanical)"
And the user selects "Segment 2: AC 702 YYC?YVR"

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + segment combination

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

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:
TRIP TRACER UI VALIDATIONS:
Then the tester opens Trip Tracer UI for PNR
Trip Overview:
? PNR: [PNR Code]
? TYPE: REVENUE
? ?? Trip Not Completed, Disruption Detected
? Multi-segment domestic trip YYZ?YYC?YVR � Segment 2 AC702 YYC?YVR was cancelled due to mechanical/safety issue (Code 44). Passenger stranded at YYC.
? PASSENGERS: 1 � SEGMENTS: 2
? Class of Booking: J (Business)

Itinerary:
? Promised Itinerary � Seg 1: AC 701, YYZ ? YYC, Dep: 12-Jun 07:00 | Seg 2: AC 702, YYC ? YVR, Dep: 12-Jun 12:00
? Current Itinerary � Seg 1: AC 701, YYZ ? YYC, Status: ON TIME | Seg 2: AC 702, YYC ? YVR, Status: CANCELLED

Standards of Care (1):
? SOC section present � SOC Segment: AC 702 YYC?YVR
? Departure Delay Code: 44 (Spares and Maintenance Equipment) � Safety
? PASSENGER: [Name] | STATUS: ELIGIBLE | BAND: DELAY_6_HOURS_OR_MORE | MEAL: $60.00 (J cabin � same CCT rate) | ACCOMMODATION: Rate of day (max $500) | GENERAL EXPENSES: Transport $200 + Comm $30 + Parking $50 + Essentials $30 | EXPIRES: [date]
? CyberSource: GREEN

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: ELIGIBLE
? Total Approved: $353.00 CAD (Hotel $210 + Meals $55 + Transport $60 + Essentials $28)

DDS RESPONSE CODE = SoC-APPR-EL-05

Then the chatbot checks which airline company is it ? AC

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger)
And CyberSource evaluates the claim
And CyberSource returns: GREEN (no fraud indicators detected)
? PROCEED to eligible flow

ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your connecting flight AC 702 from Calgary to Vancouver was cancelled due to a mechanical safety issue, and you were stranded in Calgary for approximately 14 hours. Under the applicable regulations (APPR), you may be reimbursed for reasonable expenses incurred during this disruption."

ENTITLEMENT DISPLAY:
Then the chatbot displays the eligible expense categories based on  delay, 1 adult, J class, no ACR:
"Based on the length of your disruption (14 hours), you may be eligible for reimbursement in the following categories:
� Meals: up to $60.00
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
� Receipt 1: Hotel receipt � $210.00 CAD (1 night at Calgary)
� Receipt 2: Meal receipt � $55.00 CAD (dinner + breakfast)
� Receipt 3: Taxi receipt � $60.00 CAD (airport to hotel + hotel to airport)
� Receipt 4: Essential items � $28.00 CAD (toiletries)

RECEIPT READER � OCR VALIDATION (RR-01):
Then the system processes uploaded receipts through OCR (Agentic Receipt Reader)
And the OCR engine extracts line items from each receipt:

Receipt 1 � Hotel:
� Line item: Hotel stay, 1 night � $210.00 CAD
� Date: June 12, 2026
� Category: Hotel
� Within disruption window: YES ?
� Rate of day comparison: $210 vs rate of day (Calgary) ? WITHIN range ?
� Nights: 1 (within 3-night max) ?
� Amount: $210 < $500 cap ?
� OCR Result: PASS ?

Receipt 2 � Meals:
� Line item 1: Dinner � $32.00 CAD
� Line item 2: Breakfast � $23.00 CAD
� Total meals: $55.00 CAD
� Date: June 12-13, 2026
� Category: Meals
� Within disruption window: YES ?
� Threshold check: $55 ? $60 ( meal entitlement, J class) ?
� OCR Result: PASS ?

Receipt 3 � Transport:
� Line item 1: Taxi airport?hotel � $32.00 CAD
� Line item 2: Taxi hotel?airport � $28.00 CAD
� Total transport: $60.00 CAD
� Date: June 12-13, 2026
� Category: Transport
� Within disruption window: YES ?
� Threshold check: $60 ? $200 (1-5 pax transport entitlement) ?
� OCR Result: PASS ?

Receipt 4 � Essentials:
� Line item: Toiletries kit � $28.00 CAD
� Date: June 12, 2026
� Category: Essentials
� Within disruption window: YES ?
� Threshold check: $28 ? $30 (essentials entitlement) ?
� OCR Result: PASS ?

RECEIPT VALIDATION SUMMARY:
Then the system displays the OCR validation summary:
� Total receipts processed: 4
� Total line items extracted: 6
� Items PASSED: 6
� Items FLAGGED for agent review: 0
� Items FAILED: 0

EXPENSE BREAKDOWN:
� Hotel: $210.00 ?
� Meals: $55.00 ?
� Transport: $60.00 ?
� Communication: $0.00 (no receipt submitted)
� Parking: $0.00 (no receipt submitted)
� Essentials: $28.00 ?
� TOTAL APPROVED: $353.00 CAD

CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada"
Then the system determines: Country = Canada ? Currency = CAD
CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot checks if the claim is for multiple pax ? No
Then the chatbot responds: "You are entitled to receive a $353.00 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
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
Deposit Amount: $353.00 CAD
Payment Method: t***@gmail.com
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps that will also include the password required to access the secure payment link, which will be sent in a separate email
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user provides: "Yes"
CASE CREATION (GLOB-09):
Then the system creates a case in Case Services
And the case includes:
� DDS response code: SoC-APPR-EL-05
� Eligibility: ELIGIBLE
� Regime: APPR
� Class of Booking: J (Business)
� All approved line items with amounts
� Receipt images attached
� Fraud screening result: GREEN
� Country of residence: Canada | Currency: CAD
� Payment method: Interac e-Transfer | Payment email: t***@gmail.com
� IDV: Persona PASS
And the case reference number is provided to the passenger
Then the chatbot responds:
"Your claim has been submitted successfully. Here's a summary:
� Case Reference: [Case Number]
� Total claim amount: $353.00 CAD
� Categories: Hotel ($210.00), Meals ($55.00), Transport ($60.00), Essentials ($28.00)
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
Scenario: Claims Dashboard validation for SoC-APPR-EL-05 � Safety Incomplete Journey J Class Eligible
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Resolved"
  And the Created date and Last Updated date are populated
  And the SLA countdown is tracking correctly
  And the Claimant Name is populated
  And the Claimant Type is "Regular"
  And the Authentication is "Pass"
  And the PNR is populated
  And the Regime is "APPR"
  And the Full Name is populated
  And the Tags include "Claimant" and "Adult"
  And the Itinerary shows Journey AC 701 ? AC 702 YYZ ? YYC ? YVR with claim filed for segment AC 702 YYC ? YVR
  And Segment 1 AC 701 YYZ ? YYC is "Operated normally"
  And Segment 2 AC 702 YYC ? YVR is "CANCELLED (Mechanical) � Disrupted segment"
  And the Eligibility section shows Journey = AC 701 ? AC 702 YYZ ? YYC ? YVR
  And the Flight Leg at Fault is AC 702 YYC ? YVR
  And the Operating Carrier is AC
  And the Disruption Reason is "Spares and Maintenance Equipment (Code 44 � Safety)"
  And the Delay Minutes is 840 min (14 hours)
  And the Travel Status is "No Travel � Incomplete Journey (stranded at YYC)"
  And the Controllability is "Safety"
  And the Passenger Type is "Regular" (checked FIRST)
  And the Class of Booking is "J (Business)"
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-APPR-EL-05"
  And the Fraud Screening is "CyberSource GREEN"
  And the Eligibility is "ELIGIBLE"
  And the Entitlements for 1 adult J class no ACR show Meals $60/pax, Hotel rate of day 3 nights max $500 cap, Transport $200, Communication $30/pax, Parking $50 1 day max, Essentials $30/pax
  And the Receipt Validator shows Hotel $210.00 APPROVED (1 night Calgary, within rate of day, <$500 cap)
  And the Receipt Validator shows Meals $55.00 APPROVED (dinner $32 + breakfast $23, ?$60 J class)
  And the Receipt Validator shows Transport $60.00 APPROVED (taxi airport?hotel, ?$200)
  And the Receipt Validator shows Communication $0.00 No receipt
  And the Receipt Validator shows Parking $0.00 No receipt
  And the Receipt Validator shows Essentials $28.00 APPROVED (toiletries, ?$30)
  And the Total Approved is $353.00 CAD
  And the Items Flagged for Review is 0
  And the Applicable Regimes SOC Amount is "$353.00 CAD (APPR � Suggested Highlighted)"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource result is "GREEN"
  And the Eligible confirmation email was sent
  And the email contains $353.00 CAD, category breakdown, and J class noted
  And the Country of Residence is "Canada" with Currency "CAD"
  And the Payment Method is "Interac e-Transfer"
  And the Payment Email is "t***@gmail.com" (confirmed, locked)
  And no bank details are stored on the case
  And the IDV result is "Persona PASS (at Payment)"
  And the secure payment link email and password were sent to "t***@gmail.com"
  And the Final Status is "Resolved"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-APPR-EL-05 � Safety Incomplete Journey J Class Eligible
  Given the case SoC-APPR-EL-05 is determined as ELIGIBLE
  Then SOC payment is CASH ONLY
  And AC Wallet / e-credit is NOT offered
  And the route is AC 701 ? AC 702 YYZ ? YYC ? YVR (stranded at YYC) for 1 adult J class
  And the approved receipts are Hotel $210, Meals $55, Taxi $60, Essentials $28 totalling $353.00 CAD
  And the country of residence is Canada with currency CAD
  And the payment method is Interac e-Transfer
  And only the customer's email t***@gmail.com is collected (no bank details)
  And Persona IDV returned PASS before claim submission
  And the Comp Status is "Sent for issuance"
  And the Claims Dashboard shows $353.00 CAD, Cash, Interac, t***@gmail.com, status via talkback

EXPECTED RESULTS:
SoC-APPR-EL-05. ELIGIBLE. No travel (incomplete), Safety. J class entitlements applied. Full receipt + case flow.