# FD_TC_186 · CHAI-31578 — checkpoints

**Goal:** Customer's flight was disrupted and the system auto-rebooked via REACC (React/Auto-Accommodation). Identifier: MUC1A06AC or YMQAC05IN in PNR history. REACC is classified as INVOL � the promise does NOT update and stays at the 14-day mark. Validates REACC classification as INVOL and that promise remains unchanged.

Methods: seed 1, chat 61, api 17, email 3, dashboard 38, implied 20, manual 12, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer's flight was disrupted and the system auto-rebooked via REACC (React/Auto-Accommodation). Identifier: MUC1A06AC or YMQAC05IN in PNR |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Laurent Tremblay); 1 leg AC YUL?YYZ; Original (14-day) arrival: 10:00; REACC auto-rebook at D-2: new arrival 14:30; A | PNR: Single passenger (Laurent Tremblay); 1 leg AC YUL?YYZ; Original (14-day) arrival: 10:00; REACC auto-rebook at D-2: new arrival 14:30; Actual arrival: 14:30 |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "My flight from Montreal to Toronto was changed by the airline and I arrived much later than planned. Can I get compensati | My flight from Montreal to Toronto was changed by the airline and I arrived much later than planned. Can I get compensation? |
| CP009 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP011 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP012 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP013 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP014 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP015 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Laurent Tremblay" | Laurent Tremblay |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Laurent! And, what is your booking reference number? |
| CP017 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TCINVOL01" | PNR: TCINVOL01 |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TCINVOL01 |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP022 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: l***@gmail.com � Phone: +1***234 |
| CP023 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: l***@gmail.com" | Email: l***@gmail.com |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP025 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP026 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP028 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP029 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP030 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP031 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP032 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Laurent Tremblay (Adult) Is this who you'd like to include? |
| CP033 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP034 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP035 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 421 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 10, 2026 � Arrival Delay: 4.5 hours Is this the journey you |
| CP036 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP037 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP038 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP039 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP040 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP041 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YUL (Canada) ? APPR |  |
| CP042 | TRIAGE & DDS EVALUATION � INVOL CHANGE DETECTED | verdict | api | Then the DDS evaluation is done in backend |  |
| CP043 | TRIAGE & DDS EVALUATION � INVOL CHANGE DETECTED | verdict | api | And DDS checks booking change history: | ? Change 1 (D-2): REACC auto-rebook (identifier: MUC1A06AC / YMQAC05IN in PNR history) ? Classification: INVOL (REACC = system-initiated auto-accommodation afte |
| CP044 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 421, Route: YUL ? YYZ, Scheduled Arrival: 10:00 (14-day mark � NOT updated by REACC) | Promised Itinerary - Flight: AC 421, Route: YUL ? YYZ, Scheduled Arrival: 10:00 (14-day mark � NOT updated by REACC) |
| CP045 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 421, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 14:30, Delay: +4H 30M | Current Itinerary - Flight: AC 421, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual: 14:30, Delay: +4H 30M |
| CP046 | TRIP TRACER UI VALIDATION | verdict | api | Change 1: REACC (MUC1A06AC / YMQAC05IN) at D-2 � INVOL � arrival 10:00 ? 14:30 | Change 1: REACC (MUC1A06AC / YMQAC05IN) at D-2 � INVOL � arrival 10:00 ? 14:30 |
| CP047 | TRIP TRACER UI VALIDATION | verdict | api | Promise = 10:00 (14-day mark � REACC did NOT update it) | Promise = 10:00 (14-day mark � REACC did NOT update it) |
| CP048 | TRIP TRACER UI VALIDATION | verdict | api | Delay from promise = 4.5 hours | Delay from promise = 4.5 hours |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR | Regime: APPR |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | APPR: Delay 3�6h, Controllable ? ELIGIBLE | APPR: Delay 3�6h, Controllable ? ELIGIBLE |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 421 � YUL ? YYZ � 42 | MSL FLIGHT: AC 421 � YUL ? YYZ � 42 |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42) | CONTROLLABLE (Code 42) |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | MR LAURENT TREMBLAY / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 | MR LAURENT TREMBLAY / ELIGIBLE / APPR_3_TO_6_HOURS / CAD $400 |
| CP054 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP055 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP056 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP057 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 421 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours and 30 minutes. Based on the |
| CP058 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP059 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP060 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP061 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP062 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP063 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP064 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP065 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP066 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada) |  |
| CP067 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer. |
| CP068 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | customer | chat | And the user provides "laurent.tremblay@gmail.com" | laurent.tremblay@gmail.com |
| CP069 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | system | implied | Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded." |  |
| CP070 | PAYMENT METHOD � INTERAC E-TRANSFER (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP071 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP072 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP073 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP074 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP075 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP076 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP077 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP078 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP079 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP080 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP081 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: Interac e-Transfer After submission, you will receive a confirmation email summarizing your eligibility, claim details  |
| CP082 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP083 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP084 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP085 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP086 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP087 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP088 | NOTIFICATION | email | email | And an eligible notification email is sent to l***@gmail.com |  |
| CP089 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details (AC 421, YUL?YYZ, 4.5hr delay), ne |  |
| CP090 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP091 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP092 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Laurent Tremblay" with PNR "TCINVOL01" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Laurent Tremblay" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TCINVOL01" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Laurent Tremblay" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility should be "ELIGIBLE" under APPR with compensation "$400 CAD" Tier 1 3 to less than 6hrs controllable |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Change History should show REACC MUC1A06AC or YMQAC05IN as INVOL |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Promise should be 10:00 at 14-day mark NOT updated by REACC |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Actual should be 14:30 |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay should be 4.5hrs |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And INVOL should have been detected via REACC tool MUC1A06AC or YMQAC05IN |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the promise should NOT have been updated and should stay at 14-day mark |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be ELIGIBLE at $400 CAD |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Laurent Tremblay + TCINVOL01 + YUL?YYZ + FD" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing Case Reference and compensation $400 CAD and regulation APPR a |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record REACC INVOL detected MUC1A06AC or YMQAC05IN and promise unchanged at 10:00 and delay 4.5hrs and eligible $40 |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the eligible notification email chronologically |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP137 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP138 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP139 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP140 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered and AC Wallet should NOT be offered |  |
| CP141 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "$400 CAD" APPR Tier 1 3 to less than 6hrs controllable |  |
| CP142 | PAYMENT VALIDATION | payment | chat | And the Interac e-Transfer email should be collected as one-time non-editable after submission |  |
| CP143 | PAYMENT VALIDATION | payment | chat | And IDV at Payment should be triggered via Persona and the customer should complete IDV and Persona should return IDV PASS |  |
| CP144 | PAYMENT VALIDATION | payment | chat | And the claim amount confirmation should show $400 CAD via Interac e-Transfer and the customer should confirm and the claim should be submit |  |
| CP145 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP146 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP147 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier and Unifier should process Interac e-Transfer for $400 CAD |  |
| CP148 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back and the end-of-day report should be received |  |
| CP149 | PAYMENT VALIDATION | payment | manual | And the end-of-day report from Interac should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP150 | PAYMENT VALIDATION | payment | manual | And if unclaimed after 35 days the status should be Expired |  |
| CP151 | PAYMENT VALIDATION | payment | chat | And if payment fails due to invalid email or Interac not registered a failure notification should be sent to the case and the agent should b |  |
| CP152 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details "$400 CAD" with payment method "Cash" via "Interac e-Transfer" and stat |  |
| CP153 | EXPECTED RESULTS | verdict | api | Tool: REACC (MUC1A06AC / YMQAC05IN); Classification: INVOL; Promise: 10:00 (14-day mark � NOT updated); Actual: 14:30; Delay: 4.5hrs; APPR T | Tool: REACC (MUC1A06AC / YMQAC05IN); Classification: INVOL; Promise: 10:00 (14-day mark � NOT updated); Actual: 14:30; Delay: 4.5hrs; APPR Tier 1; ELIGIBLE $400 |
