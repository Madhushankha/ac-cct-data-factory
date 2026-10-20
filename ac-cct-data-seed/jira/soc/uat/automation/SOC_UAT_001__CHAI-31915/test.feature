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

TRIP TRACER UI VALIDATIONS:
Then the tester opens Trip Tracer UI for PNR
Trip Overview:
? PNR: [PNR Code]
? TYPE: EMPLOYEE (non-revenue)
? ?? Trip Completed, Disruption Detected
? Single-segment domestic trip YYZ?YUL on AC101 was delayed +6H 00M due to crew / FDP exceedance (controllable)
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 101, Route: YYZ ? YUL, Scheduled Dep: 01-Jun 08:00
? Current Itinerary � Flight: AC 101, Route: YYZ ? YUL, Status: ARRIVED LATE, Scheduled Dep: 08:00 ? Actual: 14:00, Delay: +6H 00M

Standards of Care (1):
? SOC section present
? PASSENGER: [First Name] [Last Name] | STATUS: NOT_ELIGIBLE | BAND: DELAY_6_HOURS_OR_MORE | MEAL: � | ACCOMMODATION: � | GENERAL EXPENSES: � | EXPIRES: �
? NOT_ELIGIBLE reason: Employee booking

Passenger Claims:
? Passenger Claims section present
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: NOT ELIGIBLE (or no claim row if case not created)

NOT ELIGIBLE RESULT (SoC-03b): 
Then the chatbot displays: "I've reviewed the details of your flight. Unfortunately, your booking is classified as an employee booking, which does not qualify for Standards of Care expense reimbursement under the applicable regulations." 

DISPUTE OPTION (GenUC-15): 
Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" 
� Agree 
� Dispute 
And the user selects "Agree" 

END FLOW (GLOB-11): 
Then the chatbot offers: "Is there anything else I can help you with?" 
� I would like you to � new flow 
� No And the user selects "No" 
Then the chatbot responds "Thank you for choosing Air Canada." 


CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-APPR-NE-01 � AC Employee Not Eligible
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the agent can edit Topic/Sub-topic but cannot switch between automated and non-automated
  And the Status is "Closed � Not Eligible"
  And the Created date is populated
  And the Last Updated date is populated
  And the SLA countdown is tracking correctly
  And the Team assignment is correct
  And no banners are displayed (identified + authenticated, Auth Flow 1)
  And the Decision Assist panel is NOT greyed out
  And the Claimant Name is populated
  And the Claimant Type is "Adult"
  And the Authentication is "Pass"
  And the PNR is populated
  And the PNR Creation Date is populated
  And the Journey ID is populated
  And the Booking Source is populated
  And the Booking Office ID is populated
  And the Regime is "APPR"
  And the Full Name is populated
  And the Tags include "Claimant", "Adult", and "AC Employee"
  And the Email is "t***@gmail.com"
  And the Phone is "+1***789"
  And the Address is populated
  And the Tier Status is populated
  And the Itinerary shows Journey AC 101 YYZ ? YUL as the claimed flight
  And the Ancillary Fee section is present with no entries
  And the Eligibility section shows Journey = AC 101 YYZ ? YUL
  And the Flight Leg at Fault is AC 101
  And the Operating Carrier is AC
  And the Disruption Reason is "Flight Crew Shortage (Code 64)"
  And the Delay Minutes is 360 min (6 hours)
  And the Travel Status is "Travel Completed"
  And the Passenger Type is "Employee (AC)" with office suffix ES/OT/EP/EE/EC
  And the Controllability is "Controllable (Code 64)" but employee check overrides before controllability is evaluated
  And the Denied Boarding is "No"
  And the Class of Booking is "PY"
  And the Revenue Booking is "NO � Employee booking"
  And the DDS Response Code is "SoC-APPR-NE-01"
  And the Check Order is: 1. Pax Type ? Employee ? NOT ELIGIBLE (no further checks)
  And the employee is NOT blocked upfront � goes through OTP authentication first, then receives Not Eligible response
  And the Receipt Validator SOC Expense Line Items is "N/A (not reached � not eligible)"
  And the Applicable Regimes SOC Amount is "N/A"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource is NOT triggered
  And the Booking Auto-Append shows the system appended the booking record automatically
  And the Dispute option is offered (GenUC-15)
  And the user selected "Agree"
  And the Not Eligible notification is sent
  And the notification email contains employee booking ineligibility and regulation reference (APPR)
  And the Eligibility on Claims Dashboard is "NOT ELIGIBLE" with no compensation record and no payout section
  And the Final Status is "Closed � Not Eligible"
  And the case is in read-only mode
  And the agent cannot access Case Search (leads/management only)

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-APPR-NE-01 � AC Employee Not Eligible
  Given the case SoC-APPR-NE-01 is determined as NOT ELIGIBLE
  Then no payment flow is triggered
  And no country of residence is asked
  And no compensation record is created
  And no batch file is dispatched
  And no receipt upload is triggered (SOC receipts only triggered for eligible cases)
  And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section

EXPECTED RESULTS:
System correctly identifies employee booking AFTER OTP authentication (not blocked at entry). Returns SoC-APPR-NE-01. Displays NOT ELIGIBLE. Offers dispute option � if disputed, case created and sent to manual handling. No receipt upload triggered.