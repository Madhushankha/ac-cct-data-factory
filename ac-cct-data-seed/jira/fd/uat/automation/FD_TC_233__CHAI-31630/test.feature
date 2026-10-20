PART A � INITIAL CLAIM (CHATBOT):
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01) and the user selects "English"
Then the privacy alert is displayed
And the user says "My flight from Montreal to Toronto was delayed about 7 hours, the gate agent said it was the weather. I'd like to check if I'm eligible for compensation"
When the chatbot identifies flight disruption intent
Then third-party check ? NO, and the legal disclaimer is shown and accepted
IDENTIFICATION (GenUC-01): "Nicolas Fortier" + PNR "PK001" ? Trip Tracer PNR FOUND (Auth Flow 1)
AUTHENTICATION (GenUC-05): Email n***@gmail.com ? OTP "164930" ? CORRECT (attempt 1 of 5)
GROUP BOOKING / PASSENGER SELECTION (GenUC-06): group identifier NOT PRESENT; 1 passenger confirmed
JOURNEY SELECTION (GenUC-08): AC 412, YUL ? YYZ, July 20, 2026, Arrival Delay 7 hours ? "Yes"
CHECKS: single leg; no duplicate; more than 72 hours; within 366 days ? PROCEED
DDS: APPR; Code 96 Controllable; 420 min; ELIGIBLE; FD-APPR-EL-02; CAD 700
TRIP TRACER UI VALIDATION (PK001):
? Promised: AC 412, YUL ? YYZ, 12:00
? Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M
? Regime: APPR (1 regime)
? MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE
? MR NICOLAS FORTIER | ELIGIBLE | DELAY_6_TO_LT_9_HOURS | CAD 700.00 Cash / CAD 840.00 AC Wallet
CYBERSOURCE (GLOB-05): GREEN
CUSTOMER DROPS OFF: closes the chat at "In which country will your reimbursement be deposited?"
Then the case is created as ELIGIBLE, CAD 700, with no payment instruction, and the transcript is linked

PART B � AGENT PICKS UP AND FINDS THE CODING QUESTION (AUG 1, 09:45):
Given Sarah Martin is Available and clicks "Get Next Case" ? Assigned
And she opens it within 10 minutes ? In Progress
When she reads the transcript ("the gate agent said it was the weather")
And sees that Trip Tracer shows Code 96 Controllable
Then she does NOT change the flight code or override Decision Assist

PART C � AGENT SENDS NEW RESOURCING AND THE CASE PARKS (AUG 1, 10:00):
When Sarah selects "New Resourcing" in the Case Actions panel (kebab menu)
And sends it to the lead pool with the note: "Customer states weather; Trip Tracer shows Code 96 Operations Control on AC 412 YUL-YYZ Jul 20. Please confirm coding before payout."
Then a resourcing task is created in the lead / manager pool, linked to the case
And the case status changes to "Parked"
And the blue "Case Escalated" alert is shown with context and timestamp
And the case appears in Sarah's Incomplete / Parked Cases widget
And Sarah's active slot is freed and she can pull a new case
And the assigned agent stays Sarah Martin
And no customer notification is sent
And the Audit Log records: New Resourcing, target (lead pool), note, In Progress ? Parked, actor and timestamp

PART D � CASE STAYS SAFE WHILE PARKED (AUG 1 ? AUG 3):
Given the case is Parked for resourcing
Then the 10-minute Assigned timeout and the 24-hour In Progress release do NOT apply
And the case does NOT appear in To Be Assigned
When Marc Dubois clicks "Get Next Case"
Then PK001 is NOT given to him
When Sarah switches to "Break / Lunch" and back to Available
Then the case stays Parked with her

PART E � LEAD REVIEWS AND REPLIES (AUG 3, 14:00):
Given Nadia Bouchard opens the resourcing task from the lead pool
Then she can see the case context, Sarah's note, the transcript and Trip Tracer
When she confirms that Code 96 (Operations Control) is correct and there was no weather code on AC 412
And she enters the resourcing notes: "Coding confirmed Code 96 Operations Control, controllable. Proceed with APPR payout."
And she clicks Submit (return to agent with guidance)
Then the resourcing task is marked complete
And the case ownership stays with Sarah (Nadia does not take ownership)

PART F � CASE RETURNS TO THE SAME AGENT:
Then the case status changes Parked ? "Update Pending Action" straight away
And the case leaves Sarah's Parked widget and appears in her Assigned Cases list
And the case shows "?? UPDATE RECEIVED"
And it does not count against her one-new-case limit
And the assigned agent is still Sarah Martin
And the case does NOT go to To Be Assigned and Marc still can't pull it
And the "Case Escalated" alert is cleared or shows as resolved
And the Case ID does not change
And the Audit Log records: resourcing completed (by Nadia), notes, Parked ? Update Pending Action

