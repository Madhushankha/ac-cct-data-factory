# FD_TC_210 · CHAI-31602 — checkpoints

**Goal:** Customer is denied boarding on a PAL-operated flight within an AC-ticketed itinerary. Denied boarding is a distinct disruption type from delay/cancellation. Validates that DDS correctly identifies the denied boarding event on a PAL-operated leg, determines PAL as the MSL, and assesses APPR eligibility. Since PAL coding is known to be spotty, this test also confirms DDS behaviour when the denied boarding reason code from PAL may be missing or incomplete. Denied boarding under APPR has specific compensation tiers and the customer must have been rebooked or chose not to travel.

Methods: seed 13, chat 68, api 22, email 3, dashboard 48, implied 22, manual 11, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer is denied boarding on a PAL-operated flight within an AC-ticketed itinerary. Denied boarding is a distinct disruption type from del |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Antoine Lavoie), multi-leg itinerary | PNR: Single passenger (Antoine Lavoie), multi-leg itinerary |
| CP003 | PREREQUISITES | prerequisite | seed | Leg 1: AC 501 YUL?MNL (AC operated, no disruption) | Leg 1: AC 501 YUL?MNL (AC operated, no disruption) |
| CP004 | PREREQUISITES | prerequisite | seed | Leg 2: PAL 205 MNL?CEB (PAL operated, DENIED BOARDING) | Leg 2: PAL 205 MNL?CEB (PAL operated, DENIED BOARDING) |
| CP005 | PREREQUISITES | prerequisite | seed | Customer was denied boarding on PAL 205 due to overbooking | Customer was denied boarding on PAL 205 due to overbooking |
| CP006 | PREREQUISITES | prerequisite | seed | Customer was rebooked on next available PAL flight: PAL 207 MNL?CEB, arriving 5 hours later | Customer was rebooked on next available PAL flight: PAL 207 MNL?CEB, arriving 5 hours later |
| CP007 | PREREQUISITES | prerequisite | seed | Original Leg 2 scheduled arrival: 14:00 | Original Leg 2 scheduled arrival: 14:00 |
| CP008 | PREREQUISITES | prerequisite | seed | Rebooked arrival: 19:00 (5hr delay at final destination) | Rebooked arrival: 19:00 (5hr delay at final destination) |
| CP009 | PREREQUISITES | prerequisite | seed | Denied boarding reason: Overbooking (if PAL coding present) | Denied boarding reason: Overbooking (if PAL coding present) |
| CP010 | PREREQUISITES | prerequisite | seed | Booking changes: INVOL rebooking after denied boarding | Booking changes: INVOL rebooking after denied boarding |
| CP011 | PREREQUISITES | prerequisite | seed | Carrier: AC ticketing carrier, PAL operating carrier on denied boarding leg | Carrier: AC ticketing carrier, PAL operating carrier on denied boarding leg |
| CP012 | PREREQUISITES | prerequisite | seed | 72hrs: Elapsed | 72hrs: Elapsed |
| CP013 | PREREQUISITES | prerequisite | seed | Time limit: Within 366 days | Time limit: Within 366 days |
| CP014 | PREREQUISITES | prerequisite | seed | No duplicate case | No duplicate case |
| CP015 | PREREQUISITES | prerequisite | implied | CyberSource: GREEN | CyberSource: GREEN |
| CP016 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP017 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP018 | START | customer | chat | Then user selects English |  |
| CP019 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP020 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP021 | START | customer | chat | And the user says "I was denied boarding on my PAL flight because it was overbooked. They put me on a later flight and I arrived 4 hours lat | I was denied boarding on my PAL flight because it was overbooked. They put me on a later flight and I arrived 4 hours late. I want compensation. |
| CP022 | START | system | implied | When the chatbot identifies denied boarding intent |  |
| CP023 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP024 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your denied boarding and see if you are eligible for compensation. | No problem, I can help you create a claim for your denied boarding and see if you are eligible for compensation. |
| CP025 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Fran�oise Lavoie" | Fran�oise Lavoie |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Fran�oise! And, what is your booking reference number? |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC017" | PNR: TC017 |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC017 |  |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: f***@gmail.com � Phone: +1***678 |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: f***@gmail.com" | Email: f***@gmail.com |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "581937" | 581937 |
| CP039 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP041 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP042 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP043 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP044 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP045 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Fran�oise Lavoie (Adult) Is this who you'd like to include? |
| CP046 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP047 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP048 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Leg 1: AC 501 � Montreal (YUL) ? Toronto (YYZ) � July 10, 2026 � Leg 2: PAL 802 � Toronto (YYZ) ? Vancouver (YVR) � July 10, 20 |
| CP049 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP050 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 legs + rebooking) |  |
| CP051 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot identifies: Denied boarding occurred on Leg 2 (PAL 802 YYZ?YVR) |  |
| CP052 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot confirms segments with customer |  |
| CP053 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP054 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP055 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP056 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days ? within 366 days ? PROCEED |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS evaluates: Disruption type = DENIED BOARDING (not delay/cancellation) |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS evaluates: Was denied boarding voluntary or involuntary? ? INVOLUNTARY (overbooking) |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | And DDS evaluates: Delay at final destination = 4 hours |  |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Leg 1: AC 501 YUL?YYZ, Leg 2: PAL 802 YYZ?YVR, Scheduled Final Arrival: 18:00 | Promised Itinerary - Leg 1: AC 501 YUL?YYZ, Leg 2: PAL 802 YYZ?YVR, Scheduled Final Arrival: 18:00 |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Leg 1: AC 501 YUL?YYZ (ON TIME), Leg 2: PAL 802 YYZ?YVR (DENIED BOARDING), Rebooked: PAL 806 YYZ?YVR, Actual Final Arriv | Current Itinerary - Leg 1: AC 501 YUL?YYZ (ON TIME), Leg 2: PAL 802 YYZ?YVR (DENIED BOARDING), Rebooked: PAL 806 YYZ?YVR, Actual Final Arrival: 22:00, Delay: +4 |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Disruption Type: DENIED BOARDING (not delay/cancellation) | Disruption Type: DENIED BOARDING (not delay/cancellation) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR | Regime: APPR |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: PAL 802 � YYZ ? YVR � 97 | MSL FLIGHT: PAL 802 � YYZ ? YVR � 97 |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | "Denied boarding due to overbooking" | "Denied boarding due to overbooking" |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Delay at destination: +4H 00M | Delay at destination: +4H 00M |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Denied Boarding Classification: INVOLUNTARY | Denied Boarding Classification: INVOLUNTARY |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | PAL coding: Code 97 � PRESENT (verify coding is populated for DB scenario) | PAL coding: Code 97 � PRESENT (verify coding is populated for DB scenario) |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | MS FRAN�OISE LAVOIE / ELIGIBLE / DENIED_BOARDING / DELAY_AT_DEST_GTE_2_HRS / CAD 900.00 / [expiry date] | MS FRAN�OISE LAVOIE / ELIGIBLE / DENIED_BOARDING / DELAY_AT_DEST_GTE_2_HRS / CAD 900.00 / [expiry date] |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | CRITICAL: DB compensation tier applies (NOT FD delay tier). Under APPR, involuntary denied boarding with ?2hr delay at destination = $900 CA | CRITICAL: DB compensation tier applies (NOT FD delay tier). Under APPR, involuntary denied boarding with ?2hr delay at destination = $900 CAD |
| CP072 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP073 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) |  |
| CP074 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP075 | ELIGIBLE RESULT (DB-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like you were denied boarding on flight PAL 802 from Toronto (YYZ) to Vancouver (YVR) due to overbooking. You wer |
| CP076 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP077 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP078 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP079 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP080 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? No |  |
| CP081 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $900 CAD compensation for denied boarding. Please note that it will take 5 to 10 b | You are entitled to receive a $900 CAD compensation for denied boarding. Please note that it will take 5 to 10 business days to process payment. Would you like  |
| CP082 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP083 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP084 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac (CANADA) |  |
| CP085 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP086 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP087 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP088 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP089 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP090 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP091 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP092 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP093 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP094 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP095 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP096 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP097 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP098 | CLAIM AMOUNT CONFIRMATION | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $900 CAD Payment Method: f***@gmail.com After submission, you will receive a confirmation email summarizing your eligibility, claim details and  |
| CP099 | CLAIM AMOUNT CONFIRMATION | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP100 | CLAIM AMOUNT CONFIRMATION | customer | chat | When the user provides: "Yes" | Yes |
| CP101 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP102 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP103 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP104 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP105 | NOTIFICATION | email | email | And an eligible notification email is sent to f***@gmail.com |  |
| CP106 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($900 CAD), regulation (APPR), disruption type (Denied Boarding), flight details |  |
| CP107 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP108 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP109 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Antoine Lavoie" with PNR "TC184" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Denied Boarding" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Antoine Lavoie" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC184" |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Type should be "Denied Boarding" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier should be "PAL" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ticketing Carrier should be "AC" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Antoine Lavoie" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "a***@gmail.com" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***678" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? MNL (AC 501, on time) ? MNL ? CEB (PAL 205, denied boarding ? rebooked PAL 207)" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and populated with Disruption Type "Denied Boarding" and Compensation "$900 C |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the MSL should be PAL 205 |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating carrier PAL should be clearly displayed |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption type Denied Boarding should be clearly displayed |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Antoine Lavoie + TC184 + YUL?MNL?CEB + DB" |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP166 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP167 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP168 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP169 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered with no AC Wallet option |  |
| CP170 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "$900 CAD" for APPR Denied Boarding tier for delay 0 to less than 6 hours at destination NOT $400 CAD  |  |
| CP171 | PAYMENT VALIDATION | payment | chat | And the APPR Denied Boarding compensation schedule should be $900 for delays 0 to less than 6 hours and $1,800 for delays 6 to less than 9 h |  |
| CP172 | PAYMENT VALIDATION | payment | chat | And this test case has a 4-hour delay at destination so $900 applies |  |
| CP173 | PAYMENT VALIDATION | payment | chat | And IDV should be completed via Persona and Persona should return IDV PASS |  |
| CP174 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the system |  |
| CP175 | PAYMENT VALIDATION | payment | manual | And a daily batch file should be generated and dispatched to Unifier |  |
| CP176 | PAYMENT VALIDATION | payment | manual | And Unifier acknowledgement should be received |  |
| CP177 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" and monitor for Cached or Rejected or Expired |  |
| CP178 | PAYMENT VALIDATION | payment | chat | And the 35-day expiry rule should apply |  |
| CP179 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show Amount $900 Currency CAD Method Cash Interac Status Pending or Completed |  |
| CP180 | PAYMENT VALIDATION | payment | chat | And the payment confirmation email and Adobe notification should both reference "Denied Boarding" as the disruption type not "Delay" or "Can |  |
| CP181 | PAYMENT VALIDATION | payment | chat | And if PAL denied boarding coding Code 97 is missing in a variant run the same behaviour as Sub-Scenario B applies with no automated payment |  |
| CP182 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-DB-01. | DDS returns FD-APPR-DB-01. |
| CP183 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 14:00 (original PAL 205 arrival); Rebooked flight PAL 207 arrival = 19:00; Delay at destination = 5hrs; Disruption Ty | Trip Tracer: Promise = 14:00 (original PAL 205 arrival); Rebooked flight PAL 207 arrival = 19:00; Delay at destination = 5hrs; Disruption Type = DENIED BOARDING |
| CP184 | EXPECTED RESULTS | verdict | chat | Compensation: $900 CAD (APPR Denied Boarding, 3�<6hrs delay at destination). | Compensation: $900 CAD (APPR Denied Boarding, 3�<6hrs delay at destination). |
| CP185 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN ? auto-approved. | CyberSource: GREEN ? auto-approved. |
| CP186 | EXPECTED RESULTS | verdict | api | CRITICAL: DDS must correctly identify DENIED BOARDING as the disruption type (not delay or cancellation). | CRITICAL: DDS must correctly identify DENIED BOARDING as the disruption type (not delay or cancellation). |
| CP187 | EXPECTED RESULTS | verdict | chat | CRITICAL: If PAL denied boarding coding is missing ? case must route to agent queue (same behaviour as TC_016 Scenario B). | CRITICAL: If PAL denied boarding coding is missing ? case must route to agent queue (same behaviour as TC_016 Scenario B). |
| CP188 | EXPECTED RESULTS | verdict | chat | CRITICAL: Denied boarding compensation tier ($900) is different from delay compensation tier ($400) � verify correct amount. | CRITICAL: Denied boarding compensation tier ($900) is different from delay compensation tier ($400) � verify correct amount. |
