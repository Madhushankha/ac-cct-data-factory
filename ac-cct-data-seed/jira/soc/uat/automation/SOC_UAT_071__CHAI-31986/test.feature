Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Tel Aviv to Eilat was cancelled due to an air traffic control restriction and I never made it to my destination. I was stuck at Ben Gurion airport for about 14 hours. I had to buy meals, pay for a hotel, and take a taxi. Can I get reimbursed?"
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
? Single-segment trip TLV?VDA on AC084 was cancelled due to ATC restriction � passenger stayed at origin (TLV) for 14 hours
? Regime: ASL (TLV?VDA = Israel?Israel)
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 084, Route: TLV ? VDA, Scheduled Dep: 20-Jun 16:00
? Current Itinerary � Flight: AC 084, Route: TLV ? VDA, Status: CANCELLED

Standards of Care (1):
? SOC section present
? Departure Delay Code: 72 (ATC Restriction) � NOT CHECKED (ASL does not evaluate controllability)
? Geographic Check: TLV?VDA = Israel?Israel ? PASSED ?
? Cancellation: YES ? | SOC Segment Delay: 840 min (14h) ? ?2h ?
? PASSENGER: [Name] | STATUS: ELIGIBLE | BAND: DELAY_6_HOURS_OR_MORE | MEAL: ?220.00 | ACCOMMODATION: Rate of day (max ?1,800) | GENERAL EXPENSES: Transport ?720 + Comm ?110 + Parking ?180 + Essentials ?110 | EXPIRES: [date]
? CyberSource: GREEN

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: ELIGIBLE
? Total Approved: ?960.00 ILS (Hotel ?580 + Meals ?185 + Transport ?195)

DDS RESPONSE CODE = SoC-ASL-EL-04

Then the chatbot checks which airline company is it ? AC

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger)
And CyberSource evaluates the claim
And CyberSource returns: GREEN (no fraud indicators detected)
? PROCEED to eligible flow

ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 084 from Tel Aviv to Eilat was cancelled and you were unable to travel for approximately 14 hours. Under the applicable Israeli aviation regulations (ASL), you may be reimbursed for reasonable expenses incurred during this disruption."

ENTITLEMENT DISPLAY:
Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, ASL regime:
"Based on the length of your disruption (14 hours), you may be eligible for reimbursement in the following categories:
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
� Receipt 1: Hotel receipt � ?580.00 ILS (1 night near Ben Gurion)
� Receipt 2: Meal receipt � ?185.00 ILS (dinner + breakfast + lunch)
� Receipt 3: Taxi receipt � ?195.00 ILS (airport to hotel + hotel to airport)

RECEIPT READER � OCR VALIDATION (RR-01):
Then the system processes uploaded receipts through OCR (Agentic Receipt Reader)
And the OCR engine extracts line items from each receipt:

Receipt 1 � Hotel:
� Line item: Hotel stay, 1 night � ?580.00 ILS
� Date: June 11, 2026
� Category: Hotel
� Within disruption window: YES ?
� Rate of day comparison: ?580 vs rate of day (Tel Aviv area) ? WITHIN range ?
� Nights: 1 (within 3-night max) ?
� Amount: ?580 < ?1,800 cap ?
� OCR Result: PASS ?

Receipt 2 � Meals:
� Line item 1: Dinner � ?80.00 ILS
� Line item 2: Breakfast � ?55.00 ILS
� Line item 3: Lunch � ?50.00 ILS
� Total meals: ?185.00 ILS
� Date: June 11-12, 2026
� Category: Meals
� Within disruption window: YES ?
� Threshold check: ?185 ? ?220 ( meal entitlement) ?
� OCR Result: PASS ?

Receipt 3 � Transport:
� Line item 1: Taxi airport?hotel � ?105.00 ILS
� Line item 2: Taxi hotel?airport � ?90.00 ILS
� Total transport: ?195.00 ILS
� Date: June 11-12, 2026
� Category: Transport
� Within disruption window: YES ?
� Threshold check: ?195 ? ?720 ?
� OCR Result: PASS ?

