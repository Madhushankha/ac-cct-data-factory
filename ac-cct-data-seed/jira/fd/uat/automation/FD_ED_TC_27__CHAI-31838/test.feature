Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Paris to Toronto was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation"
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
And the user provides "Pierre Moreau"
Then the chatbot responds:
"Thanks, Pierre! And, what is your booking reference number?"
And the user provides "PNR: TC247"
Then the chatbot searches Trip Tracer for PNR: TC247
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: p***@gmail.com
� Phone: +33789
And the user selects "Email: p@gmail.com"
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
� Pierre Moreau (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 871
� Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ)
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
Then the chatbot checks: Filing deadline for EU 261 (France = 5 years) ? within limitation ? PROCEED
REGIME DETERMINATION:
Then the system determines: Origin = CDG (Paris, France, EU) ? EU 261
And the system checks: Distance CDG?YYZ = ~5,900 km ? Long-haul (>3500km)
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC247
? Promised Itinerary - Flight: AC 871, Route: CDG ? YYZ, Scheduled Arrival: 13:00
? Current Itinerary - Flight: AC 871, Route: CDG ? YYZ, Status: ARRIVED LATE, Actual: 17:00, Delay: +4H 00M
? Regime: EU 261 (EU origin � CDG)
? Distance: ~5,900 km ? Long-haul (>3500km)
? MSL FLIGHT: AC 871 � CDG ? YYZ � 42
? CONTROLLABLE (Code 42)
? EU 261: Delay 4h, Controllable, Long-haul ? ELIGIBLE
? Compensation: �600 (EU 261 long-haul rate)
Flight Compensation:
? MR PIERRE MOREAU | ELIGIBLE | EU261_DELAY_GTE_4_HOURS_LONG_HAUL | �600
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment
ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 871 from Paris Charles de Gaulle (CDG) to Toronto (YYZ) was delayed by about 4 hours. Based on EU Regulation 261/2004, you may be eligible for compensation of �600 for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."
CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "France"
Then the system determines: Country = France ? Currency = EUR ? Payment Method = Bank Transfer (SEPA)
CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot checks if the claim is for multiple pax ? No
Then the chatbot responds: "You are entitled to receive �600 compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency (EUR)."
And user provides "Yes"
Then system checks which payment method is mapped based on country of residence ? Bank Transfer (SEPA)
PAYMENT METHOD � BANK TRANSFER SEPA (FD-07):
Then the chatbot responds:
"Your payment will be made through SEPA bank transfer. Before we move forward, please provide your bank details for the transfer."
And the chatbot collects:
� Account holder name
� IBAN
� BIC/SWIFT
And the user provides:
� Account holder name: Pierre Moreau
� IBAN: FR76 3000 6000 0112 3456 7890 189
� BIC: AGRIFRPP
Then the chatbot confirms: "Thank you. Your SEPA bank transfer details have been recorded."
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
Deposit Amount: �600
Payment Method: SEPA Bank Transfer
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps.
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user provides: "Yes"
CASE CREATION (GLOB-09) � WITH CURRENCY CONVERSION LOGGING:
Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
CURRENCY CONVERSION LOGGING (Backend � Reporting):
Then the system logs the following for reporting purposes:
? Compensation Amount (Original): �600 EUR
? Exchange Rate Used: 1 EUR = 1.4850 CAD (standardized rate as of June 15, 2026)
? CAD Equivalent: $891.00 CAD (�600 � 1.4850)
? Exchange Rate Source: Bank of Canada daily rate (or configured standardized rate)
? Exchange Rate Date: June 15, 2026
? Logging Timestamp: June 15, 2026 12:32:00 UTC
REPORTING DATA STRUCTURE (Backend):
? Case Reference: [CASE-REF]
? Regime: EU 261
? Compensation Currency: EUR
? Compensation Amount (EUR): �600.00
? CAD Equivalent Amount: $891.00 CAD
? Exchange Rate: 1.4850 EUR/CAD
? Exchange Rate Date: 2026-06-15
? Exchange Rate Source: Bank of Canada
? Country of Residence: France
? Payment Method: SEPA Bank Transfer
? Payment Currency: EUR
NOTE: The CAD equivalent is logged for internal reporting and exposure analysis ONLY. The customer sees and receives EUR. The CAD amount is never displayed to the customer.
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to p***@gmail.com
And the email contains: Case Reference, compensation amount (�600 � EUR only, NOT CAD equivalent), regulation (EU 261), flight details, payment method (SEPA), next steps, tracking link
NOTE: Customer notification shows EUR amount ONLY. CAD equivalent is internal reporting data only.
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
� Regime: EU 261
� Compensation (EUR): �600.00
� CAD Equivalent: $891.00 CAD
� Exchange Rate: 1.4850 EUR/CAD (June 15, 2026)
� Exchange Rate Source: Bank of Canada
� Country of Residence: France
� Payment Method: SEPA Bank Transfer
� Payment Currency: EUR
REPORTING VALIDATION:
When the reporting team runs the exposure analysis report
Then the report includes:
? Case [CASE-REF]: �600 EUR / $891.00 CAD at 1.4850 EUR/CAD ?
? Exchange rate standardized: YES (Bank of Canada daily rate) ?
? CAD equivalent logged: YES ?
? Exchange rate date logged: YES (June 15, 2026) ?
? Exchange rate source logged: YES (Bank of Canada) ?
? Customer-facing amount: EUR only (no CAD shown to customer) ?
? Internal reporting amount: Both EUR and CAD ?
CURRENCY CONVERSION VALIDATION:
? Compensation in original currency (EUR): �600.00 ?
? CAD equivalent calculated: $891.00 CAD ?
? Exchange rate used: 1.4850 EUR/CAD ?
? Exchange rate source: Bank of Canada ?
? Exchange rate date: June 15, 2026 ?
? CAD equivalent logged for reporting: YES ?
? CAD equivalent shown to customer: NO (EUR only) ?
? Per call transcript: "Canadian equivalent logged for reporting, conversion rates standardized for exposure analysis" ?

Expected Results:
EU compensation (�600) correctly determined as most generous; CAD equivalent ($880.02) logged for reporting; Exchange rate, source, and date documented; APPR alternative ($700) also logged for comparison; Exposure report uses CAD equivalent; All regime assessments preserved for audit