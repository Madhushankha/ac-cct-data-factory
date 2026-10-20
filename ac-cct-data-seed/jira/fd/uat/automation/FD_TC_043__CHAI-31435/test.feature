Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
  "Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto was cancelled because of a fuel shortage and I didn't take any replacement flight. Can I get compensation?"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your cancelled flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "H�l�ne Bouchard"
Then the chatbot responds: "Thanks, H�l�ne! And, what is your booking reference number?"
And the user provides "PNR: TC083"
Then the chatbot searches Trip Tracer for PNR: TC083
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options: Email: h***@gmail.com | Phone: +1***678
And the user selects "Email: h***@gmail.com"
Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "629184"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds: "Your verification was successful. Let's proceed to the next step."

GROUP BOOKING CHECK:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
And system proceeds to passenger selection

PASSENGER SELECTION (GenUC-06):
Then the chatbot asks: "How many people are on your claim?"
And the chatbot displays: "I found 1 passenger on this booking: H�l�ne Bouchard (Adult). Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
  "I found the following journey:
   Flight: AC 444
   Route: Montreal (YUL) ? Toronto (YYZ)
   Date: May 18, 2026
   Status: CANCELLED
   Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the system calculates: Scheduled departure May 18, 2026; current date June 15, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption
And the system calculates: Disruption May 18, 2026; filing June 15, 2026 ? 28 days ? within 366 days ? PROCEED

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS identifies MSL = AC 444 YUL?YYZ (only segment, cancelled)
And DDS checks the cancellation code on MSL ? FUEL (ANF) ? used for controllability (no fallback needed)
And DDS classifies FUEL (ANF) as WITHIN CARRIER CONTROL ? CONTROLLABLE (fuel shortage)
And DDS detects travel outcome: No Travel � Origin (customer never departed YUL, no rebooking accepted)
And DDS applies APPR No Travel Origin rule: controllable cancellation ? flat CAD 400 + refund
And DDS returns FD-APPR-EL-13 and sends results to Trip Tracer UI

TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC083
? Promised Itinerary - Flight: AC 444, Route: YUL ? YYZ, Scheduled Departure: 09:00, Scheduled Arrival: 12:00
? Current Itinerary - Flight: AC 444, Route: YUL ? YYZ, Status: CANCELLED
? Customer Status: NO TRAVEL - ORIGIN (customer never departed, declined rebooking)
? History - No rebooking accepted
? Regime: APPR (1 regime)
? MSL FLIGHT: AC 444 � YUL ? YYZ � Cancellation Code: FUEL (ANF)
? "Cancellation � Fuel shortage"
? CONTROLLABLE (FUEL � ANF)
? Disruption Type: CANCELLATION
? APPR No Travel Origin: Controllable cancellation = flat CAD 400
? Fallback: FALSE (cancellation code available)
? DDS outcome code: FD-APPR-EL-13
Flight Compensation:
? MS H�L�NE BOUCHARD | ELIGIBLE | NO_TRAVEL_ORIGIN | CAD 400.00 | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment

ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
  "I've checked your flight details, and it looks like flight AC 444 from Montreal (YUL) to Toronto (YYZ) on May 18, 2026 was cancelled due to a fuel shortage. Based on the Air Passenger Protection Regulations (APPR), you may be eligible for compensation for this cancellation. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."

CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks: "Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada"
Then the system determines: Country = Canada ? Currency = CAD

CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No ? Cash only
Then the chatbot checks if the claim is for multiple pax ? No
Then the chatbot responds: "You are entitled to receive a CAD 400 compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency."
And the user provides "Yes"
Then the system checks which payment method is mapped based on country of residence ? Interac (CANADA)

PAYMENT METHOD � INTERAC (FD-07):
Then the chatbot responds:
  "Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information. Would you like to use h***@gmail.com? Please note that only one email address can be used for this compensation/reimbursement and it can't be changed once confirmed."
And the user confirms "Yes, use this email"
Then the chatbot does NOT ask for bank account, card, transit or institution numbers
Then the system checks that IDV is not completed

IDENTITY VERIFICATION � PERSONA (FD-07b):
Then the chatbot responds: "I must verify your identity for payment security. Please click here to get started"
And the chatbot displays a button "Get verified"
When the user clicks on the button
Then the system checks if IDV at Payment
And the system checks if the user has consented to IDV
And the chatbot sends Persona IDV link to the customer
And the customer completes identity verification via Persona
And Persona returns: IDV PASS
Then the chatbot responds: "Your identity has been verified successfully. Let's proceed to finalize your claim."

