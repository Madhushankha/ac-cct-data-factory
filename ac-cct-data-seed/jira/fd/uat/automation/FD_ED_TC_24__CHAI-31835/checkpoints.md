# FD_ED_TC_24 · CHAI-31835 — checkpoints

**Goal:** Customer accesses chatbot via mobile web browser. UI components (flight cards, journey selection, payment forms) must render responsively on smaller screens. Per call transcript: "Validate UI components such as flight cards and seat maps across web, mobile, and WhatsApp channels to ensure consistent display."

Methods: seed 1, chat 51, api 6, email 3, implied 31, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer accesses chatbot via mobile web browser. UI components (flight cards, journey selection, payment forms) must render responsively on |  |
| CP002 | PREREQUISITES | prerequisite | seed | Channel: Mobile Web (iPhone Safari / Android Chrome); PNR: TCED24; 1 leg AC (YYZ?YVR); Delay 4 hrs; APPR EL-01 | Channel: Mobile Web (iPhone Safari / Android Chrome); PNR: TCED24; 1 leg AC (YYZ?YVR); Delay 4 hrs; APPR EL-01 |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot via Mobile Web Browser (iPhone Safari or Android Chrome) |  |
| CP004 | START | system | implied | Then the system detects: Channel = Mobile Web |  |
| CP005 | START | system | implied | And the system applies: Responsive rendering rules (components adapt to smaller screen width) |  |
| CP006 | START | bot | chat | Then the chatbot displays greeting (GLOB-01) � Mobile Web responsive format: | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP007 | START | bot | chat | And the chatbot displays interactive buttons (responsive � stacked vertically on mobile): | � [English] � [French] NOTE: On desktop web, buttons may be side-by-side. On mobile web, buttons stack vertically to fit screen width. |
| CP008 | START | system | implied | Then user taps "English" |  |
| CP009 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP010 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP011 | START | customer | chat | And the user says "My flight from Toronto to Vancouver was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compen | My flight from Toronto to Vancouver was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation |
| CP012 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP013 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP014 | START | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP015 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP016 | LEGAL DISCLAIMER | bot | chat | And the chatbot displays interactive buttons (stacked vertically): | � [Yes, let's get started] � [No, not right now] |
| CP017 | LEGAL DISCLAIMER | system | implied | And the user taps "Yes, let's get started" | IDENTIFICATION (GenUC-01) � Mobile Web: |
| CP018 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP019 | LEGAL DISCLAIMER | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP020 | LEGAL DISCLAIMER | customer | chat | And the user types "Samantha Wong" | Samantha Wong |
| CP021 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: | Thanks, Samantha! And, what is your booking reference number? |
| CP022 | LEGAL DISCLAIMER | customer | chat | And the user types "TC244" | TC244 |
| CP023 | LEGAL DISCLAIMER | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC244 |  |
| CP024 | LEGAL DISCLAIMER | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP025 | LEGAL DISCLAIMER | verdict | api | And Trip Tracer data (passenger info, journey details) is revealed to the customer | AUTHENTICATION (GenUC-05) � Mobile Web: |
| CP026 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP027 | LEGAL DISCLAIMER | bot | chat | And the chatbot displays interactive buttons (stacked vertically): | � [Email: s***@gmail.com] � [Phone: +1***345] |
| CP028 | LEGAL DISCLAIMER | system | implied | And the user taps "Email: s***@gmail.com" |  |
| CP029 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP030 | LEGAL DISCLAIMER | customer | chat | And the user types the OTP code "629184" | 629184 |
| CP031 | LEGAL DISCLAIMER | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP032 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed to the next step. |
| CP033 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP034 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP035 | GROUP BOOKING CHECK | system | implied | And system proceeds to passenger selection | PASSENGER SELECTION (GenUC-06) � Mobile Web: |
| CP036 | GROUP BOOKING CHECK | bot | chat | Then the chatbot asks: | How many people are on your claim? |
| CP037 | GROUP BOOKING CHECK | bot | chat | And the chatbot displays a passenger card (responsive � full width on mobile): | I found 1 passenger on this booking: [Passenger Card � Responsive] � Samantha Wong (Adult) [Include ?] [Exclude ?] |
| CP038 | GROUP BOOKING CHECK | system | implied | And the user taps "Include ?" |  |
| CP039 | GROUP BOOKING CHECK | system | implied | Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED | JOURNEY SELECTION (GenUC-08) � Mobile Web (RESPONSIVE FLIGHT CARD): |
| CP040 | GROUP BOOKING CHECK | bot | chat | Then the chatbot retrieves booking details and displays a responsive flight card: | Select this journey |
| CP041 | GROUP BOOKING CHECK | system | implied | And the user taps "Select this journey" |  |
| CP042 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18 |  |
| CP043 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | Then the chatbot sends request to Case Services for duplicate check |  |
| CP044 | DUPLICATE CLAIM CHECK (GenUC-10) | system | implied | And Case Services returns: NO existing case found for this passenger + journey combination |  |
| CP045 | 72-HOUR CHECK | system | implied | Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED |  |
| CP046 | CLAIM TIME LIMIT CHECK | system | implied | Then the chatbot checks: Filing deadline ? within limitation ? PROCEED |  |
| CP047 | REGIME DETERMINATION | system | implied | Then the system determines: Origin = YYZ (Canada) ? APPR |  |
| CP048 | REGIME DETERMINATION | system | implied | And the system checks: Distance YYZ?YVR = ~3,350 km ? Long-haul (domestic) |  |
| CP049 | TRIAGE & DDS EVALUATION | verdict | api | Then the DDS evaluation is done in backend |  |
| CP050 | TRIAGE & DDS EVALUATION | verdict | api | And DDS Evaluates: | APPR: Delay 3�6h, Controllable ? ELIGIBLE Compensation: CAD $400 |
| CP051 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | Then the chatbot sends case details to CyberSource for fraud screening |  |
| CP052 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | system | implied | And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected) | ELIGIBLE RESULT (FD-05a) � Mobile Web: |
| CP053 | FRAUD SCREENING � CYBERSOURCE (GLOB-05) | bot | chat | Then the chatbot displays: | I've checked your flight details, and it looks like flight AC 103 from Toronto (YYZ) to Vancouver (YVR) was delayed by about 4 hours. Based on the Canadian Air  |
| CP054 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW � Mobile Web | bot | chat | Then the chatbot asks: | Thank you for confirming. In which country will your reimbursement be deposited? |
| CP055 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW � Mobile Web | bot | chat | And the chatbot displays a searchable dropdown (mobile-optimized � opens native mobile picker or scrollable list): | NOTE: On desktop, this is a standard dropdown. On mobile web, it opens the native OS picker (iOS wheel picker / Android dropdown) for better touch interaction. |
| CP056 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW � Mobile Web | customer | chat | And the user selects "Canada" | Canada |
| CP057 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW � Mobile Web | system | implied | Then the system determines: Country = Canada ? Currency = CAD |  |
| CP058 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then the chatbot checks: Does customer have Aeroplan number on booking? ? No |  |
| CP059 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to proc | You are entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed? |
| CP060 | CASH vs AC WALLET CHECK (FD-06b) | alert | chat | And an alert information is displayed: "Please note that payments will be deposited in your local currency." | Please note that payments will be deposited in your local currency. |
| CP061 | CASH vs AC WALLET CHECK (FD-06b) | bot | chat | And the chatbot displays buttons (stacked vertically): | � [Yes, proceed] � [No, cancel] |
| CP062 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | And user taps "Yes, proceed" |  |
| CP063 | CASH vs AC WALLET CHECK (FD-06b) | system | implied | Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada) |  |
| CP064 | PAYMENT METHOD � INTERAC E-TRANSFER � Mobile Web (FD-07) | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer. |
| CP065 | PAYMENT METHOD � INTERAC E-TRANSFER � Mobile Web (FD-07) | customer | chat | And the user types "samantha.wong@gmail.com" | samantha.wong@gmail.com |
| CP066 | PAYMENT METHOD � INTERAC E-TRANSFER � Mobile Web (FD-07) | system | implied | Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded." |  |
| CP067 | PAYMENT METHOD � INTERAC E-TRANSFER � Mobile Web (FD-07) | idv | chat | Then system checks that IDV is not completed |  |
| CP068 | IDENTITY VERIFICATION � PERSONA � Mobile Web (FD-07b) | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP069 | IDENTITY VERIFICATION � PERSONA � Mobile Web (FD-07b) | bot | chat | And chatbot displays a full-width button: [Get verified] | Get verified |
| CP070 | IDENTITY VERIFICATION � PERSONA � Mobile Web (FD-07b) | system | implied | When user taps "Get verified" |  |
| CP071 | IDENTITY VERIFICATION � PERSONA � Mobile Web (FD-07b) | idv | chat | Then system checks if IDV at Payment |  |
| CP072 | IDENTITY VERIFICATION � PERSONA � Mobile Web (FD-07b) | idv | chat | Then system checks if user have consented to IDV |  |
| CP073 | IDENTITY VERIFICATION � PERSONA � Mobile Web (FD-07b) | idv | chat | And the chatbot sends Persona IDV link to the customer |  |
| CP074 | IDENTITY VERIFICATION � PERSONA � Mobile Web (FD-07b) | idv | chat | And Persona opens in the mobile browser |  |
| CP075 | IDENTITY VERIFICATION � PERSONA � Mobile Web (FD-07b) | idv | chat | And the customer completes identity verification via Persona: | ? Camera access: Granted (mobile native camera) ? ? ID photo capture: Mobile camera used (not file upload) ? ? Selfie capture: Front-facing camera used ? ? Touc |
| CP076 | IDENTITY VERIFICATION � PERSONA � Mobile Web (FD-07b) | idv | chat | And Persona returns: IDV PASS |  |
| CP077 | IDENTITY VERIFICATION � PERSONA � Mobile Web (FD-07b) | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. Let's proceed to finalize your claim. |
| CP078 | CLAIM AMOUNT CONFIRMATION FLOW � Mobile Web | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: Interac e-Transfer After submission, you will receive a confirmation email summarizing your eligibility, claim details  |
| CP079 | CLAIM AMOUNT CONFIRMATION FLOW � Mobile Web | alert | chat | And an alert information is displayed: "Please note that the payment details cannot be changed after submission." | Please note that the payment details cannot be changed after submission. |
| CP080 | CLAIM AMOUNT CONFIRMATION FLOW � Mobile Web | bot | chat | And the chatbot displays buttons (stacked vertically): | � [Yes, submit my claim] � [No, go back] |
| CP081 | CLAIM AMOUNT CONFIRMATION FLOW � Mobile Web | system | implied | When the user taps "Yes, submit my claim" |  |
| CP082 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your em | Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your c |
| CP083 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP084 | CASE CREATION (GLOB-09) | system | implied | And the system appends the booking record to the case automatically |  |
| CP085 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP086 | NOTIFICATION | email | email | And an eligible notification email is sent to s***@gmail.com |  |
| CP087 | NOTIFICATION | email | email | And the email contains: Case Reference, compensation amount ($400 CAD), regulation (APPR), flight details, channel (Mobile Web), next steps, | END FLOW (GLOB-11) � Mobile Web: |
| CP088 | NOTIFICATION | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP089 | NOTIFICATION | bot | chat | And the chatbot displays buttons (stacked vertically): | � [Yes, I have another request] � [No, I'm done] |
| CP090 | NOTIFICATION | system | implied | And the user taps "No, I'm done" |  |
| CP091 | NOTIFICATION | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP092 | MOBILE WEB RESPONSIVE RENDERING VALIDATION | idv | chat | ? Language selection buttons: Stacked vertically ? | ? All buttons: Full-width, touch-friendly (min 44px tap target) ? ? Passenger card: Full-width, stacked layout ? ? Flight card: Responsive, full-width, stacked  |
| CP093 | EXPECTED RESULTS | verdict | chat | Mobile web channel detected; All UI components render responsively; Touch targets ?44px; No horizontal scrolling required; Native mobile pic | Mobile web channel detected; All UI components render responsively; Touch targets ?44px; No horizontal scrolling required; Native mobile pickers used for dropdo |
