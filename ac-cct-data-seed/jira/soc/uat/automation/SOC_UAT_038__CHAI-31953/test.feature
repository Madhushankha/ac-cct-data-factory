Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I was on a connecting flight from London through Frankfurt to Toronto. My first leg was fine, but I got stuck in Frankfurt. The airline says my connecting flight from Frankfurt to Toronto wasn't cancelled � it just left without me because I arrived late from the first flight. I had to buy meals and stay overnight. Can I get reimbursed?"
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
� Flight: AC 849 ? AC 847
� Route: London Heathrow (LHR) ? Frankfurt (FRA) ? Toronto (YYZ)
� Date: June 6, 2026
� Segment 1: AC 849 LHR?FRA � Operated normally
� Segment 2: AC 847 FRA?YYZ � OPERATED (passenger did not board)
Is this the journey you'd like to check?"
And the user confirms "Yes"

Then the chatbot checks if there are more than 1 segment ? Yes (2 segments)

SEGMENT SELECTION (GenUC-18a):
Then the chatbot displays the segment(s) associated with the selected journey:
"Which segment was affected by the disruption?
� Segment 1: AC 849 LHR?FRA (Operated normally)
� Segment 2: AC 847 FRA?YYZ (Operated � passenger did not board)"
And the user selects "Segment 2: AC 847 FRA?YYZ"

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + segment combination

72-HOUR CHECK:
Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes
Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for EU SOC per departing country
And the system calculates:
� Departing country (of journey origin): United Kingdom ? Limitation = 2,190 days (6 years)
� Days elapsed: 2 days ? Within limitation period ? PROCEED

Then the chatbot checks if there is triage data available? ? Yes

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:
TRIP TRACER UI VALIDATIONS:
Then the tester opens Trip Tracer UI for PNR
Trip Overview:
? PNR: [PNR Code]
? TYPE: REVENUE
? ?? Trip Not Completed � Passenger stranded at connection
? Multi-segment trip LHR?FRA?YYZ � Segment 2 AC847 FRA?YYZ operated (passenger did not board � missed connection). Passenger stranded at FRA.
? Regime: EU (LHR departure)
? PASSENGERS: 1 � SEGMENTS: 2

Itinerary:
? Promised Itinerary � Seg 1: AC 849, LHR ? FRA, Dep: 06-Jun 08:00 | Seg 2: AC 847, FRA ? YYZ, Dep: 06-Jun 14:00
? Current Itinerary � Seg 1: AC 849, LHR ? FRA, Status: ON TIME | Seg 2: AC 847, FRA ? YYZ, Status: OPERATED (passenger did not board)

Standards of Care (1):
? SOC section present � SOC Segment: AC 847 FRA?YYZ
? Flight Status: OPERATED (not cancelled � departed without passenger)
? PASSENGER: [Name] | STATUS: NOT_ELIGIBLE | BAND: � | MEAL: � | ACCOMMODATION: � | GENERAL EXPENSES: � | EXPIRES: �
? NOT_ELIGIBLE reason: Connecting flight operated � not cancelled. Dispute relevant if missed connection was caused by airline delay on first leg.

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: NOT ELIGIBLE
DDS RESPONSE CODE = SoC-EU-NE-14

Then the chatbot checks which airline company is it ? AC

NOT ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "I've reviewed the details of your flight. Our records show that your connecting flight AC 847 from Frankfurt to Toronto operated and was not cancelled. Since the connecting flight was not recorded as a cancellation, expense reimbursement is not available under the applicable EU regulations for this journey. If you believe you missed your connection due to a delay on a previous Air Canada flight, you may dispute this decision and our team will review your case manually."

DISPUTE OPTION (GenUC-15):
Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?"
� Agree
� Dispute
And the user selects "Agree"

NOTE ON DISPUTE PATH (relevant for missed connections):
If the user had selected "Dispute":
? Case created with dispute flag
? Case sent to manual handling queue
? Agent investigates:
  * Was first leg delayed, causing missed connection?
  * Was minimum connection time (MCT) violated?
  * Did the airline rebook the passenger?
  * Should the missed connection be treated as a de facto cancellation?
? Agent can override to ELIGIBLE if misconnection was airline's fault

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-EU-NE-14 � Flight Operated Incomplete Journey Not Eligible
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Closed � Not Eligible"
  And the Created date and Last Updated date are populated
  And the SLA countdown is tracking correctly
  And the Claimant Name is populated
  And the Authentication is "Pass"
  And the PNR is populated
  And the Regime is "EU"
  And the Full Name is populated
  And the Tags include "Claimant" and "Adult"
  And the Itinerary shows Journey AC 849 ? AC 847 LHR ? FRA ? YYZ with claim filed for segment AC 847 FRA ? YYZ
  And Segment 1 AC 849 LHR ? FRA is "Operated normally"
  And Segment 2 AC 847 FRA ? YYZ is "OPERATED (not cancelled � passenger did not board)"
  And the Eligibility section shows Journey = AC 849 ? AC 847 LHR ? FRA ? YYZ
  And the Flight Leg at Fault is "N/A (flight operated � not cancelled in system)"
  And the Operating Carrier is AC
  And the Disruption Reason is "N/A (flight not recorded as cancelled)"
  And the Delay Minutes is "N/A"
  And the Cancellation Check is "NOT CANCELLED � flight operated (AC 847 departed without passenger)"
  And the Travel Status is "No Travel � Incomplete Journey (stranded at FRA, not cancelled)"
  And the Passenger Type is "Regular"
  And the Geographic Check is "PASSED ? (LHR = UK origin)"
  And the Controllability is "NOT CHECKED (EU regime does not evaluate for SOC)"
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-EU-NE-14"
  And the Dispute Note is "Passenger may dispute if missed connection was caused by airline delay on first leg � agent should investigate MCT and first leg timing"
  And the connecting flight operated normally so the passenger missed it or could not board which is different from NE-11 where the connecting flight WAS cancelled but delay was <2h
  And the Receipt Validator SOC Expense Line Items is "N/A (not reached)"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource is NOT triggered
  And the Dispute option is offered (GenUC-15)
  And the user selected "Agree"
  And the Final Status is "Closed � Not Eligible"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-EU-NE-14 � Flight Operated Incomplete Journey Not Eligible
  Given the case SoC-EU-NE-14 is determined as NOT ELIGIBLE
  Then no payment flow is triggered
  And no country of residence is asked
  And no compensation record is created
  And no batch file is dispatched
  And no receipt upload is triggered (SOC receipts only triggered for eligible cases)
  And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section

EXPECTED RESULTS:
SoC-EU-NE-14. NOT ELIGIBLE. No travel (incomplete),  not cancelled under EU.