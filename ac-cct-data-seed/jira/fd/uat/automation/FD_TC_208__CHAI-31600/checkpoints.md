# FD_TC_208 · CHAI-31600 — checkpoints

**Goal:** Customer's flight is cancelled 5 days before departure. Customer decides they no longer want to travel and requests compensation instead of rebooking. Validates DDS behaviour when travel was NOT completed � the customer never boarded any flight. Confirms that the "No Travel" path is correctly identified: the disruption is a cancellation (INVOL), the customer did not accept rebooking, and the promise itinerary stays at the 14-day mark. Since the customer did not travel, the delay is measured as the full cancellation (no arrival at all). DDS should assess eligibility based on the cancellation itself under APPR.

Methods: seed 12, chat 40, api 17, dashboard 45, implied 17, manual 12, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer's flight is cancelled 5 days before departure. Customer decides they no longer want to travel and requests compensation instead of  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Mathieu Pelletier), 1 leg AC domestic YUL?YYZ | PNR: Single passenger (Mathieu Pelletier), 1 leg AC domestic YUL?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Original (14-day) scheduled departure: June 20, 2026 at 08:00, scheduled arrival: 10:00 | Original (14-day) scheduled departure: June 20, 2026 at 08:00, scheduled arrival: 10:00 |
| CP004 | PREREQUISITES | prerequisite | seed | Change (D-5, June 15, 2026): INVOL � AC cancels flight AC 430 | Change (D-5, June 15, 2026): INVOL � AC cancels flight AC 430 |
| CP005 | PREREQUISITES | prerequisite | seed | No rebooking accepted by customer | No rebooking accepted by customer |
| CP006 | PREREQUISITES | prerequisite | seed | Customer contacts chatbot on June 25, 2026 (D+5 after original travel date) | Customer contacts chatbot on June 25, 2026 (D+5 after original travel date) |
| CP007 | PREREQUISITES | prerequisite | seed | Flight status: CANCELLED | Flight status: CANCELLED |
| CP008 | PREREQUISITES | prerequisite | seed | Booking changes: INVOL cancellation only � no VOL, no SELFREACC, no rebooking | Booking changes: INVOL cancellation only � no VOL, no SELFREACC, no rebooking |
| CP009 | PREREQUISITES | prerequisite | seed | Carrier: AC only | Carrier: AC only |
| CP010 | PREREQUISITES | prerequisite | seed | 72hrs: Elapsed | 72hrs: Elapsed |
| CP011 | PREREQUISITES | prerequisite | seed | Time limit: Within 366 days | Time limit: Within 366 days |
| CP012 | PREREQUISITES | prerequisite | seed | No duplicate case | No duplicate case |
| CP013 | PREREQUISITES | prerequisite | seed | Not employee, not infant | Not employee, not infant |
| CP014 | PREREQUISITES | prerequisite | implied | CyberSource: Configured to return GREEN | CyberSource: Configured to return GREEN |
| CP015 | PREREQUISITES | prerequisite | implied | RDS: No flags | RDS: No flags |
| CP016 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP017 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): "Hello! I will be your virtual assistant today. I can assist you in English or French. Which l | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP018 | START | customer | chat | Then user selects English |  |
| CP019 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP020 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP021 | START | customer | chat | And the user says "My flight was cancelled 5 days before I was supposed to travel and I decided not to rebook. I no longer want to travel. C | My flight was cancelled 5 days before I was supposed to travel and I decided not to rebook. I no longer want to travel. Can I get compensation? |
| CP022 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP023 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP024 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your cancelled flight and see if you are eligible for compensation | No problem, I can help you create a claim for your cancelled flight and see if you are eligible for compensation. |
| CP025 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable." | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Mathieu Pelletier" | Mathieu Pelletier |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, Mathieu! And, what is your booking reference number?" | Thanks, Mathieu! And, what is your booking reference number? |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC182" | PNR: TC182 |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC182 |  |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: m***@gmail.com � Phone: +1***456 |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: m***@gmail.com" | Email: m***@gmail.com |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "738291" | 738291 |
| CP038 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP040 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP041 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP042 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP043 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP044 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: "I found 1 passenger on this booking: | � Mathieu Pelletier (Adult) Is this who you'd like to include?" |
| CP045 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP047 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: "I found the following journey: | � Flight: AC 430 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 20, 2026 � Status: CANCELLED Is this the journey you'd like to check?" |
| CP048 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP049 | NO TRAVEL CONFIRMATION | bot | chat | Then the chatbot asks: "I can see this flight was cancelled. Did you travel on an alternative flight or did you decide not to travel?" | I can see this flight was cancelled. Did you travel on an alternative flight or did you decide not to travel? |
| CP050 | NO TRAVEL CONFIRMATION | system | implied | And the user responds: "I decided not to travel" |  |
| CP051 | NO TRAVEL CONFIRMATION | system | implied | Then the chatbot confirms: "Understood. I'll process your claim based on the cancelled flight without rebooking." |  |
| CP052 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP053 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP054 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP055 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since cancellation notification |  |
| CP056 | 72-HOUR CHECK | system | implied | And the system calculates: Cancellation notified June 15, 2026; current date June 25, 2026 ? >72 hours ? PROCEED |  |
| CP057 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP058 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption June 20, 2026 (original travel date); filing June 25, 2026 ? 5 days ? within 366 days ? PROCEED |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 430, Route: YUL ? YYZ, Scheduled Arrival: 10:00 (14-day mark) | Promised Itinerary - Flight: AC 430, Route: YUL ? YYZ, Scheduled Arrival: 10:00 (14-day mark) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 430, Route: YUL ? YYZ, Status: CANCELLED, No Actual Arrival | Current Itinerary - Flight: AC 430, Route: YUL ? YYZ, Status: CANCELLED, No Actual Arrival |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | History - Change 1 (Day -5): INVOL � AC cancels flight | History - Change 1 (Day -5): INVOL � AC cancels flight |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | No Travel: Customer elected not to rebook | No Travel: Customer elected not to rebook |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 430 � YUL ? YYZ � CREW | MSL FLIGHT: AC 430 � YUL ? YYZ � CREW |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | "Flight cancelled � crew scheduling" | "Flight cancelled � crew scheduling" |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Cancellation: D-5 � CONTROLLABLE (CREW) | Cancellation: D-5 � CONTROLLABLE (CREW) |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE � Sister City: FALSE | Fallback: FALSE � Sister City: FALSE |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | MR MATHIEU PELLETIER | MR MATHIEU PELLETIER |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Mathieu Pelletier" with PNR "TC182" |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Mathieu Pelletier" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC182" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the No Travel Flag should be TRUE |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Mathieu Pelletier" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "m***@gmail.com" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***456" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" as CANCELLED with No Travel |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated for this automated FD case |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Mathieu Pelletier + TC182 + YUL?YYZ + FD" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP125 | PAYMENT VALIDATION | payment | chat | Given the customer did not travel and is not eligible for flight disruption compensation under APPR |  |
| CP126 | PAYMENT VALIDATION | payment | chat | Then no FD compensation payment should be processed for this test case |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And the chatbot must NOT trigger CyberSource fraud screening |  |
| CP128 | PAYMENT VALIDATION | payment | chat | And the chatbot must NOT present Cash vs AC Wallet options |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And the chatbot must NOT initiate Interac or wire transfer or any other payment method |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And instead the chatbot should route the customer to the Refund flow for the unused ticket |  |
| CP131 | PAYMENT VALIDATION | payment | chat | And no compensation record should be created in the FD payment pipeline |  |
| CP132 | PAYMENT VALIDATION | payment | manual | And no daily batch file entry should be generated for Unifier |  |
| CP133 | PAYMENT VALIDATION | payment | manual | And no Unifier acknowledgement should be expected |  |
| CP134 | PAYMENT VALIDATION | payment | manual | And no end-of-day report entry should exist for this case in the FD compensation report |  |
| CP135 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show "N/A � No Travel" or equivalent with no payout amount and no currency and no payment m |  |
| CP136 | PAYMENT VALIDATION | payment | chat | And if the customer is routed to the Refund flow the refund should be processed through the standard ticket refund pipeline separate from FD |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And the refund request should be created with the correct PNR TC182 and passenger name Mathieu Pelletier and original ticket value |  |
| CP138 | PAYMENT VALIDATION | payment | chat | And the refund method should follow the original form of payment OFP rule with refund going back to the credit card or payment method used a |  |
| CP139 | PAYMENT VALIDATION | payment | chat | And no 35-day expiry rule should apply as that rule is for FD compensation only not ticket refunds |  |
| CP140 | PAYMENT VALIDATION | payment | chat | And if the system erroneously generates a compensation amount or triggers a payment flow this is a P1 defect as the No Travel path must neve |  |
| CP141 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-01. | DDS returns FD-APPR-EL-01. |
| CP142 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 10:00 (14-day mark); Flight Status = CANCELLED; No Actual Arrival; Cancellation at D-5 (INVOL); Cancellation Code = C | Trip Tracer: Promise = 10:00 (14-day mark); Flight Status = CANCELLED; No Actual Arrival; Cancellation at D-5 (INVOL); Cancellation Code = CREW (Controllable);  |
| CP143 | EXPECTED RESULTS | verdict | chat | Compensation: $400 CAD. | Compensation: $400 CAD. |
| CP144 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN ? auto-approved. | CyberSource: GREEN ? auto-approved. |
