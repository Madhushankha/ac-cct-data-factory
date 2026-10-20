# FD_TC_131 · CHAI-31523 — checkpoints

**Goal:** EU mainland flight (CDG?YYZ, AC-operated) cancelled due to controllable reason (cancellation code CREW). Customer declined rebooking and remained at CDG. No Travel Origin + EU Mainland + Controllable = flat �600. APPR also applies (Canada destination) at $400 CAD � EU Mainland wins (�600 ? ~$880 CAD > $400).

Methods: seed 10, chat 66, api 11, email 3, dashboard 29, implied 25, manual 9, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | EU mainland flight (CDG?YYZ, AC-operated) cancelled due to controllable reason (cancellation code CREW). Customer declined rebooking and rem |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Beno�t Leclerc (Adult) | PNR: single passenger Beno�t Leclerc (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 871, CDG?YYZ | Journey: 1 leg AC operated, Flight AC 871, CDG?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Flight status: CANCELLED | Flight status: CANCELLED |
| CP005 | PREREQUISITES | prerequisite | seed | Cancellation code: CREW (Crew unavailability � Controllable) | Cancellation code: CREW (Crew unavailability � Controllable) |
| CP006 | PREREQUISITES | prerequisite | seed | Customer action: Declined rebooking, remained at CDG | Customer action: Declined rebooking, remained at CDG |
| CP007 | PREREQUISITES | prerequisite | seed | No Travel status: Origin | No Travel status: Origin |
| CP008 | PREREQUISITES | prerequisite | seed | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP009 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (EU Mainland) + APPR (Canada destination) | Regime: EU 261 (EU Mainland) + APPR (Canada destination) |
| CP010 | PREREQUISITES | prerequisite | seed | Residence: France ? EUR ? BSM � Email Payment | Residence: France ? EUR ? BSM � Email Payment |
| CP011 | PREREQUISITES | prerequisite | seed | Aeroplan: NOT linked ? Cash only | Aeroplan: NOT linked ? Cash only |
| CP012 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP013 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP014 | START | customer | chat | Then user selects English |  |
| CP015 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP016 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP017 | START | customer | chat | And the user says "My flight from Paris to Toronto was cancelled due to a crew issue and I didn't take any replacement flight. Can I get com | My flight from Paris to Toronto was cancelled due to a crew issue and I didn't take any replacement flight. Can I get compensation? |
| CP018 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP019 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP020 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP021 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP024 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Beno�t Leclerc" | Beno�t Leclerc |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Beno�t! And, what is your booking reference number? |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC087" | PNR: TC087 |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC087 |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: b***@gmail.com Phone: +33***901 |
| CP032 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: b***@gmail.com" | Email: b***@gmail.com |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP035 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP037 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Beno�t Leclerc (Adult) Is this who you'd like to include? |
| CP042 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP044 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 871 Route: Paris Charles de Gaulle (CDG) ? Toronto (YYZ) Date: June 1, 2026 Status: CANCELLED Is this the journey you' |
| CP045 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure |  |
| CP050 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure was June 1, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction) = 5 years ? within limitation ? PROCEED |  |
| CP052 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = CDG (Paris, EU Mainland) ? EU 261 (EU Mainland) |  |
| CP053 | REGIME DETERMINATION | system | implied | And the system checks: Destination = YYZ (Toronto, Canada) ? APPR also applies |  |
| CP054 | REGIME DETERMINATION | system | implied | And the system checks: Customer did NOT travel ? No Travel Origin (remained at CDG) |  |
| CP055 | REGIME DETERMINATION | system | implied | And the system checks: EU Mainland No Travel Origin = flat �600 (no distance band split for No Travel) |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC087 | Cancellation � crew unavailability |
| CP059 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP060 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP061 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP062 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 871 from Paris Charles de Gaulle (CDG) to Toronto (YYZ) on June 1, 2026 was cancelled. Based on th |
| CP063 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP064 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "France" | France |
| CP065 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = France ? Currency = EUR |  |
| CP066 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP067 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP068 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a �600 EUR compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a �600 EUR compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP069 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP070 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP071 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? BSM � Email Payment (France) |  |
| CP072 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | bot | chat | Then the chatbot responds: "Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email add | Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment re |
| CP073 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | system | implied | And user responds: "Yes, confirm this email." |  |
| CP074 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP075 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP076 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP077 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP078 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP085 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �600 EUR Payment Method: BSM � Email Payment After submission, you will receive a confirmation email summarizing your eligibility, claim details |
| CP086 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP087 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP088 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP089 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP090 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP091 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP092 | NOTIFICATION | email | email | And an eligible notification email is sent to b***@gmail.com |  |
| CP093 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�600 EUR), regulation (EU 261/2004), flight details (CDG?YYZ CANCELLED), travel |  |
| CP094 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP095 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP096 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Beno�t Leclerc" with PNR "TC087" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Beno�t Leclerc" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC087" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (EU Mainland) + APPR" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Beno�t Leclerc" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "b***@gmail.com" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+33***901" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: CDG ? YYZ" with claim filed for this flight as cancelled |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "�600 EUR" as EU Mainland flat rate for No Tr |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Cancellation Code should be "CREW" as a 4-character Netline code indicating Controllable |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dual Regime should show EU 261 EU Mainland at �600 as selected and APPR at $400 CAD as not selected |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the most generous regime should be EU 261 EU Mainland at �600 because at typical exchange rates �600 is approximately $880 CAD which is  |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 EU Mainland with No Travel Origin and controllable cancellat |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically and the result should be "No duplicate found" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent to "b***@gmail.com" containing "�600 EUR" and "EU 261/2004" and "CDG?YYZ CANCELLED" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP130 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "France" |  |
| CP131 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "EUR" |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM � Email Payment" |  |
| CP133 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP134 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "�600" for EU Mainland No Travel Origin with controllable cancellation code CREW |  |
| CP135 | PAYMENT VALIDATION | payment | chat | And this is a No Travel case so both compensation and refund should be processed |  |
| CP136 | PAYMENT VALIDATION | payment | chat | And a PS agent task should be created in Claims Dashboard for the refund |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And the agent should action the refund in ARD Web and mark it as refunded |  |
| CP138 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP139 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually |  |
| CP140 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier via HSBC channel for BSM |  |
| CP141 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP142 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP143 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should record EUR amount and CAD equivalent and exchange rate and source and date |  |
| CP144 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show "�600 EUR" with payment method "Cash" via "BSM � Email Payment" and status updated via |  |
| CP145 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show a refund record with PS agent task status tracked separately |  |
| CP146 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-EL-25. | DDS returns FD-EU-EL-25. |
| CP147 | EXPECTED RESULTS | verdict | api | Trip Tracer: CANCELLED; Cancellation Code = CREW; No Travel = Origin; Fallback = FALSE (cancellation code available � used first per Gate 9  | Trip Tracer: CANCELLED; Cancellation Code = CREW; No Travel = Origin; Fallback = FALSE (cancellation code available � used first per Gate 9 priority); EU 261 (E |
| CP148 | EXPECTED RESULTS | verdict | chat | EU Mainland No Travel Origin = flat �600 . | EU Mainland No Travel Origin = flat �600 . |
| CP149 | EXPECTED RESULTS | verdict | api | Dual Regime: EU Mainland = EL-25 (�600); APPR = $400 CAD (not selected). | Dual Regime: EU Mainland = EL-25 (�600); APPR = $400 CAD (not selected). |
| CP150 | EXPECTED RESULTS | verdict | chat | Most Generous: EU Mainland selected (�600 ? ~$880 CAD > $400). | Most Generous: EU Mainland selected (�600 ? ~$880 CAD > $400). |
| CP151 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP152 | EXPECTED RESULTS | verdict | chat | IDV: PASS. | IDV: PASS. |
| CP153 | EXPECTED RESULTS | verdict | chat | Payment: BSM � Email Payment France EUR. | Payment: BSM � Email Payment France EUR. |
| CP154 | EXPECTED RESULTS | verdict | api | Claims Dashboard: EU Mainland EL-25 ? SELECTED; �600; APPR $400 (not selected); No Travel = Origin; Cancellation Code = CREW; Fallback = FAL | Claims Dashboard: EU Mainland EL-25 ? SELECTED; �600; APPR $400 (not selected); No Travel = Origin; Cancellation Code = CREW; Fallback = FALSE; DDS = FD-EU-EL-2 |
