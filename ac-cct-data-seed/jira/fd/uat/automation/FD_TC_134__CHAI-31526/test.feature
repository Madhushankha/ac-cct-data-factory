Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I flew from Pointe-�-Pitre to Montreal but my connecting flight from Montreal to Toronto was cancelled due to a crew issue. I'm stuck in Montreal � I didn't go back to Guadeloupe and I never made it to Toronto. Can I get compensation?"

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
And the user provides "Maxime Th�odore"
Then the chatbot responds:
"Thanks, Maxime! And, what is your booking reference number?"
And the user provides "PNR: TC093"
Then the chatbot searches Trip Tracer for PNR: TC093
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:

Email: m***@gmail.com

Phone: +590***901

And the user selects "Email: m***@gmail.com"
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

Maxime Th�odore (Adult)

Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:

Segment 1: Flight AC 1802, Pointe-�-Pitre (PTP) ? Montreal (YUL), June 7, 2026 � COMPLETED

Segment 2: Flight AC 422, Montreal (YUL) ? Toronto (YYZ), June 7, 2026 � CANCELLED

Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK (GenUC-18):
Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments)
Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 CANCELLED
Then the chatbot determines: Claim applies to Segment 2 (AC 422 YUL?YYZ � CANCELLED)

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks: Hours since scheduled departure of Leg 2
And the system calculates: Scheduled departure was June 7, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction � Guadeloupe is French overseas territory) = 5 years ? within limitation ? PROCEED

REGIME DETERMINATION:
Then the system determines: Journey origin = PTP (Guadeloupe � EU outermost region) ? EU 261 (Guadeloupe)
And the system checks: Destination = YYZ (Toronto, Canada) ? APPR also applies
And the system checks: Customer stuck at midpoint (YUL), never reached YYZ, did not return to PTP ? No Travel Incomplete
And the system checks: Guadeloupe compensation rule ? Flat �400

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

Trip Tracer UI Validation
Then the tester opens Trip Tracer UI for PNR: TC093

? Segment 1: Flight: AC 1802, Route: PTP ? YUL, Status: COMPLETED (on time)

? Segment 2: Flight: AC 422, Route: YUL ? YYZ, Status: CANCELLED (claim filed)

? Customer Status: NO TRAVEL - INCOMPLETE (stranded at YUL � did not return to PTP, did not reach YYZ)

? History - Customer stranded at mid-point YUL; no rebooking; no return to origin

? Regime: EU 261 (Guadeloupe / DOM-TOM) + APPR (Canada destination)

? Compensation Rule: Flat �400 (Guadeloupe single band � DELAY_GTE_3_HOURS)

? MSL FLIGHT: AC 422 � YUL ? YYZ

? Cancellation Code: CREW � 4-character Netline code, NOT a numeric delay code

? "Cancellation � crew unavailability"

? CONTROLLABLE (CREW is in the Controllable cancellation code list: COMM, CREW, EQUI, FUEL, HDLG, HOLI, OPER, POSI, REPO, ROTA, RTNS, TECH)

? Disruption Type: CANCELLATION (Leg 2, mid-journey)

? EU 261 Guadeloupe: No Travel Incomplete, Controllable = �400 (flat rate)

? APPR: No Travel Incomplete, Controllable = $400 CAD

? Fallback: FALSE (cancellation code CREW is available � Gate 9 uses cancellation code first in priority order: cancellation code ? first arrival delay code ? first departure delay code)

? Most Generous: EU 261 Guadeloupe selected (�400 ? ~$590 CAD > $400 CAD)

Flight Compensation:

? MR MAXIME TH�ODORE | ELIGIBLE | EU261_GUADELOUPE_NO_TRAVEL_INCOMPLETE | EUR 400.00 | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment

ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like your connecting flight AC 422 from Montreal (YUL) to Toronto (YYZ) on June 7, 2026 was cancelled. Based on the EU Air Passenger Rights regulations (EU 261/2004), you may be eligible for compensation for this cancellation. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."

CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "France"
Then the system determines: Country = France (Guadeloupe) ? Currency = EUR

CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot checks if the claim is for multiple pax ? No
Then the chatbot responds: "You are entitled to receive a �400 EUR compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency."
And user provides "Yes"
Then system checks which payment method is mapped based on country of residence ? BSM � Email Payment (France/Guadeloupe)

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
And an eligible notification email is sent to m***@gmail.com
And the email contains: Case Reference, compensation amount (�400 EUR), regulation (EU 261/2004), flight details (Leg 2: YUL?YYZ CANCELLED), travel status (No Travel - Incomplete), disruption reason (cancellation code CREW � controllable), next steps, tracking link

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"

I would like you to � new flow

No

And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Maxime Th�odore" with PNR "TC093"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Maxime Th�odore"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC093"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "EU 261 (Guadeloupe / DOM-TOM) + APPR"
    And the Full Name should be "Maxime Th�odore"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "m***@gmail.com"
    And the Phone should be "+590***901"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Segment 1: PTP ? YUL" as completed and "Segment 2: YUL ? YYZ" with claim filed as cancelled
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and populated with compensation "�400 EUR" as Guadeloupe flat rate for No Travel Incomplete
    And the Cancellation Code should be "CREW" as a 4-character Netline code indicating Controllable
    And the Dual Regime should show EU 261 Guadeloupe at �400 as selected and APPR at $400 CAD as not selected
    And the most generous regime should be EU 261 Guadeloupe at �400 because at typical exchange rates �400 is approximately $590 CAD which is greater than APPR $400 CAD
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 Guadeloupe with No Travel Incomplete and controllable cancellation code CREW
    And the No Travel status should be "INCOMPLETE" as stranded at YUL midpoint and not Origin and not Return
    And the Duplicate Check should have run automatically using baseline data "Maxime Th�odore + TC093 + PTP?YUL?YYZ + FD"
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
    And an eligible notification email should have been sent via Adobe containing compensation "�400 EUR" and regulation "EU 261/2004" and travel status "No Travel - Incomplete" and flight details "Leg 2: YUL?YYZ CANCELLED" and cancellation code "CREW � Controllable"
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Resolved"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the customer's country of residence is "France (Guadeloupe)"
    Then the currency should be set to "EUR"
    And the payment method should be "BSM � Email Payment"
    And the customer details should be collected including email address and phone number
    And the customer has no Aeroplan linked so only Cash should be offered
    And the compensation amount should be "�400" as Guadeloupe flat rate for No Travel Incomplete with controllable cancellation code CREW
    And this is a No Travel case so both compensation and refund should be processed
    And a PS agent task should be created in Claims Dashboard for the refund
    And the agent should action the refund in ARD Web and mark it as refunded
    And a compensation record should be created in the backend with GL account and cost center
    And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team
    And Cash should be dispatched to Unifier via HSBC channel for BSM
    And Unifier should send an acknowledgement back
    And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired"
    And currency conversion logging should record EUR amount and CAD equivalent and exchange rate and source and date
    And the Claims Dashboard Compensation tab should show payout details with amount in EUR and payment method "Cash" via "BSM � Email Payment" and status updated via talkback
    And the Claims Dashboard should show a refund record with PS agent task status tracked separately

Expected Results:
DDS returns FD-EU-EL-35. Trip Tracer: Leg 1 = Completed; Leg 2 = CANCELLED; MSL = Leg 2 (AC 422 YUL?YYZ); Cancellation Code = CREW ; No Travel = Incomplete; Fallback = FALSE (cancellation code available � used first per Gate 9 priority); EU 261 (Guadeloupe) + APPR. Guadeloupe Rate: Flat �400 . Dual Regime: EU-Guadeloupe = EL-35 (�400, No Travel Incomplete); APPR = $400 CAD (not selected). Most Generous: EU-Guadeloupe selected (�400 ? ~$590 CAD > $400). CyberSource: GREEN. IDV: PASS. Payment: BSM � Email Payment Guadeloupe EUR. Claims Dashboard: EU-Guadeloupe EL-35 ? SELECTED; �400; No Travel = Incomplete; Stranded = YUL; MSL = Leg 2; Cancellation Code = CREW; Fallback = FALSE; Multi-leg (PTP?YUL?YYZ); DDS = FD-EU-EL-35.