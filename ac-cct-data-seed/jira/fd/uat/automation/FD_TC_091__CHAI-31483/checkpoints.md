# FD_TC_091 · CHAI-31483 — checkpoints

**Goal:** Flight AC 364 YUL?YYZ operated but arrived 1 hour 45 minutes late due to Code 64 (Flight Crew Shortage � Controllable). The 1h 45m delay falls well below the APPR minimum qualifying threshold of 3 hours, making the passenger NOT ELIGIBLE for compensation. Passenger holds a Basic Aeroplan profile (9876543210) linked to the booking. Validates that: (1) DDS correctly identifies that the delay exists and has a valid controllable code (Code 64), (2) DDS applies the APPR 3-hour minimum threshold gate and fails the claim because 1h 45m < 3h, (3) NOT ELIGIBLE result is returned even though the delay is controllable, (4) AC Wallet is NOT offered as no compensation is payable, (5) Basic Aeroplan profile is recognized but does not affect eligibility outcome.

Prerequisites
PNR: TC051 � single passenger V�ronique Gagnon (Adult - Basic Aeroplan Member). Journey: 1 leg AC operated, Flight AC 364, YUL?YYZ (domestic). Scheduled arrival: 14:00. Actual arrival: 15:45 (1h 45min delay, 105 min). Arrival delay code: 64 (Flight Crew Shortage � Controllable, available, no fallback). Delay: 1h 45min (105 min � below APPR 3h minimum threshold). Regime: APPR (domestic). Booking changes: None. Timing: >72hrs elapsed. Filing: Within 366 days. Aeroplan: Linked (9876543210), Basic Member in good standing. CyberSource: NOT invoked (not eligible). RDS: No flags.

