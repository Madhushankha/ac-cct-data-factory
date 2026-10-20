Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I boarded my flight from Tel Aviv to Eilat, but we ended up back at Ben Gurion airport. The airline says the flight wasn't officially cancelled though � it technically operated. I had to pay for meals and transportation. Can I get reimbursed?"
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
� Date: June 6, 2026
� Status: OPERATED � Flight departed and arrived (passenger returned to origin)
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
� Days elapsed: 3 days ? Within limitation period ? PROCEED

Then the chatbot checks if there is triage data available? ? Yes

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:
TRIP TRACER UI VALIDATIONS:
Then the tester opens Trip Tracer UI for PNR
Trip Overview:
? PNR: [PNR Code]
? TYPE: REVENUE
? ?? Trip Not Completed � Passenger returned to origin
? Single-segment trip TLV?VDA on AC084 � flight operated (departed and returned to TLV). System records as "operated" not "cancelled."
? Regime: ASL (TLV?VDA = Israel?Israel)
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 084, Route: TLV ? VDA, Scheduled Dep: 10-Jun 16:00
? Current Itinerary � Flight: AC 084, Route: TLV ? VDA, Status: OPERATED (departed and returned to origin � not recorded as cancelled)

Standards of Care (1):
? SOC section present
? Flight Status: OPERATED (not cancelled in system � departed + returned)
? Geographic Check: TLV?VDA = Israel?Israel ? PASSED ?
? PASSENGER: [Name] | STATUS: NOT_ELIGIBLE | BAND: � | MEAL: � | ACCOMMODATION: � | GENERAL EXPENSES: � | EXPIRES: �
? NOT_ELIGIBLE reason: Flight not recorded as cancelled. Dispute particularly relevant � agent may reclassify as de facto cancellation.

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: NOT ELIGIBLE
DDS RESPONSE CODE = SoC-ASL-NE-13

Then the chatbot checks which airline company is it ? AC

NOT ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "I've reviewed the details of your flight. Our records show that flight AC 084 from Tel Aviv to Eilat operated and was not recorded as cancelled. Since the flight was not recorded as a cancellation in our system, expense reimbursement is not available under the applicable Israeli aviation regulations (ASL) for this journey. If you believe this assessment is incorrect � for example, if your flight was diverted back and you never reached your destination � you may dispute this decision and our team will review your case manually."

DISPUTE OPTION (GenUC-15):
Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?"
� Agree
� Dispute
And the user selects "Agree"

NOTE ON DISPUTE PATH (particularly relevant for this case):
If the user had selected "Dispute":
? Case created with dispute flag
? Case sent to manual handling queue
? Agent investigates:
  * Was the flight diverted back to origin?
  * Should this be reclassified as a de facto cancellation?
  * Did the passenger ultimately reach their destination?
  * What was the actual disruption cause?
? Agent can override to ELIGIBLE if diversion qualifies as cancellation

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-ASL-NE-13 � Flight Operated Returned to Origin ASL Not Eligible
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Closed � Not Eligible"
  And the Created date and Last Updated date are populated
  And the SLA countdown is tracking correctly
  And the Claimant Name is populated
  And the Authentication is "Pass"
  And the PNR is populated
  And the Regime is "ASL"
  And the Full Name is populated
  And the Tags include "Claimant" and "Adult"
  And the Itinerary shows Journey AC 084 TLV ? VDA as the claimed flight
  And the Flight Status is "OPERATED (not cancelled � departed and returned to origin)"
  And the Eligibility section shows Journey = AC 084 TLV ? VDA
  And the Flight Leg at Fault is "N/A (flight operated � not cancelled in system)"
  And the Operating Carrier is AC
  And the Disruption Reason is "N/A (flight not recorded as cancelled)"
  And the Delay Minutes is "N/A"
  And the Cancellation Check is "NOT CANCELLED � flight operated (departed + returned)"
  And the Travel Status is "No Travel � Returned to Origin (TLV, not cancelled in system)"
  And the Passenger Type is "Regular"
  And the Geographic Check is "PASSED ? (TLV ? VDA = Israel ? Israel)"
  And the Controllability is "NOT CHECKED (ASL regime does not evaluate for SOC)"
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-ASL-NE-13"
  And the Dispute Note is "Passenger may dispute � agent should investigate whether diversion back to origin should be reclassified as de facto cancellation"
  And although passenger returned to origin (same outcome as cancellation from passenger's perspective) the system records flight as "operated" so the dispute option is particularly important for this scenario
  And the Receipt Validator SOC Expense Line Items is "N/A (not reached)"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource is NOT triggered
  And the Dispute option is offered (GenUC-15)
  And the user selected "Agree"
  And the Final Status is "Closed � Not Eligible"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-ASL-NE-13 � Flight Operated Returned to Origin ASL Not Eligible
  Given the case SoC-ASL-NE-13 is determined as NOT ELIGIBLE
  Then no payment flow is triggered
  And no country of residence is asked
  And no compensation record is created
  And no batch file is dispatched
  And no receipt upload is triggered (SOC receipts only triggered for eligible cases)
  And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section

EXPECTED RESULTS:
SoC-ASL-NE-13. NOT ELIGIBLE. No travel (return),  not cancelled under ASL.