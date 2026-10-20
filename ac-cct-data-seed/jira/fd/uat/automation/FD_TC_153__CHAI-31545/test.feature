Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I flew from Toronto to Montreal but my connecting flight from Montreal to Tel Aviv was cancelled due to a crew issue. I'm stuck in Montreal � I didn't go back to Toronto and I never made it to Tel Aviv. Can I get compensation?"

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
And the user provides "Avi Goldstein"
Then the chatbot responds:
"Thanks, Avi! And, what is your booking reference number?"
And the user provides "PNR: TC120"
Then the chatbot searches Trip Tracer for PNR: TC120
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:

Email: a***@gmail.com

Phone: +972***567

And the user selects "Email: a***@gmail.com"
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

Avi Goldstein (Adult)

Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:

Segment 1: Flight AC 410, Toronto (YYZ) ? Montreal (YUL), June 7, 2026 � COMPLETED

Segment 2: Flight AC 084, Montreal (YUL) ? Tel Aviv (TLV), June 7, 2026 � CANCELLED

Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK (GenUC-18):
Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments)
Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 CANCELLED
Then the chatbot determines: Claim applies to Segment 2 (AC 084 YUL?TLV � CANCELLED)

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks: Hours since scheduled departure of Leg 2
And the system calculates: Scheduled departure was June 7, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for ASL = 1,460 days (4 years) from MSL scheduled departure date ? within limitation ? PROCEED

REGIME DETERMINATION:
Then the system determines: Destination = TLV (Israel) ? ASL applies
And the system checks: Origin = YYZ (Canada) ? APPR also applies
And the system checks: Customer stuck at midpoint (YUL), never reached TLV, did not return to YYZ ? No Travel Incomplete ? Branch B (did not remain at origin)

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

Trip Tracer UI Validation
Then the tester opens Trip Tracer UI for PNR: TC120

? Segment 1: Flight: AC 410, Route: YYZ ? YUL, Status: COMPLETED (on time)

? Segment 2: Flight: AC 084, Route: YUL ? TLV, Status: CANCELLED (claim filed)

? Customer Status: NO TRAVEL - INCOMPLETE (stranded at YUL � did not return to YYZ, did not reach TLV)

? History - Customer stranded at mid-point YUL; no rebooking; no return to origin

? Regime: ASL (Israel destination � TLV) + APPR (Canadian origin � YYZ)

? MSL FLIGHT: AC 084 � YUL ? TLV

? Cancellation Code: CREW � 4-character Netline code

? "Cancellation � crew unavailability"

? NOT EXTRAORDINARY CIRCUMSTANCE (CREW in controllable cancellation code list)

? Disruption Type: CANCELLATION (Leg 2, mid-journey)

? ASL No Travel: Branch B (did not remain at origin � at midpoint YUL) ? MSL cancelled ? Not Extraordinary ? ELIGIBLE

? Compensation: ILS 3,670 + Expenses + Pro-rated/full ticket refund

? Fallback: FALSE (cancellation code CREW available)

Flight Compensation:

? MR AVI GOLDSTEIN | ELIGIBLE | ASL_NO_TRAVEL_INCOMPLETE_NON_EXTRAORDINARY | ILS 3,670.00 | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment

ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like your connecting flight AC 084 from Montreal (YUL) to Tel Aviv (TLV) on June 7, 2026 was cancelled. Based on ISL regulations, you may be eligible for compensation for this cancellation. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."

CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Israel"
Then the system determines: Country = Israel ? Currency = ILS

CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot checks if the claim is for multiple pax ? No
Then the chatbot responds: "You are entitled to receive a ?3,670 ILS compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency."
And user provides "Yes"
Then system checks which payment method is mapped based on country of residence ? BSM � Email Payment (Israel)

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
Deposit Amount: ?3,670 ILS
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
And an eligible notification email is sent to a***@gmail.com
And the email contains: Case Reference, compensation amount (?3,670 ILS), regulation (ASL � Israel Aviation Services Law), flight details (Leg 2: YUL?TLV CANCELLED), travel status (No Travel - Incomplete), disruption reason (cancellation code CREW � not extraordinary), next steps, tracking link

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"

