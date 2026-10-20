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
� Flight: UA 456
� Route: Chicago(ORD) ? Los Angeles (LAX)
� Date: June 2, 2026
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
? Single-segment trip ORD?LAX on UA456 was delayed +5H 00M � OAL operated
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: UA 456, Route: ORD ? LAX, Scheduled Dep: 02-Jun 10:00
? Current Itinerary � Flight: UA 456, Route: ORD ? LAX, Status: ARRIVED LATE, Scheduled Dep: 10:00 ? Actual: 15:00, Delay: +5H 00M

Standards of Care (1):
? SOC section present
? PASSENGER: [First Name] [Last Name] | STATUS: NOT_ELIGIBLE | BAND: DELAY_2_TO_6_HOURS | MEAL: � | ACCOMMODATION: � | GENERAL EXPENSES: � | EXPIRES: �
? NOT_ELIGIBLE reason: OAL-operated segment � redirect to United Airlines

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: NOT ELIGIBLE
? No case created (OAL redirect � passenger directed to operating carrier)
DDS RESPONSE CODE = SoC-APPR-NE-05

Then the chatbot checks which airline company is it ? OAL

NOT ELIGIBLE RESULT (SoC-03b): 
Then the chatbot displays: "I've reviewed the details of your flight, and we confirm that this flight was operated by United Airlines. Please reach out to United Airlines directly for any claim-related requests. " 

END FLOW (GLOB-11): 
Then the chatbot offers: "Is there anything else I can help you with?" 
� I would like you to � new flow 
� No And the user selects "No" 
Then the chatbot responds "Thank you for choosing Air Canada." 



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-APPR-NE-05 � OAL Only Not Eligible
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
  And the Itinerary shows Journey UA 456 ORD ? LAX (OAL operated � no AC segments)
  And the Eligibility section shows Journey = UA 456 ORD ? LAX
  And the Flight Leg at Fault is UA 456
  And the Operating Carrier is "OAL (United Airlines)" with no AC segments on itinerary
  And the Disruption Reason is "N/A (OAL � AC has no disruption data)"
  And the Delay Minutes is 300 min (5 hours)
  And the Travel Status is "Travel Completed"
  And the Passenger Type is "Regular"
  And the Controllability is "N/A � OAL only"
  And the Denied Boarding is "No"
  And the Class of Booking is "PY"
  And the Revenue Booking is "YES"
  And the DDS Response Code is "SoC-APPR-NE-05"
  And the Check Order is: 1. Carrier check on SOC segment ? OAL only ? NOT ELIGIBLE (no AC involvement on the disrupted segment)
  And the customer is redirected to contact United Airlines directly as AC cannot process OAL-only claims
  And the Receipt Validator SOC Expense Line Items is "N/A (not reached)"
  And the Applicable Regimes SOC Amount is "N/A"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource is NOT triggered
  And the Dispute option is not offered (OAL redirect � no dispute path)
  And the Eligibility on Claims Dashboard is "NOT ELIGIBLE" with no compensation record and no payout section
  And the Final Status is "Closed � Not Eligible"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-APPR-NE-05 � OAL Only Not Eligible
  Given the case SoC-APPR-NE-05 is determined as NOT ELIGIBLE
  Then no payment flow is triggered
  And no country of residence is asked
  And no compensation record is created
  And no batch file is dispatched
  And no receipt upload is triggered (SOC receipts only triggered for eligible cases)
  And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section

EXPECTED RESULTS:
SoC-APPR-NE-05. NOT ELIGIBLE. OAL-only itinerary � no AC involvement. Passenger redirected to operating carrier. No receipt upload. No case creation.