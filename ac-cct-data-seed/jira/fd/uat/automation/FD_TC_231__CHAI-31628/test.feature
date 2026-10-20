PART A � INITIAL CLAIM (CHATBOT):
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01) and the user selects "English"
Then the privacy alert is displayed
And the user says "My flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if I'm eligible for compensation"
When the chatbot identifies flight disruption intent
Then third-party check ? NO, and the legal disclaimer is shown and accepted
IDENTIFICATION (GenUC-01): "Laurence Gauthier" + PNR "PK003" ? Trip Tracer PNR FOUND (Auth Flow 1)
AUTHENTICATION (GenUC-05): Email l***@gmail.com ? OTP "903174" ? CORRECT (attempt 1 of 5)
GROUP BOOKING / PASSENGER SELECTION (GenUC-06): group identifier NOT PRESENT; 1 passenger confirmed
JOURNEY SELECTION (GenUC-08): AC 412, YUL ? YYZ, July 20, 2026, Arrival Delay 7 hours ? "Yes"
CHECKS: single leg; no duplicate; more than 72 hours; within 366 days ? PROCEED
DDS: APPR; Code 96 Controllable; 420 min; ELIGIBLE; FD-APPR-EL-02; CAD 700
TRIP TRACER UI VALIDATION (PK003):
? Promised: AC 412, YUL ? YYZ, 12:00
? Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M
? Regime: APPR (1 regime)
? MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE
? MS LAURENCE GAUTHIER | ELIGIBLE | DELAY_6_TO_LT_9_HOURS | CAD 700.00 Cash / CAD 840.00 AC Wallet
CYBERSOURCE (GLOB-05): GREEN
ELIGIBLE RESULT (FD-05a): APPR eligible message for AC 412
CUSTOMER DROPS OFF: closes the chat at "In which country will your reimbursement be deposited?"
Then case CASE-FD-20260728-003 is created as ELIGIBLE, CAD 700, with no payment instruction

PART B � AGENT PARKS THE CASE (AUG 1):
Given Sarah Martin clicks "Get Next Case" ? Assigned ? opens within 10 minutes ? In Progress
When she confirms Decision Assist (ELIGIBLE, FD-APPR-EL-02, CAD 700)
And sends "Decision Rendered � Action Required to Accept Compensation" with the secure link
And selects "Park Case"
Then the status becomes "Parked" (Awaiting Customer Info � Compensation)
And the case is in Sarah's Incomplete / Parked Cases widget

PART C � CUSTOMER TRIES TO APPEAL THROUGH THE CHATBOT (AUG 12, 10:00):
Given the case is Parked and not Closed
When the customer opens the chatbot, selects English and says "I want to appeal my case CASE-FD-20260728-003. I also had to pay for a hotel that night and I don't agree with the amount"
And completes identification and OTP authentication
And uploads "hotel_receipt.pdf"
Then the system finds the existing case CASE-FD-20260728-003
And the system checks the case status ? Parked (not Closed)
And the appeal is NOT accepted (BR-4)
And the chatbot tells the customer the case is still open, that an appeal can only be made after a decision is closed, and that their message and document have been added to the case for the agent to review
And no appeal reference or "Appeal received" confirmation is given
And the chatbot does not start a new FD claim for the same passenger and journey

PART D � SYSTEM HANDLES IT AS A CASE UPDATE:
Then the customer's message and hotel_receipt.pdf are added to the existing case (Customer Communications and Attachments)
And the case status changes Parked ? "Update Pending Action"
And the case moves to Sarah's Assigned Cases list with "?? UPDATE RECEIVED"
And the assigned agent stays Sarah Martin
And the case does NOT change to "Re-opened"
And no "Re-opened due to appeal" flag or Appeal Pending banner is shown
And the appeal counter on the case stays 0
And the case does NOT go to "To Be Assigned" and is NOT given to Marc Dubois
And no "Appeal received" notification is sent
And the Audit Log records: chatbot appeal attempt rejected (case not Closed), update added, Parked ? Update Pending Action, with actor, timestamp and channel

