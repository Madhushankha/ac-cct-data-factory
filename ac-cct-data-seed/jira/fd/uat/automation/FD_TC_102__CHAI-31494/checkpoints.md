# FD_TC_102 · CHAI-31494 — checkpoints

**Goal:** Multi-leg international journey with an AC-operated leg AND an OAL-operated leg (British Airways). AC's own leg data is complete, but the OAL leg data has NOT been received through OAG (Official Airline Guide) data feeds within the 14-day window. Without OAL timing data, DDS cannot determine: (1) actual arrival at the final destination (EDI), (2) whether the delay was caused by AC's leg or the OAL leg, (3) correct MSL identification across carriers. The case is routed for manual handling. Different from TC_072 (AC's own data missing) � here AC's data is fine but the PARTNER airline's data is unavailable from the external feed.

Methods: seed 9, chat 40, api 25, email 3, dashboard 45, implied 16, manual 9, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Multi-leg international journey with an AC-operated leg AND an OAL-operated leg (British Airways). AC's own leg data is complete, but the OA |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC056 � single passenger (Adult) | PNR: TC056 � single passenger (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 2 legs: Leg 1 AC 848 YUL?LHR (AC operated � data AVAILABLE); Leg 2 BA 1234 LHR?EDI (British Airways operated � data NOT AVAILABLE) | Journey: 2 legs: Leg 1 AC 848 YUL?LHR (AC operated � data AVAILABLE); Leg 2 BA 1234 LHR?EDI (British Airways operated � data NOT AVAILABLE) |
| CP004 | PREREQUISITES | prerequisite | seed | Flight date: April 28, 2026 | Flight date: April 28, 2026 |
| CP005 | PREREQUISITES | prerequisite | seed | AC leg data: Complete (departure, arrival, codes � all available) | AC leg data: Complete (departure, arrival, codes � all available) |
| CP006 | PREREQUISITES | prerequisite | seed | OAL leg data: NOT RECEIVED from OAG feeds within 14-day window | OAL leg data: NOT RECEIVED from OAG feeds within 14-day window |
| CP007 | PREREQUISITES | prerequisite | seed | Final destination: EDI (Edinburgh) | Final destination: EDI (Edinburgh) |
| CP008 | PREREQUISITES | prerequisite | seed | Actual arrival at EDI: UNKNOWN (depends on OAL data) | Actual arrival at EDI: UNKNOWN (depends on OAL data) |
| CP009 | PREREQUISITES | prerequisite | seed | 14-day retry: EXHAUSTED | 14-day retry: EXHAUSTED |
| CP010 | PREREQUISITES | prerequisite | seed | Regime: APPR (Canada departure); EU potentially applicable (LHR connection) | Regime: APPR (Canada departure); EU potentially applicable (LHR connection) |
| CP011 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP012 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP013 | START | customer | chat | Then user selects English |  |
| CP014 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP015 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP016 | START | customer | chat | And the user says "I flew from Montreal to Toronto on Air Canada and then from Toronto to Vancouver on another airline. The second flight wa | I flew from Montreal to Toronto on Air Canada and then from Toronto to Vancouver on another airline. The second flight was delayed. Can I get compensation? |
| CP017 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP018 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP019 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP020 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "�mile Gagnon" | �mile Gagnon |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, �mile! And, what is your booking reference number? |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC059" | PNR: TC059 |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC059 |  |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data is revealed � AC segment complete, OAL segment data MISSING |  |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: e***@gmail.com � Phone: +1***678 |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: e***@gmail.com" | Email: e***@gmail.com |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP034 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP036 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP037 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP039 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � �mile Gagnon (Adult) Is this who you'd like to include? |
| CP041 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP043 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Segment 1: Flight AC 503, Montreal (YUL) ? Toronto (YYZ), May 17, 2026 � COMPLETED (AC operated, data complete) � Segment 2: Fl |
| CP044 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP046 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED (AC, data complete), Segment 2 DATA UNAVAILABLE (OAL) |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure |  |
| CP050 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure was May 17, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 17, 2026; filing June 15, 2026 ? 29 days ? within 366 days ? PROCEED |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is attempted in backend |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Is all required flight data available for all segments? |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Segment 1 (AC 503) ? DATA COMPLETE (arrival time, status, codes all available) |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Segment 2 (PD 234) ? DATA NOT AVAILABLE (OAL data not received via OAG feeds) |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: 14-day retry window for OAG data exhausted? ? YES (disruption May 17; window ended May 31; current date June 15 ? exhausted) |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS determines: OAL DATA NOT AVAILABLE AFTER 14-DAY RETRY ? CANNOT CALCULATE DELAY PROPERLY ? NO DETERMINATION |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Segment 1: Flight: AC 503, Route: YUL ? YYZ, Status: COMPLETED, Data: COMPLETE | Segment 1: Flight: AC 503, Route: YUL ? YYZ, Status: COMPLETED, Data: COMPLETE |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Segment 2: Flight: PD 234, Route: YYZ ? YVR, Status: DATA NOT AVAILABLE (OAL � OAG feed not received) | Segment 2: Flight: PD 234, Route: YYZ ? YVR, Status: DATA NOT AVAILABLE (OAL � OAG feed not received) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | AC Data: Complete for Segment 1 | AC Data: Complete for Segment 1 |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | OAL Data: NOT RECEIVED via OAG for Segment 2 | OAL Data: NOT RECEIVED via OAG for Segment 2 |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | 14-Day Retry Window: Disruption May 17 ? Window ended May 31 ? EXHAUSTED | 14-Day Retry Window: Disruption May 17 ? Window ended May 31 ? EXHAUSTED |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | DDS: CANNOT CALCULATE DELAY � OAL DATA MISSING | DDS: CANNOT CALCULATE DELAY � OAL DATA MISSING |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Determination: NO DETERMINATION ? SENT TO AGENT | Determination: NO DETERMINATION ? SENT TO AGENT |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | MR �MILE GAGNON / NO DETERMINATION / OAL_DATA_NOT_AVAILABLE / PENDING AGENT REVIEW | MR �MILE GAGNON / NO DETERMINATION / OAL_DATA_NOT_AVAILABLE / PENDING AGENT REVIEW |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | NO FRAUD SCREENING (not triggered for No Determination) | NO FRAUD SCREENING (not triggered for No Determination) |
| CP069 | NO DETERMINATION RESULT | bot | chat | Then the chatbot displays: | I've reviewed your flight details. Your journey included a segment operated by another airline, and we have not yet received the complete flight data needed to  |
| CP070 | NO DETERMINATION RESULT | customer | chat | And the user selects "Yes" | Yes |
| CP071 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been forwarded to our team for review. You will receive an update via email once the r | Thank you. Your claim has been forwarded to our team for review. You will receive an update via email once the review is complete. |
| CP072 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim forwarded for review!" | Claim forwarded for review! |
| CP073 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP074 | CASE CREATION (GLOB-09) | system | implied | And the case is routed to the manual review team |  |
| CP075 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP076 | NOTIFICATION | email | email | And a No Determination notification email is sent to e***@gmail.com |  |
| CP077 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, reason for manual review (OAL data not available after 14-day retry), next steps, tr |  |
| CP078 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP079 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP080 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "�mile Gagnon" with PNR "TC059" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Forwarded � Manual Review" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "Manual Review Team" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel may be restricted as it is pending manual review |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "�mile Gagnon" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC059" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "�mile Gagnon" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "e***@gmail.com" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***678" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: YUL ? YYZ" as completed and AC operated with data complete and "Segment 2: YYZ ? YVR" as OAL operate |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "OAL data not received via OAG feeds  |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have attempted but cannot calculate delay due to OAL segment data missing and 14-day OAG retry exhausted |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be "PENDING AGENT REVIEW" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "�mile Gagnon + TC059 + YUL?YVR + FD" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it is pending manual review |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should be routed to Manual Review Team |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a No Determination notification email should have been sent to "e***@gmail.com" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email should contain the Case Reference and flight details and reason for manual review being OAL data not available after 14-day re |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record case creation and No Determination routing with timestamps |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the No Determination notification email |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Forwarded � Manual Review" pending agent review |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should NOT be in read-only mode as it is pending manual review team action |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP133 | PAYMENT VALIDATION | payment | chat | Given no determination was made due to OAL data missing after 14-day retry |  |
| CP134 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP135 | PAYMENT VALIDATION | payment | chat | And the case was created and sent to agent for manual handling after 14-day retry exhausted |  |
| CP136 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP138 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP139 | PAYMENT VALIDATION | payment | manual | And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e- |  |
| CP140 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved |  |
| CP141 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-ND-06. | DDS returns FD-APPR-ND-06. |
| CP142 | EXPECTED RESULTS | verdict | api | Trip Tracer: Leg 1 (AC YUL?LHR) = Data AVAILABLE (AC operated, times confirmed); Leg 2 (BA LHR?EDI) = Data NOT AVAILABLE (OAG feed has not p | Trip Tracer: Leg 1 (AC YUL?LHR) = Data AVAILABLE (AC operated, times confirmed); Leg 2 (BA LHR?EDI) = Data NOT AVAILABLE (OAG feed has not provided BA flight da |
| CP143 | EXPECTED RESULTS | verdict | chat | OAL Data Check: OAG feed for BA 1234 = NOT RECEIVED; 14-day window exhausted; Cannot determine if customer missed connection due to AC delay | OAL Data Check: OAG feed for BA 1234 = NOT RECEIVED; 14-day window exhausted; Cannot determine if customer missed connection due to AC delay or if BA leg was in |
| CP144 | EXPECTED RESULTS | verdict | api | Case Routing: Manual handling � agent must contact BA or use alternative sources to obtain Leg 2 timing data, then re-run DDS. | Case Routing: Manual handling � agent must contact BA or use alternative sources to obtain Leg 2 timing data, then re-run DDS. |
| CP145 | EXPECTED RESULTS | verdict | chat | Compensation: NOT CALCULATED. | Compensation: NOT CALCULATED. |
| CP146 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP147 | EXPECTED RESULTS | verdict | api | Regime Assessment: APPR = ND-06 (OAL data unavailable); EU = N/A (cannot assess without complete data); ASL = N/A. | Regime Assessment: APPR = ND-06 (OAL data unavailable); EU = N/A (cannot assess without complete data); ASL = N/A. |
| CP148 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Case = CASE-FD-20260520-056; Status = Pending � Agent Review; Reason = OAL data not received from OAG feeds; Flag = "OAL D | Claims Dashboard: Case = CASE-FD-20260520-056; Status = Pending � Agent Review; Reason = OAL data not received from OAG feeds; Flag = "OAL Data Unavailable"; AC |
