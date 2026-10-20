# FD_TC_098 · CHAI-31490 — checkpoints

**Goal:** ALL disruption codes are missing � no arrival code, no departure code, no cancellation code. The flight operated but was delayed 7 hours (6�<9h band observed in flight status) and no station logged any disruption information. Passenger holds a Basic Aeroplan profile (9876543210) linked to the booking. DDS has no code data to assess controllability. System polls Trip Tracer daily for up to 14 days waiting for codes to be entered. If codes never arrive after 14 days, routes to manual handling. Validates: (1) DDS correctly handles missing codes for an operated delayed flight, (2) 14-day polling window is enforced, (3) After 14 days with no code, case routes to manual review, (4) AC Wallet is NOT offered despite Basic Aeroplan linkage � No Determination cases do not trigger payment flows, (5) Agent manually investigates and determines eligibility.

Methods: chat 44, api 26, email 3, dashboard 47, implied 20, manual 8, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | ALL disruption codes are missing � no arrival code, no departure code, no cancellation code. The flight operated but was delayed 7 hours (6� |  |
| CP002 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP003 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP004 | START | customer | chat | Then user selects English |  |
| CP005 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP006 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP007 | START | customer | chat | And the user says "My flight from Montreal to Toronto was delayed about 7 hours and I never got any explanation from Air Canada. I'd like to | My flight from Montreal to Toronto was delayed about 7 hours and I never got any explanation from Air Canada. I'd like to check if I'm eligible for compensation |
| CP008 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP009 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP010 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP011 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP012 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP013 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP014 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "V�ronique Caron" | V�ronique Caron |
| CP015 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, V�ronique! And, what is your booking reference number? |
| CP016 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC057" | PNR: TC057 |
| CP017 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC057 |  |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP020 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: v***@outlook.com � Phone: +1***789 |
| CP022 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: v***@outlook.com" | Email: v***@outlook.com |
| CP023 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP024 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629481" | 629481 |
| CP025 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP027 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP028 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP029 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP030 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP031 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � V�ronique Caron (Adult - Aeroplan Member) Is this who you'd like to include? |
| CP032 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP033 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP034 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 372 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: May 18, 2026 � Status: ARRIVED LATE � Arrival Delay: 7 hours (ob |
| CP035 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP036 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP037 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP038 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP039 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP040 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 18, 2026; current date is June 10, 2026 ? >72 hours ? PROCEED |  |
| CP041 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP042 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 18, 2026; filing June 10, 2026 ? 23 days ? within 366 days ? PROCEED |  |
| CP043 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP044 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP045 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 372, Route: YUL ? YYZ, Scheduled Arrival: 14:00 | Promised Itinerary - Flight: AC 372, Route: YUL ? YYZ, Scheduled Arrival: 14:00 |
| CP046 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 372, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual Arrival: 21:00, Delay: +7H 00M (6�<9h band observed in AD | Current Itinerary - Flight: AC 372, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual Arrival: 21:00, Delay: +7H 00M (6�<9h band observed in ADS/AODB) |
| CP047 | TRIP TRACER UI VALIDATION | verdict | api | Arrival Code: NULL / MISSING | Arrival Code: NULL / MISSING |
| CP048 | TRIP TRACER UI VALIDATION | verdict | api | Departure Code: NULL / MISSING (no fallback available) | Departure Code: NULL / MISSING (no fallback available) |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Cancellation Code: NULL (flight operated � not cancelled) | Cancellation Code: NULL (flight operated � not cancelled) |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: 9876543210 (Basic Member � linked) | Aeroplan: 9876543210 (Basic Member � linked) |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | DDS Gate 6: Is disruption code available? | DDS Gate 6: Is disruption code available? |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Arrival code: NULL ? check departure code | Arrival code: NULL ? check departure code |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | Departure code: NULL ? NO CODE AVAILABLE | Departure code: NULL ? NO CODE AVAILABLE |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | DDS Gate 6.1: Has 14 days elapsed since disruption? | DDS Gate 6.1: Has 14 days elapsed since disruption? |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Disruption date: May 18, 2026 | Disruption date: May 18, 2026 |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Current date: June 10, 2026 | Current date: June 10, 2026 |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Days elapsed: 23 days ? YES, 14+ days elapsed | Days elapsed: 23 days ? YES, 14+ days elapsed |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Result: NO DETERMINATION � No code available after 14 days ? Manual review required | Result: NO DETERMINATION � No code available after 14 days ? Manual review required |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | MS V�RONIQUE CARON / NO DETERMINATION / NO_CODE_14_DAYS / CAD 0.00 | MS V�RONIQUE CARON / NO DETERMINATION / NO_CODE_14_DAYS / CAD 0.00 |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | NOTE: 7h delay (6�<9h band) IS observed � if code is later entered and confirmed Controllable, APPR Tier 2 ($700 CAD Cash / $840 AC Wallet)  | NOTE: 7h delay (6�<9h band) IS observed � if code is later entered and confirmed Controllable, APPR Tier 2 ($700 CAD Cash / $840 AC Wallet) would apply. Current |
| CP061 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP062 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NO DETERMINATION ? CyberSource NOT invoked |  |
| CP063 | AC WALLET CHECK � NOT TRIGGERED | system | implied | Then the chatbot notes: AC Wallet offer is ONLY triggered for ELIGIBLE cases |  |
| CP064 | AC WALLET CHECK � NOT TRIGGERED | system | implied | And this case is NO DETERMINATION ? AC Wallet NOT offered despite Basic Aeroplan linkage (9876543210) |  |
| CP065 | NO DETERMINATION RESULT � NO CODE (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed your flight details. Your Air Canada flight AC 372 from Montreal (YUL) to Toronto (YYZ) on May 18, 2026 arrived approximately 7 hours late. Unfort |
| CP066 | NO DETERMINATION RESULT � NO CODE (FD-05b) | customer | chat | And the user selects "Yes" | Yes |
| CP067 | MANUAL HANDLING FLOW (GenUC-27) | bot | chat | Then the chatbot responds: | To ensure our team can reach you regarding your claim, please confirm the following: |
| CP068 | MANUAL HANDLING FLOW (GenUC-27) | bot | chat | And the chatbot asks: | Please confirm your preferred email for updates: |
| CP069 | MANUAL HANDLING FLOW (GenUC-27) | customer | chat | And the user confirms: "v***@outlook.com" | v***@outlook.com |
| CP070 | MANUAL HANDLING FLOW (GenUC-27) | bot | chat | And the chatbot asks: | Which country do you reside in? |
| CP071 | MANUAL HANDLING FLOW (GenUC-27) | customer | chat | And the user provides: "Canada" | Canada |
| CP072 | CASE CREATION (GLOB-09) | system | implied | Then the chatbot creates the case and responds: | "Your case has been recorded and forwarded to our Customer Relations team for investigation. Case Reference: CASE-FD-20260610-054." "Our team will investigate t |
| CP073 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP074 | CASE CREATION (GLOB-09) | system | implied | And the case is routed to the agent queue for manual investigation |  |
| CP075 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP076 | NOTIFICATION | email | email | And a case acknowledgement email is sent to v***@outlook.com |  |
| CP077 | NOTIFICATION | email | email | And the email contains: Case Reference (CASE-FD-20260610-054), flight details (AC 372 YUL?YYZ, delayed 7h � no disruption code logged), expl | NOTE: Email does NOT reference potential compensation amount as no eligibility determination has been made |
| CP078 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP079 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP080 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "V�ronique Caron" with PNR "TC057" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Forwarded � Manual Review" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "Customer Relations (Manual Review)" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel may be restricted as it is pending manual review |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "V�ronique Caron" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC057" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "V�ronique Caron" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "v***@outlook.com" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***789" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "9876543210" linked and in good standing (Basic Member) |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be "Basic / Member" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Arrival Delay should show "+7H 00M (6�<9h band � no code logged)" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "No disruption code available after 1 |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a note should indicate: "If code later confirmed Controllable ? APPR Tier 2 ($700 CAD Cash / $840 AC Wallet) would apply � pending agent |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run but returned "NO DETERMINATION" due to Arrival code NULL, Departure code NULL, 14-day window exhausted |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be "PENDING AGENT REVIEW" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "V�ronique Caron + TC057 + YUL?YYZ + FD" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it is pending manual review |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And AC Wallet should NOT have been offered despite Basic Aeroplan linkage (9876543210) � AC Wallet only applies to eligible cases |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should be routed to Customer Relations agent queue for manual investigation |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement email should have been sent to "v***@outlook.com" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email should contain Case Reference "CASE-FD-20260610-054" and flight details AC 372 YUL to YYZ delayed 7h and explanation that disr |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record case creation and No Determination routing with timestamps |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the acknowledgement email |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Forwarded � Manual Review" pending agent investigation |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should NOT be in read-only mode as it is pending CR team action |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP135 | PAYMENT VALIDATION | payment | chat | Given no determination was made due to no disruption code after 14-day retry |  |
| CP136 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And the case was created and sent to agent for manual handling after 14-day retry exhausted |  |
| CP138 | PAYMENT VALIDATION | payment | chat | And no country of residence payment mapping should have been executed |  |
| CP139 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP140 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP141 | PAYMENT VALIDATION | payment | chat | And AC Wallet should NOT have been offered despite Basic Aeroplan linkage (9876543210) � only applies to eligible cases |  |
| CP142 | PAYMENT VALIDATION | payment | chat | And if the agent later determines eligible: | - Manual compensation should be created ($700 CAD Cash / $840 AC Wallet for 7h 6�<9h band Tier 2 if Controllable confirmed) - Payment dispatched per type (Cash  |
| CP143 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved |  |
| CP144 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-ND-04. | DDS returns FD-APPR-ND-04. |
| CP145 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 14:00; Actual = 21:00; Delay = 7hrs (6�<9h band observed � from ADS/AODB flight status data); MSL = Leg 1; Arrival Co | Trip Tracer: Promise = 14:00; Actual = 21:00; Delay = 7hrs (6�<9h band observed � from ADS/AODB flight status data); MSL = Leg 1; Arrival Code = NULL; Departure |
| CP146 | EXPECTED RESULTS | verdict | chat | Aeroplan: Basic Member (9876543210) recognized � AC Wallet NOT offered (No Determination). | Aeroplan: Basic Member (9876543210) recognized � AC Wallet NOT offered (No Determination). |
| CP147 | EXPECTED RESULTS | verdict | api | Polling: System polls Trip Tracer daily for 14 days waiting for code entry. 14-day window EXHAUSTED (23 days since disruption) ? Routes to m | Polling: System polls Trip Tracer daily for 14 days waiting for code entry. 14-day window EXHAUSTED (23 days since disruption) ? Routes to manual handling. |
| CP148 | EXPECTED RESULTS | verdict | chat | If code later confirmed Controllable ? APPR Tier 2 ($700 CAD / $840 AC Wallet) would apply. | If code later confirmed Controllable ? APPR Tier 2 ($700 CAD / $840 AC Wallet) would apply. |
| CP149 | EXPECTED RESULTS | verdict | api | Claims Dashboard: No Determination; Reason = All disruption codes missing after 14-day polling; Delay = 7h (6�<9h band); Aeroplan Basic logg | Claims Dashboard: No Determination; Reason = All disruption codes missing after 14-day polling; Delay = 7h (6�<9h band); Aeroplan Basic logged; DDS = FD-APPR-ND |