Methods: chat 41, api 27, email 3, dashboard 45, implied 18, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Flight AC 364 YUL?YYZ operated but arrived 1 hour 45 minutes late due to Code 64 (Flight Crew Shortage � Controllable). The 1h 45m delay fal |  |
| CP002 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP003 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP004 | START | customer | chat | Then user selects English |  |
| CP005 | START | alert | chat | Then an alert information is displayed ""Please note that by using this service, you will interact with an automated chatbot which uses AI t | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP006 | START | bot | chat | Then chatbot asks ""How can I help you today?"" | How can I help you today? |
| CP007 | START | customer | chat | And the user says ""My flight from Montreal to Toronto was delayed about 1 hour and 45 minutes due to crew issues. I'd like to check if I'm  | My flight from Montreal to Toronto was delayed about 1 hour and 45 minutes due to crew issues. I'd like to check if I'm eligible for compensation |
| CP008 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP009 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP010 | START | bot | chat | Then the chatbot responds: ""No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP011 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: ""Please note that the assessment and decision regarding your request will be made through an automated decision- | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP012 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP013 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP014 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides ""V�ronique Gagnon"" | V�ronique Gagnon |
| CP015 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, V�ronique! And, what is your booking reference number? |
| CP016 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides ""PNR: TC051"" | PNR: TC051 |
| CP017 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC051 |  |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP020 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: v***@gmail.com � Phone: +1***890 |
| CP022 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects ""Email: v***@gmail.com"" | Email: v***@gmail.com |
| CP023 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP024 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code ""371928"" | 371928 |
| CP025 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP027 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP028 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP029 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP030 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP031 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � V�ronique Gagnon (Adult - Aeroplan Member) Is this who you'd like to include? |
| CP032 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms ""Yes"" | Yes |
| CP033 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP034 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 364 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 4, 2026 � Scheduled Arrival: 14:00 � Actual Arrival: 15:45  |
| CP035 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms ""Yes"" | Yes |
| CP036 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP037 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP038 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP039 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP040 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was June 4, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP041 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP042 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Flight date June 4, 2026; filing June 15, 2026 ? 11 days ? within 366 days ? PROCEED |  |
| CP043 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP044 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Was the flight cancelled? ? NO (flight operated AC 364 YUL?YYZ) |  |
| CP045 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Booking changes? ? NONE (no VOL or INVOL) |  |
| CP046 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Arrival delay code present? ? YES (Code 64 � Flight Crew Shortage, Controllable) |  |
| CP047 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Was the flight delayed ? 3 hours at destination? ? NO (1h 45m = 105 min < 180 min threshold) |  |
| CP048 | TRIAGE & DDS EVALUATION | verdict | api | And DDS applies: APPR Gate 8 � Delay threshold check: 1h 45m < 3h ? FAILS THRESHOLD |  |
| CP049 | TRIAGE & DDS EVALUATION | verdict | api | And DDS determines: DELAY EXISTS BUT BELOW APPR MINIMUM THRESHOLD ? NOT ELIGIBLE |  |
| CP050 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 364, Route: YUL ? YYZ, Scheduled Arrival: 14:00 | Promised Itinerary - Flight: AC 364, Route: YUL ? YYZ, Scheduled Arrival: 14:00 |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 364, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 14:00 ? Actual: 15:45, Delay: +1H 45M (105 mi | Current Itinerary - Flight: AC 364, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 14:00 ? Actual: 15:45, Delay: +1H 45M (105 min) |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | Booking Changes: NONE (flight operated, no cancellation, no rebooking) | Booking Changes: NONE (flight operated, no cancellation, no rebooking) |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 364 � YUL ? YYZ � 64 | MSL FLIGHT: AC 364 � YUL ? YYZ � 64 |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | ""Delayed due to flight crew shortage"" | ""Delayed due to flight crew shortage"" |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +1H 45M � CONTROLLABLE | Delay: +1H 45M � CONTROLLABLE |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | APPR Gate 8: Delay 1h 45m < 3h ? FAILS threshold ? NOT ELIGIBLE | APPR Gate 8: Delay 1h 45m < 3h ? FAILS threshold ? NOT ELIGIBLE |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE | Fallback: FALSE |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | MS V�RONIQUE GAGNON / NOT ELIGIBLE / BELOW_THRESHOLD / CAD 0.00 | MS V�RONIQUE GAGNON / NOT ELIGIBLE / BELOW_THRESHOLD / CAD 0.00 |
| CP061 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP062 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP063 | AC WALLET CHECK � NOT TRIGGERED | system | implied | Then the chatbot notes: AC Wallet offer is ONLY triggered for ELIGIBLE cases |  |
| CP064 | AC WALLET CHECK � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? AC Wallet NOT offered despite Basic Aeroplan linkage (9876543210) |  |
| CP065 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your departure from Montreal was delayed by 1 hour and 45 minutes due to a crew shortage. However, you ar |
| CP066 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: ""Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your e | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP067 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: ""Claim submission successful!"" | Claim submission successful! |
| CP068 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP069 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP070 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to v***@gmail.com |  |
| CP071 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (AC 364 YUL?YYZ, delayed 1h 45m), not eligible reason (delay 1h 45m below APPR 3h thr |  |
| CP072 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP073 | END FLOW (GLOB-11) | customer | chat | And the user selects ""No"" | No |
| CP074 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds ""Thank you for choosing Air Canada."" | Thank you for choosing Air Canada. |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant ""V�ronique Gagnon"" with PNR ""TC051"" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be ""Travel Disruptions � Delay"" |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be ""Closed � Not Eligible"" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be ""V�ronique Gagnon"" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be ""Adult"" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be ""Pass"" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be ""TC051"" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be ""APPR"" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be ""V�ronique Gagnon"" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include ""Claimant"" and ""Adult"" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be ""v***@gmail.com"" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be ""+1***890"" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be ""9876543210"" linked and in good standing (Basic Member) |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be ""Basic / Member"" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show ""Bound 1: YUL ? YYZ"" (AC 364 operated, delayed 1h 45m, Code 64) |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Change History should show ""No booking changes � flight operated as AC 364"" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show ""NOT ELIGIBLE"" with reason ""Delay 1h 45m (105 min) below APPR 3h  |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as ""NOT ELIGIBLE"" � delay 1h 45m (105 min) fails APPR Gate 8 threshold (minimum 3h /  |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data ""V�ronique Gagnon + TC051 + YUL?YYZ + FD"" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be ""No duplicate found"" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And AC Wallet should NOT have been offered despite Basic Aeroplan linkage as it only applies to eligible cases |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from ""Assigned"" to ""In Progress"" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be ""Closed � Not Eligible"" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP129 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is ""NOT ELIGIBLE"" due to delay below APPR 3h threshold (Code 64, 1h 45m) |  |
| CP130 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP131 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP133 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP134 | PAYMENT VALIDATION | payment | chat | And AC Wallet should NOT have been offered despite Basic Aeroplan linkage (9876543210) � AC Wallet only applies to eligible cases |  |
| CP135 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as ""NOT ELIGIBLE"" with no compensation record and no payout section |  |
| CP136 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-01. | DDS returns FD-APPR-NE-01. |
| CP137 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 14:00; Actual = 15:45; Delay = 1h 45m (105 min � below APPR 3h threshold); MSL = Leg 1 (AC 364); Code 64 (Flight Crew | Trip Tracer: Promise = 14:00; Actual = 15:45; Delay = 1h 45m (105 min � below APPR 3h threshold); MSL = Leg 1 (AC 364); Code 64 (Flight Crew Shortage � Controll |
| CP138 | EXPECTED RESULTS | verdict | chat | No booking changes � flight operated as scheduled (no cancellation, no rebooking). | No booking changes � flight operated as scheduled (no cancellation, no rebooking). |
| CP139 | EXPECTED RESULTS | verdict | api | CRITICAL: Code 64 IS controllable and delay IS confirmed � however 1h 45m < 3h APPR minimum threshold ? $0. | CRITICAL: Code 64 IS controllable and delay IS confirmed � however 1h 45m < 3h APPR minimum threshold ? $0. |
| CP140 | EXPECTED RESULTS | verdict | api | Delay duration below threshold is the sole NE reason. | Delay duration below threshold is the sole NE reason. |
| CP141 | EXPECTED RESULTS | verdict | chat | Aeroplan Basic (9876543210) recognized but AC Wallet NOT offered (NE case). | Aeroplan Basic (9876543210) recognized but AC Wallet NOT offered (NE case). |
| CP142 | EXPECTED RESULTS | verdict | chat | Compensation: $0 � Below APPR threshold. | Compensation: $0 � Below APPR threshold. |
| CP143 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP144 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP145 | EXPECTED RESULTS | verdict | api | DDS = FD-APPR-NE-01 | DDS = FD-APPR-NE-01 |
