Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Tel Aviv to Eilat was cancelled because of bad weather and I never made it to my destination. I was stuck at Ben Gurion airport for about 18 hours. I had to buy meals, pay for a hotel, and take a taxi. Can I get reimbursed for what I spent?"
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
� Route: Tel Aviv (TLV) ? Eilat (VDA)
� Date: June 11, 2026
� Status: CANCELLED
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
? ?? Trip Not Completed, Disruption Detected
? Single-segment trip TLV?VDA on AC084 was cancelled � passenger stayed at origin (TLV) for 18 hours
? Regime: ASL (TLV?VDA = Israel?Israel)
? PASSENGERS: 3 (2 adults + 1 child) � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 084, Route: TLV ? VDA, Scheduled Dep: 19-Jun 21:00
? Current Itinerary � Flight: AC 084, Route: TLV ? VDA, Status: CANCELLED

Standards of Care (3):
? SOC section present � 3 passenger rows
? Departure Delay Code: 77 (Weather) � NOT CHECKED (ASL does not evaluate controllability)
? Geographic Check: TLV?VDA = Israel?Israel ? PASSED ?
? Cancellation: YES ? | SOC Segment Delay to rebooking: 1080 min (18h) ? ?2h ?
? PASSENGER 1 (Adult � Claimant): [Name] | STATUS: ELIGIBLE | BAND: DELAY_6_HOURS_OR_MORE | MEAL: ?220.00 (3 pax) | ACCOMMODATION: Rate of day (max ?1,800) | GENERAL EXPENSES: per-pax amounts | EXPIRES: [date]
? PASSENGER 2 (Adult): [Name] | STATUS: ELIGIBLE | same entitlements
? PASSENGER 3 (Child): [Name] | STATUS: ELIGIBLE | same entitlements
? Transportation (PNR-level): ?720.00 (1�5 pax shared)
? Hotel: 2 rooms (1 per adult)
? CyberSource: GREEN

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: ELIGIBLE
? Total Approved: ?1,085.00 ILS (Hotel ?600 + Meals ?190 + Transport ?200 + Essentials ?95)

DDS RESPONSE CODE = SoC-ASL-EL-02

Then the chatbot checks which airline company is it ? AC

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger)
And CyberSource evaluates the claim
And CyberSource returns: GREEN (no fraud indicators detected)
? PROCEED to eligible flow

ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 084 from Tel Aviv to Eilat was cancelled and you were unable to travel for approximately 18 hours. Under the applicable Israeli aviation regulations (ASL), you may be reimbursed for reasonable expenses incurred during this disruption."

ENTITLEMENT DISPLAY:
Then the chatbot displays the eligible expense categories based on  delay, 2 adults + 1 child, PY class, ASL regime:
"Based on the length of your disruption (18 hours), you may be eligible for reimbursement in the following categories:
� Meals: up to ?220.00
� Hotel accommodation: Rate of day (up to 3 nights, ?1,800 maximum)
� Ground transportation: up to ?720.00
� Communication: up to ?110.00
� Parking: up to ?180.00 (1 day maximum)
� Essential items: up to ?110.00

Please note that all expenses must have been incurred during the disruption period and supported by valid receipts."

RECEIPT UPLOAD � WELCOME BACK FLOW:
Then the chatbot responds:
"To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption."
And the chatbot displays the receipt upload interface
And the user uploads receipt images:
� Receipt 1: Hotel receipt � ?600.00 ILS (1 night near Ben Gurion)
� Receipt 2: Meal receipt � ?190.00 ILS (dinner + breakfast + lunch)
� Receipt 3: Taxi receipt � ?200.00 ILS (airport to hotel + hotel to airport)
� Receipt 4: Essential items � ?95.00 ILS (toiletries)

RECEIPT READER � OCR VALIDATION (RR-01):
Then the system processes uploaded receipts through OCR (Agentic Receipt Reader)
And the OCR engine extracts line items from each receipt:

Receipt 1 � Hotel:
� Line item: Hotel stay, 1 night � ?600.00 ILS
� Date: June 11, 2026
� Category: Hotel
� Within disruption window: YES ?
� Rate of day comparison: ?600 vs rate of day (Tel Aviv area) ? WITHIN range ?
� Nights: 1 (within 3-night max) ?
� Amount: ?600 < ?1,800 cap ?
� OCR Result: PASS ?

Receipt 2 � Meals:
� Line item 1: Dinner � ?85.00 ILS
� Line item 2: Breakfast � ?55.00 ILS
� Line item 3: Lunch � ?50.00 ILS
� Total meals: ?190.00 ILS
� Date: June 11-12, 2026
� Category: Meals
� Within disruption window: YES ?
� Threshold check: ?190 ? ?220 ( meal entitlement) ?
� OCR Result: PASS ?

