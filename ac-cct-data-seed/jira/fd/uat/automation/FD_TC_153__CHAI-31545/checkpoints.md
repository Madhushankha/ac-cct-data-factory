# FD_TC_153 · CHAI-31545 — checkpoints

**Goal:** Israel-bound multi-leg journey (YYZ?YUL?TLV). Leg 1 completed on time. Leg 2 (YUL?TLV) cancelled due to non-extraordinary reason (cancellation code CREW). Customer stranded at YUL (midpoint) � did not return to YYZ, did not reach TLV. Under ASL No Travel rules, Branch B applies (did not remain at origin) ? MSL cancelled ? Not Extraordinary ? ILS 3,670 + Expenses + Pro-rated/full ticket refund.

Methods: seed 13, chat 65, api 12, email 3, dashboard 29, implied 25, manual 8, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Israel-bound multi-leg journey (YYZ?YUL?TLV). Leg 1 completed on time. Leg 2 (YUL?TLV) cancelled due to non-extraordinary reason (cancellati |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Avi Goldstein (Adult) | PNR: single passenger Avi Goldstein (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 2 legs AC operated: Leg 1 AC 410 YYZ?YUL (on time); Leg 2 AC 084 YUL?TLV (CANCELLED) | Journey: 2 legs AC operated: Leg 1 AC 410 YYZ?YUL (on time); Leg 2 AC 084 YUL?TLV (CANCELLED) |
| CP004 | PREREQUISITES | prerequisite | seed | Cancellation code on Leg 2: CREW (Crew unavailability � Not Extraordinary) | Cancellation code on Leg 2: CREW (Crew unavailability � Not Extraordinary) |
| CP005 | PREREQUISITES | prerequisite | seed | Customer action: Stranded at YUL (midpoint) | Customer action: Stranded at YUL (midpoint) |
| CP006 | PREREQUISITES | prerequisite | seed | Did NOT return to YYZ | Did NOT return to YYZ |
| CP007 | PREREQUISITES | prerequisite | seed | Did NOT reach TLV | Did NOT reach TLV |
| CP008 | PREREQUISITES | prerequisite | seed | No Travel status: Incomplete | No Travel status: Incomplete |
| CP009 | PREREQUISITES | prerequisite | seed | Fallback: FALSE | Fallback: FALSE |
| CP010 | PREREQUISITES | prerequisite | seed | MSL: Leg 2 (YUL?TLV) | MSL: Leg 2 (YUL?TLV) |
| CP011 | PREREQUISITES | prerequisite | seed | Regime: ASL (Israel destination) + APPR (Canadian origin) | Regime: ASL (Israel destination) + APPR (Canadian origin) |
| CP012 | PREREQUISITES | prerequisite | seed | Residence: Israel ? ILS ? BSM � Email Payment | Residence: Israel ? ILS ? BSM � Email Payment |
| CP013 | PREREQUISITES | prerequisite | seed | Aeroplan: NOT linked ? Cash only | Aeroplan: NOT linked ? Cash only |
| CP014 | PREREQUISITES | prerequisite | seed | Result: ELIGIBLE � ILS 3,670 + Expenses + Refund | Result: ELIGIBLE � ILS 3,670 + Expenses + Refund |
| CP015 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP016 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP017 | START | customer | chat | Then user selects English |  |
| CP018 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP019 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP020 | START | customer | chat | And the user says "I flew from Toronto to Montreal but my connecting flight from Montreal to Tel Aviv was cancelled due to a crew issue. I'm | I flew from Toronto to Montreal but my connecting flight from Montreal to Tel Aviv was cancelled due to a crew issue. I'm stuck in Montreal � I didn't go back t |
| CP021 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP022 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP023 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP024 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Avi Goldstein" | Avi Goldstein |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Avi! And, what is your booking reference number? |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC120" | PNR: TC120 |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC120 |  |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: a***@gmail.com Phone: +972***567 |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: a***@gmail.com" | Email: a***@gmail.com |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP038 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP040 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP041 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP042 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP043 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP044 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Avi Goldstein (Adult) Is this who you'd like to include? |
| CP045 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP047 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Segment 1: Flight AC 410, Toronto (YYZ) ? Montreal (YUL), June 7, 2026 � COMPLETED Segment 2: Flight AC 084, Montreal (YUL) ? Tel |
| CP048 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP049 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP050 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 CANCELLED |  |
| CP051 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot determines: Claim applies to Segment 2 (AC 084 YUL?TLV � CANCELLED) |  |
| CP052 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP053 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP054 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure of Leg 2 |  |
| CP055 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure was June 7, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED |  |
| CP056 | CLAIM TIME LIMIT CHECK | verdict | api | Then the chatbot checks: Filing deadline for ASL = 1,460 days (4 years) from MSL scheduled departure date ? within limitation ? PROCEED |  |
| CP057 | REGIME DETERMINATION | system | implied | Then the system determines: Destination = TLV (Israel) ? ASL applies |  |
| CP058 | REGIME DETERMINATION | system | implied | And the system checks: Origin = YYZ (Canada) ? APPR also applies |  |
| CP059 | REGIME DETERMINATION | system | implied | And the system checks: Customer stuck at midpoint (YUL), never reached TLV, did not return to YYZ ? No Travel Incomplete ? Branch B (did not |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC120 | Cancellation � crew unavailability |
| CP063 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP064 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP065 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP066 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your connecting flight AC 084 from Montreal (YUL) to Tel Aviv (TLV) on June 7, 2026 was cancelled. Based on  |
| CP067 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP068 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Israel" | Israel |
| CP069 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Israel ? Currency = ILS |  |
| CP070 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP071 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP072 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a ?3,670 ILS compensation. Please note that it will take 5 to 10 business days to pr | You are entitled to receive a ?3,670 ILS compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP073 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP074 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP075 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? BSM � Email Payment (Israel) |  |
| CP076 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | bot | chat | Then the chatbot responds: "Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email add | Your payment will be made through electronic bank transfer. Before we move forward, please confirm the email address where you'd like to receive your payment re |
| CP077 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | system | implied | And user responds: "Yes, confirm this email." |  |
| CP078 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP085 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP086 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP087 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP088 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP089 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: ?3,670 ILS Payment Method: BSM � Email Payment After submission, you will receive a confirmation email summarizing your eligibility, claim detai |
| CP090 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP091 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP092 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP093 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP094 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP095 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP096 | NOTIFICATION | email | email | And an eligible notification email is sent to a***@gmail.com |  |
| CP097 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (?3,670 ILS), regulation (ASL � Israel Aviation Services Law), flight details (L |  |
| CP098 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP099 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP100 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Avi Goldstein" with PNR "TC120" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Avi Goldstein" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC120" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL + APPR" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Avi Goldstein" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "a***@gmail.com" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+972***567" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: YYZ ? YUL" as completed and "Segment 2: YUL ? TLV" with claim filed as cancelled |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "?3,670 ILS" as ASL fixed rate for No Travel  |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Cancellation Code should be "CREW" as Not Extraordinary Circumstance |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And No Travel should include Compensation at ?3,670 plus Expenses plus pro-rated or full ticket refund |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the ASL No Travel Branch should be "B" as the customer did not remain at origin and is stranded at midpoint YUL |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under ASL with No Travel Incomplete and Not Extraordinary and cancellatio |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the No Travel status should be "INCOMPLETE" as stranded at YUL midpoint |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically and the result should be "No duplicate found" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent to "a***@gmail.com" containing "?3,670 ILS" and "ASL" and "Leg 2 YUL?TLV CANCELLED" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP133 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Israel" |  |
| CP134 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "ILS" |  |
| CP135 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM � Email Payment" |  |
| CP136 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "?3,670" as ASL fixed rate for No Travel Incomplete Not Extraordinary with cancellation code CREW |  |
| CP138 | PAYMENT VALIDATION | payment | chat | And this is a No Travel case so compensation plus expenses plus pro-rated or full ticket refund should be processed |  |
| CP139 | PAYMENT VALIDATION | payment | chat | And a PS agent task should be created in Claims Dashboard for the refund |  |
| CP140 | PAYMENT VALIDATION | payment | chat | And the agent should action the refund in ARD Web and mark it as refunded |  |
| CP141 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP142 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually |  |
| CP143 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier via HSBC channel for BSM |  |
| CP144 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP145 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP146 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should record ILS amount and CAD equivalent and exchange rate and source and date |  |
| CP147 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show "?3,670 ILS" with payment method "Cash" via "BSM � Email Payment" and status updated v |  |
| CP148 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show a refund record with PS agent task status tracked separately |  |
| CP149 | EXPECTED RESULTS | verdict | api | DDS returns FD-ASL-EL-09. | DDS returns FD-ASL-EL-09. |
| CP150 | EXPECTED RESULTS | verdict | api | Trip Tracer: Leg 1 = Completed; Leg 2 = CANCELLED; MSL = Leg 2 (AC 084 YUL?TLV); Cancellation Code = CREW (4-char Netline � Not Extraordinar | Trip Tracer: Leg 1 = Completed; Leg 2 = CANCELLED; MSL = Leg 2 (AC 084 YUL?TLV); Cancellation Code = CREW (4-char Netline � Not Extraordinary Circumstance / Con |
| CP151 | EXPECTED RESULTS | verdict | api | ASL No Travel: Branch B (did not remain at origin � at midpoint) ? MSL cancelled ? Not Extraordinary ? ELIGIBLE. | ASL No Travel: Branch B (did not remain at origin � at midpoint) ? MSL cancelled ? Not Extraordinary ? ELIGIBLE. |
| CP152 | EXPECTED RESULTS | verdict | chat | Compensation: ILS 3,670 + Expenses + Pro-rated/full ticket refund. | Compensation: ILS 3,670 + Expenses + Pro-rated/full ticket refund. |
| CP153 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP154 | EXPECTED RESULTS | verdict | chat | IDV: PASS. | IDV: PASS. |
| CP155 | EXPECTED RESULTS | verdict | chat | Payment: BSM � Email Payment Israel ILS. | Payment: BSM � Email Payment Israel ILS. |
| CP156 | EXPECTED RESULTS | verdict | api | Claims Dashboard: ASL EL-09; ELIGIBLE; No Travel = Incomplete; Stranded = YUL; Not Extraordinary (CREW); ?3,670 ILS; Multi-leg (YYZ?YUL?TLV) | Claims Dashboard: ASL EL-09; ELIGIBLE; No Travel = Incomplete; Stranded = YUL; Not Extraordinary (CREW); ?3,670 ILS; Multi-leg (YYZ?YUL?TLV); Branch B; DDS = FD |
