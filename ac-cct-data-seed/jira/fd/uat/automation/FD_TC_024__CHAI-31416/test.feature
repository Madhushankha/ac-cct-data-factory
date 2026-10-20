GREETING & INTENT IDENTIFICATION:
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
  "Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects "English"
Then an alert information is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks: "How can I help you today?"
And the user says: "My flight was delayed about 7 hours because of a catering problem, I'd like to check if I'm eligible for compensation and I'd prefer to get it on my Aeroplan account"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Isabelle C�t�"
Then the chatbot responds: "Thanks, Isabelle! And, what is your booking reference number?"
And the user provides "TC074"
Then the chatbot searches Trip Tracer for PNR: TC074
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details, Aeroplan Elite 25K profile) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options: Email: i***@gmail.com | Phone: +1***345
And the user selects "Email: i***@gmail.com"
Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "629184"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds: "Your verification was successful. Welcome back, Isabelle (Aeroplan Elite 25K). Let's proceed to the next step."

GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06):
Then the system checks Trip Tracer for group booking identifier ? NOT PRESENT
Then the chatbot asks: "How many people are on your claim?"
And the chatbot displays: "I found 1 passenger on this booking: Isabelle C�t� (Adult - Aeroplan Elite 25K). Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
  "I found the following journey:
   Flight: AC 431
   Route: Montreal (YUL) ? Toronto (YYZ)
   Date: May 10, 2026
   Arrival Delay: 7 hours
   Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT & ELIGIBILITY CHECKS:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
Then the chatbot sends request to Case Services for duplicate check ? NO existing case found
Then the chatbot checks 72-hour rule: Arrival May 10, 2026; filing June 13, 2026 ? 34 days (>72 hours) ? PROCEED
Then the chatbot checks APPR filing deadline: 34 days elapsed (within 366 days) ? PROCEED

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend for PNR TC074 / Claimant Isabelle C�t�
And DDS checks the cancellation code on MSL ? NONE
And DDS checks the first arrival delay code on MSL ? 17 (PC)
And DDS classifies 17 (PC) as WITHIN CARRIER CONTROL ? CONTROLLABLE
And DDS calculates delay = 7 hours ? band 6 to <9 hours ? Tier 2
And DDS validates Aeroplan Elite 25K status as active
And DDS sets base eligibility = CAD 700 cash; AC Wallet eligibility (+20%) = CAD 840
And DDS returns FD-APPR-EL-02 and sends results to Trip Tracer UI

TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC074
? Promised Itinerary: Flight AC 431, Route: YUL ? YYZ, Scheduled Arrival: 10:00
? Current Itinerary: Flight AC 431, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 10:00 ? Actual: 17:00, Delay: +7H 00M
? Regime: APPR (1 regime)
? MSL Flight: AC 431 � YUL ? YYZ � Code 17 (PC) � "Catering order � late or incorrect order given to supplier"
? Cancellation code: NONE ; Fallback: FALSE (arrival delay code available)
? APPR causal category: Within carrier control ? CONTROLLABLE
? Delay Classification: +7H 00M � CONTROLLABLE � DELAY_6_TO_LT_9_HOURS
? Aeroplan: 9876543210 (Elite 25K � linked, active, Star Alliance Silver)
? DDS outcome code: FD-APPR-EL-02
Flight Compensation Assessment:
? MS ISABELLE C�T� | ELIGIBLE | DELAY_6_TO_LT_9_HOURS | CAD 840.00 (Wallet) | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource
And CyberSource returns: GREEN LIGHT (Pass)

ELIGIBLE RESULT DISPLAY (FD-05a):
Then the chatbot displays: "I've checked your flight details, and flight AC 431 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7 hours. Based on the Air Passenger Protection Regulations (APPR), you are eligible for compensation for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."

CLAIM PAYMENT & AC WALLET SELECTION (FD-06b / FD-07):
Then the chatbot asks: "In which country will your reimbursement be deposited?"
And the user selects "Canada" ? Currency = CAD
Then the chatbot checks Aeroplan status: Isabelle C�t� has linked Aeroplan 9876543210, Elite 25K in good standing
And the chatbot offers BOTH options:
  "As an Aeroplan Elite 25K member, you can choose to either receive:
   Cash: CAD 700 will be compensated by Interac e-Transfer and takes 5 to 10 business days to process the payment.
   AC Wallet: CAD 840 (including a 20% bonus of CAD 140) will be added to your AC Wallet immediately and has no expiry.
   How would you like to receive your funds?"
And the user selects "AC Wallet"
Then the chatbot does NOT ask for an Interac email, bank account, card or any other payment details

IDENTITY VERIFICATION (PERSONA � FD-07b):
Then the chatbot displays "Get verified" button
And the user completes Persona IDV
And Persona returns: IDV PASS

