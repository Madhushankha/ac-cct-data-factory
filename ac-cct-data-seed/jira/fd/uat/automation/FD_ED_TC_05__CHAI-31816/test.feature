Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto was delayed 7 hours due to a crew transport issue. I'd like to check if I'm eligible for compensation"
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
And the user provides "Isabelle Fournier"
Then the chatbot responds:
"Thanks, Isabelle! And, what is your booking reference number?"
And the user provides "PNR: TC223"
Then the chatbot searches Trip Tracer for PNR: TC223
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05) � OTP ATTEMPTS:
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: i***@gmail.com
� Phone: +1***345
And the user selects "Email: i***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."

OTP ATTEMPT 1 OF 5:
And the user provides the OTP code "111111"
Then the chatbot validates the OTP code ? INCORRECT (attempt 1 of 5)
Then the chatbot responds:
"The code you entered is incorrect. Please try again. You have 4 attempts remaining."

OTP ATTEMPT 2 OF 5:
And the user provides the OTP code "222222"
Then the chatbot validates the OTP code ? INCORRECT (attempt 2 of 5)
Then the chatbot responds:
"The code you entered is incorrect. Please try again. You have 3 attempts remaining."

OTP ATTEMPT 3 OF 5:
And the user provides the OTP code "333333"
Then the chatbot validates the OTP code ? INCORRECT (attempt 3 of 5)
Then the chatbot responds:
"The code you entered is incorrect. Please try again. You have 2 attempts remaining."

OTP ATTEMPT 4 OF 5:
And the user provides the OTP code "444444"
Then the chatbot validates the OTP code ? INCORRECT (attempt 4 of 5)
Then the chatbot responds:
"The code you entered is incorrect. Please try again. You have 1 attempt remaining."

OTP ATTEMPT 5 OF 5:
And the user provides the OTP code "555555"
Then the chatbot validates the OTP code ? INCORRECT (attempt 5 of 5)
Then the system determines: OTP MAXIMUM ATTEMPTS REACHED (5/5) � 24-HOUR OTP LOCKOUT ENFORCED

OTP FAILURE ? IDV OFFERED IMMEDIATELY (24-HR OTP COOLDOWN):
Then the chatbot responds:
"You've reached the maximum number of verification attempts. Don't worry � I can verify your identity another way. I'll send you a secure link to verify your identity using a government-issued ID."
NOTE: 24-hour OTP cooling period enforced. IDV is offered IMMEDIATELY after 5th OTP failure.

IDV LINK � NON-BIOMETRIC FLOW:
Then the chatbot responds:
"Please click the link below to verify your identity. You'll need a valid government-issued photo ID (passport, driver's license, or national ID card)."
And chatbot displays a button "Verify my identity"
When user clicks on the button
Then the chatbot sends Persona IDV link to the customer
And the customer opens the Persona link

PERSONA IDV PROCESS:
And the customer completes all steps:
? ID Type: Canadian Driver's License
? Front of ID: Uploaded successfully
? Back of ID: Uploaded successfully
? Selfie: Captured successfully
? Document quality: CLEAR and READABLE
? Face match: CONFIRMED (selfie matches ID photo)
And Persona returns: IDV PASS
Then the chatbot responds:
"Your identity has been verified successfully. Let's proceed to the next step."
NOTE: Customer is now authenticated via IDV (replacing OTP). Flow continues normally.

GROUP BOOKING CHECK:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
And system proceeds to passenger selection

PASSENGER SELECTION (GenUC-06):
Then the chatbot asks:
"How many people are on your claim?"
And the chatbot displays passengers from PNR:
"I found 1 passenger on this booking:
� Isabelle Fournier (Adult - Aeroplan Member)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 422
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: June 1, 2026
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
Then the tester opens Trip Tracer UI for PNR: TC223
? Authentication Method: IDV (Persona PASS) � after OTP 5x failure
? OTP Attempts: 5/5 FAILED (24-hour lockout enforced)
? IDV at Auth: PASS (Canadian Driver's License)
? Promised Itinerary - Flight: AC 422, Route: YUL ? YYZ, Scheduled Arrival: 10:00
? Current Itinerary - Flight: AC 422, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 17:00, Delay: +7H 00M (6�<9h band)
? Regime: APPR (Canadian origin � YUL)
? Distance: ~505 km ? Short-haul
? MSL FLIGHT: AC 422 � YUL ? YYZ � 67
? CONTROLLABLE (Code 67 � Crew Transport / Hotel / Logistics Delay)
? APPR: Delay 6�9h, Controllable ? ELIGIBLE (Tier 2)
? Aeroplan: 9876543210 (Basic Member � linked)
Flight Compensation:
? MS ISABELLE FOURNIER | ELIGIBLE | APPR_6_TO_LT_9_HOURS | CAD $700 Cash / CAD $840 AC Wallet (+20%) | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment

ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 422 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7 hours due to crew transport logistics. Based on the Canadian Air Passenger Protection Regulations (APPR), you are eligible for compensation for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."

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
And the user provides "isabelle.fournier@gmail.com"
Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded."

IDV AT PAYOUT � ALREADY COMPLETED:
Then system checks: Has IDV been completed? ? YES (completed during authentication phase after OTP failure)
Then system determines: IDV ALREADY PASSED � NO NEED TO REPEAT
Then the chatbot responds:
"Your identity was already verified earlier. No additional verification is needed."

CLAIM AMOUNT CONFIRMATION FLOW:
Then the chatbot responds: "Please review your compensation details:
Deposit Amount: $700 CAD
Payment Method: Interac e-Transfer (isabelle.fournier@gmail.com)
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps.
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user provides: "Yes"

CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to i***@gmail.com
And the email contains: Case Reference, compensation amount ($700 CAD Cash), regulation (APPR), flight details (YUL?YYZ AC 422, delayed 7h, Code 67 Crew Transport Delay), authentication method (IDV after OTP 5x failure), next steps, tracking link

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
� Status: In Review / Done
� Authentication: IDV (Persona PASS) � after OTP 5x failure
� OTP History: 5/5 INCORRECT (24-hour lockout)
� IDV at Auth: PASS
� IDV at Payout: SKIPPED (already completed at auth stage)
� Claimant Name: Isabelle Fournier
� Aeroplan: 9876543210 (linked, Basic Member in good standing)
� Tier Status: Basic / Member
� Regime: APPR
� Disruption Reason: Code 67 (Crew Transport / Hotel / Logistics Delay � Controllable)
� Arrival Delay: 7 hours (6�<9h band, APPR Tier 2)
� Compensation: $700 CAD Cash (Interac e-Transfer selected; $840 CAD AC Wallet option offered but not selected)