Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?
Then user selects English
Then an alert information is displayed " Please note  that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot ask "How can I help you today?"
And the user says "My flight was delayed about 4 hours, I'd like to check if I'm eligible for compensation and I'd prefer to get it on my Aeroplan account"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd liketo be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds:
"I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Marie-Claire Dubois"
Then the chatbot responds:
"Thanks, Marie-Claire! And, what is your booking reference number?"
And the user provides "PNR: TC002"
Then the chatbot searches Trip Tracer for PNR: TC002
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: m***@gmail.com
� Phone: +1***234
And the user selects "Email: m***@gmail.com"
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
� Marie-Claire Dubois (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 302
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: January 15, 2026
� Arrival Delay: 4 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival
And the system calculates: Arrival was January 15, 2026; current date is January 28, 2026 ? 312 hours ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption
And the system calculates: Disruption January 15, 2026; filing January 28, 2026 ? 13 days ? within 366 days ? PROCEED

TRIAGE & DDS EVALUATION (All 7 Levels):
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC002
? Promised Itinerary - Flight: AC 302, Route: YUL ? YYZ, Scheduled Arrival: 14:00
? Current Itinerary - Flight: AC 302, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: ~~14:00~~ ? Actual: 18:00, Delay: +4H 00M
? Regime: APPR (1 regime)
? MSL FLIGHT: AC 302 � YUL ? YYZ � 67
? "Delayed due to Crew "
? Delay: +4H 00M � CONTROLLABLE
Flight Compensation:
  ? MS MARIE-CLAIRE DUBOIS | ELIGIBLE | DELAY_3_TO_LT_6_HOURS | CAD 480.00 (Wallet) | [expiry date]


FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment

ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 302 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours . Based on the Air Passenger Protection Regulations (APPR), you may be eligible for compensation for this delays. I'll guide you through the next steps so we can get your claim submitted and processes as quickly as possible."

CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada"
Then the system determines: Country = Canada ? Currency = CAD

CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (Aeroplan #: 9876546710)
Then the chatbot checks: Aeroplan account in good standing? ? YES
Then the chatbot offers BOTH options:
"Since you have an AC wallet, you can choose to either recieve:
� Cash: CAD $400 will be compensated and takes 5 to 10 business days to process the payment.
� AC Wallet: CAD $480 will be added to your AC wallet immediately and has no expiry.
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
Then the chatbot responds: "Thank you. You will be receiving $400 CAD converted into the currency associatedto your profile.
Deposit Amount: $480 CAD
Payment Method: AC Wallet
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that payment details cannot be changed after submission"
When the user clicks on "Yes"

CASE CREATION (GLOB-09):
Then chatbot responds: "Thank you. Your claim has been submitted and will be processed within 10 business days.
A confirmation email will be sent to you with details on how to monitor your claim status and payment updates.
Please refer to that email for any follow-up information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to m***@gmail.com
And the email contains: Case Reference, compensation amount ($480 AC Wallet), Aeroplan confirmation, regulation (APPR), flight details, tracking link

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Marie-Claire Dubois" with PNR "TC002"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" mapped from chatbot intent
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Marie-Claire Dubois"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC002"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR"
    And the Full Name should be "Marie-Claire Dubois"
    And the Email should be "m***@gmail.com"
    And the Phone should be "+1***234"
    And the Address should be populated
    And the Aeroplan should be "9876546710" linked and in good standing
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
    And the customer has Aeroplan "9876546710" linked and in good standing
    And both options should be offered: Cash at $400 and AC Wallet at $480 with 20% top-up
    And the customer selects "AC Wallet"
    And the 20% top-up should be applied converting $400 to $480
    And AC Wallet should only be offered because this is flight disruption APPR
    And a compensation record should be created
    And the record should be picked up by the daily evening batch file
    And the record should be dispatched to EIP and NOT Unifier
    And EIP should convert from CAD to the customer's Aeroplan profile country currency
    And EIP should check Aeroplan account validity confirming it is active and not frozen
    And EIP should send to iGiga
    And iGiga should send to iFly for deposit
    And iFly should talk back to EIP
    And EIP should talk back to Claims Dashboard with deposited amount, exchange rate used, and status "Completed" or "Issued"
    And if the Aeroplan account is frozen or closed a rejection with error message should be returned
    And a failure notification should be sent to the case
    And the agent should be flagged
    And the Claims Dashboard Compensation tab should show the correct amount
    And the currency should be displayed
    And the payment method should show "AC Wallet"
    And the status should be updated

Expected Results:
DDS returns FD-APPR-EL-01. Trip Tracer: Same as TC_001 � Promise 14:00, Actual 18:00, 4hrs, MSL Leg 1, Code 67, Controllable, APPR. Compensation: $480 CAD via AC Wallet ($400 base + 20% top-up). EAP check: Account active, deposit successful. Claims Dashboard: $480 AC Wallet; Aeroplan confirmed; All other DDS values same as TC_001.