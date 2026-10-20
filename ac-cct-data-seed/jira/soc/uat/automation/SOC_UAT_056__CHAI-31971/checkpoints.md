# SOC_UAT_056 · CHAI-31971 — checkpoints

**Goal:** Verify NOT ELIGIBLE when claim past 1460-day (4-year) ASL limit.

Methods: seed 17, chat 37, api 2, dashboard 37, implied 14, manual 4, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify NOT ELIGIBLE when claim past 1460-day (4-year) ASL limit. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: ASL | � Regime: ASL |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 084 TLV?VDA | � Itinerary: Single segment � AC 084 TLV?VDA |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 084 TLV?VDA | � SOC Segment (per SoC Flight Identifier): AC 084 TLV?VDA |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 084 YYZ?TLV, Dep: 01-Jan-2021 21:00 | � Promised Itinerary: AC 084 YYZ?TLV, Dep: 01-Jan-2021 21:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 084 YYZ?TLV, Dep: 02-Jan-2021 05:00 | � Actual Itinerary: AC 084 YYZ?TLV, Dep: 02-Jan-2021 05:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 480 min (8 hours) | � Departure Delay: 480 min (8 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 64 (Flight Crew Shortage) � Controllable (present in flight data but never evaluated � limitation check fails first) | � Departure delay code: 64 (Flight Crew Shortage) � Controllable (present in flight data but never evaluated � limitation check fails first) |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Controllable (Code 64) � NOT EVALUATED (limitation expired) | � Controllability: Controllable (Code 64) � NOT EVALUATED (limitation expired) |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP011 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Limitation period check ? >1460 days ? EXPIRED ? NOT ELIGIBLE | � Check Order: 1. Limitation period check ? >1460 days ? EXPIRED ? NOT ELIGIBLE |
| CP012 | PREREQUISITES | prerequisite | seed | � Note: ASL limitation period = 1460 days (4 years) � different from APPR and EU | � Note: ASL limitation period = 1460 days (4 years) � different from APPR and EU |
| CP013 | PREREQUISITES | prerequisite | seed | � Claim Filing Date: Beyond 1460 days from disruption | � Claim Filing Date: Beyond 1460 days from disruption |
| CP014 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult | � PAX Count: 1 adult |
| CP015 | PREREQUISITES | prerequisite | seed | � Class of Booking: PY | � Class of Booking: PY |
| CP016 | PREREQUISITES | prerequisite | seed | � Revenue Booking: YES | � Revenue Booking: YES |
| CP017 | PREREQUISITES | prerequisite | seed | � ACR Issued: N/A | � ACR Issued: N/A |
| CP018 | PREREQUISITES | prerequisite | seed | � Journey Completed: > 72h (well beyond) | � Journey Completed: > 72h (well beyond) |
| CP019 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP020 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP021 | START | customer | chat | Then user selects English |  |
| CP022 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP023 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP024 | START | customer | chat | And the user says "I had a flight from Tel Aviv to Eilat over 5 years ago that was delayed by about 7 hours. I had to buy food and pay for a | I had a flight from Tel Aviv to Eilat over 5 years ago that was delayed by about 7 hours. I had to buy food and pay for a hotel. I never filed a claim and want  |
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
| CP042 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP043 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? No |  |
| CP044 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 084 � Route: Tel Aviv (TLV) ? Eilat (VDA) � Date: March 1, 2022 � Departure Delay: 7 hours Is this the journey you'd |
| CP045 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP046 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP048 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes (well beyond � disruption was March 20 | CLAIM TIME LIMIT CHECK: ? FLOW STOPS HERE |
| CP051 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Filing deadline for ASL SOC |  |
| CP052 | 72-HOUR CHECK | system | implied | And the system calculates: | � ASL limitation: 1,460 days (4 years) � FIXED for all origins � Disruption date: March 1, 2022 � Filing date: June 9, 2026 � Days elapsed: 1,561 days � 1,561 > |
| CP053 | ? FLOW DOES NOT PROCEED TO | system | implied | ? Triage Eligibility Check (SoC-02b) � SKIPPED | ? Airline Company Routing � SKIPPED ? DDS Evaluation � SKIPPED ? Geographic check � SKIPPED (limitation expired first) ? Fraud Screening � SKIPPED ? Receipt Upl |
| CP054 | KEY ASL DIFFERENCE � FIXED LIMITATION | system | implied | Unlike APPR (province-based, 730/1095/2190 days) and EU (country-based, 365-3650 days), | ASL has a SINGLE fixed limitation period of 1,460 days (4 years) regardless of origin. This makes the ASL limitation check the simplest of all three regimes. DD |
| CP055 | NOT ELIGIBLE RESULT | bot | chat | Then the chatbot displays: "Unfortunately, too much time has passed since your flight disruption to submit this claim. Your flight AC 084 fr | Unfortunately, too much time has passed since your flight disruption to submit this claim. Your flight AC 084 from Tel Aviv to Eilat was disrupted on March 1, 2 |
| CP056 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP057 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP058 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP059 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP060 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP061 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-ASL-NE-08 � Limitation Expired ASL Not Eligible |  |
| CP062 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP063 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP064 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP065 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "ASL" |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 084 TLV ? VDA as the claimed flight |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (7 hours)" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 084 TLV ? VDA |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 084 |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "N/A (not evaluated � limitation expired)" |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 420 min (7 hours) |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Limitation Period Check is "FAILED" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the ASL limitation is "1,460 days (4 years) � FIXED for all origins" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption date is "March 1, 2022" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Filing date is "June 9, 2026" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Days elapsed is "1,561 days" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And 1,561 is greater than 1,460 so the limitation is EXPIRED |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT EVALUATED (limitation expired)" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "NOT EVALUATED (limitation expired)" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-ASL-NE-08" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And unlike APPR (province-based, 730/1095/2190 days) and EU (country-based, 365�3650 days), ASL has a SINGLE fixed limitation of 1,460 days  |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP100 | PAYMENT VALIDATION | payment | manual | Scenario: Payment validation for SoC-ASL-NE-08 � Limitation Expired ASL Not Eligible |  |
| CP101 | PAYMENT VALIDATION | payment | chat | Given the case SoC-ASL-NE-08 is determined as NOT ELIGIBLE |  |
| CP102 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP103 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP104 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP105 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP106 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP107 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP108 | EXPECTED RESULTS | verdict | chat | SoC-ASL-NE-08. | SoC-ASL-NE-08. |
| CP109 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP110 | EXPECTED RESULTS | verdict | chat | Claim outside ASL limitation period (>1460 days / 4 years). | Claim outside ASL limitation period (>1460 days / 4 years). |
| CP111 | EXPECTED RESULTS | verdict | chat | No receipt upload. | No receipt upload. |
| CP112 | EXPECTED RESULTS | verdict | chat | No case creation. | No case creation. |
