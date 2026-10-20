PART A � INITIAL CLAIM (CHATBOT):
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01): "Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects "English"
Then the privacy alert is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if I'm eligible for compensation"
When the chatbot identifies flight disruption intent
Then the chatbot checks third-party submission ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot shows the automated decision-making disclaimer and asks "Would you like to get started?"
And the user confirms "Yes"

IDENTIFICATION (GenUC-01):
Then the chatbot asks for full name ? user provides "Chlo� Lavoie"
Then the chatbot responds: "Thanks, Chlo�! And, what is your booking reference number?" ? user provides "PK006"
Then Trip Tracer returns PNR FOUND (Auth Flow 1)

AUTHENTICATION (GenUC-05):
Then the chatbot offers OTP by Email c***@gmail.com or Phone +1456
And the user selects Email ? enters OTP "418263" ? CORRECT (attempt 1 of 5)
Then the chatbot responds: "Your verification was successful. Let's proceed to the next step."

GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06):
Then group booking identifier = NOT PRESENT
And the chatbot displays: "I found 1 passenger on this booking: Chlo� Lavoie (Adult - Aeroplan Member). Is this who you'd like to include?" ? user "Yes"
Then PAX count = 1 ? 9 or fewer ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot displays: Flight AC 412, Montreal (YUL) ? Toronto (YYZ), July 20, 2026, Arrival Delay 7 hours ? user "Yes"

CHECKS:
Then single leg ? skip GenUC-18
And duplicate check ? NO existing case
And 72-hour check ? more than 72 hours ? PROCEED
And APPR filing limit ? 8 days (within 366 days) ? PROCEED

DDS EVALUATION:
Regime APPR; Code 96 Controllable; 420 min ? 6 to under 9 hrs; ELIGIBLE; FD-APPR-EL-02; CAD 700

TRIP TRACER UI VALIDATION (PNR PK006):
? Promised Itinerary: AC 412, YUL ? YYZ, Scheduled Arrival 12:00
? Current Itinerary: AC 412, Status ARRIVED LATE, 12:00 ? 19:00, Delay +7H 00M
? Regime: APPR (1 regime)
? MSL Flight: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control"
? Delay: +7H 00M � CONTROLLABLE
? Aeroplan: 9876543210 (Basic Member � linked)
? MS CHLO� LAVOIE | ELIGIBLE | DELAY_6_TO_LT_9_HOURS | CAD 700.00 Cash / CAD 840.00 AC Wallet | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05): GREEN LIGHT

ELIGIBLE RESULT (FD-05a):
Then the chatbot displays: "I've checked your flight details, and it looks like flight AC 412 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7 hours. Based on the Air Passenger Protection Regulations (APPR), you may be eligible for compensation for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."

CUSTOMER DROPS OFF:
When the chatbot asks "In which country will your reimbursement be deposited?"
Then the customer closes the chat without answering
And the case is created with DDS = ELIGIBLE, CAD 700, and no payment instruction
And the case is routed to the agent queue to complete payout

PART B � AGENT SENDS ACTION REQUIRED AND PARKS (DAY 0 = AUG 1):
Given the agent pulls the case from My Activities (Assigned ? In Progress)
When the agent reviews Decision Assist (ELIGIBLE, FD-APPR-EL-02, CAD 700) and confirms it
And the agent sends "Decision Rendered � Action Required to Accept Compensation" with the secure IDV/payment link to c@gmail.com
Then the case status becomes "Awaiting Customer Info (Compensation)"
And the agent parks the case
And the "Parked" banner is displayed
And the 30-day customer response window starts (Aug 1 ? Aug 31)
And the case is no longer in the agent's active work list while parked
And the Audit Log records the notification, park action, date and agent

PART C � CUSTOMER REPLIES ON DAY 19 (AUG 20):
Given the customer replies to the Action Required email / case link on Aug 20, 2026
And the reply says "I'd like to receive my compensation, please confirm the next step"
Then the system recognises the reply is within the 30-day window
And the case is unparked automatically
And the "Parked" banner is removed
And the "Customer Response" banner is displayed
And the case status changes to "Assigned"
And the case is assigned back to the same agent who parked it
And the case appears in that agent's My Activities / queue
And the reply is attached to Customer Communications
And the case is NOT closed
And the case is NOT reopened as an Appeal (no "Appeal Pending" banner)
And no new FD case is created for the same passenger and journey
And the original secure link is still valid (window not expired)
And the Audit Log records: customer reply received, unpark (system), status Awaiting Customer Info ? Assigned

