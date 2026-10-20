Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
  "Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto was cancelled because the ground handling team had to do a security check on the aircraft, and I was moved to a renumbered flight. It was scheduled to leave at the same time as my original flight, but I arrived 7 hours later than originally scheduled. I'd like to check if I'm eligible for compensation."
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Dominique Arsenault"
Then the chatbot responds: "Thanks, Dominique! And, what is your booking reference number?"
And the user provides "PNR: TC082"
Then the chatbot searches Trip Tracer for PNR: TC082
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details, linked Aeroplan profile) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options: Email: d***@gmail.com | Phone: +1***890
And the user selects "Email: d***@gmail.com"
Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "629184"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds: "Your verification was successful. Let's proceed to the next step."

GROUP BOOKING CHECK:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
And system proceeds to passenger selection

PASSENGER SELECTION (GenUC-06):
Then the chatbot asks: "How many people are on your claim?"
And the chatbot displays: "I found 1 passenger on this booking: Dominique Arsenault (Adult - Aeroplan Member). Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
  "I found the following journey:
   Original Flight: AC 435 � CANCELLED (HDLG � ACS)
   Reprotected Flight: AC 445 (Renumbered)
   Route: Montreal (YUL) ? Toronto (YYZ)
   Date: May 10, 2026
   Scheduled Departure: 08:00 (Same as original scheduled departure)
   Original Promised Arrival: 10:00
   Actual Arrival: 17:00 (7 hours late)
   Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the system calculates: Arrival May 10, 2026; current date June 15, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption
And the system calculates: Disruption May 10, 2026; filing June 15, 2026 ? 36 days ? within 366 days ? PROCEED

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS identifies MSL = AC 435 YUL?YYZ (cancelled leg)
And DDS checks the cancellation code on MSL ? HDLG (ACS) ? used for controllability (no fallback needed)
And DDS classifies HDLG (ACS) as WITHIN CARRIER CONTROL ? CONTROLLABLE (ACS ground handling security check)
And DDS detects INVOL reprotection: AC 435 ? renumbered AC 445 YUL?YYZ
And DDS confirms AC 445 scheduled departure 08:00 = original scheduled departure 08:00
And DDS calculates delay = 17:00 (actual arrival on AC 445) ? 10:00 (original promise on AC 435) = 7 hours ? band 6 to <9 hours ? Tier 2
And DDS validates Aeroplan Basic Member status as linked and in good standing
And DDS sets eligibility = CAD 700 Cash / CAD 840 AC Wallet
And DDS returns ELIGIBLE (APPR Tier 2) and sends results to Trip Tracer UI

TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC082
? Promised Itinerary - Flight: AC 435, Route: YUL ? YYZ, Scheduled Departure: 08:00, Scheduled Arrival: 10:00 (CANCELLED)
? Current Itinerary - Flight: AC 445 (Renumbered), Route: YUL ? YYZ, Status: ARRIVED, Scheduled Departure: 08:00 (SAME), Actual Arrival: 17:00
? History - Change 1: INVOL � AC 435 YUL?YYZ cancelled (HDLG � ACS). Customer reprotected onto renumbered flight AC 445 YUL?YYZ
? Departure Check: Scheduled departure matches original (08:00)
? Delay Calculation: Original promised arrival = 10:00; Actual arrival on AC 445 = 17:00; Delay = 7 hrs ? DELAY_6_TO_LT_9_HOURS
? Regime: APPR (1 regime)
? MSL FLIGHT: AC 435 � YUL ? YYZ � Cancellation Code: HDLG (ACS) � "Cancelled due to security check � ACS ground handling"
? Fallback: FALSE (cancellation code available)
? Rebooked Flight: AC 445 � YUL ? YYZ (Renumbered)
? APPR causal category: Within carrier control ? CONTROLLABLE
? Delay: +7H 00M � CONTROLLABLE (HDLG � ACS)
? Aeroplan: 9876543210 (Basic Member � linked)
Flight Compensation:
? MS DOMINIQUE ARSENAULT | ELIGIBLE | DELAY_6_TO_LT_9_HOURS | CAD 700.00 Cash / CAD 840.00 AC Wallet (+20%) | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment

ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
  "I've checked your flight details, and it looks like your original flight AC 435 from Montreal (YUL) to Toronto (YYZ) was cancelled because of a security check by our ground handling team, and you were reprotected on renumbered flight AC 445. Although it was scheduled to depart at the same time, your actual arrival was 7 hours later than originally scheduled. Based on the Air Passenger Protection Regulations (APPR), you are eligible for compensation for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."

CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks: "Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada"
Then the system determines: Country = Canada ? Currency = CAD

CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (9876543210, Basic Member)
Then the chatbot checks: Aeroplan account in good standing? ? YES
Then the chatbot offers BOTH options:
  "Since you are an Aeroplan member, you can choose to receive:
   Cash: CAD 700 will be sent via Interac e-Transfer and takes 5 to 10 business days to process.
   AC Wallet: CAD 840 (including a 20% bonus) will be added to your AC Wallet immediately and has no expiry.
   How would you like to receive your funds?"
