Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "Air Canada rebooked me to a late flight but then I found an earlier one and changed myself. Can I get compensation?"

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
And the user provides "Val�rie Dupont"
Then the chatbot responds:
"Thanks, Val�rie! And, what is your booking reference number?"
And the user provides "PNR: TC005"
Then the chatbot searches Trip Tracer for PNR: TC005
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:

Email: v***@gmail.com

Phone: +1***234

And the user selects "Email: v***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "482916"
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

Val�rie Dupont (Adult)

Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:

Segment 1: Flight AC 8302, Montreal (YUL) ? Kitchener-Waterloo (YKF), May 10, 2026 � COMPLETED

Segment 2: Flight AC 8402, Kitchener-Waterloo (YKF) ? Toronto (YYZ), May 10, 2026 � ARRIVED LATE

Arrival Delay at final destination (YYZ): 5 hours

Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK (GenUC-18):
Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments � MANY_TO_MANY rebooking, connection change)
Then the chatbot identifies: Segment 1 COMPLETED (YUL?YKF), Segment 2 ARRIVED LATE (YKF?YYZ)
Then the chatbot determines: Final destination = YYZ; Final arrival delay = 5h; MSL = Leg 2 (YKF?YYZ)

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival
And the system calculates: Arrival was May 10, 2026; current date is June 4, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption
And the system calculates: Disruption May 10, 2026; filing June 4, 2026 ? within 366 days ? PROCEED

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

Trip Tracer UI Validation
Then the tester opens Trip Tracer UI for PNR: TC005

? Rebooking Pattern: MANY_TO_MANY (2?2 legs, connection change) � Original YUL?YOW?YYZ rerouted to YUL?YKF?YYZ (different connection point)

? Promised Itinerary - 2-leg connecting: Leg 1 AC 8103 YUL?YOW; Leg 2 AC 8203 YOW?YYZ, Scheduled Final Arrival at YYZ: 10:00 (14-day mark)

? Current Itinerary (Rebooked � 2 legs after MANY_TO_MANY + VOL):

? Segment 1: Flight AC 8302, Route: YUL ? YKF, Status: COMPLETED, Dep: 10:00, Arr: 11:30

? Segment 2: Flight AC 8402, Route: YKF ? YYZ, Status: ARRIVED LATE, Dep: 12:30, Actual Arr: 15:00

? Final Destination Arrival: YYZ at 15:00

? Total Delay: +5H 00M (15:00 - 10:00 promise)

? Post-INVOL VOL: -2H 00M (customer moved to EARLIER connecting � NEGATIVE ? NOT DEDUCTED)

? Net Delay: +5H 00M (full delay, no deduction � negative VOL is NOT deducted)

? History:

? Original (14-day): 2-leg connecting YUL?YOW?YYZ arr 10:00

? Change 1 (Day -3): INVOL � AC rerouted through different connection YUL?YKF?YYZ (MANY_TO_MANY) ? arr 17:00

? Change 2 (Day -1): VOL � Customer moves to EARLIER connecting YUL?YKF?YYZ ? arr 15:00 (-2hrs NEGATIVE, NOT DEDUCTED � customer was mitigating delay)

? Regime: APPR (1 regime)

? MSL FLIGHT: AC 8402 � YKF ? YYZ � 62

? "Delayed due to operational requirements"

? Total Delay: +5H 00M � Post-INVOL VOL: -2H 00M (negative ? NOT DEDUCTED) � Net Delay: +5H 00M � CONTROLLABLE

? CRITICAL: Negative VOL must NOT reduce the delay � customer was trying to arrive sooner, not adding delay

Flight Compensation:

? MS VAL�RIE DUPONT | ELIGIBLE | DELAY_3_TO_LT_6_HOURS | CAD 400.00 | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment

ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like your journey from Montreal (YUL) to Toronto (YYZ) via Kitchener-Waterloo (YKF) was delayed by about 5 hours. Based on the Air Passenger Protection Regulations (APPR), you may be eligible for compensation for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."

CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada"
Then the system determines: Country = Canada ? Currency = CAD

CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot checks if the claim is for multiple pax ? No
Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency."
And user provides "Yes"
Then system checks which payment method is mapped based on country of residence ? Interac (CANADA)

PAYMENT METHOD � INTERAC (FD-07):
Then the chatbot responds:
"Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information. Would you like to use v***@gmail.com? Please note that only one email address can be used for this compensation/reimbursement and it can't be changed once confirmed."
And the user confirms "Yes, use this email"
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

CLAIM AMOUNT CONFIRMATION:
Then the chatbot responds: "Please review your compensation details:
Deposit Amount: $400 CAD
Payment Method: v***@gmail.com
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that payment details cannot be changed after submission"
When the user clicks on "Yes"

CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to v***@gmail.com
And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details (MANY_TO_MANY rebooking: original YUL?YOW?YYZ rerouted to YUL?YKF?YYZ), tracking link

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"

I would like you to � new flow

No

And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Val�rie Dupont" with PNR "TC005"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" mapped from chatbot intent
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Val�rie Dupont"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC005"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR"
    And the Full Name should be "Val�rie Dupont"
    And the Email should be "v***@gmail.com"
    And the Phone should be "+1***234"
    And the Aeroplan should be "Not linked"
    And the Address should be populated
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and populated for this automated FD case
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated
    And the Duplicate Check should have run automatically
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And the CyberSource result should be "GREEN"
    And the case should have proceeded automatically and not be parked in Fraud Queue
    And the system should have appended the booking record to the case automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case function from My Activities to get this case
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent to the customer
    And an eligible notification email should have been sent via Adobe
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps
    And Customer Communications should show the notification email
    And the chatbot transcript should be accessible and linked
    And the Attachments tab should be empty
    And the Final Status should be "Resolved"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the customer's country of residence is "Canada"
    Then the currency should be set to "CAD"
    And the payment method should be "Interac e-Transfer"
    And the customer has no Aeroplan linked so only Cash should be offered
    And a compensation record should be created
    And the record should be picked up by the daily evening batch file
    And the record should be dispatched to Unifier
    And Unifier should send an acknowledgement back
    And the end-of-day report should be received from Interac
    And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired"
    And if the customer does not claim the Interac payment within 35 days the status should be set to "Expired"
    And the Claims Dashboard Compensation tab should show the correct amount
    And the currency should be displayed
    And the payment method should show "Cash"
    And the status should be updated

Expected Results:
DDS returns FD-APPR-EL-01. Rebooking: MANY_TO_MANY (2?2 legs, connection change) � original 2-leg YUL?YOW?YYZ rerouted to 2-leg YUL?YKF?YYZ (different connection point). Promise = 10:00 (14-day mark); Actual final arrival at YYZ = 15:00; Total delay = 5hrs; Post-INVOL VOL = -2hrs (NEGATIVE ? NOT DEDUCTED � customer was mitigating delay); Net delay = 5hrs (full delay, no deduction); MSL = Leg 2 (AC 8402 YKF?YYZ); Code 62; Controllable. CRITICAL: Negative VOL must NOT reduce the delay. Compensation: $400 CAD (Tier 1, 3�<6hrs).