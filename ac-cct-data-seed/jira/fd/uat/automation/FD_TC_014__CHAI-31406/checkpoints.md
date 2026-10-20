# FD_TC_014 · CHAI-31406 — checkpoints

**Goal:** Three adults on the same PNR. One claimant files for all three. Validates that DDS calculates per-passenger compensation ($400 each) and total payout is $1,200 ($400 � 3). Confirms passenger selection logic allows filing for multiple passengers on same booking.

Methods: seed 6, chat 75, api 16, email 3, dashboard 250, implied 22, manual 52, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Three adults on the same PNR. One claimant files for all three. Validates that DDS calculates per-passenger compensation ($400 each) and tot |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: 3 passengers (Catherine Bouchard, Marc Bouchard, Sophie Bouchard � all adults), 1 leg AC domestic YUL?YYZ | PNR: 3 passengers (Catherine Bouchard, Marc Bouchard, Sophie Bouchard � all adults), 1 leg AC domestic YUL?YYZ |
| CP003 | PREREQUISITES | prerequisite | seed | Itinerary: Scheduled arrival 14:00, Actual arrival 18:00 (4hr delay) | Itinerary: Scheduled arrival 14:00, Actual arrival 18:00 (4hr delay) |
| CP004 | PREREQUISITES | prerequisite | seed | Arrival delay code: 56 (Crew Legality) | Arrival delay code: 56 (Crew Legality) |
| CP005 | PREREQUISITES | prerequisite | seed | Booking changes: None | Booking changes: None |
| CP006 | PREREQUISITES | prerequisite | seed | Claimant: Catherine Bouchard files for all 3 | Claimant: Catherine Bouchard files for all 3 |
| CP007 | PREREQUISITES | prerequisite | seed | All 3 passengers arrived on same flight | All 3 passengers arrived on same flight |
| CP008 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP009 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP010 | START | customer | chat | Then user selects English |  |
| CP011 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP012 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP013 | START | customer | chat | And the user says "My family's flight was delayed 4 hours, there are 3 of us on the booking, we all want compensation" | My family's flight was delayed 4 hours, there are 3 of us on the booking, we all want compensation |
| CP014 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP015 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP016 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP017 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP018 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP019 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP020 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Catherine Bouchard" | Catherine Bouchard |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Catherine! And, what is your booking reference number? |
| CP022 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC012" | PNR: TC012 |
| CP023 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC012 |  |
| CP024 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP025 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: c***@gmail.com � Phone: +1***123 |
| CP028 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: c***@gmail.com" | Email: c***@gmail.com |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP030 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629481" | 629481 |
| CP031 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP033 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP034 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP035 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP036 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP037 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 3 passengers on this booking: � Catherine Bouchard (Adult) � Marc Bouchard (Adult) � Sophie Bouchard (Adult) Which passengers would you like to include? |
| CP038 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user selects all 3 passengers: "All of them" | All of them |
| CP039 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 3 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP040 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot confirms: "I'll include all 3 passengers in this claim: Catherine Bouchard, Marc Bouchard, and Sophie Bouchard." |  |
| CP041 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 424 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: May 15, 2026 � Arrival Delay: 4 hours Is this the journey you'd  |
| CP042 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP043 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for these passengers + journey combination |  |
| CP046 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP047 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 15, 2026; current date is June 4, 2026 ? >72 hours ? PROCEED |  |
| CP048 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP049 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 15, 2026; filing June 4, 2026 ? within 366 days ? PROCEED |  |
| CP050 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP051 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 424, Route: YUL ? YYZ, Scheduled Arrival: 14:00 (14-day mark) | Promised Itinerary - Flight: AC 424, Route: YUL ? YYZ, Scheduled Arrival: 14:00 (14-day mark) |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 424, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: ~~14:00~~ ? Actual: 18:00, Delay: +4H 00M | Current Itinerary - Flight: AC 424, Route: YUL ? YYZ, Status: ARRIVED LATE, Scheduled Arrival: ~~14:00~~ ? Actual: 18:00, Delay: +4H 00M |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | History - No changes recorded | History - No changes recorded |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 424 � YUL ? YYZ � 56 | MSL FLIGHT: AC 424 � YUL ? YYZ � 56 |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to crew legality" | "Delayed due to crew legality" |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +4H 00M � CONTROLLABLE | Delay: +4H 00M � CONTROLLABLE |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | MS CATHERINE BOUCHARD / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 / [expiry date] | MS CATHERINE BOUCHARD / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 / [expiry date] |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | MR MARC BOUCHARD / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 / [expiry date] | MR MARC BOUCHARD / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 / [expiry date] |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | MS SOPHIE BOUCHARD / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 / [expiry date] | MS SOPHIE BOUCHARD / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 / [expiry date] |
| CP062 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP063 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP064 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP065 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 424 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours. Based on the Air Passenger  |
| CP066 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP067 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP068 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP069 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP070 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? Yes (3 passengers) |  |
| CP071 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "Each passenger is entitled to receive $400 CAD compensation, for a total of $1,200 CAD for all 3 passengers. Ple | Each passenger is entitled to receive $400 CAD compensation, for a total of $1,200 CAD for all 3 passengers. Please note that it will take 5 to 10 business days |
| CP072 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP073 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP074 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac (CANADA) |  |
| CP075 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP076 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP077 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP078 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP081 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP082 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP083 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP084 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP085 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP086 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP087 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP088 | CLAIM AMOUNT CONFIRMATION | bot | chat | Then the chatbot responds: "Please review your compensation details: | Passengers: Catherine Bouchard, Marc Bouchard, Sophie Bouchard Deposit Amount: $1,200 CAD ($400 � 3 passengers) Payment Method: c***@gmail.com After submission, |
| CP089 | CLAIM AMOUNT CONFIRMATION | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP090 | CLAIM AMOUNT CONFIRMATION | customer | chat | When the user provides: "Yes" | Yes |
| CP091 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP092 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP093 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP094 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP095 | NOTIFICATION | email | email | And an eligible notification email is sent to c***@gmail.com |  |
| CP096 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($1,200 CAD total, $400 per passenger), regulation (APPR), flight details, all 3 |  |
| CP097 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP098 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP099 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Feature: Claims Dashboard Validation � TC011 Catherine Bouchard (3 Passengers) | Scenario: Validate Claims Dashboard for TC011 Catherine Bouchard (3 Passengers) |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Catherine Bouchard" with PNR "TC011" and 3 passengers |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Catherine Bouchard" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC011" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Passenger 1 Full Name should be "Catherine Bouchard" with Tags "Claimant" and "Adult" and Email "c***@gmail.com" and Phone "+1***123" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Passenger 2 Full Name should be "Marc Bouchard" with Tags "Adult" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Passenger 3 Full Name should be "Sophie Bouchard" with Tags "Adult" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to add or remove passengers from the claim |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated for this automated FD case |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Catherine Bouchard + Marc Bouchard + Sophie Bouchard + TC011 + YU |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Feature: Payment Validation � TC011 Catherine Bouchard (3 Passengers) Scenario: Validate Payment for TC011 Catherine Bouchard (3 Passengers) |
| CP155 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP156 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP157 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP158 | PAYMENT VALIDATION | payment | chat | And all 3 passengers are eligible so the aggregated total should be displayed as "$400 x 3 = $1,200" |  |
| CP159 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP160 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP161 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP162 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP163 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received from Interac |  |
| CP164 | PAYMENT VALIDATION | payment | manual | And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP165 | PAYMENT VALIDATION | payment | manual | And if the payment is unclaimed after 35 days the status should be set to "Expired" |  |
| CP166 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should verify the per-passenger amount |  |
| CP167 | PAYMENT VALIDATION | payment | chat | And the total amount should be displayed |  |
| CP168 | PAYMENT VALIDATION | payment | chat | And the currency should be displayed |  |
| CP169 | PAYMENT VALIDATION | payment | chat | And the payment method should be displayed |  |
| CP170 | PAYMENT VALIDATION | payment | manual | And the status should be updated via talkback | Feature: Claims Dashboard Validation � TC012 Group Booking Redirect Scenario: Validate Claims Dashboard for TC012 Group Booking Redirect |
| CP171 | PAYMENT VALIDATION | payment | chat | Given the group booking identifier was detected in Trip Tracer for PNR "TC012" |  |
| CP172 | PAYMENT VALIDATION | payment | chat | Then the chatbot should have redirected the customer to Customer Relations via phone, email, or online |  |
| CP173 | PAYMENT VALIDATION | payment | chat | And no passenger selection should have occurred |  |
| CP174 | PAYMENT VALIDATION | payment | chat | And no journey selection should have occurred |  |
| CP175 | PAYMENT VALIDATION | payment | chat | And no DDS evaluation should have occurred |  |
| CP176 | PAYMENT VALIDATION | payment | chat | And no case should have been created in the automated system |  |
| CP177 | PAYMENT VALIDATION | payment | chat | And no Claims Dashboard entry should exist for PNR "TC012" |  |
| CP178 | PAYMENT VALIDATION | payment | chat | And when searching Claims Dashboard by PNR "TC012" no case should be found | Feature: Payment Validation � TC012 Group Booking Scenario: Validate Payment for TC012 Group Booking |
| CP179 | PAYMENT VALIDATION | payment | chat | Given the group booking allows the customer to claim for self only and passenger selection is skipped |  |
| CP180 | PAYMENT VALIDATION | payment | chat | Then the payment flow should proceed for 1 passenger only |  |
| CP181 | PAYMENT VALIDATION | payment | chat | And the customer's country of residence is "Canada" |  |
| CP182 | PAYMENT VALIDATION | payment | chat | And the currency should be set to "CAD" |  |
| CP183 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP184 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created |  |
| CP185 | PAYMENT VALIDATION | payment | manual | And the record should be picked up by the daily evening batch file |  |
| CP186 | PAYMENT VALIDATION | payment | manual | And the record should be dispatched to Unifier |  |
| CP187 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually |  |
| CP188 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP189 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received from Interac |  |
| CP190 | PAYMENT VALIDATION | payment | manual | And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP191 | PAYMENT VALIDATION | payment | manual | And if the payment is unclaimed after 35 days the status should be set to "Expired" |  |
| CP192 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show payout details for the single claimant only | Feature: Claims Dashboard Validation � TC013 Catherine Bouchard Scenario: Validate Claims Dashboard for TC013 Catherine Bouchard |
| CP193 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Catherine Bouchard" with PNR "TC013" |  |
| CP194 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP195 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP196 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP197 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP198 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP199 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP200 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP201 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP202 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP203 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Catherine Bouchard" |  |
| CP204 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP205 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP206 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC013" |  |
| CP207 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP208 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP209 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP210 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP211 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP212 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Catherine Bouchard" |  |
| CP213 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP214 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "c***@gmail.com" |  |
| CP215 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***345" |  |
| CP216 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP217 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP218 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP219 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP220 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP221 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP222 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP223 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated for this automated FD case |  |
| CP224 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP225 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP226 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated |  |
| CP227 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Catherine Bouchard + TC013 + YUL?YYZ + FD" |  |
| CP228 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP229 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP230 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP231 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP232 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP233 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP234 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP235 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP236 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP237 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP238 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP239 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP240 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP241 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP242 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP243 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP244 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP245 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP246 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Feature: Payment Validation � TC013 Catherine Bouchard Scenario: Validate Payment for TC013 Catherine Bouchard |
| CP247 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the CyberSource fraud screening result is "GREEN" so the normal payment flow should proceed |  |
| CP248 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the customer's country of residence is "Canada" |  |
| CP249 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the currency should be set to "CAD" |  |
| CP250 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the payment method should be "Interac e-Transfer" |  |
| CP251 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP252 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a compensation record should be created |  |
| CP253 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the record should be picked up by the daily evening batch file |  |
| CP254 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the record should be dispatched to Unifier |  |
| CP255 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And in UAT the batch file should be triggered manually |  |
| CP256 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Unifier should send an acknowledgement back |  |
| CP257 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the end-of-day report should be received from Interac |  |
| CP258 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP259 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if the payment is unclaimed after 35 days the status should be set to "Expired" |  |
| CP260 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard Compensation tab should show the correct amount |  |
| CP261 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the currency should be displayed |  |
| CP262 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the payment method should be displayed |  |
| CP263 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the status should be updated | Feature: Claims Dashboard Validation � TC014 Fran�ois Pelletier (CyberSource YELLOW) Scenario: Validate Claims Dashboard for TC014 Fran�ois Pelletier (CyberSour |
| CP264 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Fran�ois Pelletier" with PNR "TC014" |  |
| CP265 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP266 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP267 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP268 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP269 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP270 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP271 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP272 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP273 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP274 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Fran�ois Pelletier" |  |
| CP275 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP276 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP277 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC014" |  |
| CP278 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP279 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP280 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP281 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP282 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP283 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Fran�ois Pelletier" |  |
| CP284 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP285 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "f***@gmail.com" |  |
| CP286 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***456" |  |
| CP287 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP288 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP289 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP290 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP291 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP292 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP293 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP294 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated for this automated FD case |  |
| CP295 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP296 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP297 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated |  |
| CP298 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Fran�ois Pelletier + TC014 + YUL?YYZ + FD" |  |
| CP299 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP300 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP301 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP302 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "YELLOW" indicating suspicious activity detected |  |
| CP303 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should move to the Fraud Queue in Claims Dashboard |  |
| CP304 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource team should review in their tool and not in Claims Dashboard |  |
| CP305 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be parked with no agent able to action it until CyberSource responds |  |
| CP306 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Queue should only be visible to fraud team and management roles |  |
| CP307 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the customer flow should have continued as YELLOW does not block the customer |  |
| CP308 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if CyberSource approves the case from YELLOW status the case should resume the automated flow |  |
| CP309 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if CyberSource rejects the case after YELLOW review a rejection notification should be sent and the case should be closed with a specifi |  |
| CP310 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP311 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP312 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP313 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" to "Parked" awaiting CyberSource review |  |
| CP314 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP315 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe as YELLOW does not block customer messaging |  |
| CP316 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP317 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values including the CyberSource YELLOW flag |  |
| CP318 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP319 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP320 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP321 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Parked" awaiting CyberSource fraud team review |  |
| CP322 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should NOT be in read-only mode yet as it is pending fraud review outcome |  |
| CP323 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Feature: Payment Validation � TC014 Fran�ois Pelletier (CyberSource YELLOW) Scenario: Validate Payment for TC014 Fran�ois Pelletier (CyberSource YELLOW) |
| CP324 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the CyberSource fraud screening result is "YELLOW" |  |
| CP325 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the customer flow should continue normally |  |
| CP326 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | But the compensation should be HELD pending manual review by the CyberSource team | Feature: Claims Dashboard Validation � TC015 Alain Moreau (CyberSource RED) Scenario: Validate Claims Dashboard for TC015 Alain Moreau (CyberSource RED) |
| CP327 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Alain Moreau" with PNR "TC015" |  |
| CP328 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP329 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP330 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Pending Fraud Manual Review" |  |
| CP331 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP332 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP333 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP334 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "Fraud Investigation Team" |  |
| CP335 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP336 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel may be restricted due to fraud flag |  |
| CP337 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Alain Moreau" |  |
| CP338 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP339 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP340 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC015" |  |
| CP341 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP342 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP343 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP344 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP345 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP346 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Alain Moreau" |  |
| CP347 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP348 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "a***@outlook.com" |  |
| CP349 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***567" |  |
| CP350 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP351 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP352 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP353 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP354 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP355 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP356 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP357 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and DDS should have determined eligible but payment should be blocked by Cybe |  |
| CP358 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP359 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP360 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as eligible per DDS but blocked by fraud |  |
| CP361 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Alain Moreau + TC015 + YUL?YYZ + FD" |  |
| CP362 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP363 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP364 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP365 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "RED" indicating fraud detected and high risk |  |
| CP366 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the customer should have been told the case cannot be processed through the automated system and redirected to Customer Relations |  |
| CP367 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the automated payment flow should have been BLOCKED |  |
| CP368 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no payment should have been initiated with no country of residence, no payment method, and no IDV |  |
| CP369 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should be flagged as "FRAUD DETECTED" |  |
| CP370 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should be routed to the fraud investigation team |  |
| CP371 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a dispute option should be offered as required by privacy law |  |
| CP372 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if disputed the case should go to the CyberSource queue for review |  |
| CP373 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And if CyberSource rejects the case after review a rejection notification should be sent and the case should be closed with a specific closu |  |
| CP374 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP375 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP376 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should be routed directly to the fraud investigation team and not the regular agent queue |  |
| CP377 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a generic notification email should have been sent to "a***@outlook.com" |  |
| CP378 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email should contain the Case Reference and a generic message about contacting Customer Relations |  |
| CP379 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email should NOT mention fraud detection as a security measure |  |
| CP380 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP381 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps including the CyberSource RED flag and BLOCK action |  |
| CP382 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the generic notification email |  |
| CP383 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP384 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP385 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Blocked � Fraud Review" |  |
| CP386 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should NOT be resolved as it is pending fraud investigation outcome |  |
| CP387 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP388 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Queue should only be visible to fraud team and management roles | Feature: Payment Validation � TC015 Alain Moreau (CyberSource RED) Scenario: Validate Payment for TC015 Alain Moreau (CyberSource RED) |
| CP389 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the CyberSource fraud screening result is "RED" |  |
| CP390 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then no payment flow should be triggered |  |
| CP391 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the customer should be offered a dispute option as required by privacy law |  |
| CP392 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claims Dashboard should show CyberSource result as "RED" |  |
| CP393 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should be auto-rejected |  |
| CP394 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a dispute record should exist if the customer disputed | Feature: Claims Dashboard Validation � TC016 Diane Lefebvre (CyberSource GREEN + RDS Flag) Scenario: Validate Claims Dashboard for TC016 Diane Lefebvre (CyberSo |
| CP395 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Diane Lefebvre" with PNR "TC016" |  |
| CP396 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP397 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP398 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP399 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP400 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP401 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP402 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP403 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP404 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP405 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Diane Lefebvre" |  |
| CP406 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP407 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP408 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC016" |  |
| CP409 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP410 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP411 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP412 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP413 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP414 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Diane Lefebvre" |  |
| CP415 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP416 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "d***@gmail.com" |  |
| CP417 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***678" |  |
| CP418 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP419 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP420 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP421 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP422 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP423 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP424 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP425 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibil |  |
