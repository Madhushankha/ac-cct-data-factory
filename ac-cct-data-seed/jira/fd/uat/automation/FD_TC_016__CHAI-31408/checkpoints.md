# FD_TC_016 · CHAI-31408 — checkpoints

**Goal:** Validates an end-to-end flight disruption claim for a passenger traveling under a group booking (12 passengers on PNR) who files a self-only claim. The system detects the group booking identifier, restricts claim processing strictly to the authenticated claimant (Jean-Pierre Martin), and does not expose the other 11 passenger details for privacy. The single domestic leg (Flight AC 301, YUL?YYZ) is delayed 7 hours (6�<9h band) due to controllable documentation/dispatch/system issues (Code 31). APPR applies at Tier 2 compensation ($700 CAD Cash or $840 CAD AC Wallet with +20% bonus). The claimant's Basic Aeroplan profile is linked, both Cash and AC Wallet options are presented, and the customer selects Cash (Interac e-Transfer to Canada). Validates Persona IDV PASS, CyberSource GREEN, full automated case creation, and Claims Dashboard validation reflecting single-claimant group booking resolution.

Methods: seed 16, chat 35, api 17, email 1, dashboard 44, implied 11, manual 17, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates an end-to-end flight disruption claim for a passenger traveling under a group booking (12 passengers on PNR) who files a self-only |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC013 � 12 passengers (Group booking flag: TRUE in PNR / Trip Tracer) | PNR: TC013 � 12 passengers (Group booking flag: TRUE in PNR / Trip Tracer) |
| CP003 | PREREQUISITES | prerequisite | seed | Claimant: Jean-Pierre Martin (Adult - Basic Aeroplan Member 9871234567, 1 of 12) | Claimant: Jean-Pierre Martin (Adult - Basic Aeroplan Member 9871234567, 1 of 12) |
| CP004 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC domestic YUL?YYZ (Flight AC 301) | Journey: 1 leg AC domestic YUL?YYZ (Flight AC 301) |
| CP005 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 14:00 | Scheduled arrival: 14:00 |
| CP006 | PREREQUISITES | prerequisite | seed | Actual arrival: 21:00 (7hr delay � Delay band: 6 to <9 hours) | Actual arrival: 21:00 (7hr delay � Delay band: 6 to <9 hours) |
| CP007 | PREREQUISITES | prerequisite | seed | Arrival delay code: 31 (Documentation / Dispatch / System Issue � Controllable) | Arrival delay code: 31 (Documentation / Dispatch / System Issue � Controllable) |
| CP008 | PREREQUISITES | prerequisite | seed | Flight status: Arrived (operated) | Flight status: Arrived (operated) |
| CP009 | PREREQUISITES | prerequisite | seed | Booking changes: None � no VOL or INVOL | Booking changes: None � no VOL or INVOL |
| CP010 | PREREQUISITES | prerequisite | seed | Carrier: AC only | Carrier: AC only |
| CP011 | PREREQUISITES | prerequisite | seed | 72hrs: Elapsed (filed D+13) | 72hrs: Elapsed (filed D+13) |
| CP012 | PREREQUISITES | prerequisite | seed | Time limit: Within 366 days | Time limit: Within 366 days |
| CP013 | PREREQUISITES | prerequisite | seed | No duplicate case | No duplicate case |
| CP014 | PREREQUISITES | prerequisite | seed | Not employee, not infant | Not employee, not infant |
| CP015 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked (9871234567), Basic Member in good standing | Aeroplan: Linked (9871234567), Basic Member in good standing |
| CP016 | PREREQUISITES | prerequisite | implied | CyberSource: Configured to return GREEN | CyberSource: Configured to return GREEN |
| CP017 | PREREQUISITES | prerequisite | seed | Persona: Configured to return IDV PASS | Persona: Configured to return IDV PASS |
| CP018 | PREREQUISITES | prerequisite | seed | Country of residence: Canada (CAD) | Country of residence: Canada (CAD) |
| CP019 | GREETING & INTENT IDENTIFICATION | customer | chat | Given the user opens the agentic chatbot |  |
| CP020 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP021 | GREETING & INTENT IDENTIFICATION | customer | chat | Then user selects "English" | English |
| CP022 | GREETING & INTENT IDENTIFICATION | alert | chat | Then an alert information is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI t | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP023 | GREETING & INTENT IDENTIFICATION | bot | chat | Then chatbot asks: "How can I help you today?" | How can I help you today? |
| CP024 | GREETING & INTENT IDENTIFICATION | customer | chat | And the user says: "Our group flight was delayed 7 hours, there are 12 of us, we want compensation" | Our group flight was delayed 7 hours, there are 12 of us, we want compensation |
| CP025 | GREETING & INTENT IDENTIFICATION | system | implied | When the chatbot identifies flight disruption intent |  |
| CP026 | GREETING & INTENT IDENTIFICATION | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP027 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP028 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. Please provide your f |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Jean-Pierre Martin" | Jean-Pierre Martin |
| CP031 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, Jean-Pierre! And, what is your booking reference number?" | Thanks, Jean-Pierre! And, what is your booking reference number? |
| CP032 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "TC013" | TC013 |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC013 |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP035 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data is retrieved |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | * Email: j***@gmail.com * Phone: +1234 |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: j@gmail.com" | Email: j@gmail.com |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP040 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides OTP code "847291" | 847291 |
| CP041 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP042 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP043 | GROUP BOOKING CHECK & PRIVACY RESTRICTION | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP044 | GROUP BOOKING CHECK & PRIVACY RESTRICTION | system | implied | And group booking identifier = PRESENT (12 passengers on booking) |  |
| CP045 | GROUP BOOKING CHECK & PRIVACY RESTRICTION | bot | chat | Then the chatbot responds: "I can see this is a group booking with 12 passengers. For privacy and data protection, you will only be able to  | I can see this is a group booking with 12 passengers. For privacy and data protection, you will only be able to claim for yourself. Other travelers on this book |
| CP046 | GROUP BOOKING CHECK & PRIVACY RESTRICTION | customer | chat | And the user confirms "Understood" | Understood |
| CP047 | GROUP BOOKING CHECK & PRIVACY RESTRICTION | system | implied | Then passenger selection is skipped (restricted to Jean-Pierre Martin only) |  |
| CP048 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: * Flight: AC 301 * Route: Montreal (YUL) ? Toronto (YYZ) * Date: January 15, 2026 * Arrival Delay: 7 hours Is this the journey yo |
| CP049 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP050 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP051 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot sends request to Case Services for duplicate check ? NO existing case found for Jean-Pierre Martin on this journey |  |
| CP052 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks 72-hour rule: Arrival Jan 15, 2026; filing Jan 28, 2026 ? 312 hours (>72 hours) ? PROCEED |  |
| CP053 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks APPR filing deadline: 13 days elapsed (within 366 days) ? PROCEED |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | Backend DDS executes evaluation for PNR TC013 / Claimant Jean-Pierre Martin: | � Regime: APPR Applicable � Delay reason: Code 31 (Documentation / Dispatch / System Issue � Controllable) � Delay duration: 7 hours (Band: 6 to <9 hours ? Tier |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | [x] Promised Itinerary: Flight AC 301, YUL ? YYZ, Scheduled Arrival: 14:00 | [x] Promised Itinerary: Flight AC 301, YUL ? YYZ, Scheduled Arrival: 14:00 |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | [x] Current Itinerary: Flight AC 301, YUL ? YYZ, Status: ARRIVED LATE, Scheduled: 14:00 ? Actual: 21:00, Delay: +7H 00M | [x] Current Itinerary: Flight AC 301, YUL ? YYZ, Status: ARRIVED LATE, Scheduled: 14:00 ? Actual: 21:00, Delay: +7H 00M |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | [x] Regime: APPR (1 regime) | [x] Regime: APPR (1 regime) |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | [x] MSL Flight: AC 301 � YUL ? YYZ � Code 31 ("Delayed due to documentation / flight dispatch issues") | [x] MSL Flight: AC 301 � YUL ? YYZ � Code 31 ("Delayed due to documentation / flight dispatch issues") |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | [x] Delay Classification: +7H 00M � CONTROLLABLE | [x] Delay Classification: +7H 00M � CONTROLLABLE |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | [x] Aeroplan: 9871234567 (Basic Member � linked) | [x] Aeroplan: 9871234567 (Basic Member � linked) |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | [x] Group Booking Indicator: TRUE (12 Pax total, restricted to self-claim) | [x] Group Booking Indicator: TRUE (12 Pax total, restricted to self-claim) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | MR JEAN-PIERRE MARTIN / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet (+20%) / [expiry date] | MR JEAN-PIERRE MARTIN / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet (+20%) / [expiry date] |
| CP063 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Chatbot sends case details to CyberSource ? Returns GREEN LIGHT (Pass) |  |
| CP064 | ELIGIBLE RESULT DISPLAY (FD-05a) | bot | chat | Chatbot displays: "I've checked your flight details, and flight AC 301 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7 hours due | I've checked your flight details, and flight AC 301 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7 hours due to documentation and scheduling delays |
| CP065 | CLAIM PAYMENT & AEROPLAN OFFER | bot | chat | Chatbot asks: "In which country will your reimbursement be deposited?" | In which country will your reimbursement be deposited? |
| CP066 | IDENTITY VERIFICATION | bot | chat | Chatbot displays "Get verified" button ? User completes Persona IDV ? Persona returns IDV PASS | Get verified |
| CP067 | CLAIM CONFIRMATION & CASE CREATION (GLOB-09) | bot | chat | Chatbot displays summary: | Please review your compensation details: Deposit Amount: $700 CAD Payment Method: Interac e-Transfer (j***@gmail.com) After submission, you will receive a confi |
| CP068 | NOTIFICATION & WRAP-UP (GLOB-11) | email | email | Adobe triggers notification email to j***@gmail.com containing: Case Reference, compensation amount ($700 CAD Cash � Interac e-Transfer), re | Claims Dashboard Gherkin: |
| CP069 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Given the case has been created for claimant "Jean-Pierre Martin" with PNR "TC013" |  |
| CP070 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" mapped from chatbot intent |  |
| CP071 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP072 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Created date should be populated |  |
| CP074 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP075 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP076 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the Team assignment should be correct |  |
| CP077 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP078 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP079 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Claimant Name should be "Jean-Pierre Martin" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the PNR should be "TC013" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Journey ID should be populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Booking Source should be populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Full Name should be "Jean-Pierre Martin" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Tags should include "Claimant", "Adult", and "Group Booking" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Email should be "j***@gmail.com" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Phone should be "+1234" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Address should be populated |  |
| CP093 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Aeroplan should be "9871234567" linked and in good standing (Basic Member) |  |
| CP094 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Tier Status should be "Basic / Member" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight |  |
| CP096 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Ancillary Fee section should be present and empty |  |
| CP097 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Eligibility and Compensation section should show "$700 CAD (Cash � Interac e-Transfer)" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the AC Wallet option ($840 CAD) should be visible as the offered alternative but NOT selected |  |
| CP099 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP100 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP101 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" (APPR, Code 31 Controllable, 7h delay, Tier 2) |  |
| CP102 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Jean-Pierre Martin + TC013 + YUL?YYZ + FD" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP105 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP106 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP108 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the system should have appended the booking record to the case automatically |  |
| CP109 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP110 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the agent should have used pull case function from My Activities to get this case |  |
| CP111 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And a case acknowledgement notification should have been sent to the customer |  |
| CP113 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And an eligible notification email should have been sent via Adobe containing $700 CAD Cash and Interac e-Transfer payment method |  |
| CP114 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP115 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the Audit Log should record all actions with timestamps |  |
| CP116 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And Customer Communications should show the notification email |  |
| CP117 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the chatbot transcript should be accessible and linked |  |
| CP118 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP119 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP121 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Payment Validation Gherkin: |
| CP122 | PAYMENT VALIDATION (GLOB-11) | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP123 | PAYMENT VALIDATION (GLOB-11) | payment | chat | Then the currency should be set to "CAD" |  |
| CP124 | PAYMENT VALIDATION (GLOB-11) | payment | chat | And the customer has Aeroplan "9871234567" linked with Basic Member status in good standing |  |
| CP125 | PAYMENT VALIDATION (GLOB-11) | payment | chat | And both options should have been offered: Cash ($700 CAD Interac) AND AC Wallet ($840 CAD with 20% top-up) |  |
| CP126 | PAYMENT VALIDATION (GLOB-11) | payment | chat | And the customer selected "Cash" ? Payment method = Interac e-Transfer |  |
| CP127 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And AC Wallet was offered but NOT selected � AC Wallet payout NOT dispatched |  |
| CP128 | PAYMENT VALIDATION (GLOB-11) | payment | chat | And the Interac email should be collected from the customer (j@gmail.com) |  |
| CP129 | PAYMENT VALIDATION (GLOB-11) | payment | chat | And a compensation record should be created with $700 CAD |  |
| CP130 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And the record should be picked up by the daily evening batch file |  |
| CP131 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And the record should be dispatched to Unifier |  |
| CP132 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And Unifier should send an acknowledgement back |  |
| CP133 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And the end-of-day report should be received from Interac |  |
| CP134 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired" |  |
| CP135 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And if the customer does not claim the Interac payment within 35 days the status should be set to "Expired" |  |
| CP136 | PAYMENT VALIDATION (GLOB-11) | payment | manual | And the Claims Dashboard Compensation tab should show payout details: amount ($700 CAD), payment method (Cash � Interac e-Transfer), status  |  |
| CP137 | EXPECTED RESULTS | verdict | api | DDS generates FD-APPR-EL-01 for single claimant under group booking. | DDS generates FD-APPR-EL-01 for single claimant under group booking. |
| CP138 | EXPECTED RESULTS | verdict | api | Delay: 7 hours (Tier 2: 6�<9h). | Delay: 7 hours (Tier 2: 6�<9h). |
| CP139 | EXPECTED RESULTS | verdict | api | Code: 31 (Documentation / Dispatch � Controllable). | Code: 31 (Documentation / Dispatch � Controllable). |
| CP140 | EXPECTED RESULTS | verdict | api | Regime: APPR. | Regime: APPR. |
| CP141 | EXPECTED RESULTS | verdict | chat | Total Payout: $700 CAD Cash via Interac e-Transfer to j***@gmail.com. | Total Payout: $700 CAD Cash via Interac e-Transfer to j***@gmail.com. |
| CP142 | EXPECTED RESULTS | verdict | chat | Other 11 group passengers remain unexposed and unfiled. | Other 11 group passengers remain unexposed and unfiled. |
