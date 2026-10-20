BACKGROUND (System Processing � No Customer Interaction):
Given a case was previously created for PNR: TC115
And the case was placed in the System Processing Queue (case previously filed via chatbot, all identification/authentication/journey selection completed)
And 72 hours have elapsed since last leg arrival
And the Rules Engine attempted to retrieve disruption data from OAL (WestJet)
OAL DATA RETRIEVAL (Days 1�14):
Then the system attempts to retrieve disruption data from WestJet on a scheduled basis
Day 1: RE queries OAL data feed ? WestJet data: NOT AVAILABLE ? retry
Day 3: RE retries ? WestJet data: NOT AVAILABLE ? retry
Day 7: RE retries ? WestJet data: NOT AVAILABLE ? retry
Day 10: RE retries ? WestJet data: NOT AVAILABLE ? retry
Day 14: RE final retry ? WestJet data: NOT AVAILABLE ? 14-DAY WINDOW EXHAUSTED ? OAL DATA NOT AVAILABLE ? NO DETERMINATION ? ESCALATE TO AGENT
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC115
? Segment 1: Flight: AC 871, Route: CDG ? YYZ, Status: COMPLETED (on time) � AC operated
? Segment 2: Flight: WS 3421, Route: YYZ ? YOW, Status: ARRIVED LATE, Delay: +4H 00M � WestJet operated (OAL, non-Star Alliance)
? MSL = Segment 2 (WS 3421 � WestJet, OAL)
? Regime: EU 261 (EU origin � CDG)
? MSL Operating Carrier: WestJet (WS) � NOT Star Alliance (unlike TC_142 where Lufthansa = Star Alliance ? StarQuest)
? OAL Data: NOT AVAILABLE (WestJet does not share disruption codes with AC)
? Arrival Code (WS 3421): NULL (OAL data not shared)
? Departure Code (WS 3421): NULL (OAL data not shared)
? 14-Day Retry Window: EXHAUSTED
? Case Status: System Processing Queue ? 14 days exhausted ? ESCALATED TO AGENT
? NOTE: Differs from ND-02/TC_142 (Star Alliance ? StarQuest immediate). Here, non-Star Alliance OAL ? system polls for 14 days ? then escalates.
Flight Compensation:
? [PASSENGER] | NO DETERMINATION | OAL_DATA_NOT_AVAILABLE_14_DAYS | PENDING AGENT REVIEW
CASE STATUS UPDATE:
Then the system updates the case status from "System Processing Queue" to "Pending Agent Review"
And the system records: 14-day retry window exhausted, OAL data not available (WestJet WS 3421), non-Star Alliance carrier
And the case is routed to the manual review agent queue
NOTIFICATION � ESCALATION EMAIL (Adobe):
Then the system triggers notification via Adobe:
And a No Determination notification email is sent to the customer's email on file
And the email contains:
Subject: "Update on your Air Canada claim � [Case Reference]"
Case Reference number
Flight details (Leg 1: CDG?YYZ AC completed; Leg 2: YYZ?YOW WestJet delayed 4h)
Status: "Your claim is currently under review by our Customer Relations team. We require additional time to assess your eligibility as this involves coordination with another airline."
Expected timeline for agent review
Contact information for further questions
NO CHATBOT INTERACTION (customer does not return to chatbot � result pending agent review)

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for PNR "TC115" under EU 261 EU origin CDG
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the Case Status should be "Pending Agent Review" escalated from System Processing Queue after 14 days
    And the Last Updated date should be Day 14
    And the Team assignment should be "Manual Review Agent Queue"
    And the Journey should show "Segment 1: CDG ? YYZ" as completed and AC operated and "Segment 2: YYZ ? YOW" arrived late plus 4h and WestJet WS 3421 operated as OAL Non-Star Alliance
    And the MSL should be Segment 2 WestJet as non-Star Alliance OAL
    And this should differ from TC142 where Star Alliance results in immediate StarQuest routing whereas here non-Star OAL means system polls for 14 days then escalates
    And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "OAL data not available � WestJet does not share disruption codes with AC; 14-day retry exhausted"
    And RE should have polled on Days 1, 3, 7, 10, and 14 and all returned WestJet data NOT AVAILABLE
    And the 14-Day Retry Window should be exhausted
    And the determination should be "NO DETERMINATION" escalated to agent
    And the Case Status History should show Created then System Processing Queue then Day 14 Pending Agent Review escalated due to OAL data not available
    And an escalation email should have been sent to the customer's email on file containing Case Reference and Leg 1 CDG to YYZ AC completed and Leg 2 YYZ to YOW WestJet delayed 4h and status under review and coordination with another airline note
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
DDS returns FD-EU-ND-05. Trip Tracer: Leg 1 = Operated (AC); Leg 2 = Arrived 4hrs late (LH, partial data); MSL = Leg 2; Carrier = LH; Flight status = available (4hr delay); Disruption codes = NULL (missing from partner feed); Partial data � delay known but cause unknown. CRITICAL: DDS knows the delay exceeds threshold but cannot determine if cause was controllable or extraordinary without disruption codes. Partial partner data is insufficient for full determination. Claims Dashboard: No Determination; Reason = Partial OAL data (flight status only, no codes); Delay observed = 4hrs; Cause = Unknown; EU 261; DDS = FD-EU-ND-05.