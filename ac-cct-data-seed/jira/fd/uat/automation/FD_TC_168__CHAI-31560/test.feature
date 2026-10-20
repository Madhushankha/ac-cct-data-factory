BACKGROUND (System Processing � No Customer Interaction):
Given a case was previously created for PNR: TC142
And the case was placed in the System Processing Queue (case previously filed via chatbot, all identification/authentication/journey selection completed)
And 72 hours have elapsed since last leg arrival
DDS POLLING (Days 1�14):
Then the system polls for disruption codes on a scheduled basis
Day 1: DDS runs ? Arrival code: NULL, Departure code: NULL ? NO DETERMINATION ? retry
Day 3: DDS retries ? Arrival code: NULL, Departure code: NULL ? NO DETERMINATION ? retry
Day 7: DDS retries ? Arrival code: NULL, Departure code: NULL ? NO DETERMINATION ? retry
Day 10: DDS retries ? Arrival code: NULL, Departure code: NULL ? NO DETERMINATION ? retry
Day 14: DDS final retry ? Arrival code: NULL, Departure code: NULL ? 14-DAY WINDOW EXHAUSTED ? NO DETERMINATION ? ESCALATE TO AGENT
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC142
? Promised Itinerary - Flight: AC 084, Route: TLV ? YYZ, Scheduled Arrival: 16:00
? Current Itinerary - Flight: AC 084, Route: TLV ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 16:00 ? Actual: 20:00, Delay: +4H 00M
? Regime: ASL (Israel) (Israel origin � TLV)
? MSL FLIGHT: AC 084 � TLV ? YYZ � NO CODE
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
Flight details (AC 084, TLV?YYZ, date, delay 4h)
Status: "Your claim is currently under review by our Customer Relations team. We require additional time to assess your eligibility."
Expected timeline for agent review
Contact information for further questions
NO CHATBOT INTERACTION (customer does not return to chatbot � result pending agent review)

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for PNR "TC142" under ASL Israel origin TLV
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the Case Status should be "Pending Agent Review" escalated from System Processing Queue after 14 days
    And the Created date should be populated as the original case creation date
    And the Last Updated date should be Day 14 as the date of final retry and escalation
    And the SLA countdown should be tracking correctly
    And the Team assignment should be "Customer Relations (CR) Agent Queue"
    And the Decision Assist panel status should reflect NO DETERMINATION after 14-day exhaustion
    And the Journey should show "Bound 1: TLV ? YYZ" arrived late plus 4h
    And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "No disruption code after 14 days � all codes NULL; arrival, departure, and cancellation codes all missing"
    And DDS should have polled on Days 1, 3, 7, 10, and 14 and all returned NULL codes
    And fallback should have been attempted but ALL CODES NULL with NO FALLBACK AVAILABLE
    And the 14-Day Retry Window should be exhausted
    And the determination should be "NO DETERMINATION" escalated to CR agent
    And the Duplicate Check should have run automatically and the result should be "No duplicate found"
    And CyberSource should NOT have been triggered
    And the booking should have been appended at original case creation
    And the Case Status History should show Created then System Processing Queue then Day 14 Pending Agent Review escalated
    And an escalation email should have been sent to the customer's email on file containing Case Reference and flight details AC 084 TLV to YYZ delay 4h and status under review by Customer Relations and expected timeline
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given no determination was made due to no disruption code after 14-day retry
    Then no automated payment flow should be triggered
    And the case was created and sent to agent for manual handling
    And no country of residence should have been asked
    And no compensation record should have been created automatically
    And no batch file should have been dispatched
    And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e-credit to EIP
    And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved

Expected Results:
DDS returns FD-ASL-ND-04. Trip Tracer: Flight times may be partially available; Arrival Code = NULL; Departure Code = NULL; Cancellation Code = NULL; ALL codes MISSING after 14-day polling; Delay may be calculable but controllability CANNOT be determined (no code). No Determination: Delay exists but without a code, DDS cannot classify controllability (controllable vs extraordinary) ? cannot determine eligibility. Case Routing: Agent review � agent must investigate the disruption cause through operations team, assign a code, then re-run DDS. Compensation: NOT CALCULATED. Fraud Screening: NOT INVOKED. Regime Assessment: ASL = ND-04 (No code after 14 days). Claims Dashboard: Status = No Determination; Reason = No disruption code after 14-day polling; Agent Action = "Contact operations for code assignment, then re-run DDS"; DDS = FD-ASL-ND-04.