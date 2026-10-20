Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from London Heathrow to Toronto was cancelled due to a crew issue and I didn't take any replacement flight. Can I get compensation?"

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
And the user provides "Henry Whitfield"
Then the chatbot responds:
"Thanks, Henry! And, what is your booking reference number?"
And the user provides "PNR: TC086"
Then the chatbot searches Trip Tracer for PNR: TC086
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:

Email: h***@gmail.com

Phone: +44***890

And the user selects "Email: h***@gmail.com"
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

Henry Whitfield (Adult)

Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:

Flight: AC 849

Route: London Heathrow (LHR) ? Toronto (YYZ)

Date: May 28, 2026

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
And the system calculates: Scheduled departure was May 28, 2026; current date is June 24, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for EU 261 (UK) = 6 years ? within limitation ? PROCEED

REGIME DETERMINATION:
Then the system determines: Origin = LHR (UK) ? EU 261 (UK)
And the system checks: Destination = YYZ (Toronto, Canada) ? APPR also applies
And the system checks: Customer did NOT travel ? No Travel Origin (remained at LHR)

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

Trip Tracer UI Validation
Then the tester opens Trip Tracer UI for PNR: TC086

? Promised Itinerary - Flight: AC 849, Route: LHR ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 14:00 (local YYZ)

? Current Itinerary - Flight: AC 849, Route: LHR ? YYZ, Status: CANCELLED

? Customer Status: NO TRAVEL - ORIGIN (customer remained at LHR, declined rebooking)

? History - No rebooking accepted

? Regime: EU 261 (UK) (UK origin � LHR) + APPR (Canada destination � YYZ)

? MSL FLIGHT: AC 849 � LHR ? YYZ

? Cancellation Code: CREW � 4-character Netline code, NOT a numeric delay code

? "Cancellation � crew unavailability"

? CONTROLLABLE (CREW is in the Controllable cancellation code list: COMM, CREW, EQUI, FUEL, HDLG, HOLI, OPER, POSI, REPO, ROTA, RTNS, TECH)

? Disruption Type: CANCELLATION

? EU 261 UK: No Travel Origin, Controllable = �520

? APPR: No Travel Origin, Controllable = $400 CAD

? Fallback: FALSE (cancellation code CREW is available � Gate 9 uses cancellation code first in priority order)

? Most Generous: EU 261 UK selected (�520 ? ~$880 CAD > $400 CAD)

Flight Compensation:

? MR HENRY WHITFIELD | ELIGIBLE | EU261_UK_NO_TRAVEL_ORIGIN | GBP 520.00 | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment

ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 849 from London Heathrow (LHR) to Toronto (YYZ) on May 28, 2026 was cancelled. Based on the UK Air Passenger Rights regulations (EU 261), you may be eligible for compensation for this cancellation. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."

CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "United Kingdom"
Then the system determines: Country = UK ? Currency = GBP

CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot checks if the claim is for multiple pax ? No
Then the chatbot responds: "You are entitled to receive a �520 GBP compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency."
And user provides "Yes"
Then system checks which payment method is mapped based on country of residence ? BSM � Email Payment (UK)

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
Deposit Amount: �520 GBP
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
And an eligible notification email is sent to h***@gmail.com
And the email contains: Case Reference, compensation amount (�520 GBP), regulation (EU 261 UK), flight details (LHR?YYZ CANCELLED), travel status (No Travel - Origin), disruption reason (cancellation code CREW � controllable), next steps, tracking link

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"

I would like you to � new flow

No

And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Henry Whitfield" with PNR "TC086"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Henry Whitfield"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC086"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "EU 261 (UK) + APPR"
    And the Full Name should be "Henry Whitfield"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "h***@gmail.com"
    And the Phone should be "+44***890"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: LHR ? YYZ" with claim filed for this flight as cancelled
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and populated with compensation "�520 GBP"
    And the Cancellation Code should be "CREW" as a 4-character Netline code indicating Controllable
    And the Dual Regime should show EU 261 UK at �520 as selected and APPR at $400 CAD as not selected
    And the most generous regime should be EU 261 UK at �520 because at typical exchange rates �520 is approximately $880 CAD which is greater than APPR $400 CAD
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 UK with No Travel Origin and controllable cancellation code CREW
    And the Duplicate Check should have run automatically using baseline data "Henry Whitfield + TC086 + LHR?YYZ + FD"
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
    And an eligible notification email should have been sent via Adobe containing compensation "�520 GBP" and regulation "EU 261 UK" and travel status "No Travel - Origin" and flight details LHR to YYZ cancelled and cancellation code CREW as Controllable
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Resolved"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the customer's country of residence is "United Kingdom"
    Then the currency should be set to "GBP"
    And the payment method should be "BSM � Email Payment"
    And the customer details should be collected including email address and phone number
    And the customer has no Aeroplan linked so only Cash should be offered
    And the compensation amount should be "�520" for EU UK No Travel Origin with controllable cancellation code CREW
    And this is a No Travel case so both compensation and refund should be processed
    And a PS agent task should be created in Claims Dashboard for the refund
    And the agent should action the refund in ARD Web and mark it as refunded
    And a compensation record should be created in the backend with GL account and cost center
    And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team
    And Cash should be dispatched to Unifier via HSBC channel for BSM
    And Unifier should send an acknowledgement back
    And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired"
    And currency conversion logging should record GBP amount and CAD equivalent and exchange rate and source and date
    And the Claims Dashboard Compensation tab should show payout details with amount in GBP and payment method "Cash" via "BSM � Email Payment" and status updated via talkback
    And the Claims Dashboard should show a refund record with PS agent task status tracked separately

Expected Results:
DDS returns FD-EU-EL-21. Trip Tracer: Flight = CANCELLED; MSL = Leg 1; Cancellation Code = CREW; No Travel = Origin; Fallback = FALSE ;Sister City = FALSE; EU 261 (UK) + APPR. Dual Regime: EU-UK = EL-21 (�520, No Travel Origin); APPR = $400 CAD (not selected). Most Generous: EU-UK selected (�520 ? ~$880 CAD > $400). CyberSource: GREEN. IDV: PASS. Payment: BSM � Email Payment UK GBP. Claims Dashboard: EU-UK EL-21 ? SELECTED; APPR $400 (not selected); No Travel = Origin; Cancellation Code = CREW; Fallback = FALSE; DDS = FD-EU-EL-21.