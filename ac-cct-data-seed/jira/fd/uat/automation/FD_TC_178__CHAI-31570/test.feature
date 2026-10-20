Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I flew from Paris to Toronto and then Toronto to Tel Aviv. My second flight was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation"
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
And the user provides "Sylvain Moreau"
Then the chatbot responds:
"Thanks, Sylvain! And, what is your booking reference number?"
And the user provides "PNR: TC152"
Then the chatbot searches Trip Tracer for PNR: TC152
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
Email: s***@gmail.com
Phone: +33***890
And the user selects "Email: s***@gmail.com"
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
Then the chatbot displays passengers from PNR:
"I found 1 passenger on this booking:
Sylvain Moreau (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
Segment 1: Flight AC 871, Paris Charles de Gaulle (CDG) ? Toronto (YYZ), June 6, 2026 � COMPLETED
Segment 2: Flight AC 085, Toronto (YYZ) ? Tel Aviv Ben Gurion (TLV), June 6, 2026 � ARRIVED LATE (+4h)
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK (GenUC-18):
Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments)
Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 DELAYED
Then the chatbot determines: Claim applies to Segment 2 (AC 085 YYZ?TLV � DELAYED); Final destination = TLV; Final arrival delay = 4h
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED
REGIME DETERMINATION � TRIPLE REGIME:
Then the system determines applicable regimes:
And the system checks: Journey origin = CDG (EU) ? EU 261 applies
And the system checks: Connection through YYZ (Canada) ? APPR applies
And the system checks: Final destination = TLV (Israel) ? ASL applies
And the system determines: TRIPLE REGIME � EU 261 + APPR + ASL
TRIAGE & DDS EVALUATION � TRIPLE REGIME WITH ASL ND:
Then the DDS evaluation is done in backend
And DDS assesses ALL THREE regimes independently:
EU 261 ASSESSMENT:
? Origin: CDG (EU) ? EU 261 applies
? Distance: CDG?TLV = ~3,400 km ? Medium-haul (1500�3500km)
? Delay at final destination: 4 hours ? ?3h threshold
? Code: 42 ? Controllable under EU 261
? EU 261 Data: COMPLETE
? EU 261 Result: ELIGIBLE � �400 (1500�3500km band, ?3h delay)
APPR ASSESSMENT:
? Connection: YYZ (Canada) ? APPR applies
? Delay at final destination: 4 hours ? 3�<6h tier
? Code: 42 ? Controllable under APPR
? APPR Data: COMPLETE
? APPR Result: ELIGIBLE � $400 CAD
ASL ASSESSMENT:
? Destination: TLV (Israel) ? ASL applies
? Delay at final destination: 4 hours
? Code: 42 ? Controllable under ASL
? ASL Data: INCOMPLETE � Israeli regulatory data missing (specific ASL compensation table data unavailable)
? ASL Result: NO DETERMINATION (cannot assess due to missing data)
MIXED RESULT � EU ELIGIBLE, APPR ELIGIBLE, ASL NO DETERMINATION:
? EU 261: ELIGIBLE � �400
? APPR: ELIGIBLE � $400 CAD
? ASL: NO DETERMINATION (data incomplete)
? ASL ND blocks eligible assessment? ? NO � ASL's ND does NOT block EU/APPR
? System selects from regimes that DID produce a determination
? Eligible regimes with determination: EU 261 + APPR
? Per fixed priority: APPR & EU ? EU always first
? SELECTED: EU 261 � �400
? NOTE: Selection is by fixed priority hierarchy, NOT by CAD conversion comparison. If ASL data becomes available later and ASL is eligible, ASL would take priority over EU per fixed hierarchy (ASL > EU > APPR).
TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC152
? Segment 1: Flight: AC 871, Route: CDG ? YYZ, Status: COMPLETED (on time)
? Segment 2: Flight: AC 085, Route: YYZ ? TLV, Status: ARRIVED LATE, Delay: +4H 00M
? Triple Regime: EU 261 + APPR + ASL
? EU 261: ELIGIBLE � �400 � DATA COMPLETE
? APPR: ELIGIBLE � $400 CAD � DATA COMPLETE
? ASL: NO DETERMINATION � DATA INCOMPLETE (Israeli regulatory data missing)
? ASL ND Blocking: NO � does not block EU/APPR eligible assessment
? Eligible regimes: EU 261 + APPR ? Fixed priority: EU first
? Most Generous (from determined regimes): EU 261 � �400 (fixed priority)
? MSL FLIGHT: AC 085 � YYZ ? TLV � 42
? CONTROLLABLE (Code 42)
Flight Compensation:
? MR SYLVAIN MOREAU | ELIGIBLE | EU261_3_PLUS_HOURS_MEDIUM_HAUL (FIXED PRIORITY from determined regimes) | �400
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment
ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like your connecting flight AC 085 from Toronto (YYZ) to Tel Aviv Ben Gurion (TLV) was delayed by about 4 hours. Based on the applicable regulations, you may be eligible for compensation of �400 for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."
CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "France"
Then the system determines: Country = France ? Currency = EUR ? Payment Method = BSM Email Payment
CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot responds: "You are entitled to receive �400 compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency (EUR)."
And user provides "Yes"
PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07):
Then the chatbot responds:
"Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information and updates about this case. Would you like to use s***@gmail.com? Please note that only one email address can be used for this compensation and it can't be changed once confirmed"
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
Deposit Amount: �400
Payment Method: Email
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps.
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user provides: "Yes"
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
ASL NO DETERMINATION � BACKGROUND PROCESSING:
Then the system notes: ASL assessment returned No Determination
And the system schedules: ASL data retry (daily polling for up to 14 days for Israeli regulatory data)
And the system records: If ASL data becomes available and ASL is eligible, ASL would take priority over EU per fixed hierarchy (ASL > EU > APPR) � case may be re-assessed (but customer already compensated under EU 261)
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to s***@gmail.com
And the email contains: Case Reference, compensation amount (�400), regulation (EU 261 � selected per fixed priority from determined regimes), flight details (CDG?YYZ?TLV, Leg 2 delayed 4h), next steps, tracking link
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
I would like you to � new flow
No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Sylvain Moreau" with PNR "TC152"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Sylvain Moreau"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC152"
    And the Regime should be "EU 261 + APPR + ASL (Triple Regime � EU 261 SELECTED per fixed priority; ASL = No Determination)"
    And the Full Name should be "Sylvain Moreau"
    And the Tags should include "Claimant" and "Adult"
    And the Journey should show "Segment 1: CDG ? YYZ" completed on time and "Segment 2: YYZ ? TLV" delayed plus 4h with claim filed
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And Assessment 1 ELIGIBLE SELECTED should be EU 261 with eligibility ELIGIBLE and compensation "�400 EUR" for 1500 to 3500km band and 3h or more delay and SELECTED per fixed priority hierarchy from regimes with definitive results as EU over APPR
    And Assessment 2 ELIGIBLE Not Selected should be APPR with eligibility ELIGIBLE and compensation "$400 CAD" Tier 1 and NOT SELECTED as EU takes priority per fixed hierarchy
    And Assessment 3 NO DETERMINATION should be ASL with eligibility NO DETERMINATION due to Israeli regulatory data missing and compensation PENDING and LOGGED for manual handling if needed
    And ASL's ND should NOT block the other regimes from being assessed and selected
    And the eligible regimes should be EU 261 and APPR and per fixed priority EU always over APPR so EU 261 should be SELECTED
    And the selection should be by fixed priority hierarchy NOT by CAD conversion comparison
    And ASL should be excluded from selection as No Determination and may be resolved later
    And if ASL data becomes available and ASL is eligible ASL would take priority as ASL is greater than EU is greater than APPR
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically
    And ALL THREE regimes should be assessed
    And EU 261 should be Eligible at �400 selected per fixed priority
    And APPR should be Eligible at $400 not selected
    And ASL should be No Determination logged with manual handling if needed
    And ASL ND should NOT prevent eligible outcome as the system selects from regimes with definitive results using fixed priority
    And the Duplicate Check should have run automatically using baseline data "Sylvain Moreau + TC152 + CDG?TLV + FD"
    And the result should be "No duplicate found"
    And the CyberSource result should be "GREEN" as it ran for the eligible EU 261 assessment
    And the system should have appended the booking record automatically
    And an eligible notification email should have been sent containing compensation "�400 EUR" and regulation "EU 261" and flight details CDG to YYZ to TLV Leg 2 delayed 4h
    And the Agent Notes section should be accessible
    And the Audit Log should record triple-regime assessment with EU 261 Eligible �400 selected per fixed priority and APPR Eligible $400 not selected and ASL No Determination logged
    And the exchange rate should be logged for internal reporting
    And the ASL ND flag should be visible for potential manual follow-up
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Resolved" based on EU 261 eligible assessment as ASL ND does not block resolution
    And the case should be in read-only mode
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the customer's country of residence is "France"
    Then the currency should be set to "EUR"
    And the payment method should be "BSM Email Payment"
    And the customer has no Aeroplan linked so only Cash should be offered and AC Wallet should NOT be offered
    And the triple regime should be assessed with EU 261 ELIGIBLE at �400 vs APPR ELIGIBLE at $400 CAD vs ASL NO DETERMINATION data missing
    And ASL should be excluded as ND and EU vs APPR should result in EU selected per fixed priority hierarchy NOT by CAD comparison
    And the compensation amount should be "�400" EUR as EU 261 selected per fixed priority from regimes with definitive results
    And the payment currency should be EUR as the customer is in France and EU 261 is already in EUR so no conversion is needed
    And email should be confirmed for BSM Email Payment
    And IDV at Payment should be triggered via Persona and IDV PASS should be required before claim submission
    And a compensation record should be created in the backend with GL account and cost center
    And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team
    And Cash should be dispatched to Unifier and Unifier should process BSM Email Payment
    And HSBC should send an acknowledgement back and the end-of-day report should be received
    And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired"
    And BSM Email Payment processing should take 5 to 10 business days
    And the Claims Dashboard Compensation tab should show payout details "�400 EUR" with payment method "Cash" via "BSM Email Payment" and status updated via talkback

Expected Results:
DDS returns FD-MIXED-ND-01. Trip Tracer: Delay = 4hrs; MSL = Leg 2; Code 42; Controllable; Regime = EU + APPR + ASL. Triple Assessment: EU 261 = ELIGIBLE (�400, 1500�3500km); APPR = ELIGIBLE ($400 CAD); ASL = NO DETERMINATION (missing data). CRITICAL: ASL's ND does NOT block the other regimes. System selects from regimes with definitive results using fixed priority: EU over APPR ? EU selected. Selection is by fixed priority hierarchy, NOT by CAD conversion comparison. ASL ND is logged and may be resolved later via manual handling � if ASL data becomes available and ASL is eligible, ASL would take priority over EU per fixed hierarchy (ASL > EU > APPR). Compensation: �400 (EU 261). Claims Dashboard: EU = Eligible (�400, selected per fixed priority); APPR = Eligible ($400, not selected); ASL = No Determination (logged); DDS = FD-MIXED-ND-01.