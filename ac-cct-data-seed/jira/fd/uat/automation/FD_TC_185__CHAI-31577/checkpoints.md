# FD_TC_185 · CHAI-31577 — checkpoints

**Goal:** Customer's ticket was changed via ATC (Amadeus Ticket Changes) transaction. ATC is classified as VOL. Promise updates to the new arrival. Flight operates on time � no disruption.

Methods: seed 1, chat 35, api 17, email 3, dashboard 31, implied 13, manual 6, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer's ticket was changed via ATC (Amadeus Ticket Changes) transaction. ATC is classified as VOL. Promise updates to the new arrival. Fl |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Philippe Boudreau); 1 leg AC YUL?YYZ; Original (14-day) arrival: 09:00; ATC change at D-5: new arrival 13:00; Flight  | PNR: Single passenger (Philippe Boudreau); 1 leg AC YUL?YYZ; Original (14-day) arrival: 09:00; ATC change at D-5: new arrival 13:00; Flight operates on time; Ac |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "My ticket was changed last week and I ended up on a later flight. Can I get compensation?" | My ticket was changed last week and I ended up on a later flight. Can I get compensation? |
| CP009 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP011 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP012 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP013 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP014 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP015 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Philippe Boudreau" | Philippe Boudreau |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Philippe! And, what is your booking reference number? |
| CP017 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TCVOL05" | PNR: TCVOL05 |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TCVOL05 |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP022 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: p***@gmail.com � Phone: +1***678 |
| CP023 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: p***@gmail.com" | Email: p***@gmail.com |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP025 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP026 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP028 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP029 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP030 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP031 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP032 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Philippe Boudreau (Adult) Is this who you'd like to include? |
| CP033 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP034 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP035 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 409 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 10, 2026 � Scheduled Arrival: 13:00 � Actual Arrival: 13:00 |
| CP036 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP037 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP038 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP039 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP040 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP041 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YUL (Canada) ? APPR |  |
| CP042 | TRIAGE & DDS EVALUATION � VOL CHANGE DETECTED | verdict | api | Then the DDS evaluation is done in backend |  |
| CP043 | TRIAGE & DDS EVALUATION � VOL CHANGE DETECTED | verdict | api | And DDS checks booking change history: | ? Change 1 (D-5): ATC (Amadeus Ticket Changes) transaction ? Identifier: ATC transaction in PNR history ? Classification: VOL (ATC = voluntary ticket reissue/ch |
| CP044 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 409, Route: YUL ? YYZ, Scheduled Arrival: 13:00 (updated by ATC VOL) | Promised Itinerary - Flight: AC 409, Route: YUL ? YYZ, Scheduled Arrival: 13:00 (updated by ATC VOL) |
| CP045 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 409, Route: YUL ? YYZ, Status: ON TIME, Actual: 13:00 | Current Itinerary - Flight: AC 409, Route: YUL ? YYZ, Status: ON TIME, Actual: 13:00 |
| CP046 | TRIP TRACER UI VALIDATION | verdict | api | Change 1: ATC (Amadeus Ticket Changes) at D-5 � VOL � arrival 09:00 ? 13:00 | Change 1: ATC (Amadeus Ticket Changes) at D-5 � VOL � arrival 09:00 ? 13:00 |
| CP047 | TRIP TRACER UI VALIDATION | verdict | api | Promise = 13:00 (updated by VOL) | Promise = 13:00 (updated by VOL) |
| CP048 | TRIP TRACER UI VALIDATION | verdict | api | Delay from promise = 0 hours | Delay from promise = 0 hours |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR | Regime: APPR |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | Result: NOT ELIGIBLE (no delay) | Result: NOT ELIGIBLE (no delay) |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | No MSL (no disruption) | No MSL (no disruption) |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | No disruption code (flight operated normally) | No disruption code (flight operated normally) |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | MR PHILIPPE BOUDREAU / NOT ELIGIBLE / NO_DELAY_FROM_PROMISE / $0 | MR PHILIPPE BOUDREAU / NOT ELIGIBLE / NO_DELAY_FROM_PROMISE / $0 |
| CP054 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP055 | NOT ELIGIBLE RESULT | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. Your flight AC 409 from Montreal (YUL) to Toronto (YYZ) arrived on time based on your current booking. Our records sho |
| CP056 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP057 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP058 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP059 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP060 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to p***@gmail.com |  |
| CP061 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (AC 409, YUL?YYZ, June 10, 2026), not eligible reason (no delay from updated schedule |  |
| CP062 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP063 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP064 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP065 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Philippe Boudreau" with PNR "TCVOL05" |  |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Philippe Boudreau" |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TCVOL05" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Philippe Boudreau" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility should be "NOT ELIGIBLE" with reason "No delay from promise (ATC VOL change updated promise; flight on time)" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the compensation should be $0 |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Change History should show ATC Amadeus Ticket Changes as VOL with promise updated to 13:00 |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Promise should be 13:00 VOL-updated and the Actual should be 13:00 and the Delay should be 0hrs |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And VOL should have been detected via ATC Amadeus Ticket Changes |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the promise should have been updated to VOL arrival 13:00 |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no delay should result in Not Eligible |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Philippe Boudreau + TCVOL05 + YUL?YYZ + FD" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for ELIGIBLE cases |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe containing Case Reference and flight details and not eligible reason n |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record ATC VOL detected and promise updated to 13:00 and no delay and not eligible |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP101 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to no delay from promise after ATC VOL change |  |
| CP102 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP103 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP104 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created in the backend |  |
| CP105 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched to Unifier |  |
| CP106 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show $0 with no delay from promise due to ATC VOL change |  |
| CP107 | EXPECTED RESULTS | verdict | api | Tool: ATC (Amadeus Ticket Changes); Classification: VOL; Promise: Updated from 09:00 to 13:00; Actual: 13:00; Delay: 0hrs; NOT ELIGIBLE; $0  | Tool: ATC (Amadeus Ticket Changes); Classification: VOL; Promise: Updated from 09:00 to 13:00; Actual: 13:00; Delay: 0hrs; NOT ELIGIBLE; $0 / |
