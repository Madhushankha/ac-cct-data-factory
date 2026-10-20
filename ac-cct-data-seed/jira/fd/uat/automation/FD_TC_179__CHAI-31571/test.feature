BACKGROUND � ORIGINAL CASE (Previously Completed):
Given a case was previously created and completed:
? Original Case Reference: CASE-FD-20260501-153
? Passenger: Catherine Bouchard (Basic Aeroplan Member #: 9876543210)
? PNR: TC153
? Journey: ORD ? DEN ? YYZ (Leg 1 AC 8452, Leg 2 AC 8204), May 1, 2026, delayed 7h (Code 15 Boarding on Leg 2 DEN?YYZ)
? Regime: APPR
? Decision: ELIGIBLE � $700 CAD Cash / $840 CAD AC Wallet
? Payment: AC Wallet � $840 CAD ISSUED (May 12, 2026)
? Case Status: CLOSED (compensation paid)

SECOND CLAIM ATTEMPT (D+45 � June 15, 2026):
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Denver to Toronto on May 1st was delayed 7 hours due to boarding delays. I'd like to file a compensation claim."
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
And the user provides "Catherine Bouchard"
Then the chatbot responds:
"Thanks, Catherine! And, what is your booking reference number?"
And the user provides "PNR: TC153"
Then the chatbot searches Trip Tracer for PNR: TC153
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: c***@gmail.com
� Phone: +1***234
And the user selects "Email: c***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "482917"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds:
"Your verification was successful. Let's proceed to the next step."

GROUP BOOKING CHECK:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT

PASSENGER SELECTION (GenUC-06):
Then the chatbot displays passengers from PNR:
"I found 1 passenger on this booking:
� Catherine Bouchard (Adult - Aeroplan Member)
Is this who you'd like to include?"
And the user confirms "Yes"

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Segment 1: Flight AC 8452, Chicago (ORD) ? Denver (DEN) � COMPLETED
� Segment 2: Flight AC 8204, Denver (DEN) ? Toronto (YYZ) � ARRIVED LATE
� Date: May 1, 2026
� Arrival Delay at final destination (YYZ): 7 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"

DUPLICATE CLAIM CHECK (GenUC-10) � DUPLICATE DETECTED:
Then the chatbot sends request to Case Services for duplicate check
And Case Services checks:
? PNR: TC153 ? MATCH
? Passenger: Catherine Bouchard ? MATCH
? Journey: ORD ? DEN ? YYZ (AC 8452 / AC 8204) ? MATCH
? Flight Date: May 1, 2026 ? MATCH
? Existing Case: CASE-FD-20260501-153
? Existing Case Status: CLOSED (compensation paid � $840 CAD AC Wallet)
? Payment Status: ISSUED / PAID (May 12, 2026)
And Case Services returns: DUPLICATE DETECTED
? Duplicate Match Type: EXACT (PNR + Passenger + Multi-leg Journey + Date all match)
? Original Case: CASE-FD-20260501-153
? Original Decision: ELIGIBLE � $840 CAD AC Wallet ISSUED

DUPLICATE CLAIM � BLOCKED:
Then the chatbot responds:
"I can see that a claim has already been filed and processed for this journey. Here are the details of your existing claim:
� Case Reference: CASE-FD-20260501-153
� Journey: Chicago (ORD) ? Denver (DEN) ? Toronto (YYZ), May 1, 2026
� Disruption Reason: Gate Boarding Delay (Code 15)
� Decision: Eligible
� Compensation: $840 CAD (AC Wallet)
� Payment Status: Issued (May 12, 2026)
Since compensation has already been issued for this flight, a new claim cannot be filed for the same journey. If you believe there is an error or if you have questions about your existing claim, please contact our Customer Relations team."

NO DDS EVALUATION (blocked � duplicate)
NO PAYMENT FLOW (blocked � duplicate)
NO IDV (blocked � duplicate)
NO FRAUD SCREENING (blocked � duplicate)
NO NEW COMPENSATION RECORD CREATION (blocked � duplicate; original case referenced)

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

DUPLICATE DETECTION VALIDATION:
? PNR match: YES (TC153) ?
? Passenger match: YES (Catherine Bouchard) ?
? Multi-leg journey match: YES (ORD?DEN?YYZ) ?
? Date match: YES (May 1, 2026) ?
? Duplicate detected: YES ?
? Original case referenced: YES (CASE-FD-20260501-153) ?
? Original payment status shown: YES ($840 CAD AC Wallet issued) ?
? Second claim blocked: YES ?
? Customer informed of existing claim: YES ?

CLAIMS DASHBOARD VALIDATION
    Given the second claim attempt was made for claimant "Catherine Bouchard" with PNR "TC153"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the Case Status should be "Closed � Not Eligible (Duplicate)"
    And the Created date should be populated
    And the Last Updated date should be populated
    And a Duplicate Warning Banner should be displayed on top of the case
    And the Decision Assist panel should be blocked with no new DDS assessment
    And the Claimant Name should be "Catherine Bouchard"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC153"
    And the Aeroplan should be "9876543210" linked and in good standing (Basic Member)
    And the Tier Status should be "Basic / Member"
    And the Regime should be "APPR" (same as original)
    And the Journey should show "Bound 1: ORD ? DEN ? YYZ" (multi-leg connecting with disrupted segment arriving in Canada)
    And the Ancillary Fee section should be present
    And the Eligibility and Compensation section should show "NOT ELIGIBLE (DUPLICATE)" with compensation $0 CAD as already paid on original case
    And the DUPLICATE check MUST have triggered during GenUC-10
    And the match criteria should show PNR match, Passenger match, Multi-leg journey match, and Flight date match
    And the Original Case ID should be referenced (CASE-FD-20260501-153)
    And the original payment details ($840 CAD AC Wallet / $700 CAD Cash) should be linked
    And the system MUST NOT process the second claim or create a new compensation record
    And CyberSource should NOT have been triggered
    And the system should have appended the booking record automatically
    And a duplicate notification email should have been sent via Adobe containing Case Reference, duplicate detected status, original case ID, and original payout summary
    And the Agent Notes section should be accessible
    And the Audit Log should record duplicate detection and original case reference
    And Customer Communications should show the duplicate notification
    And the Related Cases tab should link directly to the original case (CASE-FD-20260501-153)
    And the Final Status should be "Closed � Not Eligible (Duplicate)"
    And the case should be in read-only mode

PAYMENT VALIDATION
    Given the claim is a DUPLICATE
    Then no payment flow should be triggered
    And no country of residence or payment method choice should be asked
    And no new compensation record should be created
    And no batch file should be dispatched
    And no IDV should be triggered
    And no CyberSource fraud screening should be triggered
    And the original case should be referenced as CASE-FD-20260501-153 with $840 CAD AC Wallet already ISSUED on May 12, 2026
    And the second claim should be BLOCKED and the system must NOT process any payment for the duplicate
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE (Duplicate)" with no new payout section
    And the Claims Dashboard Related Cases tab should link to the original case showing original payment ($840 CAD AC Wallet ISSUED)

Expected Results:
DDS returns FD-DUP-NE-01. Duplicate Detection: System matches second claim against existing database ? DUPLICATE FOUND. Original case CASE-FD-20260501-153 retrieved. CRITICAL: System MUST NOT process the second claim � compensation was already paid ($840 CAD AC Wallet / $700 CAD Cash for 7h delay under Code 15 Boarding on Leg 2 DEN?YYZ). Must reference the original case ID so customer and agent see prior payout. Compensation: $0 � already paid on original claim. Claims Dashboard: Closed � Not Eligible; Reason = Duplicate claim detected; Original case ID = CASE-FD-20260501-153; Original payment = $840 AC Wallet; Second claim blocked; DDS = FD-DUP-NE-01.