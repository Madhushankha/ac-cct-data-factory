# FD_TC_179 · CHAI-31571 — checkpoints

**Goal:** Customer files a second claim for the exact same multi-leg journey with a Canadian arrival destination (Chicago ORD ? Denver DEN ? Toronto YYZ) for which compensation was already issued on a prior claim. The disrupted segment is Leg 2 (Denver DEN ? Toronto YYZ), which experienced a 7-hour arrival delay (6�<9h band) caused by Code 15 (Boarding Process Delay � Controllable) and paid out $700 CAD Cash / $840 CAD AC Wallet. System detects the duplicate during GenUC-10 based on exact match of PNR + Passenger Name + Journey/Flight Numbers + Flight Date. Validates that: (1) System blocks the second claim attempt automatically, (2) References the original case ID (CASE-FD-20260501-153) and prior payout details, (3) Basic Aeroplan profile is recognized on the PNR, (4) No new DDS evaluation, IDV, CyberSource, or payment dispatch is triggered, (5) Second claim is logged as Closed � Not Eligible (Duplicate).

Methods: chat 41, api 7, dashboard 28, implied 9, manual 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer files a second claim for the exact same multi-leg journey with a Canadian arrival destination (Chicago ORD ? Denver DEN ? Toronto Y |  |
| CP002 | BACKGROUND � ORIGINAL CASE | system | implied | Given a case was previously created and completed: | ? Original Case Reference: CASE-FD-20260501-153 ? Passenger: Catherine Bouchard (Basic Aeroplan Member #: 9876543210) ? PNR: TC153 ? Journey: ORD ? DEN ? YYZ (L |
| CP003 | SECOND CLAIM ATTEMPT | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | SECOND CLAIM ATTEMPT | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | SECOND CLAIM ATTEMPT | customer | chat | Then user selects English |  |
| CP006 | SECOND CLAIM ATTEMPT | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | SECOND CLAIM ATTEMPT | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | SECOND CLAIM ATTEMPT | customer | chat | And the user says "My flight from Denver to Toronto on May 1st was delayed 7 hours due to boarding delays. I'd like to file a compensation c | My flight from Denver to Toronto on May 1st was delayed 7 hours due to boarding delays. I'd like to file a compensation claim. |
| CP009 | SECOND CLAIM ATTEMPT | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | SECOND CLAIM ATTEMPT | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP011 | SECOND CLAIM ATTEMPT | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP012 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP013 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP014 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP015 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Catherine Bouchard" | Catherine Bouchard |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Catherine! And, what is your booking reference number? |
| CP017 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC153" | PNR: TC153 |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC153 |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP022 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: c***@gmail.com � Phone: +1***234 |
| CP023 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: c***@gmail.com" | Email: c***@gmail.com |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP025 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP026 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP028 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP029 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP030 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Catherine Bouchard (Adult - Aeroplan Member) Is this who you'd like to include? |
| CP031 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP032 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Segment 1: Flight AC 8452, Chicago (ORD) ? Denver (DEN) � COMPLETED � Segment 2: Flight AC 8204, Denver (DEN) ? Toronto (YYZ) � |
| CP033 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP034 | DUPLICATE CLAIM CHECK � DUPLICATE DETECTED (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP035 | DUPLICATE CLAIM CHECK � DUPLICATE DETECTED (GenUC-10) | system | implied | And Case Services checks: | ? PNR: TC153 ? MATCH ? Passenger: Catherine Bouchard ? MATCH ? Journey: ORD ? DEN ? YYZ (AC 8452 / AC 8204) ? MATCH ? Flight Date: May 1, 2026 ? MATCH ? Existin |
| CP036 | DUPLICATE CLAIM CHECK � DUPLICATE DETECTED (GenUC-10) | system | implied | And Case Services returns: DUPLICATE DETECTED | ? Duplicate Match Type: EXACT (PNR + Passenger + Multi-leg Journey + Date all match) ? Original Case: CASE-FD-20260501-153 ? Original Decision: ELIGIBLE � $840  |
| CP037 | DUPLICATE CLAIM � BLOCKED | bot | chat | Then the chatbot responds: | I can see that a claim has already been filed and processed for this journey. Here are the details of your existing claim: � Case Reference: CASE-FD-20260501-15 |
| CP038 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP039 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP040 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP041 | DUPLICATE DETECTION VALIDATION | system | implied | ? PNR match: YES (TC153) ? | ? Passenger match: YES (Catherine Bouchard) ? ? Multi-leg journey match: YES (ORD?DEN?YYZ) ? ? Date match: YES (May 1, 2026) ? ? Duplicate detected: YES ? ? Ori |
| CP042 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the second claim attempt was made for claimant "Catherine Bouchard" with PNR "TC153" |  |
| CP043 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP044 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible (Duplicate)" |  |
| CP045 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP046 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP047 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a Duplicate Warning Banner should be displayed on top of the case |  |
| CP048 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should be blocked with no new DDS assessment |  |
| CP049 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Catherine Bouchard" |  |
| CP050 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP051 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP052 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC153" |  |
| CP053 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "9876543210" linked and in good standing (Basic Member) |  |
| CP054 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be "Basic / Member" |  |
| CP055 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" (same as original) |  |
| CP056 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: ORD ? DEN ? YYZ" (multi-leg connecting with disrupted segment arriving in Canada) |  |
| CP057 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP058 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should show "NOT ELIGIBLE (DUPLICATE)" with compensation $0 CAD as already paid on original cas |  |
| CP059 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DUPLICATE check MUST have triggered during GenUC-10 |  |
| CP060 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the match criteria should show PNR match, Passenger match, Multi-leg journey match, and Flight date match |  |
| CP061 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Original Case ID should be referenced (CASE-FD-20260501-153) |  |
| CP062 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the original payment details ($840 CAD AC Wallet / $700 CAD Cash) should be linked |  |
| CP063 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system MUST NOT process the second claim or create a new compensation record |  |
| CP064 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered |  |
| CP065 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a duplicate notification email should have been sent via Adobe containing Case Reference, duplicate detected status, original case ID, a |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record duplicate detection and original case reference |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the duplicate notification |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should link directly to the original case (CASE-FD-20260501-153) |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible (Duplicate)" |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP073 | PAYMENT VALIDATION | payment | chat | Given the claim is a DUPLICATE |  |
| CP074 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP075 | PAYMENT VALIDATION | payment | chat | And no country of residence or payment method choice should be asked |  |
| CP076 | PAYMENT VALIDATION | payment | chat | And no new compensation record should be created |  |
| CP077 | PAYMENT VALIDATION | payment | manual | And no batch file should be dispatched |  |
| CP078 | PAYMENT VALIDATION | payment | chat | And no IDV should be triggered |  |
| CP079 | PAYMENT VALIDATION | payment | chat | And no CyberSource fraud screening should be triggered |  |
| CP080 | PAYMENT VALIDATION | payment | chat | And the original case should be referenced as CASE-FD-20260501-153 with $840 CAD AC Wallet already ISSUED on May 12, 2026 |  |
| CP081 | PAYMENT VALIDATION | payment | chat | And the second claim should be BLOCKED and the system must NOT process any payment for the duplicate |  |
| CP082 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE (Duplicate)" with no new payout section |  |
| CP083 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Related Cases tab should link to the original case showing original payment ($840 CAD AC Wallet ISSUED) |  |
| CP084 | EXPECTED RESULTS | verdict | api | DDS returns FD-DUP-NE-01. | DDS returns FD-DUP-NE-01. |
| CP085 | EXPECTED RESULTS | verdict | chat | Duplicate Detection: System matches second claim against existing database ? DUPLICATE FOUND. | Duplicate Detection: System matches second claim against existing database ? DUPLICATE FOUND. |
| CP086 | EXPECTED RESULTS | verdict | chat | Original case CASE-FD-20260501-153 retrieved. | Original case CASE-FD-20260501-153 retrieved. |
| CP087 | EXPECTED RESULTS | verdict | api | CRITICAL: System MUST NOT process the second claim � compensation was already paid ($840 CAD AC Wallet / $700 CAD Cash for 7h delay under Co | CRITICAL: System MUST NOT process the second claim � compensation was already paid ($840 CAD AC Wallet / $700 CAD Cash for 7h delay under Code 15 Boarding on Le |
| CP088 | EXPECTED RESULTS | verdict | chat | Must reference the original case ID so customer and agent see prior payout. | Must reference the original case ID so customer and agent see prior payout. |
| CP089 | EXPECTED RESULTS | verdict | chat | Compensation: $0 � already paid on original claim. | Compensation: $0 � already paid on original claim. |
| CP090 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Closed � Not Eligible; Reason = Duplicate claim detected; Original case ID = CASE-FD-20260501-153; Original payment = $840 | Claims Dashboard: Closed � Not Eligible; Reason = Duplicate claim detected; Original case ID = CASE-FD-20260501-153; Original payment = $840 AC Wallet; Second c |
