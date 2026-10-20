Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My Air Canada flight from Tel Aviv to London was delayed by about 8 hours. I had to buy food and pay for a hotel overnight. Can I get reimbursed?"
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
� Flight: AC 085
� Route: Tel Aviv (TLV) ? London Heathrow (LHR)
� Date: June 5, 2026
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
Then the chatbot checks: Filing deadline for ASL SOC
And the system calculates:
� ASL limitation: 1,460 days (4 years) � FIXED for all origins
� Days elapsed: 4 days ? Within limitation period ? PROCEED

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
? Single-segment trip TLV?LHR on AC085 was delayed +7H 00M � destination NOT in Israel (LHR = UK)
? Regime: APPR (system determines � ASL does not apply, AC carrier ? APPR applies)
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 085, Route: TLV ? LHR, Scheduled Dep: 05-Jun (time per prereqs)
? Current Itinerary � Flight: AC 085, Route: TLV ? LHR, Status: ARRIVED LATE, Delay: +7H 00M

Standards of Care (1):
? SOC section present
? Geographic Check (ASL): Origin = TLV (Israel) � PASS ? | Destination = LHR (UK) � NOT Israel ? ASL FAIL
? ASL requires BOTH origin AND destination in Israel ? FAIL (destination not Israel)
? Regime applied: APPR (AC carrier ? APPR applies)
? PASSENGER: [Name] | STATUS: depends on regime routing (ELIGIBLE under APPR if controllable / NOT_ELIGIBLE if evaluated under ASL only � geographic fail)

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: depends on regime routing
DDS RESPONSE CODE = SoC-ASL-NE-07

Then the chatbot checks which airline company is it ? AC

NOT ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "I've reviewed the details of your flight. Your flight AC 085 arrived in London (United Kingdom), which is outside Israel. Under the applicable Israeli aviation regulations (ASL), expense reimbursement is only available for flights departing from and arriving in Israel. Since your flight did not arrive in Israel, your claim is not eligible under ASL regulations. However, your flight may be eligible under Canadian regulations (APPR) since it was operated by Air Canada. Would you like us to check your eligibility under APPR instead?"

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
Scenario: Claims Dashboard validation for SoC-ASL-NE-07 � Destination Not Israel ASL Not Eligible
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
  And the Itinerary shows Journey AC 085 TLV ? LHR as the claimed flight
  And the Flight Status is "DELAYED (8 hours)"
  And the Eligibility section shows Journey = AC 085 TLV ? LHR
  And the Flight Leg at Fault is AC 085
  And the Operating Carrier is AC
  And the Disruption Reason is "N/A (not evaluated � geographic check failed)"
  And the Delay Minutes is 480 min (8 hours)
  And the Travel Status is "Travelled (delayed)"
  And the Passenger Type is "Regular"
  And the Geographic Check is "FAILED"
  And the Origin is "TLV (Tel Aviv, Israel) � IS Israel ?"
  And the Destination is "LHR (London, UK) � NOT Israel"
  And ASL requires BOTH origin AND destination to be Israel so the check FAILS
  And the Controllability is "NOT EVALUATED (geographic gate failed)"
  And the DDS Response Code is "SoC-ASL-NE-07"
  And the Regime Note is "May be eligible under APPR instead (AC operated flight)"
  And the key difference from NE-06 is NE-06 Origin FAILS (LHR ? TLV) while NE-07 Destination FAILS (TLV ? LHR) and together they validate both sides of the dual geographic gate
  And the Receipt Validator SOC Expense Line Items is "N/A (not reached)"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource is NOT triggered
  And the Dispute option is offered (GenUC-15)
  And the user selected "Agree"
  And the Final Status is "Closed � Not Eligible"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-ASL-NE-07 � Destination Not Israel ASL Not Eligible
  Given the case SoC-ASL-NE-07 is determined as NOT ELIGIBLE
  Then no payment flow is triggered
  And no country of residence is asked
  And no compensation record is created
  And no batch file is dispatched
  And no receipt upload is triggered (SOC receipts only triggered for eligible cases)
  And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section

EXPECTED RESULTS:
SoC-ASL-NE-07. NOT ELIGIBLE. Itinerary ended at FRA (Germany), not in Israel. ASL regime requires Israel as destination. No receipt upload. No case creation.