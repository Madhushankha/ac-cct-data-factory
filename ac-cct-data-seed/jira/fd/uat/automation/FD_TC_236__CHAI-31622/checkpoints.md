# FD_TC_236 · CHAI-31622 — checkpoints

**Goal:** Checks what DDS does when it can't identify the operating carrier of the leg that caused the delay. Leg 1, AC 412 YUL ? YYZ, is on time. Leg 2, AC 7650 YYZ ? YQB (sold by AC, codeshare), arrives 7 hours late, and DDS picks it as the MSL. Trip Tracer shows no operating carrier code for that leg, so it can't be matched to AC or an AC family carrier, a STAR carrier or OAL. DDS can't apply the carrier rules or decide controllability, so it returns NO DETERMINATION for the passenger with amount 0. It does not return Eligible or Not Eligible. The chatbot shows the standard No Determination message, the case is created automatically and sent to manual review with a 30-day response commitment. No CyberSource check, AC Wallet or Cash offer, IDV or payment takes place, even though Basic Aeroplan is linked.

Methods: seed 11, chat 17, api 10, email 2, dashboard 35, implied 13, manual 6, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Checks what DDS does when it can't identify the operating carrier of the leg that caused the delay. Leg 1, AC 412 YUL ? YYZ, is on time. Leg |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: UC002 � single passenger Gabriel Morin (Adult, Basic Aeroplan 9876543210, good standing) | PNR: UC002 � single passenger Gabriel Morin (Adult, Basic Aeroplan 9876543210, good standing) |
| CP003 | PREREQUISITES | prerequisite | seed | Leg 1: AC 412 YUL ? YYZ, Jul 20, 2026, operated by AC, on time (arrives 10:00) | Leg 1: AC 412 YUL ? YYZ, Jul 20, 2026, operated by AC, on time (arrives 10:00) |
| CP004 | PREREQUISITES | prerequisite | seed | Leg 2: AC 7650 YYZ ? YQB, sold by AC, scheduled arrival 14:00, actual 21:00 (7h late) | Leg 2: AC 7650 YYZ ? YQB, sold by AC, scheduled arrival 14:00, actual 21:00 (7h late) |
| CP005 | PREREQUISITES | prerequisite | seed | Leg 2 operating carrier code: missing (null) in Trip Tracer | Leg 2 operating carrier code: missing (null) in Trip Tracer |
| CP006 | PREREQUISITES | prerequisite | seed | Leg 2 arrival delay code: logged but can't be linked to a known carrier | Leg 2 arrival delay code: logged but can't be linked to a known carrier |
| CP007 | PREREQUISITES | prerequisite | seed | Booking changes: none | Booking changes: none |
| CP008 | PREREQUISITES | prerequisite | seed | MSL = Leg 2 | MSL = Leg 2 |
| CP009 | PREREQUISITES | prerequisite | seed | Claim filed Jul 28, 2026 (more than 72h, within 366 days) | Claim filed Jul 28, 2026 (more than 72h, within 366 days) |
| CP010 | PREREQUISITES | prerequisite | seed | No duplicate case | No duplicate case |
| CP011 | PREREQUISITES | prerequisite | seed | Not employee, not infant | Not employee, not infant |
| CP012 | PREREQUISITES | prerequisite | seed | Country of residence: Canada | Country of residence: Canada |
| CP013 | GREETING & INTENT IDENTIFICATION | customer | chat | Given the user opens the agentic chatbot |  |
| CP014 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot displays greeting (GLOB-01): "Hello! I will be your virtual assistant today. I can assist you in English or French. Which l | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP015 | GREETING & INTENT IDENTIFICATION | customer | chat | Then user selects "English" | English |
| CP016 | GREETING & INTENT IDENTIFICATION | alert | chat | Then the privacy alert is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI to a | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP017 | GREETING & INTENT IDENTIFICATION | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP018 | GREETING & INTENT IDENTIFICATION | customer | chat | And the user says "My connecting flight from Toronto to Quebec City was delayed about 7 hours. I'd like to check if I'm eligible for compens | My connecting flight from Toronto to Quebec City was delayed about 7 hours. I'd like to check if I'm eligible for compensation |
| CP019 | GREETING & INTENT IDENTIFICATION | system | implied | When the chatbot identifies flight disruption intent |  |
| CP020 | GREETING & INTENT IDENTIFICATION | system | implied | Then third-party check ? NO |  |
| CP021 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP022 | LEGAL DISCLAIMER | bot | chat | Then the chatbot shows the automated decision-making disclaimer ? user agrees to start |  |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | User provides "Gabriel Morin" and PNR "UC002" ? Trip Tracer PNR FOUND (Auth Flow 1) | Gabriel Morin UC002 |
| CP024 | AUTHENTICATION (GenUC-05) | customer | chat | User selects Email g***@gmail.com ? OTP "704318" ? CORRECT (attempt 1 of 5) ? "Your verification was successful. Let's proceed to the next s | 704318 Your verification was successful. Let's proceed to the next step. |
| CP025 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | system | implied | Group booking identifier = NOT PRESENT | "I found 1 passenger on this booking: Gabriel Morin (Adult - Aeroplan Member). Is this who you'd like to include?" ? "Yes" ? PAX count 1 ? PROCEED |
| CP026 | JOURNEY SELECTION (GenUC-08) | bot | chat | Chatbot displays: Journey YUL ? YQB, Jul 20, 2026, via YYZ (AC 412, AC 7650), Arrival Delay 7 hours ? user "Yes" | Yes |
| CP027 | SEGMENT CHECK | system | implied | More than 1 segment ? YES (2 legs) ? segment handling (GenUC-18) runs; journey confirmed as one bound |  |
| CP028 | DUPLICATE, 72-HOUR AND TIME LIMIT CHECKS | system | implied | Duplicate check ? none | 72-hour check ? more than 72 hours ? PROCEED APPR limit ? 8 days (within 366 days) ? PROCEED |
| CP029 | TRIAGE & DDS EVALUATION | system | implied | Gate 1: not employee, not infant ? PROCEED | Gate 2: promised = actual routing (no VOL / INVOL) Gate 3: travelled to final destination (YQB) Gate 4: MSL = Leg 2 AC 7650 YYZ ? YQB Gate 5: operating carrier  |
| CP030 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary: Leg 1 on time; Leg 2 ARRIVED LATE, 14:00 ? 21:00, +7H 00M | Current Itinerary: Leg 1 on time; Leg 2 ARRIVED LATE, 14:00 ? 21:00, +7H 00M |
| CP031 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP032 | TRIP TRACER UI VALIDATION | verdict | api | MSL Flight: AC 7650 � YYZ ? YQB | MSL Flight: AC 7650 � YYZ ? YQB |
| CP033 | TRIP TRACER UI VALIDATION | verdict | api | MSL operating carrier: blank / "Unknown"; isStarSegment = false; isOalSegment = false | MSL operating carrier: blank / "Unknown"; isStarSegment = false; isOalSegment = false |
| CP034 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +7H 00M � controllability not decided | Delay: +7H 00M � controllability not decided |
| CP035 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: 9876543210 (Basic Member � linked) | Aeroplan: 9876543210 (Basic Member � linked) |
| CP036 | TRIP TRACER UI VALIDATION | verdict | api | MR GABRIEL MORIN / NO DETERMINATION / Carrier unknown / CAD 0.00 | MR GABRIEL MORIN / NO DETERMINATION / Carrier unknown / CAD 0.00 |
| CP037 | TRIP TRACER UI VALIDATION | verdict | api | NOTE: The 7h delay is visible. If manual review confirms the carrier is AC or AC family and the code is controllable, APPR 6 to under 9 hrs  | NOTE: The 7h delay is visible. If manual review confirms the carrier is AC or AC family and the code is controllable, APPR 6 to under 9 hrs (CAD 700 / CAD 840 A |
| CP038 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource runs only for ELIGIBLE cases ? NOT invoked |  |
| CP039 | AC WALLET CHECK � NOT TRIGGERED | system | implied | AC Wallet / Cash offer only for ELIGIBLE cases ? NOT offered, even with Basic Aeroplan linked |  |
| CP040 | NO DETERMINATION RESULT | bot | chat | Chatbot displays the standard No Determination response: | Based on the information available, we are unable to determine your eligibility at this time. Flight disruptions can involve multiple factors, and the reason fo |
| CP041 | NO DETERMINATION RESULT | system | implied | And no compensation amount is shown |  |
| CP042 | NO DETERMINATION RESULT | system | implied | And no "Would you like us to proceed?" prompt is shown (case created automatically) |  |
| CP043 | NO DETERMINATION RESULT | system | implied | And no payment country, Interac email or other payment details are collected |  |
| CP044 | CASE CREATION (GLOB-09) | bot | chat | Chatbot responds: "Your claim has been submitted. Case Reference: CASE-FD-20260728-202." / "Our team will review your case and contact you w | Your claim has been submitted. Case Reference: CASE-FD-20260728-202. Our team will review your case and contact you within 30 days. |
| CP045 | CASE CREATION (GLOB-09) | system | implied | And the booking record is appended to the case automatically |  |
| CP046 | CASE CREATION (GLOB-09) | system | implied | And the case is routed to the manual review queue |  |
| CP047 | NOTIFICATION | email | email | Case acknowledgement email sent to g***@gmail.com with: Case Reference, journey YUL ? YQB Jul 20, 2026 (delayed 7h), the No Determination me |  |
| CP048 | NOTIFICATION | email | email | And the email does NOT mention any compensation amount |  |
| CP049 | END FLOW (GLOB-11) | customer | chat | "Is there anything I can help you with?" ? user selects "No" ? "Thank you for choosing Air Canada." | Is there anything I can help you with? No Thank you for choosing Air Canada. |
| CP050 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Given the case has been created for claimant "Gabriel Morin" with PNR "UC002" |  |
| CP051 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP052 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP053 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Case Status should be "Forwarded � Manual Review" |  |
| CP054 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Created and Last Updated dates should be populated |  |
| CP055 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the SLA countdown should track the 30-day response commitment |  |
| CP056 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the Team assignment should be the manual review team |  |
| CP057 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP058 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Claimant should be "Gabriel Morin", Adult, Authentication "Pass" |  |
| CP059 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the PNR should be "UC002" with Creation Date, Journey ID, Booking Source and Office ID populated |  |
| CP060 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP061 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP062 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Email should be "g***@gmail.com" and the Address populated |  |
| CP063 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Aeroplan should be "9876543210", Tier "Basic / Member" |  |
| CP064 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ ? YQB" with Leg 2 AC 7650 as the MSL (+7H 00M) |  |
| CP065 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the MSL operating carrier should show "Unknown" (not AC, STAR or OAL) |  |
| CP066 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Ancillary Fee section should be present and empty |  |
| CP067 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Eligibility and Compensation section should show "NO DETERMINATION � Carrier at fault unknown � CAD 0" |  |
| CP068 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no Cash or AC Wallet offer should be recorded |  |
| CP069 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And DDS should have run automatically with no agent action |  |
| CP070 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And Decision Assist should show "No Determination" with the carrier reason, and should not show an Eligible or Not Eligible recommendation |  |
| CP071 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Duplicate Check should show "No duplicate found" using baseline "Gabriel Morin + UC002 + YUL?YQB + FD" |  |
| CP072 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the CyberSource result should be "Not triggered" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the IDV status should be "Not triggered" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Trip Tracer poll should NOT be required |  |
| CP075 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the acknowledgement email should be shown in Customer Communications with no compensation amount |  |
| CP076 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the chatbot transcript should be linked |  |
| CP077 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the Audit Log should record DDS result, case creation, routing and notification with timestamps |  |
| CP078 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP079 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the agent should be able to investigate the operating carrier and record a manual decision (Eligible, Not Eligible or refer) |  |
| CP080 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Payment Validation Gherkin: |
| CP081 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Given the DDS outcome is "NO DETERMINATION" because the carrier at fault is unknown |  |
| CP082 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Then no payment country should be collected |  |
| CP083 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no Cash or AC Wallet option should be offered |  |
| CP084 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no Interac email, bank or card details should be collected |  |
| CP085 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And Persona IDV for payout should not be triggered |  |
| CP086 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no compensation record should be created |  |
| CP087 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And nothing should be picked up by the evening batch file |  |
| CP088 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And nothing should be sent to Unifier or EIP |  |
| CP089 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Compensation tab should show no payout (CAD 0) |  |
| CP090 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And if manual review later finds the claim eligible, payment should follow the Canada resident path (Interac, email only) or AC Wallet if se |  |
| CP091 | EXPECTED RESULTS | verdict | api | DDS returns NO DETERMINATION (FD-APPR-ND-xx, carrier unknown) for the single passenger, CAD 0. | DDS returns NO DETERMINATION (FD-APPR-ND-xx, carrier unknown) for the single passenger, CAD 0. |
| CP092 | EXPECTED RESULTS | verdict | api | Trip Tracer shows MSL Leg 2 AC 7650 YYZ ? YQB, +7H 00M, operating carrier Unknown. | Trip Tracer shows MSL Leg 2 AC 7650 YYZ ? YQB, +7H 00M, operating carrier Unknown. |
| CP093 | EXPECTED RESULTS | verdict | chat | The chatbot shows the standard No Determination message and creates the case automatically. | The chatbot shows the standard No Determination message and creates the case automatically. |
| CP094 | EXPECTED RESULTS | verdict | chat | The case is Forwarded � Manual Review with a 30-day SLA. | The case is Forwarded � Manual Review with a 30-day SLA. |
| CP095 | EXPECTED RESULTS | verdict | chat | No CyberSource check, AC Wallet or Cash offer, IDV, payment details or compensation record. | No CyberSource check, AC Wallet or Cash offer, IDV, payment details or compensation record. |
