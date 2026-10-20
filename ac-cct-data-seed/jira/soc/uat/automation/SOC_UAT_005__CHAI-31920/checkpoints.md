# SOC_UAT_005 · CHAI-31920 — checkpoints

**Goal:** Verify that when the SOC segment is operated by an OAL carrier (no AC involvement on the disrupted segment), the system returns NOT ELIGIBLE and directs the customer to the operating airline.

Methods: seed 15, chat 36, api 18, dashboard 37, implied 11, manual 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify that when the SOC segment is operated by an OAL carrier (no AC involvement on the disrupted segment), the system returns NOT ELIGIBLE |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � UA 456 ORD?LAX | � Itinerary: Single segment � UA 456 ORD?LAX |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): UA 456 ORD?LAX (OAL only � AC has no data) | � SOC Segment (per SoC Flight Identifier): UA 456 ORD?LAX (OAL only � AC has no data) |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: UA 456 ORD?LAX, Dep: 02-Jun 10:00 | � Promised Itinerary: UA 456 ORD?LAX, Dep: 02-Jun 10:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: UA 456 ORD?LAX, Dep: 02-Jun 15:00 | � Actual Itinerary: UA 456 ORD?LAX, Dep: 02-Jun 15:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 300 min (5 hours) | � Departure Delay: 300 min (5 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: N/A � OAL only, AC has no departure delay code data | � Departure delay code: N/A � OAL only, AC has no departure delay code data |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: N/A � OAL only | � Controllability: N/A � OAL only |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP011 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Carrier check ? OAL only ? NOT ELIGIBLE (no AC involvement) | � Check Order: 1. Carrier check ? OAL only ? NOT ELIGIBLE (no AC involvement) |
| CP012 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult | � PAX Count: 1 adult |
| CP013 | PREREQUISITES | prerequisite | seed | � Class of Booking: PY | � Class of Booking: PY |
| CP014 | PREREQUISITES | prerequisite | seed | � Revenue Booking: YES | � Revenue Booking: YES |
| CP015 | PREREQUISITES | prerequisite | seed | � ACR Issued: N/A | � ACR Issued: N/A |
| CP016 | PREREQUISITES | prerequisite | seed | � Journey Completed: > 72h | � Journey Completed: > 72h |
| CP017 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP018 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP019 | START | customer | chat | Then user selects English |  |
| CP020 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP021 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP022 | START | customer | chat | And the user says "My flight was delayed for several hours and I had to buy food at the airport and book a hotel for the night. Can I get re | My flight was delayed for several hours and I had to buy food at the airport and book a hotel for the night. Can I get reimbursed for what I spent? |
| CP023 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP024 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP025 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP026 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP035 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP038 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP041 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP042 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: UA 456 � Route: Chicago(ORD) ? Los Angeles (LAX) � Date: June 2, 2026 � Departure Delay: 5 hours Is this the journey yo |
| CP043 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP044 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP045 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP047 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP050 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP051 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP052 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP053 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip ORD?LAX on UA456 was delayed +5H 00M � OAL operated | Single-segment trip ORD?LAX on UA456 was delayed +5H 00M � OAL operated |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: UA 456, Route: ORD ? LAX, Scheduled Dep: 02-Jun 10:00 | Promised Itinerary � Flight: UA 456, Route: ORD ? LAX, Scheduled Dep: 02-Jun 10:00 |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: UA 456, Route: ORD ? LAX, Status: ARRIVED LATE, Scheduled Dep: 10:00 ? Actual: 15:00, Delay: +5H 00M | Current Itinerary � Flight: UA 456, Route: ORD ? LAX, Status: ARRIVED LATE, Scheduled Dep: 10:00 ? Actual: 15:00, Delay: +5H 00M |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [First Name] [Last Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_2_TO_6_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / E | PASSENGER: [First Name] [Last Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_2_TO_6_HOURS / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | NOT_ELIGIBLE reason: OAL-operated segment � redirect to United Airlines | NOT_ELIGIBLE reason: OAL-operated segment � redirect to United Airlines |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | No case created (OAL redirect � passenger directed to operating carrier) | No case created (OAL redirect � passenger directed to operating carrier) |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-APPR-NE-05 | DDS RESPONSE CODE = SoC-APPR-NE-05 |
| CP065 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? OAL |  |
| CP066 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight, and we confirm that this flight was operated by United Airlines. Pleas | I've reviewed the details of your flight, and we confirm that this flight was operated by United Airlines. Please reach out to United Airlines directly for any  |
| CP067 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP068 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-NE-05 � OAL Only Not Eligible |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (Auth Flow 1) |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is NOT greyed out |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey UA 456 ORD ? LAX (OAL operated � no AC segments) |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = UA 456 ORD ? LAX |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is UA 456 |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is "OAL (United Airlines)" with no AC segments on itinerary |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "N/A (OAL � AC has no disruption data)" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 300 min (5 hours) |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travel Completed" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "N/A � OAL only" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-NE-05" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Check Order is: 1. Carrier check on SOC segment ? OAL only ? NOT ELIGIBLE (no AC involvement on the disrupted segment) |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the customer is redirected to contact United Airlines directly as AC cannot process OAL-only claims |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "N/A" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is not offered (OAL redirect � no dispute path) |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility on Claims Dashboard is "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP109 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-NE-05 � OAL Only Not Eligible |  |
| CP110 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-NE-05 is determined as NOT ELIGIBLE |  |
| CP111 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP112 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP113 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP114 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP115 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP116 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP117 | EXPECTED RESULTS | verdict | chat | SoC-APPR-NE-05. | SoC-APPR-NE-05. |
| CP118 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP119 | EXPECTED RESULTS | verdict | chat | OAL-only itinerary � no AC involvement. | OAL-only itinerary � no AC involvement. |
| CP120 | EXPECTED RESULTS | verdict | chat | Passenger redirected to operating carrier. | Passenger redirected to operating carrier. |
| CP121 | EXPECTED RESULTS | verdict | chat | No receipt upload. | No receipt upload. |
| CP122 | EXPECTED RESULTS | verdict | chat | No case creation. | No case creation. |
