PART A � INITIAL CLAIM (CHATBOT):
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01): "Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects "English"
Then the privacy alert is displayed
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto was delayed about 7 hours because the crew was late, I'd like to check if I'm eligible for compensation"
When the chatbot identifies flight disruption intent
Then the chatbot checks third-party submission ? NO
Then the chatbot shows the legal disclaimer and the user agrees to start
IDENTIFICATION (GenUC-01): user provides "Julien Gagnon" and PNR "PK008" ? Trip Tracer returns PNR FOUND (Auth Flow 1)
AUTHENTICATION (GenUC-05): user selects Email j***@gmail.com ? enters OTP "552190" ? CORRECT (attempt 1 of 5) ? "Your verification was successful. Let's proceed to the next step."
GROUP BOOKING CHECK: group identifier NOT PRESENT
PASSENGER SELECTION (GenUC-06): "I found 1 passenger on this booking: Julien Gagnon (Adult - Aeroplan Member). Is this who you'd like to include?" ? user "Yes" ? PAX count 1 ? PROCEED
JOURNEY SELECTION (GenUC-08): AC 412, YUL ? YYZ, July 20, 2026, Arrival Delay 7 hours ? user "Yes"
CHECKS: single leg ? skip GenUC-18; duplicate check ? none; 72-hour check ? PROCEED; APPR 366-day limit ? 8 days ? PROCEED
DDS EVALUATION:
And DDS checks the cancellation code on MSL ? NONE
And DDS checks the first arrival delay code on MSL ? 63 (FT) ? no fallback needed
And DDS classifies 63 (FT) as WITHIN CARRIER CONTROL ? CONTROLLABLE
And DDS calculates 420 min ? 6 to under 9 hrs ? Tier 2
And DDS returns ELIGIBLE, FD-APPR-EL-02, CAD 700
TRIP TRACER UI VALIDATION (PNR PK008):
? Promised: AC 412, YUL ? YYZ, Scheduled Arrival 12:00
? Current: AC 412, ARRIVED LATE, 12:00 ? 19:00, Delay +7H 00M
? Regime: APPR (1 regime)
? MSL: AC 412 � YUL ? YYZ � 63 (FT) "Late crew boarding or departure procedures"
? Cancellation code: NONE ; Fallback: FALSE
? Delay: +7H 00M � CONTROLLABLE
? Aeroplan: 9876543210 (Basic � linked)
? MR JULIEN GAGNON | ELIGIBLE | DELAY_6_TO_LT_9_HOURS | CAD 700.00 Cash / CAD 840.00 AC Wallet | [expiry date]
CYBERSOURCE (GLOB-05): GREEN
ELIGIBLE RESULT (FD-05a): chatbot shows the APPR eligible message for AC 412, about 7 hours
CUSTOMER DROPS OFF: at the country of residence / payment step, the customer closes the chat without choosing a payout or completing IDV
Then the case is created with DDS = ELIGIBLE, CAD 700, and no payment instruction
And the case is routed to the agent queue to complete payout

PART B � AGENT SENDS ACTION REQUIRED AND PARKS (DAY 0 = AUG 1):
Given the agent pulls the case from My Activities (Assigned ? In Progress)
When the agent reviews Decision Assist (ELIGIBLE, FD-APPR-EL-02, CAD 700) and confirms the assessment
And the agent sends "Decision Rendered � Action Required to Accept Compensation" with the secure deep link for IDV/payment
Then the case status becomes "Awaiting Customer Info (Compensation)"
And the agent parks the case
And the "Parked" banner is displayed
And the 30-day customer response window starts (Aug 1 ? Aug 31)
And the Audit Log records the notification, the park action, the date and the agent

PART C � NO RESPONSE WITHIN 30 DAYS (AUG 31):
Given no customer response is received by the end of day 30
Then the case is closed for no response
And the Parked banner is removed
And the "Case Closed" banner is displayed
And the secure payment link can no longer be used
And no compensation record exists
And the Audit Log records the closure reason (no customer response within 30 days)

PART D � CUSTOMER REPLIES ON DAY 35 (SEP 5):
Given the customer comes back through the chatbot quoting the case reference, 35 days after the park date
Then the system recognises that the reply is outside the 30-day window
And the system does NOT treat it as a normal "Customer Response" on an open case
And the system does NOT create a new separate FD case for the same passenger and journey
And the original case is reopened with case type / source = Appeal
And the "Appeal Pending" banner is displayed
And the case status is "Appeal Review" (reopened)
And the customer's reply is attached to Customer Communications
And the case is routed to the appeal-handling queue / agent
And the case history from before the reopen is kept under the same case ID
And the SLA restarts for appeal handling

