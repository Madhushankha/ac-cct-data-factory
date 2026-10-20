Given the user opens the agentic chatbot
And the user is LOGGED INTO THEIR AEROPLAN PROFILE (active session detected)
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
IDENTIFICATION (GenUC-01) � AEROPLAN LOGIN DETECTED:
Then the chatbot detects: AEROPLAN SESSION ACTIVE (Aeroplan #: 1234567890)
And the chatbot responds:
"I can see you're logged into your Aeroplan account. Let me pull up your information."
And the system automatically retrieves: Customer name, Aeroplan number, associated PNRs
And the system identifies: Aeroplan #1234567890 ? Customer: "Sophie Tremblay"
And the chatbot responds:
"Hi Sophie! I can see your Aeroplan profile. What is your booking reference number?"
And the user provides "PNR: TC220"
Then the chatbot searches Trip Tracer for PNR: TC220
And Trip Tracer returns: PNR FOUND
And Trip Tracer validates: Aeroplan #1234567890 matches PNR TC220 ? AEROPLAN MATCH CONFIRMED
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION � OTP BYPASSED:
Then the system checks: Is customer authenticated via Aeroplan login? ? YES (active session)
Then the system determines: OTP AUTHENTICATION BYPASSED � Aeroplan login provides sufficient identity verification
Then the chatbot responds:
"Since you're already logged into your Aeroplan account, we've verified your identity. Let's proceed to the next step."
NOTE: GenUC-05 (OTP flow) is ENTIRELY SKIPPED � no OTP sent, no OTP entry, no OTP validation
GROUP BOOKING CHECK:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
And system proceeds to passenger selection
PASSENGER SELECTION (GenUC-06):
Then the chatbot asks:
"How many people are on your claim?"
And the chatbot displays passengers from PNR:
"I found 1 passenger on this booking:
� Sophie Tremblay (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 103
� Route: Toronto (YYZ) ? Vancouver (YVR)
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
Then the system determines: Origin = YYZ (Canada) ? APPR
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC220
? Identification Method: AEROPLAN LOGIN (Session Active)
? Aeroplan #: 1234567890
? OTP: BYPASSED (Aeroplan login authentication)
? Promised Itinerary - Flight: AC 103, Route: YYZ ? YVR, Scheduled Arrival: 14:00
? Current Itinerary - Flight: AC 103, Route: YYZ ? YVR, Status: ARRIVED LATE, Actual: 18:00, Delay: +4H 00M
? Regime: APPR (Canadian origin � YYZ)
? MSL FLIGHT: AC 103 � YYZ ? YVR � 42
? CONTROLLABLE (Code 42)
? APPR: Delay 3�6h, Controllable ? ELIGIBLE
? Compensation: CAD $400
? Aeroplan Account: ACTIVE (not frozen) ? AC Wallet eligible
Flight Compensation:
? MS SOPHIE TREMBLAY | ELIGIBLE | APPR_3_TO_6_HOURS | CAD $400
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
CASH vs AC WALLET CHECK (FD-06a) � AEROPLAN ACTIVE:
Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (Aeroplan #: 1234567890)
Then the chatbot checks: Is Aeroplan account active (not frozen)? ? YES
Then the chatbot checks if the claim is for multiple pax ? No
Then the chatbot responds:
"You are entitled to receive a $400 CAD compensation. You can choose to receive this as:
� Cash � $400 CAD via Interac e-Transfer (5�10 business days)
� AC Wallet � $480 CAD in AC Wallet credits Which would you prefer?"
And the user selects "AC Wallet"
AC WALLET PAYOUT (FD-06a):
Then the chatbot confirms:
"Great choice! You'll receive $480 CAD in AC Wallet credits, which will be available in your Aeroplan account immediately after processing."
And the system records: Payment method = AC Wallet; Amount = $480 CAD; Aeroplan #: 1234567890
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
Deposit Amount: $480 CAD
Payment Method: AC Wallet (Aeroplan #: 1234567890)
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
And an eligible notification email is sent to the customer's email on file
And the email contains: Case Reference, compensation amount ($480 CAD AC Wallet credits), payment method (AC Wallet), Aeroplan number, regulation (APPR), flight details, authentication method (Aeroplan login � OTP bypassed), next steps, tracking link
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
� Identification Method: Aeroplan Login (OTP Bypassed)
� Aeroplan #: 1234567890
� Payment Method: AC Wallet ($480 CAD)
� Regime: APPR

Expected Results:
Customer identified via Aeroplan login session; OTP/IDV completely bypassed; AC Wallet offered and selected; EAP check confirms account active; Payment deposited to Aeroplan; Authentication method logged as "Aeroplan Session"; DDS: FD-APPR-EL-01