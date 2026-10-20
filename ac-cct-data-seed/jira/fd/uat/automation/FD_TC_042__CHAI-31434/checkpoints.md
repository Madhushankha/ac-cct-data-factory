# FD_TC_042 · CHAI-31434 — checkpoints

**Goal:** Original flight AC 444 YUL?YYZ was dleayed; Arrival delay code is MISSING. Customer accepts rebooking to AC 445 YUL?YHM (sister city of YYZ). Arrival at YHM is 10 hours after original promised arrival at YYZ. DDS falls back to departure delay code 67 (Cabin Crew Shortage � Controllable). Validates: Sister City + Fallback coexistence at Tier 3 ($1,000, maximum APPR), correct delay calculation across airports (YHM actual vs YYZ promise), and a third controllable fallback code (code 67).

Methods: seed 12, chat 64, api 23, email 3, dashboard 45, implied 21, manual 16, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Original flight AC 444 YUL?YYZ was dleayed; Arrival delay code is MISSING. Customer accepts rebooking to AC 445 YUL?YHM (sister city of YYZ) |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC031 � single passenger (Adult) | PNR: TC031 � single passenger (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Original flight AC 444 YUL?YYZ, scheduled arrival 08:00 at YYZ � DELAYED | Original flight AC 444 YUL?YYZ, scheduled arrival 08:00 at YYZ � DELAYED |
| CP004 | PREREQUISITES | prerequisite | seed | Arrival Delay code: NULL (MISSING) | Arrival Delay code: NULL (MISSING) |
| CP005 | PREREQUISITES | prerequisite | seed | Departure delay code: 67 (Cabin Crew Shortage � Controllable) | Departure delay code: 67 (Cabin Crew Shortage � Controllable) |
| CP006 | PREREQUISITES | prerequisite | seed | Customer accepts INVOL rebooking to AC 445 YUL?YHM (sister city of YYZ), arrives 18:00 | Customer accepts INVOL rebooking to AC 445 YUL?YHM (sister city of YYZ), arrives 18:00 |
| CP007 | PREREQUISITES | prerequisite | seed | Delay: 10hrs (18:00 ? 08:00 = 600 min) | Delay: 10hrs (18:00 ? 08:00 = 600 min) |
| CP008 | PREREQUISITES | prerequisite | seed | Sister city: YHM ? YYZ | Sister city: YHM ? YYZ |
| CP009 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic) | Regime: APPR (domestic) |
| CP010 | PREREQUISITES | prerequisite | seed | Timing: >72hrs elapsed, within 366-day limit | Timing: >72hrs elapsed, within 366-day limit |
| CP011 | PREREQUISITES | prerequisite | seed | No duplicate, not employee, not infant | No duplicate, not employee, not infant |
| CP012 | PREREQUISITES | prerequisite | seed | Aeroplan: not linked ? Cash only | Aeroplan: not linked ? Cash only |
| CP013 | PREREQUISITES | prerequisite | seed | Residence: Canada ? Interac | Residence: Canada ? Interac |
| CP014 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP015 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP016 | START | customer | chat | Then user selects English |  |
| CP017 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP018 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP019 | START | customer | chat | And the user says "My flight from Montreal was supposed to land at Toronto Pearson but delayed and I was rebooked to Hamilton instead and ar | My flight from Montreal was supposed to land at Toronto Pearson but delayed and I was rebooked to Hamilton instead and arrived 10 hours late, I'd like to check  |
| CP020 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP021 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP022 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP023 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Olivier Deschamps" | Olivier Deschamps |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Olivier! And, what is your booking reference number? |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC031" | PNR: TC031 |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC031 |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: o***@gmail.com � Phone: +1***567 |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: o***@gmail.com" | Email: o***@gmail.com |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP037 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP039 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP041 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP043 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Olivier Deschamps (Adult) Is this who you'd like to include? |
| CP044 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP046 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 445 (rebooked from delayedAC 444) � Route: Montreal (YUL) ? Hamilton (YHM) [Rebooked � original destination: Toronto |
| CP047 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP050 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP051 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP052 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 17, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED |  |
| CP053 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP054 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 17, 2026; filing June 15, 2026 ? 29 days ? within 366 days ? PROCEED |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 444, Route: YUL ? YYZ, Scheduled Arrival: 08:00 at YYZ (original flight � DELAYED) | Promised Itinerary - Flight: AC 444, Route: YUL ? YYZ, Scheduled Arrival: 08:00 at YYZ (original flight � DELAYED) |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 445, Route: YUL ? YHM (rebooked to sister city), Status: ARRIVED, Actual Arrival: 18:00 at YHM | Current Itinerary - Flight: AC 445, Route: YUL ? YHM (rebooked to sister city), Status: ARRIVED, Actual Arrival: 18:00 at YHM |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | History - Change 1: INVOL � Original flight AC 444 YUL?YYZ Delayed(Arrival delay code: NULL � MISSING). Customer accepted rebooking to AC 44 | History - Change 1: INVOL � Original flight AC 444 YUL?YYZ Delayed(Arrival delay code: NULL � MISSING). Customer accepted rebooking to AC 445 YUL?YHM (sister ci |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Delay Calculation: Original promise = 08:00 at YYZ (AC 444); Actual arrival = 18:00 at YHM (AC 445, sister city); Delay = 10hrs | Delay Calculation: Original promise = 08:00 at YYZ (AC 444); Actual arrival = 18:00 at YHM (AC 445, sister city); Delay = 10hrs |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Sister City Check: YHM ? YYZ = VALID PAIR (confirmed in DDS sister city config) | Sister City Check: YHM ? YYZ = VALID PAIR (confirmed in DDS sister city config) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Sister city accepted as equivalent destination | Sister city accepted as equivalent destination |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 444 � YUL ? YYZ � ARRIVAL DELAY CODE: NULL (MISSING) | MSL FLIGHT: AC 444 � YUL ? YYZ � ARRIVAL DELAY CODE: NULL (MISSING) |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | FALLBACK TRIGGERED: Arrival code NULL ? using departure code | FALLBACK TRIGGERED: Arrival code NULL ? using departure code |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Departure Code: 42 (Scheduled Maintenance) | Departure Code: 42 (Scheduled Maintenance) |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Fallback Flag: TRUE | Fallback Flag: TRUE |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | CONTROLLABLE (Code 42 via fallback departure code) | CONTROLLABLE (Code 42 via fallback departure code) |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +10H 00M � CONTROLLABLE | Delay: +10H 00M � CONTROLLABLE |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | MR OLIVIER DESCHAMPS / ELIGIBLE / DELAY_GTE_9_HOURS (SISTER CITY + FALLBACK) / CAD 1000.00 / [expiry date] | MR OLIVIER DESCHAMPS / ELIGIBLE / DELAY_GTE_9_HOURS (SISTER CITY + FALLBACK) / CAD 1000.00 / [expiry date] |
| CP071 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP072 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP073 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP074 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 443 from Montreal (YUL) to Toronto (YYZ) was delayed by about 10 hours. Based on the Air Passenger |
| CP075 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP076 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP077 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP078 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP079 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP080 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $1,000 CAD compensation. Please note that it will take 5 to 10 business days to pr | You are entitled to receive a $1,000 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP081 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP082 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP083 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac (CANADA) |  |
| CP084 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP085 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP086 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP087 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP088 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP089 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP090 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP091 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP092 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP093 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP094 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP095 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP096 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP097 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $1,000 CAD Payment Method: o***@gmail.com After submission, you will receive a confirmation email summarizing your eligibility, claim details an |
| CP098 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP099 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP100 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP101 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP102 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP103 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP104 | NOTIFICATION | email | email | And an eligible notification email is sent to o***@gmail.com |  |
| CP105 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($1,000 CAD), regulation (APPR), flight details (including sister city note: YHM |  |
| CP106 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP107 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP108 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Olivier Deschamps" with PNR "TC031" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Olivier Deschamps" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC031" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Olivier Deschamps" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "o***@gmail.com" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***567" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated for this automated FD case |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Olivier Deschamps + TC031 + YUL?YYZ + FD" |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP163 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP164 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP165 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP166 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered |  |
| CP167 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "$1,000" for Tier 3 delay of 9 or more hours |  |
| CP168 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP169 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP170 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP171 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP172 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received from Interac |  |
| CP173 | PAYMENT VALIDATION | payment | manual | And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP174 | PAYMENT VALIDATION | payment | manual | And if the payment is unclaimed after 35 days the status should be set to "Expired" |  |
| CP175 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show "$1,000" CAD |  |
| CP176 | PAYMENT VALIDATION | payment | chat | And the payment method should show "Cash" via "Interac" |  |
| CP177 | PAYMENT VALIDATION | payment | manual | And the status should be updated via talkback |  |
| CP178 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-12. | DDS returns FD-APPR-EL-12. |
| CP179 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 08:00 at YYZ; Actual = 18:00 at YHM (sister city); Delay = 10hrs; MSL = Leg 1 (AC 315, AC operated); Sister City = TR | Trip Tracer: Promise = 08:00 at YYZ; Actual = 18:00 at YHM (sister city); Delay = 10hrs; MSL = Leg 1 (AC 315, AC operated); Sister City = TRUE; Arrival Code = N |
| CP180 | EXPECTED RESULTS | verdict | chat | Compensation: 600 min = Tier 3 = $1,000 CAD (maximum APPR). | Compensation: 600 min = Tier 3 = $1,000 CAD (maximum APPR). |
| CP181 | EXPECTED RESULTS | verdict | chat | Fraud Screening: CyberSource = GREEN. | Fraud Screening: CyberSource = GREEN. |
| CP182 | EXPECTED RESULTS | verdict | chat | IDV: Persona = PASS. | IDV: Persona = PASS. |
| CP183 | EXPECTED RESULTS | verdict | chat | Payment: $1,000 via Interac e-Transfer to a***@gmail.com. | Payment: $1,000 via Interac e-Transfer to a***@gmail.com. |
| CP184 | EXPECTED RESULTS | verdict | api | Regime Assessment: APPR = $1,000 (Sister City + Fallback) ? SELECTED; EU = N/A; ASL = N/A. | Regime Assessment: APPR = $1,000 (Sister City + Fallback) ? SELECTED; EU = N/A; ASL = N/A. |
| CP185 | EXPECTED RESULTS | verdict | chat | Sister City + Fallback Tier . | Sister City + Fallback Tier . |