PART E � AGENT HANDLES THE APPEAL:
Given the agent opens the reopened case from My Activities
When the agent reviews the original decision, notification, Trip Tracer, coding and prior payments
Then the agent confirms there is no prior payment for this passenger and journey
And the agent confirms Code 63 and the 7h delay are unchanged in Trip Tracer
And the agent confirms the APPR filing limit is still met (claim filed Jul 28, 2026, within 366 days)
And the agent keeps the decision as ELIGIBLE, CAD 700 (no override needed)
And the agent records an internal note: late customer reply handled as appeal, decision upheld as eligible
And the agent sends "Decision Rendered � Action Required" again with a new secure link

PART F � CUSTOMER COMPLETES PAYOUT:
Given the customer opens the new secure link
Then country of residence = Canada ? Currency = CAD
And Aeroplan is checked: Basic Member, good standing
And both options are offered: Cash CAD 700 via Interac e-Transfer, or AC Wallet CAD 840 (20% bonus)
And the customer selects "Cash"
And only the Interac email (j***@gmail.com) is confirmed; no other payment details are collected
And Persona IDV runs ? PASS
And the claim is submitted ? compensation record CAD 700 is created
And an eligible notification email is sent via Adobe (Case Reference, CAD 700, Interac, APPR, AC 412 YUL ? YYZ, Code 63)

CLAIMS DASHBOARD VALIDATION
Given case "PK008" for claimant "Julien Gagnon" was parked on Aug 1, 2026 awaiting customer compensation action
And no customer response was received within 30 days
Then the case should have been closed for no response on Aug 31, 2026
When the customer replies on Sep 5, 2026
Then the same case should be reopened (no new case ID)
And the case type / source should show "Appeal"
And the "Appeal Pending" banner should be displayed
And the "Customer Response" banner should NOT be shown as a normal in-window response
And the status should be "Appeal Review" / "Reopened"
And the Topic/Sub-topic should remain "Travel Disruptions � Delay"
And the Claimant Name should be "Julien Gagnon", Claimant Type "Adult", Authentication "Pass"
And the PNR should be "PK008" with PNR Creation Date, Journey ID, Booking Source and Booking Office ID populated
And the Regime should be "APPR"
And the Aeroplan should be "9876543210" linked, Tier Status "Basic / Member"
And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 63)
And the Decision Assist panel should show ELIGIBLE, FD-APPR-EL-02, CAD 700
And the Duplicate Check should show no separate duplicate case created by the late reply
And the CyberSource result should be "GREEN"
And the Audit Log should record in order: case created, Action Required sent, parked, 30-day window expired, closed, customer late reply, reopened as appeal, appeal decision upheld, Action Required re-sent, payout completed
And Customer Communications should show both Action Required emails, the customer's late reply and the eligible notification
And the chatbot transcripts should be linked
And the Final Status should be "Resolved" after payment
And the case should be read-only after resolution

PAYMENT VALIDATION
Given the case was closed with no payment instruction
Then no compensation record should exist before the appeal
When the appeal is upheld and the customer completes the new secure link
Then country of residence should be "Canada" and currency "CAD"
And both Cash (CAD 700) and AC Wallet (CAD 840) should be offered
And the customer selects "Cash" ? Interac e-Transfer
And only the email "j***@gmail.com" should be collected
And exactly one compensation record of CAD 700 should be created
And it should be picked up by the daily evening batch file and dispatched to Unifier
And Unifier should acknowledge
And the Interac end-of-day status should move Pending ? Cashed / Rejected / Expired
And an unclaimed Interac payment should expire after 35 days
And the Compensation tab should show CAD 700, Cash � Interac, status updated via talkback

Expected Results: DDS returns FD-APPR-EL-02, CAD 700 (APPR, Code 63 controllable, 7h). The case parks, then closes after 30 days with no response. The late reply on day 35 reopens the same case as an Appeal (Appeal Pending, Appeal Review). It isn't a new case and isn't a normal customer response. The appeal is upheld as Eligible, and the customer is paid CAD 700 cash by Interac (email only). There's one compensation record and a full audit trail.