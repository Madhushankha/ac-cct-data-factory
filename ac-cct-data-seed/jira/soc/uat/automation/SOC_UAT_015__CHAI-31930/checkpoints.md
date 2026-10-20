# SOC_UAT_015 · CHAI-31930 — checkpoints

**Goal:** Verify that Priority/Exception passengers (Aeroplan 100K, Star Gold, UMNR, elderly 70+, accessibility SSR, DIV, SIXF) are eligible regardless of disruption type under APPR.

Methods: seed 24, chat 74, api 24, email 4, dashboard 68, implied 29, manual 5, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Verify that Priority/Exception passengers (Aeroplan 100K, Star Gold, UMNR, elderly 70+, accessibility SSR, DIV, SIXF) are eligible regardles |  |
| CP002 | PREREQUISITES | prerequisite | seed | � Regime: APPR | � Regime: APPR |
| CP003 | PREREQUISITES | prerequisite | seed | � Itinerary: Single segment � AC 301 YYZ?YVR | � Itinerary: Single segment � AC 301 YYZ?YVR |
| CP004 | PREREQUISITES | prerequisite | seed | � SOC Segment (per SoC Flight Identifier): AC 301 YYZ?YVR | � SOC Segment (per SoC Flight Identifier): AC 301 YYZ?YVR |
| CP005 | PREREQUISITES | prerequisite | seed | � Promised Itinerary: AC 301 YYZ?YVR, Dep: 12-Jun 08:00 | � Promised Itinerary: AC 301 YYZ?YVR, Dep: 12-Jun 08:00 |
| CP006 | PREREQUISITES | prerequisite | seed | � Actual Itinerary: AC 301 YYZ?YVR, Dep: 12-Jun 14:00 | � Actual Itinerary: AC 301 YYZ?YVR, Dep: 12-Jun 14:00 |
| CP007 | PREREQUISITES | prerequisite | seed | � Departure Delay: 360 min (6 hours) | � Departure Delay: 360 min (6 hours) |
| CP008 | PREREQUISITES | prerequisite | seed | � Departure delay code: 77 (Weather) � Uncontrollable � BUT IRRELEVANT for exception pax | � Departure delay code: 77 (Weather) � Uncontrollable � BUT IRRELEVANT for exception pax |
| CP009 | PREREQUISITES | prerequisite | seed | � Controllability: Uncontrollable (Code 77) � SKIPPED for exception pax | � Controllability: Uncontrollable (Code 77) � SKIPPED for exception pax |
| CP010 | PREREQUISITES | prerequisite | seed | � Passenger Type: Exception � Super Elite 50K | � Passenger Type: Exception � Super Elite 50K |
| CP011 | PREREQUISITES | prerequisite | seed | � Check Order: 1. Pax Type ? Super Elite 50K (EXCEPTION) ? Controllability SKIPPED ? ELIGIBLE | � Check Order: 1. Pax Type ? Super Elite 50K (EXCEPTION) ? Controllability SKIPPED ? ELIGIBLE |
| CP012 | PREREQUISITES | prerequisite | seed | � Exception Privilege: Extends to ALL passengers on same PNR | � Exception Privilege: Extends to ALL passengers on same PNR |
| CP013 | PREREQUISITES | prerequisite | seed | � PAX Count: 2 adults (Super Elite 50K + companion) | � PAX Count: 2 adults (Super Elite 50K + companion) |
| CP014 | PREREQUISITES | prerequisite | seed | � Class of Booking: J (Business) | � Class of Booking: J (Business) |
| CP015 | PREREQUISITES | prerequisite | seed | � Revenue Booking: YES | � Revenue Booking: YES |
| CP016 | PREREQUISITES | prerequisite | seed | � ACR Issued: Hotel: No, Transport: No, Meal: No | � ACR Issued: Hotel: No, Transport: No, Meal: No |
| CP017 | PREREQUISITES | prerequisite | seed | � Journey Completed: > 72h | � Journey Completed: > 72h |
| CP018 | PREREQUISITES | prerequisite | seed | � J CABIN MEAL NOTE: J cabin passengers receive meal entitlement at standard CCT rate ($30 for ). Business and economy currently have same C | � J CABIN MEAL NOTE: J cabin passengers receive meal entitlement at standard CCT rate ($30 for ). Business and economy currently have same CCT meal allowance |
| CP019 | PREREQUISITES | prerequisite | seed | � ENTITLEMENTS (, 2 adults, J class, no ACR): | � ENTITLEMENTS (, 2 adults, J class, no ACR): |
| CP020 | PREREQUISITES | prerequisite | seed | - Meals: $30/pax � 2 = $60 (J cabin � same CCT rate as economy currently) | - Meals: $30/pax � 2 = $60 (J cabin � same CCT rate as economy currently) |
| CP021 | PREREQUISITES | prerequisite | seed | - Hotel: Rate of day, 2 rooms (1 per adult), 3 nights max, $500 cap (if overnight) | - Hotel: Rate of day, 2 rooms (1 per adult), 3 nights max, $500 cap (if overnight) |
| CP022 | PREREQUISITES | prerequisite | seed | - Transport: $200 (1�5 pax) | - Transport: $200 (1�5 pax) |
| CP023 | PREREQUISITES | prerequisite | seed | - Communication: $30/pax � 2 = $60 | - Communication: $30/pax � 2 = $60 |
| CP024 | PREREQUISITES | prerequisite | seed | - Parking: $50, 1 day max | - Parking: $50, 1 day max |
| CP025 | PREREQUISITES | prerequisite | seed | - Essentials: $30/pax � 2 = $60 | - Essentials: $30/pax � 2 = $60 |
| CP026 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP027 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP028 | START | customer | chat | Then user selects English |  |
| CP029 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP030 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP031 | START | customer | chat | And the user says "My flight from Toronto to Vancouver was delayed by about 6 hours because of bad weather. I'm a Super Elite member and was | My flight from Toronto to Vancouver was delayed by about 6 hours because of bad weather. I'm a Super Elite member and was travelling with a companion. We had to |
| CP032 | START | system | implied | When the chatbot identifies Standards of Care (SoC) intent |  |
| CP033 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP034 | SOC ENTRY (SoC-01) | bot | chat | Then the chatbot displays the case opening legal disclaimer (GenUC-24): | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP035 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP036 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP037 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "[First Name] [Last Name]" | [First Name] [Last Name] |
| CP038 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, [First Name]! And, what is your booking reference number? |
| CP039 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: [PNR Code]" | PNR: [PNR Code] |
| CP040 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: [PNR Code] |  |
| CP041 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP042 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP043 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: t***@gmail.com � Phone: +1***789 |
| CP044 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: t***@gmail.com" | Email: t***@gmail.com |
| CP045 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP046 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "546879" | 546879 |
| CP047 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP048 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP049 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if this PNR a group booking ? No |  |
| CP050 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot checks if there are multiple PAX on PNR? ? Yes (2 passengers) |  |
| CP051 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP052 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 2 passengers on this booking: � [First Name] [Last Name] (Adult) � Super Elite 50K � Claimant � [Companion First Name] [Companion Last Name] (Adult) Is  |
| CP053 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes, both" | Yes, both |
| CP054 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 2 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP055 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 301 � Route: Toronto (YYZ) ? Vancouver (YVR) � Date: June 13, 2026 � Departure Delay: 6 hours Is this the journey yo |
| CP056 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP057 | JOURNEY SELECTION (GenUC-08) | system | implied | Then the chatbot checks if there are more than 1 segment ? No |  |
| CP058 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP059 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP060 | 72-HOUR CHECK | system | implied | Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes |  |
| CP061 | 72-HOUR CHECK | system | implied | Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes |  |
| CP062 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR SOC per province |  |
| CP063 | CLAIM TIME LIMIT CHECK | system | implied | And the system calculates: | � Origin: YYZ (Ontario) ? Limitation = 730 days � Destination: YVR (British Columbia) ? Limitation = 1,095 days � Days elapsed: Within limitation period ? PROCE |
| CP064 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks if there is triage data available? ? Yes |  |
| CP065 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP066 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates and sends to Trip Tracer UI: |  |
| CP067 | TRIP TRACER UI VALIDATIONS | verdict | api | PNR: [PNR Code] | PNR: [PNR Code] |
| CP068 | TRIP TRACER UI VALIDATIONS | verdict | api | TYPE: REVENUE | TYPE: REVENUE |
| CP069 | TRIP TRACER UI VALIDATIONS | verdict | api | Trip Completed, Disruption Detected | Trip Completed, Disruption Detected |
| CP070 | TRIP TRACER UI VALIDATIONS | verdict | api | Single-segment domestic trip YYZ?YVR on AC301 was delayed +6H 00M due to weather (uncontrollable � but IRRELEVANT for exception pax) | Single-segment domestic trip YYZ?YVR on AC301 was delayed +6H 00M due to weather (uncontrollable � but IRRELEVANT for exception pax) |
| CP071 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGERS: 2 (Super Elite 50K + companion) � SEGMENTS: 1 | PASSENGERS: 2 (Super Elite 50K + companion) � SEGMENTS: 1 |
| CP072 | TRIP TRACER UI VALIDATIONS | verdict | api | Class of Booking: J (Business) | Class of Booking: J (Business) |
| CP073 | TRIP TRACER UI VALIDATIONS | verdict | api | Promised Itinerary � Flight: AC 301, Route: YYZ ? YVR, Scheduled Dep: 12-Jun 08:00 | Promised Itinerary � Flight: AC 301, Route: YYZ ? YVR, Scheduled Dep: 12-Jun 08:00 |
| CP074 | TRIP TRACER UI VALIDATIONS | verdict | api | Current Itinerary � Flight: AC 301, Route: YYZ ? YVR, Status: ARRIVED LATE, Scheduled Dep: 08:00 ? Actual: 14:00, Delay: +6H 00M | Current Itinerary � Flight: AC 301, Route: YYZ ? YVR, Status: ARRIVED LATE, Scheduled Dep: 08:00 ? Actual: 14:00, Delay: +6H 00M |
| CP075 | TRIP TRACER UI VALIDATIONS | verdict | api | SOC section present � 2 passenger rows | SOC section present � 2 passenger rows |
| CP076 | TRIP TRACER UI VALIDATIONS | verdict | api | Departure Delay Code: 77 (Weather) � Uncontrollable (SKIPPED � exception pax) | Departure Delay Code: 77 (Weather) � Uncontrollable (SKIPPED � exception pax) |
| CP077 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER 1 (Adult � Super Elite 50K � Claimant): [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: $30.00 / ACCOMMODATION: Ra | PASSENGER 1 (Adult � Super Elite 50K � Claimant): [Name] / STATUS: ELIGIBLE / BAND: DELAY_6_HOURS_OR_MORE / MEAL: $30.00 / ACCOMMODATION: Rate of day (max $500) |
| CP078 | TRIP TRACER UI VALIDATIONS | verdict | api | PASSENGER 2 (Adult � Companion): [Name] / STATUS: ELIGIBLE (exception privilege extended) / same entitlements | PASSENGER 2 (Adult � Companion): [Name] / STATUS: ELIGIBLE (exception privilege extended) / same entitlements |
| CP079 | TRIP TRACER UI VALIDATIONS | verdict | api | Transportation (PNR-level): $200.00 (1�5 pax shared) | Transportation (PNR-level): $200.00 (1�5 pax shared) |
| CP080 | TRIP TRACER UI VALIDATIONS | verdict | api | Hotel: 2 rooms (1 per adult) | Hotel: 2 rooms (1 per adult) |
| CP081 | TRIP TRACER UI VALIDATIONS | verdict | api | CyberSource: GREEN | CyberSource: GREEN |
| CP082 | TRIP TRACER UI VALIDATIONS | verdict | api | CRITICAL: Exception pax ? controllability SKIPPED. Regular pax + weather = NE-07. Exception pax + weather = EL-07. | CRITICAL: Exception pax ? controllability SKIPPED. Regular pax + weather = NE-07. Exception pax + weather = EL-07. |
| CP083 | TRIP TRACER UI VALIDATIONS | verdict | api | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE | Intent: TRAVEL DISRUPTIONS / Sub-Intent: EXPENSES / Status: ELIGIBLE |
| CP084 | TRIP TRACER UI VALIDATIONS | verdict | api | Total Approved: $127.00 CAD (Meals $52 + Comm $40 + Essentials $35) | Total Approved: $127.00 CAD (Meals $52 + Comm $40 + Essentials $35) |
| CP085 | TRIP TRACER UI VALIDATIONS | verdict | api | DDS RESPONSE CODE = SoC-APPR-EL-07 | DDS RESPONSE CODE = SoC-APPR-EL-07 |
| CP086 | TRIP TRACER UI VALIDATIONS | verdict | api | Then the chatbot checks which airline company is it ? AC |  |
| CP087 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger) |  |
| CP088 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates the claim |  |
| CP089 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource returns: GREEN (no fraud indicators detected) | ? PROCEED to eligible flow |
| CP090 | ELIGIBLE RESULT (SoC-03b) | bot | chat | Then the chatbot displays: "Great news! Based on the details of your flight, both passengers on your booking are eligible for expense reimbu | Great news! Based on the details of your flight, both passengers on your booking are eligible for expense reimbursement. Your flight AC 301 from Toronto to Vanc |
| CP091 | ENTITLEMENT DISPLAY | bot | chat | Then the chatbot displays the eligible expense categories based on  delay, 2 adults, J class, no ACR: | Based on the length of your disruption (6 hours) and your party size (2 passengers), you may be eligible for reimbursement in the following categories: � Meals: |
| CP092 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | Then the chatbot responds: | To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption |
| CP093 | RECEIPT UPLOAD � WELCOME BACK FLOW | bot | chat | And the chatbot displays the receipt upload interface |  |
| CP094 | RECEIPT UPLOAD � WELCOME BACK FLOW | system | implied | And the user uploads receipt images: | � Receipt 1: Meal receipt � $52.00 CAD (dinner for 2 at airport restaurant) � Receipt 2: Communication � $40.00 CAD (Wi-Fi + phone calls for 2) � Receipt 3: Ess |
| CP095 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | Then the system processes uploaded receipts through OCR (Agentic Receipt Reader) |  |
| CP096 | RECEIPT READER � OCR VALIDATION (RR-01) | system | implied | And the OCR engine extracts line items from each receipt: | Receipt 1 � Meals: � Line item 1: Dinner (Person 1) � $28.00 CAD � Line item 2: Dinner (Person 2) � $24.00 CAD � Total meals: $52.00 CAD � Date: June 13, 2026 � |
| CP097 | RECEIPT VALIDATION SUMMARY | system | implied | Then the system displays the OCR validation summary: | � Total receipts processed: 3 � Total line items extracted: 6 � Items PASSED: 6 � Items FLAGGED for agent review: 0 � Items FAILED: 0 |
| CP098 | EXPENSE BREAKDOWN | system | implied | � Hotel: $0.00 (no receipt submitted) | � Meals: $52.00 ? (2 pax) � Transport: $0.00 (no receipt submitted) � Communication: $40.00 ? (2 pax) � Parking: $0.00 (no receipt submitted) � Essentials: $35. |
| CP099 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP100 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP101 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP102 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? Yes (Super Elite 50K) |  |
| CP103 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | And the system confirms SOC = CASH ONLY ? AC Wallet / e-credit NOT offered |  |
| CP104 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks if the claim is for multiple pax ? Yes (2 pax) |  |
| CP105 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $127.00 CAD compensation. Please note that it will take 5 to 10 business days to p | You are entitled to receive a $127.00 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP106 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP107 | CASH vs AC WALLET CHECK (FD-06b) | customer | chat | And user provides "Yes" | Yes |
| CP108 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac (CANADA) |  |
| CP109 | PAYMENT METHOD � INTERAC (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related  |
| CP110 | PAYMENT METHOD � INTERAC (FD-07) | customer | chat | And the user confirms "Yes, use this email" | Yes, use this email |
| CP111 | PAYMENT METHOD � INTERAC (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP112 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP113 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP114 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | When user clicks on the button |  |
| CP115 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP116 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP117 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP118 | IDENTITY VERIFICATION � PERSONA (FD-07b) | customer | chat | And the customer opens the Persona link |  |
| CP119 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And the customer completes identity verification via Persona |  |
| CP120 | IDENTITY VERIFICATION � PERSONA (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP121 | IDENTITY VERIFICATION � PERSONA (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP122 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $127.00 CAD Payment Method: t***@gmail.com After submission, you will receive a confirmation email summarizing your eligibility, claim details a |
| CP123 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP124 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user provides: "Yes" | Yes |
| CP125 | CASE CREATION (GLOB-09) | system | implied | Then the system creates a case in Case Services |  |
| CP126 | CASE CREATION (GLOB-09) | idv | chat | And the case includes: | � DDS response code: SoC-APPR-EL-07 � Eligibility: ELIGIBLE � Regime: APPR � Passengers: 2 adults (1 Super Elite 50K + 1 companion) � Exception privilege: Exten |
| CP127 | CASE CREATION (GLOB-09) | system | implied | And the case reference number is provided to the passenger |  |
| CP128 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: | Your claim has been submitted successfully for both passengers. Here's a summary: � Case Reference: [Case Number] � Total claim amount: $127.00 CAD � Categories |
| CP129 | NOTIFICATION | email | email | Then the system triggers notification via Adobe |  |
| CP130 | NOTIFICATION | email | email | And an eligible confirmation email is sent to the passenger at t***@gmail.com |  |
| CP131 | NOTIFICATION | email | email | And the email includes: | � Case reference number � Claim summary with approved amounts � Next steps for payment � Password required to access the secure payment link |
| CP132 | NOTIFICATION | email | email | And a separate email containing the secure Interac payment link is sent to t***@gmail.com |  |
| CP133 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything else I can help you with?" | Is there anything else I can help you with? |
| CP134 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP135 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP136 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Scenario: Claims Dashboard validation for SoC-APPR-EL-07 � Exception Super Elite 50K + Companion Eligible |  |
| CP137 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the agent opens the Claims Dashboard for the case |  |
| CP138 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Topic/Sub-topic is "Travel Disruptions � Expenses" |  |
| CP139 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent can edit Topic/Sub-topic but cannot switch between automated and non-automated |  |
| CP140 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Status is "Resolved" |  |
| CP141 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date is populated |  |
| CP142 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date is populated |  |
| CP143 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown is tracking correctly |  |
| CP144 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment is correct |  |
| CP145 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners are displayed (identified + authenticated, Auth Flow 1) |  |
| CP146 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel is NOT greyed out |  |
| CP147 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name is populated |  |
| CP148 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type is "Exception (Super Elite 50K)" |  |
| CP149 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication is "Pass" |  |
| CP150 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR is populated |  |
| CP151 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date is populated |  |
| CP152 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID is populated |  |
| CP153 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source is populated |  |
| CP154 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID is populated |  |
| CP155 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime is "APPR" |  |
| CP156 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Passenger 1 Full Name is populated with Tags "Claimant, Adult, Super Elite 50K" |  |
| CP157 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Passenger 1 Email is "t***@gmail.com" |  |
| CP158 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Passenger 1 Phone is "+1***789" |  |
| CP159 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Passenger 1 Address is populated |  |
| CP160 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Passenger 1 Tier Status is "Super Elite 50K" |  |
| CP161 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Passenger 2 Full Name is populated with Tags "Adult, Companion" |  |
| CP162 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Passenger 2 Exception Privilege is "CONFERRED from Passenger 1" |  |
| CP163 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Passenger 2 Tier Status is "Regular (privilege extended via exception rule)" |  |
| CP164 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Itinerary shows Journey AC 301 YYZ ? YVR as the claimed flight |  |
| CP165 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Status is "DELAYED (6 hours)" |  |
| CP166 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section is present with no entries |  |
| CP167 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility section shows Journey = AC 301 YYZ ? YVR |  |
| CP168 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Flight Leg at Fault is AC 301 |  |
| CP169 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier is AC |  |
| CP170 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Disruption Reason is "Weather (Code 77 � UNCONTROLLABLE but IRRELEVANT for exception pax)" |  |
| CP171 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Delay Minutes is 360 min (6 hours) |  |
| CP172 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Travel Status is "Travelled (delayed Departure)" |  |
| CP173 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Passenger Type is "EXCEPTION � Super Elite 50K" (checked FIRST) |  |
| CP174 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Controllability is "SKIPPED � exception passenger bypasses controllability check entirely" |  |
| CP175 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Exception Privilege Extended is "YES � companion receives same eligibility" |  |
| CP176 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Overnight Eligible is "Borderline (delay = 360 min, depends on ETD/Departure time)" |  |
| CP177 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Class of Booking is "J (Business)" |  |
| CP178 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Revenue Booking is "YES" |  |
| CP179 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the ACR Issued shows Hotel No, Transport No, Meal No |  |
| CP180 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Denied Boarding is "No" |  |
| CP181 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the DDS Response Code is "SoC-APPR-EL-07" |  |
| CP182 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Fraud Screening is "CyberSource GREEN" |  |
| CP183 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility is "ELIGIBLE (both passengers)" |  |
| CP184 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the same scenario with Regular pax would be SoC-APPR-NE-07 (NOT ELIGIBLE) because weather is uncontrollable but exception pax bypasses c |  |
| CP185 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Entitlements for 2 adults J class no ACR show Meals $30�2=$60, Hotel 2 rooms/$500 cap, Transport $200, Communication $30�2=$60, Park |  |
| CP186 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Hotel $0.00 No receipt submitted |  |
| CP187 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Meals $52.00 APPROVED (2 pax: $28 + $24, ?$60) |  |
| CP188 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Transport $0.00 No receipt submitted |  |
| CP189 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Communication $40.00 APPROVED (2 pax: Wi-Fi $25 + calls $15, ?$60) |  |
| CP190 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Parking $0.00 No receipt submitted |  |
| CP191 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Receipt Validator shows Essentials $35.00 APPROVED (2 pax: $18 + $17, ?$60) |  |
| CP192 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Total Approved is $127.00 CAD |  |
| CP193 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Items Flagged for Review is 0 |  |
| CP194 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Applicable Regimes SOC Amount is "$127.00 CAD (APPR � Suggested Highlighted)" |  |
| CP195 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check result is "No duplicate found" |  |
| CP196 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And CyberSource result is "GREEN" |  |
| CP197 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Auto-Append shows the system appended the booking record automatically |  |
| CP198 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligible confirmation email was sent to "t***@gmail.com" |  |
| CP199 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the email contains both passengers covered, $127.00 CAD, category breakdown, and Super Elite status noted |  |
| CP200 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Country of Residence is "Canada" with Currency "CAD" |  |
| CP201 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Method is "Interac e-Transfer" |  |
| CP202 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Payment Email is "t***@gmail.com" (claimant, single payee, locked) |  |
| CP203 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no bank details are stored on the case |  |
| CP204 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the IDV result is "Persona PASS (at Payment)" |  |
| CP205 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And AC Wallet / e-credit was NOT offered despite Aeroplan number on booking |  |
| CP206 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status is "Resolved" |  |
| CP207 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case is in read-only mode |  |
| CP208 | PAYMENT VALIDATION | payment | chat | Scenario: Payment validation for SoC-APPR-EL-07 � Exception Super Elite 50K + Companion Eligible |  |
| CP209 | PAYMENT VALIDATION | payment | chat | Given the case SoC-APPR-EL-07 is determined as ELIGIBLE |  |
| CP210 | PAYMENT VALIDATION | payment | chat | Then SOC payment is CASH ONLY |  |
| CP211 | PAYMENT VALIDATION | payment | chat | And AC Wallet / e-credit is NOT offered even though an Aeroplan number is on the booking |  |
| CP212 | PAYMENT VALIDATION | payment | chat | And the route is AC 301 YYZ ? YVR with delay 360 min (6 hrs) for 2 adults (SE50K + companion) J class |  |
| CP213 | PAYMENT VALIDATION | payment | chat | And exception pax controllability is SKIPPED so ELIGIBLE regardless |  |
| CP214 | PAYMENT VALIDATION | payment | chat | And the approved receipts are Meals $52, Comm $40, Essentials $35 totalling $127.00 CAD |  |
| CP215 | PAYMENT VALIDATION | payment | chat | And the country of residence is Canada with currency CAD |  |
| CP216 | PAYMENT VALIDATION | payment | chat | And the payment method is Interac e-Transfer to a single email t***@gmail.com |  |
| CP217 | PAYMENT VALIDATION | payment | chat | And only the customer's email is collected (no bank details) |  |
| CP218 | PAYMENT VALIDATION | payment | chat | And Persona IDV returned PASS before claim submission |  |
| CP219 | PAYMENT VALIDATION | payment | chat | And the Comp Status is "Sent for issuance" |  |
| CP220 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard shows $127.00 CAD, Cash, Interac, t***@gmail.com, status via talkback |  |
| CP221 | EXPECTED RESULTS | verdict | chat | SoC-APPR-EL-07. | SoC-APPR-EL-07. |
| CP222 | EXPECTED RESULTS | verdict | chat | ELIGIBLE. | ELIGIBLE. |
| CP223 | EXPECTED RESULTS | verdict | chat | Exception passenger (Super Elite 50K) recognized. | Exception passenger (Super Elite 50K) recognized. |
| CP224 | EXPECTED RESULTS | verdict | chat | Pax type checked FIRST � controllability SKIPPED entirely. | Pax type checked FIRST � controllability SKIPPED entirely. |
| CP225 | EXPECTED RESULTS | verdict | chat | Eligible regardless of disruption type (weather = uncontrollable, but irrelevant). | Eligible regardless of disruption type (weather = uncontrollable, but irrelevant). |
| CP226 | EXPECTED RESULTS | verdict | chat | Exception privilege extends to companion on same PNR. | Exception privilege extends to companion on same PNR. |
| CP227 | EXPECTED RESULTS | verdict | chat | Both passengers receive eligible status. | Both passengers receive eligible status. |
| CP228 | EXPECTED RESULTS | verdict | chat | Full receipt + case flow completes for entire party. | Full receipt + case flow completes for entire party. |
| CP229 | EXPECTED RESULTS | verdict | chat | Hotel: 2 rooms entitled. | Hotel: 2 rooms entitled. |
