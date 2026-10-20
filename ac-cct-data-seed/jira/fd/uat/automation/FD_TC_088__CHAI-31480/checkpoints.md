# FD_TC_088 · CHAI-31480 — checkpoints

**Goal:** Two-leg journey, Leg 2 cancelled (TECH). Customer stranded at midpoint. Re-routing delay was only 1.5 hours � below threshold. Completes the No Travel Below Threshold matrix .

Methods: seed 8, chat 36, api 24, email 3, dashboard 44, implied 18, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Two-leg journey, Leg 2 cancelled (TECH). Customer stranded at midpoint. Re-routing delay was only 1.5 hours � below threshold. Completes the |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger, 2 legs AC domestic YUL?YYZ?YVR | PNR: Single passenger, 2 legs AC domestic YUL?YYZ?YVR |
| CP003 | PREREQUISITES | prerequisite | seed | Leg 1: Operated, on time | Leg 1: Operated, on time |
| CP004 | PREREQUISITES | prerequisite | seed | Leg 2 (YYZ?YVR): CANCELLED | Leg 2 (YYZ?YVR): CANCELLED |
| CP005 | PREREQUISITES | prerequisite | seed | Cancellation code: TECH(Controllable) | Cancellation code: TECH(Controllable) |
| CP006 | PREREQUISITES | prerequisite | seed | Original Leg 2 scheduled arrival at YVR: 19:00 | Original Leg 2 scheduled arrival at YVR: 19:00 |
| CP007 | PREREQUISITES | prerequisite | seed | Next available rebooking arrival: 20:30 (1.5hr delay � below 3hr threshold) | Next available rebooking arrival: 20:30 (1.5hr delay � below 3hr threshold) |
| CP008 | PREREQUISITES | prerequisite | seed | Customer action: Stranded at YYZ | Customer action: Stranded at YYZ |
| CP009 | PREREQUISITES | prerequisite | seed | No Travel status: Incomplete | No Travel status: Incomplete |
| CP010 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP011 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP012 | START | customer | chat | Then user selects English |  |
| CP013 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP014 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP015 | START | customer | chat | And the user says "I flew from Montreal to Toronto but my connecting flight from Toronto to Vancouver was cancelled. They offered me another | I flew from Montreal to Toronto but my connecting flight from Toronto to Vancouver was cancelled. They offered me another flight but I decided not to take it. C |
| CP016 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP017 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP018 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP019 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP022 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Luc Bergeron" | Luc Bergeron |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Luc! And, what is your booking reference number? |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC048" | PNR: TC048 |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC048 |  |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: l***@gmail.com � Phone: +1***345 |
| CP030 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: l***@gmail.com" | Email: l***@gmail.com |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP033 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP035 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP036 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP037 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP038 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP039 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Luc Bergeron (Adult) Is this who you'd like to include? |
| CP040 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP041 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP042 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Segment 1: Flight AC 484, Montreal (YUL) ? Toronto (YYZ), June 5, 2026 � COMPLETED � Segment 2: Flight AC 485, Toronto (YYZ) ?  |
| CP043 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP045 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 CANCELLED |  |
| CP046 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot determines: Claim applies to Segment 2 (AC 485 YYZ?YVR � CANCELLED) |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure of cancelled segment |  |
| CP050 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure was June 5, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption June 5, 2026; filing June 15, 2026 ? 10 days ? within 366 days ? PROCEED |  |
| CP053 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Segment 1: Flight: AC 484, Route: YUL ? YYZ, Status: COMPLETED | Segment 1: Flight: AC 484, Route: YUL ? YYZ, Status: COMPLETED |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Segment 2: Flight: AC 485, Route: YYZ ? YVR, Status: CANCELLED (claim filed) | Segment 2: Flight: AC 485, Route: YYZ ? YVR, Status: CANCELLED (claim filed) |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Alternate Offered: Flight AC 486, YYZ ? YVR, Departure: 16:00, Arrival: 19:00 (2h after original arrival of 17:00) | Alternate Offered: Flight AC 486, YYZ ? YVR, Departure: 16:00, Arrival: 19:00 (2h after original arrival of 17:00) |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Customer Status: NO TRAVEL - INCOMPLETE (customer declined alternate, stranded at YYZ) | Customer Status: NO TRAVEL - INCOMPLETE (customer declined alternate, stranded at YYZ) |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | History - Alternate offered and DECLINED by customer | History - Alternate offered and DECLINED by customer |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 485 � YYZ ? YVR � TECH | MSL FLIGHT: AC 485 � YYZ ? YVR � TECH |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | "Cancellation � Technical Fault" | "Cancellation � Technical Fault" |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42) | CONTROLLABLE (Code 42) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Disruption Type: CANCELLATION (mid-journey) | Disruption Type: CANCELLATION (mid-journey) |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Effective Delay: Alternate arrival (19:00) - Original arrival (17:00) = 2h 00m | Effective Delay: Alternate arrival (19:00) - Original arrival (17:00) = 2h 00m |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | APPR Gate 8: Effective delay 2h 00m < 3 hrs ? BELOW THRESHOLD ? NOT ELIGIBLE | APPR Gate 8: Effective delay 2h 00m < 3 hrs ? BELOW THRESHOLD ? NOT ELIGIBLE |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Gate 9 (controllability) NOT REACHED � short-circuited at Gate 8 | Gate 9 (controllability) NOT REACHED � short-circuited at Gate 8 |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | MR LUC BERGERON / NOT ELIGIBLE / DELAY_BELOW_THRESHOLD / CAD 0.00 | MR LUC BERGERON / NOT ELIGIBLE / DELAY_BELOW_THRESHOLD / CAD 0.00 |
| CP070 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP071 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NOT ELIGIBLE ? CyberSource NOT invoked |  |
| CP072 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your arrival in Vancouver was on time. That means there's no recorded delay for this part of your trip. Base |
| CP073 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP074 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP075 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP076 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP077 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to l***@gmail.com |  |
| CP078 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (delay below 3-hour threshold), travel status (No Travel - Incom |  |
| CP079 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP080 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP081 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Luc Bergeron" with PNR "TC048" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Luc Bergeron" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC048" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Luc Bergeron" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "l***@gmail.com" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***345" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: YUL ? YYZ" as completed and "Segment 2: YYZ ? YVR" with claim filed for this flight |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Delay below 3-hour threshold" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to effective delay 2h 00m being less than 3 hours short-circuited |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Luc Bergeron + TC048 + YYZ?YVR + FD" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP135 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to delay below 3-hour threshold |  |
| CP136 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP138 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP139 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP140 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP141 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-22. | DDS returns FD-APPR-NE-22. |
| CP142 | EXPECTED RESULTS | verdict | api | Trip Tracer: Leg 2 = CANCELLED; MSL = Leg 2; Cancellation Code =TECH; Controllable; Re-routing delay = 1.5hrs (below 3hr threshold); No Trav | Trip Tracer: Leg 2 = CANCELLED; MSL = Leg 2; Cancellation Code =TECH; Controllable; Re-routing delay = 1.5hrs (below 3hr threshold); No Travel = TRUE; Status =  |
| CP143 | EXPECTED RESULTS | verdict | chat | Compensation: $0. | Compensation: $0. |
| CP144 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Not Eligible; Below Threshold (1.5hrs < 3hrs); No Travel = Incomplete; DDS = FD-APPR-NE-22. | Claims Dashboard: Not Eligible; Below Threshold (1.5hrs < 3hrs); No Travel = Incomplete; DDS = FD-APPR-NE-22. |
