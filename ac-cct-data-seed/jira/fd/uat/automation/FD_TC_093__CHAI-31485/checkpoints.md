# FD_TC_093 · CHAI-31485 — checkpoints

**Goal:** Flight delayed 5 hours due to severe weather (Code 71 � snowstorm). Uncontrollable under APPR. Despite a significant delay that would normally qualify for Tier 1 ($400 per pax) if controllable, the uncontrollable weather classification blocks eligibility for all passengers on the booking. Claimant (Philippe Tremblay) has a Basic Aeroplan account linked to the booking. Validates that: (1) DDS correctly classifies Code 71 as Uncontrollable and returns NE-28 regardless of delay duration, (2) NOT ELIGIBLE result applies to all selected passengers on a multi-pax booking, (3) No payment flow is triggered even when an Aeroplan account is linked, (4) AC Wallet is NOT offered for not eligible cases regardless of Aeroplan status.

Methods: seed 12, chat 41, api 23, email 3, dashboard 45, implied 19, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Flight delayed 5 hours due to severe weather (Code 71 � snowstorm). Uncontrollable under APPR. Despite a significant delay that would normal |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC052 � 2 passengers: Philippe Tremblay (Adult, claimant) and Sophie Tremblay (Adult) | PNR: TC052 � 2 passengers: Philippe Tremblay (Adult, claimant) and Sophie Tremblay (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 365, YYZ?YVR (domestic) | Journey: 1 leg AC operated, Flight AC 365, YYZ?YVR (domestic) |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 14:00 | Scheduled arrival: 14:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival: 19:00 (5hr delay) | Actual arrival: 19:00 (5hr delay) |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival delay code: 71 (Weather � snowstorm, available, no fallback) | Arrival delay code: 71 (Weather � snowstorm, available, no fallback) |
| CP007 | PREREQUISITES | prerequisite | seed | Delay: 5hrs (300 min � would be Tier 1 per pax if controllable) | Delay: 5hrs (300 min � would be Tier 1 per pax if controllable) |
| CP008 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic) | Regime: APPR (domestic) |
| CP009 | PREREQUISITES | prerequisite | seed | Booking changes: None | Booking changes: None |
| CP010 | PREREQUISITES | prerequisite | seed | Timing: >72hrs elapsed | Timing: >72hrs elapsed |
| CP011 | PREREQUISITES | prerequisite | seed | Filing: Within limitation | Filing: Within limitation |
| CP012 | PREREQUISITES | prerequisite | seed | Aeroplan: Philippe Tremblay � linked (Aeroplan #: 9876543210), Basic Member, account in good standing | Aeroplan: Philippe Tremblay � linked (Aeroplan #: 9876543210), Basic Member, account in good standing |
| CP013 | PREREQUISITES | prerequisite | seed | Sophie Tremblay � no Aeroplan linked | Sophie Tremblay � no Aeroplan linked |
| CP014 | PREREQUISITES | prerequisite | implied | CyberSource: NOT invoked (not eligible case) | CyberSource: NOT invoked (not eligible case) |
| CP015 | PREREQUISITES | prerequisite | implied | RDS: No flags | RDS: No flags |
| CP016 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP017 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP018 | START | customer | chat | Then user selects English |  |
| CP019 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP020 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP021 | START | customer | chat | And the user says "My flight was delayed about 5 hours due to bad weather, I'd like to check if my family and I are eligible for compensatio | My flight was delayed about 5 hours due to bad weather, I'd like to check if my family and I are eligible for compensation |
| CP022 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP023 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP024 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP025 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Philippe Tremblay" | Philippe Tremblay |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Philippe! And, what is your booking reference number? |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC052" | PNR: TC052 |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC052 |  |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: p***@gmail.com � Phone: +1***901 |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: p***@gmail.com" | Email: p***@gmail.com |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP039 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP041 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP042 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP043 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP044 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP045 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 2 passengers on this booking: � Philippe Tremblay (Adult - Aeroplan Member) � Sophie Tremblay (Adult) Who would you like to include in your claim? |
| CP046 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Both passengers" | Both passengers |
| CP047 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 2 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP048 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 365 � Route: Toronto (YYZ) ? Vancouver (YVR) � Date: June 5, 2026 � Arrival Delay: 5 hours Is this the journey you'd |
| CP049 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP050 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP052 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for Philippe Tremblay + TC052 + YYZ?YVR + FD |  |
| CP053 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for Sophie Tremblay + TC052 + YYZ?YVR + FD |  |
| CP054 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP055 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was June 5, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP056 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP057 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption June 5, 2026; filing June 15, 2026 ? 10 days ? within 366 days ? PROCEED |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 365, Route: YYZ ? YVR, Scheduled Arrival: 14:00 | Promised Itinerary - Flight: AC 365, Route: YYZ ? YVR, Scheduled Arrival: 14:00 |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 365, Route: YYZ ? YVR, Status: ARRIVED LATE, Scheduled Arrival: 14:00 ? Actual: 19:00, Delay: +5H 00M | Current Itinerary - Flight: AC 365, Route: YYZ ? YVR, Status: ARRIVED LATE, Scheduled Arrival: 14:00 ? Actual: 19:00, Delay: +5H 00M |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 365 � YYZ ? YVR � 71 | MSL FLIGHT: AC 365 � YYZ ? YVR � 71 |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to severe weather (snowstorm)" | "Delayed due to severe weather (snowstorm)" |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +5H 00M � UNCONTROLLABLE | Delay: +5H 00M � UNCONTROLLABLE |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | APPR Gate 8: Delay 5h ? 3h ? PASSES threshold | APPR Gate 8: Delay 5h ? 3h ? PASSES threshold |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | APPR Gate 9: Code 71 = Uncontrollable ? NOT ELIGIBLE | APPR Gate 9: Code 71 = Uncontrollable ? NOT ELIGIBLE |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE | Fallback: FALSE |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | MR PHILIPPE TREMBLAY / NOT ELIGIBLE / UNCONTROLLABLE / CAD 0.00 | MR PHILIPPE TREMBLAY / NOT ELIGIBLE / UNCONTROLLABLE / CAD 0.00 |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | MS SOPHIE TREMBLAY / NOT ELIGIBLE / UNCONTROLLABLE / CAD 0.00 | MS SOPHIE TREMBLAY / NOT ELIGIBLE / UNCONTROLLABLE / CAD 0.00 |
| CP071 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP072 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE for all passengers ? CyberSource NOT invoked |  |
| CP073 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight for all passengers on your booking. I understand your departure from Toronto was delayed by 5 hours. However, you are n |
| CP074 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP075 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP076 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically for both passengers |  |
| CP077 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP078 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to p***@gmail.com |  |
| CP079 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (AC 365 YYZ?YVR), not eligible reason (uncontrollable � severe weather, Code 71), all |  |
| CP080 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP081 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP082 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Philippe Tremblay" with PNR "TC052" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Philippe Tremblay" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC052" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Philippe Tremblay" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "p***@gmail.com" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***901" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "9876543210" linked and in good standing (Basic Member) |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be "Basic / Member" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the second passenger "Sophie Tremblay" should appear in the passenger panel as "Adult" with no Aeroplan linked |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YYZ ? YVR" with claim filed for both passengers |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" for both Philippe Tremblay and Sophie Tremblay with r |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" for all passengers � delay 5h passes Gate 8 threshold but Code 71 is  |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Philippe Tremblay + TC052 + YYZ?YVR + FD" and "Sophie Tremblay +  |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" for both passengers |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP137 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to uncontrollable weather Code 71 for all 2 passengers |  |
| CP138 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered for any passenger |  |
| CP139 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP140 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created for Philippe Tremblay or Sophie Tremblay |  |
| CP141 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP142 | PAYMENT VALIDATION | payment | chat | And AC Wallet should NOT have been offered to Philippe Tremblay despite having a linked Basic Aeroplan account (9876543210) � AC Wallet is o |  |
| CP143 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" for all passengers with no compensation record and no payout section |  |
| CP144 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-28 for all passengers. | DDS returns FD-APPR-NE-28 for all passengers. |
| CP145 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 14:00; Actual = 19:00; Delay = 5hrs; MSL = Leg 1 (AC 365 YYZ?YVR); Code 71 (Weather � snowstorm); Uncontrollable; Fal | Trip Tracer: Promise = 14:00; Actual = 19:00; Delay = 5hrs; MSL = Leg 1 (AC 365 YYZ?YVR); Code 71 (Weather � snowstorm); Uncontrollable; Fallback = FALSE; APPR. |
| CP146 | EXPECTED RESULTS | verdict | chat | Passengers: Philippe Tremblay (Basic Aeroplan 9876543210) � NOT ELIGIBLE; Sophie Tremblay (no Aeroplan) � NOT ELIGIBLE. | Passengers: Philippe Tremblay (Basic Aeroplan 9876543210) � NOT ELIGIBLE; Sophie Tremblay (no Aeroplan) � NOT ELIGIBLE. |
| CP147 | EXPECTED RESULTS | verdict | api | CRITICAL: 5hr delay meets Tier 1 threshold (?3hrs) BUT Code 71 = Uncontrollable ? $0 for all passengers. | CRITICAL: 5hr delay meets Tier 1 threshold (?3hrs) BUT Code 71 = Uncontrollable ? $0 for all passengers. |
| CP148 | EXPECTED RESULTS | verdict | api | Delay duration is irrelevant when cause is uncontrollable. | Delay duration is irrelevant when cause is uncontrollable. |
| CP149 | EXPECTED RESULTS | verdict | chat | AC Wallet NOT offered despite Aeroplan linkage � no compensation payable. | AC Wallet NOT offered despite Aeroplan linkage � no compensation payable. |
| CP150 | EXPECTED RESULTS | verdict | chat | Compensation: $0 per passenger. | Compensation: $0 per passenger. |
| CP151 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP152 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
| CP153 | EXPECTED RESULTS | verdict | api | Regime Assessment: APPR = NE-28; EU = N/A; ASL = N/A. | Regime Assessment: APPR = NE-28; EU = N/A; ASL = N/A. |
| CP154 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Code 71 (Weather, Uncontrollable); Delay = 5hrs (would be Tier 1 per pax if controllable); $0 for all; DDS = FD-APPR-NE-28 | Claims Dashboard: Code 71 (Weather, Uncontrollable); Delay = 5hrs (would be Tier 1 per pax if controllable); $0 for all; DDS = FD-APPR-NE-28.Case Header: |
