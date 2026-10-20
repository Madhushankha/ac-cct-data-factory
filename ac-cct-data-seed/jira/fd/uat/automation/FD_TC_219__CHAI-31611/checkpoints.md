# FD_TC_219 · CHAI-31611 — checkpoints

**Goal:** Validates that when a Travel Agency attempts to submit a flight disruption claim on behalf of a passenger, the system immediately rejects the submission and advises the customer must file the claim themselves. The underlying flight involves a 7-hour arrival delay (6�<9h band) caused by Code 67 (Crew Transport / Hotel / Logistics Delay � Controllable) on a domestic APPR-applicable route, and the passenger holds a Basic Aeroplan profile (9876543210). Despite the disruption being a valid APPR controllable claim that would normally yield $700 CAD (Tier 2) / $840 CAD AC Wallet for a linked Basic Aeroplan member, the Travel Agency submission is a hard rejection per policy. Validates that: (1) System correctly identifies third-party type as Travel Agency, (2) System immediately rejects without proceeding to case number, country, Aeroplan, or info collection steps, (3) No case is created regardless of how valid or eligible the underlying flight disruption is, (4) No country-based, Aeroplan-based, or dispute override path exists for Travel Agencies, (5) Flow ends cleanly with rejection message.

Methods: seed 7, chat 24, api 2, dashboard 12, implied 8, manual 2, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates that when a Travel Agency attempts to submit a flight disruption claim on behalf of a passenger, the system immediately rejects th |  |
| CP002 | PREREQUISITES | prerequisite | seed | Third-party caller type: Travel Agency | Third-party caller type: Travel Agency |
| CP003 | PREREQUISITES | prerequisite | seed | Underlying flight: 1 leg AC domestic YUL?YYZ | Underlying flight: 1 leg AC domestic YUL?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Arrival delay code: 67 (Crew Transport / Hotel / Logistics Delay � Controllable) | Arrival delay code: 67 (Crew Transport / Hotel / Logistics Delay � Controllable) |
| CP005 | PREREQUISITES | prerequisite | seed | Delay: 7 hours (6�<9h band, APPR Tier 2 � would yield $700 CAD Cash / $840 CAD AC Wallet if filed by passenger directly) | Delay: 7 hours (6�<9h band, APPR Tier 2 � would yield $700 CAD Cash / $840 CAD AC Wallet if filed by passenger directly) |
| CP006 | PREREQUISITES | prerequisite | seed | Regime: APPR (domestic) | Regime: APPR (domestic) |
| CP007 | PREREQUISITES | prerequisite | seed | Passenger Aeroplan: Basic Member (9876543210) | Passenger Aeroplan: Basic Member (9876543210) |
| CP008 | PREREQUISITES | prerequisite | seed | CRITICAL: Despite a valid controllable APPR claim, Travel Agency submission is a hard rejection with no override path | CRITICAL: Despite a valid controllable APPR claim, Travel Agency submission is a hard rejection with no override path |
| CP009 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP010 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP011 | START | customer | chat | Then user selects English |  |
| CP012 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP013 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP014 | START | customer | chat | And the user says "I'm a travel agent and I need to file a flight disruption claim on behalf of my client. Their flight from Montreal to Tor | I'm a travel agent and I need to file a flight disruption claim on behalf of my client. Their flight from Montreal to Toronto was delayed 7 hours due to crew tr |
| CP015 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP016 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? YES |  |
| CP017 | START | system | implied | Then the chatbot identifies third-party type ? TRAVEL AGENCY |  |
| CP018 | THIRD-PARTY TYPE CHECK | system | implied | Then the system evaluates: Caller type = Travel Agency |  |
| CP019 | THIRD-PARTY TYPE CHECK | system | implied | And the system checks: Is Travel Agency an accepted third-party submission type? ? NO (hard rejection per policy) |  |
| CP020 | THIRD-PARTY TYPE CHECK | system | implied | And the system determines: NO override path exists for Travel Agencies |  |
| CP021 | THIRD-PARTY TYPE CHECK | system | implied | And the system determines: Flight details (Code 67, 7h delay, APPR, Basic Aeroplan) are irrelevant to the rejection � policy is absolute |  |
| CP022 | REJECTION | bot | chat | Then the chatbot responds: | Thank you for contacting Air Canada. We appreciate you reaching out on behalf of your client. However, under Air Canada's passenger compensation policy, flight  |
| CP023 | NOTE � CRITICAL VALIDATION POINT | system | implied | ? Underlying flight = Code 67 (Crew Transport � Controllable), 7h delay (6�<9h band) | ? APPR Tier 2 baseline = $700 CAD Cash / $840 CAD AC Wallet (Basic Aeroplan linked) ? Under normal passenger submission, this would be a fully ELIGIBLE, auto-ap |
| CP024 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP025 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP026 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP027 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the system correctly identifies the third-party type as "Travel Agency" |  |
| CP028 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the system should immediately reject the submission at the third-party check gate |  |
| CP029 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the rejection should occur BEFORE any of the following steps: | ? Identification / name collection ? PNR lookup ? OTP / authentication ? Passenger selection ? Journey selection (Code 67 / 7h delay / APPR details not evaluate |
| CP030 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the rejection message should clearly state the customer must submit the claim themselves |  |
| CP031 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no case should be created in Claims Dashboard |  |
| CP032 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And when searching Claims Dashboard no entry should exist for this Travel Agency submission |  |
| CP033 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no manual handoff should occur |  |
| CP034 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the flow should end after the rejection message |  |
| CP035 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no country of residence should have been collected |  |
| CP036 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Aeroplan or profile lookup should have been performed |  |
| CP037 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no compensation record should exist |  |
| CP038 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Travel Agencies are always denied per policy with no country-based, Aeroplan-based, or dispute override path |  |
| CP039 | PAYMENT VALIDATION | payment | manual | Given the Travel Agency submission was hard rejected per policy |  |
| CP040 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP041 | PAYMENT VALIDATION | payment | chat | And no case should exist in Claims Dashboard |  |
| CP042 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP043 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP044 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP045 | PAYMENT VALIDATION | payment | chat | And no Aeroplan or AC Wallet evaluation should have been triggered (Basic Aeroplan 9876543210 not reached) |  |
| CP046 | PAYMENT VALIDATION | payment | chat | And no IDV should have been triggered |  |
| CP047 | PAYMENT VALIDATION | payment | chat | And no CyberSource fraud screening should have been triggered |  |
| CP048 | PAYMENT VALIDATION | payment | chat | And the underlying APPR claim data (Code 67, 7h delay, Tier 2, $700 CAD / $840 AC Wallet) is irrelevant to the outcome � Travel Agency = har |  |
| CP049 | EXPECTED RESULTS | verdict | chat | System correctly identifies third-party type as Travel Agency. | System correctly identifies third-party type as Travel Agency. |
| CP050 | EXPECTED RESULTS | verdict | api | System immediately rejects at third-party gate BEFORE identification, PNR lookup, authentication, journey selection, or DDS evaluation. | System immediately rejects at third-party gate BEFORE identification, PNR lookup, authentication, journey selection, or DDS evaluation. |
| CP051 | EXPECTED RESULTS | verdict | chat | Rejection message clearly states the customer must submit the claim themselves. | Rejection message clearly states the customer must submit the claim themselves. |
| CP052 | EXPECTED RESULTS | verdict | api | CRITICAL: Even though the underlying flight involves a valid controllable APPR claim (Code 67 Crew Transport, 7h delay, 6�<9h band, $700 CAD | CRITICAL: Even though the underlying flight involves a valid controllable APPR claim (Code 67 Crew Transport, 7h delay, 6�<9h band, $700 CAD Tier 2 / $840 CAD A |
| CP053 | EXPECTED RESULTS | verdict | chat | No case created. | No case created. |
| CP054 | EXPECTED RESULTS | verdict | chat | No manual handoff. | No manual handoff. |
| CP055 | EXPECTED RESULTS | verdict | chat | No compensation record. | No compensation record. |
| CP056 | EXPECTED RESULTS | verdict | chat | Flow ends cleanly after rejection. | Flow ends cleanly after rejection. |
