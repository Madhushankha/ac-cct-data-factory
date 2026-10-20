# SOC_UAT_003 · CHAI-31918 — checkpoints

**Goal:** Verify that when the customer was informed of the delay ?12 hours before scheduled departure, the system returns NOT ELIGIBLE under APPR.

Methods: seed 16, chat 36, api 16, dashboard 38, implied 11, manual 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify that when the customer was informed of the delay ?12 hours before scheduled departure, the system returns NOT ELIGIBLE under APPR. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 201 YYZ?YVR | � Itinerary: Single segment � AC 201 YYZ?YVR |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 201 YYZ?YVR | � SOC Segment (per SoC Flight Identifier): AC 201 YYZ?YVR |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 201 YYZ?YVR, Dep: 05-Jun 14:00 | � Promised Itinerary: AC 201 YYZ?YVR, Dep: 05-Jun 14:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 201 YYZ?YVR, Dep: 06-Jun 08:00 | � Actual Itinerary: AC 201 YYZ?YVR, Dep: 06-Jun 08:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 1080 min (18 hours) | � Departure Delay: 1080 min (18 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 67 (Cabin Crew Shortage) � Controllable | � Departure delay code: 67 (Cabin Crew Shortage) � Controllable |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Controllable (Code 67) | � Controllability: Controllable (Code 67) |
| CP010 | PREREQUISITES | prerequisite | seed | � Notification Time: 15 hours before scheduled departure | � Notification Time: 15 hours before scheduled departure |
| CP011 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP012 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Regular ? ? 2. Notification check ? ?12h ? NOT ELIGIBLE | � Check Order: 1. Pax Type ? Regular ? ? 2. Notification check ? ?12h ? NOT ELIGIBLE |
| CP013 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult | � PAX Count: 1 adult |
| CP014 | PREREQUISITES | prerequisite | seed | � Class of Booking: PY | � Class of Booking: PY |
| CP015 | PREREQUISITES | prerequisite | seed | � Revenue Booking: YES | � Revenue Booking: YES |
| CP016 | PREREQUISITES | prerequisite | seed | � ACR Issued: N/A | � ACR Issued: N/A |
| CP017 | PREREQUISITES | prerequisite | seed | � Journey Completed: > 72h | � Journey Completed: > 72h |
| CP018 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP019 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP020 | START | customer | chat | Then user selects English |  |
| CP021 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP022 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP023 | START | customer | chat | And the user says "My flight was delayed for several hours and I had to buy food at the airport and book a hotel for the night. Can I get re | My flight was delayed for several hours and I had to buy food at the airport and book a hotel for the night. Can I get reimbursed for what I spent? |
| CP024 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP025 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP026 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP029 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP031 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP032 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP034 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP039 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP041 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP042 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP043 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 201 � Route: Toronto (YYZ) ? Vancouver (YVR) � Date: June 6, 2026 � Departure Delay: 18 hours Is this the journey yo |
| CP044 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP051 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP052 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP053 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP056 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment domestic trip YYZ?YVR on AC201 was delayed +18H 00M due to crew (controllable) | Single-segment domestic trip YYZ?YVR on AC201 was delayed +18H 00M due to crew (controllable) |
| CP057 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP058 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 201, Route: YYZ ? YVR, Scheduled Dep: 05-Jun 14:00 | Promised Itinerary � Flight: AC 201, Route: YYZ ? YVR, Scheduled Dep: 05-Jun 14:00 |
| CP059 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 201, Route: YYZ ? YVR, Status: ARRIVED LATE, Scheduled Dep: 14:00 ? Actual Dep: 06-Jun 08:00, Delay: +18H 00M | Current Itinerary � Flight: AC 201, Route: YYZ ? YVR, Status: ARRIVED LATE, Scheduled Dep: 14:00 ? Actual Dep: 06-Jun 08:00, Delay: +18H 00M |
| CP060 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP061 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [First Name] [Last Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: �  | PASSENGER: [First Name] [Last Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP062 | TRIP TRACER UI VALIDATIONS | verdict | api | NOT_ELIGIBLE reason: Notified ?12 hours before departure | NOT_ELIGIBLE reason: Notified ?12 hours before departure |
| CP063 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE |
| CP064 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP065 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. I understand your departure from Toronto was delayed by 18 hours. Howe | I've reviewed the details of your flight. I understand your departure from Toronto was delayed by 18 hours. However, you are not eligible for expense reimbursem |
| CP066 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP067 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-NE-03 � Notification ?12h Not Eligible |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (Auth Flow 1) |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is NOT greyed out |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 201 YYZ ? YVR as the claimed flight |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 201 YYZ ? YVR |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 201 |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Cabin Crew Shortage (Code 67)" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 1080 min (18 hours) |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travel Completed" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "Controllable (Code 67)" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Notification Time is "15 hours before scheduled departure" which is ?12h threshold |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-NE-03" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Check Order is: 1. Pax Type ? Regular ? ? 2. Notification check ? ?12h ? NOT ELIGIBLE |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the customer was informed of delay 15 hours before departure exceeding the 12-hour notification threshold making SOC not applicable |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "N/A" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is not offered (not shown in transcript for NE-03) |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility on Claims Dashboard is "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP109 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-NE-03 � Notification ?12h Not Eligible |  |
| CP110 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-NE-03 is determined as NOT ELIGIBLE |  |
| CP111 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP112 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP113 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP114 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP115 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP116 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP117 | EXPECTED RESULTS | verdict | chat | SoC-APPR-NE-03. | SoC-APPR-NE-03. |
| CP118 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP119 | EXPECTED RESULTS | verdict | chat | Passenger notified ?12 hours before departure. | Passenger notified ?12 hours before departure. |
| CP120 | EXPECTED RESULTS | verdict | chat | No receipt upload. | No receipt upload. |
| CP121 | EXPECTED RESULTS | verdict | chat | No case creation. | No case creation. |
| CP122 | EXPECTED RESULTS | verdict | chat | End flow. | End flow. |
