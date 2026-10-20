Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I had a connecting flight booked through Air Canada from Paris to San Francisco through Chicago. The Air Canada leg from Paris to Chicago was fine, but the United Airlines leg from Chicago to San Francisco was delayed by 4 hours. I had to pay for food and a hotel. Can I get reimbursed?"
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
� Flight: AC 871 ? UA 8765
� Route: Paris (CDG) ? Chicago (ORD) ? San Francisco (SFO)
� Date: June 2, 2026
� Segment 1: AC 871 CDG?ORD � Operated normally
� Segment 2: UA 8765 ORD?SFO � DELAYED (4 hours)
Is this the journey you'd like to check?"
And the user confirms "Yes"

Then the chatbot checks if there are more than 1 segment ? Yes (2 segments)

SEGMENT SELECTION (GenUC-18a):
Then the chatbot displays the segment(s) associated with the selected journey:
"Which segment was affected by the disruption?
� Segment 1: AC 871 CDG?ORD (Operated normally)
� Segment 2: UA 8765 ORD?SFO (Delayed � 4 hours)"
And the user selects "Segment 2: UA 8765 ORD?SFO"

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + segment combination

72-HOUR CHECK:
Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes
Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for EU SOC per departing country
And the system calculates:
� Departing country (of journey origin): France ? Limitation = 1,825 days (5 years)
� Days elapsed: 6 days ? Within limitation period ? PROCEED

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
? Multi-segment trip CDG?ORD?SFO � Segment 1 AC871 on time, Segment 2 UA8765 (STAR) delayed +4H 00M
? Regime: EU (CDG departure)
? PASSENGERS: 1 � SEGMENTS: 2

Itinerary:
? Promised Itinerary � Seg 1: AC 871, CDG ? ORD, Dep: 02-Jun 08:00 | Seg 2: UA 8765, ORD ? SFO, Dep: 02-Jun 14:00
? Current Itinerary � Seg 1: AC 871, CDG ? ORD, Status: ON TIME | Seg 2: UA 8765, ORD ? SFO, Status: ARRIVED LATE, Scheduled Dep: 14:00 ? Actual: 18:00, Delay: +4H 00M

Standards of Care (1):
? SOC section present � SOC Segment: UA 8765 ORD?SFO (STAR)
? Operating Carrier: UA (United Airlines � STAR Alliance)
? Departure Delay Code: Unknown (STAR � AC has limited data)
? PASSENGER: [Name] | STATUS: NO_DETERMINATION | BAND: DELAY_2_TO_6_HOURS | MEAL: � | ACCOMMODATION: � | GENERAL EXPENSES: � | EXPIRES: �
? Receipt collection: INITIATED (STAR partners � more cooperative data-sharing)

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: NO DETERMINATION � case created for manual review, receipt collection initiated
DDS RESPONSE CODE = SoC-EU-ND-02

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
Scenario: Claims Dashboard validation for SoC-EU-ND-02 � STAR Alliance EU No Determination
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Assigned (Manual Review Queue)"
  And the Created date and Last Updated date are populated
  And the SLA countdown is tracking correctly
  And the Team assignment is "Manual Review Queue"
  And no banners are displayed (Auth Flow 1)
  And the Decision Assist panel is greyed out / not applicable
  And the Claimant Name is populated
  And the Claimant Type is "Regular"
  And the Authentication is "Pass"
  And the PNR is populated
  And the Regime is "EU"
  And the Full Name is populated
  And the Tags include "Claimant" and "Adult"
  And the Email is "t***@gmail.com"
  And the Phone is "+1***789"
  And the Itinerary shows Journey AC 871 ? UA 8765 CDG ? ORD ? SFO with claim filed for segment UA 8765 ORD ? SFO
  And Segment 1 AC 871 CDG ? ORD is "Operated normally"
  And Segment 2 UA 8765 ORD ? SFO is "DELAYED 4 hours (STAR Alliance partner � disrupted segment)"
  And the Eligibility section shows Journey = AC 871 ? UA 8765 CDG ? ORD ? SFO
  And the Flight Leg at Fault is "UA 8765 ORD ? SFO (STAR partner)"
  And the Operating Carrier is "UA (United Airlines � STAR Alliance)"
  And the Disruption Reason is "UNKNOWN (limited STAR data available)"
  And the Delay Minutes is 240 min (4 hours)
  And the Travel Status is "Travelled (delayed)"
  And the Passenger Type is "Regular"
  And the Geographic Check is "PASSED ? (CDG = France, EU origin)"
  And the Controllability is "NOT APPLICABLE (EU doesn't check � but STAR data still limited)"
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-EU-ND-02"
  And the Receipt Collection is "INITIATED (pending manual review � STAR partners may share more data)"
  And the Agent Action Required is "Manual investigation � review with STAR partner data, verify delay, determine eligibility"
  And this differs from ND-01 (OAL) because STAR partners have more cooperative data-sharing so receipt collection is initiated proactively and the agent has slightly more data to work with
  And the Receipt Validator SOC Expense Line Items is "N/A (pending manual determination)"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource is NOT triggered
  And the Current Status is "Assigned (Manual Review Queue)" and the case is NOT in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-EU-ND-02 � STAR Alliance EU No Determination
  Given the case SoC-EU-ND-02 has No Determination
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
SoC-EU-ND-02. NO DETERMINATION.  on STAR Alliance partner. Case created for agent review. Receipt collection initiated. Dark mode review may be needed.