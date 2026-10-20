Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I was denied boarding on my PAL flight because it was overbooked. They put me on a later flight and I arrived 4 hours late. I want compensation."
When the chatbot identifies denied boarding intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your denied boarding and see if you are eligible for compensation."
LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"
IDENTIFICATION (GenUC-01):
Then the chatbot responds:
"I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Fran�oise Lavoie"
Then the chatbot responds:
"Thanks, Fran�oise! And, what is your booking reference number?"
And the user provides "PNR: TC017"
Then the chatbot searches Trip Tracer for PNR: TC017
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: f***@gmail.com
� Phone: +1***678
And the user selects "Email: f***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "581937"
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
� Fran�oise Lavoie (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Leg 1: AC 501 � Montreal (YUL) ? Toronto (YYZ) � July 10, 2026
� Leg 2: PAL 802 � Toronto (YYZ) ? Vancouver (YVR) � July 10, 2026 � DENIED BOARDING
� Rebooked: PAL 806 � Toronto (YYZ) ? Vancouver (YVR) � July 10, 2026
� Arrival Delay at final destination: 4 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK (GenUC-18):
Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 legs + rebooking)
Then the chatbot identifies: Denied boarding occurred on Leg 2 (PAL 802 YYZ?YVR)
Then the chatbot confirms segments with customer
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED
CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days ? within 366 days ? PROCEED
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS evaluates: Disruption type = DENIED BOARDING (not delay/cancellation)
And DDS evaluates: Was denied boarding voluntary or involuntary? ? INVOLUNTARY (overbooking)
And DDS evaluates: Delay at final destination = 4 hours
TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC017
? Promised Itinerary - Leg 1: AC 501 YUL?YYZ, Leg 2: PAL 802 YYZ?YVR, Scheduled Final Arrival: 18:00
? Current Itinerary - Leg 1: AC 501 YUL?YYZ (ON TIME), Leg 2: PAL 802 YYZ?YVR (DENIED BOARDING), Rebooked: PAL 806 YYZ?YVR, Actual Final Arrival: 22:00, Delay: +4H 00M
? Disruption Type: DENIED BOARDING (not delay/cancellation)
? Regime: APPR
? MSL FLIGHT: PAL 802 � YYZ ? YVR � 97
? "Denied boarding due to overbooking"
? Delay at destination: +4H 00M
? Denied Boarding Classification: INVOLUNTARY
? PAL coding: Code 97 � PRESENT (verify coding is populated for DB scenario)
Flight Compensation:
? MS FRAN�OISE LAVOIE | ELIGIBLE | DENIED_BOARDING | DELAY_AT_DEST_GTE_2_HRS | CAD 900.00 | [expiry date]
? CRITICAL: DB compensation tier applies (NOT FD delay tier). Under APPR, involuntary denied boarding with ?2hr delay at destination = $900 CAD
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment
ELIGIBLE RESULT (DB-05a):
Then the chatbot displays:
"I've checked your flight details, and it looks like you were denied boarding on flight PAL 802 from Toronto (YYZ) to Vancouver (YVR) due to overbooking. You were rebooked and arrived approximately 4 hours late at your final destination. Based on the Air Passenger Protection Regulations (APPR), you may be eligible for denied boarding compensation. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."
CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada"
Then the system determines: Country = Canada ? Currency = CAD
CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot checks if the claim is for multiple pax ? No
Then the chatbot responds: "You are entitled to receive a $900 CAD compensation for denied boarding. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency."
And user provides "Yes"
Then system checks which payment method is mapped based on country of residence ? Interac (CANADA)
PAYMENT METHOD � INTERAC (FD-07):
Then the chatbot responds:
"Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information. Would you like to use f***@gmail.com? Please note that only one email address can be used for this compensation/reimbursement and it can't be changed once confirmed."
And the user confirms "Yes, use this email"
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
CLAIM AMOUNT CONFIRMATION:
Then the chatbot responds: "Please review your compensation details:
Deposit Amount: $900 CAD
Payment Method: f***@gmail.com
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps that will also include the password required to access the secure payment link, which will be sent in a separate email
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user provides: "Yes"
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to f***@gmail.com
And the email contains: Case Reference, compensation amount ($900 CAD), regulation (APPR), disruption type (Denied Boarding), flight details, next steps, tracking link
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Antoine Lavoie" with PNR "TC184"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Denied Boarding"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Antoine Lavoie"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC184"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR"
    And the Disruption Type should be "Denied Boarding"
    And the Operating Carrier should be "PAL"
    And the Ticketing Carrier should be "AC"
    And the Full Name should be "Antoine Lavoie"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "a***@gmail.com"
    And the Phone should be "+1***678"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: YUL ? MNL (AC 501, on time) ? MNL ? CEB (PAL 205, denied boarding ? rebooked PAL 207)"
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and populated with Disruption Type "Denied Boarding" and Compensation "$900 CAD"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically
    And the eligibility decision should be pre-populated
    And the MSL should be PAL 205
    And the Operating carrier PAL should be clearly displayed
    And the Disruption type Denied Boarding should be clearly displayed
    And the Duplicate Check should have run automatically using baseline data "Antoine Lavoie + TC184 + YUL?MNL?CEB + DB"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the CyberSource result should be "GREEN"
    And the system should have appended the booking record automatically
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent
    And an eligible notification email should have been sent via Adobe
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps
    And Customer Communications should show the notification email
    And the chatbot transcript should be accessible and linked
    And the Attachments tab should be empty
    And the Final Status should be "Resolved"
    And the case should be in read-only mode

