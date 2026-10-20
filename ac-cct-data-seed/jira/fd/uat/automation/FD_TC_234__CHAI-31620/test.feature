PART A � INITIAL CLAIM (CHATBOT):
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01) and the user selects "English"
Then the privacy alert is displayed
And the user says "My flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if I'm eligible for compensation"
When the chatbot identifies flight disruption intent
Then third-party check ? NO, and the legal disclaimer is shown and accepted
IDENTIFICATION (GenUC-01): "Antoine Leblanc" + PNR "OV001" ? Trip Tracer PNR FOUND (Auth Flow 1)
AUTHENTICATION (GenUC-05): Email a***@gmail.com ? OTP "581204" ? CORRECT (attempt 1 of 5)
GROUP BOOKING / PASSENGER SELECTION (GenUC-06): group identifier NOT PRESENT; 1 passenger ? "Yes"
JOURNEY SELECTION (GenUC-08): AC 412, YUL ? YYZ, July 20, 2026, Arrival Delay 7 hours ? "Yes"
CHECKS: single leg; duplicate check ? no existing case in CD; more than 72 hours; within 366 days ? PROCEED
DDS: APPR; Code 96 Controllable; 420 min; ELIGIBLE; FD-APPR-EL-02; CAD 700
TRIP TRACER UI VALIDATION (OV001):
? Promised: AC 412, YUL ? YYZ, 12:00
? Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M
? Regime: APPR (1 regime)
? MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE
? MR ANTOINE LEBLANC | ELIGIBLE | DELAY_6_TO_LT_9_HOURS | CAD 700.00 Cash / CAD 840.00 AC Wallet
CYBERSOURCE (GLOB-05): GREEN
ELIGIBLE RESULT (FD-05a): APPR eligible message for AC 412
CUSTOMER DROPS OFF: closes the chat at "In which country will your reimbursement be deposited?"
Then the case is created as ELIGIBLE, CAD 700, with no payment instruction, and is routed to the agent queue

PART B � AGENT REVIEWS THE CASE:
Given Sarah Martin clicks "Get Next Case" ? Assigned ? opens it within 10 minutes ? In Progress
Then Decision Assist shows the FD badge, "Recommended: Eligible" (green), the reasoning list, "Last run: [timestamp]" and "CAD $700.00" with the payout method badge
When Sarah checks the Compensation history, ops notes and legacy payment lookup
Then she finds LEG-APPR-55821: CAD 700 APPR compensation paid to Antoine Leblanc for AC 412, Jul 20, 2026, issued Jul 22, 2026
And she confirms that Trip Tracer coding (Code 96, 7h) is correct and doesn't need changing
And she does NOT edit the flight code

PART C � PERMISSION CHECK (NEGATIVE):
Given Paul Girard (no case.render_decision permission) opens the same case
Then the "Override" button is NOT displayed
And Paul cannot change eligibility, amount or payout method

PART D � OVERRIDE FORM VALIDATION (NEGATIVE):
Given Sarah clicks "Override" next to the recommendation
Then an inline form opens with: new eligibility (Eligible / Not Eligible / Partial), new amount, new payout method, override reason (required)
When she selects "Not Eligible" and leaves the reason empty
Then she cannot confirm and a required-field message is shown
When she enters a 30-character reason ("Already paid at airport, close")
Then she cannot confirm (below the 50-character minimum)
When she pastes a 520-character reason
Then she cannot confirm (above the 500-character maximum)

