# FD_TC_152 · CHAI-31544 — checkpoints

**Goal:** Israel-bound flight (YYZ?TLV, AC-operated) cancelled due to non-extraordinary reason (cancellation code CREW � crew unavailability, controllable). Customer remained at origin (YYZ), did not travel. Under ASL No Travel rules, when MSL is cancelled and disruption is Not Extraordinary, customer is entitled to ILS 3,670 + expenses + pro-rated/full ticket refund.

Methods: seed 12, chat 35, api 11, email 1, dashboard 23, implied 11, manual 7, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Israel-bound flight (YYZ?TLV, AC-operated) cancelled due to non-extraordinary reason (cancellation code CREW � crew unavailability, controll |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Yael Levi (Adult) | PNR: single passenger Yael Levi (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 082, YYZ?TLV | Journey: 1 leg AC operated, Flight AC 082, YYZ?TLV |
| CP004 | PREREQUISITES | prerequisite | seed | Flight status: CANCELLED | Flight status: CANCELLED |
| CP005 | PREREQUISITES | prerequisite | seed | Cancellation code: CREW (Crew unavailability � Not Extraordinary Circumstance / Controllable) | Cancellation code: CREW (Crew unavailability � Not Extraordinary Circumstance / Controllable) |
| CP006 | PREREQUISITES | prerequisite | seed | Customer action: Remained at YYZ (origin), did not travel | Customer action: Remained at YYZ (origin), did not travel |
| CP007 | PREREQUISITES | prerequisite | seed | No Travel status: Origin | No Travel status: Origin |
| CP008 | PREREQUISITES | prerequisite | seed | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP009 | PREREQUISITES | prerequisite | seed | MSL: AC 082 YYZ?TLV | MSL: AC 082 YYZ?TLV |
| CP010 | PREREQUISITES | prerequisite | seed | Regime: ASL (Israel destination) + APPR (Canadian origin) | Regime: ASL (Israel destination) + APPR (Canadian origin) |
| CP011 | PREREQUISITES | prerequisite | seed | Residence: Israel ? ILS ? BSM � Email Payment | Residence: Israel ? ILS ? BSM � Email Payment |
| CP012 | PREREQUISITES | prerequisite | seed | Aeroplan: NOT linked ? Cash only | Aeroplan: NOT linked ? Cash only |
| CP013 | PREREQUISITES | prerequisite | seed | Result: ELIGIBLE � ILS 3,670 + Expenses + Refund | Result: ELIGIBLE � ILS 3,670 + Expenses + Refund |
| CP014 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP015 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP016 | START | customer | chat | Then user selects English |  |
| CP017 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP018 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP019 | START | customer | chat | And the user says "My flight from Toronto to Tel Aviv was cancelled due to a crew issue and I didn't take any replacement flight. I stayed i | My flight from Toronto to Tel Aviv was cancelled due to a crew issue and I didn't take any replacement flight. I stayed in Toronto. Can I get compensation? |
| CP020 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP021 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP022 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP023 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Yael Levi" | Yael Levi |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Yael! And, what is your booking reference number? |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC118" | PNR: TC118 |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC118 |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: y***@gmail.com Phone: +972***789 |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: y***@gmail.com" | Email: y***@gmail.com |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" ? CORRECT (attempt 1 of 5) | 518293 |
| CP035 | JOURNEY SELECTION (GenUC-08) | system | implied | "I found the following journey: | Flight: AC 082 Route: Toronto (YYZ) ? Tel Aviv (TLV) Date: June 3, 2026 Status: CANCELLED Is this the journey you'd like to check?" |
| CP036 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP037 | REGIME DETERMINATION | system | implied | Then the system determines: Destination = TLV (Israel) ? ASL applies |  |
| CP038 | REGIME DETERMINATION | system | implied | And the system checks: Origin = YYZ (Canada) ? APPR also applies |  |
| CP039 | REGIME DETERMINATION | verdict | api | And the system checks: Flight CANCELLED ? MSL cancelled ? meets ASL No Travel threshold |  |
| CP040 | REGIME DETERMINATION | system | implied | And the system checks: Customer remained at origin (YYZ) ? No Travel Origin ? Branch A |  |
| CP041 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP042 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP043 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC118 | Cancellation � crew unavailability |
| CP044 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | CyberSource ? GREEN LIGHT |  |
| CP045 | ELIGIBLE RESULT (FD-05a) | system | implied | "I've checked your flight details, and it looks like flight AC 082 from Toronto (YYZ) to Tel Aviv (TLV) on June 3, 2026 was cancelled. Based |  |
| CP046 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | User selects "Israel" ? Currency = ILS | Israel |
| CP047 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | No Aeroplan ? "You are entitled to receive a ?3,670 ILS compensation." | ? BSM � Email Payment (Israel) |
| CP048 | PAYMENT METHOD � BSM EMAIL PAYMENT (FD-07) | idv | chat | Email confirmation ? IDV via Persona ? IDV PASS |  |
| CP049 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | "Deposit Amount: ?3,670 ILS / Payment Method: BSM � Email Payment" ? User confirms "Yes" | Deposit Amount: ?3,670 ILS / Payment Method: BSM � Email Payment Yes |
| CP050 | CASE CREATION (GLOB-09) | system | implied | Claim submitted ? Booking auto-appended |  |
| CP051 | NOTIFICATION | email | email | Eligible notification email sent to y***@gmail.com containing: ?3,670 ILS, ASL, YYZ?TLV CANCELLED, No Travel - Origin, cancellation code CRE |  |
| CP052 | END FLOW (GLOB-11) | system | implied | "Thank you for choosing Air Canada." |  |
| CP053 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Yael Levi" with PNR "TC118" |  |
| CP054 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation" |  |
| CP055 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP056 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP057 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP058 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP059 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Yael Levi" |  |
| CP060 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP061 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC118" |  |
| CP062 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL + APPR" |  |
| CP063 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Yael Levi" |  |
| CP064 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "y***@gmail.com" |  |
| CP065 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+972***789" |  |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YYZ ? TLV" with claim filed as cancelled |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "?3,670 ILS" as ASL fixed rate for No Travel  |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Cancellation Code should be "CREW" as Not Extraordinary Circumstance |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And No Travel should include Compensation at ?3,670 plus Expenses plus pro-rated or full ticket refund |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under ASL with No Travel Origin and Not Extraordinary and cancellation co |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically and the result should be "No duplicate found" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP078 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Israel" |  |
| CP079 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "ILS" |  |
| CP080 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM � Email Payment" |  |
| CP081 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP082 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "?3,670" as ASL fixed rate for No Travel Origin Not Extraordinary with cancellation code CREW |  |
| CP083 | PAYMENT VALIDATION | payment | chat | And this is a No Travel case so compensation plus expenses plus pro-rated or full ticket refund should be processed |  |
| CP084 | PAYMENT VALIDATION | payment | chat | And a PS agent task should be created in Claims Dashboard for the refund |  |
| CP085 | PAYMENT VALIDATION | payment | chat | And the agent should action the refund in ARD Web and mark it as refunded |  |
| CP086 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP087 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually |  |
| CP088 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier via HSBC channel for BSM |  |
| CP089 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP090 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP091 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should record ILS amount and CAD equivalent and exchange rate and source and date |  |
| CP092 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show "?3,670 ILS" with payment method "Cash" via "BSM � Email Payment" and status updated v |  |
| CP093 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show a refund record with PS agent task status tracked separately |  |
| CP094 | EXPECTED RESULTS | verdict | api | DDS returns FD-ASL-EL-05. | DDS returns FD-ASL-EL-05. |
| CP095 | EXPECTED RESULTS | verdict | api | Trip Tracer: CANCELLED; MSL = AC 082 YYZ?TLV; Cancellation Code = CREW (4-char Netline � Not Extraordinary Circumstance / Controllable); No  | Trip Tracer: CANCELLED; MSL = AC 082 YYZ?TLV; Cancellation Code = CREW (4-char Netline � Not Extraordinary Circumstance / Controllable); No Travel = Origin (cus |
| CP096 | EXPECTED RESULTS | verdict | api | ASL No Travel: Branch A (remained at origin) ? MSL cancelled ? Not Extraordinary ? ELIGIBLE. | ASL No Travel: Branch A (remained at origin) ? MSL cancelled ? Not Extraordinary ? ELIGIBLE. |
| CP097 | EXPECTED RESULTS | verdict | chat | Compensation: ILS 3,670 + Expenses + Pro-rated/full ticket refund. | Compensation: ILS 3,670 + Expenses + Pro-rated/full ticket refund. |
| CP098 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP099 | EXPECTED RESULTS | verdict | chat | IDV: PASS. | IDV: PASS. |
| CP100 | EXPECTED RESULTS | verdict | chat | Payment: BSM � Email Payment Israel ILS. | Payment: BSM � Email Payment Israel ILS. |
| CP101 | EXPECTED RESULTS | verdict | api | Claims Dashboard: ASL EL-05; ELIGIBLE; No Travel = Origin; Not Extraordinary (CREW); ?3,670 ILS; DDS = FD-ASL-EL-05. | Claims Dashboard: ASL EL-05; ELIGIBLE; No Travel = Origin; Not Extraordinary (CREW); ?3,670 ILS; DDS = FD-ASL-EL-05. |
