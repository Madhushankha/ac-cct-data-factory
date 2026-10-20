# FD_TC_101 · CHAI-31493 — checkpoints

**Goal:** DDS cannot complete eligibility assessment because critical flight data is MISSING from back-end systems (Trip Tracer, FDM). The actual arrival time has not been finalized � without it, DDS cannot calculate delay, identify MSL, or determine the tier. The system has already waited the full 14-day retry window for data ingestion, but the data never arrived. Since DDS cannot make a determination either way (Eligible or Not Eligible), the result is No Determination (ND) and the case is routed to a human agent for manual investigation using alternative data sources. Different from NE (where DDS definitively says "not eligible") � ND means "we don't have enough data to decide."

Methods: seed 9, chat 42, api 26, email 3, dashboard 45, implied 15, manual 9, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | DDS cannot complete eligibility assessment because critical flight data is MISSING from back-end systems (Trip Tracer, FDM). The actual arri |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger (Adult) | PNR: single passenger (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 377, YUL?YYZ | Journey: 1 leg AC operated, Flight AC 377, YUL?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Flight date: April 25, 2026 | Flight date: April 25, 2026 |
| CP005 | PREREQUISITES | prerequisite | seed | Trip Tracer data status: INCOMPLETE � actual arrival time NOT finalized; flight status not confirmed in FDM | Trip Tracer data status: INCOMPLETE � actual arrival time NOT finalized; flight status not confirmed in FDM |
| CP006 | PREREQUISITES | prerequisite | seed | Scheduled arrival: Available | Scheduled arrival: Available |
| CP007 | PREREQUISITES | prerequisite | seed | Actual arrival: MISSING (not ingested into Trip Tracer) | Actual arrival: MISSING (not ingested into Trip Tracer) |
| CP008 | PREREQUISITES | prerequisite | seed | 14-day retry window: EXHAUSTED (flight was April 25, claim filed after May 9 � data still not available) | 14-day retry window: EXHAUSTED (flight was April 25, claim filed after May 9 � data still not available) |
| CP009 | PREREQUISITES | prerequisite | seed | Disruption code: Cannot be assessed (dependent on missing data) | Disruption code: Cannot be assessed (dependent on missing data) |
| CP010 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic) | Regime: APPR (domestic) |
| CP011 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP012 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP013 | START | customer | chat | Then user selects English |  |
| CP014 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP015 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP016 | START | customer | chat | And the user says "My flight was delayed several hours, I'd like to check if I'm eligible for compensation" | My flight was delayed several hours, I'd like to check if I'm eligible for compensation |
| CP017 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP018 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP019 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP020 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Jacques Fortier" | Jacques Fortier |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Jacques! And, what is your booking reference number? |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC058" | PNR: TC058 |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC058 |  |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data is revealed BUT INCOMPLETE � missing actual arrival time and/or flight status |  |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: j***@gmail.com � Phone: +1***567 |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: j***@gmail.com" | Email: j***@gmail.com |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP034 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP036 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP037 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP039 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Jacques Fortier (Adult) Is this who you'd like to include? |
| CP041 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP043 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 502 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: May 16, 2026 � Status: Data incomplete Is this the journey you'd |
| CP044 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure (actual arrival unknown) |  |
| CP049 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure was May 16, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 16, 2026; filing June 15, 2026 ? 30 days ? within 366 days ? PROCEED |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is attempted in backend |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Is required flight data available? |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Actual arrival time ? MISSING (NULL) |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Flight status ? MISSING or INCOMPLETE |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: 14-day retry window exhausted? ? YES (disruption May 16; window ended May 30; current date June 15 ? exhausted) |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | And DDS determines: CRITICAL DATA MISSING AFTER 14-DAY RETRY ? CANNOT RUN ASSESSMENT ? NO DETERMINATION |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 502, Route: YUL ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 12:00 | Promised Itinerary - Flight: AC 502, Route: YUL ? YYZ, Scheduled Departure: 10:00, Scheduled Arrival: 12:00 |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 502, Route: YUL ? YYZ, Status: INCOMPLETE DATA | Current Itinerary - Flight: AC 502, Route: YUL ? YYZ, Status: INCOMPLETE DATA |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Actual Arrival: NULL (MISSING) | Actual Arrival: NULL (MISSING) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Flight Status: MISSING or NOT UPDATED | Flight Status: MISSING or NOT UPDATED |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Delay: CANNOT CALCULATE (actual arrival unknown) | Delay: CANNOT CALCULATE (actual arrival unknown) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Disruption Code: N/A (DDS cannot run without flight data) | Disruption Code: N/A (DDS cannot run without flight data) |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | 14-Day Retry Window: Disruption May 16 ? Window ended May 30 ? EXHAUSTED | 14-Day Retry Window: Disruption May 16 ? Window ended May 30 ? EXHAUSTED |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | DDS: CANNOT RUN ASSESSMENT � CRITICAL DATA MISSING | DDS: CANNOT RUN ASSESSMENT � CRITICAL DATA MISSING |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Determination: NO DETERMINATION ? SENT TO AGENT | Determination: NO DETERMINATION ? SENT TO AGENT |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | MR JACQUES FORTIER / NO DETERMINATION / DATA_MISSING / PENDING AGENT REVIEW | MR JACQUES FORTIER / NO DETERMINATION / DATA_MISSING / PENDING AGENT REVIEW |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | NO FRAUD SCREENING (not triggered for No Determination) | NO FRAUD SCREENING (not triggered for No Determination) |
| CP070 | NO DETERMINATION RESULT | bot | chat | Then the chatbot displays: | I've reviewed your flight details. Your flight AC 502 from Montreal (YUL) to Toronto (YYZ) on May 16, 2026 appears to have experienced a disruption. However, I' |
| CP071 | NO DETERMINATION RESULT | customer | chat | And the user selects "Yes" | Yes |
| CP072 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been forwarded to our team for review. You will receive an update via email once the r | Thank you. Your claim has been forwarded to our team for review. You will receive an update via email once the review is complete. |
| CP073 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim forwarded for review!" | Claim forwarded for review! |
| CP074 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP075 | CASE CREATION (GLOB-09) | system | implied | And the case is routed to the manual review team |  |
| CP076 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP077 | NOTIFICATION | email | email | And a No Determination notification email is sent to j***@gmail.com |  |
| CP078 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, reason for manual review (critical data missing after 14-day retry), next steps, tra |  |
| CP079 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP080 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP081 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Jacques Fortier" with PNR "TC058" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Forwarded � Manual Review" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "Manual Review Team" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel may be restricted as it is pending manual review |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Jacques Fortier" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC058" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Jacques Fortier" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "j***@gmail.com" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***567" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "Critical data missing � actual arriv |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have attempted but cannot run assessment due to critical flight data missing after 14-day retry |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be "PENDING AGENT REVIEW" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Jacques Fortier + TC058 + YUL?YYZ + FD" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it is pending manual review |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should be routed to Manual Review Team |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a No Determination notification email should have been sent to "j***@gmail.com" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email should contain the Case Reference and flight details and reason for manual review being critical data missing after 14-day ret |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record case creation and No Determination routing with timestamps |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the No Determination notification email |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Forwarded � Manual Review" pending agent review |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should NOT be in read-only mode as it is pending manual review team action |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP134 | PAYMENT VALIDATION | payment | chat | Given no determination was made due to critical data missing after 14-day retry |  |
| CP135 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP136 | PAYMENT VALIDATION | payment | chat | And the case was created and sent to agent for manual handling after 14-day retry exhausted |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP138 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP139 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP140 | PAYMENT VALIDATION | payment | manual | And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e- |  |
| CP141 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved |  |
| CP142 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-ND-05. | DDS returns FD-APPR-ND-05. |
| CP143 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = available (scheduled arrival); Actual = MISSING (not finalized); Delay = CANNOT CALCULATE (actual arrival unknown); M | Trip Tracer: Promise = available (scheduled arrival); Actual = MISSING (not finalized); Delay = CANNOT CALCULATE (actual arrival unknown); MSL = CANNOT IDENTIFY |
| CP144 | EXPECTED RESULTS | verdict | chat | Data Completeness Check: Critical data point missing (actual arrival time); 14-day retry window exhausted; No additional data feeds expected | Data Completeness Check: Critical data point missing (actual arrival time); 14-day retry window exhausted; No additional data feeds expected ? NO DETERMINATION. |
| CP145 | EXPECTED RESULTS | verdict | chat | Case Routing: Manual handling � case forwarded to CR agent for investigation using alternative sources (ADS logs, airport records, manual fl | Case Routing: Manual handling � case forwarded to CR agent for investigation using alternative sources (ADS logs, airport records, manual flight data lookup). |
| CP146 | EXPECTED RESULTS | verdict | chat | Compensation: NOT CALCULATED (pending manual review). | Compensation: NOT CALCULATED (pending manual review). |
| CP147 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP148 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP149 | EXPECTED RESULTS | verdict | api | Regime Assessment: APPR = ND-05 (Data missing after 14 days); EU = N/A; ASL = N/A. | Regime Assessment: APPR = ND-05 (Data missing after 14 days); EU = N/A; ASL = N/A. |
| CP150 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Case = CASE-FD-20260520-055; Status = Pending � Agent Review; Reason = Critical data missing from systems; Flag = "Data Mi | Claims Dashboard: Case = CASE-FD-20260520-055; Status = Pending � Agent Review; Reason = Critical data missing from systems; Flag = "Data Missing - System"; Age |
