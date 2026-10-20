# FD_TC_182 · CHAI-31574 — checkpoints

**Goal:** Customer's flight was voluntarily changed via the Volantio tool (identifier: SK VOLY in PNR history). Since Volantio is a VOL tool, the promise updates to the new arrival. Flight operates on time � no disruption. Validates Volantio classification as VOL.

Methods: seed 1, chat 39, api 16, email 3, dashboard 37, implied 13, manual 7, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer's flight was voluntarily changed via the Volantio tool (identifier: SK VOLY in PNR history). Since Volantio is a VOL tool, the prom |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (Brigitte Lavoie); 1 leg AC YUL?YYZ; Original (14-day) arrival: 09:00; Volantio change at D-6: new arrival 12:00; Flig | PNR: Single passenger (Brigitte Lavoie); 1 leg AC YUL?YYZ; Original (14-day) arrival: 09:00; Volantio change at D-6: new arrival 12:00; Flight operates on time; |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "My flight from Montreal to Toronto was changed and I arrived later than originally planned. Can I get compensation?" | My flight from Montreal to Toronto was changed and I arrived later than originally planned. Can I get compensation? |
| CP009 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP011 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP012 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP013 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP014 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP015 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Brigitte Lavoie" | Brigitte Lavoie |
| CP016 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Brigitte! And, what is your booking reference number? |
| CP017 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TCVOL02" | PNR: TCVOL02 |
| CP018 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TCVOL02 |  |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP022 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: b***@gmail.com � Phone: +1***345 |
| CP023 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: b***@gmail.com" | Email: b***@gmail.com |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP025 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP026 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP027 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP028 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP029 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP030 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP031 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP032 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Brigitte Lavoie (Adult) Is this who you'd like to include? |
| CP033 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP034 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP035 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 403 � Route: Montreal (YUL) ? Toronto (YYZ) � Date: June 10, 2026 � Scheduled Arrival: 12:00 � Actual Arrival: 12:00 |
| CP036 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP037 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP038 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP039 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP040 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP041 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YUL (Canada) ? APPR |  |
| CP042 | TRIAGE & DDS EVALUATION � VOL CHANGE DETECTED | verdict | api | Then the DDS evaluation is done in backend |  |
| CP043 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Flight: AC 403, Route: YUL ? YYZ, Scheduled Arrival: 12:00 (updated by Volantio VOL) | Promised Itinerary - Flight: AC 403, Route: YUL ? YYZ, Scheduled Arrival: 12:00 (updated by Volantio VOL) |
| CP044 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Flight: AC 403, Route: YUL ? YYZ, Status: ON TIME, Actual: 12:00 | Current Itinerary - Flight: AC 403, Route: YUL ? YYZ, Status: ON TIME, Actual: 12:00 |
| CP045 | TRIP TRACER UI VALIDATION | verdict | api | Change 1: Volantio (SK VOLY) at D-6 � VOL � arrival 09:00 ? 12:00 | Change 1: Volantio (SK VOLY) at D-6 � VOL � arrival 09:00 ? 12:00 |
| CP046 | TRIP TRACER UI VALIDATION | verdict | api | Promise = 12:00 (updated by VOL) | Promise = 12:00 (updated by VOL) |
| CP047 | TRIP TRACER UI VALIDATION | verdict | api | Delay from promise = 0 hours | Delay from promise = 0 hours |
| CP048 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR | Regime: APPR |
| CP049 | TRIP TRACER UI VALIDATION | verdict | api | Result: NOT ELIGIBLE (no delay) | Result: NOT ELIGIBLE (no delay) |
| CP050 | TRIP TRACER UI VALIDATION | verdict | api | No MSL (no disruption) | No MSL (no disruption) |
| CP051 | TRIP TRACER UI VALIDATION | verdict | api | No disruption code (flight operated normally) | No disruption code (flight operated normally) |
| CP052 | TRIP TRACER UI VALIDATION | verdict | api | MS BRIGITTE LAVOIE / NOT ELIGIBLE / NO_DELAY_FROM_PROMISE / $0 | MS BRIGITTE LAVOIE / NOT ELIGIBLE / NO_DELAY_FROM_PROMISE / $0 |
| CP053 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP054 | NOT ELIGIBLE RESULT | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. Your flight AC 403 from Montreal (YUL) to Toronto (YYZ) arrived on time based on your current booking. Our records sho |
| CP055 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP056 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP057 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP058 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP059 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to b***@gmail.com |  |
| CP060 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (AC 403, YUL?YYZ, June 10, 2026), not eligible reason (no delay from updated schedule |  |
| CP061 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP062 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP063 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP064 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Brigitte Lavoie" with PNR "TCVOL02" |  |
| CP065 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Brigitte Lavoie" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TCVOL02" |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Brigitte Lavoie" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? YYZ" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility should be "NOT ELIGIBLE" with reason "No delay from promise (Volantio VOL updated promise; flight on time)" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the compensation should be $0 |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Change History should show Volantio SK VOLY as VOL with promise updated to 12:00 |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Promise should be 12:00 VOL-updated and the Actual should be 12:00 and the Delay should be 0hrs |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And VOL should have been detected via Volantio tool SK VOLY |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the promise should have been updated to VOL arrival 12:00 |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no delay should result in Not Eligible |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Brigitte Lavoie + TCVOL02 + YUL?YYZ + FD" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for ELIGIBLE cases |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe containing Case Reference and flight details and not eligible reason n |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record Volantio VOL detected SK VOLY and promise updated to 12:00 and no delay and not eligible |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP107 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to no delay from promise after Volantio VOL change |  |
| CP108 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP109 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP110 | PAYMENT VALIDATION | payment | chat | And no payment method should have been determined |  |
| CP111 | PAYMENT VALIDATION | payment | chat | And no compensation amount should have been calculated as it is $0 |  |
| CP112 | PAYMENT VALIDATION | payment | chat | And no IDV should have been triggered |  |
| CP113 | PAYMENT VALIDATION | payment | chat | And no CyberSource fraud screening should have been triggered as it only runs for eligible cases |  |
| CP114 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created in the backend |  |
| CP115 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched to Unifier |  |
| CP116 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show $0 with no delay from promise due to Volantio VOL change |  |
| CP117 | EXPECTED RESULTS | verdict | api | Tool: Volantio (SK VOLY); Classification: VOL; Promise: Updated from 09:00 to 12:00; Actual: 12:00; Delay from promise: 0hrs; Result: NOT EL | Tool: Volantio (SK VOLY); Classification: VOL; Promise: Updated from 09:00 to 12:00; Actual: 12:00; Delay from promise: 0hrs; Result: NOT ELIGIBLE; No disruptio |
