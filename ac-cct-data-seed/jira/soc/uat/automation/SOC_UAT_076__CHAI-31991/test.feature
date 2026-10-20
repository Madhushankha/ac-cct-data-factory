Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My Air Canada flight from Toronto to Vancouver was delayed by about 7 hours because of bad weather. I had to buy food and pay for a hotel. Can I get reimbursed?"
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
� Flight: AC 301
� Route: Toronto (YYZ) ? Vancouver (YVR)
� Date: June 1, 2026
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
Then the chatbot checks: Filing deadline for APPR SOC per province
And the system calculates:
� Origin: YYZ (Ontario) ? Limitation = 730 days
� Destination: YVR (British Columbia) ? Limitation = 1,095 days
� Days elapsed: 8 days ? Within limitation period ? PROCEED

Then the chatbot checks if there is triage data available? ? Yes

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:
TRIP TRACER UI VALIDATIONS:
Then the tester opens Trip Tracer UI for PNR
Trip Overview:
? PNR: [PNR Code]
? TYPE: REVENUE
? ?? Trip Completed, Disruption Detected � DISPUTED ? OVERRIDE PENDING
? Single-segment trip YYZ?YVR on AC301 was delayed +7H 00M due to weather (uncontrollable)
? Regime: APPR
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 301, Route: YYZ ? YVR, Scheduled Dep: 25-Jun 08:00
? Current Itinerary � Flight: AC 301, Route: YYZ ? YVR, Status: ARRIVED LATE, Scheduled Dep: 08:00 ? Actual: 14:00, Delay: +7H 00M (note: prereqs say 6h/360 min, chatbot says 7h � use chatbot flow)

Standards of Care (1):
? SOC section present
? Departure Delay Code: 77 (Weather) � Uncontrollable
? Original DDS: SoC-APPR-NE-07 (NOT ELIGIBLE � weather)
? PASSENGER: [Name] | STATUS: NOT_ELIGIBLE (original) ? DISPUTED ? OVERRIDE PENDING
? Dispute Flag: YES
? Override Status: PENDING � agent investigating delay code accuracy
? CyberSource: NOT triggered (not eligible / override pending)

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: DISPUTED � Override Pending
? Case in manual handling queue � awaiting agent override decision
? No payment initiated | No Welcome Back email sent

DDS RESPONSE CODE = SoC-APPR-NE-07

Then the chatbot checks which airline company is it ? AC

NOT ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "I've reviewed the details of your flight. Unfortunately, your flight AC 301 from Toronto to Vancouver was delayed due to weather conditions, which is classified as outside the airline's control. Under the applicable Canadian regulations (APPR), expense reimbursement is not available for disruptions caused by factors beyond the airline's control."

DISPUTE OPTION (GenUC-15):
Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?"
� Agree
� Dispute
And the user selects "Dispute"

 DISPUTE FLOW � THIS IS THE KEY TEST:
Then the chatbot responds: "We understand. Your dispute has been recorded and a case has been created for our team to review manually. You will receive an update once our team has completed their review."

CASE CREATION WITH DISPUTE FLAG:
Then the system creates a case in Case Services
And the case includes:
� DDS response code: SoC-APPR-NE-07
� Original eligibility: NOT ELIGIBLE
� Dispute flag: YES 
� Dispute reason: Passenger disputes weather classification
� Status: DISPUTED � Pending Override Review
� Regime: APPR
� All triage data attached
And the case is assigned to the manual handling queue (NOT fraud queue)
And the case reference number is provided to the passenger

Then the chatbot provides:
"Your dispute reference number is: [Case Number]. You will receive an email confirmation shortly."

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

 AGENT OVERRIDE FLOW � BEHIND THE SCENES:
When the agent opens the case in Claims Dashboard
Then the agent reviews:
� Original DDS determination: SoC-APPR-NE-07 (NOT ELIGIBLE � weather)
� Passenger dispute: Claims weather classification is incorrect
� Agent investigates:
  - Reviews Departure delay code 77 (Weather)
  - Checks if code was correctly assigned
  - Reviews operational logs
  - Determines if override is warranted

OVERRIDE DECISION � PENDING:
Then the agent determines: Override decision is PENDING
� Agent needs additional information before making a decision
� Agent may need to:
  - Contact operations team for clarification on Departure delay code
  - Review weather reports for the date/time
  - Consult with supervisor on borderline cases
  - Request additional documentation from passenger
� Case remains in PENDING OVERRIDE status

Then the agent updates the case:
� Override Status: PENDING
� Override Reason: "Investigating Departure delay code accuracy. Awaiting operations team response."
� Case Status: In Review (Override Pending)
� No payment initiated
� No Welcome Back email sent
� Passenger receives: "Your dispute is under review. We will update you once our investigation is complete."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-APPR-OVERRIDE-PENDING � Override Pending Disputed
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "In Review (Override Pending)"
  And the Team assignment is "Manual Handling"
  And the Tags include "Claimant", "Adult", and "Disputed"
  And the Itinerary shows Journey AC 301 YYZ ? YVR as the claimed flight
  And the Flight Status is "DELAYED (7 hours)"
  And the Eligibility section shows Disruption Reason "Weather (Code 77)"
  And the Delay Minutes is 420 min (7 hours)
  And the Controllability is "UNCONTROLLABLE (Weather � Code 77)"
  And the DDS Response Code is "SoC-APPR-NE-07"
  And the Original Eligibility is "NOT ELIGIBLE"
  And the Dispute is "YES"
  And the Override Status is "PENDING"
  And the Agent Action is "Investigating Departure delay code accuracy. Awaiting operations team response."
  And the Fraud Screening is "NOT PERFORMED (not eligible � no fraud check needed)"
  And the Receipt Validator SOC Expense Line Items is "N/A (pending override decision)"
  And the case Status is "In Review (Override Pending)" and the case is NOT in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-APPR-OVERRIDE-PENDING � Override Pending Disputed
  Given the case SoC-APPR-OVERRIDE-PENDING has an override PENDING
  Then no payment flow is triggered
  And the route is AC 301 YYZ ? YVR with delay 420 min (7 hrs) and Weather (Code 77)
  And the original DDS is SoC-APPR-NE-07 (NOT ELIGIBLE � weather, regular pax)
  And the customer disputed and the case was created with dispute flag
  And the agent is investigating and override status is PENDING
  And no country of residence is asked
  And no receipts are uploaded
  And no CyberSource fraud check is triggered
  And the case is held in override queue until agent resolves
  And the Claims Dashboard shows "In Review (Override Pending)" with no payout section

EXPECTED RESULTS:
SoC-Override-Pending. PENDING. Emergency override active. Normal DDS evaluation suspended. Shell case created and held in override queue. Passenger informed claim is being processed. Case remains pending until override resolves to Pay or NoPay. No receipt upload at this stage.