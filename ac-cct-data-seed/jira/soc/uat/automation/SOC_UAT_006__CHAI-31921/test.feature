Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight was delayed for several hours and I had to buy food at the airport and book a hotel for the night. Can I get reimbursed for what I spent?"
When the chatbot identifies Standards of Care (SoC) intent
Then the chatbot checks: Is this a third-party submission? ? NO

SOC ENTRY (SoC-01):
Then the chatbot displays the case opening legal disclaimer (GenUC-24):
"Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd liketo be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

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
� Flight: AC 701
� Route: Toronto (YYZ) ? Winnipeg (YWG)
� Date: June 5, 2026
Is this the journey you'd like to check?"
And the user confirms "Yes"

Then the chatbot checks if there are more than 1 segment ? No

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes
Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes

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
? Single-segment domestic trip YYZ?YWG on AC701 was cancelled due to ATC restriction (uncontrollable)
? Passenger stayed at origin (YYZ)
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 701, Route: YYZ ? YWG, Scheduled Dep: 05-Jun 06:00
? Current Itinerary � Flight: AC 701, Route: YYZ ? YWG, Status: CANCELLED

Standards of Care (1):
? SOC section present
? PASSENGER: [First Name] [Last Name] | STATUS: NOT_ELIGIBLE | BAND: � (cancelled, no delay band) | MEAL: � | ACCOMMODATION: � | GENERAL EXPENSES: � | EXPIRES: �
? NOT_ELIGIBLE reason: Uncontrollable (ATC Restriction � Code 72), regular passenger, no travel

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: NOT ELIGIBLE


DDS RESPONSE CODE = SoC-APPR-NE-08
Then the chatbot checks which airline company is it ? AC

NOT ELIGIBLE RESULT (SoC-03b): 
Then the chatbot displays: "I've reviewed the details of your flight, and it looks like you haven't travelled. You are not eligible for expense reimbursement for this." 

END FLOW (GLOB-11): 
Then the chatbot offers: "Is there anything else I can help you with?" 
� I would like you to � new flow 
� No And the user selects "No" 
Then the chatbot responds "Thank you for choosing Air Canada." 



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-APPR-NE-08 � ATC No Travel Not Eligible
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Closed � Not Eligible"
  And the Created date and Last Updated date are populated
  And the SLA countdown is tracking correctly
  And the Team assignment is correct
  And no banners are displayed (Auth Flow 1)
  And the Decision Assist panel is NOT greyed out
  And the Claimant Name is populated
  And the Authentication is "Pass"
  And the PNR is populated
  And the Regime is "APPR"
  And the Full Name is populated
  And the Tags include "Claimant" and "Adult"
  And the Email is "t***@gmail.com"
  And the Phone is "+1***789"
  And the Itinerary shows Journey AC 701 YYZ ? YWG as the claimed flight
  And the Flight Status is "CANCELLED � passenger stayed at origin (YYZ)"
  And the Eligibility section shows Journey = AC 701 YYZ ? YWG
  And the Flight Leg at Fault is AC 701
  And the Operating Carrier is AC
  And the Disruption Reason is "ATC Restriction (Code 72)"
  And the Delay Minutes is "N/A (no travel)"
  And the Travel Status is "No Travel � Stayed at Origin"
  And the Passenger Type is "Regular"
  And the Controllability is "Uncontrollable (Code 72 � ATC restriction)"
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-APPR-NE-08"
  And the Check Order is: 1. Pax Type ? Regular ? ? 2. Controllability ? Uncontrollable ? NOT ELIGIBLE
  And if Pax Type were Exception, controllability would be skipped and passenger would be ELIGIBLE
  And the Receipt Validator SOC Expense Line Items is "N/A (not reached)"
  And the Applicable Regimes SOC Amount is "N/A"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource is NOT triggered
  And the Dispute option is not offered (not shown in transcript for NE-08)
  And the Eligibility on Claims Dashboard is "NOT ELIGIBLE" with no compensation record and no payout section
  And the Final Status is "Closed � Not Eligible"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-APPR-NE-08 � ATC No Travel Not Eligible
  Given the case SoC-APPR-NE-08 is determined as NOT ELIGIBLE
  Then no payment flow is triggered
  And no country of residence is asked
  And no compensation record is created
  And no batch file is dispatched
  And no receipt upload is triggered (SOC receipts only triggered for eligible cases)
  And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section

EXPECTED RESULTS:
SoC-APPR-NE-08. NOT ELIGIBLE. No travel (stayed at origin), outside carrier control, regular passenger. Departure Delaycode used.