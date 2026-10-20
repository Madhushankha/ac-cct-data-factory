Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from London to Toronto was delayed by about 6 hours and I had to buy food and pay for a hotel overnight. Can I get reimbursed for what I spent?"
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
� Flight: AC 849
� Route: London Heathrow (LHR) ? Toronto (YYZ)
� Date: June 1, 2026
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
Then the chatbot checks: Filing deadline for EU SOC per departing country
And the system calculates:
� Departing country: United Kingdom ? Limitation = 2,190 days (6 years)
� Days elapsed: Within limitation period ? PROCEED

Then the chatbot checks if there is triage data available? ? Yes

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

TRIP TRACER UI VALIDATIONS:
Then the tester opens Trip Tracer UI for PNR
Trip Overview:
? PNR: [PNR Code]
? TYPE: EMPLOYEE (non-revenue)
? ?? Trip Completed, Disruption Detected
? Single-segment trip LHR?YYZ on AC849 was delayed +6H 00M
? Regime: EU (LHR departure)
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 849, Route: LHR ? YYZ, Scheduled Dep: 01-Jun 19:00
? Current Itinerary � Flight: AC 849, Route: LHR ? YYZ, Status: ARRIVED LATE, Scheduled Dep: 19:00 ? Actual: 02-Jun 01:00, Delay: +6H 00M

Standards of Care (1):
? SOC section present
? PASSENGER: [Name] | STATUS: NOT_ELIGIBLE | BAND: DELAY_6_HOURS_OR_MORE | MEAL: � | ACCOMMODATION: � | GENERAL EXPENSES: � | EXPIRES: �
? NOT_ELIGIBLE reason: Employee booking (AC)

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: NOT ELIGIBLE
 EMPLOYEE CHECK � THIS IS THE KEY TEST:
� Passenger type check:
  - PNR booking type detected: EMPLOYEE (AC)
  - Office suffix: ES (employee standby) / OT / EP / EE / EC
  - Employee detected AFTER OTP authentication (not blocked upfront)
  - Revenue booking check: FAIL � employee booking (non-revenue)
  - Result: NOT ELIGIBLE � employees are not eligible under CCT

� Policy: "Air Canada employees are not eligible for claims under CCT, 
  but are eligible for bag use cases, as decided by Mohammed."
� Employee flow: "Employees receive a 'not eligible' response if they 
  attempt to claim under CCT."

DDS RESPONSE CODE = SoC-EU-NE-01

Then the chatbot checks which airline company is it ? AC

NOT ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "I've reviewed the details of your booking. Unfortunately, your booking is classified as an employee booking, which does not qualify for Standards of Care expense reimbursement under the applicable regulations. If you incurred expenses during this disruption, please contact your employee services team for guidance on available options."

DISPUTE OPTION (GenUC-15):
Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?"
� Agree
� Dispute
And the user selects "Agree"

NOTE ON DISPUTE PATH:
If the user had selected "Dispute":
? Case created with dispute flag
? Case sent to manual handling queue
? Agent reviews employee status and circumstances
? Employee remains not eligible for CCT but may be directed to 
   employee services or baggage claims if applicable

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-EU-NE-01 � AC Employee EU Not Eligible
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Closed � Not Eligible"
  And the Created date and Last Updated date are populated
  And the SLA countdown is tracking correctly
  And the Team assignment is correct
  And the Claimant Name is populated
  And the Claimant Type is "Employee (AC)"
  And the Authentication is "Pass"
  And the PNR is populated
  And the Booking Office ID is "Employee office suffix (ES/OT/EP/EE/EC)"
  And the Regime is "EU"
  And the Full Name is populated
  And the Tags include "Claimant", "Adult", and "Employee"
  And the Tier Status is "Employee"
  And the Itinerary shows Journey AC 849 LHR ? YYZ as the claimed flight
  And the Flight Status is "DELAYED (6 hours)"
  And the Eligibility section shows Journey = AC 849 LHR ? YYZ
  And the Flight Leg at Fault is AC 849
  And the Operating Carrier is AC
  And the Disruption Reason is "N/A (not evaluated � employee not eligible)"
  And the Delay Minutes is 360 min (6 hours)
  And the Travel Status is "Travelled (delayed)"
  And the Passenger Type is "EMPLOYEE (AC) � detected after OTP authentication"
  And the Revenue Booking is "NO � employee booking"
  And the Controllability is "NOT EVALUATED (employee not eligible regardless; EU doesn't check controllability anyway)"
  And the Employee Flow is "OTP completed ? Employee detected ? Not Eligible"
  And the DDS Response Code is "SoC-EU-NE-01"
  And the Policy is "Not eligible under CCT (Mohammed decision). Eligible for baggage only."
  And the Receipt Validator SOC Expense Line Items is "N/A (not reached)"
  And the Applicable Regimes SOC Amount is "N/A"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource is NOT triggered
  And the Dispute option is offered (GenUC-15)
  And the user selected "Agree"
  And the Eligibility on Claims Dashboard is "NOT ELIGIBLE" with no compensation record and no payout section
  And the Final Status is "Closed � Not Eligible"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-EU-NE-01 � AC Employee EU Not Eligible
  Given the case SoC-EU-NE-01 is determined as NOT ELIGIBLE
  Then no payment flow is triggered
  And no country of residence is asked
  And no compensation record is created
  And no batch file is dispatched
  And no receipt upload is triggered (SOC receipts only triggered for eligible cases)
  And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section

EXPECTED RESULTS:
System correctly identifies AC employee booking AFTER OTP authentication (not blocked at entry). Returns SoC-EU-NE-01. Displays NOT ELIGIBLE. Offers dispute option � if disputed, case created and sent to manual handling. No receipt upload triggered.