Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My Air Canada flight from Tel Aviv to Eilat was significantly delayed a couple of weeks ago. I had to pay for meals and accommodation. Can I get reimbursed?"
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
� Flight: AC 084
� Route: Tel Aviv (TLV) ? Eilat (VDA)
� Date: May 16, 2026
� Status: Flight data incomplete � actual departure/Departure times unavailable
Is this the journey you'd like to check?"
And the user confirms "Yes"

Then the chatbot checks if there are more than 1 segment ? No

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes
Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes (well beyond � disruption was May 16)

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for ASL SOC
And the system calculates:
� ASL limitation: 1,460 days (4 years) � FIXED
� Days elapsed: 24 days (disruption May 16, filing Jun 9) ? Within limitation period ? PROCEED

Then the chatbot checks if there is triage data available? ? Partial � operating data MISSING

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:
TRIP TRACER UI VALIDATIONS:
Then the tester opens Trip Tracer UI for PNR
Trip Overview:
? PNR: [PNR Code]
? TYPE: REVENUE
? ?? Trip Completed, Disruption Detected
? Single-segment trip TLV?VDA on AC084 was delayed +6H 00M � departure delay code missing after 14-day retrigger
? Regime: ASL (TLV?VDA = Israel?Israel)
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 084, Route: TLV ? VDA, Scheduled Dep: 15-May 16:00
? Current Itinerary � Flight: AC 084, Route: TLV ? VDA, Status: ARRIVED LATE, Scheduled Dep: 16:00 ? Actual: 22:00, Delay: +6H 00M

Standards of Care (1):
? SOC section present
? Departure Delay Code: NONE (not populated after 14-day RE retrigger)
? 14-Day RE Retrigger: COMPLETED � code still not populated
? Geographic Check: TLV?VDA = Israel?Israel ? PASSED ?
? PASSENGER: [Name] | STATUS: NO_DETERMINATION | BAND: DELAY_6_HOURS_OR_MORE | MEAL: � | ACCOMMODATION: � | GENERAL EXPENSES: � | EXPIRES: �

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: NO DETERMINATION � case created for manual review
DDS RESPONSE CODE = SoC-ASL-ND-03

Then the chatbot checks which airline company is it ? AC

NO DETERMINATION RESULT:
Then the chatbot displays: "I've reviewed the details of your flight AC 084 from Tel Aviv to Eilat. Unfortunately, we are unable to determine your eligibility for expense reimbursement automatically at this time because some of the required flight operating data is currently unavailable in our system. We have created a case for our team to investigate and review manually. You will receive an update once our team has completed their review."

CASE CREATION:
Then the system creates a case for manual agent review
And the case is assigned to the manual review queue
And the case note indicates: "ASL regime � Operating data missing (actual dep/arr times) after 14-day RE retrigger. Cannot calculate delay. Geographic check passed (TLV?VDA = Israel?Israel). Agent must source operating data manually from operations team."
And the case reference number is provided to the passenger

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-ASL-ND-03 � Missing Delay Code ASL No Determination
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
  And the Itinerary shows Journey AC 084 TLV ? VDA as the claimed flight
  And the Flight Status is "DELAYED (6 hours)"
  And the Eligibility section shows Journey = AC 084 TLV ? VDA
  And the Flight Leg at Fault is AC 084
  And the Operating Carrier is AC
  And the Disruption Reason is "UNKNOWN � no Departure delay code populated"
  And the Delay Minutes is 360 min (6 hours)
  And the Travel Status is "Travelled (delayed)"
  And the Passenger Type is "Regular"
  And the Geographic Check is "PASSED ? (TLV ? VDA = Israel ? Israel)"
  And the Controllability is "NOT APPLICABLE (ASL doesn't check � but code still needed for validation)"
  And the 14-Day RE Retrigger is "COMPLETED � code still not populated"
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-ASL-ND-03"
  And the Agent Action Required is "Manually investigate disruption cause � contact operations for Departure delay code. Code needed for audit trail and claim validation even though ASL doesn't check controllability."
  And all other data is available (operating times, carrier, delay calculation, geographic check) � ONLY the Departure delay code is missing
  And the Receipt Validator SOC Expense Line Items is "N/A (pending manual determination)"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource is NOT triggered
  And the Current Status is "Assigned (Manual Review Queue)" and the case is NOT in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-ASL-ND-03 � Missing Delay Code ASL No Determination
  Given the case SoC-ASL-ND-03 has No Determination
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
SoC-ASL-ND-03. NO DETERMINATION. No Departure delay code available after 14-day RE retrigger. Case created for manual review.