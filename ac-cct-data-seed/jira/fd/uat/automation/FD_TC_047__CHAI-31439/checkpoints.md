# FD_TC_047 · CHAI-31439 — checkpoints

**Goal:** Validates an all-OAL itinerary operated by a Star Alliance partner (United Airlines) where the original flight is involuntarily cancelled due to Code TECH(Aircraft Technical Issue) - DMT (Upline Safety) and rebooked onto a later flight, resulting in a 7-hour arrival delay at the final destination DEN (6�<9h delay band). Passenger holds Aeroplan Elite 35K status on an Air Canada issued ticket (014- ticket stock). Validates that: (1) DDS scans all legs and confirms zero AC-operated segments exist on the itinerary, (2) Under APPR, the operating carrier (United Airlines) is responsible for disruption handling rather than the ticketing carrier (Air Canada), (3) Chatbot recognizes the Star Alliance partner and provides a direct redirect/guidance to United Airlines for claim processing, (4) Aeroplan Elite 35K profile status is recognized but does not override operating carrier liability rules, (5) Code TECH and all-OAL operation result in $0 Air Canada direct liability with no automated payout triggered.

Methods: seed 13, chat 47, api 8, dashboard 6, implied 14, manual 1, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates an all-OAL itinerary operated by a Star Alliance partner (United Airlines) where the original flight is involuntarily cancelled du |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC037 � single passenger Richard Clarke (Adult - Aeroplan Elite 35K) | PNR: TC037 � single passenger Richard Clarke (Adult - Aeroplan Elite 35K) |
| CP003 | PREREQUISITES | prerequisite | seed | Ticket stock: 014- (Air Canada issued ticket) | Ticket stock: 014- (Air Canada issued ticket) |
| CP004 | PREREQUISITES | prerequisite | seed | Journey: 1 leg, Original Flight UA 4521 (AC Codeshare AC 4521), Chicago (ORD) ? Denver (DEN) | Journey: 1 leg, Original Flight UA 4521 (AC Codeshare AC 4521), Chicago (ORD) ? Denver (DEN) |
| CP005 | PREREQUISITES | prerequisite | seed | Operating carrier: United Airlines (UA � Star Alliance partner) � NOT Air Canada | Operating carrier: United Airlines (UA � Star Alliance partner) � NOT Air Canada |
| CP006 | PREREQUISITES | prerequisite | seed | Disruption: Original flight cancelled at D-1 due to Code TECH(Aircraft Technical Issue)[DMT (Upline Safety)] | Disruption: Original flight cancelled at D-1 due to Code TECH(Aircraft Technical Issue)[DMT (Upline Safety)] |
| CP007 | PREREQUISITES | prerequisite | seed | Rebooking: INVOL rebooked by UA onto flight UA 4525, scheduled arrival 14:00 ? actual arrival 21:00 (7hr arrival delay at destination DEN, 6 | Rebooking: INVOL rebooked by UA onto flight UA 4525, scheduled arrival 14:00 ? actual arrival 21:00 (7hr arrival delay at destination DEN, 6�<9h band) |
| CP008 | PREREQUISITES | prerequisite | seed | Cancellation code: TECH(Aircraft Technical Issue)[DMT (Upline Safety � Star Alliance)] | Cancellation code: TECH(Aircraft Technical Issue)[DMT (Upline Safety � Star Alliance)] |
| CP009 | PREREQUISITES | prerequisite | seed | ALL legs on itinerary: OAL operated (zero AC operated segments) | ALL legs on itinerary: OAL operated (zero AC operated segments) |
| CP010 | PREREQUISITES | prerequisite | seed | Regime: APPR (Operating carrier rule applies) | Regime: APPR (Operating carrier rule applies) |
| CP011 | PREREQUISITES | prerequisite | seed | Aeroplan: Linked (9876543210), Status = Elite 35K, in good standing | Aeroplan: Linked (9876543210), Status = Elite 35K, in good standing |
| CP012 | PREREQUISITES | prerequisite | seed | 72hrs: Elapsed (filed D+10) | 72hrs: Elapsed (filed D+10) |
| CP013 | PREREQUISITES | prerequisite | seed | Time limit: Within 366 days | Time limit: Within 366 days |
| CP014 | PREREQUISITES | prerequisite | seed | No duplicate case | No duplicate case |
| CP015 | PREREQUISITES | prerequisite | implied | CyberSource: NOT invoked (not eligible case) | CyberSource: NOT invoked (not eligible case) |
| CP016 | PREREQUISITES | prerequisite | implied | RDS: No flags | RDS: No flags |
| CP017 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP018 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP019 | START | customer | chat | Then user selects English |  |
| CP020 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP021 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP022 | START | customer | chat | And the user says "My United Airlines flight booked through Air Canada was cancelled and rebooked, and I arrived 7 hours late. I am an Elite | My United Airlines flight booked through Air Canada was cancelled and rebooked, and I arrived 7 hours late. I am an Elite 35K member and want to check compensat |
| CP023 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP024 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP025 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP026 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Richard Clarke" | Richard Clarke |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Richard! And, what is your booking reference number? |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC037" | PNR: TC037 |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC037 |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: r***@gmail.com � Phone: +1***678 |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: r***@gmail.com" | Email: r***@gmail.com |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP042 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP043 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP044 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP045 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP046 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Richard Clarke (Adult - Aeroplan Elite 35K) Is this who you'd like to include? |
| CP047 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP049 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Original Flight: UA 4521 / AC 4521 (Cancelled) � Rebooked Flight: UA 4525 (Operated by United Airlines) � Route: Chicago (ORD)  |
| CP050 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP051 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP052 | MSL CHECK � ALL OAL | verdict | api | Then the system checks MSL for operating carrier on all segments |  |
| CP053 | MSL CHECK � ALL OAL | verdict | api | And MSL returns: ALL segments operated by United Airlines (UA � Star Alliance) ? NO AC-OPERATED LEGS |  |
| CP054 | MSL CHECK � ALL OAL | system | implied | And the system determines: ALL OAL ITINERARY ? REDIRECT TO OPERATING AIRLINE (UNITED AIRLINES) |  |
| CP055 | OAL REDIRECT RESULT | bot | chat | Then the chatbot displays: | I�ve reviewed your flight details and noticed that this trip was operated by our United Airlines partner. To complete your claim, I can forward your details to  |
| CP056 | OAL REDIRECT RESULT | customer | chat | And the user confirms "Yes" | Yes |
| CP057 | OAL REDIRECT RESULT | system | implied | Then chatbot checks whether the user is identified/authenticated ? Yes |  |
| CP058 | OAL REDIRECT RESULT | bot | chat | Then the chatbot asks: "Before I send your claim to manual review, please confirm the email address where you�d like to receive further info | Before I send your claim to manual review, please confirm the email address where you�d like to receive further information related to your claim.   Would you l |
| CP059 | OAL REDIRECT RESULT | customer | chat | And the user confirms "Yes, confirm this email" | Yes, confirm this email |
| CP060 | OAL REDIRECT RESULT | bot | chat | Then the chatbot asks: "To route you to the right support team, can you please share your country of residence?" | To route you to the right support team, can you please share your country of residence? |
| CP061 | OAL REDIRECT RESULT | system | implied | And the user responds:"Canada" |  |
| CP062 | OAL REDIRECT RESULT | bot | chat | Then the chatbot responds: "Perfect, share any additional relevant information to help me process your claim." | Perfect, share any additional relevant information to help me process your claim. |
| CP063 | OAL REDIRECT RESULT | system | implied | And the user uploads the Ticket |  |
| CP064 | OAL REDIRECT RESULT | customer | chat | And the user clicks on "Submit" button | Submit |
| CP065 | OAL REDIRECT RESULT | bot | chat | Then the chatbot responds: "Your claim has been submitted you should hear from a team member within ["30 days"]" | Your claim has been submitted you should hear from a team member within [ ] |
| CP066 | OAL REDIRECT RESULT | alert | chat | Then an alert information is displayed: "Please note that an ID verification process will be required if you are deemed eligible for payment | Please note that an ID verification process will be required if you are deemed eligible for payment. |
| CP067 | OAL REDIRECT RESULT | system | implied | Then the case is sent for manual handoff |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given MSL determined all segments are operated by United Airlines (Star Alliance) for PNR "TC037" |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the chatbot should have redirected the customer to contact United Airlines directly |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no DDS evaluation should have occurred |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no automated AC payment case should have been created |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the customer profile should record Aeroplan Elite 35K status and ticket stock 014- |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And when searching Claims Dashboard by PNR "TC037", the system should reflect OAL redirect status or no open AC liability case |  |
| CP074 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE / OAL OPERATED" for Air Canada payout |  |
| CP075 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP076 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP077 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP078 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP079 | PAYMENT VALIDATION | payment | chat | And AC Wallet should NOT be offered as Air Canada was not the operating carrier |  |
| CP080 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE (OAL Operated)" with no compensation record and no payout section |  |
| CP081 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-NE-05. | DDS returns FD-APPR-NE-05. |
| CP082 | EXPECTED RESULTS | verdict | api | Trip Tracer: MSL = Leg 1; Operating carrier = United Airlines (UA � Star Alliance); Cancellation Code = TECH(Aircraft Technical Issue)[DMT ( | Trip Tracer: MSL = Leg 1; Operating carrier = United Airlines (UA � Star Alliance); Cancellation Code = TECH(Aircraft Technical Issue)[DMT (Upline Safety)]; All |
| CP083 | EXPECTED RESULTS | verdict | chat | Operating Carrier Check: AC operated legs = 0 ? AC has no compensation liability ? NOT ELIGIBLE for AC payout. | Operating Carrier Check: AC operated legs = 0 ? AC has no compensation liability ? NOT ELIGIBLE for AC payout. |
| CP084 | EXPECTED RESULTS | verdict | chat | CRITICAL: AC ticket stock (014-) and Elite 35K status do NOT make AC responsible for OAL disruptions. | CRITICAL: AC ticket stock (014-) and Elite 35K status do NOT make AC responsible for OAL disruptions. |
| CP085 | EXPECTED RESULTS | verdict | chat | Operating carrier (United Airlines) bears APPR obligation. | Operating carrier (United Airlines) bears APPR obligation. |
| CP086 | EXPECTED RESULTS | verdict | chat | Customer Redirect: System provides helpful guidance directing customer to United Airlines. | Customer Redirect: System provides helpful guidance directing customer to United Airlines. |
| CP087 | EXPECTED RESULTS | verdict | chat | Compensation: $0 (from AC). | Compensation: $0 (from AC). |
| CP088 | EXPECTED RESULTS | verdict | chat | Fraud Screening: NOT INVOKED. | Fraud Screening: NOT INVOKED. |
| CP089 | EXPECTED RESULTS | verdict | chat | IDV: NOT REQUIRED. | IDV: NOT REQUIRED. |
| CP090 | EXPECTED RESULTS | verdict | chat | Payment: N/A. | Payment: N/A. |
