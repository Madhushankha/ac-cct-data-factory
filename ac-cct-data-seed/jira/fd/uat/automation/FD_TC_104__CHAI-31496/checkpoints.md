# FD_TC_104 · CHAI-31496 — checkpoints

**Goal:** Customer made a VOLUNTARY change (unprompted by AC) to a later flight. No involuntary change exists on the booking. Under the promise calculation rules, when ONLY voluntary changes exist (no INVOL), the promise updates to the latest state INCLUDING the VOL � meaning the customer's chosen time becomes the new baseline. Customer arrived exactly on time per the VOL schedule. Delay = 0. Validates that: (1) VOL-only bookings use the VOL time as the promise (not the original booking), (2) A customer cannot claim compensation for arriving "later than original" when they voluntarily chose the later flight, (3) Zero delay from the updated promise = NE.

Methods: seed 10, chat 40, api 25, email 3, dashboard 44, implied 16, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer made a VOLUNTARY change (unprompted by AC) to a later flight. No involuntary change exists on the booking. Under the promise calcul |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger (Adult) | PNR: single passenger (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 428, YUL?YYZ | Journey: 1 leg AC operated, Flight AC 428, YUL?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Original booking arrival: 10:00 | Original booking arrival: 10:00 |
| CP005 | PREREQUISITES | prerequisite | seed | VOL change: Customer changed to later flight � new arrival 15:00 (customer-initiated, no INVOL) | VOL change: Customer changed to later flight � new arrival 15:00 (customer-initiated, no INVOL) |
| CP006 | PREREQUISITES | prerequisite | seed | INVOL changes: NONE | INVOL changes: NONE |
| CP007 | PREREQUISITES | prerequisite | seed | Promise rule: VOL only (no INVOL) ? promise = VOL selection = 15:00 | Promise rule: VOL only (no INVOL) ? promise = VOL selection = 15:00 |
| CP008 | PREREQUISITES | prerequisite | seed | Actual arrival: 15:00 (on time per VOL schedule) | Actual arrival: 15:00 (on time per VOL schedule) |
| CP009 | PREREQUISITES | prerequisite | seed | Delay from promise: 15:00 ? 15:00 = 0hrs | Delay from promise: 15:00 ? 15:00 = 0hrs |
| CP010 | PREREQUISITES | prerequisite | seed | No arrival or delay code (flight operated normally per VOL schedule) | No arrival or delay code (flight operated normally per VOL schedule) |
| CP011 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic) | Regime: APPR (domestic) |
| CP012 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP013 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP014 | START | customer | chat | Then user selects English |  |
| CP015 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP016 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP017 | START | customer | chat | And the user says "I changed my flight myself to a later one and it arrived on time. I'd like to check if I'm eligible for any compensation  | I changed my flight myself to a later one and it arrived on time. I'd like to check if I'm eligible for any compensation since my original flight was much earli |
| CP018 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP019 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP020 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP021 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Olivier Deschamps" | Olivier Deschamps |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Olivier! And, what is your booking reference number? |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC061" | PNR: TC061 |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC061 |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: o***@gmail.com � Phone: +1***890 |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: o***@gmail.com" | Email: o***@gmail.com |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "371928" | 371928 |
| CP035 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP037 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Olivier Deschamps (Adult) Is this who you'd like to include? |
| CP042 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP044 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 505 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: May 20, 2026 � Status: ARRIVED (on time) Is this the journey you |
| CP045 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP050 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 20, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Flight date May 20, 2026; filing June 15, 2026 ? 26 days ? within 366 days ? PROCEED |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Booking change history |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | And DDS identifies: Change 1 (Day -5): VOL � customer changed flight ? arrival updated from 10:00 to 15:00 |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Any INVOL changes? ? NO (VOL only) |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | And DDS determines: Promise = VOL arrival (15:00) � VOL updates the promise baseline |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS calculates: Delay = Actual arrival (15:00) - Promise (15:00) = 0H 00M |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS determines: NO DELAY ? NOT ELIGIBLE |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 505, Route: YUL ? YYZ, Scheduled Arrival: 15:00 (VOL-updated promise, NOT 10:00 original) | Promised Itinerary - Flight: AC 505, Route: YUL ? YYZ, Scheduled Arrival: 15:00 (VOL-updated promise, NOT 10:00 original) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 505, Route: YUL ? YYZ, Status: ARRIVED ON TIME, Actual Arrival: 15:00, Delay: 0H 00M | Current Itinerary - Flight: AC 505, Route: YUL ? YYZ, Status: ARRIVED ON TIME, Actual Arrival: 15:00, Delay: 0H 00M |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | History - Original booking: arr 10:00 / Change 1 (Day -5): VOL � customer changed flight ? arr 15:00 | History - Original booking: arr 10:00 / Change 1 (Day -5): VOL � customer changed flight ? arr 15:00 |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Promise Rule: VOL only (no INVOL) ? promise = VOL arrival (15:00) | Promise Rule: VOL only (no INVOL) ? promise = VOL arrival (15:00) |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Delay = Actual (15:00) - Promise (15:00) = 0h | Delay = Actual (15:00) - Promise (15:00) = 0h |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | CRITICAL: Promise = 15:00 (VOL), NOT 10:00 (original/14-day mark). Customer's voluntary change updates the baseline. | CRITICAL: Promise = 15:00 (VOL), NOT 10:00 (original/14-day mark). Customer's voluntary change updates the baseline. |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | DDS: NO DELAY ? NOT ELIGIBLE | DDS: NO DELAY ? NOT ELIGIBLE |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | MR OLIVIER DESCHAMPS / NOT ELIGIBLE / NO_DELAY / CAD 0.00 | MR OLIVIER DESCHAMPS / NOT ELIGIBLE / NO_DELAY / CAD 0.00 |
| CP070 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP071 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP072 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your arrival in Toronto was on time. That means there's no recorded delay for this part of your trip. Based  |
| CP073 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP074 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP075 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP076 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP077 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to o***@gmail.com |  |
| CP078 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (no delay � VOL change updated promise, actual matched promise), |  |
| CP079 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP080 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP081 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Olivier Deschamps" with PNR "TC061" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Olivier Deschamps" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC061" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Olivier Deschamps" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "o***@gmail.com" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***890" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "No delay � VOL change updated promise to |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to VOL only with promise updated to VOL arrival and actual matche |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Olivier Deschamps + TC061 + YUL?YYZ + FD" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP135 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to VOL change with no delay |  |
| CP136 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP138 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP139 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP140 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP141 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-27. | DDS returns FD-APPR-NE-27. |
| CP142 | EXPECTED RESULTS | verdict | api | Trip Tracer � Promise Calculation: Changes = VOL only (no INVOL); Rule = when only VOL, promise = latest state including VOL; Original arriv | Trip Tracer � Promise Calculation: Changes = VOL only (no INVOL); Rule = when only VOL, promise = latest state including VOL; Original arrival = 10:00; VOL arri |
| CP143 | EXPECTED RESULTS | verdict | chat | Actual = 15:00. | Actual = 15:00. |
| CP144 | EXPECTED RESULTS | verdict | api | Delay = 0 (no delay from updated promise). | Delay = 0 (no delay from updated promise). |
| CP145 | EXPECTED RESULTS | verdict | chat | No arrival or delay code (normal operation). | No arrival or delay code (normal operation). |
| CP146 | EXPECTED RESULTS | verdict | chat | Compensation: $0 � no delay. | Compensation: $0 � no delay. |
| CP147 | EXPECTED RESULTS | verdict | chat | Customer voluntarily chose the later flight; that time is the baseline. | Customer voluntarily chose the later flight; that time is the baseline. |
| CP148 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP149 | EXPECTED RESULTS | verdict | api | Claims Dashboard: VOL updated promise to 15:00; Actual = 15:00; No delay; $0; DDS = FD-APPR-NE-27. | Claims Dashboard: VOL updated promise to 15:00; Actual = 15:00; No delay; $0; DDS = FD-APPR-NE-27. |
