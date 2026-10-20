PART A � INITIAL CLAIM (CHATBOT):
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01) and the user selects "English"
Then the privacy alert is displayed
And the user says "My flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if I'm eligible for compensation"
When the chatbot identifies flight disruption intent
Then third-party check ? NO, and the legal disclaimer is shown and accepted
IDENTIFICATION (GenUC-01): "�milie Pelletier" + PNR "PK005" ? Trip Tracer PNR FOUND (Auth Flow 1)
AUTHENTICATION (GenUC-05): Email e***@gmail.com ? OTP "735102" ? CORRECT (attempt 1 of 5)
GROUP BOOKING / PASSENGER SELECTION (GenUC-06): group identifier NOT PRESENT; 1 passenger confirmed
JOURNEY SELECTION (GenUC-08): AC 412, YUL ? YYZ, July 20, 2026, Arrival Delay 7 hours ? "Yes"
CHECKS: single leg; no duplicate; more than 72 hours; within 366 days ? PROCEED
DDS: APPR; Code 96 Controllable; 420 min; ELIGIBLE; FD-APPR-EL-02; CAD 700
TRIP TRACER UI VALIDATION (PK005):
? Promised: AC 412, YUL ? YYZ, 12:00
? Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M
? Regime: APPR (1 regime)
? MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE
? MS �MILIE PELLETIER | ELIGIBLE | DELAY_6_TO_LT_9_HOURS | CAD 700.00 Cash / CAD 840.00 AC Wallet
CYBERSOURCE (GLOB-05): GREEN
ELIGIBLE RESULT (FD-05a): APPR eligible message for AC 412
CUSTOMER DROPS OFF: closes the chat at "In which country will your reimbursement be deposited?"
Then the case is created as ELIGIBLE, CAD 700, with no payment instruction, and is routed to the queue

PART B � AGENT PARKS THE CASE (AUG 1):
Given Sarah Martin clicks "Get Next Case" ? status Assigned
And she opens the case within 10 minutes ? status In Progress
When she confirms Decision Assist (ELIGIBLE, FD-APPR-EL-02, CAD 700)
And sends "Decision Rendered � Action Required to Accept Compensation" with the secure link to e***@gmail.com
And selects "Park Case" in the Case Actions panel
Then the status becomes "Parked" (Awaiting Customer Info � Compensation)
And the case appears in Sarah's Incomplete / Parked Cases widget
And Sarah's active case slot is freed
And the assigned agent stays Sarah Martin

PART C � AGENT GOES OFFLINE, NOT ON LEAVE (AUG 10, 18:00):
Given Sarah has no case in Assigned or In Progress
When Sarah clicks "Sign Out"
Then her session ends and she shows as offline
And her profile is NOT set to On Leave
And the case PK005 stays in her Parked list
And the case status stays "Parked"
And the assigned agent stays Sarah Martin
And the case is NOT moved to "To Be Assigned"

PART D � CUSTOMER REPLIES WHILE AGENT IS OFFLINE (AUG 10, 21:00):
Given Sarah is still signed out
When the customer replies to the Action Required email: "Hi, I'd like to receive my compensation, what do I need to do next?"
Then the system changes the status to "Update Pending Action" straight away
And the case moves out of Sarah's Parked list into her Assigned Cases list
And the case shows the "?? UPDATE RECEIVED" tag
And the assigned agent stays Sarah Martin
And the case does NOT go to "To Be Assigned" or the global backlog
And the case status is NOT "Held - Agent Offline" (that status is only for a disconnect with a saved draft)
And the case is NOT closed, NOT made an appeal, and no new case is created
And the reply is saved in Customer Communications
And the Audit Log records: customer reply received, Parked ? Update Pending Action (system), owner unchanged

PART E � OTHER AGENT CANNOT TAKE THE CASE (AUG 10, 21:05):
Given Marc Dubois is Available in the same queue
When Marc clicks "Get Next Case"
Then PK005 is NOT given to Marc
And PK005 does not appear in the unassigned queue

PART F � TIMERS DO NOT RELEASE THE CASE (AUG 10 21:00 ? AUG 11 09:00):
Given the case is "Update Pending Action" and Sarah is still signed out
When 10 minutes pass
Then the 10-minute "Assigned" timeout does NOT return the case to "To Be Assigned"
When 12 hours pass overnight
Then the case is still "Update Pending Action" with Sarah

