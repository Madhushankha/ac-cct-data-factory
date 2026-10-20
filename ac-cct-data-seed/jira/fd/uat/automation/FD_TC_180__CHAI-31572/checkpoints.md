# FD_TC_180 · CHAI-31572 — checkpoints

**Goal:** A different person (e.g., travel agent, spouse) files a claim for a passenger who was already compensated on a previous claim filed by the passenger themselves. System detects that the PASSENGER has already been compensated even though the CLAIMANT is different. Validates that duplicate detection is passenger-based, not claimant-based.

Methods: seed 5, chat 72, api 16, email 3, dashboard 36, implied 29, manual 12, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | A different person (e.g., travel agent, spouse) files a claim for a passenger who was already compensated on a previous claim filed by the p |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: 2 passengers (Catherine Bouchard + Marc Bouchard), 1 leg AC domestic YUL?YYZ | PNR: 2 passengers (Catherine Bouchard + Marc Bouchard), 1 leg AC domestic YUL?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Original claim: Catherine filed for herself, $400 paid | Original claim: Catherine filed for herself, $400 paid |
| CP004 | PREREQUISITES | prerequisite | seed | Second claim: Marc Bouchard files a new claim and includes Catherine as a passenger to claim for | Second claim: Marc Bouchard files a new claim and includes Catherine as a passenger to claim for |
| CP005 | PREREQUISITES | prerequisite | seed | Duplicate indicators: Catherine's passenger record already has compensation paid on original case | Duplicate indicators: Catherine's passenger record already has compensation paid on original case |
| CP006 | PREREQUISITES | prerequisite | seed | Marc's claim for himself is NEW (not duplicate) | Marc's claim for himself is NEW (not duplicate) |
| CP007 | BACKGROUND � ORIGINAL CASE | system | implied | Given a case was previously created and completed: | ? Original Case Reference: CASE-FD-20260501-002 ? Claimant: Catherine Bouchard (filed for herself only) ? PNR: TC198 ? Passengers on PNR: Catherine Bouchard (Ad |
| CP008 | SECOND CLAIM � MARC FILES FOR BOTH | customer | chat | Given the user opens the agentic chatbot |  |
| CP009 | SECOND CLAIM � MARC FILES FOR BOTH | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP010 | SECOND CLAIM � MARC FILES FOR BOTH | customer | chat | Then user selects English |  |
| CP011 | SECOND CLAIM � MARC FILES FOR BOTH | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP012 | SECOND CLAIM � MARC FILES FOR BOTH | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP013 | SECOND CLAIM � MARC FILES FOR BOTH | customer | chat | And the user says "My flight from Montreal to Toronto on May 1st was delayed 4 hours. I'd like to file a compensation claim for myself and m | My flight from Montreal to Toronto on May 1st was delayed 4 hours. I'd like to file a compensation claim for myself and my wife |
| CP014 | SECOND CLAIM � MARC FILES FOR BOTH | system | implied | When the chatbot identifies flight disruption intent |  |
| CP015 | SECOND CLAIM � MARC FILES FOR BOTH | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO (Marc is a passenger on the PNR) |  |
| CP016 | SECOND CLAIM � MARC FILES FOR BOTH | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP017 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP018 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP020 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Marc Bouchard" | Marc Bouchard |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Marc! And, what is your booking reference number? |
| CP022 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC198" | PNR: TC198 |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC198 |  |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: m***@gmail.com � Phone: +1***345 |
| CP028 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: m***@gmail.com" | Email: m***@gmail.com |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP030 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP031 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP033 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP034 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP035 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP036 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP037 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 2 passengers on this booking: � Marc Bouchard (Adult) � Catherine Bouchard (Adult) Who would you like to include? |
| CP038 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user selects BOTH passengers (Marc + Catherine) |  |
| CP039 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 2 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP040 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 422 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: May 1, 2026 � Arrival Delay: 4 hours Is this the journey you'd l |
| CP041 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment? ? NO ? skip GenUC-18 |  |
| CP043 | DUPLICATE CLAIM CHECK � PER-PASSENGER DUPLICATE CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP044 | DUPLICATE CLAIM CHECK � PER-PASSENGER DUPLICATE CHECK (GenUC-10) | system | implied | And Case Services checks EACH PASSENGER INDIVIDUALLY: |  |
| CP045 | MARC BOUCHARD � DUPLICATE CHECK | system | implied | ? PNR: TC198 + Passenger: Marc Bouchard + Flight: AC 422 + Date: May 1, 2026 | ? Existing Case for Marc on this flight: NONE FOUND ? Marc's Duplicate Status: NOT A DUPLICATE � NEW CLAIM |
| CP046 | CATHERINE BOUCHARD � DUPLICATE CHECK | system | implied | ? PNR: TC198 + Passenger: Catherine Bouchard + Flight: AC 422 + Date: May 1, 2026 | ? Existing Case: CASE-FD-20260501-002 ? Existing Case Claimant: Catherine Bouchard (filed for herself) ? Existing Case Status: CLOSED ($400 CAD PAID to Catherin |
| CP047 | MIXED DUPLICATE RESULT | system | implied | ? Marc Bouchard: NOT DUPLICATE (new claim � eligible for assessment) | ? Catherine Bouchard: DUPLICATE (already compensated on CASE-FD-20260501-002) KEY INSIGHT: Duplicate detection is PASSENGER-BASED, not CLAIMANT-BASED. Even thou |
| CP048 | DUPLICATE NOTIFICATION TO CUSTOMER | bot | chat | Then the chatbot responds: | I've checked the records for both passengers: For Marc Bouchard: No previous claim found for this flight. I'll proceed with your claim. For Catherine Bouchard:  |
| CP049 | DUPLICATE NOTIFICATION TO CUSTOMER | customer | chat | And the user confirms "Yes, please proceed for Marc" | Yes, please proceed for Marc |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP051 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline ? within limitation ? PROCEED |  |
| CP052 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YUL (Canada) ? APPR |  |
| CP053 | REGIME DETERMINATION | system | implied | And the system checks: Distance YUL?YYZ = ~505 km ? Short-haul |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend for Marc Bouchard only |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates: | ? APPR: Delay 3�6h, Controllable ? ELIGIBLE ? Compensation: CAD $400 (Marc Bouchard only) |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | Passenger 1: Marc Bouchard ? NEW CLAIM ? ELIGIBLE $400 CAD | Passenger 1: Marc Bouchard ? NEW CLAIM ? ELIGIBLE $400 CAD |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Passenger 2: Catherine Bouchard ? DUPLICATE (already compensated on CASE-FD-20260501-002) | Passenger 2: Catherine Bouchard ? DUPLICATE (already compensated on CASE-FD-20260501-002) |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Duplicate Detection: PASSENGER-BASED (not claimant-based) | Duplicate Detection: PASSENGER-BASED (not claimant-based) |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Claimant on original case: Catherine Bouchard (herself) | Claimant on original case: Catherine Bouchard (herself) |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Claimant on new case: Marc Bouchard (different person) | Claimant on new case: Marc Bouchard (different person) |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | System correctly identified Catherine as duplicate despite different claimant | System correctly identified Catherine as duplicate despite different claimant |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | MR MARC BOUCHARD / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 | MR MARC BOUCHARD / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | MS CATHERINE BOUCHARD / DUPLICATE / ALREADY_COMPENSATED / CAD $0 | MS CATHERINE BOUCHARD / DUPLICATE / ALREADY_COMPENSATED / CAD $0 |
| CP064 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening (for Marc only) |  |
| CP065 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP066 | ELIGIBLE RESULT � MARC ONLY (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details. Flight AC 422 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours. For Marc Bouchard: Based on the Canadian Air  |
| CP067 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP068 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP069 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP070 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP071 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No (only 1 eligible � Marc) |  |
| CP072 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "Marc Bouchard is entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business day | Marc Bouchard is entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP073 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP074 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP075 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada) |  |
| CP076 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer. |
| CP077 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | customer | chat | And the user provides "marc.bouchard@gmail.com" | marc.bouchard@gmail.com |
| CP078 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | system | implied | Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded." |  |
| CP079 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP085 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP086 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP087 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP088 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP089 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP090 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Marc Bouchard: $400 CAD Catherine Bouchard: Not eligible (already compensated) Total Deposit Amount: $400 CAD Payment Method: Interac e-Transfer After submissio |
| CP091 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP092 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP093 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP094 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP095 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP096 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP097 | NOTIFICATION | email | email | And notification email is sent to m***@gmail.com |  |
| CP098 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation details (Marc: $400 CAD eligible; Catherine: duplicate � already compensated), regulati |  |
| CP099 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP100 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP101 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the new case by PNR |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � New Case Title: "Travel Disruptions � Delay" � Status: in review/done � Claimant: Marc Bouchard � Regime: APPR |
| CP105 | PASSENGER INFORMATION | system | implied | � Marc Bouchard: Tags: Claimant, Adult � ELIGIBLE ($400 CAD) � NEW CLAIM | � Catherine Bouchard: Tags: Adult � DUPLICATE (already compensated on CASE-FD-20260501-002) |
| CP106 | LINKED CASES | system | implied | � Original Case: CASE-FD-20260501-002 (Catherine's original claim � $400 PAID) |  |
| CP107 | ELIGIBILITY AND COMPENSATION | system | implied | � Marc Bouchard: ELIGIBLE � $400 CAD | � Catherine Bouchard: DUPLICATE � $0 (already compensated) |
| CP108 | DUPLICATE DETECTION VALIDATION | system | implied | ? Different claimant (Marc vs Catherine): YES ? | ? Same PNR: YES (TC198) ? ? Same flight: YES (AC 422, May 1, 2026) ? ? Catherine already compensated: YES ($400 on CASE-FD-20260501-002) ? ? Duplicate detection |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Marc Bouchard" with the same PNR as the original claim containing two passengers |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" as partial with Marc's claim new and Catherine's duplicate |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a Partial Duplicate Warning Banner should be displayed as one passenger is duplicate and one is new |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out for Marc's new claim |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Marc Bouchard" as new claimant different from original claimant Catherine |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Passenger 1 DUPLICATE BLOCKED should be Catherine Bouchard with Tags Adult and DUPLICATE and Duplicate Status already compensated on pri |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Passenger 2 NEW eligible for assessment should be Marc Bouchard with Tags Claimant and Adult |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" same flight as original claim |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Catherine Bouchard DUPLICATE should show DUPLICATE FOUND at individual passenger level with Catherine's passenger record already having  |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Marc Bouchard NEW CLAIM should show NOT DUPLICATE as first-time claim for this passenger and DDS assessment should proceed normally and  |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And duplicate detection should be at the INDIVIDUAL PASSENGER level NOT PNR or claimant level |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Catherine should be Blocked as duplicate passenger and Marc should Proceed as new passenger claim |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a different claimant filing should NOT bypass duplicate detection for already-compensated passengers |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run for Marc Bouchard only as Catherine is blocked as duplicate |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Marc should be ELIGIBLE under APPR and Catherine should be DUPLICATE blocked with original case referenced |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should show Catherine Bouchard as DUPLICATE FOUND already compensated on prior case and Marc Bouchard as NOT DUPLICA |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" as it ran for eligible Marc Bouchard only |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a notification email should have been sent to Marc Bouchard containing Marc Eligible $400 and Catherine Duplicate already compensated or |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record passenger-level duplicate detection with Catherine duplicate and Marc new |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the original case ID should be logged for Catherine |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Marc's assessment should be logged as new eligible claim |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" with Marc's claim processed and Catherine's blocked |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should link to Catherine's original case |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP148 | PAYMENT VALIDATION | payment | chat | Given the result is MIXED with Marc Bouchard NEW eligible for payment and Catherine Bouchard DUPLICATE blocked already compensated on CASE-F |  |
| CP149 | PAYMENT VALIDATION | payment | chat | Then the customer's country of residence should be "Canada" |  |
| CP150 | PAYMENT VALIDATION | payment | chat | And the currency should be set to "CAD" |  |
| CP151 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" for Marc only |  |
| CP152 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP153 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "$400 CAD" for Marc Bouchard only as single eligible passenger |  |
| CP154 | PAYMENT VALIDATION | payment | chat | And Catherine Bouchard should receive $0 as already compensated $400 CAD on original case CASE-FD-20260501-002 paid May 14 2026 and NO new c |  |
| CP155 | PAYMENT VALIDATION | payment | chat | And the Interac e-Transfer email should be collected for Marc |  |
| CP156 | PAYMENT VALIDATION | payment | chat | And IDV at Payment should be triggered via Persona for Marc and IDV PASS should be required before claim submission |  |
| CP157 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created for Marc only in the backend with GL account and cost center |  |
| CP158 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP159 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier and Unifier should send acknowledgement for Marc's $400 only |  |
| CP160 | PAYMENT VALIDATION | payment | manual | And the end-of-day report from Interac should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP161 | PAYMENT VALIDATION | payment | manual | And if Marc does not claim Interac within 35 days the status should be Expired |  |
| CP162 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details "$400 CAD" for Marc only with payment method "Cash" via "Interac" and s |  |
| CP163 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show Catherine's record as DUPLICATE with $0 and original case ID referenced and original payment $400 CAD a |  |
| CP164 | PAYMENT VALIDATION | payment | chat | And duplicate detection should be at the INDIVIDUAL PASSENGER level NOT PNR or claimant level and Catherine should be blocked as duplicate e |  |
| CP165 | PAYMENT VALIDATION | payment | chat | And the total payout for this case should be "$400 CAD" for 1 eligible passenger multiplied by $400 NOT $800 CAD |  |
| CP166 | EXPECTED RESULTS | verdict | api | DDS returns FD-DUP-NE-02 (for Catherine) + FD-APPR-EL-01 (for Marc). | DDS returns FD-DUP-NE-02 (for Catherine) + FD-APPR-EL-01 (for Marc). |
| CP167 | EXPECTED RESULTS | verdict | chat | Duplicate Detection: Catherine Bouchard ? DUPLICATE FOUND (already compensated on prior case). | Duplicate Detection: Catherine Bouchard ? DUPLICATE FOUND (already compensated on prior case). |
| CP168 | EXPECTED RESULTS | verdict | chat | Marc Bouchard ? NOT DUPLICATE (first-time claim, proceed with assessment). | Marc Bouchard ? NOT DUPLICATE (first-time claim, proceed with assessment). |
| CP169 | EXPECTED RESULTS | verdict | chat | CRITICAL: Duplicate detection must be at the INDIVIDUAL PASSENGER level, not PNR or claimant level. | CRITICAL: Duplicate detection must be at the INDIVIDUAL PASSENGER level, not PNR or claimant level. |
| CP170 | EXPECTED RESULTS | verdict | chat | Catherine is blocked; Marc proceeds normally. | Catherine is blocked; Marc proceeds normally. |
| CP171 | EXPECTED RESULTS | verdict | chat | Compensation: Catherine = $0 (duplicate); Marc = $400 (new eligible claim). | Compensation: Catherine = $0 (duplicate); Marc = $400 (new eligible claim). |
| CP172 | EXPECTED RESULTS | verdict | dashboard | Claims Dashboard: Catherine: Duplicate; Original case referenced; Blocked. | Claims Dashboard: Catherine: Duplicate; Original case referenced; Blocked. |
| CP173 | EXPECTED RESULTS | verdict | chat | Marc: Eligible; $400; New claim processed. | Marc: Eligible; $400; New claim processed. |
| CP174 | EXPECTED RESULTS | verdict | api | DDS = FD-DUP-NE-02. | DDS = FD-DUP-NE-02. |
