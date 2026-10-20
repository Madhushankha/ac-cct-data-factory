Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My British Airways flight from London to New York was delayed by about 5 hours. I had to buy food and pay for a hotel. Can I get reimbursed through Air Canada?"
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
� Flight: BA 178
� Route: London Heathrow (LHR) ? New York (JFK)
� Date: June 4, 2026
� Departure Delay: 5 hours
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
? TYPE: REVENUE
? ?? Trip Completed, Disruption Detected
? Single-segment trip LHR?JFK on BA178 was delayed +5H 00M � OAL operated (British Airways)
? Regime: EU (LHR departure)
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: BA 178, Route: LHR ? JFK, Scheduled Dep: 04-Jun 08:00
? Current Itinerary � Flight: BA 178, Route: LHR ? JFK, Status: ARRIVED LATE, Scheduled Dep: 08:00 ? Actual: 13:00, Delay: +5H 00M

Standards of Care (1):
? SOC section present
? Operating Carrier: BA (British Airways � OAL)
? PASSENGER: [Name] | STATUS: NOT_ELIGIBLE | BAND: DELAY_2_TO_6_HOURS | MEAL: � | ACCOMMODATION: � | GENERAL EXPENSES: � | EXPIRES: �
? NOT_ELIGIBLE reason: OAL-operated segment � redirect to British Airways

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: NOT ELIGIBLE
? No case created (OAL redirect)

 CARRIER CHECK � THIS IS THE KEY TEST:
� Operating Carrier check:
  - PNR contains: BA 178 only
  - Carrier: BA (British Airways) ? OAL
  - AC segments in PNR: NONE
  - No Air Canada involvement whatsoever
  - Result: OAL-only itinerary ? NOT ELIGIBLE

� Triage routing (per Miro flow):
  - SoC-02b: Airline Company check ? OAL only
  - Route to SoC-03g (OAL only flow)
  - Passenger redirected to operating carrier (British Airways)

� All further checks SKIPPED:
  ? Geographic origin check � SKIPPED (no AC involvement)
  ? Controllability check � SKIPPED (no AC involvement)
  ? Notification check � SKIPPED (no AC involvement)

DDS RESPONSE CODE = SoC-EU-NE-05

Then the chatbot checks which airline company is it ? OAL

NOT ELIGIBLE RESULT (SoC-03g � OAL only flow):
Then the chatbot displays: "I've reviewed the details of your flight, and we confirm that this flight was operated by British Airways. Since Air Canada was not involved in operating this flight, we are unable to process a Standards of Care expense claim for this journey. Please reach out to British Airways directly for any claim-related requests regarding flight BA 178."

(Auto-proceeds after 15 seconds per Miro flow SoC-03g)

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-EU-NE-05 � OAL Only EU Not Eligible
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Closed � Not Eligible"
  And the Created date and Last Updated date are populated
  And the SLA countdown is tracking correctly
  And the Claimant Name is populated
  And the Claimant Type is "Regular"
  And the Authentication is "Pass"
  And the PNR is populated
  And the Regime is "EU"
  And the Full Name is populated
  And the Tags include "Claimant" and "Adult"
  And the Itinerary shows Journey BA 178 LHR ? JFK (OAL operated � no AC segments)
  And the Flight Status is "DELAYED (5 hours)"
  And the Eligibility section shows Journey = BA 178 LHR ? JFK
  And the Flight Leg at Fault is BA 178
  And the Operating Carrier is "BA (British Airways � OAL)"
  And the Carrier Check is "OAL ONLY � no AC segments in PNR"
  And the Disruption Reason is "N/A (not evaluated � OAL only)"
  And the Delay Minutes is 300 min (5 hours)
  And the Travel Status is "Travelled (delayed)"
  And the Passenger Type is "Regular"
  And the Controllability is "NOT EVALUATED (OAL only)"
  And the Triage Routing is "SoC-03g (OAL only flow)"
  And the Passenger is Redirected To "British Airways"
  And the DDS Response Code is "SoC-EU-NE-05"
  And the Receipt Validator SOC Expense Line Items is "N/A (not reached)"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource is NOT triggered
  And the Dispute option is not offered (OAL redirect � no dispute path)
  And the Final Status is "Closed � Not Eligible"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-EU-NE-05 � OAL Only EU Not Eligible
  Given the case SoC-EU-NE-05 is determined as NOT ELIGIBLE
  Then no payment flow is triggered
  And no country of residence is asked
  And no compensation record is created
  And no batch file is dispatched
  And no receipt upload is triggered (SOC receipts only triggered for eligible cases)
  And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section

EXPECTED RESULTS:
SoC-EU-NE-05. NOT ELIGIBLE. OAL-only itinerary � no AC involvement. Passenger redirected to operating carrier. No receipt upload. No case creation.