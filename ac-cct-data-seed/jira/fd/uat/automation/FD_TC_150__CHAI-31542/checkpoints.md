# FD_TC_150 · CHAI-31542 — checkpoints

**Goal:** EU-originating flight occurred less than 72 hours ago. DDS hasn't processed the data yet because the standard processing window is 72 hours. Case is created in Pending state. Mirrors APPR pending test (TC_077) but for EU 261 regime. Validates that the 72-hour processing window applies equally to EU 261 claims.

Methods: seed 7, chat 37, api 15, email 3, dashboard 50, implied 17, manual 7, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | EU-originating flight occurred less than 72 hours ago. DDS hasn't processed the data yet because the standard processing window is 72 hours. |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger, 1 leg AC operated LHR?YYZ | PNR: Single passenger, 1 leg AC operated LHR?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: Flight operated yesterday (within 72hr window) | Itinerary: Flight operated yesterday (within 72hr window) |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival 16:00, Actual arrival 20:00 (4hr delay) | Scheduled arrival 16:00, Actual arrival 20:00 (4hr delay) |
| CP005 | PREREQUISITES | prerequisite | seed | Disruption code: Not yet available in DDS (within 72hr processing window) | Disruption code: Not yet available in DDS (within 72hr processing window) |
| CP006 | PREREQUISITES | prerequisite | seed | Filing time: 30 hours after flight | Filing time: 30 hours after flight |
| CP007 | PREREQUISITES | prerequisite | seed | DDS status: Data processing not yet complete | DDS status: Data processing not yet complete |
| CP008 | PREREQUISITES | prerequisite | seed | Route context: LHR = UK origin ? EU 261 applies | Route context: LHR = UK origin ? EU 261 applies |
| CP009 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP010 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP011 | START | customer | chat | Then user selects English |  |
| CP012 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP013 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP014 | START | customer | chat | And the user says "My flight from Paris to Toronto just landed about 4 hours late due to a crew issue. I'd like to file a compensation claim | My flight from Paris to Toronto just landed about 4 hours late due to a crew issue. I'd like to file a compensation claim right away |
| CP015 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP016 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP017 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP018 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP021 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Philippe Lavoie" | Philippe Lavoie |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Philippe! And, what is your booking reference number? |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC116" | PNR: TC116 |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC116 |  |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: p***@gmail.com � Phone: +33***123 |
| CP029 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: p***@gmail.com" | Email: p***@gmail.com |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP032 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP034 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP035 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP036 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP037 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP038 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Philippe Lavoie (Adult) Is this who you'd like to include? |
| CP039 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP040 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP041 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 871 � Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ) � Date: June 15, 2026 � Arrival Delay: 4 hours Is this th |
| CP042 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP046 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP047 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was June 15, 2026 at ~17:00 UTC; current time is June 15, 2026 at ~10:05 UTC ? approximately 0 hours sinc |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the system determines: 72-HOUR WINDOW NOT YET ELAPSED ? CASE PLACED IN PENDING / SYSTEM PROCESSING QUEUE |  |
| CP049 | PENDING STATUS � 72-HOUR HOLD | bot | chat | Then the chatbot responds: | Thank you for submitting your claim. Your claim has been received and is currently being processed. Please note that it may take up to 15 days to fully assess y |
| CP050 | PENDING STATUS � 72-HOUR HOLD | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP051 | CASE CREATION (GLOB-09) | system | implied | Then the system creates the case with status: PENDING (System Processing Queue) |  |
| CP052 | CASE CREATION (GLOB-09) | verdict | api | And the system records: Filed within 72 hours of arrival; DDS assessment deferred until 72-hour window elapses |  |
| CP053 | CASE CREATION (GLOB-09) | verdict | api | And the system schedules: DDS auto-processing to begin after 72 hours post-arrival (approximately June 18, 2026 at ~17:00 UTC) |  |
| CP054 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP055 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP056 | NOTIFICATION | email | email | And a Pending/Received notification email is sent to p***@gmail.com |  |
| CP057 | NOTIFICATION | email | email | And the email contains: | Your Air Canada claim has been received � [Case Reference] Your claim has been received and is being processed. We will notify you of the outcome within 15 days |
| CP058 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP059 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP060 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP061 | POST-72-HOUR PROCESSING | system | implied | When 72 hours have elapsed since arrival (approximately June 18, 2026 at ~17:00 UTC) |  |
| CP062 | POST-72-HOUR PROCESSING | verdict | api | Then the system automatically triggers DDS evaluation for PNR: TC116 |  |
| CP063 | POST-72-HOUR PROCESSING | verdict | api | And DDS retrieves disruption codes from backend |  |
| CP064 | POST-72-HOUR PROCESSING | verdict | api | And DDS evaluates eligibility under EU 261 regime |  |
| CP065 | POST-72-HOUR PROCESSING | system | implied | And the case status is updated from "Pending (System Processing Queue)" to the appropriate outcome (Eligible, Not Eligible, or No Determinat |  |
| CP066 | POST-72-HOUR PROCESSING | system | implied | And the customer is notified via email of the final outcome |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the case by PNR |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Case Title: "Travel Disruptions � Delay" � Status: Pending (System Processing Queue) � Created: June 15, 2026 � Last updated at: June 15, 2026 � SLA: 15 days  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard after June 18, 2026 |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Status: Updated to Eligible / Not Eligible / No Determination (based on DDS result) � DDS Run: Completed � Disruption Code: [populated from backend] � Eligibi |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Philippe Lavoie" with PNR "TC116" filed within 72 hours of arrival |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Pending (System Processing Queue)" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated as June 15 2026 |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated as June 15 2026 |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the SLA should be 15 days |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "System Processing" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should be pending as DDS has not yet run |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Philippe Lavoie" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC116" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261" pending confirmation after DDS runs |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Pending Reason should be "Filed within 72 hours of arrival" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Scheduled DDS Run should be approximately June 18 2026 |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Philippe Lavoie" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "p***@gmail.com" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+33***123" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: CDG ? YYZ" delayed plus 4h with claim filed for this flight |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation status should be "PENDING" awaiting 72-hour window |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should NOT have run yet as it is deferred until 72-hour window elapses approximately June 18 2026 |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no eligibility determination should exist yet |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Philippe Lavoie + TC116 + CDG?YYZ + FD" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as DDS has not yet determined eligibility |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a pending received notification email should have been sent via Adobe to "p***@gmail.com" containing Case Reference and AC 871 CDG to YY |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record case creation and pending status |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the pending notification email |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Current Status should be "Pending (System Processing Queue)" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should NOT be in read-only mode as it will be updated after DDS runs post 72h |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And after approximately June 18 2026 the system should automatically trigger DDS evaluation |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the status should update to Eligible or Not Eligible or No Determination based on DDS result |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the customer should be notified via email of the final outcome |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP123 | PAYMENT VALIDATION | payment | chat | Given the case is in System Processing Queue pending 72-hour window |  |
| CP124 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP125 | PAYMENT VALIDATION | payment | chat | And the system should poll DDS for up to 14 days |  |
| CP126 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP128 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And if DDS returns eligible the Welcome Back flow should trigger and then the payment flow should proceed |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And if no answer after 14 days the case should be sent to the agent queue |  |
| CP131 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "Pending" with no payout section |  |
| CP132 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-PE-01 (Pending). | DDS returns FD-EU-PE-01 (Pending). |
| CP133 | EXPECTED RESULTS | verdict | api | Trip Tracer: Data may or may not be available yet � within 72hr processing window. | Trip Tracer: Data may or may not be available yet � within 72hr processing window. |
| CP134 | EXPECTED RESULTS | verdict | api | Case status: PENDING � waiting for DDS processing. | Case status: PENDING � waiting for DDS processing. |
| CP135 | EXPECTED RESULTS | verdict | api | System behavior: Case created with collected customer data; DDS will auto-process when 72hr window expires; No polling needed � expected tim | System behavior: Case created with collected customer data; DDS will auto-process when 72hr window expires; No polling needed � expected timing. |
| CP136 | EXPECTED RESULTS | verdict | api | After 72hrs: DDS processes ? returns definitive EU code (EL/NE/ND) with distance band and compensation amount. | After 72hrs: DDS processes ? returns definitive EU code (EL/NE/ND) with distance band and compensation amount. |
| CP137 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Status = Pending; Reason = Within 72hr processing window; EU 261 regime identified; Auto-assessment scheduled; DDS = FD-EU | Claims Dashboard: Status = Pending; Reason = Within 72hr processing window; EU 261 regime identified; Auto-assessment scheduled; DDS = FD-EU-PE-01. |