RECEIPT VALIDATION SUMMARY:
Then the system displays the OCR validation summary:
� Total receipts processed: 3
� Total line items extracted: 5
� Items PASSED: 5
� Items FLAGGED for agent review: 0
� Items FAILED: 0

EXPENSE BREAKDOWN:
� Hotel: ?580.00 ?
� Meals: ?185.00 ?
� Transport: ?195.00 ?
� Communication: ?0.00 (no receipt submitted)
� Parking: ?0.00 (no receipt submitted)
� Essentials: ?0.00 (no receipt submitted)
� TOTAL APPROVED: ?960.00 ILS

CASE CREATION (GLOB-09):
Then the system creates a case in Case Services
And the case includes:
� DDS response code: SoC-ASL-EL-04
� Eligibility: ELIGIBLE
� Regime: ASL
� Currency: ILS
� All approved line items with amounts
� Receipt images attached
� Fraud screening result: GREEN
� Note: ATC restriction (Code 72) � APPR would reject as uncontrollable (NE-08), but ASL does NOT check controllability ? ELIGIBLE
And the case reference number is provided to the passenger

Then the chatbot responds:
"Your claim has been submitted successfully. Here's a summary:
� Case Reference: [Case Number]
� Total claim amount: ?960.00 ILS
� Categories: Hotel (?580.00), Meals (?185.00), Transport (?195.00)

You will receive a confirmation email shortly with your case details and next steps."

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe
And an eligible confirmation email is sent to the passenger at t***@gmail.com

CLAIMS PAYMENT FLOW:
Then the system initiates payment processing
And Case Services calculates:
� Approved amount: ?960.00 ILS
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
Scenario: Claims Dashboard validation for SoC-ASL-EL-04 � ASL Eligible ATC Restriction Cancelled
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Resolved"
  And the Itinerary shows Journey AC 084 TLV ? VDA as the claimed flight
  And the Flight Status is "CANCELLED"
  And the Eligibility section shows Journey = AC 084 TLV ? VDA
  And the Disruption Reason is "ATC Restriction (Code 72 � IRRELEVANT under ASL)"
  And the Delay Minutes is 840 min (14 hours)
  And the Travel Status is "No Travel � Stayed at Origin (TLV)"
  And the Geographic Check is "PASSED ? (TLV ? VDA = Israel ? Israel)"
  And the Controllability is "NOT CHECKED"
  And the Cancellation Check is "CANCELLED ?"
  And the Departure Delay is "?2h (14 hours) ?"
  And the DDS Response Code is "SoC-ASL-EL-04"
  And the Fraud Screening is "CyberSource GREEN"
  And the Eligibility is "ELIGIBLE"
  And under APPR this would be SoC-APPR-NE-08 (NOT ELIGIBLE � ATC is uncontrollable)
  And this tests a DIFFERENT uncontrollable code (72 vs 77 in EL-02) to ensure ASL doesn't accidentally check controllability
  And the Receipt Validator shows Hotel ?580.00 APPROVED
  And the Receipt Validator shows Meals ?185.00 APPROVED (??220)
  And the Receipt Validator shows Transport ?195.00 APPROVED
  And the Total Approved is ?960.00 ILS
  And the Items Flagged for Review is 0
  And the Final Status is "Resolved"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-ASL-EL-04 � ASL Eligible ATC Restriction Cancelled
  Given the case SoC-ASL-EL-04 is determined as ELIGIBLE
  Then SOC payment is CASH ONLY
  And the route is AC 084 TLV ? VDA CANCELLED with 14h delay for 1 adult PY
  And the approved receipts are Hotel ?580, Meals ?185, Taxi ?195 totalling ?960.00 ILS
  And the country of residence determines currency and payment method
  And the Comp Status is "Sent for issuance"
  And the Claims Dashboard shows ?960.00 ILS, Cash, payment method, status via talkback

EXPECTED RESULTS:
SoC-ASL-EL-04. ELIGIBLE. No travel (origin), flight cancelled. Controllability NOT checked. Full receipt + case flow. Entitlements per  category.