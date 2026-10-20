Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I had a connecting flight booked through Air Canada. The first leg on Air Canada was fine, but the second leg operated by United Airlines was delayed by 4 hours. I had to pay for food and a hotel. Can I get reimbursed?"
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
� Flight: AC 789 ? UA 8765
� Route: Toronto (YYZ) ? Chicago (ORD) ? San Francisco (SFO)
� Date: June 2, 2026
� Segment 1: AC 789 YYZ?ORD � Operated normally
� Segment 2: UA 8765 ORD?SFO � DELAYED (4 hours)
Is this the journey you'd like to check?"
And the user confirms "Yes"

Then the chatbot checks if there are more than 1 segment ? Yes (2 segments)

SEGMENT SELECTION (GenUC-18a):
Then the chatbot displays the segment(s) associated with the selected journey:
"Which segment was affected by the disruption?
� Segment 1: AC 789 YYZ?ORD (Operated normally)
� Segment 2: UA 8765 ORD?SFO (Delayed � 4 hours)"
And the user selects "Segment 2: UA 8765 ORD?SFO"

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + segment combination

72-HOUR CHECK:
Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes
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
? Multi-segment trip YYZ?ORD?SFO � Segment 1 AC789 on time, Segment 2 UA8765 (STAR) delayed +4H 00M
? PASSENGERS: 1 � SEGMENTS: 2

Itinerary:
? Promised Itinerary � Seg 1: AC 789, YYZ ? ORD, Dep: 02-Jun 08:00 | Seg 2: UA 8765, ORD ? SFO, Dep: 02-Jun 14:00
? Current Itinerary � Seg 1: AC 789, YYZ ? ORD, Status: ON TIME | Seg 2: UA 8765, ORD ? SFO, Status: ARRIVED LATE, Scheduled Dep: 14:00 ? Actual: 18:00, Delay: +4H 00M

Standards of Care (1):
? SOC section present � SOC Segment: UA 8765 ORD?SFO (STAR)
? Operating Carrier: UA (United Airlines � STAR Alliance)
? Departure Delay Code: Unknown (STAR � AC has limited data)
? PASSENGER: [Name] | STATUS: NO_DETERMINATION | BAND: DELAY_2_TO_6_HOURS | MEAL: � | ACCOMMODATION: � | GENERAL EXPENSES: � | EXPIRES: �

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: NO DETERMINATION � case created for manual review



DDS RESPONSE CODE = SoC-APPR-ND-02

Then the chatbot checks which airline company is it ? AC & STAR

NO DETERMINATION RESULT:
Then the chatbot displays: "I've reviewed the details of your journey. The disruption on your trip was caused by a delay on your United Airlines flight UA 8765 from Chicago to San Francisco, which was operated by a Star Alliance partner. Since this segment was not operated by Air Canada, we are unable to determine your eligibility for expense reimbursement automatically at this time. We have created a case for our team to review. In the meantime, please have any receipts for expenses you incurred during the disruption ready, as our team may request them during the review."

RECEIPT COLLECTION INITIATED:
Then the system flags the case for potential receipt collection
And the case note indicates: "STAR partner disruption � receipt collection initiated pending manual review"

CASE CREATION:
Then the system creates a case for agent review
And the case is assigned to the manual review queue
And the case reference number is provided to the passenger

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-APPR-ND-02 � STAR Alliance No Determination
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the agent can edit Topic/Sub-topic but cannot switch between automated and non-automated
  And the Status is "Assigned (Manual Review Queue)"
  And the Created date is populated
  And the Last Updated date is populated
  And the SLA countdown is tracking correctly
  And the Team assignment is "Manual Review Queue"
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
  And the Itinerary shows Journey AC 789 ? UA 8765 YYZ ? ORD ? SFO with claim filed for segment UA 8765 ORD ? SFO
  And Segment 1 AC 789 YYZ ? ORD is "Operated normally"
  And Segment 2 UA 8765 ORD ? SFO is "DELAYED 4 hours (STAR Alliance partner � disrupted segment)"
  And the Ancillary Fee section is present with no entries
  And the Eligibility section shows Journey = AC 789 ? UA 8765 YYZ ? ORD ? SFO
  And the SOC Segment is UA 8765 ORD ? SFO
  And the Operating Carrier is "UA (United Airlines � STAR Alliance)"
  And the Flight Leg at Fault is "UA 8765 (STAR operated � largest delay)"
  And the Disruption Reason is "UNKNOWN (limited STAR data available � AC cannot determine)"
  And the Delay Minutes is 240 min (4 hours)
  And the Travel Status is "Travelled (delayed)"
  And the Passenger Type is "Regular"
  And the Controllability is "UNKNOWN � cannot determine for STAR partner"
  And the Denied Boarding is "No"
  And the Class of Booking is "PY"
  And the Revenue Booking is "YES"
  And the DDS Response Code is "SoC-APPR-ND-02"
  And the Check Order is: 1. SOC carrier check ? STAR ? No Determination
  And the Receipt Collection is "INITIATED (pending manual review � STAR partners may share more data than non-partner OALs)"
  And the Agent Action Required is "Manual investigation � review with STAR partner data"
  And this differs from ND-01 (non-Star OAL) because STAR partners may share more data so receipt collection is initiated proactively
  And the Receipt Validator SOC Expense Line Items is "N/A (pending manual determination)"
  And the Applicable Regimes SOC Amount is "N/A (pending manual determination)"
  And the Duplicate Check ran automatically and result is "No duplicate found"
  And CyberSource is NOT triggered (No Determination � pending manual review)
  And the Booking Auto-Append shows the system appended the booking record automatically
  And the Agent Notes section is accessible
  And the Audit Log records case creation, No Determination, STAR flag, receipt collection initiated, and manual handling routing
  And the Customer Communications shows forwarded notification
  And the Chatbot transcript is accessible and linked to the case
  And the Attachments tab is empty
  And the Current Status is "Assigned (Manual Review Queue � No Determination)"
  And the case is NOT in read-only mode (agent can determine outcome after manual review)
  And the agent cannot access Case Search (leads/management only)

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-APPR-ND-02 � STAR Alliance No Determination
  Given the case SoC-APPR-ND-02 has No Determination
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
SoC-APPR-ND-02. NO DETERMINATION.  on STAR Alliance partner. Case created for agent review. Receipt collection initiated. 