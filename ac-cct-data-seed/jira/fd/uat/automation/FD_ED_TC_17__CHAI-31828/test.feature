Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Toronto to Vancouver was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation"
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
And the user provides "Priya Sharma"
Then the chatbot responds:
"Thanks, Priya! And, what is your booking reference number?"
And the user provides "PNR: TC237"
Then the chatbot searches Trip Tracer for PNR: TC237
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: p***@gmail.com
� Phone: +1***456
And the user selects "Email: p***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "629184"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds:
"Your verification was successful. Let's proceed to the next step."
GROUP BOOKING CHECK � SPLIT PNR DETECTION:
Then the system checks Trip Tracer for group booking identifier
And Trip Tracer returns:
? Group booking identifier on PNR TC237: NOT PRESENT (PNR was split � group ID removed from split PNR)
? However, system checks: Originator Office ID = YYZAC1234
? System cross-references: Originator Office ID YYZAC1234 ? matches original group booking GRP-2026-0520
? System determines: SPLIT PNR FROM GROUP BOOKING
? Per call transcript: "When a group PNR is split, the originator office ID remains the same, and the booking is still considered a group booking"
SPLIT PNR � GROUP TREATMENT APPLIED:
Then the system determines: SPLIT PNR ? GROUP BOOKING TREATMENT
And the system applies group booking rules:
? Rule 1: Treat as group booking for eligibility and reporting ? ENFORCED
? Rule 2: Individual claim only (1 passenger on split PNR) ? ENFORCED
? Rule 3: Originator office ID tracked for reporting ? ENFORCED
? PAX count on split PNR = 1 ? but group treatment still applies due to originator office ID
PASSENGER SELECTION (GenUC-06):
Then the chatbot displays:
"I found 1 passenger on this booking:
� Priya Sharma (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
NOTE: Since the split PNR has only 1 passenger, the display looks like a normal individual booking. The group treatment is applied in the backend for eligibility and reporting purposes � the customer experience is seamless.
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 103
� Route: Toronto (YYZ) ? Vancouver (YVR)
� Date: June 2, 2026
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
Then the system determines: Origin = YYZ (Canada) ? APPR
And the system checks: Distance YYZ?YVR = ~3,350 km ? Long-haul (domestic)
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC237
? PNR Type: SPLIT PNR (split from group GRP-2026-0520)
? Originator Office ID: YYZAC1234 (same as original group)
? Group Treatment: APPLIED (despite split)
? Passengers on Split PNR: 1 (Priya Sharma)
? Promised Itinerary - Flight: AC 103, Route: YYZ ? YVR, Scheduled Arrival: 14:00
? Current Itinerary - Flight: AC 103, Route: YYZ ? YVR, Status: ARRIVED LATE, Actual: 18:00, Delay: +4H 00M
? Regime: APPR (Canadian origin � YYZ)
? MSL FLIGHT: AC 103 � YYZ ? YVR � 42
? CONTROLLABLE (Code 42)
? APPR: Delay 3�6h, Controllable ? ELIGIBLE
? Compensation: CAD $400
Flight Compensation:
? MS PRIYA SHARMA | ELIGIBLE | APPR_3_TO_6_HOURS | CAD $400
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment
ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 103 from Toronto (YYZ) to Vancouver (YVR) was delayed by about 4 hours. Based on the Canadian Air Passenger Protection Regulations (APPR), you may be eligible for compensation of $400 CAD for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."
CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada"
Then the system determines: Country = Canada ? Currency = CAD
CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency."
And user provides "Yes"
Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada)
PAYMENT METHOD � INTERAC E-TRANSFER (FD-07):
Then the chatbot responds:
"Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer."
And the user provides "priya.sharma@gmail.com"
Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded."
Then system checks that IDV is not completed
IDENTITY VERIFICATION � PERSONA (FD-07b):
Then the chatbot responds:
"I must verify your identity for payment security. Please click here to get started"
And chatbot displays a button "Get verified"
When user clicks on the button
Then system checks if IDV at Payment
Then system checks if user have consented to IDV
And the chatbot sends Persona IDV link to the customer
And the customer opens the Persona link
And the customer completes identity verification via Persona
And Persona returns: IDV PASS
Then the chatbot responds:
"Your identity has been verified successfully. Let's proceed to finalize your claim."
CLAIM AMOUNT CONFIRMATION FLOW:
Then the chatbot responds: "Please review your compensation details:
Deposit Amount: $400 CAD
Payment Method: Interac e-Transfer
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps.
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user provides: "Yes"
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to p***@gmail.com
And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details, next steps, tracking link
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
� Status: in review/done
� PNR Type: SPLIT PNR (from group GRP-2026-0520)
� Originator Office ID: YYZAC1234 (group origin)
� Group Treatment: APPLIED
� Regime: APPR
SPLIT PNR VALIDATION:
? Split PNR detected via originator office ID: YES ?
? Originator office ID matches original group: YES (YYZAC1234) ?
? Group treatment applied: YES ?
? Individual claim processed: YES ?
? Customer experience seamless (no mention of group/split): YES ?
? Reporting tagged as group-origin: YES ?

Expected Results:
Split PNR detected via originator office ID matching group office; Treated as group booking (individual claim only); Full eligible flow completed; Group origin and original group ID logged in dashboard