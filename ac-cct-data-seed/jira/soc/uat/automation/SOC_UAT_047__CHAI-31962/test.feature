Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My Air Canada flight from Frankfurt to Toronto was delayed by about 8 hours because of a crew scheduling issue. I had to buy food, pay for a hotel, and take a taxi. Can I get reimbursed?"
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
� Flight: AC 837
� Route: Frankfurt (FRA) ? Toronto (YYZ)
� Date: June 14, 2026
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
Then the chatbot checks: Filing deadline for EU SOC per departing country
And the system calculates:
� Departing country: Germany ? Limitation = 1,460 days (4 years)
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
? Single-segment trip FRA?YYZ on AC837 was delayed +8H 00M due to weather (uncontrollable � NOT CHECKED under EU)
? Regime: EU (FRA departure)
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 837, Route: FRA ? YYZ, Scheduled Dep: 22-Jun 10:00
? Current Itinerary � Flight: AC 837, Route: FRA ? YYZ, Status: ARRIVED LATE, Scheduled Dep: 10:00 ? Actual: 17:00, Delay: +7H 00M (note: prereqs say 420 min/7h, chatbot says 8h � use prereqs)

Standards of Care (1):
? SOC section present
? Departure Delay Code: 77 (Weather) � NOT CHECKED (EU does not evaluate controllability)
? PASSENGER: [Name] | STATUS: ELIGIBLE | BAND: DELAY_6_HOURS_OR_MORE | MEAL: �30.00 | ACCOMMODATION: Rate of day (max �500) | GENERAL EXPENSES: Transport �200 + Comm �30 + Parking �50 + Essentials �30 | EXPIRES: [date]
? CyberSource: YELLOW ?? � Case PARKED in fraud queue
? Fraud queue: Case visible to fraud team only. Agent cannot see CyberSource result.
? Passenger NOT informed of fraud flag � receives generic "being processed" message.
? Welcome Back email: NOT SENT (held until fraud team clears)

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: ELIGIBLE (parked � pending fraud review)
? Post-fraud-clear: If cleared ? Welcome Back email ? receipt upload ? normal flow
? Post-fraud-confirm: If confirmed fraud ? rejection email ? case closed

DDS RESPONSE CODE = SoC-EU-EL-07

Then the chatbot checks which airline company is it ? AC

FRAUD SCREENING � CYBERSOURCE (GLOB-05):  YELLOW RESULT
Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger)
And CyberSource evaluates the claim
And CyberSource returns: YELLOW  (potential fraud indicators detected)

 CYBERSOURCE YELLOW � CASE PARKED IN FRAUD QUEUE:
� YELLOW means: suspicious but not confirmed fraud
� Case is PARKED in the CyberSource/Fraud queue
� Agent CANNOT see the CyberSource result � it's invisible to them
� The case appears in the fraud team's queue for review
� The passenger does NOT receive the Welcome Back email yet
� The passenger is NOT told about the fraud flag

WHAT THE PASSENGER SEES:
The chatbot does NOT mention fraud. Instead, it displays a generic processing message.

Then the chatbot displays: "Thank you for your patience. We've reviewed the details of your flight AC 837 from Frankfurt to Toronto and confirmed your eligibility for expense reimbursement. Your case is currently being processed. You will receive an email with instructions to upload your receipts shortly."

NOTE: The "shortly" is intentionally vague � the fraud review may take hours or days.

WHAT HAPPENS BEHIND THE SCENES:
� Case is created with ELIGIBLE status but PARKED in fraud queue
� Fraud team reviews the CyberSource indicators
� If fraud team CLEARS the case:
  ? Welcome Back email sent to passenger
  ? Passenger uploads receipts ? normal flow continues
� If fraud team CONFIRMS fraud:
  ? Rejection email sent to passenger
  ? Case closed with CyberSource rejection status
  ? Passenger can dispute ? goes to manual handling

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-EU-EL-07 � EU Eligible CyberSource Yellow Fraud Queue
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "In Fraud Queue" (visible to fraud team + management ONLY; regular agents see "In Progress")
  And the Created date and Last Updated date are populated
  And the SLA countdown is tracking correctly
  And the Team assignment is "Fraud Review Team"
  And no banners are visible to regular agents (fraud flag is invisible to them)
  And the Decision Assist panel is NOT greyed out
  And the Claimant Name is populated
  And the Claimant Type is "Regular"
  And the Authentication is "Pass"
  And the PNR is populated
  And the Regime is "EU (EC 261/2004)"
  And the Full Name is populated
  And the Tags include "Claimant" and "Adult"
  And the Email is "t***@gmail.com"
  And the Phone is "+1***789"
  And the Itinerary shows Journey AC 837 FRA ? YYZ as the claimed flight
  And the Flight Status is "DELAYED (8 hours)"
  And the Eligibility section shows Journey = AC 837 FRA ? YYZ
  And the Flight Leg at Fault is AC 837
  And the Operating Carrier is AC
  And the Disruption Reason is "Crew Scheduling (Code 41)"
  And the Delay Minutes is 480 min (8 hours)
  And the Travel Status is "Travelled (delayed Departure)"
  And the Passenger Type is "Regular"
  And the Geographic Check is "PASSED ? (FRA = Germany, EU origin)"
  And the Controllability is "NOT CHECKED (EU regime)"
  And the Overnight Eligible is "YES (delay >360 min)"
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-EU-EL-07"
  And the Fraud Screening is "CyberSource YELLOW"
  And the status is "PARKED in fraud queue"
  And the Fraud Team Action Required is: if CLEARED then send Welcome Back email then receipt upload then payment; if CONFIRMED fraud then rejection email then case closed
  And the agent CANNOT see CyberSource result � invisible to regular agents
  And the passenger is NOT told about fraud flag � sees generic "being processed" message
  And the Eligibility is "ELIGIBLE (pending fraud clearance)"
  And the Receipt Validator SOC Expense Line Items is "N/A (pending fraud clearance � Welcome Back not yet sent)"
  And the Applicable Regimes SOC Amount is "N/A (pending)"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource result is "YELLOW"
  And the case Status is "In Fraud Queue (PARKED) � visible to fraud team + management only; regular agents see In Progress"

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-EU-EL-07 � EU Eligible CyberSource Yellow Fraud Queue
  Given the case SoC-EU-EL-07 is PARKED in fraud queue
  Then the case is awaiting fraud review
  And no receipts are uploaded (Welcome Back not sent � pending fraud clearance)
  And no compensation record is created yet
  And the route is AC 837 FRA ? YYZ with delay 480 min (8 hrs) for 1 adult PY
  And the entitlements if cleared are Meals �30, Hotel rate of day/�500, Transport �200, Comm �30, Parking �50, Essentials �30
  And if the fraud team CLEARS then Welcome Back email is sent and receipt upload and normal payment flow resume with SOC as CASH ONLY
  And if fraud is CONFIRMED then rejection email is sent and case is closed with no payment
  And the Claims Dashboard shows case status as "In Fraud Queue" for fraud team and "In Progress" for regular agents

EXPECTED RESULTS:
SoC-EU-EL-07. ELIGIBLE. Transit delay ?2h (7 hours,  category). Controllability NOT checked � this is the key EU regime difference. Same scenario under APPR with weather + regular pax = NOT ELIGIBLE (NE-07). Under EU = ELIGIBLE regardless of disruption type. Entitlements in EUR. Full receipt + case flow.