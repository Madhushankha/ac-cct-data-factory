Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I was on a connecting flight within Israel from Tel Aviv through Haifa to Eilat. My first leg was fine, but my second leg from Haifa to Eilat was cancelled because of a crew scheduling issue. I was stuck in Haifa for about 12 hours. I had to buy food, pay for a hotel, and take a taxi. Can I get reimbursed?"
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
� Date: June 12, 2026
� Segment 1: AC 090 TLV?HFA � Operated normally
� Segment 2: AC 091 HFA?VDA � CANCELLED (Crew Scheduling)
Is this the journey you'd like to check?"
And the user confirms "Yes"

Then the chatbot checks if there are more than 1 segment ? Yes (2 segments)

SEGMENT SELECTION (GenUC-18a):
Then the chatbot displays the segment(s) associated with the selected journey:
"Which segment was affected by the disruption?
� Segment 1: AC 090 TLV?HFA (Operated normally)
� Segment 2: AC 091 HFA?VDA (Cancelled)"
And the user selects "Segment 2: AC 091 HFA?VDA"

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + segment combination

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
? Multi-segment trip TLV?HFA?VDA � Segment 2 AC091 HFA?VDA cancelled due to crew shortage. Passenger stranded at HFA for 12 hours.
? Regime: ASL (TLV?HFA?VDA = all Israel)
? PASSENGERS: 1 � SEGMENTS: 2

Itinerary:
? Promised Itinerary � Seg 1: AC 090, TLV ? HFA | Seg 2: AC 091, HFA ? VDA
? Current Itinerary � Seg 1: AC 090, TLV ? HFA, Status: ON TIME | Seg 2: AC 091, HFA ? VDA, Status: CANCELLED

Standards of Care (1):
? SOC section present � SOC Segment: AC 091 HFA?VDA
? Departure Delay Code: 64 (Flight Crew Shortage) � NOT CHECKED (ASL does not evaluate controllability)
? Geographic Check: TLV?HFA?VDA = all Israel ? PASSED ?
? Cancellation: YES ? | SOC Segment Delay: 720 min (12h) ? ?2h ?
? PASSENGER: [Name] | STATUS: ELIGIBLE | BAND: DELAY_6_HOURS_OR_MORE | MEAL: ?220.00 | ACCOMMODATION: Rate of day (max ?1,800) | GENERAL EXPENSES: Transport ?720 + Comm ?110 + Parking ?180 + Essentials ?110 | EXPIRES: [date]
? CyberSource: GREEN

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: ELIGIBLE
? Total Approved: ?775.00 ILS (Hotel ?450 + Meals ?175 + Transport ?150)

DDS RESPONSE CODE = SoC-ASL-EL-06

Then the chatbot checks which airline company is it ? AC

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the system sends case data to CyberSource for fraud screening (behind the scenes)
And CyberSource returns: GREEN (no fraud indicators detected)
? PROCEED to eligible flow

ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your connecting flight AC 091 from Haifa to Eilat was cancelled due to a crew scheduling issue, and you were stranded in Haifa for approximately 12 hours. Under the applicable Israeli aviation regulations (ASL), you may be reimbursed for reasonable expenses incurred during this disruption."

ENTITLEMENT DISPLAY:
Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, ASL regime:
"Based on the length of your disruption (12 hours), you may be eligible for reimbursement in the following categories:
� Meals: up to ?220.00
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
� Receipt 1: Hotel receipt � ?450.00 ILS (1 night in Haifa)
� Receipt 2: Meal receipt � ?175.00 ILS (dinner + breakfast)
� Receipt 3: Taxi receipt � ?150.00 ILS (airport to hotel + hotel to airport)

RECEIPT READER � OCR VALIDATION (RR-01):
Then the system processes uploaded receipts through OCR (Agentic Receipt Reader)

Receipt 1 � Hotel:
� Line item: Hotel stay, 1 night � ?450.00 ILS
� Within disruption window: YES ? | Rate of day: WITHIN range ?
� Nights: 1 ? | Amount: ?450 < ?1,800 cap ? | OCR Result: PASS ?

Receipt 2 � Meals:
� Line item 1: Dinner � ?95.00 ILS | Line item 2: Breakfast � ?80.00 ILS
� Total meals: ?175.00 ILS | Within disruption window: YES ?
� Threshold check: ?175 ? ?220 ? | OCR Result: PASS ?

