# FD_TC_163 · CHAI-31555 — checkpoints

**Goal:** Israel-destination multi-leg (YYZ?FRA?TLV). BOTH the MSL delay (2hrs on Leg 1) AND the final arrival delay (1.5hrs at TLV) are below the 8-hour ASL Travel Completed threshold (and also below the 3hr No Travel threshold). This is the simplest "below threshold" NE scenario � no ambiguity, no recovered delay, just insufficient delay everywhere. Paired with TC_146 (NE-22, where MSL was above 3hr but arrival was below 8hr) to show the distinction

Methods: seed 9, chat 35, api 12, email 3, dashboard 44, implied 16, manual 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Israel-destination multi-leg (YYZ?FRA?TLV). BOTH the MSL delay (2hrs on Leg 1) AND the final arrival delay (1.5hrs at TLV) are below the 8-h |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: single passenger Shai Benvenisti (Adult) | PNR: single passenger Shai Benvenisti (Adult) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 2 legs: Leg 1 AC 873 YYZ?FRA (delayed 2hrs, arrival delay code 42 � Not Extraordinary Circumstance); Leg 2 AC 9042 FRA?TLV (on time | Journey: 2 legs: Leg 1 AC 873 YYZ?FRA (delayed 2hrs, arrival delay code 42 � Not Extraordinary Circumstance); Leg 2 AC 9042 FRA?TLV (on time) |
| CP004 | PREREQUISITES | prerequisite | seed | Promise: Final arrival TLV = 18:00 | Promise: Final arrival TLV = 18:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual: Final arrival TLV = 19:30 (1.5hr delay) | Actual: Final arrival TLV = 19:30 (1.5hr delay) |
| CP006 | PREREQUISITES | prerequisite | seed | MSL: Leg 1 (2hr delay) | MSL: Leg 1 (2hr delay) |
| CP007 | PREREQUISITES | prerequisite | seed | Final destination delay: 1.5hrs | Final destination delay: 1.5hrs |
| CP008 | PREREQUISITES | prerequisite | seed | Both below 8hr ASL Travel Completed threshold (and also below 3hr) | Both below 8hr ASL Travel Completed threshold (and also below 3hr) |
| CP009 | PREREQUISITES | prerequisite | seed | Regime: ASL (Israel destination � TLV) + APPR | Regime: ASL (Israel destination � TLV) + APPR |
| CP010 | PREREQUISITES | prerequisite | seed | Result: NOT ELIGIBLE (both MSL and arrival delay below all applicable thresholds) | Result: NOT ELIGIBLE (both MSL and arrival delay below all applicable thresholds) |
| CP011 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP012 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP013 | START | customer | chat | Then user selects English |  |
| CP014 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP015 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP016 | START | customer | chat | And the user says "My flight from Toronto to Frankfurt was delayed about 2 hours and I arrived in Tel Aviv about an hour and a half late. Ca | My flight from Toronto to Frankfurt was delayed about 2 hours and I arrived in Tel Aviv about an hour and a half late. Can I get compensation under Israeli regu |
| CP017 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP018 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP019 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP020 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP021 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP022 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP023 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Shai Benvenisti" | Shai Benvenisti |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Shai! And, what is your booking reference number? |
| CP025 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC137" | PNR: TC137 |
| CP026 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC137 |  |
| CP027 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP028 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP029 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP030 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | Email: s***@gmail.com Phone: +1***234 |
| CP031 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: s***@gmail.com" | Email: s***@gmail.com |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP033 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP034 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP036 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP037 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP038 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP039 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP040 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: Shai Benvenisti (Adult) Is this who you'd like to include? |
| CP041 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP042 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP043 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: Segment 1: Flight AC 873, Toronto (YYZ) ? Frankfurt (FRA), June 9, 2026 � ARRIVED LATE (+2h) Segment 2: Flight AC 9042, Frankfurt |
| CP044 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments) |  |
| CP046 | SEGMENT CHECK (GenUC-18) | verdict | api | Then the chatbot identifies: Segment 1 ARRIVED LATE (MSL), Segment 2 ARRIVED ON TIME |  |
| CP047 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot determines: Final destination = TLV; Final arrival delay = 1.5h |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP049 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP051 | 72-HOUR CHECK | system | implied | And the system calculates: Arrival was June 9, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED |  |
| CP052 | CLAIM TIME LIMIT CHECK | verdict | api | Then the chatbot checks: Filing deadline for ASL = 1,460 days (4 years) from MSL scheduled departure date ? within limitation ? PROCEED |  |
| CP053 | REGIME DETERMINATION | system | implied | Then the system determines: Destination = TLV (Israel) ? ASL applies |  |
| CP054 | REGIME DETERMINATION | system | implied | And the system checks: Travel Completed ? ASL threshold = 8 hours ? 1.5hrs < 8hrs ? well below threshold |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: | Trip Tracer UI Validation |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | Then the tester opens Trip Tracer UI for PNR: TC137 | ? Segment 1: Flight: AC 873, Route: YYZ ? FRA, Scheduled Arrival: 08:00, Actual: 10:00, Delay: +2H 00M (MSL) ? Arrival Delay Code on Leg 1: 42 � numeric delay c |
| CP058 | FRAUD SCREENING � NOT TRIGGERED | system | implied | CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked |  |
| CP059 | NOT ELIGIBLE RESULT (FD-05b) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like your arrival in Tel Aviv was on time. That means there's no recorded delay for this part of your trip. Based |
| CP060 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP061 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP062 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP063 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP064 | NOTIFICATION | email | email | And a Not Eligible notification email is sent to s***@gmail.com |  |
| CP065 | NOTIFICATION | email | email | And the email contains: Case Reference, flight details (Seg 1: YYZ?FRA +2h MSL; Seg 2: FRA?TLV; Final arrival TLV +1h30m), not eligible reas |  |
| CP066 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP067 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP068 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Shai Benvenisti" with PNR "TC137" |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "Closed � Not Eligible" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Shai Benvenisti" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC137" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "ASL (Israel destination � TLV)" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Shai Benvenisti" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant" and "Adult" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "s***@gmail.com" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***234" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Segment 1: YYZ ? FRA" arrived late plus 2h as MSL and "Segment 2: FRA ? TLV" arrived on time |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the expected ancillary fees should be none |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Both MSL delay 2h AND final arrival dela |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to arrival delay 1.5h being less than 8h ASL Travel Completed thr |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Shai Benvenisti + TC137 + YYZ?TLV + FD" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource should NOT have been triggered as it only runs for eligible cases |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a not eligible notification email should have been sent via Adobe to "s***@gmail.com" containing arrival delay and MSL delay both below  |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the not eligible notification email chronologically |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Closed � Not Eligible" |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only |  |
| CP122 | PAYMENT VALIDATION | payment | chat | Given the eligibility result is "NOT ELIGIBLE" due to both MSL and final arrival delays below 8-hour ASL threshold |  |
| CP123 | PAYMENT VALIDATION | payment | chat | Then no payment flow should be triggered |  |
| CP124 | PAYMENT VALIDATION | payment | chat | And no country of residence should have been asked |  |
| CP125 | PAYMENT VALIDATION | payment | chat | And no compensation record should have been created |  |
| CP126 | PAYMENT VALIDATION | payment | manual | And no batch file should have been dispatched |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP128 | EXPECTED RESULTS | verdict | api | DDS returns FD-ASL-NE-23. | DDS returns FD-ASL-NE-23. |
| CP129 | EXPECTED RESULTS | verdict | api | Trip Tracer: Leg 1 = Delayed 2hrs (Arrival Delay Code 42, Not Extraordinary Circumstance / Controllable); Leg 2 = On time; MSL = Leg 1 (2hr  | Trip Tracer: Leg 1 = Delayed 2hrs (Arrival Delay Code 42, Not Extraordinary Circumstance / Controllable); Leg 2 = On time; MSL = Leg 1 (2hr delay); Final arriva |
| CP130 | EXPECTED RESULTS | verdict | api | Both delays below ALL thresholds: MSL delay 2hrs < 8hrs (ASL Travel Completed) and < 3hrs (No Travel/APPR/EU); Arrival delay 1.5hrs < 8hrs a | Both delays below ALL thresholds: MSL delay 2hrs < 8hrs (ASL Travel Completed) and < 3hrs (No Travel/APPR/EU); Arrival delay 1.5hrs < 8hrs and < 3hrs ? NE under |
