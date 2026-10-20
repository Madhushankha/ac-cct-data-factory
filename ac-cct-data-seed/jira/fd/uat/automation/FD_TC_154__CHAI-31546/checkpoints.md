# FD_TC_154 · CHAI-31546 — checkpoints

**Goal:** Customer is an Air Canada employee on an employee booking flying to Israel. Employee bookings are NOT eligible for compensation under ANY regime � ASL included. Validates that DDS detects the employee booking flag and returns Not Eligible before any ASL assessment.

Methods: seed 6, chat 30, api 13, email 3, dashboard 284, implied 14, manual 44, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer is an Air Canada employee on an employee booking flying to Israel. Employee bookings are NOT eligible for compensation under ANY re |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (AC employee), 1 leg AC operated YYZ?TLV | PNR: Single passenger (AC employee), 1 leg AC operated YYZ?TLV |
| CP003 | PREREQUISITES | prerequisite | seed | Employee booking flag: TRUE in PNR | Employee booking flag: TRUE in PNR |
| CP004 | PREREQUISITES | prerequisite | seed | Itinerary: Scheduled arrival 06:00, Actual arrival 10:00 (4hr delay) | Itinerary: Scheduled arrival 06:00, Actual arrival 10:00 (4hr delay) |
| CP005 | PREREQUISITES | prerequisite | seed | Disruption code: 42 (Controllable) | Disruption code: 42 (Controllable) |
| CP006 | PREREQUISITES | prerequisite | seed | Booking type: Employee/staff travel | Booking type: Employee/staff travel |
| CP007 | PREREQUISITES | prerequisite | seed | Route context: Canada departure ? APPR; Israel arrival ? ASL | Route context: Canada departure ? APPR; Israel arrival ? ASL |
| CP008 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP009 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP010 | START | customer | chat | Then user selects English |  |
| CP011 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP012 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP013 | START | customer | chat | And the user says "My flight from Tel Aviv to Toronto was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compens | My flight from Tel Aviv to Toronto was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation |
| CP014 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP015 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP016 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP017 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP018 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP020 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Daniel Avraham" | Daniel Avraham |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Daniel! And, what is your booking reference number? |
| CP022 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC121" | PNR: TC121 |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC121 |  |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data is revealed � EMPLOYEE BOOKING IDENTIFIER PRESENT (AC Employee) |  |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: d***@aircanada.ca � Phone: +972***123 |
| CP028 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: d***@aircanada.ca" | Email: d***@aircanada.ca |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP030 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP031 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP033 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP034 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP035 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP036 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP037 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Daniel Avraham (Adult) [AC Employee] Is this who you'd like to include? |
| CP038 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP039 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP040 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 084 � Route: Tel Aviv Ben Gurion (TLV) ? Toronto (YYZ) � Date: May 31, 2026 � Arrival Delay: 4 hours Is this the jou |
| CP041 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP045 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP046 | EMPLOYEE CHECK | system | implied | Then the system checks: Is passenger an AC employee? ? YES (employee booking identifier present) |  |
| CP047 | EMPLOYEE CHECK | system | implied | Then the system determines: AC EMPLOYEE ? NOT ELIGIBLE (employee bookings excluded from all regimes) |  |
| CP048 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP049 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 084, Route: TLV ? YYZ, Scheduled Arrival: 16:00 | Promised Itinerary - Flight: AC 084, Route: TLV ? YYZ, Scheduled Arrival: 16:00 |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 084, Route: TLV ? YYZ, Status: ARRIVED LATE, Actual: 20:00, Delay: +4H 00M | Current Itinerary - Flight: AC 084, Route: TLV ? YYZ, Status: ARRIVED LATE, Actual: 20:00, Delay: +4H 00M |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Passenger: AC EMPLOYEE (employee booking identifier present) | Passenger: AC EMPLOYEE (employee booking identifier present) |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | Regime: ASL (Israel origin � TLV) � BUT employee exclusion applies | Regime: ASL (Israel origin � TLV) � BUT employee exclusion applies |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 084 � TLV ? YYZ � 42 � CONTROLLABLE | MSL FLIGHT: AC 084 � TLV ? YYZ � 42 � CONTROLLABLE |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Employee Check: AC EMPLOYEE ? NOT ELIGIBLE (overrides all other checks) | Employee Check: AC EMPLOYEE ? NOT ELIGIBLE (overrides all other checks) |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | MR DANIEL AVRAHAM / NOT ELIGIBLE / EMPLOYEE_AC / 0.00 | MR DANIEL AVRAHAM / NOT ELIGIBLE / EMPLOYEE_AC / 0.00 |
| CP057 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP058 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your flight AC 084 from Tel Aviv Ben Gurion (TLV) to Toronto (YYZ) was delayed by 4 hours. However, based |
| CP059 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP060 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP061 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP062 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP063 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to d***@aircanada.ca |  |
| CP064 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (AC employee booking), regulation reference, contact information |  |
| CP065 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP066 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP067 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Feature: Claims Dashboard Validation � TC121 Daniel Avraham (ASL AC Employee � Not Eligible) | Scenario: Validate Claims Dashboard for TC121 Daniel Avraham (ASL AC Employee � Not Eligible) |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Daniel Avraham" with PNR "TC121" |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Daniel Avraham" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC121" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL (Israel)" but employee exclusion applies |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Daniel Avraham" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" and "AC Employee" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "d***@aircanada.ca" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+972***123" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: TLV ? YYZ" with claim filed for this flight |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "AC Employee � employee bookings excluded |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to AC Employee booking overriding all other checks including cont |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Daniel Avraham + TC121 + TLV?YYZ + FD" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe to "d***@aircanada.ca" containing Case Reference and flight details an |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Feature: Payment Validation � TC121 Daniel Avraham (ASL AC Employee � No Payment) Scenario: Validate Payment for TC121 Daniel Avraham (ASL AC Employee � No Paym |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the eligibility result is "NOT ELIGIBLE" due to AC Employee |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then no payment flow should be triggered |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no country of residence should have been asked |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no compensation record should have been created |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no batch file should have been dispatched |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section | Feature: Claims Dashboard Validation � TC122 Yonatan Weiss (ASL OAL Employee � Not Eligible) Scenario: Validate Claims Dashboard for TC122 Yonatan Weiss (ASL OA |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Yonatan Weiss" with PNR "TC122" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Yonatan Weiss" |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC122" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL (Israel)" but employee exclusion applies |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Yonatan Weiss" |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" and "OAL Employee" |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "y***@elal.co.il" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+972***234" |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: TLV ? YYZ" with claim filed for this flight |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "OAL Employee � employee bookings exclude |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to OAL Employee booking overriding all other checks |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically and the result should be "No duplicate found" |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent to "y***@elal.co.il" containing Case Reference and flight details and not eligib |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Feature: Payment Validation � TC122 Yonatan Weiss (ASL OAL Employee � No Payment) Scenario: Validate Payment for TC122 Yonatan Weiss (ASL OAL Employee � No Paym |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the eligibility result is "NOT ELIGIBLE" due to OAL Employee |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then no payment flow should be triggered |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no country of residence should have been asked |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no compensation record should have been created |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no batch file should have been dispatched |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section | Feature: Claims Dashboard Validation � TC123 OAL Operated ASL (No Case) Scenario: Validate Claims Dashboard for TC123 OAL Operated ASL (No Case) |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the system determined all segments are operated by OAL El Al LY 315 for PNR "TC123" |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the chatbot should have redirected the customer to contact El Al directly |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no DDS evaluation should have occurred |  |
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no case should have been created in the automated system |  |
| CP166 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Claims Dashboard entry should exist for PNR "TC123" |  |
| CP167 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And when searching Claims Dashboard by PNR "TC123" no case should be found | Feature: Payment Validation � TC123 OAL Operated ASL (No Payment) Scenario: Validate Payment for TC123 OAL Operated ASL (No Payment) |
| CP168 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given no case was created due to OAL operated flight |  |
| CP169 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then no payment flow should be triggered |  |
| CP170 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no country of residence should have been asked |  |
| CP171 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no compensation record should have been created |  |
| CP172 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no batch file should have been dispatched |  |
| CP173 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section | Feature: Claims Dashboard Validation � TC124 Denied Boarding ASL (No Case) Scenario: Validate Claims Dashboard for TC124 Denied Boarding ASL (No Case) |
| CP174 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the chatbot identified a denied boarding event for PNR "TC124" |  |
| CP175 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the chatbot should have redirected the customer to Customer Relations or the denied boarding claim form |  |
| CP176 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no identification flow should have occurred |  |
| CP177 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no authentication flow should have occurred |  |
| CP178 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no DDS evaluation should have occurred |  |
| CP179 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no case should have been created in the automated system as denied boarding is handled separately |  |
| CP180 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Claims Dashboard entry should exist for PNR "TC124" |  |
| CP181 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And when searching Claims Dashboard by PNR "TC124" no automated case should be found | Feature: Payment Validation � TC124 Denied Boarding ASL (No Payment) Scenario: Validate Payment for TC124 Denied Boarding ASL (No Payment) |
| CP182 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given no case was created due to denied boarding being handled separately |  |
| CP183 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then no payment flow should be triggered |  |
| CP184 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no country of residence should have been asked |  |
| CP185 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no compensation record should have been created |  |
| CP186 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no batch file should have been dispatched |  |
| CP187 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section | Feature: Claims Dashboard Validation � TC125 Amir Segal (ASL Extraordinary Weather Origin Cancellation � Not Eligible) Scenario: Validate Claims Dashboard for T |
| CP188 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Amir Segal" with PNR "TC125" |  |
| CP189 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation" |  |
| CP190 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP191 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP192 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP193 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP194 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP195 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP196 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP197 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP198 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Amir Segal" |  |
| CP199 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP200 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP201 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC125" |  |
| CP202 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP203 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP204 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP205 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP206 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL (Israel origin � TLV) + APPR" |  |
| CP207 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Amir Segal" |  |
| CP208 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP209 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "a***@gmail.com" |  |
| CP210 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+972***789" |  |
| CP211 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP212 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP213 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP214 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP215 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: TLV ? YYZ" with claim filed for this flight as cancelled |  |
| CP216 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP217 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP218 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Extraordinary Circumstance � severe weat |  |
| CP219 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP220 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP221 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to Extraordinary Circumstance with cancellation code WEAT and No  |  |
| CP222 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Amir Segal + TC125 + TLV?YYZ + FD" |  |
| CP223 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP224 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP225 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP226 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP227 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP228 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP229 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP230 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP231 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP232 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe to "a***@gmail.com" containing Extraordinary Circumstance severe weath |  |
| CP233 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP234 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP235 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP236 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP237 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP238 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP239 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP240 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Feature: Payment Validation � TC125 Amir Segal (ASL Extraordinary Weather Origin � No Payment) Scenario: Validate Payment for TC125 Amir Segal (ASL Extraordinar |
| CP241 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the eligibility result is "NOT ELIGIBLE" due to Extraordinary Circumstance severe weather |  |
| CP242 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then no payment flow should be triggered |  |
| CP243 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no country of residence should have been asked |  |
| CP244 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no compensation record should have been created |  |
| CP245 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no batch file should have been dispatched |  |
| CP246 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section | Feature: Claims Dashboard Validation � TC126 Eli Navon (ASL Extraordinary Weather Leg 2 Return Cancellation � Not Eligible) Scenario: Validate Claims Dashboard  |
| CP247 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Eli Navon" with PNR "TC126" |  |
| CP248 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation" |  |
| CP249 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP250 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP251 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP252 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP253 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP254 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP255 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP256 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP257 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Eli Navon" |  |
| CP258 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP259 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP260 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC126" |  |
| CP261 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP262 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP263 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP264 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP265 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL (Israel destination � TLV) + APPR" |  |
| CP266 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Eli Navon" |  |
| CP267 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP268 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "e***@gmail.com" |  |
| CP269 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***901" |  |
| CP270 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP271 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP272 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP273 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP274 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: YYZ ? FRA" as completed and "Segment 2: FRA ? TLV" as cancelled with claim filed |  |
| CP275 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP276 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP277 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Extraordinary Circumstance � severe weat |  |
| CP278 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP279 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP280 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to Extraordinary Circumstance with cancellation code WEAT and Leg |  |
| CP281 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Eli Navon + TC126 + YYZ?TLV + FD" |  |
| CP282 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP283 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP284 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP285 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP286 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP287 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP288 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP289 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP290 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP291 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe to "e***@gmail.com" containing Case Reference and Leg 2 FRA to TLV CAN |  |
| CP292 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP293 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP294 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP295 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP296 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP297 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP298 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP299 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Feature: Payment Validation � TC126 Eli Navon (ASL Extraordinary Weather Leg 2 Return � No Payment) Scenario: Validate Payment for TC126 Eli Navon (ASL Extraord |
| CP300 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the eligibility result is "NOT ELIGIBLE" due to Extraordinary Circumstance severe weather on Leg 2 |  |
| CP301 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then no payment flow should be triggered |  |
| CP302 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no country of residence should have been asked |  |
| CP303 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no compensation record should have been created |  |
| CP304 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no batch file should have been dispatched |  |
| CP305 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section | Feature: Claims Dashboard Validation � TC127 Talia Friedman (ASL Extraordinary Weather Leg 2 Incomplete Cancellation � Not Eligible) Scenario: Validate Claims D |
| CP306 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Talia Friedman" with PNR "TC127" |  |
| CP307 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation" |  |
| CP308 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP309 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP310 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP311 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP312 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP313 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Talia Friedman" |  |
| CP314 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP315 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC127" |  |
| CP316 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL (Israel destination � TLV) + APPR" |  |
| CP317 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Talia Friedman" |  |
| CP318 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "t***@outlook.com" |  |
| CP319 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***123" |  |
| CP320 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: YYZ ? FRA" as completed and "Segment 2: FRA ? TLV" as cancelled with claim filed |  |
| CP321 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Extraordinary Circumstance � WEAT � Leg  |  |
| CP322 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP323 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to Extraordinary Circumstance with WEAT and Leg 2 FRA to TLV and  |  |
| CP324 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically and the result should be "No duplicate found" |  |
| CP325 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered |  |
| CP326 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP327 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent to "t***@outlook.com" |  |
| CP328 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP329 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP330 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Feature: Payment Validation � TC127 Talia Friedman (ASL Extraordinary Weather Leg 2 Incomplete � No Payment) Scenario: Validate Payment for TC127 Talia Friedman |
| CP331 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the eligibility result is "NOT ELIGIBLE" due to Extraordinary Circumstance severe weather on Leg 2 |  |
| CP332 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then no payment flow should be triggered |  |
| CP333 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no country of residence should have been asked |  |
| CP334 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no compensation record should have been created |  |
| CP335 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no batch file should have been dispatched |  |
| CP336 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section | Feature: Claims Dashboard Validation � TC128 Hadas Mor (ASL Below Threshold Origin Cancellation � Not Eligible) Scenario: Validate Claims Dashboard for TC128 Ha |
| CP337 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Hadas Mor" with PNR "TC128" |  |
| CP338 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation" |  |
| CP339 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP340 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP341 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP342 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP343 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP344 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP345 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP346 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP347 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Hadas Mor" |  |
| CP348 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP349 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP350 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC128" |  |
| CP351 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP352 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP353 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP354 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP355 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL (Israel destination � TLV) + APPR" |  |
| CP356 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Hadas Mor" |  |
| CP357 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP358 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "h***@gmail.com" |  |
| CP359 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***345" |  |
| CP360 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP361 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP362 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP363 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP364 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YYZ ? TLV" with claim filed as cancelled |  |
| CP365 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP366 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP367 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "MSL re-routing delay 2h � below ASL mini |  |
| CP368 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP369 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP370 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to delay 2h being less than 3h ASL No Travel threshold |  |
| CP371 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Hadas Mor + TC128 + YYZ?TLV + FD" |  |
| CP372 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP373 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP374 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP375 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP376 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP377 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP378 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP379 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP380 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP381 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe to "h***@gmail.com" containing Case Reference and YYZ to TLV CANCELLED |  |
| CP382 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP383 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP384 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP385 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP386 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP387 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP388 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP389 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Feature: Payment Validation � TC128 Hadas Mor (ASL Below Threshold Origin � No Payment) Scenario: Validate Payment for TC128 Hadas Mor (ASL Below Threshold Orig |
| CP390 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the eligibility result is "NOT ELIGIBLE" due to MSL delay below 3-hour ASL threshold |  |
| CP391 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then no payment flow should be triggered |  |
| CP392 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no country of residence should have been asked |  |
| CP393 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no compensation record should have been created |  |
| CP394 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no batch file should have been dispatched |  |
| CP395 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section | Feature: Claims Dashboard Validation � TC129 Itai Bergman (ASL Below |
