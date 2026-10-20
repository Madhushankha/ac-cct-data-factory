# FD_TC_052 · CHAI-31444 — checkpoints

**Goal:** Customer files a claim for a flight that occurred MORE than 1 year (366 days) ago. Under APPR, the limitation period for filing compensation claims is 1 year from the date of the disrupted travel. This claim was filed 420 days after travel � 54 days past the deadline. The disruption was Code 64 (Flight Crew Shortage � Controllable) with a 7-hour arrival delay (6�<9h band, normally $700 CAD Tier 2). Passenger holds a Basic Aeroplan profile linked to the booking. Validates: (1) DDS correctly calculates the number of days between the travel date and the filing date, (2) The 366-day (1-year) limitation is strictly enforced with no grace period, (3) Even though the disruption was controllable Code 64 with a 7h delay (normally $700 CAD Tier 2), the limitation override blocks eligibility entirely, (4) The time limit check occurs as a PRE-DDS gate � limitation exceeded means result is always NE regardless of code or delay band, (5) Basic Aeroplan profile is recognized but AC Wallet is NOT offered as the case is not eligible, (6) Tests that the system correctly handles stale claims from customers who discover their rights long after travel.

Methods: seed 15, chat 45, api 11, email 3, dashboard 44, implied 18, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer files a claim for a flight that occurred MORE than 1 year (366 days) ago. Under APPR, the limitation period for filing compensation |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC039 � single passenger Luc Bergeron (Adult - Basic Aeroplan Member) | PNR: TC039 � single passenger Luc Bergeron (Adult - Basic Aeroplan Member) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 331, YUL?YYZ (domestic) | Journey: 1 leg AC operated, Flight AC 331, YUL?YYZ (domestic) |
| CP004 | PREREQUISITES | prerequisite | seed | Travel date: May 1, 2025 (over 13 months ago) | Travel date: May 1, 2025 (over 13 months ago) |
| CP005 | PREREQUISITES | prerequisite | seed | Filing date: June 15, 2026 | Filing date: June 15, 2026 |
| CP006 | PREREQUISITES | prerequisite | seed | Days since travel: May 1, 2025 ? June 15, 2026 = 420 days (exceeds 366-day limit by 54 days) | Days since travel: May 1, 2025 ? June 15, 2026 = 420 days (exceeds 366-day limit by 54 days) |
| CP007 | PREREQUISITES | prerequisite | seed | APPR limitation: 366 days (1 year) | APPR limitation: 366 days (1 year) |
| CP008 | PREREQUISITES | prerequisite | seed | Disruption: 7h delay (6�<9h band) | Disruption: 7h delay (6�<9h band) |
| CP009 | PREREQUISITES | prerequisite | seed | Arrival delay code: 64 (Flight Crew Shortage � Controllable) | Arrival delay code: 64 (Flight Crew Shortage � Controllable) |
| CP010 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 14:00 | Scheduled arrival: 14:00 |
| CP011 | PREREQUISITES | prerequisite | seed | Actual arrival: 21:00 (+7h) | Actual arrival: 21:00 (+7h) |
| CP012 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic) | Regime: APPR (domestic) |
| CP013 | PREREQUISITES | prerequisite | seed | Timing: >72hrs elapsed (obviously, 420 days) | Timing: >72hrs elapsed (obviously, 420 days) |
| CP014 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked (9876543210), Basic Member in good standing | Aeroplan: Linked (9876543210), Basic Member in good standing |
| CP015 | PREREQUISITES | prerequisite | seed | Key point: Despite controllable Code 64 with 7h delay (normally $700 CAD Tier 2), claim is time-barred | Key point: Despite controllable Code 64 with 7h delay (normally $700 CAD Tier 2), claim is time-barred |
| CP016 | PREREQUISITES | prerequisite | seed | AC Wallet NOT offered (NE case) | AC Wallet NOT offered (NE case) |
| CP017 | PREREQUISITES | prerequisite | implied | CyberSource: NOT invoked | CyberSource: NOT invoked |
| CP018 | PREREQUISITES | prerequisite | implied | RDS: No flags | RDS: No flags |
| CP019 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP020 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP021 | START | customer | chat | Then user selects English |  |
| CP022 | START | alert | chat | Then an alert information is displayed ""Please note that by using this service, you will interact with an automated chatbot which uses AI t | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP023 | START | bot | chat | Then chatbot asks ""How can I help you today?"" | How can I help you today? |
| CP024 | START | customer | chat | And the user says ""My flight from Montreal to Toronto last year was delayed about 7 hours due to crew issues. I'd like to check if I'm stil | My flight from Montreal to Toronto last year was delayed about 7 hours due to crew issues. I'd like to check if I'm still eligible for compensation |
| CP025 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP026 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP027 | START | bot | chat | Then the chatbot responds: ""No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP028 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: ""Please note that the assessment and decision regarding your request will be made through an automated decision- | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides ""Luc Bergeron"" | Luc Bergeron |
| CP032 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Luc! And, what is your booking reference number? |
| CP033 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides ""PNR: TC039"" | PNR: TC039 |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC039 |  |
| CP035 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP036 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: l***@gmail.com � Phone: +1***890 |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects ""Email: l***@gmail.com"" | Email: l***@gmail.com |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP041 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code ""482917"" | 482917 |
| CP042 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP043 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP044 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP045 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP046 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP047 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP048 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Luc Bergeron (Adult - Aeroplan Member) Is this who you'd like to include? |
| CP049 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms ""Yes"" | Yes |
| CP050 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP051 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 459 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: May 1, 2025 � Arrival Delay: 7 hours Is this the journey you'd l |
| CP052 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms ""Yes"" | Yes |
| CP053 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP054 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP055 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP056 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP057 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 1, 2025; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP058 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP059 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 1, 2025; filing June 15, 2026 ? 420 days ? EXCEEDS 366 days by 54 days ? OUTSIDE LIMITATION |  |
| CP060 | CLAIM TIME LIMIT CHECK | system | implied | Then the system determines: CLAIM TIME-BARRED ? NOT ELIGIBLE (limitation override) |  |
| CP061 | CRITICAL NOTE � LIMITATION AS ABSOLUTE OVERRIDE | system | implied | ? Code 64 (Flight Crew Shortage) IS confirmed as Controllable | ? 7h delay IS within 6�<9h band (would normally yield $700 CAD Tier 2 / $840 AC Wallet) ? Basic Aeroplan IS linked (9876543210) � AC Wallet top-up would normall |
| CP062 | NOT ELIGIBLE RESULT | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your flight AC 459 from Montreal (YUL) to Toronto (YYZ) on May 1, 2025 was delayed by 7 hours due to a fl |
| CP063 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: ""Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your e | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP064 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: ""Claim submission successful!"" | Claim submission successful! |
| CP065 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP066 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP067 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to l***@gmail.com |  |
| CP068 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (AC 459 YUL?YYZ, May 1, 2025, 7h delay � Code 64 Crew Shortage), not eligible reason  |  |
| CP069 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP070 | END FLOW (GLOB-11) | customer | chat | And the user selects ""No"" | No |
| CP071 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds ""Thank you for choosing Air Canada."" | Thank you for choosing Air Canada. |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant ""Luc Bergeron"" with PNR ""TC039"" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be ""Travel Disruptions � Delay"" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be ""Closed � Not Eligible"" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be ""Luc Bergeron"" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be ""Adult"" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be ""Pass"" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be ""TC039"" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be ""APPR"" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be ""Luc Bergeron"" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include ""Claimant"" and ""Adult"" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be ""l***@gmail.com"" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be ""+1***890"" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be ""9876543210"" linked and in good standing (Basic Member) |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be ""Basic / Member"" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show ""Bound 1: YUL ? YYZ"" with claim filed for this flight |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show ""NOT ELIGIBLE"" with reason ""Outside 366-day APPR limitation (420  |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should NOT have run a full assessment as the limitation was exceeded before DDS evaluation |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should show ""NOT ELIGIBLE"" as time-barred |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data ""Luc Bergeron + TC039 + YUL?YYZ + FD"" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be ""No duplicate found"" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And AC Wallet should NOT have been offered despite Basic Aeroplan linkage (9876543210) as it only applies to eligible cases |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from ""Assigned"" to ""In Progress"" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be ""Closed � Not Eligible"" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP125 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is ""NOT ELIGIBLE"" due to outside 366-day APPR limitation (420 days elapsed) |  |
| CP126 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP128 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP129 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And AC Wallet should NOT have been offered despite Basic Aeroplan linkage (9876543210) � AC Wallet only applies to eligible cases |  |
| CP131 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as ""NOT ELIGIBLE (Outside Limitation)"" with no compensation record and no payout section |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And the audit log should record Code 64 (Flight Crew Shortage � Controllable) and 7h delay (6�<9h band, Tier 2) for logging purposes only �  |  |
| CP133 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-07. | DDS returns FD-APPR-NE-07. |
| CP134 | EXPECTED RESULTS | verdict | api | Trip Tracer: Travel date = May 1, 2025; Filing date = June 15, 2026; Days elapsed = 420 days; APPR limitation = 366 days; LIMITATION EXCEEDE | Trip Tracer: Travel date = May 1, 2025; Filing date = June 15, 2026; Days elapsed = 420 days; APPR limitation = 366 days; LIMITATION EXCEEDED by 54 days. |
| CP135 | EXPECTED RESULTS | verdict | api | Arrival delay code = 64 (Flight Crew Shortage � Controllable); Delay = 7h (6�<9h band); Scheduled arrival = 14:00; Actual arrival = 21:00. | Arrival delay code = 64 (Flight Crew Shortage � Controllable); Delay = 7h (6�<9h band); Scheduled arrival = 14:00; Actual arrival = 21:00. |
| CP136 | EXPECTED RESULTS | verdict | chat | Time Limit Check: 420 days > 366 days ? OUTSIDE LIMITATION ? NOT ELIGIBLE. | Time Limit Check: 420 days > 366 days ? OUTSIDE LIMITATION ? NOT ELIGIBLE. |
| CP137 | EXPECTED RESULTS | verdict | api | CRITICAL: The limitation check is an absolute override � even though the disruption was controllable Code 64 with 7h delay (normally $700 CA | CRITICAL: The limitation check is an absolute override � even though the disruption was controllable Code 64 with 7h delay (normally $700 CAD Tier 2 / $840 AC W |
| CP138 | EXPECTED RESULTS | verdict | chat | AC Wallet NOT offered (NE). | AC Wallet NOT offered (NE). |
| CP139 | EXPECTED RESULTS | verdict | chat | No grace period, no exceptions, no rounding. | No grace period, no exceptions, no rounding. |
| CP140 | EXPECTED RESULTS | verdict | api | DDS may log the delay/controllability data (Code 64, 7h, Tier 2) for audit but the result is definitively NE. | DDS may log the delay/controllability data (Code 64, 7h, Tier 2) for audit but the result is definitively NE. |
| CP141 | EXPECTED RESULTS | verdict | chat | Compensation: $0 � limitation expired. | Compensation: $0 � limitation expired. |
| CP142 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP143 | EXPECTED RESULTS | verdict | chat | IDV: NOT REQUIRED. | IDV: NOT REQUIRED. |
| CP144 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP145 | EXPECTED RESULTS | verdict | chat | Aeroplan: Basic Member (9876543210) recognized � AC Wallet NOT offered. | Aeroplan: Basic Member (9876543210) recognized � AC Wallet NOT offered. |
| CP146 | EXPECTED RESULTS | verdict | api | Regime Assessment: APPR = NE-07 (Outside 1-year limitation, 420 days); EU = N/A; ASL = N/A. | Regime Assessment: APPR = NE-07 (Outside 1-year limitation, 420 days); EU = N/A; ASL = N/A. |
| CP147 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Case = CASE-FD-20260615-039; Status = Closed � Not Eligible; Reason = Outside 1-year limitation (420 days, exceeded by 54  | Claims Dashboard: Case = CASE-FD-20260615-039; Status = Closed � Not Eligible; Reason = Outside 1-year limitation (420 days, exceeded by 54 days); Travel date = |
