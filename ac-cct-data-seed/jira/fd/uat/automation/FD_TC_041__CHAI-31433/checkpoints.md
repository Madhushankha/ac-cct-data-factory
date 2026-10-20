# FD_TC_041 · CHAI-31433 — checkpoints

**Goal:** Combines TWO special handling mechanisms simultaneously under APPR: Sister City rebooking AND Fallback code. Customer's original flight AC 442 YUL?YYZ was delayed. Arrival delay code is MISSING from the system (data issue). Customer accepts rebooking to AC 443 YUL?YHM (Hamilton � sister city of YYZ). Actual arrival at YHM is 7 hours after original promised arrival at YYZ. DDS falls back to the departure delay code 42 (Scheduled Maintenance � Controllable) for eligibility assessment. Validates: (1) Sister City flag set when customer is rebooked to sister city airport, (2) Fallback flag set when arrival delay code is unavailable and departure delay code is used, (3) Both flags coexist without interfering, (4) Delay calculated as actual arrival at sister city (YHM) minus original promised arrival at original destination (YYZ), (5) Tier 2 ($700) applies for 7hr delay (6�<9hrs). Tests a different controllable fallback code from TC_030 (which used departure delay code 64) to confirm controllability classification is consistent across codes.

Methods: seed 17, chat 64, api 24, email 3, dashboard 47, implied 21, manual 16, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Combines TWO special handling mechanisms simultaneously under APPR: Sister City rebooking AND Fallback code. Customer's original flight AC 4 |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC030 � single passenger Marc-Andr� Lavoie (Adult) | PNR: TC030 � single passenger Marc-Andr� Lavoie (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Original itinerary: AC 442 YUL?YYZ, Scheduled arrival: 10:00 at YYZ | Original itinerary: AC 442 YUL?YYZ, Scheduled arrival: 10:00 at YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Original flight AC 442 DELAYED | Original flight AC 442 DELAYED |
| CP005 | PREREQUISITES | prerequisite | seed | Arrival delay code: NULL (MISSING � not received from system) | Arrival delay code: NULL (MISSING � not received from system) |
| CP006 | PREREQUISITES | prerequisite | seed | Departure delay code: 42 (Scheduled Maintenance � Controllable, used as fallback) | Departure delay code: 42 (Scheduled Maintenance � Controllable, used as fallback) |
| CP007 | PREREQUISITES | prerequisite | seed | Customer offered rebooking options | Customer offered rebooking options |
| CP008 | PREREQUISITES | prerequisite | seed | Customer ACCEPTS rebooking to AC 443 YUL?YHM (Hamilton � sister city of YYZ) | Customer ACCEPTS rebooking to AC 443 YUL?YHM (Hamilton � sister city of YYZ) |
| CP009 | PREREQUISITES | prerequisite | seed | Rebooked flight AC 443 departs YUL and arrives YHM at 17:00 | Rebooked flight AC 443 departs YUL and arrives YHM at 17:00 |
| CP010 | PREREQUISITES | prerequisite | seed | Delay: 17:00 (YHM actual) ? 10:00 (YYZ original promise) = 7hrs (420 min) | Delay: 17:00 (YHM actual) ? 10:00 (YYZ original promise) = 7hrs (420 min) |
| CP011 | PREREQUISITES | prerequisite | seed | Sister city mapping: YHM ? YYZ configured in system | Sister city mapping: YHM ? YYZ configured in system |
| CP012 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic Canada, YUL?YYZ) | Regime: APPR (domestic Canada, YUL?YYZ) |
| CP013 | PREREQUISITES | prerequisite | seed | Booking changes: INVOL � AC 442 delayed? rebooked to AC 443 | Booking changes: INVOL � AC 442 delayed? rebooked to AC 443 |
| CP014 | PREREQUISITES | prerequisite | seed | Timing: >72hrs post-arrival elapsed | Timing: >72hrs post-arrival elapsed |
| CP015 | PREREQUISITES | prerequisite | seed | Filing: Within 366-day limitation | Filing: Within 366-day limitation |
| CP016 | PREREQUISITES | prerequisite | seed | Exclusions: No duplicate case; NOT employee; NOT infant | Exclusions: No duplicate case; NOT employee; NOT infant |
| CP017 | PREREQUISITES | prerequisite | seed | Aeroplan: NOT linked ? Cash only | Aeroplan: NOT linked ? Cash only |
| CP018 | PREREQUISITES | prerequisite | seed | Residence: Canada ? Interac | Residence: Canada ? Interac |
| CP019 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP020 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP021 | START | customer | chat | Then user selects English |  |
| CP022 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP023 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP024 | START | customer | chat | And the user says "My flight from Montreal to Toronto was delayed and I was rebooked to a flight landing at Hamilton instead. I arrived 7 ho | My flight from Montreal to Toronto was delayed and I was rebooked to a flight landing at Hamilton instead. I arrived 7 hours later than my original flight was s |
| CP025 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP026 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP027 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP028 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Marc-Andr� Lavoie" | Marc-Andr� Lavoie |
| CP032 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Marc-Andr�! And, what is your booking reference number? |
| CP033 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC030" | PNR: TC030 |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC030 |  |
| CP035 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP036 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: m***@gmail.com � Phone: +1***456 |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: m***@gmail.com" | Email: m***@gmail.com |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP041 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "371928" | 371928 |
| CP042 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP043 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP044 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP045 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP046 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP047 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP048 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Marc-Andr� Lavoie (Adult) Is this who you'd like to include? |
| CP049 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP050 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP051 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 443 (rebooked from delayed (AC 442) � Route: Montreal (YUL) ? Hamilton (YHM) [Rebooked � original destination: Toron |
| CP052 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP053 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP054 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP055 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP056 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP057 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 16, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP058 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP059 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 16, 2026; filing June 15, 2026 ? 30 days ? within 366 days ? PROCEED |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 442, Route: YUL ? YYZ, Scheduled Arrival: 10:00 at YYZ (original flight � DELAYED) | Promised Itinerary - Flight: AC 442, Route: YUL ? YYZ, Scheduled Arrival: 10:00 at YYZ (original flight � DELAYED) |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 443, Route: YUL ? YHM (rebooked to sister city), Status: ARRIVED, Actual Arrival: 17:00 at YHM | Current Itinerary - Flight: AC 443, Route: YUL ? YHM (rebooked to sister city), Status: ARRIVED, Actual Arrival: 17:00 at YHM |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | History - Change 1: INVOL � Original flight AC 442 YUL?YYZ delayed(arrival delay code: NULL � MISSING). Customer accepted rebooking to AC 44 | History - Change 1: INVOL � Original flight AC 442 YUL?YYZ delayed(arrival delay code: NULL � MISSING). Customer accepted rebooking to AC 443 YUL?YHM (sister ci |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Sister City Check: YHM ? YYZ = VALID PAIR (confirmed in DDS sister city config) | Sister City Check: YHM ? YYZ = VALID PAIR (confirmed in DDS sister city config) |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Delay Calculation: Original promise = 10:00 at YYZ (AC 442); Actual arrival = 17:00 at YHM (AC 443, sister city); Delay = 7hrs | Delay Calculation: Original promise = 10:00 at YYZ (AC 442); Actual arrival = 17:00 at YHM (AC 443, sister city); Delay = 7hrs |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 442 � YUL ? YYZ � DELAYED CODE: NULL (MISSING) | MSL FLIGHT: AC 442 � YUL ? YYZ � DELAYED CODE: NULL (MISSING) |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | FALLBACK TRIGGERED: Arrival delay code NULL ? using departure delay code | FALLBACK TRIGGERED: Arrival delay code NULL ? using departure delay code |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Departure Code: 42 (Scheduled Maintenance) | Departure Code: 42 (Scheduled Maintenance) |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | Fallback Flag: TRUE | Fallback Flag: TRUE |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42 via fallback departure code) | CONTROLLABLE (Code 42 via fallback departure code) |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +7H 00M � CONTROLLABLE | Delay: +7H 00M � CONTROLLABLE |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | Rebooked Flight: AC 443 � YUL ? YHM (sister city of YYZ) | Rebooked Flight: AC 443 � YUL ? YHM (sister city of YYZ) |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | MR MARC-ANDR� LAVOIE / ELIGIBLE / DELAY_6_TO_LT_9_HOURS (SISTER CITY + FALLBACK) / CAD 700.00 / [expiry date] | MR MARC-ANDR� LAVOIE / ELIGIBLE / DELAY_6_TO_LT_9_HOURS (SISTER CITY + FALLBACK) / CAD 700.00 / [expiry date] |
| CP076 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP077 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP078 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP079 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your original flight from Montreal (YUL) to Toronto (YYZ) was delayed and you were rebooked to Hamilton (YHM |
| CP080 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP081 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP082 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP083 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP084 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP085 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $700 CAD compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a $700 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP086 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP087 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP088 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac (CANADA) |  |
| CP089 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP090 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP091 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP092 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP093 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP094 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP095 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP096 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP097 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP098 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP099 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP100 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP101 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP102 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $700 CAD Payment Method: m***@gmail.com After submission, you will receive a confirmation email summarizing your eligibility, claim details and  |
| CP103 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP104 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP105 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP106 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP107 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP108 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP109 | NOTIFICATION | email | email | And an eligible notification email is sent to m***@gmail.com |  |
| CP110 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($700 CAD), regulation (APPR), flight details (including sister city note: YHM f |  |
| CP111 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP112 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP113 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Marc-Andr� Lavoie" with PNR "TC030" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Marc-Andr� Lavoie" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC030" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Marc-Andr� Lavoie" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "m***@gmail.com" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***456" |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with original flight AC 442 cancelled |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the rebooked flight should be "AC 443 YUL ? YHM" as a sister city diversion |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the claim should be filed for this journey |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated for this automated FD case |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Marc-Andr� Lavoie + TC030 + YUL?YYZ + FD" |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP166 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP167 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP168 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP169 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP170 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP171 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP172 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP173 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP174 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "$700" for Tier 2 delay of 6 to less than 9 hours |  |
| CP175 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP176 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP177 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP178 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP179 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received from Interac |  |
| CP180 | PAYMENT VALIDATION | payment | manual | And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP181 | PAYMENT VALIDATION | payment | manual | And if the payment is unclaimed after 35 days the status should be set to "Expired" |  |
| CP182 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show "$700" CAD |  |
| CP183 | PAYMENT VALIDATION | payment | chat | And the payment method should show "Cash" via "Interac" |  |
| CP184 | PAYMENT VALIDATION | payment | manual | And the status should be updated via talkback |  |
| CP185 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-11. | DDS returns FD-APPR-EL-11. |
| CP186 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 10:00 at YYZ (original flight AC 442, DELAYED); Actual = 17:00 at YHM (rebooked flight AC 443, sister city); Sister C | Trip Tracer: Promise = 10:00 at YYZ (original flight AC 442, DELAYED); Actual = 17:00 at YHM (rebooked flight AC 443, sister city); Sister City = TRUE (YHM?YYZ) |
| CP187 | EXPECTED RESULTS | verdict | chat | Change History: INVOL � AC 442 delayed? customer accepted rebooking to AC 443 YUL?YHM. | Change History: INVOL � AC 442 delayed? customer accepted rebooking to AC 443 YUL?YHM. |
| CP188 | EXPECTED RESULTS | verdict | chat | Compensation: 420 min = Tier 2 = $700 CAD. | Compensation: 420 min = Tier 2 = $700 CAD. |
| CP189 | EXPECTED RESULTS | verdict | chat | Fraud Screening: CyberSource = GREEN. | Fraud Screening: CyberSource = GREEN. |
| CP190 | EXPECTED RESULTS | verdict | chat | IDV: Persona = PASS. | IDV: Persona = PASS. |
| CP191 | EXPECTED RESULTS | verdict | chat | Payment: $700 via Interac e-Transfer to m***@gmail.com. | Payment: $700 via Interac e-Transfer to m***@gmail.com. |
| CP192 | EXPECTED RESULTS | verdict | api | Regime Assessment: APPR = $700 (Sister City + Fallback) ? SELECTED; EU = N/A (domestic); ASL = N/A. | Regime Assessment: APPR = $700 (Sister City + Fallback) ? SELECTED; EU = N/A (domestic); ASL = N/A. |
| CP193 | EXPECTED RESULTS | verdict | api | Claims Dashboard: DDS = FD-APPR-EL-11; Departure delay code 42 (Controllable, Fallback); Sister City = TRUE; Fallback = TRUE; Delay = 7hrs;  | Claims Dashboard: DDS = FD-APPR-EL-11; Departure delay code 42 (Controllable, Fallback); Sister City = TRUE; Fallback = TRUE; Delay = 7hrs; Tier 2; $700 Interac |
