# FD_TC_099 · CHAI-31491 — checkpoints

**Goal:** Flight AC 372 YUL?YYZ operated but arrived 7 hours late (6�<9h band observed in ADS/AODB). A disruption code IS logged in the system, but the code is UNKNOWN � it is not recognized or mapped in DDS and cannot be classified as Controllable or Uncontrollable. Passenger holds a Basic Aeroplan profile (9876543210) linked to the booking. Unlike FD-APPR-ND-04 (where ALL codes are NULL/missing and polling occurs), in this scenario a code exists but its type is unclassifiable � DDS immediately returns NO DETERMINATION (FD-APPR-ND-X02) without a 14-day polling window. Chatbot displays the standardized ND-X02 response and case is created automatically for manual review with a 30-day response commitment. Validates: (1) DDS correctly handles an UNKNOWN disruption code distinct from a NULL/missing code, (2) FD-APPR-ND-X02 is returned immediately (no 14-day polling), (3) Chatbot displays the standardized ND-X02 response message, (4) Case is created and routed to manual review without asking customer for confirmation, (5) AC Wallet is NOT offered despite Basic Aeroplan linkage � No Determination cases do not trigger payment flows.

Methods: chat 41, api 23, email 3, dashboard 44, implied 21, manual 11, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Flight AC 372 YUL?YYZ operated but arrived 7 hours late (6�<9h band observed in ADS/AODB). A disruption code IS logged in the system, but th |  |
| CP002 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP003 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP004 | START | customer | chat | Then user selects English |  |
| CP005 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP006 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP007 | START | customer | chat | And the user says "My flight from Montreal to Toronto was delayed about 7 hours and I never got any clear explanation from Air Canada. I'd l | My flight from Montreal to Toronto was delayed about 7 hours and I never got any clear explanation from Air Canada. I'd like to check if I'm eligible for compen |
| CP008 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP009 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP010 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP011 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP012 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP013 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP014 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "V�ronique Caron" | V�ronique Caron |
| CP015 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, V�ronique! And, what is your booking reference number? |
| CP016 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC057" | PNR: TC057 |
| CP017 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC057 |  |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP020 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: v***@outlook.com � Phone: +1***789 |
| CP022 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: v***@outlook.com" | Email: v***@outlook.com |
| CP023 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP024 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629481" | 629481 |
| CP025 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP026 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP027 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP028 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP029 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP030 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP031 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � V�ronique Caron (Adult - Aeroplan Member) Is this who you'd like to include? |
| CP032 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP033 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP034 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 372 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: May 18, 2026 � Status: ARRIVED LATE � Arrival Delay: 7 hours (ob |
| CP035 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP036 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP037 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP038 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP039 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP040 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was May 18, 2026; current date is June 10, 2026 ? >72 hours ? PROCEED |  |
| CP041 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption |  |
| CP042 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: Disruption May 18, 2026; filing June 10, 2026 ? 23 days ? within 366 days ? PROCEED |  |
| CP043 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP044 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP045 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 372, Route: YUL ? YYZ, Scheduled Arrival: 14:00 | Promised Itinerary - Flight: AC 372, Route: YUL ? YYZ, Scheduled Arrival: 14:00 |
| CP046 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 372, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual Arrival: 21:00, Delay: +7H 00M (6�<9h band observed in AD | Current Itinerary - Flight: AC 372, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual Arrival: 21:00, Delay: +7H 00M (6�<9h band observed in ADS/AODB) |
| CP047 | TRIP TRACER UI VALIDATION | verdict | api | Disruption Code: UNKNOWN (code IS logged in system but is not recognized / not mapped in DDS classification table) | Disruption Code: UNKNOWN (code IS logged in system but is not recognized / not mapped in DDS classification table) |
| CP048 | TRIP TRACER UI VALIDATION | verdict | api | Departure Code: N/A | Departure Code: N/A |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Cancellation Code: N/A (flight operated � not cancelled) | Cancellation Code: N/A (flight operated � not cancelled) |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: 9876543210 (Basic Member � linked) | Aeroplan: 9876543210 (Basic Member � linked) |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | DDS Gate 6: Is disruption code available? | DDS Gate 6: Is disruption code available? |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | Code IS present ? YES | Code IS present ? YES |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | DDS Gate 6a: Is disruption code RECOGNIZED / MAPPED? | DDS Gate 6a: Is disruption code RECOGNIZED / MAPPED? |
| CP054 | TRIP TRACER UI VALIDATION | verdict | api | Code type = UNKNOWN ? NOT recognized in DDS classification table | Code type = UNKNOWN ? NOT recognized in DDS classification table |
| CP055 | TRIP TRACER UI VALIDATION | verdict | api | Cannot determine Controllable / Uncontrollable ? NO DETERMINATION | Cannot determine Controllable / Uncontrollable ? NO DETERMINATION |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | DDS determines: FD-APPR-ND-X02 � UNKNOWN CODE ? immediate No Determination (no 14-day polling � code exists) | DDS determines: FD-APPR-ND-X02 � UNKNOWN CODE ? immediate No Determination (no 14-day polling � code exists) |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | 14-day polling: NOT triggered (polling only applies when code is NULL/missing � code IS present here, just unknown) | 14-day polling: NOT triggered (polling only applies when code is NULL/missing � code IS present here, just unknown) |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | MS V�RONIQUE CARON / NO DETERMINATION / UNKNOWN_CODE / CAD 0.00 | MS V�RONIQUE CARON / NO DETERMINATION / UNKNOWN_CODE / CAD 0.00 |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | NOTE: 7h delay (6�<9h band) IS observed � if code is later reclassified as Controllable, APPR Tier 2 ($700 CAD Cash / $840 AC Wallet) would  | NOTE: 7h delay (6�<9h band) IS observed � if code is later reclassified as Controllable, APPR Tier 2 ($700 CAD Cash / $840 AC Wallet) would apply. Currently blo |
| CP060 | FRAUD SCREENING � NOT TRIGGERED | system | implied | Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases |  |
| CP061 | FRAUD SCREENING � NOT TRIGGERED | system | implied | And this case is NO DETERMINATION ? CyberSource NOT invoked |  |
| CP062 | AC WALLET CHECK � NOT TRIGGERED | system | implied | Then the chatbot notes: AC Wallet offer is ONLY triggered for ELIGIBLE cases |  |
| CP063 | AC WALLET CHECK � NOT TRIGGERED | system | implied | And this case is NO DETERMINATION ? AC Wallet NOT offered despite Basic Aeroplan linkage (9876543210) |  |
| CP064 | NO DETERMINATION RESULT � UNKNOWN CODE | bot | chat | Then the chatbot displays the standardized FD-APPR-ND-X02 response: | Based on the information available, we are unable to determine your eligibility at this time. Flight disruptions can involve multiple factors, and the reason fo |
| CP065 | NO DETERMINATION RESULT � UNKNOWN CODE | system | implied | Then the system proceeds immediately to CASE CREATION without collecting preferred email or country from the customer | NOTE: This is distinct from FD-APPR-ND-04 which includes manual handling flow (GenUC-27). FD-APPR-ND-X02 creates the case automatically after the ND message. |
| CP066 | CASE CREATION (GLOB-09) | system | implied | Then the chatbot creates the case and responds: | "Your claim has been submitted. Case Reference: CASE-FD-20260610-054." "Our team will review your case and contact you within 30 days." |
| CP067 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP068 | CASE CREATION (GLOB-09) | system | implied | And the case is routed to the agent queue for manual investigation |  |
| CP069 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP070 | NOTIFICATION | email | email | And a case acknowledgement email is sent to v***@outlook.com |  |
| CP071 | NOTIFICATION | email | email | And the email contains: | Based on the information available, we are unable to determine your eligibility at this time. Flight disruptions can involve multiple factors, and the reason fo |
| CP072 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP073 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP074 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "V�ronique Caron" with PNR "TC057" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Forwarded � Manual Review" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date should be populated |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking against the 30-day response commitment |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be "Customer Relations (Manual Review)" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "V�ronique Caron" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC057" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "V�ronique Caron" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "v***@outlook.com" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***789" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address and Profile ID should be populated |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "9876543210" linked and in good standing (Basic Member) |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be "Basic / Member" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" (AC 372, 14:00 ? 21:00, +7H 00M) with claim filed for this flight |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Code should show "UNKNOWN � not mapped in DDS" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present with no expected ancillary fees |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should show "NO DETERMINATION � Unknown disruption code � CAD 0" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no CAD 700 Cash or CAD 840 AC Wallet amount should be shown or stored |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS outcome should be "FD-APPR-ND-X02" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should show the observed delay (7h, 6 to <9h band) for agent reference |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should allow the agent to record a manual eligibility decision |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should NOT show a 14-day polling status or System Processing Queue entry |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "V�ronique Caron + TC057 + YUL?YYZ + FD" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "Not triggered" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Persona IDV status should be "Not triggered" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be available in the manual review queue for an agent to pull from My Activities |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement email should have been sent via Adobe to "v***@outlook.com" |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the acknowledgement email should not contain any compensation amount |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record DDS returning FD-APPR-ND-X02, automatic case creation and routing to manual review, with timestamps |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the acknowledgement email chronologically |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should show no confirmation prompt and no email or country collection after the ND-X02 message |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP125 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should remain open (NOT Resolved and NOT read-only) pending the agent's manual decision |  |
| CP126 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP127 | PAYMENT VALIDATION | payment | chat | Given the DDS outcome is "FD-APPR-ND-X02" (No Determination � Unknown Code) |  |
| CP128 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And no Cash offer should have been displayed |  |
| CP131 | PAYMENT VALIDATION | payment | chat | And no AC Wallet offer should have been displayed despite Basic Aeroplan "9876543210" being linked |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And no Interac email, banking or card details should have been collected |  |
| CP133 | PAYMENT VALIDATION | payment | chat | And Persona IDV should NOT have been triggered |  |
| CP134 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP135 | PAYMENT VALIDATION | payment | chat | And no CAD 700 or CAD 840 amount should have been calculated or stored |  |
| CP136 | PAYMENT VALIDATION | payment | manual | And no record should be picked up by the daily evening batch file |  |
| CP137 | PAYMENT VALIDATION | payment | manual | And nothing should be dispatched to Unifier or EIP |  |
| CP138 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show no payout and no payment instruction |  |
| CP139 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-ND-X02 straight away. | DDS returns FD-APPR-ND-X02 straight away. |
| CP140 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 14:00, Actual = 21:00, Delay = 7 hours (6 to under 9 hour band), MSL = Leg 1 (AC 372), no cancellation code, disrupti | Trip Tracer: Promise = 14:00, Actual = 21:00, Delay = 7 hours (6 to under 9 hour band), MSL = Leg 1 (AC 372), no cancellation code, disruption code UNKNOWN (pre |
| CP141 | EXPECTED RESULTS | verdict | chat | Compensation: CAD 0. | Compensation: CAD 0. |
| CP142 | EXPECTED RESULTS | verdict | chat | The chatbot shows the standard ND-X02 message, asks for no confirmation, and creates the case for manual review with a 30-day commitment. | The chatbot shows the standard ND-X02 message, asks for no confirmation, and creates the case for manual review with a 30-day commitment. |
| CP143 | EXPECTED RESULTS | verdict | chat | CyberSource, Persona, Cash, AC Wallet and payment are all not triggered. | CyberSource, Persona, Cash, AC Wallet and payment are all not triggered. |
| CP144 | EXPECTED RESULTS | verdict | dashboard | Claims Dashboard: Forwarded � Manual Review, ND-X02, the case stays open for the agent's decision. | Claims Dashboard: Forwarded � Manual Review, ND-X02, the case stays open for the agent's decision. |
