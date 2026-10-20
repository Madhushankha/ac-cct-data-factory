# SOC_UAT_076 · CHAI-31991 — checkpoints

**Goal:** Verify that when an emergency override is configured and the override status is Pending, the system holds the case until override is resolved.

Methods: seed 20, chat 46, api 25, email 1, dashboard 17, implied 21, manual 2, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify that when an emergency override is configured and the override status is Pending, the system holds the case until override is resolve |  |
| CP002 | PREREQUISITES | prerequisite | seed | Regime: ANY (Override applies across all regimes) | Regime: ANY (Override applies across all regimes) |
| CP003 | PREREQUISITES | prerequisite | seed | Carrier: AC (AC 301 YYZ?YVR) | Carrier: AC (AC 301 YYZ?YVR) |
| CP004 | PREREQUISITES | prerequisite | seed | Promised Itinerary: AC 301 YYZ?YVR, Dep: 25-Jun 08:00, Arr: 25-Jun 11:00 | Promised Itinerary: AC 301 YYZ?YVR, Dep: 25-Jun 08:00, Arr: 25-Jun 11:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual Itinerary: AC 301 YYZ?YVR, Dep: 25-Jun 14:00, Arr: 25-Jun 17:00 | Actual Itinerary: AC 301 YYZ?YVR, Dep: 25-Jun 14:00, Arr: 25-Jun 17:00 |
| CP006 | PREREQUISITES | prerequisite | seed | Delay Length: 360 min (6 hours) | Delay Length: 360 min (6 hours) |
| CP007 | PREREQUISITES | prerequisite | seed | Controllability: TBD | Controllability: TBD |
| CP008 | PREREQUISITES | prerequisite | seed | override pending | override pending |
| CP009 | PREREQUISITES | prerequisite | seed | Departure delay code: TBD | Departure delay code: TBD |
| CP010 | PREREQUISITES | prerequisite | seed | override pending | override pending |
| CP011 | PREREQUISITES | prerequisite | seed | Passenger Type: Regular | Passenger Type: Regular |
| CP012 | PREREQUISITES | prerequisite | seed | Check Order: 1. Override check ? ACTIVE ? PENDING (override takes precedence over all other checks) | Check Order: 1. Override check ? ACTIVE ? PENDING (override takes precedence over all other checks) |
| CP013 | PREREQUISITES | prerequisite | seed | Override Status: ACTIVE | Override Status: ACTIVE |
| CP014 | PREREQUISITES | prerequisite | seed | pending resolution | pending resolution |
| CP015 | PREREQUISITES | prerequisite | seed | Override Reason: Emergency event (e.g., system-wide disruption, mass cancellation, regulatory hold) | Override Reason: Emergency event (e.g., system-wide disruption, mass cancellation, regulatory hold) |
| CP016 | PREREQUISITES | prerequisite | seed | PAX Count: 1 adult | PAX Count: 1 adult |
| CP017 | PREREQUISITES | prerequisite | seed | Class of Booking: PY | Class of Booking: PY |
| CP018 | PREREQUISITES | prerequisite | seed | Revenue Booking: YES | Revenue Booking: YES |
| CP019 | PREREQUISITES | prerequisite | seed | ACR Issued: N/A (pending) | ACR Issued: N/A (pending) |
| CP020 | PREREQUISITES | prerequisite | seed | Journey Completed: > 72h | Journey Completed: > 72h |
| CP021 | PREREQUISITES | prerequisite | seed | Note: Override takes precedence over ALL normal DDS evaluation. Normal eligibility logic is suspended until override is resolved | Note: Override takes precedence over ALL normal DDS evaluation. Normal eligibility logic is suspended until override is resolved |
| CP022 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP023 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP024 | START | customer | chat | Then user selects English |  |
| CP025 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP026 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP027 | START | customer | chat | And the user says "My Air Canada flight from Toronto to Vancouver was delayed by about 7 hours because of bad weather. I had to buy food and | My Air Canada flight from Toronto to Vancouver was delayed by about 7 hours because of bad weather. I had to buy food and pay for a hotel. Can I get reimbursed? |
| CP028 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP029 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP030 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP031 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP032 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP033 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP034 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP035 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP036 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP037 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP040 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP042 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP043 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP044 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP045 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP046 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP047 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 301 � Route: Toronto (YYZ) ? Vancouver (YVR) � Date: June 1, 2026 � Departure Delay: 7 hours Is this the journey you |
| CP048 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP049 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP050 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP052 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP053 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP054 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR SOC per province |  |
| CP055 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Origin: YYZ (Ontario) ? Limitation = 730 days � Destination: YVR (British Columbia) ? Limitation = 1,095 days � Days elapsed: 8 days ? Within limitation perio |
| CP056 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP057 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP058 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected � DISPUTED ? OVERRIDE PENDING | Trip Completed, Disruption Detected � DISPUTED ? OVERRIDE PENDING |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip YYZ?YVR on AC301 was delayed +7H 00M due to weather (uncontrollable) | Single-segment trip YYZ?YVR on AC301 was delayed +7H 00M due to weather (uncontrollable) |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Regime: APPR | Regime: APPR |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 301, Route: YYZ ? YVR, Scheduled Dep: 25-Jun 08:00 | Promised Itinerary � Flight: AC 301, Route: YYZ ? YVR, Scheduled Dep: 25-Jun 08:00 |
| CP066 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 301, Route: YYZ ? YVR, Status: ARRIVED LATE, Scheduled Dep: 08:00 ? Actual: 14:00, Delay: +7H 00M (note: prer | Current Itinerary � Flight: AC 301, Route: YYZ ? YVR, Status: ARRIVED LATE, Scheduled Dep: 08:00 ? Actual: 14:00, Delay: +7H 00M (note: prereqs say 6h/360 min,  |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 77 (Weather) � Uncontrollable | Departure Delay Code: 77 (Weather) � Uncontrollable |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | Original DDS: SoC-APPR-NE-07 (NOT ELIGIBLE � weather) | Original DDS: SoC-APPR-NE-07 (NOT ELIGIBLE � weather) |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE (original) ? DISPUTED ? OVERRIDE PENDING | PASSENGER: [Name] / STATUS: NOT_ELIGIBLE (original) ? DISPUTED ? OVERRIDE PENDING |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | Dispute Flag: YES | Dispute Flag: YES |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | Override Status: PENDING � agent investigating delay code accuracy | Override Status: PENDING � agent investigating delay code accuracy |
| CP073 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: NOT triggered (not eligible / override pending) | CyberSource: NOT triggered (not eligible / override pending) |
| CP074 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: DISPUTED � Override Pending | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: DISPUTED � Override Pending |
| CP075 | TRIP TRACER UI VALIDATIONS | verdict | api | Case in manual handling queue � awaiting agent override decision | Case in manual handling queue � awaiting agent override decision |
| CP076 | TRIP TRACER UI VALIDATIONS | verdict | api | No payment initiated / No Welcome Back email sent | No payment initiated / No Welcome Back email sent |
| CP077 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-APPR-NE-07 | DDS RESPONSE CODE = SoC-APPR-NE-07 |
| CP078 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP079 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. Unfortunately, your flight AC 301 from Toronto to Vancouver was delaye | I've reviewed the details of your flight. Unfortunately, your flight AC 301 from Toronto to Vancouver was delayed due to weather conditions, which is classified |
| CP080 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP081 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Dispute" | Dispute |
| CP082 | DISPUTE FLOW � THIS IS THE KEY TEST | bot | chat | Then the chatbot responds: "We understand. Your dispute has been recorded and a case has been created for our team to review manually. You w | We understand. Your dispute has been recorded and a case has been created for our team to review manually. You will receive an update once our team has complete |
| CP083 | CASE CREATION WITH DISPUTE FLAG | system | implied | Then the system creates a case in Case Services |  |
| CP084 | CASE CREATION WITH DISPUTE FLAG | system | implied | And the case includes: | � DDS response code: SoC-APPR-NE-07 � Original eligibility: NOT ELIGIBLE � Dispute flag: YES � Dispute reason: Passenger disputes weather classification � Statu |
| CP085 | CASE CREATION WITH DISPUTE FLAG | system | implied | And the case is assigned to the manual handling queue (NOT fraud queue) |  |
| CP086 | CASE CREATION WITH DISPUTE FLAG | system | implied | And the case reference number is provided to the passenger |  |
| CP087 | CASE CREATION WITH DISPUTE FLAG | system | implied | Then the chatbot provides: | "Your dispute reference number is: [Case Number]. You will receive an email confirmation shortly." |
| CP088 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP089 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP090 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP091 | AGENT OVERRIDE FLOW � BEHIND THE SCENES | system | implied | When the agent opens the case in Claims Dashboard |  |
| CP092 | AGENT OVERRIDE FLOW � BEHIND THE SCENES | system | implied | Then the agent reviews: | � Original DDS determination: SoC-APPR-NE-07 (NOT ELIGIBLE � weather) � Passenger dispute: Claims weather classification is incorrect � Agent investigates: - Re |
| CP093 | OVERRIDE DECISION � PENDING | system | implied | Then the agent determines: Override decision is PENDING | � Agent needs additional information before making a decision � Agent may need to: - Contact operations team for clarification on Departure delay code - Review  |
| CP094 | OVERRIDE DECISION � PENDING | email | email | Then the agent updates the case: | Investigating Departure delay code accuracy. Awaiting operations team response. Your dispute is under review. We will update you once our investigation is compl |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-OVERRIDE-PENDING � Override Pending Disputed |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "In Review (Override Pending)" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is "Manual Handling" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant", "Adult", and "Disputed" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 301 YYZ ? YVR as the claimed flight |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (7 hours)" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Disruption Reason "Weather (Code 77)" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 420 min (7 hours) |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "UNCONTROLLABLE (Weather � Code 77)" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-NE-07" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Original Eligibility is "NOT ELIGIBLE" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute is "YES" |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Override Status is "PENDING" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Agent Action is "Investigating Departure delay code accuracy. Awaiting operations team response." |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "NOT PERFORMED (not eligible � no fraud check needed)" |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (pending override decision)" |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case Status is "In Review (Override Pending)" and the case is NOT in read-only mode |  |
| CP114 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-OVERRIDE-PENDING � Override Pending Disputed |  |
| CP115 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-OVERRIDE-PENDING has an override PENDING |  |
| CP116 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP117 | PAYMENT VALIDATION | payment | chat | And the route is AC 301 YYZ ? YVR with delay 420 min (7 hrs) and Weather (Code 77) |  |
| CP118 | PAYMENT VALIDATION | payment | chat | And the original DDS is SoC-APPR-NE-07 (NOT ELIGIBLE � weather, regular pax) |  |
| CP119 | PAYMENT VALIDATION | payment | chat | And the customer disputed and the case was created with dispute flag |  |
| CP120 | PAYMENT VALIDATION | payment | chat | And the agent is investigating and override status is PENDING |  |
| CP121 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP122 | PAYMENT VALIDATION | payment | chat | And no receipts are uploaded |  |
| CP123 | PAYMENT VALIDATION | payment | chat | And no CyberSource fraud check is triggered |  |
| CP124 | PAYMENT VALIDATION | payment | chat | And the case is held in override queue until agent resolves |  |
| CP125 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows "In Review (Override Pending)" with no payout section |  |
| CP126 | EXPECTED RESULTS | verdict | chat | SoC-Override-Pending. | SoC-Override-Pending. |
| CP127 | EXPECTED RESULTS | verdict | chat | PENDING. | PENDING. |
| CP128 | EXPECTED RESULTS | verdict | chat | Emergency override active. | Emergency override active. |
| CP129 | EXPECTED RESULTS | verdict | api | Normal DDS evaluation suspended. | Normal DDS evaluation suspended. |
| CP130 | EXPECTED RESULTS | verdict | chat | Shell case created and held in override queue. | Shell case created and held in override queue. |
| CP131 | EXPECTED RESULTS | verdict | chat | Passenger informed claim is being processed. | Passenger informed claim is being processed. |
| CP132 | EXPECTED RESULTS | verdict | chat | Case remains pending until override resolves to Pay or NoPay. | Case remains pending until override resolves to Pay or NoPay. |
| CP133 | EXPECTED RESULTS | verdict | chat | No receipt upload at this stage. | No receipt upload at this stage. |