PART D � AGENT HANDLES THE RESPONSE:
Given the agent pulls the case from My Activities
Then the status changes Assigned ? In Progress
When the agent reviews the customer reply
Then the agent confirms the decision is unchanged: ELIGIBLE, FD-APPR-EL-02, CAD 700 (no override)
And the agent tells the customer to use the secure link to finish the payment step (or re-sends it if needed)
And the agent records an internal note: customer responded within 30 days, case unparked, proceeding to payout

PART E � CUSTOMER COMPLETES PAYOUT:
Given the customer opens the secure link
Then country of residence = Canada ? Currency = CAD
And the Aeroplan check shows Basic Member, good standing
And both options are offered: "Cash: $700 CAD will be sent via Interac e-Transfer and takes 5 to 10 business days to process." / "AC Wallet: $840 CAD (including a 20% bonus) will be added to your AC Wallet immediately and has no expiry."
And the customer selects "Cash"
And the customer confirms the Interac email c***@gmail.com; no other payment details are collected
And Persona IDV runs ? IDV PASS
And the customer reviews "Deposit Amount: $700 CAD, Payment Method: Interac e-Transfer (c***@gmail.com)" and submits
Then a compensation record for CAD 700 is created
And an eligible notification email is sent via Adobe (Case Reference, CAD 700, Interac e-Transfer, APPR, AC 412 YUL ? YYZ, Code 96)

Claims Dashboard Gherkin:
Given case "PK006" for claimant "Chlo� Lavoie" was parked on Aug 1, 2026 as "Awaiting Customer Info (Compensation)"
When the customer replies on Aug 20, 2026 (within 30 days)
Then the case should be unparked automatically
And the "Parked" banner should be removed
And the "Customer Response" banner should be displayed
And the status should be "Assigned"
And the assignee should be the agent who parked the case
And no "Appeal Pending" banner should be displayed
And the case should keep the same Case ID (no new case)
And the Topic/Sub-topic should be "Travel Disruptions � Delay"
And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
And the Created and Last Updated dates should be populated
And the SLA countdown should be tracking correctly
And the Claimant Name should be "Chlo� Lavoie", Claimant Type "Adult", Authentication "Pass"
And the PNR should be "PK006" with PNR Creation Date, Journey ID, Booking Source and Booking Office ID populated
And the Regime should be "APPR"
And the Tags should include "Claimant" and "Adult"
And the Email should be "c***@gmail.com" and the Phone "+1456"
And the Address should be populated
And the Aeroplan should be "9876543210" linked, Tier Status "Basic / Member"
And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 96)
And the Ancillary Fee section should be present and empty
And the Decision Assist panel should show ELIGIBLE, FD-APPR-EL-02, CAD 700 and should NOT be greyed out
And the Duplicate Check should show "No duplicate found" and no Duplicate Warning Banner
And the Related Cases tab should show no related cases
And the CyberSource result should be "GREEN"
When the agent pulls the case from My Activities
Then the status should change from "Assigned" to "In Progress"
And the Audit Log should record in order: case created, Action Required sent, parked, customer reply, unparked, Assigned, In Progress, payout completed, with timestamps and before/after values
And Customer Communications should show the Action Required email, the customer reply and the eligible notification in date order
And the chatbot transcript should be accessible and linked
And the Attachments tab should be empty
And the Final Status should be "Resolved" after payment
And the case should be read-only after resolution
And the agent should not be able to access Case Search as it is for leads and management only

Payment Validation Gherkin:
Given the case was unparked within 30 days and the decision is ELIGIBLE, CAD 700
Then no compensation record should exist before the customer completes the secure link
When the customer completes the secure link
Then country of residence should be "Canada" and currency "CAD"
And both Cash (CAD 700) and AC Wallet (CAD 840) should be offered
And the customer selects "Cash" ? payment method = Interac e-Transfer
And AC Wallet should NOT be dispatched
And only the email "c@gmail.com" should be collected
And Persona IDV should PASS before payout
And exactly one compensation record of CAD 700 should be created
And it should be picked up by the daily evening batch file and dispatched to Unifier
And in UAT the batch file should be triggered manually with the Unifier team
And Unifier should send an acknowledgement back
And the Interac end-of-day status should move Pending ? Cached / Rejected / Expired
And an unclaimed Interac payment should be set to Expired after 35 days
And the Compensation tab should show CAD 700, Cash � Interac e-Transfer, status updated via talkback

Expected Results:
DDS FD-APPR-EL-02, CAD 700 (APPR, Code 96 Controllable, 7h, Tier 2). The case parks on Aug 1. The customer replies on day 19, inside the 30-day window. The case unparks automatically, shows the Customer Response banner and goes back to Assigned for the same agent. It is not closed, not treated as an appeal and no new case is created. The agent pulls it (In Progress) and the customer is paid CAD 700 Cash via Interac (email only), with one compensation record and a full audit trail.