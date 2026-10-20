# FD_TC_237 · CHAI-31623 — checkpoints

**Goal:** Checks that DDS doesn't automatically decline a weather cancellation while the coding is still being reviewed. Flight AC 305 YUL ? YVR is cancelled on the day of travel. Both passengers are rebooked on AC 311 and arrive 7 hours later than promised. The cancelled flight has cancellation code WXX (Weather, uncontrollable). It also carries an open coding review (code 00 / IU "Under Investigation"), so controllability is disputed. DDS returns NO DETERMINATION with CAD 0 for both passengers. It does not return Not Eligible (FD-APPR-NE-28) and does not decline in the chat. The chatbot shows the standard No Determination message and creates one case for both passengers, sent to manual review with a 30-day commitment. There is no CyberSource check, no Cash or AC Wallet offer, no IDV and no payment.

Methods: seed 14, chat 18, api 13, email 2, dashboard 34, implied 15, manual 7, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Checks that DDS doesn't automatically decline a weather cancellation while the coding is still being reviewed. Flight AC 305 YUL ? YVR is ca |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: UD002 � 2 passengers: Marie-�ve Tremblay (Adult - Claimant, Basic Aeroplan 9876543210, good standing), Luc Tremblay (Adult) | PNR: UD002 � 2 passengers: Marie-�ve Tremblay (Adult - Claimant, Basic Aeroplan 9876543210, good standing), Luc Tremblay (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Promised (14-day itinerary): AC 305 YUL ? YVR, Aug 5, 2026, departing 08:00, arriving 10:30 local | Promised (14-day itinerary): AC 305 YUL ? YVR, Aug 5, 2026, departing 08:00, arriving 10:30 local |
| CP004 | PREREQUISITES | prerequisite | seed | Change: INVOL on Aug 5, AC 305 cancelled (customers told on the day) | Change: INVOL on Aug 5, AC 305 cancelled (customers told on the day) |
| CP005 | PREREQUISITES | prerequisite | seed | Actual: AC 311 YUL ? YVR, Aug 5, arriving 17:30 local, both boarded (coupons flown) | Actual: AC 311 YUL ? YVR, Aug 5, arriving 17:30 local, both boarded (coupons flown) |
| CP006 | PREREQUISITES | prerequisite | seed | Delay at arrival: 7h (420 min) | Delay at arrival: 7h (420 min) |
| CP007 | PREREQUISITES | prerequisite | seed | AC 305 cancellation code: WXX (Weather) | AC 305 cancellation code: WXX (Weather) |
| CP008 | PREREQUISITES | prerequisite | seed | Coding status: under review, code 00 / IU "Under Investigation" also logged | Coding status: under review, code 00 / IU "Under Investigation" also logged |
| CP009 | PREREQUISITES | prerequisite | seed | No voluntary changes (VOL) | No voluntary changes (VOL) |
| CP010 | PREREQUISITES | prerequisite | seed | AC only | AC only |
| CP011 | PREREQUISITES | prerequisite | seed | Not a group booking | Not a group booking |
| CP012 | PREREQUISITES | prerequisite | seed | Claim filed Aug 14, 2026 (more than 72h, within 366 days) | Claim filed Aug 14, 2026 (more than 72h, within 366 days) |
| CP013 | PREREQUISITES | prerequisite | seed | No duplicate | No duplicate |
| CP014 | PREREQUISITES | prerequisite | seed | Not employee, not infant | Not employee, not infant |
| CP015 | PREREQUISITES | prerequisite | seed | Country of residence: Canada | Country of residence: Canada |
| CP016 | GREETING & INTENT IDENTIFICATION | customer | chat | Given the user opens the agentic chatbot |  |
| CP017 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot displays greeting (GLOB-01): "Hello! I will be your virtual assistant today. I can assist you in English or French. Which l | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP018 | GREETING & INTENT IDENTIFICATION | customer | chat | Then user selects "English" | English |
| CP019 | GREETING & INTENT IDENTIFICATION | alert | chat | Then the privacy alert is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI to a | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP020 | GREETING & INTENT IDENTIFICATION | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP021 | GREETING & INTENT IDENTIFICATION | customer | chat | And the user says "Our flight from Montreal to Vancouver was cancelled and they said it was the weather, but the weather was fine. We were p | Our flight from Montreal to Vancouver was cancelled and they said it was the weather, but the weather was fine. We were put on a later flight and arrived about  |
| CP022 | GREETING & INTENT IDENTIFICATION | system | implied | When the chatbot identifies flight disruption intent |  |
| CP023 | GREETING & INTENT IDENTIFICATION | system | implied | Then third-party check ? NO |  |
| CP024 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP025 | LEGAL DISCLAIMER | bot | chat | Then the chatbot shows the automated decision-making disclaimer ? user agrees to start |  |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | User provides "Marie-�ve Tremblay" and PNR "UD002" ? Trip Tracer PNR FOUND (Auth Flow 1) | Marie-�ve Tremblay UD002 |
| CP027 | AUTHENTICATION (GenUC-05) | customer | chat | User selects Email m***@gmail.com ? OTP "482091" ? CORRECT (attempt 1 of 5) ? "Your verification was successful. Let's proceed to the next s | 482091 Your verification was successful. Let's proceed to the next step. |
| CP028 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | system | implied | Group booking identifier = NOT PRESENT | "I found 2 passengers on this booking: Marie-�ve Tremblay (Adult - Aeroplan Member), Luc Tremblay (Adult). Would you like to include all passengers in this clai |
| CP029 | JOURNEY SELECTION (GenUC-08) | bot | chat | Chatbot displays: Original flight AC 305 Montreal (YUL) ? Vancouver (YVR), Aug 5, 2026 (Cancelled); rebooked on AC 311; Arrival Delay 7 hour | Yes |
| CP030 | SEGMENT CHECK | system | implied | More than 1 segment on the selected journey ? NO (single leg) ? skip GenUC-18 |  |
| CP031 | DUPLICATE, 72-HOUR AND TIME LIMIT CHECKS | system | implied | Duplicate check ? no existing case for either passenger | 72-hour check ? more than 72 hours ? PROCEED APPR limit ? 9 days (within 366 days) ? PROCEED |
| CP032 | TRIAGE & DDS EVALUATION | system | implied | Gate 1: not employee, not infant ? PROCEED (both) | Gate 2: first INVOL = AC 305 cancellation; no earlier VOL ? promised itinerary = 14-day itinerary (AC 305, arriving 10:30) Gate 3: both boarded AC 311 and reach |
| CP033 | TRIAGE & DDS EVALUATION | verdict | api | And DDS does NOT return FD-APPR-NE-28 (uncontrollable Not Eligible) |  |
| CP034 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary: AC 305 CANCELLED (INVOL); AC 311 YUL ? YVR, arrived 17:30 | Current Itinerary: AC 305 CANCELLED (INVOL); AC 311 YUL ? YVR, arrived 17:30 |
| CP035 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +7H 00M | Delay: +7H 00M |
| CP036 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP037 | TRIP TRACER UI VALIDATION | verdict | api | MSL Flight: AC 305 � YUL ? YVR � Cancellation code WXX "Cancelled due to weather" | MSL Flight: AC 305 � YUL ? YVR � Cancellation code WXX "Cancelled due to weather" |
| CP038 | TRIP TRACER UI VALIDATION | verdict | api | Coding flag: 00 / IU "Under Investigation" (controllability under review) | Coding flag: 00 / IU "Under Investigation" (controllability under review) |
| CP039 | TRIP TRACER UI VALIDATION | verdict | api | Controllability: UNDER DETERMINATION (not Uncontrollable, not Controllable) | Controllability: UNDER DETERMINATION (not Uncontrollable, not Controllable) |
| CP040 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: 9876543210 (Basic Member � linked, claimant) | Aeroplan: 9876543210 (Basic Member � linked, claimant) |
| CP041 | TRIP TRACER UI VALIDATION | verdict | api | MS MARIE-�VE TREMBLAY / NO DETERMINATION / Controllability under determination / CAD 0.00 | MS MARIE-�VE TREMBLAY / NO DETERMINATION / Controllability under determination / CAD 0.00 |
| CP042 | TRIP TRACER UI VALIDATION | verdict | api | MR LUC TREMBLAY / NO DETERMINATION / Controllability under determination / CAD 0.00 | MR LUC TREMBLAY / NO DETERMINATION / Controllability under determination / CAD 0.00 |
| CP043 | TRIP TRACER UI VALIDATION | verdict | api | NOTE: If the review confirms Weather, both passengers become Not Eligible. If it changes the cause to controllable, APPR 6 to under 9 hrs ap | NOTE: If the review confirms Weather, both passengers become Not Eligible. If it changes the cause to controllable, APPR 6 to under 9 hrs applies (CAD 700 each) |
| CP044 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource runs only for ELIGIBLE cases ? NOT invoked |  |
| CP045 | AC WALLET / CASH � NOT TRIGGERED | system | implied | No offer, even with Basic Aeroplan linked |  |
| CP046 | NO DETERMINATION RESULT | bot | chat | Chatbot displays the standard No Determination response: | Based on the information available, we are unable to determine your eligibility at this time. Flight disruptions can involve multiple factors, and the reason fo |
| CP047 | NO DETERMINATION RESULT | system | implied | And the chatbot does NOT say the claim is declined or that weather makes them ineligible |  |
| CP048 | NO DETERMINATION RESULT | system | implied | And no compensation amount is shown |  |
| CP049 | NO DETERMINATION RESULT | system | implied | And no "Would you like us to proceed?" prompt is shown (case created automatically) |  |
| CP050 | NO DETERMINATION RESULT | system | implied | And no payment country, Interac email or other payment details are collected |  |
| CP051 | CASE CREATION (GLOB-09) | bot | chat | Chatbot responds: "Your claim has been submitted. Case Reference: CASE-FD-20260814-302." / "Our team will review your case and contact you w | Your claim has been submitted. Case Reference: CASE-FD-20260814-302. Our team will review your case and contact you within 30 days. |
| CP052 | CASE CREATION (GLOB-09) | system | implied | And one case is created for both passengers |  |
| CP053 | CASE CREATION (GLOB-09) | system | implied | And the booking record is appended to the case automatically |  |
| CP054 | CASE CREATION (GLOB-09) | system | implied | And the case is routed to the manual review queue |  |
| CP055 | NOTIFICATION | email | email | One acknowledgement email sent to m***@gmail.com for the case, containing: Case Reference, both passenger names, AC 305 YUL ? YVR Aug 5, 202 |  |
| CP056 | NOTIFICATION | email | email | And the email does NOT mention any compensation amount or a weather decline |  |
| CP057 | END FLOW (GLOB-11) | customer | chat | "Is there anything I can help you with?" ? user selects "No" ? "Thank you for choosing Air Canada." | Is there anything I can help you with? No Thank you for choosing Air Canada. |
| CP058 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Given the case has been created for claimant "Marie-�ve Tremblay" with PNR "UD002" covering 2 passengers |  |
| CP059 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellations" |  |
| CP060 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP061 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Case Status should be "Forwarded � Manual Review" |  |
| CP062 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Created and Last Updated dates should be populated |  |
| CP063 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the SLA countdown should track the 30-day response commitment |  |
| CP064 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the Team assignment should be the manual review team |  |
| CP065 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP066 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Claimant should be "Marie-�ve Tremblay", Adult, Authentication "Pass" |  |
| CP067 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the PNR should be "UD002" with Creation Date, Journey ID, Booking Source and Office ID populated |  |
| CP068 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP069 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the passengers should be listed as Marie-�ve Tremblay (Adult, Claimant, Aeroplan 9876543210, Basic / Member) and Luc Tremblay (Adult) |  |
| CP070 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Email should be "m***@gmail.com" and the Address populated |  |
| CP071 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YVR" with AC 305 Cancelled (MSL) and AC 311 as the rebooked flight (+7H 00M) |  |
| CP072 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Disruption Code should show "WXX � Weather" with the "Under Investigation / under review" flag |  |
| CP073 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Ancillary Fee section should be present and empty |  |
| CP074 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Eligibility and Compensation section should show "NO DETERMINATION � Controllability under determination � CAD 0" for each passenger |  |
| CP075 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no Cash or AC Wallet offer should be recorded |  |
| CP076 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And DDS should have run automatically with no agent action |  |
| CP077 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And Decision Assist should show "No Determination" and should not show "Not Eligible" or "Eligible" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Duplicate Check should show "No duplicate found" for both passengers using baseline "Marie-�ve Tremblay + UD002 + YUL?YVR + FD" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the CyberSource result should be "Not triggered" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the IDV status should be "Not triggered" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Trip Tracer poll should NOT be required |  |
| CP082 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And Customer Communications should show one acknowledgement email with no compensation amount |  |
| CP083 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the chatbot transcript should be linked |  |
| CP084 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the Audit Log should record DDS result, case creation, routing and notification with timestamps |  |
| CP085 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP086 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the agent should not edit the flight code and should request a coding review, then re-run Decision Assist once the review is complete |  |
| CP087 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the agent should be able to record a manual decision per passenger (Eligible or Not Eligible) after the review |  |
| CP088 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Payment Validation Gherkin: |
| CP089 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Given the DDS outcome is "NO DETERMINATION" for both passengers because controllability is under determination |  |
| CP090 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Then no payment country should be collected |  |
| CP091 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no Cash or AC Wallet option should be offered |  |
| CP092 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no Interac email, bank or card details should be collected |  |
| CP093 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And Persona IDV for payout should not be triggered |  |
| CP094 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no payment record should be created for either passenger |  |
| CP095 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And nothing should be picked up by the evening batch file |  |
| CP096 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And nothing should be sent to Unifier or EIP |  |
| CP097 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Compensation tab should show no payout (CAD 0 per passenger, CAD 0 total) |  |
| CP098 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And if manual review later finds the claim eligible, payment should follow the Canada resident path (Interac, email only) or AC Wallet if se |  |
| CP099 | EXPECTED RESULTS | verdict | api | DDS returns NO DETERMINATION (FD-APPR-ND-xx, controllability under determination) for both passengers, CAD 0. | DDS returns NO DETERMINATION (FD-APPR-ND-xx, controllability under determination) for both passengers, CAD 0. |
| CP100 | EXPECTED RESULTS | verdict | chat | It does not return FD-APPR-NE-28. | It does not return FD-APPR-NE-28. |
| CP101 | EXPECTED RESULTS | verdict | api | Trip Tracer shows the MSL as AC 305 cancelled with WXX Weather plus an under-review flag, rebooked on AC 311, +7H 00M. | Trip Tracer shows the MSL as AC 305 cancelled with WXX Weather plus an under-review flag, rebooked on AC 311, +7H 00M. |
| CP102 | EXPECTED RESULTS | verdict | chat | The chatbot shows the standard No Determination message, with no decline and no amount, and creates one case automatically. | The chatbot shows the standard No Determination message, with no decline and no amount, and creates one case automatically. |
| CP103 | EXPECTED RESULTS | verdict | chat | The case is Forwarded � Manual Review with a 30-day SLA. | The case is Forwarded � Manual Review with a 30-day SLA. |
| CP104 | EXPECTED RESULTS | verdict | chat | No CyberSource check, offer, IDV, payment details or payment records. | No CyberSource check, offer, IDV, payment details or payment records. |
