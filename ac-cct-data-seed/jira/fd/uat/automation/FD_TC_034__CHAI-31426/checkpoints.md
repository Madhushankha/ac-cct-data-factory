# FD_TC_034 · CHAI-31426 — checkpoints

**Goal:** The customer's original flight AC 435 YUL?YYZ was CANCELLED with code HDLG (ACS): a security check by AC's own ground handling, which is controllable. The customer was involuntarily moved to the renumbered flight AC 445 YUL?YYZ. AC 445 has the same scheduled departure (08:00) but arrives at 17:00, 7 hours after the original promised arrival of 10:00. A Basic Aeroplan profile (9876543210) is linked. Checks six things: (1) involuntary reprotection and renumbering (AC 435 ? AC 445) are handled, (2) delay = actual arrival on AC 445 (17:00) minus original promise (10:00) = 7 hours, in the 6 to under 9 hour band (APPR Tier 2), (3) HDLG (ACS) is classed as controllable, (4) APPR Tier 2 applies (CAD 700 cash / CAD 840 AC Wallet), (5) the linked Basic Aeroplan profile triggers the dual offer, and (6) the customer picks Cash (CAD 700 by Interac).

Methods: seed 13, chat 67, api 30, email 3, dashboard 42, implied 23, manual 17, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | The customer's original flight AC 435 YUL?YYZ was CANCELLED with code HDLG (ACS): a security check by AC's own ground handling, which is con |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR TC082: one passenger, Dominique Arsenault (Adult, Basic Aeroplan 9876543210, good standing) | PNR TC082: one passenger, Dominique Arsenault (Adult, Basic Aeroplan 9876543210, good standing) |
| CP003 | PREREQUISITES | prerequisite | seed | Original flight: AC 435 YUL?YYZ, May 10, 2026, scheduled departure 08:00, scheduled arrival 10:00 | Original flight: AC 435 YUL?YYZ, May 10, 2026, scheduled departure 08:00, scheduled arrival 10:00 |
| CP004 | PREREQUISITES | prerequisite | seed | AC 435 CANCELLED, cancellation code HDLG (ACS), security check by ACS ground handling, controllable | AC 435 CANCELLED, cancellation code HDLG (ACS), security check by ACS ground handling, controllable |
| CP005 | PREREQUISITES | prerequisite | seed | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP006 | PREREQUISITES | prerequisite | seed | INVOL reprotection onto renumbered flight AC 445 YUL?YYZ: scheduled departure 08:00 (same as original), actual arrival 17:00 | INVOL reprotection onto renumbered flight AC 445 YUL?YYZ: scheduled departure 08:00 (same as original), actual arrival 17:00 |
| CP007 | PREREQUISITES | prerequisite | seed | Delay: 17:00 ? 10:00 = 7 hours | Delay: 17:00 ? 10:00 = 7 hours |
| CP008 | PREREQUISITES | prerequisite | seed | Status: Arrived (operated) | Status: Arrived (operated) |
| CP009 | PREREQUISITES | prerequisite | seed | AC only | AC only |
| CP010 | PREREQUISITES | prerequisite | seed | Filed June 15, 2026 (more than 72 hours after arrival, 36 days, within 366 days) | Filed June 15, 2026 (more than 72 hours after arrival, 36 days, within 366 days) |
| CP011 | PREREQUISITES | prerequisite | seed | No duplicate | No duplicate |
| CP012 | PREREQUISITES | prerequisite | seed | Not an employee, not an infant | Not an employee, not an infant |
| CP013 | PREREQUISITES | prerequisite | implied | CyberSource set to GREEN | CyberSource set to GREEN |
| CP014 | PREREQUISITES | prerequisite | seed | Persona set to IDV PASS | Persona set to IDV PASS |
| CP015 | PREREQUISITES | prerequisite | implied | RDS: no flags | RDS: no flags |
| CP016 | PREREQUISITES | prerequisite | seed | Country of residence: Canada (CAD, Interac, email only) | Country of residence: Canada (CAD, Interac, email only) |
| CP017 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP018 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP019 | START | customer | chat | Then user selects English |  |
| CP020 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP021 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP022 | START | customer | chat | And the user says "My flight from Montreal to Toronto was cancelled because the ground handling team had to do a security check on the aircr | My flight from Montreal to Toronto was cancelled because the ground handling team had to do a security check on the aircraft, and I was moved to a renumbered fl |
| CP023 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP024 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP025 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP026 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable." | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Dominique Arsenault" | Dominique Arsenault |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, Dominique! And, what is your booking reference number?" | Thanks, Dominique! And, what is your booking reference number? |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC082" | PNR: TC082 |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC082 |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details, linked Aeroplan profile) is revealed to the customer |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: Email: d***@gmail.com / Phone: +1***890 |  |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: d***@gmail.com" | Email: d***@gmail.com |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP042 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP043 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP044 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP045 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP046 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays: "I found 1 passenger on this booking: Dominique Arsenault (Adult - Aeroplan Member). Is this who you'd like to inc | I found 1 passenger on this booking: Dominique Arsenault (Adult - Aeroplan Member). Is this who you'd like to include? |
| CP047 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP049 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Original Flight: AC 435 � CANCELLED (HDLG � ACS) Reprotected Flight: AC 445 (Renumbered) Route: Montreal (YUL) ? Toronto (YYZ) Da |
| CP050 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP051 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP052 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP053 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP054 | 72-HOUR CHECK | system | implied | Then the system calculates: Arrival May 10, 2026; current date June 15, 2026 ? >72 hours ? PROCEED |  |
| CP055 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP056 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 10, 2026; filing June 15, 2026 ? 36 days ? within 366 days ? PROCEED |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS identifies MSL = AC 435 YUL?YYZ (cancelled leg) |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS checks the cancellation code on MSL ? HDLG (ACS) ? used for controllability (no fallback needed) |  |
| CP060 | TRIAGE & DDS EVALUATION | verdict | api | And DDS classifies HDLG (ACS) as WITHIN CARRIER CONTROL ? CONTROLLABLE (ACS ground handling security check) |  |
| CP061 | TRIAGE & DDS EVALUATION | verdict | api | And DDS detects INVOL reprotection: AC 435 ? renumbered AC 445 YUL?YYZ |  |
| CP062 | TRIAGE & DDS EVALUATION | verdict | api | And DDS confirms AC 445 scheduled departure 08:00 = original scheduled departure 08:00 |  |
| CP063 | TRIAGE & DDS EVALUATION | verdict | api | And DDS calculates delay = 17:00 (actual arrival on AC 445) ? 10:00 (original promise on AC 435) = 7 hours ? band 6 to <9 hours ? Tier 2 |  |
| CP064 | TRIAGE & DDS EVALUATION | verdict | api | And DDS validates Aeroplan Basic Member status as linked and in good standing |  |
| CP065 | TRIAGE & DDS EVALUATION | verdict | api | And DDS sets eligibility = CAD 700 Cash / CAD 840 AC Wallet |  |
| CP066 | TRIAGE & DDS EVALUATION | verdict | api | And DDS returns ELIGIBLE (APPR Tier 2) and sends results to Trip Tracer UI |  |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 435, Route: YUL ? YYZ, Scheduled Departure: 08:00, Scheduled Arrival: 10:00 (CANCELLED) | Promised Itinerary - Flight: AC 435, Route: YUL ? YYZ, Scheduled Departure: 08:00, Scheduled Arrival: 10:00 (CANCELLED) |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 445 (Renumbered), Route: YUL ? YYZ, Status: ARRIVED, Scheduled Departure: 08:00 (SAME), Actual Arrival: 17:00 | Current Itinerary - Flight: AC 445 (Renumbered), Route: YUL ? YYZ, Status: ARRIVED, Scheduled Departure: 08:00 (SAME), Actual Arrival: 17:00 |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | History - Change 1: INVOL � AC 435 YUL?YYZ cancelled (HDLG � ACS). Customer reprotected onto renumbered flight AC 445 YUL?YYZ | History - Change 1: INVOL � AC 435 YUL?YYZ cancelled (HDLG � ACS). Customer reprotected onto renumbered flight AC 445 YUL?YYZ |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Departure Check: Scheduled departure matches original (08:00) | Departure Check: Scheduled departure matches original (08:00) |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | Delay Calculation: Original promised arrival = 10:00; Actual arrival on AC 445 = 17:00; Delay = 7 hrs ? DELAY_6_TO_LT_9_HOURS | Delay Calculation: Original promised arrival = 10:00; Actual arrival on AC 445 = 17:00; Delay = 7 hrs ? DELAY_6_TO_LT_9_HOURS |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: AC 435 � YUL ? YYZ � Cancellation Code: HDLG (ACS) � "Cancelled due to security check � ACS ground handling" | MSL FLIGHT: AC 435 � YUL ? YYZ � Cancellation Code: HDLG (ACS) � "Cancelled due to security check � ACS ground handling" |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | Rebooked Flight: AC 445 � YUL ? YYZ (Renumbered) | Rebooked Flight: AC 445 � YUL ? YYZ (Renumbered) |
| CP076 | TRIP TRACER UI VALIDATION | verdict | api | APPR causal category: Within carrier control ? CONTROLLABLE | APPR causal category: Within carrier control ? CONTROLLABLE |
| CP077 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +7H 00M � CONTROLLABLE (HDLG � ACS) | Delay: +7H 00M � CONTROLLABLE (HDLG � ACS) |
| CP078 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: 9876543210 (Basic Member � linked) | Aeroplan: 9876543210 (Basic Member � linked) |
| CP079 | TRIP TRACER UI VALIDATION | verdict | api | MS DOMINIQUE ARSENAULT / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet (+20%) / [expiry date] | MS DOMINIQUE ARSENAULT / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet (+20%) / [expiry date] |
| CP080 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP081 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN LIGHT (no fraud detected) |  |
| CP082 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And the customer is cleared to proceed to payment |  |
| CP083 | ELIGIBLE RESULT (FD-05a) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your original flight AC 435 from Montreal (YUL) to Toronto (YYZ) was cancelled because of a security check b |
| CP084 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: "Thank you for confirming. In which country will your reimbursement be deposited?" | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP085 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP086 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP087 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (9876543210, Basic Member) |  |
| CP088 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Aeroplan account in good standing? ? YES |  |
| CP089 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot offers BOTH options: | Since you are an Aeroplan member, you can choose to receive: Cash: CAD 700 will be sent via Interac e-Transfer and takes 5 to 10 business days to process. AC Wa |
| CP090 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And the user selects "Cash" | Cash |
| CP091 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the system determines: Cash selected ? Payment method = Interac e-Transfer (Canada) |  |
| CP092 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP093 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP094 | PAYMENT METHOD � INTERAC (FD-07) | system | implied | Then the chatbot does NOT ask for bank account, card, transit or institution numbers |  |
| CP095 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then the system checks that IDV is not completed |  |
| CP096 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: "I must verify your identity for payment security. Please click here to get started" | I must verify your identity for payment security. Please click here to get started |
| CP097 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And the chatbot displays a button "Get verified" | Get verified |
| CP098 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When the user clicks on the button |  |
| CP099 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then the system checks if IDV at Payment |  |
| CP100 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the system checks if the user has consented to IDV |  |
| CP101 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP102 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP103 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP104 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: "Your identity has been verified successfully. Let's proceed to finalize your claim." | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP105 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: CAD 700 Payment Method: Interac e-Transfer (d***@gmail.com) After submission, you will receive a confirmation email summarizing your eligibility |
| CP106 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP107 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP108 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP109 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP110 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP111 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP112 | NOTIFICATION | email | email | And an eligible notification email is sent to d***@gmail.com |  |
| CP113 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount (CAD 700 Cash � Interac e-Transfer), regulation (APPR), flight details (AC 435 ? |  |
| CP114 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No] | Is there anything I can help you with? |
| CP115 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP116 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Dominique Arsenault" with PNR "TC082" |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date should be populated |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Dominique Arsenault" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP128 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP129 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC082" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated |  |
| CP131 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP132 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Dominique Arsenault" |  |
| CP133 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP134 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "d***@gmail.com" |  |
| CP135 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***890" |  |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address and Profile ID should be populated |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "9876543210" linked and in good standing (Basic Member) |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be "Basic / Member" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" (original AC 435 cancelled; reprotected on renumbered AC 445) with claim filed for this fli |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Code should show "Cancellation Code HDLG (ACS) � security check � Controllable" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present with no expected ancillary fees |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should show "CAD 700 (Cash � Interac e-Transfer)" |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the AC Wallet option (CAD 840) should be visible as offered but NOT selected |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" under APPR Tier 2 (renumbered AC 445, same departure 08:00, arrival 17:00 |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Dominique Arsenault + TC082 + YUL?YYZ + FD" |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Persona IDV result should be "PASS" |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP166 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP167 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP168 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP169 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP170 | PAYMENT VALIDATION | payment | chat | And the customer has Aeroplan "9876543210" linked with Basic Member status in good standing |  |
| CP171 | PAYMENT VALIDATION | payment | chat | And both options should have been offered: Cash (CAD 700 Interac) AND AC Wallet (CAD 840 with 20% top-up) |  |
| CP172 | PAYMENT VALIDATION | payment | chat | And the customer selected "Cash" ? Payment method = Interac e-Transfer |  |
| CP173 | PAYMENT VALIDATION | payment | manual | And AC Wallet was offered but NOT selected ? AC Wallet payout NOT dispatched |  |
| CP174 | PAYMENT VALIDATION | payment | chat | And only the Interac email "d***@gmail.com" should be collected (no bank, card, transit or institution numbers) |  |
| CP175 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "CAD 700" for Tier 2 delay of 6 to less than 9 hours |  |
| CP176 | PAYMENT VALIDATION | payment | chat | And exactly one compensation record should be created in the backend with GL account and cost center |  |
| CP177 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team |  |
| CP178 | PAYMENT VALIDATION | payment | manual | And Cash should be dispatched to Unifier |  |
| CP179 | PAYMENT VALIDATION | payment | manual | And Unifier should send an acknowledgement back |  |
| CP180 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should be received from Interac |  |
| CP181 | PAYMENT VALIDATION | payment | manual | And the status should be "Pending" transitioning to "Cashed" or "Rejected" or "Expired" |  |
| CP182 | PAYMENT VALIDATION | payment | manual | And if the payment is unclaimed after 35 days the status should be set to "Expired" |  |
| CP183 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show "CAD 700" Cash via Interac |  |
| CP184 | PAYMENT VALIDATION | payment | manual | And the status should be updated via talkback |  |
| CP185 | EXPECTED RESULTS | verdict | api | Trip Tracer:  Promise: 10:00 at YYZ (AC 435, CANCELLED). | Trip Tracer:  Promise: 10:00 at YYZ (AC 435, CANCELLED). |
| CP186 | EXPECTED RESULTS | verdict | chat | Actual: 17:00 at YYZ (renumbered AC 445). | Actual: 17:00 at YYZ (renumbered AC 445). |
| CP187 | EXPECTED RESULTS | verdict | chat | Scheduled departure was 08:00, the same as the original. | Scheduled departure was 08:00, the same as the original. |
| CP188 | EXPECTED RESULTS | verdict | api | Delay: 7 hours (17:00 ? 10:00). | Delay: 7 hours (17:00 ? 10:00). |
| CP189 | EXPECTED RESULTS | verdict | api | Cause: MSL = AC 435. | Cause: MSL = AC 435. |
| CP190 | EXPECTED RESULTS | verdict | chat | Cancellation code HDLG (ACS), controllable. | Cancellation code HDLG (ACS), controllable. |
| CP191 | EXPECTED RESULTS | verdict | chat | Fallback = FALSE. | Fallback = FALSE. |
| CP192 | EXPECTED RESULTS | verdict | chat | APPR Tier 2. | APPR Tier 2. |
| CP193 | EXPECTED RESULTS | verdict | chat | The Basic Aeroplan member (9876543210) is offered both Cash (CAD 700) and AC Wallet (CAD 840). | The Basic Aeroplan member (9876543210) is offered both Cash (CAD 700) and AC Wallet (CAD 840). |
| CP194 | EXPECTED RESULTS | verdict | chat | The customer picks Cash, and CAD 700 is paid by Interac to d***@gmail.com. | The customer picks Cash, and CAD 700 is paid by Interac to d***@gmail.com. |
| CP195 | EXPECTED RESULTS | verdict | chat | CyberSource GREEN, Persona PASS. | CyberSource GREEN, Persona PASS. |
| CP196 | EXPECTED RESULTS | verdict | chat | Change history: INVOL, AC 435 cancelled (HDLG � ACS), customer moved to renumbered AC 445. | Change history: INVOL, AC 435 cancelled (HDLG � ACS), customer moved to renumbered AC 445. |
