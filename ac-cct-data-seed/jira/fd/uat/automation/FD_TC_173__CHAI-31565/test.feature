Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Paris to Toronto was delayed 10 hours due to a crew issue. I'd like to check if I'm eligible for compensation"
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
And the user provides "Jean-Marc Rousseau"
Then the chatbot responds:
"Thanks, Jean-Marc! And, what is your booking reference number?"
And the user provides "PNR: TC147"
Then the chatbot searches Trip Tracer for PNR: TC147
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
Email: j***@gmail.com
Phone: +33***234
And the user selects "Email: j***@gmail.com"
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
Jean-Marc Rousseau (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
Flight: AC 871
Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ)
Date: June 1, 2026
Arrival Delay: 10 hours
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
And the system determines: DUAL REGIME � EU 261 + APPR (both assessed independently)
TRIAGE & DDS EVALUATION � DUAL REGIME FIXED PRIORITY:
Then the DDS evaluation is done in backend
And DDS assesses BOTH regimes independently:
EU 261 ASSESSMENT:
? Origin: CDG (EU) ? EU 261 applies
? Distance: CDG?YYZ = ~5,500 km ? Long-haul (>3500km)
? Delay: 10 hours ? 4+ threshold (EU261 amount is fixed at �600 for >3500km regardless of delay duration beyond 4h)
? Code: 42 ? Controllable under EU 261
? EU 261 Result: ELIGIBLE � �600 (fixed amount for long-haul ?4h)
APPR ASSESSMENT:
? Destination: YYZ (Canada) ? APPR applies
? Delay: 10 hours ? 9+ hours tier (Tier 3)
? Code: 42 ? Controllable under APPR
? APPR Result: ELIGIBLE � $1,000 CAD (Tier 3: 9+ hours)
MOST GENEROUS SELECTION (Fixed Priority):
? Applicable regimes: APPR & EU
? Per Most Generous Logic: APPR & EU ? EU is always selected first (fixed priority hierarchy)
? EU 261: �600
? APPR: $1,000 CAD (not selected despite higher CAD value)
? SELECTED: EU 261 � �600
? CRITICAL: There is NO "regime flip." The fixed priority hierarchy does NOT change based on delay duration or amount comparison. EU is always selected over APPR per legal team approval, even when APPR's CAD amount ($1,000) exceeds EU's converted equivalent (~$880 CAD). The legal team explicitly approved this: "Although certain EU amounts are slightly below the CAD, they were fine with placing EU over APPR."
TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC147
? Promised Itinerary - Flight: AC 871, Route: CDG ? YYZ, Scheduled Arrival: 10:00
? Current Itinerary - Flight: AC 871, Route: CDG ? YYZ, Status: ARRIVED LATE, Actual: 20:00, Delay: +10H 00M
? Dual Regime: EU 261 + APPR
? EU 261: ELIGIBLE � �600
? APPR: ELIGIBLE � $1,000 CAD
? Most Generous: EU 261 � �600 (fixed priority: EU always selected over APPR, NO regime flip)
? MSL FLIGHT: AC 871 � CDG ? YYZ � 42
? CONTROLLABLE (Code 42)
Flight Compensation:
? MR JEAN-MARC ROUSSEAU | ELIGIBLE | EU261_4_PLUS_HOURS_LONG_HAUL (FIXED PRIORITY) | �600
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment
ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 871 from Paris Charles de Gaulle (CDG) to Toronto (YYZ) was delayed by about 10 hours. Based on the applicable regulations, you may be eligible for compensation of �600 for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."
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
Then system checks which payment method is mapped based on country of residence ? BSM Email Payment
PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07):
Then the chatbot responds:
"Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information and updates about this case. Would you like to use [Email Address]? Please note that only one email address can be used for this compensation and it can't be changed once confirmed"
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
? APPR Amount (Not Selected): $1,000 CAD
? Exchange Rate Used: 1 EUR = 1.4667 CAD (for internal reporting only)
? CAD Equivalent of EU 261 Amount: ~$880 CAD (logged for reporting only)
? Exchange Rate Date: June 15, 2026
? Payment Currency: EUR (customer in France � no conversion needed)
? NOTE: APPR $1,000 exceeds EU ~$880 CAD equivalent, but EU is still selected per fixed priority. No regime flip.
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to j***@gmail.com
And the email contains: Case Reference, compensation amount (�600 EUR), regulation (EU 261 � selected per fixed priority), flight details (CDG?YYZ, 10hr delay), next steps, tracking link
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
I would like you to � new flow
No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Jean-Marc Rousseau" with PNR "TC147"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Jean-Marc Rousseau"
    And the Authentication should be "Pass"
    And the PNR should be "TC147"
    And the Regime should be "EU 261 + APPR (Dual Regime � EU 261 SELECTED per fixed priority)"
    And the Full Name should be "Jean-Marc Rousseau"
    And the Tags should include "Claimant" and "Adult"
    And the Journey should show "Bound 1: CDG ? YYZ" with claim filed for this flight
    And the Primary Selected regime should be EU 261 with eligibility ELIGIBLE and compensation "�600 EUR" for greater than 3500km and EU compensation is FIXED by distance band and does NOT increase with longer delays and SELECTED per fixed priority hierarchy
    And the Secondary Not Selected regime should be APPR with eligibility ELIGIBLE and compensation "$1,000 CAD" Tier 3 9hrs or more controllable and NOT SELECTED as EU always takes priority over APPR per fixed hierarchy even when APPR CAD amount is higher
    And the Selection Method should be fixed priority hierarchy NOT CAD conversion comparison
    And there should be NO regime flip as EU is always selected over APPR regardless of delay tier
    And at 4hr delay TC189 EU �600 was selected and APPR $400 was not selected
    And at 10hr delay TC147 EU �600 is STILL selected and APPR $1,000 is STILL not selected
    And the fixed priority does NOT change based on delay duration or amount
    And DDS should have run automatically
    And BOTH regimes should be assessed and logged
    And the eligibility decision should be "ELIGIBLE" under EU 261 fixed priority
    And EU 261 should be flagged as SELECTED
    And the Duplicate Check should have run automatically and the result should be "No duplicate found"
    And the CyberSource result should be "GREEN"
    And the system should have appended the booking record automatically
    And an eligible notification email should have been sent containing compensation "�600 EUR" and regulation "EU 261" and flight details CDG to YYZ 10hr delay
    And the Final Status should be "Resolved"
    And the case should be in read-only mode
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the customer's country of residence is "France"
    Then the currency should be set to "EUR"
    And the payment method should be "BSM Email Payment"
    And the customer has no Aeroplan linked so only Cash should be offered and AC Wallet should NOT be offered
    And EU should be selected despite APPR having higher CAD amount with $1,000 being greater than approximately $880 CAD equivalent of �600 as this is fixed priority with NO regime flip
    And the compensation amount should be "�600" EUR as EU 261 selected per fixed priority
    And the payment currency should be EUR as the customer is in France and EU 261 is already in EUR so no conversion is needed
    And IDV should be completed via Persona and IDV should PASS
    And a compensation record should be created in the backend with GL account and cost center
    And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team
    And Cash should be dispatched to Unifier and Unifier should process Email Payment
    And Unifier should send an acknowledgement back
    And the end-of-day report should be received with status "Pending" transitioning to "Completed" or "Rejected"
    And the Claims Dashboard Compensation tab should show payout details "�600 EUR" as EU 261 selected per fixed priority with payment currency EUR and payment method SEPA and status updated via talkback
    And both regime assessments should be logged with EU 261 Eligible �600 SELECTED and APPR Eligible $1,000 not selected
    And NO regime flip exists as EU is always selected over APPR regardless of delay tier per legal team approval

Expected Results:
DDS returns FD-MIXED-EL-02. Trip Tracer: Promise = 10:00; Actual = 20:00; Delay = 10hrs; MSL = Leg 1; Code 42; Controllable; Regime = EU 261 + APPR. Dual Assessment: EU 261 = �600 (>3500km � EU compensation is FIXED by distance band, does NOT increase with longer delays); APPR = $1,000 CAD (Tier 3, ?9hrs). Most Generous Selection: Fixed priority � APPR & EU ? EU always first. EU 261 SELECTED � �600. CRITICAL: There is NO regime flip. EU is always selected over APPR regardless of delay duration or amount. At 10hr delay, APPR's $1,000 CAD exceeds EU's ~$880 CAD equivalent, but the fixed priority hierarchy (approved by legal) overrides any amount comparison. Compensation: �600 (EU 261). Claims Dashboard: Primary = EU 261 (�600, selected per fixed priority); Secondary = APPR ($1,000, not selected despite higher CAD value); DDS = FD-MIXED-EL-02.