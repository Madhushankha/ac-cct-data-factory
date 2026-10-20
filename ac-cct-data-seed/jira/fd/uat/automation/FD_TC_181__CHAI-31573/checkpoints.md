# FD_TC_181 · CHAI-31573 — checkpoints

**Goal:** Customer's flight was voluntarily changed via the Pre-Move tool (identifier: RF-PMV or office ID YMQAC0848). Since this is a VOL change, the promise itinerary updates to the new VOL arrival. Flight operates on time per the VOL schedule � no disruption, no delay from promise. Validates that Pre-Move is correctly classified as VOL and that promise updates accordingly.

Methods: seed 1, chat 35, api 17, email 3, dashboard 27, implied 13, manual 3, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer's flight was voluntarily changed via the Pre-Move tool (identifier: RF-PMV or office ID YMQAC0848). Since this is a VOL change, the |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Andr� Pelletier); 1 leg AC YUL?YYZ; Original (14-day) arrival: 10:00; Pre-Move change at D-8: new arrival 14:00; Flig | PNR: Single passenger (Andr� Pelletier); 1 leg AC YUL?YYZ; Original (14-day) arrival: 10:00; Pre-Move change at D-8: new arrival 14:00; Flight operates on time  |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "My flight from Montreal to Toronto arrived later than my original booking. I'd like to check if I'm eligible for compensa | My flight from Montreal to Toronto arrived later than my original booking. I'd like to check if I'm eligible for compensation |
| CP009 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP011 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP012 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP013 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP014 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP015 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Andr� Pelletier" | Andr� Pelletier |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Andr�! And, what is your booking reference number? |
| CP017 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TCVOL01" | PNR: TCVOL01 |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TCVOL01 |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP022 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: a***@gmail.com � Phone: +1***234 |
| CP023 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: a***@gmail.com" | Email: a***@gmail.com |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP025 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP026 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP028 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP029 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP030 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP031 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP032 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Andr� Pelletier (Adult) Is this who you'd like to include? |
| CP033 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP034 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP035 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 401 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 10, 2026 � Scheduled Arrival: 14:00 � Actual Arrival: 14:00 |
| CP036 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP037 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP038 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP039 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP040 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP041 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YUL (Canada) ? APPR |  |
| CP042 | TRIAGE & DDS EVALUATION � VOL CHANGE DETECTED | verdict | api | Then the DDS evaluation is done in backend |  |
| CP043 | TRIAGE & DDS EVALUATION � VOL CHANGE DETECTED | verdict | api | And DDS checks booking change history: | ? Change 1 (D-8): Pre-Move tool (identifier: RF-PMV / office ID: YMQAC0848) ? Classification: VOL (Pre-Move is always voluntary � proactive schedule optimizatio |
| CP044 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 401, Route: YUL ? YYZ, Scheduled Arrival: 14:00 (updated by Pre-Move VOL) | Promised Itinerary - Flight: AC 401, Route: YUL ? YYZ, Scheduled Arrival: 14:00 (updated by Pre-Move VOL) |
| CP045 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 401, Route: YUL ? YYZ, Status: ON TIME, Actual: 14:00 | Current Itinerary - Flight: AC 401, Route: YUL ? YYZ, Status: ON TIME, Actual: 14:00 |
| CP046 | TRIP TRACER UI VALIDATION | verdict | api | Change 1: Pre-Move (RF-PMV / YMQAC0848) at D-8 � VOL � arrival 10:00 ? 14:00 | Change 1: Pre-Move (RF-PMV / YMQAC0848) at D-8 � VOL � arrival 10:00 ? 14:00 |
| CP047 | TRIP TRACER UI VALIDATION | verdict | api | Promise = 14:00 (updated by VOL) | Promise = 14:00 (updated by VOL) |
| CP048 | TRIP TRACER UI VALIDATION | verdict | api | Delay from promise = 0 hours | Delay from promise = 0 hours |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR | Regime: APPR |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | Result: NOT ELIGIBLE (no delay) | Result: NOT ELIGIBLE (no delay) |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | No MSL (no disruption) | No MSL (no disruption) |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | No disruption code (flight operated normally) | No disruption code (flight operated normally) |
| CP053 | TRIP TRACER UI VALIDATION | verdict | api | MR ANDR� PELLETIER / NOT ELIGIBLE / NO_DELAY_FROM_PROMISE / $0 | MR ANDR� PELLETIER / NOT ELIGIBLE / NO_DELAY_FROM_PROMISE / $0 |
| CP054 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP055 | NOT ELIGIBLE RESULT | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. Your flight AC 401 from Montreal (YUL) to Toronto (YYZ) arrived on time based on your current booking. Our records sho |
| CP056 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP057 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP058 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP059 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP060 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to a***@gmail.com |  |
| CP061 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details, not eligible reason (no delay from updated schedule), contact information |  |
| CP062 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP063 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP064 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP065 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Andr� Pelletier" with PNR "TCVOL01" |  |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Andr� Pelletier" |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TCVOL01" |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Andr� Pelletier" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility should be "NOT ELIGIBLE" with reason "No delay from promise (VOL change updated promise; flight on time)" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the compensation should be $0 |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Change History should show Pre-Move RF-PMV or YMQAC0848 as VOL with promise updated to 14:00 |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Promise should be 14:00 VOL-updated and the Actual should be 14:00 and the Delay should be 0hrs |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And VOL should have been detected via Pre-Move tool |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the promise should have been updated to VOL arrival |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no delay should result in Not Eligible |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically and the result should be "No duplicate found" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification should have been sent containing no delay from updated schedule |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP094 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to no delay from promise after VOL change |  |
| CP095 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP096 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP097 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP098 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP099 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation should show $0 |  |
| CP100 | EXPECTED RESULTS | verdict | api | Tool: Pre-Move (RF-PMV / YMQAC0848); Classification: VOL; Promise: Updated from 10:00 to 14:00; Actual: 14:00; Delay from promise: 0hrs; Res | Tool: Pre-Move (RF-PMV / YMQAC0848); Classification: VOL; Promise: Updated from 10:00 to 14:00; Actual: 14:00; Delay from promise: 0hrs; Result: NOT ELIGIBLE; N |
