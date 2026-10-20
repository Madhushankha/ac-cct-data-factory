PART A � INITIAL CLAIM (CHATBOT):
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01) and the user selects "English"
Then the privacy alert is displayed
And the user says "My flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if I'm eligible for compensation"
When the chatbot identifies flight disruption intent
Then third-party check ? NO, and the legal disclaimer is shown and accepted
IDENTIFICATION (GenUC-01): "Mathieu Roy" + PNR "PK004" ? Trip Tracer PNR FOUND (Auth Flow 1)
AUTHENTICATION (GenUC-05): Email m***@gmail.com ? OTP "284615" ? CORRECT (attempt 1 of 5)
GROUP BOOKING / PASSENGER SELECTION (GenUC-06): group identifier NOT PRESENT; 1 passenger confirmed
JOURNEY SELECTION (GenUC-08): AC 412, YUL ? YYZ, July 20, 2026, Arrival Delay 7 hours ? "Yes"
CHECKS: single leg; no duplicate; more than 72 hours; within 366 days ? PROCEED
DDS: APPR; Code 96 Controllable; 420 min; ELIGIBLE; FD-APPR-EL-02; CAD 700
TRIP TRACER UI VALIDATION (PK004):
? Promised: AC 412, YUL ? YYZ, 12:00
? Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M
? Regime: APPR (1 regime)
? MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE
? MR MATHIEU ROY | ELIGIBLE | DELAY_6_TO_LT_9_HOURS | CAD 700.00 Cash / CAD 840.00 AC Wallet
CYBERSOURCE (GLOB-05): GREEN
ELIGIBLE RESULT (FD-05a): APPR eligible message for AC 412
CUSTOMER DROPS OFF: closes the chat at "In which country will your reimbursement be deposited?"
Then the case is created as ELIGIBLE, CAD 700, with no payment instruction, and is routed to the queue

PART B � OWNER AGENT PARKS THE CASE (AUG 1):
Given Sarah Martin clicks "Get Next Case" ? status Assigned
And she opens it within 10 minutes ? status In Progress
When she confirms Decision Assist (ELIGIBLE, FD-APPR-EL-02, CAD 700)
And sends "Decision Rendered � Action Required to Accept Compensation" with the secure link to m***@gmail.com
And adds an internal note "Awaiting customer payout action"
And selects "Park Case" in the Case Actions panel
Then the status becomes "Parked" (Awaiting Customer Info � Compensation)
And the case appears in Sarah's Incomplete / Parked Cases widget
And the assigned agent = Sarah Martin

PART C � SUPERVISOR SETS OWNER TO ON LEAVE (AUG 12, 09:00):
Given PK004 is Parked and owned by Sarah Martin
When supervisor Nadia Bouchard sets Sarah's profile to "On Leave" with start Aug 12 and end Aug 26
Then the pre-leave sweep runs straight away
And PK004 disappears from Sarah's Incomplete / Parked Cases widget
And Sarah's ownership is removed (assigned agent = blank)
And the case status changes to "To Be Assigned"
And the case shows in the global backlog
And the original creation date (Jul 28), the Action Required email, Sarah's internal note and all audit entries are kept
And Decision Assist still shows ELIGIBLE, FD-APPR-EL-02, CAD 700
And the secure payment link stays valid (within 30 days)
And the Audit Log records: agent set On Leave (by Nadia), ownership removed (system sweep), Parked ? To Be Assigned

PART D � CUSTOMER REPLIES WHILE OWNER IS ON LEAVE (AUG 14, 10:00):
Given PK004 is "To Be Assigned" with no owner
When the customer replies to the Action Required email: "Hi, I'd like to receive my compensation, what do I need to do next?"
Then the reply is saved in Customer Communications
And the case stays in the global backlog, ready for the next available agent
And the case is NOT sent to Sarah's workspace
And no "?? UPDATE RECEIVED" item appears for Sarah
And the case is NOT closed, NOT made an appeal, and no new case is created
And the Audit Log records: customer reply received (case unassigned, owner on leave)

PART E � AWAY AGENT CANNOT PULL (AUG 14, 10:10):
Given Julie Tremblay's status is "Break / Lunch"
Then "Get Next Case" is blocked for Julie
And PK004 is NOT given to Julie

PART F � NEXT AVAILABLE AGENT GETS THE CASE (AUG 14, 10:15):
Given Marc Dubois is Available and qualified for FD cases
When Marc clicks "Get Next Case"
Then PK004 is given to Marc
And the status becomes "Assigned"
And the assigned agent = Marc Dubois
When Marc opens the case within 10 minutes
Then the status becomes "In Progress"
And Marc sees the full history: DDS decision, Action Required email, Sarah's note and the customer's reply
And the 24-hour In Progress clock starts

