# FD_TC_176 · CHAI-31568 — checkpoints

**Goal:** Mixed Regime � EU Eligible but APPR Not Eligible (Different Controllability). Flight from London LHR to Toronto YYZ. Disruption code maps differently under the two regimes � under EU 261 the cause is classified as controllable (eligible), but under APPR the same code maps to a different controllability classification resulting in Not Eligible. Per fixed priority, EU would be selected over APPR regardless, but this test validates that DDS applies each regime's OWN controllability rules independently and doesn't blend classifications. One regime can be Eligible while the other is Not Eligible for the SAME flight. EU is selected as the only eligible regime.

Methods: seed 5, chat 61, api 20, email 3, dashboard 45, implied 17, manual 15, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Mixed Regime � EU Eligible but APPR Not Eligible (Different Controllability). Flight from London LHR to Toronto YYZ. Disruption code maps di |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Bridget Carmichael), 1 leg AC operated LHR?YYZ | PNR: Single passenger (Bridget Carmichael), 1 leg AC operated LHR?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: Scheduled arrival 16:00, Actual arrival 20:00 (4hr delay) | Itinerary: Scheduled arrival 16:00, Actual arrival 20:00 (4hr delay) |
| CP004 | PREREQUISITES | prerequisite | seed | Disruption code: A code that maps to controllable under EU 261 but uncontrollable under APPR (regime-specific classification divergence) | Disruption code: A code that maps to controllable under EU 261 but uncontrollable under APPR (regime-specific classification divergence) |
| CP005 | PREREQUISITES | prerequisite | seed | Flight distance: LHR?YYZ = ~5,550km (>3500km) | Flight distance: LHR?YYZ = ~5,550km (>3500km) |
| CP006 | PREREQUISITES | prerequisite | seed | Flight status: Arrived (operated) | Flight status: Arrived (operated) |
| CP007 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP008 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP009 | START | customer | chat | Then user selects English |  |
| CP010 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP011 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP012 | START | customer | chat | And the user says "My flight from London to Toronto was delayed 4 hours. I'd like to check if I'm eligible for compensation" | My flight from London to Toronto was delayed 4 hours. I'd like to check if I'm eligible for compensation |
| CP013 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP014 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP015 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP016 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP017 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP018 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP019 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Bridget Carmichael" | Bridget Carmichael |
| CP020 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Bridget! And, what is your booking reference number? |
| CP021 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC150" | PNR: TC150 |
| CP022 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC150 |  |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP025 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: b***@gmail.com Phone: +44***678 |
| CP027 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: b***@gmail.com" | Email: b***@gmail.com |
| CP028 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP029 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP030 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP032 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP033 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP034 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Bridget Carmichael (Adult) Is this who you'd like to include? |
| CP035 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP036 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP037 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 855 Route: London Heathrow (LHR) ? Toronto (YYZ) Date: June 5, 2026 Arrival Delay: 4 hours Is this the journey you'd l |
| CP038 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP039 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment? ? NO ? skip GenUC-18 |  |
| CP040 | DUPLICATE CLAIM CHECK | system | implied | Case Services returns: NO existing case found |  |
| CP041 | 72-HOUR CHECK | system | implied | Hours since arrival ? >72 hours ? PROCEED |  |
| CP042 | REGIME DETERMINATION � DUAL REGIME | system | implied | Then the system determines: Origin = LHR (UK, EU 261 applies to UK departures) ? EU 261 applies; Destination = YYZ (Canada) ? APPR applies |  |
| CP043 | REGIME DETERMINATION � DUAL REGIME | verdict | api | And the system determines: DUAL REGIME � EU 261 + APPR |  |
| CP044 | TRIAGE & DDS EVALUATION � DIVERGENT CONTROLLABILITY | verdict | api | Then the DDS evaluation is done in backend |  |
| CP045 | TRIAGE & DDS EVALUATION � DIVERGENT CONTROLLABILITY | verdict | api | And DDS assesses BOTH regimes independently with REGIME-SPECIFIC controllability rules: |  |
| CP046 | EU 261 ASSESSMENT | system | implied | ? Origin: LHR (UK) ? EU 261 applies | ? Distance: LHR?YYZ = ~5,550 km ? Long-haul (>3500km) ? Delay: 4 hours ? ?4h threshold ? Disruption Code: [Code that maps differently per regime] ? EU 261 Contr |
| CP047 | APPR ASSESSMENT | system | implied | ? Destination: YYZ (Canada) ? APPR applies | ? Delay: 4 hours ? 3�<6h tier ? Same Disruption Code ? APPR Controllability Classification: UNCONTROLLABLE (under APPR rules, the same cause maps to outside car |
| CP048 | MIXED RESULT � EU ELIGIBLE, APPR NOT ELIGIBLE | system | implied | ? EU 261: ELIGIBLE � �520 GBP | ? APPR: NOT ELIGIBLE (uncontrollable) ? Since at least one regime is eligible, the customer IS eligible ? Selected Regime: EU 261 � �520 GBP (the only eligible  |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 855, Route: LHR ? YYZ, Scheduled Arrival: 16:00 | Promised Itinerary - Flight: AC 855, Route: LHR ? YYZ, Scheduled Arrival: 16:00 |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 855, Route: LHR ? YYZ, Status: ARRIVED LATE, Actual: 20:00, Delay: +4H 00M | Current Itinerary - Flight: AC 855, Route: LHR ? YYZ, Status: ARRIVED LATE, Actual: 20:00, Delay: +4H 00M |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | Dual Regime: EU 261 + APPR | Dual Regime: EU 261 + APPR |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | EU 261: ELIGIBLE � �520 GBP (controllable under EU rules; EU UK column, 4+ hours, >3500km) | EU 261: ELIGIBLE � �520 GBP (controllable under EU rules; EU UK column, 4+ hours, >3500km) |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | APPR: NOT ELIGIBLE (uncontrollable under APPR rules) | APPR: NOT ELIGIBLE (uncontrollable under APPR rules) |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | Same disruption code ? different controllability per regime | Same disruption code ? different controllability per regime |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Selected: EU 261 (only eligible regime; also would win per fixed priority) | Selected: EU 261 (only eligible regime; also would win per fixed priority) |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 855 � LHR ? YYZ � [Code] | MSL FLIGHT: AC 855 � LHR ? YYZ � [Code] |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | MS BRIDGET CARMICHAEL / ELIGIBLE / EU_UK_4_PLUS_HOURS_LONG_HAUL / �520 GBP | MS BRIDGET CARMICHAEL / ELIGIBLE / EU_UK_4_PLUS_HOURS_LONG_HAUL / �520 GBP |
| CP058 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP059 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP060 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 855 from London Heathrow (LHR) to Toronto (YYZ) was delayed by about 4 hours. Based on the applica |
| CP061 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP062 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "United Kingdom" | United Kingdom |
| CP063 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = UK ? Currency = GBP ? Payment Method = BSM Email Payment |  |
| CP064 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP065 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive �520 compensation. Please note that it will take 5 to 10 business days to process pa | You are entitled to receive �520 compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP066 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP067 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment re |
| CP068 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | customer | chat | And user provides "Yes" | Yes |
| CP069 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP070 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP071 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP072 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP073 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP074 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP075 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP076 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �520 Payment Method: Email After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps. W |
| CP077 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP078 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user confirms "Yes" | Yes |
| CP079 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP080 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP081 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP082 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP083 | NOTIFICATION | email | email | And an eligible notification email is sent to b***@gmail.com |  |
| CP084 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�520 GBP), regulation (EU 261 UK), flight details (LHR?YYZ, 4hr delay), next st |  |
| CP085 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP086 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP087 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Bridget Carmichael" with PNR "TC150" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Bridget Carmichael" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC150" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 + APPR (Dual Regime � EU 261 SELECTED; APPR Not Eligible)" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Bridget Carmichael" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: LHR ? YYZ" with claim filed for this flight |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Assessment 1 ELIGIBLE should be EU 261 UK with disruption code classification under EU rules as Controllable and eligibility ELIGIBLE an |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Assessment 2 NOT ELIGIBLE should be APPR with disruption code classification under APPR rules as Uncontrollable and eligibility NOT ELIG |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Divergent Classification should show the same disruption code producing DIFFERENT controllability outcomes under different regimes w |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should apply each regime's OWN controllability rules independently with no cross-regime blending |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the divergent classification should be highlighted in the dashboard |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And BOTH regimes should be assessed independently |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be "ELIGIBLE" under EU 261 controllable under EU rules with APPR NE under APPR rules |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the divergent controllability classification should be noted |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Bridget Carmichael + TC150 + LHR?YYZ + FD" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" as it ran for the eligible EU 261 assessment |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent containing compensation "�520 GBP" and regulation "EU 261 UK" and flight details LH |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record dual-regime assessment with divergent controllability |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should show EU 261 Eligible controllable at �520 GBP and APPR Not Eligible uncontrollable at $0 |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the divergent classification should be flagged in the audit trail |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP143 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "United Kingdom" |  |
| CP144 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "GBP" |  |
| CP145 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM Email Payment" |  |
| CP146 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered and AC Wallet should NOT be offered |  |
| CP147 | PAYMENT VALIDATION | payment | chat | And the dual regime should be assessed with EU 261 ELIGIBLE at �520 GBP controllable under EU rules vs APPR NOT ELIGIBLE uncontrollable unde |  |
| CP148 | PAYMENT VALIDATION | payment | chat | And only one regime should be eligible so EU 261 should be selected at �520 GBP |  |
| CP149 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "�520 GBP" EU UK column greater than 3500km 4 plus hours |  |
| CP150 | PAYMENT VALIDATION | payment | chat | And the payment currency should be GBP as the customer is in UK and EU UK compensation is already in GBP so no conversion is needed |  |
| CP151 | PAYMENT VALIDATION | payment | chat | And email should be confirmed for BSM Email Payment |  |
| CP152 | PAYMENT VALIDATION | payment | chat | And IDV should be completed via Persona and IDV should PASS |  |
| CP153 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP154 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP155 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier and Unifier should process BSM Email Payment in GBP |  |
| CP156 | PAYMENT VALIDATION | payment | manual | And HSBC should send an acknowledgement back and the end-of-day report should be received |  |
| CP157 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Completed" or "Rejected" or "Expired" |  |
| CP158 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details "�520 GBP" as EU 261 UK selected with payment currency GBP and payment  |  |
| CP159 | EXPECTED RESULTS | verdict | api | DDS returns FD-MIXED-NE-01. | DDS returns FD-MIXED-NE-01. |
| CP160 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 16:00; Actual = 20:00; Delay = 4hrs; MSL = Leg 1; Disruption code = [divergent code]; EU classification = Controllabl | Trip Tracer: Promise = 16:00; Actual = 20:00; Delay = 4hrs; MSL = Leg 1; Disruption code = [divergent code]; EU classification = Controllable; APPR classificati |
| CP161 | EXPECTED RESULTS | verdict | chat | Dual Assessment: EU 261 = ELIGIBLE (�520 GBP, EU UK column, controllable under EU rules, >3500km, 4+ hours); APPR = NOT ELIGIBLE (uncontroll | Dual Assessment: EU 261 = ELIGIBLE (�520 GBP, EU UK column, controllable under EU rules, >3500km, 4+ hours); APPR = NOT ELIGIBLE (uncontrollable under APPR rule |
| CP162 | EXPECTED RESULTS | verdict | chat | CRITICAL: The SAME disruption code can produce different controllability outcomes under different regimes. | CRITICAL: The SAME disruption code can produce different controllability outcomes under different regimes. |
| CP163 | EXPECTED RESULTS | verdict | api | DDS must NOT apply one regime's classification to the other. | DDS must NOT apply one regime's classification to the other. |
| CP164 | EXPECTED RESULTS | verdict | chat | Each regime's rules are independent. | Each regime's rules are independent. |
| CP165 | EXPECTED RESULTS | verdict | chat | Per fixed priority, EU would win over APPR regardless, but APPR is also NE. | Per fixed priority, EU would win over APPR regardless, but APPR is also NE. |
| CP166 | EXPECTED RESULTS | verdict | chat | Compensation: �520 GBP (EU 261 UK � the one eligible regime). | Compensation: �520 GBP (EU 261 UK � the one eligible regime). |
| CP167 | EXPECTED RESULTS | verdict | api | Claims Dashboard: EU 261 = Eligible (�520 GBP); APPR = Not Eligible (uncontrollable); Divergent classification highlighted; DDS = FD-MIXED-N | Claims Dashboard: EU 261 = Eligible (�520 GBP); APPR = Not Eligible (uncontrollable); Divergent classification highlighted; DDS = FD-MIXED-NE-01. |
