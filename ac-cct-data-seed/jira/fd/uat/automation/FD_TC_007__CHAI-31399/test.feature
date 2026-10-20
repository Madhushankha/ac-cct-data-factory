Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "Air Canada rebooked me after a disruption, then I changed to an even later flight myself. I'd like to claim compensation for my delay and get it in my AC Wallet."
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
And the user provides "Camille Brosseau"
Then the chatbot responds:
"Thanks, Camille! And, what is your booking reference number?"
And the user provides "PNR: TC004"
Then the chatbot searches Trip Tracer for PNR: TC004
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: c***@gmail.com
� Phone: +1***234
And the user selects "Email: c***@gmail.com"
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
� Camille Brosseau (Adult - Aeroplan Member)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 427
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: May 10, 2026
� Arrival Delay: 7 hours (net, after adjustment for your voluntary change)
Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg � MANY_TO_ONE consolidated 2 legs into 1) ? skip GenUC-18

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

TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC004
? Rebooking Pattern: MANY_TO_ONE (2?1 leg) � Original 2-leg connecting YUL?YOW?YYZ consolidated into direct YUL?YYZ
? Promised Itinerary - 2-leg connecting: Leg 1 AC 8102 YUL?YOW arr 09:00; Leg 2 AC 8202 YOW?YYZ arr 10:00 (14-day mark final arrival, no VOL before INVOL)
? Current Itinerary (Rebooked � 1 leg after MANY_TO_ONE + VOL):
  ? Flight AC 427, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual Arrival: 19:00
? Final Destination Arrival: YYZ at 19:00
? Total Gross Delay: +9H 00M (19:00 - 10:00 promise)
? Post-INVOL VOL Deduction: +2H 00M (customer voluntarily chose later flight: 17:00?19:00 = +2hrs POSITIVE, DEDUCTED)
? Net Delay: +7H 00M (9hrs - 2hrs deduction)
? History:
  ? Original (14-day): 2-leg connecting YUL?YOW?YYZ arr 10:00
  ? Change 1 (Day -3): INVOL � AC consolidated connecting into direct YUL?YYZ (MANY_TO_ONE) ? arr 17:00
  ? Change 2 (Day -1): VOL � Customer changes to later direct flight ? arr 19:00 (+2hrs POSITIVE, DEDUCTED)
? Regime: APPR (1 regime)
? MSL FLIGHT: AC 427 � YUL ? YYZ � 32
? "Delayed due to ramp loading operations"
? Total Delay: +9H 00M � Post-INVOL VOL Deduction: +2H 00M � Net Delay: +7H 00M � CONTROLLABLE
? Fallback: FALSE � Sister City: FALSE
Flight Compensation:
  ? MS CAMILLE BROSSEAU | ELIGIBLE | DELAY_6_TO_LT_9_HOURS | CAD 840.00 (Wallet) / CAD 700.00 (Cash) | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment

ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 427 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7 hours (after accounting for your requested schedule change). Based on the Air Passenger Protection Regulations (APPR), you may be eligible for compensation for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."

CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada"
Then the system determines: Country = Canada ? Currency = CAD

CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (Aeroplan #: 9876543210, Status: Basic Member)
Then the chatbot checks: Aeroplan account in good standing? ? YES
Then the chatbot offers BOTH options:
"Since you are an Aeroplan member, you can choose to either receive:
� Cash: CAD $700 will be compensated and takes 5 to 10 business days to process the payment.
� AC Wallet: CAD $840 (including a 20% bonus) will be added to your AC wallet immediately and has no expiry.
How would you like to receive your funds?"
And the user selects "AC Wallet"

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
Deposit Amount: $840 CAD
Payment Method: AC Wallet (Aeroplan #: 9876543210)
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that payment details cannot be changed after submission."
When the user provides: "Yes"

CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 10 business days. A confirmation email will be sent to you with details on how to monitor your claim status and payment updates."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to c***@gmail.com
And the email contains: Case Reference, compensation amount ($840 CAD AC Wallet), Aeroplan confirmation, regulation (APPR), flight details (MANY_TO_ONE rebooking: original YUL?YOW?YYZ consolidated to direct YUL?YYZ; net delay 7h), tracking link

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Camille Brosseau" with PNR "TC004"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" mapped from chatbot intent
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Camille Brosseau"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC004"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR"
    And the Full Name should be "Camille Brosseau"
    And the Email should be "c***@gmail.com"
    And the Phone should be "+1***234"
    And the Aeroplan should be "9876543210" linked and in good standing
    And the Address should be populated
    And the Profile ID should be populated
    And the Tier Status should be "Basic / Member"
    And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight
    And the Rebooking Pattern should be "MANY_TO_ONE" where original connecting YUL to YOW to YYZ was consolidated into direct YUL to YYZ
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
    And the customer has Aeroplan "9876543210" linked with Basic status in good standing
    And both options should be offered: Cash at $700 CAD and AC Wallet at $840 CAD with 20% top-up
    And the customer selects "AC Wallet"
    And the 20% top-up should be applied converting $700 base to $840 CAD
    And a compensation record should be created
    And the record should be picked up by the daily evening batch file
    And the record should be dispatched to EIP
    And EIP should convert from CAD to customer's Aeroplan profile currency if applicable
    And EIP should check Aeroplan account validity confirming it is active and not frozen
    And EIP should send to iGiga
    And iGiga should send to iFly for deposit
    And iFly should talk back to EIP
    And EIP should talk back to Claims Dashboard with deposited amount ($840 CAD), exchange rate used, and status "Completed" or "Issued"
    And the Claims Dashboard Compensation tab should show the correct amount ($840 CAD)
    And the currency should be displayed as "CAD"
    And the payment method should show "AC Wallet"
    And the status should be updated

Expected Results:
DDS returns FD-APPR-EL-01. Rebooking: MANY_TO_ONE (2?1 leg) � original 2-leg connecting YUL?YOW?YYZ consolidated into direct YUL?YYZ. Promise = 10:00 (14-day mark final arrival at YYZ, no VOL before INVOL); Actual = 19:00; Total gross delay = 9hrs; Post-INVOL VOL = +2hrs (POSITIVE ? DEDUCTED); Net delay = 7hrs (9hrs - 2hrs deduction, Tier 2: 6�<9hrs); MSL = AC 427 YUL?YYZ (single leg after consolidation); Code 32 (Ramp Loading); Controllable; APPR. Compensation: $840 CAD via AC Wallet ($700 base Tier 2 + 20% top-up) or $700 CAD Cash. Basic Aeroplan profile recognized and active.