# FD_TC_096 · CHAI-31488 — checkpoints

**Goal:** Disrupted leg operated by a Star Alliance partner (Lufthansa). AC systems have the flight timing data � scheduled and actual arrival times, delay duration � and can identify the MSL. DDS determines MSL = Lufthansa-operated leg. Since Lufthansa is a Star Alliance partner, AC does not auto-assess but instead creates a StarQuest case and forwards it to an agent for manual handling with the partner. The system has all the data; the reason for manual routing is the Star Alliance partnership, not missing data.

Methods: seed 10, chat 37, api 10, dashboard 45, implied 11, manual 9, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Disrupted leg operated by a Star Alliance partner (Lufthansa). AC systems have the flight timing data � scheduled and actual arrival times,  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Francine Dub�), 2 legs YUL?FRA?MUC | PNR: Single passenger (Francine Dub�), 2 legs YUL?FRA?MUC |
| CP003 | PREREQUISITES | prerequisite | seed | Leg 1 (YUL?FRA): AC operated, on time | Leg 1 (YUL?FRA): AC operated, on time |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 07:30 | Scheduled arrival: 07:30 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival: 07:25 | Actual arrival: 07:25 |
| CP006 | PREREQUISITES | prerequisite | seed | Leg 2 (FRA?MUC): Operated by Lufthansa (LH 471) | Leg 2 (FRA?MUC): Operated by Lufthansa (LH 471) |
| CP007 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 11:00 | Scheduled arrival: 11:00 |
| CP008 | PREREQUISITES | prerequisite | seed | Actual arrival: 15:00 (4hr delay) | Actual arrival: 15:00 (4hr delay) |
| CP009 | PREREQUISITES | prerequisite | seed | MSL: Leg 2 (LH 471) � 4hr delay is the most significant disruption | MSL: Leg 2 (LH 471) � 4hr delay is the most significant disruption |
| CP010 | PREREQUISITES | prerequisite | seed | MSL Carrier: Lufthansa (LH) � Star Alliance partner | MSL Carrier: Lufthansa (LH) � Star Alliance partner |
| CP011 | PREREQUISITES | prerequisite | seed | DDS Action: MSL identified on Star Alliance partner ? AC does not auto-assess ? StarQuest case created ? forwarded to agent for manual handl | DDS Action: MSL identified on Star Alliance partner ? AC does not auto-assess ? StarQuest case created ? forwarded to agent for manual handling |
| CP012 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP013 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP014 | START | customer | chat | Then user selects English |  |
| CP015 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP016 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP017 | START | customer | chat | And the user says "I flew from Montreal to Frankfurt on Air Canada and then from Frankfurt to Munich on Lufthansa. The Lufthansa flight was  | I flew from Montreal to Frankfurt on Air Canada and then from Frankfurt to Munich on Lufthansa. The Lufthansa flight was delayed 4 hours. Can I get compensation |
| CP018 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP019 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP020 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP021 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Francine Dub�" | Francine Dub� |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Francine! And, what is your booking reference number? |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC055" | PNR: TC055 |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC055 |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: f***@gmail.com Phone: +1***234 |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: f***@gmail.com" | Email: f***@gmail.com |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP035 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP037 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Francine Dub� (Adult) Is this who you'd like to include? |
| CP042 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP044 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Segment 1: Flight AC 870, Montreal (YUL) ? Frankfurt (FRA), June 8, 2026 � COMPLETED (AC operated) Segment 2: Flight LH 471, Fran |
| CP045 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP047 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED on time (AC), Segment 2 DELAYED +4h (Lufthansa � Star Alliance) |  |
| CP048 | MSL DETERMINATION | verdict | api | Then the system calculates MSL using available timing data: | Segment 1 (AC 870): Scheduled arrival 07:30, Actual arrival 07:25 ? No delay Segment 2 (LH 471): Scheduled arrival 11:00, Actual arrival 15:00 ? 4hr delay MSL = |
| CP049 | MSL CHECK � STAR ALLIANCE PARTNER | verdict | api | Then the system checks MSL for operating carrier on the disrupted leg |  |
| CP050 | MSL CHECK � STAR ALLIANCE PARTNER | verdict | api | And MSL returns: Segment 2 operated by Lufthansa (LH) ? Star Alliance partner |  |
| CP051 | MSL CHECK � STAR ALLIANCE PARTNER | system | implied | And the system checks: Is Lufthansa a Star Alliance partner? ? YES |  |
| CP052 | MSL CHECK � STAR ALLIANCE PARTNER | verdict | api | And the system determines: MSL on Star Alliance partner ? AC does not auto-assess ? STARQUEST CASE ? MANUAL HANDLING |  |
| CP053 | STAR ALLIANCE PARTNER RESULT | bot | chat | Then the chatbot displays: | I've reviewed your flight details and noticed that this trip was operated by our Star Alliance partner. To complete this claim, I can forward your details to an |
| CP054 | STAR ALLIANCE PARTNER RESULT | customer | chat | And the user selects "Yes" | Yes |
| CP055 | STARQUEST CASE CREATION | system | implied | Then the system creates a StarQuest case for manual agent handling |  |
| CP056 | STARQUEST CASE CREATION | system | implied | And the case is routed to the StarQuest team |  |
| CP057 | STARQUEST CASE CREATION | verdict | api | And the case contains: PNR TC055, passenger Francine Dub�, journey YUL?FRA?MUC, MSL on Lufthansa LH 471, scheduled arrival 11:00, actual arr |  |
| CP058 | STARQUEST CASE CREATION | bot | chat | Then the chatbot responds: | Thank you. Your claim has been forwarded to our team for review. You will receive an update via email once the review is complete. Please allow additional proce |
| CP059 | STARQUEST CASE CREATION | alert | chat | And an alert information is displayed: "Claim forwarded for review!" | Claim forwarded for review! |
| CP060 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP061 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP062 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP063 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Francine Dub�" with PNR "TC055" |  |
| CP064 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP065 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Forwarded � StarQuest Review" |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "StarQuest Team" |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel may be restricted as it is pending manual review |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Francine Dub�" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC055" |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Francine Dub�" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "f***@gmail.com" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***234" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: YUL ? FRA" as completed and AC operated and "Segment 2: FRA ? MUC" with claim filed and Lufthansa op |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT AUTO-ASSESSED" with reason "Star Alliance partner � forwarded t |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should NOT have been auto-evaluated as Star Alliance partner requires manual handling |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be "PENDING" for StarQuest manual review |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Francine Dub� + TC055 + FRA?MUC + FD" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it is pending manual review |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should be routed to StarQuest Team and not the regular agent queue |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case forwarded notification should have been sent |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an email should have been sent to "f***@gmail.com" confirming claim forwarded for Star Alliance partner review |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record case creation and StarQuest routing with timestamps |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the forwarded notification email |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Forwarded � StarQuest Review" pending manual review |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should NOT be in read-only mode as it is pending StarQuest team action |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP115 | PAYMENT VALIDATION | payment | chat | Given no determination was made due to Star Alliance partner operated segment |  |
| CP116 | PAYMENT VALIDATION | payment | chat | Then no automated payment flow should be triggered |  |
| CP117 | PAYMENT VALIDATION | payment | chat | And the case was created and sent to agent for manual handling |  |
| CP118 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP119 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created automatically |  |
| CP120 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP121 | PAYMENT VALIDATION | payment | manual | And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e- |  |
| CP122 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved |  |
| CP123 | EXPECTED RESULTS | verdict | api | DDS identifies MSL using available flight timing data: Segment 1 (AC 870): Scheduled arrival 07:30, Actual arrival 07:25 ? 0 delay Segment 2 | DDS identifies MSL using available flight timing data: Segment 1 (AC 870): Scheduled arrival 07:30, Actual arrival 07:25 ? 0 delay Segment 2 (LH 471): Scheduled |
