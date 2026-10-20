Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I had a connecting flight booked through Air Canada. The first leg on Air Canada was fine, but the second leg operated by Lufthansa was delayed by 5 hours. I had to pay for food and a hotel while I waited. Can I get reimbursed for what I spent?"
When the chatbot identifies Standards of Care (SoC) intent
Then the chatbot checks: Is this a third-party submission? ? NO
SOC ENTRY (SoC-01):
Then the chatbot displays the case opening legal disclaimer (GenUC-24):
"Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"
IDENTIFICATION (GenUC-01):
Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "[First Name] [Last Name]"
Then the chatbot responds: "Thanks, [First Name]! And, what is your booking reference number?"
And the user provides "PNR: [PNR Code]"
Then the chatbot searches Trip Tracer for PNR: [PNR Code]
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: t***@gmail.com
� Phone: +1***789
And the user selects "Email: t***@gmail.com"
Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "546879"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds: "Your verification was successful. Let's proceed to the next step."
GROUP BOOKING CHECK:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
And system proceeds to passenger selection
PASSENGER SELECTION (GenUC-06):
Then the chatbot asks: "How many people are on your claim?"
And the chatbot displays passengers from PNR:
"I found 1 passenger on this booking:
� [First Name] [Last Name] (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 845 ? LH 470
� Route: Toronto (YYZ) ? Frankfurt (FRA) ? Munich (MUC)
� Date: June 10, 2026
� Segment 1: AC 845 YYZ?FRA � Operated normally
� Segment 2: LH 470 FRA?MUC � DELAYED (Departure delay: 5 hours)
Is this the journey you'd like to check?"
And the user confirms "Yes"
Then the chatbot checks if there are more than 1 segment ? Yes (2 segments)
SEGMENT SELECTION (GenUC-18a):
Then the chatbot displays the segment(s) associated with the selected journey:
"Which segment was affected by the disruption?
� Segment 1: AC 845 YYZ?FRA (Operated normally)
� Segment 2: LH 470 FRA?MUC (Delayed � 5 hours)"
And the user selects "Segment 2: LH 470 FRA?MUC"
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + segment combination
72-HOUR CHECK:
Then the chatbot checks if it passed the expected departure time of the last segment ? Yes
Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes
CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR SOC per province
And the system calculates:
� Origin: YYZ (Ontario) ? Limitation = 730 days
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
? Multi-segment trip YYZ?FRA?MUC � Segment 1 AC845 on time, Segment 2 LH470 (OAL) delayed +5H 00M
? PASSENGERS: 1 � SEGMENTS: 2

Itinerary:
? Promised Itinerary � Seg 1: AC 845, YYZ ? FRA, Dep: 10-Jun 08:00 | Seg 2: LH 470, FRA ? MUC, Dep: 10-Jun 14:00
? Current Itinerary � Seg 1: AC 845, YYZ ? FRA, Status: ON TIME | Seg 2: LH 470, FRA ? MUC, Status: ARRIVED LATE, Scheduled Dep: 14:00 ? Actual: 19:00, Delay: +5H 00M

Standards of Care (1):
? SOC section present � SOC Segment: LH 470 FRA?MUC (OAL)
? Operating Carrier: LH (Lufthansa � OAL)
? Departure Delay Code: Unknown (OAL � AC has no data)
? PASSENGER: [Name] | STATUS: NO_DETERMINATION | BAND: DELAY_2_TO_6_HOURS | MEAL: � | ACCOMMODATION: � | GENERAL EXPENSES: � | EXPIRES: �
? NO_DETERMINATION reason: OAL-operated SOC segment � AC cannot determine controllability

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: NO DETERMINATION (or redirected to OAL)
DDS RESPONSE CODE = SoC-APPR-ND-01
Then the chatbot checks which airline company is it ? AC & OAL
NO DETERMINATION RESULT:
Then the chatbot displays: "I've reviewed the details of your flight and we confirm that this flight was operated by lufthansa. Please reach out to Lufthansa for any claim related request."
END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."


CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-APPR-ND-01 � OAL Segment No Determination
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the agent can edit Topic/Sub-topic but cannot switch between automated and non-automated
  And the Status is "Pending Agent Review (No Determination � sent to OAL)"
  And the Created date is populated
  And the Last Updated date is populated
  And the SLA countdown is tracking correctly
  And the Team assignment is "Manual Handling Queue"
  And no banners are displayed (identified + authenticated, Auth Flow 1)
  And the Decision Assist panel is greyed out / not applicable (No Determination � agent must manually assess)
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
  And the Tags include "Claimant" and "Adult"
  And the Email is "t***@gmail.com"
  And the Phone is "+1***789"
  And the Address is populated
  And the Tier Status is populated
  And the Itinerary shows Journey AC 845 YYZ ? FRA ? MUC with claim filed for segment LH 470 FRA ? MUC
  And Segment 1 AC 845 YYZ ? FRA is "Operated normally (NOT the disrupted segment)"
  And Segment 2 LH 470 FRA ? MUC is "DELAYED 5 hours (OAL � Lufthansa � disrupted segment)"
  And the Ancillary Fee section is present with no entries
  And the Eligibility section shows Journey = AC 845 ? LH 470 YYZ ? FRA ? MUC
  And the Flight Leg at Fault is "LH 470 FRA ? MUC (OAL segment)"
  And the Operating Carrier is "OAL (Lufthansa � LH)"
  And the Disruption Reason is "Unknown � OAL disruption, AC cannot determine"
  And the Delay Minutes is 300 min (5 hours) on OAL segment
  And the Travel Status is "Travel Completed"
  And the Passenger Type is "Regular"
  And the Controllability is "Unknown � OAL disruption data not available to AC"
  And the Denied Boarding is "No"
  And the Class of Booking is "PY"
  And the Revenue Booking is "YES"
  And the DDS Response Code is "SoC-APPR-ND-01"
  And the Check Order is: 1. SOC carrier check ? OAL ? No Determination
  And AC cannot determine eligibility because the disruption occurred on an OAL segment and AC does not have access to Lufthansa's departure delay codes or controllability data
  And the Receipt Validator SOC Expense Line Items is "N/A (not reached � No Determination)"
  And the Applicable Regimes SOC Amount is "N/A"
  And the Duplicate Check ran automatically and result is "No duplicate found"
  And CyberSource is NOT triggered (No Determination � pending manual review)
  And the Booking Auto-Append shows the system appended the booking record automatically
  And the Dispute option is not applicable (No Determination � case already routed to manual handling)
  And the Agent Notes section is accessible
  And the Audit Log records case creation, No Determination, OAL flag, and manual handling routing
  And the Customer Communications shows forwarded notification
  And the Chatbot transcript is accessible and linked to the case
  And the Attachments tab is empty
  And the Current Status is "Pending Agent Review (No Determination)"
  And the case is NOT in read-only mode (agent can determine outcome after manual review)
  And the agent cannot access Case Search (leads/management only)

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-APPR-ND-01 � OAL Segment No Determination
  Given the case SoC-APPR-ND-01 has No Determination
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
SoC-APPR-ND-01. NO DETERMINATION.  on OAL � AC cannot determine eligibility. Passenger redirected to OAL. Case created for manual agent handling. Dark mode review may be needed for QA validation.