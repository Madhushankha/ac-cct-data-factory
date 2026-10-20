Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I flew from Montreal to Toronto on Air Canada and then from Toronto to Vancouver on WestJet. The WestJet flight was delayed 5 hours. Can I get compensation?"

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
And the user provides "Thierry Rousseau"
Then the chatbot responds:
"Thanks, Thierry! And, what is your booking reference number?"
And the user provides "PNR: TC057"
Then the chatbot searches Trip Tracer for PNR: TC057
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:

Email: t***@gmail.com

Phone: +1***123

And the user selects "Email: t***@gmail.com"
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

Thierry Rousseau (Adult)

Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:

Segment 1: Flight AC 497, Montreal (YUL) ? Toronto (YYZ), June 7, 2026 � COMPLETED (AC operated)

Segment 2: Flight WS 3456, Toronto (YYZ) ? Vancouver (YVR), June 7, 2026 � ARRIVED LATE (+5h) (Operated by WestJet)

Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK (GenUC-18):
Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments)
Then the chatbot identifies: Segment 1 COMPLETED on time (AC), Segment 2 DELAYED +5h (WestJet � OAL)

MSL DETERMINATION:
Then the system calculates MSL using available timing data:

Segment 1 (AC 497): Scheduled arrival 10:30, Actual arrival 10:28 ? No delay

Segment 2 (WS 3456): Scheduled arrival 16:00, Actual arrival 21:00 ? 5hr delay

MSL = Segment 2 (WS 3456) � largest delay

MSL CHECK � OAL (NOT Star Alliance):
Then the system checks MSL for operating carrier on the disrupted leg
And MSL returns: Segment 2 operated by WestJet (WS) ? OAL
And the system checks: Is WestJet a Star Alliance partner? ? NO
And the system determines: MSL on non-Star Alliance OAL ? AC NOT RESPONSIBLE ? REDIRECT TO OAL

OAL REDIRECT RESULT (MSL=OAL):
Then the chatbot displays:
"I've reviewed the details of your flight, and we confirm that this flight was operated by a different airline. Please reach out to WestJet directly for any claim related requests."

NO DDS ELIGIBILITY EVALUATION (skipped � MSL on non-Star Alliance OAL, AC not responsible)
NO PAYMENT FLOW (skipped)
NO IDV (skipped)
NO FRAUD SCREENING (skipped)
NO CASE CREATION (no AC case created � OAL redirect is a terminal outcome)

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"

I would like you to � new flow

No

And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given MSL determined the disrupted leg is operated by a non-Star Alliance OAL for PNR "TC057"
    Then the chatbot should have redirected the customer to contact the operating airline directly
    And no DDS evaluation should have occurred
    And no case should have been created in the automated system
    And no Claims Dashboard entry should exist for PNR "TC057"
    And when searching Claims Dashboard by PNR "TC057" no case should be found

PAYMENT VALIDATION
    Given no case was created due to OAL non-Star Alliance operated flight
    Then no automated payment flow should be triggered
    And the case was created and sent to agent for manual handling
    And no country of residence should have been asked
    And no compensation record should have been created automatically
    And no batch file should have been dispatched
    And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e-credit to EIP
    And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved

Expected Results:
DDS identifies MSL using available flight timing data:
Segment 1 (AC 497): Scheduled arrival 10:30, Actual arrival 10:28 ? 0 delay
Segment 2 (WS 3456): Scheduled arrival 16:00, Actual arrival 21:00 ? 5hr delay
MSL = Segment 2 (WS 3456)
MSL Carrier = WestJet (WS) � non-Star Alliance OAL
AC Responsibility = NONE � disruption is on a carrier AC has no responsibility for
Outcome = OAL REDIRECT (customer told to contact WestJet directly)
DDS Code = FD-APPR-ND-01
Claims Dashboard: No case created. Validation = confirm NO entry exists for PNR TC057.