PAYMENT VALIDATION
    Given the customer's country of residence is "Canada"
    Then the currency should be set to "CAD"
    And the payment method should be "Interac e-Transfer"
    And the customer has no Aeroplan linked so only Cash should be offered with no AC Wallet option
    And the compensation amount should be "$900 CAD" for APPR Denied Boarding tier for delay 0 to less than 6 hours at destination NOT $400 CAD which is the FD delay tier for 3 to less than 6 hours
    And the APPR Denied Boarding compensation schedule should be $900 for delays 0 to less than 6 hours and $1,800 for delays 6 to less than 9 hours and $2,400 for delays 9 hours or more
    And this test case has a 4-hour delay at destination so $900 applies
    And IDV should be completed via Persona and Persona should return IDV PASS
    And a compensation record should be created in the system
    And a daily batch file should be generated and dispatched to Unifier
    And Unifier acknowledgement should be received
    And the end-of-day report should show status "Pending" and monitor for Cached or Rejected or Expired
    And the 35-day expiry rule should apply
    And the Claims Dashboard Compensation tab should show Amount $900 Currency CAD Method Cash Interac Status Pending or Completed
    And the payment confirmation email and Adobe notification should both reference "Denied Boarding" as the disruption type not "Delay" or "Cancellation"
    And if PAL denied boarding coding Code 97 is missing in a variant run the same behaviour as Sub-Scenario B applies with no automated payment and case routes to agent queue for manual review

Expected Results:
DDS returns FD-APPR-DB-01. Trip Tracer: Promise = 14:00 (original PAL 205 arrival); Rebooked flight PAL 207 arrival = 19:00; Delay at destination = 5hrs; Disruption Type = DENIED BOARDING; MSL = PAL 205 MNL?CEB; Operating Carrier = PAL; Ticketing Carrier = AC; Denied Boarding Reason = Overbooking (if coding present). Compensation: $900 CAD (APPR Denied Boarding, 3�<6hrs delay at destination). CyberSource: GREEN ? auto-approved. CRITICAL: DDS must correctly identify DENIED BOARDING as the disruption type (not delay or cancellation). CRITICAL: If PAL denied boarding coding is missing ? case must route to agent queue (same behaviour as TC_016 Scenario B). CRITICAL: Denied boarding compensation tier ($900) is different from delay compensation tier ($400) � verify correct amount.