PART E � OVERRIDE TO NOT ELIGIBLE (POSITIVE):
When Sarah selects new eligibility "Not Eligible"
And the new amount is 0 / "�" and no payout method is selected
And she enters the reason: "Passenger already received CAD 700 APPR compensation for AC 412 YUL-YYZ Jul 20 2026 via airport/legacy payment LEG-APPR-55821 issued Jul 22 2026. Paying again would duplicate compensation for the same disruption."
And she clicks Confirm
Then the override is saved to the case
And Decision Assist shows the agent decision "Not Eligible"
And the original recommendation "Recommended: Eligible � CAD 700 � FD-APPR-EL-02" stays visible as read-only context
And the stored values show suggested = Eligible / CAD 700, approved = Not Eligible / CAD 0, difference = ?CAD 700
And the Audit Log records: Override, agent ID (Sarah Martin), timestamp, before (Eligible, CAD 700, Cash/AC Wallet) and after (Not Eligible, 0, none), reason text
And Sarah adds an internal note referencing LEG-APPR-55821

PART F � ADVANCE CASE AND NOTIFY THE CUSTOMER:
When Sarah clicks "Advance Case"
Then Step 1 shows the decision Not Eligible (overridden) with the reason summary
When she selects the template "Decision Rendered � Not Eligible" (English)
And enters customer text saying compensation for this disruption has already been issued, without internal references or payment details
And sends it
Then the notification is sent via Adobe to a***@gmail.com
And no secure payment / Welcome Back link is included
And the case status becomes "Closed � Not Eligible"

PART G � AFTER CLOSURE:
Given the case is Closed � Not Eligible
Then Decision Assist is read-only and the Override button can't be used
And no compensation record exists

Claims Dashboard Gherkin:
Given case "CASE-FD-20260728-101" for claimant "Antoine Leblanc" (PNR "OV001") has a DDS recommendation of "Eligible", "FD-APPR-EL-02", "CAD 700"
And agent "Sarah Martin" has the "case.render_decision" permission
When a user without "case.render_decision" opens the case
Then the "Override" button should not be displayed
When Sarah clicks "Override" and selects "Not Eligible"
And the override reason is empty, under 50 characters or over 500 characters
Then the override should not be saved
When Sarah enters a valid reason of 50 to 500 characters and confirms
Then the agent decision should be "Not Eligible" with amount 0 and no payout method
And the original "Recommended: Eligible � CAD 700" should remain visible as read-only
And the suggested value, approved value and difference should be stored
And the Audit Log should record agent ID, timestamp, before/after values and reason
And the flight code should still be 96 (not edited)
And the Topic/Sub-topic should be "Travel Disruptions � Delay"
And the Claimant should be "Antoine Leblanc", Adult, Authentication "Pass"
And the PNR should be "OV001" with Creation Date, Journey ID, Booking Source and Office ID populated
And the Regime should be "APPR"
And the Aeroplan should be "9876543210", Tier "Basic / Member"
And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 96)
And the Eligibility and Compensation section should show "Not Eligible (Agent Override)"
And CyberSource should be "GREEN"
When Sarah sends "Decision Rendered � Not Eligible"
Then Customer Communications should show the Not Eligible notification with template ID, version, language, timestamp and delivery status
And no payment link should be sent
And the status should be "Closed � Not Eligible"
And the case should be read-only after closure
And the agent should not be able to access Case Search as it is for leads and management only

Payment Validation Gherkin:
Given the DDS recommendation was "Eligible, CAD 700" and the agent overrode it to "Not Eligible"
Then no Cash or AC Wallet option should be offered to the customer
And no country of residence, Interac email, bank or card details should be collected
And Persona IDV for payout should not be triggered
And no compensation record should be created
And nothing should be picked up by the evening batch file
And nothing should be sent to Unifier or EIP
And the Compensation tab should show no payout for this case
And the prior payment LEG-APPR-55821 should not be duplicated

Expected Results:
DDS FD-APPR-EL-02, Eligible, CAD 700. An authorized agent overrides it to Not Eligible with a required 50 to 500-character reason. The original recommendation is kept as read-only, and suggested vs approved values and the difference are stored. The override is audited with before/after values. Users without permission can't override, and invalid reasons are blocked. The "Decision Rendered � Not Eligible" notice is sent with no payment link, and the case closes as Closed � Not Eligible with no payout.