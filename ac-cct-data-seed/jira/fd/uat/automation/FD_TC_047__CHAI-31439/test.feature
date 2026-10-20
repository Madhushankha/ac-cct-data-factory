Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My United Airlines flight booked through Air Canada was cancelled and rebooked, and I arrived 7 hours late. I am an Elite 35K member and want to check compensation."
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
And the user provides "Richard Clarke"
Then the chatbot responds:
"Thanks, Richard! And, what is your booking reference number?"
And the user provides "PNR: TC037"
Then the chatbot searches Trip Tracer for PNR: TC037
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: r***@gmail.com
� Phone: +1***678
And the user selects "Email: r***@gmail.com"
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
� Richard Clarke (Adult - Aeroplan Elite 35K)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Original Flight: UA 4521 / AC 4521 (Cancelled)
� Rebooked Flight: UA 4525 (Operated by United Airlines)
� Route: Chicago (ORD) ? Denver (DEN)
� Date: May 26, 2026
� Arrival Delay: 7 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18

MSL CHECK � ALL OAL (STAR ALLIANCE):
Then the system checks MSL for operating carrier on all segments
And MSL returns: ALL segments operated by United Airlines (UA � Star Alliance) ? NO AC-OPERATED LEGS
And the system determines: ALL OAL ITINERARY ? REDIRECT TO OPERATING AIRLINE (UNITED AIRLINES)

OAL REDIRECT RESULT (MSL=OAL):
Then the chatbot displays:
"I�ve reviewed your flight details and noticed that this trip was operated by our United Airlines partner. To complete your claim, I can forward your details to an agent for review. Would you like to proceed?"
And the user confirms "Yes"

MANUAL HANDLING 
Then chatbot checks whether the user is identified/authenticated ? Yes
Then the chatbot asks: "Before I send your claim to manual review, please confirm the email address where you�d like to receive further information related to your claim.   Would you like to use r***@gmail.com?"
And the user confirms "Yes, confirm this email"
Then the chatbot asks: "To route you to the right support team, can you please share your country of residence?"
And the user responds:"Canada"
Then the chatbot responds: "Perfect, share any additional relevant information to help me process your claim."
And the user uploads the Ticket
And the user clicks on "Submit" button
Then the chatbot responds: "Your claim has been submitted you should hear from a team member within ["30 days"]"
Then an alert information is displayed: "Please note that an ID verification process will be required if you are deemed eligible for payment."
Then the case is sent for manual handoff

CLAIMS DASHBOARD VALIDATION
    Given MSL determined all segments are operated by United Airlines (Star Alliance) for PNR "TC037"
    Then the chatbot should have redirected the customer to contact United Airlines directly
    And no DDS evaluation should have occurred
    And no automated AC payment case should have been created
    And the customer profile should record Aeroplan Elite 35K status and ticket stock 014-
    And when searching Claims Dashboard by PNR "TC037", the system should reflect OAL redirect status or no open AC liability case

PAYMENT VALIDATION
    Given the eligibility result is "NOT ELIGIBLE / OAL OPERATED" for Air Canada payout
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And AC Wallet should NOT be offered as Air Canada was not the operating carrier
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE (OAL Operated)" with no compensation record and no payout section

Expected Results:
DDS returns FD-APPR-NE-05. Trip Tracer: MSL = Leg 1; Operating carrier = United Airlines (UA � Star Alliance); Cancellation Code = TECH(Aircraft Technical Issue)[DMT (Upline Safety)]; All legs scanned ? ZERO AC-operated segments on entire itinerary; Scheduled Arrival = 14:00; Actual Arrival on UA 4525 = 21:00; Delay = 7hrs (6�<9h band); Ticket stock = 014- (AC issued); Aeroplan Status = Elite 35K. Operating Carrier Check: AC operated legs = 0 ? AC has no compensation liability ? NOT ELIGIBLE for AC payout. CRITICAL: AC ticket stock (014-) and Elite 35K status do NOT make AC responsible for OAL disruptions. Operating carrier (United Airlines) bears APPR obligation. Customer Redirect: System provides helpful guidance directing customer to United Airlines. Compensation: $0 (from AC). Fraud Screening: NOT INVOKED. IDV: NOT REQUIRED. Payment: N/A.