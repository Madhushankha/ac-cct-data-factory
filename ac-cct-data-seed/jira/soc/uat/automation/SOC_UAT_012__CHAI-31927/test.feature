Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My Air Canada flight from Toronto to Vancouver was delayed by about 6 hours a couple of weeks ago. I had to buy meals and pay for a hotel. Can I get reimbursed for what I spent?"
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
� Date: May 15, 2026
� Departure Delay: 6 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"

Then the chatbot checks if there are more than 1 segment ? No

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes
Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes (well beyond � disruption was May 15)

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR SOC per province
And the system calculates:
� Origin: YYZ (Ontario) ? Limitation = 730 days
� Destination: YVR (British Columbia) ? Limitation = 1,095 days
� Days elapsed: 24 days (disruption May 15, filing Jun 8) ? Within limitation period ? PROCEED

Then the chatbot checks if there is triage data available? ? Partial � Departure delay code MISSING

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

TRIP TRACER UI VALIDATIONS:
Then the tester opens Trip Tracer UI for PNR
Trip Overview:
? PNR: [PNR Code]
? TYPE: REVENUE
? ?? Trip Completed, Disruption Detected
? Single-segment domestic trip YYZ?YVR on AC301 was delayed +6H 00M � departure delay code missing after 14-day retrigger
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 301, Route: YYZ ? YVR, Scheduled Dep: 15-May 08:00
? Current Itinerary � Flight: AC 301, Route: YYZ ? YVR, Status: ARRIVED LATE, Scheduled Dep: 08:00 ? Actual: 14:00, Delay: +6H 00M

Standards of Care (1):
? SOC section present
? Departure Delay Code: NONE (not populated after 14-day RE retrigger)
? 14-Day RE Retrigger: COMPLETED � code still not populated
? PASSENGER: [Name] | STATUS: NO_DETERMINATION | BAND: DELAY_6_HOURS_OR_MORE | MEAL: � | ACCOMMODATION: � | GENERAL EXPENSES: � | EXPIRES: �

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: NO DETERMINATION � case created for manual review

DDS RESPONSE CODE = SoC-APPR-ND-03

Then the chatbot checks which airline company is it ? AC

NO DETERMINATION RESULT:
Then the chatbot displays: "I've reviewed the details of your flight AC 301 from Toronto to Vancouver. Unfortunately, we are unable to determine your eligibility for expense reimbursement automatically at this time due to incomplete flight data. We have created a case for our team to review manually. You will receive an update once our team has completed their review."

CASE CREATION:
Then the system creates a case for manual agent review
And the case is assigned to the manual review queue
And the case note indicates: "No Departure delay code available after 14-day RE retrigger � agent investigation required"
And the case reference number is provided to the passenger

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-APPR-ND-03 � Missing Delay Code No Determination
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Assigned (Manual Review Queue)"
  And the Created date and Last Updated date are populated
  And the SLA countdown is tracking correctly
  And the Team assignment is "Manual Review Queue"
  And no banners are displayed (Auth Flow 1)
  And the Decision Assist panel is greyed out / not applicable
  And the Claimant Name is populated
  And the Authentication is "Pass"
  And the PNR is populated
  And the Regime is "APPR"
  And the Full Name is populated
  And the Tags include "Claimant" and "Adult"
  And the Email is "t***@gmail.com"
  And the Phone is "+1***789"
  And the Itinerary shows Journey AC 301 YYZ ? YVR as the claimed flight
  And the Flight Status is "DELAYED (6 hours)"
  And the Eligibility section shows Journey = AC 301 YYZ ? YVR
  And the Flight Leg at Fault is AC 301
  And the Operating Carrier is AC
  And the Disruption Reason is "UNKNOWN � no Departure delay code populated"
  And the Delay Minutes is 360 min (6 hours)
  And the Travel Status is "Travelled (delayed)"
  And the Passenger Type is "Regular"
  And the Controllability is "UNKNOWN � no Departure delay code available"
  And the 14-Day RE Retrigger is "COMPLETED � code still not populated"
  And the Denied Boarding is "No"
  And the Class of Booking is "PY"
  And the Revenue Booking is "YES"
  And the DDS Response Code is "SoC-APPR-ND-03"
  And the Check Order is: 1. Departure delay code check ? NONE ? No Determination
  And the Agent Action Required is "Manually investigate disruption cause � contact operations for Departure delay code"
  And all other data is available (operating times, carrier, delay calculation) � ONLY the Departure delay code is missing so controllability cannot be classified
  And the Limitation Period Check shows Origin YYZ (Ontario) = 730 days and Destination YVR (British Columbia) = 1,095 days
  And the disruption was May 15 with filing Jun 8 = 24 days which is within limitation
  And the Receipt Validator SOC Expense Line Items is "N/A (pending manual determination)"
  And the Applicable Regimes SOC Amount is "N/A"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource is NOT triggered
  And the Current Status is "Assigned (Manual Review Queue)" and the case is NOT in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-APPR-ND-03 � Missing Delay Code No Determination
  Given the case SoC-APPR-ND-03 has No Determination
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
SoC-APPR-ND-03. NO DETERMINATION. No Departure delay code available after 14-day RE retrigger. Case created for manual review.