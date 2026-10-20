# FD_TC_139 · CHAI-31531 — checkpoints

**Goal:** Customer voluntarily gave up their seat in exchange for benefits offered by the airline (e.g., voucher, upgrade on next flight). Voluntary denied boarding is NOT eligible for EU 261 compensation because the customer chose to give up their seat. Validates that DDS distinguishes between voluntary and involuntary denied boarding � only involuntary triggers compensation.

Methods: seed 5, chat 19, api 4, dashboard 45, implied 2, manual 8, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer voluntarily gave up their seat in exchange for benefits offered by the airline (e.g., voucher, upgrade on next flight). Voluntary d |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Sophie Laurent), 1 leg AC operated LHR?YYZ | PNR: Single passenger (Sophie Laurent), 1 leg AC operated LHR?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: Original flight LHR?YYZ scheduled departure 10:00 | Itinerary: Original flight LHR?YYZ scheduled departure 10:00 |
| CP004 | PREREQUISITES | prerequisite | seed | Denied boarding type: VOLUNTARY � customer accepted airline's offer of �200 voucher + next flight | Denied boarding type: VOLUNTARY � customer accepted airline's offer of �200 voucher + next flight |
| CP005 | PREREQUISITES | prerequisite | seed | Next flight: Departed 14:00, arrived 18:00 (4hr later than original) | Next flight: Departed 14:00, arrived 18:00 (4hr later than original) |
| CP006 | PREREQUISITES | prerequisite | seed | Booking flag: VOL-DB (voluntary denied boarding) | Booking flag: VOL-DB (voluntary denied boarding) |
| CP007 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP008 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP009 | START | customer | chat | Then user selects English |  |
| CP010 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP011 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP012 | START | customer | chat | And the user says "I was denied boarding on my flight from Paris to Toronto even though I had a valid ticket and was at the gate on time. Ca | I was denied boarding on my flight from Paris to Toronto even though I had a valid ticket and was at the gate on time. Can I get compensation? |
| CP013 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP014 | START | system | implied | Then the chatbot checks: Is this a denied boarding event? ? YES |  |
| CP015 | DENIED BOARDING REDIRECT | bot | chat | Then the chatbot responds: | I understand you were denied boarding on your flight. I'm sorry for the inconvenience. Denied boarding claims are handled through a separate process. Please con |
| CP016 | DENIED BOARDING REDIRECT | idv | chat | And the chatbot provides: | � Customer Relations contact information � Link to denied boarding claim form � Reference to EU 261 denied boarding rights NO IDENTIFICATION FLOW (skipped � den |
| CP017 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP018 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP019 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP020 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the claimant "Sophie Laurent" was identified and authenticated for PNR "TC098" (Auth Flow 1) |  |
| CP021 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS detected a denied boarding event on the MSL with booking flag "VOL-DB" |  |
| CP022 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then exactly one case should have been created for claimant "Sophie Laurent" with PNR "TC098" |  |
| CP023 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Header Topic/Sub-topic should be "Travel Disruptions � Denied Boarding" |  |
| CP024 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP025 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP026 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date should be populated |  |
| CP027 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP028 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP029 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP030 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP031 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Sophie Laurent" |  |
| CP032 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP033 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP034 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC098" |  |
| CP035 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated |  |
| CP036 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier should be "Air Canada (AC)" |  |
| CP037 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (UK)" |  |
| CP038 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Sophie Laurent" |  |
| CP039 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP040 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email, Phone, Address and Profile ID should be populated |  |
| CP041 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: LHR ? YYZ" with the original flight (scheduled departure 10:00) and the next flight (departed 14:00, a |  |
| CP042 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding Type should be "VOLUNTARY" |  |
| CP043 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the VOL-DB flag should be "TRUE" |  |
| CP044 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the airline offer should be shown as "Accepted � EUR 200 voucher + next flight" |  |
| CP045 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present with no expected ancillary fees |  |
| CP046 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should show "NOT ELIGIBLE (Flight Disruption) � Voluntary Denied Boarding � GBP 0" |  |
| CP047 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no EU 261 compensation amount (GBP 520 / EUR 600) should be calculated or shown on top of the voluntary offer |  |
| CP048 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the 4-hour later arrival should NOT be used to calculate delay compensation |  |
| CP049 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP050 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP051 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS outcome should be "FD-EU-NE-06" |  |
| CP052 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" with reason "Voluntary Denied Boarding � customer accepted airline of |  |
| CP053 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Sophie Laurent + TC098 + LHR?YYZ + FD" |  |
| CP054 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP055 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP056 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP057 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "Not triggered" |  |
| CP058 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Persona IDV status should be "Not triggered" |  |
| CP059 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no manual-review queue item should exist for this case |  |
| CP060 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP061 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP062 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe stating the reason (voluntary denied boarding, airline offer accepted) |  |
| CP063 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email should NOT contain any compensation amount |  |
| CP064 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP065 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record the VOL-DB detection and the Not Eligible decision with timestamps and before/after values |  |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible email chronologically |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP072 | PAYMENT VALIDATION | payment | chat | Given no case was created due to denied boarding being handled separately |  |
| CP073 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP074 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP075 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP076 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP077 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP078 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-NE-05. | DDS returns FD-EU-NE-05. |
| CP079 | EXPECTED RESULTS | verdict | api | Trip Tracer: Original flight = LHR?YYZ 10:00; Customer voluntarily denied boarding; Accepted compensation offer (�200 voucher); Rebooked on  | Trip Tracer: Original flight = LHR?YYZ 10:00; Customer voluntarily denied boarding; Accepted compensation offer (�200 voucher); Rebooked on next flight arriving |
| CP080 | EXPECTED RESULTS | verdict | chat | CRITICAL: Voluntary denied boarding = customer chose to give up seat ? NOT eligible for additional EU 261 compensation. | CRITICAL: Voluntary denied boarding = customer chose to give up seat ? NOT eligible for additional EU 261 compensation. |
| CP081 | EXPECTED RESULTS | verdict | chat | The airline's offer (�200 voucher) is the agreed compensation. | The airline's offer (�200 voucher) is the agreed compensation. |
| CP082 | EXPECTED RESULTS | verdict | api | DDS must NOT calculate additional �600 on top of the voluntary offer. | DDS must NOT calculate additional �600 on top of the voluntary offer. |
| CP083 | EXPECTED RESULTS | verdict | chat | Compensation under EU 261: $0 � Not Eligible (voluntary DB). | Compensation under EU 261: $0 � Not Eligible (voluntary DB). |
| CP084 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Not Eligible; Reason = Voluntary Denied Boarding; VOL-DB flag = TRUE; Airline offer accepted; DDS = FD-EU-NE-05. | Claims Dashboard: Not Eligible; Reason = Voluntary Denied Boarding; VOL-DB flag = TRUE; Airline offer accepted; DDS = FD-EU-NE-05. |
