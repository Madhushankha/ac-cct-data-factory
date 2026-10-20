Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I was on a connecting flight within Israel from Tel Aviv through Haifa to Eilat. My first leg was fine, but my second leg from Haifa to Eilat was cancelled because of an aircraft defect. I was stuck in Haifa for about 3 hours. I had to buy food while waiting. Can I get reimbursed?"
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
� Flight: AC 090 ? AC 091
� Route: Tel Aviv (TLV) ? Haifa (HFA) ? Eilat (VDA)
� Date: June 13, 2026
� Departure Delay: 180 min (3 hours)
Is this the journey you'd like to check?"
And the user confirms "Yes"

Then the chatbot checks if there are more than 1 segment ? Yes (2 segments)

	
SEGMENT SELECTION (GenUC-18a): 
Then the chatbot displays: "Which segment was affected by the disruption? 
* Segment 1: AC 090 TLV?HFA (Operated normally) 
* Segment 2: AC 091 HFA?VDA (Cancelled)" 
And the user selects "Segment 2: AC 091 HFA?VDA"

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes
Then the chatbot checks has it been more than 73 hours for all segments in the selected journey ? Yes

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for ASL SOC
And the system calculates:
� ASL limitation: 1,460 days (4 years) � FIXED
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
? Multi-segment trip TLV?HFA?VDA � Segment 2 AC091 HFA?VDA was cancelled due to aircraft defect. Passenger stranded at HFA for 3 hours.
? Regime: ASL (TLV?HFA?VDA = all Israel)
? PASSENGERS: 1 � SEGMENTS: 2
? Class of Booking: J (Business)

Itinerary:
? Promised Itinerary � Seg 1: AC 090, TLV ? HFA | Seg 2: AC 091, HFA ? VDA
? Current Itinerary � Seg 1: AC 090, TLV ? HFA, Status: ON TIME | Seg 2: AC 091, HFA ? VDA, Status: CANCELLED

Standards of Care (1):
? SOC section present � SOC Segment: AC 091 HFA?VDA
? Departure Delay Code: 05 (Aircraft Defect) � NOT CHECKED (ASL does not evaluate controllability)
? Geographic Check: TLV?HFA?VDA = all Israel ? PASSED ?
? Cancellation: YES ? | SOC Segment Delay: 180 min (3h) ? ?2h ?
? PASSENGER: [Name] | STATUS: ELIGIBLE | BAND: DELAY_2_TO_6_HOURS | MEAL: ?55.00 (LIMITED � short delay tier) | ACCOMMODATION: � (NOT ENTITLED, delay <6h) | GENERAL EXPENSES: Comm ?110 only (Transport/Parking/Essentials NOT ENTITLED) | EXPIRES: [date]
? CyberSource: GREEN
? LIMITED entitlements: Meals ?55 + Comm ?110 only. No hotel/transport/parking/essentials.

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: ELIGIBLE
? Total Approved: ?83.00 ILS (Meals ?48 + Comm ?35)
DDS RESPONSE CODE = SoC-ASL-EL-03

Then the chatbot checks which airline company is it ? AC

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger)
And CyberSource evaluates the claim
And CyberSource returns: GREEN (no fraud indicators detected)
? PROCEED to eligible flow

ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "Your connecting flight AC 091 from Haifa to Eilat was cancelled due to an aircraft defect, and you were stranded in Haifa for approximately 3 hours."

ENTITLEMENT DISPLAY:
Then the chatbot displays the eligible expense categories based on  delay, 1 adult, J class, ASL regime:
"Based on the length of your disruption (3 hours), you may be eligible for reimbursement in the following categories:
� Meals: up to ?55.00
� Communication: up to ?110.00

Please note that due to the length of the disruption (under 6 hours), hotel accommodation, ground transportation, parking, and essential items are not eligible for reimbursement at this time.

All expenses must have been incurred during the disruption period and supported by valid receipts."

RECEIPT UPLOAD � WELCOME BACK FLOW:
Then the chatbot responds:
"To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption."
And the chatbot displays the receipt upload interface
And the user uploads receipt images:
� Receipt 1: Meal receipt � ?48.00 ILS (sandwich + coffee + water at Ben Gurion)
� Receipt 2: Communication � ?35.00 ILS (Wi-Fi access + phone calls)

RECEIPT READER � OCR VALIDATION (RR-01):
Then the system processes uploaded receipts through OCR (Agentic Receipt Reader)
And the OCR engine extracts line items from each receipt:

Receipt 1 � Meals:
� Line item 1: Sandwich � ?28.00 ILS
� Line item 2: Coffee � ?14.00 ILS
� Line item 3: Water � ?6.00 ILS
� Total meals: ?48.00 ILS
� Date: June 13, 2026
� Category: Meals
� Within disruption window: YES ?
� Threshold check: ?48 ? ?55 ( meal entitlement) ?
� OCR Result: PASS ?

Receipt 2 � Communication:
� Line item 1: Airport Wi-Fi access � ?20.00 ILS
� Line item 2: Phone calls � ?15.00 ILS
� Total communication: ?35.00 ILS
� Date: June 13, 2026
� Category: Communication
� Within disruption window: YES ?
� Threshold check: ?35 ? ?110 ?
� OCR Result: PASS ?

