BACKGROUND (System Processing � No Customer Interaction):
Given a case was previously created for PNR: TC148
And the case was placed in the System Processing Queue (case previously filed via chatbot, all identification/authentication/journey selection completed)
And 72 hours have elapsed since last leg arrival
And the Rules Engine attempted to retrieve MSL data from backend systems
MSL DATA RETRIEVAL (Days 1�14):
Then the system attempts to retrieve critical MSL data on a scheduled basis
Day 1: RE queries backend ? Operating times: NULL, Flight number: NULL ? CRITICAL DATA MISSING ? retry
Day 3: RE retries ? Operating times: NULL, Flight number: NULL ? CRITICAL DATA MISSING ? retry
Day 7: RE retries ? Operating times: NULL, Flight number: NULL ? CRITICAL DATA MISSING ? retry
Day 10: RE retries ? Operating times: NULL, Flight number: NULL ? CRITICAL DATA MISSING ? retry
Day 14: RE final retry ? Operating times: NULL, Flight number: NULL ? 14-DAY WINDOW EXHAUSTED ? CRITICAL DATA STILL MISSING ? NO DETERMINATION ? ESCALATE TO AGENT
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC148
? Promised Itinerary - Flight: MISSING (flight number not available in backend), Route: YYZ ? TLV
? Current Itinerary - Status: DISRUPTED (details incomplete)
? Customer Status: Travel Completed (filed after travel)
? Regime: ASL (Israel) (Israel destination � TLV)
? Destination: TLV (Israel)
? MSL DATA: CRITICAL DATA MISSING
? Operating Times: NULL (after 14 days)
? Flight Number: NULL (after 14 days � backend unable to resolve)
? Disruption Code: CANNOT BE ASSESSED (no MSL flight identified)
? 14-Day Retry Window: EXHAUSTED
? Case Status: System Processing Queue ? 14 days exhausted ? ESCALATED TO AGENT
? NOTE: Unlike ND-04 (codes missing), here the structural flight data itself is absent � RE cannot even identify which flight to query codes for
Flight Compensation:
? [PASSENGER] | NO DETERMINATION | MSL_DATA_MISSING_14_DAYS | PENDING AGENT REVIEW
CASE STATUS UPDATE:
Then the system updates the case status from "System Processing Queue" to "Pending Agent Review"
And the system records: 14-day retry window exhausted, critical MSL data missing (operating times, flight number)
And the case is routed to the manual review agent queue
NOTIFICATION � ESCALATION EMAIL (Adobe):
Then the system triggers notification via Adobe:
And a No Determination notification email is sent to the customer's email on file
And the email contains:
Subject: "Update on your Air Canada claim � [Case Reference]"
Case Reference number
Flight details (YYZ?TLV, date � limited details available due to data gap)
Status: "Your claim is currently under review by our Customer Relations team. We require additional time to assess your eligibility."
Expected timeline for agent review
Contact information for further questions
NO CHATBOT INTERACTION (customer does not return to chatbot � result pending agent review)

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for PNR "TC148" under ASL Israel destination TLV
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the Case Status should be "Pending Agent Review" escalated from System Processing Queue after 14 days
    And the Last Updated date should be Day 14
    And the Team assignment should be "Manual Review Agent Queue"
    And the Journey should show "YYZ ? TLV" as disrupted with details incomplete due to missing structural data
    And the flight number and operating times should both be NULL meaning RE cannot even identify which flight to query codes for
    And this should differ from TC185 where the flight was identified but codes were missing
    And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "Critical MSL data missing � operating times NULL, flight number NULL after 14 days"
    And RE should have polled on Days 1, 3, 7, 10, and 14 and all returned NULL for operating times and flight number
    And the 14-Day Retry Window should be exhausted
    And the determination should be "NO DETERMINATION" escalated to agent
    And the Case Status History should show Created then System Processing Queue then Day 14 Pending Agent Review escalated due to MSL data missing
    And an escalation email should have been sent to the customer's email on file containing Case Reference and limited flight details YYZ to TLV with date and data gap and status under review and expected timeline
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given no determination was made due to critical MSL data missing after 14-day retry
    Then no automated payment flow should be triggered
    And the case was created and sent to agent for manual handling
    And no country of residence should have been asked
    And no compensation record should have been created automatically
    And no batch file should have been dispatched
    And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e-credit to EIP
    And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved

Expected Results:
DDS returns FD-ASL-ND-05. Trip Tracer: Promise = available (scheduled); Actual = MISSING; Arrival Code = NULL; Departure Code = NULL; Cancellation Code = NULL; ALL codes MISSING; Delay = CANNOT CALCULATE; Controllability = CANNOT DETERMINE. Data Completeness Check: All critical data points missing; 14-day retry exhausted ? NO DETERMINATION. Case Routing: Manual handling � 30-day SLA (May 28 ? June 27, 2026). Agent must contact operations for missing backend data. Compensation: NOT CALCULATED. Fraud Screening: NOT INVOKED. Regime Assessment: ASL = ND-05 (data missing); APPR = ND (same gap); EU = N/A. Claims Dashboard: Case = CASE-FD-20260528-205; Status = Pending � Manual Investigation; 30-day SLA active; Agent Action = "Contact operations for missing data, re-run DDS"; DDS = FD-ASL-ND-05.