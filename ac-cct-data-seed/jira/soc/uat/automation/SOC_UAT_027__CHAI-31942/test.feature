Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Paris to Montreal was delayed by about 18 hours. I was notified weeks in advance about the schedule change. I still had to buy food and stay at a hotel. Can I get reimbursed?"
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
� Route: Paris (CDG) ? Montreal (YUL)
� Date: June 3, 2026
� Departure Delay: 18 hours
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
? Single-segment trip CDG?YUL on AC871 was delayed +18H 00M � passenger notified 18 days before departure
? Regime: EU (CDG departure)
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 871, Route: CDG ? YUL, Scheduled Dep: 20-Jun 11:00
? Current Itinerary � Flight: AC 871, Route: CDG ? YUL, Status: ARRIVED LATE, Scheduled Dep: 11:00 ? Actual Dep: 21-Jun 08:00, Delay: +18H 00M (note: actual is +21h per times, but prereqs say 18h / 1080 min)

Standards of Care (1):
? SOC section present
? Notification: 18 days before departure ? ?14 days threshold ? NOT ELIGIBLE
? PASSENGER: [Name] | STATUS: NOT_ELIGIBLE | BAND: DELAY_6_HOURS_OR_MORE | MEAL: � | ACCOMMODATION: � | GENERAL EXPENSES: � | EXPIRES: �
? NOT_ELIGIBLE reason: Notified ?14 days before departure (EU threshold)

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: NOT ELIGIBLE
 NOTIFICATION CHECK � THIS IS THE KEY TEST:
� Passenger type check:
  - Passenger type: Regular (not employee, not exception)
  - Regular ? proceed to notification check

� Notification check:
  - Notification timestamp: 18 days before scheduled departure
  - EU threshold: ?14 days advance notification
  - 18 days > 14 days ? PASSENGER WAS NOTIFIED IN ADVANCE ? NOT ELIGIBLE

   CRITICAL REGIME DIFFERENCE:
  - APPR threshold: 12 HOURS (NE-03 uses 12-hour threshold)
  - EU threshold: 14 days (this test uses 15-day threshold)
  - ASL threshold: 14 days (same as EU)
  - Under APPR, 18 days advance notice ? would still be NE (exceeds 12h)
  - Under EU, 18 days advance notice ? NE (exceeds 14 days)
  - The EU threshold is MUCH more protective of airlines � 14 days vs 12 hours

� All further checks SKIPPED because notification threshold exceeded:
  ? Controllability check � SKIPPED (EU doesn't check anyway)
  ? Delay threshold check � SKIPPED (notification already disqualifies)
  ? No-travel check � SKIPPED

DDS RESPONSE CODE = SoC-EU-NE-03

Then the chatbot checks which airline company is it ? AC

NOT ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "I've reviewed the details of your flight. Our records show that you were notified about the schedule change for flight AC 871 from Paris to Montreal approximately 18 days before your scheduled departure. Under the applicable EU regulations, expense reimbursement is not available when passengers are notified of the disruption at least 14 days before the scheduled departure date, as this provides sufficient time to make alternative arrangements."

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
Scenario: Claims Dashboard validation for SoC-EU-NE-03 � Notification ?14 Days EU Not Eligible
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
  And the Tier Status is "Regular"
  And the Itinerary shows Journey AC 871 CDG ? YUL as the claimed flight
  And the Flight Status is "DELAYED (18 hours)"
  And the Eligibility section shows Journey = AC 871 CDG ? YUL
  And the Flight Leg at Fault is AC 871
  And the Operating Carrier is AC
  And the Disruption Reason is "N/A (not evaluated � notification threshold exceeded)"
  And the Delay Minutes is 1080 min (18 hours)
  And the Travel Status is "Travelled (delayed)"
  And the Passenger Type is "Regular"
  And the Notification Check is "NOTIFIED 18 days before departure ? ?14 days (EU threshold) ? NOT ELIGIBLE"
  And the Controllability is "NOT EVALUATED (EU doesn't check; also notification already disqualifies)"
  And the DDS Response Code is "SoC-EU-NE-03"
  And the APPR threshold is 12 HOURS (SoC-APPR-NE-03)
  And the EU threshold is 14 days (this test)
  And the ASL threshold is 14 days (same as EU)
  And the Receipt Validator SOC Expense Line Items is "N/A (not reached)"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource is NOT triggered
  And the Dispute option is offered (GenUC-15)
  And the user selected "Agree"
  And the Final Status is "Closed � Not Eligible"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-EU-NE-03 � Notification ?14 Days EU Not Eligible
  Given the case SoC-EU-NE-03 is determined as NOT ELIGIBLE
  Then no payment flow is triggered
  And no country of residence is asked
  And no compensation record is created
  And no batch file is dispatched
  And no receipt upload is triggered (SOC receipts only triggered for eligible cases)
  And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section

EXPECTED RESULTS:
SoC-EU-NE-03. NOT ELIGIBLE. Passenger notified ?14 days before departure (EU threshold). No receipt upload. No case creation.