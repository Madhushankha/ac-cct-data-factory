# FD_TC_146 · CHAI-31538 — checkpoints

**Goal:** EU Mainland flight (CDG?YYZ) delayed 4 hours due to severe weather (arrival delay code 72 � Uncontrollable/Extraordinary). Despite a 4hr delay that exceeds the 3hr threshold and would normally qualify for �600 compensation if controllable, the extraordinary circumstances classification blocks eligibility under Article 5(3).

Methods: seed 8, chat 43, api 11, email 3, dashboard 47, implied 16, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | EU Mainland flight (CDG?YYZ) delayed 4 hours due to severe weather (arrival delay code 72 � Uncontrollable/Extraordinary). Despite a 4hr del |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Julien Marchand (Adult) | PNR: single passenger Julien Marchand (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 871, CDG?YYZ | Journey: 1 leg AC operated, Flight AC 871, CDG?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 16:00 | Scheduled arrival: 16:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival: 20:00 (4hr delay) | Actual arrival: 20:00 (4hr delay) |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival delay code: 72 (Weather � Severe Thunderstorm � Uncontrollable/Extraordinary) | Arrival delay code: 72 (Weather � Severe Thunderstorm � Uncontrollable/Extraordinary) |
| CP007 | PREREQUISITES | prerequisite | seed | Fallback: FALSE (arrival code available) | Fallback: FALSE (arrival code available) |
| CP008 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (EU Mainland � CDG origin) | Regime: EU 261 (EU Mainland � CDG origin) |
| CP009 | PREREQUISITES | prerequisite | seed | Result: NOT ELIGIBLE (extraordinary circumstances � Article 5(3) exemption) | Result: NOT ELIGIBLE (extraordinary circumstances � Article 5(3) exemption) |
| CP010 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP011 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP012 | START | customer | chat | Then user selects English |  |
| CP013 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP014 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP015 | START | customer | chat | And the user says "My flight from Paris to Toronto was delayed about 4 hours due to severe weather. Can I get compensation?" | My flight from Paris to Toronto was delayed about 4 hours due to severe weather. Can I get compensation? |
| CP016 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP017 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP018 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP019 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP022 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Julien Marchand" | Julien Marchand |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Julien! And, what is your booking reference number? |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC112" | PNR: TC112 |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC112 |  |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: j***@gmail.com Phone: +33***234 |
| CP030 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: j***@gmail.com" | Email: j***@gmail.com |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP033 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP035 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP036 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP037 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP038 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP039 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Julien Marchand (Adult) Is this who you'd like to include? |
| CP040 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP041 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP042 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 871 Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ) Date: June 8, 2026 Arrival Delay: 4 hours Is this the journey |
| CP043 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP047 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP048 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was June 8, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED |  |
| CP049 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction � CDG origin) = 5 years ? within limitation ? PROCEED |  |
| CP050 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = CDG (Paris, EU Mainland) ? EU 261 (EU Mainland) |  |
| CP051 | REGIME DETERMINATION | system | implied | And the system checks: Distance CDG?YYZ = ~5,900 km ? Long-haul (>3500km) |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC112 | Delayed due to severe weather (thunderstorm) |
| CP055 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP056 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your flight AC 871 from Paris Charles de Gaulle (CDG) to Toronto (YYZ) on June 8, 2026 was delayed by 4 h |
| CP057 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP058 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP059 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP060 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP061 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to j***@gmail.com |  |
| CP062 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (AC 871 CDG?YYZ, delayed 4h), not eligible reason (extraordinary circumstances � seve |  |
| CP063 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP064 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP065 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Julien Marchand" with PNR "TC112" |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Julien Marchand" |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC112" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (EU Mainland)" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Julien Marchand" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "j***@gmail.com" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+33***234" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: CDG ? YYZ" with claim filed for this flight as arrived late plus 4h |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Extraordinary circumstances � severe wea |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the delay should be 4hrs which would be eligible if controllable as long-haul greater than 3500km CDG to YYZ approximately 5900km equals |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to extraordinary circumstances with arrival delay code 72 and wea |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fallback flag should be FALSE as arrival code is available Code 72 |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Sister City flag should be FALSE |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Julien Marchand + TC112 + CDG?YYZ + FD" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe to "j***@gmail.com" containing Case Reference and flight details AC 87 |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP122 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to extraordinary circumstances severe weather |  |
| CP123 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP124 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP125 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP126 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP128 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-NE-23. | DDS returns FD-EU-NE-23. |
| CP129 | EXPECTED RESULTS | verdict | api | Trip Tracer: Flight operated; Promise = 16:00; Actual = 20:00; Arrival delay = 4hrs; Arrival Delay Code 72 ; CDG?YYZ = ~5,900km (long-haul > | Trip Tracer: Flight operated; Promise = 16:00; Actual = 20:00; Arrival delay = 4hrs; Arrival Delay Code 72 ; CDG?YYZ = ~5,900km (long-haul >3500km); Fallback =  |
| CP130 | EXPECTED RESULTS | verdict | chat | CRITICAL: 4hr delay meets 3hr threshold . | CRITICAL: 4hr delay meets 3hr threshold . |
| CP131 | EXPECTED RESULTS | verdict | chat | But arrival delay code 72 = Extraordinary ? airline exempt under Article 5(3). | But arrival delay code 72 = Extraordinary ? airline exempt under Article 5(3). |
| CP132 | EXPECTED RESULTS | verdict | chat | Weather is outside airline control regardless of delay duration. | Weather is outside airline control regardless of delay duration. |
| CP133 | EXPECTED RESULTS | verdict | api | Dual regime assessment: EU 261 = NE-23 (Extraordinary, Weather, Delay at Arrival); APPR = NE (Uncontrollable, Weather). | Dual regime assessment: EU 261 = NE-23 (Extraordinary, Weather, Delay at Arrival); APPR = NE (Uncontrollable, Weather). |
| CP134 | EXPECTED RESULTS | verdict | chat | Both regimes = Not Eligible. | Both regimes = Not Eligible. |
| CP135 | EXPECTED RESULTS | verdict | chat | Result: NOT ELIGIBLE, �0. | Result: NOT ELIGIBLE, �0. |
| CP136 | EXPECTED RESULTS | verdict | chat | CyberSource: NOT triggered. | CyberSource: NOT triggered. |
| CP137 | EXPECTED RESULTS | verdict | chat | IDV: NOT required. | IDV: NOT required. |
| CP138 | EXPECTED RESULTS | verdict | chat | Payment: NONE. | Payment: NONE. |
| CP139 | EXPECTED RESULTS | verdict | api | Claims Dashboard: EU Mainland NE-23; NOT ELIGIBLE; Travel Completed; Arrival Delay Code 72 (Weather, Extraordinary); Delay = 4hrs (would be  | Claims Dashboard: EU Mainland NE-23; NOT ELIGIBLE; Travel Completed; Arrival Delay Code 72 (Weather, Extraordinary); Delay = 4hrs (would be �600 if controllable |
