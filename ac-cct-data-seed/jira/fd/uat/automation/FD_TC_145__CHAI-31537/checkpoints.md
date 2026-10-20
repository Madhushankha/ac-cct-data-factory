# FD_TC_145 · CHAI-31537 — checkpoints

**Goal:** EU Mainland multi-leg (CDG?YYZ?YVR). BOTH the MSL delay (2hrs on Leg 1) AND the final arrival delay (1.5hrs at YVR) are below the 3-hour threshold. This is the simplest "below threshold" NE scenario � no ambiguity, no recovered delay, just insufficient delay everywhere.

Methods: seed 9, chat 30, api 8, email 3, dashboard 259, implied 16, manual 39, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | EU Mainland multi-leg (CDG?YYZ?YVR). BOTH the MSL delay (2hrs on Leg 1) AND the final arrival delay (1.5hrs at YVR) are below the 3-hour thr |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Jos�phine Lambert (Adult) | PNR: single passenger Jos�phine Lambert (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 2 legs: Leg 1 AC 871 CDG?YYZ (delayed 2hrs, arrival delay code 42 � Controllable); Leg 2 AC 121 YYZ?YVR (on time) | Journey: 2 legs: Leg 1 AC 871 CDG?YYZ (delayed 2hrs, arrival delay code 42 � Controllable); Leg 2 AC 121 YYZ?YVR (on time) |
| CP004 | PREREQUISITES | prerequisite | seed | Promise: Final arrival YVR = 20:00 | Promise: Final arrival YVR = 20:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual: Final arrival YVR = 21:30 (1.5hr delay) | Actual: Final arrival YVR = 21:30 (1.5hr delay) |
| CP006 | PREREQUISITES | prerequisite | seed | MSL: Leg 1 (2hr delay) | MSL: Leg 1 (2hr delay) |
| CP007 | PREREQUISITES | prerequisite | seed | Final destination delay: 1.5hrs | Final destination delay: 1.5hrs |
| CP008 | PREREQUISITES | prerequisite | seed | Both below 3hr threshold | Both below 3hr threshold |
| CP009 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (EU Mainland � CDG origin) | Regime: EU 261 (EU Mainland � CDG origin) |
| CP010 | PREREQUISITES | prerequisite | seed | Result: NOT ELIGIBLE (both MSL and arrival delay below 3hr threshold) | Result: NOT ELIGIBLE (both MSL and arrival delay below 3hr threshold) |
| CP011 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP012 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP013 | START | customer | chat | Then user selects English |  |
| CP014 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP015 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP016 | START | customer | chat | And the user says "My flight from Paris to Toronto was delayed about 2 hours and I arrived in Vancouver about an hour and a half late. Can I | My flight from Paris to Toronto was delayed about 2 hours and I arrived in Vancouver about an hour and a half late. Can I get compensation under EU regulations? |
| CP017 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP018 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP019 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP020 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Jos�phine Lambert" | Jos�phine Lambert |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Jos�phine! And, what is your booking reference number? |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC111" | PNR: TC111 |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC111 |  |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: j***@outlook.com Phone: +33***678 |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: j***@outlook.com" | Email: j***@outlook.com |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP034 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP036 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP037 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP039 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Jos�phine Lambert (Adult) Is this who you'd like to include? |
| CP041 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP043 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Segment 1: Flight AC 871, Paris Charles de Gaulle (CDG) ? Toronto (YYZ), June 6, 2026 � ARRIVED LATE (+2h) Segment 2: Flight AC 1 |
| CP044 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP046 | SEGMENT CHECK (GenUC-18) | verdict | api | Then the chatbot identifies: Segment 1 ARRIVED LATE (MSL), Segment 2 ARRIVED ON TIME |  |
| CP047 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot determines: Final destination = YVR; Final arrival delay = 1.5h |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP051 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was June 6, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED |  |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction � CDG origin) = 5 years ? within limitation ? PROCEED |  |
| CP053 | REGIME DETERMINATION | system | implied | Then the system determines: Journey origin = CDG (Paris, EU Mainland) ? EU 261 (EU Mainland) |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC111 | ? Segment 1: Flight: AC 871, Route: CDG ? YYZ, Scheduled Arrival: 13:00, Actual: 15:00, Delay: +2H 00M (MSL) ? Arrival Delay Code on Leg 1: 42 � numeric delay c |
| CP057 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP058 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your arrival in Vancouver was on time. That means there's no recorded delay for this part of your trip. Base |
| CP059 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP060 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP061 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP062 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP063 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to j***@outlook.com |  |
| CP064 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (Seg 1: CDG?YYZ +2h MSL; Seg 2: YYZ?YVR; Final arrival YVR +1h30m), not eligible reas |  |
| CP065 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP066 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP067 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Feature: Claims Dashboard Validation � TC111 Jos�phine Lambert (EU 261 EU Mainland Both Delays Below Threshold � Not Eligible) | Scenario: Validate Claims Dashboard for TC111 Jos�phine Lambert (EU 261 EU Mainland Both Delays Below Threshold � Not Eligible) |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Jos�phine Lambert" with PNR "TC111" |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Jos�phine Lambert" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC111" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (EU Mainland)" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Jos�phine Lambert" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "j***@outlook.com" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+33***678" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: CDG ? YYZ" arrived late plus 2h as MSL and "Segment 2: YYZ ? YVR" arrived on time |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Both MSL delay 2h AND final arrival dela |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to arrival delay 1.5h being less than 3h and MSL delay 2h also be |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Jos�phine Lambert + TC111 + CDG?YVR + FD" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe to "j***@outlook.com" containing arrival delay and MSL delay both belo |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Feature: Payment Validation � TC111 Jos�phine Lambert (EU 261 Both Delays Below Threshold � No Payment) Scenario: Validate Payment for TC111 Jos�phine Lambert ( |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the eligibility result is "NOT ELIGIBLE" due to both MSL and final arrival delays below 3-hour threshold |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then no payment flow should be triggered |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no country of residence should have been asked |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no compensation record should have been created |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no batch file should have been dispatched |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section | Feature: Claims Dashboard Validation � TC112 Julien Marchand (EU 261 EU Mainland Extraordinary Weather Delay � Not Eligible) Scenario: Validate Claims Dashboard |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Julien Marchand" with PNR "TC112" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Julien Marchand" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC112" |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (EU Mainland)" |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Julien Marchand" |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "j***@gmail.com" |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+33***234" |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: CDG ? YYZ" with claim filed for this flight as arrived late plus 4h |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Extraordinary circumstances � severe wea |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the delay should be 4hrs which would be eligible if controllable as long-haul greater than 3500km CDG to YYZ approximately 5900km equals |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to extraordinary circumstances with arrival delay code 72 and wea |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fallback flag should be FALSE as arrival code is available Code 72 |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Sister City flag should be FALSE |  |
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Julien Marchand + TC112 + CDG?YYZ + FD" |  |
| CP166 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP167 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP168 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP169 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP170 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP171 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP172 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP173 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP174 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP175 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe to "j***@gmail.com" containing Case Reference and flight details AC 87 |  |
| CP176 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP177 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP178 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP179 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP180 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP181 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP182 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP183 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Feature: Payment Validation � TC112 Julien Marchand (EU 261 Extraordinary Weather Delay � No Payment) Scenario: Validate Payment for TC112 Julien Marchand (EU 2 |
| CP184 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the eligibility result is "NOT ELIGIBLE" due to extraordinary circumstances severe weather |  |
| CP185 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then no payment flow should be triggered |  |
| CP186 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no country of residence should have been asked |  |
| CP187 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no compensation record should have been created |  |
| CP188 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no batch file should have been dispatched |  |
| CP189 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section | Feature: Claims Dashboard Validation � TC113 Brigitte Pelletier (EU 261 New Destination � No Determination) Scenario: Validate Claims Dashboard for TC113 Brigit |
| CP190 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Brigitte Pelletier" with PNR "TC113" |  |
| CP191 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP192 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP193 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Pending Agent Review" |  |
| CP194 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP195 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP196 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP197 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "Manual Review Team" |  |
| CP198 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP199 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should be greyed out or not applicable as it cannot assess new destination |  |
| CP200 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Brigitte Pelletier" |  |
| CP201 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP202 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP203 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC113" |  |
| CP204 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP205 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP206 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP207 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP208 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (EU origin � CDG)" |  |
| CP209 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Brigitte Pelletier" |  |
| CP210 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP211 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "b***@outlook.com" |  |
| CP212 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+33***012" |  |
| CP213 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the original journey should show "CDG ? YYZ" as cancelled |  |
| CP214 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the rebooked journey should show "CDG ? YOW" as completed with new destination |  |
| CP215 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Sister City Check should show YOW and YYZ as NOT A VALID PAIR |  |
| CP216 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP217 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP218 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "New destination / new contract � DDS |  |
| CP219 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should show DDS ran automatically but returned CANNOT ASSESS due to new destination |  |
| CP220 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the determination should be "NO DETERMINATION" sent to agent |  |
| CP221 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Brigitte Pelletier + TC113 + CDG?YYZ + FD" |  |
| CP222 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP223 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it is No Determination |  |
| CP224 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP225 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should be routed to manual review team queue |  |
| CP226 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should pull the case for manual review |  |
| CP227 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a No Determination notification email should have been sent to "b***@outlook.com" containing Case Reference and original CDG to YYZ canc |  |
| CP228 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Current Status should be "Pending Agent Review" |  |
| CP229 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should NOT be in read-only mode as the agent can determine outcome |  |
| CP230 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Feature: Payment Validation � TC113 Brigitte Pelletier (EU 261 New Destination � No Automated Payment) Scenario: Validate Payment for TC113 Brigitte Pelletier ( |
| CP231 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given no determination was made due to new destination |  |
| CP232 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then no automated payment flow should be triggered |  |
| CP233 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case was created and sent to agent for manual handling |  |
| CP234 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no country of residence should have been asked |  |
| CP235 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no compensation record should have been created automatically |  |
| CP236 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no batch file should have been dispatched |  |
| CP237 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e- |  |
| CP238 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved | Feature: Claims Dashboard Validation � TC145 Critical MSL Data Missing EU (No Determination � 14-Day Exhausted) Scenario: Validate Claims Dashboard for TC145 Cr |
| CP239 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for PNR "TC145" under EU 261 EU origin CDG |  |
| CP240 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP241 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Pending Agent Review" escalated from System Processing Queue after 14 days |  |
| CP242 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be Day 14 |  |
| CP243 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "Manual Review Agent Queue" |  |
| CP244 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "CDG ? YYZ" as disrupted with details incomplete due to missing structural data |  |
| CP245 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the flight number and operating times should both be NULL meaning RE cannot even identify which flight to query codes for |  |
| CP246 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "Critical MSL data missing � operatin |  |
| CP247 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And RE should have polled on Days 1, 3, 7, 10, and 14 and all returned NULL for operating times and flight number |  |
| CP248 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the 14-Day Retry Window should be exhausted |  |
| CP249 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the determination should be "NO DETERMINATION" escalated to agent |  |
| CP250 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status History should show Created then System Processing Queue then Day 14 Pending Agent Review escalated due to MSL data miss |  |
| CP251 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an escalation email should have been sent to the customer's email on file containing Case Reference and limited flight details CDG to YY |  |
| CP252 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Feature: Payment Validation � TC145 Critical MSL Data Missing EU (No Automated Payment) Scenario: Validate Payment for TC145 Critical MSL Data Missing EU (No Au |
| CP253 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given no determination was made due to critical MSL data missing after 14-day retry |  |
| CP254 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then no automated payment flow should be triggered |  |
| CP255 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case was created and sent to agent for manual handling |  |
| CP256 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no country of residence should have been asked |  |
| CP257 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no compensation record should have been created automatically |  |
| CP258 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no batch file should have been dispatched |  |
| CP259 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e- |  |
| CP260 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved | Feature: Claims Dashboard Validation � TC115 OAL Non-Star Alliance Data Missing EU (No Determination � 14-Day Exhausted) Scenario: Validate Claims Dashboard for |
| CP261 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for PNR "TC115" under EU 261 EU origin CDG |  |
| CP262 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP263 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Pending Agent Review" escalated from System Processing Queue after 14 days |  |
| CP264 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be Day 14 |  |
| CP265 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "Manual Review Agent Queue" |  |
| CP266 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: CDG ? YYZ" as completed and AC operated and "Segment 2: YYZ ? YOW" arrived late plus 4h and WestJet  |  |
| CP267 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the MSL should be Segment 2 WestJet as non-Star Alliance OAL |  |
| CP268 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And this should differ from TC142 where Star Alliance results in immediate StarQuest routing whereas here non-Star OAL means system polls fo |  |
| CP269 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "OAL data not available � WestJet doe |  |
| CP270 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And RE should have polled on Days 1, 3, 7, 10, and 14 and all returned WestJet data NOT AVAILABLE |  |
| CP271 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the 14-Day Retry Window should be exhausted |  |
| CP272 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the determination should be "NO DETERMINATION" escalated to agent |  |
| CP273 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status History should show Created then System Processing Queue then Day 14 Pending Agent Review escalated due to OAL data not  |  |
| CP274 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an escalation email should have been sent to the customer's email on file containing Case Reference and Leg 1 CDG to YYZ AC completed an |  |
| CP275 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Feature: Payment Validation � TC115 OAL Non-Star Alliance Data Missing EU (No Automated Payment) Scenario: Validate Payment for TC115 OAL Non-Star Alliance Data |
| CP276 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given no determination was made due to OAL data not available after 14-day retry |  |
| CP277 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then no automated payment flow should be triggered |  |
| CP278 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case was created and sent to agent for manual handling |  |
| CP279 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no country of residence should have been asked |  |
| CP280 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no compensation record should have been created automatically |  |
| CP281 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no batch file should have been dispatched |  |
| CP282 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e- |  |
| CP283 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved | Feature: Claims Dashboard Validation � TC116 Philippe Lavoie (EU 261 72-Hour Pending) Scenario: Validate Claims Dashboard for TC116 Philippe Lavoie (EU 261 72-H |
| CP284 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Philippe Lavoie" with PNR "TC116" filed within 72 hours of arrival |  |
| CP285 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP286 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP287 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Pending (System Processing Queue)" |  |
| CP288 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated as June 15 2026 |  |
| CP289 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated as June 15 2026 |  |
| CP290 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the SLA should be 15 days |  |
| CP291 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "System Processing" |  |
| CP292 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP293 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should be pending as DDS has not yet run |  |
| CP294 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Philippe Lavoie" |  |
| CP295 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP296 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP297 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC116" |  |
| CP298 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP299 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP300 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP301 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP302 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261" pending confirmation after DDS runs |  |
| CP303 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Pending Reason should be "Filed within 72 hours of arrival" |  |
| CP304 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Scheduled DDS Run should be approximately June 18 2026 |  |
| CP305 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Philippe Lavoie" |  |
| CP306 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP307 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "p***@gmail.com" |  |
| CP308 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+33***123" |  |
| CP309 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP310 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP311 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP312 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP313 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: CDG ? YYZ" delayed plus 4h with claim filed for this flight |  |
| CP314 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP315 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP316 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation status should be "PENDING" awaiting 72-hour window |  |
| CP317 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should NOT have run yet as it is deferred until 72-hour window elapses approximately June 18 2026 |  |
| CP318 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no eligibility determination should exist yet |  |
| CP319 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Philippe Lavoie + TC116 + CDG?YYZ + FD" |  |
| CP320 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP321 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as DDS has not yet determined eligibility |  |
| CP322 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP323 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a pending received notification email should have been sent via Adobe to "p***@gmail.com" containing Case Reference and AC 871 CDG to YY |  |
| CP324 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP325 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record case creation and pending status |  |
| CP326 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the pending notification email |  |
| CP327 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP328 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP329 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Current Status should be "Pending (System Processing Queue)" |  |
| CP330 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should NOT be in read-only mode as it will be updated after DDS runs post 72h |  |
| CP331 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And after approximately June 18 2026 the system should automatically trigger DDS evaluation |  |
| CP332 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the status should update to Eligible or Not Eligible or No Determination based on DDS result |  |
| CP333 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the customer should be notified via email of the final outcome |  |
| CP334 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Feature: Payment Validation � TC116 Philippe Lavoie (EU 261 72-Hour Pending � No Payment Yet) Scenario: Validate Payment for TC116 Philippe Lavoie (EU 261 72-Ho |
| CP335 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case is in System Processing Queue pending 72-hour window |  |
| CP336 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then no payment flow should be triggered |  |
| CP337 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should poll DDS for up to 14 days |  |
| CP338 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no country of residence should have been asked |  |
| CP339 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no compensation record should have been created |  |
| CP340 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no batch file should have been dispatched |  |
| CP341 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if DDS returns eligible the Welcome Back flow should trigger and then the payment flow should proceed |  |
| CP342 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if no answer after 14 days the case should be sent to the agent queue |  |
| CP343 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show case status as "Pending" with no payout section | Feature: Claims Dashboard Validation � TC117 David Cohen (ASL Travel Completed � ?3,670 Eligible) Scenario: Validate Claims Dashboard for TC117 David Cohen (ASL |
| CP344 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "David Cohen" with PNR "TC117" |  |
| CP345 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP346 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP347 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP348 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP349 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP350 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP351 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP352 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP353 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "David Cohen" |  |
| CP354 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP355 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP356 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC117" |  |
| CP357 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL + APPR" |  |
| CP358 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "David Cohen" |  |
| CP359 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP360 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "d***@gmail.com" |  |
| CP361 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+972***456" |  |
| CP362 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YYZ ? TLV" with claim filed for this flight as arrived late plus 9h |  |
| CP363 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "?3,670 ILS" as ASL fixed rate for Travel Com |  |
| CP364 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Arrival Delay Code should be "42" as Not Extraordinary Circumstance |  |
| CP365 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dual Regime should show ASL at ?3,6 |  |