RECEIPT VALIDATION SUMMARY:
Then the system displays the OCR validation summary:
� Total receipts processed: 2
� Total line items extracted: 5
� Items PASSED: 5
� Items FLAGGED for agent review: 0
� Items FAILED: 0

EXPENSE BREAKDOWN:
� Hotel: NOT ENTITLED (delay <360 min)
� Meals: ?48.00 ?
� Transport: NOT ENTITLED (delay <360 min)
� Communication: ?35.00 ?
� Parking: NOT ENTITLED (delay <300 min)
� Essentials: NOT ENTITLED (delay <300 min)
� TOTAL APPROVED: ?83.00 ILS

CASE CREATION (GLOB-09):
Then the system creates a case in Case Services
And the case includes:
� DDS response code: SoC-ASL-EL-03
� Eligibility: ELIGIBLE
� Regime: ASL
  (limited entitlements)
� Currency: ILS (receipts in ILS � no conversion needed)
� All approved line items with amounts
� Receipt images attached
� Fraud screening result: GREEN
And the case reference number is provided to the passenger

Then the chatbot responds:
"Your claim has been submitted successfully. Here's a summary:
� Case Reference: [Case Number]
� Total claim amount: ?83.00 ILS
� Categories: Meals (?48.00), Communication (?35.00)

You will receive a confirmation email shortly with your case details and next steps."

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe
And an eligible confirmation email is sent to the passenger at t***@gmail.com

CLAIMS PAYMENT FLOW:
Then the system initiates payment processing
And Case Services calculates:
� Approved amount: ?83.00 ILS
� Currency conversion to country of residence currency (if different from ILS)
� Payment method per country of residence

Then the chatbot responds:
"To complete your reimbursement, we'll need your payment details."
And the chatbot collects:
� Country of residence: [Country]
� Payment method: [determined by country]
� Payment details: [collected securely]

Then the chatbot responds:
"Your payment of [amount in local currency] will be processed via [payment method]. You should receive the funds within [X] business days."

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-ASL-EL-03 � ASL Eligible Incomplete Journey Limited Entitlements
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Resolved"
  And the Itinerary shows Journey AC 090 ? AC 091 TLV ? HFA ? VDA with claim filed for segment AC 091 HFA ? VDA
  And Segment 1 AC 090 TLV ? HFA is "Operated normally"
  And Segment 2 AC 091 HFA ? VDA is "CANCELLED (Aircraft defect) � Disrupted segment"
  And the Eligibility section shows Journey = AC 090 ? AC 091 TLV ? HFA ? VDA
  And the Flight Leg at Fault is AC 091 HFA ? VDA
  And the Operating Carrier is AC
  And the Departure Delay Code is "05 (Aircraft Defect) � NOT CHECKED under ASL"
  And the Delay Minutes is 180 min (3 hours)
  And the Travel Status is "No Travel � Incomplete Journey (stranded at HFA)"
  And the Geographic Check is "PASSED ? (TLV ? HFA ? VDA = all Israel)"
  And the Controllability is "NOT CHECKED (ASL regime)"
  And the SOC Segment Cancellation Check is "CANCELLED ?"
  And the SOC Segment Departure Delay is "?2h (3 hours) ?"
  And the Overnight Eligible is "NO (delay <360 min)"
  And the Class of Booking is "J (Business)"
  And the DDS Response Code is "SoC-ASL-EL-03"
  And the Fraud Screening is "CyberSource GREEN"
  And the Eligibility is "ELIGIBLE"
  And the Entitlement Limits Applied are LIMITED
  And Meals entitlement is ?55 max (lower tier, J cabin � same CCT rate)
  And Communication entitlement is ?110 max
  And Hotel is NOT ENTITLED (delay <360 min)
  And Transport is NOT ENTITLED
  And Parking is NOT ENTITLED
  And Essentials is NOT ENTITLED
  And the Receipt Validator shows Meals ?48.00 APPROVED (??55)
  And the Receipt Validator shows Communication ?35.00 APPROVED (??110)
  And the Total Approved is ?83.00 ILS
  And the Items Flagged for Review is 0
  And the Final Status is "Resolved"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-ASL-EL-03 � ASL Eligible Incomplete Journey Limited Entitlements
  Given the case SoC-ASL-EL-03 is determined as ELIGIBLE
  Then SOC payment is CASH ONLY
  And the route is AC 090 ? AC 091 TLV ? HFA ? VDA (stranded at HFA) with delay 180 min (3 hrs) for 1 adult J class
  And ASL controllability is NOT checked
  And the entitlements are LIMITED for 2�6h delay: Meals ?55 and Comm ?110 only
  And Hotel, Transport, Parking, and Essentials are NOT entitled
  And the approved receipts are Meals ?48 and Comm ?35 totalling ?83.00 ILS
  And the country of residence determines currency and payment method
  And the Comp Status is "Sent for issuance"
  And the batch file is sent to Unifier and EOD report updates only when event occurs
  And the Claims Dashboard shows ?83.00 ILS, Cash, payment method, status via talkback

EXPECTED RESULTS:
SoC-ASL-EL-03. ELIGIBLE. No travel (incomplete � stranded at HFA mid-point), SOC segment (AC 091) cancelled, departure delay 180 min (?2h). Controllability NOT checked (ASL). J class, limited entitlements (meals ?55 + comm ?110 only). Full receipt + case flow.