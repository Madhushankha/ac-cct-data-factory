PHASE 1 � INITIAL SESSION (Active):
Given the user opens the agentic chatbot at 14:00
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto was delayed 4 hours. I'd like to file a compensation claim"
When the chatbot identifies flight disruption intent
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."
LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process..."
IDENTIFICATION (GenUC-01):
Then the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Nathalie C�t�"
Then the chatbot responds:
"Thanks, Nathalie! And, what is your booking reference number?"
And the user provides "PNR: TC242"
Then the chatbot searches Trip Tracer for PNR: TC242
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data is revealed
SESSION STATE AT 14:05:
? Session ID: SES-20260615-1400-001
? Session Status: ACTIVE
? Last Activity: 14:05
? Progress: Identification COMPLETED (name + PNR found)
? Next Step: Authentication (OTP)
? Session Timeout: 30 minutes of inactivity
PHASE 2 � INACTIVITY (Customer Gets Distracted):
At 14:05, the customer gets distracted and stops interacting with the chatbot.
INACTIVITY MONITORING:
? 14:05 � Last customer interaction
? 14:15 � 10 minutes inactive (no action)
? 14:25 � 20 minutes inactive (no action)
? 14:30 � 25 minutes inactive � WARNING THRESHOLD APPROACHING
INACTIVITY WARNING (at 25 minutes):
Then the chatbot displays an inactivity warning:
"Are you still there? Your session will expire in 5 minutes due to inactivity. Please respond to continue."
? 14:35 � 30 minutes inactive � NO RESPONSE TO WARNING
SESSION EXPIRATION (at 30 minutes):
Then the system determines: SESSION EXPIRED (30 minutes of inactivity)
And the system takes the following actions:
? Session ID: SES-20260615-1400-001 ? EXPIRED
? Session data: CLEARED (for security � PNR data, passenger info purged from active session)
? Authentication state: RESET (OTP not completed � must re-authenticate)
? Progress saved: PARTIAL � system records that PNR TC242 was looked up but authentication was not completed
? No case created (flow not completed)
Then the chatbot displays:
"Your session has expired due to inactivity. For your security, you'll need to start a new session. Don't worry � you can return anytime to file your claim."
PHASE 3 � CUSTOMER RETURNS (2 Hours Later):
At 16:05, the customer returns to the chatbot (2 hours after session expired).
Given the user opens the agentic chatbot at 16:05
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
NOTE: Full re-greeting is displayed. Session has expired � customer must restart from the beginning. No "resume" option because authentication was never completed (security requirement).
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I was trying to file a compensation claim earlier but got distracted. Can I continue?"
SESSION RESUME CHECK:
Then the system checks: Is there an active session for this user? ? NO (session expired)
Then the system checks: Is there a saved progress state? ? PARTIAL (PNR TC242 looked up, but authentication not completed)
Then the system determines: CANNOT RESUME � AUTHENTICATION NOT COMPLETED ? MUST RESTART
RESTART FLOW:
Then the chatbot responds:
"I see you started a claim earlier but your session expired due to inactivity. For security reasons, since your identity wasn't fully verified, you'll need to start the process again. Don't worry � it won't take long! Let's get started."
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."
LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process..."
IDENTIFICATION (GenUC-01) � RESTART:
Then the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Nathalie C�t�"
Then the chatbot responds:
"Thanks, Nathalie! And, what is your booking reference number?"
And the user provides "PNR: TC242"
Then the chatbot searches Trip Tracer for PNR: TC242
And Trip Tracer returns: PNR FOUND
NOTE: From this point, the standard FD flow continues from the beginning (authentication ? passenger selection ? journey selection ? DDS ? result). The customer must complete the entire flow again.
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: n***@gmail.com
� Phone: +1***789
And the user selects "Email: n***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "482917"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds:
"Your verification was successful. Let's proceed to the next step."
NOTE: Flow continues normally from here (passenger selection ? journey selection ? DDS ? eligible/not eligible ? payment ? case creation). Full flow restart required because authentication was never completed in the expired session.
SESSION EXPIRATION VALIDATION:
? Session timeout: 30 minutes ?
? Inactivity warning at 25 minutes: YES ?
? Session expired at 30 minutes: YES ?
? Session data cleared (security): YES ?
? Authentication state reset: YES ?
? Customer returns 2 hours later: YES ?
? Resume possible: NO (authentication not completed) ?
? Full restart required: YES ?
? Re-greeting displayed: YES ?
? Duplicate claim check: Will pass (no case created in expired session) ?

Expected Results:
Session timeout detected after 30 min inactivity; 5-minute warning sent; Session expired; Data preserved; Customer returns and offered resume option; Re-authentication required; Session restored from saved state; Full flow completed; Both session transcripts merged