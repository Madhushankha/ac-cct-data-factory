# FD_TC_105 · CHAI-31497 — checkpoints

**Goal:** AC involuntarily rebooked customer to an EARLIER flight. Customer arrived at 12:00 � 2 hours BEFORE the original promise of 14:00. Since the customer arrived EARLIER than promised, there is no delay (delay cannot be negative). Validates that: (1) DDS treats negative delay (early arrival) as zero, (2) An INVOL change to an earlier flight does NOT create a compensable event � arriving early is not a disruption, (3) The promise remains the original 14:00 (no VOL before the INVOL), and actual 12:00 is before that promise ? no delay. Edge case where INVOL actually benefits the customer.

Methods: seed 7, chat 39, api 18, email 3, dashboard 44, implied 15, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | AC involuntarily rebooked customer to an EARLIER flight. Customer arrived at 12:00 � 2 hours BEFORE the original promise of 14:00. Since the |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger(Adult) | PNR: single passenger(Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 424, YUL?YYZ | Journey: 1 leg AC operated, Flight AC 424, YUL?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Promise (14-day): Arrival = 14:00 (no VOL changes before the INVOL) | Promise (14-day): Arrival = 14:00 (no VOL changes before the INVOL) |
| CP005 | PREREQUISITES | prerequisite | seed | INVOL change: AC rebooked to earlier flight � new arrival 12:00 | INVOL change: AC rebooked to earlier flight � new arrival 12:00 |
| CP006 | PREREQUISITES | prerequisite | seed | Actual arrival: 12:00 (on time per INVOL rebooking � 2hrs BEFORE original promise) | Actual arrival: 12:00 (on time per INVOL rebooking � 2hrs BEFORE original promise) |
| CP007 | PREREQUISITES | prerequisite | seed | Delay calculation: 12:00 ? 14:00 = ?2hrs (arrived early) ? net delay = 0 | Delay calculation: 12:00 ? 14:00 = ?2hrs (arrived early) ? net delay = 0 |
| CP008 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic) | Regime: APPR (domestic) |
| CP009 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP010 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP011 | START | customer | chat | Then user selects English |  |
| CP012 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP013 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP014 | START | customer | chat | And the user says "Air Canada changed my flight to an earlier one. I arrived earlier than my original time. I'd like to check if I'm eligibl | Air Canada changed my flight to an earlier one. I arrived earlier than my original time. I'd like to check if I'm eligible for any compensation |
| CP015 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP016 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP017 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP018 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP021 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "V�ronique Gagnon" | V�ronique Gagnon |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, V�ronique! And, what is your booking reference number? |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC062" | PNR: TC062 |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC062 |  |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: v***@gmail.com � Phone: +1***901 |
| CP029 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: v***@gmail.com" | Email: v***@gmail.com |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP032 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP034 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP035 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP036 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP037 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP038 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � V�ronique Gagnon (Adult) Is this who you'd like to include? |
| CP039 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP040 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP041 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 506 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: May 22, 2026 � Status: ARRIVED (on time per rebooked schedule) I |
| CP042 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP046 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP047 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 22, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP048 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP049 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 22, 2026; filing June 15, 2026 ? 24 days ? within 366 days ? PROCEED |  |
| CP050 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP051 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sends to Trip Tracer UI: |  |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 506, Route: YUL ? YYZ, Scheduled Arrival: 14:00 (14-day mark � INVOL does NOT update promise when rebook is  | Promised Itinerary - Flight: AC 506, Route: YUL ? YYZ, Scheduled Arrival: 14:00 (14-day mark � INVOL does NOT update promise when rebook is to earlier flight) |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 506, Route: YUL ? YYZ, Status: ARRIVED, Actual Arrival: 12:00 | Current Itinerary - Flight: AC 506, Route: YUL ? YYZ, Status: ARRIVED, Actual Arrival: 12:00 |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | History - INVOL: AC rebooked customer to earlier flight ? arr 12:00 (earlier than promise 14:00) | History - INVOL: AC rebooked customer to earlier flight ? arr 12:00 (earlier than promise 14:00) |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Promise Rule: INVOL to earlier flight ? promise remains at 14-day mark (14:00). INVOL does not update promise. | Promise Rule: INVOL to earlier flight ? promise remains at 14-day mark (14:00). INVOL does not update promise. |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Delay = Actual (12:00) - Promise (14:00) = NEGATIVE (arrived 2h EARLY) ? treated as 0h delay | Delay = Actual (12:00) - Promise (14:00) = NEGATIVE (arrived 2h EARLY) ? treated as 0h delay |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | CRITICAL: Actual < Promise ? no compensable delay. Arriving earlier than promise is not a disruption. | CRITICAL: Actual < Promise ? no compensable delay. Arriving earlier than promise is not a disruption. |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | MS V�RONIQUE GAGNON / NOT ELIGIBLE / NO_DELAY / CAD 0.00 | MS V�RONIQUE GAGNON / NOT ELIGIBLE / NO_DELAY / CAD 0.00 |
| CP060 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP061 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your arrival in Toronto was on time. That means there's no recorded delay for this part of your trip. Based  |
| CP062 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP063 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP064 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP065 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP066 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to v***@gmail.com |  |
| CP067 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (no delay � arrived earlier than promise), regulation reference  |  |
| CP068 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP069 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP070 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "V�ronique Gagnon" with PNR "TC062" |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "V�ronique Gagnon" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC062" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "V�ronique Gagnon" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "v***@gmail.com" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***901" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "No delay � INVOL to earlier flight, actu |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to INVOL to earlier flight with promise remaining at 14-day mark  |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "V�ronique Gagnon + TC062 + YUL?YYZ + FD" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP124 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to INVOL to earlier flight with no compensable delay |  |
| CP125 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP126 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP128 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP130 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-27. | DDS returns FD-APPR-NE-27. |
| CP131 | EXPECTED RESULTS | verdict | api | Trip Tracer � Promise Calculation: No VOL before INVOL; Promise = 14:00 (14-day mark). | Trip Tracer � Promise Calculation: No VOL before INVOL; Promise = 14:00 (14-day mark). |
| CP132 | EXPECTED RESULTS | verdict | chat | Actual = 12:00. | Actual = 12:00. |
| CP133 | EXPECTED RESULTS | verdict | api | Delay = ?2hrs (arrived early) ? net delay = 0 (negative delay = no delay). | Delay = ?2hrs (arrived early) ? net delay = 0 (negative delay = no delay). |
| CP134 | EXPECTED RESULTS | verdict | chat | Compensation: $0 � customer arrived before promise. | Compensation: $0 � customer arrived before promise. |
| CP135 | EXPECTED RESULTS | verdict | chat | No disruption from customer's perspective � they arrived earlier than originally scheduled. | No disruption from customer's perspective � they arrived earlier than originally scheduled. |
| CP136 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP137 | EXPECTED RESULTS | verdict | api | Claims Dashboard: INVOL to earlier flight; Promise = 14:00; Actual = 12:00 (early); No delay; $0; DDS = FD-APPR-NE-27. | Claims Dashboard: INVOL to earlier flight; Promise = 14:00; Actual = 12:00 (early); No delay; $0; DDS = FD-APPR-NE-27. |
