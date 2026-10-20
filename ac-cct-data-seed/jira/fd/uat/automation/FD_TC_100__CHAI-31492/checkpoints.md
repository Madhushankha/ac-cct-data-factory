# FD_TC_100 · CHAI-31492 — checkpoints

**Goal:** Flight AC 865 LHR ? YUL flew but arrived 5 hours late (4+ hours band seen in ADS/AODB). The trip starts in the UK, so the UK regime (EU 261 UK branch) applies. APPR also applies because the flight lands in Canada. A disruption code is logged, but DDS doesn't recognize it, so it can't be classed as Controllable or Uncontrollable under either regime. The passenger has a Basic Aeroplan profile (9876543210) on the booking. This is different from the NULL/missing code case, which waits and re-checks for 14 days. Here a code exists but can't be mapped, so DDS returns NO DETERMINATION straight away. The chatbot shows the standard ND-X02 message, and the case is created automatically for manual review with a 30-day response commitment.
Validates: (1) DDS treats an UNKNOWN code differently from a NULL code for a UK departure, (2) No Determination comes back straight away with no 14-day re-check, (3) the chatbot shows the standard ND-X02 message, (4) the case is created and sent to manual review without asking the customer to confirm, (5) no Cash or AC Wallet offer is made even though Basic Aeroplan is linked, (6) the UK 6-year filing limit is used.

