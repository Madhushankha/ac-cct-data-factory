Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Paris to Toronto took off but had to turn around and come back to Paris because of a problem. I was rebooked about 2 hours and 40 minutes later. I had to buy food while waiting at the airport. Can I get reimbursed?"
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
� Flight: AC 871
� Route: Paris (CDG) ? Toronto (YYZ)
� Date: June 5, 2026
� Status: DIVERTED � Returned to origin (CDG), rebooked on later flight
�  Delay: 90 min (1.5 hours)
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
� Departing country: France ? Limitation = 1,825 days (5 years)
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
? ?? Trip Not Completed, Disruption Detected
? Single-segment trip CDG?YYZ on AC871 was diverted � returned to origin � rebooked with SOC segment departure delay +1H 30M. Passenger returned to CDG.
? Regime: EU (CDG departure)
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 871, Route: CDG ? YYZ, Scheduled Dep: 08-Jun 11:00
? Current Itinerary � Flight: AC 871, Route: CDG ? YYZ, Status: DIVERTED � Returned to origin (CDG), rebooked, SOC Segment Departure Delay: +1H 30M

Standards of Care (1):
? SOC section present
? SOC Segment Departure Delay: 90 min (1.5 hours) � below 2h threshold
? Departure Delay Code: 64 (Flight Crew Shortage) � Controllable (NOT CHECKED � EU doesn't evaluate)
? PASSENGER: [Name] | STATUS: NOT_ELIGIBLE | BAND: DELAY_LESS_THAN_2_HOURS | MEAL: � | ACCOMMODATION: � | GENERAL EXPENSES: � | EXPIRES: �

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: NOT ELIGIBLE

DDS RESPONSE CODE = SoC-EU-NE-10

Then the chatbot checks which airline company is it ? AC

NOT ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "I've reviewed the details of your flight. Your flight AC 871 from Paris to Toronto was diverted back to Paris and you were rebooked on a later flight. However, the total delay to your journey was 2 hours and 40 minutes, which is below the minimum 2-hour threshold required for expense reimbursement under the applicable EU regulations for passengers who did not travel on their original flight."

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
Scenario: Claims Dashboard validation for SoC-EU-NE-10 � No Travel Returned to Origin Below 2h Not Eligible
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
  And the Itinerary shows Journey AC 871 CDG ? YYZ as the claimed flight
  And the Flight Status is "DIVERTED � Returned to origin (CDG), rebooked"
  And the Eligibility section shows Journey = AC 871 CDG ? YYZ
  And the Flight Leg at Fault is AC 871
  And the Operating Carrier is AC
  And the Disruption Reason is "N/A (not evaluated � delay below threshold)"
  And the Departure Delay is 90 min (1.5 hours)
  And the No-Travel Threshold is "120 min (2 hours) � NOT MET"
  And the Travel Status is "No Travel � Returned to Origin (CDG, rebooked)"
  And the Passenger Type is "Regular"
  And the Geographic Check is "PASSED ? (CDG = France, EU origin)"
  And the Controllability is "NOT CHECKED (EU regime does not evaluate for SOC)"
  And the DDS Response Code is "SoC-EU-NE-10"
  And this is the "Returned to origin" variant of no-travel <2h check where NE-09 tested "stayed at origin" and NE-10 tests "returned to origin" with the same 2-hour threshold
  And the Receipt Validator SOC Expense Line Items is "N/A (not reached)"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource is NOT triggered
  And the Dispute option is offered (GenUC-15)
  And the user selected "Agree"
  And the Final Status is "Closed � Not Eligible"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-EU-NE-10 � No Travel Returned to Origin Below 2h Not Eligible
  Given the case SoC-EU-NE-10 is determined as NOT ELIGIBLE
  Then no payment flow is triggered
  And no country of residence is asked
  And no compensation record is created
  And no batch file is dispatched
  And no receipt upload is triggered (SOC receipts only triggered for eligible cases)
  And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section

EXPECTED RESULTS:
SoC-EU-NE-10. NOT ELIGIBLE. No travel (return),  delay 90 min (<2h threshold under EU).