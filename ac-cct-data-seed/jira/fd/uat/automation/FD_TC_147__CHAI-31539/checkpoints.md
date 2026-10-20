# FD_TC_147 · CHAI-31539 — checkpoints

**Goal:** After disruption on an EU-originating journey, customer was rerouted to a completely different destination than originally booked. DDS cannot assess EU 261 eligibility because the original itinerary no longer matches the actual journey � distance band calculation is impossible when the destination changed. Mirrors APPR new destination test (TC_071).

Methods: seed 7, chat 37, api 25, email 3, dashboard 35, implied 13, manual 8, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | After disruption on an EU-originating journey, customer was rerouted to a completely different destination than originally booked. DDS canno |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger, 2 legs AC operated LHR?YYZ?YVR | PNR: Single passenger, 2 legs AC operated LHR?YYZ?YVR |
| CP003 | PREREQUISITES | prerequisite | seed | Leg 1 (LHR?YYZ): Operated, on time | Leg 1 (LHR?YYZ): Operated, on time |
| CP004 | PREREQUISITES | prerequisite | seed | Leg 2 (YYZ?YVR): CANCELLED | Leg 2 (YYZ?YVR): CANCELLED |
| CP005 | PREREQUISITES | prerequisite | seed | Rerouting: Customer was rebooked to YEG (Edmonton) instead of original destination YVR (Vancouver) | Rerouting: Customer was rebooked to YEG (Edmonton) instead of original destination YVR (Vancouver) |
| CP006 | PREREQUISITES | prerequisite | seed | New itinerary: YYZ?YEG | New itinerary: YYZ?YEG |
| CP007 | PREREQUISITES | prerequisite | seed | Disruption code: 42 (Controllable) | Disruption code: 42 (Controllable) |
| CP008 | PREREQUISITES | prerequisite | seed | Route context: LHR = UK origin ? EU 261 applies | Route context: LHR = UK origin ? EU 261 applies |
| CP009 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP010 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP011 | START | customer | chat | Then user selects English |  |
| CP012 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP013 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP014 | START | customer | chat | And the user says "My flight from Paris to Toronto was cancelled and I was rebooked to Ottawa instead. Can I get compensation?" | My flight from Paris to Toronto was cancelled and I was rebooked to Ottawa instead. Can I get compensation? |
| CP015 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP016 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP017 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP018 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP021 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Brigitte Pelletier" | Brigitte Pelletier |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Brigitte! And, what is your booking reference number? |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC113" | PNR: TC113 |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC113 |  |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: b***@outlook.com � Phone: +33***012 |
| CP029 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: b***@outlook.com" | Email: b***@outlook.com |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP032 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP034 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP035 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP036 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP037 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP038 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Brigitte Pelletier (Adult) Is this who you'd like to include? |
| CP039 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP040 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP041 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Original: Flight AC 871, Paris Charles de Gaulle (CDG) ? Toronto (YYZ), June 10, 2026 � CANCELLED � Rebooked: Flight AC 872, Pa |
| CP042 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO ? skip GenUC-18 |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP046 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP047 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction) = 5 years ? within limitation ? PROCEED |  |
| CP048 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP049 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Is the current destination the same as the original destination? |  |
| CP050 | TRIAGE & DDS EVALUATION | verdict | api | And DDS compares: Original destination = YYZ (Toronto); Current destination = YOW (Ottawa) ? DIFFERENT DESTINATION |  |
| CP051 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Is YOW a sister city of YYZ? ? NO (Ottawa ? Toronto sister city) |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | And DDS determines: NEW DESTINATION (NEW CONTRACT) ? CANNOT ASSESS ? NO DETERMINATION |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | Original Itinerary - Flight: AC 871, Route: CDG ? YYZ, Status: CANCELLED | Original Itinerary - Flight: AC 871, Route: CDG ? YYZ, Status: CANCELLED |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 872, Route: CDG ? YOW, Status: COMPLETED (new destination) | Current Itinerary - Flight: AC 872, Route: CDG ? YOW, Status: COMPLETED (new destination) |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Original Destination: YYZ (Toronto) | Original Destination: YYZ (Toronto) |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Current Destination: YOW (Ottawa) � DIFFERENT CITY | Current Destination: YOW (Ottawa) � DIFFERENT CITY |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Sister City Check: YOW ? YYZ = NOT A VALID PAIR | Sister City Check: YOW ? YYZ = NOT A VALID PAIR |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Contract Status: Original contract VOIDED; New contract issued for CDG?YOW | Contract Status: Original contract VOIDED; New contract issued for CDG?YOW |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Regime: EU 261 (EU origin � CDG) | Regime: EU 261 (EU origin � CDG) |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | DDS: CANNOT ASSESS � NEW DESTINATION / NEW CONTRACT | DDS: CANNOT ASSESS � NEW DESTINATION / NEW CONTRACT |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Determination: NO DETERMINATION ? SENT TO AGENT | Determination: NO DETERMINATION ? SENT TO AGENT |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | MS BRIGITTE PELLETIER / NO DETERMINATION / NEW_DESTINATION / PENDING AGENT REVIEW | MS BRIGITTE PELLETIER / NO DETERMINATION / NEW_DESTINATION / PENDING AGENT REVIEW |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | NO FRAUD SCREENING (not triggered for No Determination) | NO FRAUD SCREENING (not triggered for No Determination) |
| CP065 | NO DETERMINATION RESULT | bot | chat | Then the chatbot displays: | I've reviewed your flight details. Your original flight from Paris Charles de Gaulle (CDG) to Toronto (YYZ) was cancelled and you were rebooked to a different d |
| CP066 | NO DETERMINATION RESULT | customer | chat | And the user selects "Yes" | Yes |
| CP067 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been forwarded to our team for review. You will receive an update via email once the r | Thank you. Your claim has been forwarded to our team for review. You will receive an update via email once the review is complete. |
| CP068 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim forwarded for review!" | Claim forwarded for review! |
| CP069 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP070 | CASE CREATION (GLOB-09) | system | implied | And the case is routed to the manual review team |  |
| CP071 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP072 | NOTIFICATION | email | email | And a No Determination notification email is sent to b***@outlook.com |  |
| CP073 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (original CDG?YYZ cancelled, rebooked CDG?YOW), reason for manual review (new destina |  |
| CP074 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP075 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP076 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Brigitte Pelletier" with PNR "TC113" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Pending Agent Review" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "Manual Review Team" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should be greyed out or not applicable as it cannot assess new destination |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Brigitte Pelletier" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC113" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (EU origin � CDG)" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Brigitte Pelletier" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "b***@outlook.com" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+33***012" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the original journey should show "CDG ? YYZ" as cancelled |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the rebooked journey should show "CDG ? YOW" as completed with new destination |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Sister City Check should show YOW and YYZ as NOT A VALID PAIR |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "New destination / new contract � DDS |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should show DDS ran automatically but returned CANNOT ASSESS due to new destination |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the determination should be "NO DETERMINATION" sent to agent |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Brigitte Pelletier + TC113 + CDG?YYZ + FD" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it is No Determination |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should be routed to manual review team queue |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should pull the case for manual review |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a No Determination notification email should have been sent to "b***@outlook.com" containing Case Reference and original CDG to YYZ canc |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Current Status should be "Pending Agent Review" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should NOT be in read-only mode as the agent can determine outcome |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP118 | PAYMENT VALIDATION | payment | chat | Given no determination was made due to new destination |  |
| CP119 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP120 | PAYMENT VALIDATION | payment | chat | And the case was created and sent to agent for manual handling |  |
| CP121 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP122 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP123 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP124 | PAYMENT VALIDATION | payment | manual | And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e- |  |
| CP125 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved |  |
| CP126 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-ND-03. | DDS returns FD-EU-ND-03. |
| CP127 | EXPECTED RESULTS | verdict | api | Trip Tracer: Leg 1 = Operated; Leg 2 = CANCELLED; MSL = Leg 2; Original destination = YVR; Actual destination = YEG (different); Cancellatio | Trip Tracer: Leg 1 = Operated; Leg 2 = CANCELLED; MSL = Leg 2; Original destination = YVR; Actual destination = YEG (different); Cancellation Code = 42; Control |
| CP128 | EXPECTED RESULTS | verdict | api | CRITICAL: Destination changed from YVR to YEG � DDS cannot calculate delay against original promise (different endpoints). | CRITICAL: Destination changed from YVR to YEG � DDS cannot calculate delay against original promise (different endpoints). |
| CP129 | EXPECTED RESULTS | verdict | api | Claims Dashboard: No Determination; Reason = Destination changed post-disruption (YVR ? YEG); EU 261; Routed to manual handling; DDS = FD-EU | Claims Dashboard: No Determination; Reason = Destination changed post-disruption (YVR ? YEG); EU 261; Routed to manual handling; DDS = FD-EU-ND-03. |
