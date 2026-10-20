Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My Air Canada flight from Tel Aviv to Toronto was delayed by about 7 hours because of bad weather. I had to buy food, pay for a hotel overnight, and take a taxi. Can I get reimbursed for what I spent?"
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
� Flight: AC 084
� Route: Tel Aviv (TLV) ? Toronto (YYZ)
� Date: June 10, 2026
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
? ?? Trip Completed, Disruption Detected
? Single-segment trip TLV?YYZ on AC085 was delayed +7H 00M (note: prereqs say 24h/1440 min but chatbot says 7h � use chatbot flow: 7h) due to weather (uncontrollable � NOT CHECKED under ASL)
? Regime: ASL (TLV departure � Israel)
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 085, Route: TLV ? YYZ, Scheduled Dep: 18-Jun 16:00
? Current Itinerary � Flight: AC 085, Route: TLV ? YYZ, Status: ARRIVED LATE, Delay: +7H 00M

Standards of Care (1):
? SOC section present
? Departure Delay Code: 77 (Weather) � NOT CHECKED (ASL does not evaluate controllability)
? Geographic Check: Origin = TLV (Israel) ?
? PASSENGER: [Name] | STATUS: ELIGIBLE | BAND: DELAY_6_HOURS_OR_MORE | MEAL: ?110.00 | ACCOMMODATION: Rate of day (max ?1,800) | GENERAL EXPENSES: Transport ?720 + Comm ?110 + Parking ?180 + Essentials ?110 | EXPIRES: [date]
? CyberSource: GREEN
? CRITICAL: Weather = NOT ELIGIBLE under APPR (NE-07) but ELIGIBLE under ASL (EL-01)
? Currency: ILS (Israeli New Shekel � ?)

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: ELIGIBLE
? Total Approved: ?870.00 ILS (Hotel ?550 + Meals ?95 + Transport ?180 + Comm ?45)

DDS RESPONSE CODE = SoC-ASL-EL-01

Then the chatbot checks which airline company is it ? AC

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger)
And CyberSource evaluates the claim
And CyberSource returns: GREEN (no fraud indicators detected)
? PROCEED to eligible flow

ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 084 from Tel Aviv to Eilat was delayed by approximately 7 hours. Under the applicable Israeli aviation regulations (ASL), you may be reimbursed for reasonable expenses incurred during this disruption."

ENTITLEMENT DISPLAY:
Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, ASL regime:
"Based on the length of your disruption (7 hours), you may be eligible for reimbursement in the following categories:
� Meals: up to ?110.00
� Hotel accommodation: Rate of day (up to 3 nights, ?1,800 maximum)
� Ground transportation: up to ?720.00
� Communication: up to ?110.00
� Parking: up to ?180.00 (1 day maximum)
� Essential items: up to ?110.00

 ASL CURRENCY NOTE:
ASL entitlements are calculated in ILS (Israeli New Shekel � ?).
Receipts may be in any currency � Case Services handles conversion:
1. Receipt currency ? regime currency (ILS) for threshold comparison
2. Regime currency ? country of residence currency for payout display

Please note that all expenses must have been incurred during the disruption period and supported by valid receipts."

RECEIPT UPLOAD � WELCOME BACK FLOW:
Then the chatbot responds:
"To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption."
And the chatbot displays the receipt upload interface
And the user uploads receipt images:
� Receipt 1: Hotel receipt � ?550.00 ILS (1 night near Ben Gurion)
� Receipt 2: Meal receipt � ?95.00 ILS (dinner + breakfast)
� Receipt 3: Taxi receipt � ?180.00 ILS (airport to hotel + hotel to airport)
� Receipt 4: Communication � ?45.00 ILS (Wi-Fi + phone calls)

RECEIPT READER � OCR VALIDATION (RR-01):
Then the system processes uploaded receipts through OCR (Agentic Receipt Reader)
And the OCR engine extracts line items from each receipt:

Receipt 1 � Hotel:
� Line item: Hotel stay, 1 night � ?550.00 ILS
� Date: June 10, 2026
� Category: Hotel
� Within disruption window: YES ?
� Rate of day comparison: ?550 vs rate of day (Tel Aviv area) ? WITHIN range ?
� Nights: 1 (within 3-night max) ?
� Amount: ?550 < ?1,800 cap ?
� OCR Result: PASS ?

Receipt 2 � Meals:
� Line item 1: Dinner � ?55.00 ILS
� Line item 2: Breakfast � ?40.00 ILS
� Total meals: ?95.00 ILS
� Date: June 10-11, 2026
� Category: Meals
� Within disruption window: YES ?
� Threshold check: ?95 ? ?110 ( meal entitlement) ?
� OCR Result: PASS ?

Receipt 3 � Transport:
� Line item 1: Taxi airport?hotel � ?100.00 ILS
� Line item 2: Taxi hotel?airport � ?80.00 ILS
� Total transport: ?180.00 ILS
� Date: June 10-11, 2026
� Category: Transport
� Within disruption window: YES ?
� Threshold check: ?180 ? ?720 ?
� OCR Result: PASS ?

Receipt 4 � Communication:
� Line item 1: Wi-Fi � ?25.00 ILS
� Line item 2: Phone calls � ?20.00 ILS
� Total communication: ?45.00 ILS
� Date: June 10, 2026
� Category: Communication
� Within disruption window: YES ?
� Threshold check: ?45 ? ?110 ?
� OCR Result: PASS ?