Receipt 3 � Transport:
� Line item 1: Taxi airport?hotel � ?110.00 ILS
� Line item 2: Taxi hotel?airport � ?90.00 ILS
� Total transport: ?200.00 ILS
� Date: June 11-12, 2026
� Category: Transport
� Within disruption window: YES ?
� Threshold check: ?200 ? ?720 ?
� OCR Result: PASS ?

Receipt 4 � Essentials:
� Line item: Toiletry kit � ?95.00 ILS
� Date: June 11, 2026
� Category: Essentials
� Within disruption window: YES ?
� Threshold check: ?95 ? ?110 ?
� OCR Result: PASS ?

RECEIPT VALIDATION SUMMARY:
Then the system displays the OCR validation summary:
� Total receipts processed: 4
� Total line items extracted: 6
� Items PASSED: 6
� Items FLAGGED for agent review: 0
� Items FAILED: 0

EXPENSE BREAKDOWN:
� Hotel: ?600.00 ?
� Meals: ?190.00 ?
� Transport: ?200.00 ?
� Communication: ?0.00 (no receipt submitted)
� Parking: ?0.00 (no receipt submitted)
� Essentials: ?95.00 ?
� TOTAL APPROVED: ?1,085.00 ILS

CASE CREATION (GLOB-09):
Then the system creates a case in Case Services
And the case includes:
� DDS response code: SoC-ASL-EL-02
� Eligibility: ELIGIBLE
� Regime: ASL
� Currency: ILS (receipts in ILS � no conversion needed for threshold comparison)
� All approved line items with amounts
� Receipt images attached
� Fraud screening result: GREEN
� Note: Weather disruption (Code 77) � APPR would reject as uncontrollable (NE-08), but ASL does NOT check controllability ? ELIGIBLE (same as EU EL-02)
And the case reference number is provided to the passenger

Then the chatbot responds:
"Your claim has been submitted successfully. Here's a summary:
� Case Reference: [Case Number]
� Total claim amount: ?1,085.00 ILS
� Categories: Hotel (?600.00), Meals (?190.00), Transport (?200.00), Essentials (?95.00)

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
� Approved amount: ?1,085.00 ILS
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
Scenario: Claims Dashboard validation for SoC-ASL-EL-02 � ASL Eligible No Travel Stayed at Origin Cancelled
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Resolved"
  And the Itinerary shows Journey AC 084 TLV ? VDA as the claimed flight
  And the Flight Status is "CANCELLED"
  And the Eligibility section shows Journey = AC 084 TLV ? VDA
  And the Disruption Reason is "Weather (Code 77 � IRRELEVANT under ASL)"
  And the Delay Minutes is 1080 min (18 hours)
  And the Travel Status is "No Travel � Stayed at Origin (TLV)"
  And the Geographic Check is "PASSED ? (TLV ? VDA = Israel ? Israel)"
  And the Controllability is "NOT CHECKED"
  And the Cancellation Check is "CANCELLED ?"
  And the Departure Delay is "?2h (18 hours) ?"
  And the DDS Response Code is "SoC-ASL-EL-02"
  And the Fraud Screening is "CyberSource GREEN"
  And the Eligibility is "ELIGIBLE"
  And under APPR this would be SoC-APPR-NE-08 (NOT ELIGIBLE) and under EU SoC-EU-EL-02 (ELIGIBLE)
  And the Receipt Validator shows Hotel ?600.00 APPROVED
  And the Receipt Validator shows Meals ?190.00 APPROVED (??220)
  And the Receipt Validator shows Transport ?200.00 APPROVED
  And the Receipt Validator shows Essentials ?95.00 APPROVED (??110)
  And the Total Approved is ?1,085.00 ILS
  And the Items Flagged for Review is 0
  And the Final Status is "Resolved"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-ASL-EL-02 � ASL Eligible No Travel Stayed at Origin Cancelled
  Given the case SoC-ASL-EL-02 is determined as ELIGIBLE
  Then SOC payment is CASH ONLY
  And the route is AC 084 TLV ? VDA CANCELLED with 18h delay for 1 adult PY
  And ASL controllability is NOT checked
  And the approved receipts are Hotel ?600, Meals ?190, Taxi ?200, Essentials ?95 totalling ?1,085.00 ILS
  And the country of residence determines currency and payment method
  And currency conversion logging applies
  And the batch file is sent to Unifier and end-of-day report is generated
  And the Claims Dashboard shows ?1,085.00 ILS, Cash, payment method, status via talkback

EXPECTED RESULTS:
SoC-ASL-EL-02. ELIGIBLE. No travel (return), delay ?2h. Controllability NOT checked. Hotel: 2 rooms (per adult). Entitlements per  for 3 passengers. Full receipt + case flow.