Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight was cancelled and I rebooked myself, then I was moved to an earlier flight. I still arrived 4 hours late. Can I get compensation?"
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
And the user provides "Ren�e Cloutier"
Then the chatbot responds:
"Thanks, Ren�e! And, what is your booking reference number?"
And the user provides "PNR: TCCOMBO12"
Then the chatbot searches Trip Tracer for PNR: TCCOMBO12
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: r***@gmail.com
� Phone: +1***345
And the user selects "Email: r***@gmail.com"
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
Then the chatbot asks:
"How many people are on your claim?"
And the chatbot displays passengers from PNR:
"I found 1 passenger on this booking:
� Ren�e Cloutier (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 443
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: June 16, 2026
� Arrival Delay: 4 hours
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
TRIAGE & DDS EVALUATION � INVOL THEN NEGATIVE VOL DETECTED:
Then the DDS evaluation is done in backend
And DDS checks booking change history:
? Change 1: INVOL � AC cancels original flight
? Change 2: SELFREACC (identifier: XXXAC08SR + UN/TK)
? Classification: INVOL (SELFREACC = customer self-rebook necessitated by airline cancellation)
? SELFREACC changed arrival from 10:00 ? 17:00
? Promise update: NO � INVOL does NOT update promise
? Promise remains at: 10:00 (14-day mark)
? Change 3: Volantio tool (identifier: SK VOLY)
? Classification: VOL (Volantio is always voluntary)
? Volantio changed arrival from 17:00 ? 14:00 (customer went EARLIER by -3hrs)
? Direction: NEGATIVE (-3hrs � customer chose an earlier flight, mitigating the delay)
? Promise update: VOL after INVOL does NOT update promise
? Promise remains at: 10:00
? NEGATIVE VOL � NO DEDUCTION LOGIC:
? Total delay = 14:00 - 10:00 = 4 hours (actual - promise)
? Post-INVOL VOL direction = NEGATIVE (-3hrs � customer went EARLIER)
? Negative VOL = NOT DEDUCTED (customer is mitigating)
? Net delay = 4 hours (full delay, no deduction)
? APPR: Net delay 3�6h, Controllable (Code 42) ? ELIGIBLE � $400 CAD (Tier 1)
? CRITICAL ASSERTION: Customer mitigated by going earlier after SELFREACC � no penalty. Full 4hr delay used.
TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TCCOMBO12
? Promised Itinerary - Flight: AC 443, Route: YUL ? YYZ, Scheduled Arrival: 10:00 (14-day mark)
? Current Itinerary - Flight: AC 443, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 14:00, Delay: +4H 00M
? Change History:
Change 1: INVOL cancellation
Change 2: SELFREACC (XXXAC08SR + UN/TK) � INVOL � arrival 10:00 ? 17:00 � PROMISE NOT UPDATED
Change 3: Volantio (SK VOLY) � VOL (-ve) � arrival 17:00 ? 14:00 � NEGATIVE, NO DEDUCTION
? Promise = 10:00 (14-day mark)
? Total/Net delay = 4hrs (14:00 - 10:00) � NO deduction for negative VOL
? Post-INVOL VOL = -3hrs (NEGATIVE ? NOT DEDUCTED)
? Regime: APPR
? APPR: Delay 3�6h, Controllable ? ELIGIBLE
? MSL FLIGHT: AC 443 � YUL ? YYZ � 42
? CONTROLLABLE (Code 42)
Flight Compensation:
? MS REN�E CLOUTIER | ELIGIBLE | APPR_3_TO_6_HOURS | CAD $400
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment
ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like flight AC 443 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours. Based on the Canadian Air Passenger Protection Regulations (APPR), you may be eligible for compensation of $400 CAD for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."
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
And the user provides "renee.cloutier@gmail.com"
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
And an eligible notification email is sent to r***@gmail.com
And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details (AC 443, YUL?YYZ, 4hr delay), next steps, tracking link
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Ren�e Cloutier" with PNR "TCCOMBO12"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Ren�e Cloutier"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TCCOMBO12"
    And the Regime should be "APPR"
    And the Full Name should be "Ren�e Cloutier"
    And the Tags should include "Claimant" and "Adult"
    And the Aeroplan should be "Not linked"
    And the Journey should show "Bound 1: YUL ? YYZ"
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility should be "ELIGIBLE" under APPR with compensation "$400 CAD" Tier 1 3 to less than 6hrs controllable
    And the Change History should show Change 1 INVOL cancellation and Change 2 SELFREACC XXXAC08SR plus UN/TK as INVOL with arrival 10:00 to 17:00 and PROMISE NOT UPDATED and Change 3 Volantio SK VOLY as VOL negative with arrival 17:00 to 14:00 and NEGATIVE NO DEDUCTION
    And the Promise should be 10:00 at 14-day mark
    And the Total and Net delay should be 4hrs from 14:00 minus 10:00 with NO deduction for negative VOL
    And the Post-INVOL VOL should be minus 3hrs NEGATIVE and NOT DEDUCTED
    And the Actual should be 14:00
    And the Negative VOL as customer mitigation should NEVER be deducted and the full delay should be used
    And DDS should have run automatically
    And INVOL should have been detected via SELFREACC with promise staying at 14-day mark
    And VOL negative should have been detected via Volantio SK VOLY with negative equals NO deduction as customer mitigating
    And the Full delay should be 4hrs resulting in Tier 1
    And the result should be ELIGIBLE at $400 CAD
    And the Duplicate Check should have run automatically using baseline data "Ren�e Cloutier + TCCOMBO12 + YUL?YYZ + FD"
    And the result should be "No duplicate found"
    And the CyberSource result should be "GREEN"
    And the system should have appended the booking record automatically
    And an eligible notification email should have been sent via Adobe containing Case Reference and compensation $400 CAD and regulation APPR and flight details AC 443 YUL to YYZ 4hr delay and next steps
    And the Audit Log should record INVOL cancel then SELFREACC INVOL promise unchanged at 10:00 then Volantio VOL negative minus 3hrs NOT deducted as customer mitigating and delay 4hrs and eligible $400
    And the negative VOL should be logged as mitigation with no deduction applied
    And the Final Status should be "Resolved"
    And the case should be in read-only mode
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the customer's country of residence is "Canada"
    Then the currency should be set to "CAD"
    And the payment method should be "Interac e-Transfer"
    And the customer has no Aeroplan linked so only Cash should be offered
    And the compensation amount should be "$400 CAD" APPR Tier 1 full 4hr delay with no deduction for negative VOL
    And IDV at Payment should be triggered via Persona and Persona should return IDV PASS
    And a compensation record should be created in the backend with GL account and cost center
    And Cash should be dispatched to Unifier and Unifier should process Interac e-Transfer for $400 CAD
    And if unclaimed after 35 days the status should be Expired
    And the Claims Dashboard Compensation tab should show payout details "$400 CAD" with payment method "Cash" via "Interac e-Transfer" and status updated via talkback

Expected Results:
Sequence: INVOL cancel ? INVOL (SELFREACC) ? VOL (-ve Volantio); Promise: 10:00 (14-day); Actual: 14:00; Delay: 4hrs; Negative VOL (-3hrs): NOT deducted; Full delay used; APPR Tier 1; ELIGIBLE $400 CAD |