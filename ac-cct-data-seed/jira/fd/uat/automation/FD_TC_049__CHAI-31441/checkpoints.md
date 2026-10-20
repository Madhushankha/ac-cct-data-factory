# FD_TC_049 · CHAI-31441 — checkpoints

**Goal:** Customer's original flight AC 435 YUL?YYZ was CANCELLED due to SKD (Schedule / Commercial Cancellation � Controllable). Customer is reprotected onto renumbered flight AC 445 YUL?YYZ. The renumbered flight departs at the exact SAME scheduled departure time (08:00) as the original flight, but arrives at YYZ only 2 hours 30 minutes later than the original promised arrival (10:00 original promise vs 12:30 actual arrival). Passenger holds a Basic Aeroplan profile (9876543210) linked to the booking. Despite SKD being a Controllable cancellation code, the delay on the renumbered flight is only 2h 30m � below the APPR 3-hour minimum threshold. Validates: (1) Renumbered flight reprotection is correctly captured in change history (INVOL: AC 435 ? AC 445), (2) Delay calculated as actual arrival on renumbered flight (12:30) minus original promised arrival (10:00) = 2h 30m (150 min), (3) DDS applies APPR Gate 8 threshold check � 2h 30m < 3h ? FAILS THRESHOLD ? NOT ELIGIBLE, (4) NOT ELIGIBLE result returned even though SKD is Controllable, (5) AC Wallet NOT offered despite Basic Aeroplan linkage � not eligible cases do not trigger payment flow.

