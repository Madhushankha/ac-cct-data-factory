# FD_TC_040 · CHAI-31432 — checkpoints

**Goal:** Tests Sister City rebooking and a Fallback code together, with a controllable cause. AC 442 YUL?YYZ was delayed because its inbound aircraft arrived late for a reason within AC's control (upline, code 05). The customer accepted rebooking to AC 444 YUL?YHM (Hamilton, sister city of YYZ). The arrival delay code is missing, so DDS falls back to departure delay code 05. Checks five things: (1) Sister City = TRUE, (2) Fallback = TRUE, (3) both flags are set together, (4) delay = actual arrival at YHM minus the original promised arrival at YYZ (5 hours), and (5) code 05 is Controllable, so Tier 1 pays CAD 400 by Interac.

Methods: seed 15, chat 62, api 34, email 3, dashboard 42, implied 22, manual 16, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Tests Sister City rebooking and a Fallback code together, with a controllable cause. AC 442 YUL?YYZ was delayed because its inbound aircraft |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR TC077: one passenger, Isabelle C�t� (Adult) | PNR TC077: one passenger, Isabelle C�t� (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Original flight: AC 442 YUL?YYZ, May 15, 2026, scheduled arrival 12:00 at YYZ, DELAYED | Original flight: AC 442 YUL?YYZ, May 15, 2026, scheduled arrival 12:00 at YYZ, DELAYED |
| CP004 | PREREQUISITES | prerequisite | seed | Cancellation code: NONE | Cancellation code: NONE |
| CP005 | PREREQUISITES | prerequisite | seed | Arrival delay code: NULL (missing) | Arrival delay code: NULL (missing) |
| CP006 | PREREQUISITES | prerequisite | seed | First departure delay code: 05 (upline, within carrier control), used as fallback | First departure delay code: 05 (upline, within carrier control), used as fallback |
| CP007 | PREREQUISITES | prerequisite | seed | The customer accepted INVOL rebooking to AC 444 YUL?YHM, which arrived at 17:00 at YHM | The customer accepted INVOL rebooking to AC 444 YUL?YHM, which arrived at 17:00 at YHM |
| CP008 | PREREQUISITES | prerequisite | seed | Delay: 17:00 (YHM) ? 12:00 (YYZ) = 5 hours | Delay: 17:00 (YHM) ? 12:00 (YYZ) = 5 hours |
| CP009 | PREREQUISITES | prerequisite | seed | Sister city pair: YHM ? YYZ | Sister city pair: YHM ? YYZ |
| CP010 | PREREQUISITES | prerequisite | seed | Fallback: TRUE | Fallback: TRUE |
| CP011 | PREREQUISITES | prerequisite | seed | Aeroplan: not linked | Aeroplan: not linked |
| CP012 | PREREQUISITES | prerequisite | implied | CyberSource set to GREEN | CyberSource set to GREEN |
| CP013 | PREREQUISITES | prerequisite | seed | Persona set to IDV PASS | Persona set to IDV PASS |
| CP014 | PREREQUISITES | prerequisite | seed | Country of residence: Canada (CAD, Interac) | Country of residence: Canada (CAD, Interac) |
| CP015 | PREREQUISITES | prerequisite | seed | Regime: APPR | Regime: APPR |
| CP016 | PREREQUISITES | prerequisite | seed | More than 72 hours have passed | More than 72 hours have passed |
| CP017 | PREREQUISITES | prerequisite | seed | Filed after 31 days, within 366 days | Filed after 31 days, within 366 days |
| CP018 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP019 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP020 | START | customer | chat | Then user selects English |  |
| CP021 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP022 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP023 | START | customer | chat | And the user says "My flight from Montreal to Toronto was delayed because the plane arrived late from its previous flight, and I was rebooke | My flight from Montreal to Toronto was delayed because the plane arrived late from its previous flight, and I was rebooked to a flight landing at Hamilton inste |
| CP024 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP025 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP026 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP027 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable." | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Isabelle C�t�" | Isabelle C�t� |
| CP031 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, Isabelle! And, what is your booking reference number?" | Thanks, Isabelle! And, what is your booking reference number? |
| CP032 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC077" | PNR: TC077 |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC077 |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP035 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: Email: i***@gmail.com / Phone: +1***345 |  |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: i***@gmail.com" | Email: i***@gmail.com |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP040 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP041 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP042 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP043 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP044 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP045 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP046 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP047 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays: "I found 1 passenger on this booking: Isabelle C�t� (Adult). Is this who you'd like to include?" | I found 1 passenger on this booking: Isabelle C�t� (Adult). Is this who you'd like to include? |
| CP048 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP049 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP050 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 444 Route: Montreal (YUL) ? Hamilton (YHM) [Rebooked � original: AC 442 to Toronto YYZ] Date: May 15, 2026 Arrival Del |
| CP051 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP052 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP053 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP054 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP055 | 72-HOUR CHECK | system | implied | Then the system calculates: Arrival May 15, 2026; current date June 15, 2026 ? >72 hours ? PROCEED |  |
| CP056 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP057 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 15, 2026; filing June 15, 2026 ? 31 days ? within 366 days ? PROCEED |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS identifies MSL = AC 442 YUL?YYZ (original delayed flight) |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the cancellation code on MSL ? NONE |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the first arrival delay code on MSL ? NULL (MISSING) |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | And DDS falls back to the first departure delay code on MSL ? 05 (upline) |  |
| CP063 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sets Fallback = TRUE |  |
| CP064 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks sister city config: YHM ? YYZ ? VALID PAIR ? Sister City = TRUE |  |
| CP065 | TRIAGE & DDS EVALUATION | verdict | api | And DDS calculates delay = 17:00 (actual at YHM) ? 12:00 (promise at YYZ) = 5 hours ? band 3 to <6 hours |  |
| CP066 | TRIAGE & DDS EVALUATION | verdict | api | And DDS classifies 05 as WITHIN CARRIER CONTROL ? CONTROLLABLE (Gate 9) |  |
| CP067 | TRIAGE & DDS EVALUATION | verdict | api | And DDS applies APPR Tier 1 = CAD 400 |  |
| CP068 | TRIAGE & DDS EVALUATION | verdict | api | And DDS returns FD-APPR-EL-10 and sends results to Trip Tracer UI |  |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 442, Route: YUL ? YYZ, Scheduled Arrival: 12:00 at YYZ (DELAYED) | Promised Itinerary - Flight: AC 442, Route: YUL ? YYZ, Scheduled Arrival: 12:00 at YYZ (DELAYED) |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 444, Route: YUL ? YHM (rebooked to sister city), Status: ARRIVED, Actual Arrival: 17:00 at YHM | Current Itinerary - Flight: AC 444, Route: YUL ? YHM (rebooked to sister city), Status: ARRIVED, Actual Arrival: 17:00 at YHM |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | History - Change 1: INVOL � AC 442 delayed ? customer accepted rebooking to AC 444 YUL?YHM | History - Change 1: INVOL � AC 442 delayed ? customer accepted rebooking to AC 444 YUL?YHM |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | Delay Calculation: 17:00 (YHM) ? 12:00 (YYZ) = 5 hrs ? DELAY_3_TO_LT_6_HOURS | Delay Calculation: 17:00 (YHM) ? 12:00 (YYZ) = 5 hrs ? DELAY_3_TO_LT_6_HOURS |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 442 � YUL ? YYZ | MSL FLIGHT: AC 442 � YUL ? YYZ |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | Cancellation code: NONE | Cancellation code: NONE |
| CP076 | TRIP TRACER UI VALIDATION | verdict | api | First arrival delay code: NULL (MISSING) | First arrival delay code: NULL (MISSING) |
| CP077 | TRIP TRACER UI VALIDATION | verdict | api | First departure delay code: 05 � "Late positioning due to upline (within carrier control)" | First departure delay code: 05 � "Late positioning due to upline (within carrier control)" |
| CP078 | TRIP TRACER UI VALIDATION | verdict | api | Controllability source = first departure delay code (fallback) | Controllability source = first departure delay code (fallback) |
| CP079 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: TRUE | Fallback: TRUE |
| CP080 | TRIP TRACER UI VALIDATION | verdict | api | Sister City: TRUE (YHM ? YYZ, confirmed in DDS sister city config) | Sister City: TRUE (YHM ? YYZ, confirmed in DDS sister city config) |
| CP081 | TRIP TRACER UI VALIDATION | verdict | api | APPR causal category: Within carrier control ? CONTROLLABLE | APPR causal category: Within carrier control ? CONTROLLABLE |
| CP082 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +5H 00M � CONTROLLABLE | Delay: +5H 00M � CONTROLLABLE |
| CP083 | TRIP TRACER UI VALIDATION | verdict | api | DDS outcome code: FD-APPR-EL-10 | DDS outcome code: FD-APPR-EL-10 |
| CP084 | TRIP TRACER UI VALIDATION | verdict | api | MS ISABELLE C�T� / ELIGIBLE / DELAY_3_TO_LT_6_HOURS (SISTER CITY + FALLBACK) / CAD 400.00 / [expiry date] | MS ISABELLE C�T� / ELIGIBLE / DELAY_3_TO_LT_6_HOURS (SISTER CITY + FALLBACK) / CAD 400.00 / [expiry date] |
| CP085 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP086 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN LIGHT (no fraud detected) |  |
| CP087 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP088 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your original flight from Montreal (YUL) to Toronto (YYZ) was delayed and you were rebooked to Hamilton (YHM |
| CP089 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: "Thank you for confirming. In which country will your reimbursement be deposited?" | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP090 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP091 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP092 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP093 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP094 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a CAD 400 compensation. Please note that it will take 5 to 10 business days to proce | You are entitled to receive a CAD 400 compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP095 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP096 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And the user provides "Yes" | Yes |
| CP097 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the system checks which payment method is mapped based on country of residence ? Interac (CANADA) |  |
| CP098 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP099 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP100 | PAYMENT METHOD � INTERAC (FD-07) | system | implied | Then the chatbot does NOT ask for bank account, card or any other payment details |  |
| CP101 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then the system checks that IDV is not completed |  |
| CP102 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: "I must verify your identity for payment security. Please click here to get started" | I must verify your identity for payment security. Please click here to get started |
| CP103 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And the chatbot displays a button "Get verified" | Get verified |
| CP104 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When the user clicks on the button |  |
| CP105 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then the system checks if IDV at Payment |  |
| CP106 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the system checks if the user has consented to IDV |  |
| CP107 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP108 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP109 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP110 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: "Your identity has been verified successfully. Let's proceed to finalize your claim." | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP111 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: CAD 400 Payment Method: Interac e-Transfer (i***@gmail.com) After submission, you will receive a confirmation email summarizing your eligibility |
| CP112 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP113 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP114 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP115 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP116 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP117 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP118 | NOTIFICATION | email | email | And an eligible notification email is sent to i***@gmail.com |  |
| CP119 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (CAD 400), regulation (APPR), flight details (including sister city note: YHM fo |  |
| CP120 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No] | Is there anything I can help you with? |
| CP121 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP122 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Isabelle C�t�" with PNR "TC077" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date should be populated |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Isabelle C�t�" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC077" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Isabelle C�t�" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "i***@gmail.com" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***345" |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address, Profile ID and Tier Status should be populated |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight and the rebooked arrival at YHM |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Sister City flag should be "TRUE" (YHM ? YYZ) |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fallback flag should be "TRUE" (arrival code NULL, departure code 05) |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present with no expected ancillary fees |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should show "ELIGIBLE � CAD 400 (Tier 1, 3 to <6 hrs, Controllable, Departure Code 05 fallback) |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS outcome should be "FD-APPR-EL-10" |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" due to controllable departure delay Code 05 (upline) used as fallback bec |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Isabelle C�t� + TC077 + YUL?YYZ + FD" |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Persona IDV result should be "PASS" |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP166 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP167 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP168 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP169 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP170 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP171 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP172 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP173 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP174 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP175 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP176 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP177 | PAYMENT VALIDATION | payment | chat | And only the customer's email address should have been collected (no bank, card or other payment details) |  |
| CP178 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP179 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "CAD 400" for Tier 1 delay of 3 to less than 6 hours |  |
| CP180 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP181 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP182 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP183 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP184 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received from Interac |  |
| CP185 | PAYMENT VALIDATION | payment | manual | And the status should be "Pending" transitioning to "Cashed" or "Rejected" or "Expired" |  |
| CP186 | PAYMENT VALIDATION | payment | manual | And if the payment is unclaimed after 35 days the status should be set to "Expired" |  |
| CP187 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show "CAD 400" |  |
| CP188 | PAYMENT VALIDATION | payment | chat | And the payment method should show "Cash" via "Interac" |  |
| CP189 | PAYMENT VALIDATION | payment | manual | And the status should be updated via talkback |  |
| CP190 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-10. | DDS returns FD-APPR-EL-10. |
| CP191 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 12:00 at YYZ (AC 442, DELAYED); Actual = 17:00 at YHM (AC 444, sister city); Sister City = TRUE (YHM ? YYZ); Delay =  | Trip Tracer: Promise = 12:00 at YYZ (AC 442, DELAYED); Actual = 17:00 at YHM (AC 444, sister city); Sister City = TRUE (YHM ? YYZ); Delay = 5 hours; MSL = AC 44 |
| CP192 | EXPECTED RESULTS | verdict | chat | Compensation: CAD 400 (Tier 1) by Interac. | Compensation: CAD 400 (Tier 1) by Interac. |
| CP193 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP194 | EXPECTED RESULTS | verdict | chat | Persona: PASS. | Persona: PASS. |
| CP195 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Sister City = TRUE; Fallback = TRUE; DDS = FD-APPR-EL-10; Resolved. | Claims Dashboard: Sister City = TRUE; Fallback = TRUE; DDS = FD-APPR-EL-10; Resolved. |
