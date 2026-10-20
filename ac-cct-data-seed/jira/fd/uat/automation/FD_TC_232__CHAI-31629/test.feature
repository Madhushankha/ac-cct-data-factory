PART A � INITIAL CLAIM (CHATBOT):
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01) and the user selects "English"
Then the privacy alert is displayed
And the user says "My flight from Montreal to Toronto was delayed about 7 hours, I think I may have been moved to a later flight, I'd like to check if I'm eligible for compensation"
When the chatbot identifies flight disruption intent
Then third-party check ? NO, and the legal disclaimer is shown and accepted
IDENTIFICATION (GenUC-01): "Olivier Bergeron" + PNR "PK002" ? Trip Tracer PNR FOUND (Auth Flow 1)
AUTHENTICATION (GenUC-05): Email o***@gmail.com ? OTP "370528" ? CORRECT (attempt 1 of 5)
GROUP BOOKING / PASSENGER SELECTION (GenUC-06): group identifier NOT PRESENT; 1 passenger confirmed
JOURNEY SELECTION (GenUC-08): AC 412, YUL ? YYZ, July 20, 2026, Arrival Delay 7 hours ? "Yes"
CHECKS: single leg; no duplicate; more than 72 hours; within 366 days ? PROCEED
DDS: APPR; Code 96 Controllable; 420 min; ELIGIBLE; FD-APPR-EL-02; CAD 700
TRIP TRACER UI VALIDATION (PK002):
? Promised: AC 412, YUL ? YYZ, 12:00
? Current: AC 412, ARRIVED LATE, 12:00 ? 19:00, +7H 00M
? Booking changes: None (no VOL / INVOL)
? Regime: APPR (1 regime)
? MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE
? MR OLIVIER BERGERON | ELIGIBLE | DELAY_6_TO_LT_9_HOURS | CAD 700.00 Cash / CAD 840.00 AC Wallet
CYBERSOURCE (GLOB-05): GREEN
CUSTOMER DROPS OFF: closes the chat before payment
Then case CASE-FD-20260728-002 is created as ELIGIBLE, CAD 700, with no payment instruction, and the transcript is linked

PART B � AGENT REQUESTS INFO AND PARKS (AUG 1):
Given Sarah Martin clicks "Get Next Case" ? Assigned ? opens it within 10 minutes ? In Progress
When she reads the transcript and sees "may have been moved to a later flight"
And Trip Tracer shows no booking change
Then she decides to confirm the flight taken before payout
When she triggers "Welcome Back � Additional Details"
And defines the request with a structured question: "Which flight did you travel on? (AC 412 as booked / a different flight)", plus an optional text field for the flight number and date
Then a Welcome Back email with a deep link is sent to o***@gmail.com
And the link shows no readable case or customer data (key only)
And the case status becomes "Awaiting Customer Info"
When Sarah selects "Park Case"
Then the status becomes "Parked"
And the case moves to Sarah's Incomplete / Parked Cases widget
And Sarah's active slot is freed
And the assigned agent stays Sarah Martin
And the Audit Log records: Welcome Back type (Additional Details), question sent, notification sent, Parked, actor and timestamp

PART C � CUSTOMER RETURNS THROUGH THE DEEP LINK (AUG 8, 11:00):
Given the case is Parked
When the customer clicks the deep link
Then the system resolves the key and loads the case context
And Case Services returns "Waiting on customer details"
And the customer lands straight on the Additional Details question
And the customer is NOT asked to repeat greeting, identification, passenger or journey selection
And no new FD claim is started
And no IDV is asked for at this step (not a payment step)
When the customer selects "AC 412 as booked" and types "I was told I might be moved but I stayed on AC 412"
And submits
Then the chatbot confirms the information has been added to the case
And the answer is attached to the case as a structured field plus the free-text note

PART D � CASE RETURNS TO THE SAME AGENT:
Then the status changes Parked ? "Update Pending Action" straight away
And the case leaves Sarah's Parked widget and appears in her Assigned Cases list
And the case shows "?? UPDATE RECEIVED"
And it does not count against her one-new-case limit
And the assigned agent stays Sarah Martin
And the case does NOT go to "To Be Assigned"
And Marc Dubois cannot pull the case with "Get Next Case"
And no Appeal Pending or Case Closed banner is shown
And the Case ID does not change
And the Audit Log records: Welcome Back response received (channel: deep link), Parked ? Update Pending Action