Methods: seed 11, chat 43, api 29, email 3, dashboard 45, implied 20, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer's original flight AC 435 YUL?YYZ was CANCELLED due to SKD (Schedule / Commercial Cancellation � Controllable). Customer is reprotec |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC024 � single passenger Dominique Arsenault (Adult - Basic Aeroplan Member #: 9876543210) | PNR: TC024 � single passenger Dominique Arsenault (Adult - Basic Aeroplan Member #: 9876543210) |
| CP003 | PREREQUISITES | prerequisite | seed | Original itinerary: AC 435 YUL?YYZ, Scheduled departure: 08:00, Scheduled arrival: 10:00 | Original itinerary: AC 435 YUL?YYZ, Scheduled departure: 08:00, Scheduled arrival: 10:00 |
| CP004 | PREREQUISITES | prerequisite | seed | Original flight CANCELLED (Cancellation Code: SKD � Schedule / Commercial Cancellation � Controllable) | Original flight CANCELLED (Cancellation Code: SKD � Schedule / Commercial Cancellation � Controllable) |
| CP005 | PREREQUISITES | prerequisite | seed | Customer reprotected on renumbered flight AC 445 YUL?YYZ | Customer reprotected on renumbered flight AC 445 YUL?YYZ |
| CP006 | PREREQUISITES | prerequisite | seed | Departure time: 08:00 (SAME as original scheduled departure) | Departure time: 08:00 (SAME as original scheduled departure) |
| CP007 | PREREQUISITES | prerequisite | seed | Actual arrival: 12:30 (2h 30min after original 10:00 promise = 150 min � below APPR 3h minimum threshold) | Actual arrival: 12:30 (2h 30min after original 10:00 promise = 150 min � below APPR 3h minimum threshold) |
| CP008 | PREREQUISITES | prerequisite | seed | Delay calculation: 12:30 (actual arrival) ? 10:00 (original promise) = 2h 30m (150 min) | Delay calculation: 12:30 (actual arrival) ? 10:00 (original promise) = 2h 30m (150 min) |
| CP009 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic) | Regime: APPR (domestic) |
| CP010 | PREREQUISITES | prerequisite | seed | Timing: >72hrs elapsed | Timing: >72hrs elapsed |
| CP011 | PREREQUISITES | prerequisite | seed | Filing: Within 366 days | Filing: Within 366 days |
| CP012 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked (9876543210), Basic Member in good standing | Aeroplan: Linked (9876543210), Basic Member in good standing |
| CP013 | PREREQUISITES | prerequisite | implied | CyberSource: NOT invoked (not eligible) | CyberSource: NOT invoked (not eligible) |
| CP014 | PREREQUISITES | prerequisite | implied | RDS: No flags | RDS: No flags |
| CP015 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP016 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP017 | START | customer | chat | Then user selects English |  |
| CP018 | START | alert | chat | Then an alert information is displayed ""Please note that by using this service, you will interact with an automated chatbot which uses AI t | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP019 | START | bot | chat | Then chatbot asks ""How can I help you today?"" | How can I help you today? |
| CP020 | START | customer | chat | And the user says ""My original flight from Montreal to Toronto was cancelled due to a schedule change and I was moved to a renumbered fligh | My original flight from Montreal to Toronto was cancelled due to a schedule change and I was moved to a renumbered flight. It departed at the same time as my or |
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
| CP047 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Original Flight: AC 435 � CANCELLED (SKD � Schedule/Commercial Cancellation) � Reprotected Flight: AC 445 (Renumbered) � Route: |
| CP048 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms ""Yes"" | Yes |
| CP049 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP050 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP052 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP053 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 10, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP054 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP055 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 10, 2026; filing June 15, 2026 ? 36 days ? within 366 days ? PROCEED |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Was the flight cancelled? ? YES (AC 435 � SKD Schedule / Commercial Cancellation) |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Change history = INVOL � AC 435 cancelled (SKD) ? customer reprotected onto renumbered flight AC 445 |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Was the customer reprotected on renumbered flight? ? YES (AC 445 YUL?YYZ, same departure 08:00) |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Actual arrival on renumbered flight at final destination = 12:30 |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Original promised arrival = 10:00 |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | And DDS calculates: Delay = 12:30 ? 10:00 = 2h 30m (150 min) |  |
| CP063 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Was the reprotected arrival delayed ? 3 hours vs original promise? ? NO (2h 30m = 150 min < 180 min threshold) |  |
| CP064 | TRIAGE & DDS EVALUATION | verdict | api | And DDS applies: APPR Gate 8 � Delay threshold check: 2h 30m < 3h ? FAILS THRESHOLD |  |
| CP065 | TRIAGE & DDS EVALUATION | verdict | api | And DDS determines: SKD CANCELLATION + RENUMBERED FLIGHT SAME DEPARTURE BUT ARRIVED < 3H LATE ? NOT ELIGIBLE |  |
| CP066 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 435, Route: YUL ? YYZ, Scheduled Departure: 08:00, Scheduled Arrival: 10:00 (CANCELLED � SKD) | Promised Itinerary - Flight: AC 435, Route: YUL ? YYZ, Scheduled Departure: 08:00, Scheduled Arrival: 10:00 (CANCELLED � SKD) |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | History - Change 1: INVOL � AC 435 CANCELLED (SKD � Schedule / Commercial Cancellation � Controllable). Customer reprotected onto renumbered | History - Change 1: INVOL � AC 435 CANCELLED (SKD � Schedule / Commercial Cancellation � Controllable). Customer reprotected onto renumbered flight AC 445 YUL?Y |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 445 (Renumbered), Route: YUL ? YYZ, Status: ARRIVED, Scheduled Departure: 08:00 (SAME as original), Actual Ar | Current Itinerary - Flight: AC 445 (Renumbered), Route: YUL ? YYZ, Status: ARRIVED, Scheduled Departure: 08:00 (SAME as original), Actual Arrival: 12:30 |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 435 � YUL ? YYZ � SKD (Schedule / Commercial Cancellation � Controllable) | MSL FLIGHT: AC 435 � YUL ? YYZ � SKD (Schedule / Commercial Cancellation � Controllable) |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | Reprotected Flight: AC 445 � YUL ? YYZ � Departed 08:00 (SAME) � Arrived 12:30 | Reprotected Flight: AC 445 � YUL ? YYZ � Departed 08:00 (SAME) � Arrived 12:30 |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | Delay Calculation: Original promise = 10:00; Reprotected actual = 12:30; Delay = +2H 30M (150 min) | Delay Calculation: Original promise = 10:00; Reprotected actual = 12:30; Delay = +2H 30M (150 min) |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | APPR Gate 8: Delay 2h 30m < 3h ? FAILS threshold ? NOT ELIGIBLE | APPR Gate 8: Delay 2h 30m < 3h ? FAILS threshold ? NOT ELIGIBLE |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE | Fallback: FALSE |
| CP076 | TRIP TRACER UI VALIDATION | verdict | api | Sister City: FALSE | Sister City: FALSE |
| CP077 | TRIP TRACER UI VALIDATION | verdict | api | MS DOMINIQUE ARSENAULT / NOT ELIGIBLE / BELOW_THRESHOLD_POST_REPROTECTION / CAD 0.00 | MS DOMINIQUE ARSENAULT / NOT ELIGIBLE / BELOW_THRESHOLD_POST_REPROTECTION / CAD 0.00 |
| CP078 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP079 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP080 | AC WALLET CHECK � NOT TRIGGERED | system | implied | Then the chatbot notes: AC Wallet offer is ONLY triggered for ELIGIBLE cases |  |
| CP081 | AC WALLET CHECK � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? AC Wallet NOT offered despite Basic Aeroplan linkage (9876543210) |  |
| CP082 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I can see that your original flight AC 435 from Montreal to Toronto was cancelled due to a commercial schedule change, |
| CP083 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: ""Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your e | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP084 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: ""Claim submission successful!"" | Claim submission successful! |
| CP085 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP086 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP087 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to d***@gmail.com |  |
| CP088 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (AC 435 cancelled SKD ? reprotected renumbered AC 445 YUL?YYZ, same departure 08:00,  |  |
| CP089 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP090 | END FLOW (GLOB-11) | customer | chat | And the user selects ""No"" | No |
| CP091 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds ""Thank you for choosing Air Canada."" | Thank you for choosing Air Canada. |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant ""Dominique Arsenault"" with PNR ""TC024"" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be ""Travel Disruptions � Delay"" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be ""Closed � Not Eligible"" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be ""Dominique Arsenault"" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be ""Adult"" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be ""Pass"" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be ""TC024"" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be ""APPR"" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be ""Dominique Arsenault"" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include ""Claimant"" and ""Adult"" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be ""d***@gmail.com"" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be ""+1***890"" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be ""9876543210"" linked and in good standing (Basic Member) |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be ""Basic / Member"" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show ""Bound 1: YUL ? YYZ"" (original AC 435 cancelled SKD; reprotected renumbered AC 445 same departure 08:00, arriv |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Change History should show ""INVOL � AC 435 cancelled (SKD) ? reprotected on renumbered AC 445 YUL?YYZ, same departure 08:00"" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show ""NOT ELIGIBLE"" with reason ""Cancellation SKD (Controllable) � Rep |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as ""NOT ELIGIBLE"" � reprotected arrival 2h 30m (150 min) fails APPR Gate 8 threshold  |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data ""Dominique Arsenault + TC024 + YUL?YYZ + FD"" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be ""No duplicate found"" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And AC Wallet should NOT have been offered despite Basic Aeroplan linkage as it only applies to eligible cases |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from ""Assigned"" to ""In Progress"" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be ""Closed � Not Eligible"" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP146 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is ""NOT ELIGIBLE"" due to reprotected arrival below APPR 3h threshold (SKD cancellation, renumbered AC 445, sa |  |
| CP147 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP148 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP149 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP150 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP151 | PAYMENT VALIDATION | payment | chat | And AC Wallet should NOT have been offered despite Basic Aeroplan linkage (9876543210) � AC Wallet only applies to eligible cases |  |
| CP152 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as ""NOT ELIGIBLE"" with no compensation record and no payout section |  |
| CP153 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-01. | DDS returns FD-APPR-NE-01. |
| CP154 | EXPECTED RESULTS | verdict | api | Trip Tracer: Original promise = 10:00 (AC 435 CANCELLED � SKD Schedule / Commercial Cancellation � Controllable); Departure 08:00 (SAME as o | Trip Tracer: Original promise = 10:00 (AC 435 CANCELLED � SKD Schedule / Commercial Cancellation � Controllable); Departure 08:00 (SAME as original scheduled de |
| CP155 | EXPECTED RESULTS | verdict | chat | APPR Gate 8: 2h 30m < 3h ? FAILS ? NOT ELIGIBLE. | APPR Gate 8: 2h 30m < 3h ? FAILS ? NOT ELIGIBLE. |
| CP156 | EXPECTED RESULTS | verdict | chat | CRITICAL: SKD IS controllable and cancellation IS confirmed � however reprotected arrival on renumbered flight is within 3h of original prom | CRITICAL: SKD IS controllable and cancellation IS confirmed � however reprotected arrival on renumbered flight is within 3h of original promise ? $0. |
| CP157 | EXPECTED RESULTS | verdict | chat | Below 3h threshold on reprotected arrival is the sole NE reason. | Below 3h threshold on reprotected arrival is the sole NE reason. |
| CP158 | EXPECTED RESULTS | verdict | chat | Aeroplan Basic (9876543210) recognized but AC Wallet NOT offered (NE case). | Aeroplan Basic (9876543210) recognized but AC Wallet NOT offered (NE case). |
| CP159 | EXPECTED RESULTS | verdict | chat | Compensation: $0 � Below APPR threshold post-reprotection. | Compensation: $0 � Below APPR threshold post-reprotection. |
| CP160 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP161 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP162 | EXPECTED RESULTS | verdict | api | DDS = FD-APPR-NE-01. | DDS = FD-APPR-NE-01. |
