# SOC_UAT_048 · CHAI-31963 — checkpoints

**Goal:** Verify 72-hour hold applied when last leg landed < 72h ago under EU regime.

Methods: seed 16, chat 49, api 3, email 1, dashboard 85, implied 22, manual 6, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify 72-hour hold applied when last leg landed < 72h ago under EU regime. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: EU | � Regime: EU |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 848 LHR?YYZ | � Itinerary: Single segment � AC 848 LHR?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 848 LHR?YYZ | � SOC Segment (per SoC Flight Identifier): AC 848 LHR?YYZ |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 848 LHR?YYZ, Dep: [today-1] 11:00 | � Promised Itinerary: AC 848 LHR?YYZ, Dep: [today-1] 11:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 848 LHR?YYZ, Dep: [today-1] 17:00 | � Actual Itinerary: AC 848 LHR?YYZ, Dep: [today-1] 17:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 360 min (6 hours) | � Departure Delay: 360 min (6 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: TBD � pending RE evaluation | � Departure delay code: TBD � pending RE evaluation |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: TBD � within 72-hour window | � Controllability: TBD � within 72-hour window |
| CP010 | PREREQUISITES | prerequisite | seed | � Note: Under EU, controllability won't matter for SOC even after 72h, but system still waits for complete data | � Note: Under EU, controllability won't matter for SOC even after 72h, but system still waits for complete data |
| CP011 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP012 | PREREQUISITES | prerequisite | seed | � Check Order: 72-hour check ? FAIL (< 72h) ? PENDING | � Check Order: 72-hour check ? FAIL (< 72h) ? PENDING |
| CP013 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult | � PAX Count: 1 adult |
| CP014 | PREREQUISITES | prerequisite | seed | � Class of Booking: PY | � Class of Booking: PY |
| CP015 | PREREQUISITES | prerequisite | seed | � Revenue Booking: YES | � Revenue Booking: YES |
| CP016 | PREREQUISITES | prerequisite | seed | � ACR Issued: N/A (pending) | � ACR Issued: N/A (pending) |
| CP017 | PREREQUISITES | prerequisite | seed | � Journey Completed: < 72h (last leg departed yesterday) | � Journey Completed: < 72h (last leg departed yesterday) |
| CP018 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP019 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP020 | START | customer | chat | Then user selects English |  |
| CP021 | START | alert | chat | Then an alert information is displayed ""Please note that by using this service, you will interact with an automated chatbot which uses AI t | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP022 | START | bot | chat | Then chatbot asks ""How can I help you today?"" | How can I help you today? |
| CP023 | START | customer | chat | And the user says ""I just landed yesterday from London. My Air Canada flight was delayed by about 6 hours. I had to buy food and pay for a  | I just landed yesterday from London. My Air Canada flight was delayed by about 6 hours. I had to buy food and pay for a hotel overnight. Can I get reimbursed fo |
| CP024 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP025 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP026 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides ""[First Name] [Last Name]"" | [First Name] [Last Name] |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides ""PNR: [PNR Code]"" | PNR: [PNR Code] |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: t***@gmail.com Phone: +1***789 |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects ""Email: t***@gmail.com"" | Email: t***@gmail.com |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code ""546879"" | 546879 |
| CP039 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP041 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP042 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP043 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 848 Route: London Heathrow (LHR) ? Toronto (YYZ) Date: [yesterday's date] Departure Delay: 6 hours Is this the journey |
| CP044 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms ""Yes"" | Yes |
| CP045 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination | 72-HOUR CHECK: ? FLOW STOPS HERE � PENDING |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey: | Last leg Departure: [yesterday's date] Current date: [today's date] Hours elapsed: ~24 hours 24 hours < 72 hours ? WITHIN 72-HOUR WINDOW ? PENDING ? |
| CP050 | ? FLOW DOES NOT PROCEED TO | system | implied | ? Claim Time Limit Check � SKIPPED | ? Geographic Origin Check � SKIPPED ? Triage Eligibility Check (SoC-02b) � SKIPPED ? Airline Company Routing � SKIPPED ? DDS Evaluation � SKIPPED ? Fraud Screen |
| CP051 | SHELL CASE CREATION | system | implied | Then the system creates a SHELL case in Case Services |  |
| CP052 | SHELL CASE CREATION | system | implied | And the shell case includes: | Case type: Shell (pending � awaiting 72-hour window closure) Passenger: [First Name] [Last Name] PNR: [PNR Code] Journey: AC 848 LHR?YYZ, [yesterday's date] Del |
| CP053 | SHELL CASE CREATION | system | implied | And the case is placed in the polling queue for 72-hour retrigger | DDS RESPONSE CODE = SoC-EU-PE-01 (PENDING) |
| CP054 | PENDING RESULT | bot | chat | Then the chatbot displays: ""Thank you for submitting your claim details. Your flight AC 848 from London Heathrow to Toronto arrived recentl | Thank you for submitting your claim details. Your flight AC 848 from London Heathrow to Toronto arrived recently, and we need a little more time to gather all t |
| CP055 | PENDING RESULT | bot | chat | Then the chatbot responds: | Here's what will happen next: We've created a reference for your claim: [Shell Case Reference] Our system will automatically evaluate your eligibility once all  |
| CP056 | DEEP LINK NOTIFICATION | system | implied | NOTE: The following happens AUTOMATICALLY after 72 hours � the passenger does not need to take any action. | After 72 hours (approximately [today + 2 days]): |
| CP057 | DEEP LINK NOTIFICATION | system | implied | Then the system's polling queue triggers a re-evaluation |  |
| CP058 | DEEP LINK NOTIFICATION | system | implied | And the Rules Engine (RE) retrieves complete flight data: | Actual departure time: confirmed Actual Departure time: confirmed Disruption code: populated Operating data: complete Geographic origin: LHR (UK) � confirmed |
| CP059 | DEEP LINK NOTIFICATION | email | email | Then the DDS evaluates eligibility with complete data: | Regime: EU (LHR = UK origin confirmed) Geographic check: PASSED ? Controllability: NOT CHECKED (EU regime � irrelevant for SOC) Delay: confirmed Passenger type: |
| CP060 | WELCOME BACK FLOW | system | implied | Then the passenger receives an email from Air Canada: | ""Good news! We've reviewed the details of your flight AC 848 from London Heathrow to Toronto, and you are eligible for expense reimbursement under EU regulatio |
| CP061 | WELCOME BACK FLOW | system | implied | And the email includes: | Deep link to chatbot with pre-populated claim data Case reference number Expiry date for completing the claim |
| CP062 | WELCOME BACK FLOW | system | implied | Then the passenger clicks the deep link |  |
| CP063 | WELCOME BACK FLOW | system | implied | And the chatbot opens with pre-populated data: | ""Welcome back, [First Name]! We've determined that you are eligible for expense reimbursement for your flight AC 848 from London Heathrow to Toronto on [yester |
| CP064 | WELCOME BACK FLOW | system | implied | Then the chatbot proceeds to: | Receipt upload flow OCR validation Expense breakdown Case creation Payment flow (Same as EU EL-01 detailed steps from receipt upload onwards) |
| CP065 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: ""Is there anything else I can help you with?"" | Is there anything else I can help you with? |
| CP066 | END FLOW (GLOB-11) | customer | chat | And the user selects ""No"" | No |
| CP067 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds ""Thank you for choosing Air Canada."" | Thank you for choosing Air Canada. |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-EU-PE-01 Phase 1 � 72-Hour Hold Pending |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "System Processing ??" |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date is populated as July 8, 2026 |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date is populated as July 8, 2026 |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the SLA is 72-hour processing window |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is "N/A (system processing � not assigned to agent)" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (identified + authenticated, Auth Flow 1) |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is pending (DDS not yet run) |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date is populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID is populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source is populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID is populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "EU (preliminary � LHR origin, subject to confirmation)" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address is populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is "Regular" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 848 LHR ? YYZ as the claimed flight |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (6 hours � preliminary)" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section is present with no entries |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 848 LHR ? YYZ |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 848 |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "TBD � pending 72-hour data completion" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is approximately 360 min (preliminary � subject to confirmation) |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed Departure)" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "PRELIMINARY ? (LHR = UK origin � subject to confirmation after data completion)" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT APPLICABLE (EU regime � will not be checked even after 72h)" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "TBD" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-EU-PE-01 (PENDING)" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Polling Status is "ACTIVE � system will re-evaluate after 72h" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "NOT YET PERFORMED (CyberSource runs only after DDS determines eligibility)" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "PENDING" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the last leg Departure is July 7, 2026 |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the filing date is July 8, 2026 |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the hours elapsed is approximately 24 hours |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And 24 hours is less than 72 hours so the case is WITHIN 72-HOUR WINDOW and PENDING |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the scheduled DDS Run is approximately July 10, 2026 |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the flow is STOPPED at 72-hour check with the following ALL SKIPPED: Claim Time Limit Check, Geographic Origin Check (full), Triage Elig |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (pending eligibility determination)" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "N/A (pending)" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check ran automatically and result is "No duplicate found" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered (pending � CyberSource only runs after DDS evaluation) |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Auto-Append shows the system appended the booking record automatically |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Current Status is "System Processing (Pending � 72-hour hold)" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is NOT in read-only mode (will be updated after DDS runs post-72h) | Scenario: Claims Dashboard validation for SoC-EU-PE-01 Phase 2 � After 72-Hour Window |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the 72-hour window has elapsed for case SoC-EU-PE-01 |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard updates automatically based on DDS result |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if DDS returns ELIGIBLE then the Status changes to "In Progress (Welcome Back flow sent, awaiting receipts)" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is updated from PE-01 to actual result (e.g., EL-01, EL-07) |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is populated with actual Departure delay code |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is confirmed (no longer preliminary) |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is confirmed PASSED ? (LHR = UK) |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT CHECKED (EU regime � confirmed irrelevant)" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Polling Status is "COMPLETED" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening CyberSource runs and returns GREEN, YELLOW, or RED |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if GREEN then Welcome Back email is sent and receipt upload and payment proceed |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if YELLOW then case is parked in fraud queue pending fraud team review |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if RED then auto-rejected and passenger can dispute |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a deep link email is sent to passenger |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And entitlements are calculated based on confirmed delay category |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case awaits receipt upload via Welcome Back flow |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if DDS returns NOT ELIGIBLE then the Status changes to "Resolved (rejection email sent, case auto-closed)" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is updated from PE-01 to actual NE code (e.g., NE-04, NE-09) |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the rejection reason is populated |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Polling Status is "COMPLETED" |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a rejection email is sent to passenger |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no receipt upload is triggered |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no compensation record is created |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no payment flow is triggered |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if DDS returns NO DETERMINATION then the Status changes to "Assigned (moved to manual agent queue)" |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is updated from PE-01 to actual ND code (e.g., ND-03, ND-04) |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case is assigned to agent for manual investigation |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Polling Status is "COMPLETED � manual review required" |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent investigates and manually determines outcome |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if no DDS answer after 14 days then the Status changes to "Assigned (moved to manual agent queue)" |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Polling Status is "TIMED OUT � 14-day retrigger exhausted" |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case is sent to agent queue for manual handling |  |
| CP156 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-EU-PE-01 � During Pending Phase |  |
| CP157 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-PE-01 is PENDING |  |
| CP158 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered at this stage |  |
| CP159 | PAYMENT VALIDATION | payment | chat | And a shell case is created in System Processing Queue |  |
| CP160 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP161 | PAYMENT VALIDATION | payment | chat | And no receipts are uploaded |  |
| CP162 | PAYMENT VALIDATION | payment | chat | And no CyberSource fraud check is triggered |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP164 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP165 | PAYMENT VALIDATION | payment | chat | And no GL account or cost center is assigned | Scenario: Payment validation for SoC-EU-PE-01 � After 72h If Not Eligible |
| CP166 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-PE-01 DDS returns NOT ELIGIBLE after 72h |  |
| CP167 | PAYMENT VALIDATION | payment | chat | Then rejection email is sent to passenger |  |
| CP168 | PAYMENT VALIDATION | payment | chat | And the case is auto-closed |  |
| CP169 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP170 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP171 | PAYMENT VALIDATION | payment | chat | And no payment is triggered |  |
| CP172 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows NOT ELIGIBLE with no payout section | Scenario: Payment validation for SoC-EU-PE-01 � No DDS Answer After 14 Days |
| CP173 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-PE-01 receives no DDS answer after 14 days |  |
| CP174 | PAYMENT VALIDATION | payment | chat | Then the case is sent to agent queue for manual handling |  |
| CP175 | PAYMENT VALIDATION | payment | chat | And the agent investigates and manually determines outcome |  |
| CP176 | PAYMENT VALIDATION | payment | manual | And if the agent determines eligible then manual compensation creation proceeds with SOC as cash only and GL accounts and Unifier |  |
| CP177 | EXPECTED RESULTS | verdict | chat | SoC-EU-PE-01. | SoC-EU-PE-01. |
| CP178 | EXPECTED RESULTS | verdict | chat | PENDING. | PENDING. |
| CP179 | EXPECTED RESULTS | verdict | chat | Last leg <72h ago. | Last leg <72h ago. |
| CP180 | EXPECTED RESULTS | verdict | chat | Shell case created. | Shell case created. |
| CP181 | EXPECTED RESULTS | verdict | chat | Placed in polling queue. | Placed in polling queue. |
| CP182 | EXPECTED RESULTS | verdict | api | After 72h: RE retrigger ? DDS evaluation (no controllability check under EU) ? deep link sent if eligible. | After 72h: RE retrigger ? DDS evaluation (no controllability check under EU) ? deep link sent if eligible. |
| CP183 | EXPECTED RESULTS | verdict | chat | No receipt upload at this stage. | No receipt upload at this stage. |
