GREETING & INTENT IDENTIFICATION:
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
  "Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects "English"
Then an alert information is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks: "How can I help you today?"
And the user says: "My flight from Montreal to Toronto was delayed about 7 hours because the plane arrived late from its previous flight, I'd like to check if I'm eligible for compensation"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Philippe Tremblay"
Then the chatbot responds: "Thanks, Philippe! And, what is your booking reference number?"
And the user provides "TC081"
Then the chatbot searches Trip Tracer for PNR: TC081
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details, Aeroplan Elite 25K profile) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options: Email: p***@gmail.com | Phone: +1***234
And the user selects "Email: p***@gmail.com"
Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "482917"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds: "Your verification was successful. Let's proceed to the next step."

GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06):
Then the system checks Trip Tracer for group booking identifier ? NOT PRESENT
Then the chatbot asks: "How many people are on your claim?"
And the chatbot displays: "I found 1 passenger on this booking: Philippe Tremblay (Adult - Aeroplan Elite 25K). Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
  "I found the following journey:
   Flight: AC 430
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
Then the DDS evaluation is done in backend for PNR TC081
And DDS identifies MSL = AC 430 YUL?YYZ (only segment)
And DDS checks the cancellation code on MSL ? NONE
And DDS checks the first arrival delay code on MSL ? 99 (upline) ? no fallback needed
And DDS classifies 99 as CONTROLLABLE (upline � within carrier control)
And DDS calculates delay = 17:00 ? 10:00 = 7 hours ? band 6 to <9 hours ? Tier 2
And DDS validates Aeroplan Elite 25K status as active and in good standing
And DDS sets eligibility = CAD 700 Cash / CAD 840 AC Wallet
And DDS returns FD-APPR-EL-02 and sends results to Trip Tracer UI

TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC081
? Promised Itinerary: Flight AC 430, Route: YUL ? YYZ, Scheduled Arrival: 10:00
? Current Itinerary: Flight AC 430, Route: YUL ? YYZ, Status: ARRIVED LATE, 10:00 ? 17:00, Delay: +7H 00M
? History: No booking changes (no VOL or INVOL)
? Regime: APPR (1 regime)
? MSL Flight: AC 430 � YUL ? YYZ � Code 99 � "Delayed due to upline controllable carrier issue"
? Cancellation code: NONE ; Fallback: FALSE
? Delay Classification: +7H 00M � CONTROLLABLE � DELAY_6_TO_LT_9_HOURS
? Aeroplan: 9876543210 (Elite 25K � linked)
? DDS outcome code: FD-APPR-EL-02
Flight Compensation Assessment:
? MR PHILIPPE TREMBLAY | ELIGIBLE | DELAY_6_TO_LT_9_HOURS | CAD 700.00 Cash / CAD 840.00 AC Wallet (+20%) | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource
And CyberSource returns: GREEN LIGHT (Pass)

ELIGIBLE RESULT DISPLAY (FD-05a):
Then the chatbot displays: "I've checked your flight details, and flight AC 430 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7 hours. Based on the Air Passenger Protection Regulations (APPR), you are eligible for compensation for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."

CLAIM PAYMENT & AEROPLAN OFFER (FD-06b / FD-07):
Then the chatbot asks: "Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada" ? Currency = CAD
Then the chatbot checks Aeroplan status: Philippe Tremblay has linked Aeroplan 9876543210, Elite 25K in good standing
And the chatbot offers BOTH options:
  "As an Aeroplan Elite 25K member, you can choose to receive:
   Cash: CAD 700 sent via Interac e-Transfer, which takes 5 to 10 business days to process.
   AC Wallet: CAD 840 (including a 20% bonus of CAD 140) added to your AC Wallet immediately with no expiry.
   How would you like to receive your funds?"
And the user selects "Cash"
Then the system checks which payment method is mapped based on country of residence ? Interac (CANADA)
Then the chatbot responds: "Your payment will be made through Interac e-Transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information. Would you like to use p***@gmail.com? Please note that only one email address can be used for this compensation/reimbursement and it can't be changed once confirmed."
And the user confirms: "Yes, use this email"
Then the chatbot does NOT ask for bank account, card, transit or institution numbers
Then the system checks that IDV is not completed

