PART A � INITIAL CLAIM (CHATBOT):
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01) and the user selects "English"
Then the privacy alert is displayed
And the user says "Our flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if my family and I are eligible for compensation"
When the chatbot identifies flight disruption intent
Then third-party check ? NO, and the legal disclaimer is shown and accepted
IDENTIFICATION (GenUC-01): "Catherine Bouchard" + PNR "OV003" ? Trip Tracer PNR FOUND (Auth Flow 1)
AUTHENTICATION (GenUC-05): Email c***@gmail.com ? OTP "640219" ? CORRECT (attempt 1 of 5)
GROUP BOOKING CHECK: group identifier NOT PRESENT
PASSENGER SELECTION (GenUC-06): "I found 3 passengers on this booking: Catherine Bouchard (Adult - Aeroplan Member), Alexandre Bouchard (Adult), Sophie Bouchard (Child). Would you like to include all passengers in this claim?" ? "Yes, include all 3 passengers" ? PAX count 3 ? 9 or fewer ? PROCEED
JOURNEY SELECTION (GenUC-08): AC 412, YUL ? YYZ, July 20, 2026, Arrival Delay 7 hours ? "Yes"
CHECKS: single leg; duplicate check ? no existing case for any of the 3 passengers; more than 72 hours; within 366 days ? PROCEED
DDS: APPR; Code 96 Controllable; 420 min; ELIGIBLE for each passenger; FD-APPR-EL-02; CAD 700 each
TRIP TRACER UI VALIDATION (OV003):
? Promised: AC 412, YUL ? YYZ, 12:00
? Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M
? Regime: APPR (1 regime)
? MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE
? MS CATHERINE BOUCHARD | ELIGIBLE | DELAY_6_TO_LT_9_HOURS | CAD 700.00 Cash / CAD 840.00 AC Wallet
? MR ALEXANDRE BOUCHARD | ELIGIBLE | DELAY_6_TO_LT_9_HOURS | CAD 700.00 Cash / CAD 840.00 AC Wallet
? MISS SOPHIE BOUCHARD | ELIGIBLE | DELAY_6_TO_LT_9_HOURS | CAD 700.00 Cash / CAD 840.00 AC Wallet
? Total: CAD 2,100.00 Cash / CAD 2,520.00 AC Wallet
CYBERSOURCE (GLOB-05): GREEN
ELIGIBLE RESULT (FD-05a): APPR eligible message for AC 412 for all 3 passengers
CUSTOMER DROPS OFF: closes the chat at "In which country will your reimbursement be deposited?"
Then one case is created for all 3 passengers as ELIGIBLE, CAD 2,100 total, with no payment instruction, and is routed to the agent queue

PART B � AGENT REVIEWS THE CASE:
Given Sarah Martin clicks "Get Next Case" ? Assigned ? opens it within 10 minutes ? In Progress
Then Decision Assist shows the FD badge, "Recommended: Eligible" (green), the reasoning list and the "Last run" timestamp
And the recommendation lists each passenger: Catherine CAD 700, Alexandre CAD 700, Sophie CAD 700, total CAD 2,100
When Sarah checks the compensation history, ops notes and legacy payment lookup for each passenger
Then she finds LEG-APPR-55831, 55832 and 55833: CAD 700 APPR compensation paid to each passenger for AC 412, Jul 20, issued Jul 22, 2026
And she confirms the Trip Tracer coding (Code 96, 7h) is correct
And she does NOT edit the flight code

PART C � PERMISSION CHECK (NEGATIVE):
Given Paul Girard (no case.render_decision permission) opens the case
Then the "Override" button is NOT displayed for any passenger
And Paul cannot change eligibility, amount or payout method

PART D � OVERRIDE FORM VALIDATION (NEGATIVE):
Given Sarah clicks "Override"
Then the override form opens with: new eligibility (Eligible / Not Eligible / Partial), new amount, new payout method and override reason (required), for each passenger
When she selects "Not Eligible" and leaves the reason empty
Then she cannot confirm and a required-field message is shown
When she enters a reason under 50 characters
Then she cannot confirm
When she enters a reason over 500 characters
Then she cannot confirm

