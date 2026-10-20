# FD_TC_151 · CHAI-31543 — checkpoints

**Goal:** Israel-bound flight (YYZ?TLV, AC-operated) delayed 9 hours at arrival due to non-extraordinary reason (arrival delay code 42 � crew scheduling, controllable). Delay exceeds the 8-hour ASL threshold (Gate 8). Under ASL, non-extraordinary = within carrier's control = ILS 3,670 compensation. APPR also applies (Canadian origin) but ASL is assessed.

Methods: seed 11, chat 62, api 13, email 3, dashboard 27, implied 23, manual 8, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Israel-bound flight (YYZ?TLV, AC-operated) delayed 9 hours at arrival due to non-extraordinary reason (arrival delay code 42 � crew scheduli |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger David Cohen (Adult) | PNR: single passenger David Cohen (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 082, YYZ?TLV | Journey: 1 leg AC operated, Flight AC 082, YYZ?TLV |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 06:00 (local TLV) | Scheduled arrival: 06:00 (local TLV) |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival: 15:00 (local TLV) | Actual arrival: 15:00 (local TLV) |
| CP006 | PREREQUISITES | prerequisite | seed | Delay: 9 hours | Delay: 9 hours |
| CP007 | PREREQUISITES | prerequisite | seed | Arrival delay code: 42 (Crew scheduling � Not Extraordinary Circumstance / Controllable) | Arrival delay code: 42 (Crew scheduling � Not Extraordinary Circumstance / Controllable) |
| CP008 | PREREQUISITES | prerequisite | seed | Fallback: FALSE (arrival delay code available) | Fallback: FALSE (arrival delay code available) |
| CP009 | PREREQUISITES | prerequisite | seed | Regime: ASL (Israel destination � TLV) + APPR (Canadian origin � YYZ) | Regime: ASL (Israel destination � TLV) + APPR (Canadian origin � YYZ) |
| CP010 | PREREQUISITES | prerequisite | seed | Residence: Israel ? ILS ? BSM � Email Payment | Residence: Israel ? ILS ? BSM � Email Payment |
| CP011 | PREREQUISITES | prerequisite | seed | Aeroplan: NOT linked ? Cash only | Aeroplan: NOT linked ? Cash only |
| CP012 | PREREQUISITES | prerequisite | seed | Result: ELIGIBLE � ILS 3,670 | Result: ELIGIBLE � ILS 3,670 |
| CP013 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP014 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP015 | START | customer | chat | Then user selects English |  |
| CP016 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP017 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP018 | START | customer | chat | And the user says "My flight from Toronto to Tel Aviv was delayed about 9 hours due to a crew issue. Can I get compensation?" | My flight from Toronto to Tel Aviv was delayed about 9 hours due to a crew issue. Can I get compensation? |
| CP019 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP020 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP021 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP022 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "David Cohen" | David Cohen |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, David! And, what is your booking reference number? |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC117" | PNR: TC117 |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC117 |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: d***@gmail.com Phone: +972***456 |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: d***@gmail.com" | Email: d***@gmail.com |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP036 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP038 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: David Cohen (Adult) Is this who you'd like to include? |
| CP043 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP045 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 082 Route: Toronto (YYZ) ? Tel Aviv (TLV) Date: June 1, 2026 Arrival Delay: 9 hours Is this the journey you'd like to  |
| CP046 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP047 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP051 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was June 1, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED |  |
| CP052 | CLAIM TIME LIMIT CHECK | verdict | api | Then the chatbot checks: Filing deadline for ASL = 1,460 days (4 years) from MSL scheduled departure date ? within limitation ? PROCEED |  |
| CP053 | REGIME DETERMINATION | system | implied | Then the system determines: Destination = TLV (Israel) ? ASL applies (flights to and from Israel) |  |
| CP054 | REGIME DETERMINATION | system | implied | And the system checks: Origin = YYZ (Canada) ? APPR also applies |  |
| CP055 | REGIME DETERMINATION | system | implied | And the system checks: Arrival delay = 9 hours ? ? 8 hours ? meets ASL threshold (Gate 8) |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC117 | Delayed due to crew scheduling |
| CP059 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP060 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP061 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP062 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 082 from Toronto (YYZ) to Tel Aviv (TLV) on June 1, 2026 was delayed by about 9 hours. Based on IS |
| CP063 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP064 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Israel" | Israel |
| CP065 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Israel ? Currency = ILS |  |
| CP066 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP067 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP068 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a ?3,670 ILS compensation. Please note that it will take 5 to 10 business days to pr | You are entitled to receive a ?3,670 ILS compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP069 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP070 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP071 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? BSM � Email Payment (Israel) |  |
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
| CP085 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: ?3,670 ILS Payment Method: BSM � Email Payment After submission, you will receive a confirmation email summarizing your eligibility, claim detai |
| CP086 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP087 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP088 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP089 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP090 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP091 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP092 | NOTIFICATION | email | email | And an eligible notification email is sent to d***@gmail.com |  |
| CP093 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (?3,670 ILS), regulation (ASL � Israel Aviation Services Law), flight details (Y |  |
| CP094 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP095 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP096 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "David Cohen" with PNR "TC117" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "David Cohen" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC117" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL + APPR" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "David Cohen" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "d***@gmail.com" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+972***456" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YYZ ? TLV" with claim filed for this flight as arrived late plus 9h |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with compensation "?3,670 ILS" as ASL fixed rate for Travel Com |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Arrival Delay Code should be "42" as Not Extraordinary Circumstance |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dual Regime should show ASL at ?3,670 ILS and APPR assessed separately |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under ASL with Travel Completed and Not Extraordinary and arrival delay 9 |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically and the result should be "No duplicate found" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent to "d***@gmail.com" containing "?3,670 ILS" and "ASL" and "YYZ?TLV delayed 9h" and  |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP127 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Israel" |  |
| CP128 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "ILS" |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And the payment method should be "BSM � Email Payment" |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP131 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "?3,670" as ASL fixed rate for Travel Completed Not Extraordinary and delay 8 hours or more |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP133 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually |  |
| CP134 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier via HSBC channel for BSM |  |
| CP135 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP136 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And currency conversion logging should record ILS amount and CAD equivalent and exchange rate and source and date |  |
| CP138 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show "?3,670 ILS" with payment method "Cash" via "BSM � Email Payment" and status updated v |  |
| CP139 | EXPECTED RESULTS | verdict | api | DDS returns FD-ASL-EL-01. | DDS returns FD-ASL-EL-01. |
| CP140 | EXPECTED RESULTS | verdict | api | Trip Tracer: Flight operated; Promise = 06:00 TLV; Actual = 15:00 TLV; Arrival delay = 9hrs; Arrival Delay Code 42 (numeric � Not Extraordin | Trip Tracer: Flight operated; Promise = 06:00 TLV; Actual = 15:00 TLV; Arrival delay = 9hrs; Arrival Delay Code 42 (numeric � Not Extraordinary Circumstance / C |
| CP141 | EXPECTED RESULTS | verdict | chat | ASL Gate 8: 9hrs ? 8hr threshold ? PROCEED. | ASL Gate 8: 9hrs ? 8hr threshold ? PROCEED. |
| CP142 | EXPECTED RESULTS | verdict | api | ASL Gate 9: Code 42 = Not Extraordinary ? Controllable. | ASL Gate 9: Code 42 = Not Extraordinary ? Controllable. |
| CP143 | EXPECTED RESULTS | verdict | chat | ASL Gate 10: Fixed ILS 3,670 (single tier � no distance bands, no intermediate tiers). | ASL Gate 10: Fixed ILS 3,670 (single tier � no distance bands, no intermediate tiers). |
| CP144 | EXPECTED RESULTS | verdict | api | Dual Regime: ASL = EL-01 (?3,670); APPR = assessed separately. | Dual Regime: ASL = EL-01 (?3,670); APPR = assessed separately. |
| CP145 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP146 | EXPECTED RESULTS | verdict | chat | IDV: PASS. | IDV: PASS. |
| CP147 | EXPECTED RESULTS | verdict | chat | Payment: BSM � Email Payment Israel ILS. | Payment: BSM � Email Payment Israel ILS. |
| CP148 | EXPECTED RESULTS | verdict | api | Claims Dashboard: ASL EL-01; ELIGIBLE; Travel Completed; Not Extraordinary (code 42); Delay = 9hrs (?8hr threshold); ?3,670 ILS; DDS = FD-AS | Claims Dashboard: ASL EL-01; ELIGIBLE; Travel Completed; Not Extraordinary (code 42); Delay = 9hrs (?8hr threshold); ?3,670 ILS; DDS = FD-ASL-EL-01. |
