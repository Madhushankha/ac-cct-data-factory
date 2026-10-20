Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Toronto to Tel Aviv was cancelled due to a crew issue and I didn't take any replacement flight. I stayed in Toronto. Can I get compensation?"

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
And the user provides "Yael Levi"
Then the chatbot responds:
"Thanks, Yael! And, what is your booking reference number?"
And the user provides "PNR: TC118"
Then the chatbot searches Trip Tracer for PNR: TC118
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
And the chatbot displays options:

Email: y***@gmail.com

Phone: +972***789

And the user selects "Email: y***@gmail.com"
And the user provides the OTP code "518293" ? CORRECT (attempt 1 of 5)

GROUP BOOKING CHECK: NOT PRESENT ? PROCEED
PASSENGER SELECTION (GenUC-06): 1 passenger � Yael Levi (Adult) ? confirmed

JOURNEY SELECTION (GenUC-08):
"I found the following journey:

Flight: AC 082

Route: Toronto (YYZ) ? Tel Aviv (TLV)

Date: June 3, 2026

Status: CANCELLED

Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK: Single leg ? skip GenUC-18
DUPLICATE CLAIM CHECK (GenUC-10): NO existing case found
72-HOUR CHECK: >72 hours ? PROCEED
CLAIM TIME LIMIT CHECK: ASL = 1,460 days (4 years) ? within limitation ? PROCEED

REGIME DETERMINATION:
Then the system determines: Destination = TLV (Israel) ? ASL applies
And the system checks: Origin = YYZ (Canada) ? APPR also applies
And the system checks: Flight CANCELLED ? MSL cancelled ? meets ASL No Travel threshold
And the system checks: Customer remained at origin (YYZ) ? No Travel Origin ? Branch A

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

Trip Tracer UI Validation
Then the tester opens Trip Tracer UI for PNR: TC118

? Promised Itinerary - Flight: AC 082, Route: YYZ ? TLV

? Current Itinerary - Flight: AC 082, Route: YYZ ? TLV, Status: CANCELLED

? Customer Status: NO TRAVEL - ORIGIN (customer remained at YYZ, did not travel)

? History - No rebooking accepted

? Regime: ASL (Israel destination � TLV) + APPR (Canadian origin � YYZ)

? MSL FLIGHT: AC 082 � YYZ ? TLV

? Cancellation Code: CREW � 4-character Netline code

? "Cancellation � crew unavailability"

? NOT EXTRAORDINARY CIRCUMSTANCE (CREW in controllable cancellation code list)

? Disruption Type: CANCELLATION

? ASL No Travel: Branch A (remained at origin) ? MSL cancelled ? Not Extraordinary ? ELIGIBLE

? Compensation: ILS 3,670 + Expenses + Pro-rated/full ticket refund

? Fallback: FALSE (cancellation code CREW available)

Flight Compensation:

? MS YAEL LEVI | ELIGIBLE | ASL_NO_TRAVEL_ORIGIN_NON_EXTRAORDINARY | ILS 3,670.00 | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
CyberSource ? GREEN LIGHT

ELIGIBLE RESULT (FD-05a):
"I've checked your flight details, and it looks like flight AC 082 from Toronto (YYZ) to Tel Aviv (TLV) on June 3, 2026 was cancelled. Based on ISL regulations, you may be eligible for compensation for this cancellation. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."

CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
User selects "Israel" ? Currency = ILS

CASH vs AC WALLET CHECK (FD-06b):
No Aeroplan ? "You are entitled to receive a ?3,670 ILS compensation."
? BSM � Email Payment (Israel)

PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07):
Email confirmation ? IDV via Persona ? IDV PASS

CLAIM AMOUNT CONFIRMATION FLOW:
"Deposit Amount: ?3,670 ILS | Payment Method: BSM � Email Payment" ? User confirms "Yes"

CASE CREATION (GLOB-09):
Claim submitted ? Booking auto-appended

NOTIFICATION (Adobe):
Eligible notification email sent to y***@gmail.com containing: ?3,670 ILS, ASL, YYZ?TLV CANCELLED, No Travel - Origin, cancellation code CREW � not extraordinary

END FLOW (GLOB-11):
"Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Yael Levi" with PNR "TC118"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation"
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Claimant Name should be "Yael Levi"
    And the Authentication should be "Pass"
    And the PNR should be "TC118"
    And the Regime should be "ASL + APPR"
    And the Full Name should be "Yael Levi"
    And the Email should be "y***@gmail.com"
    And the Phone should be "+972***789"
    And the Journey should show "Bound 1: YYZ ? TLV" with claim filed as cancelled
    And the Eligibility and Compensation section should be present and populated with compensation "?3,670 ILS" as ASL fixed rate for No Travel Origin Not Extraordinary
    And the Cancellation Code should be "CREW" as Not Extraordinary Circumstance
    And No Travel should include Compensation at ?3,670 plus Expenses plus pro-rated or full ticket refund
    And DDS should have run automatically
    And the eligibility decision should be pre-populated as "ELIGIBLE" under ASL with No Travel Origin and Not Extraordinary and cancellation code CREW
    And the Duplicate Check should have run automatically and the result should be "No duplicate found"
    And the CyberSource result should be "GREEN"
    And the system should have appended the booking record automatically
    And an eligible notification email should have been sent
    And the Final Status should be "Resolved"
    And the case should be in read-only mode

PAYMENT VALIDATION
    Given the customer's country of residence is "Israel"
    Then the currency should be set to "ILS"
    And the payment method should be "BSM � Email Payment"
    And the customer has no Aeroplan linked so only Cash should be offered
    And the compensation amount should be "?3,670" as ASL fixed rate for No Travel Origin Not Extraordinary with cancellation code CREW
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
DDS returns FD-ASL-EL-05. Trip Tracer: CANCELLED; MSL = AC 082 YYZ?TLV; Cancellation Code = CREW (4-char Netline � Not Extraordinary Circumstance / Controllable); No Travel = Origin (customer remained at YYZ); Fallback = FALSE; ASL (Israel destination) + APPR. ASL No Travel: Branch A (remained at origin) ? MSL cancelled ? Not Extraordinary ? ELIGIBLE. Compensation: ILS 3,670 + Expenses + Pro-rated/full ticket refund. CyberSource: GREEN. IDV: PASS. Payment: BSM � Email Payment Israel ILS. Claims Dashboard: ASL EL-05; ELIGIBLE; No Travel = Origin; Not Extraordinary (CREW); ?3,670 ILS; DDS = FD-ASL-EL-05.