Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from London to Toronto was delayed 4 hours. I'd like to check if I'm eligible for compensation"
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
And the user provides "Bridget Carmichael"
Then the chatbot responds:
"Thanks, Bridget! And, what is your booking reference number?"
And the user provides "PNR: TC150"
Then the chatbot searches Trip Tracer for PNR: TC150
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
Email: b***@gmail.com
Phone: +44***678
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
PASSENGER SELECTION (GenUC-06):
Then the chatbot displays passengers from PNR:
"I found 1 passenger on this booking:
Bridget Carmichael (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
Flight: AC 855
Route: London Heathrow (LHR) ? Toronto (YYZ)
Date: June 5, 2026
Arrival Delay: 4 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment? ? NO ? skip GenUC-18
DUPLICATE CLAIM CHECK:
Case Services returns: NO existing case found
72-HOUR CHECK:
Hours since arrival ? >72 hours ? PROCEED
REGIME DETERMINATION � DUAL REGIME:
Then the system determines: Origin = LHR (UK, EU 261 applies to UK departures) ? EU 261 applies; Destination = YYZ (Canada) ? APPR applies
And the system determines: DUAL REGIME � EU 261 + APPR
TRIAGE & DDS EVALUATION � DIVERGENT CONTROLLABILITY:
Then the DDS evaluation is done in backend
And DDS assesses BOTH regimes independently with REGIME-SPECIFIC controllability rules:
EU 261 ASSESSMENT:
? Origin: LHR (UK) ? EU 261 applies
? Distance: LHR?YYZ = ~5,550 km ? Long-haul (>3500km)
? Delay: 4 hours ? ?4h threshold
? Disruption Code: [Code that maps differently per regime]
? EU 261 Controllability Classification: CONTROLLABLE (under EU 261 rules, this cause is within carrier control)
? EU 261 Result: ELIGIBLE � �520 GBP (EU UK column, 4+ hours, >3500km per Confluence table)
APPR ASSESSMENT:
? Destination: YYZ (Canada) ? APPR applies
? Delay: 4 hours ? 3�<6h tier
? Same Disruption Code
? APPR Controllability Classification: UNCONTROLLABLE (under APPR rules, the same cause maps to outside carrier control)
? APPR Result: NOT ELIGIBLE (uncontrollable under APPR)
KEY INSIGHT: The SAME disruption code produces DIFFERENT controllability classifications under different regimes. EU 261 and APPR have independent controllability mapping tables. DDS must NOT blend or share classifications between regimes.
MIXED RESULT � EU ELIGIBLE, APPR NOT ELIGIBLE:
? EU 261: ELIGIBLE � �520 GBP
? APPR: NOT ELIGIBLE (uncontrollable)
? Since at least one regime is eligible, the customer IS eligible
? Selected Regime: EU 261 � �520 GBP (the only eligible regime)
? NOTE: Per fixed priority, EU would be selected over APPR even if both were eligible. Since APPR is NE, EU is selected by default.
TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC150
? Promised Itinerary - Flight: AC 855, Route: LHR ? YYZ, Scheduled Arrival: 16:00
? Current Itinerary - Flight: AC 855, Route: LHR ? YYZ, Status: ARRIVED LATE, Actual: 20:00, Delay: +4H 00M
? Dual Regime: EU 261 + APPR
? EU 261: ELIGIBLE � �520 GBP (controllable under EU rules; EU UK column, 4+ hours, >3500km)
? APPR: NOT ELIGIBLE (uncontrollable under APPR rules)
? Same disruption code ? different controllability per regime
? Selected: EU 261 (only eligible regime; also would win per fixed priority)
? MSL FLIGHT: AC 855 � LHR ? YYZ � [Code]
Flight Compensation:
? MS BRIDGET CARMICHAEL | ELIGIBLE | EU_UK_4_PLUS_HOURS_LONG_HAUL | �520 GBP
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 855 from London Heathrow (LHR) to Toronto (YYZ) was delayed by about 4 hours. Based on the applicable regulations, you may be eligible for compensation of �520 for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."
CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "United Kingdom"
Then the system determines: Country = UK ? Currency = GBP ? Payment Method = BSM Email Payment
CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot responds: "You are entitled to receive �520 compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And user provides "Yes"
PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07):
Then the chatbot responds:
"Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information and updates about this case. Would you like to use b***@gmail.com? Please note that only one email address can be used for this compensation and it can't be changed once confirmed"
And user provides "Yes"
Then system checks that IDV is not completed
IDENTITY VERIFICATION � PERSONA (FD-07b):
Then the chatbot responds:
"I must verify your identity for payment security. Please click here to get started"
And chatbot displays a button "Get verified"
When user clicks on the button
And the customer completes identity verification via Persona
And Persona returns: IDV PASS
Then the chatbot responds:
"Your identity has been verified successfully. Let's proceed to finalize your claim."
CLAIM AMOUNT CONFIRMATION FLOW:
Then the chatbot responds: "Please review your compensation details:
Deposit Amount: �520
Payment Method: Email
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps.
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user confirms "Yes"
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to b***@gmail.com
And the email contains: Case Reference, compensation amount (�520 GBP), regulation (EU 261 UK), flight details (LHR?YYZ, 4hr delay), next steps, tracking link
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
I would like you to � new flow
No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Bridget Carmichael" with PNR "TC150"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Bridget Carmichael"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC150"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "EU 261 + APPR (Dual Regime � EU 261 SELECTED; APPR Not Eligible)"
    And the Full Name should be "Bridget Carmichael"
    And the Tags should include "Claimant" and "Adult"
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: LHR ? YYZ" with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And Assessment 1 ELIGIBLE should be EU 261 UK with disruption code classification under EU rules as Controllable and eligibility ELIGIBLE and compensation "�520 GBP" EU UK column greater than 3500km LHR to YYZ approximately 5550km 4 plus hours and SELECTED as only eligible regime and also wins per fixed priority
    And Assessment 2 NOT ELIGIBLE should be APPR with disruption code classification under APPR rules as Uncontrollable and eligibility NOT ELIGIBLE due to uncontrollable under APPR and compensation $0 and NOT SELECTED
    And the Divergent Classification should show the same disruption code producing DIFFERENT controllability outcomes under different regimes with EU classification Controllable resulting in Eligible and APPR classification Uncontrollable resulting in Not Eligible
    And DDS should apply each regime's OWN controllability rules independently with no cross-regime blending
    And the divergent classification should be highlighted in the dashboard
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically
    And BOTH regimes should be assessed independently
    And the eligibility decision should be "ELIGIBLE" under EU 261 controllable under EU rules with APPR NE under APPR rules
    And the divergent controllability classification should be noted
    And the Duplicate Check should have run automatically using baseline data "Bridget Carmichael + TC150 + LHR?YYZ + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And the CyberSource result should be "GREEN" as it ran for the eligible EU 261 assessment
    And the system should have appended the booking record automatically
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And an eligible notification email should have been sent containing compensation "�520 GBP" and regulation "EU 261 UK" and flight details LHR to YYZ 4hr delay
    And the Agent Notes section should be accessible
    And the Audit Log should record dual-regime assessment with divergent controllability
    And the Audit Log should show EU 261 Eligible controllable at �520 GBP and APPR Not Eligible uncontrollable at $0
    And the divergent classification should be flagged in the audit trail
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Resolved"
    And the case should be in read-only mode
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the customer's country of residence is "United Kingdom"
    Then the currency should be set to "GBP"
    And the payment method should be "BSM Email Payment"
    And the customer has no Aeroplan linked so only Cash should be offered and AC Wallet should NOT be offered
    And the dual regime should be assessed with EU 261 ELIGIBLE at �520 GBP controllable under EU rules vs APPR NOT ELIGIBLE uncontrollable under APPR rules
    And only one regime should be eligible so EU 261 should be selected at �520 GBP
    And the compensation amount should be "�520 GBP" EU UK column greater than 3500km 4 plus hours
    And the payment currency should be GBP as the customer is in UK and EU UK compensation is already in GBP so no conversion is needed
    And email should be confirmed for BSM Email Payment
    And IDV should be completed via Persona and IDV should PASS
    And a compensation record should be created in the backend with GL account and cost center
    And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team
    And Cash should be dispatched to Unifier and Unifier should process BSM Email Payment in GBP
    And HSBC should send an acknowledgement back and the end-of-day report should be received
    And the end-of-day report should show status "Pending" transitioning to "Completed" or "Rejected" or "Expired"
    And the Claims Dashboard Compensation tab should show payout details "�520 GBP" as EU 261 UK selected with payment currency GBP and payment method BSM Email Payment and status updated via talkback

Expected Results:
DDS returns FD-MIXED-NE-01. Trip Tracer: Promise = 16:00; Actual = 20:00; Delay = 4hrs; MSL = Leg 1; Disruption code = [divergent code]; EU classification = Controllable; APPR classification = Uncontrollable; Regime = EU 261 + APPR. Dual Assessment: EU 261 = ELIGIBLE (�520 GBP, EU UK column, controllable under EU rules, >3500km, 4+ hours); APPR = NOT ELIGIBLE (uncontrollable under APPR rules). CRITICAL: The SAME disruption code can produce different controllability outcomes under different regimes. DDS must NOT apply one regime's classification to the other. Each regime's rules are independent. Per fixed priority, EU would win over APPR regardless, but APPR is also NE. Compensation: �520 GBP (EU 261 UK � the one eligible regime). Claims Dashboard: EU 261 = Eligible (�520 GBP); APPR = Not Eligible (uncontrollable); Divergent classification highlighted; DDS = FD-MIXED-NE-01.