I would like you to � new flow

No

And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Avi Goldstein" with PNR "TC120"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation"
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Avi Goldstein"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC120"
    And the Regime should be "ASL + APPR"
    And the Full Name should be "Avi Goldstein"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "a***@gmail.com"
    And the Phone should be "+972***567"
    And the Journey should show "Segment 1: YYZ ? YUL" as completed and "Segment 2: YUL ? TLV" with claim filed as cancelled
    And the Eligibility and Compensation section should be present and populated with compensation "?3,670 ILS" as ASL fixed rate for No Travel Incomplete Not Extraordinary
    And the Cancellation Code should be "CREW" as Not Extraordinary Circumstance
    And No Travel should include Compensation at ?3,670 plus Expenses plus pro-rated or full ticket refund
    And the ASL No Travel Branch should be "B" as the customer did not remain at origin and is stranded at midpoint YUL
    And DDS should have run automatically
    And the eligibility decision should be pre-populated as "ELIGIBLE" under ASL with No Travel Incomplete and Not Extraordinary and cancellation code CREW and Leg 2 and Branch B
    And the No Travel status should be "INCOMPLETE" as stranded at YUL midpoint
    And the Duplicate Check should have run automatically and the result should be "No duplicate found"
    And the CyberSource result should be "GREEN"
    And the system should have appended the booking record automatically
    And an eligible notification email should have been sent to "a***@gmail.com" containing "?3,670 ILS" and "ASL" and "Leg 2 YUL?TLV CANCELLED" and "No Travel - Incomplete" and "cancellation code CREW � not extraordinary"
    And the Final Status should be "Resolved"
    And the case should be in read-only mode

PAYMENT VALIDATION
    Given the customer's country of residence is "Israel"
    Then the currency should be set to "ILS"
    And the payment method should be "BSM � Email Payment"
    And the customer has no Aeroplan linked so only Cash should be offered
    And the compensation amount should be "?3,670" as ASL fixed rate for No Travel Incomplete Not Extraordinary with cancellation code CREW
    And this is a No Travel case so compensation plus expenses plus pro-rated or full ticket refund should be processed
    And a PS agent task should be created in Claims Dashboard for the refund
    And the agent should action the refund in ARD Web and mark it as refunded
    And a compensation record should be created in the backend with GL account and cost center
    And in UAT the batch file should be triggered manually
    And Cash should be dispatched to Unifier via HSBC channel for BSM
    And Unifier should send an acknowledgement back
    And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired"
    And currency conversion logging should record ILS amount and CAD equivalent and exchange rate and source and date
    And the Claims Dashboard Compensation tab should show "?3,670 ILS" with payment method "Cash" via "BSM � Email Payment" and status updated via talkback
    And the Claims Dashboard should show a refund record with PS agent task status tracked separately

Expected Results:
DDS returns FD-ASL-EL-09. Trip Tracer: Leg 1 = Completed; Leg 2 = CANCELLED; MSL = Leg 2 (AC 084 YUL?TLV); Cancellation Code = CREW (4-char Netline � Not Extraordinary Circumstance / Controllable); No Travel = Incomplete (stranded at YUL midpoint � did not reach TLV, did not return to YYZ); Fallback = FALSE (cancellation code available); ASL (Israel destination) + APPR. ASL No Travel: Branch B (did not remain at origin � at midpoint) ? MSL cancelled ? Not Extraordinary ? ELIGIBLE. Compensation: ILS 3,670 + Expenses + Pro-rated/full ticket refund. CyberSource: GREEN. IDV: PASS. Payment: BSM � Email Payment Israel ILS. Claims Dashboard: ASL EL-09; ELIGIBLE; No Travel = Incomplete; Stranded = YUL; Not Extraordinary (CREW); ?3,670 ILS; Multi-leg (YYZ?YUL?TLV); Branch B; DDS = FD-ASL-EL-09.