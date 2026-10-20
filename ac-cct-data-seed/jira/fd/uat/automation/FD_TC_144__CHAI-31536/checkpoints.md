# FD_TC_144 · CHAI-31536 — checkpoints

**Goal:** Flight YYZ?CDG (Toronto to Paris) � delayed 4 hours, controllable (arrival delay code 42). EU 261 requires EU/UK origin for flights on any carrier. Since origin is YYZ (Canada), EU 261 does NOT apply. Additionally, for flights arriving in EU, the operating carrier must be EU-based � AC is Canadian, so the EU arrival rule also does not apply. APPR applies separately (Canadian origin).

Methods: seed 10, chat 42, api 11, email 3, dashboard 37, implied 19, manual 6, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Flight YYZ?CDG (Toronto to Paris) � delayed 4 hours, controllable (arrival delay code 42). EU 261 requires EU/UK origin for flights on any c |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Robert Tremblay (Adult) | PNR: single passenger Robert Tremblay (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 870, YYZ?CDG | Journey: 1 leg AC operated, Flight AC 870, YYZ?CDG |
| CP004 | PREREQUISITES | prerequisite | seed | Flight status: ARRIVED LATE | Flight status: ARRIVED LATE |
| CP005 | PREREQUISITES | prerequisite | seed | Arrival delay code: 42 (Controllable � numeric delay code) | Arrival delay code: 42 (Controllable � numeric delay code) |
| CP006 | PREREQUISITES | prerequisite | seed | Delay: 4 hours | Delay: 4 hours |
| CP007 | PREREQUISITES | prerequisite | seed | Origin: YYZ (Toronto, Canada) ? NOT EU origin | Origin: YYZ (Toronto, Canada) ? NOT EU origin |
| CP008 | PREREQUISITES | prerequisite | seed | Destination: CDG (Paris, EU) ? EU destination but carrier AC is NOT EU-based | Destination: CDG (Paris, EU) ? EU destination but carrier AC is NOT EU-based |
| CP009 | PREREQUISITES | prerequisite | seed | Regime: EU 261 does NOT apply (not EU origin + non-EU carrier arriving in EU) | Regime: EU 261 does NOT apply (not EU origin + non-EU carrier arriving in EU) |
| CP010 | PREREQUISITES | prerequisite | seed | APPR applies separately (Canadian origin) | APPR applies separately (Canadian origin) |
| CP011 | PREREQUISITES | prerequisite | seed | Result: NOT ELIGIBLE under EU 261 | Result: NOT ELIGIBLE under EU 261 |
| CP012 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP013 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP014 | START | customer | chat | Then user selects English |  |
| CP015 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP016 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP017 | START | customer | chat | And the user says "My flight from Toronto to Paris was delayed about 4 hours due to a crew issue. I'd like to check if I'm eligible for comp | My flight from Toronto to Paris was delayed about 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation under EU regulations |
| CP018 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP019 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP020 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP021 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Robert Tremblay" | Robert Tremblay |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Robert! And, what is your booking reference number? |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC108" | PNR: TC108 |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC108 |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: r***@gmail.com Phone: +1***123 |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: r***@gmail.com" | Email: r***@gmail.com |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP035 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP037 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Robert Tremblay (Adult) Is this who you'd like to include? |
| CP042 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP044 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 870 Route: Toronto (YYZ) ? Paris Charles de Gaulle (CDG) Date: June 3, 2026 Arrival Delay: 4 hours Is this the journey |
| CP045 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP050 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline ? within limitation ? PROCEED |  |
| CP051 | REGIME DETERMINATION | verdict | api | Then the system determines applicable regime: |  |
| CP052 | REGIME DETERMINATION | system | implied | And the system checks: Origin airport = YYZ (Toronto, Canada) ? NOT EU origin |  |
| CP053 | REGIME DETERMINATION | system | implied | And the system checks: Destination airport = CDG (Paris, EU) ? EU destination but NOT EU origin |  |
| CP054 | REGIME DETERMINATION | system | implied | And the system checks: Operating carrier = AC (Canadian) ? NOT EU-based carrier |  |
| CP055 | REGIME DETERMINATION | system | implied | And the system determines: EU 261 (EU Mainland) does NOT apply � EU 261 requires EU origin for flights on any carrier; for flights arriving  |  |
| CP056 | REGIME DETERMINATION | system | implied | And the system checks: Does APPR apply? ? YES (Canadian origin, AC operated) ? APPR assessed separately |  |
| CP057 | REGIME DETERMINATION | system | implied | And the system determines: Under EU 261 specifically ? NOT ELIGIBLE (not EU origin + non-EU carrier) |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC108 | ? Promised Itinerary - Flight: AC 870, Route: YYZ ? CDG, Scheduled Arrival: 08:00 (local CDG) ? Current Itinerary - Flight: AC 870, Route: YYZ ? CDG, Status: AR |
| CP061 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked | NOT ELIGIBLE RESULT (FD-05b) � EU 261 specific: |
| CP062 | FRAUD SCREENING � NOT TRIGGERED | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your flight AC 870 from Toronto (YYZ) to Paris Charles de Gaulle (CDG) was delayed by 4 hours. However, E |
| CP063 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP064 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP065 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP066 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP067 | NOTIFICATION | email | email | And a notification email is sent to r***@gmail.com |  |
| CP068 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (YYZ?CDG, delayed 4h), not eligible reason under EU 261 (not EU origin, non-EU carrie |  |
| CP069 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP070 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP071 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Robert Tremblay" with PNR "TC108" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Robert Tremblay" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC108" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 � BUT not EU origin so does not apply" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Robert Tremblay" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "r***@gmail.com" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***123" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YYZ ? CDG" with claim filed for this flight as arrived late plus 4h |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Itinerary not EU origin � YYZ is Canada, |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to not EU origin with EU 261 not applying and APPR may apply sepa |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Robert Tremblay + TC108 + YYZ?CDG + FD" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a notification email should have been sent to "r***@gmail.com" containing not eligible under EU 261 due to not EU origin and non-EU carr |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP114 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to not EU origin |  |
| CP115 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP116 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP117 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP118 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP119 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP120 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-NE-19. | DDS returns FD-EU-NE-19. |
| CP121 | EXPECTED RESULTS | verdict | api | Trip Tracer: Flight operated; Arrival delay = 4hrs; Arrival Delay Code 42 (numeric delay code � Controllable); Origin YYZ (Canada) � NOT EU  | Trip Tracer: Flight operated; Arrival delay = 4hrs; Arrival Delay Code 42 (numeric delay code � Controllable); Origin YYZ (Canada) � NOT EU ? EU 261 departure r |
| CP122 | EXPECTED RESULTS | verdict | chat | CRITICAL: To be covered by EU 261 when arriving in EU, the operating carrier must be EU-based (e.g., Air France for CDG). | CRITICAL: To be covered by EU 261 when arriving in EU, the operating carrier must be EU-based (e.g., Air France for CDG). |
| CP123 | EXPECTED RESULTS | verdict | chat | AC is Canadian ? excluded. | AC is Canadian ? excluded. |
| CP124 | EXPECTED RESULTS | verdict | chat | EU 261 = NOT APPLICABLE (route exclusion � not EU origin + non-EU carrier). | EU 261 = NOT APPLICABLE (route exclusion � not EU origin + non-EU carrier). |
| CP125 | EXPECTED RESULTS | verdict | chat | APPR applies separately (Canadian origin, AC operated). | APPR applies separately (Canadian origin, AC operated). |
| CP126 | EXPECTED RESULTS | verdict | chat | Result: NOT ELIGIBLE under EU 261, �0. | Result: NOT ELIGIBLE under EU 261, �0. |
| CP127 | EXPECTED RESULTS | verdict | chat | CyberSource: NOT triggered. | CyberSource: NOT triggered. |
| CP128 | EXPECTED RESULTS | verdict | chat | Payment: NONE. | Payment: NONE. |
| CP129 | EXPECTED RESULTS | verdict | api | DDS = FD-EU-NE-19. | DDS = FD-EU-NE-19. |
