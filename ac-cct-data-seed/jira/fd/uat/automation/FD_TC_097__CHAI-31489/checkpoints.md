# FD_TC_097 · CHAI-31489 — checkpoints

**Goal:** After disruption, customer was rerouted to a completely different destination than originally booked. DDS cannot assess eligibility because the original itinerary no longer matches the actual journey � the promise itinerary and actual itinerary are for different destinations. System must flag this for manual handling since the automated regime/delay logic doesn't apply when the destination itself changed.

Methods: seed 7, chat 38, api 25, email 3, dashboard 45, implied 15, manual 9, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | After disruption, customer was rerouted to a completely different destination than originally booked. DDS cannot assess eligibility because  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger, 2 legs AC domestic YUL?YYZ?YVR | PNR: Single passenger, 2 legs AC domestic YUL?YYZ?YVR |
| CP003 | PREREQUISITES | prerequisite | seed | Leg 1 (YUL?YYZ): Operated, on time | Leg 1 (YUL?YYZ): Operated, on time |
| CP004 | PREREQUISITES | prerequisite | seed | Leg 2 (YYZ?YVR): CANCELLED | Leg 2 (YYZ?YVR): CANCELLED |
| CP005 | PREREQUISITES | prerequisite | seed | Rerouting: Customer was rebooked to YEG (Edmonton) instead of original destination YVR (Vancouver) | Rerouting: Customer was rebooked to YEG (Edmonton) instead of original destination YVR (Vancouver) |
| CP006 | PREREQUISITES | prerequisite | seed | New itinerary: YYZ?YEG | New itinerary: YYZ?YEG |
| CP007 | PREREQUISITES | prerequisite | seed | Cancellation code: CREW (Controllable) | Cancellation code: CREW (Controllable) |
| CP008 | PREREQUISITES | prerequisite | seed | Customer claim: "I was supposed to go to Vancouver but they sent me to Edmonton." | Customer claim: "I was supposed to go to Vancouver but they sent me to Edmonton." |
| CP009 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP010 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP011 | START | customer | chat | Then user selects English |  |
| CP012 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP013 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP014 | START | customer | chat | And the user says "My flight from Montreal to Toronto was cancelled and I was rebooked to Ottawa instead. Can I get compensation?" | My flight from Montreal to Toronto was cancelled and I was rebooked to Ottawa instead. Can I get compensation? |
| CP015 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP016 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP017 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP018 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP021 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Laurent Mercier" | Laurent Mercier |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Laurent! And, what is your booking reference number? |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC056" | PNR: TC056 |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC056 |  |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: l***@outlook.com � Phone: +1***345 |
| CP029 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: l***@outlook.com" | Email: l***@outlook.com |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP032 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP034 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP035 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP036 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP037 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP038 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Laurent Mercier (Adult) Is this who you'd like to include? |
| CP039 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP040 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP041 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Original: Flight AC 499, Montreal (YUL) ? Toronto (YYZ), June 9, 2026 � CANCELLED � Rebooked: Flight AC 500, Montreal (YUL) ? O |
| CP042 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO ? skip GenUC-18 |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP046 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP047 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was June 9, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP048 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP049 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption June 9, 2026; filing June 15, 2026 ? 6 days ? within 366 days ? PROCEED |  |
| CP050 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP051 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Is the current destination the same as the original destination? |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | And DDS compares: Original destination = YYZ (Toronto); Current destination = YOW (Ottawa) ? DIFFERENT DESTINATION |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks: Is YOW a sister city of YYZ? ? NO (YOW is Ottawa, not a sister city of Toronto) |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | And DDS determines: NEW DESTINATION (NEW CONTRACT) ? CANNOT ASSESS ? NO DETERMINATION |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Original Itinerary - Flight: AC 499, Route: YUL ? YYZ, Status: CANCELLED | Original Itinerary - Flight: AC 499, Route: YUL ? YYZ, Status: CANCELLED |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 500, Route: YUL ? YOW, Status: COMPLETED (new destination) | Current Itinerary - Flight: AC 500, Route: YUL ? YOW, Status: COMPLETED (new destination) |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Original Destination: YYZ (Toronto) | Original Destination: YYZ (Toronto) |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Current Destination: YOW (Ottawa) � DIFFERENT CITY | Current Destination: YOW (Ottawa) � DIFFERENT CITY |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Sister City Check: YOW ? YYZ = NOT A VALID PAIR (Ottawa ? Toronto sister city) | Sister City Check: YOW ? YYZ = NOT A VALID PAIR (Ottawa ? Toronto sister city) |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Contract Status: Original contract VOIDED; New contract issued for YUL?YOW | Contract Status: Original contract VOIDED; New contract issued for YUL?YOW |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | DDS: CANNOT ASSESS � NEW DESTINATION / NEW CONTRACT | DDS: CANNOT ASSESS � NEW DESTINATION / NEW CONTRACT |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Determination: NO DETERMINATION ? SENT TO AGENT | Determination: NO DETERMINATION ? SENT TO AGENT |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | MR LAURENT MERCIER / NO DETERMINATION / NEW_DESTINATION / PENDING AGENT REVIEW | MR LAURENT MERCIER / NO DETERMINATION / NEW_DESTINATION / PENDING AGENT REVIEW |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | NO FRAUD SCREENING (not triggered for No Determination) | NO FRAUD SCREENING (not triggered for No Determination) |
| CP067 | NO DETERMINATION RESULT | bot | chat | Then the chatbot displays: | I've reviewed your flight details. Your original flight from Montreal (YUL) to Toronto (YYZ) was cancelled and you were rebooked to a different destination, Ott |
| CP068 | NO DETERMINATION RESULT | customer | chat | And the user selects "Yes" | Yes |
| CP069 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been forwarded to our team for review. You will receive an update via email once the r | Thank you. Your claim has been forwarded to our team for review. You will receive an update via email once the review is complete. |
| CP070 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim forwarded for review!" | Claim forwarded for review! |
| CP071 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP072 | CASE CREATION (GLOB-09) | system | implied | And the case is routed to the manual review team |  |
| CP073 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP074 | NOTIFICATION | email | email | And a No Determination notification email is sent to l***@outlook.com |  |
| CP075 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (original YUL?YYZ cancelled, rebooked YUL?YOW), reason for manual review (new destina |  |
| CP076 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP077 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP078 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Laurent Mercier" with PNR "TC056" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Forwarded � Manual Review" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "Manual Review Team" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel may be restricted as it is pending manual review |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Laurent Mercier" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC056" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Laurent Mercier" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "l***@outlook.com" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***345" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Original: YUL ? YYZ" as cancelled and "Rebooked: YUL ? YOW" as completed with new destination |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "New destination / new contract � can |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run but returned "NO DETERMINATION" due to destination mismatch YYZ not equal to YOW and not a sister city pair |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be "PENDING AGENT REVIEW" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Laurent Mercier + TC056 + YUL?YYZ + FD" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it is pending manual review |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should be routed to Manual Review Team |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a No Determination notification email should have been sent to "l***@outlook.com" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email should contain the Case Reference and flight details showing original YUL to YYZ cancelled and rebooked YUL to YOW and reason  |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record case creation and No Determination routing with timestamps |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the No Determination notification email |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Forwarded � Manual Review" pending agent review |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should NOT be in read-only mode as it is pending manual review team action |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP131 | PAYMENT VALIDATION | payment | chat | Given no determination was made due to new destination mismatch |  |
| CP132 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP133 | PAYMENT VALIDATION | payment | chat | And the case was created and sent to agent for manual handling |  |
| CP134 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP135 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP136 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP137 | PAYMENT VALIDATION | payment | manual | And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e- |  |
| CP138 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved |  |
| CP139 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-ND-03. | DDS returns FD-APPR-ND-03. |
| CP140 | EXPECTED RESULTS | verdict | api | Trip Tracer: Leg 1 = Operated; Leg 2 = CANCELLED; MSL = Leg 2; Original destination = YVR; Actual destination = YEG (different); Cancellatio | Trip Tracer: Leg 1 = Operated; Leg 2 = CANCELLED; MSL = Leg 2; Original destination = YVR; Actual destination = YEG (different); Cancellation Code = 42; Control |
| CP141 | EXPECTED RESULTS | verdict | api | CRITICAL: Destination changed from YVR to YEG � DDS cannot calculate delay against the original promise because the endpoints are different. | CRITICAL: Destination changed from YVR to YEG � DDS cannot calculate delay against the original promise because the endpoints are different. |
| CP142 | EXPECTED RESULTS | verdict | chat | Automated delay = meaningless (comparing arrival at two different cities). | Automated delay = meaningless (comparing arrival at two different cities). |
| CP143 | EXPECTED RESULTS | verdict | api | Claims Dashboard: No Determination; Reason = Destination changed post-disruption (YVR ? YEG); Routed to manual handling; Agent must assess w | Claims Dashboard: No Determination; Reason = Destination changed post-disruption (YVR ? YEG); Routed to manual handling; Agent must assess whether new destinati |
