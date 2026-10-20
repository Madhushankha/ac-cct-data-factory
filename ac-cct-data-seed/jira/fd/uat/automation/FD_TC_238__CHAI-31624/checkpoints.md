# FD_TC_238 · CHAI-31624 — checkpoints

**Goal:** Checks that DDS sends an EU claim to manual review when the only problem is that it can't identify the operating carrier. Flight AC 837 Madrid (MAD) ? Toronto (YYZ) is sold as AC and arrives 5 hours late. It's the only leg, so it's the MSL. Trip Tracer has no operating carrier recorded, so DDS can't match it to AC or an AC family carrier, STAR or OAL. Everything else passes: EU applies (Spain departure), APPR also applies (Canada arrival), the Spain 5-year limit is met, the delay is 300 minutes, and a controllable arrival code (96) is logged. Because of the carrier, DDS returns NO DETERMINATION for both passengers with EUR 0. It doesn't return Eligible (EUR 600) or Not Eligible. The chatbot shows the standard No Determination message and creates one case for both passengers, sent to manual review with a 30-day commitment. No CyberSource check, Cash or AC Wallet offer, IDV or payment details. BSM email and phone are not collected.

Methods: seed 13, chat 18, api 11, email 2, dashboard 36, implied 16, manual 6, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Checks that DDS sends an EU claim to manual review when the only problem is that it can't identify the operating carrier. Flight AC 837 Madr |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: EU002 � 2 passengers: Luc�a Garc�a (Adult - Claimant, Basic Aeroplan 9876543210, good standing), Javier Garc�a (Adult) | PNR: EU002 � 2 passengers: Luc�a Garc�a (Adult - Claimant, Basic Aeroplan 9876543210, good standing), Javier Garc�a (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Flight: AC 837 MAD ? YYZ, Aug 10, 2026 | Flight: AC 837 MAD ? YYZ, Aug 10, 2026 |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival 15:00, actual 20:00 (5h / 300 min late) | Scheduled arrival 15:00, actual 20:00 (5h / 300 min late) |
| CP005 | PREREQUISITES | prerequisite | seed | Operating carrier: missing (null) in Trip Tracer | Operating carrier: missing (null) in Trip Tracer |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival delay code 96 (Operations Control, Controllable) logged | Arrival delay code 96 (Operations Control, Controllable) logged |
| CP007 | PREREQUISITES | prerequisite | seed | Customers told on the day of travel (under 14 days) | Customers told on the day of travel (under 14 days) |
| CP008 | PREREQUISITES | prerequisite | seed | No VOL/INVOL changes | No VOL/INVOL changes |
| CP009 | PREREQUISITES | prerequisite | seed | Travelled to YYZ | Travelled to YYZ |
| CP010 | PREREQUISITES | prerequisite | seed | Claim filed Aug 20, 2026 (more than 72h, within the Spain 5-year limit) | Claim filed Aug 20, 2026 (more than 72h, within the Spain 5-year limit) |
| CP011 | PREREQUISITES | prerequisite | seed | No duplicate | No duplicate |
| CP012 | PREREQUISITES | prerequisite | seed | Not employee | Not employee |
| CP013 | PREREQUISITES | prerequisite | seed | Not a group booking | Not a group booking |
| CP014 | PREREQUISITES | prerequisite | seed | Country of residence: Spain | Country of residence: Spain |
| CP015 | GREETING & INTENT IDENTIFICATION | customer | chat | Given the user opens the agentic chatbot |  |
| CP016 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot displays greeting (GLOB-01): "Hello! I will be your virtual assistant today. I can assist you in English or French. Which l | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP017 | GREETING & INTENT IDENTIFICATION | customer | chat | Then user selects "English" | English |
| CP018 | GREETING & INTENT IDENTIFICATION | alert | chat | Then the privacy alert is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI to a | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP019 | GREETING & INTENT IDENTIFICATION | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP020 | GREETING & INTENT IDENTIFICATION | customer | chat | And the user says "Our flight from Madrid to Toronto arrived about 5 hours late. I'd like to check if my husband and I are eligible for comp | Our flight from Madrid to Toronto arrived about 5 hours late. I'd like to check if my husband and I are eligible for compensation |
| CP021 | GREETING & INTENT IDENTIFICATION | system | implied | When the chatbot identifies flight disruption intent |  |
| CP022 | GREETING & INTENT IDENTIFICATION | system | implied | Then third-party check ? NO |  |
| CP023 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP024 | LEGAL DISCLAIMER | bot | chat | Then the chatbot shows the automated decision-making disclaimer ? user agrees to start |  |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | User provides "Luc�a Garc�a" and PNR "EU002" ? Trip Tracer PNR FOUND (Auth Flow 1) | Luc�a Garc�a EU002 |
| CP026 | AUTHENTICATION (GenUC-05) | customer | chat | User selects Email l***@gmail.com ? OTP "830514" ? CORRECT (attempt 1 of 5) ? "Your verification was successful. Let's proceed to the next s | 830514 Your verification was successful. Let's proceed to the next step. |
| CP027 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | system | implied | Group booking identifier = NOT PRESENT | "I found 2 passengers on this booking: Luc�a Garc�a (Adult - Aeroplan Member), Javier Garc�a (Adult). Would you like to include all passengers in this claim?" ? |
| CP028 | JOURNEY SELECTION (GenUC-08) | bot | chat | Chatbot displays: Flight AC 837, Madrid (MAD) ? Toronto (YYZ), Aug 10, 2026, Arrival Delay 5 hours ? user "Yes" | Yes |
| CP029 | SEGMENT CHECK | system | implied | More than 1 segment ? NO (single leg) ? skip GenUC-18 |  |
| CP030 | DUPLICATE, 72-HOUR AND TIME LIMIT CHECKS | system | implied | Duplicate check ? no existing case for either passenger | 72-hour check ? more than 72 hours ? PROCEED Time limit ? Spain departure ? 5 years (Aug 10, 2031); 10 days elapsed ? PROCEED |
| CP031 | TRIAGE & DDS EVALUATION | system | implied | Gate 1: not employee ? PROCEED | Gate 2: promised = actual (no VOL / INVOL) Gate 3: travelled to final destination (YYZ) Gate 4: MSL = AC 837 MAD ? YYZ (single leg) Gate 5: operating carrier =  |
| CP032 | TRIAGE & DDS EVALUATION | verdict | api | And DDS does NOT return Eligible (EUR 600) or Not Eligible |  |
| CP033 | TRIAGE & DDS EVALUATION | system | implied | And APPR is also assessed as No Determination (same carrier reason), so no amount is picked under the most generous rule |  |
| CP034 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary: AC 837 MAD ? YYZ, ARRIVED LATE, 15:00 ? 20:00, +5H 00M | Current Itinerary: AC 837 MAD ? YYZ, ARRIVED LATE, 15:00 ? 20:00, +5H 00M |
| CP035 | TRIP TRACER UI VALIDATION | verdict | api | Regimes: EU + APPR (2 regimes) | Regimes: EU + APPR (2 regimes) |
| CP036 | TRIP TRACER UI VALIDATION | verdict | api | MSL: AC 837 � MAD ? YYZ � Code 96 (Controllable) | MSL: AC 837 � MAD ? YYZ � Code 96 (Controllable) |
| CP037 | TRIP TRACER UI VALIDATION | verdict | api | MSL operating carrier: blank / "Unknown"; isStarSegment = false; isOalSegment = false | MSL operating carrier: blank / "Unknown"; isStarSegment = false; isOalSegment = false |
| CP038 | TRIP TRACER UI VALIDATION | verdict | api | EU expiry: 2031-08-10 | EU expiry: 2031-08-10 |
| CP039 | TRIP TRACER UI VALIDATION | verdict | api | Aeroplan: 9876543210 (Basic Member � linked, claimant) | Aeroplan: 9876543210 (Basic Member � linked, claimant) |
| CP040 | TRIP TRACER UI VALIDATION | verdict | api | MS LUC�A GARC�A / NO DETERMINATION / Carrier unknown / EUR 0.00 | MS LUC�A GARC�A / NO DETERMINATION / Carrier unknown / EUR 0.00 |
| CP041 | TRIP TRACER UI VALIDATION | verdict | api | MR JAVIER GARC�A / NO DETERMINATION / Carrier unknown / EUR 0.00 | MR JAVIER GARC�A / NO DETERMINATION / Carrier unknown / EUR 0.00 |
| CP042 | TRIP TRACER UI VALIDATION | verdict | api | NOTE: If manual review confirms AC is the operating carrier, EU DELAY_GTE_4_HOURS applies (EUR 600 each). It's on hold until then. | NOTE: If manual review confirms AC is the operating carrier, EU DELAY_GTE_4_HOURS applies (EUR 600 each). It's on hold until then. |
| CP043 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource runs only for ELIGIBLE cases ? NOT invoked |  |
| CP044 | AC WALLET / CASH � NOT TRIGGERED | system | implied | No offer, even with Basic Aeroplan linked |  |
| CP045 | NO DETERMINATION RESULT | bot | chat | Chatbot displays the standard No Determination response: | Based on the information available, we are unable to determine your eligibility at this time. Flight disruptions can involve multiple factors, and the reason fo |
| CP046 | NO DETERMINATION RESULT | system | implied | And no compensation amount (EUR or CAD) is shown |  |
| CP047 | NO DETERMINATION RESULT | system | implied | And no "Would you like us to proceed?" prompt is shown (case created automatically) |  |
| CP048 | NO DETERMINATION RESULT | system | implied | And the country of residence question is NOT asked |  |
| CP049 | NO DETERMINATION RESULT | system | implied | And no email or phone for BSM, bank name, IBAN or SWIFT/BIC is collected |  |
| CP050 | CASE CREATION (GLOB-09) | bot | chat | Chatbot responds: "Your claim has been submitted. Case Reference: CASE-FD-20260820-402." / "Our team will review your case and contact you w | Your claim has been submitted. Case Reference: CASE-FD-20260820-402. Our team will review your case and contact you within 30 days. |
| CP051 | CASE CREATION (GLOB-09) | system | implied | And one case is created for both passengers |  |
| CP052 | CASE CREATION (GLOB-09) | system | implied | And the booking record is appended automatically |  |
| CP053 | CASE CREATION (GLOB-09) | system | implied | And the case is routed to the manual review queue |  |
| CP054 | NOTIFICATION | email | email | One acknowledgement email sent to l***@gmail.com for the case, with: Case Reference, both passenger names, AC 837 MAD ? YYZ Aug 10, 2026 (de |  |
| CP055 | NOTIFICATION | email | email | And the email does NOT mention any compensation amount |  |
| CP056 | END FLOW (GLOB-11) | customer | chat | "Is there anything I can help you with?" ? user selects "No" ? "Thank you for choosing Air Canada." | Is there anything I can help you with? No Thank you for choosing Air Canada. |
| CP057 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Given the case has been created for claimant "Luc�a Garc�a" with PNR "EU002" covering 2 passengers |  |
| CP058 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delays" |  |
| CP059 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP060 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Case Status should be "Forwarded � Manual Review" |  |
| CP061 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Created and Last Updated dates should be populated |  |
| CP062 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the SLA countdown should track the 30-day response commitment |  |
| CP063 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the Team assignment should be the manual review team |  |
| CP064 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP065 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Claimant should be "Luc�a Garc�a", Adult, Authentication "Pass" |  |
| CP066 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the PNR should be "EU002" with Creation Date, Journey ID, Booking Source and Office ID populated |  |
| CP067 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Regime should be "EU" with APPR also listed as applicable |  |
| CP068 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the passengers should be listed as Luc�a Garc�a (Adult, Claimant, Aeroplan 9876543210, Basic / Member) and Javier Garc�a (Adult) |  |
| CP069 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Email should be "l***@gmail.com" and the Address populated |  |
| CP070 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Journey should show "Bound 1: MAD ? YYZ" (AC 837, +5H 00M, MSL) |  |
| CP071 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the MSL operating carrier should show "Unknown" (not AC, STAR or OAL) |  |
| CP072 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Disruption Code should show "96 (Controllable)" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the EU expiry should show "2031-08-10" (Spain, 5 years) |  |
| CP074 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Ancillary Fee section should be present and empty |  |
| CP075 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Eligibility and Compensation section should show "NO DETERMINATION � Carrier at fault unknown � EUR 0" for each passenger |  |
| CP076 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no Cash or AC Wallet offer should be recorded |  |
| CP077 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And DDS should have run automatically with no agent action |  |
| CP078 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And Decision Assist should show "No Determination" with carrier unknown as the only reason |  |
| CP079 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Duplicate Check should show "No duplicate found" for both passengers using baseline "Luc�a Garc�a + EU002 + MAD?YYZ + FD" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the CyberSource result should be "Not triggered" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the IDV status should be "Not triggered" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Trip Tracer poll should NOT be required |  |
| CP083 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And Customer Communications should show one acknowledgement email with no compensation amount |  |
| CP084 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the chatbot transcript should be linked |  |
| CP085 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the Audit Log should record DDS result, case creation, routing and notification with timestamps |  |
| CP086 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP087 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the agent should be able to confirm the operating carrier and record a manual decision per passenger |  |
| CP088 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Payment Validation Gherkin: |
| CP089 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Given the DDS outcome is "NO DETERMINATION" for both passengers because the carrier at fault is unknown |  |
| CP090 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | Then no country of residence should be collected for payment |  |
| CP091 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no Cash or AC Wallet option should be offered |  |
| CP092 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no BSM email or phone, bank name, IBAN or SWIFT/BIC should be collected |  |
| CP093 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And Persona IDV for payout should not be triggered |  |
| CP094 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And no payment record should be created for either passenger |  |
| CP095 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And nothing should be picked up by the evening batch file |  |
| CP096 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And nothing should be sent to Unifier (HSBC) or Ariba |  |
| CP097 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And the Compensation tab should show EUR 0 per passenger and EUR 0 total |  |
| CP098 | CLAIMS DASHBOARD VALIDATION (GLOB-11) | dashboard | dashboard | And if manual review later finds the claim eligible, a Spain resident should be offered BSM � Email Payment in EUR, collecting email and pho |  |
| CP099 | EXPECTED RESULTS | verdict | api | DDS returns NO DETERMINATION (FD-EU-ND-xx, carrier unknown) for both passengers, EUR 0. | DDS returns NO DETERMINATION (FD-EU-ND-xx, carrier unknown) for both passengers, EUR 0. |
| CP100 | EXPECTED RESULTS | verdict | chat | It doesn't return EUR 600 or Not Eligible, even though the delay (5h), the code (96) and the Spain expiry all pass. | It doesn't return EUR 600 or Not Eligible, even though the delay (5h), the code (96) and the Spain expiry all pass. |
| CP101 | EXPECTED RESULTS | verdict | chat | The chatbot shows the standard No Determination message and creates one case automatically. | The chatbot shows the standard No Determination message and creates one case automatically. |
| CP102 | EXPECTED RESULTS | verdict | chat | The case is Forwarded � Manual Review with a 30-day SLA. | The case is Forwarded � Manual Review with a 30-day SLA. |
| CP103 | EXPECTED RESULTS | verdict | chat | No CyberSource check, offer, IDV, BSM or bank details, or payment records. | No CyberSource check, offer, IDV, BSM or bank details, or payment records. |
