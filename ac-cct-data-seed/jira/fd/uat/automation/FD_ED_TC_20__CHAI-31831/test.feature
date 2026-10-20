Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."
LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"
IDENTIFICATION (GenUC-01):
Then the chatbot responds:
"I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Jean-Pierre Martin"
Then the chatbot responds:
"Thanks, Jean-Pierre! And, what is your booking reference number?"
And the user provides "PNR: TC240"
Then the chatbot searches Trip Tracer for PNR: TC240
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: j***@gmail.com
� Phone: +1***678
And the user selects "Email: j***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "629184"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds:
"Your verification was successful. Let's proceed to the next step."
GROUP BOOKING CHECK:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
And system proceeds to passenger selection
PASSENGER SELECTION (GenUC-06):
Then the chatbot asks:
"How many people are on your claim?"
And the chatbot displays passengers from PNR:
"I found 1 passenger on this booking:
� Jean-Pierre Martin (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 422
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: June 1, 2026
� Arrival Delay: 4 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED
CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline ? within limitation ? PROCEED
REGIME DETERMINATION:
Then the system determines: Origin = YUL (Canada) ? APPR
And the system checks: Distance YUL?YYZ = ~505 km ? Short-haul
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates:
? APPR: Delay 3�6h, Controllable ? ELIGIBLE
? Compensation: CAD $400
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected by CyberSource)
RDS (RISK DETECTION SYSTEM) CHECK � PARALLEL TO CYBERSOURCE:
Then the system simultaneously runs RDS (Risk Detection System) checks
And RDS evaluates:
RDS FLAG 1 � GEOLOCATION MISMATCH:
? Customer's IP geolocation: Lagos, Nigeria
? Flight route: Montreal (YUL) ? Toronto (YYZ), Canada
? Mismatch: Customer claiming from Nigeria for a Canadian domestic flight
? RDS Flag: GEOLOCATION_MISMATCH � HIGH RISK
RDS FLAG 2 � MULTIPLE EMAIL USAGE:
? Email on claim: j***@gmail.com
? Same email found on: 3 other claims in past 30 days
CASE-FD-20260510-001 (YYZ?YVR, May 10, 2026)
CASE-FD-20260515-002 (YUL?YYZ, May 15, 2026)
CASE-FD-20260518-003 (YYZ?YUL, May 18, 2026)
? RDS Flag: MULTIPLE_EMAIL_USAGE � HIGH RISK
RDS OVERALL RESULT:
? RDS Flags: 2 HIGH RISK FLAGS
? RDS Decision: MANUAL REVIEW REQUIRED
RDS OVERRIDE � CYBERSOURCE GREEN OVERRIDDEN:
Then the system evaluates: CyberSource = GREEN, RDS = 2 HIGH RISK FLAGS
And the system applies the override rule:
? Per call transcript: "Any claim with an RDS flag alert should be sent to manual review or rejected, regardless of CyberSource's outcome."
? RDS FLAGS OVERRIDE CYBERSOURCE GREEN ? CASE ROUTED TO MANUAL REVIEW
? Compensation: HELD (not released)
CUSTOMER-FACING RESULT � NO ALARM:
Then the chatbot displays:
"Thank you for submitting your claim. Your claim has been received and is currently being processed. Please note that it may take up to 15 days to fully assess your eligibility. You will receive an email with the outcome of your claim once the review is complete."
And an alert information is displayed: "Claim submission successful!"
NOTE: The customer sees a standard "processing" message. The chatbot does NOT reveal the RDS flags, does NOT mention fraud concerns, and does NOT alarm the customer. The manual review happens silently in the backend.
CASE CREATION (GLOB-09):
Then the system creates the case with status: ELIGIBLE � COMPENSATION HELD (RDS Manual Review)
And the case contains:
� PNR: TC240
� Passenger: Jean-Pierre Martin
� Journey: YUL?YYZ, delayed 4h
� Regime: APPR
� DDS Decision: ELIGIBLE ($400 CAD)
� CyberSource: GREEN
� RDS Flags: GEOLOCATION_MISMATCH + MULTIPLE_EMAIL_USAGE
� RDS Decision: MANUAL REVIEW REQUIRED
� Override: RDS overrides CyberSource GREEN
� Compensation: $400 CAD � HELD
� Payment Status: BLOCKED (pending manual review)
� Case Status: Eligible � Compensation Held (RDS Review)
� Routing: Fraud Review Team / RDS Manual Review
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a standard processing notification email is sent to j***@gmail.com
And the email contains:
Subject: "Your Air Canada claim has been received � [CASE-REF]"
Case Reference number
Flight details
Status: "Your claim is being processed. We will notify you of the outcome within 15 days."
Contact information
NOTE: The notification does NOT mention RDS flags, fraud concerns, or compensation hold. Standard processing message only.
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."
CLAIMS DASHBOARD VALIDATION:
When the agent navigates to Claims Dashboard
And the agent searches for the case by PNR
Then the dashboard displays:
� Case Title: "Travel Disruptions � Delay"
� Status: Eligible � Compensation Held (RDS Review)
� Created:
� Last updated at
� SLA
� Team: Fraud Review Team
CASE OVERVIEW
� Claimant Name: Jean-Pierre Martin
� PNR: TC240
� Regime: APPR
� DDS Decision: ELIGIBLE ($400 CAD)
FRAUD SCREENING
� CyberSource: GREEN ?
� RDS Flags:
GEOLOCATION_MISMATCH � IP: Lagos, Nigeria; Flight: Canada domestic (HIGH RISK)
MULTIPLE_EMAIL_USAGE � Same email on 3 other claims in 30 days (HIGH RISK)
� RDS Decision: MANUAL REVIEW REQUIRED
� Override Applied: YES � RDS overrides CyberSource GREEN
COMPENSATION
� Amount: $400 CAD
� Payment Status: BLOCKED (pending RDS manual review)
RDS OVERRIDE VALIDATION:
? CyberSource result: GREEN ?
? RDS flags present: YES (2 high risk) ?
? Override rule applied: YES ?
? Compensation held: YES ?
? Payment blocked: YES ?
? Routed to Fraud Review Team: YES ?
? Customer alarmed: NO (standard processing message) ?
? Per call transcript rule enforced: YES ?

Expected Results:
CyberSource returns GREEN; RDS detects 3 flags (geolocation, multiple email, late booking); RDS flags OVERRIDE CyberSource GREEN; Case routed to manual review despite CyberSource GREEN; Compensation HELD; Management approval required for geolocation; Dashboard shows both CyberSource result AND RDS flags with override notation