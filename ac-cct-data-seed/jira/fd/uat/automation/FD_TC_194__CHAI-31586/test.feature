Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I changed my flight at the airport a few days ago, then on the day of travel Air Canada re-routed me. I arrived 5 hours late. Can I get compensation?"
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
And the user provides "Isabelle Fortier"
Then the chatbot responds:
"Thanks, Isabelle! And, what is your booking reference number?"
And the user provides "PNR: TCCOMBO04"
Then the chatbot searches Trip Tracer for PNR: TCCOMBO04
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: i***@gmail.com
� Phone: +1***567
And the user selects "Email: i***@gmail.com"
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
� Isabelle Fortier (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 427
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: June 12, 2026
� Arrival Delay: 5 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED
REGIME DETERMINATION:
Then the system determines: Origin = YUL (Canada) ? APPR
TRIAGE & DDS EVALUATION � VOL THEN INVOL DETECTED:
Then the DDS evaluation is done in backend
And DDS checks booking change history:
? Change 1 (D-3): Airport agent change
? Identifier: Airport office ID in PNR history (e.g., YULAC0101)
? ACNP marker: NOT PRESENT
? Disruption context: NONE (no IROPS, no cancellation, no delay at time of change)
? Classification: VOL (Airport office ID + no ACNP + no disruption context = customer-initiated change)
? Airport VOL changed arrival from 10:00 ? 12:00
? Promise update: 10:00 ? 12:00 (VOL updates promise)
? Change 2 (D-0): OPR (identifier: YTOAC00PR)
? Classification: INVOL (OPR = airline-initiated operational re-protection)
? OPR changed arrival from 12:00 ? 17:00
? Promise update: NO � INVOL does NOT update promise
? Promise remains at: 12:00 (last VOL before INVOL)
? Promise logic: Airport VOL at D-3 updated promise to 12:00. OPR at D-0 is INVOL and does NOT further update promise. Promise = 12:00 (last VOL arrival before first INVOL)
? Actual arrival: 17:00
? Delay from promise: 17:00 - 12:00 = 5 hours
? APPR: Delay 3�6h, Controllable (Code 42) ? ELIGIBLE � $400 CAD (Tier 1)
? CRITICAL ASSERTION: OPR must NOT override the VOL-updated promise. Promise stays at 12:00 (the Airport VOL arrival).
TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TCCOMBO04
? Promised Itinerary - Flight: AC 427, Route: YUL ? YYZ, Scheduled Arrival: 12:00 (updated by Airport VOL, NOT further updated by OPR)
? Current Itinerary - Flight: AC 427, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 17:00, Delay: +5H 00M
? Change History:
Change 1: Airport Agent (airport office ID YULAC0101, no ACNP, no disruption) at D-3 � VOL � arrival 10:00 ? 12:00 � PROMISE UPDATED
Change 2: OPR (YTOAC00PR) at D-0 � INVOL � arrival 12:00 ? 17:00 � PROMISE NOT UPDATED
? Promise = 12:00 (last VOL before first INVOL)
? Delay from promise = 5 hours (17:00 - 12:00)
? Regime: APPR
? APPR: Delay 3�6h, Controllable ? ELIGIBLE
? MSL FLIGHT: AC 427 � YUL ? YYZ � 42
? CONTROLLABLE (Code 42)
Flight Compensation:
? MS ISABELLE FORTIER | ELIGIBLE | APPR_3_TO_6_HOURS | CAD $400
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment
ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 427 from Montreal (YUL) to Toronto (YYZ) was delayed by about 5 hours. Based on the Canadian Air Passenger Protection Regulations (APPR), you may be eligible for compensation of $400 CAD for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."
CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada"
Then the system determines: Country = Canada ? Currency = CAD
CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot checks if the claim is for multiple pax ? No
Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency."
And user provides "Yes"
Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada)
PAYMENT METHOD � INTERAC E-TRANSFER (FD-07):
Then the chatbot responds:
"Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer."
And the user provides "isabelle.fortier@gmail.com"
Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded."
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
Deposit Amount: $400 CAD
Payment Method: Interac e-Transfer
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
And an eligible notification email is sent to i***@gmail.com
And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details (AC 427, YUL?YYZ, 5hr delay from VOL-updated promise), next steps, tracking link
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Isabelle Fortier" with PNR "TCCOMBO04"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Isabelle Fortier"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TCCOMBO04"
    And the Regime should be "APPR"
    And the Full Name should be "Isabelle Fortier"
    And the Tags should include "Claimant" and "Adult"
    And the Aeroplan should be "Not linked"
    And the Journey should show "Bound 1: YUL ? YYZ"
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility should be "ELIGIBLE" under APPR with compensation "$400 CAD" Tier 1 3 to less than 6hrs controllable
    And the Change History should show Change 1 Airport Agent airport office ID YULAC0101 no ACNP no disruption at D-3 as VOL with arrival 10:00 to 12:00 and PROMISE UPDATED and Change 2 OPR YTOAC00PR at D-0 as INVOL with arrival 12:00 to 17:00 and PROMISE NOT UPDATED
    And the Promise should be 12:00 as last VOL before first INVOL NOT 14-day mark 10:00
    And the Actual should be 17:00
    And the Delay should be 5hrs from VOL-updated promise
    And OPR should NOT have overridden the VOL-updated promise
    And DDS should have run automatically
    And VOL should have been detected via Airport Agent no ACNP no disruption with promise updated to 12:00
    And INVOL should have been detected via OPR YTOAC00PR with promise NOT further updated
    And the result should be ELIGIBLE at $400 CAD
    And the Duplicate Check should have run automatically using baseline data "Isabelle Fortier + TCCOMBO04 + YUL?YYZ + FD"
    And the result should be "No duplicate found"
    And the CyberSource result should be "GREEN"
    And the system should have appended the booking record automatically
    And an eligible notification email should have been sent via Adobe containing Case Reference and compensation $400 CAD and regulation APPR and flight details AC 427 YUL to YYZ 5hr delay and next steps
    And the Audit Log should record Airport VOL at D-3 airport office ID no ACNP no disruption promise 10:00 to 12:00 then OPR INVOL at D-0 YTOAC00PR promise unchanged at 12:00 and delay 5hrs and eligible $400
    And the Final Status should be "Resolved"
    And the case should be in read-only mode
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the customer's country of residence is "Canada"
    Then the currency should be set to "CAD"
    And the payment method should be "Interac e-Transfer"
    And the customer has no Aeroplan linked so only Cash should be offered
    And the compensation amount should be "$400 CAD" APPR Tier 1 3 to less than 6hrs controllable
    And IDV at Payment should be triggered via Persona and Persona should return IDV PASS
    And a compensation record should be created in the backend with GL account and cost center
    And Cash should be dispatched to Unifier and Unifier should process Interac e-Transfer for $400 CAD
    And the Claims Dashboard Compensation tab should show payout details "$400 CAD" with payment method "Cash" via "Interac e-Transfer" and status updated via talkback

Expected Results:
Sequence: VOL (Airport Agent, no ACNP, no disruption) ? INVOL (OPR); Promise: 12:00 (last VOL before INVOL); OPR did NOT override VOL promise; Actual: 17:00; Delay: 5hrs; APPR Tier 1; ELIGIBLE $400 CAD |