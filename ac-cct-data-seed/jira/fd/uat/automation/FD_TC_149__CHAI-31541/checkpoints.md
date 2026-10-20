# FD_TC_149 · CHAI-31541 — checkpoints

**Goal:** EU-originating journey where the disrupted leg is operated by a Star Alliance partner. SOME data has arrived (flight status showing delay) but the disruption codes are missing from the partner's data feed. DDS has partial information � knows THAT the delay occurred but not WHY. Validates that DDS handles partial partner data correctly under EU 261.

Methods: seed 6, chat 7, api 16, email 3, dashboard 13, implied 8, manual 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | EU-originating journey where the disrupted leg is operated by a Star Alliance partner. SOME data has arrived (flight status showing delay) b |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Reginald Thornton), 2 legs LHR?FRA?MUC | PNR: Single passenger (Reginald Thornton), 2 legs LHR?FRA?MUC |
| CP003 | PREREQUISITES | prerequisite | seed | Leg 1 (LHR?FRA): AC operated, on time | Leg 1 (LHR?FRA): AC operated, on time |
| CP004 | PREREQUISITES | prerequisite | seed | Leg 2 (FRA?MUC): Operated by Lufthansa (LH) | Leg 2 (FRA?MUC): Operated by Lufthansa (LH) |
| CP005 | PREREQUISITES | prerequisite | seed | Lufthansa data received: Flight status = arrived 4hrs late (partial data) | Lufthansa data received: Flight status = arrived 4hrs late (partial data) |
| CP006 | PREREQUISITES | prerequisite | seed | Lufthansa data missing: Disruption codes = NULL (not included in data feed) | Lufthansa data missing: Disruption codes = NULL (not included in data feed) |
| CP007 | PREREQUISITES | prerequisite | seed | Route context: LHR = UK origin ? EU 261 applies | Route context: LHR = UK origin ? EU 261 applies |
| CP008 | BACKGROUND | system | implied | Given a case was previously created for PNR: TC115 |  |
| CP009 | BACKGROUND | system | implied | And the case was placed in the System Processing Queue (case previously filed via chatbot, all identification/authentication/journey selecti |  |
| CP010 | BACKGROUND | system | implied | And 72 hours have elapsed since last leg arrival |  |
| CP011 | BACKGROUND | system | implied | And the Rules Engine attempted to retrieve disruption data from OAL (WestJet) |  |
| CP012 | OAL DATA RETRIEVAL | system | implied | Then the system attempts to retrieve disruption data from WestJet on a scheduled basis | Day 1: RE queries OAL data feed ? WestJet data: NOT AVAILABLE ? retry Day 3: RE retries ? WestJet data: NOT AVAILABLE ? retry Day 7: RE retries ? WestJet data:  |
| CP013 | TRIP TRACER UI VALIDATION | verdict | api | Segment 1: Flight: AC 871, Route: CDG ? YYZ, Status: COMPLETED (on time) � AC operated | Segment 1: Flight: AC 871, Route: CDG ? YYZ, Status: COMPLETED (on time) � AC operated |
| CP014 | TRIP TRACER UI VALIDATION | verdict | api | Segment 2: Flight: WS 3421, Route: YYZ ? YOW, Status: ARRIVED LATE, Delay: +4H 00M � WestJet operated (OAL, non-Star Alliance) | Segment 2: Flight: WS 3421, Route: YYZ ? YOW, Status: ARRIVED LATE, Delay: +4H 00M � WestJet operated (OAL, non-Star Alliance) |
| CP015 | TRIP TRACER UI VALIDATION | verdict | api | MSL = Segment 2 (WS 3421 � WestJet, OAL) | MSL = Segment 2 (WS 3421 � WestJet, OAL) |
| CP016 | TRIP TRACER UI VALIDATION | verdict | api | Regime: EU 261 (EU origin � CDG) | Regime: EU 261 (EU origin � CDG) |
| CP017 | TRIP TRACER UI VALIDATION | verdict | api | MSL Operating Carrier: WestJet (WS) � NOT Star Alliance (unlike TC_142 where Lufthansa = Star Alliance ? StarQuest) | MSL Operating Carrier: WestJet (WS) � NOT Star Alliance (unlike TC_142 where Lufthansa = Star Alliance ? StarQuest) |
| CP018 | TRIP TRACER UI VALIDATION | verdict | api | OAL Data: NOT AVAILABLE (WestJet does not share disruption codes with AC) | OAL Data: NOT AVAILABLE (WestJet does not share disruption codes with AC) |
| CP019 | TRIP TRACER UI VALIDATION | verdict | api | Arrival Code (WS 3421): NULL (OAL data not shared) | Arrival Code (WS 3421): NULL (OAL data not shared) |
| CP020 | TRIP TRACER UI VALIDATION | verdict | api | Departure Code (WS 3421): NULL (OAL data not shared) | Departure Code (WS 3421): NULL (OAL data not shared) |
| CP021 | TRIP TRACER UI VALIDATION | verdict | api | 14-Day Retry Window: EXHAUSTED | 14-Day Retry Window: EXHAUSTED |
| CP022 | TRIP TRACER UI VALIDATION | verdict | api | Case Status: System Processing Queue ? 14 days exhausted ? ESCALATED TO AGENT | Case Status: System Processing Queue ? 14 days exhausted ? ESCALATED TO AGENT |
| CP023 | TRIP TRACER UI VALIDATION | verdict | api | NOTE: Differs from ND-02/TC_142 (Star Alliance ? StarQuest immediate). Here, non-Star Alliance OAL ? system polls for 14 days ? then escalat | NOTE: Differs from ND-02/TC_142 (Star Alliance ? StarQuest immediate). Here, non-Star Alliance OAL ? system polls for 14 days ? then escalates. |
| CP024 | TRIP TRACER UI VALIDATION | verdict | api | [PASSENGER] / NO DETERMINATION / OAL_DATA_NOT_AVAILABLE_14_DAYS / PENDING AGENT REVIEW | [PASSENGER] / NO DETERMINATION / OAL_DATA_NOT_AVAILABLE_14_DAYS / PENDING AGENT REVIEW |
| CP025 | CASE STATUS UPDATE | system | implied | Then the system updates the case status from "System Processing Queue" to "Pending Agent Review" |  |
| CP026 | CASE STATUS UPDATE | system | implied | And the system records: 14-day retry window exhausted, OAL data not available (WestJet WS 3421), non-Star Alliance carrier |  |
| CP027 | CASE STATUS UPDATE | system | implied | And the case is routed to the manual review agent queue |  |
| CP028 | NOTIFICATION � ESCALATION EMAIL | email | email | Then the system triggers notification via Adobe: |  |
| CP029 | NOTIFICATION � ESCALATION EMAIL | email | email | And a No Determination notification email is sent to the customer's email on file |  |
| CP030 | NOTIFICATION � ESCALATION EMAIL | email | email | And the email contains: | Update on your Air Canada claim � [Case Reference] Your claim is currently under review by our Customer Relations team. We require additional time to assess you |
| CP031 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for PNR "TC115" under EU 261 EU origin CDG |  |
| CP032 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP033 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Pending Agent Review" escalated from System Processing Queue after 14 days |  |
| CP034 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be Day 14 |  |
| CP035 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "Manual Review Agent Queue" |  |
| CP036 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: CDG ? YYZ" as completed and AC operated and "Segment 2: YYZ ? YOW" arrived late plus 4h and WestJet  |  |
| CP037 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the MSL should be Segment 2 WestJet as non-Star Alliance OAL |  |
| CP038 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And this should differ from TC142 where Star Alliance results in immediate StarQuest routing whereas here non-Star OAL means system polls fo |  |
| CP039 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "OAL data not available � WestJet doe |  |
| CP040 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And RE should have polled on Days 1, 3, 7, 10, and 14 and all returned WestJet data NOT AVAILABLE |  |
| CP041 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the 14-Day Retry Window should be exhausted |  |
| CP042 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the determination should be "NO DETERMINATION" escalated to agent |  |
| CP043 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status History should show Created then System Processing Queue then Day 14 Pending Agent Review escalated due to OAL data not  |  |
| CP044 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an escalation email should have been sent to the customer's email on file containing Case Reference and Leg 1 CDG to YYZ AC completed an |  |
| CP045 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP046 | PAYMENT VALIDATION | payment | chat | Given no determination was made due to OAL data not available after 14-day retry |  |
| CP047 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP048 | PAYMENT VALIDATION | payment | chat | And the case was created and sent to agent for manual handling |  |
| CP049 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP050 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP051 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP052 | PAYMENT VALIDATION | payment | manual | And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e- |  |
| CP053 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved |  |
| CP054 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-ND-05. | DDS returns FD-EU-ND-05. |
| CP055 | EXPECTED RESULTS | verdict | api | Trip Tracer: Leg 1 = Operated (AC); Leg 2 = Arrived 4hrs late (LH, partial data); MSL = Leg 2; Carrier = LH; Flight status = available (4hr  | Trip Tracer: Leg 1 = Operated (AC); Leg 2 = Arrived 4hrs late (LH, partial data); MSL = Leg 2; Carrier = LH; Flight status = available (4hr delay); Disruption c |
| CP056 | EXPECTED RESULTS | verdict | api | CRITICAL: DDS knows the delay exceeds threshold but cannot determine if cause was controllable or extraordinary without disruption codes. | CRITICAL: DDS knows the delay exceeds threshold but cannot determine if cause was controllable or extraordinary without disruption codes. |
| CP057 | EXPECTED RESULTS | verdict | chat | Partial partner data is insufficient for full determination. | Partial partner data is insufficient for full determination. |
| CP058 | EXPECTED RESULTS | verdict | api | Claims Dashboard: No Determination; Reason = Partial OAL data (flight status only, no codes); Delay observed = 4hrs; Cause = Unknown; EU 261 | Claims Dashboard: No Determination; Reason = Partial OAL data (flight status only, no codes); Delay observed = 4hrs; Cause = Unknown; EU 261; DDS = FD-EU-ND-05. |
