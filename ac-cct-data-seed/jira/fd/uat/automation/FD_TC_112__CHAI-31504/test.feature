Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Paris was supposed to land at Toronto Pearson but was diverted to Billy Bishop and arrived 4 hours late"
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
And the user provides "Marie Dupuis"
Then the chatbot responds:
"Thanks, Marie! And, what is your booking reference number?"
And the user provides "PNR: TC069"
Then the chatbot searches Trip Tracer for PNR: TC069
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: m***@gmail.com
� Phone: +33***567
And the user selects "Email: m***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "482917"
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
� Marie Dupuis (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 870
� Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ) [Landed at Billy Bishop (YTZ)]
� Date: May 8, 2026
� Arrival Delay: 4 hours
� Note: Arrived at sister-city airport LGW
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival
And the system calculates: Arrival was May 8, 2026; current date is June 10, 2026 ? >72 hours ? PROCEED
CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for EU 261 (France departure) = 5 years from disruption
And the system calculates: Disruption May 8, 2026; filing June 10, 2026 ? 33 days ? within 5 years ? PROCEED
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC069
? Promised Itinerary - Flight: AC 870, Route: CDG ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 14:00
? Current Itinerary - Flight: AC 870, Route: CDG ? YTZ (sister city), Status: ARRIVED, Actual Departure: 14:00, Actual Arrival: 18:00
? Sister City Check: YTZ ? YYZ = VALID PAIR (confirmed in DDS sister city config)
? Sister city accepted as equivalent destination
? Arrival Delay: 4 hours (? 3-hour threshold MET)
? Customer Status: TRAVELLED (completed journey)
? History - No changes recorded
? ? Regime: EU 261 (Rest of Europe � CDG origin) + APPR (Canada arrival)
? MSL FLIGHT: AC 6712 � CDG ? LGW � 42
? "Delay � scheduled maintenance"
? CONTROLLABLE ( Code 42)
? Origin Region: CDG = Rest of Europe
? EU 261 Compensation: Rest of Europe + delay ? 4 hrs + sister city = �600
? Fallback: FALSE
Flight Compensation:
? MS MARIE DUPUIS | ELIGIBLE | EU261_REST_OF_EUROPE_DELAY_GTE_4_HOURS_SISTER_CITY | EUR �600.00
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment
ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 870 from Paris Charles de Gaulle (CDG) to Toronto (YYZ) was delayed by about 4 hours. Based on the EU Air Passenger Rights regulations (EU 261/2004), you may be eligible for compensation for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."
COUNTRY OF RESIDENCE (FD-06):
Then the chatbot asks:
"Which country would you like to receive your reimbursement in? This determines the currency and payment method."
And the user selects "France"
Then the system determines: Country = France ? Currency = EUR ? Payment Method = BSM � Email Payment
CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? NO
Then the chatbot determines: AC Wallet NOT available
Then the chatbot offers CASH ONLY:
""You are entitled to receive a �600 EUR compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?""
PAYMENT METHOD (FD-07):
Then the chatbot responds: "Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information and updates about this case. Would you like to use [Email Address]? Please note that only one email address can be used for this compensation and it can't be changed once confirmed"
And user responds: "Yes, confirm this email."
Then system checks that IDV is not completed
IDENTITY VERIFICATION � PERSONA (FD-07b):
Then the chatbot responds:
"Before we process your payment, we need to verify your identity. You will receive a separate link to complete identity verification through our secure partner."
And the chatbot sends Persona IDV link to the customer
And the customer opens the Persona link
And the customer completes identity verification via Persona
And Persona returns: IDV PASS
Then the chatbot responds:
CLAIM AMOUNT CONFIRMATION FLOW:
Then the chatbot responds: "Please review your compensation details:
Deposit Amount: �600 EUR
Payment Method: Email
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps.
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user provides: "Yes"
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
CASE CREATION (GLOB-09):
Then the chatbot creates the case and responds:
"Your claim has been submitted. Case Reference: CASE-FD-20260610-083."
"You will also receive an email with your case number and a link to track your case status."
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to m***@gmail.com
And the email contains: Case Reference, compensation amount (�600), regulation (EU 261/2004), flight details (including sister city note: YTZ for YYZ), payment method (BSM � Email Payment)
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Marie Dupuis" with PNR "TC069"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Marie Dupuis"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC069"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "EU 261 (Rest of Europe)"
    And the Full Name should be "Marie Dupuis"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "m***@gmail.com"
    And the Phone should be "+33***567"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: CDG ? YYZ" with landing at YTZ as sister city and claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and populated with compensation "�600 EUR"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 with delay 4h and Rest of Europe origin and controllable Code 42 and sister city YTZ for YYZ
    And the Duplicate Check should have run automatically using baseline data "Marie Dupuis + TC069 + CDG?YYZ"
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
    And an eligible notification email should have been sent via Adobe containing compensation "�600 EUR" and regulation "EU 261/2004" and sister city note YTZ for YYZ and payment "BSM � Email Payment"
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Resolved"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the customer's country of residence is an EU country
    Then the currency should be set to "EUR"
    And the payment method should be "BSM � Email Payment"
    And the customer details should be collected including email address
    And the customer has no Aeroplan linked so only Cash should be offered
    And the compensation amount should be "�600" for EU Rest of Europe with delay of 4 hours or more
    And a compensation record should be created in the backend with GL account and cost center
    And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team
    And Cash should be dispatched to Unifier
    And Unifier should send an acknowledgement back
    And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired"
    And currency conversion logging should record EUR amount and CAD equivalent and exchange rate and source and date for PRISM/Exposure reporting
    And the Claims Dashboard Compensation tab should show payout details "�600 EUR" with payment method "Cash" via "BSM � Email Payment"

Expected Results:
Code 42; Controllable; Sister City = TRUE (YYZ?YTZ); Origin Region = Rest of Europe. Compensation: �600 (EU 261 Rest of Europe, delay ?4hrs). Regime Assessment: APPR = EL-01 ($400 CAD); EU 261 = EL-04 (�600, Sister City) ? SELECTED (most generous). CyberSource: GREEN. IDV: PASS. Payment: BSM � Email Payment France EUR. Claims Dashboard: EU 261 EL-04; �600; Rest of Europe; Sister City = TRUE; DDS = FD-EU-EL-04.