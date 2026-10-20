BACKGROUND (System Processing � No Customer Interaction):
Given a case was previously created for PNR: TC064
And the case was placed in the System Processing Queue (72h not elapsed at time of filing)
And 72 hours have now elapsed since last leg arrival
DDS AUTO-RUN:
Then the system triggers DDS evaluation automatically (scheduled run)
And DDS retrieves flight data for PNR: TC064
And DDS evaluates:
Flight: AC 508, YUL ? YYZ
Arrival delay: 5 hours
Disruption code: 71 (Severe Weather)
Controllability: UNCONTROLLABLE
Result: NOT ELIGIBLE
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC064
? Promised Itinerary - Flight: AC 508, Route: YUL ? YYZ, Scheduled Arrival: 12:00
? Current Itinerary - Flight: AC 508, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 12:00 ? Actual: 17:00, Delay: +5H 00M
? Regime: APPR (1 regime)
? MSL FLIGHT: AC 508 � YUL ? YYZ � 71
? "Delayed due to severe weather"
? Delay: +5H 00M � UNCONTROLLABLE
? Fallback: FALSE
? Case Status: Previously in System Processing Queue ? DDS now ran ? NOT ELIGIBLE
Flight Compensation:
? MR/MS [PASSENGER] | NOT ELIGIBLE | UNCONTROLLABLE | CAD 0.00
FRAUD SCREENING � NOT TRIGGERED:
CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked
CASE STATUS UPDATE:
Then the system updates the case status from "System Processing Queue" to "Not Eligible"
And the system records the DDS result: NOT ELIGIBLE (Uncontrollable � Code 71)
NOTIFICATION � WELCOME BACK EMAIL (Adobe):
Then the system triggers notification via Adobe:
And a Not Eligible notification email is sent to the customer's email on file
And the email contains:
Subject: "Update on your Air Canada claim � [Case Reference]"
Case Reference number
Flight details (AC 508, YUL?YYZ, date, delay 5h)
Not eligible reason: "After a full review, we can confirm that weather was the primary reason. Since the delay was caused by severe weather conditions, weather and other factors outside of the airline's control aren't covered under the compensation regulations APPR."
Insurance suggestion: "If you have travel insurance, you may want to contact your insurance provider to see if your policy offers any coverage for this situation."
Contact information for further questions
NO CHATBOT INTERACTION (customer does not return to chatbot � result delivered via email)

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for the passenger from PNR "TC064" and was initially placed in System Processing Queue
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Closed � Not Eligible" transitioned from System Processing Queue
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC064"
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
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Uncontrollable � weather, Code 71"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically after the 72-hour window elapsed as a system-triggered action with no customer interaction
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to delay 5h with Code 71 being Uncontrollable
    And the Duplicate Check should have run automatically
    And the result should be "No duplicate found"
    And CyberSource should NOT have been triggered as it only runs for eligible cases
    And the system should have appended the booking record automatically for identified and authenticated user
    And the previous status should have been "System Processing Queue" and the current status should be "Closed � Not Eligible" with the transition recorded in the Audit Log with timestamp
    And a Welcome Back / Not Eligible notification email should have been sent via Adobe
    And the email subject should be "Update on your Air Canada claim � [Case Reference]"
    And the email should contain the Case Reference and flight details AC 508 YUL to YYZ delay 5h and not eligible reason weather uncontrollable and insurance suggestion and contact information
    And the Agent Notes section should be accessible
    And the Audit Log should record case creation and System Processing Queue entry and DDS auto-run and status transition to Closed Not Eligible
    And Customer Communications should show the Welcome Back not eligible email
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the case was in System Processing Queue and DDS returned "NOT ELIGIBLE" due to uncontrollable weather
    Then the customer was notified by email as not eligible
    And no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section

Expected Results:
DDS returns PENDING initially ? then FD-APPR-NE-28 when data arrives. Polling: System polls Trip Tracer daily from Day 2. At D+4: Data arrives ? DDS processes ? Code 72, Weather, Uncontrollable ? Not Eligible. Notification: Email sent to customer with Not Eligible message � "Your flight delay was caused by weather conditions beyond our control. You are not eligible for compensation under APPR." CRITICAL: Welcome Back must handle NE outcomes gracefully � customer was waiting for a decision and the answer is "no." Claims Dashboard: Welcome Back = TRUE; Polling history shown; Data arrival at D+4; Final DDS = FD-APPR-NE-28; Not Eligible; Code 72.