PART E � OWNER AGENT HANDLES THE UPDATE:
Given Sarah is Available
When she clicks the case row
Then the status changes to "In Progress"
And she can see the new message and the receipt separately from the original decision
And she confirms the flight disruption decision is unchanged (ELIGIBLE, CAD 700, no override)
And she tells the customer that the hotel expense can't be added to this APPR compensation payout. She gives the next step for expense reimbursement according to the current process
And she tells the customer to use the secure link to complete payout
And she adds an internal note: appeal attempt on a parked case, handled as an update

PART F � CUSTOMER COMPLETES PAYOUT:
Given the customer opens the secure link
Then country = Canada ? CAD
And Basic Aeroplan is found ? both options offered: Cash CAD 700 (Interac, 5 to 10 business days) or AC Wallet CAD 840 (20% bonus)
And the customer selects "Cash"
And only the Interac email l***@gmail.com is confirmed
And Persona IDV ? PASS
And the claim is submitted ? one CAD 700 compensation record is created
And the eligible notification email is sent via Adobe
And Sarah resolves the case ? status Closed

PART G � AFTER CLOSURE, THE APPEAL IS AVAILABLE (CHECK ONLY):
Given the case is now Closed
Then the case is eligible for appeal intake through the chatbot
And the appeal counter is still 0, so the rejected attempt in Part C did not use up an appeal

Claims Dashboard Gherkin:
Given case "CASE-FD-20260728-003" for claimant "Laurence Gauthier" is "Parked" and owned by "Sarah Martin"
When the customer submits an appeal through the chatbot quoting this case number with a reason and a document
Then the appeal should NOT be accepted because the case is not "Closed"
And the case should NOT change to "Re-opened"
And no new case should be created
And the Case ID should not change
And the message and document should be added to the existing case
And the case status should change to "Update Pending Action"
And the case should appear in Sarah's "Assigned Cases" list with "?? UPDATE RECEIVED"
And the assigned agent should remain "Sarah Martin"
And the case should NOT be in "To Be Assigned" or given to another agent
And no "Appeal Pending" banner or "re-opened due to appeal" flag should be shown
And the appeal counter should remain 0
And no "Appeal received" notification should be sent
When Sarah clicks the case
Then the status should change to "In Progress"
And the new customer information should be clearly visible
And the Topic/Sub-topic should be "Travel Disruptions � Delay"
And the Claimant should be "Laurence Gauthier", Adult, Authentication "Pass"
And the PNR should be "PK003" with Creation Date, Journey ID, Booking Source and Office ID populated
And the Regime should be "APPR"
And the Aeroplan should be "9876543210", Tier "Basic / Member"
And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 96)
And Decision Assist should show ELIGIBLE, FD-APPR-EL-02, CAD 700
And the Duplicate Check should show "No duplicate found"
And CyberSource should be "GREEN"
And the Attachments tab should show "hotel_receipt.pdf"
And the Audit Log should record: created, Parked, appeal attempt rejected (not Closed), update added, Update Pending Action, In Progress, payout, Closed, with actor, timestamp, action type and state change
And the Final Status should be "Closed" and read-only

Payment Validation Gherkin:
Given the appeal attempt was not accepted and the decision is ELIGIBLE, CAD 700
Then no compensation record should exist before the customer completes the secure link
And the uploaded hotel receipt should NOT change the CAD 700 APPR amount
When the customer completes the secure link
Then country should be "Canada" and currency "CAD"
And both Cash (CAD 700) and AC Wallet (CAD 840) should be offered
And the customer selects "Cash" ? Interac e-Transfer
And only the email "l***@gmail.com" should be collected
And Persona IDV should PASS
And exactly one CAD 700 compensation record should be created
And it should be picked up by the evening batch and sent to Unifier (manual trigger in UAT)
And Unifier should acknowledge
And Interac status should move Pending ? Cached / Rejected / Expired, with Expired after 35 days unclaimed
And the Compensation tab should show CAD 700, Cash � Interac, status via talkback

Expected Results:
DDS FD-APPR-EL-02, CAD 700. An appeal on a Parked case is not accepted because only Closed cases can be appealed. There is no Re-opened state, no appeal flag, no appeal count, no Appeal received email, no new case and no reassignment. The customer's message and document are added to the same case, which goes to Update Pending Action with "?? UPDATE RECEIVED" for the same agent. The agent handles the update and the customer is paid CAD 700 Cash via Interac (email only), with one compensation record. The appeal option becomes available only after the case is Closed.