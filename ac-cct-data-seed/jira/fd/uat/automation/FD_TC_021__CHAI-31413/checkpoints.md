# FD_TC_021 · CHAI-31413 — checkpoints

**Goal:** Customer files claim before 72 hours have elapsed since the flight. DDS data is not yet available. System creates case in pending state, polls DDS daily for up to 14 days. When data arrives, sends deep link notification for customer to return and complete claim. Validates the pre-72hr intake and polling mechanism.

Methods: seed 5, chat 40, api 12, email 4, dashboard 51, implied 20, manual 16, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer files claim before 72 hours have elapsed since the flight. DDS data is not yet available. System creates case in pending state, pol |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Mathieu Roy), 1 leg AC domestic YUL?YYZ | PNR: Single passenger (Mathieu Roy), 1 leg AC domestic YUL?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: 4hr delay, Arrival delay code: Pending, Controllable | Itinerary: 4hr delay, Arrival delay code: Pending, Controllable |
| CP004 | PREREQUISITES | prerequisite | seed | Filing time: 48 hours after flight (within 72hr window) | Filing time: 48 hours after flight (within 72hr window) |
| CP005 | PREREQUISITES | prerequisite | seed | DDS data: NOT YET AVAILABLE at time of filing | DDS data: NOT YET AVAILABLE at time of filing |
| CP006 | PREREQUISITES | prerequisite | seed | Trip Tracer: Data will become available at D+4 (after 72hrs) | Trip Tracer: Data will become available at D+4 (after 72hrs) |
| CP007 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP008 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP009 | START | customer | chat | Then user selects English |  |
| CP010 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP011 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP012 | START | customer | chat | And the user says "My flight just landed 4 hours late yesterday, I want to file a compensation claim right away" | My flight just landed 4 hours late yesterday, I want to file a compensation claim right away |
| CP013 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP014 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP015 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP016 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP017 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP018 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP019 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Mathieu Roy" | Mathieu Roy |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Mathieu! And, what is your booking reference number? |
| CP021 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC017" | PNR: TC017 |
| CP022 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC017 |  |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP025 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: m***@outlook.com � Phone: +1***789 |
| CP027 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: m***@outlook.com" | Email: m***@outlook.com |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP029 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "619374" | 619374 |
| CP030 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP032 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP033 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP034 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP035 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP036 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Mathieu Roy (Adult) Is this who you'd like to include? |
| CP037 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP038 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP039 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 429 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 3, 2026 � Arrival Delay: 4 hours Is this the journey you'd  |
| CP040 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP041 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP042 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP044 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP045 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was June 3, 2026 at 18:00; current date is June 4, 2026 at 14:00 ? 20 hours ? LESS THAN 72 hours ? 72-HOU |  |
| CP046 | PENDING RESULT | bot | chat | Then the chatbot displays: | Thank you for submitting your claim. Your claim has been recorded and will be automatically processed once we have complete flight data. You will receive an ema |
| CP047 | CASE CREATION | system | implied | Then the system creates a case in PENDING status: |  |
| CP048 | CASE CREATION | system | implied | And the case status = "Pending � Awaiting 72-Hour Window" |  |
| CP049 | CASE CREATION | verdict | api | And the system sets auto-trigger for DDS evaluation at 72 hours post-arrival (June 6, 2026 18:00) |  |
| CP050 | CASE CREATION | system | implied | And the booking record is appended automatically |  |
| CP051 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP052 | NOTIFICATION | email | email | And a pending notification email is sent to m***@outlook.com |  |
| CP053 | NOTIFICATION | email | email | And the email contains: Case Reference, status (Pending � Awaiting Assessment), expected assessment date (June 6, 2026), flight details, nex |  |
| CP054 | NO FURTHER PROCESSING AT THIS TIME | verdict | api | Then the chatbot does NOT proceed to DDS evaluation |  |
| CP055 | NO FURTHER PROCESSING AT THIS TIME | system | implied | And the chatbot does NOT proceed to CyberSource |  |
| CP056 | NO FURTHER PROCESSING AT THIS TIME | system | implied | And the chatbot does NOT proceed to payment |  |
| CP057 | NO FURTHER PROCESSING AT THIS TIME | idv | chat | And the chatbot does NOT proceed to IDV |  |
| CP058 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP059 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP060 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP061 | POST-72-HOUR AUTO-PROCESSING | system | implied | When 72 hours have elapsed since arrival (June 6, 2026 at 18:00) |  |
| CP062 | POST-72-HOUR AUTO-PROCESSING | verdict | api | Then the system automatically triggers DDS evaluation for the pending case |  |
| CP063 | POST-72-HOUR AUTO-PROCESSING | verdict | api | And DDS runs the full assessment (Steps 1-8) |  |
| CP064 | POST-72-HOUR AUTO-PROCESSING | system | implied | And the system determines eligibility |  |
| CP065 | POST-72-HOUR AUTO-PROCESSING | system | implied | Then the system sends a "Welcome Back" notification email to m***@outlook.com |  |
| CP066 | POST-72-HOUR AUTO-PROCESSING | email | email | And the email contains: Case Reference, eligibility result, compensation amount (if eligible), next steps to complete payment (if eligible) |  |
| CP067 | POST-72-HOUR AUTO-PROCESSING | system | implied | And the customer can return to the chatbot to complete the payment flow |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Mathieu Roy" with PNR "TC017" filed within 72 hours of arrival |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Pending � Awaiting 72-Hour Window" |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "System Processing Queue" with no agent assignment |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel may not be fully populated as DDS has not run yet |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Mathieu Roy" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC017" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Mathieu Roy" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "m***@outlook.com" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***789" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present but NOT yet populated as DDS has not run and the 72-hour window has not been  |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should NOT have run yet as the 72-hour window has not elapsed |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should NOT be pre-populated |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the 72-hour window should NOT have been met as the claim was filed 20 hours after arrival |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have entered the System Processing Queue with no agent assignment |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should NOT be routed to an agent |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have set an auto-trigger for DDS evaluation at 72 hours post-arrival |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if DDS has no answer after 14 days the case should auto-route to the agent queue |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Mathieu Roy + TC017 + YUL?YYZ + FD" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs after DDS determines eligibility and DDS has not run yet |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should NOT be in any agent's queue and should be in the System Processing Queue |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And no agent pull case action should be expected at this time |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a pending notification email should have been sent to "m***@outlook.com" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email should contain the Case Reference and status "Pending � Awaiting Assessment" and expected assessment date and flight details a |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record case creation and pending status with timestamps |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the pending notification email |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Pending � Awaiting 72-Hour Window" in the System Processing Queue |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should NOT be in read-only mode as it is still pending processing |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And after 72 hours elapse and DDS runs the case should transition to eligible or not eligible and a Welcome Back email should be sent |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP127 | PAYMENT VALIDATION | payment | chat | Given the case was filed within 72 hours of arrival and was placed in the System Processing Queue |  |
| CP128 | PAYMENT VALIDATION | payment | chat | And 72 hours have elapsed since arrival so DDS should run and return an eligible result |  |
| CP129 | PAYMENT VALIDATION | payment | chat | Then a Welcome Back email should be sent to the customer with a deep link |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And the customer clicks the deep link and returns to the flow |  |
| CP131 | PAYMENT VALIDATION | payment | chat | And the payment flow should trigger from this point |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And the customer's country of residence is "Canada" |  |
| CP133 | PAYMENT VALIDATION | payment | chat | And the currency should be set to "CAD" |  |
| CP134 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP135 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created |  |
| CP136 | PAYMENT VALIDATION | payment | manual | And the record should be picked up by the daily evening batch file |  |
| CP137 | PAYMENT VALIDATION | payment | manual | And the record should be dispatched to Unifier |  |
| CP138 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP139 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received from Interac |  |
| CP140 | PAYMENT VALIDATION | payment | manual | And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP141 | PAYMENT VALIDATION | payment | manual | And if the payment is unclaimed after 35 days the status should be set to "Expired" |  |
| CP142 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details updated via talkback |  |
| CP143 | EXPECTED RESULTS | verdict | api | DDS returns PENDING initially. | DDS returns PENDING initially. |
| CP144 | EXPECTED RESULTS | verdict | api | Case created: Status = Pending; Reason = Filed before 72hrs; DDS data unavailable. "Polling: System polls DDS daily (DDS operates post-journ | Case created: Status = Pending; Reason = Filed before 72hrs; DDS data unavailable. "Polling: System polls DDS daily (DDS operates post-journey, 72 hours after f |
| CP145 | EXPECTED RESULTS | verdict | api | Trip Tracer stores data; DDS runs eligibility.". | Trip Tracer stores data; DDS runs eligibility.". |
| CP146 | EXPECTED RESULTS | verdict | api | At D+4: Data arrives ? DDS processes ? FD-APPR-EL-01. | At D+4: Data arrives ? DDS processes ? FD-APPR-EL-01. |
| CP147 | EXPECTED RESULTS | verdict | chat | Notification: Deep link email sent to customer. | Notification: Deep link email sent to customer. |
| CP148 | EXPECTED RESULTS | verdict | chat | Customer returns: Completes claim ? $400 CAD. | Customer returns: Completes claim ? $400 CAD. |
| CP149 | EXPECTED RESULTS | verdict | dashboard | Claims Dashboard: Shows polling history; Data arrival timestamp; Welcome Back flow = TRUE. | Claims Dashboard: Shows polling history; Data arrival timestamp; Welcome Back flow = TRUE. |
