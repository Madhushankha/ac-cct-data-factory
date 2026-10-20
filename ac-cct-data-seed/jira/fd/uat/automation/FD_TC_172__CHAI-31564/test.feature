Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Paris to Toronto was delayed 4 hours. I'd like to check if I'm eligible for compensation"
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
And the user provides "Marie Lef�vre"
Then the chatbot responds:
"Thanks, Marie! And, what is your booking reference number?"
And the user provides "PNR: TC146"
Then the chatbot searches Trip Tracer for PNR: TC146
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
Email: m***@gmail.com
Phone: +33***234
And the user selects "Email: m***@gmail.com"
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
Marie Lef�vre (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
Flight: AC 871
Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ)
Date: June 10, 2026
Arrival Delay: 4 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED
CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for EU 261 (France = 5 years) and APPR ? within limitation ? PROCEED
REGIME DETERMINATION � DUAL REGIME:
Then the system determines applicable regimes:
And the system checks: Origin airport = CDG (Paris, France, EU) ? EU 261 applies
And the system checks: Destination airport = YYZ (Toronto, Canada) ? APPR applies
And the system checks: Destination = YYZ (not Israel) ? ASL does NOT apply
And the system determines: DUAL REGIME � EU 261 + APPR (both assessed independently)
TRIAGE & DDS EVALUATION � DUAL REGIME FIXED PRIORITY:
Then the DDS evaluation is done in backend
And DDS assesses BOTH regimes independently:
EU 261 ASSESSMENT:
? Origin: CDG (EU) ? EU 261 applies
? Distance: CDG?YYZ = ~5,500 km ? Long-haul (>3500km)
? Delay: 4 hours ? 4+ threshold
? Code: 42 ? Controllable under EU 261
? EU 261 Result: ELIGIBLE � �600 (EU261 column, 4+ hours, >3500km)
APPR ASSESSMENT:
? Destination: YYZ (Canada) ? APPR applies
? Delay: 4 hours ? 3�<6h tier (Tier 1)
? Code: 42 ? Controllable under APPR
? APPR Result: ELIGIBLE � $400 CAD (Tier 1: 3�<6 hours)
MOST GENEROUS SELECTION (Fixed Priority):
? Applicable regimes: APPR & EU
? Per Most Generous Logic: APPR & EU ? EU is always selected first (fixed priority hierarchy per legal team approval)
? EU 261: �600
? APPR: $400 CAD (not selected)
? SELECTED: EU 261 � �600
? NOTE: Selection is by fixed priority order, NOT by CAD conversion comparison. Legal team approved EU over APPR regardless of converted amounts.
TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC146
? Promised Itinerary - Flight: AC 871, Route: CDG ? YYZ, Scheduled Arrival: 16:00
? Current Itinerary - Flight: AC 871, Route: CDG ? YYZ, Status: ARRIVED LATE, Actual: 20:00, Delay: +4H 00M
? Dual Regime: EU 261 + APPR
? EU 261: ELIGIBLE � �600
? APPR: ELIGIBLE � $400 CAD
? Most Generous: EU 261 � �600 (fixed priority: EU always selected over APPR)
? MSL FLIGHT: AC 871 � CDG ? YYZ � 42
? CONTROLLABLE (Code 42)
? Fallback: FALSE
? Sister City: FALSE
Flight Compensation:
? MS MARIE LEF�VRE | ELIGIBLE | EU261_4_PLUS_HOURS_LONG_HAUL (FIXED PRIORITY) | �600
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment
ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 871 from Paris Charles de Gaulle (CDG) to Toronto (YYZ) was delayed by about 4 hours. Based on the applicable regulations, you may be eligible for compensation of �600 for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."
CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "France"
Then the system determines: Country = France ? Currency = EUR ? Payment Method = BSM Email Payment
CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot checks if the claim is for multiple pax ? No
Then the chatbot responds: "You are entitled to receive �600 compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency (EUR)."
And user provides "Yes"
Then system checks which payment method is mapped based on country of residence ? Bank Transfer (SEPA)
PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07):
Then the chatbot responds:
"Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information and updates about this case. Would you like to use m***@gmail.com? Please note that only one email address can be used for this compensation and it can't be changed once confirmed"
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
Deposit Amount: �600
Payment Method: Email
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps.
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user provides: "Yes"
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
CURRENCY CONVERSION LOGGING (Backend � Reporting Only):
? Compensation Amount (Selected Regime � EU 261): �600 EUR
? APPR Amount (Not Selected): $400 CAD
? Exchange Rate Used: 1 EUR = 1.4667 CAD (for internal reporting only, NOT used for regime selection)
? CAD Equivalent of EU 261 Amount: ~$880 CAD (logged for internal reporting/exposure analysis only)
? Exchange Rate Source: Bank of Canada
? Exchange Rate Date: June 15, 2026
? Payment Currency: EUR (customer in France � no conversion needed for payment since EU 261 is already in EUR)
? NOTE: Exchange rate logging is for internal reporting purposes. Regime selection was by fixed priority, not amount comparison.
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to m***@gmail.com
And the email contains: Case Reference, compensation amount (�600 EUR), regulation (EU 261 � selected per fixed priority), flight details (CDG?YYZ, 4hr delay), next steps, tracking link
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
I would like you to � new flow
No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Marie Lef�vre" with PNR "TC146"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Marie Lef�vre"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC146"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "EU 261 + APPR (Dual Regime � EU 261 SELECTED per fixed priority)"
    And the Full Name should be "Marie Lef�vre"
    And the Tags should include "Claimant" and "Adult"
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: CDG ? YYZ" with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Primary Selected regime should be EU 261 with eligibility ELIGIBLE and compensation "�600 EUR" for greater than 3500km controllable 4 plus hours and SELECTED per fixed priority hierarchy where APPR and EU results in EU always first
    And the Secondary Not Selected regime should be APPR with eligibility ELIGIBLE and compensation "$400 CAD" Tier 1 3 to less than 6hrs controllable and NOT SELECTED as EU always takes priority over APPR per legal team decision
    And the Selection Method should be fixed priority hierarchy NOT CAD conversion comparison
    And per Confluence "APPR & EU ? 1. EU, 2. APPR" and legal note "Although certain EU amounts are slightly below the CAD, they were fine with placing EU over APPR"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically
    And BOTH regimes should be assessed and logged
    And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 selected per fixed priority
    And the APPR assessment should be visible alongside the EU 261 assessment
    And EU 261 should be flagged as SELECTED
    And the Duplicate Check should have run automatically using baseline data "Marie Lef�vre + TC146 + CDG?YYZ + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And the CyberSource result should be "GREEN"
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent
    And an eligible notification email should have been sent via Adobe containing compensation "�600 EUR" and regulation "EU 261" and flight details CDG to YYZ 4hr delay and next steps
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And the Audit Log should record dual-regime assessment with EU 261 at �600 selected per fixed priority and APPR at $400 not selected
    And the exchange rate should be logged in audit trail for internal reporting with source and date and value
    And Customer Communications should show the notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Resolved"
    And the case should be in read-only mode
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the customer's country of residence is "France"
    Then the currency should be set to "EUR"
    And the payment method should be "BSM Email Payment"
    And the customer has no Aeroplan linked so only Cash should be offered
    And the compensation amount should be "�600" EUR
    And the selection should be by fixed priority order with EU always over APPR per legal team approval NOT by CAD conversion comparison
    And IDV at Payment should be triggered via Persona and the customer should complete IDV and Persona should return IDV PASS
    And the claim amount confirmation should show �600 EUR via Email and the customer should confirm and the claim should be submitted
    And a compensation record should be created in the backend with GL account and cost center
    And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team
    And Cash should be dispatched to Unifier and Unifier should process BSM Email Payment
    And HSBC should send an acknowledgement back and the end-of-day report should be received
    And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired"
    And if payment fails a failure notification should be sent to the case and the agent should be flagged
    And SEPA transfer processing should take 5 to 10 business days
    And the Claims Dashboard Compensation tab should show payout details "�600 EUR" with payment method "Cash" via "SEPA Bank Transfer" and status updated via talkback
    And currency conversion logging should be for internal reporting only with �600 EUR multiplied by Bank of Canada rate equaling approximately $880 CAD equivalent logged but NOT used for regime selection
    And exchange rate source should be Bank of Canada with exchange rate date and value logged for reporting only
    And both regime assessments should be logged in audit trail with EU 261 Eligible �600 SELECTED per fixed priority and APPR Eligible $400 not selected
    And the compensation amount must be the EU 261 amount �600 NOT the APPR amount $400
    And the payment currency should follow the customer's country of residence France resulting in EUR and EU 261 compensation is already in EUR so no additional conversion is needed for payment
    And no CAD conversion comparison should be performed for regime selection as selection is by fixed priority hierarchy per legal team approval

Expected Results:
DDS returns FD-MIXED-EL-01. Trip Tracer: Promise = 16:00; Actual = 20:00; Delay = 4hrs; MSL = Leg 1 (AC CDG?YYZ); Code 42; Controllable; Regime = EU 261 + APPR (both apply). Dual Assessment: EU 261 = �600 (EU261 column, 4+ hours, >3500km, controllable); APPR = $400 CAD (Tier 1, 3�<6hrs). Most Generous Selection: Fixed priority hierarchy � APPR & EU ? EU always first (per legal team approval). EU 261 SELECTED � �600. CRITICAL: Both regimes MUST be assessed and logged. Selection is by fixed priority order, NOT by CAD conversion comparison. Dashboard must show APPR result alongside EU result, with EU flagged as selected. Claims Dashboard: Primary = EU 261 (�600, selected per fixed priority); Secondary = APPR ($400, not selected); DDS = FD-MIXED-EL-01.