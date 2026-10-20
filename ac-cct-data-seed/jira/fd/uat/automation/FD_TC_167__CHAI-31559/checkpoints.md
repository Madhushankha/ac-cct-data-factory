# FD_TC_167 · CHAI-31559 — checkpoints

**Goal:** Israel-route flight to a NEW destination that AC has recently added. The new destination/contract is not yet fully configured in the DDS rules engine � route mappings, distance bands, or regime applicability rules may be incomplete. DDS cannot make a determination because the route configuration is missing or partial. Case routed for manual handling until the new destination is fully onboarded in the system.

Methods: seed 4, chat 39, api 27, email 3, dashboard 38, implied 13, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Israel-route flight to a NEW destination that AC has recently added. The new destination/contract is not yet fully configured in the DDS rul |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger | PNR: Single passenger |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: Israel origin to a new destination recently added to AC's network | Journey: Israel origin to a new destination recently added to AC's network |
| CP004 | PREREQUISITES | prerequisite | seed | Route configuration: Incomplete or missing in DDS rules engine (new contract not fully onboarded) | Route configuration: Incomplete or missing in DDS rules engine (new contract not fully onboarded) |
| CP005 | PREREQUISITES | prerequisite | seed | Regime: ASL applicable (Israel route) but DDS cannot fully assess due to missing route config | Regime: ASL applicable (Israel route) but DDS cannot fully assess due to missing route config |
| CP006 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP007 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP008 | START | customer | chat | Then user selects English |  |
| CP009 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP010 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP011 | START | customer | chat | And the user says "My flight from Tel Aviv to Toronto was cancelled and I was rebooked to Ottawa instead. Can I get compensation?" | My flight from Tel Aviv to Toronto was cancelled and I was rebooked to Ottawa instead. Can I get compensation? |
| CP012 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP013 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP014 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP015 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP017 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP018 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Omri Tal" | Omri Tal |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Omri! And, what is your booking reference number? |
| CP020 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC141" | PNR: TC141 |
| CP021 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC141 |  |
| CP022 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP025 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: o***@gmail.com � Phone: +972***678 |
| CP026 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: o***@gmail.com" | Email: o***@gmail.com |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP028 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP029 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP031 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP032 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP033 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP034 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP035 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Omri Tal (Adult) Is this who you'd like to include? |
| CP036 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP037 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP038 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Original: Flight AC 084, Tel Aviv Ben Gurion (TLV) ? Toronto (YYZ), June 1, 2026 � CANCELLED � Rebooked: Flight AC 083, Tel Avi |
| CP039 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP040 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO ? skip GenUC-18 |  |
| CP041 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP042 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP043 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP044 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for ASL (Israel) = 7 years ? within limitation ? PROCEED |  |
| CP045 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP046 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Is the current destination the same as the original destination? |  |
| CP047 | TRIAGE & DDS EVALUATION | verdict | api | And DDS compares: Original destination = YYZ (Toronto); Current destination = YOW (Ottawa) ? DIFFERENT DESTINATION |  |
| CP048 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Is YOW a sister city of YYZ? ? NO (Ottawa ? Toronto sister city) |  |
| CP049 | TRIAGE & DDS EVALUATION | verdict | api | And DDS determines: NEW DESTINATION (NEW CONTRACT) ? CANNOT ASSESS ? NO DETERMINATION |  |
| CP050 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | Original Itinerary - Flight: AC 084, Route: TLV ? YYZ, Status: CANCELLED | Original Itinerary - Flight: AC 084, Route: TLV ? YYZ, Status: CANCELLED |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 083, Route: TLV ? YOW, Status: COMPLETED (new destination) | Current Itinerary - Flight: AC 083, Route: TLV ? YOW, Status: COMPLETED (new destination) |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | Original Destination: YYZ (Toronto) | Original Destination: YYZ (Toronto) |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | Current Destination: YOW (Ottawa) � DIFFERENT CITY | Current Destination: YOW (Ottawa) � DIFFERENT CITY |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Sister City Check: YOW ? YYZ = NOT A VALID PAIR | Sister City Check: YOW ? YYZ = NOT A VALID PAIR |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Contract Status: Original contract VOIDED; New contract issued for TLV?YOW | Contract Status: Original contract VOIDED; New contract issued for TLV?YOW |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Regime: ASL (Israel origin � TLV) | Regime: ASL (Israel origin � TLV) |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | DDS: CANNOT ASSESS � NEW DESTINATION / NEW CONTRACT | DDS: CANNOT ASSESS � NEW DESTINATION / NEW CONTRACT |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Determination: NO DETERMINATION ? SENT TO AGENT | Determination: NO DETERMINATION ? SENT TO AGENT |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | MR OMRI TAL / NO DETERMINATION / NEW_DESTINATION / PENDING AGENT REVIEW | MR OMRI TAL / NO DETERMINATION / NEW_DESTINATION / PENDING AGENT REVIEW |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | NO FRAUD SCREENING (not triggered for No Determination) | NO FRAUD SCREENING (not triggered for No Determination) |
| CP062 | NO DETERMINATION RESULT | bot | chat | Then the chatbot displays: | I've reviewed your flight details. Your original flight from Tel Aviv Ben Gurion (TLV) to Toronto (YYZ) was cancelled and you were rebooked to a different desti |
| CP063 | NO DETERMINATION RESULT | customer | chat | And the user selects "Yes" | Yes |
| CP064 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been forwarded to our team for review. You will receive an update via email once the r | Thank you. Your claim has been forwarded to our team for review. You will receive an update via email once the review is complete. |
| CP065 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim forwarded for review!" | Claim forwarded for review! |
| CP066 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP067 | CASE CREATION (GLOB-09) | system | implied | And the case is routed to the manual review team |  |
| CP068 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP069 | NOTIFICATION | email | email | And a No Determination notification email is sent to o***@gmail.com |  |
| CP070 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (original TLV?YYZ cancelled, rebooked TLV?YOW), reason for manual review (new destina |  |
| CP071 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP072 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP073 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Omri Tal" with PNR "TC141" |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Pending Agent Review" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "Manual Review Team" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should be greyed out or not applicable as it cannot assess new destination |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Omri Tal" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC141" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL (Israel origin � TLV)" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Omri Tal" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "o***@gmail.com" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+972***678" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the original journey should show "TLV ? YYZ" as cancelled |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the rebooked journey should show "TLV ? YOW" as completed with new destination |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Sister City Check should show YOW and YYZ as NOT A VALID PAIR |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "New destination / new contract � DDS |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should show DDS ran automatically but returned CANNOT ASSESS due to new destination |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the determination should be "NO DETERMINATION" sent to agent |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Omri Tal + TC141 + TLV?YYZ + FD" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it is No Determination |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should be routed to manual review team queue |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should pull the case for manual review |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a No Determination notification email should have been sent to "o***@gmail.com" containing Case Reference and original TLV to YYZ cancel |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record case creation and manual review routing and new destination flag |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the No Determination notification |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Current Status should be "Pending Agent Review" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should NOT be in read-only mode as the agent can determine outcome |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP120 | PAYMENT VALIDATION | payment | chat | Given no determination was made due to new destination |  |
| CP121 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP122 | PAYMENT VALIDATION | payment | chat | And the case was created and sent to agent for manual handling |  |
| CP123 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP124 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP125 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP126 | PAYMENT VALIDATION | payment | manual | And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e- |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved |  |
| CP128 | EXPECTED RESULTS | verdict | api | DDS returns FD-ASL-ND-03. | DDS returns FD-ASL-ND-03. |
| CP129 | EXPECTED RESULTS | verdict | api | Trip Tracer: Flight data may be available but DDS route configuration for the new destination is incomplete. | Trip Tracer: Flight data may be available but DDS route configuration for the new destination is incomplete. |
| CP130 | EXPECTED RESULTS | verdict | api | No Determination: DDS cannot assess because the new destination's rules (distance bands, regime mappings, compensation tiers) are not yet co | No Determination: DDS cannot assess because the new destination's rules (distance bands, regime mappings, compensation tiers) are not yet configured. |
| CP131 | EXPECTED RESULTS | verdict | api | Case Routing: Manual handling � agent must assess using the new contract terms manually until DDS is updated. | Case Routing: Manual handling � agent must assess using the new contract terms manually until DDS is updated. |
| CP132 | EXPECTED RESULTS | verdict | chat | Compensation: NOT CALCULATED. | Compensation: NOT CALCULATED. |
| CP133 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP134 | EXPECTED RESULTS | verdict | api | Regime Assessment: ASL = ND-03 (New Destination, config incomplete). | Regime Assessment: ASL = ND-03 (New Destination, config incomplete). |
| CP135 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Status = No Determination; Reason = New destination (contract not configured in DDS); Agent Action = "Assess manually usin | Claims Dashboard: Status = No Determination; Reason = New destination (contract not configured in DDS); Agent Action = "Assess manually using new contract terms |