And the user selects "Cash"
Then the system determines: Cash selected ? Payment method = Interac e-Transfer (Canada)

PAYMENT METHOD � INTERAC (FD-07):
Then the chatbot responds:
  "Your payment will be made through Interac e-Transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information. Would you like to use d***@gmail.com? Please note that only one email address can be used for this compensation/reimbursement and it can't be changed once confirmed."
And the user confirms "Yes, use this email"
Then the chatbot does NOT ask for bank account, card, transit or institution numbers
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
   Deposit Amount: CAD 700
   Payment Method: Interac e-Transfer (d***@gmail.com)
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
And an eligible notification email is sent to d***@gmail.com
And the email contains: Case Reference, compensation amount (CAD 700 Cash � Interac e-Transfer), regulation (APPR), flight details (AC 435 ? renumbered AC 445 YUL?YYZ), disruption reason (Cancellation � HDLG (ACS) security check), next steps, tracking link

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No]
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
  Given the case has been created for claimant "Dominique Arsenault" with PNR "TC082"
  Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
  And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
  And the Case Status should be "In Review" or "Done"
  And the Created date and Last Updated date should be populated
  And the SLA countdown should be tracking correctly
  And the Team assignment should be correct
  And no banners should be displayed for identified and authenticated Auth Flow 1 user
  And the Decision Assist panel should NOT be greyed out
  And the Claimant Name should be "Dominique Arsenault"
  And the Claimant Type should be "Adult"
  And the Authentication should be "Pass"
  And the PNR should be "TC082"
  And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated
  And the Regime should be "APPR"
  And the Full Name should be "Dominique Arsenault"
  And the Tags should include "Claimant" and "Adult"
  And the Email should be "d***@gmail.com"
  And the Phone should be "+1***890"
  And the Address and Profile ID should be populated
  And the Aeroplan should be "9876543210" linked and in good standing (Basic Member)
  And the Tier Status should be "Basic / Member"
  And the Journey should show "Bound 1: YUL ? YYZ" (original AC 435 cancelled; reprotected on renumbered AC 445) with claim filed for this flight
  And the Disruption Code should show "Cancellation Code HDLG (ACS) � security check � Controllable"
  And the Ancillary Fee section should be present with no expected ancillary fees
  And the Eligibility and Compensation section should show "CAD 700 (Cash � Interac e-Transfer)"
  And the AC Wallet option (CAD 840) should be visible as offered but NOT selected
  And the Decision Assist Panel should auto-appear for FD topic
  And DDS should have run automatically with no agent action needed
  And the eligibility decision should be pre-populated as "ELIGIBLE" under APPR Tier 2 (renumbered AC 445, same departure 08:00, arrival 17:00 = 7h delay, HDLG (ACS) controllable)
  And the Duplicate Check should have run automatically using baseline data "Dominique Arsenault + TC082 + YUL?YYZ + FD"
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
  And the customer has Aeroplan "9876543210" linked with Basic Member status in good standing
  And both options should have been offered: Cash (CAD 700 Interac) AND AC Wallet (CAD 840 with 20% top-up)
  And the customer selected "Cash" ? Payment method = Interac e-Transfer
  And AC Wallet was offered but NOT selected ? AC Wallet payout NOT dispatched
  And only the Interac email "d***@gmail.com" should be collected (no bank, card, transit or institution numbers)
  And the compensation amount should be "CAD 700" for Tier 2 delay of 6 to less than 9 hours
  And exactly one compensation record should be created in the backend with GL account and cost center
  And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team
  And Cash should be dispatched to Unifier
  And Unifier should send an acknowledgement back
  And the end-of-day report should be received from Interac
  And the status should be "Pending" transitioning to "Cashed" or "Rejected" or "Expired"
  And if the payment is unclaimed after 35 days the status should be set to "Expired"
  And the Claims Dashboard Compensation tab should show "CAD 700" Cash via Interac
  And the status should be updated via talkback

Expected Results: Trip Tracer:

Promise: 10:00 at YYZ (AC 435, CANCELLED).

Actual: 17:00 at YYZ (renumbered AC 445). Scheduled departure was 08:00, the same as the original.

Delay: 7 hours (17:00 ? 10:00).

Cause: MSL = AC 435. Cancellation code HDLG (ACS), controllable. Fallback = FALSE. APPR Tier 2.

The Basic Aeroplan member (9876543210) is offered both Cash (CAD 700) and AC Wallet (CAD 840). The customer picks Cash, and CAD 700 is paid by Interac to d***@gmail.com. CyberSource GREEN, Persona PASS. Change history: INVOL, AC 435 cancelled (HDLG � ACS), customer moved to renumbered AC 445.