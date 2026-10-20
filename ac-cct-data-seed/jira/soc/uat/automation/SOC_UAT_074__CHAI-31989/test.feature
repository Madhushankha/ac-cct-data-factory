Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My Air Canada flight from Tel Aviv to Eilat was delayed by about 8 hours because of a crew scheduling issue. I had to buy food, pay for a hotel overnight, and take a taxi. Can I get reimbursed?"
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
� Date: June 14, 2026
� Departure Delay: 8 hours
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
? Single-segment trip TLV?VDA on AC084 was delayed +7H 00M (note: prereqs say 7h/420 min, chatbot says 8h � use prereqs: 7h) due to weather (uncontrollable � NOT CHECKED under ASL)
? Regime: ASL (TLV?VDA = Israel?Israel)
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 084, Route: TLV ? VDA, Scheduled Dep: 22-Jun 16:00
? Current Itinerary � Flight: AC 084, Route: TLV ? VDA, Status: ARRIVED LATE, Scheduled Dep: 16:00 ? Actual: 23:00, Delay: +7H 00M

Standards of Care (1):
? SOC section present
? Departure Delay Code: 77 (Weather) � NOT CHECKED (ASL does not evaluate controllability)
? Geographic Check: TLV?VDA = Israel?Israel ? PASSED ?
? PASSENGER: [Name] | STATUS: ELIGIBLE | BAND: DELAY_6_HOURS_OR_MORE | MEAL: ?110.00 | ACCOMMODATION: Rate of day (max ?1,800) | GENERAL EXPENSES: Transport ?720 + Comm ?110 + Parking ?180 + Essentials ?110 | EXPIRES: [date]
? CyberSource: GREEN

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: ELIGIBLE
? Total Approved: ?830.00 ILS (Hotel ?520 + Meals ?95 + Transport ?175 + Comm ?40)

DDS RESPONSE CODE = SoC-ASL-EL-07

Then the chatbot checks which airline company is it ? AC

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the system sends case data to CyberSource for fraud screening (behind the scenes)
And CyberSource returns: GREEN (no fraud indicators detected)
? PROCEED to eligible flow

ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 084 from Tel Aviv to Eilat was delayed by approximately 8 hours due to a crew scheduling issue. Under the applicable Israeli aviation regulations (ASL), you may be reimbursed for reasonable expenses incurred during this disruption."

ENTITLEMENT DISPLAY:
Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, ASL regime:
"Based on the length of your disruption (8 hours), you may be eligible for reimbursement in the following categories:
� Meals: up to ?110.00
� Hotel accommodation: Rate of day (up to 3 nights, ?1,800 maximum)
� Ground transportation: up to ?720.00
� Communication: up to ?110.00
� Parking: up to ?180.00 (1 day maximum)
� Essential items: up to ?110.00

Please note that all expenses must have been incurred during the disruption period and supported by valid receipts."

RECEIPT UPLOAD � WELCOME BACK FLOW:
Then the chatbot responds:
"To process your claim, I'll need you to upload your receipts."
And the chatbot displays the receipt upload interface
And the user uploads receipt images:
� Receipt 1: Hotel receipt � ?520.00 ILS (1 night)
� Receipt 2: Meal receipt � ?95.00 ILS (dinner + breakfast)
� Receipt 3: Taxi receipt � ?175.00 ILS (airport to hotel + return)
� Receipt 4: Communication � ?40.00 ILS (Wi-Fi + phone calls)

RECEIPT READER � OCR VALIDATION (RR-01):
Then the system processes uploaded receipts through OCR (Agentic Receipt Reader)

Receipt 1 � Hotel:
� Line item: Hotel stay, 1 night � ?520.00 ILS
� Within disruption window: YES ? | Rate of day: WITHIN range ?
� Nights: 1 ? | Amount: ?520 < ?1,800 cap ? | OCR Result: PASS ?

Receipt 2 � Meals:
� Line item 1: Dinner � ?55.00 ILS | Line item 2: Breakfast � ?40.00 ILS
� Total meals: ?95.00 ILS | Within disruption window: YES ?
� Threshold check: ?95 ? ?110 ? | OCR Result: PASS ?

Receipt 3 � Transport:
� Line item 1: Taxi to hotel � ?95.00 ILS | Line item 2: Taxi to airport � ?80.00 ILS
� Total transport: ?175.00 ILS | Within disruption window: YES ?
� Threshold check: ?175 ? ?720 ? | OCR Result: PASS ?