RECEIPT VALIDATION SUMMARY:
Then the system displays the OCR validation summary:
� Total receipts processed: 4
� Total line items extracted: 6
� Items PASSED: 6
� Items FLAGGED for agent review: 0
� Items FAILED: 0

EXPENSE BREAKDOWN:
� Hotel: ?550.00 ?
� Meals: ?95.00 ?
� Transport: ?180.00 ?
� Communication: ?45.00 ?
� Parking: ?0.00 (no receipt submitted)
� Essentials: ?0.00 (no receipt submitted)
� TOTAL APPROVED: ?870.00 ILS

CASE CREATION (GLOB-09):
Then the system creates a case in Case Services
And the case includes:
� DDS response code: SoC-ASL-EL-01
� Eligibility: ELIGIBLE
� Regime: ASL
� Currency: ILS (receipts in ILS � no conversion needed for threshold comparison)
� All approved line items with amounts
� Receipt images attached
� Fraud screening result: GREEN
� Note: Weather disruption (Code 77) � APPR would reject as uncontrollable, but ASL does NOT check controllability ? ELIGIBLE (same as EU)
And the case reference number is provided to the passenger

Then the chatbot responds:
"Your claim has been submitted successfully. Here's a summary:
� Case Reference: [Case Number]
� Total claim amount: ?870.00 ILS
� Categories: Hotel (?550.00), Meals (?95.00), Transport (?180.00), Communication (?45.00)

You will receive a confirmation email shortly with your case details and next steps."

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe
And an eligible confirmation email is sent to the passenger at t***@gmail.com
And the email includes:
� Case reference number
� Claim summary with approved amounts (in country of residence currency)
� Next steps for payment processing

CLAIMS PAYMENT FLOW:
Then the system initiates payment processing
And Case Services calculates:
� Approved amount: ?870.00 ILS
� Currency conversion to country of residence currency (if different from ILS)
� Payment method determination based on country of residence:
  - Israel ? Local bank transfer or BSM
  - Canada ? EFT (converted to CAD)
  - US + 70 BSM countries ? VSF
  - Others ? BSM or manual

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
Scenario: Claims Dashboard validation for SoC-ASL-EL-01 � ASL Eligible Travel Completed Weather
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
  And the Regime is "ASL"
  And the Full Name is populated
  And the Tags include "Claimant" and "Adult"
  And the Tier Status is "Regular"
  And the Itinerary shows Journey AC 084 TLV ? VDA as the claimed flight
  And the Flight Status is "DELAYED (7 hours)"
  And the Eligibility section shows Journey = AC 084 TLV ? VDA
  And the Flight Leg at Fault is AC 084
  And the Operating Carrier is AC
  And the Disruption Reason is "Weather (Code 77 � IRRELEVANT under ASL)"
  And the Delay Minutes is 420 min (7 hours)
  And the Travel Status is "Travelled (delayed Departure)"
  And the Passenger Type is "Regular"
  And the Geographic Check is "PASSED ? (TLV ? VDA = Israel ? Israel)"
  And the Controllability is "NOT CHECKED (ASL regime � controllability irrelevant, same as EU)"
  And the Overnight Eligible is "YES (delay >360 min)"
  And the Class of Booking is "PY"
  And the DDS Response Code is "SoC-ASL-EL-01"
  And the Fraud Screening is "CyberSource GREEN"
  And the Eligibility is "ELIGIBLE"
  And under APPR this would be SoC-APPR-NE-07 (NOT ELIGIBLE � weather is uncontrollable), under EU SoC-EU-EL-01 (ELIGIBLE), and under ASL SoC-ASL-EL-01 (ELIGIBLE � same as EU)
  And the Receipt Validator shows Hotel ?550.00 APPROVED
  And the Receipt Validator shows Meals ?95.00 APPROVED (??110)
  And the Receipt Validator shows Transport ?180.00 APPROVED (??720)
  And the Receipt Validator shows Communication ?45.00 APPROVED (??110)
  And the Receipt Validator shows Parking ?0.00 No receipt
  And the Receipt Validator shows Essentials ?0.00 No receipt
  And the Total Approved is ?870.00 ILS
  And the Items Flagged for Review is 0
  And the Final Status is "Resolved"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-ASL-EL-01 � ASL Eligible Travel Completed Weather
  Given the case SoC-ASL-EL-01 is determined as ELIGIBLE
  Then SOC payment is CASH ONLY
  And the route is AC 084 TLV ? VDA with delay 420 min (7 hrs) for 1 adult PY
  And ASL controllability is NOT checked
  And the approved receipts are Hotel ?550, Meals ?95, Taxi ?180, Comm ?45 totalling ?870.00 ILS
  And the receipts are in ILS so no conversion is needed for threshold comparison
  And the country of residence determines payout currency and method
  And currency conversion logging includes ILS amount, CAD equivalent, and exchange rate
  And the Comp Status is "Sent for issuance"
  And the Claims Dashboard shows ?870.00 ILS, Cash, payment method, status via talkback

EXPECTED RESULTS:
SoC-ASL-EL-01. ELIGIBLE. No travel (origin), delay ?2h. Controllability NOT checked (ASL regime). Geographic check passed: origin = TLV (Israel). Entitlements in ILS. Full receipt + case flow.