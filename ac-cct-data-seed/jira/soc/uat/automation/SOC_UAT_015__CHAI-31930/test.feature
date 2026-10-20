Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Toronto to Vancouver was delayed by about 6 hours because of bad weather. I'm a Super Elite member and was travelling with a companion. We had to pay for meals, a hotel, and taxis. Can we get reimbursed?"
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
Then the chatbot checks if there are multiple PAX on PNR? ? Yes (2 passengers)

PASSENGER SELECTION (GenUC-06):
Then the chatbot asks:
"How many people are on your claim?"
And the chatbot displays passengers from PNR:
"I found 2 passengers on this booking:
� [First Name] [Last Name] (Adult) � Super Elite 50K � Claimant
� [Companion First Name] [Companion Last Name] (Adult)

Is this who you'd like to include in the claim?"
And the user confirms "Yes, both"
Then the chatbot checks: PAX count on PNR = 2 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 301
� Route: Toronto (YYZ) ? Vancouver (YVR)
� Date: June 13, 2026
� Departure Delay: 6 hours
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

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

TRIP TRACER UI VALIDATIONS:
Then the tester opens Trip Tracer UI for PNR
Trip Overview:
? PNR: [PNR Code]
? TYPE: REVENUE
? ?? Trip Completed, Disruption Detected
? Single-segment domestic trip YYZ?YVR on AC301 was delayed +6H 00M due to weather (uncontrollable � but IRRELEVANT for exception pax)
? PASSENGERS: 2 (Super Elite 50K + companion) � SEGMENTS: 1
? Class of Booking: J (Business)

Itinerary:
? Promised Itinerary � Flight: AC 301, Route: YYZ ? YVR, Scheduled Dep: 12-Jun 08:00
? Current Itinerary � Flight: AC 301, Route: YYZ ? YVR, Status: ARRIVED LATE, Scheduled Dep: 08:00 ? Actual: 14:00, Delay: +6H 00M

Standards of Care (2):
? SOC section present � 2 passenger rows
? Departure Delay Code: 77 (Weather) � Uncontrollable (SKIPPED � exception pax)
? PASSENGER 1 (Adult � Super Elite 50K � Claimant): [Name] | STATUS: ELIGIBLE | BAND: DELAY_6_HOURS_OR_MORE | MEAL: $30.00 | ACCOMMODATION: Rate of day (max $500) | GENERAL EXPENSES: per-pax amounts | EXPIRES: [date]
? PASSENGER 2 (Adult � Companion): [Name] | STATUS: ELIGIBLE (exception privilege extended) | same entitlements
? Transportation (PNR-level): $200.00 (1�5 pax shared)
? Hotel: 2 rooms (1 per adult)
? CyberSource: GREEN
? CRITICAL: Exception pax ? controllability SKIPPED. Regular pax + weather = NE-07. Exception pax + weather = EL-07.

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: ELIGIBLE
? Total Approved: $127.00 CAD (Meals $52 + Comm $40 + Essentials $35)

DDS RESPONSE CODE = SoC-APPR-EL-07

Then the chatbot checks which airline company is it ? AC

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger)
And CyberSource evaluates the claim
And CyberSource returns: GREEN (no fraud indicators detected)
? PROCEED to eligible flow

ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "Great news! Based on the details of your flight, both passengers on your booking are eligible for expense reimbursement. Your flight AC 301 from Toronto to Vancouver was delayed by approximately 6 hours. As a valued Super Elite member, you and your travel companion are eligible for reimbursement of reasonable expenses incurred during this disruption under the applicable regulations (APPR)."

ENTITLEMENT DISPLAY:
Then the chatbot displays the eligible expense categories based on  delay, 2 adults, J class, no ACR:
"Based on the length of your disruption (6 hours) and your party size (2 passengers), you may be eligible for reimbursement in the following categories:
� Meals: up to $30.00 per person � 2 = $60.00
� Hotel accommodation: Rate of day, 2 rooms (1 per adult), up to 3 nights, $500 maximum
� Ground transportation: up to $200.00 (1-5 passengers)
� Communication: up to $30.00 per person � 2 = $60.00
� Parking: up to $50.00 (1 day maximum)
� Essential items: up to $30.00 per person � 2 = $60.00

Please note that all expenses must have been incurred during the disruption period and supported by valid receipts."

