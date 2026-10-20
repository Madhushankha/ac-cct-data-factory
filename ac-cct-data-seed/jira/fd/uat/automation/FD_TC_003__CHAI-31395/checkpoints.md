# FD_TC_003 · CHAI-31395 — checkpoints

**Goal:** An end-to-end eligible claim for a 3-passenger booking on a UK departure. AC 865 LHR ? YUL arrived 5 hours late because of a controllable reason (Code 65, a flight deck crew special request that wasn't operationally required). The UK regime (EU 261 UK branch) applies because the trip starts in the UK. APPR also applies because the flight lands in Canada. Most-generous logic picks EU/UK. Compensation is GBP 520 per passenger (DELAY_GTE_4_HOURS): GBP 1,560 cash, or GBP 1,872 AC Wallet with the 20% top-up. The customer lives in Canada and picks Cash, so payment goes by Interac in CAD and only the email is collected. Also checks the EU eligible DDS response, the UK 6-year limit, CyberSource GREEN, Persona PASS, and that the Claims Dashboard shows all 3 passengers with EU/UK selected.

Methods: seed 16, chat 61, api 36, email 6, implied 62, manual 9, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | An end-to-end eligible claim for a 3-passenger booking on a UK departure. AC 865 LHR ? YUL arrived 5 hours late because of a controllable re |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR TC079: 3 passengers | PNR TC079: 3 passengers |
| CP003 | PREREQUISITES | prerequisite | seed | Catherine Bouchard (Adult, claimant, Basic Aeroplan 9876543210, good standing), Alexandre Bouchard (Adult), Sophie Bouchard (Child, paid far | Catherine Bouchard (Adult, claimant, Basic Aeroplan 9876543210, good standing), Alexandre Bouchard (Adult), Sophie Bouchard (Child, paid fare, not an infant) |
| CP004 | PREREQUISITES | prerequisite | seed | One AC international leg: AC 865 LHR ? YUL, January 15, 2026 | One AC international leg: AC 865 LHR ? YUL, January 15, 2026 |
| CP005 | PREREQUISITES | prerequisite | seed | Departure country: United Kingdom | Departure country: United Kingdom |
| CP006 | PREREQUISITES | prerequisite | seed | Scheduled arrival 14:00, actual 19:00 (5h, 300 min) | Scheduled arrival 14:00, actual 19:00 (5h, 300 min) |
| CP007 | PREREQUISITES | prerequisite | seed | Cancellation code: NONE | Cancellation code: NONE |
| CP008 | PREREQUISITES | prerequisite | seed | Arrival delay code: 65 (FR, flight deck crew special request, controllable), so Fallback = FALSE | Arrival delay code: 65 (FR, flight deck crew special request, controllable), so Fallback = FALSE |
| CP009 | PREREQUISITES | prerequisite | seed | Status: Arrived (operated) | Status: Arrived (operated) |
| CP010 | PREREQUISITES | prerequisite | seed | Delay announced less than 14 days before departure (day-of-travel) | Delay announced less than 14 days before departure (day-of-travel) |
| CP011 | PREREQUISITES | prerequisite | seed | No VOL or INVOL changes | No VOL or INVOL changes |
| CP012 | PREREQUISITES | prerequisite | seed | AC only | AC only |
| CP013 | PREREQUISITES | prerequisite | seed | Filed January 28, 2026 (D+13, more than 72 hours after arrival, within the 2190-day UK limit) | Filed January 28, 2026 (D+13, more than 72 hours after arrival, within the 2190-day UK limit) |
| CP014 | PREREQUISITES | prerequisite | seed | No duplicate | No duplicate |
| CP015 | PREREQUISITES | prerequisite | seed | Not employees | Not employees |
| CP016 | PREREQUISITES | prerequisite | implied | CyberSource set to GREEN | CyberSource set to GREEN |
| CP017 | PREREQUISITES | prerequisite | seed | Persona set to IDV PASS | Persona set to IDV PASS |
| CP018 | PREREQUISITES | prerequisite | seed | Country of residence: Canada (CAD, Interac, email only) | Country of residence: Canada (CAD, Interac, email only) |
| CP019 | GREETING & INTENT IDENTIFICATION | customer | chat | Given the user opens the agentic chatbot |  |
| CP020 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP021 | GREETING & INTENT IDENTIFICATION | customer | chat | Then user selects "English" | English |
| CP022 | GREETING & INTENT IDENTIFICATION | alert | chat | Then an alert information is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI t | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP023 | GREETING & INTENT IDENTIFICATION | bot | chat | Then chatbot asks: "How can I help you today?" | How can I help you today? |
| CP024 | GREETING & INTENT IDENTIFICATION | customer | chat | And the user says: "Our flight from London to Montreal was delayed about 5 hours because of a request from the flight crew, I'd like to chec | Our flight from London to Montreal was delayed about 5 hours because of a request from the flight crew, I'd like to check if my family and I are eligible for co |
| CP025 | GREETING & INTENT IDENTIFICATION | system | implied | When the chatbot identifies flight disruption intent |  |
| CP026 | GREETING & INTENT IDENTIFICATION | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP027 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP028 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. Please provide your f |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Catherine Bouchard" | Catherine Bouchard |
| CP031 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, Catherine! And, what is your booking reference number?" | Thanks, Catherine! And, what is your booking reference number? |
| CP032 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "TC079" | TC079 |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC079 |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP035 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details, linked Aeroplan profile) is retrieved |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: Email: c***@gmail.com / Phone: +1***567 |  |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: c***@gmail.com" | Email: c***@gmail.com |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP040 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides OTP code "591837" | 591837 |
| CP041 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP042 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP043 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | verdict | api | Then the system checks Trip Tracer for group booking identifier ? NOT PRESENT |  |
| CP044 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP045 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR TC079: | I found 3 passengers on this booking: 1. Catherine Bouchard (Adult - Aeroplan Member) 2. Alexandre Bouchard (Adult) 3. Sophie Bouchard (Child) Would you like to |
| CP046 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes, include all 3 passengers" | Yes, include all 3 passengers |
| CP047 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 3 ? 9 or fewer ? NOT a group booking ? PROCEED |  |
| CP048 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 865 Route: London Heathrow (LHR) ? Montreal (YUL) Date: January 15, 2026 Arrival Delay: 5 hours Is this the journey yo |
| CP049 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP050 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP051 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot sends request to Case Services for duplicate check ? NO existing case found for any of the 3 passengers on this journey |  |
| CP052 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks 72-hour rule: Arrival Jan 15, 2026; filing Jan 28, 2026 ? 312 hours (more than 72 hours) ? PROCEED |  |
| CP053 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks filing deadline: UK departure ? 2190 days (6 years); 13 days elapsed ? within limit ? PROCEED |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend for PNR TC079 |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks journey origin: LHR (United Kingdom) ? UK regime applicable (EU 261 UK branch) |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks destination: YUL (Canada) ? APPR also applicable |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | And DDS identifies MSL = AC 865 LHR ? YUL (only segment) |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the cancellation code on MSL ? NONE |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the first arrival delay code on MSL ? 65 (FR) ? no fallback needed |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | And DDS classifies 65 (FR) as CONTROLLABLE (flight deck crew special request � within carrier control) |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks disruption notice: less than 14 days before departure ? compensation applies |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | And DDS calculates delay = 19:00 ? 14:00 = 300 min ? UK band DELAY_GTE_4_HOURS |  |
| CP063 | TRIAGE & DDS EVALUATION | verdict | api | And DDS evaluates UK entitlement: GBP 520 per passenger x 3 = GBP 1,560 |  |
| CP064 | TRIAGE & DDS EVALUATION | verdict | api | And DDS evaluates APPR entitlement (comparison): Tier 1 (3 to <6 hrs) CAD 400 per passenger x 3 = CAD 1,200 |  |
| CP065 | TRIAGE & DDS EVALUATION | verdict | api | And DDS applies Most Generous logic ? EU/UK selected over APPR |  |
| CP066 | TRIAGE & DDS EVALUATION | verdict | api | And DDS returns EU ELIGIBLE for all 3 passengers and sends results to Trip Tracer UI |  |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary: Flight AC 865, LHR ? YUL, Scheduled Arrival: 14:00 | Promised Itinerary: Flight AC 865, LHR ? YUL, Scheduled Arrival: 14:00 |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary: Flight AC 865, LHR ? YUL, Status: ARRIVED LATE, 14:00 ? 19:00, Delay: +5H 00M | Current Itinerary: Flight AC 865, LHR ? YUL, Status: ARRIVED LATE, 14:00 ? 19:00, Delay: +5H 00M |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | History: No booking changes (no VOL or INVOL) | History: No booking changes (no VOL or INVOL) |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Regimes: EU (UK) + APPR (2 regimes) ? Most Generous = EU/UK | Regimes: EU (UK) + APPR (2 regimes) ? Most Generous = EU/UK |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | MSL Flight: AC 865 � LHR ? YUL � Code 65 (FR) � "Delayed due to flight deck crew special request" | MSL Flight: AC 865 � LHR ? YUL � Code 65 (FR) � "Delayed due to flight deck crew special request" |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | Cancellation code: NONE ; Fallback: FALSE | Cancellation code: NONE ; Fallback: FALSE |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | Delay Classification: +5H 00M � CONTROLLABLE | Delay Classification: +5H 00M � CONTROLLABLE |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: 9876543210 (Basic Member � linked) | Aeroplan: 9876543210 (Basic Member � linked) |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | Passengers: 3 Pax (Catherine Bouchard, Alexandre Bouchard, Sophie Bouchard) | Passengers: 3 Pax (Catherine Bouchard, Alexandre Bouchard, Sophie Bouchard) |
| CP076 | TRIP TRACER UI VALIDATION | verdict | api | MS CATHERINE BOUCHARD / ELIGIBLE / DELAY_GTE_4_HOURS / GBP 520.00 Cash / GBP 624.00 AC Wallet / [expiry date] | MS CATHERINE BOUCHARD / ELIGIBLE / DELAY_GTE_4_HOURS / GBP 520.00 Cash / GBP 624.00 AC Wallet / [expiry date] |
| CP077 | TRIP TRACER UI VALIDATION | verdict | api | MR ALEXANDRE BOUCHARD / ELIGIBLE / DELAY_GTE_4_HOURS / GBP 520.00 Cash / GBP 624.00 AC Wallet / [expiry date] | MR ALEXANDRE BOUCHARD / ELIGIBLE / DELAY_GTE_4_HOURS / GBP 520.00 Cash / GBP 624.00 AC Wallet / [expiry date] |
| CP078 | TRIP TRACER UI VALIDATION | verdict | api | MISS SOPHIE BOUCHARD / ELIGIBLE / DELAY_GTE_4_HOURS / GBP 520.00 Cash / GBP 624.00 AC Wallet / [expiry date] | MISS SOPHIE BOUCHARD / ELIGIBLE / DELAY_GTE_4_HOURS / GBP 520.00 Cash / GBP 624.00 AC Wallet / [expiry date] |
| CP079 | TRIP TRACER UI VALIDATION | verdict | api | Total: GBP 1,560.00 Cash / GBP 1,872.00 AC Wallet | Total: GBP 1,560.00 Cash / GBP 1,872.00 AC Wallet |
| CP080 | TRIP TRACER UI VALIDATION | verdict | api | APPR comparison: CAD 1,200 (not selected) | APPR comparison: CAD 1,200 (not selected) |
| CP081 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource |  |
| CP082 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN LIGHT (Pass) |  |
| CP083 | ELIGIBLE RESULT DISPLAY (FD-05a) | bot | chat | Then the chatbot displays: "I've checked your flight details, and it looks like flight AC 865 from London Heathrow (LHR) to Montreal (YUL) w | I've checked your flight details, and it looks like flight AC 865 from London Heathrow (LHR) to Montreal (YUL) was delayed by about 5 hours. Because your journe |
| CP084 | CLAIM PAYMENT & AEROPLAN OFFER | bot | chat | Then the chatbot asks: "Thank you for confirming. In which country will your reimbursement be deposited?" | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP085 | CLAIM PAYMENT & AEROPLAN OFFER | customer | chat | And the user selects "Canada" ? Currency = CAD | Canada |
| CP086 | CLAIM PAYMENT & AEROPLAN OFFER | system | implied | Then the chatbot checks Aeroplan status: Catherine Bouchard has linked Aeroplan 9876543210, Basic Member in good standing |  |
| CP087 | CLAIM PAYMENT & AEROPLAN OFFER | bot | chat | And the chatbot offers BOTH payment options: | Since you are an Aeroplan member, you can choose to receive for all 3 passengers: Cash: GBP 1,560 total (GBP 520 x 3), deposited in your local currency (CAD) vi |
| CP088 | CLAIM PAYMENT & AEROPLAN OFFER | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP089 | CLAIM PAYMENT & AEROPLAN OFFER | customer | chat | And the user selects "Cash" | Cash |
| CP090 | CLAIM PAYMENT & AEROPLAN OFFER | system | implied | Then the system checks which payment method is mapped based on country of residence ? Interac (CANADA) |  |
| CP091 | CLAIM PAYMENT & AEROPLAN OFFER | bot | chat | Then the chatbot responds: "Your payment will be made through Interac e-Transfer. Before we move forward, please confirm the email address w | Your payment will be made through Interac e-Transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP092 | CLAIM PAYMENT & AEROPLAN OFFER | customer | chat | And the user confirms: "Yes, use this email" | Yes, use this email |
| CP093 | CLAIM PAYMENT & AEROPLAN OFFER | system | implied | Then the chatbot does NOT ask for bank account, card, transit or institution numbers |  |
| CP094 | CLAIM PAYMENT & AEROPLAN OFFER | idv | chat | Then the system checks that IDV is not completed |  |
| CP095 | IDENTITY VERIFICATION | bot | chat | Then the chatbot responds: "I must verify your identity for payment security. Please click here to get started" | I must verify your identity for payment security. Please click here to get started |
| CP096 | IDENTITY VERIFICATION | bot | chat | And the chatbot displays a "Get verified" button | Get verified |
| CP097 | IDENTITY VERIFICATION | customer | chat | When the user clicks on the button |  |
| CP098 | IDENTITY VERIFICATION | idv | chat | Then the system checks IDV at Payment and consent |  |
| CP099 | IDENTITY VERIFICATION | idv | chat | And the chatbot sends the Persona link |  |
| CP100 | IDENTITY VERIFICATION | system | implied | And the customer completes verification |  |
| CP101 | IDENTITY VERIFICATION | idv | chat | And Persona returns: IDV PASS |  |
| CP102 | IDENTITY VERIFICATION | bot | chat | Then the chatbot responds: "Your identity has been verified successfully. Let's proceed to finalize your claim." | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP103 | CLAIM CONFIRMATION & CASE CREATION (GLOB-09) | bot | chat | Then the chatbot displays: | Please review your compensation details: Total Amount: GBP 1,560 (3 passengers x GBP 520), deposited in CAD Payment Method: Interac e-Transfer (c***@gmail.com)  |
| CP104 | CLAIM CONFIRMATION & CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP105 | CLAIM CONFIRMATION & CASE CREATION (GLOB-09) | system | implied | When the user responds "Yes" |  |
| CP106 | CLAIM CONFIRMATION & CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP107 | CLAIM CONFIRMATION & CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP108 | CLAIM CONFIRMATION & CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP109 | NOTIFICATION & WRAP-UP (GLOB-11) | email | email | Then Adobe sends an eligible notification email to c***@gmail.com |  |
| CP110 | NOTIFICATION & WRAP-UP (GLOB-11) | email | email | And the email contains: Case Reference, GBP 1,560 Cash (paid in CAD via Interac e-Transfer), regulation (UK / EU 261), Flight AC 865 (LHR ?  |  |
| CP111 | NOTIFICATION & WRAP-UP (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No] | Is there anything I can help you with? |
| CP112 | NOTIFICATION & WRAP-UP (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP113 | NOTIFICATION & WRAP-UP (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP114 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | Given the case has been created for primary claimant "Catherine Bouchard" with PNR "TC079" covering 3 passengers |  |
| CP115 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" mapped from chatbot intent |  |
| CP116 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP117 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Case Status should be "In Review" or "Done" |  |
| CP118 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Created date and Last Updated date should be populated |  |
| CP119 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the SLA countdown should be tracking correctly against the EU261 SLA |  |
| CP120 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Team assignment should be correct |  |
| CP121 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP122 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Decision Assist panel should NOT be greyed out |  |
| CP123 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Claimant Name should be "Catherine Bouchard" |  |
| CP124 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Claimant Type should be "Adult" |  |
| CP125 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Authentication should be "Pass" |  |
| CP126 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the PNR should be "TC079" |  |
| CP127 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated |  |
| CP128 | NOTIFICATION & WRAP-UP (GLOB-11) | verdict | api | And the Regime should be "EU (UK)" with APPR also listed as applicable | EU (UK) |
| CP129 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Most Generous selection should be "EU/UK" |  |
| CP130 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And all 3 passengers should be listed (Catherine Bouchard, Alexandre Bouchard, Sophie Bouchard) |  |
| CP131 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Tags for the claimant should include "Claimant" and "Adult" |  |
| CP132 | NOTIFICATION & WRAP-UP (GLOB-11) | email | email | And the Email should be "c***@gmail.com" | c***@gmail.com |
| CP133 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Phone should be "+1***567" |  |
| CP134 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Address should be populated |  |
| CP135 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Aeroplan should be "9876543210" linked and in good standing (Basic Member) |  |
| CP136 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Tier Status should be "Basic / Member" |  |
| CP137 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Journey should show "Bound 1: LHR ? YUL" with claim filed for this flight |  |
| CP138 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Disruption Code should show "Code 65 (FR � flight deck crew special request) � Controllable" |  |
| CP139 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Ancillary Fee section should be present and empty |  |
| CP140 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Eligibility and Compensation section should show "GBP 1,560 (GBP 520 x 3) � Cash, Interac e-Transfer in CAD" |  |
| CP141 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the AC Wallet option (GBP 1,872) should be visible as the offered alternative but NOT selected |  |
| CP142 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the APPR amount (CAD 1,200) should be shown as assessed but NOT applied |  |
| CP143 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP144 | NOTIFICATION & WRAP-UP (GLOB-11) | verdict | api | And DDS should have run automatically with no agent action needed |  |
| CP145 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the eligibility decision should be pre-populated as "ELIGIBLE" (EU/UK, Code 65 Controllable, 5h delay, DELAY_GTE_4_HOURS) |  |
| CP146 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Duplicate Check should have run automatically across all 3 passengers using baseline data "Catherine Bouchard + TC079 + LHR?YUL + FD |  |
| CP147 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the result should be "No duplicate found" |  |
| CP148 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And no Duplicate Warning Banner should be displayed |  |
| CP149 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Related Cases tab should show no related cases |  |
| CP150 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the CyberSource result should be "GREEN" |  |
| CP151 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP152 | NOTIFICATION & WRAP-UP (GLOB-11) | idv | chat | And the Persona IDV result should be "PASS" | PASS |
| CP153 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the system should have appended the booking record to the case automatically |  |
| CP154 | NOTIFICATION & WRAP-UP (GLOB-11) | verdict | api | And Trip Tracer poll should NOT be required |  |
| CP155 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the agent should have used pull case from My Activities to get this case |  |
| CP156 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP157 | NOTIFICATION & WRAP-UP (GLOB-11) | email | email | And a case acknowledgement notification should have been sent to the customer |  |
| CP158 | NOTIFICATION & WRAP-UP (GLOB-11) | email | email | And an eligible notification email should have been sent via Adobe containing GBP 1,560 Cash, Interac e-Transfer and Code 65 |  |
| CP159 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Agent Notes section should be accessible |  |
| CP160 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP161 | NOTIFICATION & WRAP-UP (GLOB-11) | email | email | And Customer Communications should show the notification email chronologically |  |
| CP162 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the chatbot transcript should be accessible and linked |  |
| CP163 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Attachments tab should be empty |  |
| CP164 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the Final Status should be "Resolved" |  |
| CP165 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP166 | NOTIFICATION & WRAP-UP (GLOB-11) | system | implied | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP167 | PAYMENT VALIDATION (GLOB-11) | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP168 | PAYMENT VALIDATION (GLOB-11) | payment | chat | Then the currency should be set to "CAD" |  |
| CP169 | PAYMENT VALIDATION (GLOB-11) | payment | chat | And the payment method should be set to "Interac e-Transfer" |  |
| CP170 | PAYMENT VALIDATION (GLOB-11) | payment | chat | And the customer has Aeroplan "9876543210" linked with Basic Member status in good standing |  |
| CP171 | PAYMENT VALIDATION (GLOB-11) | payment | chat | And both options should have been offered: Cash (GBP 1,560) AND AC Wallet (GBP 1,872 with 20% top-up) |  |
| CP172 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And the customer selected "Cash" ? AC Wallet payout NOT dispatched |  |
| CP173 | PAYMENT VALIDATION (GLOB-11) | payment | chat | And only the Interac email "c***@gmail.com" should be collected (no banking details) |  |
| CP174 | PAYMENT VALIDATION (GLOB-11) | payment | chat | And the GBP 1,560 entitlement should be converted to CAD for the payout |  |
| CP175 | PAYMENT VALIDATION (GLOB-11) | payment | chat | And exactly one compensation record should be created with the CAD equivalent of GBP 1,560 |  |
| CP176 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And the record should be picked up by the daily evening batch file |  |
| CP177 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And the record should be dispatched to Unifier |  |
| CP178 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier team |  |
| CP179 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And Unifier should send an acknowledgement back |  |
| CP180 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And the end-of-day report should be received from Interac |  |
| CP181 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And the status should be "Pending" transitioning to "Cashed" or "Rejected" or "Expired" |  |
| CP182 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And if the customer does not claim the Interac payment within 35 days the status should be set to "Expired" |  |
| CP183 | PAYMENT VALIDATION (GLOB-11) | payment | chat | And payment for this controllable EU/UK claim should be issued within 30 days of submission |  |
| CP184 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And the Claims Dashboard Compensation tab should show the GBP entitlement, CAD paid amount, exchange rate, payment method (Cash � Interac e- |  |
| CP185 | EXPECTED RESULTS | verdict | api | DDS returns an EU eligible response for all 3 passengers (UK departure). | DDS returns an EU eligible response for all 3 passengers (UK departure). |
| CP186 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 14:00, Actual = 19:00, Delay = 5 hours, MSL = Leg 1 (AC 865 LHR ? YUL), no cancellation code, arrival code 65 (FR) co | Trip Tracer: Promise = 14:00, Actual = 19:00, Delay = 5 hours, MSL = Leg 1 (AC 865 LHR ? YUL), no cancellation code, arrival code 65 (FR) controllable, Fallback |
| CP187 | EXPECTED RESULTS | verdict | chat | Compensation: GBP 520 x 3 = GBP 1,560 cash, paid in CAD by Interac to c***@gmail.com. | Compensation: GBP 520 x 3 = GBP 1,560 cash, paid in CAD by Interac to c***@gmail.com. |
| CP188 | EXPECTED RESULTS | verdict | chat | AC Wallet (GBP 1,872) offered but not selected. | AC Wallet (GBP 1,872) offered but not selected. |
| CP189 | EXPECTED RESULTS | verdict | chat | APPR (CAD 1,200) not applied. | APPR (CAD 1,200) not applied. |
| CP190 | EXPECTED RESULTS | verdict | chat | CyberSource GREEN. | CyberSource GREEN. |
| CP191 | EXPECTED RESULTS | verdict | chat | Persona PASS. | Persona PASS. |
