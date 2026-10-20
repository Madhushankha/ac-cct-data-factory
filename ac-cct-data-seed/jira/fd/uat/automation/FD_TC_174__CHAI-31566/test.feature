Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Paris to Toronto was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation"
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
And the user provides "Claudette Beauregard"
Then the chatbot responds:
"Thanks, Claudette! And, what is your booking reference number?"
And the user provides "PNR: TC148"
Then the chatbot searches Trip Tracer for PNR: TC148
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
Email: c***@gmail.com
Phone: +33***345
And the user selects "Email: c***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "629184"
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
Claudette Beauregard (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
Flight: AC 871
Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ)
Date: June 2, 2026
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
REGIME DETERMINATION � DUAL REGIME:
Then the system determines: Origin = CDG (EU) ? EU 261 applies; Destination = YYZ (Canada) ? APPR applies
And the system determines: DUAL REGIME � EU 261 + APPR
TRIAGE & DDS EVALUATION � DUAL REGIME FIXED PRIORITY:
Then the DDS evaluation is done in backend
EU 261 ASSESSMENT:
? Distance: ~5,500 km ? Long-haul (>3500km)
? Delay: 4 hours ? 4+ threshold
? Code: 42 ? Controllable
? EU 261 Result: ELIGIBLE � �600
APPR ASSESSMENT:
? Delay: 4 hours ? 3�<6h tier (Tier 1)
? Code: 42 ? Controllable
? APPR Result: ELIGIBLE � $400 CAD
MOST GENEROUS SELECTION (Fixed Priority):
? Per Most Generous Logic: APPR & EU ? EU always first
? SELECTED: EU 261 � �600
TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC148
? Dual Regime: EU 261 + APPR
? EU 261: ELIGIBLE � �600
? APPR: ELIGIBLE � $400 CAD
? Most Generous: EU 261 � �600 (fixed priority)
? MSL FLIGHT: AC 871 � CDG ? YYZ � 42
? CONTROLLABLE (Code 42)
? Aeroplan: Linked, ACTIVE
Flight Compensation:
? MS CLAUDETTE BEAUREGARD | ELIGIBLE | EU261_4_PLUS_HOURS_LONG_HAUL (FIXED PRIORITY) | �600
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 871 from Paris Charles de Gaulle (CDG) to Toronto (YYZ) was delayed by about 4 hours. Based on the applicable regulations, you may be eligible for compensation of �600 for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."
CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada"
Then the system determines: Country = Canada ? Currency = CAD
CASH vs AC WALLET CHECK (FD-06a) � AEROPLAN ACTIVE:
Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (Aeroplan linked)
Then the chatbot checks: Is Aeroplan account active (not frozen)? ? YES
Then the chatbot checks if the claim is for multiple pax ? No
AC WALLET CALCULATION � APPLIED TO EU-SELECTED AMOUNT:
Then the system calculates AC Wallet amount:
? Selected Regime: EU 261 (per fixed priority)
? EU 261 Compensation: �600
? Convert to CAD: �600 � 1.4667 = $880.02 CAD (base amount)
? AC Wallet Top-Up: 20%
? AC Wallet Amount: $880.02 � 1.20 = $1,056.02 CAD
CRITICAL VALIDATION: The 20% top-up is applied to the EU-selected amount converted to CAD ($880.02), NOT to the APPR amount ($400). If the system incorrectly used the APPR amount, the AC Wallet would be $400 � 1.20 = $480 � which is WRONG.
Then the chatbot responds:
"You are entitled to receive �600 compensation (approximately $880 CAD). You can choose to receive this as:
Cash � �600 (approximately $880 CAD) via Interac e-Transfer (5�10 business days)
AC Wallet � approximately $1,056 CAD in AC Wallet credits (120% value, available immediately)
Which would you prefer?"
And the user selects "AC Wallet"
AC WALLET PAYOUT (FD-06a):
Then the chatbot confirms:
"Great choice! You'll receive approximately $1,056 CAD in AC Wallet credits, which will be available in your Aeroplan account immediately after processing."
And the system records: Payment method = AC Wallet; Amount = ~$1,056 CAD (120% of ~$880 CAD EU-selected base); Aeroplan linked
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
Deposit Amount: ~$1,056 CAD (AC Wallet credits � 120% of �600 base)
Payment Method: AC Wallet (Aeroplan linked)
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
And an eligible notification email is sent to c***@gmail.com
And the email contains: Case Reference, compensation amount (~$1,056 CAD AC Wallet), base amount (�600 EU 261), payment method (AC Wallet), regulation (EU 261 � selected per fixed priority), flight details, next steps
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
I would like you to � new flow
No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Claudette Beauregard" with PNR "TC148"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Claudette Beauregard"
    And the Authentication should be "Pass"
    And the PNR should be "TC148"
    And the Regime should be "EU 261 + APPR (Dual Regime � EU 261 SELECTED per fixed priority)"
    And the Full Name should be "Claudette Beauregard"
    And the Tags should include "Claimant" and "Adult"
    And the Aeroplan should be "Linked, account active (NOT frozen)"
    And the Journey should show "Bound 1: CDG ? YYZ" with claim filed for this flight
    And the Primary Selected regime should be EU 261 with eligibility ELIGIBLE and base compensation "�600 EUR" for greater than 3500km controllable 4 plus hours and converted base approximately $880 CAD at Bank of Canada rate and SELECTED per fixed priority hierarchy
    And the Secondary Not Selected regime should be APPR with eligibility ELIGIBLE and compensation "$400 CAD" Tier 1 and NOT SELECTED
    And the AC Wallet calculation should show payment method AC Wallet with EAP check account active NOT frozen and base amount EU-selected per fixed priority converted approximately $880 CAD and AC Wallet 20% top-up approximately $880 multiplied by 1.20 equaling approximately $1,056 CAD
    And the top-up should be applied AFTER fixed-priority regime selection AND currency conversion as 20% of the winning regime's CAD-converted amount �600 to approximately $880 CAD to plus 20% equaling approximately $1,056 and NOT 20% of APPR's $400
    And the total AC Wallet deposit should be approximately $1,056 CAD
    And DDS should have run automatically
    And BOTH regimes should be assessed and logged
    And the eligibility decision should be "ELIGIBLE" under EU 261 selected per fixed priority
    And the AC Wallet top-up calculation should be shown
    And the Duplicate Check should have run automatically and the result should be "No duplicate found"
    And the CyberSource result should be "GREEN"
    And the system should have appended the booking record automatically
    And an eligible notification email should have been sent containing EU 261 selected per fixed priority and base �600 approximately $880 CAD and AC Wallet deposit approximately $1,056 CAD including 20% top-up and exchange rate
    And the Final Status should be "Resolved"
    And the case should be in read-only mode
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the customer's country of residence is "Canada"
    Then the currency should be set to "CAD"
    And the Aeroplan should be linked and account active NOT frozen so BOTH options should be offered with Cash approximately $880 CAD AND AC Wallet approximately $1,056 CAD with 20% top-up
    And the dual regime should be assessed with EU 261 �600 vs APPR $400 CAD and EU 261 should be SELECTED per fixed priority hierarchy
    And EU 261 should be selected per fixed priority NOT by amount comparison
    And AC Wallet should be offered because this is flight disruption EU 261 and AC Wallet is available for FD APPR or EU
    And the AC Wallet calculation should be applied to the EU-SELECTED amount with EU 261 base �600 converted to CAD at �600 multiplied by Bank of Canada rate for example 1.4667 equaling approximately $880.02 CAD and AC Wallet 20% top-up at approximately $880.02 multiplied by 1.20 equaling approximately $1,056.02 CAD
    And the 20% top-up must be applied to the EU-selected amount converted to CAD approximately $880 NOT to the APPR amount $400 and if the system incorrectly used the APPR amount AC Wallet would be $400 multiplied by 1.20 equaling $480 which is WRONG
    And the customer should select AC Wallet and approximately $1,056 CAD should be deposited
    And a compensation record should be created and picked up by the daily evening batch file and dispatched to EIP NOT Unifier
    And EIP should check Aeroplan account validity as active not frozen and PASS
    And EIP should send to iGiga and then iFly for deposit
    And iFly should talk back to EIP and EIP should talk back to Claims Dashboard with deposited amount approximately $1,056 CAD and status Completed or Issued
    And if the Aeroplan account is frozen or closed there should be a rejection with error message and failure notification to case and agent flagged
    And in UAT the batch file should be triggered manually in coordination with the EIP team
    And the Claims Dashboard Compensation tab should show payout details approximately $1,056 CAD with payment method "AC Wallet" and EU 261 selected per fixed priority and base �600 approximately $880 CAD and 20% top-up applied post-currency-conversion and status updated via talkback
    And the exchange rate should be logged with source Bank of Canada and date and value for AC Wallet CAD conversion NOT for regime selection

Expected Results:
DDS returns FD-MIXED-EL-03. Trip Tracer: Promise = 16:00; Actual = 20:00; Delay = 4hrs; Code 42; Controllable; Regime = EU 261 + APPR. Dual Assessment: EU 261 = �600 (>3500km); APPR = $400 CAD. Most Generous: Fixed priority � EU always over APPR ? EU selected. Currency conversion for AC Wallet: �600 � Bank of Canada rate = ~$880 CAD. AC Wallet top-up: $880 CAD base + 20% = ~$1,056 CAD. CRITICAL: Top-up is applied to the fixed-priority-selected regime's CAD-converted amount, NOT to APPR's $400. EAP check: Account active, deposit of ~$1,056 CAD. Claims Dashboard: EU 261 selected per fixed priority; Base = �600 (~$880 CAD); AC Wallet = ~$1,056 CAD; Exchange rate logged for AC Wallet conversion; DDS = FD-MIXED-EL-03.