RECEIPT UPLOAD � WELCOME BACK FLOW:
Then the chatbot responds:
"To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption."
And the chatbot displays the receipt upload interface
And the user uploads receipt images:
� Receipt 1: Meal receipt � $52.00 CAD (dinner for 2 at airport restaurant)
� Receipt 2: Communication � $40.00 CAD (Wi-Fi + phone calls for 2)
� Receipt 3: Essential items � $35.00 CAD (toiletries for 2)

NOTE: No hotel receipt submitted � delay was 6 hours, overnight was borderline.
Overnight eligibility check: Delay >360 min AND ETD from 5 AM ? 
  Original ETD = 14:00 + 6h delay = new dep 20:00 ? overnight may apply depending on Departure time.

RECEIPT READER � OCR VALIDATION (RR-01):
Then the system processes uploaded receipts through OCR (Agentic Receipt Reader)
And the OCR engine extracts line items from each receipt:

Receipt 1 � Meals:
� Line item 1: Dinner (Person 1) � $28.00 CAD
� Line item 2: Dinner (Person 2) � $24.00 CAD
� Total meals: $52.00 CAD
� Date: June 13, 2026
� Category: Meals
� Within disruption window: YES ?
� Threshold check: $52 ? $60 (, 2 pax � $30) ?
� OCR Result: PASS ?

Receipt 2 � Communication:
� Line item 1: Wi-Fi access (2 devices) � $25.00 CAD
� Line item 2: Phone calls � $15.00 CAD
� Total communication: $40.00 CAD
� Date: June 13, 2026
� Category: Communication
� Within disruption window: YES ?
� Threshold check: $40 ? $60 (2 pax � $30) ?
� OCR Result: PASS ?

Receipt 3 � Essentials:
� Line item 1: Toiletry kit (Person 1) � $18.00 CAD
� Line item 2: Toiletry kit (Person 2) � $17.00 CAD
� Total essentials: $35.00 CAD
� Date: June 13, 2026
� Category: Essentials
� Within disruption window: YES ?
� Threshold check: $35 ? $60 (2 pax � $30) ?
� OCR Result: PASS ?

RECEIPT VALIDATION SUMMARY:
Then the system displays the OCR validation summary:
� Total receipts processed: 3
� Total line items extracted: 6
� Items PASSED: 6
� Items FLAGGED for agent review: 0
� Items FAILED: 0

