BACKGROUND (System Processing � No Customer Interaction):
Given a case was previously created for PNR: TC065
And the case was placed in the System Processing Queue
And 72 hours have elapsed since last leg arrival
And DDS has been polling for disruption codes
DDS POLLING (Days 1�14):
Then the system polls for disruption codes on a scheduled basis
Day 1: DDS runs ? Arrival code: NULL, Departure code: NULL ? NO DETERMINATION ? retry
Day 3: DDS retries ? Arrival code: NULL, Departure code: NULL ? NO DETERMINATION ? retry
Day 7: DDS retries ? Arrival code: NULL, Departure code: NULL ? NO DETERMINATION ? retry
Day 10: DDS retries ? Arrival code: NULL, Departure code: NULL ? NO DETERMINATION ? retry
Day 14: DDS final retry ? Arrival code: NULL, Departure code: NULL ? 14-DAY WINDOW EXHAUSTED ? NO DETERMINATION ? ESCALATE TO AGENT
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC065
? Promised Itinerary - Flight: AC 509, Route: YUL ? YYZ, Scheduled Arrival: 12:00
? Current Itinerary - Flight: AC 509, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 12:00 ? Actual: 16:00, Delay: +4H 00M
? Regime: APPR (1 regime)
? MSL FLIGHT: AC 509 � YUL ? YYZ � NO CODE
? Arrival Code: NULL (after 14 days)
? Departure Code: NULL (after 14 days)
? Cancellation Code: NULL (after 14 days)
? Fallback: ATTEMPTED ? ALL CODES NULL ? NO FALLBACK AVAILABLE
? 14-Day Retry Window: EXHAUSTED
? Case Status: System Processing Queue ? 14 days exhausted ? ESCALATED TO CR AGENT
Flight Compensation:
? MR/MS [PASSENGER] | NO DETERMINATION | NO_CODE_14_DAYS | PENDING CR AGENT
CASE STATUS UPDATE:
Then the system updates the case status from "System Processing Queue" to "Pending Agent Review"
And the system records: 14-day retry window exhausted, no disruption code available
And the case is routed to the Customer Relations (CR) agent queue
NOTIFICATION � ESCALATION EMAIL (Adobe):
Then the system triggers notification via Adobe:
And a No Determination notification email is sent to the customer's email on file
And the email contains:
Subject: "Update on your Air Canada claim � [Case Reference]"
Case Reference number
Flight details (AC 509, YUL?YYZ, date, delay 4h)
Status: "Your claim is currently under review by our Customer Relations team. We require additional time to assess your eligibility."
Expected timeline for agent review
Contact information for further questions
NO CHATBOT INTERACTION (customer does not return to chatbot � result pending agent review)

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for the passenger from PNR "TC065" and was initially placed in System Processing Queue
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Pending Agent Review" transitioned from System Processing Queue
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be "Customer Relations (CR) Agent Queue"
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel may be restricted as it is pending manual review
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC065"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR"
    And the Tags should include "Claimant" and "Adult"
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "All codes NULL after 14-day polling � no fallback available"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have polled on Days 1, 3, 7, 10, and 14 and all returned NULL for arrival, departure, and cancellation codes
    And the 14-day retry window should be exhausted
    And the eligibility decision should be "PENDING CR AGENT"
    And the Duplicate Check should have run automatically
    And the result should be "No duplicate found"
    And CyberSource should NOT have been triggered as it is pending manual review
    And the system should have appended the booking record automatically for identified and authenticated user
    And the previous status should have been "System Processing Queue" and the current status should be "Pending Agent Review" with 14-day window exhausted and escalated to CR with the transition recorded in the Audit Log with timestamp
    And an escalation / No Determination notification email should have been sent via Adobe
    And the email subject should be "Update on your Air Canada claim � [Case Reference]"
    And the email should contain the Case Reference and flight details AC 509 YUL to YYZ delay 4h and status under review by CR team and expected timeline and contact information
    And the Agent Notes section should be accessible
    And the Audit Log should record case creation and System Processing Queue entry and DDS polling attempts on Days 1, 3, 7, 10, and 14 and 14-day exhaustion and escalation to CR
    And Customer Communications should show the escalation notification email
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Case Status should be "Pending Agent Review" escalated to CR agent queue
    And the case should NOT be in read-only mode as it is pending CR team action
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given no determination was made after 14-day polling from System Processing Queue
    Then no automated payment flow should be triggered
    And the case was polled for 14 days with no complete answer
    And the case was sent to CR agent for manual review
    And no country of residence should have been asked
    And no compensation record should have been created automatically
    And no batch file should have been dispatched
    And if the agent later determines eligible manual compensation should be created and payment dispatched per type
    And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved

Expected Results:
DDS returns FD-APPR-ND-09. Trip Tracer: Delay = 4hrs (from flight status); All codes = NULL; Polled for 14 days � data never arrived. System behavior at Day 14: Polling stops; Case status changes from "Polling" to "Manual Handling Required"; Automatic escalation to agent queue. CRITICAL: System must NOT continue polling past 14 days � definitive cutoff. Agent must investigate manually (contact station, check paper logs, etc.). Claims Dashboard: No Determination; Reason = 14-day polling exhausted, data never arrived; Polling history = 14 attempts (all NULL); Status = Escalated to Manual Handling; DDS = FD-APPR-ND-09.