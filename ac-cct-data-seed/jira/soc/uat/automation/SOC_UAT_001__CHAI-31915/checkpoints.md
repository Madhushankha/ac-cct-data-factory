# SOC_UAT_001 · CHAI-31915 — checkpoints

**Goal:** Verify that when a customer has an AC employee standby/confirmed booking, the system returns NOT ELIGIBLE under APPR for Standards of Care and displays the appropriate ineligibility messaging.

Methods: seed 19, chat 35, api 14, dashboard 50, implied 3, manual 6, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify that when a customer has an AC employee standby/confirmed booking, the system returns NOT ELIGIBLE under APPR for Standards of Care a |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 101 YYZ?YUL | � Itinerary: Single segment � AC 101 YYZ?YUL |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 101 YYZ?YUL | � SOC Segment (per SoC Flight Identifier): AC 101 YYZ?YUL |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 101 YYZ?YUL, Dep: 01-Jun 08:00 | � Promised Itinerary: AC 101 YYZ?YUL, Dep: 01-Jun 08:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 101 YYZ?YUL, Dep: 01-Jun 14:00 | � Actual Itinerary: AC 101 YYZ?YUL, Dep: 01-Jun 14:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 360 min (6 hours) | � Departure Delay: 360 min (6 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 64 (Flight Crew Shortage) � Controllable | � Departure delay code: 64 (Flight Crew Shortage) � Controllable |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Controllable (Code 64) | � Controllability: Controllable (Code 64) |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Type: Employee (AC) � office suffix ES/OT/EP/EE/EC | � Passenger Type: Employee (AC) � office suffix ES/OT/EP/EE/EC |
| CP011 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Employee ? NOT ELIGIBLE (no further checks) | � Check Order: 1. Pax Type ? Employee ? NOT ELIGIBLE (no further checks) |
| CP012 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult | � PAX Count: 1 adult |
| CP013 | PREREQUISITES | prerequisite | seed | � Class of Booking: PY | � Class of Booking: PY |
| CP014 | PREREQUISITES | prerequisite | seed | � Revenue Booking: NO � Employee booking | � Revenue Booking: NO � Employee booking |
| CP015 | PREREQUISITES | prerequisite | seed | � ACR Issued: N/A | � ACR Issued: N/A |
| CP016 | PREREQUISITES | prerequisite | seed | � Journey Completed: > 72h | � Journey Completed: > 72h |
| CP017 | PREREQUISITES | prerequisite | seed | � Employee Flow: Employee is NOT blocked upfront. Goes through OTP authentication first, then receives "Not Eligible" response | � Employee Flow: Employee is NOT blocked upfront. Goes through OTP authentication first, then receives "Not Eligible" response |
| CP018 | PREREQUISITES | prerequisite | seed | � Dispute Path: If disputed ? case created ? sent to manual handling | � Dispute Path: If disputed ? case created ? sent to manual handling |
| CP019 | PREREQUISITES | prerequisite | seed | � Policy: Not eligible under CCT (decided by Mohammed). Eligible for baggage claims only | � Policy: Not eligible under CCT (decided by Mohammed). Eligible for baggage claims only |
| CP020 | PREREQUISITES | prerequisite | seed | � Note on Exception Pax: If this were a J cabin exception/priority customer, a meal entitlement at J cabin rate would apply � but employee c | � Note on Exception Pax: If this were a J cabin exception/priority customer, a meal entitlement at J cabin rate would apply � but employee check overrides all e |
| CP021 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP022 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP023 | START | customer | chat | Then user selects English |  |
| CP024 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP025 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP026 | START | customer | chat | And the user says "My flight was delayed for several hours and I had to buy food at the airport and book a hotel for the night. Can I get re | My flight was delayed for several hours and I had to buy food at the airport and book a hotel for the night. Can I get reimbursed for what I spent? |
| CP027 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP028 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP029 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP030 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP031 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP032 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP033 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP034 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP035 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP036 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP040 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP041 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP042 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP043 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP044 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP045 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: EMPLOYEE (non-revenue) | TYPE: EMPLOYEE (non-revenue) |
| CP046 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP047 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment domestic trip YYZ?YUL on AC101 was delayed +6H 00M due to crew / FDP exceedance (controllable) | Single-segment domestic trip YYZ?YUL on AC101 was delayed +6H 00M due to crew / FDP exceedance (controllable) |
| CP048 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP049 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 101, Route: YYZ ? YUL, Scheduled Dep: 01-Jun 08:00 | Promised Itinerary � Flight: AC 101, Route: YYZ ? YUL, Scheduled Dep: 01-Jun 08:00 |
| CP050 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 101, Route: YYZ ? YUL, Status: ARRIVED LATE, Scheduled Dep: 08:00 ? Actual: 14:00, Delay: +6H 00M | Current Itinerary � Flight: AC 101, Route: YYZ ? YUL, Status: ARRIVED LATE, Scheduled Dep: 08:00 ? Actual: 14:00, Delay: +6H 00M |
| CP051 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP052 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [First Name] [Last Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: �  | PASSENGER: [First Name] [Last Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP053 | TRIP TRACER UI VALIDATIONS | verdict | api | NOT_ELIGIBLE reason: Employee booking | NOT_ELIGIBLE reason: Employee booking |
| CP054 | TRIP TRACER UI VALIDATIONS | verdict | api | Passenger Claims section present | Passenger Claims section present |
| CP055 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE (or no claim row if case not created) | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE (or no claim row if case not created) |
| CP056 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. Unfortunately, your booking is classified as an employee booking, whic | I've reviewed the details of your flight. Unfortunately, your booking is classified as an employee booking, which does not qualify for Standards of Care expense |
| CP057 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP058 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP059 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP060 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP061 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-NE-01 � AC Employee Not Eligible |  |
| CP062 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP063 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP064 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent can edit Topic/Sub-topic but cannot switch between automated and non-automated |  |
| CP065 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date is populated |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date is populated |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (identified + authenticated, Auth Flow 1) |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is NOT greyed out |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Adult" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date is populated |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID is populated |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source is populated |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID is populated |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant", "Adult", and "AC Employee" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address is populated |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status is populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 101 YYZ ? YUL as the claimed flight |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section is present with no entries |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 101 YYZ ? YUL |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 101 |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Flight Crew Shortage (Code 64)" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 360 min (6 hours) |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travel Completed" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Employee (AC)" with office suffix ES/OT/EP/EE/EC |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "Controllable (Code 64)" but employee check overrides before controllability is evaluated |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "NO � Employee booking" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-NE-01" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Check Order is: 1. Pax Type ? Employee ? NOT ELIGIBLE (no further checks) |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the employee is NOT blocked upfront � goes through OTP authentication first, then receives Not Eligible response |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached � not eligible)" |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "N/A" |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Auto-Append shows the system appended the booking record automatically |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Not Eligible notification is sent |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the notification email contains employee booking ineligibility and regulation reference (APPR) |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility on Claims Dashboard is "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent cannot access Case Search (leads/management only) |  |
| CP116 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-NE-01 � AC Employee Not Eligible |  |
| CP117 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-NE-01 is determined as NOT ELIGIBLE |  |
| CP118 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP119 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP120 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP121 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP122 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP123 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP124 | EXPECTED RESULTS | verdict | chat | System correctly identifies employee booking AFTER OTP authentication (not blocked at entry). | System correctly identifies employee booking AFTER OTP authentication (not blocked at entry). |
| CP125 | EXPECTED RESULTS | verdict | chat | Returns SoC-APPR-NE-01. | Returns SoC-APPR-NE-01. |
| CP126 | EXPECTED RESULTS | verdict | chat | Displays NOT ELIGIBLE. | Displays NOT ELIGIBLE. |
| CP127 | EXPECTED RESULTS | verdict | chat | Offers dispute option � if disputed, case created and sent to manual handling. | Offers dispute option � if disputed, case created and sent to manual handling. |
| CP128 | EXPECTED RESULTS | verdict | chat | No receipt upload triggered. | No receipt upload triggered. |