CLAIM AMOUNT CONFIRMATION:
Then the chatbot responds: "Thank you. Here is a summary of your compensation:
   Deposit Amount: CAD 840
   Payment Method: AC Wallet (Aeroplan #: 9876543210)
   Would you like me to submit your claim?"
And an alert information is displayed: "Please note that payment details cannot be changed after submission."
When the user clicks on "Yes"

CASE CREATION & NOTIFICATION (GLOB-09 / GLOB-11):
Then the chatbot responds: "Thank you. Your claim has been submitted and will be processed within 10 business days. A confirmation email will be sent to you with details on how to monitor your claim status and payment updates. Please refer to that email for any follow-up information."
And an alert information is displayed: "Claim submission successful!"
And the system triggers notification via Adobe to i***@gmail.com
And the email contains: Case Reference, compensation amount (CAD 840 AC Wallet), Aeroplan Elite 25K confirmation (9876543210), regulation (APPR), flight details (AC 431 YUL?YYZ), disruption reason (Code 17 � catering order), tracking link
Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No]
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."


CLAIMS DASHBOARD VALIDATION
  Given the case has been created for claimant "Isabelle C�t�" with PNR "TC074"
  Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
  And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
  And the Case Status should be "In Review" or "Done"
  And the Created date and Last Updated date should be populated
  And the SLA countdown should be tracking correctly
  And the Team assignment should be correct
  And no banners should be displayed for identified and authenticated Auth Flow 1 user
  And the Decision Assist panel should NOT be greyed out
  And the Claimant Name should be "Isabelle C�t�"
  And the Claimant Type should be "Adult"
  And the Authentication should be "Pass"
  And the PNR should be "TC074"
  And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated
  And the Regime should be "APPR"
  And the Full Name should be "Isabelle C�t�"
  And the Tags should include "Claimant", "Adult", and "Elite 25K"
  And the Email should be "i***@gmail.com"
  And the Phone should be "+1***345"
  And the Address and Profile ID should be populated
  And the Aeroplan should be "9876543210" linked and active
  And the Tier Status should be "Elite 25K / Member"
  And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight
  And the Disruption Code should show "Code 17 (PC � Catering order) � Controllable"
  And the Ancillary Fee section should be present and empty
  And the Eligibility and Compensation section should show "CAD 840 (AC Wallet � 20% Top-up Applied)"
  And the Decision Assist Panel should auto-appear for FD topic
  And DDS should have run automatically with no agent action needed
  And the DDS outcome should be "FD-APPR-EL-02"
  And the eligibility decision should be pre-populated as "ELIGIBLE" (APPR, Tier 2: 6 to <9 hrs, Code 17 Controllable, AC Wallet)
  And the Duplicate Check should have run automatically using baseline data "Isabelle C�t� + TC074 + YUL?YYZ + FD"
  And the result should be "No duplicate found"
  And no Duplicate Warning Banner should be displayed
  And the Related Cases tab should show no related cases
  And the CyberSource result should be "GREEN"
  And the case should have proceeded automatically and not be parked in Fraud Queue
  And the Persona IDV result should be "PASS"
  And the system should have appended the booking record automatically for identified and authenticated user
  And Trip Tracer poll should NOT be required
  And the agent should have used pull case from My Activities
  And the case status should have transitioned from "Assigned" to "In Progress"
  And a case acknowledgement notification should have been sent
  And an eligible notification email should have been sent via Adobe
  And the Agent Notes section should be accessible
  And the Audit Log should record all actions with timestamps and before/after values
  And Customer Communications should show the notification email chronologically
  And the chatbot transcript should be accessible and linked to the case
  And the Attachments tab should be empty
  And the Final Status should be "Resolved"
  And the case should be in read-only mode with no editable Decision Assist fields
  And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
  Given the customer's country of residence is "Canada"
  Then the currency should be set to "CAD"
  And the customer has Aeroplan "9876543210" linked with Elite 25K status in good standing
  And both options should be offered: Cash at CAD 700 by Interac and AC Wallet at CAD 840 with 20% top-up
  And the customer selects "AC Wallet"
  And no Interac email or other payment details should have been collected
  And the 20% top-up should be applied converting CAD 700 to CAD 840
  And AC Wallet should be offered because this is a flight disruption under APPR
  And a compensation record should be created for CAD 840
  And the record should be picked up by the daily evening batch file
  And the record should be dispatched to EIP and NOT Unifier
  And EIP should convert from CAD to the customer's Aeroplan profile country currency if applicable
  And EIP should check Aeroplan account validity confirming it is active and not frozen
  And EIP should send to iGiga
  And iGiga should send to iFly for deposit
  And iFly should talk back to EIP
  And EIP should talk back to Claims Dashboard with deposited amount (CAD 840), exchange rate, and status
  And if the Aeroplan account is frozen or closed a rejection with error message should be returned, a failure notification should be sent to the case and the agent should be flagged
  And in UAT the batch file should be triggered manually in coordination with the EIP team
  And the Claims Dashboard Compensation tab should show "CAD 840"
  And the payment method should show "AC Wallet"
  And the status should be updated via talkback

Expected Results: DDS returns FD-APPR-EL-02. Trip Tracer: Promised = 10:00, Actual = 17:00, Delay = 7 hours, MSL = Leg 1, arrival delay code 17 (PC, catering order, within carrier control), Fallback = FALSE, Regime = APPR. Aeroplan: Elite 25K linked and active. Compensation: CAD 840 by AC Wallet (CAD 700 base + 20% top-up of CAD 140). EIP check: account active, deposit successful through iGiga/iFly. CyberSource: GREEN. Persona: PASS. Claims Dashboard: Resolved/Done, read-only, Elite 25K tier populated, Code 17, CAD 840 AC Wallet credited to Aeroplan 9876543210.
