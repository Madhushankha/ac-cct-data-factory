Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
  "Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto was delayed because the plane arrived late from its previous flight, and I was rebooked to a flight landing at Hamilton instead. I arrived 5 hours later than my original flight was supposed to land. I'd like to check if I'm eligible for compensation"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Isabelle C�t�"
Then the chatbot responds: "Thanks, Isabelle! And, what is your booking reference number?"
And the user provides "PNR: TC077"
Then the chatbot searches Trip Tracer for PNR: TC077
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options: Email: i***@gmail.com | Phone: +1***345
And the user selects "Email: i***@gmail.com"
Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "482917"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds: "Your verification was successful. Let's proceed to the next step."

GROUP BOOKING CHECK:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
And system proceeds to passenger selection

PASSENGER SELECTION (GenUC-06):
Then the chatbot asks: "How many people are on your claim?"
And the chatbot displays: "I found 1 passenger on this booking: Isabelle C�t� (Adult). Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
  "I found the following journey:
   Flight: AC 444
   Route: Montreal (YUL) ? Hamilton (YHM) [Rebooked � original: AC 442 to Toronto YYZ]
   Date: May 15, 2026
   Arrival Delay: 5 hours
   Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the system calculates: Arrival May 15, 2026; current date June 15, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption
And the system calculates: Disruption May 15, 2026; filing June 15, 2026 ? 31 days ? within 366 days ? PROCEED

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS identifies MSL = AC 442 YUL?YYZ (original delayed flight)
And DDS checks the cancellation code on MSL ? NONE
And DDS checks the first arrival delay code on MSL ? NULL (MISSING)
And DDS falls back to the first departure delay code on MSL ? 05 (upline)
And DDS sets Fallback = TRUE
And DDS checks sister city config: YHM ? YYZ ? VALID PAIR ? Sister City = TRUE
And DDS calculates delay = 17:00 (actual at YHM) ? 12:00 (promise at YYZ) = 5 hours ? band 3 to <6 hours
And DDS classifies 05 as WITHIN CARRIER CONTROL ? CONTROLLABLE (Gate 9)
And DDS applies APPR Tier 1 = CAD 400
And DDS returns FD-APPR-EL-10 and sends results to Trip Tracer UI

TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC077
? Promised Itinerary - Flight: AC 442, Route: YUL ? YYZ, Scheduled Arrival: 12:00 at YYZ (DELAYED)
? Current Itinerary - Flight: AC 444, Route: YUL ? YHM (rebooked to sister city), Status: ARRIVED, Actual Arrival: 17:00 at YHM
? History - Change 1: INVOL � AC 442 delayed ? customer accepted rebooking to AC 444 YUL?YHM
? Delay Calculation: 17:00 (YHM) ? 12:00 (YYZ) = 5 hrs ? DELAY_3_TO_LT_6_HOURS
? Regime: APPR (1 regime)
? MSL FLIGHT: AC 442 � YUL ? YYZ
? Cancellation code: NONE
? First arrival delay code: NULL (MISSING)
? First departure delay code: 05 � "Late positioning due to upline (within carrier control)"
? Controllability source = first departure delay code (fallback)
? Fallback: TRUE
? Sister City: TRUE (YHM ? YYZ, confirmed in DDS sister city config)
? APPR causal category: Within carrier control ? CONTROLLABLE
? Delay: +5H 00M � CONTROLLABLE
? DDS outcome code: FD-APPR-EL-10
Flight Compensation:
? MS ISABELLE C�T� | ELIGIBLE | DELAY_3_TO_LT_6_HOURS (SISTER CITY + FALLBACK) | CAD 400.00 | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment

ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
  "I've checked your flight details, and it looks like your original flight from Montreal (YUL) to Toronto (YYZ) was delayed and you were rebooked to Hamilton (YHM), arriving about 5 hours after your original scheduled arrival. Based on the Air Passenger Protection Regulations (APPR), you may be eligible for compensation for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."

CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks: "Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada"
Then the system determines: Country = Canada ? Currency = CAD

CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot checks if the claim is for multiple pax ? No
Then the chatbot responds: "You are entitled to receive a CAD 400 compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency."
And the user provides "Yes"
Then the system checks which payment method is mapped based on country of residence ? Interac (CANADA)

PAYMENT METHOD � INTERAC (FD-07):
Then the chatbot responds:
  "Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information. Would you like to use i***@gmail.com? Please note that only one email address can be used for this compensation/reimbursement and it can't be changed once confirmed."
And the user confirms "Yes, use this email"
Then the chatbot does NOT ask for bank account, card or any other payment details
Then the system checks that IDV is not completed

IDENTITY VERIFICATION � PERSONA (FD-07b):
Then the chatbot responds: "I must verify your identity for payment security. Please click here to get started"
And the chatbot displays a button "Get verified"
When the user clicks on the button
Then the system checks if IDV at Payment
And the system checks if the user has consented to IDV
And the chatbot sends Persona IDV link to the customer
And the customer completes identity verification via Persona
And Persona returns: IDV PASS
Then the chatbot responds: "Your identity has been verified successfully. Let's proceed to finalize your claim."

