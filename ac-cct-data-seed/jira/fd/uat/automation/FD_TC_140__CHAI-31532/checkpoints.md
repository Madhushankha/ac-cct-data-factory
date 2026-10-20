# FD_TC_140 · CHAI-31532 — checkpoints

**Goal:** UK-origin flight (LHR?YYZ, AC-operated) cancelled due to uncontrollable reason (cancellation code WEAT � severe weather). Customer declined rebooking and remained at LHR. Under EU 261, extraordinary circumstances (Article 5(3)) exempt the airline from compensation. Result: NOT ELIGIBLE, �0. Validates: (1) Uncontrollable cancellation code WEAT correctly classified, (2) EU 261 extraordinary circumstances exemption applied, (3) No payment flow triggered for not-eligible cases, (4) CyberSource NOT invoked, (5) No IDV required.

Methods: seed 11, chat 45, api 10, email 3, dashboard 29, implied 16, manual 6, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | UK-origin flight (LHR?YYZ, AC-operated) cancelled due to uncontrollable reason (cancellation code WEAT � severe weather). Customer declined  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Alice Whitfield (Adult) | PNR: single passenger Alice Whitfield (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 849, LHR?YYZ | Journey: 1 leg AC operated, Flight AC 849, LHR?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Flight status: CANCELLED | Flight status: CANCELLED |
| CP005 | PREREQUISITES | prerequisite | seed | Cancellation code: WEAT (Severe weather � Uncontrollable / Extraordinary Circumstances) | Cancellation code: WEAT (Severe weather � Uncontrollable / Extraordinary Circumstances) |
| CP006 | PREREQUISITES | prerequisite | seed | Customer action: Remained at LHR, declined rebooking | Customer action: Remained at LHR, declined rebooking |
| CP007 | PREREQUISITES | prerequisite | seed | No Travel status: Origin | No Travel status: Origin |
| CP008 | PREREQUISITES | prerequisite | seed | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP009 | PREREQUISITES | prerequisite | seed | Regime: EU 261 (UK) | Regime: EU 261 (UK) |
| CP010 | PREREQUISITES | prerequisite | seed | Residence: UK ? GBP | Residence: UK ? GBP |
| CP011 | PREREQUISITES | prerequisite | seed | Aeroplan: NOT linked | Aeroplan: NOT linked |
| CP012 | PREREQUISITES | prerequisite | seed | Result: NOT ELIGIBLE � extraordinary circumstances, Article 5(3) | Result: NOT ELIGIBLE � extraordinary circumstances, Article 5(3) |
| CP013 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP014 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP015 | START | customer | chat | Then user selects English |  |
| CP016 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP017 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP018 | START | customer | chat | And the user says "My flight from London Heathrow to Toronto was cancelled due to severe weather and I didn't take any replacement flight. C | My flight from London Heathrow to Toronto was cancelled due to severe weather and I didn't take any replacement flight. Can I get compensation? |
| CP019 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP020 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP021 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP022 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP023 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Alice Whitfield" | Alice Whitfield |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Alice! And, what is your booking reference number? |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC099" | PNR: TC099 |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC099 |  |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP031 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: a***@gmail.com Phone: +44***789 |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: a***@gmail.com" | Email: a***@gmail.com |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP036 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP038 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP039 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP041 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Alice Whitfield (Adult) Is this who you'd like to include? |
| CP043 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP045 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 849 Route: London Heathrow (LHR) ? Toronto (YYZ) Date: May 25, 2026 Status: CANCELLED Is this the journey you'd like t |
| CP046 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP047 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure |  |
| CP051 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure was May 25, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED |  |
| CP052 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for EU 261 (UK) = 6 years ? within limitation ? PROCEED |  |
| CP053 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = LHR (UK) ? EU 261 (UK) |  |
| CP054 | REGIME DETERMINATION | system | implied | And the system checks: Customer did NOT travel ? No Travel Origin (remained at LHR) |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC099 | Cancellation � severe weather |
| CP058 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked for Not Eligible outcomes |  |
| CP059 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your flight AC 849 from London Heathrow (LHR) to Toronto (YYZ) on May 25, 2026 was cancelled. However, yo |
| CP060 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP061 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP062 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP063 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP064 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to a***@gmail.com |  |
| CP065 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (LHR?YYZ CANCELLED), not eligible reason (extraordinary circumstances � severe weathe |  |
| CP066 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP067 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP068 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Alice Whitfield" with PNR "TC099" |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation" |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Alice Whitfield" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC099" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "EU 261 (UK)" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Alice Whitfield" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "a***@gmail.com" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+44***789" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: LHR ? YYZ" with claim filed for this flight as cancelled |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Extraordinary circumstances � severe wea |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Cancellation Code should be "WEAT" as a 4-character Netline code indicating Uncontrollable |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And EU 261 Article 5(3) exemption should be applied |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the compensation should be "�0 / �0" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to extraordinary circumstances with cancellation code WEAT as Unc |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the No Travel status should be "Origin" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically and the result should be "No duplicate found" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent to "a***@gmail.com" containing extraordinary circumstances severe weather and EU |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP103 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to extraordinary circumstances severe weather |  |
| CP104 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP105 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP106 | PAYMENT VALIDATION | payment | chat | And no compensation amount should have been offered |  |
| CP107 | PAYMENT VALIDATION | payment | chat | And no Aeroplan or AC Wallet check should have occurred |  |
| CP108 | PAYMENT VALIDATION | payment | chat | And no payment method selection should have occurred |  |
| CP109 | PAYMENT VALIDATION | payment | chat | And no IDV Persona should have been required |  |
| CP110 | PAYMENT VALIDATION | payment | chat | And no CyberSource fraud screening should have occurred |  |
| CP111 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created in the backend |  |
| CP112 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP113 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP114 | EXPECTED RESULTS | verdict | api | DDS returns FD-EU-NE-07. | DDS returns FD-EU-NE-07. |
| CP115 | EXPECTED RESULTS | verdict | api | Trip Tracer: CANCELLED; MSL = Leg 1 (AC 849 LHR?YYZ); Cancellation Code = WEAT; No Travel = Origin (customer remained at LHR); Fallback = FA | Trip Tracer: CANCELLED; MSL = Leg 1 (AC 849 LHR?YYZ); Cancellation Code = WEAT; No Travel = Origin (customer remained at LHR); Fallback = FALSE; EU 261 (UK). |
| CP116 | EXPECTED RESULTS | verdict | chat | EU 261 Extraordinary Circumstances: Article 5(3) � airline exempt from compensation when disruption caused by extraordinary circumstances be | EU 261 Extraordinary Circumstances: Article 5(3) � airline exempt from compensation when disruption caused by extraordinary circumstances beyond its control. |
| CP117 | EXPECTED RESULTS | verdict | chat | Result: NOT ELIGIBLE, �0/�0. | Result: NOT ELIGIBLE, �0/�0. |
| CP118 | EXPECTED RESULTS | verdict | chat | CyberSource: NOT triggered. | CyberSource: NOT triggered. |
| CP119 | EXPECTED RESULTS | verdict | chat | IDV: NOT required. | IDV: NOT required. |
| CP120 | EXPECTED RESULTS | verdict | chat | Payment: NONE. | Payment: NONE. |
| CP121 | EXPECTED RESULTS | verdict | api | Claims Dashboard: EU-UK NE-07; NOT ELIGIBLE; Extraordinary Circumstances (WEAT); No Travel = Origin; Cancellation; DDS = FD-EU-NE-07. | Claims Dashboard: EU-UK NE-07; NOT ELIGIBLE; Extraordinary Circumstances (WEAT); No Travel = Origin; Cancellation; DDS = FD-EU-NE-07. |
