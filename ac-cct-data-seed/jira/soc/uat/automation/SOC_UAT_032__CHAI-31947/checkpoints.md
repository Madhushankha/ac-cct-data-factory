# SOC_UAT_032 · CHAI-31947 — checkpoints

**Goal:** Verify NOT ELIGIBLE when claim submitted past EU limitation period.

Methods: seed 16, chat 37, api 2, dashboard 41, implied 14, manual 5, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify NOT ELIGIBLE when claim submitted past EU limitation period. |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: EU | � Regime: EU |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 835 BRU?YYZ | � Itinerary: Single segment � AC 835 BRU?YYZ |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 835 BRU?YYZ | � SOC Segment (per SoC Flight Identifier): AC 835 BRU?YYZ |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 835 BRU?YYZ, Dep: 15-Jan-2025 10:00 | � Promised Itinerary: AC 835 BRU?YYZ, Dep: 15-Jan-2025 10:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 835 BRU?YYZ, Dep: 15-Jan-2025 17:00 | � Actual Itinerary: AC 835 BRU?YYZ, Dep: 15-Jan-2025 17:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 420 min (7 hours) | � Departure Delay: 420 min (7 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 64 (Flight Crew Shortage) � Controllable (present in flight data but never evaluated � limitation check fails first) | � Departure delay code: 64 (Flight Crew Shortage) � Controllable (present in flight data but never evaluated � limitation check fails first) |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Controllable (Code 64) � NOT EVALUATED (limitation expired) | � Controllability: Controllable (Code 64) � NOT EVALUATED (limitation expired) |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Type: Regular | � Passenger Type: Regular |
| CP011 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Limitation period check ? EXPIRED ? NOT ELIGIBLE | � Check Order: 1. Limitation period check ? EXPIRED ? NOT ELIGIBLE |
| CP012 | PREREQUISITES | prerequisite | seed | � Claim Filing Date: Beyond EU limitation period | � Claim Filing Date: Beyond EU limitation period |
| CP013 | PREREQUISITES | prerequisite | seed | � Limitation Period: Belgium = 365 days (1 year) | � Limitation Period: Belgium = 365 days (1 year) |
| CP014 | PREREQUISITES | prerequisite | seed | � Disruption Date: January 15, 2025 | � Disruption Date: January 15, 2025 |
| CP015 | PREREQUISITES | prerequisite | seed | � Filing Date: June 8, 2026 | � Filing Date: June 8, 2026 |
| CP016 | PREREQUISITES | prerequisite | seed | � Days Elapsed: 509 days ? 509 > 365 ? EXPIRED | � Days Elapsed: 509 days ? 509 > 365 ? EXPIRED |
| CP017 | PREREQUISITES | prerequisite | seed | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h (well beyond) | � PAX Count: 1 adult / Class: PY / Revenue: YES / Journey: > 72h (well beyond) |
| CP018 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP019 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP020 | START | customer | chat | Then user selects English |  |
| CP021 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP022 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP023 | START | customer | chat | And the user says "I had a flight from Brussels to Toronto over a year ago that was delayed by about 7 hours. I had to buy food and pay for  | I had a flight from Brussels to Toronto over a year ago that was delayed by about 7 hours. I had to buy food and pay for a hotel. I never filed a claim and want |
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
| CP043 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 835 � Route: Brussels (BRU) ? Toronto (YYZ) � Date: January 15, 2025 � Departure Delay: 7 hours Is this the journey  |
| CP044 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP046 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP047 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP048 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP049 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes (well beyond � disruption was January  | CLAIM TIME LIMIT CHECK: ? FLOW STOPS HERE |
| CP050 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Filing deadline for EU SOC per departing country |  |
| CP051 | 72-HOUR CHECK | system | implied | And the system calculates: | � Departing country: Belgium � Belgium limitation period: 365 days (1 year) � Disruption date: January 15, 2025 � Filing date: June 8, 2026 � Days elapsed: 509  |
| CP052 | ? FLOW DOES NOT PROCEED TO | system | implied | ? Triage Eligibility Check (SoC-02b) � SKIPPED | ? Airline Company Routing � SKIPPED ? DDS Evaluation � SKIPPED ? Geographic origin check � SKIPPED (limitation expired first) ? Fraud Screening � SKIPPED ? Rece |
| CP053 | KEY EU DIFFERENCE � COUNTRY-BASED LIMITATION | system | implied | Unlike APPR (province-based) and ASL (fixed 1,460 days), EU limitation | varies by DEPARTING COUNTRY: - Belgium: 365 days (1 year) ? SHORTEST in EU - Italy: 730 days (2 years) - Portugal: 1,095 days (3 years) - Germany: 1,460 days (4 |
| CP054 | NOT ELIGIBLE RESULT | bot | chat | Then the chatbot displays: "Unfortunately, too much time has passed since your flight disruption to submit this claim. Your flight AC 835 fr | Unfortunately, too much time has passed since your flight disruption to submit this claim. Your flight AC 835 from Brussels to Toronto was disrupted on January  |
| CP055 | DISPUTE OPTION (GenUC-15) | bot | chat | Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?" | Do you agree with this assessment, or would you like to dispute it? |
| CP056 | DISPUTE OPTION (GenUC-15) | customer | chat | And the user selects "Agree" | Agree |
| CP057 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP058 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP059 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP060 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-EU-NE-08 � Limitation Expired Belgium Not Eligible |  |
| CP061 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP062 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP063 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Closed � Not Eligible" |  |
| CP064 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date and Last Updated date are populated |  |
| CP065 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP066 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP067 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP068 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Regular" |  |
| CP069 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP070 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP071 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "EU" |  |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name is populated |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags include "Claimant" and "Adult" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email is "t***@gmail.com" |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone is "+1***789" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 835 BRU ? YYZ as the claimed flight |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (7 hours)" |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 835 BRU ? YYZ |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 835 |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "N/A (not evaluated � limitation expired)" |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 420 min (7 hours) |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed)" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "Regular" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Limitation Period Check is "FAILED" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Departing country is "Belgium" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Limitation is "365 days (1 year) � shortest in EU" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption date is "January 15, 2025" |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Filing date is "June 8, 2026" |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Days elapsed is "509 days" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And 509 is greater than 365 so the limitation is EXPIRED |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "NOT EVALUATED (limitation expired)" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Geographic Check is "NOT EVALUATED (limitation expired)" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-EU-NE-08" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And unlike APPR (province-based) and ASL (fixed), EU limitation varies by departing country (Belgium 1yr, Germany 4yr, France 5yr, UK 6yr, S |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator SOC Expense Line Items is "N/A (not reached)" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource is NOT triggered |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Dispute option is offered (GenUC-15) |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user selected "Agree" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Closed � Not Eligible" |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP104 | PAYMENT VALIDATION | payment | manual | Scenario: Payment validation for SoC-EU-NE-08 � Limitation Expired Belgium Not Eligible |  |
| CP105 | PAYMENT VALIDATION | payment | chat | Given the case SoC-EU-NE-08 is determined as NOT ELIGIBLE |  |
| CP106 | PAYMENT VALIDATION | payment | chat | Then no payment flow is triggered |  |
| CP107 | PAYMENT VALIDATION | payment | chat | And no country of residence is asked |  |
| CP108 | PAYMENT VALIDATION | payment | chat | And no compensation record is created |  |
| CP109 | PAYMENT VALIDATION | payment | manual | And no batch file is dispatched |  |
| CP110 | PAYMENT VALIDATION | payment | chat | And no receipt upload is triggered (SOC receipts only triggered for eligible cases) |  |
| CP111 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section |  |
| CP112 | EXPECTED RESULTS | verdict | chat | SoC-EU-NE-08. | SoC-EU-NE-08. |
| CP113 | EXPECTED RESULTS | verdict | chat | NOT ELIGIBLE. | NOT ELIGIBLE. |
| CP114 | EXPECTED RESULTS | verdict | chat | Claim outside EU limitation period. | Claim outside EU limitation period. |
| CP115 | EXPECTED RESULTS | verdict | chat | No receipt upload. | No receipt upload. |
| CP116 | EXPECTED RESULTS | verdict | chat | No case creation. | No case creation. |