CLAIM AMOUNT CONFIRMATION FLOW:
Then the chatbot responds: "Please review your compensation details:
   Deposit Amount: CAD 400
   Payment Method: Interac e-Transfer (i***@gmail.com)
   After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps that will also include the password required to access the secure payment link, which will be sent in a separate email.
   Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user provides: "Yes"

CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe
And an eligible notification email is sent to i***@gmail.com
And the email contains: Case Reference, compensation amount (CAD 400), regulation (APPR), flight details (including sister city note: YHM for YYZ, and fallback code note), disruption reason (controllable � upline, departure delay code 05), next steps, tracking link

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No]
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
  Given the case has been created for claimant "Isabelle C�t�" with PNR "TC077"
  Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
  And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
  And the Case Status should be "In Review" or "Done"
  And the Created date and Last Updated date should be populated
  And the SLA countdown should be tracking correctly
  And the Team assignment should be correct
  And no banners should be displayed for identified and authenticated Auth Flow 1 user
  And the Decision Assist panel should NOT be greyed out
  And the Claimant Name should be "Isabelle C�t�"
  And the Claimant Type should be "Adult"
  And the Authentication should be "Pass"
  And the PNR should be "TC077"
  And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated
  And the Regime should be "APPR"
  And the Full Name should be "Isabelle C�t�"
  And the Tags should include "Claimant" and "Adult"
  And the Email should be "i***@gmail.com"
  And the Phone should be "+1***345"
  And the Address, Profile ID and Tier Status should be populated
  And the Aeroplan should be "Not linked"
  And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight and the rebooked arrival at YHM
  And the Sister City flag should be "TRUE" (YHM ? YYZ)
  And the Fallback flag should be "TRUE" (arrival code NULL, departure code 05)
  And the Ancillary Fee section should be present with no expected ancillary fees
  And the Eligibility and Compensation section should show "ELIGIBLE � CAD 400 (Tier 1, 3 to <6 hrs, Controllable, Departure Code 05 fallback)"
  And the Decision Assist Panel should auto-appear for FD topic
  And DDS should have run automatically with no agent action needed
  And the DDS outcome should be "FD-APPR-EL-10"
  And the eligibility decision should be pre-populated as "ELIGIBLE" due to controllable departure delay Code 05 (upline) used as fallback because no arrival delay code was available
  And the Duplicate Check should have run automatically using baseline data "Isabelle C�t� + TC077 + YUL?YYZ + FD"
  And the result should be "No duplicate found"
  And no Duplicate Warning Banner should be displayed
  And the Related Cases tab should show no related cases
  And the CyberSource result should be "GREEN"
  And the case should have proceeded automatically and not be parked in Fraud Queue
  And the Persona IDV result should be "PASS"
  And the system should have appended the booking record automatically for identified and authenticated user
  And Trip Tracer poll should NOT be required
  And the agent should have used pull case from My Activities
  And the case status should have transitioned from "Assigned" to "In Progress"
  And a case acknowledgement notification should have been sent
  And an eligible notification email should have been sent via Adobe
  And the Agent Notes section should be accessible
  And the Audit Log should record all actions with timestamps and before/after values
  And Customer Communications should show the notification email chronologically
  And the chatbot transcript should be accessible and linked to the case
  And the Attachments tab should be empty
  And the Final Status should be "Resolved"
  And the case should be in read-only mode with no editable Decision Assist fields
  And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
  Given the customer's country of residence is "Canada"
  Then the currency should be set to "CAD"
  And the payment method should be "Interac e-Transfer"
  And only the customer's email address should have been collected (no bank, card or other payment details)
  And the customer has no Aeroplan linked so only Cash should be offered
  And the compensation amount should be "CAD 400" for Tier 1 delay of 3 to less than 6 hours
  And a compensation record should be created in the backend with GL account and cost center
  And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team
  And Cash should be dispatched to Unifier
  And Unifier should send an acknowledgement back
  And the end-of-day report should be received from Interac
  And the status should be "Pending" transitioning to "Cashed" or "Rejected" or "Expired"
  And if the payment is unclaimed after 35 days the status should be set to "Expired"
  And the Claims Dashboard Compensation tab should show "CAD 400"
  And the payment method should show "Cash" via "Interac"
  And the status should be updated via talkback

Expected Results: DDS returns FD-APPR-EL-10. Trip Tracer: Promise = 12:00 at YYZ (AC 442, DELAYED); Actual = 17:00 at YHM (AC 444, sister city); Sister City = TRUE (YHM ? YYZ); Delay = 5 hours; MSL = AC 442; cancellation code = NONE; arrival delay code = NULL; departure delay code = 05 (upline, fallback); Fallback = TRUE; Controllable; APPR. Compensation: CAD 400 (Tier 1) by Interac. CyberSource: GREEN. Persona: PASS. Claims Dashboard: Sister City = TRUE; Fallback = TRUE; DDS = FD-APPR-EL-10; Resolved.