GREETING & INTENT IDENTIFICATION:
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects "English"
Then an alert information is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks: "How can I help you today?"
And the user says: "My flight was delayed about 4 hours, I'd like to check if my family and I are eligible for compensation"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Catherine Bouchard"
Then the chatbot responds: "Thanks, Catherine! And, what is your booking reference number?"
And the user provides "TC003"
Then the chatbot searches Trip Tracer for PNR: TC003
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is retrieved

AUTHENTICATION (GenUC-05):
Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
* Email: c***@gmail.com
* Phone: +1567
And the user selects "Email: c@gmail.com"
Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides OTP code "591837"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds: "Your verification was successful. Let's proceed to the next step."

PASSENGER SELECTION (GenUC-06):
Then the chatbot asks: "How many people are on your claim?"
And the chatbot displays passengers from PNR TC003:
"I found 3 passengers on this booking:
1. Catherine Bouchard (Adult - Aeroplan Member)
2. Alexandre Bouchard (Adult)
3. Sophie Bouchard (Child)
Would you like to include all passengers in this claim?"
And the user confirms "Yes, include all 3 passengers"
Then the chatbot checks: PAX count on PNR = 3 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
* Flight: AC 301
* Route: Montreal (YUL) ? Toronto (YYZ)
* Date: January 15, 2026
* Arrival Delay: 4 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT & ELIGIBILITY CHECKS:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
Then the chatbot sends request to Case Services for duplicate check ? NO existing case found for any of the 3 passengers on this journey
Then the chatbot checks 72-hour rule: Arrival Jan 15, 2026; filing Jan 28, 2026 ? 312 hours (>72 hours) ? PROCEED
Then the chatbot checks APPR filing deadline: 13 days elapsed (within 366 days) ? PROCEED

TRIAGE & DDS EVALUATION:
Backend DDS executes evaluation for PNR TC003:
� Regime: APPR Applicable
� Delay reason: Code 68 (Flight Crew Shortage / Crew Rest � Controllable)
� Delay duration: 4 hours (Band: 3 to <6 hours)
� Eligibility: ELIGIBLE ($400 CAD per passenger x 3 passengers = $1,200 CAD total)

TRIP TRACER UI VALIDATION:
The tester opens Trip Tracer UI for PNR: TC003
[x] Promised Itinerary: Flight AC 301, YUL ? YYZ, Scheduled Arrival: 14:00
[x] Current Itinerary: Flight AC 301, YUL ? YYZ, Status: ARRIVED LATE, Actual: 18:00, Delay: +4H 00M
[x] Regime: APPR (1 regime)
[x] MSL Flight: AC 301 � YUL ? YYZ � Code 68 ("Delayed due to flight crew shortage / crew rest requirement")
[x] Delay Classification: +4H 00M � CONTROLLABLE
[x] Passengers: 3 Pax (Catherine Bouchard, Alexandre Bouchard, Sophie Bouchard)
[x] Flight Compensation Assessment:
  - Catherine Bouchard: ELIGIBLE | DELAY_3_TO_LT_6_HOURS | CAD 400.00 Cash / CAD 480.00 AC Wallet
  - Alexandre Bouchard: ELIGIBLE | DELAY_3_TO_LT_6_HOURS | CAD 400.00 Cash / CAD 480.00 AC Wallet
  - Sophie Bouchard: ELIGIBLE | DELAY_3_TO_LT_6_HOURS | CAD 400.00 Cash / CAD 480.00 AC Wallet
  - Total: CAD 1,200.00 Cash / CAD 1,440.00 AC Wallet

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Chatbot sends case details to CyberSource ? Returns GREEN LIGHT (Pass)

ELIGIBLE RESULT DISPLAY (FD-05a):
Chatbot displays: "I've checked your flight details, and flight AC 301 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours due to crew scheduling constraints (Code 68 - Controllable). Under the Air Passenger Protection Regulations (APPR), all 3 passengers on your booking are eligible for compensation of $400 CAD each, for a total of $1,200 CAD."

CLAIM PAYMENT & AEROPLAN OFFER (FD-06b / FD-07):
Chatbot asks: "In which country will your reimbursement be deposited?"
User selects "Canada" ? Currency = CAD
Chatbot checks Aeroplan status: Primary claimant Catherine Bouchard has linked Aeroplan (9876543210, Basic Member in good standing)
Chatbot offers BOTH payment options:
"Since you are an Aeroplan member, you can choose to receive for all 3 passengers:
* Cash: $1,200 CAD total ($400 CAD x 3) sent via Interac e-Transfer (takes 5 to 10 business days).
* AC Wallet: $1,440 CAD total ($480 CAD x 3, including a 20% bonus) added to your AC Wallet immediately with no expiry.
How would you like to receive your funds?"
User selects "Cash"
Chatbot confirms payment method: "Your payment will be made through Interac e-Transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information. Would you like to use c***@gmail.com? Please note that only one email address can be used for this compensation/reimbursement and it can't be changed once confirmed."
User confirms: "Yes, use this email"

IDENTITY VERIFICATION (PERSONA - FD-07b):
Chatbot displays "Get verified" button ? User completes Persona IDV ? Persona returns IDV PASS

CLAIM CONFIRMATION & CASE CREATION (GLOB-09):
Chatbot displays summary:
"Please review your compensation details:
Total Amount: $1,200 CAD (3 passengers x $400 CAD)
Payment Method: Interac e-Transfer (c***@gmail.com)
Would you like me to submit your claim?"
User responds "Yes"
Chatbot creates case and displays: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Claim submission successful!"

NOTIFICATION & WRAP-UP (GLOB-11):
Adobe triggers notification email to c***@gmail.com containing: Case Reference, $1,200 CAD Cash via Interac e-Transfer, APPR regulation, Flight AC 301 (YUL?YYZ), Code 68 Controllable, breakdown for 3 passengers.

Claims Dashboard Gherkin:
Given the case has been created for primary claimant "Catherine Bouchard" with PNR "TC003" covering 3 passengers
Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
And the Case Status should be "In Review" or "Done"
And the Regime should be "APPR"
And the Disruption Reason Code should be "68 (Flight Crew Shortage / Rest)"
And the Passenger Count should be 3 (Catherine Bouchard, Alexandre Bouchard, Sophie Bouchard)
And the Total Compensation should display "$1,200 CAD (Cash � Interac e-Transfer)"
And the AC Wallet alternative ($1,440 CAD) should be marked as "Offered but Not Selected"
And the CyberSource result should be "GREEN"
And the IDV status should be "PASS"

Payment Validation Gherkin:
Given the customer's country of residence is "Canada"
Then the currency should be set to "CAD"
And the payment method should be set to "Interac e-Transfer"
And only the Interac email "c***@gmail.com" should be collected (no banking details)
And a compensation record for "$1,200 CAD" should be created for the batch file
And the record should be dispatched to Unifier and acknowledged

Expected Results Summary:
DDS generates FD-APPR-EL-01 for 3 pax. Delay: 4 hours. Code: 68 (Flight Crew Shortage � Controllable). Regime: APPR. Total Payout: $1,200 CAD Cash via Interac e-Transfer to c***@gmail.com.