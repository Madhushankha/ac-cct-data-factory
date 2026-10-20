# FD_TC_108 · CHAI-31500 — checkpoints

**Goal:** Extension of TC_072. ALL disruption codes are missing and after polling Trip Tracer daily for 14 days, the data NEVER arrives. System exhausts the 14-day polling window and routes the case to manual agent handling. Validates the end-of-polling escalation path � confirms that the system doesn't poll indefinitely and has a definitive cutoff.

Methods: seed 6, chat 10, api 15, email 3, dashboard 37, implied 7, manual 11, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Extension of TC_072. ALL disruption codes are missing and after polling Trip Tracer daily for 14 days, the data NEVER arrives. System exhaus |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Ga�tan Rivard), 1 leg AC domestic YUL?YYZ | PNR: Single passenger (Ga�tan Rivard), 1 leg AC domestic YUL?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: Scheduled arrival 14:00, Actual arrival 18:00 (4hr delay per flight status) | Itinerary: Scheduled arrival 14:00, Actual arrival 18:00 (4hr delay per flight status) |
| CP004 | PREREQUISITES | prerequisite | seed | All disruption codes: MISSING � never logged by any station | All disruption codes: MISSING � never logged by any station |
| CP005 | PREREQUISITES | prerequisite | seed | DDS polling: System has polled Trip Tracer daily for 14 consecutive days | DDS polling: System has polled Trip Tracer daily for 14 consecutive days |
| CP006 | PREREQUISITES | prerequisite | seed | Day 14: Data still not available | Day 14: Data still not available |
| CP007 | PREREQUISITES | prerequisite | seed | Polling window: EXHAUSTED | Polling window: EXHAUSTED |
| CP008 | BACKGROUND | system | implied | Given a case was previously created for PNR: TC065 |  |
| CP009 | BACKGROUND | system | implied | And the case was placed in the System Processing Queue |  |
| CP010 | BACKGROUND | system | implied | And 72 hours have elapsed since last leg arrival |  |
| CP011 | BACKGROUND | verdict | api | And DDS has been polling for disruption codes |  |
| CP012 | DDS POLLING | system | implied | Then the system polls for disruption codes on a scheduled basis | Day 1: DDS runs ? Arrival code: NULL, Departure code: NULL ? NO DETERMINATION ? retry Day 3: DDS retries ? Arrival code: NULL, Departure code: NULL ? NO DETERMI |
| CP013 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 509, Route: YUL ? YYZ, Scheduled Arrival: 12:00 | Promised Itinerary - Flight: AC 509, Route: YUL ? YYZ, Scheduled Arrival: 12:00 |
| CP014 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 509, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 12:00 ? Actual: 16:00, Delay: +4H 00M | Current Itinerary - Flight: AC 509, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 12:00 ? Actual: 16:00, Delay: +4H 00M |
| CP015 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP016 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 509 � YUL ? YYZ � NO CODE | MSL FLIGHT: AC 509 � YUL ? YYZ � NO CODE |
| CP017 | TRIP TRACER UI VALIDATION | verdict | api | Arrival Code: NULL (after 14 days) | Arrival Code: NULL (after 14 days) |
| CP018 | TRIP TRACER UI VALIDATION | verdict | api | Departure Code: NULL (after 14 days) | Departure Code: NULL (after 14 days) |
| CP019 | TRIP TRACER UI VALIDATION | verdict | api | Cancellation Code: NULL (after 14 days) | Cancellation Code: NULL (after 14 days) |
| CP020 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: ATTEMPTED ? ALL CODES NULL ? NO FALLBACK AVAILABLE | Fallback: ATTEMPTED ? ALL CODES NULL ? NO FALLBACK AVAILABLE |
| CP021 | TRIP TRACER UI VALIDATION | verdict | api | 14-Day Retry Window: EXHAUSTED | 14-Day Retry Window: EXHAUSTED |
| CP022 | TRIP TRACER UI VALIDATION | verdict | api | Case Status: System Processing Queue ? 14 days exhausted ? ESCALATED TO CR AGENT | Case Status: System Processing Queue ? 14 days exhausted ? ESCALATED TO CR AGENT |
| CP023 | TRIP TRACER UI VALIDATION | verdict | api | MR/MS [PASSENGER] / NO DETERMINATION / NO_CODE_14_DAYS / PENDING CR AGENT | MR/MS [PASSENGER] / NO DETERMINATION / NO_CODE_14_DAYS / PENDING CR AGENT |
| CP024 | CASE STATUS UPDATE | system | implied | Then the system updates the case status from "System Processing Queue" to "Pending Agent Review" |  |
| CP025 | CASE STATUS UPDATE | system | implied | And the system records: 14-day retry window exhausted, no disruption code available |  |
| CP026 | CASE STATUS UPDATE | system | implied | And the case is routed to the Customer Relations (CR) agent queue |  |
| CP027 | NOTIFICATION � ESCALATION EMAIL | email | email | Then the system triggers notification via Adobe: |  |
| CP028 | NOTIFICATION � ESCALATION EMAIL | email | email | And a No Determination notification email is sent to the customer's email on file |  |
| CP029 | NOTIFICATION � ESCALATION EMAIL | email | email | And the email contains: | Update on your Air Canada claim � [Case Reference] Your claim is currently under review by our Customer Relations team. We require additional time to assess you |
| CP030 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for the passenger from PNR "TC065" and was initially placed in System Processing Queue |  |
| CP031 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP032 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP033 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Case Status should be "Pending Agent Review" transitioned from System Processing Queue |  |
| CP034 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP035 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP036 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP037 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "Customer Relations (CR) Agent Queue" |  |
| CP038 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP039 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel may be restricted as it is pending manual review |  |
| CP040 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP041 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP042 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC065" |  |
| CP043 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP044 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP045 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP046 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP047 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP048 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP049 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP050 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP051 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP052 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP053 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP054 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP055 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "All codes NULL after 14-day polling  |  |
| CP056 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP057 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have polled on Days 1, 3, 7, 10, and 14 and all returned NULL for arrival, departure, and cancellation codes |  |
| CP058 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the 14-day retry window should be exhausted |  |
| CP059 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be "PENDING CR AGENT" |  |
| CP060 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically |  |
| CP061 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP062 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it is pending manual review |  |
| CP063 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP064 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the previous status should have been "System Processing Queue" and the current status should be "Pending Agent Review" with 14-day windo |  |
| CP065 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an escalation / No Determination notification email should have been sent via Adobe |  |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email subject should be "Update on your Air Canada claim � [Case Reference]" |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email should contain the Case Reference and flight details AC 509 YUL to YYZ delay 4h and status under review by CR team and expecte |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record case creation and System Processing Queue entry and DDS polling attempts on Days 1, 3, 7, 10, and 14 and 14- |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the escalation notification email |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Pending Agent Review" escalated to CR agent queue |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should NOT be in read-only mode as it is pending CR team action |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP076 | PAYMENT VALIDATION | payment | chat | Given no determination was made after 14-day polling from System Processing Queue |  |
| CP077 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP078 | PAYMENT VALIDATION | payment | chat | And the case was polled for 14 days with no complete answer |  |
| CP079 | PAYMENT VALIDATION | payment | chat | And the case was sent to CR agent for manual review |  |
| CP080 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP081 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP082 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP083 | PAYMENT VALIDATION | payment | manual | And if the agent later determines eligible manual compensation should be created and payment dispatched per type |  |
| CP084 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved |  |
| CP085 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-ND-09. | DDS returns FD-APPR-ND-09. |
| CP086 | EXPECTED RESULTS | verdict | api | Trip Tracer: Delay = 4hrs (from flight status); All codes = NULL; Polled for 14 days � data never arrived. | Trip Tracer: Delay = 4hrs (from flight status); All codes = NULL; Polled for 14 days � data never arrived. |
| CP087 | EXPECTED RESULTS | verdict | chat | System behavior at Day 14: Polling stops; Case status changes from "Polling" to "Manual Handling Required"; Automatic escalation to agent qu | System behavior at Day 14: Polling stops; Case status changes from "Polling" to "Manual Handling Required"; Automatic escalation to agent queue. |
| CP088 | EXPECTED RESULTS | verdict | chat | CRITICAL: System must NOT continue polling past 14 days � definitive cutoff. | CRITICAL: System must NOT continue polling past 14 days � definitive cutoff. |
| CP089 | EXPECTED RESULTS | verdict | chat | Agent must investigate manually (contact station, check paper logs, etc.). | Agent must investigate manually (contact station, check paper logs, etc.). |
| CP090 | EXPECTED RESULTS | verdict | api | Claims Dashboard: No Determination; Reason = 14-day polling exhausted, data never arrived; Polling history = 14 attempts (all NULL); Status  | Claims Dashboard: No Determination; Reason = 14-day polling exhausted, data never arrived; Polling history = 14 attempts (all NULL); Status = Escalated to Manua |
