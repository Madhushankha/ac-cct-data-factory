# FD_TC_169 · CHAI-31561 — checkpoints

**Goal:** Israel-destination flight (YYZ?TLV) disrupted but critical MSL data is MISSING from backend � operating times, flight number details, and ALL disruption codes are unavailable. DDS cannot calculate delay, determine controllability, or assess any regime. System retried daily for 14 days with no data. Case forwarded for manual handling with 30-day SLA. ASL counterpart to APPR TC_072 (ND-05) and EU TC_145 (ND-05). Validates that the ND-05 pattern is consistent across all three regimes.

Methods: seed 8, chat 11, api 20, email 3, dashboard 13, implied 5, manual 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Israel-destination flight (YYZ?TLV) disrupted but critical MSL data is MISSING from backend � operating times, flight number details, and AL |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Oren Navon (Adult) | PNR: single passenger Oren Navon (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 084, YYZ?TLV | Journey: 1 leg AC operated, Flight AC 084, YYZ?TLV |
| CP004 | PREREQUISITES | prerequisite | seed | Flight date: May 5, 2026 | Flight date: May 5, 2026 |
| CP005 | PREREQUISITES | prerequisite | seed | Trip Tracer data status: INCOMPLETE � actual arrival time NOT populated; operating times MISSING; ALL codes (arrival, departure, cancellatio | Trip Tracer data status: INCOMPLETE � actual arrival time NOT populated; operating times MISSING; ALL codes (arrival, departure, cancellation) = NULL |
| CP006 | PREREQUISITES | prerequisite | seed | 14-day retry: EXHAUSTED (May 8�May 22, all polls returned "data missing") | 14-day retry: EXHAUSTED (May 8�May 22, all polls returned "data missing") |
| CP007 | PREREQUISITES | prerequisite | seed | Regime: ASL (TLV destination) + APPR (YYZ origin) | Regime: ASL (TLV destination) + APPR (YYZ origin) |
| CP008 | PREREQUISITES | prerequisite | seed | Residence: Israel | Residence: Israel |
| CP009 | PREREQUISITES | prerequisite | seed | Filing date: May 28, 2026 | Filing date: May 28, 2026 |
| CP010 | BACKGROUND | system | implied | Given a case was previously created for PNR: TC148 |  |
| CP011 | BACKGROUND | system | implied | And the case was placed in the System Processing Queue (case previously filed via chatbot, all identification/authentication/journey selecti |  |
| CP012 | BACKGROUND | system | implied | And 72 hours have elapsed since last leg arrival |  |
| CP013 | BACKGROUND | verdict | api | And the Rules Engine attempted to retrieve MSL data from backend systems |  |
| CP014 | MSL DATA RETRIEVAL | verdict | api | Then the system attempts to retrieve critical MSL data on a scheduled basis | Day 1: RE queries backend ? Operating times: NULL, Flight number: NULL ? CRITICAL DATA MISSING ? retry Day 3: RE retries ? Operating times: NULL, Flight number: |
| CP015 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: MISSING (flight number not available in backend), Route: YYZ ? TLV | Promised Itinerary - Flight: MISSING (flight number not available in backend), Route: YYZ ? TLV |
| CP016 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Status: DISRUPTED (details incomplete) | Current Itinerary - Status: DISRUPTED (details incomplete) |
| CP017 | TRIP TRACER UI VALIDATION | verdict | api | Customer Status: Travel Completed (filed after travel) | Customer Status: Travel Completed (filed after travel) |
| CP018 | TRIP TRACER UI VALIDATION | verdict | api | Regime: ASL (Israel) (Israel destination � TLV) | Regime: ASL (Israel) (Israel destination � TLV) |
| CP019 | TRIP TRACER UI VALIDATION | verdict | api | Destination: TLV (Israel) | Destination: TLV (Israel) |
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
| CP034 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for PNR "TC148" under ASL Israel destination TLV |  |
| CP035 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP036 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Pending Agent Review" escalated from System Processing Queue after 14 days |  |
| CP037 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be Day 14 |  |
| CP038 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "Manual Review Agent Queue" |  |
| CP039 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "YYZ ? TLV" as disrupted with details incomplete due to missing structural data |  |
| CP040 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the flight number and operating times should both be NULL meaning RE cannot even identify which flight to query codes for |  |
| CP041 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And this should differ from TC185 where the flight was identified but codes were missing |  |
| CP042 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "Critical MSL data missing � operatin |  |
| CP043 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And RE should have polled on Days 1, 3, 7, 10, and 14 and all returned NULL for operating times and flight number |  |
| CP044 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the 14-Day Retry Window should be exhausted |  |
| CP045 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the determination should be "NO DETERMINATION" escalated to agent |  |
| CP046 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status History should show Created then System Processing Queue then Day 14 Pending Agent Review escalated due to MSL data miss |  |
| CP047 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an escalation email should have been sent to the customer's email on file containing Case Reference and limited flight details YYZ to TL |  |
| CP048 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP049 | PAYMENT VALIDATION | payment | chat | Given no determination was made due to critical MSL data missing after 14-day retry |  |
| CP050 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP051 | PAYMENT VALIDATION | payment | chat | And the case was created and sent to agent for manual handling |  |
| CP052 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP053 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP054 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP055 | PAYMENT VALIDATION | payment | manual | And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e- |  |
| CP056 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved |  |
| CP057 | EXPECTED RESULTS | verdict | api | DDS returns FD-ASL-ND-05. | DDS returns FD-ASL-ND-05. |
| CP058 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = available (scheduled); Actual = MISSING; Arrival Code = NULL; Departure Code = NULL; Cancellation Code = NULL; ALL co | Trip Tracer: Promise = available (scheduled); Actual = MISSING; Arrival Code = NULL; Departure Code = NULL; Cancellation Code = NULL; ALL codes MISSING; Delay = |
| CP059 | EXPECTED RESULTS | verdict | chat | Data Completeness Check: All critical data points missing; 14-day retry exhausted ? NO DETERMINATION. | Data Completeness Check: All critical data points missing; 14-day retry exhausted ? NO DETERMINATION. |
| CP060 | EXPECTED RESULTS | verdict | chat | Case Routing: Manual handling � 30-day SLA (May 28 ? June 27, 2026). | Case Routing: Manual handling � 30-day SLA (May 28 ? June 27, 2026). |
| CP061 | EXPECTED RESULTS | verdict | chat | Agent must contact operations for missing backend data. | Agent must contact operations for missing backend data. |
| CP062 | EXPECTED RESULTS | verdict | chat | Compensation: NOT CALCULATED. | Compensation: NOT CALCULATED. |
| CP063 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP064 | EXPECTED RESULTS | verdict | api | Regime Assessment: ASL = ND-05 (data missing); APPR = ND (same gap); EU = N/A. | Regime Assessment: ASL = ND-05 (data missing); APPR = ND (same gap); EU = N/A. |
| CP065 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Case = CASE-FD-20260528-205; Status = Pending � Manual Investigation; 30-day SLA active; Agent Action = "Contact operation | Claims Dashboard: Case = CASE-FD-20260528-205; Status = Pending � Manual Investigation; 30-day SLA active; Agent Action = "Contact operations for missing data,  |