EXPENSE BREAKDOWN:
� Hotel: $0.00 (no receipt submitted)
� Meals: $52.00 ? (2 pax)
� Transport: $0.00 (no receipt submitted)
� Communication: $40.00 ? (2 pax)
� Parking: $0.00 (no receipt submitted)
� Essentials: $35.00 ? (2 pax)
� TOTAL APPROVED: $127.00 CAD

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
Scenario: Claims Dashboard validation for SoC-APPR-EL-07 � Exception Super Elite 50K + Companion Eligible
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the agent can edit Topic/Sub-topic but cannot switch between automated and non-automated
  And the Status is "Resolved"
  And the Created date is populated
  And the Last Updated date is populated
  And the SLA countdown is tracking correctly
  And the Team assignment is correct
  And no banners are displayed (identified + authenticated, Auth Flow 1)
  And the Decision Assist panel is NOT greyed out
  And the Claimant Name is populated
  And the Claimant Type is "Exception (Super Elite 50K)"
  And the Authentication is "Pass"
  And the PNR is populated
  And the PNR Creation Date is populated
  And the Journey ID is populated
  And the Booking Source is populated
  And the Booking Office ID is populated
  And the Regime is "APPR"
  And Passenger 1 Full Name is populated with Tags "Claimant, Adult, Super Elite 50K"
  And Passenger 1 Email is "t***@gmail.com"
  And Passenger 1 Phone is "+1***789"
  And Passenger 1 Address is populated
  And Passenger 1 Tier Status is "Super Elite 50K"
  And Passenger 2 Full Name is populated with Tags "Adult, Companion"
  And Passenger 2 Exception Privilege is "CONFERRED from Passenger 1"
  And Passenger 2 Tier Status is "Regular (privilege extended via exception rule)"
  And the Itinerary shows Journey AC 301 YYZ ? YVR as the claimed flight
  And the Flight Status is "DELAYED (6 hours)"
  And the Ancillary Fee section is present with no entries
  And the Eligibility section shows Journey = AC 301 YYZ ? YVR
  And the Flight Leg at Fault is AC 301
  And the Operating Carrier is AC
  And the Disruption Reason is "Weather (Code 77 � UNCONTROLLABLE but IRRELEVANT for exception pax)"
  And the Delay Minutes is 360 min (6 hours)
  And the Travel Status is "Travelled (delayed Departure)"
  And the Passenger Type is "EXCEPTION � Super Elite 50K" (checked FIRST)
  And the Controllability is "SKIPPED � exception passenger bypasses controllability check entirely"
  And the Exception Privilege Extended is "YES � companion receives same eligibility"
  And the Overnight Eligible is "Borderline (delay = 360 min, depends on ETD/Departure time)"
  And the Class of Booking is "J (Business)"
  And the Revenue Booking is "YES"
  And the ACR Issued shows Hotel No, Transport No, Meal No
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-APPR-EL-07"
  And the Fraud Screening is "CyberSource GREEN"
  And the Eligibility is "ELIGIBLE (both passengers)"
  And the same scenario with Regular pax would be SoC-APPR-NE-07 (NOT ELIGIBLE) because weather is uncontrollable but exception pax bypasses controllability entirely
  And the Entitlements for 2 adults J class no ACR show Meals $30�2=$60, Hotel 2 rooms/$500 cap, Transport $200, Communication $30�2=$60, Parking $50 1 day max, Essentials $30�2=$60
  And the Receipt Validator shows Hotel $0.00 No receipt submitted
  And the Receipt Validator shows Meals $52.00 APPROVED (2 pax: $28 + $24, ?$60)
  And the Receipt Validator shows Transport $0.00 No receipt submitted
  And the Receipt Validator shows Communication $40.00 APPROVED (2 pax: Wi-Fi $25 + calls $15, ?$60)
  And the Receipt Validator shows Parking $0.00 No receipt submitted
  And the Receipt Validator shows Essentials $35.00 APPROVED (2 pax: $18 + $17, ?$60)
  And the Total Approved is $127.00 CAD
  And the Items Flagged for Review is 0
  And the Applicable Regimes SOC Amount is "$127.00 CAD (APPR � Suggested Highlighted)"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource result is "GREEN"
  And the Booking Auto-Append shows the system appended the booking record automatically
  And the Eligible confirmation email was sent to "t***@gmail.com"
  And the email contains both passengers covered, $127.00 CAD, category breakdown, and Super Elite status noted
  And the Country of Residence is "Canada" with Currency "CAD"
  And the Payment Method is "Interac e-Transfer"
  And the Payment Email is "t***@gmail.com" (claimant, single payee, locked)
  And no bank details are stored on the case
  And the IDV result is "Persona PASS (at Payment)"
  And AC Wallet / e-credit was NOT offered despite Aeroplan number on booking
  And the Final Status is "Resolved"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-APPR-EL-07 � Exception Super Elite 50K + Companion Eligible
  Given the case SoC-APPR-EL-07 is determined as ELIGIBLE
  Then SOC payment is CASH ONLY
  And AC Wallet / e-credit is NOT offered even though an Aeroplan number is on the booking
  And the route is AC 301 YYZ ? YVR with delay 360 min (6 hrs) for 2 adults (SE50K + companion) J class
  And exception pax controllability is SKIPPED so ELIGIBLE regardless
  And the approved receipts are Meals $52, Comm $40, Essentials $35 totalling $127.00 CAD
  And the country of residence is Canada with currency CAD
  And the payment method is Interac e-Transfer to a single email t***@gmail.com
  And only the customer's email is collected (no bank details)
  And Persona IDV returned PASS before claim submission
  And the Comp Status is "Sent for issuance"
  And the Claims Dashboard shows $127.00 CAD, Cash, Interac, t***@gmail.com, status via talkback

EXPECTED RESULTS:
SoC-APPR-EL-07. ELIGIBLE. Exception passenger (Super Elite 50K) recognized. Pax type checked FIRST � controllability SKIPPED entirely. Eligible regardless of disruption type (weather = uncontrollable, but irrelevant). Exception privilege extends to companion on same PNR. Both passengers receive eligible status. Full receipt + case flow completes for entire party. Hotel: 2 rooms entitled.