Receipt 3 � Transport:
� Line item 1: Taxi to hotel � ?80.00 ILS | Line item 2: Taxi to airport � ?70.00 ILS
� Total transport: ?150.00 ILS | Within disruption window: YES ?
� Threshold check: ?150 ? ?720 ? | OCR Result: PASS ?

RECEIPT VALIDATION SUMMARY:
� Total receipts: 3 | Line items: 5 | PASSED: 5 | FLAGGED: 0 | FAILED: 0

EXPENSE BREAKDOWN:
� Hotel: ?450.00 ? | Meals: ?175.00 ? | Transport: ?150.00 ?
� Communication: ?0.00 | Parking: ?0.00 | Essentials: ?0.00
� TOTAL APPROVED: ?775.00 ILS

CASE CREATION (GLOB-09):
Then the system creates a case with all approved line items, receipt images, fraud screening GREEN
And the case reference number is provided to the passenger

Then the chatbot responds:
"Your claim has been submitted successfully. Here's a summary:
� Case Reference: [Case Number]
� Total claim amount: ?775.00 ILS
� Categories: Hotel (?450.00), Meals (?175.00), Transport (?150.00)

You will receive a confirmation email shortly."

NOTIFICATION (Adobe) + CLAIMS PAYMENT FLOW:
Then the system triggers eligible confirmation email
Then the system initiates payment processing ? ?775.00 ILS ? country of residence currency
Then the chatbot collects payment details and payment is initiated

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-ASL-EL-06 � ASL Eligible Incomplete Journey Crew Shortage
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Resolved"
  And the Itinerary shows Journey AC 090 ? AC 091 TLV ? HFA ? VDA with claim filed for segment AC 091 HFA ? VDA
  And Segment 1 AC 090 TLV ? HFA is "Operated normally"
  And Segment 2 AC 091 HFA ? VDA is "CANCELLED (Crew Scheduling) � Disrupted segment"
  And the Eligibility section shows Journey = AC 090 ? AC 091 TLV ? HFA ? VDA
  And the Flight Leg at Fault is AC 091 HFA ? VDA
  And the Disruption Reason is "64 (Flight Crew Shortage) � IRRELEVANT under ASL"
  And the Delay Minutes is 720 min (12 hours)
  And the Travel Status is "No Travel � Incomplete Journey (stranded at HFA)"
  And the Geographic Check is "PASSED ? (TLV ? HFA ? VDA = all Israel)"
  And the Controllability is "NOT CHECKED"
  And the Cancellation Check is "CANCELLED ?"
  And the Departure Delay is "?2h (12 hours) ?"
  And the DDS Response Code is "SoC-ASL-EL-06"
  And the Fraud Screening is "CyberSource GREEN"
  And the Eligibility is "ELIGIBLE"
  And the Receipt Validator shows Hotel ?450.00 APPROVED
  And the Receipt Validator shows Meals ?175.00 APPROVED (??220)
  And the Receipt Validator shows Transport ?150.00 APPROVED
  And the Total Approved is ?775.00 ILS
  And the Items Flagged for Review is 0
  And the Final Status is "Resolved"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-ASL-EL-06 � ASL Eligible Incomplete Journey Crew Shortage
  Given the case SoC-ASL-EL-06 is determined as ELIGIBLE
  Then SOC payment is CASH ONLY
  And the route is AC 090 ? AC 091 TLV ? HFA ? VDA (stranded at HFA) with delay 720 min (12 hrs) for 1 adult PY
  And ASL controllability is NOT checked
  And the entitlements for 1 adult PY no ACR are Meals ?220, Hotel rate of day 3 nights max ?1,800 cap, Transport ?720, Communication ?110, Parking ?180 1 day max, Essentials ?110
  And the approved receipts are Hotel ?450 (1 night in Haifa vs ?1,800 PASS), Meals ?175 (vs ?220 PASS), Taxi ?150 (vs ?720 PASS) totalling ?775.00 ILS
  And the country of residence determines currency and payment method
  And currency conversion logging includes ILS amount, CAD equivalent, exchange rate, source, and date
  And ?775 (~$280 CAD) is less than $500 so no approval is needed
  And the batch file is sent to Unifier and end-of-day report is generated
  And the Claims Dashboard shows ?775.00 ILS, Cash, payment method, status via talkback

EXPECTED RESULTS:
SoC-ASL-EL-06. ELIGIBLE. No travel (incomplete), flight cancelled. Controllability NOT checked. Full receipt + case flow.