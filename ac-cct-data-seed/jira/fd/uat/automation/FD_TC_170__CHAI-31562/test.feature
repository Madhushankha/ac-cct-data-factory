BACKGROUND (System Processing � No Customer Interaction):
Given a case was previously created for PNR: TC144
And the case was placed in the System Processing Queue (case previously filed via chatbot, all identification/authentication/journey selection completed)
And 72 hours have elapsed since last leg arrival
And the Rules Engine attempted to retrieve disruption data from OAL (Lufthansa LH 694)
OAL DATA RETRIEVAL (Days 1�14):
Then the system attempts to retrieve disruption data from Lufthansa on a scheduled basis
Day 1: RE queries OAL data feed ? Lufthansa LH 694 data: NOT AVAILABLE ? retry
Day 3: RE retries ? Lufthansa LH 694 data: NOT AVAILABLE ? retry
Day 7: RE retries ? Lufthansa LH 694 data: NOT AVAILABLE ? retry
Day 10: RE retries ? Lufthansa LH 694 data: NOT AVAILABLE ? retry
Day 14: RE final retry ? Lufthansa LH 694 data: NOT AVAILABLE ? 14-DAY WINDOW EXHAUSTED ? OAL DATA NOT AVAILABLE ? NO DETERMINATION ? ESCALATE TO AGENT
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC144
? Segment 1: Flight: AC 873, Route: YYZ ? FRA, Status: COMPLETED (on time) � AC operated
? Segment 2: Flight: LH 694, Route: FRA ? TLV, Status: ARRIVED LATE, Delay: +4H 00M � Lufthansa operated (OAL)
? MSL = Segment 2 (LH 694 � Lufthansa, OAL)
? Regime: ASL (Israel) (Israel destination � TLV)
? Destination: TLV (Israel)
? MSL Operating Carrier: Lufthansa (LH) � Star Alliance partner, but data unavailable for this specific flight
? OAL Data: NOT AVAILABLE (Lufthansa did not share disruption data for LH 694)
? Arrival Code (LH 694): NULL (OAL data not shared)
? Departure Code (LH 694): NULL (OAL data not shared)
? 14-Day Retry Window: EXHAUSTED
? Case Status: System Processing Queue ? 14 days exhausted ? ESCALATED TO AGENT
? NOTE: Even though Lufthansa is Star Alliance, the specific flight data was unavailable � this is a data sharing issue, not a carrier classification issue
Flight Compensation:
? [PASSENGER] | NO DETERMINATION | OAL_DATA_NOT_AVAILABLE_14_DAYS | PENDING AGENT REVIEW
CASE STATUS UPDATE:
Then the system updates the case status from "System Processing Queue" to "Pending Agent Review"
And the system records: 14-day retry window exhausted, OAL data not available (Lufthansa LH 694), data sharing issue
And the case is routed to the manual review agent queue
NOTIFICATION � ESCALATION EMAIL (Adobe):
Then the system triggers notification via Adobe:
And a No Determination notification email is sent to the customer's email on file
And the email contains:
Subject: "Update on your Air Canada claim � [Case Reference]"
Case Reference number
Flight details (Leg 1: YYZ?FRA AC completed; Leg 2: FRA?TLV Lufthansa delayed 4h)
Status: "Your claim is currently under review by our Customer Relations team. We require additional time to assess your eligibility as this involves coordination with another airline."
Expected timeline for agent review
Contact information for further questions
NO CHATBOT INTERACTION (customer does not return to chatbot � result pending agent review)

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for PNR "TC144" under ASL Israel destination TLV
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the Case Status should be "Pending Agent Review" escalated from System Processing Queue after 14 days
    And the Last Updated date should be Day 14
    And the Team assignment should be "Manual Review Agent Queue"
    And the Journey should show "Segment 1: YYZ ? FRA" as completed and AC operated and "Segment 2: FRA ? TLV" arrived late plus 4h and Lufthansa LH 694 operated as OAL
    And the MSL should be Segment 2 Lufthansa LH 694 as OAL
    And even though Lufthansa is Star Alliance the specific flight data was unavailable as this is a data sharing issue not a carrier classification issue
    And this should differ from TC183 where Star Alliance results in immediate StarQuest routing based on carrier identity whereas here the system polled for data and it was unavailable
    And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "OAL data not available � Lufthansa did not share disruption data for LH 694; 14-day retry exhausted"
    And RE should have polled on Days 1, 3, 7, 10, and 14 and all returned Lufthansa LH 694 data NOT AVAILABLE
    And the 14-Day Retry Window should be exhausted
    And the determination should be "NO DETERMINATION" escalated to agent
    And the Case Status History should show Created then System Processing Queue then Day 14 Pending Agent Review escalated due to OAL data not available
    And an escalation email should have been sent to the customer's email on file containing Case Reference and Leg 1 YYZ to FRA AC completed and Leg 2 FRA to TLV Lufthansa delayed 4h and status under review and coordination with another airline note
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given no determination was made due to OAL data not available after 14-day retry
    Then no automated payment flow should be triggered
    And the case was created and sent to agent for manual handling
    And no country of residence should have been asked
    And no compensation record should have been created automatically
    And no batch file should have been dispatched
    And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e-credit to EIP
    And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved

Expected Results:
DDS returns FD-ASL-ND-06. Trip Tracer: Leg 1 (AC YYZ?FRA) = Data AVAILABLE (on time); Leg 2 (LH FRA?TLV) = Data NOT AVAILABLE (OAG feed gap); MSL = Leg 2 (OAL, disrupted); Final arrival at TLV = UNKNOWN; Delay = CANNOT CALCULATE at final destination. OAL Data Check: OAG feed for LH 694 = NOT RECEIVED; 14-day window exhausted ? NO DETERMINATION. Case Routing: Manual handling � 30-day SLA. Agent must request OAL data manually from Lufthansa. Compensation: NOT CALCULATED. Fraud Screening: NOT INVOKED. Regime Assessment: ASL = ND-06 (OAL data unavailable, Lufthansa); APPR = ND (same gap); EU = assessed separately. Claims Dashboard: Case = CASE-FD-20260528-206; Status = Pending � Manual Investigation; MSL = Leg 2 (LH 694 FRA?TLV); OAL = Lufthansa (data gap); 30-day SLA active; Agent Action = "Request LH disruption data manually, re-run DDS"; DDS = FD-ASL-ND-06.