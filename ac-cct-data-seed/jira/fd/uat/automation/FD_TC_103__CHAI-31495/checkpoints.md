# FD_TC_103 · CHAI-31495 — checkpoints

**Goal:** Flight occurred less than 72 hours ago. DDS hasn't processed the data yet because the standard processing window is 72 hours after the flight. Case is created in Pending state. System will auto-assess when DDS data becomes available after the 72-hour window. Differs from TC_018 (Welcome Back) � here the system creates a pending case without customer interaction, whereas Welcome Back involves the customer filing early and being notified later.

Methods: seed 6, chat 38, api 11, email 3, dashboard 44, implied 14, manual 9, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Flight occurred less than 72 hours ago. DDS hasn't processed the data yet because the standard processing window is 72 hours after the fligh |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger, 1 leg AC domestic YUL?YYZ | PNR: Single passenger, 1 leg AC domestic YUL?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: Flight operated yesterday (within 72hr window) | Itinerary: Flight operated yesterday (within 72hr window) |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival 14:00, Actual arrival 18:00 (4hr delay) | Scheduled arrival 14:00, Actual arrival 18:00 (4hr delay) |
| CP005 | PREREQUISITES | prerequisite | seed | Disruption code: Not yet available in DDS (within 72hr processing window) | Disruption code: Not yet available in DDS (within 72hr processing window) |
| CP006 | PREREQUISITES | prerequisite | seed | Filing time: 24 hours after flight (within 72hr window) | Filing time: 24 hours after flight (within 72hr window) |
| CP007 | PREREQUISITES | prerequisite | seed | DDS status: Data processing not yet complete | DDS status: Data processing not yet complete |
| CP008 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP009 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP010 | START | customer | chat | Then user selects English |  |
| CP011 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP012 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP013 | START | customer | chat | And the user says "My flight just landed 2 hours ago and it was delayed 4 hours. I'd like to file a compensation claim right away" | My flight just landed 2 hours ago and it was delayed 4 hours. I'd like to file a compensation claim right away |
| CP014 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP015 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP016 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP017 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP018 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP020 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Marc-Andr� Lavoie" | Marc-Andr� Lavoie |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Marc-Andr�! And, what is your booking reference number? |
| CP022 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC060" | PNR: TC060 |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC060 |  |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: m***@gmail.com � Phone: +1***789 |
| CP028 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: m***@gmail.com" | Email: m***@gmail.com |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP030 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP031 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP033 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP034 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP035 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP036 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP037 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Marc-Andr� Lavoie (Adult) Is this who you'd like to include? |
| CP038 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP039 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP040 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 504 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 15, 2026 � Arrival Delay: 4 hours Is this the journey you'd |
| CP041 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP045 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP046 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was June 15, 2026 at 10:00; current time is June 15, 2026 at 12:31 ? 2 hours 31 minutes ? LESS THAN 72 HO |  |
| CP047 | 72-HOUR CHECK | system | implied | Then the system determines: 72-HOUR WINDOW NOT ELAPSED ? CASE PLACED IN SYSTEM PROCESSING QUEUE |  |
| CP048 | PENDING RESULT | bot | chat | Then the chatbot displays: | Thank you for submitting your claim. Your flight AC 504 from Montreal (YUL) to Toronto (YYZ) on June 15, 2026 has been recorded. Please note that claims require |
| CP049 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Your claim has been submitted successfully and is now in our processing queue." | Your claim has been submitted successfully and is now in our processing queue. |
| CP050 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP051 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP052 | CASE CREATION (GLOB-09) | system | implied | And the case status is set to: SYSTEM PROCESSING QUEUE |  |
| CP053 | CASE CREATION (GLOB-09) | verdict | api | And the system schedules DDS evaluation for 72 hours post-arrival (June 18, 2026 at 10:00) |  |
| CP054 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP055 | NOTIFICATION | email | email | And a Pending notification email is sent to m***@gmail.com |  |
| CP056 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, status (pending � 72-hour processing window), expected processing date, tracking lin |  |
| CP057 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP058 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP059 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP060 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Marc-Andr� Lavoie" with PNR "TC060" filed within 72 hours of arrival |  |
| CP061 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP062 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP063 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "System Processing Queue" |  |
| CP064 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP065 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT yet be populated as DDS has not run |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Marc-Andr� Lavoie" |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC060" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" pending confirmation after DDS runs |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Marc-Andr� Lavoie" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "m***@gmail.com" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***789" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "PENDING" as DDS has not yet run and 72 hours have not elapsed |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should NOT have run yet as the 72-hour window has not elapsed and is scheduled for June 18 2026 at 10:00 |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be "PENDING" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Marc-Andr� Lavoie + TC060 + YUL?YYZ + FD" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as DDS has not yet run |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in System Processing Queue and not yet available for agent pull |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a pending notification email should have been sent to "m***@gmail.com" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email should contain the Case Reference and flight details and status "pending � 72-hour processing window" and expected processing  |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record case creation with timestamps |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the pending notification email |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "System Processing Queue" with DDS scheduled for June 18 2026 at 10:00 |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should NOT be in read-only mode as it is pending system processing |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP112 | PAYMENT VALIDATION | payment | chat | Given the case is in System Processing Queue pending 72-hour window |  |
| CP113 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP114 | PAYMENT VALIDATION | payment | chat | And the system should poll DDS for up to 14 days |  |
| CP115 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP116 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP117 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP118 | PAYMENT VALIDATION | payment | chat | And if DDS returns eligible the Welcome Back flow should trigger and then the payment flow should proceed |  |
| CP119 | PAYMENT VALIDATION | payment | chat | And if no answer after 14 days the case should be sent to the agent queue |  |
| CP120 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "Pending" with no payout section |  |
| CP121 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-PE-01 (Pending). | DDS returns FD-APPR-PE-01 (Pending). |
| CP122 | EXPECTED RESULTS | verdict | api | Trip Tracer: Data may or may not be available yet � within 72hr processing window. | Trip Tracer: Data may or may not be available yet � within 72hr processing window. |
| CP123 | EXPECTED RESULTS | verdict | api | Case status: PENDING � waiting for DDS processing. | Case status: PENDING � waiting for DDS processing. |
| CP124 | EXPECTED RESULTS | verdict | api | System behavior: Case created with collected customer data; DDS will auto-process when 72hr window expires; No polling needed (unlike ND sce | System behavior: Case created with collected customer data; DDS will auto-process when 72hr window expires; No polling needed (unlike ND scenarios) � this is ex |
| CP125 | EXPECTED RESULTS | verdict | api | After 72hrs: DDS processes ? returns definitive code (EL/NE/ND). | After 72hrs: DDS processes ? returns definitive code (EL/NE/ND). |
| CP126 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Status = Pending; Reason = Within 72hr processing window; Auto-assessment scheduled; DDS = FD-APPR-PE-01. | Claims Dashboard: Status = Pending; Reason = Within 72hr processing window; Auto-assessment scheduled; DDS = FD-APPR-PE-01. |
