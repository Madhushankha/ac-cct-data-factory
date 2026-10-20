# FD_TC_239 · CHAI-31631 — checkpoints

**Goal:** Checks that an eligible claim is never paid without a verified identity, even for a linked Aeroplan member. Flight AC 412 YUL ? YYZ arrived 7 hours late (Code 96, Controllable), and DDS returns FD-APPR-EL-02, CAD 700. The customer lives in Canada and has a Basic Aeroplan profile, so the bot offers Cash CAD 700 (Interac) and AC Wallet CAD 840. The customer picks Cash, and the bot collects the email only. At the payout IDV step the customer declines Persona. The bot says the identity will be checked manually, and the case goes to CR through Manual Handoff with no CyberSource flag. A CR agent sets up a video check using another email address the customer gives. The ID doesn't match the claimant, so the manual IDV fails. The agent rejects the case, an automated decline message is sent and the claim is closed. No compensation record is created, AC Wallet isn't credited and nothing is sent to Unifier.

Methods: seed 14, chat 49, api 8, email 3, implied 66, manual 2, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Checks that an eligible claim is never paid without a verified identity, even for a linked Aeroplan member. Flight AC 412 YUL ? YYZ arrived  |  |
| CP002 | PREREQUISITES | prerequisite | seed | PNR: ID040 � single passenger S�bastien Lachance (Adult, Basic Aeroplan 9876543210, linked, good standing, not frozen) | PNR: ID040 � single passenger S�bastien Lachance (Adult, Basic Aeroplan 9876543210, linked, good standing, not frozen) |
| CP003 | PREREQUISITES | prerequisite | seed | AC 412 YUL ? YYZ, July 20, 2026 | AC 412 YUL ? YYZ, July 20, 2026 |
| CP004 | PREREQUISITES | prerequisite | seed | Scheduled arrival 12:00, actual 19:00 (7h delay) | Scheduled arrival 12:00, actual 19:00 (7h delay) |
| CP005 | PREREQUISITES | prerequisite | seed | Code 96 (Operations Control � Controllable) | Code 96 (Operations Control � Controllable) |
| CP006 | PREREQUISITES | prerequisite | seed | Travelled, arrived late | Travelled, arrived late |
| CP007 | PREREQUISITES | prerequisite | seed | No VOL/INVOL changes | No VOL/INVOL changes |
| CP008 | PREREQUISITES | prerequisite | seed | AC only | AC only |
| CP009 | PREREQUISITES | prerequisite | seed | Claim filed Jul 28, 2026 (more than 72h, within 366 days) | Claim filed Jul 28, 2026 (more than 72h, within 366 days) |
| CP010 | PREREQUISITES | prerequisite | seed | No duplicate | No duplicate |
| CP011 | PREREQUISITES | prerequisite | seed | Not employee, not infant | Not employee, not infant |
| CP012 | PREREQUISITES | prerequisite | implied | CyberSource GREEN | CyberSource GREEN |
| CP013 | PREREQUISITES | prerequisite | seed | Country of residence: Canada | Country of residence: Canada |
| CP014 | PREREQUISITES | prerequisite | seed | OTP passed | OTP passed |
| CP015 | PREREQUISITES | prerequisite | seed | Persona: customer declines consent. mIDV (video): FAIL | Persona: customer declines consent. mIDV (video): FAIL |
| CP016 | PREREQUISITES | prerequisite | seed | CR agent: Sarah Martin | CR agent: Sarah Martin |
| CP017 | GREETING & INTENT IDENTIFICATION | customer | chat | Given the user opens the agentic chatbot |  |
| CP018 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot displays greeting (GLOB-01): "Hello! I will be your virtual assistant today. I can assist you in English or French. Which l | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP019 | GREETING & INTENT IDENTIFICATION | customer | chat | Then user selects "English" | English |
| CP020 | GREETING & INTENT IDENTIFICATION | alert | chat | Then the privacy alert is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI to a | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP021 | GREETING & INTENT IDENTIFICATION | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP022 | GREETING & INTENT IDENTIFICATION | customer | chat | And the user says "My flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if I'm eligible for compensation" | My flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if I'm eligible for compensation |
| CP023 | GREETING & INTENT IDENTIFICATION | system | implied | When the chatbot identifies flight disruption intent |  |
| CP024 | GREETING & INTENT IDENTIFICATION | system | implied | Then third-party check ? NO |  |
| CP025 | GREETING & INTENT IDENTIFICATION | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP026 | LEGAL DISCLAIMER | bot | chat | Then the chatbot shows the automated decision-making disclaimer ? user agrees to start |  |
| CP027 | IDENTIFICATION (GenUC-01) | customer | chat | User provides "S�bastien Lachance" and PNR "ID040" ? Trip Tracer PNR FOUND (Auth Flow 1) | S�bastien Lachance ID040 |
| CP028 | AUTHENTICATION (GenUC-05) | customer | chat | User selects Email s***@gmail.com ? OTP "275806" ? CORRECT (attempt 1 of 5) ? "Your verification was successful. Let's proceed to the next s | 275806 Your verification was successful. Let's proceed to the next step. |
| CP029 | AUTHENTICATION (GenUC-05) | system | implied | And no UMNR / YP flag on the PNR |  |
| CP030 | PASSENGER & JOURNEY SELECTION | system | implied | Group booking identifier = NOT PRESENT | "I found 1 passenger on this booking: S�bastien Lachance (Adult - Aeroplan Member). Is this who you'd like to include?" ? "Yes" AC 412, YUL ? YYZ, July 20, 2026 |
| CP031 | CHECKS | system | implied | Single leg ? skip GenUC-18; duplicate check ? none; 72-hour check ? PROCEED; APPR limit ? 8 days (within 366 days) ? PROCEED |  |
| CP032 | DDS EVALUATION | system | implied | APPR; Code 96 Controllable; 420 min ? 6 to under 9 hrs; ELIGIBLE; FD-APPR-EL-02; CAD 700 |  |
| CP033 | TRIP TRACER UI VALIDATION (ID040) | verdict | api | Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M | Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M |
| CP034 | TRIP TRACER UI VALIDATION (ID040) | verdict | api | Regime: APPR (1 regime) | Regime: APPR (1 regime) |
| CP035 | TRIP TRACER UI VALIDATION (ID040) | verdict | api | MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE | MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE |
| CP036 | TRIP TRACER UI VALIDATION (ID040) | verdict | api | Aeroplan: 9876543210 (Basic Member � linked) | Aeroplan: 9876543210 (Basic Member � linked) |
| CP037 | TRIP TRACER UI VALIDATION (ID040) | verdict | api | MR S�BASTIEN LACHANCE / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet | MR S�BASTIEN LACHANCE / ELIGIBLE / DELAY_6_TO_LT_9_HOURS / CAD 700.00 Cash / CAD 840.00 AC Wallet |
| CP038 | ELIGIBLE RESULT (FD-05a) | bot | chat | Chatbot shows the APPR eligible message for AC 412 (about 7 hours) |  |
| CP039 | CLAIM PAYMENT � COUNTRY & FRAUD | customer | chat | Chatbot asks: "In which country will your reimbursement be deposited?" ? user selects "Canada" ? currency CAD | In which country will your reimbursement be deposited? Canada |
| CP040 | AEROPLAN / AC WALLET OFFER | system | implied | System checks Aeroplan: 9876543210, Basic Member, good standing ? both options offered | Chatbot: "Since you are an Aeroplan member, you can choose to either receive: * Cash: CAD $700 sent via Interac e-Transfer, takes 5 to 10 business days to proce |
| CP041 | AEROPLAN / AC WALLET OFFER | system | implied | And AC Wallet is recorded as offered but not selected |  |
| CP042 | PAYMENT METHOD ROUTING | system | implied | Country = Canada ? Interac | Chatbot: "Your payment will be made through Interac e-Transfer. Before we move forward, please confirm the email address where you'd like to receive your paymen |
| CP043 | PAYMENT METHOD ROUTING | system | implied | And no address, bank, card or Transit/Institution details are asked for |  |
| CP044 | PAYOUT IDV � CUSTOMER DECLINES | idv | chat | System checks "Completed IDV?" ? NO | Completed IDV? |
| CP045 | PAYOUT IDV � CUSTOMER DECLINES | idv | chat | Then IDV context = Payment |  |
| CP046 | PAYOUT IDV � CUSTOMER DECLINES | system | implied | And the customer's consent is recorded as NOT given |  |
| CP047 | PAYOUT IDV � CUSTOMER DECLINES | system | implied | And the chatbot tells the customer that someone will contact them to verify their identity manually, and that they will get an email with ne |  |
| CP048 | PAYOUT IDV � CUSTOMER DECLINES | system | implied | And the Claim Amount Confirmation (GenUC-20b) is NOT shown |  |
| CP049 | PAYOUT IDV � CUSTOMER DECLINES | system | implied | And the claim is NOT submitted for payment |  |
| CP050 | PAYOUT IDV � CUSTOMER DECLINES | idv | chat | And the bot does NOT offer to switch to AC Wallet to skip IDV |  |
| CP051 | PAYOUT IDV � CUSTOMER DECLINES | system | implied | And NO CyberSource flag is raised |  |
| CP052 | PAYOUT IDV � CUSTOMER DECLINES | system | implied | And the case is routed to Manual Handoff via Case Services (queue: CR) |  |
| CP053 | PAYOUT IDV � CUSTOMER DECLINES | bot | chat | And the chatbot offers "Is there anything I can help you with?" ? user "No" ? "Thank you for choosing Air Canada." | Is there anything I can help you with? No Thank you for choosing Air Canada. |
| CP054 | NOTIFICATION � MANUAL VERIFICATION NEXT STEPS | email | email | An email is sent to s***@gmail.com with the case reference (CASE-FD-20260728-040) and the next steps for manual identity verification |  |
| CP055 | NOTIFICATION � MANUAL VERIFICATION NEXT STEPS | email | email | And the email does NOT confirm a payment, payment date or AC Wallet credit |  |
| CP056 | PART B � CR AGENT SCHEDULES mIDV | system | implied | Given Sarah Martin pulls the case from My Activities ? Assigned ? In Progress |  |
| CP057 | PART B � CR AGENT SCHEDULES mIDV | system | implied | Then Decision Assist shows ELIGIBLE, FD-APPR-EL-02, CAD 700 |  |
| CP058 | PART B � CR AGENT SCHEDULES mIDV | system | implied | And the payout selection shows Cash (Interac); AC Wallet CAD 840 offered but not selected |  |
| CP059 | PART B � CR AGENT SCHEDULES mIDV | idv | chat | And the IDV status shows "Not consented (payout)" | Not consented (payout) |
| CP060 | PART B � CR AGENT SCHEDULES mIDV | system | implied | And a banner or tag shows that payout is blocked until identity is verified |  |
| CP061 | PART B � CR AGENT SCHEDULES mIDV | system | implied | When Sarah schedules video verification and sends the invitation to the other email address the customer gave |  |
| CP062 | PART B � CR AGENT SCHEDULES mIDV | system | implied | Then the invitation is logged in Customer Communications |  |
| CP063 | PART B � CR AGENT SCHEDULES mIDV | idv | chat | And the case status is "Awaiting Customer Info" (manual IDV) | Awaiting Customer Info |
| CP064 | PART C � mIDV FAILS | system | implied | Given the customer joins the video call |  |
| CP065 | PART C � mIDV FAILS | system | implied | When Sarah compares the government ID shown with the claimant (S�bastien Lachance), the booking and the Aeroplan profile |  |
| CP066 | PART C � mIDV FAILS | system | implied | Then the name or photo on the ID doesn't match the claimant |  |
| CP067 | PART C � mIDV FAILS | idv | chat | And Sarah records the mIDV result = FAIL (Not Verified) |  |
| CP068 | PART C � mIDV FAILS | idv | chat | And the IDV result is saved to the case and can't be edited |  |
| CP069 | PART C � mIDV FAILS | idv | chat | And Sarah writes a short, factual internal note, with no personal details beyond what's needed |  |
| CP070 | PART C � mIDV FAILS | idv | chat | And the case is flagged or visible in the Fraud failed-IDV view (to confirm) |  |
| CP071 | PART D � CLAIM DECLINED AND CLOSED | system | implied | When Sarah rejects the case |  |
| CP072 | PART D � CLAIM DECLINED AND CLOSED | system | implied | Then an automated message tells the customer the claim was declined |  |
| CP073 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the message does NOT disclose itinerary details, the fraud check or the internal reason |  |
| CP074 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And no secure payment link is sent |  |
| CP075 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And no AC Wallet credit is made to 9876543210 |  |
| CP076 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the case status becomes Closed |  |
| CP077 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And Decision Assist and payment fields become read-only | Claims Dashboard Gherkin: |
| CP078 | PART D � CLAIM DECLINED AND CLOSED | verdict | api | Given case "CASE-FD-20260728-040" for claimant "S�bastien Lachance" (PNR "ID040") has DDS "ELIGIBLE", "FD-APPR-EL-02", "CAD 700" | CASE-FD-20260728-040 S�bastien Lachance ID040 ELIGIBLE FD-APPR-EL-02 CAD 700 |
| CP079 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the customer has Basic Aeroplan "9876543210" linked and in good standing |  |
| CP080 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the customer selected "Cash" over AC Wallet |  |
| CP081 | PART D � CLAIM DECLINED AND CLOSED | idv | chat | And the customer declined consent for payout IDV in the chatbot |  |
| CP082 | PART D � CLAIM DECLINED AND CLOSED | system | implied | Then the case should be routed to Manual Handoff in the CR queue |  |
| CP083 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And no CyberSource flag should be raised for the consent refusal |  |
| CP084 | PART D � CLAIM DECLINED AND CLOSED | idv | chat | And the IDV status should show "Not consented (payout)" | Not consented (payout) |
| CP085 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the payout should be blocked |  |
| CP086 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the Topic/Sub-topic should be "Travel Disruptions � Delays" |  |
| CP087 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated |  |
| CP088 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the Created and Last Updated dates should be populated |  |
| CP089 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the SLA countdown should be tracking correctly |  |
| CP090 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the Claimant should be "S�bastien Lachance", Adult, Authentication "Pass (OTP)" |  |
| CP091 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the PNR should be "ID040" with Creation Date, Journey ID, Booking Source and Office ID populated |  |
| CP092 | PART D � CLAIM DECLINED AND CLOSED | verdict | api | And the Regime should be "APPR" | APPR |
| CP093 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the Tags should include "Claimant" and "Adult" |  |
| CP094 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the Email should be "s***@gmail.com" |  |
| CP095 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the Aeroplan should be "9876543210" linked, Tier Status "Basic / Member" |  |
| CP096 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 96) |  |
| CP097 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the Ancillary Fee section should be present and empty |  |
| CP098 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the Eligibility and Compensation section should show "ELIGIBLE � CAD 700 � Cash (Interac)" with no payment issued |  |
| CP099 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And AC Wallet CAD 840 should show as offered but not selected |  |
| CP100 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the Duplicate Check should show "No duplicate found" |  |
| CP101 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the CyberSource result should be "GREEN" |  |
| CP102 | PART D � CLAIM DECLINED AND CLOSED | system | implied | When the CR agent schedules video verification using another email address |  |
| CP103 | PART D � CLAIM DECLINED AND CLOSED | system | implied | Then the invitation should be logged in Customer Communications |  |
| CP104 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the status should be "Awaiting Customer Info" |  |
| CP105 | PART D � CLAIM DECLINED AND CLOSED | idv | chat | When the agent records the mIDV result as "FAIL" | FAIL |
| CP106 | PART D � CLAIM DECLINED AND CLOSED | idv | chat | Then the IDV result should be saved and not editable |  |
| CP107 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And no passenger, Aeroplan or flight fields should be updated automatically from the failed verification |  |
| CP108 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And any related notes should be free text only |  |
| CP109 | PART D � CLAIM DECLINED AND CLOSED | system | implied | When the agent rejects the case |  |
| CP110 | PART D � CLAIM DECLINED AND CLOSED | system | implied | Then an automated "claim declined" message should be sent to the customer |  |
| CP111 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the message should not disclose itinerary or fraud details |  |
| CP112 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And no payment link should be sent |  |
| CP113 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the case status should be "Closed" |  |
| CP114 | PART D � CLAIM DECLINED AND CLOSED | email | email | And the Audit Log should record in order: created, DDS Eligible, CyberSource GREEN, Cash selected (AC Wallet offered), Interac email confirm |  |
| CP115 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the chatbot transcript should be linked |  |
| CP116 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the case should be read-only after closure |  |
| CP117 | PART D � CLAIM DECLINED AND CLOSED | system | implied | And the agent should not be able to access Case Search as it is for leads and management only | Payment Validation Gherkin: |
| CP118 | PAYMENT VALIDATION | payment | chat | Given the customer's country of residence is "Canada" |  |
| CP119 | PAYMENT VALIDATION | payment | chat | And the customer has Basic Aeroplan "9876543210" linked in good standing |  |
| CP120 | PAYMENT VALIDATION | payment | chat | Then both Cash (CAD 700) and AC Wallet (CAD 840) should be offered |  |
| CP121 | PAYMENT VALIDATION | payment | chat | When the customer selects "Cash" |  |
| CP122 | PAYMENT VALIDATION | payment | chat | Then the currency should be "CAD" and the payment method "Interac e-Transfer" |  |
| CP123 | PAYMENT VALIDATION | payment | chat | And only the email "s***@gmail.com" should be collected |  |
| CP124 | PAYMENT VALIDATION | payment | chat | And no address, bank, card or Transit/Institution details should be collected |  |
| CP125 | PAYMENT VALIDATION | payment | chat | When the customer declines payout IDV |  |
| CP126 | PAYMENT VALIDATION | payment | chat | Then the claim should not be submitted for payment |  |
| CP127 | PAYMENT VALIDATION | payment | chat | And no compensation record should be created |  |
| CP128 | PAYMENT VALIDATION | payment | chat | When the manual IDV fails and the case is closed |  |
| CP129 | PAYMENT VALIDATION | payment | chat | Then no compensation record should exist |  |
| CP130 | PAYMENT VALIDATION | payment | manual | And nothing should be picked up by the evening batch file |  |
| CP131 | PAYMENT VALIDATION | payment | manual | And nothing should be sent to Unifier or EIP |  |
| CP132 | PAYMENT VALIDATION | payment | chat | And no Interac transfer should be issued or show a status |  |
| CP133 | PAYMENT VALIDATION | payment | chat | And no AC Wallet credit should be made to account 9876543210 |  |
| CP134 | PAYMENT VALIDATION | payment | chat | And the Compensation tab should show "Eligible CAD 700 � not paid (identity not verified)" |  |
| CP135 | EXPECTED RESULTS | verdict | api | DDS FD-APPR-EL-02, ELIGIBLE, CAD 700. | DDS FD-APPR-EL-02, ELIGIBLE, CAD 700. |
| CP136 | EXPECTED RESULTS | verdict | chat | CyberSource GREEN. | CyberSource GREEN. |
| CP137 | EXPECTED RESULTS | verdict | chat | Basic Aeroplan linked, so Cash CAD 700 and AC Wallet CAD 840 are both offered. | Basic Aeroplan linked, so Cash CAD 700 and AC Wallet CAD 840 are both offered. |
| CP138 | EXPECTED RESULTS | verdict | chat | The customer picks Cash ? Interac, email only. | The customer picks Cash ? Interac, email only. |
| CP139 | EXPECTED RESULTS | verdict | chat | The customer declines Persona IDV at payout, so the claim isn't submitted. | The customer declines Persona IDV at payout, so the claim isn't submitted. |
| CP140 | EXPECTED RESULTS | verdict | chat | The case goes to CR through Manual Handoff with no CyberSource flag. | The case goes to CR through Manual Handoff with no CyberSource flag. |
| CP141 | EXPECTED RESULTS | verdict | chat | The CR video check fails, and the result is saved and can't be changed. | The CR video check fails, and the result is saved and can't be changed. |
| CP142 | EXPECTED RESULTS | verdict | chat | The agent rejects the case, an automated decline message is sent and the claim is closed. | The agent rejects the case, an automated decline message is sent and the claim is closed. |
| CP143 | EXPECTED RESULTS | verdict | chat | No compensation record, no AC Wallet credit, no batch pickup, no Unifier or EIP dispatch, no Interac transfer. | No compensation record, no AC Wallet credit, no batch pickup, no Unifier or EIP dispatch, no Interac transfer. |
