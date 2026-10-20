Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I flew from London Heathrow to Toronto but my connecting flight from Toronto to Vancouver was cancelled due to a crew issue. I'm stuck in Toronto and never made it to Vancouver. Can I get compensation?"

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
And the user provides "Oliver Bennett"
Then the chatbot responds:
"Thanks, Oliver! And, what is your booking reference number?"
And the user provides "PNR: TC092"
Then the chatbot searches Trip Tracer for PNR: TC092
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:

Email: o***@gmail.com

Phone: +44***456

And the user selects "Email: o***@gmail.com"
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

Oliver Bennett (Adult)

Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:

Segment 1: Flight AC 849, London Heathrow (LHR) ? Toronto (YYZ), June 4, 2026 � COMPLETED

Segment 2: Flight AC 121, Toronto (YYZ) ? Vancouver (YVR), June 4, 2026 � CANCELLED

Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK (GenUC-18):
Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments)
Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 CANCELLED
Then the chatbot determines: Claim applies to Segment 2 (AC 121 YYZ?YVR � CANCELLED)

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks: Hours since scheduled departure of Leg 2
And the system calculates: Scheduled departure was June 4, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for EU 261 (UK) = 6 years ? within limitation ? PROCEED

REGIME DETERMINATION:
Then the system determines: Journey origin = LHR (UK) ? EU 261 (UK) applies to entire journey
And the system checks: Customer stuck at midpoint (YYZ), never reached YVR, did not return to LHR ? No Travel Incomplete

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

Trip Tracer UI Validation
Then the tester opens Trip Tracer UI for PNR: TC092

? Segment 1: Flight: AC 849, Route: LHR ? YYZ, Status: COMPLETED (on time)

? Segment 2: Flight: AC 121, Route: YYZ ? YVR, Status: CANCELLED (claim filed)

? Customer Status: NO TRAVEL - INCOMPLETE (customer stranded at YYZ midpoint � did not reach YVR, did not return to LHR)

? History - No onward travel to YVR; no return flight to LHR booked

? Regime: EU 261 (UK) (UK origin � LHR) + APPR (Canada)

? MSL FLIGHT: AC 121 � YYZ ? YVR

? Cancellation Code: CREW � 4-character Netline code

? "Cancellation � crew unavailability"

? CONTROLLABLE (CREW in Controllable list)

? Disruption Type: CANCELLATION (Leg 2)

? EU 261 UK: No Travel Incomplete, Controllable = �520 (flat rate)

? APPR: No Travel Incomplete, Controllable = $400 CAD

? Fallback: FALSE (cancellation code available)

? Most Generous: EU 261 UK selected (�520 ? ~$880 CAD > $400 CAD)

Flight Compensation:

? MR OLIVER BENNETT | ELIGIBLE | EU261_UK_NO_TRAVEL_INCOMPLETE | GBP 520.00 | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment

ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like your connecting flight AC 121 from Toronto (YYZ) to Vancouver (YVR) on June 4, 2026 was cancelled. Based on the UK Air Passenger Rights regulations (EU 261), you may be eligible for compensation for this cancellation. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."

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
And an eligible notification email is sent to o***@gmail.com
And the email contains: Case Reference, compensation amount (�520 GBP), regulation (EU 261 UK), flight details (Leg 2: YYZ?YVR CANCELLED), travel status (No Travel - Incomplete), disruption reason (cancellation code CREW � controllable), next steps, tracking link

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"

I would like you to � new flow

No

And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Oliver Bennett" with PNR "TC092"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Oliver Bennett"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC092"
    And the Regime should be "EU 261 (UK) + APPR"
    And the Full Name should be "Oliver Bennett"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "o***@gmail.com"
    And the Phone should be "+44***456"
    And the Journey should show "Segment 1: LHR ? YYZ" as completed and "Segment 2: YYZ ? YVR" with claim filed as cancelled
    And the Eligibility and Compensation section should be present and populated with compensation "�520 GBP" as UK flat rate for No Travel Incomplete
    And the Cancellation Code should be "CREW" indicating Controllable
    And the Dual Regime should show EU 261 UK at �520 as selected and APPR at $400 CAD as not selected
    And the most generous regime should be EU 261 UK at �520 because at typical exchange rates �520 is approximately $880 CAD which is greater than APPR $400 CAD
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 UK with No Travel Incomplete and controllable cancellation code CREW and Leg 2
    And the No Travel status should be "INCOMPLETE" as the customer did NOT go back to LHR
    And the Duplicate Check should have run automatically and the result should be "No duplicate found"
    And the CyberSource result should be "GREEN"
    And the system should have appended the booking record automatically
    And an eligible notification email should have been sent to "o***@gmail.com" containing "�520 GBP" and "EU 261 UK" and "Leg 2 YYZ?YVR CANCELLED" and "No Travel - Incomplete" and "cancellation code CREW"
    And the Final Status should be "Resolved"
    And the case should be in read-only mode
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the customer's country of residence is "United Kingdom"
    Then the currency should be set to "GBP"
    And the payment method should be "BSM � Email Payment"
    And the customer has no Aeroplan linked so only Cash should be offered
    And the compensation amount should be "�520" for EU UK No Travel Incomplete with controllable cancellation code CREW
    And this is a No Travel case so both compensation and refund should be processed
    And a PS agent task should be created in Claims Dashboard for the refund
    And the agent should action the refund in ARD Web and mark it as refunded
    And a compensation record should be created in the backend with GL account and cost center
    And in UAT the batch file should be triggered manually
    And Cash should be dispatched to Unifier via HSBC channel for BSM
    And Unifier should send an acknowledgement back
    And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired"
    And currency conversion logging should record GBP amount and CAD equivalent and exchange rate and source and date
    And the Claims Dashboard Compensation tab should show "�520 GBP" with payment method "Cash" via "BSM � Email Payment" and status updated via talkback
    And the Claims Dashboard should show a refund record with PS agent task status tracked separately

Expected Results:
DDS returns FD-EU-EL-33. Trip Tracer: Leg 1 = Completed (on time); Leg 2 = CANCELLED; MSL = Leg 2 (AC 121 YYZ?YVR); Cancellation Code = CREW (4-char Netline � Controllable); No Travel = Incomplete (customer stranded at YYZ midpoint � did not reach YVR, did not return to LHR); Fallback = FALSE; EU 261 (UK) + APPR. Dual Regime: EU-UK = EL-33 (�520, No Travel Incomplete); APPR = $400 CAD (not selected). Most Generous: EU-UK selected (�520 ? ~$880 CAD > $400). CyberSource: GREEN. IDV: PASS. Payment: BSM � Email Payment UK GBP. Claims Dashboard: EU-UK EL-33 ? SELECTED; No Travel = Incomplete; MSL = Leg 2; Cancellation Code = CREW; Fallback = FALSE; Multi-leg (LHR?YYZ?YVR); DDS = FD-EU-EL-33.