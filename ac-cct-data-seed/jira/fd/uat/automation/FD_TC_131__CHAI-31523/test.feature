Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Paris to Toronto was cancelled due to a crew issue and I didn't take any replacement flight. Can I get compensation?"

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
And the user provides "Beno�t Leclerc"
Then the chatbot responds:
"Thanks, Beno�t! And, what is your booking reference number?"
And the user provides "PNR: TC087"
Then the chatbot searches Trip Tracer for PNR: TC087
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:

Email: b***@gmail.com

Phone: +33***901

And the user selects "Email: b***@gmail.com"
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

Beno�t Leclerc (Adult)

Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:

Flight: AC 871

Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ)

Date: June 1, 2026

Status: CANCELLED

Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks: Hours since scheduled departure
And the system calculates: Scheduled departure was June 1, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction) = 5 years ? within limitation ? PROCEED

REGIME DETERMINATION:
Then the system determines: Origin = CDG (Paris, EU Mainland) ? EU 261 (EU Mainland)
And the system checks: Destination = YYZ (Toronto, Canada) ? APPR also applies
And the system checks: Customer did NOT travel ? No Travel Origin (remained at CDG)
And the system checks: EU Mainland No Travel Origin = flat �600 (no distance band split for No Travel)

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

Trip Tracer UI Validation
Then the tester opens Trip Tracer UI for PNR: TC087

? Promised Itinerary - Flight: AC 871, Route: CDG ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 13:00 (local YYZ)

? Current Itinerary - Flight: AC 871, Route: CDG ? YYZ, Status: CANCELLED

? Customer Status: NO TRAVEL - ORIGIN (customer remained at CDG, declined rebooking)

? History - No rebooking accepted

? Regime: EU 261 (EU Mainland) (EU origin � CDG, France) + APPR (Canada destination � YYZ)

? MSL FLIGHT: AC 871 � CDG ? YYZ

? Cancellation Code: CREW � 4-character Netline code, NOT a numeric delay code

? "Cancellation � crew unavailability"

? CONTROLLABLE (CREW is in the Controllable cancellation code list: COMM, CREW, EQUI, FUEL, HDLG, HOLI, OPER, POSI, REPO, ROTA, RTNS, TECH)

? Disruption Type: CANCELLATION

? EU 261 EU Mainland: No Travel Origin, Controllable = �600 (flat rate � no distance bands for No Travel Origin)

? APPR: No Travel Origin, Controllable = $400 CAD

? Fallback: FALSE (cancellation code CREW is available � Gate 9 uses cancellation code first)

? Most Generous: EU 261 EU Mainland selected (�600 ? ~$880 CAD > $400 CAD)

Flight Compensation:

? MR BENO�T LECLERC | ELIGIBLE | EU261_EU_MAINLAND_NO_TRAVEL_ORIGIN | EUR 600.00 | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment

ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 871 from Paris Charles de Gaulle (CDG) to Toronto (YYZ) on June 1, 2026 was cancelled. Based on the EU Air Passenger Rights regulations (EU 261/2004), you may be eligible for compensation for this cancellation. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."

CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "France"
Then the system determines: Country = France ? Currency = EUR

CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot checks if the claim is for multiple pax ? No
Then the chatbot responds: "You are entitled to receive a �600 EUR compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency."
And user provides "Yes"
Then system checks which payment method is mapped based on country of residence ? BSM � Email Payment (France)

PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07):
Then the chatbot responds: "Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information and updates about this case. Would you like to use [Email Address]? Please note that only one email address can be used for this compensation and it can't be changed once confirmed"
And user responds: "Yes, confirm this email."
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
Deposit Amount: �600 EUR
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
And an eligible notification email is sent to b***@gmail.com
And the email contains: Case Reference, compensation amount (�600 EUR), regulation (EU 261/2004), flight details (CDG?YYZ CANCELLED), travel status (No Travel - Origin), disruption reason (cancellation code CREW � controllable), next steps, tracking link

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"

I would like you to � new flow

No

And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Beno�t Leclerc" with PNR "TC087"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Beno�t Leclerc"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC087"
    And the Regime should be "EU 261 (EU Mainland) + APPR"
    And the Full Name should be "Beno�t Leclerc"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "b***@gmail.com"
    And the Phone should be "+33***901"
    And the Journey should show "Bound 1: CDG ? YYZ" with claim filed for this flight as cancelled
    And the Eligibility and Compensation section should be present and populated with compensation "�600 EUR" as EU Mainland flat rate for No Travel Origin
    And the Cancellation Code should be "CREW" as a 4-character Netline code indicating Controllable
    And the Dual Regime should show EU 261 EU Mainland at �600 as selected and APPR at $400 CAD as not selected
    And the most generous regime should be EU 261 EU Mainland at �600 because at typical exchange rates �600 is approximately $880 CAD which is greater than APPR $400 CAD
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically
    And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 EU Mainland with No Travel Origin and controllable cancellation code CREW and flat �600
    And the Duplicate Check should have run automatically and the result should be "No duplicate found"
    And the CyberSource result should be "GREEN"
    And the system should have appended the booking record automatically
    And an eligible notification email should have been sent to "b***@gmail.com" containing "�600 EUR" and "EU 261/2004" and "CDG?YYZ CANCELLED" and "No Travel - Origin" and "cancellation code CREW � Controllable"
    And the Final Status should be "Resolved"
    And the case should be in read-only mode with no editable Decision Assist fields

PAYMENT VALIDATION
    Given the customer's country of residence is "France"
    Then the currency should be set to "EUR"
    And the payment method should be "BSM � Email Payment"
    And the customer has no Aeroplan linked so only Cash should be offered
    And the compensation amount should be "�600" for EU Mainland No Travel Origin with controllable cancellation code CREW
    And this is a No Travel case so both compensation and refund should be processed
    And a PS agent task should be created in Claims Dashboard for the refund
    And the agent should action the refund in ARD Web and mark it as refunded
    And a compensation record should be created in the backend with GL account and cost center
    And in UAT the batch file should be triggered manually
    And Cash should be dispatched to Unifier via HSBC channel for BSM
    And Unifier should send an acknowledgement back
    And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired"
    And currency conversion logging should record EUR amount and CAD equivalent and exchange rate and source and date
    And the Claims Dashboard Compensation tab should show "�600 EUR" with payment method "Cash" via "BSM � Email Payment" and status updated via talkback
    And the Claims Dashboard should show a refund record with PS agent task status tracked separately

Expected Results:
DDS returns FD-EU-EL-25. Trip Tracer: CANCELLED; Cancellation Code = CREW; No Travel = Origin; Fallback = FALSE (cancellation code available � used first per Gate 9 priority); EU 261 (EU Mainland) + APPR. EU Mainland No Travel Origin = flat �600 . Dual Regime: EU Mainland = EL-25 (�600); APPR = $400 CAD (not selected). Most Generous: EU Mainland selected (�600 ? ~$880 CAD > $400). CyberSource: GREEN. IDV: PASS. Payment: BSM � Email Payment France EUR. Claims Dashboard: EU Mainland EL-25 ? SELECTED; �600; APPR $400 (not selected); No Travel = Origin; Cancellation Code = CREW; Fallback = FALSE; DDS = FD-EU-EL-25.