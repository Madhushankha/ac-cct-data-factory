Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I was on a connecting flight and my second leg got cancelled because of weather. I got stuck at Calgary and never made it to Vancouver. I had to pay for food and a hotel. Can I get reimbursed?"
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
� Flight: AC 901 ? AC 902
� Route: Toronto (YYZ) ? Calgary (YYC) ? Vancouver (YVR)
� Date: June 6, 2026
� Segment 1: AC 901 YYZ?YYC � Operated
� Segment 2: AC 902 YYC?YVR � CANCELLED
Is this the journey you'd like to check?"
And the user confirms "Yes"

Then the chatbot checks if there are more than 1 segment ? Yes (2 segments)

SEGMENT SELECTION (GenUC-18a):
Then the chatbot displays the segment(s) associated with the selected journey:
"Which segment was affected by the disruption?
� Segment 1: AC 901 YYZ?YYC (Operated)
� Segment 2: AC 902 YYC?YVR (Cancelled)"
And the user selects "Segment 2: AC 902 YYC?YVR"

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + segment combination

72-HOUR CHECK:
Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes
Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR SOC per province ? Within limitation period ? PROCEED

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
? Multi-segment domestic trip YYZ?YYC?YVR � Segment 2 AC902 YYC?YVR was cancelled due to weather (uncontrollable). Passenger stranded at YYC.
? PASSENGERS: 1 � SEGMENTS: 2

Itinerary:
? Promised Itinerary � Seg 1: AC 901, YYZ ? YYC, Dep: 06-Jun 07:00 | Seg 2: AC 902, YYC ? YVR, Dep: 06-Jun 12:00
? Current Itinerary � Seg 1: AC 901, YYZ ? YYC, Status: ON TIME | Seg 2: AC 902, YYC ? YVR, Status: CANCELLED

Standards of Care (1):
? SOC section present � SOC Segment: AC 902 YYC?YVR
? Departure Delay Code: 77 (Weather) � Uncontrollable
? PASSENGER: [Name] | STATUS: NOT_ELIGIBLE | BAND: � | MEAL: � | ACCOMMODATION: � | GENERAL EXPENSES: � | EXPIRES: �

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: NOT ELIGIBLE
DDS RESPONSE CODE = SoC-APPR-NE-12

Then the chatbot checks which airline company is it ? AC

NOT ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "I've reviewed the details of your flight. Unfortunately, your connecting flight AC 902 from Calgary to Vancouver was cancelled due to severe weather conditions. Under the applicable regulations (APPR), expense reimbursement is not available for disruptions caused by weather and other factors outside the airline's control. If you have travel insurance, you may want to contact your insurance provider to see if your policy offers any coverage for this situation."

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
Scenario: Claims Dashboard validation for SoC-APPR-NE-12 � Weather Incomplete Journey Not Eligible
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
  And the Itinerary shows Journey AC 901 YYZ ? YYC ? YVR with claim filed for segment AC 902 YYC ? YVR
  And Segment 1 AC 901 YYZ ? YYC is "Operated"
  And Segment 2 AC 902 YYC ? YVR is "CANCELLED (Disrupted segment)"
  And the Eligibility section shows Journey = AC 901 ? AC 902 YYZ ? YYC ? YVR
  And the Flight Leg at Fault is AC 902 YYC ? YVR
  And the Operating Carrier is AC
  And the Disruption Reason is "Weather (Code 77)"
  And the Delay Minutes is "N/A (no travel � incomplete journey)"
  And the Travel Status is "No Travel � Incomplete (stranded at YYC)"
  And the Passenger Type is "Regular"
  And the Controllability is "Uncontrollable (Code 77 � Weather)"
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-APPR-NE-12"
  And the Check Order is: 1. Pax Type ? Regular ? ? 2. Controllability ? Uncontrollable ? NOT ELIGIBLE
  And if Pax Type were Exception, controllability would be skipped and passenger would be ELIGIBLE
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
Scenario: Payment validation for SoC-APPR-NE-12 � Weather Incomplete Journey Not Eligible
  Given the case SoC-APPR-NE-12 is determined as NOT ELIGIBLE
  Then no payment flow is triggered
  And no country of residence is asked
  And no compensation record is created
  And no batch file is dispatched
  And no receipt upload is triggered (SOC receipts only triggered for eligible cases)
  And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section

EXPECTED RESULTS:
SoC-APPR-NE-12. NOT ELIGIBLE. No travel (incomplete, mid-point), outside carrier control, regular passenger.