# FD_TC_026 · CHAI-31418 — checkpoints

**Goal:** Validates Tier 2 flight disruption compensation for a Star Alliance Gold member where the customer selects AC Wallet payout. A 7-hour controllable delay on a single domestic leg (Flight AC 431, YUL to YYZ) falls within the APPR 6 to <9hr delay band. The linked active Star Alliance Gold profile (Aeroplan 50K/75K/Super Elite or partner Star Alliance Gold) triggers the APPR dual payment offer, and the customer selects AC Wallet. Validates that the 20% top-up calculation is accurately applied on the Tier 2 statutory base ($700 CAD base + 20% top-up = $840 CAD AC Wallet). Confirms that DDS returns EL-02, Persona IDV passes, CyberSource returns GREEN, the compensation record routes to EIP/iFly (not Unifier), and the Claims Dashboard reflects Star Alliance Gold tier status with read-only resolution.

Methods: seed 16, chat 51, api 15, email 2, dashboard 44, implied 11, manual 13, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates Tier 2 flight disruption compensation for a Star Alliance Gold member where the customer selects AC Wallet payout. A 7-hour contro |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: TC019 � Single passenger Isabelle C�t� (Adult - Claimant, Star Alliance Gold / Aeroplan Elite Member 9876543210) | PNR: TC019 � Single passenger Isabelle C�t� (Adult - Claimant, Star Alliance Gold / Aeroplan Elite Member 9876543210) |
| CP003 | PREREQUISITES | prerequisite | seed | Journey: 1 leg AC domestic YUL to YYZ (Flight AC 431) | Journey: 1 leg AC domestic YUL to YYZ (Flight AC 431) |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival: 10:00 | Scheduled arrival: 10:00 |
| CP005 | PREREQUISITES | prerequisite | seed | Actual arrival: 17:00 (7hr delay � Delay band: 6 to <9 hours) | Actual arrival: 17:00 (7hr delay � Delay band: 6 to <9 hours) |
| CP006 | PREREQUISITES | prerequisite | seed | Arrival delay code: 11 (Late Passengers / Controllable) | Arrival delay code: 11 (Late Passengers / Controllable) |
| CP007 | PREREQUISITES | prerequisite | seed | Flight status: Arrived (operated) | Flight status: Arrived (operated) |
| CP008 | PREREQUISITES | prerequisite | seed | Booking changes: None � no VOL or INVOL | Booking changes: None � no VOL or INVOL |
| CP009 | PREREQUISITES | prerequisite | seed | Carrier: AC only | Carrier: AC only |
| CP010 | PREREQUISITES | prerequisite | seed | 72hrs: Elapsed (filed D+34) | 72hrs: Elapsed (filed D+34) |
| CP011 | PREREQUISITES | prerequisite | seed | Time limit: Within 366 days | Time limit: Within 366 days |
| CP012 | PREREQUISITES | prerequisite | seed | No duplicate case | No duplicate case |
| CP013 | PREREQUISITES | prerequisite | seed | Not employee, not infant | Not employee, not infant |
| CP014 | PREREQUISITES | prerequisite | seed | Aeroplan / Frequent Flyer: Linked (9876543210), Star Alliance Gold status active and in good standing (NOT frozen) | Aeroplan / Frequent Flyer: Linked (9876543210), Star Alliance Gold status active and in good standing (NOT frozen) |
| CP015 | PREREQUISITES | prerequisite | implied | CyberSource: Configured to return GREEN | CyberSource: Configured to return GREEN |
| CP016 | PREREQUISITES | prerequisite | seed | Persona: Configured to return IDV PASS | Persona: Configured to return IDV PASS |
| CP017 | PREREQUISITES | prerequisite | seed | Country of residence: Canada (CAD) | Country of residence: Canada (CAD) |
| CP018 | PREREQUISITES | prerequisite | seed | Payment: AC Wallet selected ($840 CAD) | Payment: AC Wallet selected ($840 CAD) |
| CP019 | GREETING & INTENT IDENTIFICATION | customer | chat | Given the user opens the agentic chatbot |  |
| CP020 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP021 | GREETING & INTENT IDENTIFICATION | customer | chat | Then user selects "English" | English |
| CP022 | GREETING & INTENT IDENTIFICATION | alert | chat | Then an alert information is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI t | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP023 | GREETING & INTENT IDENTIFICATION | bot | chat | Then chatbot asks: "How can I help you today?" | How can I help you today? |
| CP024 | GREETING & INTENT IDENTIFICATION | customer | chat | And the user says: "My flight was delayed about 7 hours due to a maintenance issue, I'd like to check if I'm eligible for compensation and I | My flight was delayed about 7 hours due to a maintenance issue, I'd like to check if I'm eligible for compensation and I'd prefer to get it on my Aeroplan accou |
| CP025 | GREETING & INTENT IDENTIFICATION | system | implied | When the chatbot identifies flight disruption intent |  |
| CP026 | GREETING & INTENT IDENTIFICATION | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP027 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP028 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP029 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. Please provide your f |
| CP030 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Isabelle C�t�" | Isabelle C�t� |
| CP031 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: "Thanks, Isabelle! And, what is your booking reference number?" | Thanks, Isabelle! And, what is your booking reference number? |
| CP032 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "PNR: TC019" | PNR: TC019 |
| CP033 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC019 |  |
| CP034 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP035 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer data (passenger info, journey details, Star Alliance Gold profile) is revealed to the customer |  |
| CP036 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP037 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | * Email: i***@gmail.com * Phone: +1345 |
| CP038 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: i@gmail.com" | Email: i@gmail.com |
| CP039 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it." | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP040 | AUTHENTICATION (GenUC-05) | customer | chat | And the user provides the OTP code "629184" | 629184 |
| CP041 | AUTHENTICATION (GenUC-05) | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP042 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: "Your verification was successful. Welcome back, Isabelle (Star Alliance Gold). Let's proceed to the next step." | Your verification was successful. Welcome back, Isabelle (Star Alliance Gold). Let's proceed to the next step. |
| CP043 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP044 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | system | implied | And group booking identifier = NOT PRESENT |  |
| CP045 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot asks: "How many people are on your claim?" | How many people are on your claim? |
| CP046 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | bot | chat | And the chatbot displays passengers from PNR TC019: | I found 1 passenger on this booking: * Isabelle C�t� (Adult - Star Alliance Gold) Is this who you'd like to include? |
| CP047 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP048 | GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06) | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED |  |
| CP049 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: * Flight: AC 431 * Route: Montreal (YUL) to Toronto (YYZ) * Date: May 10, 2026 * Arrival Delay: 7 hours Is this the journey you'd |
| CP050 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP051 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP052 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot sends request to Case Services for duplicate check ? NO existing case found for this passenger + journey combination |  |
| CP053 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks 72-hour rule: Arrival May 10, 2026; filing June 13, 2026 ? 34 days (>72 hours) ? PROCEED |  |
| CP054 | SEGMENT & ELIGIBILITY CHECKS | system | implied | Then the chatbot checks APPR filing deadline: 34 days elapsed (within 366 days) ? PROCEED |  |
| CP055 | TRIAGE & DDS EVALUATION | verdict | api | Backend DDS executes evaluation for PNR TC019 / Claimant Isabelle C�t�: | � Regime: APPR Applicable � Delay reason: Code 11 (Late Passengers / Gate Hold � Controllable) � Delay duration: 7 hours (Band: 6 to <9 hours ? Tier 2) � Star A |
| CP056 | TRIP TRACER UI VALIDATION | verdict | api | [x] Promised Itinerary: Flight AC 431, Route: YUL to YYZ, Scheduled Arrival: 10:00 | [x] Promised Itinerary: Flight AC 431, Route: YUL to YYZ, Scheduled Arrival: 10:00 |
| CP057 | TRIP TRACER UI VALIDATION | verdict | api | [x] Current Itinerary: Flight AC 431, Route: YUL to YYZ, Status: ARRIVED LATE, Scheduled Arrival: 10:00 ? Actual: 17:00, Delay: +7H 00M | [x] Current Itinerary: Flight AC 431, Route: YUL to YYZ, Status: ARRIVED LATE, Scheduled Arrival: 10:00 ? Actual: 17:00, Delay: +7H 00M |
| CP058 | TRIP TRACER UI VALIDATION | verdict | api | [x] Regime: APPR (1 regime) | [x] Regime: APPR (1 regime) |
| CP059 | TRIP TRACER UI VALIDATION | verdict | api | [x] MSL Flight: AC 431 � YUL to YYZ � Code 11 ("Delayed due to late passengers") | [x] MSL Flight: AC 431 � YUL to YYZ � Code 11 ("Delayed due to late passengers") |
| CP060 | TRIP TRACER UI VALIDATION | verdict | api | [x] Delay Classification: +7H 00M � CONTROLLABLE | [x] Delay Classification: +7H 00M � CONTROLLABLE |
| CP061 | TRIP TRACER UI VALIDATION | verdict | api | [x] Loyalty Profile: 9876543210 (Star Alliance Gold � linked, active) | [x] Loyalty Profile: 9876543210 (Star Alliance Gold � linked, active) |
| CP062 | TRIP TRACER UI VALIDATION | verdict | api | MS ISABELLE C�T� / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 840.00 (Wallet) / [expiry date] | MS ISABELLE C�T� / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 840.00 (Wallet) / [expiry date] |
| CP063 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Chatbot sends case details to CyberSource ? Returns GREEN LIGHT (Pass) |  |
| CP064 | ELIGIBLE RESULT DISPLAY (FD-05a) | bot | chat | Chatbot displays: "I've checked your flight details, and flight AC 431 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7 hours. Ba | I've checked your flight details, and flight AC 431 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7 hours. Based on the Air Passenger Protection Reg |
| CP065 | CLAIM PAYMENT & AC WALLET SELECTION | bot | chat | Chatbot asks: "In which country will your reimbursement be deposited?" | In which country will your reimbursement be deposited? |
| CP066 | IDENTITY VERIFICATION | bot | chat | Chatbot displays "Get verified" button ? User completes Persona IDV ? Persona returns IDV PASS | Get verified |
| CP067 | CLAIM AMOUNT CONFIRMATION FLOW | bot | chat | Chatbot responds: "Thank you. You will be receiving $700 CAD converted into the currency associated to your profile. | Deposit Amount: $840 CAD Payment Method: AC Wallet (Account #: 9876543210) Would you like me to submit your claim?" |
| CP068 | CLAIM AMOUNT CONFIRMATION FLOW | alert | chat | And an alert information is displayed: "Please note that payment details cannot be changed after submission." | Please note that payment details cannot be changed after submission. |
| CP069 | CLAIM AMOUNT CONFIRMATION FLOW | customer | chat | When the user clicks on "Yes" | Yes |
| CP070 | CASE CREATION & NOTIFICATION | email | email | Chatbot responds: "Thank you. Your claim has been submitted and will be processed within 10 business days. A confirmation email will be sent | Thank you. Your claim has been submitted and will be processed within 10 business days. A confirmation email will be sent to you with details on how to monitor  |
| CP071 | CASE CREATION & NOTIFICATION | email | email | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP072 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the case has been created for claimant "Isabelle C�t�" with PNR "TC019" |  |
| CP073 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" |  |
| CP074 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP075 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Case Status should be "In Review" or "Done" |  |
| CP076 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Created date should be populated |  |
| CP077 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Last Updated date should be populated |  |
| CP078 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the SLA countdown should be tracking correctly |  |
| CP079 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Team assignment should be correct |  |
| CP080 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no banners should be displayed for identified and authenticated Auth Flow 1 user |  |
| CP081 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist panel should NOT be greyed out |  |
| CP082 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Name should be "Isabelle C�t�" |  |
| CP083 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Claimant Type should be "Adult" |  |
| CP084 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Authentication should be "Pass" |  |
| CP085 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR should be "TC019" |  |
| CP086 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the PNR Creation Date should be populated |  |
| CP087 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey ID should be populated |  |
| CP088 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Source should be populated |  |
| CP089 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Booking Office ID should be populated |  |
| CP090 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Regime should be "APPR" |  |
| CP091 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Full Name should be "Isabelle C�t�" |  |
| CP092 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tags should include "Claimant", "Adult", and "Star Alliance Gold" |  |
| CP093 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Email should be "i***@gmail.com" |  |
| CP094 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Phone should be "+1***345" |  |
| CP095 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Address should be populated |  |
| CP096 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Loyalty Number should be "9876543210" linked and active |  |
| CP097 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Profile ID should be populated |  |
| CP098 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Tier Status should be "Star Alliance Gold / Member" |  |
| CP099 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Journey should show "Bound 1: YUL to YYZ" with claim filed for this flight |  |
| CP100 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Ancillary Fee section should be present and empty |  |
| CP101 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Eligibility and Compensation section should show "$840 CAD (AC Wallet � 20% Top-up Applied)" |  |
| CP102 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP103 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically with no agent action needed |  |
| CP104 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated as "ELIGIBLE" (APPR, Tier 2: 6 to <9 hrs, Code 11 Controllable, AC Wallet) |  |
| CP105 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically using baseline data "Isabelle C�t� + TC019 + YUL to YYZ + FD" |  |
| CP106 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the result should be "No duplicate found" |  |
| CP107 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no Duplicate Warning Banner should be displayed |  |
| CP108 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Related Cases tab should show no related cases |  |
| CP109 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP110 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should have proceeded automatically and not be parked in Fraud Queue |  |
| CP111 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically for identified and authenticated user |  |
| CP112 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Trip Tracer poll should NOT be required |  |
| CP113 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should have used pull case from My Activities |  |
| CP114 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case status should have transitioned from "Assigned" to "In Progress" |  |
| CP115 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And a case acknowledgement notification should have been sent |  |
| CP116 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible notification email should have been sent via Adobe |  |
| CP117 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Agent Notes section should be accessible |  |
| CP118 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the Audit Log should record all actions with timestamps and before/after values |  |
| CP119 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And Customer Communications should show the notification email chronologically |  |
| CP120 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the chatbot transcript should be accessible and linked to the case |  |
| CP121 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Attachments tab should be empty |  |
| CP122 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should be "Resolved" |  |
| CP123 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode with no editable Decision Assist fields |  |
| CP124 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the agent should not be able to access Case Search as it is for leads and management only | Payment Validation Gherkin: |
| CP125 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP126 | PAYMENT VALIDATION | payment | chat | Then the currency should be set to "CAD" |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And the customer has Star Alliance Gold profile "9876543210" linked with active status in good standing |  |
| CP128 | PAYMENT VALIDATION | payment | chat | And both options should be offered: Cash at $700 CAD and AC Wallet at $840 CAD with 20% top-up |  |
| CP129 | PAYMENT VALIDATION | payment | chat | And the customer selects "AC Wallet" |  |
| CP130 | PAYMENT VALIDATION | payment | chat | And the 20% top-up should be applied converting $700 to $840 CAD |  |
| CP131 | PAYMENT VALIDATION | payment | chat | And AC Wallet should be offered because this is flight disruption APPR |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created for $840 CAD |  |
| CP133 | PAYMENT VALIDATION | payment | manual | And the record should be picked up by the daily evening batch file |  |
| CP134 | PAYMENT VALIDATION | payment | manual | And the record should be dispatched to EIP and NOT Unifier |  |
| CP135 | PAYMENT VALIDATION | payment | chat | And EIP should convert from CAD to the customer's profile country currency if applicable |  |
| CP136 | PAYMENT VALIDATION | payment | chat | And EIP should check loyalty account validity confirming it is active and not frozen |  |
| CP137 | PAYMENT VALIDATION | payment | chat | And EIP should send to iGiga |  |
| CP138 | PAYMENT VALIDATION | payment | chat | And iGiga should send to iFly for deposit |  |
| CP139 | PAYMENT VALIDATION | payment | chat | And iFly should talk back to EIP |  |
| CP140 | PAYMENT VALIDATION | payment | chat | And EIP should talk back to Claims Dashboard with deposited amount ($840 CAD), exchange rate, and status |  |
| CP141 | PAYMENT VALIDATION | payment | chat | And if the loyalty account is frozen or closed a rejection with error message should be returned and a failure notification should be sent t |  |
| CP142 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the EIP team |  |
| CP143 | PAYMENT VALIDATION | payment | chat | And the Claims Dashboard Compensation tab should show "$840 CAD" |  |
| CP144 | PAYMENT VALIDATION | payment | chat | And the payment method should show "AC Wallet" |  |
| CP145 | PAYMENT VALIDATION | payment | manual | And the status should be updated via talkback |  |
| CP146 | EXPECTED RESULTS | verdict | api | DDS returns FD-APPR-EL-02. | DDS returns FD-APPR-EL-02. |
| CP147 | EXPECTED RESULTS | verdict | api | Trip Tracer: Promise = 10:00, Actual = 17:00, Delay = 7hrs, MSL = Leg 1, Code 11 (Late Passengers � Controllable), Regime = APPR. | Trip Tracer: Promise = 10:00, Actual = 17:00, Delay = 7hrs, MSL = Leg 1, Code 11 (Late Passengers � Controllable), Regime = APPR. |
| CP148 | EXPECTED RESULTS | verdict | chat | Loyalty Profile: Star Alliance Gold profile linked. | Loyalty Profile: Star Alliance Gold profile linked. |
| CP149 | EXPECTED RESULTS | verdict | chat | Compensation: $840 CAD via AC Wallet ($700 base + 20% top-up of $140 CAD). | Compensation: $840 CAD via AC Wallet ($700 base + 20% top-up of $140 CAD). |
| CP150 | EXPECTED RESULTS | verdict | chat | EIP check: Account active, deposit successful via iGiga/iFly. | EIP check: Account active, deposit successful via iGiga/iFly. |
| CP151 | EXPECTED RESULTS | verdict | chat | CyberSource: GREEN. | CyberSource: GREEN. |
| CP152 | EXPECTED RESULTS | verdict | chat | Persona: PASS. | Persona: PASS. |
| CP153 | EXPECTED RESULTS | verdict | api | Claims Dashboard: Case created in Resolved/Done status with read-only summary, Star Alliance Gold tier populated, Code 11, and $840 CAD AC W | Claims Dashboard: Case created in Resolved/Done status with read-only summary, Star Alliance Gold tier populated, Code 11, and $840 CAD AC Wallet credited to ac |