PART E � OVERRIDE ALL 3 PASSENGERS TO NOT ELIGIBLE (POSITIVE):
When Sarah sets Catherine Bouchard to "Not Eligible", amount 0, no payout method
And sets Alexandre Bouchard to "Not Eligible", amount 0, no payout method
And sets Sophie Bouchard to "Not Eligible", amount 0, no payout method
And enters the reason: "All 3 passengers already received CAD 700 APPR compensation each for AC 412 YUL-YYZ Jul 20 2026 via airport/legacy payments LEG-APPR-55831, 55832 and 55833 issued Jul 22 2026. Paying again would duplicate compensation."
And clicks Confirm
Then the override is saved for all 3 passengers
And Decision Assist shows the agent decision "Not Eligible" for each passenger
And the original recommendation (Eligible, CAD 700 each, FD-APPR-EL-02) stays visible as read-only for each passenger
And the stored values show, per passenger: suggested = Eligible / CAD 700, approved = Not Eligible / CAD 0, difference = ?CAD 700
And the stored case totals show: suggested CAD 2,100, approved CAD 0, difference ?CAD 2,100
And the Audit Log has an override entry for each passenger with agent ID, timestamp, before/after values and reason
And no passenger is left with an Eligible amount or a payout method
And Sarah adds an internal note referencing all 3 legacy payment references

PART F � ADVANCE CASE AND NOTIFY THE CUSTOMER:
When Sarah clicks "Advance Case"
Then Step 1 shows the decision Not Eligible (overridden) for all 3 passengers, total CAD 0, and the reason summary
When she selects the template "Decision Rendered � Not Eligible" (English)
And enters customer text saying compensation for this disruption has already been issued to all 3 passengers, without internal references or payment details
And sends it
Then one notification is sent via Adobe to c***@gmail.com for the case (not one per passenger)
And the notification lists all 3 passengers as Not Eligible
And no secure payment / Welcome Back link is included
And the case status becomes "Closed � Not Eligible"

PART G � AFTER CLOSURE:
Given the case is Closed � Not Eligible
Then Decision Assist is read-only for all passengers and the Override button can't be used
And no compensation / payment record exists for any passenger

Claims Dashboard Gherkin:
Given case "CASE-FD-20260728-103" for claimant "Catherine Bouchard" (PNR "OV003") covers 3 passengers
And the DDS recommendation is "Eligible", "FD-APPR-EL-02", CAD 700 per passenger, CAD 2,100 total
And agent "Sarah Martin" has the "case.render_decision" permission
When a user without "case.render_decision" opens the case
Then the "Override" button should not be displayed
When Sarah overrides and the reason is empty, under 50 characters or over 500 characters
Then the override should not be saved
When Sarah sets all 3 passengers to "Not Eligible" with a valid reason and confirms
Then each passenger should show agent decision "Not Eligible" with amount 0 and no payout method
And each passenger should keep the original "Recommended: Eligible � CAD 700" as read-only
And suggested value, approved value and difference should be stored per passenger and for the case total
And the Audit Log should record, for each passenger, agent ID, timestamp, before/after values and reason
And the flight code should still be 96 (not edited)
And there should be only one case for the 3 passengers and the Case ID should not change
And the Topic/Sub-topic should be "Travel Disruptions � Delay"
And the Claimant should be "Catherine Bouchard", Adult, Authentication "Pass"
And the PNR should be "OV003" with Creation Date, Journey ID, Booking Source and Office ID populated
And the Regime should be "APPR"
And the passengers should be listed as Catherine Bouchard (Adult, Claimant, Aeroplan 9876543210, Basic / Member), Alexandre Bouchard (Adult) and Sophie Bouchard (Child)
And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 96)
And the Eligibility and Compensation section should show "Not Eligible (Agent Override)" for each passenger and total CAD 0
And the Duplicate Check should show "No duplicate found" (the prior payments are outside the Claims Dashboard)
And CyberSource should be "GREEN"
When Sarah sends "Decision Rendered � Not Eligible"
Then Customer Communications should show one Not Eligible notification for the case with template ID, version, language, timestamp and delivery status
And no payment link should be sent
And the status should be "Closed � Not Eligible"
And the case should be read-only after closure
And the agent should not be able to access Case Search as it is for leads and management only

Payment Validation Gherkin:
Given the DDS recommendation was Eligible (CAD 700 per passenger, CAD 2,100 total) and the agent overrode all 3 passengers to Not Eligible
Then no Cash or AC Wallet option should be offered
And no country of residence, Interac email, bank or card details should be collected
And Persona IDV for payout should not be triggered
And no payment record should be created for any of the 3 passengers
And nothing should be picked up by the evening batch file
And nothing should be sent to Unifier or EIP
And the Compensation tab should show no payout for any passenger and a case total of CAD 0
And none of the prior payments (LEG-APPR-55831 / 55832 / 55833) should be paid again

Expected Results:
DDS FD-APPR-EL-02, Eligible, CAD 700 per passenger (CAD 2,100 total). An authorized agent overrides all 3 passengers to Not Eligible with a required 50 to 500-character reason. The original recommendation is kept read-only per passenger. Suggested vs approved values and differences are stored per passenger and for the case total (?CAD 2,100), and each override is audited. Users without permission can't override, and invalid reasons are blocked. One "Decision Rendered � Not Eligible" notice is sent for the case with no payment link. The single case closes as Closed � Not Eligible with no payment records.