Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Tel Aviv to Toronto was delayed 4 hours. I booked through Air Canada but the flight was operated by El Al. Can I get compensation?"
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
And the user provides "Noa Peretz"
Then the chatbot responds:
"Thanks, Noa! And, what is your booking reference number?"
And the user provides "PNR: TC123"
Then the chatbot searches Trip Tracer for PNR: TC123
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data is revealed � ALL LEGS OAL OPERATED (014 ticket stock, AC-issued but OAL-operated)
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: n***@gmail.com
� Phone: +972***567
And the user selects "Email: n***@gmail.com"
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
� Noa Peretz (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: LY 315 (Operated by El Al)
� Route: Tel Aviv Ben Gurion (TLV) ? Toronto (YYZ)
� Date: June 4, 2026
� Arrival Delay: 4 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
ALL OAL ITINERARY CHECK:
Then the system checks: Are ALL segments on this itinerary operated by OAL (non-AC)?
And the system identifies: Flight LY 315 operated by El Al ? OAL
And the system checks: Any AC-operated segments? ? NO (all OAL)
And the system determines: ALL OAL ITINERARY ? NOT ELIGIBLE (AC cannot assess; customer should contact operating airline)
ALL OAL RESULT:
Then the chatbot displays:
"I've reviewed the details of your flight, and we confirm that all flights on this itinerary were operated by a different airline. Please reach out to El Al directly for any claim related requests."
And the chatbot provides:
� El Al contact information
� Link to El Al claim form
� Reference to ASL rights
NO DDS EVALUATION (skipped � all OAL itinerary)
NO PAYMENT FLOW (skipped)
NO IDV (skipped)
NO FRAUD SCREENING (skipped)
NO CASE CREATION (no AC case created for all-OAL itinerary)
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the system determined all segments are operated by OAL El Al LY 315 for PNR "TC123"
    Then the chatbot should have redirected the customer to contact El Al directly
    And no DDS evaluation should have occurred
    And no case should have been created in the automated system
    And no Claims Dashboard entry should exist for PNR "TC123"
    And when searching Claims Dashboard by PNR "TC123" no case should be found

PAYMENT VALIDATION
    Given no case was created due to OAL operated flight
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section

Expected Results:
DDS returns FD-ASL-NE-05. Operating Carrier Check: AC operated legs = 0 ? NOT ELIGIBLE (all OAL itinerary). AC ticket stock does NOT make AC responsible � operating carrier bears liability. Customer Redirect: Directed to contact operating airline. Compensation: $0 (from AC). Fraud Screening: NOT INVOKED. Regime Assessment: ASL = NE-05 (All OAL); APPR = NE (if applicable); EU = NE (if applicable). Claims Dashboard: Status = Closed � Not Eligible; Reason = All OAL itinerary; Redirect = operating airline; DDS = FD-ASL-NE-05.