PART E � AGENT CONTINUES AND TRIGGERS PAYOUT:
When Sarah clicks the case row
Then the status changes to "In Progress"
And the customer's answer is clearly shown
And she confirms it matches Trip Tracer (AC 412, no change)
And she keeps the decision ELIGIBLE, FD-APPR-EL-02, CAD 700 (no override)
When she triggers "Welcome Back � Payout"
Then the amount and type are filled in by the system (CAD 700) and she cannot type or change the payout structure
And a Welcome Back payout email is sent to o***@gmail.com
And the case is Awaiting Customer Info (Compensation)

PART F � CUSTOMER COMPLETES PAYOUT THROUGH WELCOME BACK:
When the customer clicks the deep link again
Then they land straight on the payment step (earlier steps not shown)
And country of residence = Canada ? CAD
And Basic Aeroplan is found ? both options offered: Cash CAD 700 (Interac, 5 to 10 business days) or AC Wallet CAD 840 (20% bonus)
And the customer selects "Cash"
And only the Interac email o***@gmail.com is confirmed
And Persona IDV runs (payment step) ? PASS, and the result is saved to the case
And the customer submits ? one CAD 700 compensation record is created
And the eligible notification email is sent via Adobe

PART G � LINK REUSE AND EXPIRED LINK:
When the customer opens the same deep link after payout
Then they are NOT sent back to the question or payment step
And they see the latest case status only
When a changed or invalid key is used
Then a fallback message says the link is not valid, and no case data is shown

Claims Dashboard Gherkin:
Given case "CASE-FD-20260728-002" for claimant "Olivier Bergeron" is owned by "Sarah Martin"
When Sarah sends "Welcome Back � Additional Details" and parks the case
Then the status should be "Parked" and the case should be in her "Incomplete / Parked Cases" widget
When the customer answers through the deep link
Then the answer should be attached to the case
And the status should change to "Update Pending Action"
And the case should appear in Sarah's "Assigned Cases" list with "?? UPDATE RECEIVED"
And the assigned agent should remain "Sarah Martin"
And the case should NOT be in "To Be Assigned"
And another Available agent should NOT be able to pull the case
And no new case should be created and the Case ID should not change
When Sarah clicks the case
Then the status should change to "In Progress"
And the Topic/Sub-topic should be "Travel Disruptions � Delay"
And the Claimant should be "Olivier Bergeron", Adult, Authentication "Pass"
And the PNR should be "PK002" with Creation Date, Journey ID, Booking Source and Office ID populated
And the Regime should be "APPR"
And the Aeroplan should be "9876543210", Tier "Basic / Member"
And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 96)
And Decision Assist should show ELIGIBLE, FD-APPR-EL-02, CAD 700 and not be greyed out
And the Duplicate Check should show "No duplicate found"
And CyberSource should be "GREEN"
And Customer Communications should show both Welcome Back emails, the customer's answer and the eligible notification in date order
And the Audit Log should record in order: created, Assigned, In Progress, Welcome Back (Additional Details) sent, Parked, customer answer, Update Pending Action, In Progress, Welcome Back (Payout) sent, IDV PASS, payout, Resolved, with actor, timestamp and before/after values
And the Final Status should be "Resolved" and read-only

Payment Validation Gherkin:
Given the case is ELIGIBLE, CAD 700 and Sarah has triggered "Welcome Back � Payout"
Then the payout amount should be filled in by the system and not editable as free text
When the customer opens the deep link
Then they should land straight on payment
And country should be "Canada" and currency "CAD"
And both Cash (CAD 700) and AC Wallet (CAD 840) should be offered
And the customer selects "Cash" ? Interac e-Transfer
And only the email "o***@gmail.com" should be collected
And Persona IDV should PASS and be saved to the case
And exactly one CAD 700 compensation record should be created
And it should be picked up by the evening batch and sent to Unifier (manual trigger in UAT)
And Unifier should acknowledge
And Interac status should move Pending ? Cached / Rejected / Expired, with Expired after 35 days unclaimed
And the Compensation tab should show CAD 700, Cash � Interac, status via talkback

Expected Results:
DDS FD-APPR-EL-02, CAD 700. The agent sends Welcome Back � Additional Details and parks the case. The customer uses the deep link and goes straight to the question, with no restart and no new case. Their answer is attached, and the case moves to Update Pending Action with "?? UPDATE RECEIVED" in the same agent's Assigned Cases list. The agent opens it (In Progress) and sends Welcome Back � Payout with a system-filled amount. The customer goes straight to payment and is paid CAD 700 Cash via Interac (email only), with one compensation record. Reusing the link afterwards shows status only.