Receipt 4 � Communication:
� Line item 1: Wi-Fi � ?25.00 ILS | Line item 2: Phone calls � ?15.00 ILS
� Total communication: ?40.00 ILS | Within disruption window: YES ?
� Threshold check: ?40 ? ?110 ? | OCR Result: PASS ?

RECEIPT VALIDATION SUMMARY:
� Total receipts: 4 | Line items: 7 | PASSED: 7 | FLAGGED: 0 | FAILED: 0

EXPENSE BREAKDOWN:
� Hotel: ?520.00 ? | Meals: ?95.00 ? | Transport: ?175.00 ? | Communication: ?40.00 ?
� Parking: ?0.00 | Essentials: ?0.00
� TOTAL APPROVED: ?830.00 ILS

CASE CREATION (GLOB-09):
Then the system creates a case with all approved line items, receipt images, fraud screening GREEN
And the case reference number is provided to the passenger

Then the chatbot responds:
"Your claim has been submitted successfully. Here's a summary:
� Case Reference: [Case Number]
� Total claim amount: ?830.00 ILS
� Categories: Hotel (?520.00), Meals (?95.00), Transport (?175.00), Communication (?40.00)

You will receive a confirmation email shortly."

NOTIFICATION (Adobe) + CLAIMS PAYMENT FLOW:
Then the system triggers eligible confirmation email
Then the system initiates payment processing ? ?830.00 ILS ? country of residence currency
Then the chatbot collects payment details and payment is initiated

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-ASL-EL-07 � ASL Eligible Travel Completed Crew Scheduling
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Resolved"
  And the Itinerary shows Journey AC 084 TLV ? VDA as the claimed flight
  And the Flight Status is "DELAYED (8 hours)"
  And the Eligibility section shows Journey = AC 084 TLV ? VDA
  And the Flight Leg at Fault is AC 084
  And the Operating Carrier is AC
  And the Disruption Reason is "Crew Scheduling (Code 41 � IRRELEVANT under ASL)"
  And the Delay Minutes is 480 min (8 hours)
  And the Travel Status is "Travelled (delayed Departure)"
  And the Geographic Check is "PASSED ? (TLV ? VDA = Israel ? Israel)"
  And the Controllability is "NOT CHECKED"
  And the Overnight Eligible is "YES"
  And the DDS Response Code is "SoC-ASL-EL-07"
  And the Fraud Screening is "CyberSource GREEN"
  And the Eligibility is "ELIGIBLE"
  And under APPR this would be SoC-APPR-EL-08 (also ELIGIBLE � crew is controllable) and both regimes agree for controllable disruptions
  And the Receipt Validator shows Hotel ?520.00 APPROVED
  And the Receipt Validator shows Meals ?95.00 APPROVED (??110)
  And the Receipt Validator shows Transport ?175.00 APPROVED
  And the Receipt Validator shows Communication ?40.00 APPROVED (??110)
  And the Total Approved is ?830.00 ILS
  And the Items Flagged for Review is 0
  And the Final Status is "Resolved"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-ASL-EL-07 � ASL Eligible Travel Completed Crew Scheduling
  Given the case SoC-ASL-EL-07 is determined as ELIGIBLE
  Then SOC payment is CASH ONLY
  And the route is AC 084 TLV ? VDA with delay 480 min (8 hrs) for 1 adult PY
  And ASL controllability is NOT checked
  And the entitlements for 1 adult PY no ACR are Meals ?110, Hotel rate of day 3 nights max ?1,800 cap, Transport ?720, Communication ?110, Parking ?180, Essentials ?110
  And the approved receipts are Hotel ?520 (vs ?1,800 PASS), Meals ?95 (vs ?110 PASS), Taxi ?175 (vs ?720 PASS), Comm ?40 (vs ?110 PASS) totalling ?830.00 ILS
  And the country of residence determines currency and payment method
  And currency conversion logging includes ILS amount, CAD equivalent, exchange rate, source, and date
  And ?830 (~$300 CAD) is less than $500 so no approval is needed
  And the batch file is sent to Unifier and end-of-day report is generated
  And the Claims Dashboard shows ?830.00 ILS, Cash, payment method, status via talkback

EXPECTED RESULTS:
SoC-ASL-EL-07. ELIGIBLE. Transit delay ?2h (7 hours,  category). Controllability NOT checked � same behavior as EU regime. Same weather scenario under APPR with regular pax = NOT ELIGIBLE (NE-07). Under ASL = ELIGIBLE regardless of disruption type. Entitlements in ILS. Full receipt + case flow.