PART G � AGENT LOGS BACK IN AND HANDLES IT (AUG 11, 09:00):
Given Sarah signs in and sets herself Available
Then PK005 is at the top of her Assigned Cases list with "?? UPDATE RECEIVED"
And this case does not count against her "one new case at a time" limit
When Sarah clicks the case row
Then the status changes to "In Progress"
And she sees the customer's reply
And she confirms the decision is unchanged (ELIGIBLE, CAD 700, no override)
And she replies with the next step (use the secure link) and adds an internal note: customer replied while agent was offline, case kept with owner

PART H � CUSTOMER COMPLETES PAYOUT:
Given the customer opens the secure link
Then country = Canada ? CAD
And Basic Aeroplan is found ? both options offered: Cash CAD 700 (Interac, 5 to 10 business days) or AC Wallet CAD 840 (20% bonus)
And the customer selects "Cash"
And only the Interac email e***@gmail.com is confirmed
And Persona IDV ? PASS
And the claim is submitted ? one CAD 700 compensation record is created
And the eligible notification email is sent via Adobe (Case Reference, CAD 700, Interac, APPR, AC 412, Code 96)

Claims Dashboard Gherkin:
Given case "PK005" for claimant "�milie Pelletier" is "Parked" and owned by agent "Sarah Martin"
And Sarah has signed out and her profile is NOT "On Leave"
When the customer replies on Aug 10, 2026 at 21:00
Then the case status should change to "Update Pending Action"
And the case should move from Sarah's "Incomplete / Parked Cases" to her "Assigned Cases" list
And the "?? UPDATE RECEIVED" tag should be displayed
And the assigned agent should remain "Sarah Martin"
And the case should NOT be in "To Be Assigned"
And the case should NOT be "Held - Agent Offline"
And another Available agent should NOT be able to pull the case
And no "Appeal Pending" or "Case Closed" banner should be shown
And the Case ID should not change
When Sarah signs in and clicks the case
Then the status should change to "In Progress"
And the Topic/Sub-topic should be "Travel Disruptions � Delay"
And the Claimant should be "�milie Pelletier", Adult, Authentication "Pass"
And the PNR should be "PK005" with Creation Date, Journey ID, Booking Source and Office ID populated
And the Regime should be "APPR"
And the Aeroplan should be "9876543210", Tier "Basic / Member"
And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 96)
And Decision Assist should show ELIGIBLE, FD-APPR-EL-02, CAD 700
And the Duplicate Check should show "No duplicate found"
And CyberSource should be "GREEN"
And the Audit Log should record in order: created, Assigned, In Progress, Action Required sent, Parked, agent signed out, customer reply, Update Pending Action, agent signed in, In Progress, payout, Resolved, with timestamps and before/after values
And the case history and notes should be kept
And the Final Status should be "Resolved" and read-only

Payment Validation Gherkin:
Given the case is ELIGIBLE, CAD 700 and was kept with the same agent
Then no compensation record should exist before the customer completes the secure link
When the customer completes the secure link
Then country should be "Canada" and currency "CAD"
And both Cash (CAD 700) and AC Wallet (CAD 840) should be offered
And the customer selects "Cash" ? Interac e-Transfer
And only the email "e***@gmail.com" should be collected
And Persona IDV should PASS
And exactly one CAD 700 compensation record should be created
And it should be picked up by the evening batch and sent to Unifier (manual trigger in UAT)
And Unifier should acknowledge
And Interac status should move Pending ? Cached / Rejected / Expired, with Expired after 35 days unclaimed
And the Compensation tab should show CAD 700, Cash � Interac, status via talkback

Expected Results:
DDS FD-APPR-EL-02, CAD 700. The customer replies while the owner agent is signed out (not On Leave). The case moves to "Update Pending Action" with "?? UPDATE RECEIVED" in the same agent's Assigned Cases list. It does not go to the global queue, cannot be pulled by another agent and is not released by timers. When the agent logs back in and clicks it, it becomes In Progress. The customer is paid CAD 700 Cash via Interac (email only), with one compensation record.