# FD_TC_190 · CHAI-31582 — checkpoints

**Goal:** A Contact Center or Airport agent changed the customer's flight WITH the ACNP (Air Canada No Pay) marker present. Identifier: SK ACNP or CX ACNP in PNR history. The presence of ACNP indicates the change was airline-initiated accommodation (INVOL), not a customer-requested change. Promise does NOT update.

Methods: seed 1, chat 59, api 18, email 3, dashboard 34, implied 20, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | A Contact Center or Airport agent changed the customer's flight WITH the ACNP (Air Canada No Pay) marker present. Identifier: SK ACNP or CX  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Genevi�ve Roy); 1 leg AC YUL?YYZ; Original (14-day) arrival: 10:00; Agent change with ACNP at D-1: new arrival 16:00; | PNR: Single passenger (Genevi�ve Roy); 1 leg AC YUL?YYZ; Original (14-day) arrival: 10:00; Agent change with ACNP at D-1: new arrival 16:00; Actual arrival: 16: |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "An Air Canada agent changed my flight because of a disruption and I arrived 6 hours late. Can I get compensation?" | An Air Canada agent changed my flight because of a disruption and I arrived 6 hours late. Can I get compensation? |
| CP009 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP011 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP012 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP013 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP014 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP015 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Genevi�ve Roy" | Genevi�ve Roy |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Genevi�ve! And, what is your booking reference number? |
| CP017 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TCINVOL05" | PNR: TCINVOL05 |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TCINVOL05 |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP022 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: g***@gmail.com � Phone: +1***678 |
| CP023 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: g***@gmail.com" | Email: g***@gmail.com |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP025 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP026 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP028 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP029 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP030 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP031 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP032 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Genevi�ve Roy (Adult) Is this who you'd like to include? |
| CP033 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP034 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP035 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 429 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 10, 2026 � Arrival Delay: 6 hours Is this the journey you'd |
| CP036 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP037 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP038 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP039 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP040 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP041 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YUL (Canada) ? APPR |  |
| CP042 | TRIAGE & DDS EVALUATION � INVOL CHANGE DETECTED | verdict | api | Then the DDS evaluation is done in backend |  |
| CP043 | TRIAGE & DDS EVALUATION � INVOL CHANGE DETECTED | verdict | api | And DDS checks booking change history: | ? Change 1 (D-1): Agent change with ACNP ? Identifier: SK ACNP (or CX ACNP) in PNR history ? Classification logic: Agent change + ACNP PRESENT = INVOL (airline  |
| CP044 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 429, Route: YUL ? YYZ, Scheduled Arrival: 10:00 (14-day mark � NOT updated by Agent+ACNP) | Promised Itinerary - Flight: AC 429, Route: YUL ? YYZ, Scheduled Arrival: 10:00 (14-day mark � NOT updated by Agent+ACNP) |
| CP045 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 429, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 16:00, Delay: +6H 00M | Current Itinerary - Flight: AC 429, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 16:00, Delay: +6H 00M |
| CP046 | TRIP TRACER UI VALIDATION | verdict | api | Change 1: Agent with ACNP (SK ACNP) at D-1 � INVOL � arrival 10:00 ? 16:00 | Change 1: Agent with ACNP (SK ACNP) at D-1 � INVOL � arrival 10:00 ? 16:00 |
| CP047 | TRIP TRACER UI VALIDATION | verdict | api | Promise = 10:00 (14-day mark � Agent+ACNP did NOT update it) | Promise = 10:00 (14-day mark � Agent+ACNP did NOT update it) |
| CP048 | TRIP TRACER UI VALIDATION | verdict | api | Delay from promise = 6 hours | Delay from promise = 6 hours |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR | Regime: APPR |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | APPR: Delay 6�<9h, Controllable ? ELIGIBLE | APPR: Delay 6�<9h, Controllable ? ELIGIBLE |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 429 � YUL ? YYZ � 42 | MSL FLIGHT: AC 429 � YUL ? YYZ � 42 |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42) | CONTROLLABLE (Code 42) |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | CRITICAL: ACNP presence is the key differentiator � same agent action WITHOUT ACNP = VOL (FD_VOL_03/04), WITH ACNP = INVOL (this test case) | CRITICAL: ACNP presence is the key differentiator � same agent action WITHOUT ACNP = VOL (FD_VOL_03/04), WITH ACNP = INVOL (this test case) |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | MS GENEVI�VE ROY / ELIGIBLE / APPR_6_TO_9_HOURS / CAD $700 | MS GENEVI�VE ROY / ELIGIBLE / APPR_6_TO_9_HOURS / CAD $700 |
| CP055 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP056 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP057 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP058 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 429 from Montreal (YUL) to Toronto (YYZ) was delayed by about 6 hours. Based on the Canadian Air P |
| CP059 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP060 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP061 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP062 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP063 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP064 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $700 CAD compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a $700 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP065 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP066 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP067 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada) |  |
| CP068 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer. |
| CP069 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | customer | chat | And the user provides "genevieve.roy@gmail.com" | genevieve.roy@gmail.com |
| CP070 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | system | implied | Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded." |  |
| CP071 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP072 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP073 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP074 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP075 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP076 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP077 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP078 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP082 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $700 CAD Payment Method: Interac e-Transfer After submission, you will receive a confirmation email summarizing your eligibility, claim details  |
| CP083 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP084 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP085 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP086 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP087 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP088 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP089 | NOTIFICATION | email | email | And an eligible notification email is sent to g***@gmail.com |  |
| CP090 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($700 CAD), regulation (APPR), flight details (AC 429, YUL?YYZ, 6hr delay), next |  |
| CP091 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP092 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP093 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Genevi�ve Roy" with PNR "TCINVOL05" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Genevi�ve Roy" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TCINVOL05" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Genevi�ve Roy" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility should be "ELIGIBLE" under APPR with compensation "$700 CAD" Tier 2 6 to less than 9hrs controllable |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Change History should show Agent with ACNP SK ACNP as INVOL |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And ACNP presence should be the key differentiator as the same agent action WITHOUT ACNP equals VOL in FD_VOL_03 and FD_VOL_04 but WITH ACNP |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Promise should be 10:00 at 14-day mark NOT updated by Agent plus ACNP |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Actual should be 16:00 |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay should be 6hrs |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And INVOL should have been detected via Agent with ACNP SK ACNP |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the promise should NOT have been updated and should stay at 14-day mark |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be ELIGIBLE at $700 CAD |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Genevi�ve Roy + TCINVOL05 + YUL?YYZ + FD" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing Case Reference and compensation $700 CAD and regulation APPR a |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record Agent plus ACNP INVOL detected SK ACNP and promise unchanged at 10:00 and delay 6hrs and eligible $700 |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should note ACNP presence equals INVOL and cross-reference FD_VOL_03 ADDCOL plus no ACNP equals VOL and FD_VOL_04 airport  |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP134 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP135 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP136 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP138 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "$700 CAD" APPR Tier 2 6 to less than 9hrs controllable |  |
| CP139 | PAYMENT VALIDATION | payment | chat | And the Interac e-Transfer email should be collected as one-time non-editable after submission |  |
| CP140 | PAYMENT VALIDATION | payment | chat | And IDV at Payment should be triggered via Persona and Persona should return IDV PASS |  |
| CP141 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP142 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP143 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier and Unifier should process Interac e-Transfer for $700 CAD |  |
| CP144 | PAYMENT VALIDATION | payment | manual | And if unclaimed after 35 days the status should be Expired |  |
| CP145 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details "$700 CAD" with payment method "Cash" via "Interac e-Transfer" and stat |  |
| CP146 | EXPECTED RESULTS | verdict | api | Tool: Agent with ACNP (SK ACNP / CX ACNP); Classification: INVOL; Promise: 10:00 (14-day � NOT updated); Actual: 16:00; Delay: 6hrs; APPR Ti | Tool: Agent with ACNP (SK ACNP / CX ACNP); Classification: INVOL; Promise: 10:00 (14-day � NOT updated); Actual: 16:00; Delay: 6hrs; APPR Tier 2; ELIGIBLE $700  |