PART G � NEXT AGENT HANDLES THE REPLY:
When Marc reviews the reply
Then he confirms the decision is unchanged (ELIGIBLE, CAD 700, no override)
And he replies to the customer with the next step (use the secure link)
And he adds an internal note: case reassigned from Sarah Martin (On Leave), customer reply handled

PART H � CUSTOMER COMPLETES PAYOUT:
Given the customer opens the secure link
Then country = Canada ? CAD
And Basic Aeroplan is found ? both options offered: Cash CAD 700 (Interac, 5 to 10 business days) or AC Wallet CAD 840 (20% bonus)
And the customer selects "Cash"
And only the Interac email m***@gmail.com is confirmed
And Persona IDV ? PASS
And the claim is submitted ? one CAD 700 compensation record is created
And the eligible notification email is sent via Adobe (Case Reference, CAD 700, Interac, APPR, AC 412, Code 96)
And Marc resolves the case

PART I � OWNER RETURNS FROM LEAVE (AUG 27):
Given Sarah's leave has ended and she signs in
Then PK004 does NOT appear in her Parked or Assigned Cases lists
And the case owner stays Marc Dubois

Claims Dashboard Gherkin:
Given case "PK004" for claimant "Mathieu Roy" is "Parked" and owned by agent "Sarah Martin"
When a supervisor sets Sarah's profile to "On Leave" from Aug 12 to Aug 26, 2026
Then PK004 should disappear from Sarah's "Incomplete / Parked Cases" widget straight away
And the assigned agent should be removed
And the case status should change to "To Be Assigned"
And the original creation date, notes and audit entries should be kept
When the customer replies on Aug 14, 2026
Then the reply should be shown in Customer Communications
And the case should stay "To Be Assigned" in the global backlog
And no "?? UPDATE RECEIVED" item should appear in Sarah's workspace
And an agent in "Break / Lunch" should NOT be able to pull the case
When Available agent "Marc Dubois" clicks "Get Next Case"
Then PK004 should be assigned to Marc with status "Assigned"
And if Marc opens it within 10 minutes the status should change to "In Progress"
And the Case ID should not change
And no "Appeal Pending" or "Case Closed" banner should be shown
And the Topic/Sub-topic should be "Travel Disruptions � Delay"
And the Claimant should be "Mathieu Roy", Adult, Authentication "Pass"
And the PNR should be "PK004" with Creation Date, Journey ID, Booking Source and Office ID populated
And the Regime should be "APPR"
And the Aeroplan should be "9876543210", Tier "Basic / Member"
And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 96)
And Decision Assist should show ELIGIBLE, FD-APPR-EL-02, CAD 700 and not be greyed out
And the Duplicate Check should show "No duplicate found"
And CyberSource should be "GREEN"
And the Audit Log should record in order: created, Assigned (Sarah), In Progress, Action Required sent, Parked, On Leave set, ownership removed, To Be Assigned, customer reply, Assigned (Marc), In Progress, payout, Resolved, with timestamps and before/after values
And the Final Status should be "Resolved" and read-only
And when Sarah returns from leave, PK004 should not appear in her workspace

Payment Validation Gherkin:
Given the case is ELIGIBLE, CAD 700 and was reassigned because the owner went on leave
Then no compensation record should exist before the customer completes the secure link
When the customer completes the secure link
Then country should be "Canada" and currency "CAD"
And both Cash (CAD 700) and AC Wallet (CAD 840) should be offered
And the customer selects "Cash" ? Interac e-Transfer
And only the email "m***@gmail.com" should be collected
And Persona IDV should PASS
And exactly one CAD 700 compensation record should be created
And it should be picked up by the evening batch and sent to Unifier (manual trigger in UAT)
And Unifier should acknowledge
And Interac status should move Pending ? Cached / Rejected / Expired, with Expired after 35 days unclaimed
And the Compensation tab should show CAD 700, Cash � Interac, status via talkback

Expected Results:
DDS FD-APPR-EL-02, CAD 700. When the owner is set to On Leave, the parked case is removed from her straight away and returns to "To Be Assigned" with all history kept. The customer's reply is added to the unowned case in the queue. The next Available agent gets it (Assigned ? In Progress within 10 minutes) and completes it. Away agents can't pull it, and it doesn't go back to the original agent when she returns. The customer is paid CAD 700 Cash via Interac (email only), with one compensation record.