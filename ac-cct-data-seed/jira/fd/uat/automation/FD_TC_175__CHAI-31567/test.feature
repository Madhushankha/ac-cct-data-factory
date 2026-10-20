Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Toronto to Tel Aviv was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation"
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
And the user provides "Noam Golan"
Then the chatbot responds:
"Thanks, Noam! And, what is your booking reference number?"
And the user provides "PNR: TC149"
Then the chatbot searches Trip Tracer for PNR: TC149
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
Email: n***@gmail.com
Phone: +972***456
And the user selects "Email: n***@gmail.com"
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
Noam Golan (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
Flight: AC 085
Route: Toronto (YYZ) ? Tel Aviv Ben Gurion (TLV)
Date: June 3, 2026
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
REGIME DETERMINATION � DUAL REGIME (APPR + ASL):
Then the system determines applicable regimes:
And the system checks: Origin airport = YYZ (Toronto, Canada) ? APPR applies (Canada departure)
And the system checks: Destination airport = TLV (Tel Aviv, Israel) ? ASL applies (Israel arrival)
And the system checks: Origin = YYZ (not EU) ? EU 261 does NOT apply
And the system determines: DUAL REGIME � APPR + ASL (both assessed independently)
TRIAGE & DDS EVALUATION � DUAL REGIME:
Then the DDS evaluation is done in backend
And DDS assesses BOTH regimes independently:
APPR ASSESSMENT:
? Origin: YYZ (Canada) ? APPR applies
? Delay: 4 hours ? 3�<6h tier (Tier 1)
? Code: 42 ? Controllable under APPR
? APPR Result: ELIGIBLE � $400 CAD
ASL ASSESSMENT:
? Destination: TLV (Israel) ? ASL applies
? Delay: 4 hours
? Per compensation table: ASL compensation starts at 8+ hours (3670 ILS). At 4hr delay, ASL has NO applicable compensation amount.
? Code: 42 ? Controllable under ASL
? ASL Result: NOT ELIGIBLE (delay below ASL 8-hour threshold)
REGIME SELECTION:
? Applicable regimes: APPR & ASL
? APPR: ELIGIBLE � $400 CAD
? ASL: NOT ELIGIBLE (4hr delay < 8hr ASL threshold)
? Only one regime eligible ? APPR selected as the only eligible regime
? SELECTED: APPR � $400 CAD
? NOTE: Per fixed priority, ASL would be selected over APPR if both were eligible (ASL > APPR). But ASL is NE at this delay, so APPR is selected by default.
TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC149
? Promised Itinerary - Flight: AC 085, Route: YYZ ? TLV, Scheduled Arrival: 06:00
? Current Itinerary - Flight: AC 085, Route: YYZ ? TLV, Status: ARRIVED LATE, Actual: 10:00, Delay: +4H 00M
? Dual Regime: APPR + ASL
? EU 261: NOT APPLICABLE (origin not EU)
? APPR: ELIGIBLE � $400 CAD
? ASL: NOT ELIGIBLE (4hr delay < 8hr ASL threshold � ASL compensation starts at 8+ hours)
? Selected: APPR � $400 CAD (only eligible regime)
? MSL FLIGHT: AC 085 � YYZ ? TLV � 42
? CONTROLLABLE (Code 42)
Flight Compensation:
? MR NOAM GOLAN | ELIGIBLE | APPR_3_TO_6_HOURS (ONLY ELIGIBLE REGIME) | $400 CAD
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment
ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 085 from Toronto (YYZ) to Tel Aviv Ben Gurion (TLV) was delayed by about 4 hours. Based on the applicable regulations, you may be eligible for compensation of $400 CAD for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."
CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Israel"
Then the system determines: Country = Israel ? Currency = ILS ? Payment Method = BSM Email Payment
CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot responds: "You are entitled to receive $400 CAD compensation (equivalent in ILS at current exchange rate). Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency (ILS)."
And user provides "Yes"
Then system checks which payment method is mapped based on country of residence ? BSM Email Payment
Replace the entire PAYMENT METHOD section with:

PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07):
Then the chatbot responds:
"Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information and updates about this case. Would you like to use n***@gmail.com? Please note that only one email address can be used for this compensation and it can't be changed once confirmed"
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
Deposit Amount: $400 CAD (equivalent in ILS)
Payment Method: Email
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps.
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user provides: "Yes"
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
CURRENCY CONVERSION LOGGING (Backend � Reporting):
? Compensation Amount (Selected Regime � APPR): $400 CAD
? ASL Amount (Not Selected � NE): $0 (ASL not eligible at 4hr delay)
? Exchange Rate Used: CAD ? ILS (Bank of Canada rate)
? Payment Currency: ILS (customer in Israel)
? Exchange Rate Source: Bank of Canada
? Exchange Rate Date: June 15, 2026
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to n***@gmail.com
And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR � only eligible regime), flight details (YYZ?TLV, 4hr delay), next steps, tracking link
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
I would like you to � new flow
No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Noam Golan" with PNR "TC149"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Noam Golan"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC149"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR + ASL (Dual Regime � APPR SELECTED; ASL Not Eligible at this delay)"
    And EU 261 should be N/A as not EU origin
    And the Full Name should be "Noam Golan"
    And the Tags should include "Claimant" and "Adult"
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: YYZ ? TLV" with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And Assessment 1 ELIGIBLE SELECTED should be APPR with eligibility ELIGIBLE and compensation "$400 CAD" Tier 1 3 to less than 6hrs controllable and SELECTED as only eligible regime
    And Assessment 2 NOT ELIGIBLE should be ASL with eligibility NOT ELIGIBLE due to 4hr delay being less than 8hr ASL threshold and compensation $0 as ASL compensation starts at 8 plus hours per compensation table and NOT SELECTED
    And only one regime should be eligible so APPR should be selected by default
    And if delay were 8 hours or more ASL would be eligible at 3670 ILS and would be selected over APPR per fixed priority as ASL is greater than APPR
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically
    And BOTH regimes should be assessed and logged
    And the eligibility decision should be "ELIGIBLE" under APPR as only eligible regime
    And the ASL assessment should be visible showing NOT ELIGIBLE below 8hr threshold
    And the Duplicate Check should have run automatically using baseline data "Noam Golan + TC149 + YYZ?TLV + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And the CyberSource result should be "GREEN"
    And the system should have appended the booking record automatically for identified and authenticated user
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And an eligible notification email should have been sent containing compensation "$400 CAD" and regulation "APPR" and flight details YYZ to TLV 4hr delay and exchange rate CAD to ILS
    And the Agent Notes section should be accessible
    And the Audit Log should record dual-regime assessment with APPR $400 selected and ASL NE below 8hr threshold
    And the exchange rate should be logged CAD to ILS
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Resolved"
    And the case should be in read-only mode
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the customer's country of residence is "Israel"
    Then the currency should be set to "ILS"
    And the payment method should be "BSM Email Payment"
    And the customer has no Aeroplan linked so only Cash should be offered and AC Wallet should NOT be offered
    And the dual regime should be assessed with APPR ELIGIBLE at $400 CAD vs ASL NOT ELIGIBLE at 4hr delay less than 8hr ASL threshold
    And only APPR should be eligible so APPR should be selected as only eligible regime at $400 CAD
    And the compensation amount should be "$400 CAD" converted to ILS for payment
    And email should be confirmed for BSM Email Payment
    And IDV should be completed via Persona and IDV should PASS
    And a compensation record should be created in the backend with GL account and cost center
    And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team
    And Cash should be dispatched to Unifier and Unifier should process BSM Email Payment in ILS
    And HSBC should send an acknowledgement back and the end-of-day report should be received
    And the end-of-day report should show status "Pending" transitioning to "Completed" or "Rejected" or "Expired"
    And the Claims Dashboard Compensation tab should show payout details "$400 CAD" as APPR selected with payment currency ILS and exchange rate Bank of Canada CAD to ILS and payment method BSM Email Payment and status updated via talkback
    And the exchange rate source and date and value should be logged
    And ASL was assessed but NOT ELIGIBLE at 4hr delay as ASL compensation starts at 8 plus hours per compensation table and if delay were 8hrs or more ASL at 3670 ILS would be eligible and would be selected over APPR per fixed priority as ASL is greater than APPR

Expected Results:
DDS returns FD-MIXED-EL-04. Trip Tracer: Promise = 06:00; Actual = 10:00; Delay = 4hrs; MSL = Leg 1; Code 42; Controllable; Regime = APPR + ASL (both assessed). APPR = ELIGIBLE ($400 CAD, Tier 1, 3�<6hrs). ASL = NOT ELIGIBLE (4hr delay < 8hr ASL threshold � per compensation table, ASL starts at 8+ hours with 3670 ILS). Only APPR eligible ? APPR selected. NOTE: If delay were ?8hrs, ASL (3670 ILS) would be eligible and would be selected over APPR per fixed priority (ASL > APPR). Claims Dashboard: APPR = Eligible ($400, selected); ASL = Not Eligible (below 8hr threshold); DDS = FD-MIXED-EL-04.