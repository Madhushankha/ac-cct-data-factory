Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
INTENT 1 � FAQ QUESTION:
And the user says "I got an email saying my flight was disrupted and I might be eligible for compensation. What does that mean?"
INTENT DETECTION � FAQ:
Then the chatbot's intent detection engine analyzes the input:
? Detected Intent: FAQ / Information Request (customer asking about disruption notification meaning)
? Confidence: HIGH
? Routing: FAQ Response
FAQ RESPONSE:
Then the chatbot responds:
"When your flight is delayed, cancelled, or disrupted, you may be entitled to compensation under applicable air passenger protection regulations. The amount depends on several factors including:
� The length of the delay at your final destination
� The reason for the disruption (within or outside the airline's control)
� The applicable regulation based on your route
If you received a notification about a disruption, it means our records show your flight was affected. You can file a claim through this chatbot to check your eligibility and, if applicable, receive compensation.
Would you like to file a compensation claim now?"
INTENT SWITCH � FAQ TO FD COMPENSATION:
And the user says "Yes, I want to claim compensation for my delayed flight"
INTENT DETECTION � INTENT SWITCH:
Then the chatbot's intent detection engine analyzes the input:
? Previous Intent: FAQ / Information Request (completed)
? New Intent: Flight Disruption Compensation (customer wants to file a claim)
? Intent Transition: FAQ ? FD Compensation
? Context Preserved: YES (customer already mentioned disruption notification)
? Re-greeting: NO (do not re-greet � seamless transition)
SEAMLESS TRANSITION TO FD COMPENSATION FLOW:
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."
NOTE: No re-greeting. No re-display of the language selection. No re-display of the privacy notice. Seamless transition from FAQ to FD flow.
LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"
IDENTIFICATION (GenUC-01):
Then the chatbot responds:
"I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Chantal B�langer"
Then the chatbot responds:
"Thanks, Chantal! And, what is your booking reference number?"
And the user provides "PNR: TC229"
Then the chatbot searches Trip Tracer for PNR: TC229
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: c***@gmail.com
� Phone: +1***678
And the user selects "Email: c***@gmail.com"
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
� Chantal B�langer (Adult)
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
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC229
? Intent Flow: FAQ ? FD Compensation (intent switch)
? Context Loss: NONE ?
? Re-greeting: NONE ?
? Regime: APPR
? Compensation: CAD $400
Flight Compensation:
? MS CHANTAL B�LANGER | ELIGIBLE | APPR_3_TO_6_HOURS | CAD $400
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 422 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours. Based on the Canadian Air Passenger Protection Regulations (APPR), you may be eligible for compensation of $400 CAD for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."
CLAIM PAYMENT ? INTERAC E-TRANSFER ? IDV ? CONFIRMATION ? CASE CREATION ? NOTIFICATION ? END FLOW:
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
And the user provides "chantal.belanger@gmail.com"
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
And an eligible notification email is sent to c***@gmail.com
And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details, next steps, tracking link
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."
INTENT TRANSITION VALIDATION:
? Intent 1: FAQ ("what does this notification mean?") ? FAQ response provided ?
? Intent Switch: Customer says "I want to claim compensation" ? detected ?
? Intent 2: FD Compensation ? routed correctly ?
? Context Loss: NONE ? (no re-greeting, no re-language selection, no re-privacy notice)
? Seamless Transition: YES ?
? Full FD flow completed successfully ?

Expected Results:
FAQ intent handled first with correct answer; Intent switch to case creation detected seamlessly; No re-greeting or duplicate privacy notice; Smooth transition to FD flow; Full eligible flow completed; Intent transition logged in transcript; Single continuous session