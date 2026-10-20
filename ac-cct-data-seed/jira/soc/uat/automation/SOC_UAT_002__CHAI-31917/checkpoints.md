# SOC_UAT_002 · CHAI-31917 — checkpoints

**Goal:** Verify that when a customer has an OAL employee standby/confirmed booking, the system returns NOT ELIGIBLE under APPR for SOC.

Methods: seed 17, chat 35, api 13, dashboard 38, implied 3, manual 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify that when a customer has an OAL employee standby/confirmed booking, the system returns NOT ELIGIBLE under APPR for SOC. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � LH 470 FRA?YYZ | � Itinerary: Single segment � LH 470 FRA?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): LH 470 FRA?YYZ | � SOC Segment (per SoC Flight Identifier): LH 470 FRA?YYZ |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: LH 470 FRA?YYZ, Dep: 01-Jun 10:00 | � Promised Itinerary: LH 470 FRA?YYZ, Dep: 01-Jun 10:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: LH 470 FRA?YYZ, Dep: 01-Jun 17:00 | � Actual Itinerary: LH 470 FRA?YYZ, Dep: 01-Jun 17:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 420 min (7 hours) | � Departure Delay: 420 min (7 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 64 (Flight Crew Shortage) � Controllable | � Departure delay code: 64 (Flight Crew Shortage) � Controllable |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Controllable (Code 64) | � Controllability: Controllable (Code 64) |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Type: Employee (OAL) | � Passenger Type: Employee (OAL) |
| CP011 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Employee ? NOT ELIGIBLE (no further checks) | � Check Order: 1. Pax Type ? Employee ? NOT ELIGIBLE (no further checks) |
| CP012 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult | � PAX Count: 1 adult |
| CP013 | PREREQUISITES | prerequisite | seed | � Class of Booking: PY | � Class of Booking: PY |
| CP014 | PREREQUISITES | prerequisite | seed | � Revenue Booking: NO � Employee booking | � Revenue Booking: NO � Employee booking |
| CP015 | PREREQUISITES | prerequisite | seed | � ACR Issued: N/A | � ACR Issued: N/A |
| CP016 | PREREQUISITES | prerequisite | seed | � Journey Completed: > 72h | � Journey Completed: > 72h |
| CP017 | PREREQUISITES | prerequisite | seed | � Employee Flow: Employee is NOT blocked upfront. Goes through OTP authentication first, then receives "Not Eligible" response | � Employee Flow: Employee is NOT blocked upfront. Goes through OTP authentication first, then receives "Not Eligible" response |
| CP018 | PREREQUISITES | prerequisite | seed | � Dispute Path: If disputed ? case created ? sent to manual handling | � Dispute Path: If disputed ? case created ? sent to manual handling |
| CP019 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP020 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP021 | START | customer | chat | Then user selects English |  |
| CP022 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP023 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP024 | START | customer | chat | And the user says "My flight was delayed for several hours and I had to buy food at the airport and book a hotel for the night. Can I get re | My flight was delayed for several hours and I had to buy food at the airport and book a hotel for the night. Can I get reimbursed for what I spent? |
| CP025 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP026 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP027 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP028 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP031 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP032 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP037 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP039 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP040 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP041 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP042 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP043 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: EMPLOYEE (non-revenue) | TYPE: EMPLOYEE (non-revenue) |
| CP044 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP045 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment trip FRA?YYZ on LH470 was delayed +7H 00M | Single-segment trip FRA?YYZ on LH470 was delayed +7H 00M |
| CP046 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 1 � SEGMENTS: 1 | PASSENGERS: 1 � SEGMENTS: 1 |
| CP047 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: LH 470, Route: FRA ? YYZ, Scheduled Dep: 01-Jun 10:00 | Promised Itinerary � Flight: LH 470, Route: FRA ? YYZ, Scheduled Dep: 01-Jun 10:00 |
| CP048 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: LH 470, Route: FRA ? YYZ, Status: ARRIVED LATE, Scheduled Dep: 10:00 ? Actual: 17:00, Delay: +7H 00M | Current Itinerary � Flight: LH 470, Route: FRA ? YYZ, Status: ARRIVED LATE, Scheduled Dep: 10:00 ? Actual: 17:00, Delay: +7H 00M |
| CP049 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present | SOC section present |
| CP050 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER: [First Name] [Last Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: �  | PASSENGER: [First Name] [Last Name] / STATUS: NOT_ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: � / ACCOMMODATION: � / GENERAL EXPENSES: � / EXPIRES: � |
| CP051 | TRIP TRACER UI VALIDATIONS | verdict | api | NOT_ELIGIBLE reason: Employee booking (OAL) | NOT_ELIGIBLE reason: Employee booking (OAL) |
| CP052 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: NOT ELIGIBLE |
| CP053 | NOT ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "I've reviewed the details of your flight. Unfortunately, your booking is classified as an OAL employee booking,  | I've reviewed the details of your flight. Unfortunately, your booking is classified as an OAL employee booking, which does not qualify for Standards of Care exp |
| CP054 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP055 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP056 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP057 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP058 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-NE-02 � OAL Employee Not Eligible |  |
| CP059 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP060 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP061 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP062 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP063 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP064 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP065 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (Auth Flow 1) |  |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is NOT greyed out |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant", "Adult", and "OAL Employee" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey LH 470 FRA ? YYZ as the claimed flight |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = LH 470 FRA ? YYZ |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is LH 470 |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is "OAL (Lufthansa)" |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Flight Crew Shortage (Code 64)" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 420 min (7 hours) |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travel Completed" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Employee (OAL)" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "Controllable" but employee check overrides |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "PY" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "NO � Employee booking" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-NE-02" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Check Order is: 1. Pax Type ? Employee ? NOT ELIGIBLE (no further checks) |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the same exclusion applies as NE-01 but for OAL employee instead of AC employee |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "N/A" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility on Claims Dashboard is "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP099 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-NE-02 � OAL Employee Not Eligible |  |
| CP100 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-NE-02 is determined as NOT ELIGIBLE |  |
| CP101 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP102 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP103 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP104 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP105 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP106 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP107 | EXPECTED RESULTS | verdict | chat | System correctly identifies OAL employee booking AFTER OTP authentication. | System correctly identifies OAL employee booking AFTER OTP authentication. |
| CP108 | EXPECTED RESULTS | verdict | chat | Returns SoC-APPR-NE-02. | Returns SoC-APPR-NE-02. |
| CP109 | EXPECTED RESULTS | verdict | chat | Displays NOT ELIGIBLE. | Displays NOT ELIGIBLE. |
| CP110 | EXPECTED RESULTS | verdict | chat | Offers dispute option � if disputed, case created and sent to manual handling. | Offers dispute option � if disputed, case created and sent to manual handling. |
| CP111 | EXPECTED RESULTS | verdict | chat | No receipt upload triggered. | No receipt upload triggered. |
