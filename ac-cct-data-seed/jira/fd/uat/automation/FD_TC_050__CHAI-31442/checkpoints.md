# FD_TC_050 · CHAI-31442 — checkpoints

**Goal:** Customer's original flight AC 435 YUL?YYZ was CANCELLED due to WXX (Weather � Uncontrollable). Customer is reprotected onto renumbered flight AC 445 YUL?YYZ. The renumbered flight departs at the exact SAME scheduled departure time (08:00) AND arrives at the exact SAME scheduled arrival time (10:00) as the original promised itinerary (0 hours arrival delay). Passenger holds a Basic Aeroplan profile (9876543210) linked to the booking. Under APPR, BOTH compensation tracks fail: (1) Cancellation Entitlement � NOT triggered because WXX is Uncontrollable (cancellation entitlement only applies to Controllable cancellations), (2) Delay Entitlement � NOT triggered because reprotected arrival = 0h delay (below 3h minimum threshold, and moot as controllability gate already fails). Validates: (1) WXX (Weather) classified as Uncontrollable, (2) DDS Gate 3 (Controllability check) fails first � no further entitlement assessment needed, (3) NOT ELIGIBLE result returned on dual grounds � Uncontrollable cancellation + 0h arrival delay, (4) AC Wallet NOT offered despite Basic Aeroplan linkage � not eligible cases do not trigger payment flow.

