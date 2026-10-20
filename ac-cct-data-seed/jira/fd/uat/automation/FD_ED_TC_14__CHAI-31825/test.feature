Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto was delayed 4 hours due to a crew issue. I was travelling with my baby. Can I get compensation for both of us?"
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
And the user provides "Sarah Miller"
Then the chatbot responds:
"Thanks, Sarah! And, what is your booking reference number?"
And the user provides "PNR: TC234"
Then the chatbot searches Trip Tracer for PNR: TC234
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: s***@gmail.com
� Phone: +1***678
And the user selects "Email: s***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "482917"
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
"I found 2 passengers on this booking:
� Sarah Miller (Adult)
� Baby Miller (Infant � No Seat, DOB: January 2025)
Who would you like to include?"
And the user selects both passengers
Then the chatbot checks: PAX count on PNR = 2 ? ?9 ? NOT a group booking ? PROCEED
INFANT CHECK:
Then the system checks passenger types:
? Sarah Miller: Adult ? ELIGIBLE for assessment
? Baby Miller: INFANT WITHOUT SEAT (DOB: January 2025, age ~17 months, lap infant, no seat assigned) ? NOT ELIGIBLE
Then the system notes: Only Sarah Miller (Adult) is eligible for compensation assessment; Baby Miller (Infant No Seat) is excluded per APPR regulations
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 422
� Route: Montreal (YUL) ? Toronto (YYZ)
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
Then the system determines: Origin = YUL (Canada) ? APPR
And the system checks: Distance YUL?YYZ = ~505 km ? Short-haul
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC234
? Promised Itinerary - Flight: AC 422, Route: YUL ? YYZ, Scheduled Arrival: 10:00
? Current Itinerary - Flight: AC 422, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 14:00, Delay: +4H 00M
? Regime: APPR (Canadian origin � YUL)
? Distance: ~505 km ? Short-haul
? MSL FLIGHT: AC 422 � YUL ? YYZ � 42
? CONTROLLABLE (Code 42)
? Passenger 1: MS SARAH MILLER (Adult) ? ELIGIBLE
? Passenger 2: BABY MILLER (Infant � No Seat, DOB: Jan 2025) ? NOT ELIGIBLE (Infant No Seat)
? APPR: Delay 3�6h, Controllable, Short-haul ? ELIGIBLE (adult only)
? Compensation: CAD $400 (Sarah Miller only)
Flight Compensation:
? MS SARAH MILLER | ELIGIBLE | APPR_3_TO_6_HOURS | CAD $400
? BABY MILLER | NOT ELIGIBLE | INFANT_NO_SEAT | CAD $0
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening (for eligible adult only)
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
ELIGIBLE/NOT ELIGIBLE MIXED RESULT:
Then the chatbot displays:
"I've checked your flight details. Flight AC 422 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours.
For Sarah Miller: Based on the Canadian Air Passenger Protection Regulations (APPR), you may be eligible for compensation of $400 CAD for this delay.
For Baby Miller: Unfortunately, infants travelling without their own seat are not eligible for compensation under the applicable regulations."
CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada"
Then the system determines: Country = Canada ? Currency = CAD
CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot checks if the claim is for multiple pax ? No (only 1 eligible pax � Sarah Miller)
Then the chatbot responds: "Sarah Miller is entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency."
And user provides "Yes"
Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada)
PAYMENT METHOD � INTERAC E-TRANSFER (FD-07):
Then the chatbot responds:
"Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer."
And the user provides "sarah.miller@gmail.com"
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
Sarah Miller: $400 CAD
Baby Miller: Not eligible (infant without seat)
Total Deposit Amount: $400 CAD
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
And notification email is sent to s***@gmail.com
And the email contains: Case Reference, compensation details (Sarah: $400 CAD eligible; Baby: not eligible � infant no seat), regulation (APPR), flight details, next steps, tracking link
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
� Regime: APPR
PASSENGER INFORMATION
� Sarah Miller: Tags: Claimant, Adult � ELIGIBLE ($400 CAD)
� Baby Miller: Tags: Infant, No Seat, DOB: Jan 2025 � NOT ELIGIBLE
ITINERARY
� Journey: Bound 1: YUL ? YYZ (DELAYED +4h) (Claim filed for this flight)
ELIGIBILITY AND COMPENSATION
� Sarah Miller: ELIGIBLE � $400 CAD
� Baby Miller: NOT ELIGIBLE � Infant without seat

Expected Results:
Infant without seat identified; Clear messaging about infant ineligibility under APPR; Adult claim proceeds normally; Compensation for adult only ($400); Infant exclusion reason logged (INFANT_NO_SEAT); Dashboard shows both passengers with individual eligibility status