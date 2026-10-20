# FD_TC_155 · CHAI-31547 — checkpoints

**Goal:** OAL (partner airline) employee on an Israel route. Employee exclusion is universal � blocks eligibility under ASL just as it does under APPR (TC_040) and EU 261 (TC_119). Validates that the employee override applies consistently across all three regimes.

Methods: seed 5, chat 40, api 16, email 3, dashboard 24, implied 14, manual 5, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | OAL (partner airline) employee on an Israel route. Employee exclusion is universal � blocks eligibility under ASL just as it does under APPR |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (OAL Employee) | PNR: Single passenger (OAL Employee) |
| CP003 | PREREQUISITES | prerequisite | seed | Employee Flag: OAL EMPLOYEE BOOKING in Trip Tracer | Employee Flag: OAL EMPLOYEE BOOKING in Trip Tracer |
| CP004 | PREREQUISITES | prerequisite | seed | Journey: Israel route (AC operated) | Journey: Israel route (AC operated) |
| CP005 | PREREQUISITES | prerequisite | seed | Disruption: Controllable delay | Disruption: Controllable delay |
| CP006 | PREREQUISITES | prerequisite | seed | Regime: ASL applicable (Israel route) | Regime: ASL applicable (Israel route) |
| CP007 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP008 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP009 | START | customer | chat | Then user selects English |  |
| CP010 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP011 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP012 | START | customer | chat | And the user says "My flight from Tel Aviv to Toronto was delayed 4 hours. I'd like to check if I'm eligible for compensation" | My flight from Tel Aviv to Toronto was delayed 4 hours. I'd like to check if I'm eligible for compensation |
| CP013 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP014 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP015 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP016 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP017 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP018 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP019 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Yonatan Weiss" | Yonatan Weiss |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Yonatan! And, what is your booking reference number? |
| CP021 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC122" | PNR: TC122 |
| CP022 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC122 |  |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data is revealed � OAL EMPLOYEE BOOKING IDENTIFIER PRESENT |  |
| CP025 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: y***@elal.co.il � Phone: +972***234 |
| CP027 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: y***@elal.co.il" | Email: y***@elal.co.il |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP029 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP030 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP032 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP033 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP034 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP035 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP036 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Yonatan Weiss (Adult) [OAL Employee] Is this who you'd like to include? |
| CP037 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP038 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP039 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 084 � Route: Tel Aviv Ben Gurion (TLV) ? Toronto (YYZ) � Date: June 1, 2026 � Arrival Delay: 4 hours Is this the jou |
| CP040 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP041 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP042 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP044 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP045 | EMPLOYEE CHECK | system | implied | Then the system checks: Is passenger an airline employee? ? YES (OAL employee booking identifier present) |  |
| CP046 | EMPLOYEE CHECK | system | implied | Then the system determines: OAL EMPLOYEE ? NOT ELIGIBLE (employee bookings excluded from all regimes) |  |
| CP047 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP048 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 084, Route: TLV ? YYZ, Scheduled Arrival: 16:00 | Promised Itinerary - Flight: AC 084, Route: TLV ? YYZ, Scheduled Arrival: 16:00 |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 084, Route: TLV ? YYZ, Status: ARRIVED LATE, Actual: 20:00, Delay: +4H 00M | Current Itinerary - Flight: AC 084, Route: TLV ? YYZ, Status: ARRIVED LATE, Actual: 20:00, Delay: +4H 00M |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | Passenger: OAL EMPLOYEE (OAL employee booking identifier present) | Passenger: OAL EMPLOYEE (OAL employee booking identifier present) |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Regime: ASL (Israel origin � TLV) � BUT employee exclusion applies | Regime: ASL (Israel origin � TLV) � BUT employee exclusion applies |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 084 � TLV ? YYZ � 42 � CONTROLLABLE | MSL FLIGHT: AC 084 � TLV ? YYZ � 42 � CONTROLLABLE |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | Employee Check: OAL EMPLOYEE ? NOT ELIGIBLE (overrides all other checks) | Employee Check: OAL EMPLOYEE ? NOT ELIGIBLE (overrides all other checks) |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | MR YONATAN WEISS / NOT ELIGIBLE / EMPLOYEE_OAL / 0.00 | MR YONATAN WEISS / NOT ELIGIBLE / EMPLOYEE_OAL / 0.00 |
| CP056 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP057 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your flight AC 084 from Tel Aviv Ben Gurion (TLV) to Toronto (YYZ) was delayed by 4 hours. However, based |
| CP058 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP059 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP060 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP061 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP062 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to y***@elal.co.il |  |
| CP063 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (OAL employee booking), regulation reference, contact informatio |  |
| CP064 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP065 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP066 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Yonatan Weiss" with PNR "TC122" |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Yonatan Weiss" |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC122" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL (Israel)" but employee exclusion applies |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Yonatan Weiss" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" and "OAL Employee" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "y***@elal.co.il" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+972***234" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: TLV ? YYZ" with claim filed for this flight |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "OAL Employee � employee bookings exclude |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to OAL Employee booking overriding all other checks |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically and the result should be "No duplicate found" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent to "y***@elal.co.il" containing Case Reference and flight details and not eligib |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP095 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to OAL Employee |  |
| CP096 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP097 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP098 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP099 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP100 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP101 | EXPECTED RESULTS | verdict | api | DDS returns FD-ASL-NE-02. | DDS returns FD-ASL-NE-02. |
| CP102 | EXPECTED RESULTS | verdict | chat | Employee Check: OAL Employee flag = TRUE ? NOT ELIGIBLE (universal employee exclusion). | Employee Check: OAL Employee flag = TRUE ? NOT ELIGIBLE (universal employee exclusion). |
| CP103 | EXPECTED RESULTS | verdict | chat | Compensation: $0. | Compensation: $0. |
| CP104 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP105 | EXPECTED RESULTS | verdict | chat | IDV: NOT REQUIRED. | IDV: NOT REQUIRED. |
| CP106 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP107 | EXPECTED RESULTS | verdict | api | Regime Assessment: ASL = NE-02 (OAL Employee); APPR = NE (Employee); EU = NE (Employee). | Regime Assessment: ASL = NE-02 (OAL Employee); APPR = NE (Employee); EU = NE (Employee). |
| CP108 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Status = Closed � Not Eligible; Reason = OAL Employee; DDS = FD-ASL-NE-02. | Claims Dashboard: Status = Closed � Not Eligible; Reason = OAL Employee; DDS = FD-ASL-NE-02. |
