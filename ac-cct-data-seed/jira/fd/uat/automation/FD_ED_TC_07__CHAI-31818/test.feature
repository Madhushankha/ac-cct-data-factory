Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto was delayed 4 hours due to crew issues. I'd like to file a compensation claim"
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
And the user provides "Laurent Pelletier"
Then the chatbot responds:
"Thanks, Laurent! And, what is your booking reference number?"
And the user provides "PNR: TC225"
Then the chatbot searches Trip Tracer for PNR: TC225
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05) � OTP ATTEMPTS:
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: l***@gmail.com
� Phone: +1***456
And the user selects "Email: l***@gmail.com"
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
Then the system determines: OTP MAXIMUM ATTEMPTS REACHED (5/5)

OTP FAILURE ? IDV OFFERED IMMEDIATELY:
Then the chatbot responds:
"You've reached the maximum number of verification attempts. Don't worry � I can verify your identity another way. I'll send you a secure link to verify your identity using a government-issued ID."

IDV LINK � NON-BIOMETRIC FLOW:
Then the chatbot responds:
"Please click the link below to verify your identity. You'll need a valid government-issued photo ID (passport, driver's license, or national ID card)."
And chatbot displays a button "Verify my identity"
When user clicks on the button
Then the chatbot sends Persona IDV link to the customer
And the customer opens the Persona link

PERSONA IDV PROCESS � FAILURE:
And the customer attempts all steps:
? ID Type: Canadian Driver's License
? Front of ID: Uploaded � BLURRY / UNREADABLE (document quality insufficient)
? Back of ID: Uploaded � PARTIALLY OBSCURED
? Selfie: Captured � FACE MISMATCH (selfie does not match ID photo sufficiently)
And Persona evaluates:
? Document Quality: FAIL (below minimum threshold � text unreadable)
? Face Match: FAIL (confidence score below threshold)
? Overall Result: IDV FAIL
And Persona returns: IDV FAIL (reason: document quality insufficient + face mismatch)

IDV FAILURE � BOTH AUTH METHODS EXHAUSTED:
Then the chatbot responds:
"I'm sorry, but we were unable to verify your identity at this time. The document provided could not be read clearly, and the face verification was unsuccessful. Don't worry � I'll create a case with the information you've provided and forward it to our team for manual review. They will contact you to complete the verification process."
NOTE: Both OTP (5x fail) and IDV (fail) are exhausted. Customer cannot be authenticated automatically.

CASE CREATION � MANUAL HANDLING:
Then the system creates a case with status: PENDING MANUAL HANDLING (Authentication Failure)
And the case contains:
� PNR: TC225
� Passenger: Laurent Pelletier
� Journey: YUL ? YYZ (AC domestic), delayed 4h (3�<6h band)
� Scheduled Arrival: 14:00 ? Actual Arrival: 18:00
� Arrival Delay Code: 64 (Flight Crew Shortage � Controllable)
� Regime: APPR (AC domestic � pending DDS evaluation post-auth)
� Baseline APPR Tier 1 compensation if eligible: $400 CAD (subject to DDS evaluation after authentication resolved)
� Authentication Status: FAILED (OTP 5x fail + IDV fail)
� OTP History: 5/5 INCORRECT
� IDV History: FAIL (document quality insufficient + face mismatch)
� Persona Failure Reason: Document unreadable, face mismatch
� Case Status: Pending Manual Handling
� Routing: Customer Relations / Manual Authentication Team
Then the chatbot responds:
"Your case has been created and forwarded to our Customer Relations team. Your case reference number is [CASE-REF]. A team member will contact you within 15 business days to complete the verification and process your claim. Please keep your government-issued ID available for when they reach out."
And an alert information is displayed: "Case created for manual review."

NO DDS EVALUATION (deferred � authentication not completed; Code 64 + APPR Tier 1 baseline pre-loaded for agent reference)
NO PAYMENT FLOW (deferred � authentication not completed)
NO FRAUD SCREENING (deferred)

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Manual Handling notification email is sent to l***@gmail.com
And the email contains:
Subject: "Your Air Canada claim requires additional verification � [CASE-REF]"
� Case Reference number
� Flight details: YUL ? YYZ (AC domestic), May 1, 2026, delayed 4h (Flight Crew Shortage � Code 64)
� Regime: APPR
� Status: "We were unable to verify your identity automatically. Our Customer Relations team will contact you to complete the verification process."
� What to have ready: Government-issued photo ID
� Expected timeline: 15 business days
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
� Case Title: "Travel Disruptions � Authentication Failure"
� Status: Pending Manual Handling
� Created: [date populated]
� Last updated at: [date populated]
� SLA: tracking correctly (15 business days)
� Team: Customer Relations / Manual Authentication

CASE OVERVIEW:
� Claimant Name: Laurent Pelletier
� Authentication Status: FAILED
� OTP: 5/5 INCORRECT
� IDV: FAIL (document quality + face mismatch)
� PNR: TC225
� Journey: YUL ? YYZ (AC domestic, DELAYED +4h, 3�<6h band)
� Scheduled Arrival: 14:00 ? Actual Arrival: 18:00
� Arrival Delay Code: 64 (Flight Crew Shortage � Controllable)
� Regime: APPR (domestic AC operated � confirmed)
� Eligibility: PENDING (DDS deferred � authentication must be resolved first)
� Baseline APPR Tier 1 estimate: $400 CAD (for agent reference only � subject to full DDS evaluation post-authentication)
� Banner: Authentication Failure Warning Banner displayed
� Decision Assist Panel: GREYED OUT (locked until authentication resolved by manual team)
� DDS: NOT triggered (blocked pending authentication)