CLAIM AMOUNT CONFIRMATION FLOW:
Then the chatbot responds: "Please review your compensation details:
   Deposit Amount: CAD 400
   Payment Method: Interac e-Transfer (h***@gmail.com)
   After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps that will also include the password required to access the secure payment link, which will be sent in a separate email.
   Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user provides: "Yes"

CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe
And an eligible notification email is sent to h***@gmail.com
And the email contains: Case Reference, compensation amount (CAD 400), regulation (APPR), flight details (AC 444 YUL?YYZ CANCELLED), travel status (No Travel - Origin), disruption reason (Cancellation � FUEL (ANF) fuel shortage), next steps, tracking link

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No]
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
  Given the case has been created for claimant "H�l�ne Bouchard" with PNR "TC083"
  Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
  And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
  And the Case Status should be "In Review" or "Done"
  And the Created date and Last Updated date should be populated
  And the SLA countdown should be tracking correctly
  And the Team assignment should be correct
  And no banners should be displayed for identified and authenticated Auth Flow 1 user
  And the Decision Assist panel should NOT be greyed out
  And the Claimant Name should be "H�l�ne Bouchard"
  And the Claimant Type should be "Adult"
  And the Authentication should be "Pass"
  And the PNR should be "TC083"
  And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated
  And the Regime should be "APPR"
  And the Full Name should be "H�l�ne Bouchard"
  And the Tags should include "Claimant" and "Adult"
  And the Email should be "h***@gmail.com"
  And the Phone should be "+1***678"
  And the Address, Profile ID and Tier Status should be populated
  And the Aeroplan should be "Not linked"
  And the Journey should show "Bound 1: YUL ? YYZ" (CANCELLED) with claim filed for this flight
  And the Disruption Code should show "Cancellation Code FUEL (ANF) � fuel shortage � Controllable"
  And the travel status should show "No Travel � Origin"
  And the Ancillary Fee section should be present with no expected ancillary fees
  And the Eligibility and Compensation section should show "ELIGIBLE � CAD 400 (No Travel Origin, flat)"
  And the Decision Assist Panel should auto-appear for FD topic
  And DDS should have run automatically with no agent action needed
  And the DDS outcome should be "FD-APPR-EL-13"
  And the eligibility decision should be pre-populated as "ELIGIBLE" (APPR, No Travel Origin, FUEL (ANF) controllable)
  And the Duplicate Check should have run automatically using baseline data "H�l�ne Bouchard + TC083 + YUL?YYZ + FD"
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
  And a PS agent task for the refund should be visible on the case
  And the Agent Notes section should be accessible
  And the Audit Log should record all actions with timestamps and before/after values
  And Customer Communications should show the notification email chronologically
  And the chatbot transcript should be accessible and linked to the case
  And the Attachments tab should be empty
  And the Final Status should be "Resolved"
  And the case should be in read-only mode with no editable Decision Assist fields
  And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
  Given the customer's country of residence is "Canada"
  Then the currency should be set to "CAD"
  And the payment method should be "Interac e-Transfer"
  And only the customer's email "h***@gmail.com" should be collected (no bank, card, transit or institution numbers)
  And the customer has no Aeroplan linked so only Cash should be offered
  And the compensation amount should be "CAD 400" as a flat No Travel Origin amount
  And this is a No Travel case so both compensation and refund should be processed
  And a PS agent task should be created in Claims Dashboard for the refund
  And the agent should action the refund in ARD Web and mark it as refunded
  And exactly one compensation record should be created in the backend with GL account and cost center
  And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team
  And Cash should be dispatched to Unifier
  And Unifier should send an acknowledgement back
  And the end-of-day report should be received from Interac
  And the status should be "Pending" transitioning to "Cashed" or "Rejected" or "Expired"
  And if the payment is unclaimed after 35 days the status should be set to "Expired"
  And the Claims Dashboard Compensation tab should show "CAD 400" with payment method "Cash" via "Interac" and status updated via talkback
  And the Claims Dashboard should show a refund record with PS agent task status tracked separately

Expected Results: DDS returns FD-APPR-EL-13. In Trip Tracer:

Flight = CANCELLED and MSL = Leg 1 (the cancelled leg).

Cancellation code = FUEL (ANF), fuel shortage, controllable. Fallback = FALSE.

No Travel = TRUE, with No Travel status = Origin. Regime = APPR.

The system must identify No Travel Origin when the single leg is cancelled and the customer didn't travel. Compensation is CAD 400 flat by Interac (email only), plus a refund through a PS agent task in ARD Web. CyberSource is GREEN and Persona is PASS. Claims Dashboard: No Travel = TRUE, Status = Origin, Flight = Cancelled, Code = FUEL (ANF), DDS = FD-APPR-EL-13.