# FD_TC_209 · CHAI-31601 — checkpoints

**Goal:** Customer travels on an AC-ticketed itinerary where the disrupted leg is operated by PAL Airlines (interline partner). PAL is identified as the Most Significant Leg (MSL). PAL's disruption coding is known to be spotty/inconsistent � this test validates DDS behaviour in BOTH scenarios: (A) when PAL coding IS present and DDS can evaluate, and (B) when PAL coding is MISSING/incomplete and DDS cannot determine controllability. Confirms that when coding is absent, DDS correctly flags the case for agent review rather than auto-deciding. This is critical because spotty coding from PAL may result in missing disruption codes, missing delay reasons, or incomplete flight status data.

Methods: seed 11, chat 55, api 36, dashboard 23, implied 14, manual 1, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer travels on an AC-ticketed itinerary where the disrupted leg is operated by PAL Airlines (interline partner). PAL is identified as t |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: Single passenger (�lise Beaumont), multi-leg itinerary | PNR: Single passenger (�lise Beaumont), multi-leg itinerary |
| CP003 | PREREQUISITES | prerequisite | seed | Leg 1: AC 501 YUL?MNL (AC operated, no disruption) | Leg 1: AC 501 YUL?MNL (AC operated, no disruption) |
| CP004 | PREREQUISITES | prerequisite | seed | Leg 2: PAL 102 MNL?CEB (PAL operated, disrupted � 4hr delay) | Leg 2: PAL 102 MNL?CEB (PAL operated, disrupted � 4hr delay) |
| CP005 | PREREQUISITES | prerequisite | seed | Itinerary: Leg 2 scheduled arrival 14:00, Actual arrival 18:00 (4hr delay) | Itinerary: Leg 2 scheduled arrival 14:00, Actual arrival 18:00 (4hr delay) |
| CP006 | PREREQUISITES | prerequisite | seed | MSL: PAL 102 MNL?CEB (PAL is the operating carrier on the disrupted leg) | MSL: PAL 102 MNL?CEB (PAL is the operating carrier on the disrupted leg) |
| CP007 | PREREQUISITES | prerequisite | seed | Disruption code on PAL leg: TEST BOTH SCENARIOS � Scenario A: Code present (e.g., 42 equivalent); Scenario B: Code MISSING/NULL | Disruption code on PAL leg: TEST BOTH SCENARIOS � Scenario A: Code present (e.g., 42 equivalent); Scenario B: Code MISSING/NULL |
| CP008 | PREREQUISITES | prerequisite | seed | Booking changes: None | Booking changes: None |
| CP009 | PREREQUISITES | prerequisite | seed | Carrier: AC ticketing carrier, PAL operating carrier on disrupted leg | Carrier: AC ticketing carrier, PAL operating carrier on disrupted leg |
| CP010 | PREREQUISITES | prerequisite | seed | 72hrs: Elapsed | 72hrs: Elapsed |
| CP011 | PREREQUISITES | prerequisite | seed | Time limit: Within 366 days | Time limit: Within 366 days |
| CP012 | PREREQUISITES | prerequisite | seed | No duplicate case | No duplicate case |
| CP013 | PREREQUISITES | prerequisite | implied | CyberSource: GREEN | CyberSource: GREEN |
| CP014 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP015 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP016 | START | customer | chat | Then user selects English |  |
| CP017 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP018 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP019 | START | customer | chat | And the user says "My connecting flight on PAL was delayed and I arrived 4 hours late at my final destination, I want compensation" | My connecting flight on PAL was delayed and I arrived 4 hours late at my final destination, I want compensation |
| CP020 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP021 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP022 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP023 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP024 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP025 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP026 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Luc Beauchemin" | Luc Beauchemin |
| CP027 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Luc! And, what is your booking reference number? |
| CP028 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC016" | PNR: TC016 |
| CP029 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC016 |  |
| CP030 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP031 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer |  |
| CP032 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP033 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: l***@gmail.com � Phone: +1***567 |
| CP034 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: l***@gmail.com" | Email: l***@gmail.com |
| CP035 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP036 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "492817" | 492817 |
| CP037 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP038 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP039 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP040 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP041 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection |  |
| CP042 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP043 | PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Luc Beauchemin (Adult) Is this who you'd like to include? |
| CP044 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP045 | PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP046 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Leg 1: AC 501 � Montreal (YUL) ? Toronto (YYZ) � June 25, 2026 � Leg 2: PAL 802 � Toronto (YYZ) ? Vancouver (YVR) � June 25, 20 |
| CP047 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 legs) |  |
| CP049 | SEGMENT CHECK (GenUC-18) | verdict | api | Then the chatbot identifies: MSL = Leg 2 (PAL 802 YYZ?YVR) � longest leg / disrupted leg |  |
| CP050 | SEGMENT CHECK (GenUC-18) | system | implied | Then the chatbot confirms segments with customer |  |
| CP051 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP052 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP053 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival |  |
| CP054 | 72-HOUR CHECK | system | implied | And the system calculates: >72 hours ? PROCEED |  |
| CP055 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline for APPR = 366 days from disruption ? within 366 days ? PROCEED |  |
| CP056 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend | ??? SUB-SCENARIO A: PAL Coding PRESENT ??? |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Leg 1: AC 501 YUL?YYZ, Leg 2: PAL 802 YYZ?YVR, Scheduled Final Arrival: 18:00 | Promised Itinerary - Leg 1: AC 501 YUL?YYZ, Leg 2: PAL 802 YYZ?YVR, Scheduled Final Arrival: 18:00 |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Leg 1: AC 501 YUL?YYZ (ON TIME), Leg 2: PAL 802 YYZ?YVR, Status: ARRIVED LATE, Actual: 22:00, Delay: +4H 00M | Current Itinerary - Leg 1: AC 501 YUL?YYZ (ON TIME), Leg 2: PAL 802 YYZ?YVR, Status: ARRIVED LATE, Actual: 22:00, Delay: +4H 00M |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR | Regime: APPR |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: PAL 802 � YYZ ? YVR � 42 | MSL FLIGHT: PAL 802 � YYZ ? YVR � 42 |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | "Delayed due to Scheduled maintenance" | "Delayed due to Scheduled maintenance" |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +4H 00M � CONTROLLABLE | Delay: +4H 00M � CONTROLLABLE |
| CP063 | TRIP TRACER UI VALIDATION | verdict | api | PAL coding: PRESENT � Code 42 populated | PAL coding: PRESENT � Code 42 populated |
| CP064 | TRIP TRACER UI VALIDATION | verdict | api | CRITICAL: DDS successfully reads PAL coding and classifies as Controllable | CRITICAL: DDS successfully reads PAL coding and classifies as Controllable |
| CP065 | TRIP TRACER UI VALIDATION | verdict | api | MR LUC BEAUCHEMIN / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 / [expiry date] | MR LUC BEAUCHEMIN / ELIGIBLE / DELAY_3_TO_LT_6_HOURS / CAD 400.00 / [expiry date] |
| CP066 | TRIP TRACER UI VALIDATION | verdict | api | DDS proceeds normally ? Eligible ? Payment flow continues as per TC_001 | DDS proceeds normally ? Eligible ? Payment flow continues as per TC_001 |
| CP067 | TRIP TRACER UI VALIDATION | verdict | api | SUB-SCENARIO B: PAL Coding MISSING ??? | SUB-SCENARIO B: PAL Coding MISSING ??? |
| CP068 | TRIP TRACER UI VALIDATION | verdict | api | Promised Itinerary - Leg 1: AC 501 YUL?YYZ, Leg 2: PAL 802 YYZ?YVR, Scheduled Final Arrival: 18:00 | Promised Itinerary - Leg 1: AC 501 YUL?YYZ, Leg 2: PAL 802 YYZ?YVR, Scheduled Final Arrival: 18:00 |
| CP069 | TRIP TRACER UI VALIDATION | verdict | api | Current Itinerary - Leg 1: AC 501 YUL?YYZ (ON TIME), Leg 2: PAL 802 YYZ?YVR, Status: ARRIVED LATE, Actual: 22:00, Delay: +4H 00M | Current Itinerary - Leg 1: AC 501 YUL?YYZ (ON TIME), Leg 2: PAL 802 YYZ?YVR, Status: ARRIVED LATE, Actual: 22:00, Delay: +4H 00M |
| CP070 | TRIP TRACER UI VALIDATION | verdict | api | Regime: APPR | Regime: APPR |
| CP071 | TRIP TRACER UI VALIDATION | verdict | api | MSL FLIGHT: PAL 802 � YYZ ? YVR � BLANK/NULL | MSL FLIGHT: PAL 802 � YYZ ? YVR � BLANK/NULL |
| CP072 | TRIP TRACER UI VALIDATION | verdict | api | Disruption reason: MISSING � no coding from PAL | Disruption reason: MISSING � no coding from PAL |
| CP073 | TRIP TRACER UI VALIDATION | verdict | api | Delay: +4H 00M � Classification: UNABLE TO DETERMINE (no code) | Delay: +4H 00M � Classification: UNABLE TO DETERMINE (no code) |
| CP074 | TRIP TRACER UI VALIDATION | verdict | api | PAL coding: MISSING � Code field is BLANK/NULL | PAL coding: MISSING � Code field is BLANK/NULL |
| CP075 | TRIP TRACER UI VALIDATION | verdict | api | CRITICAL: DDS cannot classify controllability without disruption code | CRITICAL: DDS cannot classify controllability without disruption code |
| CP076 | TRIP TRACER UI VALIDATION | verdict | api | MR LUC BEAUCHEMIN / PENDING REVIEW / DELAY_3_TO_LT_6_HOURS / AGENT REVIEW REQUIRED / [expiry date] | MR LUC BEAUCHEMIN / PENDING REVIEW / DELAY_3_TO_LT_6_HOURS / AGENT REVIEW REQUIRED / [expiry date] |
| CP077 | DDS MISSING CODING BEHAVIOUR | verdict | api | Then DDS detects: MSL carrier = PAL, disruption code = NULL/BLANK |  |
| CP078 | DDS MISSING CODING BEHAVIOUR | verdict | api | And DDS flags: UNABLE TO CLASSIFY � missing coding from interline partner |  |
| CP079 | DDS MISSING CODING BEHAVIOUR | verdict | api | And DDS routes case to: AGENT REVIEW QUEUE (not auto-approved) |  |
| CP080 | DDS MISSING CODING BEHAVIOUR | bot | chat | Then the chatbot responds: | Thank you for providing your information. We've received your claim and it requires additional review by our team. A Customer Relations agent will review your c |
| CP081 | DDS MISSING CODING BEHAVIOUR | alert | chat | And an alert information is displayed: "Claim submitted for review." | Claim submitted for review. |
| CP082 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP083 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP084 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "�lise Beaumont" with PNR "TC183" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "�lise Beaumont" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC183" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating Carrier should be "PAL" |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ticketing Carrier should be "AC" |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "�lise Beaumont" |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "e***@gmail.com" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***567" |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Aeroplan should be "Not linked" |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL ? MNL (AC 501, on time) ? MNL ? CEB (PAL 102, delayed)" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should show DDS ran automatically |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the MSL should be PAL 102 |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Operating carrier PAL should be clearly displayed |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP108 | PAYMENT VALIDATION | payment | chat | Given Sub-Scenario A where PAL coding is present and DDS is eligible |  |
| CP109 | PAYMENT VALIDATION | payment | chat | Then payment should be processed through the standard FD compensation flow |  |
| CP110 | PAYMENT VALIDATION | payment | chat | And the customer's country of residence should be "Canada" |  |
| CP111 | PAYMENT VALIDATION | payment | chat | And the currency should be set to "CAD" |  |
| CP112 | PAYMENT VALIDATION | payment | chat | And the payment method should be "Interac e-Transfer" |  |
| CP113 | PAYMENT VALIDATION | payment | chat | And the customer has no Aeroplan linked so only Cash should be offered with no AC Wallet option |  |
| CP114 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be "$400 CAD" for FD delay tier 3 to less than 6 hours under APPR NOT $900 which is the Denied Boarding t |  |
| CP115 | PAYMENT VALIDATION | payment | chat | And IDV should be completed via Persona and Persona should return IDV PASS |  |
| CP116 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the system |  |
| CP117 | PAYMENT VALIDATION | payment | manual | And a daily batch file should be generated and dispatched to Unifier |  |
| CP118 | PAYMENT VALIDATION | payment | chat | And the 35-day expiry rule should apply |  |
| CP119 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show Amount $400 Currency CAD Method Cash Interac Status Pending or Completed |  |
| CP120 | PAYMENT VALIDATION | payment | chat | And given Sub-Scenario B where PAL coding is missing and DDS is pending review |  |
| CP121 | PAYMENT VALIDATION | payment | chat | Then no automated payment should be processed |  |
| CP122 | PAYMENT VALIDATION | payment | chat | And no country of residence prompt should be displayed |  |
| CP123 | PAYMENT VALIDATION | payment | chat | And no Cash vs AC Wallet check should be triggered |  |
| CP124 | PAYMENT VALIDATION | payment | chat | And no payment method should be presented to the customer |  |
| CP125 | PAYMENT VALIDATION | payment | chat | And no Persona IDV should be triggered |  |
| CP126 | PAYMENT VALIDATION | payment | chat | And no CyberSource fraud screening should be triggered |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And no compensation record should be created in the automated pipeline |  |
| CP128 | PAYMENT VALIDATION | payment | chat | And the case should be routed to agent queue for manual review |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show Amount Pending Currency TBD Method TBD Status Awaiting Agent Review |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And any automated payment in Sub-Scenario B is a P1 defect |  |
| CP131 | EXPECTED RESULTS | verdict | api | Scenario A (PAL coding present): DDS returns FD-APPR-EL-01. | Scenario A (PAL coding present): DDS returns FD-APPR-EL-01. |
| CP132 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 14:00 (14-day mark); Actual = 18:00; Delay = 4hrs; MSL = PAL 102 MNL?CEB; Operating Carrier = PAL; Ticketing Carrier  | Trip Tracer: Promise = 14:00 (14-day mark); Actual = 18:00; Delay = 4hrs; MSL = PAL 102 MNL?CEB; Operating Carrier = PAL; Ticketing Carrier = AC; Disruption cod |
| CP133 | EXPECTED RESULTS | verdict | chat | Compensation: $400 CAD. | Compensation: $400 CAD. |
| CP134 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN ? auto-approved. | CyberSource: GREEN ? auto-approved. |
| CP135 | EXPECTED RESULTS | verdict | api | CRITICAL: DDS must correctly read and interpret PAL's disruption coding. | CRITICAL: DDS must correctly read and interpret PAL's disruption coding. |
| CP136 | EXPECTED RESULTS | verdict | api | Scenario B (PAL coding missing): DDS returns PENDING REVIEW. | Scenario B (PAL coding missing): DDS returns PENDING REVIEW. |
| CP137 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 14:00; Actual = 18:00; Delay = 4hrs; MSL = PAL 102 MNL?CEB; Operating Carrier = PAL; Disruption code = NULL/MISSING;  | Trip Tracer: Promise = 14:00; Actual = 18:00; Delay = 4hrs; MSL = PAL 102 MNL?CEB; Operating Carrier = PAL; Disruption code = NULL/MISSING; Controllability = UN |
| CP138 | EXPECTED RESULTS | verdict | chat | Case routed to agent queue. | Case routed to agent queue. |
| CP139 | EXPECTED RESULTS | verdict | api | CRITICAL: DDS must NOT auto-approve or auto-deny. | CRITICAL: DDS must NOT auto-approve or auto-deny. |
| CP140 | EXPECTED RESULTS | verdict | chat | Agent must manually review. | Agent must manually review. |
| CP141 | EXPECTED RESULTS | verdict | api | Verify DDS gracefully handles missing PAL data without errors. | Verify DDS gracefully handles missing PAL data without errors. |
