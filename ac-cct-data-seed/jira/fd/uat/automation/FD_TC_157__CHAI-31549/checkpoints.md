# FD_TC_157 · CHAI-31549 — checkpoints

**Goal:** Passenger denied boarding on an Israel route. Denied boarding is handled under SEPARATE ASL provisions � not the flight disruption compensation flow. Same scope exclusion as APPR TC_044 (NE-06). Customer redirected to the correct denied boarding process. The case is logged as "Not Eligible (Flight Disruption)" � the customer MAY be eligible under denied boarding provisions through a different channel.

Methods: seed 4, chat 19, api 4, dashboard 45, implied 2, manual 8, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Passenger denied boarding on an Israel route. Denied boarding is handled under SEPARATE ASL provisions � not the flight disruption compensat |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger | PNR: Single passenger |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: Israel route (AC operated) | Journey: Israel route (AC operated) |
| CP004 | PREREQUISITES | prerequisite | seed | Trip Tracer Flag: DENIED BOARDING EVENT = TRUE | Trip Tracer Flag: DENIED BOARDING EVENT = TRUE |
| CP005 | PREREQUISITES | prerequisite | seed | Flight status: Flight operated but customer was NOT aboard | Flight status: Flight operated but customer was NOT aboard |
| CP006 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP007 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP008 | START | customer | chat | Then user selects English |  |
| CP009 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP010 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP011 | START | customer | chat | And the user says "I was denied boarding on my flight from Tel Aviv to Toronto even though I had a valid ticket and was at the gate on time. | I was denied boarding on my flight from Tel Aviv to Toronto even though I had a valid ticket and was at the gate on time. Can I get compensation? |
| CP012 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP013 | START | system | implied | Then the chatbot checks: Is this a denied boarding event? ? YES |  |
| CP014 | DENIED BOARDING REDIRECT | bot | chat | Then the chatbot responds: | I understand you were denied boarding on your flight. I'm sorry for the inconvenience. Denied boarding claims are handled through a separate process. Please con |
| CP015 | DENIED BOARDING REDIRECT | idv | chat | And the chatbot provides: | � Customer Relations contact information � Link to denied boarding claim form � Reference to ASL denied boarding rights NO IDENTIFICATION FLOW (skipped � denied |
| CP016 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP017 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP018 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP019 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the claimant "Sarah Baruch" was identified and authenticated for PNR "TC124" (Auth Flow 1) |  |
| CP020 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer shows DENIED BOARDING EVENT = TRUE on the AC-operated MSL TLV ? YYZ |  |
| CP021 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then exactly one case should have been created for claimant "Sarah Baruch" with PNR "TC124" |  |
| CP022 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Header Topic/Sub-topic should be "Travel Disruptions � Denied Boarding" |  |
| CP023 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP024 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible (Flight Disruption)" |  |
| CP025 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date should be populated |  |
| CP026 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking against the Israel (ASL) 20-day SLA |  |
| CP027 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP028 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP029 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP030 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Sarah Baruch" |  |
| CP031 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP032 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP033 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC124" |  |
| CP034 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated |  |
| CP035 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier should be "Air Canada (AC)" |  |
| CP036 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL (Israel)" |  |
| CP037 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Sarah Baruch" |  |
| CP038 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP039 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email, Phone, Address and Profile ID should be populated |  |
| CP040 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: TLV ? YYZ" with flight status "Operated � customer NOT aboard" |  |
| CP041 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding flag should be "TRUE" |  |
| CP042 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present with no expected ancillary fees |  |
| CP043 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should show "NOT ELIGIBLE (Flight Disruption) � Denied Boarding (separate ASL provisions) � ILS |  |
| CP044 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no ASL flight disruption compensation amount should be calculated or shown |  |
| CP045 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Redirect field should show "Customer Relations � Denied Boarding claim" |  |
| CP046 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP047 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP048 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS outcome should be "FD-ASL-NE-06" |  |
| CP049 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE (Flight Disruption)" with reason "Denied Boarding � handled under sepa |  |
| CP050 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the decision should NOT state that the customer is ineligible for denied boarding compensation |  |
| CP051 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Sarah Baruch + TC124 + TLV?YYZ + FD" |  |
| CP052 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP053 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP054 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP055 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "Not triggered" |  |
| CP056 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Persona IDV status should be "Not triggered" |  |
| CP057 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no manual-review queue item or manual-review reference number should exist for this case |  |
| CP058 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP059 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP060 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a Not Eligible (Flight Disruption) notification email should have been sent via Adobe with the denied boarding redirect, Customer Relati |  |
| CP061 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email should NOT contain any compensation amount |  |
| CP062 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP063 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record the denied boarding detection, the FD-ASL-NE-06 decision and the redirect, with timestamps and before/after  |  |
| CP064 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP065 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should show the claim declined in-chat with the redirect, not escalated |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible (Flight Disruption)" |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP071 | PAYMENT VALIDATION | payment | chat | Given no case was created due to denied boarding being handled separately |  |
| CP072 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP073 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP074 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP075 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP076 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP077 | EXPECTED RESULTS | verdict | api | DDS returns FD-ASL-NE-06. | DDS returns FD-ASL-NE-06. |
| CP078 | EXPECTED RESULTS | verdict | api | Denied Boarding Detection: Trip Tracer Denied Boarding = TRUE ? NOT ELIGIBLE under Flight Disruption flow (separate ASL provisions apply). | Denied Boarding Detection: Trip Tracer Denied Boarding = TRUE ? NOT ELIGIBLE under Flight Disruption flow (separate ASL provisions apply). |
| CP079 | EXPECTED RESULTS | verdict | chat | Customer Redirect: Directed to Customer Relations for denied boarding claim under separate ASL provisions. | Customer Redirect: Directed to Customer Relations for denied boarding claim under separate ASL provisions. |
| CP080 | EXPECTED RESULTS | verdict | chat | Compensation (FD): $0 (via this channel). | Compensation (FD): $0 (via this channel). |
| CP081 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP082 | EXPECTED RESULTS | verdict | api | Regime Assessment: ASL = NE-06 (Denied Boarding � separate process). | Regime Assessment: ASL = NE-06 (Denied Boarding � separate process). |
| CP083 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Status = Closed � Not Eligible (Flight Disruption); Reason = Denied Boarding (separate ASL provisions); Redirect = Custome | Claims Dashboard: Status = Closed � Not Eligible (Flight Disruption); Reason = Denied Boarding (separate ASL provisions); Redirect = Customer Relations; DDS = F |