Methods: seed 11, chat 41, api 32, email 3, dashboard 45, implied 20, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer's original flight AC 435 YUL?YYZ was CANCELLED due to WXX (Weather � Uncontrollable). Customer is reprotected onto renumbered fligh |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC024 � single passenger Dominique Arsenault (Adult - Basic Aeroplan Member #: 9876543210) | PNR: TC024 � single passenger Dominique Arsenault (Adult - Basic Aeroplan Member #: 9876543210) |
| CP003 | PREREQUISITES | prerequisite | seed | Original itinerary: AC 435 YUL?YYZ, Scheduled departure: 08:00, Scheduled arrival: 10:00 | Original itinerary: AC 435 YUL?YYZ, Scheduled departure: 08:00, Scheduled arrival: 10:00 |
| CP004 | PREREQUISITES | prerequisite | seed | Original flight CANCELLED (Cancellation Code: WXX � Weather � Uncontrollable) | Original flight CANCELLED (Cancellation Code: WXX � Weather � Uncontrollable) |
| CP005 | PREREQUISITES | prerequisite | seed | Customer reprotected on renumbered flight AC 445 YUL?YYZ | Customer reprotected on renumbered flight AC 445 YUL?YYZ |
| CP006 | PREREQUISITES | prerequisite | seed | Departure time: 08:00 (SAME as original scheduled departure) | Departure time: 08:00 (SAME as original scheduled departure) |
| CP007 | PREREQUISITES | prerequisite | seed | Actual arrival: 10:00 (SAME as original promised arrival � 0h delay) | Actual arrival: 10:00 (SAME as original promised arrival � 0h delay) |
| CP008 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic) | Regime: APPR (domestic) |
| CP009 | PREREQUISITES | prerequisite | seed | Timing: >72hrs elapsed | Timing: >72hrs elapsed |
| CP010 | PREREQUISITES | prerequisite | seed | Filing: Within 366 days | Filing: Within 366 days |
| CP011 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked (9876543210), Basic Member in good standing | Aeroplan: Linked (9876543210), Basic Member in good standing |
| CP012 | PREREQUISITES | prerequisite | implied | CyberSource: NOT invoked (not eligible) | CyberSource: NOT invoked (not eligible) |
| CP013 | PREREQUISITES | prerequisite | implied | RDS: No flags | RDS: No flags |
| CP014 | PREREQUISITES | prerequisite | seed | CRITICAL: Dual NE gates � WXX Uncontrollable (no cancellation entitlement) + 0h arrival delay (no delay entitlement) | CRITICAL: Dual NE gates � WXX Uncontrollable (no cancellation entitlement) + 0h arrival delay (no delay entitlement) |
| CP015 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP016 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP017 | START | customer | chat | Then user selects English |  |
| CP018 | START | alert | chat | Then an alert information is displayed ""Please note that by using this service, you will interact with an automated chatbot which uses AI t | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP019 | START | bot | chat | Then chatbot asks ""How can I help you today?"" | How can I help you today? |
| CP020 | START | customer | chat | And the user says ""My flight from Montreal to Toronto was cancelled due to weather and I was moved to a renumbered flight. It departed and  | My flight from Montreal to Toronto was cancelled due to weather and I was moved to a renumbered flight. It departed and arrived at the same time as my original  |
| CP021 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP022 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP023 | START | bot | chat | Then the chatbot responds: ""No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP024 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: ""Please note that the assessment and decision regarding your request will be made through an automated decision- | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides ""Dominique Arsenault"" | Dominique Arsenault |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Dominique! And, what is your booking reference number? |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides ""PNR: TC024"" | PNR: TC024 |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC024 |  |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: d***@gmail.com � Phone: +1***890 |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects ""Email: d***@gmail.com"" | Email: d***@gmail.com |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code ""629184"" | 629184 |
| CP038 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP040 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP041 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP042 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP043 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP044 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Dominique Arsenault (Adult - Aeroplan Member) Is this who you'd like to include? |
| CP045 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms ""Yes"" | Yes |
| CP046 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP047 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Original Flight: AC 435 � CANCELLED (WXX � Weather / Uncontrollable) � Reprotected Flight: AC 445 (Renumbered) � Route: Montrea |
| CP048 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms ""Yes"" | Yes |
| CP049 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP050 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP052 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP053 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 10, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP054 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP055 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 10, 2026; filing June 15, 2026 ? 36 days ? within 366 days ? PROCEED |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Was the flight cancelled? ? YES (AC 435 � WXX Weather) |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Change history = INVOL � AC 435 cancelled (WXX) ? customer reprotected onto renumbered flight AC 445 |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Was the customer reprotected on renumbered flight? ? YES (AC 445 YUL?YYZ, same departure 08:00) |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | And DDS applies: APPR Gate 3 � Controllability check: | Cancellation Code = WXX (Weather) ? UNCONTROLLABLE Gate 3 FAILS ? Cancellation Entitlement = NOT triggered |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Actual arrival on renumbered flight at final destination = 10:00 |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Original promised arrival = 10:00 |  |
| CP063 | TRIAGE & DDS EVALUATION | verdict | api | And DDS calculates: Delay = 10:00 ? 10:00 = 0h (0 min) |  |
| CP064 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Was the reprotected arrival delayed ? 3 hours vs original promise? ? NO (0h = 0 min < 180 min threshold) |  |
| CP065 | TRIAGE & DDS EVALUATION | verdict | api | And DDS applies: APPR Gate 8 � Delay threshold check: 0h < 3h ? FAILS THRESHOLD (moot � Gate 3 already failed) |  |
| CP066 | TRIAGE & DDS EVALUATION | verdict | api | And DDS determines: WXX UNCONTROLLABLE CANCELLATION + 0H ARRIVAL DELAY ? DUAL NOT ELIGIBLE GATES FAILED ? NOT ELIGIBLE |  |
| CP067 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 435, Route: YUL ? YYZ, Scheduled Departure: 08:00, Scheduled Arrival: 10:00 (CANCELLED � WXX Weather) | Promised Itinerary - Flight: AC 435, Route: YUL ? YYZ, Scheduled Departure: 08:00, Scheduled Arrival: 10:00 (CANCELLED � WXX Weather) |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | History - Change 1: INVOL � AC 435 CANCELLED (WXX � Weather � Uncontrollable). Customer reprotected onto renumbered flight AC 445 YUL?YYZ. | History - Change 1: INVOL � AC 435 CANCELLED (WXX � Weather � Uncontrollable). Customer reprotected onto renumbered flight AC 445 YUL?YYZ. |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 445 (Renumbered), Route: YUL ? YYZ, Status: ARRIVED ON TIME, Scheduled Departure: 08:00 (SAME as original), A | Current Itinerary - Flight: AC 445 (Renumbered), Route: YUL ? YYZ, Status: ARRIVED ON TIME, Scheduled Departure: 08:00 (SAME as original), Actual Arrival: 10:00 |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 435 � YUL ? YYZ � WXX (Weather � Uncontrollable) | MSL FLIGHT: AC 435 � YUL ? YYZ � WXX (Weather � Uncontrollable) |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | Reprotected Flight: AC 445 � YUL ? YYZ � Departed 08:00 (SAME) � Arrived 10:00 (SAME as original promise) | Reprotected Flight: AC 445 � YUL ? YYZ � Departed 08:00 (SAME) � Arrived 10:00 (SAME as original promise) |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | Delay Calculation: Original promise = 10:00; Reprotected actual = 10:00; Delay = 0H 00M | Delay Calculation: Original promise = 10:00; Reprotected actual = 10:00; Delay = 0H 00M |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | DDS Gate 3: WXX = Uncontrollable ? Cancellation Entitlement NOT triggered ? FAILS | DDS Gate 3: WXX = Uncontrollable ? Cancellation Entitlement NOT triggered ? FAILS |
| CP076 | TRIP TRACER UI VALIDATION | verdict | api | DDS Gate 8: 0h < 3h ? Delay Entitlement NOT triggered ? FAILS (moot) | DDS Gate 8: 0h < 3h ? Delay Entitlement NOT triggered ? FAILS (moot) |
| CP077 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE | Fallback: FALSE |
| CP078 | TRIP TRACER UI VALIDATION | verdict | api | Sister City: FALSE | Sister City: FALSE |
| CP079 | TRIP TRACER UI VALIDATION | verdict | api | MS DOMINIQUE ARSENAULT / NOT ELIGIBLE / UNCONTROLLABLE_CANCELLATION_NO_DELAY / CAD 0.00 | MS DOMINIQUE ARSENAULT / NOT ELIGIBLE / UNCONTROLLABLE_CANCELLATION_NO_DELAY / CAD 0.00 |
| CP080 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP081 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP082 | AC WALLET CHECK � NOT TRIGGERED | system | implied | Then the chatbot notes: AC Wallet offer is ONLY triggered for ELIGIBLE cases |  |
| CP083 | AC WALLET CHECK � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? AC Wallet NOT offered despite Basic Aeroplan linkage (9876543210) |  |
| CP084 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I can see that your original flight AC 435 from Montreal to Toronto was cancelled due to weather conditions, and you w |
| CP085 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: ""Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your e | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP086 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: ""Claim submission successful!"" | Claim submission successful! |
| CP087 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP088 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP089 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to d***@gmail.com |  |
| CP090 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (AC 435 cancelled WXX Weather ? reprotected renumbered AC 445 YUL?YYZ, same departure |  |
| CP091 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP092 | END FLOW (GLOB-11) | customer | chat | And the user selects ""No"" | No |
| CP093 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds ""Thank you for choosing Air Canada."" | Thank you for choosing Air Canada. |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant ""Dominique Arsenault"" with PNR ""TC024"" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be ""Travel Disruptions � Delay"" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be ""Closed � Not Eligible"" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be ""Dominique Arsenault"" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be ""Adult"" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be ""Pass"" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be ""TC024"" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be ""APPR"" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be ""Dominique Arsenault"" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include ""Claimant"" and ""Adult"" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be ""d***@gmail.com"" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be ""+1***890"" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be ""9876543210"" linked and in good standing (Basic Member) |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be ""Basic / Member"" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show ""Bound 1: YUL ? YYZ"" (original AC 435 cancelled WXX; reprotected renumbered AC 445 same departure 08:00, same  |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Change History should show ""INVOL � AC 435 cancelled (WXX � Weather � Uncontrollable) ? reprotected on renumbered AC 445 YUL?YYZ, s |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show ""NOT ELIGIBLE"" with reason ""WXX (Weather � Uncontrollable) � Canc |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as ""NOT ELIGIBLE"" � WXX Uncontrollable (Gate 3 fails) + 0h arrival delay (Gate 8 fail |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data ""Dominique Arsenault + TC024 + YUL?YYZ + FD"" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be ""No duplicate found"" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And AC Wallet should NOT have been offered despite Basic Aeroplan linkage as it only applies to eligible cases |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from ""Assigned"" to ""In Progress"" |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be ""Closed � Not Eligible"" |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP148 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is ""NOT ELIGIBLE"" due to WXX Uncontrollable cancellation + 0h arrival delay post-reprotection |  |
| CP149 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP150 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP151 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP152 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP153 | PAYMENT VALIDATION | payment | chat | And AC Wallet should NOT have been offered despite Basic Aeroplan linkage (9876543210) � AC Wallet only applies to eligible cases |  |
| CP154 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as ""NOT ELIGIBLE"" with no compensation record and no payout section |  |
| CP155 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-UC-01. | DDS returns FD-APPR-NE-UC-01. |
| CP156 | EXPECTED RESULTS | verdict | api | Trip Tracer: Original promise = 10:00 (AC 435 CANCELLED � WXX Weather � Uncontrollable); Departure 08:00 (SAME as original scheduled departu | Trip Tracer: Original promise = 10:00 (AC 435 CANCELLED � WXX Weather � Uncontrollable); Departure 08:00 (SAME as original scheduled departure); INVOL reprotect |
| CP157 | EXPECTED RESULTS | verdict | api | DUAL NOT ELIGIBLE GATES: (1) DDS Gate 3 � WXX = Uncontrollable ? Cancellation Entitlement NOT triggered ? FAILS; (2) DDS Gate 8 � 0h < 3h ?  | DUAL NOT ELIGIBLE GATES: (1) DDS Gate 3 � WXX = Uncontrollable ? Cancellation Entitlement NOT triggered ? FAILS; (2) DDS Gate 8 � 0h < 3h ? Delay Entitlement NO |
| CP158 | EXPECTED RESULTS | verdict | chat | CRITICAL: WXX is Uncontrollable � neither the cancellation entitlement track ($400 cancellation floor) nor the delay entitlement track (3h t | CRITICAL: WXX is Uncontrollable � neither the cancellation entitlement track ($400 cancellation floor) nor the delay entitlement track (3h threshold) is trigger |
| CP159 | EXPECTED RESULTS | verdict | chat | Aeroplan Basic (9876543210) recognized but AC Wallet NOT offered (NE case). | Aeroplan Basic (9876543210) recognized but AC Wallet NOT offered (NE case). |
| CP160 | EXPECTED RESULTS | verdict | chat | Compensation: $0. | Compensation: $0. |
| CP161 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP162 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP163 | EXPECTED RESULTS | verdict | api | DDS = FD-APPR-NE-UC-01. | DDS = FD-APPR-NE-UC-01. |
