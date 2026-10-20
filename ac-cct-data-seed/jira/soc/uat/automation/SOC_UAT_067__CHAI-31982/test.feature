Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I had a connecting flight booked through Air Canada from Tel Aviv through Haifa to Eilat. The Air Canada leg was fine, but the El Al leg from Haifa to Eilat was delayed and I missed my onward travel. I had to buy food and stay overnight. The airline says they still don't have the El Al flight data. Can I get reimbursed?"
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
� Flight: AC 090 ? LY 301
� Route: Tel Aviv (TLV) ? Haifa (HFA) ? Eilat (VDA)
� Date: May 16, 2026
� Segment 1: AC 090 TLV?HFA � Operated normally
� Segment 2: LY 301 HFA?VDA � Flight data unavailable
Is this the journey you'd like to check?"
And the user confirms "Yes"

Then the chatbot checks if there are more than 1 segment ? Yes (2 segments)

SEGMENT SELECTION (GenUC-18a):
Then the chatbot displays the segment(s) associated with the selected journey:
"Which segment was affected by the disruption?
� Segment 1: AC 090 TLV?HFA (Operated normally)
� Segment 2: LY 301 HFA?VDA (Flight data unavailable)"
And the user selects "Segment 2: LY 301 HFA?VDA"

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + segment combination

72-HOUR CHECK:
Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes
Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes (well beyond � disruption was May 16)

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for ASL SOC
And the system calculates:
� ASL limitation: 1,460 days (4 years) � FIXED
� Days elapsed: 24 days (disruption May 16, filing Jun 9) ? Within limitation period ? PROCEED

Then the chatbot checks if there is triage data available? ? Partial � OAL operating data MISSING

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:
TRIP TRACER UI VALIDATIONS:
Then the tester opens Trip Tracer UI for PNR
Trip Overview:
? PNR: [PNR Code]
? TYPE: REVENUE
? ?? Disruption Suspected � OAL operating data unavailable
? Multi-segment trip TLV?HFA?VDA � Segment 1 AC090 on time, Segment 2 LY301 (OAL) � flight data unavailable after 14-day retrigger
? Regime: ASL (TLV?HFA?VDA = all Israel)
? PASSENGERS: 1 � SEGMENTS: 2

Itinerary:
? Promised Itinerary � Seg 1: AC 090, TLV ? HFA | Seg 2: LY 301, HFA ? VDA
? Current Itinerary � Seg 1: AC 090, TLV ? HFA, Status: ON TIME | Seg 2: LY 301, HFA ? VDA, Status: DATA UNAVAILABLE � OAL operating data not populated

Standards of Care (1):
? SOC section present � SOC Segment: LY 301 HFA?VDA (OAL)
? Operating Carrier: LY (El Al � OAL)
? OAL Operating Data: UNAVAILABLE after 14-day RE retrigger
? Delay Calculation: IMPOSSIBLE (no OAL actual times)
? Geographic Check: TLV?HFA?VDA = all Israel ? PASSED ?
? PASSENGER: [Name] | STATUS: NO_DETERMINATION | BAND: � (cannot calculate) | MEAL: � | ACCOMMODATION: � | GENERAL EXPENSES: � | EXPIRES: �
? Difference from ND-01: ND-01 = immediate OAL detection ? instant ND. ND-05 = system waited 14 days, retriggered RE, OAL data still unavailable ? ND after exhausting automated options.

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: NO DETERMINATION � case created for manual review (agent must coordinate with OAL for operating data)

DDS RESPONSE CODE = SoC-ASL-ND-05

Then the chatbot checks which airline company is it ? AC & OAL

NO DETERMINATION RESULT:
Then the chatbot displays: "I've reviewed the details of your journey. The disruption appears to have occurred on your El Al flight LY 301 from Haifa to Eilat. Unfortunately, the operating data for this flight is currently unavailable in our system even after an extended data retrieval period, and we are unable to determine your eligibility for expense reimbursement automatically at this time. We have created a case for our team to investigate and review manually. You may also wish to contact El Al directly regarding any claims for this flight. You will receive an update once our team has completed their review."

CASE CREATION:
Then the system creates a case for manual agent review
And the case is assigned to the manual review queue
And the case note indicates: "ASL regime � OAL (El Al LY 301) operating data unavailable after 14-day RE retrigger. Geographic check passed (TLV?HFA?VDA = all Israel). Agent must investigate OAL disruption data manually or coordinate with El Al for operating data. Passenger may also file directly with OAL."
And the case reference number is provided to the passenger

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-ASL-ND-05 � OAL Data Missing After Retrigger ASL No Determination
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Assigned (Manual Review Queue)"
  And the Created date and Last Updated date are populated
  And the SLA countdown is tracking correctly
  And the Team assignment is "Manual Review Queue"
  And the Claimant Name is populated
  And the Authentication is "Pass"
  And the PNR is populated
  And the Regime is "ASL"
  And the Full Name is populated
  And the Tags include "Claimant" and "Adult"
  And the Itinerary shows Journey AC 090 ? LY 301 TLV ? HFA ? VDA with claim filed for segment LY 301 HFA ? VDA
  And Segment 1 AC 090 TLV ? HFA is "Operated normally"
  And Segment 2 LY 301 HFA ? VDA is "OAL operating data UNAVAILABLE (Disrupted segment)"
  And the Eligibility section shows Journey = AC 090 ? LY 301 TLV ? HFA ? VDA
  And the Flight Leg at Fault is "LY 301 HFA ? VDA (OAL)"
  And the Operating Carrier is "LY (El Al � OAL)"
  And the SOC Segment is "LY 301 (OAL operated � data unavailable)"
  And the Disruption Reason is "UNKNOWN � OAL operating data unavailable"
  And the Actual Departure Time (OAL) is "NOT AVAILABLE"
  And the Actual Arrival Time (OAL) is "NOT AVAILABLE"
  And the Delay Minutes is "UNKNOWN � cannot calculate without OAL operating data"
  And the Travel Status is "UNKNOWN � OAL data missing"
  And the Passenger Type is "Regular"
  And the Geographic Check is "PASSED ? (TLV ? HFA ? VDA = all Israel)"
  And the Controllability is "NOT APPLICABLE (ASL doesn't check)"
  And the 14-Day RE Retrigger is "COMPLETED � OAL data still not available"
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-ASL-ND-05"
  And the Agent Action Required is "Investigate OAL disruption data � coordinate with El Al for operating data. Geographic origin already confirmed (all Israel). Passenger may also file directly with OAL."
  And the difference from ND-01 is ND-01 detects OAL SOC immediately and triggers instant ND while ND-05 means the system WAITED 14 days, retriggered RE, STILL couldn't get OAL data so ND after exhausting all automated options
  And the difference from ND-04 is ND-04 is AC's OWN operating data missing (AC flight) while ND-05 is OAL operating data missing (El Al flight) � both can't calculate delay but for different carriers
  And the Receipt Validator SOC Expense Line Items is "N/A (pending manual determination)"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource is NOT triggered
  And the Current Status is "Assigned (Manual Review Queue)" and the case is NOT in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-ASL-ND-05 � OAL Data Missing After Retrigger ASL No Determination
  Given the case SoC-ASL-ND-05 has No Determination
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
SoC-ASL-ND-05. NO DETERMINATION. OAL data unavailable after 14-day retrigger. Case created for manual review. Dark mode review may be needed.