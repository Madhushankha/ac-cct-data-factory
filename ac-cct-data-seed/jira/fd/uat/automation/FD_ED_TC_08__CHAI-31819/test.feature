Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto was delayed 7 hours due to a crew issue. I'd like to check if I'm eligible for compensation"
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
And the user provides "Vincent Larose"
Then the chatbot responds:
"Thanks, Vincent! And, what is your booking reference number?"
And the user provides "PNR: TC226"
Then the chatbot searches Trip Tracer for PNR: TC226
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05) � OTP SUCCESS:
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: v***@gmail.com
� Phone: +1***567
And the user selects "Email: v***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "518293"
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
� Vincent Larose (Adult - Aeroplan Member)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 422
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: June 2, 2026
� Arrival Delay: 7 hours
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
And DDS Evaluates and sends to Trip Tracer UI:

TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC226
? Promised Itinerary - Flight: AC 422, Route: YUL ? YYZ, Scheduled Arrival: 10:00
? Current Itinerary - Flight: AC 422, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 17:00, Delay: +7H 00M (6�<9h band)
? Regime: APPR (Canadian origin � YUL)
? MSL FLIGHT: AC 422 � YUL ? YYZ � 64
? CONTROLLABLE (Code 64 � Flight Crew Shortage)
? APPR: Delay 6�9h, Controllable ? ELIGIBLE (Tier 2)
? Aeroplan: 9876543210 (Basic Member � linked)
Flight Compensation:
? MR VINCENT LAROSE | ELIGIBLE | APPR_6_TO_LT_9_HOURS | CAD $700 Cash / CAD $840 AC Wallet (+20%) | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected at this stage)
And the customer is cleared to proceed to payment

ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 422 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7 hours due to a crew shortage. Based on the Canadian Air Passenger Protection Regulations (APPR), you are eligible for compensation for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."

CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada"
Then the system determines: Country = Canada ? Currency = CAD

CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (Aeroplan #: 9876543210, Status: Basic Member)
Then the chatbot checks: Aeroplan account in good standing? ? YES
Then the chatbot offers BOTH options:
"Since you are an Aeroplan member, you can choose to receive:
� Cash: $700 CAD will be sent via Interac e-Transfer and takes 5 to 10 business days to process.
� AC Wallet: $840 CAD (including a 20% bonus) will be added to your AC Wallet immediately and has no expiry.
How would you like to receive your funds?"
And the user selects "Cash"
Then the system determines: Customer selected Cash ? Payment method = Interac e-Transfer (Canada)

PAYMENT METHOD � INTERAC E-TRANSFER (FD-07):
Then the chatbot responds:
"Your payment will be made through Interac e-Transfer. Before we move forward, please confirm the email address where you'd like to receive the transfer."
And the user provides "vincent.larose@gmail.com"
Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded."
Then system checks that IDV is not completed

IDENTITY VERIFICATION AT PAYOUT � PERSONA (FD-07b) � IDV FAILURE:
Then the chatbot responds:
"I must verify your identity for payment security. Please click here to get started"
And chatbot displays a button "Get verified"
When user clicks on the button
Then system checks if IDV at Payment
Then system checks if user have consented to IDV
And the chatbot sends Persona IDV link to the customer
And the customer opens the Persona link

PERSONA IDV PROCESS � FAILURE AT PAYOUT:
And the customer attempts all steps:
? ID Type: Canadian Passport
? Front of ID: Uploaded � GLARE / PARTIALLY UNREADABLE
? Selfie: Captured � FACE MISMATCH (selfie does not match passport photo)
And Persona evaluates:
? Document Quality: MARGINAL (glare on key fields)
? Face Match: FAIL (confidence score 42% � below 80% threshold)
? Overall Result: IDV FAIL
And Persona returns: IDV FAIL (reason: face mismatch + document quality marginal)

IDV FAILURE AT PAYOUT ? COMPENSATION HELD + FRAUD FLAG:
Then the system determines: IDV FAILED AT PAYOUT STAGE
And the system takes the following actions:
? Compensation: HELD ($700 CAD payment NOT released)
? Case Status: FLAGGED FOR FRAUD REVIEW
? Fraud Flag Reason: IDV failure at payout (face mismatch � potential identity fraud)
? Payment Status: BLOCKED pending fraud review
? Case routed to: Fraud Review Team
Then the chatbot responds:
"I'm sorry, but we were unable to verify your identity for payment processing. Your claim has been approved, but the payment cannot be released until your identity is verified. Your case has been forwarded to our team for further review. They will contact you to complete the verification process."
And the chatbot provides:
� Case Reference number
� Status: "Claim approved � payment held pending identity verification"
� Next steps: "Our team will contact you within 15 business days"

CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted. Please check your email for a confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submitted � payment pending verification."
And the system appends the booking record to the case automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Compensation Held notification email is sent to v***@gmail.com
And the email contains:
Subject: "Your Air Canada claim � Payment pending verification � [CASE-REF]"
� Case Reference number
� Flight details (YUL ? YYZ, delayed 7h, Code 64 Flight Crew Shortage)
� Eligibility: APPROVED ($700 CAD APPR Tier 2)
� Payment Status: HELD � pending identity verification
� Reason: "We were unable to verify your identity during the payment process."
� Next steps: "Our team will contact you within 15 business days to complete verification."
� Contact information for further questions

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
� Status: Eligible � Payment Held (Fraud Review)
� Created: [date populated]
� Last updated at: [date populated]
� SLA: tracking correctly (15 business days)
� Team: Fraud Review

CASE OVERVIEW:
� Claimant Name: Vincent Larose
� Authentication (OTP): PASS (1st attempt)
� IDV at Auth: NOT REQUIRED (OTP passed)
� IDV at Payout: FAIL (face mismatch + document quality marginal)
� Persona Failure Reason: Face match 42% (below 80% threshold), document glare
� CyberSource: GREEN (passed fraud screening)
� Payment Status: BLOCKED
� Fraud Flag: YES (IDV failure at payout)
� Compensation: $700 CAD � HELD ($840 AC Wallet option logged but not selected)
� PNR: TC226
� Regime: APPR
� Disruption Reason: Code 64 (Flight Crew Shortage � Controllable)
� Arrival Delay: 7 hours (6�<9h band, APPR Tier 2)

PASSENGER INFORMATION:
� Full Name: Vincent Larose
� Aeroplan: 9876543210 (linked, Basic Member in good standing)
� Tier Status: Basic / Member
� Tags: Claimant, Adult, Fraud Flag
� Email: v***@gmail.com
� Phone: +1***567
� Address: [populated]

ITINERARY:
� Journey: Bound 1: YUL ? YYZ (AC 422, DELAYED +7h, 6�<9h band)

ELIGIBILITY AND COMPENSATION:
� Eligibility: ELIGIBLE ($700 CAD Cash / $840 CAD AC Wallet)
� Payment: HELD ($700 CAD Interac payment blocked due to IDV fail at payout)
� Fraud Review: PENDING