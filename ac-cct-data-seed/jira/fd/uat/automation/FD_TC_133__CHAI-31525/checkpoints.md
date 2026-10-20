# FD_TC_133 · CHAI-31525 — checkpoints

**Goal:** UK-originating multi-leg journey (LHR?YYZ?YVR). Leg 1 completed on time. Leg 2 (YYZ?YVR) cancelled due to controllable reason (cancellation code CREW). Customer remained stranded at YYZ (midpoint) � did not reach final destination YVR and did not return to LHR. No Travel Incomplete + UK + Controllable = flat �520. APPR also applies but EU-UK wins.

Methods: seed 12, chat 65, api 11, email 3, dashboard 30, implied 25, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | UK-originating multi-leg journey (LHR?YYZ?YVR). Leg 1 completed on time. Leg 2 (YYZ?YVR) cancelled due to controllable reason (cancellation  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Oliver Bennett (Adult) | PNR: single passenger Oliver Bennett (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 2 legs AC operated: Leg 1 AC 849 LHR?YYZ (arrived on time); Leg 2 AC 121 YYZ?YVR (CANCELLED) | Journey: 2 legs AC operated: Leg 1 AC 849 LHR?YYZ (arrived on time); Leg 2 AC 121 YYZ?YVR (CANCELLED) |
| CP004 | PREREQUISITES | prerequisite | seed | Cancellation code on Leg 2: CREW (Crew unavailability � Controllable) | Cancellation code on Leg 2: CREW (Crew unavailability � Controllable) |
| CP005 | PREREQUISITES | prerequisite | seed | Customer action: Remained stranded at YYZ (midpoint) | Customer action: Remained stranded at YYZ (midpoint) |
| CP006 | PREREQUISITES | prerequisite | seed | Did NOT reach YVR | Did NOT reach YVR |
| CP007 | PREREQUISITES | prerequisite | seed | Did NOT return to LHR | Did NOT return to LHR |
| CP008 | PREREQUISITES | prerequisite | seed | No Travel status: Incomplete | No Travel status: Incomplete |
| CP009 | PREREQUISITES | prerequisite | seed | Fallback: FALSE | Fallback: FALSE |
| CP010 | PREREQUISITES | prerequisite | seed | MSL: Leg 2 (YYZ?YVR) | MSL: Leg 2 (YYZ?YVR) |
| CP011 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (UK) + APPR | Regime: EU 261 (UK) + APPR |
| CP012 | PREREQUISITES | prerequisite | seed | Residence: UK ? GBP ? BSM � Email Payment | Residence: UK ? GBP ? BSM � Email Payment |
| CP013 | PREREQUISITES | prerequisite | seed | Aeroplan: NOT linked ? Cash only | Aeroplan: NOT linked ? Cash only |
| CP014 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP015 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP016 | START | customer | chat | Then user selects English |  |
| CP017 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP018 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP019 | START | customer | chat | And the user says "I flew from London Heathrow to Toronto but my connecting flight from Toronto to Vancouver was cancelled due to a crew iss | I flew from London Heathrow to Toronto but my connecting flight from Toronto to Vancouver was cancelled due to a crew issue. I'm stuck in Toronto and never made |
| CP020 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP021 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP022 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP023 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Oliver Bennett" | Oliver Bennett |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Oliver! And, what is your booking reference number? |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC092" | PNR: TC092 |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC092 |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: o***@gmail.com Phone: +44***456 |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: o***@gmail.com" | Email: o***@gmail.com |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP037 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP039 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP041 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP043 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Oliver Bennett (Adult) Is this who you'd like to include? |
| CP044 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP046 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Segment 1: Flight AC 849, London Heathrow (LHR) ? Toronto (YYZ), June 4, 2026 � COMPLETED Segment 2: Flight AC 121, Toronto (YYZ) |
| CP047 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP049 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 CANCELLED |  |
| CP050 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot determines: Claim applies to Segment 2 (AC 121 YYZ?YVR � CANCELLED) |  |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP052 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP053 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure of Leg 2 |  |
| CP054 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure was June 4, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED |  |
| CP055 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (UK) = 6 years ? within limitation ? PROCEED |  |
| CP056 | REGIME DETERMINATION | system | implied | Then the system determines: Journey origin = LHR (UK) ? EU 261 (UK) applies to entire journey |  |
| CP057 | REGIME DETERMINATION | system | implied | And the system checks: Customer stuck at midpoint (YYZ), never reached YVR, did not return to LHR ? No Travel Incomplete |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC092 | Cancellation � crew unavailability |
| CP061 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP062 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP063 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP064 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your connecting flight AC 121 from Toronto (YYZ) to Vancouver (YVR) on June 4, 2026 was cancelled. Based on  |
| CP065 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP066 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "United Kingdom" | United Kingdom |
| CP067 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = UK ? Currency = GBP |  |
| CP068 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP069 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP070 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a �520 GBP compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a �520 GBP compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP071 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP072 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP073 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? BSM � Email Payment (UK) |  |
| CP074 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | bot | chat | Then the chatbot responds: "Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email add | Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment re |
| CP075 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | system | implied | And user responds: "Yes, confirm this email." |  |
| CP076 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP077 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP078 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP085 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP086 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP087 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �520 GBP Payment Method: BSM � Email Payment After submission, you will receive a confirmation email summarizing your eligibility, claim details |
| CP088 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP089 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP090 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP091 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP092 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP093 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP094 | NOTIFICATION | email | email | And an eligible notification email is sent to o***@gmail.com |  |
| CP095 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�520 GBP), regulation (EU 261 UK), flight details (Leg 2: YYZ?YVR CANCELLED), t |  |
| CP096 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP097 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP098 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Oliver Bennett" with PNR "TC092" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Oliver Bennett" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC092" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (UK) + APPR" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Oliver Bennett" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "o***@gmail.com" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+44***456" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: LHR ? YYZ" as completed and "Segment 2: YYZ ? YVR" with claim filed as cancelled |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "�520 GBP" as UK flat rate for No Travel Inco |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Cancellation Code should be "CREW" indicating Controllable |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dual Regime should show EU 261 UK at �520 as selected and APPR at $400 CAD as not selected |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the most generous regime should be EU 261 UK at �520 because at typical exchange rates �520 is approximately $880 CAD which is greater t |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 UK with No Travel Incomplete and controllable cancellation c |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the No Travel status should be "INCOMPLETE" as the customer did NOT go back to LHR |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically and the result should be "No duplicate found" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent to "o***@gmail.com" containing "�520 GBP" and "EU 261 UK" and "Leg 2 YYZ?YVR CANCEL |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP134 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "United Kingdom" |  |
| CP135 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "GBP" |  |
| CP136 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM � Email Payment" |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP138 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "�520" for EU UK No Travel Incomplete with controllable cancellation code CREW |  |
| CP139 | PAYMENT VALIDATION | payment | chat | And this is a No Travel case so both compensation and refund should be processed |  |
| CP140 | PAYMENT VALIDATION | payment | chat | And a PS agent task should be created in Claims Dashboard for the refund |  |
| CP141 | PAYMENT VALIDATION | payment | chat | And the agent should action the refund in ARD Web and mark it as refunded |  |
| CP142 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP143 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually |  |
| CP144 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier via HSBC channel for BSM |  |
| CP145 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP146 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP147 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should record GBP amount and CAD equivalent and exchange rate and source and date |  |
| CP148 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show "�520 GBP" with payment method "Cash" via "BSM � Email Payment" and status updated via |  |
| CP149 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show a refund record with PS agent task status tracked separately |  |
| CP150 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-EL-33. | DDS returns FD-EU-EL-33. |
| CP151 | EXPECTED RESULTS | verdict | api | Trip Tracer: Leg 1 = Completed (on time); Leg 2 = CANCELLED; MSL = Leg 2 (AC 121 YYZ?YVR); Cancellation Code = CREW (4-char Netline � Contro | Trip Tracer: Leg 1 = Completed (on time); Leg 2 = CANCELLED; MSL = Leg 2 (AC 121 YYZ?YVR); Cancellation Code = CREW (4-char Netline � Controllable); No Travel = |
| CP152 | EXPECTED RESULTS | verdict | api | Dual Regime: EU-UK = EL-33 (�520, No Travel Incomplete); APPR = $400 CAD (not selected). | Dual Regime: EU-UK = EL-33 (�520, No Travel Incomplete); APPR = $400 CAD (not selected). |
| CP153 | EXPECTED RESULTS | verdict | chat | Most Generous: EU-UK selected (�520 ? ~$880 CAD > $400). | Most Generous: EU-UK selected (�520 ? ~$880 CAD > $400). |
| CP154 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP155 | EXPECTED RESULTS | verdict | chat | IDV: PASS. | IDV: PASS. |
| CP156 | EXPECTED RESULTS | verdict | chat | Payment: BSM � Email Payment UK GBP. | Payment: BSM � Email Payment UK GBP. |
| CP157 | EXPECTED RESULTS | verdict | api | Claims Dashboard: EU-UK EL-33 ? SELECTED; No Travel = Incomplete; MSL = Leg 2; Cancellation Code = CREW; Fallback = FALSE; Multi-leg (LHR?YY | Claims Dashboard: EU-UK EL-33 ? SELECTED; No Travel = Incomplete; MSL = Leg 2; Cancellation Code = CREW; Fallback = FALSE; Multi-leg (LHR?YYZ?YVR); DDS = FD-EU- |
