Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I had a connecting flight from London to Munich through Frankfurt. The Air Canada leg from London to Frankfurt was fine, but the Lufthansa leg from Frankfurt to Munich was delayed by about 5 hours. I had to buy food and pay for a hotel. Can I get reimbursed?"
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
� Flight: AC 849 ? LH 470
� Route: London Heathrow (LHR) ? Frankfurt (FRA) ? Munich (MUC)
� Date: June 1, 2026
� Segment 1: AC 849 LHR?FRA � Operated normally
� Segment 2: LH 470 FRA?MUC � DELAYED (5 hours)
Is this the journey you'd like to check?"
And the user confirms "Yes"

Then the chatbot checks if there are more than 1 segment ? Yes (2 segments)

SEGMENT SELECTION (GenUC-18a):
Then the chatbot displays the segment(s) associated with the selected journey:
"Which segment was affected by the disruption?
� Segment 1: AC 849 LHR?FRA (Operated normally)
� Segment 2: LH 470 FRA?MUC (Delayed � 5 hours)"
And the user selects "Segment 2: LH 470 FRA?MUC"

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
� Days elapsed: 7 days ? Within limitation period ? PROCEED

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
? Multi-segment trip LHR?FRA?MUC � Segment 1 AC849 on time, Segment 2 LH470 (OAL) delayed +5H 00M
? Regime: EU (LHR departure)
? PASSENGERS: 1 � SEGMENTS: 2

Itinerary:
? Promised Itinerary � Seg 1: AC 849, LHR ? FRA, Dep: 01-Jun 08:00 | Seg 2: LH 470, FRA ? MUC, Dep: 01-Jun 14:00
? Current Itinerary � Seg 1: AC 849, LHR ? FRA, Status: ON TIME | Seg 2: LH 470, FRA ? MUC, Status: ARRIVED LATE, Scheduled Dep: 14:00 ? Actual: 19:00, Delay: +5H 00M

Standards of Care (1):
? SOC section present � SOC Segment: LH 470 FRA?MUC (OAL)
? Operating Carrier: LH (Lufthansa � OAL)
? Departure Delay Code: Unknown (OAL � AC has no data)
? PASSENGER: [Name] | STATUS: NO_DETERMINATION | BAND: DELAY_2_TO_6_HOURS | MEAL: � | ACCOMMODATION: � | GENERAL EXPENSES: � | EXPIRES: �

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: NO DETERMINATION (or redirected to OAL)

DDS RESPONSE CODE = SoC-EU-ND-01

Then the chatbot checks which airline company is it ? AC & OAL

NO DETERMINATION RESULT:
Then the chatbot displays: "I've reviewed the details of your flight, and we confirm that this flight was operated by Lufthansa. Please reach out to United Airlines directly for any claim-related requests."


END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-EU-ND-01 � OAL Segment EU No Determination
  Given the agent opens the Claims Dashboard for the case
  Then no case is created in the Claims Dashboard for this scenario
  And the case is routed directly to manual handling without case creation at chatbot stage

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-EU-ND-01 � OAL Segment EU No Determination
  Given the case SoC-EU-ND-01 has No Determination
  Then no automated payment flow is triggered
  And the case is created and sent to agent for manual handling
  And no country of residence is asked at chatbot stage
  And no automated compensation record is created
  And no batch file is dispatched
  And no receipt upload is triggered at chatbot stage
  And if the agent later determines eligible then the agent manually creates compensation with SOC as cash only
  And a compensation record is created with GL account and cost center
  And a batch file is dispatched to Unifier
  And end-of-day report status tracking is initiated
  And the Claims Dashboard shows Case status = "No Determination" with no payout section until manually resolved

EXPECTED RESULTS:
SoC-EU-ND-01. NO DETERMINATION.  on OAL � AC cannot determine eligibility. Passenger redirected to OAL. Case created for manual agent handling. Dark mode review may be needed for QA validation.