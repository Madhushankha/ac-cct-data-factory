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
And the user provides "Fran�ois Leblanc"
Then the chatbot responds:
"Thanks, Fran�ois! And, what is your booking reference number?"
And the user provides "PNR: TC242"
Then the chatbot searches Trip Tracer for PNR: TC242
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: f***@gmail.com
� Phone: +1***890
And the user selects "Email: f***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "739281"
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
� Fran�ois Leblanc (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
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
TRIAGE & DDS EVALUATION � SERVICE FAILURE:
Then the system attempts to send the case to DDS for eligibility assessment
And the system calls DDS service
And DDS service returns: SERVICE UNAVAILABLE (HTTP 503 � service down)
DDS RETRY LOGIC:
? Attempt 1: DDS call ? 503 SERVICE UNAVAILABLE ? retry after 5 seconds
? Attempt 2: DDS call ? 503 SERVICE UNAVAILABLE ? retry after 10 seconds
? Attempt 3: DDS call ? 503 SERVICE UNAVAILABLE ? MAX RETRIES EXHAUSTED
DDS SERVICE DOWN � GRACEFUL ERROR HANDLING:
Then the system determines: DDS SERVICE DOWN � CANNOT ASSESS ELIGIBILITY
And the system takes the following actions:
? DDS Status: DOWN (3 retries failed)
? Eligibility Assessment: DEFERRED (cannot be completed)
? Case Creation: YES (create case for automatic retry when DDS recovers)
? Customer Impact: MINIMAL (case created, customer notified, auto-retry scheduled)
GRACEFUL ERROR MESSAGE TO CUSTOMER:
Then the chatbot responds:
"Thank you for providing all the information. I've received your claim details, but our eligibility assessment system is currently experiencing a temporary issue. Don't worry � your claim has been saved and will be automatically processed once the system is back online. You will receive an email with the outcome of your claim once the assessment is complete. This should not take longer than 15 days."
And an alert information is displayed: "Claim received � processing will resume shortly."
CASE CREATION � DDS RETRY QUEUE:
Then the system creates a case with status: PENDING (DDS Retry Queue)
And the case contains:
� PNR: TC242
� Passenger: Fran�ois Leblanc
� Journey: YUL?YYZ, June 2, 2026, delayed 4h
� Identification: COMPLETED
� Authentication: COMPLETED (OTP PASS)
� Passenger Selection: COMPLETED
� Journey Selection: COMPLETED
� Duplicate Check: PASSED
� 72-Hour Check: PASSED
� DDS Assessment: PENDING (Service Down � Retry Scheduled)
� DDS Retry Count: 0 (will retry when service recovers)
� Case Status: Pending (DDS Retry Queue)
� Routing: System Processing Queue (automatic retry)
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Claim Received notification email is sent to f***@gmail.com
And the email contains:
Subject: "Your Air Canada claim has been received � [CASE-REF]"
Case Reference number
Flight details (YUL?YYZ, June 2, 2026, delayed 4h)
Status: "Your claim has been received and is being processed. We will notify you of the outcome within 15 days."
Note: "There may be a slight delay in processing due to system maintenance. Rest assured, your claim is in our queue and will be processed as soon as possible."
Contact information
NOTE: The notification does NOT mention "DDS service down" or any technical details. Standard processing message with a gentle note about potential delay.
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."
POST-RECOVERY � DDS AUTO-RETRY (Backend):
When the DDS service recovers (e.g., 2 hours later)
Then the system automatically detects DDS recovery
And the system queries the DDS Retry Queue
And the system finds: Case [CASE-REF] for PNR TC242 � pending DDS assessment
And the system automatically sends the case to DDS for eligibility assessment
And DDS evaluates:
? Regime: APPR
? MSL: AC 422 � YUL ? YYZ � Code 42 � Controllable
? Delay: 4h (3�6h tier)
? Result: ELIGIBLE � $400 CAD
And the case status is updated from "Pending (DDS Retry Queue)" to "Eligible"
And the system proceeds with CyberSource fraud screening
And CyberSource returns: GREEN
And the system sends eligible notification to customer
And the customer is prompted to complete payment flow
CLAIMS DASHBOARD VALIDATION:
When the agent navigates to Claims Dashboard
And the agent searches for the case by PNR
Then the dashboard displays:
TBD

Expected Results:
DDS failure detected after 3 retries; Graceful error message (no technical jargon); Case created with all data preserved; Auto-retry scheduled; Customer notified; When DDS restored, auto-retry succeeds; Welcome Back notification sent; Dashboard shows full retry log