# FD_TC_206 · CHAI-31598 — checkpoints

**Goal:** Validates that when a customer's AC-sold itinerary includes a VIA Rail train segment (YOW?YUL) connecting to a flight (YUL?LHR), and the train is delayed causing the customer to miss the connecting flight, DDS correctly returns NOT ELIGIBLE. Only flight segments are evaluated for APPR/EU/ASL compensation. Train disruptions do not qualify under any regime. Goodwill (GW) may be offered at business discretion but is not automatic.

Methods: seed 10, chat 41, api 19, email 3, dashboard 43, implied 15, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates that when a customer's AC-sold itinerary includes a VIA Rail train segment (YOW?YUL) connecting to a flight (YUL?LHR), and the tra |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (�lise Beauchemin), 2-segment AC-sold itinerary: Segment 1 = VIA Rail train YOW?YUL (scheduled dep 07:00, arr 09:00),  | PNR: Single passenger (�lise Beauchemin), 2-segment AC-sold itinerary: Segment 1 = VIA Rail train YOW?YUL (scheduled dep 07:00, arr 09:00), Segment 2 = Flight A |
| CP003 | PREREQUISITES | prerequisite | seed | Train delayed 4 hours due to track maintenance (actual arr YUL 13:00) | Train delayed 4 hours due to track maintenance (actual arr YUL 13:00) |
| CP004 | PREREQUISITES | prerequisite | seed | Customer missed AC 848 | Customer missed AC 848 |
| CP005 | PREREQUISITES | prerequisite | seed | No rebooking available same day | No rebooking available same day |
| CP006 | PREREQUISITES | prerequisite | seed | Disruption on train segment only � flight AC 848 departed on time | Disruption on train segment only � flight AC 848 departed on time |
| CP007 | PREREQUISITES | prerequisite | seed | Carrier: AC-sold (train operated by VIA Rail) | Carrier: AC-sold (train operated by VIA Rail) |
| CP008 | PREREQUISITES | prerequisite | seed | 72hrs: Elapsed | 72hrs: Elapsed |
| CP009 | PREREQUISITES | prerequisite | seed | Time limit: Within 366 days | Time limit: Within 366 days |
| CP010 | PREREQUISITES | prerequisite | seed | No duplicate case | No duplicate case |
| CP011 | PREREQUISITES | prerequisite | seed | Not employee, not infant | Not employee, not infant |
| CP012 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP013 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP014 | START | customer | chat | Then user selects English |  |
| CP015 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP016 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP017 | START | customer | chat | And the user says "My VIA Rail train from Ottawa to Montreal was delayed 4 hours due to track maintenance and I missed my connecting flight  | My VIA Rail train from Ottawa to Montreal was delayed 4 hours due to track maintenance and I missed my connecting flight AC 848 to London. I want to check if I' |
| CP018 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP019 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP020 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP021 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "�lise Beauchemin" | �lise Beauchemin |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, �lise! And, what is your booking reference number? |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC_TRAIN01" | PNR: TC_TRAIN01 |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC_TRAIN01 |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: e***@gmail.com Phone: +1***789 |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: e***@gmail.com" | Email: e***@gmail.com |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "817253" | 817253 |
| CP035 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP037 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: �lise Beauchemin (Adult) Is this who you'd like to include? |
| CP042 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP044 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Segment 1: Train (VIA Rail) � Ottawa (YOW) ? Montreal (YUL) � June 8, 2026 Segment 2: Flight AC 848 � Montreal (YUL) ? London (LH |
| CP045 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments: train + flight) |  |
| CP047 | SEGMENT CHECK | system | implied | Then the chatbot identifies: Segment 1 = Train (ground transport), Segment 2 = Flight AC 848 |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg expected arrival |  |
| CP051 | 72-HOUR CHECK | system | implied | And the system calculates: Expected arrival was June 9, 2026 00:30; current date is June 17, 2026 ? >72 hours ? PROCEED |  |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP053 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption June 8, 2026; filing June 17, 2026 ? 9 days ? within 366 days ? PROCEED |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Segment 1: Train (VIA Rail) YOW ? YUL, Scheduled Dep: 07:00, Scheduled Arr: 09:00 | Segment 1: Train (VIA Rail) YOW ? YUL, Scheduled Dep: 07:00, Scheduled Arr: 09:00 |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Segment 2: Flight AC 848 YUL ? LHR, Scheduled Dep: 12:30, Scheduled Arr: 00:30+1 | Segment 2: Flight AC 848 YUL ? LHR, Scheduled Dep: 12:30, Scheduled Arr: 00:30+1 |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Segment 1: Train (VIA Rail) YOW ? YUL, Status: ARRIVED LATE, Actual Arr: 13:00, Delay: +4H 00M (track maintenance) | Segment 1: Train (VIA Rail) YOW ? YUL, Status: ARRIVED LATE, Actual Arr: 13:00, Delay: +4H 00M (track maintenance) |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Segment 2: Flight AC 848 YUL ? LHR, Status: DEPARTED ON TIME � CUSTOMER NO-SHOW (missed connection) | Segment 2: Flight AC 848 YUL ? LHR, Status: DEPARTED ON TIME � CUSTOMER NO-SHOW (missed connection) |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Disrupted Segment: Segment 1 (Train) � NOT a flight segment | Disrupted Segment: Segment 1 (Train) � NOT a flight segment |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Flight Segment (AC 848): Operated on time � no flight disruption occurred | Flight Segment (AC 848): Operated on time � no flight disruption occurred |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Rule Applied: "Train and Bus: If the customer misses their flight due to a delay on the bus/train, there is no entitlement to compensation ( | Rule Applied: "Train and Bus: If the customer misses their flight due to a delay on the bus/train, there is no entitlement to compensation (all regimes) as only |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | APPR = NOT ELIGIBLE (disruption on non-flight segment) | APPR = NOT ELIGIBLE (disruption on non-flight segment) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | EU 261 = NOT ELIGIBLE (disruption on non-flight segment) | EU 261 = NOT ELIGIBLE (disruption on non-flight segment) |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | ASL = NOT ELIGIBLE (disruption on non-flight segment) | ASL = NOT ELIGIBLE (disruption on non-flight segment) |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | GW Flag: Available at business discretion � not automatic | GW Flag: Available at business discretion � not automatic |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | MS �LISE BEAUCHEMIN / NOT ELIGIBLE / NON_FLIGHT_SEGMENT_DISRUPTION / CAD 0.00 | MS �LISE BEAUCHEMIN / NOT ELIGIBLE / NON_FLIGHT_SEGMENT_DISRUPTION / CAD 0.00 |
| CP068 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | CyberSource only runs for ELIGIBLE cases ? NOT invoked |  |
| CP069 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've checked your journey details. Your itinerary included a ground transportation (VIA Rail train) segment from Ottawa (YOW) to Montreal (YUL), which experienc |
| CP070 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP071 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP072 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Your case has been recorded. Case Reference: CASE-FD-20260617-TRAIN01." | Your case has been recorded. Case Reference: CASE-FD-20260617-TRAIN01. |
| CP073 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP074 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to e***@gmail.com |  |
| CP075 | NOTIFICATION | email | email | And the email contains: Case Reference, regulation (APPR), journey details, reason for ineligibility (non-flight segment disruption), next s |  |
| CP076 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP077 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP078 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "�lise Beauchemin" with PNR "TC_TRAIN01" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "�lise Beauchemin" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC_TRAIN01" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "�lise Beauchemin" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "e***@gmail.com" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***789" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Yes (Aeroplan #: 1234567890)" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YOW ? YUL (Train/VIA Rail) + YUL ? LHR (Flight AC 848)" with claim filed for missed connection |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility should be "NOT ELIGIBLE" with reason "Non-flight segment disruption (train)" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "�lise Beauchemin + TC_TRAIN01 + YOW?YUL?LHR + FD" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been invoked as it only runs for eligible cases |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record to the case automatically for identified and authenticated user |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case function from My Activities to get this case |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent to the customer |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP131 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to non-flight segment disruption |  |
| CP132 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP133 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP134 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP135 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP136 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP137 | EXPECTED RESULTS | verdict | api | Trip Tracer: Segment 1 = Train (VIA Rail) YOW?YUL, delayed 4hrs (track maintenance); Segment 2 = Flight AC 848 YUL?LHR, operated on time. | Trip Tracer: Segment 1 = Train (VIA Rail) YOW?YUL, delayed 4hrs (track maintenance); Segment 2 = Flight AC 848 YUL?LHR, operated on time. |
| CP138 | EXPECTED RESULTS | verdict | chat | Disruption on non-flight segment. | Disruption on non-flight segment. |
| CP139 | EXPECTED RESULTS | verdict | chat | Rule: "Only flight segments matter for compensation � bus/train disruptions excluded under all regimes." APPR = NOT ELIGIBLE; EU = NOT ELIGI | Rule: "Only flight segments matter for compensation � bus/train disruptions excluded under all regimes." APPR = NOT ELIGIBLE; EU = NOT ELIGIBLE; ASL = NOT ELIGI |
| CP140 | EXPECTED RESULTS | verdict | chat | Compensation: $0. | Compensation: $0. |
| CP141 | EXPECTED RESULTS | verdict | chat | GW: Available at business discretion. | GW: Available at business discretion. |
| CP142 | EXPECTED RESULTS | verdict | chat | CyberSource: NOT invoked. | CyberSource: NOT invoked. |