Methods: seed 14, chat 31, api 23, email 3, dashboard 52, implied 24, manual 7, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Flight AC 865 LHR ? YUL flew but arrived 5 hours late (4+ hours band seen in ADS/AODB). The trip starts in the UK, so the UK regime (EU 261  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC057 � single passenger V�ronique Caron (Adult - Basic Aeroplan Member 9876543210) | PNR: TC057 � single passenger V�ronique Caron (Adult - Basic Aeroplan Member 9876543210) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC international LHR ? YUL (Flight AC 865) | Journey: 1 leg AC international LHR ? YUL (Flight AC 865) |
| CP004 | PREREQUISITES | prerequisite | seed | Departure country: United Kingdom | Departure country: United Kingdom |
| CP005 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 14:00 | Scheduled arrival: 14:00 |
| CP006 | PREREQUISITES | prerequisite | seed | Actual arrival: 19:00 (5hr delay, 4+ hours band seen in ADS/AODB) | Actual arrival: 19:00 (5hr delay, 4+ hours band seen in ADS/AODB) |
| CP007 | PREREQUISITES | prerequisite | seed | Disruption code: UNKNOWN (logged but not mapped in the DDS controllability table for EU/UK or APPR) | Disruption code: UNKNOWN (logged but not mapped in the DDS controllability table for EU/UK or APPR) |
| CP008 | PREREQUISITES | prerequisite | seed | Flight status: Arrived (operated, 5hr late) | Flight status: Arrived (operated, 5hr late) |
| CP009 | PREREQUISITES | prerequisite | seed | Regimes: EU (UK) + APPR | Regimes: EU (UK) + APPR |
| CP010 | PREREQUISITES | prerequisite | seed | Timing: more than 72hrs elapsed | Timing: more than 72hrs elapsed |
| CP011 | PREREQUISITES | prerequisite | seed | Filing: within 2190 days (UK 6-year limit) | Filing: within 2190 days (UK 6-year limit) |
| CP012 | PREREQUISITES | prerequisite | seed | 14-day re-check: NOT triggered (code is present) | 14-day re-check: NOT triggered (code is present) |
| CP013 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked (9876543210), Basic Member in good standing | Aeroplan: Linked (9876543210), Basic Member in good standing |
| CP014 | PREREQUISITES | prerequisite | implied | CyberSource: NOT invoked | CyberSource: NOT invoked |
| CP015 | PREREQUISITES | prerequisite | seed | AC Wallet: NOT offered | AC Wallet: NOT offered |
| CP016 | PREREQUISITES | prerequisite | implied | RDS: No flags | RDS: No flags |
| CP017 | PREREQUISITES | prerequisite | seed | Country of residence: Canada | Country of residence: Canada |
| CP018 | GREETING & INTENT IDENTIFICATION | customer | chat | Given the user opens the agentic chatbot |  |
| CP019 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP020 | GREETING & INTENT IDENTIFICATION | customer | chat | Then user selects "English" | English |
| CP021 | GREETING & INTENT IDENTIFICATION | alert | chat | Then an alert information is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI t | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP022 | GREETING & INTENT IDENTIFICATION | bot | chat | Then chatbot asks: "How can I help you today?" | How can I help you today? |
| CP023 | GREETING & INTENT IDENTIFICATION | customer | chat | And the user says: "My flight from London to Montreal was delayed about 5 hours and I never got any clear explanation from Air Canada. I'd l | My flight from London to Montreal was delayed about 5 hours and I never got any clear explanation from Air Canada. I'd like to check if I'm eligible for compens |
| CP024 | GREETING & INTENT IDENTIFICATION | system | implied | When the chatbot identifies flight disruption intent |  |
| CP025 | GREETING & INTENT IDENTIFICATION | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP026 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP027 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. Please provide your f |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "V�ronique Caron" | V�ronique Caron |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, V�ronique! And, what is your booking reference number?" | Thanks, V�ronique! And, what is your booking reference number? |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC057" | PNR: TC057 |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC057 |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | * Email: v***@outlook.com * Phone: +1789 |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: v@outlook.com" | Email: v@outlook.com |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629481" | 629481 |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Let's proceed to the next step." | Your verification was successful. Let's proceed to the next step. |
| CP042 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP043 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP044 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP045 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP046 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: * V�ronique Caron (Adult - Aeroplan Member) Is this who you'd like to include? |
| CP047 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? 9 or fewer ? NOT a group booking ? PROCEED |  |
| CP049 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: * Flight: AC 865 * Route: London Heathrow (LHR) ? Montreal (YUL) * Date: May 18, 2026 * Status: ARRIVED LATE * Arrival Delay: 5 h |
| CP050 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP051 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP052 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP053 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP054 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP055 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival May 18, 2026; current date June 10, 2026 ? more than 72 hours ? PROCEED |  |
| CP056 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Departure country = United Kingdom ? filing deadline = 2190 days (6 years) |  |
| CP057 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 18, 2026; filing June 10, 2026 ? 23 days ? within 2190 days ? PROCEED |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP059 | TRIAGE & DDS EVALUATION | verdict | api | And DDS evaluates and sends to Trip Tracer UI |  |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 865, Route: LHR ? YUL, Scheduled Arrival: 14:00 | Promised Itinerary - Flight: AC 865, Route: LHR ? YUL, Scheduled Arrival: 14:00 |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 865, Route: LHR ? YUL, Status: ARRIVED LATE, Actual Arrival: 19:00, Delay: +5H 00M (4+ hours band seen in ADS | Current Itinerary - Flight: AC 865, Route: LHR ? YUL, Status: ARRIVED LATE, Actual Arrival: 19:00, Delay: +5H 00M (4+ hours band seen in ADS/AODB) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Regime: EU (UK) + APPR (2 regimes) | Regime: EU (UK) + APPR (2 regimes) |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | Disruption Code: UNKNOWN (logged but not mapped in the DDS controllability table) | Disruption Code: UNKNOWN (logged but not mapped in the DDS controllability table) |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | Departure Code: N/A | Departure Code: N/A |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | Cancellation Code: N/A (flight operated) | Cancellation Code: N/A (flight operated) |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: 9876543210 (Basic Member � linked) | Aeroplan: 9876543210 (Basic Member � linked) |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | DDS Gate: Is disruption code available? ? YES (code present) | DDS Gate: Is disruption code available? ? YES (code present) |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | DDS Gate: Is disruption code recognized / mapped? ? NO | DDS Gate: Is disruption code recognized / mapped? ? NO |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | EU/UK controllability (Controllable / Uncontrollable) ? cannot be decided | EU/UK controllability (Controllable / Uncontrollable) ? cannot be decided |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | APPR controllability ? cannot be decided | APPR controllability ? cannot be decided |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | DDS decides: No Determination � UNKNOWN CODE ? straight away (no 14-day re-check) | DDS decides: No Determination � UNKNOWN CODE ? straight away (no 14-day re-check) |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | 14-day re-check: NOT triggered (it only applies when the code is NULL/missing) | 14-day re-check: NOT triggered (it only applies when the code is NULL/missing) |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | MS V�RONIQUE CARON / NO DETERMINATION / UNKNOWN_CODE / GBP 0.00 (EU/UK) / CAD 0.00 (APPR) | MS V�RONIQUE CARON / NO DETERMINATION / UNKNOWN_CODE / GBP 0.00 (EU/UK) / CAD 0.00 (APPR) |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | NOTE: The 5h delay (4+ hours band) is visible. If the code is later found to be Controllable, the UK 4+ hours amount (GBP 520 Cash / GBP 624 | NOTE: The 5h delay (4+ hours band) is visible. If the code is later found to be Controllable, the UK 4+ hours amount (GBP 520 Cash / GBP 624 AC Wallet) would ap |
| CP075 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then CyberSource is called ONLY for ELIGIBLE cases |  |
| CP076 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NO DETERMINATION ? CyberSource NOT invoked |  |
| CP077 | AC WALLET CHECK � NOT TRIGGERED | system | implied | Then the AC Wallet offer appears ONLY for ELIGIBLE cases |  |
| CP078 | AC WALLET CHECK � NOT TRIGGERED | system | implied | And this case is NO DETERMINATION ? AC Wallet NOT offered, even with Basic Aeroplan linked (9876543210) |  |
| CP079 | NO DETERMINATION RESULT � UNKNOWN CODE | bot | chat | Then the chatbot displays the standard ND-X02 response: | Based on the information available, we are unable to determine your eligibility at this time. Flight disruptions can involve multiple factors, and the reason fo |
| CP080 | NO MANUAL HANDLING PROMPT | system | implied | Then the system goes straight to CASE CREATION without asking the customer for a preferred email or country |  |
| CP081 | NO MANUAL HANDLING PROMPT | system | implied | And no payment country, Interac email or other payment details are collected |  |
| CP082 | CASE CREATION (GLOB-09) | system | implied | Then the chatbot creates the case and responds: | "Your claim has been submitted. Case Reference: CASE-FD-20260610-054." "Our team will review your case and contact you within 30 days." |
| CP083 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP084 | CASE CREATION (GLOB-09) | system | implied | And the case is routed to the agent queue for manual investigation |  |
| CP085 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP086 | NOTIFICATION | email | email | And a case acknowledgement email is sent to v***@outlook.com |  |
| CP087 | NOTIFICATION | email | email | And the email contains: | Based on the information available, we are unable to determine your eligibility at this time. Flight disruptions can involve multiple factors, and the reason fo |
| CP088 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" | Is there anything I can help you with? |
| CP089 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP090 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP091 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Given the case has been created for claimant "V�ronique Caron" with PNR "TC057" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP094 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Case Status should be "Forwarded � Manual Review" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Created date should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the SLA countdown should be tracking correctly (30-day response commitment) |  |
| CP098 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the Team assignment should be "Customer Relations (Manual Review)" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP100 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Decision Assist panel may be restricted as it is pending manual review |  |
| CP101 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Claimant Name should be "V�ronique Caron" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the PNR should be "TC057" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP106 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Journey ID should be populated |  |
| CP107 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Booking Source should be populated |  |
| CP108 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP109 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Regime should be "EU (UK)" with APPR also listed as applicable |  |
| CP110 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Full Name should be "V�ronique Caron" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Email should be "v***@outlook.com" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Phone should be "+1***789" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Address should be populated |  |
| CP115 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Aeroplan should be "9876543210" linked (Basic Member in good standing) |  |
| CP116 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Tier Status should be "Basic / Member" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Journey should show "Bound 1: LHR ? YUL" with claim filed for this flight |  |
| CP118 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Disruption Code should show "UNKNOWN (not mapped)" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Ancillary Fee section should be present and empty |  |
| CP120 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Eligibility and Compensation section should show "NO DETERMINATION � Unknown disruption code � GBP 0 / CAD 0" |  |
| CP121 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no Cash or AC Wallet offer should be recorded |  |
| CP122 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP123 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the eligibility decision should be pre-populated as "NO DETERMINATION" (EU/UK and APPR, unknown code) |  |
| CP124 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no 14-day re-check job should exist for this case |  |
| CP125 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "V�ronique Caron + TC057 + LHR?YUL + FD" |  |
| CP126 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP127 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP128 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP129 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the CyberSource result should be "Not triggered" |  |
| CP130 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the IDV status should be "Not triggered" |  |
| CP131 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP132 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP133 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And a case acknowledgement email should have been sent via Adobe without any compensation amount |  |
| CP134 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP135 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP136 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And Customer Communications should show the acknowledgement email chronologically |  |
| CP137 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP138 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP139 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the agent should be able to record a manual decision after investigating the code |  |
| CP140 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Payment Validation Gherkin: |
| CP141 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Given the DDS outcome is "NO DETERMINATION" for claimant "V�ronique Caron" |  |
| CP142 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Then no payment country should be collected |  |
| CP143 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no Cash or AC Wallet option should be offered |  |
| CP144 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no Interac email, banking or card details should be collected |  |
| CP145 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no compensation record should be created |  |
| CP146 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no record should be picked up by the daily evening batch file |  |
| CP147 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And nothing should be dispatched to Unifier or EIP |  |
| CP148 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Claims Dashboard Compensation tab should show no payout (GBP 0 / CAD 0, no payment instruction) |  |
| CP149 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And if manual review later decides the claim is eligible, payment should follow the normal Canada resident path (Interac, email only) or AC  |  |
| CP150 | EXPECTED RESULTS | verdict | api | DDS returns No Determination (ND-X02, unknown code) for a UK departure. | DDS returns No Determination (ND-X02, unknown code) for a UK departure. |
| CP151 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 14:00; Actual = 19:00; Delay = 5hrs (4+ hours band); MSL = Leg 1 (AC 865 LHR ? YUL); Code UNKNOWN; Regimes = EU (UK)  | Trip Tracer: Promise = 14:00; Actual = 19:00; Delay = 5hrs (4+ hours band); MSL = Leg 1 (AC 865 LHR ? YUL); Code UNKNOWN; Regimes = EU (UK) + APPR. |
| CP152 | EXPECTED RESULTS | verdict | chat | No 14-day re-check. | No 14-day re-check. |
| CP153 | EXPECTED RESULTS | verdict | chat | Compensation GBP 0 / CAD 0 while waiting. | Compensation GBP 0 / CAD 0 while waiting. |
| CP154 | EXPECTED RESULTS | verdict | chat | No CyberSource, IDV, AC Wallet or payment. | No CyberSource, IDV, AC Wallet or payment. |
| CP155 | EXPECTED RESULTS | verdict | chat | Case created automatically ? Forwarded � Manual Review, 30-day SLA. | Case created automatically ? Forwarded � Manual Review, 30-day SLA. |
