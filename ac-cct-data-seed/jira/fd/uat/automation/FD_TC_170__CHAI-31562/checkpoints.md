# FD_TC_170 · CHAI-31562 — checkpoints

**Goal:** Israel-destination multi-leg (YYZ?FRA?TLV). AC leg (Leg 1 YYZ?FRA) completed on time. OAL leg (Leg 2 LH 694 FRA?TLV, Lufthansa operated) was disrupted but Lufthansa's flight data has NOT been received through OAG feeds within the 14-day window. AC's own data is complete but the partner airline's data is unavailable. Without OAL timing data, DDS cannot determine actual arrival at TLV or whether the delay was caused by AC or Lufthansa. ASL counterpart to APPR TC_073 (ND-06) and EU TC_145 equivalent.

Methods: seed 8, chat 11, api 17, email 3, dashboard 14, implied 8, manual 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Israel-destination multi-leg (YYZ?FRA?TLV). AC leg (Leg 1 YYZ?FRA) completed on time. OAL leg (Leg 2 LH 694 FRA?TLV, Lufthansa operated) was |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Shira Abramov (Adult) | PNR: single passenger Shira Abramov (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 2 legs: Leg 1 AC 873 YYZ?FRA (AC operated � data AVAILABLE, on time); Leg 2 LH 694 FRA?TLV (Lufthansa operated � data NOT AVAILABLE | Journey: 2 legs: Leg 1 AC 873 YYZ?FRA (AC operated � data AVAILABLE, on time); Leg 2 LH 694 FRA?TLV (Lufthansa operated � data NOT AVAILABLE) |
| CP004 | PREREQUISITES | prerequisite | seed | MSL: Leg 2 (OAL, disrupted, data missing) | MSL: Leg 2 (OAL, disrupted, data missing) |
| CP005 | PREREQUISITES | prerequisite | seed | AC leg data: Complete | AC leg data: Complete |
| CP006 | PREREQUISITES | prerequisite | seed | OAL leg data: NOT RECEIVED from OAG feeds within 14-day window (data-sharing gap for this specific flight) | OAL leg data: NOT RECEIVED from OAG feeds within 14-day window (data-sharing gap for this specific flight) |
| CP007 | PREREQUISITES | prerequisite | seed | 14-day retry: EXHAUSTED | 14-day retry: EXHAUSTED |
| CP008 | PREREQUISITES | prerequisite | seed | Regime: ASL (TLV destination) + APPR | Regime: ASL (TLV destination) + APPR |
| CP009 | PREREQUISITES | prerequisite | seed | Residence: Israel | Residence: Israel |
| CP010 | BACKGROUND | system | implied | Given a case was previously created for PNR: TC144 |  |
| CP011 | BACKGROUND | system | implied | And the case was placed in the System Processing Queue (case previously filed via chatbot, all identification/authentication/journey selecti |  |
| CP012 | BACKGROUND | system | implied | And 72 hours have elapsed since last leg arrival |  |
| CP013 | BACKGROUND | system | implied | And the Rules Engine attempted to retrieve disruption data from OAL (Lufthansa LH 694) |  |
| CP014 | OAL DATA RETRIEVAL | system | implied | Then the system attempts to retrieve disruption data from Lufthansa on a scheduled basis | Day 1: RE queries OAL data feed ? Lufthansa LH 694 data: NOT AVAILABLE ? retry Day 3: RE retries ? Lufthansa LH 694 data: NOT AVAILABLE ? retry Day 7: RE retrie |
| CP015 | TRIP TRACER UI VALIDATION | verdict | api | Segment 1: Flight: AC 873, Route: YYZ ? FRA, Status: COMPLETED (on time) � AC operated | Segment 1: Flight: AC 873, Route: YYZ ? FRA, Status: COMPLETED (on time) � AC operated |
| CP016 | TRIP TRACER UI VALIDATION | verdict | api | Segment 2: Flight: LH 694, Route: FRA ? TLV, Status: ARRIVED LATE, Delay: +4H 00M � Lufthansa operated (OAL) | Segment 2: Flight: LH 694, Route: FRA ? TLV, Status: ARRIVED LATE, Delay: +4H 00M � Lufthansa operated (OAL) |
| CP017 | TRIP TRACER UI VALIDATION | verdict | api | MSL = Segment 2 (LH 694 � Lufthansa, OAL) | MSL = Segment 2 (LH 694 � Lufthansa, OAL) |
| CP018 | TRIP TRACER UI VALIDATION | verdict | api | Regime: ASL (Israel) (Israel destination � TLV) | Regime: ASL (Israel) (Israel destination � TLV) |
| CP019 | TRIP TRACER UI VALIDATION | verdict | api | Destination: TLV (Israel) | Destination: TLV (Israel) |
| CP020 | TRIP TRACER UI VALIDATION | verdict | api | MSL Operating Carrier: Lufthansa (LH) � Star Alliance partner, but data unavailable for this specific flight | MSL Operating Carrier: Lufthansa (LH) � Star Alliance partner, but data unavailable for this specific flight |
| CP021 | TRIP TRACER UI VALIDATION | verdict | api | OAL Data: NOT AVAILABLE (Lufthansa did not share disruption data for LH 694) | OAL Data: NOT AVAILABLE (Lufthansa did not share disruption data for LH 694) |
| CP022 | TRIP TRACER UI VALIDATION | verdict | api | Arrival Code (LH 694): NULL (OAL data not shared) | Arrival Code (LH 694): NULL (OAL data not shared) |
| CP023 | TRIP TRACER UI VALIDATION | verdict | api | Departure Code (LH 694): NULL (OAL data not shared) | Departure Code (LH 694): NULL (OAL data not shared) |
| CP024 | TRIP TRACER UI VALIDATION | verdict | api | 14-Day Retry Window: EXHAUSTED | 14-Day Retry Window: EXHAUSTED |
| CP025 | TRIP TRACER UI VALIDATION | verdict | api | Case Status: System Processing Queue ? 14 days exhausted ? ESCALATED TO AGENT | Case Status: System Processing Queue ? 14 days exhausted ? ESCALATED TO AGENT |
| CP026 | TRIP TRACER UI VALIDATION | verdict | api | NOTE: Even though Lufthansa is Star Alliance, the specific flight data was unavailable � this is a data sharing issue, not a carrier classif | NOTE: Even though Lufthansa is Star Alliance, the specific flight data was unavailable � this is a data sharing issue, not a carrier classification issue |
| CP027 | TRIP TRACER UI VALIDATION | verdict | api | [PASSENGER] / NO DETERMINATION / OAL_DATA_NOT_AVAILABLE_14_DAYS / PENDING AGENT REVIEW | [PASSENGER] / NO DETERMINATION / OAL_DATA_NOT_AVAILABLE_14_DAYS / PENDING AGENT REVIEW |
| CP028 | CASE STATUS UPDATE | system | implied | Then the system updates the case status from "System Processing Queue" to "Pending Agent Review" |  |
| CP029 | CASE STATUS UPDATE | system | implied | And the system records: 14-day retry window exhausted, OAL data not available (Lufthansa LH 694), data sharing issue |  |
| CP030 | CASE STATUS UPDATE | system | implied | And the case is routed to the manual review agent queue |  |
| CP031 | NOTIFICATION � ESCALATION EMAIL | email | email | Then the system triggers notification via Adobe: |  |
| CP032 | NOTIFICATION � ESCALATION EMAIL | email | email | And a No Determination notification email is sent to the customer's email on file |  |
| CP033 | NOTIFICATION � ESCALATION EMAIL | email | email | And the email contains: | Update on your Air Canada claim � [Case Reference] Your claim is currently under review by our Customer Relations team. We require additional time to assess you |
| CP034 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for PNR "TC144" under ASL Israel destination TLV |  |
| CP035 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP036 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Pending Agent Review" escalated from System Processing Queue after 14 days |  |
| CP037 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be Day 14 |  |
| CP038 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "Manual Review Agent Queue" |  |
| CP039 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: YYZ ? FRA" as completed and AC operated and "Segment 2: FRA ? TLV" arrived late plus 4h and Lufthans |  |
| CP040 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the MSL should be Segment 2 Lufthansa LH 694 as OAL |  |
| CP041 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And even though Lufthansa is Star Alliance the specific flight data was unavailable as this is a data sharing issue not a carrier classifica |  |
| CP042 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And this should differ from TC183 where Star Alliance results in immediate StarQuest routing based on carrier identity whereas here the syst |  |
| CP043 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "OAL data not available � Lufthansa d |  |
| CP044 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And RE should have polled on Days 1, 3, 7, 10, and 14 and all returned Lufthansa LH 694 data NOT AVAILABLE |  |
| CP045 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the 14-Day Retry Window should be exhausted |  |
| CP046 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the determination should be "NO DETERMINATION" escalated to agent |  |
| CP047 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status History should show Created then System Processing Queue then Day 14 Pending Agent Review escalated due to OAL data not  |  |
| CP048 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an escalation email should have been sent to the customer's email on file containing Case Reference and Leg 1 YYZ to FRA AC completed an |  |
| CP049 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP050 | PAYMENT VALIDATION | payment | chat | Given no determination was made due to OAL data not available after 14-day retry |  |
| CP051 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP052 | PAYMENT VALIDATION | payment | chat | And the case was created and sent to agent for manual handling |  |
| CP053 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP054 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP055 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP056 | PAYMENT VALIDATION | payment | manual | And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e- |  |
| CP057 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved |  |
| CP058 | EXPECTED RESULTS | verdict | api | DDS returns FD-ASL-ND-06. | DDS returns FD-ASL-ND-06. |
| CP059 | EXPECTED RESULTS | verdict | api | Trip Tracer: Leg 1 (AC YYZ?FRA) = Data AVAILABLE (on time); Leg 2 (LH FRA?TLV) = Data NOT AVAILABLE (OAG feed gap); MSL = Leg 2 (OAL, disrup | Trip Tracer: Leg 1 (AC YYZ?FRA) = Data AVAILABLE (on time); Leg 2 (LH FRA?TLV) = Data NOT AVAILABLE (OAG feed gap); MSL = Leg 2 (OAL, disrupted); Final arrival  |
| CP060 | EXPECTED RESULTS | verdict | chat | OAL Data Check: OAG feed for LH 694 = NOT RECEIVED; 14-day window exhausted ? NO DETERMINATION. | OAL Data Check: OAG feed for LH 694 = NOT RECEIVED; 14-day window exhausted ? NO DETERMINATION. |
| CP061 | EXPECTED RESULTS | verdict | chat | Case Routing: Manual handling � 30-day SLA. | Case Routing: Manual handling � 30-day SLA. |
| CP062 | EXPECTED RESULTS | verdict | chat | Agent must request OAL data manually from Lufthansa. | Agent must request OAL data manually from Lufthansa. |
| CP063 | EXPECTED RESULTS | verdict | chat | Compensation: NOT CALCULATED. | Compensation: NOT CALCULATED. |
| CP064 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP065 | EXPECTED RESULTS | verdict | api | Regime Assessment: ASL = ND-06 (OAL data unavailable, Lufthansa); APPR = ND (same gap); EU = assessed separately. | Regime Assessment: ASL = ND-06 (OAL data unavailable, Lufthansa); APPR = ND (same gap); EU = assessed separately. |
| CP066 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Case = CASE-FD-20260528-206; Status = Pending � Manual Investigation; MSL = Leg 2 (LH 694 FRA?TLV); OAL = Lufthansa (data  | Claims Dashboard: Case = CASE-FD-20260528-206; Status = Pending � Manual Investigation; MSL = Leg 2 (LH 694 FRA?TLV); OAL = Lufthansa (data gap); 30-day SLA act |
