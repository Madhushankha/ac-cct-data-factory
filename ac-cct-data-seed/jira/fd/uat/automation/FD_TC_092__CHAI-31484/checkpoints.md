# FD_TC_092 · CHAI-31484 — checkpoints

**Goal:** Flight AC 364 YUL?YYZ operated but arrived 1 hour 45 minutes late due to Code 67 (Crew Transport / Hotel / Logistics Delay � Controllable). The 1h 45m delay falls well below the APPR minimum qualifying threshold of 3 hours, making ALL THREE passengers NOT ELIGIBLE for compensation. Claimant holds a Basic Aeroplan profile (9876543210) linked to the booking. Validates that: (1) DDS correctly identifies that the delay exists and has a valid controllable code (Code 67), (2) DDS applies the APPR 3-hour minimum threshold gate and fails the claim because 1h 45m < 3h, (3) NOT ELIGIBLE result is returned for all 3 passengers even though the delay is controllable, (4) AC Wallet is NOT offered as no compensation is payable, (5) Basic Aeroplan profile is recognized but does not affect eligibility outcome, (6) 3-passenger claim is correctly handled � all 3 PAX display correctly in passenger selection, PAX count ?9 confirms not a group booking.

Methods: seed 11, chat 41, api 28, email 3, dashboard 46, implied 20, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Flight AC 364 YUL?YYZ operated but arrived 1 hour 45 minutes late due to Code 67 (Crew Transport / Hotel / Logistics Delay � Controllable).  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC051 � 3 passengers (V�ronique Gagnon Adult � Basic Aeroplan Member; Marc Gagnon Adult; Sophie Gagnon Adult) | PNR: TC051 � 3 passengers (V�ronique Gagnon Adult � Basic Aeroplan Member; Marc Gagnon Adult; Sophie Gagnon Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 364, YUL?YYZ (domestic) | Journey: 1 leg AC operated, Flight AC 364, YUL?YYZ (domestic) |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 14:00 | Scheduled arrival: 14:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival: 15:45 (1h 45min delay, 105 min) | Actual arrival: 15:45 (1h 45min delay, 105 min) |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival delay code: 67 (Crew Transport / Hotel / Logistics Delay � Controllable, available, no fallback) | Arrival delay code: 67 (Crew Transport / Hotel / Logistics Delay � Controllable, available, no fallback) |
| CP007 | PREREQUISITES | prerequisite | seed | Delay: 1h 45min (105 min � below APPR 3h minimum threshold) | Delay: 1h 45min (105 min � below APPR 3h minimum threshold) |
| CP008 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic) | Regime: APPR (domestic) |
| CP009 | PREREQUISITES | prerequisite | seed | Booking changes: None | Booking changes: None |
| CP010 | PREREQUISITES | prerequisite | seed | Timing: >72hrs elapsed | Timing: >72hrs elapsed |
| CP011 | PREREQUISITES | prerequisite | seed | Filing: Within 366 days | Filing: Within 366 days |
| CP012 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked on claimant V�ronique Gagnon (9876543210), Basic Member in good standing | Aeroplan: Linked on claimant V�ronique Gagnon (9876543210), Basic Member in good standing |
| CP013 | PREREQUISITES | prerequisite | implied | CyberSource: NOT invoked (not eligible) | CyberSource: NOT invoked (not eligible) |
| CP014 | PREREQUISITES | prerequisite | implied | RDS: No flags | RDS: No flags |
| CP015 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP016 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP017 | START | customer | chat | Then user selects English |  |
| CP018 | START | alert | chat | Then an alert information is displayed ""Please note that by using this service, you will interact with an automated chatbot which uses AI t | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP019 | START | bot | chat | Then chatbot asks ""How can I help you today?"" | How can I help you today? |
| CP020 | START | customer | chat | And the user says ""My flight from Montreal to Toronto was delayed about 1 hour and 45 minutes due to crew transport issues. There were 3 of | My flight from Montreal to Toronto was delayed about 1 hour and 45 minutes due to crew transport issues. There were 3 of us on the booking. I'd like to check if |
| CP021 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP022 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP023 | START | bot | chat | Then the chatbot responds: ""No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP024 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: ""Please note that the assessment and decision regarding your request will be made through an automated decision- | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides ""V�ronique Gagnon"" | V�ronique Gagnon |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, V�ronique! And, what is your booking reference number? |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides ""PNR: TC051"" | PNR: TC051 |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC051 |  |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: v***@gmail.com � Phone: +1***890 |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects ""Email: v***@gmail.com"" | Email: v***@gmail.com |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code ""371928"" | 371928 |
| CP038 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP040 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP041 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP042 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP043 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP044 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 3 passengers on this booking: � V�ronique Gagnon (Adult - Aeroplan Member) � Marc Gagnon (Adult) � Sophie Gagnon (Adult) Would you like to include all 3 |
| CP045 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms ""Yes, include all 3"" | Yes, include all 3 |
| CP046 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 3 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP047 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 364 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 4, 2026 � Scheduled Arrival: 14:00 � Actual Arrival: 15:45  |
| CP048 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms ""Yes"" | Yes |
| CP049 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP050 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for any of the 3 passengers + journey combination |  |
| CP052 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP053 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was June 4, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP054 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP055 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Flight date June 4, 2026; filing June 15, 2026 ? 11 days ? within 366 days ? PROCEED |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Was the flight cancelled? ? NO (flight operated AC 364 YUL?YYZ) |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Booking changes? ? NONE (no VOL or INVOL) |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Arrival delay code present? ? YES (Code 67 � Crew Transport / Hotel / Logistics Delay, Controllable) |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Was the flight delayed ? 3 hours at destination? ? NO (1h 45m = 105 min < 180 min threshold) |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS applies: APPR Gate 8 � Delay threshold check: 1h 45m < 3h ? FAILS THRESHOLD |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | And DDS determines: DELAY EXISTS BUT BELOW APPR MINIMUM THRESHOLD ? NOT ELIGIBLE for ALL 3 passengers |  |
| CP063 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 364, Route: YUL ? YYZ, Scheduled Arrival: 14:00 | Promised Itinerary - Flight: AC 364, Route: YUL ? YYZ, Scheduled Arrival: 14:00 |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 364, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 14:00 ? Actual: 15:45, Delay: +1H 45M (105 mi | Current Itinerary - Flight: AC 364, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: 14:00 ? Actual: 15:45, Delay: +1H 45M (105 min) |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Booking Changes: NONE (flight operated, no cancellation, no rebooking) | Booking Changes: NONE (flight operated, no cancellation, no rebooking) |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 364 � YUL ? YYZ � 67 | MSL FLIGHT: AC 364 � YUL ? YYZ � 67 |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | ""Delayed due to crew transport / logistics delay"" | ""Delayed due to crew transport / logistics delay"" |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +1H 45M � CONTROLLABLE | Delay: +1H 45M � CONTROLLABLE |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | APPR Gate 8: Delay 1h 45m < 3h ? FAILS threshold ? NOT ELIGIBLE (all 3 passengers) | APPR Gate 8: Delay 1h 45m < 3h ? FAILS threshold ? NOT ELIGIBLE (all 3 passengers) |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE | Fallback: FALSE |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | MS V�RONIQUE GAGNON / NOT ELIGIBLE / BELOW_THRESHOLD / CAD 0.00 | MS V�RONIQUE GAGNON / NOT ELIGIBLE / BELOW_THRESHOLD / CAD 0.00 |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | MR MARC GAGNON / NOT ELIGIBLE / BELOW_THRESHOLD / CAD 0.00 | MR MARC GAGNON / NOT ELIGIBLE / BELOW_THRESHOLD / CAD 0.00 |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | MS SOPHIE GAGNON / NOT ELIGIBLE / BELOW_THRESHOLD / CAD 0.00 | MS SOPHIE GAGNON / NOT ELIGIBLE / BELOW_THRESHOLD / CAD 0.00 |
| CP076 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP077 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE for all 3 passengers ? CyberSource NOT invoked |  |
| CP078 | AC WALLET CHECK � NOT TRIGGERED | system | implied | Then the chatbot notes: AC Wallet offer is ONLY triggered for ELIGIBLE cases |  |
| CP079 | AC WALLET CHECK � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? AC Wallet NOT offered despite Basic Aeroplan linkage on V�ronique Gagnon (9876543210) |  |
| CP080 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight for all 3 passengers. I understand your departure from Montreal was delayed by 1 hour and 45 minutes due to crew transp |
| CP081 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: ""Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your e | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP082 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: ""Claim submission successful!"" | Claim submission successful! |
| CP083 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically for all 3 passengers |  |
| CP084 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP085 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to v***@gmail.com |  |
| CP086 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (AC 364 YUL?YYZ, delayed 1h 45m, Code 67 Crew Transport Delay), not eligible reason ( |  |
| CP087 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP088 | END FLOW (GLOB-11) | customer | chat | And the user selects ""No"" | No |
| CP089 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds ""Thank you for choosing Air Canada."" | Thank you for choosing Air Canada. |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant ""V�ronique Gagnon"" with PNR ""TC051"" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be ""Travel Disruptions � Delay"" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be ""Closed � Not Eligible"" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be ""V�ronique Gagnon"" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be ""Adult"" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be ""Pass"" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be ""TC051"" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be ""APPR"" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be ""V�ronique Gagnon"" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include ""Claimant"" and ""Adult"" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be ""v***@gmail.com"" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be ""+1***890"" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be ""9876543210"" linked and in good standing (Basic Member � V�ronique Gagnon) |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be ""Basic / Member"" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger section should list all 3 passengers: | � V�ronique Gagnon (Adult - Aeroplan Member 9876543210 � Claimant) � Marc Gagnon (Adult) � Sophie Gagnon (Adult) |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show ""Bound 1: YUL ? YYZ"" (AC 364 operated, delayed 1h 45m, Code 67) with claim filed for all 3 passengers |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Change History should show ""No booking changes � flight operated as AC 364"" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show ""NOT ELIGIBLE"" for all 3 passengers with reason ""Delay 1h 45m (10 |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically for all 3 passengers |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as ""NOT ELIGIBLE"" � delay 1h 45m (105 min) fails APPR Gate 8 threshold (minimum 3h /  |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data ""V�ronique Gagnon + TC051 + YUL?YYZ + FD"" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be ""No duplicate found"" for all 3 passengers |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And AC Wallet should NOT have been offered despite Basic Aeroplan linkage on V�ronique Gagnon as it only applies to eligible cases |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for all 3 identified and authenticated passengers |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from ""Assigned"" to ""In Progress"" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be ""Closed � Not Eligible"" |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP145 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is ""NOT ELIGIBLE"" for all 3 passengers due to delay below APPR 3h threshold (Code 67, 1h 45m) |  |
| CP146 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered for any passenger |  |
| CP147 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP148 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created for any of the 3 passengers |  |
| CP149 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP150 | PAYMENT VALIDATION | payment | chat | And AC Wallet should NOT have been offered despite Basic Aeroplan linkage on V�ronique Gagnon (9876543210) � AC Wallet only applies to eligi |  |
| CP151 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as ""NOT ELIGIBLE"" for all 3 passengers with no compensation record and no payout section |  |
| CP152 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-01 for all 3 passengers. | DDS returns FD-APPR-NE-01 for all 3 passengers. |
| CP153 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 14:00; Actual = 15:45; Delay = 1h 45m (105 min � below APPR 3h threshold); MSL = Leg 1 (AC 364); Code 67 (Crew Transp | Trip Tracer: Promise = 14:00; Actual = 15:45; Delay = 1h 45m (105 min � below APPR 3h threshold); MSL = Leg 1 (AC 364); Code 67 (Crew Transport / Hotel / Logist |
| CP154 | EXPECTED RESULTS | verdict | chat | No booking changes � flight operated as scheduled. | No booking changes � flight operated as scheduled. |
| CP155 | EXPECTED RESULTS | verdict | api | CRITICAL: Code 67 IS controllable and delay IS confirmed � however 1h 45m < 3h APPR minimum threshold ? $0 for all 3 passengers. | CRITICAL: Code 67 IS controllable and delay IS confirmed � however 1h 45m < 3h APPR minimum threshold ? $0 for all 3 passengers. |
| CP156 | EXPECTED RESULTS | verdict | chat | Aeroplan Basic (9876543210) on V�ronique Gagnon recognized but AC Wallet NOT offered (NE case). | Aeroplan Basic (9876543210) on V�ronique Gagnon recognized but AC Wallet NOT offered (NE case). |
| CP157 | EXPECTED RESULTS | verdict | chat | Compensation: $0 � 3 passengers � Below APPR threshold. | Compensation: $0 � 3 passengers � Below APPR threshold. |
| CP158 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP159 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP160 | EXPECTED RESULTS | verdict | api | DDS = FD-APPR-NE-01. | DDS = FD-APPR-NE-01. |
