# FD_TC_158 · CHAI-31550 — checkpoints

**Goal:** Israel-originating flight (TLV?YYZ, AC-operated) cancelled due to extraordinary circumstance (cancellation code WEAT � severe weather). Customer remained at origin (TLV), did not travel. Under ASL, extraordinary circumstance = outside carrier's control = airline exempt from compensation.

Methods: seed 9, chat 39, api 12, email 3, dashboard 44, implied 16, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Israel-originating flight (TLV?YYZ, AC-operated) cancelled due to extraordinary circumstance (cancellation code WEAT � severe weather). Cust |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Amir Segal (Adult) | PNR: single passenger Amir Segal (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC operated, Flight AC 084, TLV?YYZ | Journey: 1 leg AC operated, Flight AC 084, TLV?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | Flight status: CANCELLED | Flight status: CANCELLED |
| CP005 | PREREQUISITES | prerequisite | seed | Cancellation code: WEAT (Severe weather � Extraordinary Circumstance) | Cancellation code: WEAT (Severe weather � Extraordinary Circumstance) |
| CP006 | PREREQUISITES | prerequisite | seed | Customer action: Stayed at TLV (origin), did NOT travel | Customer action: Stayed at TLV (origin), did NOT travel |
| CP007 | PREREQUISITES | prerequisite | seed | No Travel status: Origin | No Travel status: Origin |
| CP008 | PREREQUISITES | prerequisite | seed | Fallback: FALSE (cancellation code available) | Fallback: FALSE (cancellation code available) |
| CP009 | PREREQUISITES | prerequisite | seed | Regime: ASL (Israel origin � TLV) + APPR (Canadian destination � YYZ) | Regime: ASL (Israel origin � TLV) + APPR (Canadian destination � YYZ) |
| CP010 | PREREQUISITES | prerequisite | seed | Result: NOT ELIGIBLE (Extraordinary Circumstance � airline exempt) | Result: NOT ELIGIBLE (Extraordinary Circumstance � airline exempt) |
| CP011 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP012 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP013 | START | customer | chat | Then user selects English |  |
| CP014 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP015 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP016 | START | customer | chat | And the user says "My flight from Tel Aviv to Toronto was cancelled due to severe weather and I didn't take any replacement flight. Can I ge | My flight from Tel Aviv to Toronto was cancelled due to severe weather and I didn't take any replacement flight. Can I get compensation? |
| CP017 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP018 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP019 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP020 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Amir Segal" | Amir Segal |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Amir! And, what is your booking reference number? |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC125" | PNR: TC125 |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC125 |  |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: a***@gmail.com Phone: +972***789 |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: a***@gmail.com" | Email: a***@gmail.com |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP034 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP036 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP037 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP039 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Amir Segal (Adult) Is this who you'd like to include? |
| CP041 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP043 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Flight: AC 084 Route: Tel Aviv Ben Gurion (TLV) ? Toronto (YYZ) Date: May 25, 2026 Status: CANCELLED Is this the journey you'd li |
| CP044 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since scheduled departure |  |
| CP049 | 72-HOUR CHECK | system | implied | And the system calculates: Scheduled departure was May 25, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED |  |
| CP050 | CLAIM TIME LIMIT CHECK | verdict | api | Then the chatbot checks: Filing deadline for ASL = 1,460 days (4 years) from MSL scheduled departure date ? within limitation ? PROCEED |  |
| CP051 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = TLV (Israel) ? ASL applies (flights to AND from Israel) |  |
| CP052 | REGIME DETERMINATION | system | implied | And the system checks: Destination = YYZ (Canada) ? APPR also applies |  |
| CP053 | REGIME DETERMINATION | system | implied | And the system checks: Customer remained at origin (TLV) ? No Travel Origin |  |
| CP054 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC125 | Cancellation � severe weather |
| CP057 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP058 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've reviewed the details of your flight. I understand your flight AC 084 from Tel Aviv Ben Gurion (TLV) to Toronto (YYZ) on May 25, 2026 was cancelled. However |
| CP059 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP060 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP061 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP062 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP063 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to a***@gmail.com |  |
| CP064 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (TLV?YYZ CANCELLED), not eligible reason (Extraordinary Circumstance � severe weather |  |
| CP065 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP066 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP067 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Amir Segal" with PNR "TC125" |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation" |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Amir Segal" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC125" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL (Israel origin � TLV) + APPR" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Amir Segal" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "a***@gmail.com" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+972***789" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: TLV ? YYZ" with claim filed for this flight as cancelled |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Extraordinary Circumstance � severe weat |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to Extraordinary Circumstance with cancellation code WEAT and No  |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Amir Segal + TC125 + TLV?YYZ + FD" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe to "a***@gmail.com" containing Extraordinary Circumstance severe weath |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP121 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to Extraordinary Circumstance severe weather |  |
| CP122 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP123 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP124 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP125 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP126 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP127 | EXPECTED RESULTS | verdict | api | DDS returns FD-ASL-NE-08. | DDS returns FD-ASL-NE-08. |
| CP128 | EXPECTED RESULTS | verdict | api | Trip Tracer: Flight = CANCELLED; MSL = AC 084 TLV?YYZ; Cancellation Code = WEAT (4-char Netline code � Extraordinary Circumstance: AIRS, ARP | Trip Tracer: Flight = CANCELLED; MSL = AC 084 TLV?YYZ; Cancellation Code = WEAT (4-char Netline code � Extraordinary Circumstance: AIRS, ARPT, DAMA, INDU, POLI, |
| CP129 | EXPECTED RESULTS | verdict | chat | ASL: Extraordinary Circumstance ? airline exempt. | ASL: Extraordinary Circumstance ? airline exempt. |
| CP130 | EXPECTED RESULTS | verdict | api | Regime comparison: ASL = NE (Extraordinary Circumstance); APPR = NE (Uncontrollable); Both NE. | Regime comparison: ASL = NE (Extraordinary Circumstance); APPR = NE (Uncontrollable); Both NE. |
| CP131 | EXPECTED RESULTS | verdict | chat | Result: NOT ELIGIBLE, ILS 0. | Result: NOT ELIGIBLE, ILS 0. |
| CP132 | EXPECTED RESULTS | verdict | chat | CyberSource: NOT triggered. | CyberSource: NOT triggered. |
| CP133 | EXPECTED RESULTS | verdict | chat | Payment: NONE. | Payment: NONE. |
| CP134 | EXPECTED RESULTS | verdict | api | Claims Dashboard: ASL NE-08; NOT ELIGIBLE; Extraordinary Circumstance (WEAT); No Travel = Origin; Both regimes NE; DDS = FD-ASL-NE-08. | Claims Dashboard: ASL NE-08; NOT ELIGIBLE; Extraordinary Circumstance (WEAT); No Travel = Origin; Both regimes NE; DDS = FD-ASL-NE-08. |
