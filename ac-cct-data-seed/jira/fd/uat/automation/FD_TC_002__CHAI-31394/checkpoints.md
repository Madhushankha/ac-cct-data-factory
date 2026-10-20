# FD_TC_002 · CHAI-31394 — checkpoints

**Goal:** Validates an end-to-end eligible flight disruption claim scenario for a multi-passenger booking (3 passengers) where the primary claimant is a Basic Aeroplan member. Flight AC 301 is delayed 4 hours on a single domestic leg due to a controllable reason (Code 68 � Flight Crew Shortage / Crew Rest). APPR regime applies under Tier 1 delay compensation ($400 CAD per passenger, totaling $1,200 CAD Cash or $1,440 CAD AC Wallet with 20% top-up). The customer selects Cash (Interac e-Transfer) over AC Wallet. Confirms that DDS evaluates APPR eligibility correctly (generating EL-01 response), CyberSource passes GREEN, Persona IDV passes, the bot collects only the email ID for Interac e-Transfer (Canada resident), and the Claims Dashboard reflects all 3 passengers with read-only resolution.

Methods: seed 15, chat 33, api 19, email 1, implied 18, manual 2, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates an end-to-end eligible flight disruption claim scenario for a multi-passenger booking (3 passengers) where the primary claimant is |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC003 � 3 passengers: Catherine Bouchard (Adult - Claimant, Basic Aeroplan Member 9876543210), Alexandre Bouchard (Adult), Sophie Bouch | PNR: TC003 � 3 passengers: Catherine Bouchard (Adult - Claimant, Basic Aeroplan Member 9876543210), Alexandre Bouchard (Adult), Sophie Bouchard (Child) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC domestic YUL?YYZ | Journey: 1 leg AC domestic YUL?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 14:00 | Scheduled arrival: 14:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival: 18:00 (4hr delay) | Actual arrival: 18:00 (4hr delay) |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival delay code: 68 (Flight Crew Shortage / Crew Rest � Controllable) | Arrival delay code: 68 (Flight Crew Shortage / Crew Rest � Controllable) |
| CP007 | PREREQUISITES | prerequisite | seed | Flight status: Arrived (operated) | Flight status: Arrived (operated) |
| CP008 | PREREQUISITES | prerequisite | seed | Booking changes: None � no VOL or INVOL | Booking changes: None � no VOL or INVOL |
| CP009 | PREREQUISITES | prerequisite | seed | Carrier: AC only | Carrier: AC only |
| CP010 | PREREQUISITES | prerequisite | seed | 72hrs: Elapsed (filed D+13) | 72hrs: Elapsed (filed D+13) |
| CP011 | PREREQUISITES | prerequisite | seed | Time limit: Within 366 days | Time limit: Within 366 days |
| CP012 | PREREQUISITES | prerequisite | seed | No duplicate case | No duplicate case |
| CP013 | PREREQUISITES | prerequisite | seed | Not employee, not infant | Not employee, not infant |
| CP014 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked (9876543210), Basic Member in good standing | Aeroplan: Linked (9876543210), Basic Member in good standing |
| CP015 | PREREQUISITES | prerequisite | implied | CyberSource: Configured to return GREEN | CyberSource: Configured to return GREEN |
| CP016 | PREREQUISITES | prerequisite | seed | Persona: Configured to return IDV PASS | Persona: Configured to return IDV PASS |
| CP017 | PREREQUISITES | prerequisite | seed | Country of residence: Canada (CAD) | Country of residence: Canada (CAD) |
| CP018 | GREETING & INTENT IDENTIFICATION | customer | chat | Given the user opens the agentic chatbot |  |
| CP019 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP020 | GREETING & INTENT IDENTIFICATION | customer | chat | Then user selects "English" | English |
| CP021 | GREETING & INTENT IDENTIFICATION | alert | chat | Then an alert information is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI t | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP022 | GREETING & INTENT IDENTIFICATION | bot | chat | Then chatbot asks: "How can I help you today?" | How can I help you today? |
| CP023 | GREETING & INTENT IDENTIFICATION | customer | chat | And the user says: "My flight was delayed about 4 hours, I'd like to check if my family and I are eligible for compensation" | My flight was delayed about 4 hours, I'd like to check if my family and I are eligible for compensation |
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
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is retrieved |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | * Email: c***@gmail.com * Phone: +1567 |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: c@gmail.com" | Email: c@gmail.com |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides OTP code "591837" | 591837 |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP043 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR TC003: | I found 3 passengers on this booking: 1. Catherine Bouchard (Adult - Aeroplan Member) 2. Alexandre Bouchard (Adult) 3. Sophie Bouchard (Child) Would you like to |
| CP044 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes, include all 3 passengers" | Yes, include all 3 passengers |
| CP045 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 3 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP046 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: * Flight: AC 301 * Route: Montreal (YUL) ? Toronto (YYZ) * Date: January 15, 2026 * Arrival Delay: 4 hours Is this the journey yo |
| CP047 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP049 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot sends request to Case Services for duplicate check ? NO existing case found for any of the 3 passengers on this journey |  |
| CP050 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks 72-hour rule: Arrival Jan 15, 2026; filing Jan 28, 2026 ? 312 hours (>72 hours) ? PROCEED |  |
| CP051 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks APPR filing deadline: 13 days elapsed (within 366 days) ? PROCEED |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | Backend DDS executes evaluation for PNR TC003: | � Regime: APPR Applicable � Delay reason: Code 68 (Flight Crew Shortage / Crew Rest � Controllable) � Delay duration: 4 hours (Band: 3 to <6 hours) � Eligibilit |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | [x] Promised Itinerary: Flight AC 301, YUL ? YYZ, Scheduled Arrival: 14:00 | [x] Promised Itinerary: Flight AC 301, YUL ? YYZ, Scheduled Arrival: 14:00 |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | [x] Current Itinerary: Flight AC 301, YUL ? YYZ, Status: ARRIVED LATE, Actual: 18:00, Delay: +4H 00M | [x] Current Itinerary: Flight AC 301, YUL ? YYZ, Status: ARRIVED LATE, Actual: 18:00, Delay: +4H 00M |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | [x] Regime: APPR (1 regime) | [x] Regime: APPR (1 regime) |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | [x] MSL Flight: AC 301 � YUL ? YYZ � Code 68 ("Delayed due to flight crew shortage / crew rest requirement") | [x] MSL Flight: AC 301 � YUL ? YYZ � Code 68 ("Delayed due to flight crew shortage / crew rest requirement") |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | [x] Delay Classification: +4H 00M � CONTROLLABLE | [x] Delay Classification: +4H 00M � CONTROLLABLE |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | [x] Passengers: 3 Pax (Catherine Bouchard, Alexandre Bouchard, Sophie Bouchard) | [x] Passengers: 3 Pax (Catherine Bouchard, Alexandre Bouchard, Sophie Bouchard) |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Catherine Bouchard: ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 Cash / CAD 480.00 AC Wallet | Catherine Bouchard: ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 Cash / CAD 480.00 AC Wallet |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Alexandre Bouchard: ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 Cash / CAD 480.00 AC Wallet | Alexandre Bouchard: ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 Cash / CAD 480.00 AC Wallet |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Sophie Bouchard: ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 Cash / CAD 480.00 AC Wallet | Sophie Bouchard: ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 Cash / CAD 480.00 AC Wallet |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Total: CAD 1,200.00 Cash / CAD 1,440.00 AC Wallet | Total: CAD 1,200.00 Cash / CAD 1,440.00 AC Wallet |
| CP063 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Chatbot sends case details to CyberSource ? Returns GREEN LIGHT (Pass) |  |
| CP064 | ELIGIBLE RESULT DISPLAY (FD-05a) | bot | chat | Chatbot displays: "I've checked your flight details, and flight AC 301 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours due | I've checked your flight details, and flight AC 301 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours due to crew scheduling constraints (Code 6 |
| CP065 | CLAIM PAYMENT & AEROPLAN OFFER | bot | chat | Chatbot asks: "In which country will your reimbursement be deposited?" | In which country will your reimbursement be deposited? |
| CP066 | IDENTITY VERIFICATION | bot | chat | Chatbot displays "Get verified" button ? User completes Persona IDV ? Persona returns IDV PASS | Get verified |
| CP067 | CLAIM CONFIRMATION & CASE CREATION (GLOB-09) | bot | chat | Chatbot displays summary: | Please review your compensation details: Total Amount: $1,200 CAD (3 passengers x $400 CAD) Payment Method: Interac e-Transfer (c***@gmail.com) Would you like m |
| CP068 | NOTIFICATION & WRAP-UP (GLOB-11) | email | email | Adobe triggers notification email to c***@gmail.com containing: Case Reference, $1,200 CAD Cash via Interac e-Transfer, APPR regulation, Fli | Claims Dashboard Gherkin: |
| CP069 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | Given the case has been created for primary claimant "Catherine Bouchard" with PNR "TC003" covering 3 passengers |  |
| CP070 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP071 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Case Status should be "In Review" or "Done" |  |
| CP072 | NOTIFICATION & WRAP-UP (GLOB-11) | verdict | api | And the Regime should be "APPR" | APPR |
| CP073 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Disruption Reason Code should be "68 (Flight Crew Shortage / Rest)" |  |
| CP074 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Passenger Count should be 3 (Catherine Bouchard, Alexandre Bouchard, Sophie Bouchard) |  |
| CP075 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Total Compensation should display "$1,200 CAD (Cash � Interac e-Transfer)" |  |
| CP076 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the AC Wallet alternative ($1,440 CAD) should be marked as "Offered but Not Selected" |  |
| CP077 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the CyberSource result should be "GREEN" |  |
| CP078 | NOTIFICATION & WRAP-UP (GLOB-11) | idv | chat | And the IDV status should be "PASS" | PASS |
| CP079 | PAYMENT VALIDATION (GLOB-11) | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP080 | PAYMENT VALIDATION (GLOB-11) | payment | chat | Then the currency should be set to "CAD" |  |
| CP081 | PAYMENT VALIDATION (GLOB-11) | payment | chat | And the payment method should be set to "Interac e-Transfer" |  |
| CP082 | PAYMENT VALIDATION (GLOB-11) | payment | chat | And only the Interac email "c***@gmail.com" should be collected (no banking details) |  |
| CP083 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And a compensation record for "$1,200 CAD" should be created for the batch file |  |
| CP084 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And the record should be dispatched to Unifier and acknowledged |  |
| CP085 | EXPECTED RESULTS | verdict | api | DDS generates FD-APPR-EL-01 for 3 pax. | DDS generates FD-APPR-EL-01 for 3 pax. |
| CP086 | EXPECTED RESULTS | verdict | api | Delay: 4 hours. | Delay: 4 hours. |
| CP087 | EXPECTED RESULTS | verdict | api | Code: 68 (Flight Crew Shortage � Controllable). | Code: 68 (Flight Crew Shortage � Controllable). |
| CP088 | EXPECTED RESULTS | verdict | api | Regime: APPR. | Regime: APPR. |
| CP089 | EXPECTED RESULTS | verdict | chat | Total Payout: $1,200 CAD Cash via Interac e-Transfer to c***@gmail.com. | Total Payout: $1,200 CAD Cash via Interac e-Transfer to c***@gmail.com. |
