# FD_TC_135 · CHAI-31527 — checkpoints

**Goal:** EU mainland multi-leg journey (CDG?YYZ?YVR). Leg 1 completed on time. Leg 2 (YYZ?YVR) cancelled due to controllable reason (cancellation code CREW). Customer stranded at YYZ � neither returned to CDG nor reached YVR. No Travel Incomplete + EU Mainland + Controllable = flat �600. APPR also applies ($400 CAD) but EU Mainland wins. Together with EL-25 (Origin) and EL-31 (Return), this completes the EU Mainland No Travel status coverage. Validates: (1) No Travel Incomplete correctly identified, (2) Flat EU Mainland rate applied, (3) Distinction from Return (customer did NOT go back to CDG).

Methods: seed 12, chat 62, api 11, email 3, dashboard 27, implied 25, manual 9, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | EU mainland multi-leg journey (CDG?YYZ?YVR). Leg 1 completed on time. Leg 2 (YYZ?YVR) cancelled due to controllable reason (cancellation cod |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger �tienne Marchand (Adult) | PNR: single passenger �tienne Marchand (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 2 legs AC operated: Leg 1 AC 871 CDG?YYZ (on time); Leg 2 AC 121 YYZ?YVR (CANCELLED) | Journey: 2 legs AC operated: Leg 1 AC 871 CDG?YYZ (on time); Leg 2 AC 121 YYZ?YVR (CANCELLED) |
| CP004 | PREREQUISITES | prerequisite | seed | Cancellation code on Leg 2: CREW (Crew unavailability � Controllable) | Cancellation code on Leg 2: CREW (Crew unavailability � Controllable) |
| CP005 | PREREQUISITES | prerequisite | seed | Customer action: Stranded at YYZ (midpoint) | Customer action: Stranded at YYZ (midpoint) |
| CP006 | PREREQUISITES | prerequisite | seed | Did NOT reach YVR | Did NOT reach YVR |
| CP007 | PREREQUISITES | prerequisite | seed | Did NOT return to CDG | Did NOT return to CDG |
| CP008 | PREREQUISITES | prerequisite | seed | No Travel status: Incomplete | No Travel status: Incomplete |
| CP009 | PREREQUISITES | prerequisite | seed | Fallback: FALSE | Fallback: FALSE |
| CP010 | PREREQUISITES | prerequisite | seed | MSL: Leg 2 (YYZ?YVR) | MSL: Leg 2 (YYZ?YVR) |
| CP011 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (EU Mainland) + APPR | Regime: EU 261 (EU Mainland) + APPR |
| CP012 | PREREQUISITES | prerequisite | seed | Residence: France ? EUR ? BSM � Email Payment | Residence: France ? EUR ? BSM � Email Payment |
| CP013 | PREREQUISITES | prerequisite | seed | Aeroplan: NOT linked ? Cash only | Aeroplan: NOT linked ? Cash only |
| CP014 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP015 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP016 | START | customer | chat | Then user selects English |  |
| CP017 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP018 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP019 | START | customer | chat | And the user says "I flew from Paris to Toronto but my connecting flight from Toronto to Vancouver was cancelled due to a crew issue. I'm st | I flew from Paris to Toronto but my connecting flight from Toronto to Vancouver was cancelled due to a crew issue. I'm stuck in Toronto � I didn't go back to Pa |
| CP020 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP021 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP022 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP023 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "�tienne Marchand" | �tienne Marchand |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, �tienne! And, what is your booking reference number? |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC094" | PNR: TC094 |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC094 |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: e***@gmail.com Phone: +33***123 |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: e***@gmail.com" | Email: e***@gmail.com |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP037 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP039 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP041 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP043 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: �tienne Marchand (Adult) Is this who you'd like to include? |
| CP044 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP046 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Segment 1: Flight AC 871, Paris Charles de Gaulle (CDG) ? Toronto (YYZ), June 9, 2026 � COMPLETED Segment 2: Flight AC 121, Toron |
| CP047 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP049 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 CANCELLED |  |
| CP050 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot determines: Claim applies to Segment 2 (AC 121 YYZ?YVR � CANCELLED) |  |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP052 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP053 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure of Leg 2 |  |
| CP054 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure was June 9, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED |  |
| CP055 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction) = 5 years ? within limitation ? PROCEED |  |
| CP056 | REGIME DETERMINATION | system | implied | Then the system determines: Journey origin = CDG (Paris, EU Mainland) ? EU 261 (EU Mainland) |  |
| CP057 | REGIME DETERMINATION | system | implied | And the system checks: Customer stuck at midpoint (YYZ), never reached YVR, did not return to CDG ? No Travel Incomplete |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC094 | Cancellation � crew unavailability |
| CP061 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP062 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP063 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP064 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your connecting flight AC 121 from Toronto (YYZ) to Vancouver (YVR) on June 9, 2026 was cancelled. Based on  |
| CP065 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP066 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "France" | France |
| CP067 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = France ? Currency = EUR |  |
| CP068 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP069 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP070 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a �600 EUR compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a �600 EUR compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP071 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP072 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP073 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? BSM � Email Payment (France) |  |
| CP074 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | bot | chat | Then the chatbot responds: "Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email add | Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment re |
| CP075 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | system | implied | And user responds: "Yes, confirm this email." |  |
| CP076 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP077 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP078 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP084 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: �600 EUR Payment Method: BSM � Email Payment After submission, you will receive a confirmation email summarizing your eligibility, claim details |
| CP085 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP086 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP087 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP088 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP089 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP090 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP091 | NOTIFICATION | email | email | And an eligible notification email is sent to e***@gmail.com |  |
| CP092 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (�600 EUR), regulation (EU 261/2004), flight details (Leg 2: YYZ?YVR CANCELLED), |  |
| CP093 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP094 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP095 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "�tienne Marchand" with PNR "TC094" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "�tienne Marchand" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC094" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (EU Mainland) + APPR" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "�tienne Marchand" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "e***@gmail.com" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+33***123" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: CDG ? YYZ" as completed and "Segment 2: YYZ ? YVR" with claim filed as cancelled |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "�600 EUR" as EU Mainland flat rate for No Tr |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Cancellation Code should be "CREW" indicating Controllable |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dual Regime should show EU 261 EU Mainland at �600 as selected and APPR at $400 CAD as not selected |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the most generous regime should be EU 261 EU Mainland at �600 because at typical exchange rates �600 is approximately $880 CAD which is  |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under EU 261 EU Mainland with No Travel Incomplete and controllable cance |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the No Travel status should be "INCOMPLETE" as stranded at YYZ midpoint and not Return |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically and the result should be "No duplicate found" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent to "e***@gmail.com" containing "�600 EUR" and "EU 261/2004" and "Leg 2 YYZ?YVR CANC |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP127 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "France" |  |
| CP128 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "EUR" |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM � Email Payment" |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP131 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "�600" for EU Mainland No Travel Incomplete with controllable cancellation code CREW |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And this is a No Travel case so both compensation and refund should be processed |  |
| CP133 | PAYMENT VALIDATION | payment | chat | And a PS agent task should be created in Claims Dashboard for the refund |  |
| CP134 | PAYMENT VALIDATION | payment | chat | And the agent should action the refund in ARD Web and mark it as refunded |  |
| CP135 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP136 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually |  |
| CP137 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier via HSBC channel for BSM |  |
| CP138 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP139 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP140 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should record EUR amount and CAD equivalent and exchange rate and source and date |  |
| CP141 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show "�600 EUR" with payment method "Cash" via "BSM � Email Payment" and status updated via |  |
| CP142 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show a refund record with PS agent task status tracked separately |  |
| CP143 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-EL-37. | DDS returns FD-EU-EL-37. |
| CP144 | EXPECTED RESULTS | verdict | api | Trip Tracer: Leg 1 = Completed; Leg 2 = CANCELLED; MSL = Leg 2 (AC 121 YYZ?YVR); Cancellation Code = CREW (4-char Netline � Controllable); N | Trip Tracer: Leg 1 = Completed; Leg 2 = CANCELLED; MSL = Leg 2 (AC 121 YYZ?YVR); Cancellation Code = CREW (4-char Netline � Controllable); No Travel = Incomplet |
| CP145 | EXPECTED RESULTS | verdict | api | Dual Regime: EU Mainland = EL-37 (�600, No Travel Incomplete); APPR = $400 CAD (not selected). | Dual Regime: EU Mainland = EL-37 (�600, No Travel Incomplete); APPR = $400 CAD (not selected). |
| CP146 | EXPECTED RESULTS | verdict | chat | Most Generous: EU Mainland selected (�600 ? ~$880 CAD > $400). | Most Generous: EU Mainland selected (�600 ? ~$880 CAD > $400). |
| CP147 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP148 | EXPECTED RESULTS | verdict | chat | IDV: PASS. | IDV: PASS. |
| CP149 | EXPECTED RESULTS | verdict | chat | Payment: BSM � Email Payment France EUR. | Payment: BSM � Email Payment France EUR. |
| CP150 | EXPECTED RESULTS | verdict | api | Claims Dashboard: EU Mainland EL-37 ? SELECTED; �600; No Travel = Incomplete; Stranded = YYZ; MSL = Leg 2; Cancellation Code = CREW; Fallbac | Claims Dashboard: EU Mainland EL-37 ? SELECTED; �600; No Travel = Incomplete; Stranded = YYZ; MSL = Leg 2; Cancellation Code = CREW; Fallback = FALSE; Multi-leg |