IDENTITY VERIFICATION (PERSONA � FD-07b):
Then the chatbot responds: "I must verify your identity for payment security. Please click here to get started"
And the chatbot displays a "Get verified" button
When the user clicks on the button
Then the system checks IDV at Payment and consent
And the customer completes Persona verification
And Persona returns: IDV PASS
Then the chatbot responds: "Your identity has been verified successfully. Let's proceed to finalize your claim."

CLAIM CONFIRMATION & CASE CREATION (GLOB-09):
Then the chatbot displays:
  "Please review your compensation details:
   Deposit Amount: CAD 700
   Payment Method: Interac e-Transfer (p***@gmail.com)
   After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps that will also include the password required to access the secure payment link, which will be sent in a separate email.
   Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user confirms "Yes"
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically

NOTIFICATION & WRAP-UP (GLOB-11):
Then Adobe sends a notification email to p***@gmail.com
And the email contains: Case Reference, CAD 700 Cash (Interac e-Transfer), Aeroplan Elite 25K confirmation, regulation (APPR), flight details (AC 430 YUL?YYZ), disruption reason (Code 99 � upline, controllable), next steps, tracking link
Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No]
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

Given the case has been created for claimant "Philippe Tremblay" with PNR "TC081"
Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
And the Case Status should be "In Review" or "Done"
And the Created date and Last Updated date should be populated
And the SLA countdown should be tracking correctly
And the Team assignment should be correct
And no banners should be displayed for identified and authenticated Auth Flow 1 user
And the Decision Assist panel should NOT be greyed out
And the Claimant Name should be "Philippe Tremblay"
And the Claimant Type should be "Adult"
And the Authentication should be "Pass"
And the PNR should be "TC081"
And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated
And the Regime should be "APPR"
And the Full Name should be "Philippe Tremblay"
And the Tags should include "Claimant", "Adult", and "Elite 25K"
And the Email should be "p***@gmail.com"
And the Phone should be "+1***234"
And the Address and Profile ID should be populated
And the Aeroplan should be "9876543210" linked and active
And the Tier Status should be "Elite 25K / Member"
And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight
And the Disruption Code should show "Code 99 (upline) � Controllable"
And the Ancillary Fee section should be present and empty
And the Eligibility and Compensation section should show "CAD 700 (Cash � Interac e-Transfer)"
And the AC Wallet option (CAD 840 with 20% bonus) should be visible as the offered alternative but NOT selected
And the Decision Assist Panel should auto-appear for FD topic
And DDS should have run automatically with no agent action needed
And the DDS outcome should be "FD-APPR-EL-02"
And the eligibility decision should be pre-populated as "ELIGIBLE" (APPR, Code 99 Controllable, 7h delay, Tier 2)
And the Duplicate Check should have run automatically using baseline data "Philippe Tremblay + TC081 + YUL?YYZ + FD"
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

Given the customer's country of residence is "Canada"
Then the currency should be set to "CAD"
And the customer has Aeroplan "9876543210" linked with Elite 25K status in good standing
And both options should have been offered: Cash (CAD 700 Interac) AND AC Wallet (CAD 840 with 20% top-up)
And the customer selected "Cash" ? Payment method = Interac e-Transfer
And AC Wallet was offered but NOT selected ? AC Wallet payout NOT dispatched
And only the Interac email "p***@gmail.com" should be collected (no bank, card, transit or institution numbers)
And exactly one compensation record of CAD 700 should be created with GL account and cost center
And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team
And Cash should be dispatched to Unifier
And Unifier should send an acknowledgement back
And the end-of-day report should be received from Interac
And the status should be "Pending" transitioning to "Cashed" or "Rejected" or "Expired"
And if the payment is unclaimed after 35 days the status should be set to "Expired"
And the Claims Dashboard Compensation tab should show "CAD 700", payment method "Cash" via "Interac", and status updated via talkback

Expected Results: DDS returns FD-APPR-EL-02. Trip Tracer: Promise = 10:00, Actual = 17:00, Delay = 7 hours, MSL = Leg 1, no cancellation code, arrival code 99 (upline, controllable), Fallback = FALSE, Regime = APPR. The linked Elite 25K profile gets both Cash (CAD 700) and AC Wallet (CAD 840). The customer picks Cash, and CAD 700 is paid by Interac to p***@gmail.com. CyberSource GREEN, Persona PASS. Claims Dashboard: Resolved/Done, Elite 25K, Code 99, CAD 700 Interac payout.