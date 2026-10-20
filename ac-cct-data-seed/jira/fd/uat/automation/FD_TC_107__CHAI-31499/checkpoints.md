# FD_TC_107 · CHAI-31499 — checkpoints

**Goal:** Customer files before 72 hours (similar to TC_018). System creates case, polls daily, data eventually arrives. DIFFERENCE: When DDS data arrives and processes, the result is NOT ELIGIBLE (uncontrollable cause). Validates that the Welcome Back flow correctly delivers a Not Eligible outcome � not just eligible outcomes (TC_018 tested eligible). Customer receives notification but the message is "Not Eligible" instead of "complete your claim."

Methods: seed 6, chat 7, api 17, email 3, dashboard 36, implied 5, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer files before 72 hours (similar to TC_018). System creates case, polls daily, data eventually arrives. DIFFERENCE: When DDS data arr |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Claudine V�zina), 1 leg AC domestic YUL?YYZ | PNR: Single passenger (Claudine V�zina), 1 leg AC domestic YUL?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: 4hr delay, Code 72 (Weather � uncontrollable) | Itinerary: 4hr delay, Code 72 (Weather � uncontrollable) |
| CP004 | PREREQUISITES | prerequisite | seed | Filing time: 36 hours after flight (within 72hr window) | Filing time: 36 hours after flight (within 72hr window) |
| CP005 | PREREQUISITES | prerequisite | seed | DDS data: NOT available at filing | DDS data: NOT available at filing |
| CP006 | PREREQUISITES | prerequisite | seed | Data arrives at D+4 | Data arrives at D+4 |
| CP007 | PREREQUISITES | prerequisite | seed | Expected DDS result when data arrives: Not Eligible (Code 72, uncontrollable) | Expected DDS result when data arrives: Not Eligible (Code 72, uncontrollable) |
| CP008 | BACKGROUND | system | implied | Given a case was previously created for PNR: TC064 |  |
| CP009 | BACKGROUND | system | implied | And the case was placed in the System Processing Queue (72h not elapsed at time of filing) |  |
| CP010 | BACKGROUND | system | implied | And 72 hours have now elapsed since last leg arrival |  |
| CP011 | DDS AUTO-RUN | verdict | api | Then the system triggers DDS evaluation automatically (scheduled run) |  |
| CP012 | DDS AUTO-RUN | verdict | api | And DDS retrieves flight data for PNR: TC064 |  |
| CP013 | DDS AUTO-RUN | verdict | api | And DDS evaluates: | Flight: AC 508, YUL ? YYZ Arrival delay: 5 hours Disruption code: 71 (Severe Weather) Controllability: UNCONTROLLABLE Result: NOT ELIGIBLE |
| CP014 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 508, Route: YUL ? YYZ, Scheduled Arrival: 12:00 | Promised Itinerary - Flight: AC 508, Route: YUL ? YYZ, Scheduled Arrival: 12:00 |
| CP015 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 508, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 12:00 ? Actual: 17:00, Delay: +5H 00M | Current Itinerary - Flight: AC 508, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 12:00 ? Actual: 17:00, Delay: +5H 00M |
| CP016 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP017 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 508 � YUL ? YYZ � 71 | MSL FLIGHT: AC 508 � YUL ? YYZ � 71 |
| CP018 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to severe weather" | "Delayed due to severe weather" |
| CP019 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +5H 00M � UNCONTROLLABLE | Delay: +5H 00M � UNCONTROLLABLE |
| CP020 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE | Fallback: FALSE |
| CP021 | TRIP TRACER UI VALIDATION | verdict | api | Case Status: Previously in System Processing Queue ? DDS now ran ? NOT ELIGIBLE | Case Status: Previously in System Processing Queue ? DDS now ran ? NOT ELIGIBLE |
| CP022 | TRIP TRACER UI VALIDATION | verdict | api | MR/MS [PASSENGER] / NOT ELIGIBLE / UNCONTROLLABLE / CAD 0.00 | MR/MS [PASSENGER] / NOT ELIGIBLE / UNCONTROLLABLE / CAD 0.00 |
| CP023 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP024 | CASE STATUS UPDATE | system | implied | Then the system updates the case status from "System Processing Queue" to "Not Eligible" |  |
| CP025 | CASE STATUS UPDATE | verdict | api | And the system records the DDS result: NOT ELIGIBLE (Uncontrollable � Code 71) |  |
| CP026 | NOTIFICATION � WELCOME BACK EMAIL | email | email | Then the system triggers notification via Adobe: |  |
| CP027 | NOTIFICATION � WELCOME BACK EMAIL | email | email | And a Not Eligible notification email is sent to the customer's email on file |  |
| CP028 | NOTIFICATION � WELCOME BACK EMAIL | email | email | And the email contains: | Update on your Air Canada claim � [Case Reference] After a full review, we can confirm that weather was the primary reason. Since the delay was caused by severe |
| CP029 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for the passenger from PNR "TC064" and was initially placed in System Processing Queue |  |
| CP030 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP031 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP032 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Case Status should be "Closed � Not Eligible" transitioned from System Processing Queue |  |
| CP033 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP034 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP035 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP036 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP037 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP038 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP039 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP040 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP041 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC064" |  |
| CP042 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP043 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP044 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP045 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP046 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP047 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP048 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP049 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP050 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP051 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP052 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP053 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP054 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Uncontrollable � weather, Code 71" |  |
| CP055 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP056 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically after the 72-hour window elapsed as a system-triggered action with no customer interaction |  |
| CP057 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to delay 5h with Code 71 being Uncontrollable |  |
| CP058 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically |  |
| CP059 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP060 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP061 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP062 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the previous status should have been "System Processing Queue" and the current status should be "Closed � Not Eligible" with the transit |  |
| CP063 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a Welcome Back / Not Eligible notification email should have been sent via Adobe |  |
| CP064 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email subject should be "Update on your Air Canada claim � [Case Reference]" |  |
| CP065 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email should contain the Case Reference and flight details AC 508 YUL to YYZ delay 5h and not eligible reason weather uncontrollable |  |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record case creation and System Processing Queue entry and DDS auto-run and status transition to Closed Not Eligibl |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the Welcome Back not eligible email |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP074 | PAYMENT VALIDATION | payment | chat | Given the case was in System Processing Queue and DDS returned "NOT ELIGIBLE" due to uncontrollable weather |  |
| CP075 | PAYMENT VALIDATION | payment | chat | Then the customer was notified by email as not eligible |  |
| CP076 | PAYMENT VALIDATION | payment | chat | And no payment flow should be triggered |  |
| CP077 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP078 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP079 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP080 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP081 | EXPECTED RESULTS | verdict | api | DDS returns PENDING initially ? then FD-APPR-NE-28 when data arrives. | DDS returns PENDING initially ? then FD-APPR-NE-28 when data arrives. |
| CP082 | EXPECTED RESULTS | verdict | api | Polling: System polls Trip Tracer daily from Day 2. | Polling: System polls Trip Tracer daily from Day 2. |
| CP083 | EXPECTED RESULTS | verdict | api | At D+4: Data arrives ? DDS processes ? Code 72, Weather, Uncontrollable ? Not Eligible. | At D+4: Data arrives ? DDS processes ? Code 72, Weather, Uncontrollable ? Not Eligible. |
| CP084 | EXPECTED RESULTS | verdict | chat | Notification: Email sent to customer with Not Eligible message � "Your flight delay was caused by weather conditions beyond our control. | Notification: Email sent to customer with Not Eligible message � "Your flight delay was caused by weather conditions beyond our control. |
| CP085 | EXPECTED RESULTS | verdict | api | You are not eligible for compensation under APPR." CRITICAL: Welcome Back must handle NE outcomes gracefully � customer was waiting for a de | You are not eligible for compensation under APPR." CRITICAL: Welcome Back must handle NE outcomes gracefully � customer was waiting for a decision and the answe |