PART G � AGENT CONTINUES AND SENDS THE ELIGIBLE NOTICE:
When Sarah clicks the case row
Then the status changes to "In Progress"
And the lead's notes are clearly shown on the case
And she keeps the decision ELIGIBLE, FD-APPR-EL-02, CAD 700 (no override)
And she adds an internal note: coding confirmed by lead, proceeding to payout
When she completes the Advance Case wizard: Step 1 confirm Eligible / CAD 700; Step 2 "Decision Rendered � Action Required to Accept Compensation" (English) with the deep link; Step 3 Advance Case (under threshold, no approval needed)
Then the notification is sent to n***@gmail.com
And the case status becomes "Awaiting Customer Info (Compensation)"

PART H � CUSTOMER COMPLETES PAYOUT:
Given the customer opens the deep link
Then they land straight on the payment step
And country = Canada ? CAD
And Basic Aeroplan is found ? both options offered: Cash CAD 700 (Interac, 5 to 10 business days) or AC Wallet CAD 840 (20% bonus)
And the customer selects "Cash"
And only the Interac email n***@gmail.com is confirmed
And Persona IDV ? PASS
And the customer submits ? one CAD 700 compensation record is created
And the eligible notification email is sent via Adobe
And the case auto-closes when payout completes

Claims Dashboard Gherkin:
Given case "CASE-FD-20260728-001" for claimant "Nicolas Fortier" is "In Progress" with agent "Sarah Martin"
When Sarah selects "New Resourcing" to the lead pool with a coding question
Then a resourcing task should be created in the lead pool and linked to the case
And the case status should be "Parked"
And the "Case Escalated" alert should be displayed with context and timestamp
And the case should be in Sarah's "Incomplete / Parked Cases" widget
And Sarah should be able to pull a new case
And the case should NOT be in "To Be Assigned"
And another Available agent should NOT be able to pull the case
And no customer notification should be sent
When lead "Nadia Bouchard" completes the resourcing notes and submits
Then the case status should change to "Update Pending Action"
And the case should appear in Sarah's "Assigned Cases" list with "?? UPDATE RECEIVED"
And the assigned agent should remain "Sarah Martin"
And the lead's notes should be visible on the case
And the Case ID should not change
When Sarah clicks the case
Then the status should change to "In Progress"
And the Topic/Sub-topic should be "Travel Disruptions � Delay"
And the Claimant should be "Nicolas Fortier", Adult, Authentication "Pass"
And the PNR should be "PK001" with Creation Date, Journey ID, Booking Source and Office ID populated
And the Regime should be "APPR"
And the Aeroplan should be "9876543210", Tier "Basic / Member"
And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 96)
And the flight code should still be 96 and not edited by the agent
And Decision Assist should show ELIGIBLE, FD-APPR-EL-02, CAD 700 and not be greyed out
And the Duplicate Check should show "No duplicate found"
And CyberSource should be "GREEN"
And the Audit Log should record in order: created, Assigned, In Progress, New Resourcing (with note), Parked, lead task opened, resourcing completed, Update Pending Action, In Progress, Action Required sent, Awaiting Customer Info (Compensation), IDV PASS, payout, Closed, with actor, timestamp and before/after values
And Customer Communications should show only the Action Required email and the eligible notification (no customer message during resourcing)
And the Final Status should be "Closed" and read-only

Payment Validation Gherkin:
Given the case was parked for internal resourcing
Then no compensation record should exist while the case is Parked
When the lead confirms the coding and Sarah sends the Action Required notice
And the customer completes the deep link
Then country should be "Canada" and currency "CAD"
And both Cash (CAD 700) and AC Wallet (CAD 840) should be offered
And the customer selects "Cash" ? Interac e-Transfer
And only the email "n***@gmail.com" should be collected
And Persona IDV should PASS
And exactly one CAD 700 compensation record should be created
And it should be picked up by the evening batch and sent to Unifier (manual trigger in UAT)
And Unifier should acknowledge
And Interac status should move Pending ? Cached / Rejected / Expired, with Expired after 35 days unclaimed
And the Compensation tab should show CAD 700, Cash � Interac, status via talkback

Expected Results:
DDS FD-APPR-EL-02, CAD 700. The agent sends New Resourcing: a lead task is created, the case parks and "Case Escalated" is shown. The agent's slot is freed, the case stays hers and no one else can pull it. When the lead submits resourcing notes, the case moves straight to Update Pending Action with "?? UPDATE RECEIVED" in the same agent's Assigned Cases list. The agent opens it (In Progress), keeps the decision and sends Action Required. The customer is paid CAD 700 Cash via Interac (email only), with one compensation record.