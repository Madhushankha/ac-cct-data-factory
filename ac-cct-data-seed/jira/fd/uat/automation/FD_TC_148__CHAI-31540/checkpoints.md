# FD_TC_148 · CHAI-31540 — checkpoints

**Goal:** EU-originating flight (CDG?YYZ) was disrupted but critical MSL data is MISSING from backend � operating times, flight number details, and ALL disruption codes (arrival, departure, cancellation) are unavailable. DDS cannot calculate delay, determine controllability, or assess any regime. The system retries daily for 14 days (automatic polling). After 14 days with no data, the case is forwarded for manual handling with a 30-day SLA. This is the EU counterpart to APPR TC_072 (ND-05). Validates: (1) All three code types missing simultaneously triggers ND, (2) 14-day retry window is exhausted before ND is declared, (3) Manual handling includes 30-day SLA and agent action items.

Methods: seed 9, chat 11, api 19, email 3, dashboard 12, implied 5, manual 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | EU-originating flight (CDG?YYZ) was disrupted but critical MSL data is MISSING from backend � operating times, flight number details, and AL |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Fran�ois Girard (Adult) | PNR: single passenger Fran�ois Girard (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 879, CDG?YYZ | Journey: 1 leg AC operated, Flight AC 879, CDG?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Flight date: May 5, 2026 | Flight date: May 5, 2026 |
| CP005 | PREREQUISITES | prerequisite | seed | Trip Tracer data status: INCOMPLETE � actual arrival time NOT populated; operating times MISSING; ALL codes (arrival, departure, cancellatio | Trip Tracer data status: INCOMPLETE � actual arrival time NOT populated; operating times MISSING; ALL codes (arrival, departure, cancellation) = NULL |
| CP006 | PREREQUISITES | prerequisite | seed | Scheduled arrival: Available (from booking) | Scheduled arrival: Available (from booking) |
| CP007 | PREREQUISITES | prerequisite | seed | Actual arrival: MISSING | Actual arrival: MISSING |
| CP008 | PREREQUISITES | prerequisite | seed | 14-day retry window: EXHAUSTED (May 8�May 22, all polls returned "data missing") | 14-day retry window: EXHAUSTED (May 8�May 22, all polls returned "data missing") |
| CP009 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (CDG = EU origin) + APPR (YYZ = Canada) | Regime: EU 261 (CDG = EU origin) + APPR (YYZ = Canada) |
| CP010 | PREREQUISITES | prerequisite | seed | Filing date: May 28, 2026 (23 days post-disruption) | Filing date: May 28, 2026 (23 days post-disruption) |
| CP011 | BACKGROUND | system | implied | Given a case was previously created for PNR: TC145 |  |
| CP012 | BACKGROUND | system | implied | And the case was placed in the System Processing Queue (case previously filed via chatbot, all identification/authentication/journey selecti |  |
| CP013 | BACKGROUND | system | implied | And 72 hours have elapsed since last leg arrival |  |
| CP014 | BACKGROUND | verdict | api | And the Rules Engine attempted to retrieve MSL data from backend systems |  |
| CP015 | MSL DATA RETRIEVAL | verdict | api | Then the system attempts to retrieve critical MSL data on a scheduled basis | Day 1: RE queries backend ? Operating times: NULL, Flight number: NULL ? CRITICAL DATA MISSING ? retry Day 3: RE retries ? Operating times: NULL, Flight number: |
| CP016 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: MISSING (flight number not available in backend), Route: CDG ? YYZ | Promised Itinerary - Flight: MISSING (flight number not available in backend), Route: CDG ? YYZ |
| CP017 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Status: DISRUPTED (details incomplete) | Current Itinerary - Status: DISRUPTED (details incomplete) |
| CP018 | TRIP TRACER UI VALIDATION | verdict | api | Customer Status: Travel Completed (filed after travel) | Customer Status: Travel Completed (filed after travel) |
| CP019 | TRIP TRACER UI VALIDATION | verdict | api | Regime: EU 261 (EU origin � CDG) | Regime: EU 261 (EU origin � CDG) |
| CP020 | TRIP TRACER UI VALIDATION | verdict | api | MSL DATA: CRITICAL DATA MISSING | MSL DATA: CRITICAL DATA MISSING |
| CP021 | TRIP TRACER UI VALIDATION | verdict | api | Operating Times: NULL (after 14 days) | Operating Times: NULL (after 14 days) |
| CP022 | TRIP TRACER UI VALIDATION | verdict | api | Flight Number: NULL (after 14 days � backend unable to resolve) | Flight Number: NULL (after 14 days � backend unable to resolve) |
| CP023 | TRIP TRACER UI VALIDATION | verdict | api | Disruption Code: CANNOT BE ASSESSED (no MSL flight identified) | Disruption Code: CANNOT BE ASSESSED (no MSL flight identified) |
| CP024 | TRIP TRACER UI VALIDATION | verdict | api | 14-Day Retry Window: EXHAUSTED | 14-Day Retry Window: EXHAUSTED |
| CP025 | TRIP TRACER UI VALIDATION | verdict | api | Case Status: System Processing Queue ? 14 days exhausted ? ESCALATED TO AGENT | Case Status: System Processing Queue ? 14 days exhausted ? ESCALATED TO AGENT |
| CP026 | TRIP TRACER UI VALIDATION | verdict | api | NOTE: Unlike ND-04 (codes missing), here the structural flight data itself is absent � RE cannot even identify which flight to query codes f | NOTE: Unlike ND-04 (codes missing), here the structural flight data itself is absent � RE cannot even identify which flight to query codes for |
| CP027 | TRIP TRACER UI VALIDATION | verdict | api | [PASSENGER] / NO DETERMINATION / MSL_DATA_MISSING_14_DAYS / PENDING AGENT REVIEW | [PASSENGER] / NO DETERMINATION / MSL_DATA_MISSING_14_DAYS / PENDING AGENT REVIEW |
| CP028 | CASE STATUS UPDATE | system | implied | Then the system updates the case status from "System Processing Queue" to "Pending Agent Review" |  |
| CP029 | CASE STATUS UPDATE | verdict | api | And the system records: 14-day retry window exhausted, critical MSL data missing (operating times, flight number) |  |
| CP030 | CASE STATUS UPDATE | system | implied | And the case is routed to the manual review agent queue |  |
| CP031 | NOTIFICATION � ESCALATION EMAIL | email | email | Then the system triggers notification via Adobe: |  |
| CP032 | NOTIFICATION � ESCALATION EMAIL | email | email | And a No Determination notification email is sent to the customer's email on file |  |
| CP033 | NOTIFICATION � ESCALATION EMAIL | email | email | And the email contains: | Update on your Air Canada claim � [Case Reference] Your claim is currently under review by our Customer Relations team. We require additional time to assess you |
| CP034 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for PNR "TC145" under EU 261 EU origin CDG |  |
| CP035 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP036 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Pending Agent Review" escalated from System Processing Queue after 14 days |  |
| CP037 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be Day 14 |  |
| CP038 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "Manual Review Agent Queue" |  |
| CP039 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "CDG ? YYZ" as disrupted with details incomplete due to missing structural data |  |
| CP040 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the flight number and operating times should both be NULL meaning RE cannot even identify which flight to query codes for |  |
| CP041 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "Critical MSL data missing � operatin |  |
| CP042 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And RE should have polled on Days 1, 3, 7, 10, and 14 and all returned NULL for operating times and flight number |  |
| CP043 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the 14-Day Retry Window should be exhausted |  |
| CP044 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the determination should be "NO DETERMINATION" escalated to agent |  |
| CP045 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status History should show Created then System Processing Queue then Day 14 Pending Agent Review escalated due to MSL data miss |  |
| CP046 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an escalation email should have been sent to the customer's email on file containing Case Reference and limited flight details CDG to YY |  |
| CP047 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP048 | PAYMENT VALIDATION | payment | chat | Given no determination was made due to critical MSL data missing after 14-day retry |  |
| CP049 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP050 | PAYMENT VALIDATION | payment | chat | And the case was created and sent to agent for manual handling |  |
| CP051 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP052 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP053 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP054 | PAYMENT VALIDATION | payment | manual | And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e- |  |
| CP055 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved |  |
| CP056 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-ND-05. | DDS returns FD-EU-ND-05. |
| CP057 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = available (scheduled); Actual = MISSING; Arrival Code = NULL; Departure Code = NULL; Cancellation Code = NULL; ALL co | Trip Tracer: Promise = available (scheduled); Actual = MISSING; Arrival Code = NULL; Departure Code = NULL; Cancellation Code = NULL; ALL codes MISSING; Delay = |
| CP058 | EXPECTED RESULTS | verdict | chat | Data Completeness Check: All critical data points missing; 14-day retry exhausted; No additional data expected ? NO DETERMINATION. | Data Completeness Check: All critical data points missing; 14-day retry exhausted; No additional data expected ? NO DETERMINATION. |
| CP059 | EXPECTED RESULTS | verdict | chat | Case Routing: Manual handling � 30-day SLA (May 28 ? June 27, 2026). | Case Routing: Manual handling � 30-day SLA (May 28 ? June 27, 2026). |
| CP060 | EXPECTED RESULTS | verdict | chat | Agent must contact operations team for missing backend data. | Agent must contact operations team for missing backend data. |
| CP061 | EXPECTED RESULTS | verdict | chat | Compensation: NOT CALCULATED (pending manual review). | Compensation: NOT CALCULATED (pending manual review). |
| CP062 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP063 | EXPECTED RESULTS | verdict | api | Regime Assessment: EU 261 = ND-05 (data missing); APPR = ND (same data gap); ASL = N/A. | Regime Assessment: EU 261 = ND-05 (data missing); APPR = ND (same data gap); ASL = N/A. |
| CP064 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Case = CASE-FD-20260528-188; Status = Pending � Manual Investigation; Reason = MSL data missing after 14-day polling; 30-d | Claims Dashboard: Case = CASE-FD-20260528-188; Status = Pending � Manual Investigation; Reason = MSL data missing after 14-day polling; 30-day SLA active; Agent |
