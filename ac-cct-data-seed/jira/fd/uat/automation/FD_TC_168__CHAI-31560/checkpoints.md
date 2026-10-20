# FD_TC_168 · CHAI-31560 — checkpoints

**Goal:** Israel-route flight was disrupted but NO disruption code (arrival, departure, or cancellation) has been assigned after the full 14-day polling window. The flight data (times, status) may be partially available, but without a disruption code, DDS cannot determine controllability � and controllability is required for eligibility assessment. Different from ND-05 (ALL data missing) � here some data exists but the critical CODE is absent. Case routed for agent review.

Methods: seed 6, chat 8, api 17, email 3, dashboard 17, implied 7, manual 5, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Israel-route flight was disrupted but NO disruption code (arrival, departure, or cancellation) has been assigned after the full 14-day polli |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger | PNR: Single passenger |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: Israel route (AC operated) | Journey: Israel route (AC operated) |
| CP004 | PREREQUISITES | prerequisite | seed | Flight data: Partially available (times may exist) | Flight data: Partially available (times may exist) |
| CP005 | PREREQUISITES | prerequisite | seed | Disruption codes: ALL NULL � arrival code, departure code, cancellation code = MISSING after 14-day polling | Disruption codes: ALL NULL � arrival code, departure code, cancellation code = MISSING after 14-day polling |
| CP006 | PREREQUISITES | prerequisite | seed | 14-day retry: EXHAUSTED | 14-day retry: EXHAUSTED |
| CP007 | PREREQUISITES | prerequisite | seed | Regime: ASL applicable | Regime: ASL applicable |
| CP008 | BACKGROUND | system | implied | Given a case was previously created for PNR: TC142 |  |
| CP009 | BACKGROUND | system | implied | And the case was placed in the System Processing Queue (case previously filed via chatbot, all identification/authentication/journey selecti |  |
| CP010 | BACKGROUND | system | implied | And 72 hours have elapsed since last leg arrival |  |
| CP011 | DDS POLLING | system | implied | Then the system polls for disruption codes on a scheduled basis | Day 1: DDS runs ? Arrival code: NULL, Departure code: NULL ? NO DETERMINATION ? retry Day 3: DDS retries ? Arrival code: NULL, Departure code: NULL ? NO DETERMI |
| CP012 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 084, Route: TLV ? YYZ, Scheduled Arrival: 16:00 | Promised Itinerary - Flight: AC 084, Route: TLV ? YYZ, Scheduled Arrival: 16:00 |
| CP013 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 084, Route: TLV ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 16:00 ? Actual: 20:00, Delay: +4H 00M | Current Itinerary - Flight: AC 084, Route: TLV ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 16:00 ? Actual: 20:00, Delay: +4H 00M |
| CP014 | TRIP TRACER UI VALIDATION | verdict | api | Regime: ASL (Israel) (Israel origin � TLV) | Regime: ASL (Israel) (Israel origin � TLV) |
| CP015 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 084 � TLV ? YYZ � NO CODE | MSL FLIGHT: AC 084 � TLV ? YYZ � NO CODE |
| CP016 | TRIP TRACER UI VALIDATION | verdict | api | Arrival Code: NULL (after 14 days) | Arrival Code: NULL (after 14 days) |
| CP017 | TRIP TRACER UI VALIDATION | verdict | api | Departure Code: NULL (after 14 days) | Departure Code: NULL (after 14 days) |
| CP018 | TRIP TRACER UI VALIDATION | verdict | api | Cancellation Code: NULL (after 14 days) | Cancellation Code: NULL (after 14 days) |
| CP019 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: ATTEMPTED ? ALL CODES NULL ? NO FALLBACK AVAILABLE | Fallback: ATTEMPTED ? ALL CODES NULL ? NO FALLBACK AVAILABLE |
| CP020 | TRIP TRACER UI VALIDATION | verdict | api | 14-Day Retry Window: EXHAUSTED | 14-Day Retry Window: EXHAUSTED |
| CP021 | TRIP TRACER UI VALIDATION | verdict | api | Case Status: System Processing Queue ? 14 days exhausted ? ESCALATED TO CR AGENT | Case Status: System Processing Queue ? 14 days exhausted ? ESCALATED TO CR AGENT |
| CP022 | TRIP TRACER UI VALIDATION | verdict | api | MR/MS [PASSENGER] / NO DETERMINATION / NO_CODE_14_DAYS / PENDING CR AGENT | MR/MS [PASSENGER] / NO DETERMINATION / NO_CODE_14_DAYS / PENDING CR AGENT |
| CP023 | CASE STATUS UPDATE | system | implied | Then the system updates the case status from "System Processing Queue" to "Pending Agent Review" |  |
| CP024 | CASE STATUS UPDATE | system | implied | And the system records: 14-day retry window exhausted, no disruption code available |  |
| CP025 | CASE STATUS UPDATE | system | implied | And the case is routed to the Customer Relations (CR) agent queue |  |
| CP026 | NOTIFICATION � ESCALATION EMAIL | email | email | Then the system triggers notification via Adobe: |  |
| CP027 | NOTIFICATION � ESCALATION EMAIL | email | email | And a No Determination notification email is sent to the customer's email on file |  |
| CP028 | NOTIFICATION � ESCALATION EMAIL | email | email | And the email contains: | Update on your Air Canada claim � [Case Reference] Your claim is currently under review by our Customer Relations team. We require additional time to assess you |
| CP029 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for PNR "TC142" under ASL Israel origin TLV |  |
| CP030 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP031 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Pending Agent Review" escalated from System Processing Queue after 14 days |  |
| CP032 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated as the original case creation date |  |
| CP033 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be Day 14 as the date of final retry and escalation |  |
| CP034 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP035 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "Customer Relations (CR) Agent Queue" |  |
| CP036 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel status should reflect NO DETERMINATION after 14-day exhaustion |  |
| CP037 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: TLV ? YYZ" arrived late plus 4h |  |
| CP038 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "No disruption code after 14 days � a |  |
| CP039 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have polled on Days 1, 3, 7, 10, and 14 and all returned NULL codes |  |
| CP040 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And fallback should have been attempted but ALL CODES NULL with NO FALLBACK AVAILABLE |  |
| CP041 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the 14-Day Retry Window should be exhausted |  |
| CP042 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the determination should be "NO DETERMINATION" escalated to CR agent |  |
| CP043 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically and the result should be "No duplicate found" |  |
| CP044 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered |  |
| CP045 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the booking should have been appended at original case creation |  |
| CP046 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status History should show Created then System Processing Queue then Day 14 Pending Agent Review escalated |  |
| CP047 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an escalation email should have been sent to the customer's email on file containing Case Reference and flight details AC 084 TLV to YYZ |  |
| CP048 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP049 | PAYMENT VALIDATION | payment | chat | Given no determination was made due to no disruption code after 14-day retry |  |
| CP050 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP051 | PAYMENT VALIDATION | payment | chat | And the case was created and sent to agent for manual handling |  |
| CP052 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP053 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP054 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP055 | PAYMENT VALIDATION | payment | manual | And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e- |  |
| CP056 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved |  |
| CP057 | EXPECTED RESULTS | verdict | api | DDS returns FD-ASL-ND-04. | DDS returns FD-ASL-ND-04. |
| CP058 | EXPECTED RESULTS | verdict | api | Trip Tracer: Flight times may be partially available; Arrival Code = NULL; Departure Code = NULL; Cancellation Code = NULL; ALL codes MISSIN | Trip Tracer: Flight times may be partially available; Arrival Code = NULL; Departure Code = NULL; Cancellation Code = NULL; ALL codes MISSING after 14-day polli |
| CP059 | EXPECTED RESULTS | verdict | api | No Determination: Delay exists but without a code, DDS cannot classify controllability (controllable vs extraordinary) ? cannot determine el | No Determination: Delay exists but without a code, DDS cannot classify controllability (controllable vs extraordinary) ? cannot determine eligibility. |
| CP060 | EXPECTED RESULTS | verdict | api | Case Routing: Agent review � agent must investigate the disruption cause through operations team, assign a code, then re-run DDS. | Case Routing: Agent review � agent must investigate the disruption cause through operations team, assign a code, then re-run DDS. |
| CP061 | EXPECTED RESULTS | verdict | chat | Compensation: NOT CALCULATED. | Compensation: NOT CALCULATED. |
| CP062 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP063 | EXPECTED RESULTS | verdict | api | Regime Assessment: ASL = ND-04 (No code after 14 days). | Regime Assessment: ASL = ND-04 (No code after 14 days). |
| CP064 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Status = No Determination; Reason = No disruption code after 14-day polling; Agent Action = "Contact operations for code a | Claims Dashboard: Status = No Determination; Reason = No disruption code after 14-day polling; Agent Action = "Contact operations for code assignment, then re-r |
