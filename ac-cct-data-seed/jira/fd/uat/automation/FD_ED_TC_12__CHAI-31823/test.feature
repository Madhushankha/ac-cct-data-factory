Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
MULTIPLE INTENTS IN ONE MESSAGE:
And the user says "My flight from Toronto to Vancouver was delayed 5 hours and I had to pay for a hotel. I also need to know about wheelchair assistance for my next flight. Can you help with all of this?"
INTENT DETECTION � MULTIPLE INTENTS DETECTED:
Then the chatbot's intent detection engine analyzes the input:
? Intent 1: Flight Disruption Compensation (flight delayed 5 hours ? FD claim) � PRIORITY: HIGH
? Intent 2: Expense Reimbursement (hotel expense due to disruption) � PRIORITY: MEDIUM
? Intent 3: Accessibility FAQ (wheelchair assistance for next flight) � PRIORITY: LOW
? Multiple Intents Detected: YES (3 intents)
? Prioritization: FD Compensation (HIGH) ? Expense Claim (MEDIUM) ? Accessibility FAQ (LOW)
INTENT ACKNOWLEDGMENT + PRIORITIZATION:
Then the chatbot responds:
"I can see you have a few things you need help with. Let me address them one at a time:
1
2
3
Let's start with your flight compensation claim."
INTENT 1 � FD COMPENSATION (HIGHEST PRIORITY):
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."
LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"
IDENTIFICATION (GenUC-01):
Then the chatbot responds:
"I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "James Chen"
Then the chatbot responds:
"Thanks, James! And, what is your booking reference number?"
And the user provides "PNR: TC230"
Then the chatbot searches Trip Tracer for PNR: TC230
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: j***@gmail.com
� Phone: +1***789
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
� James Chen (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 103
� Route: Toronto (YYZ) ? Vancouver (YVR)
� Date: June 1, 2026
� Arrival Delay: 5 hours
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
Then the tester opens Trip Tracer UI for PNR: TC230
? Regime: APPR
? MSL FLIGHT: AC 103 � YYZ ? YVR � 42
? CONTROLLABLE (Code 42)
? APPR: Delay 3�6h, Controllable ? ELIGIBLE
? Compensation: CAD $400
Flight Compensation:
? MR JAMES CHEN | ELIGIBLE | APPR_3_TO_6_HOURS | CAD $400
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 103 from Toronto (YYZ) to Vancouver (YVR) was delayed by about 5 hours. Based on the Canadian Air Passenger Protection Regulations (APPR), you may be eligible for compensation of $400 CAD for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."
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
And the user provides "james.chen@gmail.com"
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
FD COMPENSATION COMPLETE � TRANSITION TO INTENT 2:
Then the chatbot responds:
"Great, your flight compensation claim has been submitted! Now let's take care of your hotel expense. ? 1/3 complete"
INTENT 2 � EXPENSE REIMBURSEMENT (MEDIUM PRIORITY):
Then the chatbot responds:
"You mentioned you had to pay for a hotel due to the delay. I can help you submit that expense for reimbursement. Please upload your hotel receipt (PDF, JPG, or PNG format, max 10MB)."
And the user uploads: Hotel_Receipt_TC230.pdf
Then the chatbot confirms:
"Thank you. I've attached your hotel receipt to your case [CASE-REF]. Our team will review the expense as part of your claim. Hotel expenses related to flight disruptions may be eligible for reimbursement under APPR."
And the chatbot responds:
"Could you confirm the hotel expense amount?"
And the user provides "$189.50 CAD"
Then the chatbot confirms:
"Thank you. Hotel expense of $189.50 CAD has been added to your case for review. ? 2/3 complete"
INTENT 2 COMPLETE � TRANSITION TO INTENT 3:
Then the chatbot responds:
"Now let me help you with your question about wheelchair assistance."
INTENT 3 � ACCESSIBILITY FAQ (LOW PRIORITY):
Then the chatbot responds:
"Air Canada offers wheelchair assistance and other accessibility services for passengers who need them. Here's what you need to know:
� Requesting wheelchair assistance: You can request wheelchair assistance when booking your flight, or by contacting Air Canada at least 48 hours before departure
� At the airport: Wheelchair assistance is available from check-in through boarding, and from arrival through baggage claim
� On board: If you need assistance during the flight, our cabin crew is trained to help
� Special equipment: If you have your own wheelchair or mobility device, Air Canada will transport it free of charge
For your next flight, I recommend requesting wheelchair assistance at least 48 hours in advance. You can do this through:
� Air Canada website (Manage My Booking)
� Air Canada app
� Calling Air Canada Accessibility Services at 1-800-xxx-xxxx
Is there anything specific about wheelchair assistance you'd like to know more about?"
And the user responds "No, that covers it. Thank you!"
ALL INTENTS COMPLETE:
Then the chatbot responds:
"Great! Here's a summary of everything we covered today:
? Flight compensation claim � Submitted (Case [CASE-REF], $400 CAD via Interac e-Transfer)
? Hotel expense � Attached to your case ($189.50 CAD, pending review)
? Wheelchair assistance � Information provided for your next flight
Is there anything else I can help you with?"
END FLOW (GLOB-11):
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to j***@gmail.com
And the email contains: Case Reference, compensation amount ($400 CAD), hotel expense ($189.50 CAD attached), regulation (APPR), flight details, next steps, tracking link
CLAIMS DASHBOARD VALIDATION:
When the agent navigates to Claims Dashboard
And the agent searches for the case by PNR
Then the dashboard displays:
� Case Title: "Travel Disruptions � Delay"
� Status: in review/done
� Regime: APPR
� Intents Handled: 3 (FD Compensation, Expense Reimbursement, Accessibility FAQ)
ATTACHMENTS
� Hotel_Receipt_TC230.pdf ($189.50 CAD)
ELIGIBILITY AND COMPENSATION
� Flight Compensation: $400 CAD (ELIGIBLE)
� Hotel Expense: $189.50 CAD (pending review)
INTENT PRIORITIZATION VALIDATION:
? Intent 1 (HIGH): FD Compensation ? processed FIRST ?
? Intent 2 (MEDIUM): Expense Reimbursement ? processed SECOND ?
? Intent 3 (LOW): Accessibility FAQ ? processed THIRD ?
? All 3 intents detected from single message ?
? Priority order respected ?
? Sequential processing (not parallel) ?
? No context loss between intents ?
? Summary provided at end ?

Expected Results:
All 3 intents detected from single message; Priority order applied (FD > Expense > Accessibility); FD compensation processed first with full flow; Expense claim processed second with receipt upload; Accessibility handled as FAQ (no case); Two cases created and linked; Single continuous session; All transitions logged 