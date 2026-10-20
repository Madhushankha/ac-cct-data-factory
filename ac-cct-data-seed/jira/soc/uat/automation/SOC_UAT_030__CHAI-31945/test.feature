Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Toronto to London was delayed by about 8 hours. I had to buy food and pay for a hotel overnight at the airport. Can I get reimbursed?"
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
� Flight: AC 848
� Route: Toronto (YYZ) ? London Heathrow (LHR)
� Date: June 4, 2026
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
Then the chatbot checks: Filing deadline for EU SOC per departing country
And the system calculates:
� Departing country: Canada ? Limitation = 730 days (2 years)
  NOTE: Canada is listed in the EU limitation table under "2 years" category
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
? Single-segment trip YYZ?LHR on AC848 was delayed +6H 00M � origin NOT in EU (YYZ = Canada)
? Regime: APPR (system determines � EU does not apply to non-EU departures)
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 848, Route: YYZ ? LHR, Scheduled Dep: 05-Jun 19:00
? Current Itinerary � Flight: AC 848, Route: YYZ ? LHR, Status: ARRIVED LATE, Scheduled Dep: 19:00 ? Actual: 06-Jun 01:00, Delay: +6H 00M

Standards of Care (1):
? SOC section present
? Geographic Check: Origin = YYZ (Canada) � NOT EU/EEA/UK ? EU regime does NOT apply
? Regime applied: APPR (system routes to applicable regime)
? Departure Delay Code: 64 (Crew Shortage) � Controllable
? PASSENGER: [Name] | STATUS: ELIGIBLE (under APPR � controllable, ?2h) or NOT_ELIGIBLE (if evaluated under EU only � geographic fail) � depends on system routing
? NOTE: Test validates EU geographic gate specifically. If system correctly routes to APPR, passenger would be ELIGIBLE under APPR.

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: depends on regime routing (ELIGIBLE under APPR / NOT ELIGIBLE under EU)

 GEOGRAPHIC ORIGIN CHECK � THIS IS THE KEY TEST:
� EU regime geographic check:
  - Origin airport: YYZ (Toronto, Canada)
  - Origin country: CANADA
  - Is Canada an EU/EEA member state? ? NO 
  - Is Canada the United Kingdom? ? NO 
  - EU regulation 261/2004 requires flight to DEPART FROM an EU/EEA/UK airport
  - YYZ is NOT in the EU/EEA/UK
  - Result: ITINERARY DID NOT START IN EU ? NOT ELIGIBLE

   CRITICAL REGIME DIFFERENCES � GEOGRAPHIC CHECKS:
  - APPR: NO geographic origin check � applies to all Canadian airline flights
  - EU: Flight must DEPART FROM EU/EEA/UK airport (origin check ONLY)
  - ASL: Flight must DEPART FROM AND ARRIVE IN Israel (BOTH origin + destination)
  
  NOTE: Even though the flight ARRIVES at LHR (EU/UK), under EU261 the regulation 
  only applies to flights departing FROM the EU on non-EU carriers, or to/from EU 
  on EU carriers. Since AC is a non-EU carrier and the flight departs from Canada, 
  EU261 does NOT apply.

  NOTE: This itinerary WOULD be eligible under APPR (Canadian departure, AC flight, 
  controllable delay ?2h). The system should route to APPR regime instead. However, 
  this test case specifically validates the EU regime geographic gate � confirming 
  that if the system attempts to evaluate under EU, it correctly rejects.

� All further EU checks SKIPPED because geographic gate failed:
  ? Controllability check � SKIPPED (EU doesn't check anyway)
  ? Notification check � SKIPPED
  ? No-travel check � SKIPPED

DDS RESPONSE CODE = SoC-EU-NE-06

Then the chatbot checks which airline company is it ? AC

NOT ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "I've reviewed the details of your flight. Your flight AC 848 departed from Toronto (Canada), which is outside the European Union. Under EU Regulation 261/2004, expense reimbursement is only available for flights departing from an EU/EEA or UK airport when operated by a non-EU carrier. Since your flight did not depart from within the EU, your claim is not eligible under EU regulations. However, your flight may be eligible under Canadian regulations (APPR). Would you like us to check your eligibility under APPR instead?"

DISPUTE OPTION (GenUC-15):
Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?"
� Agree
� Dispute
And the user selects "Agree"

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-EU-NE-06 � Geographic Gate Failed Not Eligible
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Closed � Not Eligible"
  And the Created date and Last Updated date are populated
  And the SLA countdown is tracking correctly
  And the Claimant Name is populated
  And the Claimant Type is "Regular"
  And the Authentication is "Pass"
  And the PNR is populated
  And the Regime is "APPR"
  And the Full Name is populated
  And the Tags include "Claimant" and "Adult"
  And the Itinerary shows Journey AC 848 YYZ ? LHR as the claimed flight
  And the Flight Status is "DELAYED (8 hours)"
  And the Eligibility section shows Journey = AC 848 YYZ ? LHR
  And the Flight Leg at Fault is AC 848
  And the Operating Carrier is AC
  And the Disruption Reason is "N/A (not evaluated � geographic check failed)"
  And the Delay Minutes is 480 min (8 hours)
  And the Travel Status is "Travelled (delayed)"
  And the Passenger Type is "Regular"
  And the Geographic Origin Check is "FAILED"
  And the Origin is "YYZ (Toronto, Canada) � NOT EU/EEA/UK"
  And the Destination is "LHR (London, UK) � EU/UK ? (but origin is what matters for non-EU carriers)"
  And the Controllability is "NOT EVALUATED (geographic gate failed first)"
  And the DDS Response Code is "SoC-EU-NE-06"
  And the Regime Note is "May be eligible under APPR instead"
  And the Receipt Validator SOC Expense Line Items is "N/A (not reached)"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource is NOT triggered
  And the Dispute option is offered (GenUC-15)
  And the user selected "Agree"
  And the Final Status is "Closed � Not Eligible"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-EU-NE-06 � Geographic Gate Failed Not Eligible
  Given the case SoC-EU-NE-06 is determined as NOT ELIGIBLE
  Then no payment flow is triggered
  And no country of residence is asked
  And no compensation record is created
  And no batch file is dispatched
  And no receipt upload is triggered (SOC receipts only triggered for eligible cases)
  And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section

EXPECTED RESULTS:
SoC-EU-NE-06. NOT ELIGIBLE. Itinerary originated from YYZ (Canada), not from EU. EU regime requires EU origin. No receipt upload. No case creation.