# FD_TC_004 · CHAI-31396 — checkpoints

**Goal:** Checks the full flow for a 3-passenger booking on a UK departure where the delay is too short to pay compensation. Flight AC 865 LHR ? YUL arrives 2 hours 30 minutes late for a controllable reason (Code 68 � Flight Crew Shortage / Crew Rest). The trip starts in the UK, so the UK regime (EU 261 UK branch) applies, and APPR also applies because the flight lands in Canada. Neither regime pays for delays under 3 hours, so all 3 passengers are NOT ELIGIBLE and the amount is 0. Confirms that DDS returns an EU not-eligible response and the bot declines the claim in the chat with the reason, without sending it to manual review. It also confirms that no Cash or AC Wallet offer, CyberSource check, Persona IDV, payment email request or compensation record happens, and that the Claims Dashboard shows the Not Eligible outcome for all 3 passengers.

Methods: seed 16, chat 31, api 18, email 5, implied 66, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Checks the full flow for a 3-passenger booking on a UK departure where the delay is too short to pay compensation. Flight AC 865 LHR ? YUL a |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC003 � 3 passengers: Catherine Bouchard (Adult - Claimant, Basic Aeroplan Member 9876543210), Alexandre Bouchard (Adult), Sophie Bouch | PNR: TC003 � 3 passengers: Catherine Bouchard (Adult - Claimant, Basic Aeroplan Member 9876543210), Alexandre Bouchard (Adult), Sophie Bouchard (Child) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC international LHR ? YUL (Flight AC 865) | Journey: 1 leg AC international LHR ? YUL (Flight AC 865) |
| CP004 | PREREQUISITES | prerequisite | seed | Departure country: United Kingdom | Departure country: United Kingdom |
| CP005 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 14:00 | Scheduled arrival: 14:00 |
| CP006 | PREREQUISITES | prerequisite | seed | Actual arrival: 16:30 (2hr 30min delay) | Actual arrival: 16:30 (2hr 30min delay) |
| CP007 | PREREQUISITES | prerequisite | seed | Arrival delay code: 68 (Flight Crew Shortage / Crew Rest � Controllable) | Arrival delay code: 68 (Flight Crew Shortage / Crew Rest � Controllable) |
| CP008 | PREREQUISITES | prerequisite | seed | Flight status: Arrived (operated) | Flight status: Arrived (operated) |
| CP009 | PREREQUISITES | prerequisite | seed | Disruption notice: less than 14 days before departure | Disruption notice: less than 14 days before departure |
| CP010 | PREREQUISITES | prerequisite | seed | Booking changes: None � no VOL or INVOL | Booking changes: None � no VOL or INVOL |
| CP011 | PREREQUISITES | prerequisite | seed | Carrier: AC only | Carrier: AC only |
| CP012 | PREREQUISITES | prerequisite | seed | 72hrs: Elapsed (filed D+13) | 72hrs: Elapsed (filed D+13) |
| CP013 | PREREQUISITES | prerequisite | seed | Time limit: Within 2190 days (UK 6-year limit) | Time limit: Within 2190 days (UK 6-year limit) |
| CP014 | PREREQUISITES | prerequisite | seed | No duplicate case | No duplicate case |
| CP015 | PREREQUISITES | prerequisite | seed | Not employee | Not employee |
| CP016 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked (9876543210), Basic Member in good standing | Aeroplan: Linked (9876543210), Basic Member in good standing |
| CP017 | PREREQUISITES | prerequisite | seed | Country of residence: Canada | Country of residence: Canada |
| CP018 | GREETING & INTENT IDENTIFICATION | customer | chat | Given the user opens the agentic chatbot |  |
| CP019 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP020 | GREETING & INTENT IDENTIFICATION | customer | chat | Then user selects "English" | English |
| CP021 | GREETING & INTENT IDENTIFICATION | alert | chat | Then an alert information is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI t | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP022 | GREETING & INTENT IDENTIFICATION | bot | chat | Then chatbot asks: "How can I help you today?" | How can I help you today? |
| CP023 | GREETING & INTENT IDENTIFICATION | customer | chat | And the user says: "Our flight from London to Montreal was delayed about 2 and a half hours, I'd like to check if my family and I are eligib | Our flight from London to Montreal was delayed about 2 and a half hours, I'd like to check if my family and I are eligible for compensation |
| CP024 | GREETING & INTENT IDENTIFICATION | system | implied | When the chatbot identifies flight disruption intent |  |
| CP025 | GREETING & INTENT IDENTIFICATION | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP026 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP027 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. Please provide your f |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Catherine Bouchard" | Catherine Bouchard |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, Catherine! And, what is your booking reference number?" | Thanks, Catherine! And, what is your booking reference number? |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "TC003" | TC003 |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC003 |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | * Email: c***@gmail.com * Phone: +1567 |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: c@gmail.com" | Email: c@gmail.com |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides OTP code "591837" | 591837 |
| CP039 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP041 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | verdict | api | Then the system checks Trip Tracer for group booking identifier ? NOT PRESENT |  |
| CP042 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP043 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR TC003: | I found 3 passengers on this booking: 1. Catherine Bouchard (Adult - Aeroplan Member) 2. Alexandre Bouchard (Adult) 3. Sophie Bouchard (Child) Would you like to |
| CP044 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes, include all 3 passengers" | Yes, include all 3 passengers |
| CP045 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 3 ? 9 or fewer ? NOT a group booking ? PROCEED |  |
| CP046 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: * Flight: AC 865 * Route: London Heathrow (LHR) ? Montreal (YUL) * Date: January 15, 2026 * Arrival Delay: 2 hours 30 minutes Is  |
| CP047 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP049 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot sends request to Case Services for duplicate check ? NO existing case found for any of the 3 passengers |  |
| CP050 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks 72-hour rule: Arrival Jan 15, 2026; filing Jan 28, 2026 ? 312 hours ? PROCEED |  |
| CP051 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks filing deadline: UK departure ? 2190 days; 13 days elapsed ? PROCEED |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | Backend DDS executes evaluation for PNR TC003: | � Journey origin: LHR (United Kingdom) ? UK regime applicable � Arrival in Canada ? APPR also applicable � Delay reason: Code 68 (Controllable) � Delay duration |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | [x] Promised Itinerary: Flight AC 865, LHR ? YUL, Scheduled Arrival: 14:00 | [x] Promised Itinerary: Flight AC 865, LHR ? YUL, Scheduled Arrival: 14:00 |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | [x] Current Itinerary: Flight AC 865, LHR ? YUL, Status: ARRIVED LATE, Scheduled: 14:00 ? Actual: 16:30, Delay: +2H 30M | [x] Current Itinerary: Flight AC 865, LHR ? YUL, Status: ARRIVED LATE, Scheduled: 14:00 ? Actual: 16:30, Delay: +2H 30M |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | [x] Regime: EU (UK) + APPR (2 regimes) | [x] Regime: EU (UK) + APPR (2 regimes) |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | [x] MSL Flight: AC 865 � LHR ? YUL � Code 68 ("Delayed due to flight crew shortage / crew rest requirement") | [x] MSL Flight: AC 865 � LHR ? YUL � Code 68 ("Delayed due to flight crew shortage / crew rest requirement") |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | [x] Delay Classification: +2H 30M � CONTROLLABLE | [x] Delay Classification: +2H 30M � CONTROLLABLE |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | [x] Aeroplan: 9876543210 (Basic Member � linked) | [x] Aeroplan: 9876543210 (Basic Member � linked) |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | MS CATHERINE BOUCHARD / NOT ELIGIBLE / Delay under 3 hours / GBP 0.00 | MS CATHERINE BOUCHARD / NOT ELIGIBLE / Delay under 3 hours / GBP 0.00 |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | MR ALEXANDRE BOUCHARD / NOT ELIGIBLE / Delay under 3 hours / GBP 0.00 | MR ALEXANDRE BOUCHARD / NOT ELIGIBLE / Delay under 3 hours / GBP 0.00 |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | MISS SOPHIE BOUCHARD / NOT ELIGIBLE / Delay under 3 hours / GBP 0.00 | MISS SOPHIE BOUCHARD / NOT ELIGIBLE / Delay under 3 hours / GBP 0.00 |
| CP062 | NOT ELIGIBLE RESULT � IN-CHAT DECLINE | system | implied | Then the chatbot does NOT send the claim to manual review |  |
| CP063 | NOT ELIGIBLE RESULT � IN-CHAT DECLINE | bot | chat | And the chatbot displays: "I've checked your flight details. Flight AC 865 from London Heathrow (LHR) to Montreal (YUL) arrived about 2 hour | I've checked your flight details. Flight AC 865 from London Heathrow (LHR) to Montreal (YUL) arrived about 2 hours and 30 minutes late. Compensation under the U |
| CP064 | NOT ELIGIBLE RESULT � IN-CHAT DECLINE | system | implied | And no compensation amount is quoted (amount = 0) |  |
| CP065 | NOT ELIGIBLE RESULT � IN-CHAT DECLINE | system | implied | And no manual-review reference number is given |  |
| CP066 | PAYMENT FLOW SKIPPED | system | implied | Then CyberSource fraud screening (GLOB-05) is NOT triggered |  |
| CP067 | PAYMENT FLOW SKIPPED | system | implied | And the country of residence question is NOT asked |  |
| CP068 | PAYMENT FLOW SKIPPED | system | implied | And no Cash or AC Wallet offer is shown |  |
| CP069 | PAYMENT FLOW SKIPPED | system | implied | And no Interac email is requested |  |
| CP070 | PAYMENT FLOW SKIPPED | idv | chat | And Persona IDV (FD-07b) is NOT triggered |  |
| CP071 | NOTIFICATION & WRAP-UP (GLOB-11) | email | email | Then a not-eligible notification email is sent via Adobe to c***@gmail.com containing: Case Reference, outcome (Not Eligible), reason (arriv |  |
| CP072 | NOTIFICATION & WRAP-UP (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" | Is there anything I can help you with? |
| CP073 | NOTIFICATION & WRAP-UP (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP074 | NOTIFICATION & WRAP-UP (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP075 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | Given a case has been created for primary claimant "Catherine Bouchard" with PNR "TC003" covering 3 passengers |  |
| CP076 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" mapped from chatbot intent |  |
| CP077 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP078 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Case Status should be "Done" |  |
| CP079 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Created date should be populated |  |
| CP080 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Last Updated date should be populated |  |
| CP081 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the SLA countdown should be tracking correctly |  |
| CP082 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Team assignment should be correct |  |
| CP083 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP084 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Decision Assist panel should NOT be greyed out |  |
| CP085 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Claimant Name should be "Catherine Bouchard" |  |
| CP086 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Claimant Type should be "Adult" |  |
| CP087 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Authentication should be "Pass" |  |
| CP088 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the PNR should be "TC003" |  |
| CP089 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the PNR Creation Date should be populated |  |
| CP090 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Journey ID should be populated |  |
| CP091 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Booking Source should be populated |  |
| CP092 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Booking Office ID should be populated |  |
| CP093 | NOTIFICATION & WRAP-UP (GLOB-11) | verdict | api | And the Regime should be "EU (UK)" with APPR also listed as applicable | EU (UK) |
| CP094 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And all 3 passengers should be listed (Catherine Bouchard, Alexandre Bouchard, Sophie Bouchard) |  |
| CP095 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Tags for the claimant should include "Claimant" and "Adult" |  |
| CP096 | NOTIFICATION & WRAP-UP (GLOB-11) | email | email | And the Email should be "c***@gmail.com" | c***@gmail.com |
| CP097 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Phone should be "+1***567" |  |
| CP098 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Address should be populated |  |
| CP099 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Aeroplan should be "9876543210" linked and in good standing (Basic Member) |  |
| CP100 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Tier Status should be "Basic / Member" |  |
| CP101 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Journey should show "Bound 1: LHR ? YUL" with claim filed for this flight |  |
| CP102 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Ancillary Fee section should be present and empty |  |
| CP103 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Eligibility and Compensation section should show "NOT ELIGIBLE � Delay under 3 hours � GBP 0" for all 3 passengers |  |
| CP104 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And no Cash or AC Wallet offer should be recorded |  |
| CP105 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP106 | NOTIFICATION & WRAP-UP (GLOB-11) | verdict | api | And DDS should have run automatically with no agent action needed |  |
| CP107 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" (EU/UK and APPR, 2h 30m delay) |  |
| CP108 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Duplicate Check should have run automatically using baseline data "Catherine Bouchard + TC003 + LHR?YUL + FD" |  |
| CP109 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the result should be "No duplicate found" |  |
| CP110 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And no Duplicate Warning Banner should be displayed |  |
| CP111 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Related Cases tab should show no related cases |  |
| CP112 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the CyberSource result should be "Not triggered" |  |
| CP113 | NOTIFICATION & WRAP-UP (GLOB-11) | idv | chat | And the IDV status should be "Not triggered" | Not triggered |
| CP114 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And no manual-review queue item should exist for this case |  |
| CP115 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the system should have appended the booking record automatically |  |
| CP116 | NOTIFICATION & WRAP-UP (GLOB-11) | verdict | api | And Trip Tracer poll should NOT be required |  |
| CP117 | NOTIFICATION & WRAP-UP (GLOB-11) | email | email | And a not-eligible notification email should have been sent via Adobe |  |
| CP118 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Agent Notes section should be accessible |  |
| CP119 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP120 | NOTIFICATION & WRAP-UP (GLOB-11) | email | email | And Customer Communications should show the notification email chronologically |  |
| CP121 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the chatbot transcript should be accessible and linked |  |
| CP122 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Attachments tab should be empty |  |
| CP123 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Final Status should be "Resolved" |  |
| CP124 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP125 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the agent should not be able to access Case Search as it is for leads and management only | Payment Validation Gherkin: |
| CP126 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | Given the claim outcome is "NOT ELIGIBLE" for all 3 passengers |  |
| CP127 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | Then no country of residence should be collected for payment |  |
| CP128 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And no Cash or AC Wallet option should be offered |  |
| CP129 | NOTIFICATION & WRAP-UP (GLOB-11) | email | email | And no Interac email, banking or card details should be collected |  |
| CP130 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And no compensation record should be created |  |
| CP131 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And no record should be picked up by the daily evening batch file |  |
| CP132 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And nothing should be dispatched to Unifier or EIP |  |
| CP133 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Claims Dashboard Compensation tab should show no payout (GBP 0 / no payment instruction) |  |
| CP134 | EXPECTED RESULTS | verdict | api | DDS returns an EU not-eligible response for all 3 pax. | DDS returns an EU not-eligible response for all 3 pax. |
| CP135 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 14:00; Actual = 16:30; Delay = 2h 30m; MSL = Leg 1 (AC 865 LHR ? YUL); Code 68 Controllable; Regimes = EU (UK) + APPR | Trip Tracer: Promise = 14:00; Actual = 16:30; Delay = 2h 30m; MSL = Leg 1 (AC 865 LHR ? YUL); Code 68 Controllable; Regimes = EU (UK) + APPR. |
| CP136 | EXPECTED RESULTS | verdict | chat | Compensation: GBP 0 (under 3 hours). | Compensation: GBP 0 (under 3 hours). |
| CP137 | EXPECTED RESULTS | verdict | chat | The bot declines in the chat with the reason, with no manual review, no payment offer, no CyberSource check and no IDV. | The bot declines in the chat with the reason, with no manual review, no payment offer, no CyberSource check and no IDV. |
