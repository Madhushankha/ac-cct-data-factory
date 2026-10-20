# FD_TC_204 · CHAI-31596 — checkpoints

**Goal:** AC applied an OPR operational re-protection (INVOL) pushing arrival to 18:00, then customer at the airport voluntarily changed to an EARLIER flight (airport office ID, no ACNP = -ve VOL) arriving at 14:00. Customer is mitigating � no deduction. Full delay = 4hrs.

Methods: seed 1, chat 58, api 19, email 3, dashboard 37, implied 21, manual 8, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | AC applied an OPR operational re-protection (INVOL) pushing arrival to 18:00, then customer at the airport voluntarily changed to an EARLIER |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Mathieu Arsenault); 1 leg AC YUL?YYZ; Original (14-day) arrival: 10:00; Change 1 (D-0): OPR (YTOAC00PR) ? new arrival | PNR: Single passenger (Mathieu Arsenault); 1 leg AC YUL?YYZ; Original (14-day) arrival: 10:00; Change 1 (D-0): OPR (YTOAC00PR) ? new arrival 18:00; Change 2 (D- |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "Air Canada re-routed me to a very late flight, so I asked at the airport to change to an earlier one. I still arrived 4 h | Air Canada re-routed me to a very late flight, so I asked at the airport to change to an earlier one. I still arrived 4 hours late. Can I get compensation? |
| CP009 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP011 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP012 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP013 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP014 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP015 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Mathieu Arsenault" | Mathieu Arsenault |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Mathieu! And, what is your booking reference number? |
| CP017 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TCCOMBO14" | PNR: TCCOMBO14 |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TCCOMBO14 |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP022 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: m***@gmail.com � Phone: +1***567 |
| CP023 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: m***@gmail.com" | Email: m***@gmail.com |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP025 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP026 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP028 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP029 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP030 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP031 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP032 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Mathieu Arsenault (Adult) Is this who you'd like to include? |
| CP033 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP034 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP035 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 447 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 16, 2026 � Arrival Delay: 4 hours Is this the journey you'd |
| CP036 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP037 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP038 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP039 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP040 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP041 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YUL (Canada) ? APPR |  |
| CP042 | TRIAGE & DDS EVALUATION � INVOL THEN NEGATIVE VOL DETECTED | verdict | api | Then the DDS evaluation is done in backend |  |
| CP043 | TRIAGE & DDS EVALUATION � INVOL THEN NEGATIVE VOL DETECTED | verdict | api | And DDS checks booking change history: | ? Change 1 (D-0): OPR (identifier: YTOAC00PR) ? Classification: INVOL (OPR = airline-initiated operational re-protection) ? OPR changed arrival from 10:00 ? 18: |
| CP044 | ? NEGATIVE VOL � NO DEDUCTION LOGIC | system | implied | ? Total delay = 14:00 - 10:00 = 4 hours (actual - promise) | ? Post-INVOL VOL direction = NEGATIVE (-4hrs � customer went EARLIER) ? Negative VOL = NOT DEDUCTED (customer is mitigating) ? Net delay = 4 hours (full delay,  |
| CP045 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 447, Route: YUL ? YYZ, Scheduled Arrival: 10:00 (14-day mark) | Promised Itinerary - Flight: AC 447, Route: YUL ? YYZ, Scheduled Arrival: 10:00 (14-day mark) |
| CP046 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 447, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 14:00, Delay: +4H 00M | Current Itinerary - Flight: AC 447, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 14:00, Delay: +4H 00M |
| CP047 | TRIP TRACER UI VALIDATION | verdict | api | Change 1: OPR (YTOAC00PR) at D-0 � INVOL � arrival 10:00 ? 18:00 � PROMISE NOT UPDATED | Change 1: OPR (YTOAC00PR) at D-0 � INVOL � arrival 10:00 ? 18:00 � PROMISE NOT UPDATED |
| CP048 | TRIP TRACER UI VALIDATION | verdict | api | Change 2: Airport Agent (airport office ID, no ACNP) at D-0 � VOL (-ve) � arrival 18:00 ? 14:00 � NEGATIVE, NO DEDUCTION | Change 2: Airport Agent (airport office ID, no ACNP) at D-0 � VOL (-ve) � arrival 18:00 ? 14:00 � NEGATIVE, NO DEDUCTION |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Promise = 10:00 (14-day mark) | Promise = 10:00 (14-day mark) |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | Total/Net delay = 4hrs (14:00 - 10:00) � NO deduction for negative VOL | Total/Net delay = 4hrs (14:00 - 10:00) � NO deduction for negative VOL |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | Post-INVOL VOL = -4hrs (NEGATIVE ? NOT DEDUCTED) | Post-INVOL VOL = -4hrs (NEGATIVE ? NOT DEDUCTED) |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR | Regime: APPR |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | APPR: Delay 3�6h, Controllable ? ELIGIBLE | APPR: Delay 3�6h, Controllable ? ELIGIBLE |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 447 � YUL ? YYZ � 42 | MSL FLIGHT: AC 447 � YUL ? YYZ � 42 |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42) | CONTROLLABLE (Code 42) |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | MR MATHIEU ARSENAULT / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 | MR MATHIEU ARSENAULT / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 |
| CP057 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP058 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP059 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP060 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 447 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours. Based on the Canadian Air P |
| CP061 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP062 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP063 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP064 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP065 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP066 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP067 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP068 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP069 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada) |  |
| CP070 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer. |
| CP071 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | customer | chat | And the user provides "mathieu.arsenault@gmail.com" | mathieu.arsenault@gmail.com |
| CP072 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | system | implied | Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded." |  |
| CP073 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP074 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP075 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP076 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP077 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP078 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP084 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: Interac e-Transfer After submission, you will receive a confirmation email summarizing your eligibility, claim details  |
| CP085 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP086 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP087 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP088 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP089 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP090 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP091 | NOTIFICATION | email | email | And an eligible notification email is sent to m***@gmail.com |  |
| CP092 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details (AC 447, YUL?YYZ, 4hr delay), next |  |
| CP093 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP094 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP095 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Mathieu Arsenault" with PNR "TCCOMBO14" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Mathieu Arsenault" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TCCOMBO14" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Mathieu Arsenault" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility should be "ELIGIBLE" under APPR with compensation "$400 CAD" Tier 1 3 to less than 6hrs controllable |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Change History should show Change 1 OPR YTOAC00PR at D-0 as INVOL with arrival 10:00 to 18:00 and PROMISE NOT UPDATED and Change 2 A |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Promise should be 10:00 at 14-day mark |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total and Net delay should be 4hrs from 14:00 minus 10:00 with NO deduction for negative VOL |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Post-INVOL VOL should be minus 4hrs NEGATIVE and NOT DEDUCTED |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Actual should be 14:00 |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Negative VOL as customer mitigation at airport should NEVER be deducted and the full delay should be used |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And INVOL should have been detected via OPR YTOAC00PR with promise staying at 14-day mark |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And VOL negative should have been detected via Airport Agent no ACNP with negative equals NO deduction as customer mitigating |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full delay should be 4hrs resulting in Tier 1 |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be ELIGIBLE at $400 CAD |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Mathieu Arsenault + TCCOMBO14 + YUL?YYZ + FD" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing Case Reference and compensation $400 CAD and regulation APPR a |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record OPR INVOL at D-0 YTOAC00PR promise unchanged at 10:00 then Airport VOL negative at D-0 airport office ID no  |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the negative VOL should be logged as mitigation with no deduction applied |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP138 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP139 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP140 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP141 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP142 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "$400 CAD" APPR Tier 1 full 4hr delay with no deduction for negative VOL |  |
| CP143 | PAYMENT VALIDATION | payment | chat | And IDV at Payment should be triggered via Persona and Persona should return IDV PASS |  |
| CP144 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP145 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier and Unifier should process Interac e-Transfer for $400 CAD |  |
| CP146 | PAYMENT VALIDATION | payment | manual | And if unclaimed after 35 days the status should be Expired |  |
| CP147 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details "$400 CAD" with payment method "Cash" via "Interac e-Transfer" and stat |  |
| CP148 | EXPECTED RESULTS | verdict | api | Sequence: INVOL (OPR) ? VOL (-ve Airport Agent no ACNP); Promise: 10:00 (14-day); Actual: 14:00; Delay: 4hrs; Negative VOL (-4hrs): NOT dedu | Sequence: INVOL (OPR) ? VOL (-ve Airport Agent no ACNP); Promise: 10:00 (14-day); Actual: 14:00; Delay: 4hrs; Negative VOL (-4hrs): NOT deducted; Full delay use |
