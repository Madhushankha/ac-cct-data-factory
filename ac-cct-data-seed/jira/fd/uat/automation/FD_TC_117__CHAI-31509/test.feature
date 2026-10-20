Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Pointe-�-Pitre in Guadeloupe to Montreal was delayed about 3 and a half hours due to a crew issue, I'd like to check if I'm eligible for compensation"
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
And the user provides "Jean-Pierre Duval"
Then the chatbot responds:
"Thanks, Jean-Pierre! And, what is your booking reference number?"
And the user provides "PNR: TC074"
Then the chatbot searches Trip Tracer for PNR: TC074
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: j***@gmail.com
� Phone: +590***123
And the user selects "Email: j***@gmail.com"
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
� Jean-Pierre Duval (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 1840
� Route: Pointe-�-Pitre (PTP) ? Montreal (YUL)
� Date: May 25, 2026
� Arrival Delay: 3 hours 30 minutes
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival
And the system calculates: Arrival was May 25, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED
CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction) = 5 years
And the system calculates: Disruption May 25, 2026; filing June 15, 2026 ? 21 days ? within limitation ? PROCEED
REGIME DETERMINATION:
Then the system determines applicable regime:
And the system checks: Origin airport = PTP (Pointe-�-Pitre, Guadeloupe)
And the system checks: Is Guadeloupe an EU territory? ? YES (DOM-TOM � French overseas department, EU outermost region)
And the system checks: Operating carrier = AC (Air Canada)
And the system determines: EU 261 (Guadeloupe) applies � EU outermost region originating flight on any carrier
And the system checks: Guadeloupe compensation rule ? Flat �400 regardless of distance band
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC074
? Promised Itinerary - Flight: AC 1840, Route: PTP ? YUL, Scheduled Arrival: 18:00 (local YUL time)
? Current Itinerary - Flight: AC 1840, Route: PTP ? YUL, Status: ARRIVED LATE, Scheduled Arrival: 18:00 ? Actual: 21:30, Delay: +3H 30M
? Regime: EU 261 (Guadeloupe / DOM-TOM)
? Origin: PTP (Guadeloupe � EU outermost region)
? Compensation Rule: Flat �400 (Guadeloupe-specific, no distance band tiers)
? MSL FLIGHT: AC 1840 � PTP ? YUL � 42
? "Delayed due to scheduled maintenance"
? Delay: +3H 30M � CONTROLLABLE
? Sister City: FALSE
? Fallback: FALSE
Flight Compensation:
? MR JEAN-PIERRE DUVAL | ELIGIBLE | EU261_GUADELOUPE_DELAY_GTE_3_HOURS | EUR 400.00 | [expiry date]
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment
ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 1840 from Pointe-�-Pitre (PTP) to Montreal (YUL) was delayed by about 3 hours and 30 minutes. Based on the EU Air Passenger Rights regulations (EU 261/2004), you may be eligible for compensation for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."
CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "France"
Then the system determines: Country = France ? Currency = EUR
CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot checks if the claim is for multiple pax ? No
Then the chatbot responds: "You are entitled to receive a �400 EUR compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency."
And user provides "Yes"
Then system checks which payment method is mapped based on country of residence ? BSM � Email Payment (France/Guadeloupe)
PAYMENT METHOD  � BSM EMAIL PAYMENT (FD-07):
Then the chatbot responds:
"Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information and updates about this case. Would you like to use [Email Address]? Please note that only one email address can be used for this compensation and it can't be changed once confirmed"
And user provides "Yes"
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
Deposit Amount: �400 EUR
Payment Method: BSM � Email Payment
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps.
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user provides: "Yes"
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to j***@gmail.com
And the email contains: Case Reference, compensation amount (�400 EUR), regulation (EU 261/2004), flight details (PTP?YUL), disruption reason, next steps, tracking link
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Jean-Pierre Duval" with PNR "TC074"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Jean-Pierre Duval"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC074"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "EU 261 (Guadeloupe / DOM-TOM)"
    And the Full Name should be "Jean-Pierre Duval"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "j***@gmail.com"
    And the Phone should be "+590***123"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: PTP ? YUL" with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and populated with compensation "�400 EUR" as Guadeloupe flat rate
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 Guadeloupe with delay 3h 30m and controllable Code 42 and flat �400
    And the Duplicate Check should have run automatically using baseline data "Jean-Pierre Duval + TC074 + PTP?YUL + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And the CyberSource result should be "GREEN"
    And the case should have proceeded automatically and not be parked in Fraud Queue
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent
    And an eligible notification email should have been sent via Adobe containing compensation "�400 EUR" and regulation "EU 261/2004" and flight details PTP to YUL
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Resolved"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the customer's country of residence is "France/EU"
    Then the currency should be set to "EUR"
    And the payment method should be "BSM � Email Payment"
    And the customer details should be collected including email address
    And the customer has no Aeroplan linked so only Cash should be offered
    And the compensation amount should be "�400" as Guadeloupe flat rate
    And a compensation record should be created in the backend with GL account and cost center
    And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team
    And Cash should be dispatched to Unifier
    And Unifier should send an acknowledgement back
    And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired"
    And currency conversion logging should record EUR amount and CAD equivalent and exchange rate and source and date for PRISM/Exposure reporting
    And the Claims Dashboard Compensation tab should show payout details "�400 EUR" with payment method "Cash" via "SEPA" and status updated via talkback

Expected Results:
DDS returns FD-EU-EL-09. Trip Tracer: Promise = 18:00; Actual = 21:30; Delay = 3.5hrs; MSL = Leg 1 (AC 1840); Code 42; Controllable; Fallback = FALSE; Sister City = FALSE. Guadeloupe Rate: 3+hrs ? flat �400. Dual Regime: EU-Guadeloupe = EL-09 (�400 flat); APPR = EL-01 ($400 CAD). Currency Comparison: �400 ? ~$590 CAD > $400 CAD ? EU-Guadeloupe selected (most generous). CyberSource: GREEN. IDV: PASS. Payment: Email. 